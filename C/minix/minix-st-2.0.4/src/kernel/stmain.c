/* This file contains the main program of MINIX for the Atari ST.
 * The routine main() initializes the system and starts the ball
 * rolling by setting up the proc table, interrupt vectors, and
 * scheduling each task to run to initialize itself.
 * 
 * The entries into this file are:
 *   main:		MINIX main program
 *   none:		called for an interrupt to an unused vector
 *   rupt:		called for an unexpected interrupt (async)
 *   trap:		called for an unexpected trap (synchronous)
 *   panic:		abort MINIX due to a fatal error
 */

#include "kernel.h"
#if (MACHINE == ATARI)
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <minix/callnr.h>
#include <minix/com.h>
#include <minix/boot.h>
#include "proc.h"
/*#include "tty.h"*/

FORWARD _PROTOTYPE( void initst, (void)					);
FORWARD _PROTOTYPE( void fake_task, (char *s)				);
FORWARD _PROTOTYPE( void k_putenv, (_CONST char *name, _CONST char *val));
FORWARD _PROTOTYPE( char *ul2a, (u32_t n, unsigned base)		);

/* Environment strings. */
#define	ENV_SIZE	192
PRIVATE char k_environ[ENV_SIZE];
PRIVATE char *ep = k_environ;

#define	ALIGNMENT	   4

/*===========================================================================*
 *                                   main                                    * 
 *===========================================================================*/
PUBLIC void main()
{
/* Start the ball rolling. */

  register struct proc *rp;
  register int t;
  register vir_clicks size;
  register phys_clicks base;
  reg_t ktsb;
  unsigned long memsiz;
  struct tasktab *ttp;

  mem[1].size = 0;	/* initialize */
#if FIXED_MEM_SIZE
  mem[0].base = 0;
  mem[0].size = (vir_clicks)((FIXED_MEM_SIZE*1024*1024) >> CLICK_SHIFT);
#else
  mem[0].base = 0;
  mem[0].size = (vir_clicks)(get_mem_size((char *)0) >> CLICK_SHIFT);
#if (ATARI_TYPE == TT)
  /* check the TT fast ram */
  memsiz = get_mem_size((char *)0x1000000);
  if (memsiz != 0)
  {
    mem[1].base = (vir_clicks)(0x1000000 >> CLICK_SHIFT);
    mem[1].size = (vir_clicks)(memsiz >> CLICK_SHIFT);
  }
#else
  /* if the first scan got less than 4MB check for MULTIBOARD */
  if (mem[0].size <= (vir_clicks)(0x400000L >> CLICK_SHIFT)) {
	/* check for H&N Multiboard */
	memsiz = get_mem_size((char *)0x400000);
	if (memsiz != 0)
	{
		mem[1].base = (vir_clicks)(0x400000 >> CLICK_SHIFT);
		mem[1].size = (vir_clicks)(memsiz >> CLICK_SHIFT);
	}
  }
#endif /* ATARI_TYPE == TT */
#endif /* FIXED_MEM_SIZE */
  tot_mem_size = mem[0].size + mem[1].size;	/* total RAM */

  /* go back to assembly code to start running the current process. */
  initst();
#if (SHADOWING == 0)
  pmmuinit();
#endif /* SHADOWING */

  /* Clear the process table.
   * Set up mappings for proc_addr() and proc_number() macros.
   */
  for (rp = BEG_PROC_ADDR, t = -NR_TASKS; rp < END_PROC_ADDR; ++rp, ++t) {
        rp->p_priority = PPRI_NONE;
        rp->p_nr = t;           /* proc number from ptr */
        (pproc_addr + NR_TASKS)[t] = rp;        /* proc ptr from number */
  }

  mapdrivers();

  size = sizes[0] + sizes[1];	/* kernel text + data size */
  base = size;			/* end of kernel */

  ktsb = ((reg_t) t_stack + (ALIGNMENT - 1)) & ~((reg_t) ALIGNMENT - 1);

  for (t = -NR_TASKS; t <= LOW_USER; t++) {	/* for all drivers */
	rp = proc_addr(t);			/* t's process slot */
	ttp = &tasktab[t + NR_TASKS];		/* t's task attributes */
	strcpy(rp->p_name, ttp->name);
	if (t < 0) {				/* kernel task */
		if (ttp->stksize > 0) {
			rp->p_stguard = (reg_t *) ktsb;
			*rp->p_stguard = STACK_GUARD;
		}
		ktsb += ttp->stksize;
		rp->p_reg.sp = ktsb;
		rp->p_splow = rp->p_reg.sp;
		rp->p_reg.pc = (reg_t) ttp->initial_pc;
		rp->p_priority = PPRI_TASK;
		if (!isidlehardware(t)) {
			lock_ready(rp);	/* IDLE, HARDWARE neveready */
			rp->p_reg.psw = 0x2200;	/* S-BIT, SPL2 */
		} else {
			rp->p_reg.psw = 0x0200;	/* SPL2 */
		}
		rp->p_map[T].mem_len  = sizes[0];
	/*	rp->p_map[T].mem_phys = 0; */
		rp->p_map[D].mem_len  = sizes[1]; 
		rp->p_map[D].mem_phys = sizes[0];
	/*	rp->p_map[S].mem_len  = 0; */
		rp->p_map[S].mem_phys = size;
	/*	rp->p_map[T].mem_vir  = rp->p_map[T].mem_phys; */
		rp->p_map[D].mem_vir  = rp->p_map[D].mem_phys;
		rp->p_map[S].mem_vir  = rp->p_map[S].mem_phys;
#if (SHADOWING == 0)
		rp->p_crp = (char *)0;	/* kernel tasks do not use the mmu */
		if (isidlehardware(t)) {
			pmmu_init_proc(rp);
		}
#endif /* SHADOWING */
	} else {				/* MM, FS, INET, INIT */
		rp->p_reg.psw = (reg_t)0x0200;	/* no S-BIT, SPL2 */
#if (SHADOWING == 0)
		rp->p_reg.pc = (reg_t) 0;
#else
		rp->p_reg.pc = (reg_t) ((long)base << CLICK_SHIFT);
#endif /* SHADOWING */
		size = sizes[2*t + 2];
		rp->p_map[T].mem_len  = size;
		rp->p_map[T].mem_phys = base;
		base += size;
		size = sizes[2*t + 3];
		rp->p_map[D].mem_len  = size;
		rp->p_map[D].mem_phys = base;
		base += size;
		rp->p_map[S].mem_len  = 0;
		rp->p_map[S].mem_phys = base;
		/* setup stack */
		rp->p_reg.sp = (reg_t) ((long) base << CLICK_SHIFT) - 4;
		rp->p_splow = rp->p_reg.sp;
		* (reg_t *) rp->p_splow = 0; 	/* argc = 0, user task */
/*		rp->p_stguard = (reg_t *) rp->p_reg.sp;
		*rp->p_stguard = STACK_GUARD;*/	/* not very useful */
		rp->p_priority = t < LOW_USER ? PPRI_SERVER : PPRI_USER;
		lock_ready(rp);
#if (SHADOWING == 0)
		rp->p_map[T].mem_vir = 0;
		rp->p_map[D].mem_vir = rp->p_map[T].mem_len;
		rp->p_map[S].mem_vir = rp->p_map[T].mem_len +
				       rp->p_map[D].mem_len;
		pmmu_init_proc(rp);
#else
		rp->p_map[T].mem_vir = rp->p_map[T].mem_phys;
		rp->p_map[D].mem_vir = rp->p_map[D].mem_phys;
		rp->p_map[S].mem_vir = rp->p_map[S].mem_phys;
#endif /* SHADOWING */
#ifdef FPP
		/* initialize fpp for this process */
		fpp_new_state(rp);
#endif /* FPP */
  	}
	rp->p_flags = 0;
  }

  rp = proc_addr(HARDWARE);
  rp->p_map[D].mem_len  = ~0;	/* maximum size */
  rp->p_map[D].mem_phys = 0;
  rp->p_map[D].mem_vir  = 0;
#if (SHADOWING == 0)
  pmmu_init_proc(rp);
#endif /* SHADOWING */

  mem[0].size -= base;			/* used by system */
  mem[0].base += base;			/* memory no longer free */

  proc[NR_TASKS+INIT_PROC_NR].p_pid = 1;/* INIT of course has pid 1 */
  bill_ptr = proc_addr(HARDWARE);	/* it has to point somewhere */
  proc_addr(IDLE)->p_priority = PPRI_IDLE;
  lock_pick_proc();
}


/*===========================================================================*
 *                              none, rupt, trap                             * 
 *===========================================================================*/
PUBLIC void none()
{
  panic("Nonexisting interrupt. Vector =", proc_ptr->p_trap);
}

PUBLIC void rupt()
{
  panic("Unexpected interrupt.  Vector =", proc_ptr->p_trap);
}

static unsigned long dummy;
#define	LOOP_COUNT 0x40000L

PUBLIC void trap()
{
  register int t;
  register struct proc *rp;
  static char vecsig[] = {
	0, 0, SIGSEGV, SIGBUS, SIGILL, SIGILL, SIGILL, SIGABRT,
	SIGILL, SIGTRAP, SIGEMT, SIGFPE, SIGSTKFLT
  };

  rp = proc_ptr;
  t = rp->p_trap;
  if (rp->p_reg.psw & 0x2000)
  {
#ifdef FPP
	if (t >= 48 && t <= 54) return;
#endif
	p_dmp();
  	panic("trap via vector", t);
  }
  if (t >= 0 && t < sizeof(vecsig)/sizeof(vecsig[0]) && vecsig[t]) {
	t = vecsig[t];
#ifdef FPP
  } else if( t >= 48 && t <= 54 ) {	
	t = SIGFPE;
#endif
  } else {
	printf("\nUnexpected trap.  Vector = %d\n", t);
	printf("This may be due to accidentally including\n");
	printf("a non-MINIX library routine that is trying to make a system call.\n");
	t = SIGILL;
  }

  if (t != SIGSTKFLT && t != SIGTRAP) {	/* DEBUG */
	printf("sig=%d to pid=%d at pc=%lx\n",
		t, rp->p_pid, rp->p_reg.pc);
/*	for (dummy=0;dummy<LOOP_COUNT;dummy++) ;
	dump();*/
  }

  cause_sig(proc_number(rp), t);
}

/*===========================================================================*
 *                              checksp		                             * 
 *===========================================================================*/
PUBLIC void checksp()
{
  register struct proc *rp;
  register phys_bytes ad;

  rp = proc_ptr;
  /* if a user process is in supervisor mode don't check stack */
  if ((rp->p_nr >= 0) && (rp->p_reg.psw & 0x2000)) return;
  if ((rp->p_reg.sp < rp->p_splow) || (rp->p_splow == 0))
	rp->p_splow = rp->p_reg.sp;
  if (rp->p_map[S].mem_len == 0)
	return;
  ad = (phys_bytes)rp->p_map[S].mem_vir << CLICK_SHIFT;
  if ((phys_bytes)rp->p_reg.sp > ad)
	return;
  /*
   * Stack violation.
   */
  ad = (phys_bytes)rp->p_map[D].mem_vir;
  ad += (phys_bytes)rp->p_map[D].mem_len;
  ad <<= CLICK_SHIFT;
  if ((phys_bytes)rp->p_reg.sp < ad + CLICK_SIZE)
	printf("Stack low (pid=%d,pc=%lx,sp=%lx,end=%lx)\n",
		rp->p_pid, (long)rp->p_reg.pc,
		(long)rp->p_reg.sp, (long)ad);

  rp->p_trap = 12;	/* fake trap causing SIGSTKFLT */
  trap();
}

/*===========================================================================*
 *                                   panic                                   * 
 *===========================================================================*/
PUBLIC void panic(s,n)
_CONST char *s;
int n; 
{
/* The system has run aground of a fatal error.  Terminate execution.
 * If the panic originated in MM or FS, the string will be empty and the
 * file system already syncked.  If the panic originates in the kernel, we are
 * kind of stuck. 
 */

  if (*s != 0) {
	printf("\nKernel panic: %s",s); 
	if (n != NO_NUM) printf(" %d", n);
	printf("\n");
  }
/*  for (dummy=0;dummy<LOOP_COUNT;dummy++) ;
  dump();*/
#ifdef REBOOT_AFTER_PANIC
  wreboot(RBT_REBOOT);
#else
  printf("\nPush RESET button\n");
  for (;;)
	;
#endif /* REBOOT_AFTER_PANIC */
}

/*==========================================================================*
 *				wreboot					    *
 *==========================================================================*/
PUBLIC void wreboot(how)
int how;		/* 0 = halt, 1 = reboot, 2 = panic!, ... */
{
/* Wait for keystrokes for printing debugging info and reboot. */
  long l;
  switch (how) {
    case RBT_HALT:
  	printf("\nSystem halted");
  	for (;;);
	break;
	/* notreached */
    case RBT_REBOOT:
    	printf("\nRebooting ...");
	for (l=0; l<512000; l++) ;
    	kreboot();
	break;
    	/* notreached */
    case RBT_PANIC:
    	panic("", how);
	break;
    	/* notreached */
    default:
    	panic("", how);
    	/* notreached */
  }
  /* notreached */
}  
  
/*==========================================================================*
 *				getenv					    *
 *==========================================================================*/
PUBLIC char *getenv(name)
_CONST char *name;
{
/* Get environment value - kernel version of getenv to avoid setting up the
 * usual environment array.
 */

  register _CONST char *namep;
  register char *envp;

  for (envp = k_environ; *envp != 0;) {
	for (namep = name; *namep != 0 && *namep == *envp; namep++, envp++)
		;
	if (*namep == '\0' && *envp == '=') return(envp + 1);
	while (*envp++ != 0)
		;
  }
  return(NIL_PTR);
}


/*
 * Atari ST specific initialization.
 */

#include "staddr.h"
#include "stacia.h"
#include "stmfp.h"
#include "stsound.h"
#include "stvideo.h"

/*===========================================================================*
 *                                   initst                                   * 
 *===========================================================================*/
PRIVATE void initst()
{
  long ad;

  /*
   * both 8-bit ports of the sound chip are configured for output
   */
  SOUND->sd_selr = YM_MFR;
  SOUND->sd_wdat = PA_OUT|PB_OUT;
  /*
   * init port A (Note: low 3 bits inverted)
   */
  SOUND->sd_selr = YM_IOA;
#if (SPEEDUP16 == 1)
  SOUND->sd_wdat = SOUND->sd_rdat | PA_PSTROBE | PA_FDDENS;
#else
  SOUND->sd_wdat = SOUND->sd_rdat | PA_PSTROBE;
#endif /* SPEEDUP16 */
  /*
   * initialize MFP
   */
  MFP->mf_ierb |= (IB_DINT|IB_AINT|IB_TIMC|IB_PBSY);
  MFP->mf_imrb |= (IB_DINT|IB_AINT|IB_TIMC|IB_PBSY);
  MFP->mf_iera |= (IA_RRDY|IA_RERR|IA_TRDY|IA_TERR);
  MFP->mf_imra |= (IA_RRDY|IA_RERR|IA_TRDY|IA_TERR);
  MFP->mf_vr = V_INIT;
  
#if (ATARI_TYPE == TT)
  /*
   * initialize 2nd MFP
   */
  MFP2->mf_vr = V_INIT2;
  MFP2->mf_ierb |= (IB_DINT);
  MFP2->mf_imrb |= (IB_DINT);
  MFP2->mf_iera |= (IA_SCSI);
  MFP2->mf_imra |= (IA_SCSI);
#endif /* ATARI_TYPE == TT */

  /*
   * The following code is needed if TOS is not in ROM.
   * It is harmless for more modern systems.
   */
  ad = (unsigned long)(mem[0].base + mem[0].size) << CLICK_SHIFT;
  ad &= 0xffffff00;		/* align on 256 byte boundary for ST */

#if (ATARI_TYPE == TT)
  ad -= 320*480L;
#else
  ad -= 0x7d00L;		/* size of VIDEO memory */
#endif /* ATARI_TYPE == TT */
  mem[0].size = (vir_bytes)(ad >> CLICK_SHIFT) - mem[0].base;
  vdusetup((unsigned int)(VIDEO->vd_st_res), (char *)ad, VIDEO->vd_st_rgb);

/* warning: fs expects decimal numbers */
#if 0
  k_putenv("rootdev", ul2a((unsigned long) DEV_RAM, 10));
#endif
#if 0
  k_putenv("rootdev", ul2a((unsigned long) DEV_FD0+4, 10));
#endif
#if 1
  k_putenv("rootdev", ul2a((unsigned long) DEV_HD0+4, 10));
#endif
  k_putenv("ramimagedev", ul2a((unsigned long) DEV_FD0+5, 10));
  k_putenv("ramsize", ul2a((unsigned long) 0, 10));	/* size of ramdisk */
  k_putenv("processor", ul2a((unsigned long) M68000, 10));
  k_putenv("c0", "ACSI");
  k_putenv("NR_BUFS", ul2a((unsigned long) NR_BUFS, 10));
  k_putenv("DMA_SECTORS", ul2a((unsigned long) DMA_SECTORS, 10));
  k_putenv("ENABLE_SYMLINKS", ul2a((unsigned long) ENABLE_SYMLINKS, 10));
  k_putenv("ENABLE_SWAP", ul2a((unsigned long) ENABLE_SWAP, 10));
  k_putenv("NR_CONS", ul2a((unsigned long) NR_CONS, 10));
  k_putenv("NR_PTYS", ul2a((unsigned long) NR_PTYS, 10));
  mon_params = (phys_bytes) k_environ;
  mon_parmsize = ep - k_environ + 1;
}

/*===========================================================================*
 *				aciaint					     *
 *===========================================================================*/
PUBLIC void aciaint()
{
  if (KBD->ac_cs & A_IRQ)
	kbdint();
  if (MDI->ac_cs & A_IRQ)
	mdiint();
}

/*===========================================================================*
 *				idle task				     *
 *===========================================================================*/
PUBLIC void idle_task()
{
#if 0
    /* the following code is useful to determine stack sizes */
    static int beenhere = 0;
    int t;
    reg_t ktsb;
    register struct proc *rp;

    if (!beenhere)
    {
	beenhere = 1;
  	ktsb = ((reg_t) t_stack + (ALIGNMENT - 1)) & ~((reg_t) ALIGNMENT - 1);
	for (t = 0; t < NR_TASKS; t++)
	{
	    ktsb += tasktab[t].stksize;
	    printf("task %s, stack start: %lx\n", tasktab[t].name, ktsb);
	}
	for (t = 0; t <= LOW_USER; t++) {
	    rp = proc_addr(t);
  	    if (rp->p_splow == 0)
		rp->p_splow = rp->p_reg.sp;
	}
    }
#endif
    while (1);
}

/*===========================================================================*
 *			fake kernel environment stuff			     *
 *===========================================================================*/
PRIVATE void k_putenv(name, val)
_CONST char *name;
_CONST char *val;
{
  /* append "name=num\0" to k_environ */
  strcpy(ep, name);
  strcat(ep, "=");
  strcat(ep, val);
  while (*ep++)
	;
  *ep = '\0';
}

#define arraysize(a)             (sizeof(a) / sizeof((a)[0]))
#define arraylimit(a)            ((a) + arraysize(a))

PRIVATE char *ul2a(n, b)
u32_t n;
unsigned b;
/* Transform a long number to ascii at base b, (b >= 8). */
{
  static char num[(CHAR_BIT * sizeof(n) + 2) / 3 + 1];
  char *a= arraylimit(num) - 1;
  static char hex[16] = "0123456789ABCDEF";

  do *--a = hex[(int) (n % b)]; while ((n/= b) > 0);
  return a;
}

/*===========================================================================*
 *				temporary stuff				     *
 *===========================================================================*/
PUBLIC void fake_int(s, t)
const char *s;
int t;
{
  if (t != 0x03)
    printf("Fake interrupt handler for %s. trap = %02x\n", s, t);
}

PUBLIC void timint(t)
int t;
{
  fake_int("timint", t);
}

PUBLIC void mdiint()
{
  int code;
  int i;

  for (i = 0; i < 200; i++) 
	if (MDI->ac_cs & A_IRQ) {
		code = MDI -> ac_da;
		i = 0;	/* re-start time out */
	}
}

PUBLIC void iob(t)
int t;
{
  fake_int("iob", t);
}

PRIVATE void fake_task(s)
char *s;
{
  message m;

  /* printf("%s alive\n", s); */
  for (;;) {
	receive(ANY, &m);
	printf("%s received %d from %d\n", s, m.m_type, m.m_source);
  }
}

#if (NR_ACSI_DRIVES == 0)
PUBLIC void winchester_task()
{
  fake_task("winchester_task");
}
#endif

#if (NR_SCSI_DRIVES == 0)
PUBLIC void scsi_task()
{
  fake_task("scsi_task");
}
#endif

#if (NR_FD_DRIVES == 0)
PUBLIC void floppy_task()
{
  fake_task("floppy_task");
}
#endif

#endif
