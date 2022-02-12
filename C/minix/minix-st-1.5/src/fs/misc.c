/* This file contains a collection of miscellaneous procedures.  Some of them
 * perform simple system calls.  Some others do a little part of system calls
 * that are mostly performed by the Memory Manager.
 *
 * The entry points into this file are
 *   do_dup:	perform the DUP system call
 *   do_fcntl:	perform the FCNTL system call
 *   do_sync:	perform the SYNC system call
 *   do_fork:	adjust the tables after MM has performed a FORK system call
 *   do_exit:	a process has exited; note that in the tables
 *   do_set:	set uid or gid for some process
 *   do_revive:	revive a process that was waiting for something (e.g. TTY)
 */

#include "fs.h"
#include <fcntl.h>
#include <minix/callnr.h>
#include <minix/com.h>
#include <minix/boot.h>
#include "buf.h"
#include "file.h"
#include "fproc.h"
#include "inode.h"
#include "param.h"
#include "super.h"

/*===========================================================================*
 *				do_dup					     *
 *===========================================================================*/
PUBLIC int do_dup()
{
/* Perform the dup(fd) or dup(fd,fd2) system call. */

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
/* Perform the fcntl(fd, request, addr) system call. */

  register struct filp *f;
  int new_fd, r, fl;
  struct filp *dummy;

  /* Is the file descriptor valid? */
  if ((f = get_filp(fd)) == NIL_FILP) return(err_code);

  switch (request) {
     case F_DUPFD: 
	/* DUP */
	if (addr < 0 || addr >= OPEN_MAX) break;
	if ((r = get_fd(addr, 0, &new_fd, &dummy)) != OK) return(r);
   	f->filp_count++;
  	fp->fp_filp[new_fd] = f;
  	return(new_fd);

     case F_GETFD: 
	/* Get close-on-exec flag. */
	break;	

     case F_SETFD: 
	/* Set close-on-exec flag. */
	break;	

     case F_GETFL: 
	/* Get file status flags. */
	return(f->filp_flags);	

     case F_SETFL: 
	/* Set file status flags. */
	fl = O_NONBLOCK | O_APPEND;
	f->filp_flags = (f->filp_flags & ~fl) | (addr & fl);
	return(OK);

     case F_GETLK:
     case F_SETLK:
     case F_SETLKW:
	printf("do_fcntl: flag not yet implemented\n");
  }
  return(EINVAL);
}


/*===========================================================================*
 *				do_sync					     *
 *===========================================================================*/
PUBLIC int do_sync()
{
/* Perform the sync() system call.  Flush all the tables. */

  register struct inode *rip;
  register struct buf *bp;
  register struct super_block *sp;

  /* The order in which the various tables are flushed is critical.  The
   * blocks must be flushed last, since rw_inode() and rw_super() leave their
   * results in the block cache.
   */

  /* Update the time in the root super_block. */
  sp = get_super(ROOT_DEV);
  if (sp != NIL_SUPER) {
	  sp->s_time = clock_time();
	  if (sp->s_rd_only == FALSE) sp->s_dirt = DIRTY;
  }

  /* Write all the dirty inodes to the disk. */
  for (rip = &inode[0]; rip < &inode[NR_INODES]; rip++)
	if (rip->i_count > 0 && rip->i_dirt == DIRTY) rw_inode(rip, WRITING);

  /* Write all the dirty super_blocks to the disk. */
  for (sp = &super_block[0]; sp < &super_block[NR_SUPERS]; sp++)
	if (sp->s_dev != NO_DEV && sp->s_dirt == DIRTY) rw_super(sp, WRITING);

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
  register char *sptr, *dptr;
  int i;

  /* Only MM may make this call directly. */
  if (who != MM_PROC_NR) return(ERROR);

  /* Copy the parent's fproc struct to the child. */
  sptr = (char *) &fproc[parent];	/* pointer to parent's 'fproc' struct */
  dptr = (char *) &fproc[child];	/* pointer to child's 'fproc' struct */
  i = sizeof(struct fproc);		/* how many bytes to copy */
  while (i--) *dptr++ = *sptr++;	/* fproc[child] = fproc[parent] */

  /* Increase the counters in the 'filp' table. */
  cp = &fproc[child];
  for (i = 0; i < OPEN_MAX; i++)
	if (cp->fp_filp[i] != NIL_FILP) cp->fp_filp[i]->filp_count++;

  /* Fill in new process id and, if necessary, process group. */
  cp->fp_pid = pid;
  if (parent == INIT_PROC_NR) {
	cp->fp_pgrp = pid;
  }

  /* Record the fact that both root and working dir have another user. */
  dup_inode(cp->fp_rootdir);
  dup_inode(cp->fp_workdir);
  return(OK);
}


/*===========================================================================*
 *				do_exit					     *
 *===========================================================================*/
PUBLIC int do_exit()
{
/* Perform the file system portion of the exit(status) system call. */

  register int i, exitee, task;

  /* Only MM may do the EXIT call directly. */
  if (who != MM_PROC_NR) return(ERROR);

  /* Nevertheless, pretend that the call came from the user. */
  fp = &fproc[slot1];		/* get_filp() needs 'fp' */
  exitee = slot1;

  /* Can this be a process group leader associated with a terminal? */
  if (fp->fp_pid == fp->fp_pgrp && fp->fs_tty != 0) tty_exit();

  if (fp->fp_suspended == SUSPENDED) {
	task = -fp->fp_task;
	if (task == XPIPE || task == XOPEN) susp_count--;
	pro = exitee;
	do_unpause();
	fp->fp_suspended = NOT_SUSPENDED;
  }

  /* Loop on file descriptors, closing any that are open. */
  for (i=0; i < OPEN_MAX; i++) {
	fd = i;
	(void) do_close();
  }

  /* Release root and working directories. */
  put_inode(fp->fp_rootdir);
  put_inode(fp->fp_workdir);
  fp->fp_rootdir = NIL_INODE;
  fp->fp_workdir = NIL_INODE;

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
  if (who != MM_PROC_NR) return(ERROR);

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

  if (who > 0) return(EPERM);
  revive(m.REP_PROC_NR, m.REP_STATUS);
  dont_reply = TRUE;		/* don't reply to the TTY task */
  return(OK);
}
