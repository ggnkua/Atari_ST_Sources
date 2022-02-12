/* This file contains device independent device driver interface.
 *							Author: Kees J. Bot.
 *
 * The drivers support the following operations (using message format m2):
 *
 *    m_type      DEVICE    PROC_NR     COUNT    POSITION  ADRRESS
 * ----------------------------------------------------------------
 * |  DEV_OPEN  | device  | proc nr |         |         |         |
 * |------------+---------+---------+---------+---------+---------|
 * |  DEV_CLOSE | device  | proc nr |         |         |         |
 * |------------+---------+---------+---------+---------+---------|
 * |  DEV_READ  | device  | proc nr |  bytes  |  offset | buf ptr |
 * |------------+---------+---------+---------+---------+---------|
 * |  DEV_WRITE | device  | proc nr |  bytes  |  offset | buf ptr |
 * |------------+---------+---------+---------+---------+---------|
 * |SCATTERED_IO| device  | proc nr | requests|         | iov ptr |
 * ----------------------------------------------------------------
 * |  DEV_IOCTL | device  | proc nr |func code|         | buf ptr |
 * ----------------------------------------------------------------
 *
 * The file contains one entry point:
 *
 *   driver_task:	called by the device dependent task entry
 *
 *
 * Constructed 92/04/02 by Kees J. Bot from the old AT wini and floppy driver.
 */

#include "kernel.h"
#include <sys/ioctl.h>
#include "driver.h"

#if (CHIP == INTEL)
#if ENABLE_AHA1540_SCSI && DMA_BUF_SIZE < 2048
/* A bit extra scratch for the Adaptec driver. */
#define BUF_EXTRA	(2048 - DMA_BUF_SIZE)
#else
#define BUF_EXTRA	0
#endif

/* Claim space for variables. */
PRIVATE u8_t buffer[(unsigned) 2 * DMA_BUF_SIZE + BUF_EXTRA];
u8_t *tmp_buf;			/* the DMA buffer eventually */
phys_bytes tmp_phys;		/* phys address of DMA buffer */

#else /* CHIP != INTEL */

/* Claim space for variables. */
u8_t tmp_buf[DMA_BUF_SIZE];	/* the DMA buffer */
phys_bytes tmp_phys;		/* phys address of DMA buffer */

#endif /* CHIP != INTEL */

FORWARD _PROTOTYPE( void init_buffer, (void) );


/*===========================================================================*
 *				driver_task				     *
 *===========================================================================*/
PUBLIC void driver_task(dp)
struct driver *dp;	/* Device dependent entry points. */
{
/* Main program of any device driver task. */

  int r, caller, proc_nr;
  message mess;

  init_buffer();	/* Get a DMA buffer. */


  /* Here is the main loop of the disk task.  It waits for a message, carries
   * it out, and sends a reply.
   */

  while (TRUE) {
	/* First wait for a request to read or write a disk block. */
	receive(ANY, &mess);

	caller = mess.m_source;
	proc_nr = mess.PROC_NR;

	/* Check if legitimate caller: FS or a task. */
	if (caller != FS_PROC_NR && caller >= 0) {
		printf("%s: got message from %d\n", (*dp->dr_name)(), caller);
		continue;
	}

	/* Now carry out the work. */
	switch(mess.m_type) {
	    case DEV_OPEN:	r = (*dp->dr_open)(dp, &mess);	break;
	    case DEV_CLOSE:	r = (*dp->dr_close)(dp, &mess);	break;
	    case DEV_IOCTL:	r = (*dp->dr_ioctl)(dp, &mess);	break;

	    case DEV_READ:
	    case DEV_WRITE:	r = do_rdwt(dp, &mess);		break;

	    case SCATTERED_IO:	r = do_vrdwt(dp, &mess);	break;

	    case HARD_INT:	/* Leftover interrupt. */	continue;

	    default:		r = EINVAL;			break;
	}

	/* Clean up leftover state. */
	(*dp->dr_cleanup)();

	/* Finally, prepare and send the reply message. */
	mess.m_type = TASK_REPLY;
	mess.REP_PROC_NR = proc_nr;

	mess.REP_STATUS = r;	/* # of bytes transferred or error code */
	send(caller, &mess);	/* send reply to caller */
  }
}


/*===========================================================================*
 *				init_buffer				     *
 *===========================================================================*/
PRIVATE void init_buffer()
{
/* Select a buffer that can safely be used for dma transfers.  It may also
 * be used to read partition tables and such.  Its absolute address is
 * 'tmp_phys', the normal address is 'tmp_buf'.
 */

#if (CHIP == INTEL)
  tmp_buf = buffer;
  tmp_phys = vir2phys(buffer);

  if (tmp_phys == 0) panic("no DMA buffer", NO_NUM);

  if (dma_bytes_left(tmp_phys) < DMA_BUF_SIZE) {
	/* First half of buffer crosses a 64K boundary, can't DMA into that */
	tmp_buf += DMA_BUF_SIZE;
	tmp_phys += DMA_BUF_SIZE;
  }
#else /* CHIP != INTEL */
  tmp_phys = vir2phys(tmp_buf);
#endif /* CHIP != INTEL */
}


/*===========================================================================*
 *				do_rdwt					     *
 *===========================================================================*/
PUBLIC int do_rdwt(dp, m_ptr)
struct driver *dp;		/* device dependent entry points */
message *m_ptr;			/* pointer to read or write message */
{
/* Carry out a single read or write request. */
  struct iorequest_s ioreq;
  int r;

  if (m_ptr->COUNT <= 0) return(EINVAL);

  if ((*dp->dr_prepare)(m_ptr->DEVICE) == NIL_DEV) return(ENXIO);

  ioreq.io_request = m_ptr->m_type;
  ioreq.io_buf = m_ptr->ADDRESS;
  ioreq.io_position = m_ptr->POSITION;
  ioreq.io_nbytes = m_ptr->COUNT;

  r = (*dp->dr_schedule)(m_ptr->PROC_NR, &ioreq);

  if (r == OK) (void) (*dp->dr_finish)();

  r = ioreq.io_nbytes;
  return(r < 0 ? r : m_ptr->COUNT - r);
}


/*==========================================================================*
 *				do_vrdwt				    *
 *==========================================================================*/
PUBLIC int do_vrdwt(dp, m_ptr)
struct driver *dp;	/* device dependent entry points */
message *m_ptr;		/* pointer to read or write message */
{
/* Fetch a vector of i/o requests.  Handle requests one at a time.  Return
 * status in the vector.
 */

  struct iorequest_s *iop;
  static struct iorequest_s iovec[NR_IOREQS];
  phys_bytes iovec_phys, user_iovec_phys;
  size_t iovec_size;
  unsigned nr_requests;
  int request;
  int r;

  nr_requests = m_ptr->COUNT;

  if (m_ptr->m_source < 0) {
	/* Called by a task, no need to copy vector. */
	iop = (struct iorequest_s *) m_ptr->ADDRESS;
  } else {
	if (nr_requests > NR_IOREQS)
		panic("too big I/O vector by", m_ptr->m_source);
	iovec_size = nr_requests * sizeof(iovec[0]);
	user_iovec_phys = umap(proc_addr(m_ptr->m_source), D,
				(vir_bytes) m_ptr->ADDRESS, iovec_size);
	if (user_iovec_phys == 0) panic("bad I/O vector by", m_ptr->m_source);

	iovec_phys = vir2phys(iovec);
	phys_copy(user_iovec_phys, iovec_phys, (phys_bytes) iovec_size);
	iop = iovec;
  }

  if ((*dp->dr_prepare)(m_ptr->DEVICE) == NIL_DEV) return(ENXIO);

  for (request = 0; request < nr_requests; request++, iop++) {
	if ((r = (*dp->dr_schedule)(m_ptr->PROC_NR, iop)) != OK) break;
  }

  if (r == OK) (void) (*dp->dr_finish)();

  /* Copy the I/O vector back to the caller. */
  if (m_ptr->m_source >= 0) {
	phys_copy(iovec_phys, user_iovec_phys, (phys_bytes) iovec_size);
  }
  return(OK);
}


/*===========================================================================*
 *				no_name					     *
 *===========================================================================*/
PUBLIC char *no_name()
{
/* If no specific name for the device. */

  return(tasktab[proc_number(proc_ptr) + NR_TASKS].name);
}


/*============================================================================*
 *				do_nop					      *
 *============================================================================*/
PUBLIC int do_nop(dp, m_ptr)
struct driver *dp;
message *m_ptr;
{
/* Nothing there, or nothing to do. */

  switch (m_ptr->m_type) {
  case DEV_OPEN:	return(ENODEV);
  case DEV_CLOSE:	return(OK);
  case DEV_IOCTL:	return(ENOTTY);
  default:		return(EIO);
  }
}


/*===========================================================================*
 *				nop_finish				     *
 *===========================================================================*/
PUBLIC int nop_finish()
{
/* Nothing to finish, all the work has been done by dp->dr_schedule. */
  return(OK);
}


/*===========================================================================*
 *				nop_cleanup				     *
 *===========================================================================*/
PUBLIC void nop_cleanup()
{
/* Nothing to clean up. */
}


/*===========================================================================*
 *				clock_mess				     *
 *===========================================================================*/
PUBLIC void clock_mess(ticks, func)
int ticks;			/* how many clock ticks to wait */
watchdog_t func;		/* function to call upon time out */
{
/* Send the clock task a message. */

  message mess;

  mess.m_type = SET_ALARM;
  mess.CLOCK_PROC_NR = proc_number(proc_ptr);
  mess.DELTA_TICKS = (long) ticks;
  mess.FUNC_TO_CALL = (sighandler_t) func;
  sendrec(CLOCK, &mess);
}


/*============================================================================*
 *				do_diocntl				      *
 *============================================================================*/
PUBLIC int do_diocntl(dp, m_ptr)
struct driver *dp;
message *m_ptr;			/* pointer to ioctl request */
{
/* Carry out a partition setting/getting request. */
  struct device *dv;
  phys_bytes user_phys, entry_phys;
  struct partition entry;

  if (m_ptr->REQUEST != DIOCSETP && m_ptr->REQUEST != DIOCGETP) return(ENOTTY);

  /* Decode the message parameters. */
  if ((dv = (*dp->dr_prepare)(m_ptr->DEVICE)) == NIL_DEV) return(ENXIO);

  user_phys = numap(m_ptr->PROC_NR, (vir_bytes) m_ptr->ADDRESS, sizeof(entry));
  if (user_phys == 0) return(EFAULT);

  entry_phys = vir2phys(&entry);

  if (m_ptr->REQUEST == DIOCSETP) {
	/* Copy just this one partition table entry. */
	phys_copy(user_phys, entry_phys, (phys_bytes) sizeof(entry));
	dv->dv_base = entry.base;
	dv->dv_size = entry.size;
  } else {
	/* Return a partition table entry and the geometry of the drive. */
	entry.base = dv->dv_base;
	entry.size = dv->dv_size;
	(*dp->dr_geometry)(&entry);
	phys_copy(entry_phys, user_phys, (phys_bytes) sizeof(entry));
  }
  return(OK);
}
