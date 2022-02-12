/* This file contains the main program of MINIX.  The routine main()
 * initializes the system and starts the ball rolling by setting up the proc
 * table, interrupt vectors, and scheduling each task to run to initialize
 * itself.
 *
 * The entries into this file are:
 *   main:		MINIX main program
 *   panic:		abort MINIX due to a fatal error
 */

#include "kernel.h"
#include <signal.h>
#include <unistd.h>
#include <a.out.h>
#include <minix/callnr.h>
#include <minix/com.h>
#include "proc.h"


/*===========================================================================*
 *                                   main                                    *
 *===========================================================================*/
PUBLIC void main()
{
/* Start the ball rolling. */

  register struct proc *rp;
  register int t;
  int hdrindex;
  phys_clicks text_base;
  vir_clicks text_clicks;
  vir_clicks data_clicks;
  reg_t ktsb;			/* kernel task stack base */
  struct memory *memp;
  struct tasktab *ttp;
  struct exec e_hdr;

  /* Initialize the interrupt controller. */
  intr_init(1);

  /* Interpret memory sizes. */
  mem_init();

  /* Clear the process table.
   * Set up mappings for proc_addr() and proc_number() macros.
   */
  for (rp = BEG_PROC_ADDR, t = -NR_TASKS; rp < END_PROC_ADDR; ++rp, ++t) {
	rp->p_nr = t;		/* proc number from ptr */
        (pproc_addr + NR_TASKS)[t] = rp;        /* proc ptr from number */
  }

  /* Resolve driver selections in the task table. */
  mapdrivers();

  /* Set up proc table entries for tasks and servers.  The stacks of the
   * kernel tasks are initialized to an array in data space.  The stacks
   * of the servers have been added to the data segment by the monitor, so
   * the stack pointer is set to the end of the data segment.  All the
   * processes are in low memory on the 8086.  On the 386 only the kernel
   * is in low memory, the rest is loaded in extended memory.
   */

  /* Task stacks. */
  ktsb = (reg_t) t_stack;

  for (t = -NR_TASKS; t <= LOW_USER; ++t) {
	rp = proc_addr(t);			/* t's process slot */
	ttp = &tasktab[t + NR_TASKS];		/* t's task attributes */
	strcpy(rp->p_name, ttp->name);
	if (t < 0) {
		if (ttp->stksize > 0) {
			rp->p_stguard = (reg_t *) ktsb;
			*rp->p_stguard = STACK_GUARD;
		}
		ktsb += ttp->stksize;
		rp->p_reg.sp = ktsb;
		text_base = code_base >> CLICK_SHIFT;
					/* tasks are all in the kernel */
		hdrindex = 0;		/* and use the first a.out header */
		rp->p_priority = PPRI_TASK;
	} else {
		hdrindex = 1 + t;	/* MM, FS, INIT follow the kernel */
		rp->p_priority = t < LOW_USER ? PPRI_SERVER : PPRI_USER;
	}

	/* The bootstrap loader has created an array of the a.out headers at
	 * absolute address 'aout'.
	 */
	phys_copy(aout + hdrindex * A_MINHDR, vir2phys(&e_hdr),
							(phys_bytes) A_MINHDR);
	text_base = e_hdr.a_syms >> CLICK_SHIFT;
	text_clicks = (e_hdr.a_text + CLICK_SIZE-1) >> CLICK_SHIFT;
	if (!(e_hdr.a_flags & A_SEP)) text_clicks = 0;	/* Common I&D */
	data_clicks = (e_hdr.a_total + CLICK_SIZE-1) >> CLICK_SHIFT;
	rp->p_map[T].mem_phys = text_base;
	rp->p_map[T].mem_len  = text_clicks;
	rp->p_map[D].mem_phys = text_base + text_clicks;
	rp->p_map[D].mem_len  = data_clicks;
	rp->p_map[S].mem_phys = text_base + text_clicks + data_clicks;
	rp->p_map[S].mem_vir  = data_clicks;	/* empty - stack is in data */

	/* Remove server memory from the free memory list.  The boot monitor
	 * promises to put processes at the start of memory chunks.
	 */
	for (memp = mem; memp < &mem[NR_MEMS]; memp++) {
		if (memp->base == text_base) {
			memp->base += text_clicks + data_clicks;
			memp->size -= text_clicks + data_clicks;
		}
	}

	/* Set initial register values. */
	rp->p_reg.pc = (reg_t) ttp->initial_pc;
	rp->p_reg.psw = istaskp(rp) ? INIT_TASK_PSW : INIT_PSW;

	if (t >= 0) {
		/* Initialize the server stack pointer.  Take it down one word
		 * to give crtso.s something to use as "argc".
		 */
		rp->p_reg.sp = (rp->p_map[S].mem_vir +
				rp->p_map[S].mem_len) << CLICK_SHIFT;
		rp->p_reg.sp -= sizeof(reg_t);
	}

	if (!isidlehardware(t)) lock_ready(rp);	/* IDLE, HARDWARE neveready */
	rp->p_flags = 0;

	alloc_segments(rp);
  }

  proc[NR_TASKS+INIT_PROC_NR].p_pid = 1;/* INIT of course has pid 1 */
  bill_ptr = proc_addr(IDLE);		/* it has to point somewhere */
  proc_addr(IDLE)->p_priority = PPRI_IDLE;
  lock_pick_proc();

  /* Now go to the assembly code to start running the current process. */
  restart();
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

  if (s != NULL) {
	printf("\nKernel panic: %s",s);
	if (n != NO_NUM) printf(" %d", n);
	printf("\n");
  }
  wreboot(RBT_PANIC);
}
