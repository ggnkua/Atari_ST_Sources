/*
 * Lattice C Threads Library for MiNT
 * Written by Craig Graham
 */

#include <basepage.h>
#include <mintbind.h>
#include <fcntl.h>
#include <ioctl.h>
#include <osbind.h>
#include <memory.h>
#include <signal.h>
#include "xa_globl.h"
#if __PUREC__			/* FIX_PC */
#include <string.h>
#endif
#ifndef NULL
#define NULL ((void *)0L)
#endif
#include "threads.h"

__saveds void ThreadLauncher(void);
void reopen_moose(void);

/*
 * Launch a function as a new thread.
 * ---------
 * Parameters:
 *  thread_function: pointer to a function of type ThreadableFunction
 *                   eg.   void my_threadfn(void *c) { }
 *                     or  void my_other_threadfn(char *text) { }
 *  stacksize: size of the stack to allow for execution of this function
 *  parm: pointer to whatever parameter you may wish to pass into the thread
 *  name: pointer to a C string for what to call the thread when it shows up
 *        in the MiNT task list. If this is NULL, then the name "thread.XA" will
 *        be used.
 * Returns:
 *  MiNT process id of the child thread
 * Notes:
 *  You must remember to allow enough stack space for the function (and
 *  any functions it may call) to operate. 
 *  The thread will exit with Pterm0() when the function you spawned
 *  returns.
 *  All threads
*/
short __stdargs ThreadNew(ThreadableFunction *thread_function, unsigned long stacksize, void *parm, char *name)
{
	BASEPAGE *bp_thread, *bp_main;
	short h;
	short pid_thread;
	unsigned long *lf;

	/* Kludge to get round a bug in MiNT (or moose?) */
#if MOUSE_KLUDGE
	if (MOUSE_dev)
		Fclose(MOUSE_dev);
#endif
	/* Create a child basepage */
	bp_thread = (BASEPAGE *)Pexec(5, "", "", "");
	
	/* Shrink to only include the stack */
	Mshrink(bp_thread, sizeof(BASEPAGE) + stacksize + 50);
	
	/* Read the parent basepage */
	h = Fopen("U:\\PROC\\.-1", O_RDONLY);
	Fcntl(h, &bp_main, PBASEADDR);
	Fclose(h);
	
	/* Copy parent basepage */
#if __PUREC__   /* FIX_PC */
	memcpy(bp_thread, bp_main, sizeof(BASEPAGE));
#else
	__builtin_memcpy(bp_thread, bp_main, sizeof(BASEPAGE));
#endif
	/* Modify, so we get the correct parent */
	bp_thread->p_parent = bp_main;

	/* Pass parameters into the thread via the command line buffer */
	lf = (unsigned long *)bp_thread->p_cmdlin;
	*lf++ = (unsigned long)thread_function;
	*lf = (unsigned long)parm;

	/* Allocate a stack */
	bp_thread->p_bbase = (char *)(bp_thread + 1);
	bp_thread->p_blen = stacksize;

	/* ThreadLauncher handlers the thread entry and exit for us */
	bp_thread->p_tbase = (char *)&ThreadLauncher;

	/* Name the thread if it isn't already */
	if (name == NULL)
		name = "thread.XA";
		
	/* Launch the thread and return the child id */
	pid_thread = Pexec(0x8000 | 104, name, bp_thread, NULL);

	/*
	 * MASSIVE KLUDGE
	 * - For some reason, you MUST re-open the moose after a Pexec(): same as I worked around in shellwrt.c
	 */
#if MOUSE_KLUDGE
	if (MOUSE_dev) 
		reopen_moose();
#endif
	Pkill(pid_thread, SIGCONT);

	return pid_thread;
}

/*
 * The actual kickoff function for a thread - this ensures
 * that the parameter is passed across correctly, and that
 * the thread will exit after the function returns
 */
__saveds void ThreadLauncher(void)
{
	BASEPAGE *bp_me;
	ThreadableFunction *f;
	unsigned long *lf;
	short h;
	void *parm;

	/* We need our basepage here... */
	h = Fopen("U:\\PROC\\.-1", O_RDONLY);
	Fcntl(h, &bp_me, PBASEADDR);
	Fclose(h);
	
	/* Get the command line parameters */
	lf = (unsigned long *)bp_me->p_cmdlin;
	f = (ThreadableFunction *)(lf[0]);
	parm = (void *)(lf[1]);
	
	/* Call the function */
	(f)(parm);

	/* Exit - this will free up the stack we used anyway as the stack */
	/* was in the BSS allocated by Pexec(5, "", "", "")                  */
	Pterm0();			
}

