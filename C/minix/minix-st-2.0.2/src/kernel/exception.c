/* This file contains a simple exception handler.  Exceptions in user
 * processes are converted to signals.  Exceptions in the kernel, MM and
 * FS cause a panic.
 */

#include "kernel.h"
#include <signal.h>
#include "proc.h"

/*==========================================================================*
 *				exception				    *
 *==========================================================================*/
PUBLIC void exception(vec_nr)
unsigned vec_nr;
{
/* An exception or unexpected interrupt has occurred. */

  struct ex_s {
	char *msg;
	int signum;
	int minprocessor;
  };
  static struct ex_s ex_data[] = {
	"Divide error", SIGFPE, 86,
	"Debug exception", SIGTRAP, 86,
	"Nonmaskable interrupt", SIGBUS, 86,
	"Breakpoint", SIGEMT, 86,
	"Overflow", SIGFPE, 86,
	"Bounds check", SIGFPE, 186,
	"Invalid opcode", SIGILL, 186,
	"Coprocessor not available", SIGFPE, 186,
	"Double fault", SIGBUS, 286,
	"Copressor segment overrun", SIGSEGV, 286,
	"Invalid TSS", SIGSEGV, 286,
	"Segment not present", SIGSEGV, 286,
	"Stack exception", SIGSEGV, 286,	/* STACK_FAULT already used */
	"General protection", SIGSEGV, 286,
	"Page fault", SIGSEGV, 386,		/* not close */
	NIL_PTR, SIGILL, 0,			/* probably software trap */
	"Coprocessor error", SIGFPE, 386,
  };
  register struct ex_s *ep;
  struct proc *saved_proc;

  saved_proc= proc_ptr;	/* Save proc_ptr, because it may be changed by debug 
  			 * statements.
  			 */

  ep = &ex_data[vec_nr];

  if (vec_nr == 2) {		/* spurious NMI on some machines */
	printf("got spurious NMI\n");
	return;
  }

  if (k_reenter == 0 && isuserp(saved_proc)) {
	unlock();		/* this is protected like sys_call() */
	cause_sig(proc_number(saved_proc), ep->signum);
	return;
  }

  /* This is not supposed to happen. */
  if (ep->msg == NIL_PTR || processor < ep->minprocessor)
	printf("\nIntel-reserved exception %d\n", vec_nr);
  else
	printf("\n%s\n", ep->msg);
  printf("process number %d, pc = 0x%04x:0x%08x\n",
	proc_number(saved_proc),
	(unsigned) saved_proc->p_reg.cs,
	(unsigned) saved_proc->p_reg.pc);
  panic("exception in system code", NO_NUM);
}
