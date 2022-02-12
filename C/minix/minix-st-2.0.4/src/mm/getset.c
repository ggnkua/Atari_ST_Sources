/* This file handles the 4 system calls that get and set uids and gids.
 * It also handles getpid(), setsid(), and getpgrp().  The code for each
 * one is so tiny that it hardly seemed worthwhile to make each a separate
 * function.
 */

#include "mm.h"
#include <minix/callnr.h>
#include <signal.h>
#include "mproc.h"
#include "param.h"

/*===========================================================================*
 *				do_getset				     *
 *===========================================================================*/
PUBLIC int do_getset()
{
/* Handle GETUID, GETGID, GETPID, GETPGRP, SETUID, SETGID, SETSID.  The four
 * GETs and SETSID return their primary results in 'r'.  GETUID, GETGID, and
 * GETPID also return secondary results (the effective IDs, or the parent
 * process ID) in 'reply_res2', which is returned to the user.
 */

  register struct mproc *rmp = mp;
  register int r;

  switch(mm_call) {
	case GETUID:
		r = rmp->mp_realuid;
		rmp->reply_res2 = rmp->mp_effuid;
		break;

	case GETGID:
		r = rmp->mp_realgid;
		rmp->reply_res2 = rmp->mp_effgid;
		break;

	case GETPID:
		r = mproc[who].mp_pid;
		rmp->reply_res2 = mproc[rmp->mp_parent].mp_pid;
		break;

	case SETUID:
		if (rmp->mp_realuid != usr_id && rmp->mp_effuid != SUPER_USER)
			return(EPERM);
		rmp->mp_realuid = usr_id;
		rmp->mp_effuid = usr_id;
		tell_fs(SETUID, who, usr_id, usr_id);
		r = OK;
		break;

	case SETGID:
		if (rmp->mp_realgid != grpid && rmp->mp_effuid != SUPER_USER)
			return(EPERM);
		rmp->mp_realgid = grpid;
		rmp->mp_effgid = grpid;
		tell_fs(SETGID, who, grpid, grpid);
		r = OK;
		break;

	case SETSID:
		if (rmp->mp_procgrp == rmp->mp_pid) return(EPERM);
		rmp->mp_procgrp = rmp->mp_pid;
		tell_fs(SETSID, who, 0, 0);
		/*FALL THROUGH*/

	case GETPGRP:
		r = rmp->mp_procgrp;
		break;

	default:
		r = EINVAL;
		break;	
  }
  return(r);
}
