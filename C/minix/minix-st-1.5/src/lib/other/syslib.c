#include <lib.h>
#include <minix/com.h>

/*----------------------------------------------------------------------------
		Messages to systask (special calls)
----------------------------------------------------------------------------*/

#if (CHIP == M68000)
PUBLIC void sys_xit(parent, proc, basep, sizep)
phys_clicks *basep, *sizep;
#else
PUBLIC void sys_xit(parent, proc)
#endif
int parent;			/* parent of exiting proc. */
int proc;			/* which proc has exited */
{
/* A proc has exited.  Tell the kernel. */

  callm1(SYSTASK, SYS_XIT, parent, proc, 0, NIL_PTR, NIL_PTR, NIL_PTR);
#if (CHIP == M68000)
  *basep = (phys_clicks) _M.m1_i1;
  *sizep = (phys_clicks) _M.m1_i2;
#endif
}


PUBLIC void sys_getsp(proc, newsp)
int proc;			/* which proc has enabled signals */
vir_bytes *newsp;		/* place to put sp read from kernel */
{
/* Ask the kernel what the sp is. */


  callm1(SYSTASK, SYS_GETSP, proc, 0, 0, NIL_PTR, NIL_PTR, NIL_PTR);
  *newsp = (vir_bytes) _M.STACK_PTR;
}


PUBLIC void sys_sig(proc, sig, sighandler)
int proc;			/* which proc has exited */
int sig;			/* signal number: 1 - 16 */
void (*sighandler) ();		/* pointer to signal handler in user space */
{
/* A proc has to be signaled.  Tell the kernel. */

  _M.m6_i1 = proc;
  _M.m6_i2 = sig;
  _M.m6_f1 = sighandler;
  callx(SYSTASK, SYS_SIG);
}


#if (CHIP == M68000)
PUBLIC void sys_fork(parent, child, pid, shadow)
#ifdef ALCYON_C_BUG_FIXED
phys_clicks shadow;		/* memory allocated for shadow */
#else
int shadow;
#endif
#else
PUBLIC void sys_fork(parent, child, pid)
#endif
int parent;			/* proc doing the fork */
int child;			/* which proc has been created by the fork */
int pid;			/* process id assigned by MM */
{
/* A proc has forked.  Tell the kernel. */

#if (CHIP == M68000)
  callm1(SYSTASK, SYS_FORK, parent, child, pid, (char *) shadow, NIL_PTR, NIL_PTR);
#else
  callm1(SYSTASK, SYS_FORK, parent, child, pid, NIL_PTR, NIL_PTR, NIL_PTR);
#endif
}


PUBLIC void sys_exec(proc, ptr, traced)
int proc;			/* proc that did exec */
char *ptr;			/* new stack pointer */
int traced;			/* is tracing enabled? */
{
/* A proc has exec'd.  Tell the kernel. */

  callm1(SYSTASK, SYS_EXEC, proc, traced, 0, ptr, NIL_PTR, NIL_PTR);
}

PUBLIC void sys_newmap(proc, ptr)
int proc;			/* proc whose map is to be changed */
char *ptr;			/* pointer to new map */
{
/* A proc has been assigned a new memory map.  Tell the kernel. */


  callm1(SYSTASK, SYS_NEWMAP, proc, 0, 0, ptr, NIL_PTR, NIL_PTR);
}

PUBLIC void sys_copy(mptr)
message *mptr;			/* pointer to message */
{
/* A proc wants to use local copy. */

  /* Make this routine better.  Also check other guys' error handling
   * -DEBUG */
  mptr->m_type = SYS_COPY;
  if (sendrec(SYSTASK, mptr) != 0) panic("sys_copy can't send", NO_NUM);
}

PUBLIC void sys_times(proc, ptr)
int proc;			/* proc whose times are needed */
time_t ptr[4];		/* pointer to time buffer */
{
/* Fetch the accounting info for a proc. */

  callm1(SYSTASK, SYS_TIMES, proc, 0, 0, (char *)ptr, NIL_PTR, NIL_PTR);
  ptr[0] = _M.USER_TIME;
  ptr[1] = _M.SYSTEM_TIME;
  ptr[2] = _M.CHILD_UTIME;
  ptr[3] = _M.CHILD_STIME;
}


PUBLIC void sys_abort()
{
/* Something awful has happened.  Abandon ship. */

  callm1(SYSTASK, SYS_ABORT, 0, 0, 0, NIL_PTR, NIL_PTR, NIL_PTR);
}

#if (CHIP == M68000)
PUBLIC void sys_fresh(proc, ptr, dc, basep, sizep)
int proc;			/* proc whose map is to be changed */
char *ptr;			/* pointer to new map */
phys_clicks dc;			/* size of initialized data */
phys_clicks *basep, *sizep;	/* base and size for free_mem() */
{
/* Create a fresh process image for exec().  Tell the kernel. */

  callm1(SYSTASK, SYS_FRESH, proc, (int) dc, 0, ptr, NIL_PTR, NIL_PTR);
  *basep = (phys_clicks) _M.m1_i1;
  *sizep = (phys_clicks) _M.m1_i2;
}

#endif


PUBLIC void sys_kill(proc, sig)
int proc;			/* which proc has exited */
int sig;			/* signal number: 1 - 16 */
{
/* A proc has to be signaled via MM.  Tell the kernel. */

  _M.m6_i1 = proc;
  _M.m6_i2 = sig;
  callx(SYSTASK, SYS_KILL);
}

PUBLIC int sys_trace(req, procnr, addr, data_p)
int req, procnr;
long addr, *data_p;
{
  int r;

  _M.m2_i1 = procnr;
  _M.m2_i2 = req;
  _M.m2_l1 = addr;
  if (data_p) _M.m2_l2 = *data_p;
  r = callx(SYSTASK, SYS_TRACE);
  if (data_p) *data_p = _M.m2_l2;
  return(r);
}

PUBLIC void tell_fs(what, p1, p2, p3)
int what, p1, p2, p3;
{
/* This routine is only used by MM to inform FS of certain events:
 *      tell_fs(CHDIR, slot, dir, 0)
 *      tell_fs(EXIT, proc, 0, 0)
 *      tell_fs(FORK, parent, child, pid)
 *      tell_fs(SETGID, proc, realgid, effgid)
 *      tell_fs(SETUID, proc, realuid, effuid)
 *      tell_fs(SYNC, 0, 0, 0)
 *      tell_fs(UNPAUSE, proc, signr, 0)
 *      tell_fs(SETPGRP, proc, 0, 0)
 */
  callm1(FS, what, p1, p2, p3, NIL_PTR, NIL_PTR, NIL_PTR);
}
