#if (MACHINE == ATARI)
/*
 * This file contains a driver for the Hard Disk Controller (HDC)
 * on the Atari ST.
 * If yor drive is an old Supra drive you perhaps want to compile 
 * using -DSUPRA. The code added with #ifdef SUPRA/#endif is taken 
 * from usenet and not verified (since I do not have such a drive)
 *
 * The driver supports two operations: read a block and write a block.
 * It accepts two messages, one for reading and one for writing,
 * both using message format m2 and with the same parameters:
 *
 *    m_type      DEVICE    PROC_NR     COUNT    POSITION  ADRRESS
 * ----------------------------------------------------------------
 * |  DISK_READ | device  | proc nr |  bytes  |  offset | buf ptr |
 * |------------+---------+---------+---------+---------+---------|
 * | DISK_WRITE | device  | proc nr |  bytes  |  offset | buf ptr |
 * |--------------------------------------------------------------|
 * |SCATTERED_IO| device  | proc nr | requests|         | iov ptr |
#ifdef CLOCKS
 * |------------+---------+---------+---------+---------+---------|
 * | DISK_IOCTL | device  | proc nr |func code| address |         |
#endif 
 * ----------------------------------------------------------------
 *
 * The file contains one entry point:
 *
 *	winchester_task: main entry when system is brought up
 *
 * A single ST may have several controllers.
 * Each controller support up to two drives.
 * Each physical drive contains up to 4 partitions, but for MINIX
 * each physical drive contains 8 minor devices, so that
 *	DEVICE = (contr << 4) | (drive << 3) | minor;
 * These 8 minor devices per drive are interpreted as follows:
 *	d+0:	drive descriptor (sector 0)
 *	d+1:	partition 1	according to drive descriptor
 *	d+2:	partition 2	according to drive descriptor
 *	d+3:	partition 3	according to drive descriptor
 *	d+4:	partition 4	according to drive descriptor
 *	d+5:	whole disk
 *	d+6:	not used (later: whole disk but no badblock translation)
 *	d+7:	not used (later: head into shipping position)
 *
 * Multiple controllers are not yet tested.
 * Multiple drives per controller are not yet tested.
 *
 * TODO:
 * - add more status checking of HDC and DMA
 * - find out which partitions are minix and which not
 * - obey bad sector info
 * - only access partitions with pi_id == "MIX" (prog to modify pi_id?)
 */

#include "kernel.h"
#include <minix/callnr.h>
#include <minix/com.h>
#include "proc.h"

#include "staddr.h"
#include "stmfp.h"
#include "sthdc.h"
#include "stdma.h"

#define TRACE(x)	/* x */
#define DEBUG(x)	x

#ifdef CLOCKS
#ifndef DISK_IOCTL
# define DISK_IOCTL TTY_IOCTL
#endif

#endif /* CLOCKS */
/* Parameters for the disk drive. */
#define SECTOR_SIZE	512	/* physical sector size in bytes */
#define	MAX_MINOR	(NR_DRIVES<<3)
#define MAX_ERRORS	10	/* how often to try rd/wt before quitting */
/* dis/enable interrupts */
#define IENABLE()	MFP->mf_ierb |= IB_DINT
#define IDISABLE()	MFP->mf_ierb &= ~IB_DINT

/* timing constants */
#define	HDC_DELAY	0	/* for dma[rw]dat() */
#define	HDC_POLL	1000	/* polling of MFP for interrupt bit */

PRIVATE struct pi pi[MAX_MINOR];/* begin and size of any minor device */
PRIVATE	struct hi hi;		/* buffer for drive descriptor */
PRIVATE message mess;		/* message buffer for in and out */

static int do_rdwt();
static int do_xfer();
static void cmdhead();
static int cmdtail();
static int poll();
static void hdcint();

/*===========================================================================*
 *				winchester_task				     *
 *===========================================================================*/
PUBLIC void winchester_task()
{
  register	r, drive, minor, caller, procno;

 /*
  * Initialize the partition description for all minor devices
  */
  for (drive = 0; drive < NR_DRIVES; drive++) {
	minor = drive << 3;
	/* read sector 0 of the drive and copy the partition info */
	pi[minor].pi_size = 1;
	dmagrab(WINCHESTER, hdcint);
	r = do_xfer(drive, (phys_bytes)&hi, 0L, 1, DISK_READ);
	dmafree(WINCHESTER);
	if (r != OK) {
		pi[minor].pi_size = 0;
		continue;
	}
	for (r = 0, minor++; r < NPARTS; r++, minor++) {
		pi[minor] = hi.hd_pi[r];
		if (pi[minor].pi_flag == PI_INVALID)
			pi[minor].pi_size = 0;
	}
	/* the next minor number is for the whole device */
	/* don't overwrite partition table; start at sector 1 */
	pi[minor].pi_start = 1;
	pi[minor].pi_size = hi.hd_size - SECTOR_SIZE;
  }
  TRACE(
	for (r = 0; r < MAX_MINOR; r++)
		printf("hd%d: 1st=%D, tot=%D\n", r,
			pi[r].pi_start,
			pi[r].pi_size
		);
  );
  TRACE(printf("winchester: task started\n"));

  /*
   * The main loop of the disk task.
   * It waits for a message, carries it out, and sends a reply.
   */
  while (TRUE) {
	receive(ANY, &mess);
	if (mess.m_source < 0)
		panic("disk task got message from ", mess.m_source);
	TRACE(printf("hd: received %d from %d\n",mess.m_type,mess.m_source));
	caller = mess.m_source;
	procno = mess.PROC_NR;

	/* Now carry out the work. */
	switch (mess.m_type) {
	    case DISK_READ:
	    case DISK_WRITE:	r = do_rdwt(&mess);	break;
	    case SCATTERED_IO:	r = do_vrdwt(&mess, do_rdwt); break;
#ifdef CLOCKS
	    case DISK_IOCTL:	r = do_ioctl(&mess);	break;
#endif /* CLOCKS */
	    default:		r = EINVAL;		break;
	}

	/* Finally, prepare and send the reply message. */
	mess.m_type = TASK_REPLY;	
	mess.REP_PROC_NR = procno;
	mess.REP_STATUS = r;	/* # of bytes transferred or error code */
	send(caller, &mess);	/* send reply to caller */
  }
}


/*===========================================================================*
 *				do_rdwt					     *
 *===========================================================================*/
PRIVATE int do_rdwt(mp)
register message *mp;
{
  register struct proc	*rp;
  register		r, errors, count, rw, drive, minor;
  register long		secnum, avail;
  register phys_bytes	address;

  rw = mp->m_type;
  minor = mp->DEVICE;
  drive = minor >> 3;
  if (drive < 0 || drive >= NR_DRIVES)
	return(EIO);
  if (pi[minor].pi_size == 0)
	return(EIO);
  if ((mp->POSITION % SECTOR_SIZE) != 0)
	return(EINVAL);
  secnum = (long)(mp->POSITION / SECTOR_SIZE);
  count = mp->COUNT;
  if ((count % SECTOR_SIZE) != 0)
	return(EINVAL);
  rp = proc_addr(mp->PROC_NR);
  address = umap(rp, D, (vir_bytes) mp->ADDRESS, (vir_bytes) count);
  if (address == 0)
	return(EINVAL);
  count /= SECTOR_SIZE;
  TRACE(printf("hd%d: %s: sec=%D; cnt=%d\n",
	minor, rw == DISK_READ ? "read" : "write", secnum, count));
  avail = pi[minor].pi_size - secnum;
  if (avail <= 0)
	return(0);
  if (avail < count)
	count = avail;
  if (count <= 0)
	return(0);
  secnum += pi[minor].pi_start;
  rp->p_physio = 1;		/* disable (un)shadowing */
  dmagrab(WINCHESTER, hdcint);
  /* This loop allows a failed operation to be repeated. */
  for (errors = 0; errors < MAX_ERRORS; errors++) {
	r = do_xfer(drive, address, secnum, count, rw);
	if (r == OK)
		break;		/* if successful, exit loop */
  }
  dmafree(WINCHESTER);
  rp->p_physio = 0;		/* enable (un)shadowing */
  if (r != OK)
	return(EIO);
  return(count * SECTOR_SIZE);
}

/*===========================================================================*
 *				do_xfer					     *
 *===========================================================================*/

#ifdef SUPRA
#define PNK_DELAY	50 	/* tunable */
#endif

PRIVATE int do_xfer(drive, address, sector, count, rw)
int		drive;
phys_bytes 	address;
long		sector;
int		count;
int		rw;
{
  register	r, s, wrbit;

  /*
   * Carry out the transfer. All parameters have been checked and
   * are set up properly.
   *
   * Every single byte written to the hdc will cause an interrupt.
   * Thus disable interrupts while communicating with hdc. Ready test
   * will be done by busy waiting. Only for real hard disk operations
   * interrupts will be enabled.
   */
  TRACE(printf("hd drive:%d address:0x%X sector:%D count=%d cmd:%s\n",
	drive, address, sector, count, (rw==DISK_READ)?"READ":"WRITE")
  );
  IDISABLE();
  if (rw == DISK_READ) {
	cmdhead(drive, HD_RD);		/* command code */
	dmaaddr(address);		/* DMA address setup */
	wrbit = 0;
  } else {
	dmaaddr(address);		/* DMA address setup */
	cmdhead(drive, HD_WR);		/* command code */
	wrbit = WRBIT;
  }
  r = cmdtail(drive, sector, count);	/* command parameters */
#ifndef SUPRA
  IENABLE();
#endif
  if (r == OK) {
#ifdef SUPRA
	IENABLE();
#endif
	dmacomm(wrbit | FDC | SCREG, count, HDC_DELAY);
	DMA->dma_mode = wrbit | FDC | HDC | A0;
	dmawcmd(0, wrbit);
	receive(HARDWARE, &mess);	/* Wait for interrupt. */
#ifdef SUPRA
	IDISABLE();
#endif
	s = dmardat(wrbit | FDC | HDC | A0, HDC_DELAY);
	if (s & HDC_CC) {
#ifdef SUPRA
	  if ((s & HDC_CC) != 2) /* 2: invalid cyl/no drive */
#endif
		printf("hd: %s: drive=%d sector=%D status=0x%x\n",
			wrbit ? "write" : "read", drive, sector, s&0xFF);
		r = ERROR;
	}
  }
  if (dmardat(FDC, HDC_DELAY))		/* finish HDC command */
	;
#ifdef SUPRA
	for (s = 0; s< PNK_DELAY; s++) {} /* Guarantee interrupt is gone */
	IENABLE();			  /* re-enable normal interrupts */
#endif
  return(r);
}

/*===========================================================================*
 *				cmdhead/tail				     *
 *===========================================================================*/

PRIVATE void cmdhead(drive, cmd)
int drive;
int cmd;
{
  DMA->dma_mode = FDC | HDC;
  dmawcmd((short)(((drive>>1)<<5) | (cmd&0x1F)), FDC | HDC | A0);
}

PRIVATE int cmdtail(drive, sector, count)
int drive;
long sector;
int count;
{
  /* Write 4 (not 5!) parameter bytes of an I/O command */
  DMA->dma_mode = FDC | HDC | A0;
  if (poll() != OK)
	return(ERROR);
  dmawcmd((short) (((drive&1)<<5) | (((int)(sector>>16))&0x1F)), FDC | HDC | A0);
  if (poll() != OK)
	return(ERROR);
  dmawcmd((short) ((int)sector >> 8), FDC | HDC | A0);
  if (poll() != OK)
	return(ERROR);
  dmawcmd((short) sector, FDC | HDC | A0);
  if (poll() != OK)
	return(ERROR);
  dmawcmd((short) count, FDC | HDC | A0);
  if (poll() != OK)
	return(ERROR);
  return(OK);
}

/*===========================================================================*
 *				poll					     *
 *===========================================================================*/
PRIVATE int poll()
{
  register i;

  /* wait until hdc signals ready - or return ERROR after t tries */
  for (i = HDC_POLL; --i >= 0; )
	if ((MFP->mf_gpip & IO_DINT) == 0)
		return(OK);
  return(ERROR);
}

/*===========================================================================*
 *				hdcint					     *
 *===========================================================================*/

PRIVATE void hdcint()
{
  interrupt(WINCHESTER);
}

#ifdef CLOCKS
#include <sgtty.h>
#define XFERSIZE 13
/*===========================================================================*
 *				do_ioctl				     *
 *===========================================================================*/
PRIVATE int do_ioctl(mp)
register message *mp;
{
  register phys_bytes	address;
  register struct proc	*rp;
  int r;
	
  rp = proc_addr(mp->PROC_NR);
  address = umap(rp, D, (vir_bytes) mp->POSITION, (vir_bytes) XFERSIZE);
  switch(mp->TTY_REQUEST) {
     case DC_RBMS100:
     case DC_RBMS200:
     case DC_RSUPRA:
     case DC_RICD:
	  r = do_xbms(address,XFERSIZE,DISK_READ,(int)mp->TTY_REQUEST);
	  break;
     case DC_WBMS100:
     case DC_WBMS200:
	  r = do_xbms(address,XFERSIZE,DISK_WRITE,(int)mp->TTY_REQUEST);
	  break;
     default:
	r = EINVAL;
  }
  return(r);
}
#endif /* CLOCKS */
#endif 
