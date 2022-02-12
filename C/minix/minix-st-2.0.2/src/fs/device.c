/* When a needed block is not in the cache, it must be fetched from the disk.
 * Special character files also require I/O.  The routines for these are here.
 *
 * The entry points in this file are:
 *   dev_io:	 perform a read or write on a block or character device
 *   dev_opcl:   perform generic device-specific processing for open & close
 *   tty_open:   perform tty-specific processing for open
 *   ctty_open:  perform controlling-tty-specific processing for open
 *   ctty_close: perform controlling-tty-specific processing for close
 *   do_setsid:	 perform the SETSID system call (FS side)
 *   do_ioctl:	 perform the IOCTL system call
 *   call_task:	 procedure that actually calls the kernel tasks
 *   call_ctty:	 procedure that actually calls task for /dev/tty
 */

#include "fs.h"
#include <fcntl.h>
#include <minix/callnr.h>
#include <minix/com.h>
#include "dev.h"
#include "file.h"
#include "fproc.h"
#include "inode.h"
#include "param.h"

PRIVATE message dev_mess;
PRIVATE major, minor, task;

FORWARD _PROTOTYPE( void find_dev, (Dev_t dev)				);

/*===========================================================================*
 *				dev_io					     *
 *===========================================================================*/
PUBLIC int dev_io(op, nonblock, dev, pos, bytes, proc, buff)
int op;				/* DEV_READ, DEV_WRITE, DEV_IOCTL, etc. */
int nonblock;			/* TRUE if nonblocking op */
dev_t dev;			/* major-minor device number */
off_t pos;			/* byte position */
int bytes;			/* how many bytes to transfer */
int proc;			/* in whose address space is buff? */
char *buff;			/* virtual address of the buffer */
{
/* Read or write from a device.  The parameter 'dev' tells which one. */

  find_dev(dev);		/* load the variables major, minor, and task */

  /* Set up the message passed to task. */
  dev_mess.m_type   = op;
  dev_mess.DEVICE   = (dev >> MINOR) & BYTE;
  dev_mess.POSITION = pos;
  dev_mess.PROC_NR  = proc;
  dev_mess.ADDRESS  = buff;
  dev_mess.COUNT    = bytes;
  dev_mess.TTY_FLAGS = nonblock; /* temporary kludge */

  /* Call the task. */
  (*dmap[major].dmap_rw)(task, &dev_mess);

  /* Task has completed.  See if call completed. */
  if (dev_mess.REP_STATUS == SUSPEND) {
	if (nonblock) {
		/* Not supposed to block. */
		dev_mess.m_type = CANCEL;
		dev_mess.PROC_NR = proc;
		dev_mess.DEVICE = (dev >> MINOR) & BYTE;
		(*dmap[major].dmap_rw)(task, &dev_mess);
		if (dev_mess.REP_STATUS == EINTR) dev_mess.REP_STATUS = EAGAIN;
	} else {
		if (op == DEV_OPEN) task = XPOPEN;
		suspend(task);		/* suspend user */
	}
  }

  return(dev_mess.REP_STATUS);
}


/*===========================================================================*
 *				dev_opcl				     *
 *===========================================================================*/
PUBLIC void dev_opcl(task_nr, mess_ptr)
int task_nr;			/* which task */
message *mess_ptr;		/* message pointer */
{
/* Called from the dmap struct in table.c on opens & closes of special files.*/

  int op;

  op = mess_ptr->m_type;	/* save DEV_OPEN or DEV_CLOSE for later */
  mess_ptr->DEVICE = (mess_ptr->DEVICE >> MINOR) & BYTE;
  mess_ptr->PROC_NR = fp - fproc;

  call_task(task_nr, mess_ptr);

  /* Task has completed.  See if call completed. */
  if (mess_ptr->REP_STATUS == SUSPEND) {
	if (op == DEV_OPEN) task_nr = XPOPEN;
	suspend(task_nr);	/* suspend user */
  }
}

/*===========================================================================*
 *				tty_open				     *
 *===========================================================================*/
PUBLIC void tty_open(task_nr, mess_ptr)
int task_nr;
message *mess_ptr;
{
/* This procedure is called from the dmap struct in table.c on tty opens. */
  
  int r;
  dev_t dev;
  int flags, proc;
  register struct fproc *rfp;

  dev = (dev_t) mess_ptr->DEVICE;
  flags = mess_ptr->COUNT;
  proc = fp - fproc;

  /* Add O_NOCTTY to the flags if this process is not a session leader, or
   * if it already has a controlling tty, or if it is someone elses
   * controlling tty.
   */
  if (!fp->fp_sesldr || fp->fp_tty != 0) {
	flags |= O_NOCTTY;
  } else {
	for (rfp = &fproc[LOW_USER]; rfp < &fproc[NR_PROCS]; rfp++) {
		if (rfp->fp_tty == dev) flags |= O_NOCTTY;
	}
  }

  r = dev_io(DEV_OPEN, mode, dev, (off_t) 0, flags, proc, NIL_PTR);

  if (r == 1) {
	fp->fp_tty = dev;
	r = OK;
  }

  mess_ptr->REP_STATUS = r;
}


/*===========================================================================*
 *				ctty_open				     *
 *===========================================================================*/
PUBLIC void ctty_open(task_nr, mess_ptr)
int task_nr;
message *mess_ptr;
{
/* This procedure is called from the dmap struct in table.c on opening
 * /dev/tty, the magic device that translates to the controlling tty.
 */
  
  mess_ptr->REP_STATUS = fp->fp_tty == 0 ? ENXIO : OK;
}


/*===========================================================================*
 *				ctty_close				     *
 *===========================================================================*/
PUBLIC void ctty_close(task_nr, mess_ptr)
int task_nr;
message *mess_ptr;
{
/* Close /dev/tty. */

  mess_ptr->REP_STATUS = OK;
}


/*===========================================================================*
 *				do_setsid				     *
 *===========================================================================*/
PUBLIC int do_setsid()
{
/* Perform the FS side of the SETSID call, i.e. get rid of the controlling
 * terminal of a process, and make the process a session leader.
 */
  register struct fproc *rfp;

  /* Only MM may do the SETSID call directly. */
  if (who != MM_PROC_NR) return(ENOSYS);

  /* Make the process a session leader with no controlling tty. */
  rfp = &fproc[slot1];
  rfp->fp_sesldr = TRUE;
  rfp->fp_tty = 0;
}


/*===========================================================================*
 *				do_ioctl				     *
 *===========================================================================*/
PUBLIC int do_ioctl()
{
/* Perform the ioctl(ls_fd, request, argx) system call (uses m2 fmt). */

  struct filp *f;
  register struct inode *rip;
  dev_t dev;

  if ( (f = get_filp(ls_fd)) == NIL_FILP) return(err_code);
  rip = f->filp_ino;		/* get inode pointer */
  if ( (rip->i_mode & I_TYPE) != I_CHAR_SPECIAL
	&& (rip->i_mode & I_TYPE) != I_BLOCK_SPECIAL) return(ENOTTY);
  dev = (dev_t) rip->i_zone[0];
  find_dev(dev);

  dev_mess= m;

  dev_mess.m_type  = DEV_IOCTL;
  dev_mess.PROC_NR = who;
  dev_mess.TTY_LINE = minor;	

  /* Call the task. */
  (*dmap[major].dmap_rw)(task, &dev_mess);

  /* Task has completed.  See if call completed. */
  if (dev_mess.REP_STATUS == SUSPEND) {
	if (f->filp_flags & O_NONBLOCK) {
		/* Not supposed to block. */
		dev_mess.m_type = CANCEL;
		dev_mess.PROC_NR = who;
		dev_mess.TTY_LINE = minor;
		(*dmap[major].dmap_rw)(task, &dev_mess);
		if (dev_mess.REP_STATUS == EINTR) dev_mess.REP_STATUS = EAGAIN;
	} else {
		suspend(task);		/* User must be suspended. */
	}
  }
#if ENABLE_BINCOMPAT
  m1.TTY_SPEK = dev_mess.TTY_SPEK;	/* erase and kill */
  m1.TTY_FLAGS = dev_mess.TTY_FLAGS;	/* flags */
#endif
  return(dev_mess.REP_STATUS);
}


/*===========================================================================*
 *				find_dev				     *
 *===========================================================================*/
PRIVATE void find_dev(dev)
dev_t dev;			/* device */
{
/* Extract the major and minor device number from the parameter. */

  major = (dev >> MAJOR) & BYTE;	/* major device number */
  minor = (dev >> MINOR) & BYTE;	/* minor device number */
  if (major >= max_major) {
	major = minor = 0;		/* will fail with ENODEV */
  }
  task = dmap[major].dmap_task;	/* which task services the device */
}


/*===========================================================================*
 *				call_task				     *
 *===========================================================================*/
PUBLIC void call_task(task_nr, mess_ptr)
int task_nr;			/* which task to call */
message *mess_ptr;		/* pointer to message for task */
{
/* All file system I/O ultimately comes down to I/O on major/minor device
 * pairs.  These lead to calls on the following routines via the dmap table.
 */

  int r, proc_nr;
  message local_m;

  proc_nr = mess_ptr->PROC_NR;

  while ((r = sendrec(task_nr, mess_ptr)) == ELOCKED) {
	/* sendrec() failed to avoid deadlock. The task 'task_nr' is
	 * trying to send a REVIVE message for an earlier request.
	 * Handle it and go try again.
	 */
	if ((r = receive(task_nr, &local_m)) != OK) break;

	/* If we're trying to send a cancel message to a task which has just
	 * sent a completion reply, ignore the reply and abort the cancel
	 * request. The caller will do the revive for the process. 
	 */
	if (mess_ptr->m_type == CANCEL && local_m.REP_PROC_NR == proc_nr)
		return;

	/* Otherwise it should be a REVIVE. */
	if (local_m.m_type != REVIVE) {
		printf(
		"fs: strange device reply from %d, type = %d, proc = %d\n",
			local_m.m_source,
			local_m.m_type, local_m.REP_PROC_NR);
		continue;
	}

	revive(local_m.REP_PROC_NR, local_m.REP_STATUS);
  }

  /* The message received may be a reply to this call, or a REVIVE for some
   * other process.
   */
  for (;;) {
	if (r != OK) panic("call_task: can't send/receive", NO_NUM);

  	/* Did the process we did the sendrec() for get a result? */
  	if (mess_ptr->REP_PROC_NR == proc_nr) break;

	/* Otherwise it should be a REVIVE. */
	if (mess_ptr->m_type != REVIVE) {
		printf(
		"fs: strange device reply from %d, type = %d, proc = %d\n",
			mess_ptr->m_source,
			mess_ptr->m_type, mess_ptr->REP_PROC_NR);
		continue;
	}
	revive(mess_ptr->REP_PROC_NR, mess_ptr->REP_STATUS);

	r = receive(task_nr, mess_ptr);
  }
}


/*===========================================================================*
 *				call_ctty					     *
 *===========================================================================*/
PUBLIC void call_ctty(task_nr, mess_ptr)
int task_nr;			/* not used - for compatibility with dmap_t */
message *mess_ptr;		/* pointer to message for task */
{
/* This routine is only called for one device, namely /dev/tty.  Its job
 * is to change the message to use the controlling terminal, instead of the
 * major/minor pair for /dev/tty itself.
 */

  int major_device;
 
  if (fp->fp_tty == 0) {
	/* No controlling tty present anymore, return an I/O error. */
	mess_ptr->REP_STATUS = EIO;
	return;
  }
  major_device = (fp->fp_tty >> MAJOR) & BYTE;
  task_nr = dmap[major_device].dmap_task;	/* task for controlling tty */
  mess_ptr->DEVICE = (fp->fp_tty >> MINOR) & BYTE;
  call_task(task_nr, mess_ptr);
}


/*===========================================================================*
 *				no_dev					     *
 *===========================================================================*/
PUBLIC void no_dev(task_nr, m_ptr)
int task_nr;			/* not used - for compatibility with dmap_t */
message *m_ptr;			/* message pointer */
{
/* No device there. */

  m_ptr->REP_STATUS = ENODEV;
}


#if ENABLE_NETWORKING
/*===========================================================================*
 *				net_open				     *
 *===========================================================================*/
PUBLIC void net_open(task_nr, mess_ptr)
int task_nr;			/* task to send message to */
message *mess_ptr;		/* pointer to message to send */
{
/* Network files need special processing upon open.  A network device is
 * "cloned", i.e. on a succesful open it is replaced by a new network device
 * with a new unique minor device number.  This new device number identifies
 * the new IP connection with the network task.
 */

  dev_t dev;
  struct inode *rip, *nrip;
  int result;
  int ncount, proc;

  rip = fp->fp_filp[fd]->filp_ino; 

  nrip = alloc_inode(rip->i_dev, ALL_MODES | I_CHAR_SPECIAL);
  if (nrip == NIL_INODE) {
	mess_ptr->REP_STATUS = err_code;
	return;
  }

  dev = (dev_t) mess_ptr->DEVICE;
  ncount = mess_ptr->COUNT;
  proc = fp - fproc;
  result = dev_io(DEV_OPEN, mode, dev, (off_t) 0, ncount, proc, NIL_PTR);

  if (result < 0) {
	put_inode(nrip);
	mess_ptr->REP_STATUS = result;
	return;
  }

  dev= rip->i_zone[0]; 
  dev= (dev & ~(BYTE << MINOR)) | ((result & BYTE) << MINOR); 

  nrip->i_zone[0]= dev;
  put_inode(rip);
  fp->fp_filp[fd]->filp_ino = nrip;
  mess_ptr->REP_STATUS = OK;
}
#endif /* ENABLE_NETWORKING */
