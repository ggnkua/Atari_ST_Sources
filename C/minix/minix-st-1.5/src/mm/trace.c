#include "mm.h"
#include <signal.h>
#include "mproc.h"
#include "param.h"

FORWARD struct mproc *findproc();

/*===========================================================================*
 *				findproc  				     *
 *===========================================================================*/
PRIVATE struct mproc *findproc(lpid)
int lpid;
{
  register struct mproc *rmp;

  for (rmp = &mproc[INIT_PROC_NR + 1]; rmp < &mproc[NR_PROCS]; rmp++ )
	if (rmp->mp_flags & IN_USE && rmp->mp_pid == lpid) return rmp;

  return 0;
}

/*===========================================================================*
 *				do_trace  				     *
 *===========================================================================*/
PUBLIC int do_trace()
{
  register struct mproc *child;

  if (request == 0) {  /* enable tracing by parent for this process */
	mp->mp_flags |= TRACED;
	mm_out.m2_l2 = 0;
	return OK;
  }
  if ((child = findproc(pid)) == 0 || (child->mp_flags & STOPPED) == 0) {
	return ESRCH;
  }
  if (request == 8) { /* exit */
	mm_exit(child, data);
	mm_out.m2_l2 = 0;
	return OK;
  }
  if (request == 7) { /* resume execution */
	if (data > _NSIG) {
		return EIO;
	}
	if (data > 0) { /* issue signal */
		child->mp_flags &= ~TRACED; /* so signal is not diverted */
		sig_proc(child, (int)data);
		child->mp_flags |= TRACED;
	}
	child->mp_flags &= ~STOPPED;
  }	
  if (sys_trace(request, (int)(child - mproc), (long)taddr, (long *)&data) != OK)
	return -errno;
  mm_out.m2_l2 = data;
  return OK;
}

/*===========================================================================*
 *				stop_proc  				     *
 *===========================================================================*/
PUBLIC void stop_proc(rmp, sig_nr) /* a traced process got a signal so stop */
register struct mproc *rmp;
int sig_nr;
{
  register struct mproc *rpmp = mproc + rmp->mp_parent;

  if (sys_trace(-1, (int)(rmp - mproc), 0L, (long *)0) != OK) return;
  rmp->mp_flags |= STOPPED;
  if (rpmp->mp_flags & WAITING) {
	rpmp->mp_flags &= ~WAITING;	/* parent is no longer waiting */
	reply(rmp->mp_parent, rmp->mp_pid, 0177 | (sig_nr << 8), NIL_PTR);
  }
  else {
	rmp->mp_sigstatus = sig_nr;
  }
  return;
}
