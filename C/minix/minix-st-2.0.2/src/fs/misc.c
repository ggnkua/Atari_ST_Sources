/* This file contains a collection of miscellaneous procedures.  Some of them
 * perform simple system calls.  Some others do a little part of system calls
 * that are mostly performed by the Memory Manager.
 *
 * The entry points into this file are
 *   do_dup:	  perform the DUP system call
 *   do_fcntl:	  perform the FCNTL system call
 *   do_sync:	  perform the SYNC system call
 *   do_fork:	  adjust the tables after MM has performed a FORK system call
 *   do_exec:	  handle files with FD_CLOEXEC on after MM has done an EXEC
 *   do_exit:	  a process has exited; note that in the tables
 *   do_set:	  set uid or gid for some process
 *   do_revive:	  revive a process that was waiting for something (e.g. TTY)
 */

#include "fs.h"
#include <fcntl.h>
#include <unistd.h>	/* cc runs out of memory with unistd.h :-( */
#include <minix/callnr.h>
#include <minix/com.h>
#include <minix/boot.h>
#include "buf.h"
#include "file.h"
#include "fproc.h"
#include "inode.h"
#include "dev.h"
#include "param.h"


/*===========================================================================*
 *				do_dup					     *
 *===========================================================================*/
PUBLIC int do_dup()
{
/* Perform the dup(fd) or dup2(fd,fd2) system call. These system calls are
 * obsolete.  In fact, it is not even possible to invoke them using the
 * current library because the library routines call fcntl().  They are
 * provided to permit old binary programs to continue to run.
 */

  register int rfd;
  register struct filp *f;
  struct filp *dummy;
  int r;

  /* Is the file descriptor valid? */
  rfd = fd & ~DUP_MASK;		/* kill off dup2 bit, if on */
  if ((f = get_filp(rfd)) == NIL_FILP) return(err_code);

  /* Distinguish between dup and dup2. */
  if (fd == rfd) {			/* bit not on */
	/* dup(fd) */
	if ( (r = get_fd(0, 0, &fd2, &dummy)) != OK) return(r);
  } else {
	/* dup2(fd, fd2) */
	if (fd2 < 0 || fd2 >= OPEN_MAX) return(EBADF);
	if (rfd == fd2) return(fd2);	/* ignore the call: dup2(x, x) */
	fd = fd2;		/* prepare to close fd2 */
	(void) do_close();	/* cannot fail */
  }

  /* Success. Set up new file descriptors. */
  f->filp_count++;
  fp->fp_filp[fd2] = f;
  return(fd2);
}

/*===========================================================================*
 *				do_fcntl				     *
 *===========================================================================*/
PUBLIC int do_fcntl()
{
/* Perform the fcntl(fd, request, ...) system call. */

  register struct filp *f;
  int new_fd, r, fl;
  long cloexec_mask;		/* bit map for the FD_CLOEXEC flag */
  long clo_value;		/* FD_CLOEXEC flag in proper position */
  struct filp *dummy;

  /* Is the file descriptor valid? */
  if ((f = get_filp(fd)) == NIL_FILP) return(err_code);

  switch (request) {
     case F_DUPFD: 
	/* This replaces the old dup() system call. */
	if (addr < 0 || addr >= OPEN_MAX) return(EINVAL);
	if ((r = get_fd(addr, 0, &new_fd, &dummy)) != OK) return(r);
   	f->filp_count++;
  	fp->fp_filp[new_fd] = f;
  	return(new_fd);

     case F_GETFD: 
	/* Get close-on-exec flag (FD_CLOEXEC in POSIX Table 6-2). */
	return( ((fp->fp_cloexec >> fd) & 01) ? FD_CLOEXEC : 0);

     case F_SETFD: 
	/* Set close-on-exec flag (FD_CLOEXEC in POSIX Table 6-2). */
	cloexec_mask = 1L << fd;	/* singleton set position ok */
	clo_value = (addr & FD_CLOEXEC ? cloexec_mask : 0L);
	fp->fp_cloexec = (fp->fp_cloexec & ~cloexec_mask) | clo_value;
	return(OK);

     case F_GETFL: 
	/* Get file status flags (O_NONBLOCK and O_APPEND). */
	fl = f->filp_flags & (O_NONBLOCK | O_APPEND | O_ACCMODE);
	return(fl);	

     case F_SETFL: 
	/* Set file status flags (O_NONBLOCK and O_APPEND). */
	fl = O_NONBLOCK | O_APPEND;
	f->filp_flags = (f->filp_flags & ~fl) | (addr & fl);
	return(OK);

     case F_GETLK:
     case F_SETLK:
     case F_SETLKW:
	/* Set or clear a file lock. */
	r = lock_op(f, request);
	return(r);

     default:
	return(EINVAL);
  }
}


/*===========================================================================*
 *				do_sync					     *
 *===========================================================================*/
PUBLIC int do_sync()
{
/* Perform the sync() system call.  Flush all the tables. */

  register struct inode *rip;
  register struct buf *bp;

  /* The order in which the various tables are flushed is critical.  The
   * blocks must be flushed last, since rw_inode() leaves its results in
   * the block cache.
   */

  /* Write all the dirty inodes to the disk. */
  for (rip = &inode[0]; rip < &inode[NR_INODES]; rip++)
	if (rip->i_count > 0 && rip->i_dirt == DIRTY) rw_inode(rip, WRITING);

  /* Write all the dirty blocks to the disk, one drive at a time. */
  for (bp = &buf[0]; bp < &buf[NR_BUFS]; bp++)
	if (bp->b_dev != NO_DEV && bp->b_dirt == DIRTY) flushall(bp->b_dev);

  return(OK);		/* sync() can't fail */
}


/*===========================================================================*
 *				do_fork					     *
 *===========================================================================*/
PUBLIC int do_fork()
{
/* Perform those aspects of the fork() system call that relate to files.
 * In particular, let the child inherit its parent's file descriptors.
 * The parent and child parameters tell who forked off whom. The file
 * system uses the same slot numbers as the kernel.  Only MM makes this call.
 */

  register struct fproc *cp;
  int i;

  /* Only MM may make this call directly. */
  if (who != MM_PROC_NR) return(EGENERIC);

  /* Copy the parent's fproc struct to the child. */
  fproc[child] = fproc[parent];

  /* Increase the counters in the 'filp' table. */
  cp = &fproc[child];
  for (i = 0; i < OPEN_MAX; i++)
	if (cp->fp_filp[i] != NIL_FILP) cp->fp_filp[i]->filp_count++;

  /* Fill in new process id. */
  cp->fp_pid = pid;

  /* A child is not a process leader. */
  cp->fp_sesldr = 0;

  /* Record the fact that both root and working dir have another user. */
  dup_inode(cp->fp_rootdir);
  dup_inode(cp->fp_workdir);
  return(OK);
}


/*===========================================================================*
 *				do_exec					     *
 *===========================================================================*/
PUBLIC int do_exec()
{
/* Files can be marked with the FD_CLOEXEC bit (in fp->fp_cloexec).  When
 * MM does an EXEC, it calls FS to allow FS to find these files and close them.
 */

  register int i;
  long bitmap;

  /* Only MM may make this call directly. */
  if (who != MM_PROC_NR) return(EGENERIC);

  /* The array of FD_CLOEXEC bits is in the fp_cloexec bit map. */
  fp = &fproc[slot1];		/* get_filp() needs 'fp' */
  bitmap = fp->fp_cloexec;
  if (bitmap == 0) return(OK);	/* normal case, no FD_CLOEXECs */

  /* Check the file desriptors one by one for presence of FD_CLOEXEC. */
  for (i = 0; i < OPEN_MAX; i++) {
	fd = i;
	if ( (bitmap >> i) & 01) (void) do_close();
  }

  return(OK);
}


/*===========================================================================*
 *				do_exit					     *
 *===========================================================================*/
PUBLIC int do_exit()
{
/* Perform the file system portion of the exit(status) system call. */

  register int i, exitee, task;
  register struct fproc *rfp;
  register struct filp *rfilp;
  register struct inode *rip;
  int major;
  dev_t dev;
  message dev_mess;

  /* Only MM may do the EXIT call directly. */
  if (who != MM_PROC_NR) return(EGENERIC);

  /* Nevertheless, pretend that the call came from the user. */
  fp = &fproc[slot1];		/* get_filp() needs 'fp' */
  exitee = slot1;

  if (fp->fp_suspended == SUSPENDED) {
	task = -fp->fp_task;
	if (task == XPIPE || task == XPOPEN) susp_count--;
	pro = exitee;
	(void) do_unpause();	/* this always succeeds for MM */
	fp->fp_suspended = NOT_SUSPENDED;
  }

  /* Loop on file descriptors, closing any that are open. */
  for (i = 0; i < OPEN_MAX; i++) {
	fd = i;
	(void) do_close();
  }

  /* Release root and working directories. */
  put_inode(fp->fp_rootdir);
  put_inode(fp->fp_workdir);
  fp->fp_rootdir = NIL_INODE;
  fp->fp_workdir = NIL_INODE;

  /* If a session leader exits then revoke access to its controlling tty from
   * all other processes using it.
   */
  if (!fp->fp_sesldr) return(OK);		/* not a session leader */
  fp->fp_sesldr = FALSE;
  if (fp->fp_tty == 0) return(OK);		/* no controlling tty */
  dev = fp->fp_tty;

  for (rfp = &fproc[LOW_USER]; rfp < &fproc[NR_PROCS]; rfp++) {
	if (rfp->fp_tty == dev) rfp->fp_tty = 0;

	for (i = 0; i < OPEN_MAX; i++) {
		if ((rfilp = rfp->fp_filp[i]) == NIL_FILP) continue;
		if (rfilp->filp_mode == FILP_CLOSED) continue;
		rip = rfilp->filp_ino;
		if ((rip->i_mode & I_TYPE) != I_CHAR_SPECIAL) continue;
		if ((dev_t) rip->i_zone[0] != dev) continue;
		dev_mess.m_type = DEV_CLOSE;
		dev_mess.DEVICE = dev;
		major = (dev >> MAJOR) & BYTE;	/* major device nr */
		task = dmap[major].dmap_task;	/* device task nr */
		(*dmap[major].dmap_close)(task, &dev_mess);
		rfilp->filp_mode = FILP_CLOSED;
	}
  }
  return(OK);
}


/*===========================================================================*
 *				do_set					     *
 *===========================================================================*/
PUBLIC int do_set()
{
/* Set uid_t or gid_t field. */

  register struct fproc *tfp;

  /* Only MM may make this call directly. */
  if (who != MM_PROC_NR) return(EGENERIC);

  tfp = &fproc[slot1];
  if (fs_call == SETUID) {
	tfp->fp_realuid = (uid_t) real_user_id;
	tfp->fp_effuid =  (uid_t) eff_user_id;
  }
  if (fs_call == SETGID) {
	tfp->fp_effgid =  (gid_t) eff_grp_id;
	tfp->fp_realgid = (gid_t) real_grp_id;
  }
  return(OK);
}


/*===========================================================================*
 *				do_revive				     *
 *===========================================================================*/
PUBLIC int do_revive()
{
/* A task, typically TTY, has now gotten the characters that were needed for a
 * previous read.  The process did not get a reply when it made the call.
 * Instead it was suspended.  Now we can send the reply to wake it up.  This
 * business has to be done carefully, since the incoming message is from
 * a task (to which no reply can be sent), and the reply must go to a process
 * that blocked earlier.  The reply to the caller is inhibited by setting the
 * 'dont_reply' flag, and the reply to the blocked process is done explicitly
 * in revive().
 */

#if !ALLOW_USER_SEND
  if (who >= LOW_USER) return(EPERM);
#endif

  revive(m.REP_PROC_NR, m.REP_STATUS);
  dont_reply = TRUE;		/* don't reply to the TTY task */
  return(OK);
}
