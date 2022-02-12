#if (CHIP == M68000)
/*
 * This file contains a driver for the Floppy Disk Controller (FDC)
 * on the Atari ST. It uses the WD 1772 chip, modified for steprates.
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
 * ----------------------------------------------------------------
 *
 * The file contains two entry points:
 *
 *	floppy_task:	main entry when system is brought up
 *	fd_timer:	used to deselect drives, called from clock.c
 *
 * The ST floppy disk controller shares the access to the DMA circuitry
 * with other devices. For this reason the floppy disk controller makes
 * use of some special DMA accessing code.
 *
 * Interrupts from the FDC are in fact DMA interrupts which get their
 * first level handling in stdma.c . If the floppy driver is currently
 * using DMA the interrupt is signalled to the floppy task.
 */

#include "kernel.h"
#include <minix/callnr.h>
#include <minix/com.h>
#include "proc.h"

#include "staddr.h"
#include "stfdc.h"
#include "stdma.h"
#include "stsound.h"

#define	ASSERT(x)	if (!(x)) panic("fd: ASSERT(x) failed",NO_NUM);
#define TRACE(x)	/* x */
#define DEBUG(x)	x

#define	FDC_DELAY	32	/* for dma[rw]dat() */

/* Parameters for the disk drive. */
#define TRACK_SIZE	7168	/* track size in bytes for formatting */
#define SECTOR_SIZE	512	/* physical sector size in bytes */
#define NR_SECTORS	9	/* number of sectors per track */
#define NR_CYLINDERS	80	/* number of cylinders */
#define NR_FLOPDRIVES	2	/* maximum number of drives */
#define NR_TYPES	2	/* number of diskette/drive combinations */
#define MAX_ERRORS	10	/* how often to try rd/wt before quitting */

/* return values of xfer_ok(): */
#define X_OK		0
#define X_AGAIN		1
#define X_ERROR		2
#define X_FAIL		3

PRIVATE int curcyl[NR_FLOPDRIVES];	/* current cylinder (-1 if not calibrated) */

PRIVATE message mess;		/* message buffer for in and out */

/*
 * Two combinations of diskette/drive are supported:
 *   # Drive  Diskette  Heads  Comment
 *   0   Any      360K      1  Single Sided
 *   1  720K      720K      2  Double Sided
 */
PRIVATE int nr_heads[NR_TYPES]	= {1,2};	/* tracks/cylinder */

PRIVATE struct xfer {
	int	x_rw;		/* read or write */
	int	x_drive;	/* drive number */
	int	x_secnum;	/* current sector */
	phys_bytes x_address;	/* current physical address */
	int	x_count;	/* bytes still to transfer */
	int	x_errors;	/* errors on current sector */
	int	x_cmd;		/* controller command */
} xfer;

#define	DRIVE(d)	((d) & 0x07)
#define	DTYPE(d)	(((d) >> 3) & 0x07)
#define FORMAT(d)	((d) & 0x40)

static int do_open();
static int do_rdwt();
static int do_xfer();
static int select();
static void deselect();
static void fdcint();
static int xfer_done();
static int xfer_ok();
  
/*===========================================================================*
 *				floppy_task				     *
 *===========================================================================*/
PUBLIC void floppy_task()
{
  register r, drive, caller, procno;

  /*
   * The main loop of the disk task.
   * It waits for a message, carries it out, and sends a reply.
   */
  TRACE(printf("fd: task started\n"));
  dmagrab(FLOPPY, fdcint);
  dmawdat(FDC_CS, IRUPT, FDC_DELAY);		/* reset controller */
  dmafree(FLOPPY);
  for (drive = 0; drive < NR_FLOPDRIVES; drive++)
	curcyl[drive] = -1;	/* uncalibrated */
  while (TRUE) {
	receive(ANY, &mess);
	ASSERT(mess.m_source >= 0);
	TRACE(printf("fd: received %d from %d\n",mess.m_type,mess.m_source));
	caller = mess.m_source;
	procno = mess.PROC_NR;

	/* Now carry out the work. */
	switch (mess.m_type) {
	    case DISK_READ:
	    case DISK_WRITE:	r = do_rdwt(&mess);	break;
	    case SCATTERED_IO:	r = do_vrdwt(&mess, do_rdwt); break;
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
  register struct proc *rp;
  register struct xfer *xp;
  register nbytes;

  xp = &xfer;
  xp->x_rw = mp->m_type;
  xp->x_drive = mp->DEVICE;
  if (DRIVE(xp->x_drive) >= NR_FLOPDRIVES)
	return(EIO);
  if (DTYPE(xp->x_drive) >= NR_TYPES)
	return(EIO);
  nbytes = mp->COUNT;
  xp->x_count = nbytes;
  if ((mp->POSITION % SECTOR_SIZE) != 0)
	return(EINVAL);
  if ((nbytes % SECTOR_SIZE) != 0)
	return(EINVAL);
  if (FORMAT(xp->x_drive)) {
	if (nbytes != TRACK_SIZE || xp->x_rw != DISK_WRITE)
		return(EINVAL);
	xp->x_secnum = (int)(mp->POSITION/TRACK_SIZE);
  }
  else
	xp->x_secnum = (int)(mp->POSITION/SECTOR_SIZE);
  rp = proc_addr(mp->PROC_NR);
  xp->x_address = umap(rp, D, (vir_bytes) mp->ADDRESS, (vir_bytes) nbytes);
  if (xp->x_address == 0)
	return(EINVAL);
  if (nbytes == 0)
	return(0);
  rp->p_physio = 1;		/* disable (un)shadowing */
  dmagrab(FLOPPY, fdcint);
  xp->x_errors = 0;
  if (do_xfer()) {
	receive(HARDWARE, &mess);
	deselect();
  }
  dmafree(FLOPPY);
  rp->p_physio = 0;		/* enable (un)shadowing */
  if (xp->x_count == nbytes)
	return(0);		/* nothing transferred */
  if (xp->x_count != 0)
	return(EIO);		/* partial transfer */
  return(nbytes);
}

/*===========================================================================*
 *				do_xfer					     *
 *===========================================================================*/
PRIVATE int do_xfer()
{
  register struct xfer *xp;
  register d, head, cylinder, sector, hbit;

  xp = &xfer;

  d = DTYPE(xp->x_drive);
  if (FORMAT(xp->x_drive))
	cylinder = xp->x_secnum;
  else
	cylinder = xp->x_secnum / NR_SECTORS;
  head = cylinder % nr_heads[d];
  cylinder = cylinder / nr_heads[d];
  if (cylinder >= NR_CYLINDERS)
	return(0);

  d = DRIVE(xp->x_drive);

  hbit = 0;
  if (select(d, head) != 0)
	hbit = HBIT;	/* motor on, suppress spin up sequence */

  if (curcyl[d] == -1) {
	/* 
	 * Recalibrate, since we lost track of head positioning.
	 * The floppy disk controller has no way of determining its
	 * absolute arm position (cylinder).  Instead, it steps the
	 * arm a cylinder at a time and keeps track of where it
	 * thinks it is (in software).  However, after a SEEK, the
	 * hardware reads information from the diskette telling
	 * where the arm actually is.  If the arm is in the wrong place,
	 * a recalibration is done, which forces the arm to cylinder 0.
	 * This way the controller can get back into sync with reality.
	 */
	TRACE(printf("fd%d: recalibrate\n", xp->x_drive));
	if (FORMAT(xp->x_drive))
		dmawdat(FDC_CS, RESTORE|hbit, FDC_DELAY);
	else
		dmawdat(FDC_CS, RESTORE|VBIT|hbit, FDC_DELAY);
	xp->x_cmd = RESTORE;
	return(1);
  }

  dmawdat(FDC_TR, curcyl[d], FDC_DELAY);

  /*
   * Issue a SEEK command on the indicated drive unless the arm is
   * already positioned on the correct cylinder.
   */
  if (cylinder != curcyl[d]) {
	curcyl[d] = cylinder;	/* be optimistic */
	dmawdat(FDC_DR, cylinder, FDC_DELAY);
	if (FORMAT(xp->x_drive)) {
		if (cylinder == 0)
			dmawdat(FDC_CS, RESTORE|hbit, FDC_DELAY);
		else
			dmawdat(FDC_CS, SEEK|RATE3|hbit, FDC_DELAY);
	}
	else
		dmawdat(FDC_CS, SEEK|RATE3|VBIT|hbit, FDC_DELAY);
	xp->x_cmd = SEEK;
	return(1);
  }

  TRACE(printf("fd%d: %s: secnum=%d,cylinder=%d,sector=%d,head=%d\n",
	xp->x_drive, xp->x_rw == DISK_READ ? "read" : "write",
	xp->x_secnum, cylinder, sector, head));

  /* The drive is now on the proper cylinder.  Read or write 1 block. */
  sector = xp->x_secnum % NR_SECTORS;
  sector++;	/* start numbering at 1 */

  dmawdat(FDC_SR, sector, FDC_DELAY);
  dmaaddr(xp->x_address);	/* DMA address setup */

  if (xp->x_rw == DISK_READ) {
	/* Issue the command */
	dmacomm(FDC | SCREG, 1, 0);
	dmawdat(FDC_CS, F_READ|hbit, FDC_DELAY);
	xp->x_cmd = F_READ;
  } else {
	/* Issue the command */
	if (FORMAT(xp->x_drive)) {
		dmacomm(WRBIT | FDC | SCREG, TRACK_SIZE/SECTOR_SIZE, FDC_DELAY);
		dmawdat(WRBIT | FDC_CS, WRITETR|hbit, FDC_DELAY);
	}
	else {
		dmacomm(WRBIT | FDC | SCREG, 1, FDC_DELAY);
		dmawdat(WRBIT | FDC_CS, F_WRITE|hbit, FDC_DELAY);
	}
	xp->x_cmd = F_WRITE;
  }
  return(1);
}

/*===========================================================================*
 *			select,	deselect, fd_timer			     *
 *===========================================================================*/

PRIVATE int selected;		/* drive/head currently selected */
PRIVATE int selectic = 30;	/* # of fd_timer calls to deselect */
PRIVATE int motoron;		/* for how long will motor run? */

PRIVATE int select(drive, head)
int drive;
int head;
{
  register i, s, spinning;

  TRACE(printf("fd: select (drive %d, head %d)\n", drive, head));
  spinning = motoron;
  motoron = 5;		/* will run for more than 500 msec */
  selectic = -30;	/* error if not ready within 3 sec */
  i = (drive == 1 ? PA_FLOP1 : PA_FLOP0);
  i |= head;
  if (i != selected) {
	selected = i;
	s = lock();
	SOUND->sd_selr = YM_IOA;
	SOUND->sd_wdat = (SOUND->sd_rdat & 0xF8) | (i ^ 0x07);
	restore(s);
  }
  return(spinning);
}

PRIVATE void deselect()
{
  TRACE(printf("fd: deselect\n"));
  selectic = 30;	/* postpone for 30 * 100 msec == 3 sec */
}

PUBLIC void fd_timer()
{
/*
 * Perform three functions:
 * 1. Estimate when motor stops running
 * 2. Force interrupt if drive does not respond
 * 3. Deselect drive(s) when all motors stopped spinning
 */
  register s, wrbit;

  if (selectic == 0)
	return;
  if (motoron)
	--motoron;
  if (selectic < 0) {
	if (++selectic == 0) {
		s = lock();
		wrbit = xfer.x_cmd == F_WRITE ? WRBIT : 0;
		xfer.x_cmd = IRUPT;
		dmawdat(FDC_CS, wrbit|IRUPT, FDC_DELAY);
		fdcint();
		restore(s);
	}
	return;
  }
  if (--selectic != 0)
	return;
  selected = 0;
  s = lock();
  SOUND->sd_selr = YM_IOA;
  SOUND->sd_wdat = SOUND->sd_rdat | 0x07;
  restore(s);
}

/*===========================================================================*
 *				fdcint					     *
 *===========================================================================*/
PRIVATE void fdcint()
{
  ASSERT(xfer.x_count);
  if (xfer_done() == 0)
	return;
  interrupt(FLOPPY);
}

/*===========================================================================*
 *				xfer_done				     *
 *===========================================================================*/
PRIVATE int xfer_done()
{
  register struct xfer *xp;

  xp = &xfer;
  switch (xfer_ok()) {
  case X_FAIL:
	return(1);
  case X_ERROR:
	xp->x_errors++;
	if (xp->x_errors == MAX_ERRORS)
		return(1);
	break;
  case X_AGAIN:
	break;
  case X_OK:
	xp->x_errors = 0;
	xp->x_secnum++;
	if (FORMAT(xp->x_drive)) {
		xp->x_address += TRACK_SIZE;
		xp->x_count -= TRACK_SIZE;
	}
	else {
		xp->x_address += SECTOR_SIZE;
		xp->x_count -= SECTOR_SIZE;
	}
	if (xp->x_count == 0)
		return(1);
	break;
  }
  if (do_xfer() == 0)
	return(1);
  return(0);
}

/*===========================================================================*
 *				xfer_ok					     *
 *===========================================================================*/
PRIVATE int xfer_ok()
{
  register struct xfer *xp;
  register status;

  xp = &xfer;
  switch (xp->x_cmd) {
  case IRUPT:
	printf("fd%d: timeout\n", xp->x_drive);
	curcyl[DRIVE(xp->x_drive)] = -1;
	return(X_ERROR);
  case F_READ:
	/* Test for DMA error */
	status = dmastat(FDC_CS | SCREG, 0);
	if ((status & DMAOK) == 0) {
		printf("fd%d: read: dma status = 0x%x\n",
			xp->x_drive, DMA->dma_stat);
		return(X_ERROR);
	}
	/* Get controller status and check for errors. */
	status = dmardat(FDC_CS, FDC_DELAY);
	if (status & (RNF | CRCERR | LD_T00)) {
		printf("fd%d: read sector %d: fdc status = 0x%x\n",
			xp->x_drive, xp->x_secnum, status&0xFF);
		curcyl[DRIVE(xp->x_drive)] = -1;
		return(X_ERROR);
	}
	break;
  case F_WRITE:
	/* Get controller status and check for errors. */
	status = dmardat(WRBIT | FDC_CS, FDC_DELAY);
	if (status & WRI_PRO) {
		printf("fd%d: write protected\n", xp->x_drive);
		return(X_FAIL);
	}
	if (status & (RNF | CRCERR | LD_T00)) {
		printf("fd%d: write sector %d: fdc status = 0x%x\n",
			xp->x_drive, xp->x_secnum, status&0xFF);
		curcyl[DRIVE(xp->x_drive)] = -1;
		return(X_ERROR);
	}
	break;
  case SEEK:
	status = dmardat(FDC_CS, FDC_DELAY);
	if (status & (RNF | CRCERR)) {
		curcyl[DRIVE(xp->x_drive)] = -1;
		return(X_ERROR);
	}
	return(X_AGAIN);
  case RESTORE:
	/* Determine if the recalibration succeeded. */
	status = dmardat(FDC_CS, FDC_DELAY);
	if (status & RNF) {
		printf("fd%d: recalibrate failed. status = 0x%x\n",
				xp->x_drive, status&0xFF);
		dmawdat(FDC_CS, IRUPT, FDC_DELAY);	/* reset controller */
		curcyl[DRIVE(xp->x_drive)] = -1;
		return(X_ERROR);
	}
	curcyl[DRIVE(xp->x_drive)] = 0;
	return(X_AGAIN);
  default:
	ASSERT(0);
  }
  return(X_OK);
}
#endif
