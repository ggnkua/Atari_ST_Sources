/* This file contains code for initialization of protected mode, to initialize
 * code and data segment descriptors, and to initialize global descriptors
 * for local descriptors in the process table.
 */

#include "kernel.h"
#include "proc.h"
#include "protect.h"

#if _WORD_SIZE == 4
#define INT_GATE_TYPE	(INT_286_GATE | DESC_386_BIT)
#define TSS_TYPE	(AVL_286_TSS  | DESC_386_BIT)
#else
#define INT_GATE_TYPE	INT_286_GATE
#define TSS_TYPE	AVL_286_TSS
#endif

struct desctableptr_s {
  char limit[sizeof(u16_t)];
  char base[sizeof(u32_t)];		/* really u24_t + pad for 286 */
};

struct gatedesc_s {
  u16_t offset_low;
  u16_t selector;
  u8_t pad;			/* |000|XXXXX| ig & trpg, |XXXXXXXX| task g */
  u8_t p_dpl_type;		/* |P|DL|0|TYPE| */
#if _WORD_SIZE == 4
  u16_t offset_high;
#else
  u16_t reserved;
#endif
};

struct tss_s {
  reg_t backlink;
  reg_t sp0;                    /* stack pointer to use during interrupt */
  reg_t ss0;                    /*   "   segment  "  "    "        "     */
  reg_t sp1;
  reg_t ss1;
  reg_t sp2;
  reg_t ss2;
#if _WORD_SIZE == 4
  reg_t cr3;
#endif
  reg_t ip;
  reg_t flags;
  reg_t ax;
  reg_t cx;
  reg_t dx;
  reg_t bx;
  reg_t sp;
  reg_t bp;
  reg_t si;
  reg_t di;
  reg_t es;
  reg_t cs;
  reg_t ss;
  reg_t ds;
#if _WORD_SIZE == 4
  reg_t fs;
  reg_t gs;
#endif
  reg_t ldt;
#if _WORD_SIZE == 4
  u16_t trap;
  u16_t iobase;
/* u8_t iomap[0]; */
#endif
};

PUBLIC struct segdesc_s gdt[GDT_SIZE];
PRIVATE struct gatedesc_s idt[IDT_SIZE];	/* zero-init so none present */
PUBLIC struct tss_s tss;	/* zero init */

FORWARD _PROTOTYPE( void int_gate, (unsigned vec_nr, phys_bytes base,
		unsigned dpl_type) );
FORWARD _PROTOTYPE( void sdesc, (struct segdesc_s *segdp, phys_bytes base,
		phys_bytes size) );

/*=========================================================================*
 *				prot_init				   *
 *=========================================================================*/
PUBLIC void prot_init()
{
/* Set up tables for protected mode.
 * All GDT slots are allocated at compile time.
 */

  extern int etext, end;
#define code_bytes ((phys_bytes) &etext)	/* Size of code segment. */
#define data_bytes ((phys_bytes) &end)		/* Size of data segment. */
  struct gate_table_s *gtp;
  struct desctableptr_s *dtp;
  unsigned ldt_selector;
  register struct proc *rp;

  static struct gate_table_s {
	_PROTOTYPE( void (*gate), (void) );
	unsigned char vec_nr;
	unsigned char privilege;
  }
  gate_table[] = {
	divide_error, DIVIDE_VECTOR, INTR_PRIVILEGE,
	single_step_exception, DEBUG_VECTOR, INTR_PRIVILEGE,
	nmi, NMI_VECTOR, INTR_PRIVILEGE,
	breakpoint_exception, BREAKPOINT_VECTOR, USER_PRIVILEGE,
	overflow, OVERFLOW_VECTOR, USER_PRIVILEGE,
	bounds_check, BOUNDS_VECTOR, INTR_PRIVILEGE,
	inval_opcode, INVAL_OP_VECTOR, INTR_PRIVILEGE,
	copr_not_available, COPROC_NOT_VECTOR, INTR_PRIVILEGE,
	double_fault, DOUBLE_FAULT_VECTOR, INTR_PRIVILEGE,
	copr_seg_overrun, COPROC_SEG_VECTOR, INTR_PRIVILEGE,
	inval_tss, INVAL_TSS_VECTOR, INTR_PRIVILEGE,
	segment_not_present, SEG_NOT_VECTOR, INTR_PRIVILEGE,
	stack_exception, STACK_FAULT_VECTOR, INTR_PRIVILEGE,
	general_protection, PROTECTION_VECTOR, INTR_PRIVILEGE,
#if _WORD_SIZE == 4
	page_fault, PAGE_FAULT_VECTOR, INTR_PRIVILEGE,
	copr_error, COPROC_ERR_VECTOR, INTR_PRIVILEGE,
#endif
	{ hwint00, VECTOR( 0), INTR_PRIVILEGE },
	{ hwint01, VECTOR( 1), INTR_PRIVILEGE },
	{ hwint02, VECTOR( 2), INTR_PRIVILEGE },
	{ hwint03, VECTOR( 3), INTR_PRIVILEGE },
	{ hwint04, VECTOR( 4), INTR_PRIVILEGE },
	{ hwint05, VECTOR( 5), INTR_PRIVILEGE },
	{ hwint06, VECTOR( 6), INTR_PRIVILEGE },
	{ hwint07, VECTOR( 7), INTR_PRIVILEGE },
	{ hwint08, VECTOR( 8), INTR_PRIVILEGE },
	{ hwint09, VECTOR( 9), INTR_PRIVILEGE },
	{ hwint10, VECTOR(10), INTR_PRIVILEGE },
	{ hwint11, VECTOR(11), INTR_PRIVILEGE },
	{ hwint12, VECTOR(12), INTR_PRIVILEGE },
	{ hwint13, VECTOR(13), INTR_PRIVILEGE },
	{ hwint14, VECTOR(14), INTR_PRIVILEGE },
	{ hwint15, VECTOR(15), INTR_PRIVILEGE },
#if _WORD_SIZE == 2
	{ p_s_call, SYS_VECTOR, USER_PRIVILEGE },	/* 286 system call */
#else
	{ s_call, SYS386_VECTOR, USER_PRIVILEGE },	/* 386 system call */
#endif
	{ level0_call, LEVEL0_VECTOR, TASK_PRIVILEGE },
  };

  /* Build gdt and idt pointers in GDT where the BIOS expects them. */
  dtp= (struct desctableptr_s *) &gdt[GDT_INDEX];
  * (u16_t *) dtp->limit = (sizeof gdt) - 1;
  * (u32_t *) dtp->base = vir2phys(gdt);

  dtp= (struct desctableptr_s *) &gdt[IDT_INDEX];
  * (u16_t *) dtp->limit = (sizeof idt) - 1;
  * (u32_t *) dtp->base = vir2phys(idt);

  /* Build segment descriptors for tasks and interrupt handlers. */
  init_codeseg(&gdt[CS_INDEX], code_base, code_bytes, INTR_PRIVILEGE);
  init_dataseg(&gdt[DS_INDEX], data_base, data_bytes, INTR_PRIVILEGE);
  init_dataseg(&gdt[ES_INDEX], 0L, 0L, TASK_PRIVILEGE);

  /* Build scratch descriptors for functions in klib88. */
  init_dataseg(&gdt[DS_286_INDEX], (phys_bytes) 0,
	       (phys_bytes) MAX_286_SEG_SIZE, TASK_PRIVILEGE);
  init_dataseg(&gdt[ES_286_INDEX], (phys_bytes) 0,
	       (phys_bytes) MAX_286_SEG_SIZE, TASK_PRIVILEGE);

  /* Build local descriptors in GDT for LDT's in process table.
   * The LDT's are allocated at compile time in the process table, and
   * initialized whenever a process' map is initialized or changed.
   */
  for (rp = BEG_PROC_ADDR, ldt_selector = FIRST_LDT_INDEX * DESC_SIZE;
       rp < END_PROC_ADDR; ++rp, ldt_selector += DESC_SIZE) {
	init_dataseg(&gdt[ldt_selector / DESC_SIZE], vir2phys(rp->p_ldt),
		     (phys_bytes) sizeof rp->p_ldt, INTR_PRIVILEGE);
	gdt[ldt_selector / DESC_SIZE].access = PRESENT | LDT;
	rp->p_ldt_sel = ldt_selector;
  }

  /* Build main TSS.
   * This is used only to record the stack pointer to be used after an
   * interrupt.
   * The pointer is set up so that an interrupt automatically saves the
   * current process's registers ip:cs:f:sp:ss in the correct slots in the
   * process table.
   */
  tss.ss0 = DS_SELECTOR;
  init_dataseg(&gdt[TSS_INDEX], vir2phys(&tss), (phys_bytes) sizeof tss,
  							INTR_PRIVILEGE);
  gdt[TSS_INDEX].access = PRESENT | (INTR_PRIVILEGE << DPL_SHIFT) | TSS_TYPE;

  /* Build descriptors for interrupt gates in IDT. */
  for (gtp = &gate_table[0];
       gtp < &gate_table[sizeof gate_table / sizeof gate_table[0]]; ++gtp) {
	int_gate(gtp->vec_nr, (phys_bytes) (vir_bytes) gtp->gate,
		 PRESENT | INT_GATE_TYPE | (gtp->privilege << DPL_SHIFT));
  }

#if _WORD_SIZE == 4
  /* Complete building of main TSS. */
  tss.iobase = sizeof tss;	/* empty i/o permissions map */
#endif
}

/*=========================================================================*
 *				init_codeseg				   *
 *=========================================================================*/
PUBLIC void init_codeseg(segdp, base, size, privilege)
register struct segdesc_s *segdp;
phys_bytes base;
phys_bytes size;
int privilege;
{
/* Build descriptor for a code segment. */

  sdesc(segdp, base, size);
  segdp->access = (privilege << DPL_SHIFT)
	        | (PRESENT | SEGMENT | EXECUTABLE | READABLE);
		/* CONFORMING = 0, ACCESSED = 0 */
}

/*=========================================================================*
 *				init_dataseg				   *
 *=========================================================================*/
PUBLIC void init_dataseg(segdp, base, size, privilege)
register struct segdesc_s *segdp;
phys_bytes base;
phys_bytes size;
int privilege;
{
/* Build descriptor for a data segment. */

  sdesc(segdp, base, size);
  segdp->access = (privilege << DPL_SHIFT) | (PRESENT | SEGMENT | WRITEABLE);
		/* EXECUTABLE = 0, EXPAND_DOWN = 0, ACCESSED = 0 */
}

/*=========================================================================*
 *				sdesc					   *
 *=========================================================================*/
PRIVATE void sdesc(segdp, base, size)
register struct segdesc_s *segdp;
phys_bytes base;
phys_bytes size;
{
/* Fill in the size fields (base, limit and granularity) of a descriptor. */

  segdp->base_low = base;
  segdp->base_middle = base >> BASE_MIDDLE_SHIFT;

#if _WORD_SIZE == 4
  segdp->base_high = base >> BASE_HIGH_SHIFT;
  --size;			/* convert to a limit, 0 size means 4G */
  if (size > BYTE_GRAN_MAX) {
	segdp->limit_low = size >> PAGE_GRAN_SHIFT;
	segdp->granularity = GRANULAR | (size >>
				     (PAGE_GRAN_SHIFT + GRANULARITY_SHIFT));
  } else {
	segdp->limit_low = size;
	segdp->granularity = size >> GRANULARITY_SHIFT;
  }
  segdp->granularity |= DEFAULT;	/* means BIG for data seg */
#else
  segdp->limit_low = size - 1;
#endif
}

/*=========================================================================*
 *				seg2phys				   *
 *=========================================================================*/
PUBLIC phys_bytes seg2phys(seg)
U16_t seg;
{
/* Return the base address of a segment, with seg being either a 8086 segment
 * register, or a 286/386 segment selector.
 */
  phys_bytes base;
  struct segdesc_s *segdp;

  if (!protected_mode) {
	base = hclick_to_physb(seg);
  } else {
	segdp = &gdt[seg >> 3];
	base = segdp->base_low | ((u32_t) segdp->base_middle << 16);
#if _WORD_SIZE == 4
	base |= ((u32_t) segdp->base_high << 24);
#endif
  }
  return base;
}

/*=========================================================================*
 *				int_gate				   *
 *=========================================================================*/
PRIVATE void int_gate(vec_nr, base, dpl_type)
unsigned vec_nr;
phys_bytes base;
unsigned dpl_type;
{
/* Build descriptor for an interrupt gate. */

  register struct gatedesc_s *idp;

  idp = &idt[vec_nr];
  idp->offset_low = base;
  idp->selector = CS_SELECTOR;
  idp->p_dpl_type = dpl_type;
#if _WORD_SIZE == 4
  idp->offset_high = base >> OFFSET_HIGH_SHIFT;
#endif
}

/*=========================================================================*
 *				enable_iop				   *
 *=========================================================================*/
PUBLIC void enable_iop(pp)
struct proc *pp;
{
/* Allow a user process to use I/O instructions.  Change the I/O Permission
 * Level bits in the psw. These specify least-privileged Current Permission
 * Level allowed to execute I/O instructions. Users and servers have CPL 3. 
 * You can't have less privilege than that. Kernel has CPL 0, tasks CPL 1.
 */
  pp->p_reg.psw |= 0x3000;
}
