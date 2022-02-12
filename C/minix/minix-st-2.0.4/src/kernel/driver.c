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
 * | DEV_GATHER | device  | proc nr | iov len |  offset | iov ptr |
 * |------------+---------+---------+---------+---------+---------|
 * | DEV_SCATTER| device  | proc nr | iov len |  offset | iov ptr |
 * |------------+---------+---------+---------+---------+---------|
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
#include <sys/ioc_disk.h>
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
FORWARD _PROTOTYPE( int do_rdwt, (struct driver *dr, message *mp) );
FORWARD _PROTOTYPE( int do_vrdwt, (struct driver *dr, message *mp) );


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
	/* Check if a timer expired. */
	if (proc_ptr->p_exptimers != NULL) tmr_exptimers();

	/* Wait for a request to read or write a disk block. */
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
	case DEV_OPEN:		r = (*dp->dr_open)(dp, &mess);	break;
	case DEV_CLOSE:		r = (*dp->dr_close)(dp, &mess);	break;
	case DEV_IOCTL:		r = (*dp->dr_ioctl)(dp, &mess);	break;

	case DEV_READ:
	case DEV_WRITE:		r = do_rdwt(dp, &mess);		break;

	case DEV_GATHER:
	case DEV_SCATTER:	r = do_vrdwt(dp, &mess);	break;

	case HARD_INT:		/* Leftover interrupt or expired timer. */
				continue;

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
  unsigned left;

  tmp_buf = buffer;
  tmp_phys = vir2phys(buffer);

  if ((left = dma_bytes_left(tmp_phys)) < DMA_BUF_SIZE) {
	/* First half of buffer crosses a 64K boundary, can't DMA into that */
	tmp_buf += left;
	tmp_phys += left;
  }
#else /* CHIP != INTEL */
  tmp_phys = vir2phys(tmp_buf);
#endif /* CHIP != INTEL */
}


/*===========================================================================*
 *				do_rdwt					     *
 *===========================================================================*/
PRIVATE int do_rdwt(dp, mp)
struct driver *dp;		/* device dependent entry points */
message *mp;			/* pointer to read or write message */
{
/* Carry out a single read or write request. */
  iovec_t iovec1;
  int r, opcode;
  phys_bytes phys_addr;

  /* Disk address?  Address and length of the user buffer? */
  if (mp->COUNT < 0) return(EINVAL);

  /* Check the user buffer. */
  phys_addr = numap(mp->PROC_NR, (vir_bytes) mp->ADDRESS, mp->COUNT);
  if (phys_addr == 0) return(EFAULT);

  /* Prepare for I/O. */
  if ((*dp->dr_prepare)(mp->DEVICE) == NIL_DEV) return(ENXIO);

  /* Create a one element scatter/gather vector for the buffer. */
  opcode = mp->m_type == DEV_READ ? DEV_GATHER : DEV_SCATTER;
  iovec1.iov_addr = (vir_bytes) mp->ADDRESS;
  iovec1.iov_size = mp->COUNT;

  /* Transfer bytes from/to the device. */
  r = (*dp->dr_transfer)(mp->PROC_NR, opcode, mp->POSITION, &iovec1, 1);

  /* Return the number of bytes transferred or an error code. */
  return(r == OK ? (mp->COUNT - iovec1.iov_size) : r);
}


/*==========================================================================*
 *				do_vrdwt				    *
 *==========================================================================*/
PRIVATE int do_vrdwt(dp, mp)
struct driver *dp;	/* device dependent entry points */
message *mp;		/* pointer to read or write message */
{
/* Carry out an device read or write to/from a vector of user addresses.
 * The "user addresses" are assumed to be safe, i.e. FS transferring to/from
 * its own buffers, so they are not checked.
 */
  static iovec_t iovec[NR_IOREQS];
  iovec_t *iov;
  phys_bytes iovec_phys, user_iovec_phys;
  size_t iovec_size;
  unsigned nr_req;
  int r;

  nr_req = mp->COUNT;	/* Length of I/O vector */

  if (mp->m_source < 0) {
	/* Called by a task, no need to copy vector. */
	iov = (iovec_t *) mp->ADDRESS;
  } else {
	/* Copy the vector from the caller to kernel space. */
	if (nr_req > NR_IOREQS) nr_req = NR_IOREQS;
	iovec_size = nr_req * sizeof(iovec[0]);
	user_iovec_phys = numap(mp->m_source,
				(vir_bytes) mp->ADDRESS, iovec_size);
	if (user_iovec_phys == 0) panic("bad I/O vector by", mp->m_source);

	iovec_phys = vir2phys(iovec);
	phys_copy(user_iovec_phys, iovec_phys, (phys_bytes) iovec_size);
	iov = iovec;
  }

  /* Prepare for I/O. */
  if ((*dp->dr_prepare)(mp->DEVICE) == NIL_DEV) return(ENXIO);

  /* Transfer bytes from/to the device. */
  r = (*dp->dr_transfer)(mp->PROC_NR, mp->m_type, mp->POSITION, iov, nr_req);

  /* Copy the I/O vector back to the caller. */
  if (mp->m_source >= 0) {
	  phys_copy(iovec_phys, user_iovec_phys, (phys_bytes) iovec_size);
  }
  return(r);
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
PUBLIC int do_nop(dp, mp)
struct driver *dp;
message *mp;
{
/* Nothing there, or nothing to do. */

  switch (mp->m_type) {
  case DEV_OPEN:	return(ENODEV);
  case DEV_CLOSE:	return(OK);
  case DEV_IOCTL:	return(ENOTTY);
  default:		return(EIO);
  }
}


/*===========================================================================*
 *				nop_prepare				     *
 *===========================================================================*/
PUBLIC struct device *nop_prepare(device)
{
/* Nothing to prepare for. */
  return(NIL_DEV);
}



/*===========================================================================*
 *				nop_cleanup				     *
 *===========================================================================*/
PUBLIC void nop_cleanup()
{
/* Nothing to clean up. */
}



/*===========================================================================*
 *				nop_task				     *
 *===========================================================================*/
PUBLIC void nop_task()
{
/* Unused controllers are "serviced" by this task. */
  struct driver nop_tab = {
	no_name,
	do_nop,
	do_nop,
	do_nop,
	nop_prepare,
	NULL,
	nop_cleanup,
	NULL,
  };
  driver_task(&nop_tab);
}


/*============================================================================*
 *				do_diocntl				      *
 *============================================================================*/
PUBLIC int do_diocntl(dp, mp)
struct driver *dp;
message *mp;			/* pointer to ioctl request */
{
/* Carry out a partition setting/getting request. */
  struct device *dv;
  phys_bytes user_phys, entry_phys;
  struct partition entry;

  if (mp->REQUEST != DIOCSETP && mp->REQUEST != DIOCGETP) return(ENOTTY);

  /* Decode the message parameters. */
  if ((dv = (*dp->dr_prepare)(mp->DEVICE)) == NIL_DEV) return(ENXIO);

  user_phys = numap(mp->PROC_NR, (vir_bytes) mp->ADDRESS, sizeof(entry));
  if (user_phys == 0) return(EFAULT);

  entry_phys = vir2phys(&entry);

  if (mp->REQUEST == DIOCSETP) {
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
