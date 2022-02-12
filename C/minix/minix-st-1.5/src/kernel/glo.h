/* Global variables used in the kernel. */

/* EXTERN is defined as extern except in table.c. */
#ifdef _TABLE
#undef EXTERN
#define EXTERN
#endif

/* Kernel memory. */
EXTERN phys_bytes code_base;	/* base of kernel code */
EXTERN phys_bytes data_base;	/* base of kernel data */

/* Low level interrupt communications. */
EXTERN struct proc *held_head;	/* head of queue of held-up interrupts */
EXTERN struct proc *held_tail;	/* tail of queue of held-up interrupts */
EXTERN unsigned char k_reenter;	/* kernel reentry count (entry count less 1)*/

/* Process table.  Here to stop too many things having to include proc.h. */
EXTERN struct proc *proc_ptr;	/* pointer to currently running process */

/* Signals. */
EXTERN int sig_procs;		/* number of procs with p_pending != 0 */

/* Miscellaneous. */
extern u16_t sizes[8];		/* table filled in by build */
extern struct tasktab tasktab[];	/* see table.c */
extern char t_stack[];		/* see table.c */

#if (CHIP == INTEL)

/* Machine type. */
EXTERN int pc_at;		/* PC-AT compatible hardware interface */
EXTERN int ps;			/* PS/2 */
EXTERN int ps_mca;		/* PS/2 with Micro Channel */
EXTERN int port_65;		/* saved contents of Planar Control Register */
EXTERN unsigned processor;	/* 86, 186, 286, 386, ... */
EXTERN int protected_mode;	/* nonzero if running in Intel protected mode*/
extern int using_bios;		/* nonzero to force real mode (for bios_wini)*/

/* Video cards and keyboard types. */
EXTERN int color;		/* nonzero if console is color, 0 if mono */
EXTERN int ega;			/* nonzero if console is EGA */
EXTERN int scan_code;		/* scan code of key pressed to start minix */
EXTERN int snow;		/* nonzero if screen needs snow removal */

/* Memory sizes. */
EXTERN unsigned ext_memsize;	/* initialized by assembler startup code */
EXTERN unsigned low_memsize;
EXTERN phys_clicks mem_base[NR_MEMS];	/* bases of chunks of memory */
EXTERN phys_clicks mem_size[NR_MEMS];	/* sizes of chunks of memory */
EXTERN unsigned char mem_type[NR_MEMS];	/* types of chunks of memory */

/* Miscellaneous. */
EXTERN u16_t Ax, Bx, Cx, Dx, Es;	/* to hold registers for BIOS calls */
EXTERN struct farptr_s break_vector;	/* debugger breakpoint hook */
EXTERN int db_enabled;		/* nonzero if external debugger is enabled */
EXTERN int db_exists;		/* nonzero if external debugger exists */
extern struct segdesc_s gdt[];	/* global descriptor table for protected mode*/
EXTERN struct farptr_s sstep_vector;	/* debugger single-step hook */
EXTERN u16_t vec_table[VECTOR_BYTES / sizeof(u16_t)]; /* copy of BIOS vectors*/

#endif /* (CHIP == INTEL) */

#if (CHIP == M68000)
EXTERN int flush_flag;		/* tells clock when to flush the tty buf */
extern unsigned char font8[];	/* 8 pixel wide font table */
extern unsigned char font16[];	/* 16 pixel wide font table */
extern int keypad;		/* Flag for keypad mode */
extern int app_mode;		/* Flag for arrow key application mode */
#endif
