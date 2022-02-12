#if (CHIP == M68000)
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
#include <signal.h>
#include <minix/config.h>
#include <minix/callnr.h>
#include <minix/com.h>
#include "proc.h"

static void initst();
void panic();
void mdiint();

#define SIZES              8	/* sizes array has 8 entries */

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

  initst();

  /* Clear the process table.
   * Set up mappings for proc_addr() and proc_number() macros.
   */
  for (rp = BEG_PROC_ADDR, t = -NR_TASKS; rp < END_PROC_ADDR; ++rp, ++t) {
        rp->p_flags = P_SLOT_FREE;
        rp->p_nr = t;           /* proc number from ptr */
        (pproc_addr + NR_TASKS)[t] = rp;        /* proc ptr from number */
  }
 
  size = sizes[0] + sizes[1];	/* kernel text + data size */
  base = size;			/* end of kernel */

  ktsb = ((reg_t) t_stack + (ALIGNMENT - 1)) & ~((reg_t) ALIGNMENT - 1);
  for (t = -NR_TASKS; t < 0; t++) {	/* for all drivers */
	rp = proc_addr(t);
	rp->p_flags = 0;
	ktsb += tasktab[t+NR_TASKS].stksize;
	rp->p_reg.sp = ktsb;
	rp->p_splow = rp->p_reg.sp;
	rp->p_reg.pc = (reg_t) tasktab[t + NR_TASKS].initial_pc;
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
  }

  rp = proc_addr(HARDWARE);
  rp->p_map[D].mem_len  = ~0;	/* maximum size */
  rp->p_map[D].mem_phys = 0;
  rp->p_map[D].mem_vir  = 0;

  for (t = 0; t <= LOW_USER; t++) {
	rp = proc_addr(t);
	rp->p_flags = 0;
	lock_ready(rp);
	rp->p_reg.psw = (reg_t)0x0200;	/* no S-BIT, SPL2 */
	rp->p_reg.pc = (reg_t) ((long)base << CLICK_SHIFT);
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
	rp->p_map[T].mem_vir  = rp->p_map[T].mem_phys;
	rp->p_map[D].mem_vir  = rp->p_map[D].mem_phys;
	rp->p_map[S].mem_vir  = rp->p_map[S].mem_phys;
  }

  bill_ptr = proc_addr(HARDWARE);	/* it has to point somewhere */
  lock_pick_proc();

  /* go back to assembly code to start running the current process. */
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


PUBLIC void trap()
{
  register t;
  register struct proc *rp;
  static char vecsig[] = {
	0, 0, SIGSEGV, SIGBUS, SIGILL, SIGILL, SIGILL, SIGABRT,
	SIGILL, SIGTRAP, SIGEMT, SIGFPE, SIGSTKFLT
  };

  rp = proc_ptr;
  t = rp->p_trap;
  if (rp->p_reg.psw & 0x2000) panic("trap via vector", t);
  if (t >= 0 && t < sizeof(vecsig)/sizeof(vecsig[0]) && vecsig[t]) {
	t = vecsig[t];
  } else {
	printf("\nUnexpected trap.  Vector = %d\n", t);
	printf("This may be due to accidentally including\n");
	printf("a non-MINIX library routine that is trying to make a system call.\n");
	t = SIGILL;
  }
  if (t != SIGSTKFLT) {	/* DEBUG */
	printf("sig=%d to pid=%d at pc=%X\n",
		t, rp->p_pid, rp->p_reg.pc);
	dump();
  }
  cause_sig(proc_number(rp), t);
}

PUBLIC void checksp()
{
  register struct proc *rp;
  register phys_bytes ad;

  rp = proc_ptr;
  /* if a user process is is supervisor mode don't check stack */
  if ((rp->p_nr >= 0) && (rp->p_reg.psw & 0x2000)) return;
  if (rp->p_reg.sp < rp->p_splow)
	rp->p_splow = rp->p_reg.sp;
  if (rp->p_map[S].mem_len == 0)
	return;
  ad = (phys_bytes)rp->p_map[S].mem_phys;
  ad <<= CLICK_SHIFT;
  if ((phys_bytes)rp->p_reg.sp > ad)
	return;
  /*
   * Stack violation.
   */
  ad = (phys_bytes)rp->p_map[D].mem_phys;
  ad += (phys_bytes)rp->p_map[D].mem_len;
  ad <<= CLICK_SHIFT;
  if ((phys_bytes)rp->p_reg.sp < ad + CLICK_SIZE)
	printf("Stack low (pid=%d,pc=%X,sp=%X,end=%X)\n",
		rp->p_pid, (long)rp->p_reg.pc,
		(long)rp->p_reg.sp, (long)ad);
  rp->p_trap = 12;	/* fake trap causing SIGSTKFLT */
  trap();
}

/*===========================================================================*
 *                                   panic                                   * 
 *===========================================================================*/
PUBLIC void panic(s,n)
char *s;
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
  dump();
  printf("\nPush RESET button\n");
  for (;;)
	;
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
  SOUND->sd_wdat = SOUND->sd_rdat | PA_PSTROBE;
  /*
   * initialize MFP
   */
  MFP->mf_ierb |= (IB_DINT|IB_AINT|IB_TIMC|IB_PBSY);
  MFP->mf_imrb |= (IB_DINT|IB_AINT|IB_TIMC|IB_PBSY);
  MFP->mf_iera |= (IA_RRDY|IA_RERR|IA_TRDY|IA_TERR);
  MFP->mf_imra |= (IA_RRDY|IA_RERR|IA_TRDY|IA_TERR);
  MFP->mf_vr = V_INIT;
  /*
   * The following code is needed if TOS is not in ROM.
   * It is harmless for more modern systems.
   */
  ad = *((long *)0x042E);	/* TOS variable 'phystop' */
  ad -= 0x8000L;		/* size of VIDEO memory */
  *((long *)0x0436) = ad;	/* TOS variable '_memtop' */
  VIDEO->vd_ramm = (char)(ad >> 8);
  VIDEO->vd_ramh = (char)(ad >> 16);
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
 *				temporary stuff				     *
 *===========================================================================*/

PUBLIC void fake_int(s, t)
char *s;
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

PUBLIC void mdiint(t)
int t;
{
	int code;
	int i;

	for (i = 0; i < 200; i++) 
		if (MDI->ac_cs & A_IRQ)
		{
			code = MDI -> ac_da;
			i = 0;	/* re-start time out */
		}
}

PUBLIC void iob(t)
int t;
{
  fake_int("iob", t);
}

#if (NR_DRIVES == 0)
PUBLIC void fake_task(s)
char *s;
{
  message m;

  /* printf("%s alive\n", s); */
  for (;;) {
	receive(ANY, &m);
	printf("%s received %d from %d\n", s, m.m_type, m.m_source);
  }
}

PUBLIC void winchester_task()
{
  fake_task("winchester_task");
}
#endif

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
#endif
