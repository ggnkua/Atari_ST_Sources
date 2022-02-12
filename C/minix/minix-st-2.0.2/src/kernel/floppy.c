/* This file contains the device dependent part of the driver for the Floppy
 * Disk Controller (FDC) using the NEC PD765 chip.
 *
 * The file contains one entry point:
 *
 *   floppy_task:	main entry when system is brought up
 *   floppy_stop:	stop all activity
 *
 *  Changes:
 *	27 Oct. 1986 by Jakob Schripsema: fdc_results fixed for 8 MHz
 *	28 Nov. 1986 by Peter Kay: better resetting for 386
 *	06 Jan. 1988 by Al Crew: allow 1.44 MB diskettes
 *	        1989 by Bruce Evans: I/O vector to keep up with 1-1 interleave
 *	13 May  1991 by Don Chapman: renovated the errors loop.
 *		1991 by Bruce Evans: len[] / motors / reset / step rate / ...
 *	14 Feb  1992 by Andy Tanenbaum: check drive density on opens only
 *	27 Mar  1992 by Kees J. Bot: last details on density checking
 *	04 Apr  1992 by Kees J. Bot: device dependent/independent split
 */

#include "kernel.h"
#include "driver.h"
#include "drvlib.h"
#include <ibm/diskparm.h>

/* I/O Ports used by floppy disk task. */
#define DOR            0x3F2	/* motor drive control bits */
#define FDC_STATUS     0x3F4	/* floppy disk controller status register */
#define FDC_DATA       0x3F5	/* floppy disk controller data register */
#define FDC_RATE       0x3F7	/* transfer rate register */
#define DMA_ADDR       0x004	/* port for low 16 bits of DMA address */
#define DMA_TOP        0x081	/* port for top 4 bits of 20-bit DMA addr */
#define DMA_COUNT      0x005	/* port for DMA count (count =  bytes - 1) */
#define DMA_FLIPFLOP   0x00C	/* DMA byte pointer flip-flop */
#define DMA_MODE       0x00B	/* DMA mode port */
#define DMA_INIT       0x00A	/* DMA init port */
#define DMA_RESET_VAL   0x06

/* Status registers returned as result of operation. */
#define ST0             0x00	/* status register 0 */
#define ST1             0x01	/* status register 1 */
#define ST2             0x02	/* status register 2 */
#define ST3             0x00	/* status register 3 (return by DRIVE_SENSE) */
#define ST_CYL          0x03	/* slot where controller reports cylinder */
#define ST_HEAD         0x04	/* slot where controller reports head */
#define ST_SEC          0x05	/* slot where controller reports sector */
#define ST_PCN          0x01	/* slot where controller reports present cyl */

/* Fields within the I/O ports. */
/* Main status register. */
#define CTL_BUSY        0x10	/* bit is set when read or write in progress */
#define DIRECTION       0x40	/* bit is set when reading data reg is valid */
#define MASTER          0x80	/* bit is set when data reg can be accessed */

/* Digital output port (DOR). */
#define MOTOR_SHIFT        4	/* high 4 bits control the motors in DOR */
#define ENABLE_INT      0x0C	/* used for setting DOR port */

/* ST0. */
#define ST0_BITS        0xF8	/* check top 5 bits of seek status */
#define TRANS_ST0       0x00	/* top 5 bits of ST0 for READ/WRITE */
#define SEEK_ST0        0x20	/* top 5 bits of ST0 for SEEK */

/* ST1. */
#define BAD_SECTOR      0x05	/* if these bits are set in ST1, recalibrate */
#define WRITE_PROTECT   0x02	/* bit is set if diskette is write protected */

/* ST2. */
#define BAD_CYL         0x1F	/* if any of these bits are set, recalibrate */

/* ST3 (not used). */
#define ST3_FAULT       0x80	/* if this bit is set, drive is sick */
#define ST3_WR_PROTECT  0x40	/* set when diskette is write protected */
#define ST3_READY       0x20	/* set when drive is ready */

/* Floppy disk controller command bytes. */
#define FDC_SEEK        0x0F	/* command the drive to seek */
#define FDC_READ        0xE6	/* command the drive to read */
#define FDC_WRITE       0xC5	/* command the drive to write */
#define FDC_SENSE       0x08	/* command the controller to tell its status */
#define FDC_RECALIBRATE 0x07	/* command the drive to go to cyl 0 */
#define FDC_SPECIFY     0x03	/* command the drive to accept params */
#define FDC_READ_ID     0x4A	/* command the drive to read sector identity */
#define FDC_FORMAT      0x4D	/* command the drive to format a track */

/* DMA channel commands. */
#define DMA_READ        0x46	/* DMA read opcode */
#define DMA_WRITE       0x4A	/* DMA write opcode */

/* Parameters for the disk drive. */
#define HC_SIZE         2880	/* # sectors on largest legal disk (1.44MB) */
#define NR_HEADS        0x02	/* two heads (i.e., two tracks/cylinder) */
#define MAX_SECTORS	  18	/* largest # sectors per track */
#define DTL             0xFF	/* determines data length (sector size) */
#define SPEC2           0x02	/* second parameter to SPECIFY */
#define MOTOR_OFF       3*HZ	/* how long to wait before stopping motor */
#define WAKEUP		2*HZ	/* timeout on I/O, FDC won't quit. */

/* Error codes */
#define ERR_SEEK         (-1)	/* bad seek */
#define ERR_TRANSFER     (-2)	/* bad transfer */
#define ERR_STATUS       (-3)	/* something wrong when getting status */
#define ERR_READ_ID      (-4)	/* bad read id */
#define ERR_RECALIBRATE  (-5)	/* recalibrate didn't work properly */
#define ERR_DRIVE        (-6)	/* something wrong with a drive */
#define ERR_WR_PROTECT   (-7)	/* diskette is write protected */
#define ERR_TIMEOUT      (-8)	/* interrupt timeout */

/* No retries on some errors. */
#define err_no_retry(err)	((err) <= ERR_WR_PROTECT)

/* Encoding of drive type in minor device number. */
#define DEV_TYPE_BITS   0x7C	/* drive type + 1, if nonzero */
#define DEV_TYPE_SHIFT     2	/* right shift to normalize type bits */
#define FORMAT_DEV_BIT  0x80	/* bit in minor to turn write into format */

/* Miscellaneous. */
#define MAX_ERRORS         6	/* how often to try rd/wt before quitting */
#define MAX_RESULTS        7	/* max number of bytes controller returns */
#define NR_DRIVES          2	/* maximum number of drives */
#define DIVISOR          128	/* used for sector size encoding */
#define SECTOR_SIZE_CODE   2	/* code to say "512" to the controller */
#define TIMEOUT		 500	/* milliseconds waiting for FDC */
#define NT                 7	/* number of diskette/drive combinations */
#define UNCALIBRATED       0	/* drive needs to be calibrated at next use */
#define CALIBRATED         1	/* no calibration needed */
#define BASE_SECTOR        1	/* sectors are numbered starting at 1 */
#define NO_SECTOR          0	/* current sector unknown */
#define NO_CYL		 (-1)	/* current cylinder unknown, must seek */
#define NO_DENS		 100	/* current media unknown */
#define BSY_IDLE	   0	/* busy doing nothing */
#define BSY_IO		   1	/* doing I/O */
#define BSY_WAKEN	   2	/* got a wakeup call */

/* Variables. */
PRIVATE struct floppy {		/* main drive struct, one entry per drive */
  int fl_curcyl;		/* current cylinder */
  int fl_hardcyl;		/* hardware cylinder, as opposed to: */
  int fl_cylinder;		/* cylinder number addressed */
  int fl_sector;		/* sector addressed */
  int fl_head;			/* head number addressed */
  char fl_calibration;		/* CALIBRATED or UNCALIBRATED */
  char fl_density;		/* NO_DENS = ?, 0 = 360K; 1 = 360K/1.2M; etc.*/
  char fl_class;		/* bitmap for possible densities */
  struct device fl_geom;	/* Geometry of the drive */
  struct device fl_part[NR_PARTITIONS];  /* partition's base & size */
} floppy[NR_DRIVES], *f_fp;

/* Gather transfer data for each sector. */
PRIVATE struct trans {		/* precomputed transfer params */
  unsigned tr_count;		/* byte count */
  struct iorequest_s *tr_iop;	/* belongs to this I/O request */
  phys_bytes tr_phys;		/* user physical address */
  phys_bytes tr_dma;		/* DMA physical address */
} ftrans[MAX_SECTORS];

PRIVATE unsigned f_count;	/* this many bytes to transfer */
PRIVATE unsigned f_nexttrack;	/* don't do blocks above this */
PRIVATE int motor_status;	/* bitmap of current motor status */
PRIVATE int motor_goal;		/* bitmap of desired motor status */
PRIVATE int need_reset;		/* set to 1 when controller must be reset */
PRIVATE int d;			/* diskette/drive combination */
PRIVATE int f_drive;		/* selected drive */
PRIVATE int f_device;		/* selected minor device */
PRIVATE int f_opcode;		/* DEV_READ or DEV_WRITE */
PRIVATE int f_sectors;		/* sectors per track of the floppy */
PRIVATE int f_must;		/* must do part of the next track? */
PRIVATE int f_busy;		/* BSY_IDLE, BSY_IO, BSY_WAKEN */
PRIVATE int current_spec1;	/* latest spec1 sent to the controller */
PRIVATE struct device *f_dv;	/* device's base and size */
PRIVATE struct disk_parameter_s fmt_param; /* parameters for format */
PRIVATE char f_results[MAX_RESULTS];/* the controller can give lots of output */


/* Seven combinations of diskette/drive are supported.
 *
 * # Drive  diskette  Sectors  Tracks  Rotation Data-rate  Comment
 * 0  360K    360K      9       40     300 RPM  250 kbps   Standard PC DSDD
 * 1  1.2M    1.2M     15       80     360 RPM  500 kbps   AT disk in AT drive
 * 2  720K    360K      9       40     300 RPM  250 kbps   Quad density PC
 * 3  720K    720K      9       80     300 RPM  250 kbps   Toshiba, et al.
 * 4  1.2M    360K      9       40     360 RPM  300 kbps   PC disk in AT drive
 * 5  1.2M    720K      9       80     360 RPM  300 kbps   Toshiba in AT drive
 * 6  1.44M   1.44M    18	80     300 RPM  500 kbps   PS/2, et al.
 *
 * In addition, 720K diskettes can be read in 1.44MB drives, but that does
 * not need a different set of parameters.  This combination uses
 *
 * X  1.44M   720K	9	80     300 RPM  250 kbps   PS/2, et al.
 */
PRIVATE char gap[NT] =
	{0x2A, 0x1B, 0x2A, 0x2A, 0x23, 0x23, 0x1B}; /* gap size */
PRIVATE char rate[NT] =
	{0x02, 0x00, 0x02, 0x02, 0x01, 0x01, 0x00}; /* 2=250,1=300,0=500 kbps*/
PRIVATE char nr_sectors[NT] =
	{9,    15,   9,    9,    9,    9,    18};   /* sectors/track */
PRIVATE int nr_blocks[NT] =
	{720,  2400, 720,  1440, 720,  1440, 2880}; /* sectors/diskette*/
PRIVATE char steps_per_cyl[NT] =
	{1,    1,    2,    1,    2,    1,     1};   /* 2 = dbl step */
PRIVATE char mtr_setup[NT] =
	{1*HZ/4,3*HZ/4,1*HZ/4,4*HZ/4,3*HZ/4,3*HZ/4,4*HZ/4}; /* in ticks */
PRIVATE char spec1[NT] =
	{0xDF, 0xDF, 0xDF, 0xDF, 0xDF, 0xDF, 0xDF}; /* step rate, etc. */
PRIVATE char test_sector[NT] =
	{4*9,  14,   2*9,  4*9,  2*9,  4*9,  17};   /* to recognize it */

#define b(d)	(1 << (d))	/* bit for density d. */

/* The following table is used with the test_sector array to recognize a
 * drive/floppy combination.  The sector to test has been determined by
 * looking at the differences in gap size, sectors/track, and double stepping.
 * This means that types 0 and 3 can't be told apart, only the motor start
 * time differs.  If a read test succeeds then the drive is limited to the
 * set of densities it can support to avoid unnecessary tests in the future.
 */

PRIVATE struct test_order {
	char	t_density;	/* floppy/drive type */
	char	t_class;	/* limit drive to this class of densities */
} test_order[NT-1] = {
	{ 6,  b(3) | b(6) },		/* 1.44M  {720K, 1.44M} */
	{ 1,  b(1) | b(4) | b(5) },	/* 1.2M   {1.2M, 360K, 720K} */
	{ 3,  b(2) | b(3) | b(6) },	/* 720K   {360K, 720K, 1.44M} */
	{ 4,  b(1) | b(4) | b(5) },	/* 360K   {1.2M, 360K, 720K} */
	{ 5,  b(1) | b(4) | b(5) },	/* 720K   {1.2M, 360K, 720K} */
	{ 2,  b(2) | b(3) },		/* 360K   {360K, 720K} */
	/* Note that type 0 is missing, type 3 can read/write it too (alas). */
};

FORWARD _PROTOTYPE( struct device *f_prepare, (int device) );
FORWARD _PROTOTYPE( char *f_name, (void) );
FORWARD _PROTOTYPE( void f_cleanup, (void) );
FORWARD _PROTOTYPE( int f_schedule, (int proc_nr, struct iorequest_s *iop) );
FORWARD _PROTOTYPE( int f_finish, (void) );
FORWARD _PROTOTYPE( void defuse, (void) );
FORWARD _PROTOTYPE( void dma_setup, (struct trans *tp) );
FORWARD _PROTOTYPE( void start_motor, (void) );
FORWARD _PROTOTYPE( void stop_motor, (void) );
FORWARD _PROTOTYPE( int seek, (struct floppy *fp) );
FORWARD _PROTOTYPE( int f_transfer, (struct floppy *fp, struct trans *tp) );
FORWARD _PROTOTYPE( int fdc_results, (void) );
FORWARD _PROTOTYPE( int f_handler, (int irq) );
FORWARD _PROTOTYPE( void fdc_out, (int val) );
FORWARD _PROTOTYPE( int recalibrate, (struct floppy *fp) );
FORWARD _PROTOTYPE( void f_reset, (void) );
FORWARD _PROTOTYPE( void send_mess, (void) );
FORWARD _PROTOTYPE( int f_intr_wait, (void) );
FORWARD _PROTOTYPE( void f_timeout, (void) );
FORWARD _PROTOTYPE( int read_id, (struct floppy *fp) );
FORWARD _PROTOTYPE( int f_do_open, (struct driver *dp, message *m_ptr) );
FORWARD _PROTOTYPE( int test_read, (int density) );
FORWARD _PROTOTYPE( void f_geometry, (struct partition *entry));


/* Entry points to this driver. */
PRIVATE struct driver f_dtab = {
  f_name,	/* current device's name */
  f_do_open,	/* open or mount request, sense type of diskette */
  do_nop,	/* nothing on a close */
  do_diocntl,	/* get or set a partitions geometry */
  f_prepare,	/* prepare for I/O on a given minor device */
  f_schedule,	/* precompute cylinder, head, sector, etc. */
  f_finish,	/* do the I/O */
  f_cleanup,	/* cleanup before sending reply to user process */
  f_geometry	/* tell the geometry of the diskette */
};


/*===========================================================================*
 *				floppy_task				     *
 *===========================================================================*/
PUBLIC void floppy_task()
{
/* Initialize the floppy structure. */

  struct floppy *fp;

  for (fp = &floppy[0]; fp < &floppy[NR_DRIVES]; fp++) {
	fp->fl_curcyl = NO_CYL;
	fp->fl_density = NO_DENS;
	fp->fl_class = ~0;
  }

  put_irq_handler(FLOPPY_IRQ, f_handler);
  enable_irq(FLOPPY_IRQ);		/* ready for floppy interrupts */

  driver_task(&f_dtab);
}


/*===========================================================================*
 *				f_prepare				     *
 *===========================================================================*/
PRIVATE struct device *f_prepare(device)
int device;
{
/* Prepare for I/O on a device. */

  /* Leftover jobs after an I/O error must be removed */
  if (f_count > 0) defuse();

  f_device = device;
  f_drive = device & ~(DEV_TYPE_BITS | FORMAT_DEV_BIT);
  if (f_drive < 0 || f_drive >= NR_DRIVES) return(NIL_DEV);

  f_fp = &floppy[f_drive];
  f_dv = &f_fp->fl_geom;
  d = f_fp->fl_density;
  f_sectors = nr_sectors[d];

  f_must = TRUE;	/* the first transfers must be done */

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
 *				f_cleanup				     *
 *===========================================================================*/
PRIVATE void f_cleanup()
{
  /* Start watchdog timer to turn all motors off in a few seconds.
   * There is a race here.  An old watchdog might bite before the
   * new delay is installed, and turn of the motors prematurely.
   * This cannot be solved simply by resetting motor_goal after
   * sending the message, because the new watchdog might bite
   * before motor_goal is reset.  Then the motors would stay on
   * until after the next floppy access.  This could be fixed with
   * extra code (call the clock task twice in some cases).  Or
   * stop_motor() could be replaced by send_mess(), and send a
   * STOP_MOTOR message to be accepted by the clock task.  This
   * would be slower but have the advantage that this comment could
   * be deleted!
   *
   * Since it is not likely and not serious for an old watchdog to
   * bite, accept that possibility for now.  A full solution to the
   * motor madness requires a lots of extra work anyway, such as
   * a separate timer for each motor, and smaller delays for motors
   * that have just been turned off or start faster than the spec.
   * (is there a motor-ready bit?).
   */
  motor_goal = 0;
  clock_mess(MOTOR_OFF, stop_motor);
}


/*===========================================================================*
 *				f_schedule				     *
 *===========================================================================*/
PRIVATE int f_schedule(proc_nr, iop)
int proc_nr;			/* process doing the request */
struct iorequest_s *iop;	/* pointer to read or write request */
{
  int r, opcode, spanning;
  unsigned long pos;
  unsigned block;	/* Seen any 32M floppies lately? */
  unsigned nbytes, count, dma_count;
  phys_bytes user_phys, dma_phys;
  struct trans *tp, *tp0;

  /* Ignore any alarm to turn motor off, now there is work to do. */
  motor_goal = motor_status;

  /* This many bytes to read/write */
  nbytes = iop->io_nbytes;
  if ((nbytes & SECTOR_MASK) != 0) return(iop->io_nbytes = EINVAL);

  /* From/to this position on disk */
  pos = iop->io_position;
  if ((pos & SECTOR_MASK) != 0) return(iop->io_nbytes = EINVAL);

  /* To/from this user address */
  user_phys = numap(proc_nr, (vir_bytes) iop->io_buf, nbytes);
  if (user_phys == 0) return(iop->io_nbytes = EINVAL);

  /* Read, write or format? */
  opcode = iop->io_request & ~OPTIONAL_IO;
  if (f_device & FORMAT_DEV_BIT) {
	if (opcode != DEV_WRITE) return(iop->io_nbytes = EIO);
	if (nbytes != BLOCK_SIZE) return(iop->io_nbytes = EINVAL);

	phys_copy(user_phys + SECTOR_SIZE, vir2phys(&fmt_param),
						(phys_bytes) sizeof fmt_param);

	/* Check that the number of sectors in the data is reasonable, to
	 * avoid division by 0.  Leave checking of other data to the FDC.
	 */
	if (fmt_param.sectors_per_cylinder == 0)
		return(iop->io_nbytes = EIO);

	/* Only the first sector of the parameters now needed. */
	iop->io_nbytes = nbytes = SECTOR_SIZE;
  }

  /* Which block on disk and how close to EOF? */
  if (pos >= f_dv->dv_size) return(OK);		/* At EOF */
  if (pos + nbytes > f_dv->dv_size) nbytes = f_dv->dv_size - pos;
  block = (f_dv->dv_base + pos) >> SECTOR_SHIFT;

  spanning = FALSE;	/* set if the block spans a track */

  /* While there are "unscheduled" bytes in the request: */
  do {
	count = nbytes;

	if (f_count > 0 && block >= f_nexttrack) {
		/* The new job leaves the track, finish all gathered jobs */
		if ((r = f_finish()) != OK) return(r);
		f_must = spanning;
	}

	if (f_count == 0) {
		/* This is the first job, compute cylinder and head */
		f_opcode = opcode;
		f_fp->fl_cylinder = block / (NR_HEADS * f_sectors);
		f_fp->fl_hardcyl = f_fp->fl_cylinder * steps_per_cyl[d];
		f_fp->fl_head = (block % (NR_HEADS * f_sectors)) / f_sectors;

		/* See where the next track starts, one is trouble enough */
		f_nexttrack = (f_fp->fl_cylinder * NR_HEADS
					+ f_fp->fl_head + 1) * f_sectors;
	}

	/* Don't do track spanning I/O. */
	if (block + (count >> SECTOR_SHIFT) > f_nexttrack)
		count = (f_nexttrack - block) << SECTOR_SHIFT;

	/* Memory chunk to DMA. */
	dma_phys = user_phys;
	dma_count = dma_bytes_left(dma_phys);

#if _WORD_SIZE > 2
	/* The DMA chip uses a 24 bit address, so don't DMA above 16MB. */
	if (dma_phys >= 0x1000000) dma_count = 0;
#endif
	if (dma_count < count) {
		/* Nearing a 64K boundary. */
		if (dma_count >= SECTOR_SIZE) {
			/* Can read a few sectors before hitting the
			 * boundary.
			 */
			count = dma_count & ~SECTOR_MASK;
		} else {
			/* Must use the special buffer for this. */
			count = SECTOR_SIZE;
			dma_phys = tmp_phys;
		}
	}

	/* Store the I/O parameters in the ftrans slots for the sectors to
	 * read.  The first slot specifies all sectors, the ones following
	 * it each specify one sector less.  This allows I/O to be started
	 * in the middle of a block.
	 */
	tp = tp0 = &ftrans[block % f_sectors];

	block += count >> SECTOR_SHIFT;
	nbytes -= count;
	f_count += count;
	if (!(iop->io_request & OPTIONAL_IO)) f_must = TRUE;

	do {
		tp->tr_count = count;
		tp->tr_iop = iop;
		tp->tr_phys = user_phys;
		tp->tr_dma = dma_phys;
		tp++;

		user_phys += SECTOR_SIZE;
		dma_phys += SECTOR_SIZE;
		count -= SECTOR_SIZE;
	} while (count > 0);

	spanning = TRUE;	/* the rest of the block may span a track */
  } while (nbytes > 0);

  return(OK);
}


/*===========================================================================*
 *				f_finish				     *
 *===========================================================================*/
PRIVATE int f_finish()
{
/* Carry out the I/O requests gathered in ftrans[].  */

  struct floppy *fp = f_fp;
  struct trans *tp;
  int r, errors;

  if (f_count == 0) return(OK);	/* Spurious finish. */

  /* If all the requests are optional then don't read from the next track.
   * (There may be enough buffers to read the next track, but doing so is
   * unwise.  It's no good to be greedy on a slow device.)
   */
  if (!f_must) {
	defuse();
	return(EAGAIN);
  }

  /* See if motor is running; if not, turn it on and wait */
  start_motor();

  /* Let read_id find out the next sector to read/write if it pays to do so.
   * Note that no read_id is done while formatting if there is one format
   * request per track as there should be.
   */
  fp->fl_sector = f_count >= (6 * SECTOR_SIZE) ? 0 : BASE_SECTOR;

  do {
	/* This loop allows a failed operation to be repeated. */
	errors = 0;
	for (;;) {
		/* First check to see if a reset is needed. */
		if (need_reset) f_reset();

		/* Set the stepping rate */
		if (current_spec1 != spec1[d]) {
			fdc_out(FDC_SPECIFY);
			current_spec1 = spec1[d];
			fdc_out(current_spec1);
			fdc_out(SPEC2);
		}

		/* Set the data rate */
		if (pc_at) out_byte(FDC_RATE, rate[d]);

		/* If we are going to a new cylinder, perform a seek. */
		r = seek(fp);

		if (fp->fl_sector == NO_SECTOR) {
			/* Don't retry read_id too often, we need tp soon */
			if (errors > 0) fp->fl_sector = BASE_SECTOR;

			/* Find out what the current sector is */
			if (r == OK) r = read_id(fp);
		}

		/* Look for the next job in ftrans[] */
		if (fp->fl_sector != NO_SECTOR) {
			for (;;) {
				if (fp->fl_sector >= BASE_SECTOR + f_sectors)
					fp->fl_sector = BASE_SECTOR;

				tp = &ftrans[fp->fl_sector - BASE_SECTOR];
				if (tp->tr_count > 0) break;
				fp->fl_sector++;
			}
			/* Do not transfer more than f_count bytes. */
			if (tp->tr_count > f_count) tp->tr_count = f_count;
		}

		if (r == OK && tp->tr_dma == tmp_phys
						&& f_opcode == DEV_WRITE) {
			/* Copy the bad user buffer to the DMA buffer. */
			phys_copy(tp->tr_phys, tp->tr_dma,
						(phys_bytes) tp->tr_count);
		}

		/* Set up the DMA chip and perform the transfer. */
		if (r == OK) {
			dma_setup(tp);
			r = f_transfer(fp, tp);
		}

		if (r == OK && tp->tr_dma == tmp_phys
						&& f_opcode == DEV_READ) {
			/* Copy the DMA buffer to the bad user buffer. */
			phys_copy(tp->tr_dma, tp->tr_phys,
						(phys_bytes) tp->tr_count);
		}

		if (r == OK) break;	/* if successful, exit loop */

		/* Don't retry if write protected or too many errors. */
		if (err_no_retry(r) || ++errors == MAX_ERRORS) {
			if (fp->fl_sector != 0) tp->tr_iop->io_nbytes = EIO;
			return(EIO);
		}

		/* Recalibrate if halfway, but bail out if optional I/O. */
		if (errors == MAX_ERRORS / 2) {
			fp->fl_calibration = UNCALIBRATED;
			if (tp->tr_iop->io_request & OPTIONAL_IO)
				return(tp->tr_iop->io_nbytes = EIO);
		}
	}
	f_count -= tp->tr_count;
	tp->tr_iop->io_nbytes -= tp->tr_count;
  } while (f_count > 0);

  /* Defuse the leftover partial jobs. */
  defuse();

  return(OK);
}


/*===========================================================================*
 *				defuse					     *
 *===========================================================================*/
PRIVATE void defuse()
{
/* Invalidate leftover requests in the transfer array. */

  struct trans *tp;

  for (tp = ftrans; tp < ftrans + MAX_SECTORS; tp++) tp->tr_count = 0;
  f_count = 0;
}


/*===========================================================================*
 *				dma_setup				     *
 *===========================================================================*/
PRIVATE void dma_setup(tp)
struct trans *tp;		/* pointer to the transfer struct */
{
/* The IBM PC can perform DMA operations by using the DMA chip.  To use it,
 * the DMA (Direct Memory Access) chip is loaded with the 20-bit memory address
 * to be read from or written to, the byte count minus 1, and a read or write
 * opcode.  This routine sets up the DMA chip.  Note that the chip is not
 * capable of doing a DMA across a 64K boundary (e.g., you can't read a
 * 512-byte block starting at physical address 65520).
 */

  /* Set up the DMA registers.  (The comment on the reset is a bit strong,
   * it probably only resets the floppy channel.)
   */
  out_byte(DMA_INIT, DMA_RESET_VAL);    /* reset the dma controller */
  out_byte(DMA_FLIPFLOP, 0);		/* write anything to reset it */
  out_byte(DMA_MODE, f_opcode == DEV_WRITE ? DMA_WRITE : DMA_READ);
  out_byte(DMA_ADDR, (int) tp->tr_dma >>  0);
  out_byte(DMA_ADDR, (int) tp->tr_dma >>  8);
  out_byte(DMA_TOP, (int) (tp->tr_dma >> 16));
  out_byte(DMA_COUNT, (tp->tr_count - 1) >> 0);
  out_byte(DMA_COUNT, (tp->tr_count - 1) >> 8);
  out_byte(DMA_INIT, 2);	/* some sort of enable */
}


/*===========================================================================*
 *				start_motor				     *
 *===========================================================================*/
PRIVATE void start_motor()
{
/* Control of the floppy disk motors is a big pain.  If a motor is off, you
 * have to turn it on first, which takes 1/2 second.  You can't leave it on
 * all the time, since that would wear out the diskette.  However, if you turn
 * the motor off after each operation, the system performance will be awful.
 * The compromise used here is to leave it on for a few seconds after each
 * operation.  If a new operation is started in that interval, it need not be
 * turned on again.  If no new operation is started, a timer goes off and the
 * motor is turned off.  I/O port DOR has bits to control each of 4 drives.
 * The timer cannot go off while we are changing with the bits, since the
 * clock task cannot run while another (this) task is active, so there is no
 * need to lock().
 */

  int motor_bit, running;
  message mess;

  motor_bit = 1 << f_drive;		/* bit mask for this drive */
  running = motor_status & motor_bit;	/* nonzero if this motor is running */
  motor_goal = motor_status | motor_bit;/* want this drive running too */

  out_byte(DOR, (motor_goal << MOTOR_SHIFT) | ENABLE_INT | f_drive);
  motor_status = motor_goal;

  /* If the motor was already running, we don't have to wait for it. */
  if (running) return;			/* motor was already running */
  clock_mess(mtr_setup[d], send_mess);	/* motor was not running */
  receive(CLOCK, &mess);		/* wait for clock interrupt */
}


/*===========================================================================*
 *				stop_motor				     *
 *===========================================================================*/
PRIVATE void stop_motor()
{
/* This routine is called by the clock interrupt after several seconds have
 * elapsed with no floppy disk activity.  It checks to see if any drives are
 * supposed to be turned off, and if so, turns them off.
 */

  if (motor_goal != motor_status) {
	out_byte(DOR, (motor_goal << MOTOR_SHIFT) | ENABLE_INT);
	motor_status = motor_goal;
  }
}


/*===========================================================================*
 *				floppy_stop				     *
 *===========================================================================*/
PUBLIC void floppy_stop()
{
/* Stop all activity. */

  motor_goal = 0;
  stop_motor();
}


/*===========================================================================*
 *				seek					     *
 *===========================================================================*/
PRIVATE int seek(fp)
struct floppy *fp;		/* pointer to the drive struct */
{
/* Issue a SEEK command on the indicated drive unless the arm is already
 * positioned on the correct cylinder.
 */

  int r;
  message mess;

  /* Are we already on the correct cylinder? */
  if (fp->fl_calibration == UNCALIBRATED)
	if (recalibrate(fp) != OK) return(ERR_SEEK);
  if (fp->fl_curcyl == fp->fl_hardcyl) return(OK);

  /* No.  Wrong cylinder.  Issue a SEEK and wait for interrupt. */
  fdc_out(FDC_SEEK);
  fdc_out((fp->fl_head << 2) | f_drive);
  fdc_out(fp->fl_hardcyl);
  if (need_reset) return(ERR_SEEK);	/* if controller is sick, abort seek */
  if (f_intr_wait() != OK) return(ERR_TIMEOUT);

  /* Interrupt has been received.  Check drive status. */
  fdc_out(FDC_SENSE);		/* probe FDC to make it return status */
  r = fdc_results();		/* get controller status bytes */
  if (r != OK || (f_results[ST0] & ST0_BITS) != SEEK_ST0
				|| f_results[ST1] != fp->fl_hardcyl) {
	/* seek failed, may need a recalibrate */
	return(ERR_SEEK);
  }
  /* give head time to settle on a format, no retrying here! */
  if (f_device & FORMAT_DEV_BIT) {
	clock_mess(2, send_mess);
	receive(CLOCK, &mess);
  }
  fp->fl_curcyl = fp->fl_hardcyl;
  return(OK);
}


/*===========================================================================*
 *				f_transfer				     *
 *===========================================================================*/
PRIVATE int f_transfer(fp, tp)
struct floppy *fp;		/* pointer to the drive struct */
struct trans *tp;		/* pointer to the transfer struct */
{
/* The drive is now on the proper cylinder.  Read, write or format 1 block. */

  int r, s;

  /* Never attempt a transfer if the drive is uncalibrated or motor is off. */
  if (fp->fl_calibration == UNCALIBRATED) return(ERR_TRANSFER);
  if ((motor_status & (1 << f_drive)) == 0) return(ERR_TRANSFER);

  /* The command is issued by outputting several bytes to the controller chip.
   */
  if (f_device & FORMAT_DEV_BIT) {
	fdc_out(FDC_FORMAT);
	fdc_out((fp->fl_head << 2) | f_drive);
	fdc_out(fmt_param.sector_size_code);
	fdc_out(fmt_param.sectors_per_cylinder);
	fdc_out(fmt_param.gap_length_for_format);
	fdc_out(fmt_param.fill_byte_for_format);
  } else {
	fdc_out(f_opcode == DEV_WRITE ? FDC_WRITE : FDC_READ);
	fdc_out((fp->fl_head << 2) | f_drive);
	fdc_out(fp->fl_cylinder);
	fdc_out(fp->fl_head);
	fdc_out(fp->fl_sector);
	fdc_out(SECTOR_SIZE_CODE);
	fdc_out(f_sectors);
	fdc_out(gap[d]);	/* sector gap */
	fdc_out(DTL);		/* data length */
  }

  /* Block, waiting for disk interrupt. */
  if (need_reset) return(ERR_TRANSFER);	/* if controller is sick, abort op */

  if (f_intr_wait() != OK) return(ERR_TIMEOUT);

  /* Get controller status and check for errors. */
  r = fdc_results();
  if (r != OK) return(r);

  if (f_results[ST1] & WRITE_PROTECT) {
	printf("%s: diskette is write protected.\n", f_name());
	return(ERR_WR_PROTECT);
  }

  if ((f_results[ST0] & ST0_BITS) != TRANS_ST0) return(ERR_TRANSFER);
  if (f_results[ST1] | f_results[ST2]) return(ERR_TRANSFER);

  if (f_device & FORMAT_DEV_BIT) return(OK);

  /* Compare actual numbers of sectors transferred with expected number. */
  s =  (f_results[ST_CYL] - fp->fl_cylinder) * NR_HEADS * f_sectors;
  s += (f_results[ST_HEAD] - fp->fl_head) * f_sectors;
  s += (f_results[ST_SEC] - fp->fl_sector);
  if ((s << SECTOR_SHIFT) != tp->tr_count) return(ERR_TRANSFER);

  /* This sector is next for I/O: */
  fp->fl_sector = f_results[ST_SEC];
  return(OK);
}


/*==========================================================================*
 *				fdc_results				    *
 *==========================================================================*/
PRIVATE int fdc_results()
{
/* Extract results from the controller after an operation, then allow floppy
 * interrupts again.
 */

  int result_nr, status;
  struct milli_state ms;

  /* Extract bytes from FDC until it says it has no more.  The loop is
   * really an outer loop on result_nr and an inner loop on status.
   */
  result_nr = 0;
  milli_start(&ms);
  do {
	/* Reading one byte is almost a mirror of fdc_out() - the DIRECTION
	 * bit must be set instead of clear, but the CTL_BUSY bit destroys
	 * the perfection of the mirror.
	 */
	status = in_byte(FDC_STATUS) & (MASTER | DIRECTION | CTL_BUSY);
	if (status == (MASTER | DIRECTION | CTL_BUSY)) {
		if (result_nr >= MAX_RESULTS) break;	/* too many results */
		f_results[result_nr++] = in_byte(FDC_DATA);
		continue;
	}
	if (status == MASTER) {	/* all read */
		enable_irq(FLOPPY_IRQ);
		return(OK);	/* only good exit */
	}
  } while (milli_elapsed(&ms) < TIMEOUT);
  need_reset = TRUE;		/* controller chip must be reset */
  enable_irq(FLOPPY_IRQ);
  return(ERR_STATUS);
}


/*==========================================================================*
 *				f_handler				    *
 *==========================================================================*/
PRIVATE int f_handler(irq)
int irq;
{
/* FDC interrupt, send message to floppy task. */

  interrupt(FLOPPY);
  return 0;
}


/*===========================================================================*
 *				fdc_out					     *
 *===========================================================================*/
PRIVATE void fdc_out(val)
int val;		/* write this byte to floppy disk controller */
{
/* Output a byte to the controller.  This is not entirely trivial, since you
 * can only write to it when it is listening, and it decides when to listen.
 * If the controller refuses to listen, the FDC chip is given a hard reset.
 */

  struct milli_state ms;

  if (need_reset) return;	/* if controller is not listening, return */

  /* It may take several tries to get the FDC to accept a command. */
  milli_start(&ms);
  while ((in_byte(FDC_STATUS) & (MASTER | DIRECTION)) != (MASTER | 0)) {
	if (milli_elapsed(&ms) >= TIMEOUT) {
		/* Controller is not listening.  Hit it over the head. */
		need_reset = TRUE;
		return;
	}
  }
  out_byte(FDC_DATA, val);
}


/*===========================================================================*
 *				recalibrate				     *
 *===========================================================================*/
PRIVATE int recalibrate(fp)
struct floppy *fp;	/* pointer tot he drive struct */
{
/* The floppy disk controller has no way of determining its absolute arm
 * position (cylinder).  Instead, it steps the arm a cylinder at a time and
 * keeps track of where it thinks it is (in software).  However, after a
 * SEEK, the hardware reads information from the diskette telling where the
 * arm actually is.  If the arm is in the wrong place, a recalibration is done,
 * which forces the arm to cylinder 0.  This way the controller can get back
 * into sync with reality.
 */

  int r;

  /* Issue the RECALIBRATE command and wait for the interrupt. */
  start_motor();		/* can't recalibrate with motor off */
  fdc_out(FDC_RECALIBRATE);	/* tell drive to recalibrate itself */
  fdc_out(f_drive);		/* specify drive */
  if (need_reset) return(ERR_SEEK);	/* don't wait if controller is sick */
  if (f_intr_wait() != OK) return(ERR_TIMEOUT);

  /* Determine if the recalibration succeeded. */
  fdc_out(FDC_SENSE);		/* issue SENSE command to request results */
  r = fdc_results();		/* get results of the FDC_RECALIBRATE command*/
  fp->fl_curcyl = NO_CYL;	/* force a SEEK next time */
  if (r != OK ||		/* controller would not respond */
     (f_results[ST0] & ST0_BITS) != SEEK_ST0 || f_results[ST_PCN] != 0) {
	/* Recalibration failed.  FDC must be reset. */
	need_reset = TRUE;
	return(ERR_RECALIBRATE);
  } else {
	/* Recalibration succeeded. */
	fp->fl_calibration = CALIBRATED;
	return(OK);
  }
}


/*===========================================================================*
 *				f_reset					     *
 *===========================================================================*/
PRIVATE void f_reset()
{
/* Issue a reset to the controller.  This is done after any catastrophe,
 * like the controller refusing to respond.
 */

  int i;
  message mess;

  /* Disable interrupts and strobe reset bit low. */
  need_reset = FALSE;

  /* It is not clear why the next lock is needed.  Writing 0 to DOR causes
   * interrupt, while the PC documentation says turning bit 8 off disables
   * interrupts.  Without the lock:
   *   1) the interrupt handler sets the floppy mask bit in the 8259.
   *   2) writing ENABLE_INT to DOR causes the FDC to assert the interrupt
   *      line again, but the mask stops the cpu being interrupted.
   *   3) the sense interrupt clears the interrupt (not clear which one).
   * and for some reason the reset does not work.
   */
  lock();
  motor_status = 0;
  motor_goal = 0;
  out_byte(DOR, 0);		/* strobe reset bit low */
  out_byte(DOR, ENABLE_INT);	/* strobe it high again */
  unlock();
  receive(HARDWARE, &mess);	/* collect the RESET interrupt */

  /* The controller supports 4 drives and returns a result for each of them.
   * Collect all the results now.  The old version only collected the first
   * result.  This happens to work for 2 drives, but it doesn't work for 3
   * or more drives, at least with only drives 0 and 2 actually connected
   * (the controller generates an extra interrupt for the middle drive when
   * drive 2 is accessed and the driver panics).
   *
   * It would be better to keep collecting results until there are no more.
   * For this, fdc_results needs to return the number of results (instead
   * of OK) when it succeeds.
   */
  for (i = 0; i < 4; i++) {
	fdc_out(FDC_SENSE);	/* probe FDC to make it return status */
	(void) fdc_results();	/* flush controller */
  }
  for (i = 0; i < NR_DRIVES; i++)	/* clear each drive */
	floppy[i].fl_calibration = UNCALIBRATED;

  /* The current timing parameters must be specified again. */
  current_spec1 = 0;
}


/*===========================================================================*
 *				send_mess				     *
 *===========================================================================*/
PRIVATE void send_mess()
{
/* This routine is called when the clock task has timed out on motor startup.*/

  message mess;

  send(FLOPPY, &mess);
}


/*===========================================================================*
 *				f_intr_wait				     *
 *===========================================================================*/
PRIVATE int f_intr_wait()
{
/* Wait for an interrupt, but not forever.  The FDC may have all the time of
 * the world, but we humans do not.
 */
  message mess;

  f_busy = BSY_IO;
  clock_mess(WAKEUP, f_timeout);
  receive(HARDWARE, &mess);

  if (f_busy == BSY_WAKEN) {
	/* No interrupt from the FDC, this means that there is probably no
	 * floppy in the drive.  Get the FDC down to earth and return error.
	 */
	f_reset();
	return(ERR_TIMEOUT);
  }
  f_busy = BSY_IDLE;
  return(OK);
}


/*===========================================================================*
 *				f_timeout				     *
 *===========================================================================*/
PRIVATE void f_timeout()
{
/* When it takes too long for the FDC to get an interrupt (no floppy in the
 * drive), this routine is called.  It sets a flag and fakes a hardware
 * interrupt.
 */
  if (f_busy == BSY_IO) {
	f_busy = BSY_WAKEN;
	interrupt(FLOPPY);
  }
}


/*==========================================================================*
 *				read_id					    *
 *==========================================================================*/
PRIVATE int read_id(fp)
struct floppy *fp;	/* pointer to the drive struct */
{
/* Determine current cylinder and sector. */

  int result;

  /* Never attempt a read id if the drive is uncalibrated or motor is off. */
  if (fp->fl_calibration == UNCALIBRATED) return(ERR_READ_ID);
  if ((motor_status & (1 << f_drive)) == 0) return(ERR_READ_ID);

  /* The command is issued by outputting 2 bytes to the controller chip. */
  fdc_out(FDC_READ_ID);		/* issue the read id command */
  fdc_out( (f_fp->fl_head << 2) | f_drive);

  /* Block, waiting for disk interrupt. */
  if (need_reset) return(ERR_READ_ID);	/* if controller is sick, abort op */

  if (f_intr_wait() != OK) return(ERR_TIMEOUT);

  /* Get controller status and check for errors. */
  result = fdc_results();
  if (result != OK) return(result);

  if ((f_results[ST0] & ST0_BITS) != TRANS_ST0) return(ERR_READ_ID);
  if (f_results[ST1] | f_results[ST2]) return(ERR_READ_ID);

  /* The next sector is next for I/O: */
  f_fp->fl_sector = f_results[ST_SEC] + 1;
  return(OK);
}


/*==========================================================================*
 *				f_do_open				    *
 *==========================================================================*/
PRIVATE int f_do_open(dp, m_ptr)
struct driver *dp;
message *m_ptr;			/* pointer to open message */
{
/* Handle an open on a floppy.  Determine diskette type if need be. */

  int dtype;
  struct test_order *top;

  /* Decode the message parameters. */
  if (f_prepare(m_ptr->DEVICE) == NIL_DEV) return(ENXIO);

  dtype = f_device & DEV_TYPE_BITS;	/* get density from minor dev */
  if (dtype >= MINOR_fd0a) dtype = 0;
  if (dtype != 0) {
	/* All types except 0 indicate a specific drive/medium combination.*/
	dtype = (dtype >> DEV_TYPE_SHIFT) - 1;
	if (dtype >= NT) return(ENXIO);
	f_fp->fl_density = dtype;
	f_fp->fl_geom.dv_size = (long) nr_blocks[dtype] << SECTOR_SHIFT;
	return(OK);
  }
  if (f_device & FORMAT_DEV_BIT) return(EIO);	/* Can't format /dev/fdx */

  /* No need to test if the motor is still running. */
  if (motor_status & (1 << f_drive)) return(OK);

  /* The device opened is /dev/fdx.  Experimentally determine drive/medium.
   * First check fl_density.  If it is not NO_DENS, the drive has been used
   * before and the value of fl_density tells what was found last time. Try
   * that first.
   */
  if (f_fp->fl_density != NO_DENS && test_read(f_fp->fl_density) == OK)
	return(OK);

  /* Either drive type is unknown or a different diskette is now present.
   * Use test_order to try them one by one.
   */
  for (top = &test_order[0]; top < &test_order[NT-1]; top++) {
	dtype = top->t_density;

	/* Skip densities that have been proven to be impossible */
	if (!(f_fp->fl_class & (1 << dtype))) continue;

	if (test_read(dtype) == OK) {
		/* The test succeeded, use this knowledge to limit the
		 * drive class to match the density just read.
		 */
		f_fp->fl_class &= top->t_class;
		return(OK);
	}
	/* Test failed, wrong density or did it time out? */
	if (f_busy == BSY_WAKEN) break;
  }
  f_fp->fl_density = NO_DENS;
  return(EIO);			/* nothing worked */
}


/*==========================================================================*
 *				test_read				    *
 *==========================================================================*/
PRIVATE int test_read(density)
int density;
{
/* Try to read the highest numbered sector on cylinder 2.  Not all floppy
 * types have as many sectors per track, and trying cylinder 2 finds the
 * ones that need double stepping.
 */

  message m;
  int r, device;

  f_fp->fl_density = density;
  device = ((density + 1) << DEV_TYPE_SHIFT) + f_drive;
  f_fp->fl_geom.dv_size = (long) nr_blocks[density] << SECTOR_SHIFT;
  m.m_type = DEV_READ;
  m.DEVICE = device;
  m.PROC_NR = FLOPPY;
  m.COUNT = SECTOR_SIZE;
  m.POSITION = (long) test_sector[density] * SECTOR_SIZE;
  m.ADDRESS = (char *) tmp_buf;
  r = do_rdwt(&f_dtab, &m);
  if (r != SECTOR_SIZE) return(EIO);

  partition(&f_dtab, f_drive, P_FLOPPY);
  return(OK);
}


/*============================================================================*
 *				f_geometry				      *
 *============================================================================*/
PRIVATE void f_geometry(entry)
struct partition *entry;
{
  entry->cylinders = nr_blocks[d] / (NR_HEADS * f_sectors);
  entry->heads = NR_HEADS;
  entry->sectors = f_sectors;
}
