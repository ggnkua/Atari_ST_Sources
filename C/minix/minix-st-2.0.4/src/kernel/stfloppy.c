/*
 * This file contains a driver for the Floppy Disk Controller (FDC)
 * on the Atari ST. It uses the WD 1772 chip, modified for steprates.
 * The driver supports two operations: read a block and write a block.
 * It accepts messages for reading, for writing, for scattered I/O, for
 * control and for opening and closing a device.
 *
 * The ST floppy disk controller shares the access to the DMA circuitry
 * with other devices. For this reason the floppy disk controller makes
 * use of some special DMA accessing code.
 *
 * Interrupts from the FDC are in fact DMA interrupts which get their
 * first level handling in stdma.c . If the floppy driver is currently
 * using DMA the interrupt is signalled to the floppy task.
 *
 * For the MegaSTE and the TT HD-Drives are interfaced via DMA->fdc_mode
 * (0xFFFF860EL). For normal STs PA_USER and PA_FDDENS are used for
 * density selection. PA_FDDENS should be connected to the Shugartbus
 * signal HD-IN (Pin 2).
 * The following frequency assignment is used:
 *	PA_USER PA_FDDENS	Frequency	HD-IN
 *	0	0 		 8    Mhz	0
 *	0	1		16    Mhz	1
 *	1	0		10.24 Mhz	0
 *	1	1		 9.6  Mhz	0
 */

#include "kernel.h"
#if (MACHINE == ATARI)
#if (NR_FD_DRIVES == 0)
PUBLIC void fd_timer()
{
}
#else /* (NR_FD_DRIVES > 0) */
#ifndef VS_FLOPPY
# define VS_FLOPPY 0
#endif /* VS_FLOPPY */
#include <minix/callnr.h>
#include <minix/com.h>
#include <sgtty.h>
#include <fcntl.h>
#include <ibm/diskparm.h>

#include "proc.h"
#include "driver.h"
#include "drvlib.h"

#include "staddr.h"
#include "stfdc.h"
#include "stdma.h"
#include "stsound.h"

#define	ASSERT(x)	if (!(x)) panic("FD: ASSERT(x) failed", NO_NUM)
#define TRACE(x)	/* x */
#define TRACE1(x)	x
#define DEBUG(x)	x

#define	USE_BUF		(DMA_BUF_SIZE > BLOCK_SIZE)
#define	FDC_DELAY	32	/* for dma[rw]dat() */
#define	IRUPT_DELAY	1536	/* IRUPT command needs extra delay */

/* Parameters for the disk drive. */
#define MAX_ERRORS	8	/* how often to try rd/wt before quitting */

#define NR_TYPES	((sizeof(fparam)/(sizeof(struct fparam *) * 2)) - 1)
				/* number of formats */

/*
 * The minor device number is build as follows
 */
#if (VS_FLOPPY == 1)
/*      0pxxxx0n
 *	n     =      drive
 *	 xxxx = disk type
 *      pp    = partition
 */
#else
/*      0xxxxx0n
 *	n     =      drive
 *	xxxxx = disk type
 */
#endif /* VS_FLOPPY */
/*
 * All parameters in fparam can be set by an ioctl-system call.
 * The nr_cylinders-field of the format device is allways set
 * to the value of the corresponding non-format device.
 * The parameters of all devices (except disk types 0 and 16) are
 * read-only.
 */

/*
 * tracklen in bytes for the differnt densities
 */
#if (VS_FLOPPY == 1)
			/* DD,	QD,	HD5,  HD3 */
PRIVATE int trklen[] = { 7168, 14336, 14336, 14336 };
#define	MAX_TRACK_LEN	(16*1024)
#else
		/* DD    QD    HD5    HD3 */
PRIVATE int trklen[] = { 6656, 8192, 10752, 12800 };
#define	MAX_TRACK_LEN	(13*1024)
#endif /* VS_FLOPPY */

/*
 * temp buffer for dma transfers into "fast ram" on ST
 */
#if 0
#define	dmabuf	tmp_phys
#else
#if (DMA_BUF_SIZE >= MAX_TRACK_LEN)
#define	dmabuf	tmp_phys
#define	FL_BUF_SIZE	DMA_BUF_SIZE
#else
#define	FL_BUF_SIZE	MAX_TRACK_LEN
PRIVATE char fl_dmabuf[FL_BUF_SIZE];
#define	dmabuf	(phys_bytes)&fl_dmabuf[0]
#endif /* DMA_BUF_SIZE < MAX_TRACK_LEN */
#endif

#define	DEV_TYPE_BITS	0x7c	/* drive type + 1, if nonzero */
#define	DEV_TYPE_SHIFT	2	/* right shift to normalize type bits */
#define	FORMAT_DEV_BIT	0x80	/* bit in minor to turn write into format */
#define	MAX_SECTORS	21
#define	NO_CYL		100	/* floppy is uncalibrated */

/*
 * DRIVE returns the select code
 */
#define	DRIVE(d)	((d) & 0x01)

/*
 * DTYPE returns the disk type number
 */
#define	DTYPE(d)	(((d) & DEV_TYPE_BITS) >> DEV_TYPE_SHIFT)

/*
 * structure to count how many times a drive is open
 */
PRIVATE struct open_count {
	int o_cnt;
	int formatting;
} open_count[NR_FD_DRIVES] = {0};

/*
 * drive parameters
 */
#if ((ATARI_TYPE >= MSTE) || (VS_FLOPPY == 1))
PRIVATE struct hparam hparam[] = {
	{ 80, (1<<DD)|(1<<HD), I3, SIDES2, FAST },
	{ 80, (1<<DD)|(1<<HD), I3, SIDES2, FAST },
};
#else
PRIVATE struct hparam hparam[] = {
	{ 80, (1<<DD)|(1<<QD)|(1<<HD), I3, SIDES2, FAST },
	{ 80, (1<<DD)|(1<<QD)|(1<<HD), I3, SIDES2, FAST },
};
#endif /* ATARI_TYPE >= MSTE || VS_FLOPPY == 1 */

#if (VS_FLOPPY == 1)
/*
 * variable parameters for each minor device
 */
PRIVATE struct fparam fparams[] = {
{  512, 1, 10,	0, 80, SIDES2, DD,  NSTP, AUTO }, /* Autoconfig drive A    0 */
{  512, 1, 10,	0, 80, SIDES2, DD,  NSTP, AUTO }, /* Autoconfig drive B    1 */
{  512, 1, 10,  0, 80, SIDES2, DD,  NSTP, HARD }, /* Configurable drive A  2 */
{  512, 1, 10,	0, 80, SIDES2, DD,  NSTP, HARD }, /* Configurable drive B  3 */
{  512, 1,  9,	0, 80, SIDES2, DD,  NSTP, HARD }, /* 3.5'',  720k, 80 trk  4 */
{  512, 1, 10,	0, 80, SIDES2, DD,  NSTP, HARD }, /* 3.5'',  800k, 80 trk  5 */
{  512, 1, 11,	0, 80, SIDES2, DD,  NSTP, HARD }, /* 3.5'',  880k, 80 trk  6 */
{  512, 1, 18,	0, 80, SIDES2, HD,  NSTP, HARD }, /* 3.5'', 1.44M, 80 trk  7 */
{  512, 1, 20,	0, 80, SIDES2, HD,  NSTP, HARD }, /* 3.5'',  1.6M, 80 trk  8 */
{  512, 1, 21,	0, 80, SIDES2, HD,  NSTP, HARD }, /* 3.5'',  1.7M, 80 trk  9 */
{  512, 1, 10, 15, 65, SIDES2, DD,  NSTP, HARD }, /* boot disk		  10 */
{  256, 1, 16,	0, 80, SIDES2, DD,  NSTP, HARD }, /* 3.5'',  640k, 80 trk 11 */
{  256, 1, 32,	0, 80, SIDES2, DD,  NSTP, HARD }, /* 3.5'', 1.28M, 80 trk 12 */
};

PRIVATE struct fparam format;	/* fparam struct used for formatting */

PRIVATE struct fparam *fparam[][2] = {
  { &fparams[ 0], &fparams[ 1] },		/*  0 */
  { &fparams[ 4], &fparams[ 4] },		/*  1 */
  { &fparams[ 5], &fparams[ 5] },		/*  2 */
  { &fparams[ 6], &fparams[ 6] },		/*  3 */
  { &fparams[ 7], &fparams[ 7] },		/*  4 */
  { &fparams[ 8], &fparams[ 8] },		/*  5 */
  { &fparams[ 9], &fparams[ 9] },		/*  6 */
  { &fparams[10], &fparams[10] },		/*  7 */
  { &fparams[11], &fparams[11] },		/*  8 */
  { &fparams[12], &fparams[12] },		/*  9 */
  { NULL,	  NULL	       },		/*  a */
  { NULL,	  NULL	       },		/*  b */
  { NULL,	  NULL	       },		/*  c */
  { NULL,	  NULL	       },		/*  d */
  { NULL,	  NULL	       },		/*  e */
  { NULL,	  NULL	       },		/*  f */
  { &fparams[ 2], &fparams[ 3] },		/*  10 */
};
#else
/*
 * variable parameters for each minor device
 */
PRIVATE struct fparam fparams[] = {
{  512, 1, 10,	0, 80, SIDES2, DD,  NSTP, AUTO }, /* Autoconfig drive A    0 */
{  512, 1, 10,	0, 80, SIDES2, DD,  NSTP, AUTO }, /* Autoconfig drive B    1 */
{  512, 1, 10,  0, 80, SIDES2, DD,  NSTP, HARD }, /* Configurable drive A  2 */
{  512, 1, 10,	0, 80, SIDES2, DD,  NSTP, HARD }, /* Configurable drive B  3 */
{  512, 1,  9,	0, 40, SIDES2, DD,  NSTP, HARD }, /* 5.25'', 360k, 40 trk  4 */
{  512, 1, 15,	0, 80, SIDES2, HD,  NSTP, HARD }, /* 5.25'', 1.2M, 80 trk  5 */
{  512, 1,  9,	0, 40, SIDES2, DD,  DSTP, HARD }, /* 5.25'', 360k, 80 trk  6 */
{  512, 1,  9,	0, 80, SIDES2, DD,  NSTP, HARD }, /* 3.5'',  720k, 80 trk  7 */
{  512, 1,  9,	0, 40, SIDES2, DD5, DSTP, HARD }, /* 5.25'', 360k, 80 trk  8 */
{  512, 1,  9,	0, 80, SIDES2, DD5, NSTP, HARD }, /* 5.25'', 720k, 80 trk  9 */
{  512, 1, 18,	0, 80, SIDES2, HD,  NSTP, HARD }, /* 3.5'', 1.44M, 80 trk 10 */
{  512, 1, 10, 15, 65, SIDES2, DD,  NSTP, HARD }, /* boot disk		  11 */
{  512, 1, 13,	0, 80, SIDES2, QD,  NSTP, HARD }, /* 3.5'', 1.04M, 80 trk 12 */
{ 1024, 1,  7,	0, 80, SIDES2, QD,  NSTP, HARD }, /* 3.5'', 1.11M, 80 trk 13 */
{ 1024, 1, 10,	0, 80, SIDES2, HD,  NSTP, HARD }, /* 3.5'',  1.6M, 80 trk 14 */
{ 1024, 1, 11,	0, 80, SIDES2, HD,  NSTP, HARD }, /* 3.5'',  1.7M, 80 trk 15 */
};

PRIVATE struct fparam format;	/* fparam struct used for formatting */

PRIVATE struct fparam *fparam[][2] = {
  { &fparams[ 0], &fparams[ 1] },		/*  0 */
  { &fparams[ 4], &fparams[ 4] },		/*  1 */
  { &fparams[ 5], &fparams[ 5] },		/*  2 */
  { &fparams[ 6], &fparams[ 6] },		/*  3 */
  { &fparams[ 7], &fparams[ 7] },		/*  4 */
  { &fparams[ 8], &fparams[ 8] },		/*  5 */
  { &fparams[ 9], &fparams[ 9] },		/*  6 */
  { &fparams[10], &fparams[10] },		/*  7 */
  { NULL,	  NULL	       },		/*  8 */
  { NULL,	  NULL	       },		/*  9 */
  { NULL,	  NULL	       },		/*  a */
  { NULL,	  NULL	       },		/*  b */
  { NULL,	  NULL	       },		/*  c */
  { NULL,	  NULL	       },		/*  d */
  { NULL,	  NULL	       },		/*  e */
  { NULL,	  NULL	       },		/*  f */
  { &fparams[ 2], &fparams[ 3] },		/* 10 */
  { &fparams[11], &fparams[11] },		/* 11 */
  { &fparams[12], &fparams[12] },		/* 12 */
  { &fparams[13], &fparams[13] },		/* 13 */
  { &fparams[14], &fparams[14] },		/* 14 */
  { &fparams[15], &fparams[15] },		/* 15 */
};
#endif /* VS_FLOPPY */

/* return values of xfer_ok(): */
#define X_OK		0
#define X_AGAIN		1
#define X_ERROR		2
#define X_FAIL		3

#define	MINOR_fd0a	(28<<2)

PRIVATE message mess;		/* message buffer for in and out */

PRIVATE struct xfer {
  int	x_rw;			/* read or write */
  int	x_block;		/* current block */
  phys_bytes x_address;		/* current physical address */
  int	x_count;		/* bytes still to transfer */
  int	x_errors;		/* errors on current sector */
  int	x_cmd;			/* controller command */
} xfer;

/* Variables. */
PRIVATE struct floppy {		/* main drive struct, one entry per drive */
  int fl_curcyl;		/* current cylinder */
  struct fparam *fl_fparam;	/* pointer to according fparam struct */
  struct device fl_geom;	/* Geometry of the drive */
  struct device fl_part[NR_PARTITIONS];  /* partition's base & size */
} floppy[NR_FD_DRIVES], *f_fp;

PRIVATE	short f_drive;		/* selected drive */
PRIVATE	short f_device;		/* selected minor device */
PRIVATE	short fl_procnr;	/* process using device */
PRIVATE	struct device *f_dv;	/* device's base and size */

FORWARD _PROTOTYPE( int do_ioctl, (message *mp)				);
FORWARD _PROTOTYPE( int do_xfer, (void)					);
FORWARD _PROTOTYPE( int fd_select, (int drive, int head, int dense)	);
FORWARD _PROTOTYPE( void fd_deselect, (void)				);
FORWARD _PROTOTYPE( void fdcint, (void)					);
FORWARD _PROTOTYPE( int xfer_done, (void)				);
FORWARD _PROTOTYPE( int xfer_ok, (void)					);
FORWARD _PROTOTYPE( struct fparam *gparam, (int drive)			);
FORWARD _PROTOTYPE( void sparam, (int drive, struct fparam *f)		);

FORWARD _PROTOTYPE( struct device *f_prepare, (int device)		);
FORWARD _PROTOTYPE( char *f_name, (void)				);
FORWARD _PROTOTYPE( void f_cleanup, (void)				);
FORWARD _PROTOTYPE( int f_transfer, (int proc_nr, int opcode,
		    off_t position, iovec_t *iov, unsigned nr_req)	);
FORWARD _PROTOTYPE( int f_do_open, (struct driver *dp, message *m_ptr)	);
FORWARD _PROTOTYPE( int f_do_close, (struct driver *dp, message *m_ptr) );
FORWARD _PROTOTYPE( void f_geometry, (struct partition *entry)		);
FORWARD _PROTOTYPE( int f_do_diocntl, (struct driver *dp, message *m_ptr));
FORWARD	_PROTOTYPE( int chk_id_marks, (int idsec, int *secmin, int *secmax));
PRIVATE	_PROTOTYPE( void iruptdelay, (void)				);

/* Entry points to this driver. */
PRIVATE struct driver f_dtab = {
  f_name,	/* current device's name */
  f_do_open,	/* open or mount request, sense type of diskette */
  f_do_close,	/* nothing on a close */
  f_do_diocntl,	/* get or set a partitions geometry */
  f_prepare,	/* prepare for I/O on a given minor device */
  f_transfer,	/* precompute cylinder, head, sector, etc. */
  f_cleanup,	/* cleanup before sending reply to user process */
  f_geometry	/* tell the geometry of the diskette */
};


/*===========================================================================*
 *				floppy_task				     *
 *===========================================================================*/
PUBLIC void floppy_task()
{
  register struct floppy *fp;

  /*
   * The main loop of the disk task.
   * It waits for a message, carries it out, and sends a reply.
   */
  TRACE(printf("fd: task started\n"));

  for (fp = &floppy[0]; fp < &floppy[NR_FD_DRIVES]; fp++)
	fp->fl_curcyl = NO_CYL;	/* uncalibrated */

  driver_task(&f_dtab);
}

/*===========================================================================*
 *				f_prepare				     *
 *===========================================================================*/
PRIVATE struct device *f_prepare(device)
int device;
{
/* Prepare for I/O on a device. */

  f_device = device;
  f_drive = device & ~(DEV_TYPE_BITS | FORMAT_DEV_BIT);
  if (f_drive < 0 || f_drive >= NR_FD_DRIVES) return(NIL_DEV);
  if (((f_device - MINOR_fd0a) >> DEV_TYPE_SHIFT) >= NR_PARTITIONS)
	return(NIL_DEV);

  f_fp = &floppy[f_drive];
  f_dv = &f_fp->fl_geom;
  
  /* A partition? */
  if ((device &= DEV_TYPE_BITS) >= MINOR_fd0a)
	f_dv = &f_fp->fl_part[(device - MINOR_fd0a) >> DEV_TYPE_SHIFT];

  return f_dv;
}


/*===========================================================================*
 *				f_name					     *
 *===========================================================================*/
PRIVATE char *f_name()
{
/* Return a name for the current device. */
  static char name[] = "fd3";

  name[2] = '0' + f_drive;
  return name;
}

/*===========================================================================*
 *				f_transfer				     *
 *===========================================================================*/
PRIVATE int f_transfer(proc_nr, opcode, position, iov, nr_req)
int proc_nr;                    /* process doing the request */
int opcode;                     /* DEV_GATHER or DEV_SCATTER */
off_t position;                 /* offset on device to read or write */
iovec_t *iov;                   /* pointer to read or write request vector */
unsigned nr_req;                /* length of request vector */
{
  register struct xfer *xp;
  iovec_t *iop, *iov_end = iov + nr_req;
  struct fparam *f;
  unsigned int nbytes, count, chunk;
  phys_bytes first_dma_phys;
  struct proc *rp;
  phys_bytes user_base = proc_vir2phys(proc_addr(proc_nr), 0);
  int do_use_buf = USE_BUF;

  xp = &xfer;
  
  /* check iop values */
  if (open_count[f_drive].formatting && opcode == DEV_GATHER)
	return(EIO);
  if (!(f = gparam(f_device))) return(ENXIO);
  f_fp->fl_fparam = f;

  /* Check disk address. */
  if ((position % f->sector_size) != 0) return(EINVAL);

  while (nr_req > 0) {
	nbytes = 0;
	for (iop = iov; iop < iov_end; iop++) {
		if (do_use_buf && nbytes + iop->iov_size > DMA_BUF_SIZE) {
			/* Don't do more than one DMA buffer one time. */
			if (nbytes == 0) {
				/* don't split format data */
				if (open_count[f_drive].formatting) {
					do_use_buf = FALSE;
					nbytes = iop->iov_size;
				} else
					nbytes = DMA_BUF_SIZE;
			}
			break;
		}
		nbytes += iop->iov_size;
		if ((nbytes % f->sector_size) != 0) return(EINVAL);
	}

	/* Which block on disk and how close to EOF? */
	if (! open_count[f_drive].formatting) {
		if (position >= f_dv->dv_size._[1])
			return(OK);		/* At EOF */
		if (position + nbytes > f_dv->dv_size._[1])
			nbytes = f_dv->dv_size._[1] - position;
	}
	xp->x_block = (int)((f_dv->dv_base._[1] + position)/f->sector_size);

	/* This should never happen */
	TRACE1( if (nbytes == 0) \
	printf("FLOPPY %d sec %d: funny nbytes == 0\n", f_device, xp->x_block));
	if (nbytes == 0) return(OK);

	if (do_use_buf) first_dma_phys = dmabuf;
	else first_dma_phys = user_base + iov[0].iov_addr;

	if (open_count[f_drive].formatting && is_fast_ram(first_dma_phys)) {
		printf("Formatting from Atari FAST-RAM impossible\n");
		return(EIO);
	}

	/* everything okay, prepare xfer and lock dma */
	xp->x_address = first_dma_phys;
	xp->x_count = nbytes;
	xp->x_rw = opcode;
	fl_procnr = proc_nr;
	rp = proc_addr(fl_procnr);
	rp->p_physio = 1;			/* disable (un)shadowing */
	dmagrab(FLOPPY, fdcint);

	if (do_use_buf && opcode == DEV_SCATTER) {
		/* Copy from user space to the DMA buffer. */
		count = 0;
		for (iop = iov; count < nbytes; iop++) {
			chunk = iop->iov_size;
			if (count + chunk > nbytes)
				chunk = nbytes - count;
			phys_copy(user_base + iop->iov_addr,
						first_dma_phys + count,
						(phys_bytes) chunk);
			count += chunk;
		}
	}

  TRACE(printf("f_transfer:dev=%x, rw=%d, nbytes=%d, pos=%ld, secnum=%d, proc=%d, adr=%lx\n",
  	f_device, xp->x_rw, nbytes, position, xp->x_block, fl_procnr, xp->x_address));

	xp->x_errors = 0;
	if (do_xfer()) {
		receive(HARDWARE, &mess);
		fd_deselect();
	}

	if (xp->x_errors >= MAX_ERRORS || xp->x_count == nbytes) {
		dmafree(FLOPPY);
		rp->p_physio = 0;		/* enable (un)shadowing */
		return(EIO);	/* too many errors / nothing transferred */
	}

	if (do_use_buf && opcode == DEV_GATHER) {
		/* Copy from the DMA buffer to user space. */
		count = 0;
		for (iop = iov; count < nbytes; iop++) {
			chunk = iop->iov_size;
			if (count + chunk > nbytes)
				chunk = nbytes - count;
			phys_copy(first_dma_phys + count,
						user_base + iop->iov_addr,
						(phys_bytes) chunk);
			count += chunk;
		}
	}
	dmafree(FLOPPY);
	rp->p_physio = 0;			/* enable (un)shadowing */

	position += nbytes;
	for (;;) {
		if (nbytes < iov->iov_size) {
			/* Not done with this one yet. */
			iov->iov_addr += nbytes;
			iov->iov_size -= nbytes;
			break;
		}
		nbytes -= iov->iov_size;
		iov->iov_addr += iov->iov_size;
		iov->iov_size = 0;
		if (nbytes == 0) {
			/* The rest is optional, so we return to give FS a
			 * chance to think it over. */
			return(OK);
		}
		iov++;
		nr_req--;
	}
  }
  return(OK);
}
  

/*===========================================================================*
 *				f_do_open				     *
 *===========================================================================*/
#define reset_xfer(xp, start) \
	xp->x_block = start;\
	xp->x_address = kaddress;\
	xp->x_count   = 3 * sizeof(struct idmark);\
	xp->x_errors  = 0;

PRIVATE int f_do_open(dp, mp)
struct driver *dp;
message *mp;
{
  register struct fparam *f;
  register struct hparam *h;
  register struct xfer *xp;
  register int r = OK, sec0, sec1;
  phys_bytes kaddress;
  struct idmark ids[3];
  int dtype;
  int secmin, secmax, unchanged;

  if (f_prepare(mp->DEVICE) == NIL_DEV) return (ENXIO);

  dtype = DTYPE(f_device);
  if (f_device >= MINOR_fd0a) dtype = 0;
  if (dtype > NR_TYPES) return(ENXIO);
  if (open_count[f_drive].formatting)	return(EBUSY);	/* XXX */
  if (!(f = gparam(f_device))) return(ENXIO);	/* XXX */
  f_fp->fl_fparam = f;			/* must be set for do_xfer() */
  h = &hparam[f_drive];

  dmagrab(FLOPPY, fdcint);
  fd_select(f_drive, 0, DD);

  /* This updates the WRI_PRO bit */
  dmawdat(FDC_CS, IRUPT, FDC_DELAY);
  iruptdelay();
  if ((dmardat(FDC_CS, FDC_DELAY) & WRI_PRO) &&
      ((mp->TTY_FLAGS & 3) != O_RDONLY))
	r = EACCES;
  else
	r = OK;

  /* IRUPT cleared track reg of fdc */
  f_fp->fl_curcyl = NO_CYL;

  if (r == OK && f->autocf == AUTO) {
	kaddress = umap(proc_ptr, S, (vir_bytes) ids, (vir_bytes) sizeof(ids));
	f->nr_sides = h->sides;

	sec0 = f->nr_sectors * 2 * (f->nr_sides?2:1);
	xp            = &xfer;
	xp->x_rw      = mp->m_type;

	/* Probe density */
	for (r = EIO, f->density = DD; f->density <= DD5; f->density++) {
		if (!(h->dense & (1<<f->density)))
			continue;
		reset_xfer(xp, sec0);
		if (do_xfer())
			receive(HARDWARE, &mess);
		else
			xp->x_errors = MAX_ERRORS;
		if (xp->x_errors < MAX_ERRORS) {
			r = OK;
			break;
		}
	}
	if (r != OK) {
		fd_deselect();
		dmafree(FLOPPY);
		return(r);
	}

	/* Probe number of sectors/track */
	secmin = secmax = sec1 = ids[0].secnum;
	if (ids[1].secnum > sec1)
		secmax = ids[1].secnum;
	else
		secmin = ids[1].secnum;
	if (ids[2].secnum > secmax) secmax = ids[2].secnum; else
	if (ids[2].secnum < secmin) secmin = ids[2].secnum;
#if 1
	/* Die folgende Schleife musste ich (VS 2002/04/04) aendern,
	 * da sie mit alten Laufwerken nicht funktionierte.
	 * Wie sieht eine korrekte Abschlussbedingung aus? */
	unchanged = 0;
	while (unchanged < 20) {
		reset_xfer(xp, sec0);
		if (do_xfer())
			receive(HARDWARE, &mess);
		else
			xp->x_errors = MAX_ERRORS;
		if (xp->x_errors >= MAX_ERRORS) {
			fd_deselect();
			dmafree(FLOPPY);
			return(EIO);
		}

		unchanged += chk_id_marks(ids[0].secnum, &secmin, &secmax);
		unchanged += chk_id_marks(ids[1].secnum, &secmin, &secmax);
		unchanged += chk_id_marks(ids[2].secnum, &secmin, &secmax);
	}
#else
	do {
		reset_xfer(xp, sec0);
		if (do_xfer())
			receive(HARDWARE, &mess);
		else
			xp->x_errors = MAX_ERRORS;
		if (xp->x_errors >= MAX_ERRORS) {
			fd_deselect();
			dmafree(FLOPPY);
			return(EIO);
		}

		if (ids[0].secnum == sec1) break;
		if (ids[0].secnum > secmax) secmax = ids[0].secnum; else
		if (ids[0].secnum < secmin) secmin = ids[0].secnum;

		if (ids[1].secnum == sec1) break;
		if (ids[1].secnum > secmax) secmax = ids[1].secnum; else
		if (ids[1].secnum < secmin) secmin = ids[1].secnum;

		if (ids[2].secnum == sec1) break;
		if (ids[2].secnum > secmax) secmax = ids[2].secnum; else
		if (ids[2].secnum < secmin) secmin = ids[2].secnum;
	} while (1);
#endif

	f->sector_0   = secmin;
	f->nr_sectors = secmax - secmin + 1;

	/* set sector size */
	f->sector_size = 128 << ids[0].seclen;

	/* Test for double stepping */
	if (ids[0].trknum == 1) {
		f->stepping = DSTP;
		f->nr_cylinders = h->max_cyl / 2;
	} else {
		f->stepping = NSTP;
		f->nr_cylinders = h->max_cyl;
	}		
	f->cylinder_0 = 0;

	if (f->nr_sides == SIDES2) {
		reset_xfer(xp, sec0 + f->nr_sectors);
		if (do_xfer())
			receive(HARDWARE, &mess);
		else
			r = EIO;
		if (xp->x_errors >= MAX_ERRORS)
			f->nr_sides = SIDES1;
		else
			f->nr_sides = SIDES2;
	}
  }
  fd_deselect();
  dmafree(FLOPPY);
  if (r == OK) {
	f_fp->fl_geom.dv_base._[0] = 0;
	f_fp->fl_geom.dv_base._[1] = 0;
	f_fp->fl_geom.dv_size._[0] = 0;
  	f_fp->fl_geom.dv_size._[1] =
  		(long) f->nr_cylinders * f->sector_size * f->nr_sectors;
  	if (f->nr_sides == SIDES2) f_fp->fl_geom.dv_size._[1] *= 2;
	if (dtype == 0) partition(&f_dtab, f_drive, P_FLOPPY);
	open_count[f_drive].o_cnt++;
#if 0
	printf("open succeeded:\n");
	printf("  sector_size =%d\n", f->sector_size);
	printf("  nr_sides    =%d\n", f->nr_sides == SIDES2 ? 2 : 1);
	printf("  sector_0    =%d\n", f->sector_0);
	printf("  nr_sectors  =%d\n", f->nr_sectors);
	printf("  cylinder_0  =%d\n", f->cylinder_0);
	printf("  nr_cylinders=%d\n", f->nr_cylinders);
	printf("fl_geom=%lu/%lu\n",
			f_fp->fl_geom.dv_base,_[1], f_fp->fl_geom.dv_size._[1]);
	printf("fl_geom=%lx/%lx\n",
			f_fp->fl_geom.dv_base._[1], f_fp->fl_geom.dv_size._[1]);
#endif
  }
  return(r);
}


/*===========================================================================*
 *				f_do_close				     *
 *===========================================================================*/
PRIVATE int f_do_close(dp, mp)
struct driver *dp;
message *mp;
{
/*  if (mp->COUNT != 0)
	return(OK);		XXX */

  DEBUG(if (open_count[DRIVE(mp->DEVICE)].o_cnt < 0) {
  	printf("FD: MINOR 0x%x: open_count = %d!\n", mp->DEVICE, open_count[DRIVE(mp->DEVICE)].o_cnt);
  	open_count[DRIVE(mp->DEVICE)].o_cnt = 1;
  });
  if (open_count[DRIVE(mp->DEVICE)].o_cnt == 0) {
	printf("FD: MINOR %d: Closing non open device\n", mp->DEVICE);
	return(OK);
  }
  if (!--open_count[DRIVE(mp->DEVICE)].o_cnt)
	open_count[DRIVE(mp->DEVICE)].formatting = 0;

  return(OK);
}

/*===========================================================================*
 *				f_cleanup				     *
 *===========================================================================*/
PRIVATE void f_cleanup()
{
  /* nothing by now ... */
}

/*===========================================================================*
 *				floppy_stop				     *
 *===========================================================================*/
PUBLIC void floppy_stop()
{
  /* nothing by now ... */
}

/*===========================================================================*
 *				do_xfer					     *
 *===========================================================================*/
PRIVATE int do_xfer()
{
  register struct xfer *xp;
  register struct fparam *f;
  register struct hparam *h;
  register int head, cylinder, sector, hbit, dense, seekrate;
  static int ebit = 0;

  xp = &xfer;

  f = f_fp->fl_fparam;
  cylinder = xp->x_block / f->nr_sectors;
  if (f->nr_sides == SIDES2) {
	head = cylinder & 1;
	cylinder >>= 1;
  } else
	head = 0;

  if (f->stepping == DSTP)
	cylinder <<= 1;
  cylinder += f->cylinder_0;
  if (cylinder >= (f->cylinder_0 + f->nr_cylinders))
	return(0);

  dense = f->density;
  h = &hparam[f_drive];
  hbit = 0;
  if (fd_select(f_drive, head, dense) != 0)
	hbit = HBIT;	/* motor on, suppress spin up sequence */
  if (dense != DD)
	seekrate = (h->slow == SLOW)?RATE12:RATE6;
  else
	seekrate = (h->slow == SLOW)?RATE6:RATE3;

  switch (xp->x_rw) {
	case DEV_GATHER:
		xp->x_cmd = F_READ;
		break;
	case DEV_SCATTER:
		xp->x_cmd = open_count[f_drive].formatting ? WRITETR:F_WRITE;
		break;
	case DEV_OPEN:
		xp->x_cmd = READID;
		break;
	default:
		printf("\nKernel panic: FD: MINOR %d: bad xp->x_rw(%d)\n", f_device, xp->x_rw);
		panic(NULL, NO_NUM);
		return(0);
  }
  
  if (f_fp->fl_curcyl == NO_CYL) {
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
	TRACE(printf("fd%d: recalibrate\n", f_drive));
	xp->x_cmd = RESTORE;
	dmawdat(FDC_CS, RESTORE|hbit|seekrate, FDC_DELAY);
	ebit = EBIT;
	return(1);
  }

  dmawdat(FDC_TR, f_fp->fl_curcyl, FDC_DELAY);

  /*
   * Issue a SEEK command on the indicated drive unless the arm is
   * already positioned on the correct cylinder.
   */
  if (cylinder != f_fp->fl_curcyl) {
	f_fp->fl_curcyl = cylinder;	/* be optimistic */
	xp->x_cmd = SEEK;
	dmawdat(FDC_DR, cylinder, FDC_DELAY);
	dmawdat(FDC_CS, SEEK|hbit|seekrate, FDC_DELAY);
	ebit = EBIT;
	return(1);
  }

  /* The drive is now on the proper cylinder.  Read or write 1 block. */
  sector = (xp->x_block % f->nr_sectors) + f->sector_0;

  TRACE(printf("fd%d: %s: secnum=%d,cylinder=%d,sector=%d,head=%d,cmd=%x\n",
	f_drive, xp->x_rw == DEV_GATHER ? "read" : "write",
	xp->x_block, cylinder, sector, head, xp->x_cmd));

  dmawdat(FDC_SR, sector, FDC_DELAY);
  dmaaddr(xp->x_address);	/* DMA address setup */

  if (xp->x_rw == DEV_GATHER || xp->x_rw == DEV_OPEN) {
	/* Issue the command */
	dmacomm(FDC_CS | SCREG, (f->sector_size + 511) / 512, FDC_DELAY);
	dmawdat(FDC_CS, xp->x_cmd|hbit|ebit, FDC_DELAY);
  } else {
	/* Issue the command */
	dmacomm(WRBIT | FDC_CS | SCREG, (f->sector_size + 511) / 512, FDC_DELAY);
	dmawdat(WRBIT | FDC_CS, xp->x_cmd|hbit|ebit, FDC_DELAY);
  }
  ebit = 0;
  return(1);
}

/*===========================================================================*
 *			fd_select, fd_deselect, fd_timer		     *
 *===========================================================================*/

PRIVATE int selected;		/* drive/head currently selected */
PRIVATE int selectic = 30;	/* # of fd_timer calls to deselect */
PRIVATE int motoron;		/* for how long will motor run? */

PRIVATE int fd_select(drive, head, dense)
int drive;
int head;
int dense;
{
  register int	i, s, spinning;

  TRACE(printf("fd: select (drive %d, head %d)\n", drive, head));
  spinning = motoron;
  motoron = 5;		/* will run for more than 500 msec */
  selectic = -30;	/* error if not ready within 3 sec */
  i = (drive == 1 ? PA_FLOP1 : PA_FLOP0);
  i |= head;
  switch(dense)
  {
#if ((ATARI_TYPE == TT) || (ATARI_TYPE == MSTE))
	case HD:
		DMA->fdc_mode = FD_HD;
		break;
	case DD5:
		/* No DD5 - would a panic be better? */
	case QD:
		/* No QD  - would a panic be better? */
	case DD:
		DMA->fdc_mode = FD_DD;
		break;
#else
#if (VS_FLOPPY == 1)
	case HD:
#if (ATARI_TYPE == DETECT_TYPE)
		if (atari_type == MSTE)
			DMA->fdc_mode = FD_HD;
		else
#endif /* ATARI_TYPE == DETECT_TYPE */
		i |= PA_USER;
		break;
	case DD5:
	case QD:
#if (ATARI_TYPE == DETECT_TYPE)
		if (atari_type == MSTE)
			DMA->fdc_mode = FD_DD;
		else
#endif /* ATARI_TYPE == DETECT_TYPE */
		i |= PA_USER;
		break;
#else
	case HD:
#if (ATARI_TYPE == DETECT_TYPE)
		if (atari_type == MSTE)
			DMA->fdc_mode = FD_HD;
		else
#endif /* ATARI_TYPE == DETECT_TYPE */
		i |= PA_FDDENS;
		break;
	case DD5:
#if (ATARI_TYPE == DETECT_TYPE)
		if (atari_type == MSTE)
			DMA->fdc_mode = FD_DD;
		else
#endif /* ATARI_TYPE == DETECT_TYPE */
		i |= PA_FDDENS | PA_USER;
		break;
	case QD:
#if (ATARI_TYPE == DETECT_TYPE)
		if (atari_type == MSTE)
			DMA->fdc_mode = FD_DD;
		else
#endif /* ATARI_TYPE == DETECT_TYPE */
		i |= PA_USER;
		break;
#endif /* VS_FLOPPY */
	case DD:
#if (ATARI_TYPE == DETECT_TYPE)
		if (atari_type == MSTE)
			DMA->fdc_mode = FD_DD;
#endif /* ATARI_TYPE == DETECT_TYPE */
		break;
#endif /* ATARI_TYPE == TT || ATARI_TYPE == MSTE */

	default:
		printf("\nKernel panic: FD: MINOR %d: illegal density code %d\n", f_device, dense);
		panic(NULL, NO_NUM);
		break;
  }

  if (i != selected) {
	selected = i;
	s = lock();
	SOUND->sd_selr = YM_IOA;
#if (SPEEDUP16 == 1)
	/* PA_FDDENS steuert Prozessortakt, beibehalten */
	SOUND->sd_wdat = (SOUND->sd_rdat & 0xF8) | (i ^ 0x07);
#else
	SOUND->sd_wdat = (SOUND->sd_rdat & 0x78) | (i ^ 0x07);
#endif /* SPEEDUP16 */
	restore(s);
  }
  return(spinning);
}

PRIVATE void fd_deselect()
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
  register int	pl;

  if (selectic == 0)
	return;
  if (motoron)
	--motoron;
  if (selectic < 0) {
	if (++selectic == 0) {
		pl = lock();
		xfer.x_cmd = IRUPT;
		/*
		 * IRUPT|IFORCE should be used. This does not
		 * work as expected for unknown reasons.
		 * RESTORE should never fail and will force
		 * an interrupt too.
		 */
		dmawdat(FDC_CS, IRUPT, FDC_DELAY);
		iruptdelay();
		dmardat(FDC_CS, FDC_DELAY);
		dmawdat(FDC_CS, RESTORE, FDC_DELAY);
		restore(pl);
	}
	return;
  }
  if (--selectic != 0)
	return;
  selected = 0;
  pl = lock();
  SOUND->sd_selr = YM_IOA;
  /* It is better to switch back to 8 Mhz
   * when the FDC is not in use. This will
   * reduce heating.
   */
#if ((ATARI_TYPE == TT) || (ATARI_TYPE == MSTE))
  SOUND->sd_wdat = (SOUND->sd_rdat | 0x07);
  DMA->fdc_mode = FD_DD;
#else
#if (ATARI_TYPE == DETECT_TYPE)
  if (atari_type == MSTE) {
	SOUND->sd_wdat = (SOUND->sd_rdat | 0x07);
	DMA->fdc_mode = FD_DD;
  } else
#endif /* ATARI_TYPE == DETECT_TYPE */
#if (SPEEDUP16 == 1)
  /* PA_FDDENS steuert Prozessortakt, beibehalten */
  SOUND->sd_wdat = (SOUND->sd_rdat | 0x87) & ~PA_USER;
#else
  SOUND->sd_wdat = (SOUND->sd_rdat | 0x07) & ~(PA_FDDENS|PA_USER);
#endif /* SPEEDUP16 */
#endif /* ATARI_TYPE == TT || ATARI_TYPE == MSTE */
  restore(pl);
}

/*===========================================================================*
 *				fdcint					     *
 *===========================================================================*/
PRIVATE void fdcint()
{
  ASSERT(xfer.x_count);
  if (xfer_done() == 0) {
	return;
  }
  interrupt(FLOPPY);
}

/*===========================================================================*
 *				xfer_done				     *
 *===========================================================================*/
PRIVATE int xfer_done()
{
  register struct xfer *xp;
  register struct fparam *f;

  xp = &xfer;
  f = f_fp->fl_fparam;
  switch (xfer_ok()) {
  case X_FAIL:
	return(1);
  case X_ERROR:
	xp->x_errors++;
	if (xp->x_errors >= MAX_ERRORS)
		return(1);
	break;
  case X_AGAIN:
	break;
  case X_OK:
	xp->x_errors = 0;
	xp->x_block++;
	if (xp->x_cmd == READID) {
		xp->x_address += sizeof(struct idmark);
		xp->x_count   -= sizeof(struct idmark);
		if (xp->x_count <= 0)
			return(1);
		dmawdat(FDC_CS, xp->x_cmd, FDC_DELAY);
		return(0);
	} else {
		xp->x_address += f->sector_size;
		xp->x_count   -= f->sector_size;
		if (xp->x_count <= 0)
			return(1);
	}
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
  register int	status;

  xp = &xfer;
  switch (xp->x_cmd) {
  case IRUPT:
	status = dmardat(FDC_CS, FDC_DELAY);
	if (xp->x_rw == DEV_OPEN) {
		xp->x_errors = MAX_ERRORS - 1;
	}
	printf("FD: MINOR %d: timeout\n", f_device);
	f_fp->fl_curcyl = NO_CYL;
	return(X_ERROR);
  case F_READ:
  case READID:
	/* Test for DMA error */
	status = dmastat(FDC_CS | SCREG, 0);
	if ((status & DMAOK) == 0) {
		printf("FD: MINOR %d: READ: dma status = 0x%x\n",
			f_device, DMA->dma_stat & BYTE);
		return(X_ERROR);
	}
	/* Get controller status and check for errors. */
	status = dmardat(FDC_CS, FDC_DELAY);
	if (status & (RNF | CRCERR | LD_T00)) {
		if (xp->x_cmd == READID) {
			xp->x_errors = MAX_ERRORS - 1;
		} else {
			printf("FD: MINOR %d: READ: sector=%d fdc status=0x%x\n",
				f_device, xp->x_block, status & 0xFF);
			if (xp->x_errors > 2)
				f_fp->fl_curcyl = NO_CYL;
		}
		return(X_ERROR);
	}
	break;
  case F_WRITE:
  case WRITETR:
	/* Test for DMA error */
	status = dmastat(FDC_CS | SCREG, 0);
	if ((status & DMAOK) == 0) {
		printf("FD: MINOR %d: WRITE: dma status = 0x%x\n",
			f_device, DMA->dma_stat & BYTE);
		return(X_ERROR);
	}
	/* Get controller status and check for errors. */
	status = dmardat(WRBIT | FDC_CS, FDC_DELAY);
	if (status & WRI_PRO) {
		printf("FD: MINOR %d: write protected\n", f_device);
		return(X_FAIL);
	}
	if (status & (RNF | CRCERR | LD_T00)) {
		printf("FD: MINOR %d: WRITE: sector=%d fdc status=0x%x\n",
			f_device, xp->x_block, status&0xFF);
		/* we retry two times in without recalibrate
		   to get softerrors without seeking */
		if (xp->x_errors > 2)
			f_fp->fl_curcyl = NO_CYL;
		return(X_ERROR);
	}
	break;
  case SEEK:
	status = dmardat(FDC_CS, FDC_DELAY);
	if (status & (RNF | CRCERR)) {
		f_fp->fl_curcyl = NO_CYL;
		return(X_ERROR);
	}
	return(X_AGAIN);
  case RESTORE:
	/* Determine if the recalibration succeeded. */
	status = dmardat(FDC_CS, FDC_DELAY);
	if (status & RNF) {
		printf("FD: MINOR %d: recalibrate failed fdc status=0x%x\n",
				f_device, status&0xFF);
		dmawdat(FDC_CS, IRUPT, FDC_DELAY);	/* reset controller */
		iruptdelay();
		f_fp->fl_curcyl = NO_CYL;
		return(X_ERROR);
	}
	f_fp->fl_curcyl = 0;
	return(X_AGAIN);
  default:
	ASSERT(0);
  }
  return(X_OK);
}

/*===========================================================================*
 *				gparam					     *
 *===========================================================================*/
PRIVATE struct fparam *gparam(drive)
int drive;
{
	if ((drive & DEV_TYPE_BITS) >= MINOR_fd0a) drive &= ~DEV_TYPE_BITS;
	if (open_count[DRIVE(drive)].formatting) {
		sparam(drive, fparam[DTYPE(drive)][DRIVE(drive)]);
		return(&format);
	}
	return(fparam[DTYPE(drive)][DRIVE(drive)]);
}

/*===========================================================================*
 *				sparam					     *
 *===========================================================================*/
PRIVATE void sparam(drive, f)
int drive; struct fparam *f;
{
	register struct hparam *h;

	h = &hparam[DRIVE(drive)];
	switch (f->density) {
		case DD:
		case DD5:
			format.sector_size = trklen[0];
			break;

		case QD:
			format.sector_size = trklen[1];
			break;

		case HD:
			format.sector_size =
			       trklen[h->size == I5 ?
					2
				:
					3];
			break;
	}
	format.sector_0     = 1;
	format.nr_sectors   = 1;
	format.cylinder_0   = f->cylinder_0;
	format.nr_cylinders = f->nr_cylinders;
	format.nr_sides     = f->nr_sides;
	format.density      = f->density;
	format.stepping     = f->stepping;
}

/*============================================================================*
 *				f_do_diocntl				      *
 *============================================================================*/
PRIVATE int f_do_diocntl(dp, m_ptr)
struct driver *dp;
message *m_ptr;			/* pointer to ioctl request */
{
/* Carry out a partition setting/getting request. */
  struct device *dv;
  phys_bytes user_phys, entry_phys;
  struct partition entry;

  /* Decode the message parameters. */
  if ((dv = f_prepare(m_ptr->DEVICE)) == NIL_DEV) return(ENXIO);

  if (m_ptr->REQUEST != DIOCSETP && m_ptr->REQUEST != DIOCGETP)
  	return(do_ioctl(m_ptr));

  user_phys = numap(m_ptr->PROC_NR, (vir_bytes) m_ptr->ADDRESS,
				    (vir_bytes) sizeof(entry));
  if (user_phys == 0) return(EFAULT);

  entry_phys = vir2phys(&entry);

  if (m_ptr->REQUEST == DIOCSETP) {
	/* Copy just this one partition table entry. */
	phys_copy(user_phys, entry_phys, (phys_bytes) sizeof(entry));
	dv->dv_base._[0] = entry.base._[0];
	dv->dv_base._[1] = entry.base._[1];
	dv->dv_size._[0] = entry.size._[0];
	dv->dv_size._[1] = entry.size._[1];
  } else {
	/* Return a partition table entry and the geometry of the drive. */
	entry.base._[0] = dv->dv_base._[0];
	entry.base._[1] = dv->dv_base._[1];
	entry.size._[0] = dv->dv_size._[0];
	entry.size._[1] = dv->dv_size._[1];
	f_geometry(&entry);
	phys_copy(entry_phys, user_phys, (phys_bytes) sizeof(entry));
  }
  return(OK);
}

/*===========================================================================*
 *				do_ioctl				     *
 *===========================================================================*/
PRIVATE int do_ioctl(mp)
register message *mp;		/* pointer to read or write message */
{
  struct fparam ufparam;
  struct hparam uhparam;
  register struct fparam *f;
  register struct hparam *h;
  register int sector_size;
  register phys_bytes uaddress, kaddress;

  /* parms already checked by f_prepare */
  f = gparam(f_device);
  h = &hparam[f_drive];

  switch (mp->REQUEST) {
	case DIOFMTLOCK:
	case DIOFMTFREE:
		break;

	case DIOGETP:
	case DIOSETP:
		if (!(uaddress = numap(mp->PROC_NR, (vir_bytes) mp->ADDRESS,
		      (vir_bytes) sizeof(ufparam))))
			return(EINVAL);
		kaddress = umap(proc_ptr, S, (vir_bytes) &ufparam,
					     (vir_bytes) sizeof(ufparam));
		break;

	case DIOGETHP:
	case DIOSETHP:
		if (!(uaddress = numap(mp->PROC_NR, (vir_bytes) mp->ADDRESS,
		      (vir_bytes) sizeof(uhparam))))
			return(EINVAL);
		kaddress = umap(proc_ptr, S, (vir_bytes) &uhparam,
					     (vir_bytes) sizeof(uhparam));
		break;

	default:
		return(EINVAL);
  }

  switch (mp->REQUEST) {
	case DIOFMTLOCK:
		if (open_count[f_drive].o_cnt > 1)
#if 0
			return(EBUSY);				/* XXX */
#else
			printf("Kernelwarnung: DIOFMTLOCK(%d): o_cnt=%d\n",
				f_drive, open_count[f_drive].o_cnt);
#endif
		open_count[f_drive].formatting = 1;
		break;

	case DIOFMTFREE:
		open_count[f_drive].formatting = 0;
		break;

	case DIOGETP:
		ufparam = *f;
		phys_copy(kaddress, uaddress, (phys_bytes) sizeof(ufparam));
		break;

	case DIOSETP:
		phys_copy(uaddress, kaddress, (phys_bytes) sizeof(ufparam));
		if (DTYPE(mp->DEVICE) & 0x0f)	/* only allowed for type 0 */
			return(EINVAL);		/* and type 16             */

		if (open_count[DRIVE(mp->DEVICE)].formatting)
			return(EBUSY);

		if (ufparam.sector_size !=  128 &&
		    ufparam.sector_size !=  256 &&
		    ufparam.sector_size !=  512 &&
		    ufparam.sector_size != 1024 &&
		    ufparam.sector_size != 2048 &&
		    ufparam.sector_size != 4096)
			return(EINVAL);

		if (ufparam.cylinder_0 >= h->max_cyl)
			return(EINVAL);
		if ((ufparam.nr_cylinders + ufparam.cylinder_0) > h->max_cyl ||
		    (ufparam.stepping == DSTP &&
		     (ufparam.nr_cylinders + ufparam.cylinder_0) > h->max_cyl/2))
			return(EINVAL);

		if (ufparam.nr_sides > h->sides)
			return(EINVAL);

		if (!(h->dense & (1<<ufparam.density)))
			return(EINVAL);

		*f = ufparam;
		break;

	case DIOGETHP:
		uhparam = *h;
		phys_copy(kaddress, uaddress, (phys_bytes) sizeof(uhparam));
		break;

	case DIOSETHP:
		phys_copy(uaddress, kaddress, (phys_bytes) sizeof(uhparam));
		if (uhparam.max_cyl <= 0)
			return(EINVAL);
		if (uhparam.dense == 0)
			return(EINVAL);
		*h = uhparam;
		break;
  }
  return(OK);
}

/*============================================================================*
 *				f_geometry				      *
 *============================================================================*/
PRIVATE void f_geometry(entry)
struct partition *entry;
{
  struct fparam *fp = f_fp->fl_fparam;
  
  entry->cylinders = fp->nr_cylinders;
  entry->heads = fp->nr_sides == SIDES2 ? 2 : 1;
  entry->sectors = fp->nr_sectors;
}

/*===========================================================================*
 *				chk_id_marks				     *
 *===========================================================================*/
PRIVATE int chk_id_marks(idsec,secmin,secmax)
int idsec;	/* Aus ID-Mark gelesene Sektornummer */
int *secmin;	/* bislang kleinste Sektornummer */
int *secmax;	/* bislang groesste Sektornummer */
{
  int unchanged = 1;
  
  if (idsec > *secmax) {
  	unchanged = 0;
  	*secmax = idsec;
  } else if (idsec < *secmin) {
  	unchanged = 0;
  	*secmin = idsec;
  }
  return (unchanged);
}

/*===========================================================================*
 *				iruptdelay				     *
 *===========================================================================*/
PRIVATE void iruptdelay()
{
  static int _delay;
  _delay = IRUPT_DELAY;
  while (--_delay)
    ;
}
 
#endif /* NR_FD_DRIVES > 0 */
#endif /* MACHINE == ATARI */
