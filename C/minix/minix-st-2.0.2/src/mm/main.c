/* This file contains the main program of the memory manager and some related
 * procedures.  When MINIX starts up, the kernel runs for a little while,
 * initializing itself and its tasks, and then it runs MM and FS.  Both MM
 * and FS initialize themselves as far as they can.  FS then makes a call to
 * MM, because MM has to wait for FS to acquire a RAM disk.  MM asks the
 * kernel for all free memory and starts serving requests.
 *
 * The entry points into this file are:
 *   main:	starts MM running
 *   reply:	reply to a process making an MM system call
 */

#include "mm.h"
#include <minix/callnr.h>
#include <minix/com.h>
#include <signal.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include "mproc.h"
#include "param.h"

FORWARD _PROTOTYPE( void get_work, (void)				);
FORWARD _PROTOTYPE( void mm_init, (void)				);

/*===========================================================================*
 *				main					     *
 *===========================================================================*/
PUBLIC void main()
{
/* Main routine of the memory manager. */

  int error;

  mm_init();			/* initialize memory manager tables */

  /* This is MM's main loop-  get work and do it, forever and forever. */
  while (TRUE) {
	/* Wait for message. */
	get_work();		/* wait for an MM system call */
	mp = &mproc[who];

  	/* Set some flags. */
	error = OK;
	dont_reply = FALSE;
	err_code = -999;

	/* If the call number is valid, perform the call. */
	if (mm_call < 0 || mm_call >= NCALLS)
		error = EBADCALL;
	else
		error = (*call_vec[mm_call])();

	/* Send the results back to the user to indicate completion. */
	if (dont_reply) continue;	/* no reply for EXIT and WAIT */
	if (mm_call == EXEC && error == OK) continue;
	reply(who, error, result2, res_ptr);
  }
}


/*===========================================================================*
 *				get_work				     *
 *===========================================================================*/
PRIVATE void get_work()
{
/* Wait for the next message and extract useful information from it. */

  if (receive(ANY, &mm_in) != OK) panic("MM receive error", NO_NUM);
  who = mm_in.m_source;		/* who sent the message */
  mm_call = mm_in.m_type;	/* system call number */
}


/*===========================================================================*
 *				reply					     *
 *===========================================================================*/
PUBLIC void reply(proc_nr, result, res2, respt)
int proc_nr;			/* process to reply to */
int result;			/* result of the call (usually OK or error #)*/
int res2;			/* secondary result */
char *respt;			/* result if pointer */
{
/* Send a reply to a user process. */

  register struct mproc *proc_ptr;

  proc_ptr = &mproc[proc_nr];
  /* 
   * To make MM robust, check to see if destination is still alive.  This
   * validy check must be skipped if the caller is a task.
   */
  if ((who >=0) && ((proc_ptr->mp_flags&IN_USE) == 0 || 
	(proc_ptr->mp_flags&HANGING))) return;

  reply_type = result;
  reply_i1 = res2;
  reply_p1 = respt;
  if (send(proc_nr, &mm_out) != OK) panic("MM can't reply", NO_NUM);
}


/*===========================================================================*
 *				mm_init					     *
 *===========================================================================*/
PRIVATE void mm_init()
{
/* Initialize the memory manager. */

  static char core_sigs[] = {
	SIGQUIT, SIGILL, SIGTRAP, SIGABRT,
	SIGEMT, SIGFPE, SIGUSR1, SIGSEGV,
	SIGUSR2, 0 };
  register int proc_nr;
  register struct mproc *rmp;
  register char *sig_ptr;
  phys_clicks ram_clicks, total_clicks, minix_clicks, free_clicks;
  message mess;
  struct mem_map kernel_map[NR_SEGS];
  int mem;

  /* Build the set of signals which cause core dumps. Do it the Posix
   * way, so no knowledge of bit positions is needed.
   */
  sigemptyset(&core_sset);
  for (sig_ptr = core_sigs; *sig_ptr != 0; sig_ptr++)
	sigaddset(&core_sset, *sig_ptr);

  /* Get the memory map of the kernel to see how much memory it uses. */
  sys_getmap(SYSTASK, kernel_map);
  minix_clicks = (kernel_map[S].mem_phys + kernel_map[S].mem_len)
				- kernel_map[T].mem_phys;

  /* Initialize MM's tables. */
  for (proc_nr = 0; proc_nr <= INIT_PROC_NR; proc_nr++) {
	rmp = &mproc[proc_nr];
	rmp->mp_flags |= IN_USE;
	sys_getmap(proc_nr, rmp->mp_seg);
	if (rmp->mp_seg[T].mem_len != 0) rmp->mp_flags |= SEPARATE;
	minix_clicks += (rmp->mp_seg[S].mem_phys + rmp->mp_seg[S].mem_len)
				- rmp->mp_seg[T].mem_phys;
  }
  mproc[INIT_PROC_NR].mp_pid = INIT_PID;
  sigemptyset(&mproc[INIT_PROC_NR].mp_ignore);
  sigemptyset(&mproc[INIT_PROC_NR].mp_catch);
  procs_in_use = LOW_USER + 1;

  /* Wait for FS to send a message telling the RAM disk size then go "on-line".
   */
  if (receive(FS_PROC_NR, &mess) != OK)
	panic("MM can't obtain RAM disk size from FS", NO_NUM);

  ram_clicks = mess.m1_i1;

  /* Initialize tables to all physical mem. */
  mem_init(&total_clicks, &free_clicks);

  /* Print memory information. */
  printf("\nMemory size = %dK   ", click_to_round_k(total_clicks));
  printf("MINIX = %dK   ", click_to_round_k(minix_clicks));
  printf("RAM disk = %dK   ", click_to_round_k(ram_clicks));
  printf("Available = %dK\n\n", click_to_round_k(free_clicks));

  /* Tell FS to continue. */
  if (send(FS_PROC_NR, &mess) != OK)
	panic("MM can't sync up with FS", NO_NUM);

  /* Tell the memory task where my process table is for the sake of ps(1). */
  if ((mem = open("/dev/mem", O_RDWR)) != -1) {
	ioctl(mem, MIOCSPSINFO, (void *) mproc);
	close(mem);
  }
}
