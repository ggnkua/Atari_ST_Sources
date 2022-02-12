/*
 * This file contains the device dependent part of an experimental disk
 * and tape driver for the Adaptec 154x SCSI Host Adapter family, written
 * by James da Silva (jds@cs.umd.edu).
 *
 * I wrote this driver using the technical documentation for the AHA available
 * from the Adaptec BBS at 1-408-945-7727, and from the SCSI standard drafts
 * available on NCR's SCSI BBS at 1-316-636-8700.  I suggest you get both
 * these documents if you want to understand and hack this code.
 *
 * This code has been extensively modified by Kees J. Bot (kjb@cs.vu.nl) to
 * a point that James will barely recognize it as his.  It is completely
 * remodeled and doubled in both size and functionality.  It is no longer
 * considered experimental either.
 *
 * The supported device numbers are as follows:
 *   #	Name	Device
 *   0	d0	disk 0
 *   1	d0p0	disk 0, partition 0
 *   2	d0p0	disk 0, partition 1
 *   3	d0p0	disk 0, partition 2
 *   4	d0p0	disk 0, partition 3
 *   5	d1	disk 1
 *   6	d1p0	disk 1, partition 0
 *  ..	....	....
 *  39	d7p3	disk 7, partition 3
 *
 *  64	t0n	tape 0, no rewind
 *  65	t0	tape 0, rewind
 *  66	t1n	tape 1, no rewind
 *  ..	....	....
 *  79	t7	tape 7, rewind
 *
 * 128	d0p0s0	disk 0, partition 0, subpartition 0
 * 129	d0p0s1	disk 0, partition 0, subpartition 1
 * ...	....	....
 * 255	d7p3s3	disk 7, partition 3, subpartition 3
 *
 * The translation of device numbers to targets and logical units is very
 * simple:  The target is the same as the disk or tape number, the logical
 * unit is always zero.  Devices with logical unit numbers other then zero
 * are usually RAID enclosures.  If you happen to be so lucky to have such
 * a thing, then you can reprogram (e.g.) d7 and t7 to target 0, lun 1
 * from the Boot Monitor with 'aha1540-d7=:0,1'.
 *
 *
 * The file contains one entry point:
 *
 *   aha1540_scsi_task:	main entry when system is brought up
 *
 *
 * Changes:
 *	 5 May 1992 by Kees J. Bot: device dependent/independent split.
 *	 7 Jul 1992 by Kees J. Bot: speedup & features.
 *	28 Dec 1992 by Kees J. Bot: completely remodeled & virtual memory.
 *	18 Sep 1994 by Kees J. Bot: removed "send 2 commands at once" junk.
 *	14 May 2000 by Kees J. Bot: d-d/i rewrite.
 */
#include "kernel.h"
#include "driver.h"
#include "drvlib.h"
#if ENABLE_AHA1540_SCSI
#include <fcntl.h>
#include <sys/ioc_disk.h>
#include <sys/ioc_tape.h>
#include <sys/ioc_scsi.h>
#include <sys/mtio.h>


#ifndef AHA_DEBUG
#define AHA_DEBUG	0	/* 1=print all SCSI errors | 2=dump ccb
				 * 4=show iov&request | 8=dump scsi cmd
				 */
#endif

/* AHA-154x port addresses */
#define AHA_BASEREG	0x330	/* default base port address of AHA registers */
#define AHA_CNTLREG	aha_basereg+0	/* Control Register - write only */
#define AHA_STATREG	aha_basereg+0	/* Status Register - read only */
#define AHA_DATAREG	aha_basereg+1	/* Data Register - read/write */
#define AHA_INTRREG	aha_basereg+2	/* Interrupt Flags - read only */

/* control register bits */
#define AHA_HRST	0x80	/* bit 7 - Hard Reset */
#define AHA_SRST	0x40	/* bit 6 - Soft Reset */
#define AHA_IRST	0x20	/* bit 5 - Interrupt Reset */
#define AHA_SCRST	0x10	/* bit 4 - SCSI Bus Reset */
/*			0x08	 * bit 3 - Reserved (set to 0) */
/*			0x04	 * bit 2 - Reserved (set to 0) */
/*			0x02	 * bit 1 - Reserved (set to 0) */
/*			0x01	 * bit 0 - Reserved (set to 0) */

/* status register bits */
#define AHA_STST	0x80	/* bit 7 - Self Test in Progress */
#define AHA_DIAGF	0x40	/* bit 6 - Internal Diagnostic Failure */
#define AHA_INIT	0x20	/* bit 5 - Mailbox Initialization Required */
#define AHA_IDLE	0x10	/* bit 4 - SCSI Host Adapter Idle */
#define AHA_CDF		0x08	/* bit 3 - Command/Data Out Port Full */
#define AHA_DF		0x04	/* bit 2 - Data In Port Full */
/*			0x02	 * bit 1 - Reserved */
#define AHA_INVDCMD	0x01	/* bit 0 - Invalid Host Adapter Command */

/* interrupt flags register bits */
#define AHA_ANYINT	0x80	/* bit 7 - Any Interrupt */
/*			0x40	 * bit 6 - Reserved */
/*			0x20	 * bit 5 - Reserved */
/*			0x10	 * bit 4 - Reserved */
#define AHA_SCRD	0x08	/* bit 3 - SCSI Reset Detected */
#define AHA_HACC	0x04	/* bit 2 - Host Adapter Command Complete */
#define AHA_MBOE	0x02	/* bit 1 - Mailbox Out Empty */
#define AHA_MBIF	0x01	/* bit 0 - Mailbox In Full */

/* AHA board models */
#define AHA1540		0x30
#define AHA1540A	0x41
#define AHA1640		0x42
#define AHA1740		0x43
#define AHA1540C	0x44
#define AHA1540CF	0x45
#define BT545		0x20	/* BusLogic */

/* AHA Command Codes */
#define AHACOM_INITBOX		0x01	/* Mailbox Initialization */
#define AHACOM_STARTSCSI	0x02	/* Start SCSI Command */
#define AHACOM_HAINQUIRY	0x04	/* Host Adapter Inquiry */
#define AHACOM_SETIMEOUT	0x06	/* Set SCSI selection time out value */
#define AHACOM_BUSON		0x07	/* Set DMA bus on time */
#define AHACOM_BUSOFF		0x08	/* Set DMA bus off time */
#define AHACOM_SPEED		0x09	/* Set DMA transfer speed */
#define AHACOM_INSTALLED	0x0A	/* Return Installed Devices */
#define AHACOM_GETCONFIG	0x0B	/* Return Configuration Data */
#define AHACOM_GETSETUP		0x0D	/* Return Setup Data */
#define AHACOM_EXTBIOS		0x28	/* Return Extended BIOS Info */
#define AHACOM_MBOX_ENABLE	0x29	/* Enable Mailbox Interface */

/* AHA Mailbox Out Codes */
#define AHA_MBOXFREE	0x00	/* Mailbox is Free */
#define AHA_MBOXSTART	0x01	/* Start Command */
#define AHA_MBOXABORT	0x02	/* Abort Command */
/* AHA Mailbox In Codes */
#define AHA_MBOXOK	0x01	/* Command Completed Successfully */
#define AHA_MBOXERR	0x04	/* Command Completed with Error */


/* Basic types */
typedef unsigned char byte;
typedef byte big16[2];	/* 16 bit big-endian values */
typedef byte big24[3];	/* AHA uses 24 bit, big-endian values! */
typedef byte big32[4];	/* Group 1 SCSI commands use 32 bit big-endian values */

/* AHA Mailbox structure */
typedef struct {
  byte status;		/* Command or Status byte */
  big24 ccbptr;		/* pointer to Command Control Block */
} mailbox_t;

/* SCSI Group 0 Command Descriptor Block structure */
typedef union {
    struct {	/* Disk i/o commands */
	byte d_scsi_op;		/* SCSI Operation Code */
#	    define SCSI_UNITRDY  0x00	/* Test Unit Ready */
#	    define SCSI_REWIND   0x01	/* Rewind */
#	    define SCSI_REQSENSE 0x03	/* Request sense */
#	    define SCSI_RDLIMITS 0x05	/* Read Block Limits Opcode */
#	    define SCSI_READ     0x08	/* Group 0 Read Opcode */
#	    define SCSI_WRITE    0x0A	/* Group 0 Write Opcode */
#	    define SCSI_WREOF    0x10	/* Write File Marks */
#	    define SCSI_SPACE    0x11	/* Space over filemarks/blocks */
#	    define SCSI_INQUIRY  0x12	/* Group 0 Inquiry Opcode */
#	    define SCSI_MDSELECT 0x15	/* Group 0 Mode Select Opcode */
#	    define SCSI_ERASE    0x19	/* Erase Tape */
#	    define SCSI_MDSENSE  0x1A	/* Group 0 Mode Sense Opcode */
#	    define SCSI_STRTSTP  0x1B	/* Start/Stop */
#	    define SCSI_LOADUNLD 0x1B	/* Load/Unload */
        big24 d_lba;		/* LUN and logical block address */
	byte d_nblocks;		/* Transfer size in blocks */
	byte d_control;		/* Reserved and link bit fields, set to 0 */
    } d;
    struct {	/* Tape i/o commands */
	byte t_scsi_op;		/* SCSI Operation Code */
	byte t_fixed;		/* Fixed length? */
	big24 t_trlength;	/* Transfer length */
	byte t_control;		/* reserved and link bit fields, set to 0 */
    } t;
} cdb0_t;
#define scsi_op		d.d_scsi_op
#define lba		d.d_lba
#define nblocks		d.d_nblocks
#define fixed		t.t_fixed
#define trlength	t.t_trlength
#define control		d.d_control

/* SCSI Group 1 Command Descriptor Block structure */
typedef union {
    struct {	/* Disk i/o commands */
	byte d_scsi_op;		/* SCSI Operation Code */
#	    define SCSI_CAPACITY 0x25	/* Read Capacity */
#	    define SCSI_READ1    0x28	/* Group 1 Read Opcode */
#	    define SCSI_WRITE1   0x2A	/* Group 1 Write Opcode */
	byte d_lunra;		/* LUN etc. */
        big32 d_lba;		/* Logical Block Address */
	byte reserved;
	big16 d_nblocks;	/* transfer size in blocks */
	byte d_control;		/* reserved and link bit fields, set to 0 */
    } d;
} cdb1_t;
#define lunra		d.d_lunra

/* SCSI Request Sense Information */
typedef struct {
    byte errc;			/* Error Code, Error Class, and Valid bit */
    byte segnum;		/* Segment Number */
    byte key;			/* Sense Key */
#	define sense_key(key)	(key & 0x0F)	/* the key portion */
#	define sense_ili(key)	(key & 0x20)	/* illegal block size */
#	define sense_eom(key)	(key & 0x40)	/* end-of-media */
#	define sense_eof(key)	(key & 0x80)	/* filemark reached */
    big32 info;			/* sense info */
    byte len;			/* additional length */
    big32 comspec;		/* command specific info */
    byte add_code;		/* additional sense code */
    byte add_qual;		/* additional sense code qualifier */
} sense_t;

/* Interesting SCSI sense key types. */
#define SENSE_NO_SENSE		0x00
#define SENSE_RECOVERED		0x01
#define SENSE_NOT_READY		0x02
#define SENSE_HARDWARE		0x04
#define SENSE_UNIT_ATT		0x06
#define SENSE_BLANK_CHECK	0x08
#define SENSE_VENDOR		0x09
#define SENSE_ABORTED_CMD	0x0B

/* SCSI Inquiry Information */
typedef struct {
    byte devtype;		/* Peripheral Device Type */
#	define SCSI_DEVDISK	0	/* Direct-access */
#	define SCSI_DEVTAPE	1	/* Sequential-access */
#	define SCSI_DEVPRN	2	/* Printer */
#	define SCSI_DEVCPU	3	/* Processor */
#	define SCSI_DEVWORM	4	/* Write-Once Read-Multiple device */
#	define SCSI_DEVCDROM	5	/* Read-Only Direct-access */
#	define SCSI_DEVSCANNER	6	/* Scanner */
#	define SCSI_DEVOPTICAL	7	/* Optical Memory */
#	define SCSI_DEVJUKEBOX	8	/* Medium Changer device */
#	define SCSI_DEVCOMM	9	/* Communications device */
#	define SCSI_DEVMAX	9	/* Last device type we know about */
#	define SCSI_DEVUNKNOWN	10	/* If we do not know or care. */
    byte devqual;		/* Device-Type Qualifier */
#	define scsi_rmb(d)	(((d) & 0x80) != 0)	/* Removable? */
    byte stdver;		/* Version of standard compliance */
#	define scsi_isover(v)   (((v) & 0xC0) >> 6)	/* ISO version */
#	define scsi_ecmaver(v)  (((v) & 0x38) >> 3)	/* ECMA version */
#	define scsi_ansiver(v)  ((v) & 0x07)		/* ANSI version */
    byte format;		/* Response data format */
    byte len;			/* length of remaining info */
    byte reserved[2];
    byte flags;
#	define scsi_sync(f)	(((f) & 0x10) != 0)	/* Sync SCSI? */
    char vendor[8];		/* Vendor name */
    char product[16];		/* Product name */
    char revision[4];		/* Revision level */
    char extra[20];		/* Vendor specific */
} inquiry_t;

/* AHA Command Control Block structure */
typedef struct {
    byte opcode;		/* Operation Code */
#	define CCB_INIT		0x00		/* SCSI Initiator Command */
#	define CCB_TARGET	0x01		/* Target Mode Command */
#	define CCB_SCATTER	0x02	     /* Initiator with scatter/gather */
    byte addrcntl;		/* Address and Direction Control: */
#       define ccb_scid(id)     (((id)<<5)&0xE0) /* SCSI ID field */
#	define CCB_OUTCHECK	0x10		 /* Outbound length check */
#	define CCB_INCHECK	0x08		 /* Inbound length check */
#	define CCB_NOCHECK	0x00		 /* No length check */
#	define ccb_lun(lun)     ((lun)&0x07)	 /* SCSI LUN field */
    byte cmdlen;		/* SCSI Command Length (6 for Group 0) */
    byte senselen;		/* Request/Disable Sense, Allocation Length */
#	define CCB_SENSEREQ	0x0E		/* Request Sense, 14 bytes */
#	define CCB_SENSEOFF	0x01		/* Disable Request Sense */
    big24 datalen;		/* Data Length:  3 bytes, big endian */
    big24 dataptr;		/* Data Pointer: 3 bytes, big endian */
    big24 linkptr;		/* Link Pointer: 3 bytes, big endian */
    byte linkid;		/* Command Linking Identifier */
    byte hastat;		/* Host Adapter Status */
#	define HST_TIMEOUT	0x11		/* SCSI selection timeout */
    byte tarstat;		/* Target Device Status */
#	define TST_CHECK	0x02		/* Check status in sense[] */
#	define TST_LUNBUSY	0x08		/* Unit is very busy */
    byte reserved[2];		/* reserved, set to 0 */
    byte cmd[sizeof(cdb1_t)];	/* SCSI Command Descriptor Block */
    byte sense[sizeof(sense_t)];/* SCSI Request Sense Information */
} ccb_t;


	/* End of one chunk must be as "odd" as the start of the next. */
#define DMA_CHECK(end, start)	((((int) (end) ^ (int) (start)) & 1) == 0)

/* Scatter/Gather DMA list */
typedef struct {
    big24 datalen;		/* length of a memory segment */
    big24 dataptr;		/* address of a memory segment */
} dma_t;


/* Miscellaneous parameters */
#define SCSI_TIMEOUT	 250	/* SCSI selection timeout (ms), 0 = none */
#define AHA_TIMEOUT   500000L	/* max usec wait for controller reset */

#define MAX_DEVICES	   8	/* 8 devices for the 8 SCSI targets */
#define NR_DISKDEVS	 (MAX_DEVICES * DEV_PER_DRIVE)
#define NR_TAPEDEVS	 (MAX_DEVICES * 2)
#define NR_GENDEVS	 (MAX_DEVICES)
#define SUB_PER_DRIVE	 (NR_PARTITIONS * NR_PARTITIONS)
#define NR_SUBDEVS	 (MAX_DEVICES * SUB_PER_DRIVE)

#define TYPE_D		   0	/* disk device number */
#define TYPE_TN		   1	/* non rewind-on-close tape device */
#define TYPE_T		   2	/* rewind-on-close tape device */


/* Variables */
PRIVATE struct scsi {	/* Per-device table */
    char targ;			/* SCSI Target ID */
    char lun;			/* SCSI Logical Unit Number */
    char state;			/* online? */
#	define S_PRESENT	0x01	/* Device exists */
#	define S_READY		0x02	/* Device is ready */
#	define S_RDONLY		0x04	/* Device is read-only */
    char devtype;		/* SCSI_DEVDISK, SCSI_DEVTAPE, ... */
    unsigned block_size;	/* device or media block size */
    unsigned count_max;		/* maximum single read or write */
    unsigned open_ct;		/* number of processes using the device */
    union {
	struct {		/* Tape data */
	    char open_mode;	/* open for reading or writing? */
	    char at_eof;	/* got EOF mark */
	    char need_eof;	/* need to write an eof mark */
	    char tfixed;	/* tape in fixed mode */
	    struct mtget tstat;	/* tape status info */
	    struct device dummypart;  /* something for s_prepare to return */
	} tape;
	struct {		/* Disk data */
	    struct device part[DEV_PER_DRIVE];	  /* disks and partitions */
	    struct device subpart[SUB_PER_DRIVE]; /* subpartitions */
	} disk;
    } u;
} scsi[MAX_DEVICES];

#define open_mode	u.tape.open_mode
#define at_eof		u.tape.at_eof
#define need_eof	u.tape.need_eof
#define tfixed		u.tape.tfixed
#define tstat		u.tape.tstat
#define dummypart	u.tape.dummypart
#define part		u.disk.part
#define subpart		u.disk.subpart

/* Tape device status (tstat.mt_dsreg). */
#define DS_OK		0	/* Device OK */
#define DS_ERR		1	/* Error state */
#define DS_EOF		2	/* Last read or space hit EOF */

/* SCSI device types */
PRIVATE char *scsi_devstr[SCSI_DEVMAX+1] = {
  "DISK", "TAPE", "PRINTER", "CPU", "WORM", "CDROM", "SCANNER", "OPTICAL",
  "JUKEBOX", "COMM"
};

/* SCSI sense key types */
PRIVATE char *str_scsi_sense[] = {
  "NO SENSE INFO", "RECOVERED ERROR", "NOT READY", "MEDIUM ERROR",
  "HARDWARE ERROR", "ILLEGAL REQUEST", "UNIT ATTENTION", "DATA PROTECT",
  "BLANK CHECK", "VENDOR UNIQUE ERROR", "COPY ABORTED", "ABORTED COMMAND",
  "EQUAL", "VOLUME OVERFLOW", "MISCOMPARE", "SENSE RESERVED"
};

/* Some of the above errors must be printed on the console. */
#if AHA_DEBUG & 1
#define sense_serious(key)	((key) != 0)
#else
#define sense_serious(key)	((0xFE1C & (1 << (key))) != 0)
#endif

/* Administration for one SCSI request. */
typedef struct request {
  int opcode;			/* DEV_GATHER or DEV_SCATTER */
  unsigned count;		/* number of bytes to transfer */
  unsigned retry;		/* number of tries allowed if retryable */
  u64_t position;		/* first byte on the device to transfer */
  ccb_t ccb;			/* Command Control Block */
  dma_t dmalist[NR_IOREQS];	/* scatter/gather dma list */
  dma_t *dmaptr;		/* to add scatter/gather entries */
  dma_t *dmalimit;		/* adapter model dependent limit to list */
} request_t;

PRIVATE request_t request;
#define rq (&request)		/* current request (there is only one) */

#define ccb_cmd0(rq)	(* (cdb0_t *) (rq)->ccb.cmd)
#define ccb_cmd1(rq)	(* (cdb1_t *) (rq)->ccb.cmd)
#define ccb_sense(rq)	(* (sense_t *) ((rq)->ccb.cmd + (rq)->ccb.cmdlen))

PRIVATE int aha_tasknr;		/* my task number */
PRIVATE int aha_basereg;	/* base I/O register */
PRIVATE int aha_model;		/* board model */
PRIVATE struct scsi *s_sp;	/* active SCSI device struct */
PRIVATE struct device *s_dv;	/* active partition */
PRIVATE int s_type;		/* disk, nonrewind tape, rewind tape? */
PRIVATE int aha_irq;		/* configured IRQ */
PRIVATE irq_hook_t aha_hook;	/* interrupt hook */
PRIVATE mailbox_t mailbox[2];	/* out and in mailboxes */
PRIVATE inquiry_t inqdata;	/* results of Inquiry command */


/* Functions */

FORWARD _PROTOTYPE( void s_init, (void) );
FORWARD _PROTOTYPE( struct device *s_prepare, (int device) );
FORWARD _PROTOTYPE( char *s_name, (void) );
FORWARD _PROTOTYPE( int s_do_open, (struct driver *dp, message *m_ptr) );
FORWARD _PROTOTYPE( int scsi_probe, (void) );
FORWARD _PROTOTYPE( int scsi_sense, (void) );
FORWARD _PROTOTYPE( int scsi_inquiry, (void) );
FORWARD _PROTOTYPE( int scsi_ndisk, (void) );
FORWARD _PROTOTYPE( int scsi_ntape, (void) );
FORWARD _PROTOTYPE( int s_transfer, (int proc_nr, int opcode, off_t position,
					iovec_t *iov, unsigned nr_req) );
FORWARD _PROTOTYPE( int s_rdcdrom, (int proc_nr, int opcode, off_t position,
					iovec_t *iov, unsigned nr_req) );
FORWARD _PROTOTYPE( int s_do_close, (struct driver *dp, message *m_ptr) );
FORWARD _PROTOTYPE( int s_do_ioctl, (struct driver *dp, message *m_ptr) );
FORWARD _PROTOTYPE( int scsi_simple, (int opcode, int count) );
FORWARD _PROTOTYPE( void group0, (void) );
FORWARD _PROTOTYPE( void group1, (void) );
FORWARD _PROTOTYPE( int scsi_command, (phys_bytes data, vir_bytes len) );
FORWARD _PROTOTYPE( void aha_command, (int outlen, byte *outptr,
						int inlen, byte *inptr) );
FORWARD _PROTOTYPE( int aha_reset, (void) );
FORWARD _PROTOTYPE( int s_handler, (irq_hook_t *hook) );

FORWARD _PROTOTYPE( void h2b16, (big16 b, U16_t l) );
FORWARD _PROTOTYPE( void h2b24, (big24 b, u32_t l) );
FORWARD _PROTOTYPE( void h2b32, (big32 b, u32_t l) );
FORWARD _PROTOTYPE( u16_t b2h16, (big16 b) );
FORWARD _PROTOTYPE( u32_t b2h24, (big24 b) );
FORWARD _PROTOTYPE( u32_t b2h32, (big32 b) );


#if AHA_DEBUG & 2
FORWARD _PROTOTYPE( void errordump, (void) );
#else
#define errordump()
#endif

#if AHA_DEBUG & 4
FORWARD _PROTOTYPE( void show_iov, (iovec_t *iov, unsigned nr_req) );
FORWARD _PROTOTYPE( void show_req, (void) );
#else
#define show_iov(iov, nr_req)	((void)0)
#define show_req()		((void)0)
#endif

#if AHA_DEBUG & 8
FORWARD _PROTOTYPE( void dump_scsi_cmd, (void) );
#else
#define dump_scsi_cmd()
#endif

FORWARD _PROTOTYPE( void s_geometry, (struct partition *entry));


/* Entry points to this driver. */
PRIVATE struct driver s_dtab = {
  s_name,	/* current device's name */
  s_do_open,	/* open or mount request, initialize device */
  s_do_close,	/* release device */
  s_do_ioctl,	/* tape and partition ioctls */
  s_prepare,	/* prepare for I/O on a given minor device */
  s_transfer,	/* do the I/O */
  nop_cleanup,	/* no cleanup needed */
  s_geometry	/* tell the geometry of the disk */
};


/*===========================================================================*
 *				aha1540_scsi_task			     *
 *===========================================================================*/
PUBLIC void aha1540_scsi_task()
{
/* Initialize special parameters, then call the generic main loop. */

  aha_tasknr = proc_number(proc_ptr);
  s_init();
  driver_task(&s_dtab);
}


/*===========================================================================*
 *				s_init					     *
 *===========================================================================*/
PRIVATE void s_init()
{
/* Set target and logical unit numbers. */
  int i;
  struct scsi *sp;
  long v;
  char *name;
  static char fmt[] = "d:d,d";

  for (i = 0; i < MAX_DEVICES; i++) {
	(void) s_prepare(i * DEV_PER_DRIVE);
	sp = s_sp;

	/* Look into the environment for special parameters. */
	name = s_name();

	v = i;
	(void) env_parse(name, fmt, 1, &v, 0L, 7L);
	sp->targ = v;

	v = 0;
	(void) env_parse(name, fmt, 2, &v, 0L, 7L);
	sp->lun = v;
  }
}


/*===========================================================================*
 *				s_prepare				     *
 *===========================================================================*/
PRIVATE struct device *s_prepare(device)
int device;
{
/* Prepare for I/O on a device. */

  if (device < NR_DISKDEVS) {			/* d0, d0p[0-3], d1, ... */
	s_type = TYPE_D;
	s_sp = &scsi[device / DEV_PER_DRIVE];
	s_dv = &s_sp->part[device % DEV_PER_DRIVE];
  } else
  if ((unsigned) (device - MINOR_d0p0s0) < NR_SUBDEVS) {/* d[0-7]p[0-3]s[0-3] */
	device -= MINOR_d0p0s0;
	s_type = TYPE_D;
	s_sp = &scsi[device / SUB_PER_DRIVE];
	s_dv = &s_sp->subpart[device % SUB_PER_DRIVE];
  } else
  if ((unsigned) (device - MINOR_t0) < NR_TAPEDEVS) {	/* t[0-7] */
	device -= MINOR_t0;
	s_type = (device & 1) ? TYPE_T : TYPE_TN;
	s_sp = &scsi[device >> 1];
	s_dv = &s_sp->dummypart;
  } else {
	return(NIL_DEV);
  }

  return(s_dv);
}


/*===========================================================================*
 *				s_name					     *
 *===========================================================================*/
PRIVATE char *s_name()
{
/* Return a name for the current device. */
  static char name[] = "aha1540-d0";

  name[8]= "dtt"[s_type];
  name[9]= '0' + (s_sp - scsi);
  return name;
}


/*===========================================================================*
 *				s_do_open				     *
 *===========================================================================*/
PRIVATE int s_do_open(dp, m_ptr)
struct driver *dp;
message *m_ptr;
{
  struct scsi *sp;
  int r;

  if (aha_irq == 0 && !aha_reset()) return(EIO); /* no controller, forget it */

  if (s_prepare(m_ptr->DEVICE) == NIL_DEV) return(ENXIO);
  sp = s_sp;

  if ((r = scsi_probe()) != OK) return(r);

  if (sp->state & S_RDONLY && m_ptr->COUNT & W_BIT) return(EACCES);

  switch (sp->devtype) {
  case SCSI_DEVDISK:
  case SCSI_DEVWORM:
  case SCSI_DEVCDROM:
  case SCSI_DEVOPTICAL:
	/* Read partition tables on first open. */
	if (sp->open_ct == 0) {
		partition(&s_dtab, (int) (sp-scsi) * DEV_PER_DRIVE, P_PRIMARY);
	}
	break;
  case SCSI_DEVTAPE:
	/* Make sure tape is not already open. */
	if (sp->open_ct > 0) return(EBUSY);

	sp->open_mode = m_ptr->COUNT;
	/* If open(..., O_WRONLY) then write a filemark on close even if no
	 * write is done.
	 */
	sp->need_eof = ((sp->open_mode & (R_BIT|W_BIT)) == W_BIT);
	break;
  }
  sp->open_ct++;
  return(OK);
}


/*===========================================================================*
 *				scsi_probe				     *
 *===========================================================================*/
PRIVATE int scsi_probe()
{
/* See if a device exists and if it is ready. */
  struct scsi *sp = s_sp;
  sense_t *sense;
  int r, key;

  /* Something out there? */
  if ((r = scsi_sense()) != OK) {
	if (sp->state & S_PRESENT) {
		printf("%s: offline\n", s_name());
		sp->state = 0;
	}
	return(r);
  }

  if (!(sp->state & S_PRESENT)) {
	/* First contact with a new device, what type is it? */

	if ((r = scsi_inquiry()) != OK) return(r);

	sp->devtype = inqdata.devtype;
  }

  if (!(sp->state & S_READY)) {
	/* If it's a disk: start it, if it's a tape: load it. */
	(void) scsi_simple(SCSI_STRTSTP, 1);
  }

  /* See if the unit is ready for I/O.  A disk may be spinning up, a
   * floppy or tape drive may be empty.
   */
  while ((key = scsi_simple(SCSI_UNITRDY, 0)) != SENSE_NO_SENSE) {
	/* Not ready, why? */

	sp->state &= ~S_READY;

	switch (key) {
	case SENSE_UNIT_ATT:
		/* A media change or something, try again. */
		break;
	case SENSE_NOT_READY:
		/* Look at the additional sense data to see why it isn't
		 * ready.
		 */
		sense = &ccb_sense(rq);
		switch ((sense->add_code << 8) | sense->add_qual) {
		case 0x0401:
			/* "It is becoming ready."  Fine, we wait. */
			micro_delay(1000000L);
			break;
		case 0x0402:
			/* "Initialization command required."  So we tell it
			 * to spin up.
			 */
			if (scsi_simple(SCSI_STRTSTP, 1) != SENSE_NO_SENSE)
				return(EIO);
			break;
		case 0x0403:
			/* "Manual intervention required." */
		case 0x3A00:
			/* "No media present." */
			printf("%s: no media loaded\n", s_name());
			return(EIO);
		default:
			/* For some reason it is not usable. */
			printf("%s: not ready\n", s_name());
			return(EIO);
		}
		break;
	default:
		/* The device is in some odd state.  */
		if (key != SENSE_NOT_READY) {
			printf("%s: hardware error\n", s_name());
			return(EIO);
		}
	}
  }

  if (!(sp->state & S_PRESENT)) {
	/* Do the inquiry again, the message may have changed. */
	if (scsi_inquiry() != OK) return(EIO);

	/* Tell what kind of device it is we have found. */

	printf("%s: %-7s %.48s\n",
		s_name(),
		inqdata.devtype > SCSI_DEVMAX ? "UNKNOWN"
				: scsi_devstr[inqdata.devtype],
		inqdata.vendor /* + product + revision + extra */);
  }

  if (!(sp->state & S_READY)) {
	/* Get the geometry, limits, etc. */

	switch (sp->devtype) {
	case SCSI_DEVDISK:
	case SCSI_DEVWORM:
	case SCSI_DEVCDROM:
	case SCSI_DEVOPTICAL:
		if (scsi_ndisk() != OK) return(EIO);
		break;
	case SCSI_DEVTAPE:
		if (scsi_ntape() != OK) return(EIO);
		break;
	default:
		printf("%s: unsupported\n", s_name());
		return(EIO);
	}
  }
  return(OK);
}


/*===========================================================================*
 *				scsi_sense				     *
 *===========================================================================*/
PRIVATE int scsi_sense()
{
  int key;
  sense_t *sense = (sense_t *) tmp_buf;

  /* Do a request sense to find out if a target exists or to check out
   * a unit attention condition.
   */
  key = scsi_simple(SCSI_REQSENSE, sizeof(sense_t));

  if (rq->ccb.hastat == HST_TIMEOUT) return(ENXIO);	/* nothing there */
  if (rq->ccb.hastat != 0) return(EIO);		/* something very bad */

  /* There is something out there for sure. */
  if (key == SENSE_UNIT_ATT || sense_key(sense->key) == SENSE_UNIT_ATT) {
	/* Device is in a "look at me" state, probably changed media. */
	s_sp->state &= ~S_READY;
  }
  return(OK);
}


/*===========================================================================*
 *				scsi_inquiry				     *
 *===========================================================================*/
PRIVATE int scsi_inquiry()
{
  /* Prefill with nulls. */
  memset(tmp_buf, '\0', sizeof(inquiry_t));

  /* Do a SCSI inquiry. */
  if (scsi_simple(SCSI_INQUIRY, sizeof(inquiry_t)) != SENSE_NO_SENSE)
	return(EIO);
  inqdata = * (inquiry_t *) tmp_buf;

  if (inqdata.len == 0) {
	/* The device doesn't return meaningful text fields. */
	strcpy(inqdata.vendor, "(unknown)");
  }

  /* The top three bits of devtype must be zero for the lun to exist. */
  if ((inqdata.devtype & 0xE0) != 0) return(ENXIO);

  return(OK);
}


/*===========================================================================*
 *				scsi_ndisk				     *
 *===========================================================================*/
PRIVATE int scsi_ndisk()
{
/* Gather disk data, capacity and block size. */

  struct scsi *sp = s_sp;
  unsigned long capacity = -1, block_size = SECTOR_SIZE;
  byte *buf = tmp_buf;

  /* Minor device type must be for a disk. */
  if (s_type != TYPE_D) return(EIO);

  if (sp->devtype == SCSI_DEVCDROM) {
	/* Read-only by definition. */
	sp->state |= S_RDONLY;
  } else {
	/* SCSI modesense to find out if the disk is write protected. */
	if (scsi_simple(SCSI_MDSENSE, 255) != SENSE_NO_SENSE) return(EIO);

	/* Write protected? */
	sp->state &= ~S_RDONLY;
	if (buf[2] & 0x80) sp->state |= S_RDONLY;

	/* Don't write a worm disk, not wise at the moment. */
	if (sp->devtype == SCSI_DEVWORM) sp->state |= S_RDONLY;
  }

  /* Get drive capacity and block size. */
  group1();
  rq->ccb.opcode = CCB_INIT;
  ccb_cmd1(rq).scsi_op = SCSI_CAPACITY;

  if (scsi_command(tmp_phys, 8) == SENSE_NO_SENSE) {
	capacity = b2h32(buf + 0) + 1;
	block_size = b2h32(buf + 4);
	printf("%s: capacity %lu x %lu bytes\n",
					s_name(), capacity, block_size);
  } else {
	printf("%s: unknown capacity\n", s_name());
  }

  /* We do not believe block sizes over 4 kb. */
  if (block_size > 4096) {
	printf("%s: can't handle %lu byte blocks\n", s_name(), block_size);
	return(EIO);
  }

  sp->block_size = block_size;
  sp->part[0].dv_size = mul64u(capacity, block_size);

  /* Keep it within reach of a group 0 command, and within 'unsigned'. */
  sp->count_max = block_size > UINT_MAX/0x100 ? UINT_MAX : 0x100 * block_size;

  /* Finally we recognize its existence. */
  sp->state |= S_PRESENT|S_READY;

  return(OK);
}


/*===========================================================================*
 *				scsi_ntape				     *
 *===========================================================================*/
PRIVATE int scsi_ntape()
{
/* Gather tape data, block limits, fixed block size or not. */
  struct scsi *sp = s_sp;
  unsigned minblk;
  unsigned long maxblk;
  byte *buf = tmp_buf;

  /* Minor device type must be for a tape. */
  if (s_type != TYPE_T && s_type != TYPE_TN) return(EIO);

  /* Read limits. */
  if (scsi_simple(SCSI_RDLIMITS, 6) != SENSE_NO_SENSE) return(EIO);
  minblk = b2h16(buf + 4);
  maxblk = b2h24(buf + 1);

  printf("%s: limits: min block len %u, max block len %lu\n",
	s_name(), minblk, maxblk);

  if (sp->state & S_PRESENT) {
	/* Keep the current block size. */
	if (sp->tfixed) minblk= maxblk= sp->block_size;
  }

  sp->tstat.mt_dsreg = DS_OK;
  sp->tstat.mt_erreg = 0;
  sp->tstat.mt_fileno = 0;
  sp->tstat.mt_blkno = 0;
  sp->tstat.mt_resid = 0;

  if (minblk == maxblk) {
	/* Fixed block length. */
	sp->tfixed = TRUE;
	sp->block_size = minblk;
	sp->tstat.mt_blksize = minblk;
	sp->count_max = UINT_MAX;
  } else {
	/* Variable block length. */
	sp->tfixed = FALSE;
	sp->block_size = 1;
	sp->tstat.mt_blksize = 0;
	sp->count_max = maxblk == 0 ? UINT_MAX : maxblk;
  }

  /* SCSI modesense. */
  if (scsi_simple(SCSI_MDSENSE, 255) != SENSE_NO_SENSE) return(EIO);

  /* Write protected? */
  sp->state &= ~S_RDONLY;
  if (buf[2] & 0x80) sp->state |= S_RDONLY;

  /* Density and block size. */
  if (buf[3] >= 8) {
	printf("%s: density 0x%02x, nblocks %lu, block len ",
		s_name(),
		buf[4],
		b2h24(buf + 4 + 1));
	printf(sp->tfixed ? "%lu\n" : "variable\n", b2h24(buf + 4 + 5));
  }

  sp->state |= S_PRESENT|S_READY;
  return(OK);
}


/*===========================================================================*
 *				s_transfer				     *
 *===========================================================================*/
PRIVATE int s_transfer(proc_nr, opcode, position, iov, nr_req)
int proc_nr;			/* process doing the request */
int opcode;			/* DEV_GATHER or DEV_SCATTER */
off_t position;			/* offset on device to read or write */
iovec_t *iov;			/* pointer to read or write request vector */
unsigned nr_req;		/* length of request vector */
{
  struct scsi *sp = s_sp;
  iovec_t *iop, *iov_end = iov + nr_req;
  int key;
  unsigned nbytes, dma_count;
  vir_bytes addr, size;
  phys_bytes dma_phys;
  phys_bytes last_phys;
  unsigned last_count;
  unsigned long block;
  unsigned long dv_size = cv64ul(s_dv->dv_size);
  phys_bytes user_base = proc_vir2phys(proc_addr(proc_nr), 0);

  rq->opcode = opcode;
  rq->retry = 2;

  while (nr_req > 0) {
	/* Probe the device if it isn't ready. */
	if (!(sp->state & S_READY) && scsi_probe() != OK) return(EIO);

	show_iov(iov, nr_req);

	/* How many bytes to transfer? */
	nbytes = 0;
	for (iop = iov; iop < iov_end; iop++) nbytes += iop->iov_size;

	switch (sp->devtype) {
	case SCSI_DEVCDROM:
	case SCSI_DEVWORM:
	case SCSI_DEVDISK:
	case SCSI_DEVOPTICAL:
		/* Which block on disk and how close to EOF? */
		if (position >= dv_size) return(OK);	/* EOF */
		if (position + nbytes > dv_size) nbytes = dv_size - position;
		rq->position = add64ul(s_dv->dv_base, position);

		if ((nbytes % sp->block_size) != 0
				|| rem64u(rq->position, sp->block_size) != 0) {
			/* Not on a device block boundary.  CD-ROM? */
			return(s_rdcdrom(proc_nr, opcode, position, iov,
								nr_req));
		}
		break;

	case SCSI_DEVTAPE:
		if ((nbytes % sp->block_size) != 0) return(EINVAL);

		/* Old error condition? */
		if (sp->tstat.mt_dsreg == DS_ERR) return(EIO);

		if (opcode == DEV_GATHER && sp->at_eof) return(OK);
		break;

	default:
		return(EIO);
	}

	/* Construct a DMA scatter/gather vector from the I/O vector. */
	rq->count = 0;
	rq->dmaptr = rq->dmalist;
	for (iop = iov; iop < iov_end; iop++) {
		addr = iop->iov_addr;
		size = iop->iov_size;

		while (size > 0) {
			/* DMA addresses. */
			dma_phys = user_base + addr;
			dma_count = size;

			/* Several constraints... */
			if (rq->count + dma_count > nbytes)
				dma_count = nbytes - rq->count;
			if (rq->count + dma_count > sp->count_max)
				dma_count = sp->count_max - rq->count;

			if (rq->count > 0 && dma_phys == last_phys) {
				/* Two blocks are adjacent! */
				h2b24(rq->dmaptr[-1].datalen,
					(u32_t) (last_count += dma_count));
			} else
			if (rq->dmaptr < rq->dmalimit
				&& (rq->count == 0
					|| DMA_CHECK(last_phys, dma_phys))
			) {
				/* New scatter/gather entry. */
				h2b24(rq->dmaptr->dataptr, dma_phys);
				h2b24(rq->dmaptr->datalen,
					(u32_t) (last_count = dma_count));
				rq->dmaptr++;
			} else {
				/* End of DMA vector, or addresses not
				 * compatible.
				 */
				goto dma_vec_done;
			}
			last_phys = dma_phys + dma_count;

			/* Update counters. */
			rq->count += dma_count;
			addr += dma_count;
			size -= dma_count;

			if (rq->count == nbytes) goto dma_vec_done;
			if (rq->count == sp->count_max) goto dma_vec_done;
		}
	}
  dma_vec_done:

	show_req();

	switch (sp->devtype) {
	case SCSI_DEVCDROM:
	case SCSI_DEVWORM:
	case SCSI_DEVDISK:
	case SCSI_DEVOPTICAL:
		/* A read or write SCSI command for a random access device. */
		block = div64u(rq->position, sp->block_size);

		if (block < (1L << 21)) {
			/* We can use a group 0 command for small disks. */
			group0();
			rq->ccb.opcode = CCB_SCATTER;
			ccb_cmd0(rq).scsi_op = opcode == DEV_SCATTER
						? SCSI_WRITE : SCSI_READ;
			h2b24(ccb_cmd0(rq).lba, block);
			ccb_cmd0(rq).nblocks = rq->count / sp->block_size;
		} else {
			/* Large disks require a group 1 command. */
			group1();
			rq->ccb.opcode = CCB_SCATTER;
			ccb_cmd1(rq).scsi_op = opcode == DEV_SCATTER
						? SCSI_WRITE1 : SCSI_READ1;
			h2b32(ccb_cmd1(rq).lba, block);
			h2b16(ccb_cmd1(rq).nblocks, rq->count / sp->block_size);
		}

		key = scsi_command(0L, 0);

		if (key == SENSE_NO_SENSE) {
			/* fine */;
		} else
		if (key == SENSE_UNIT_ATT || key == SENSE_ABORTED_CMD) {
			/* Check condition?  Bus reset most likely. */
			/* Aborted command?  Maybe retrying will help. */
			if (--rq->retry > 0) continue;
			return(EIO);
		} else
		if (key == SENSE_RECOVERED) {
			/* Disk drive managed to recover from a read error. */
			printf("%s: soft read error at block %lu (recovered)\n",
				s_name(), b2h32(ccb_sense(rq).info));
			key = SENSE_NO_SENSE;
			break;
		} else {
			/* A fatal error occurred, bail out. */
			return(EIO);
		}
		break;

	case SCSI_DEVTAPE:
		/* A read or write SCSI command for a sequential access device.
		 */
		group0();
		rq->ccb.opcode = CCB_SCATTER;
		ccb_cmd0(rq).scsi_op = opcode == DEV_SCATTER
						? SCSI_WRITE : SCSI_READ;
		ccb_cmd0(rq).fixed = sp->tfixed;
		h2b24(ccb_cmd0(rq).trlength, rq->count / sp->block_size);

		key = scsi_command(0L, 0);

		if (key != SENSE_NO_SENSE) {
			/* Either near/at EOF or EOM, or an I/O error. */

			if (sense_eof(key) || sense_eom(key)) {
				/* Not an error, but near/at EOF or EOM.  The
				 * residual tells how much has not been read.
				 */
				rq->count -= sp->tstat.mt_resid
							* sp->block_size;

				if (opcode == DEV_SCATTER
					&& sense_key(key) == SENSE_NO_SENSE
				) {
					/* Early warning, ignore. */
					sp->tstat.mt_dsreg = DS_OK;
				} else {
					/* EOF or EOM. */
					sp->at_eof = TRUE;
					sp->tstat.mt_dsreg = DS_EOF;

					if (sense_eof(key)) {
						/* Went over a filemark. */
						sp->tstat.mt_blkno = - (int)
						  (rq->count / sp->block_size);
						if (!sp->tfixed)
							sp->tstat.mt_blkno = -1;
						sp->tstat.mt_fileno++;
					}
				}
			}
			if (sense_ili(key)) {
				/* Incorrect length on a variable block length
				 * tape.
				 */

				if (sp->tstat.mt_resid <= 0) {
					/* Large block could not be read. */
					return(EIO);
				}
				/* Small block read, this is ok. */
				rq->count -= sp->tstat.mt_resid;
				sp->tstat.mt_dsreg = DS_OK;
			}
			if (key == SENSE_RECOVERED) {
				/* Tape drive managed to recover from an error.
				 */
				printf("%s: soft %s error (recovered)\n",
					s_name(), opcode == DEV_GATHER
							? "read" : "write");
				key = SENSE_NO_SENSE;
				sp->tstat.mt_dsreg = DS_OK;
			}
			if (sp->tstat.mt_dsreg == DS_ERR) {
				/* Error was fatal. */
				return(EIO);
			}
		} else {
			sp->tstat.mt_dsreg = DS_OK;
		}
		if (!sp->tfixed) {
			/* Variable block length tape reads record by record.
			 */
			sp->tstat.mt_blkno++;
		} else {
			/* Fixed length tape, multiple blocks transferred. */
			sp->tstat.mt_blkno += rq->count / sp->block_size;
		}
		sp->need_eof = (opcode == DEV_SCATTER);
		break;
	}

	/* Book the bytes successfully transferred. */
	position += rq->count;
	for (;;) {
		if (rq->count < iov->iov_size) {
			/* Not done with this one yet. */
			iov->iov_addr += rq->count;
			iov->iov_size -= rq->count;
			break;
		}
		rq->count -= iov->iov_size;
		iov->iov_addr += iov->iov_size;
		iov->iov_size = 0;
		if (rq->count == 0) {
			/* The rest is optional, so we return to give FS a
			 * chance to think it over.
			 */
			return(OK);
		}
		iov++;
		nr_req--;
	}
  }
  return(OK);
}


/*===========================================================================*
 *				s_rdcdrom				     *
 *===========================================================================*/
PRIVATE int s_rdcdrom(proc_nr, opcode, position, iov, nr_req)
int proc_nr;			/* process doing the request */
int opcode;			/* DEV_GATHER or DEV_SCATTER */
off_t position;			/* offset on device to read or write */
iovec_t *iov;			/* pointer to read or write request vector */
unsigned nr_req;		/* length of request vector */
{
/* CD-ROM's have a basic block size of 2k.  We could try to set a smaller
 * virtual block size, but many don't support it.  So we use this function.
 */
  struct scsi *sp = s_sp;
  int key;
  unsigned nbytes, offset, count;
  unsigned long block, curblock;
  unsigned long dv_size = cv64ul(s_dv->dv_size);
  phys_bytes user_base = proc_vir2phys(proc_addr(proc_nr), 0);

  /* Only do reads. */
  if (opcode != DEV_GATHER) return(EINVAL);

  rq->retry = 2;
  curblock = -1;

  while (nr_req > 0) {
	/* Number of bytes to transfer. */
	nbytes = iov->iov_size;

	/* Which position on disk and how close to EOF? */
	if (position >= dv_size) return(OK);	/* EOF */
	if (position + nbytes > dv_size) nbytes = dv_size - position;
	rq->position = add64ul(s_dv->dv_base, position);

	block = div64u(rq->position, sp->block_size);
	if (curblock != block) {
		/* Read a block that contains (some of) the bytes wanted. */
		group1();
		rq->ccb.opcode = CCB_INIT;
		ccb_cmd1(rq).scsi_op = SCSI_READ1;
		h2b32(ccb_cmd1(rq).lba, block);
		h2b16(ccb_cmd1(rq).nblocks, 1);
		key = scsi_command(tmp_phys, sp->block_size);

		if (key != SENSE_NO_SENSE) {
			if (key == SENSE_UNIT_ATT && --rq->retry > 0)
				continue;	/* retry */
			return(EIO);
		}
		curblock = block;
	}

	/* Copy the bytes wanted to user space. */
	offset = rem64u(rq->position, sp->block_size);
	count = sp->block_size - offset;
	if (count > nbytes) count = nbytes;
	phys_copy(tmp_phys + offset, user_base + iov->iov_addr,
							(phys_bytes) count);
	position += count;
	iov->iov_addr += count;
	if ((iov->iov_size -= count) == 0) { iov++; nr_req--; }
  }
  return(OK);
}


/*===========================================================================*
 *				s_do_close				     *
 *===========================================================================*/
PRIVATE int s_do_close(dp, m_ptr)
struct driver *dp;
message *m_ptr;
{
  struct scsi *sp;

  if (s_prepare(m_ptr->DEVICE) == NIL_DEV) return(ENXIO);
  sp = s_sp;

  sp->open_ct--;

  /* Disks and such don't make trouble. */
  if (sp->devtype != SCSI_DEVTAPE) return(OK);

  sp->at_eof = FALSE;

  /* Write filemark if writes have been done. */
  if (sp->need_eof && sp->tstat.mt_dsreg != DS_ERR) {
	if (scsi_simple(SCSI_WREOF, 1) != SENSE_NO_SENSE) {
		printf("%s: failed to add filemark\n", s_name());
	} else {
		sp->tstat.mt_dsreg = DS_OK;
		sp->tstat.mt_blkno = 0;
		sp->tstat.mt_fileno++;
	}
  }

  /* Rewind if rewind device. */
  if (s_type == TYPE_T) {
	if (scsi_simple(SCSI_REWIND, 1) != SENSE_NO_SENSE) {
		printf("%s: failed to rewind\n", s_name());
	} else {
		sp->tstat.mt_dsreg = DS_OK;
		sp->tstat.mt_blkno = 0;
		sp->tstat.mt_fileno = 0;
	}
  }
  return(OK);
}


/*===========================================================================*
 *				s_do_ioctl				     *
 *===========================================================================*/
PRIVATE int s_do_ioctl(dp, m_ptr)
struct driver *dp;
message *m_ptr;
{
  struct scsi *sp;

  if (s_prepare(m_ptr->DEVICE) == NIL_DEV) return(ENXIO);
  sp = s_sp;

  /* Ioctls are device specific. */
  switch (sp->devtype) {
  case SCSI_DEVDISK:
  case SCSI_DEVWORM:
  case SCSI_DEVCDROM:
  case SCSI_DEVOPTICAL:
	if (m_ptr->REQUEST == DIOCEJECT) {
		/* Eject disk. */
		if (sp->open_ct > 1) return(EBUSY);

		/* Send a start/stop command with code 2: stop and eject. */
		if (scsi_simple(SCSI_STRTSTP, 2) != SENSE_NO_SENSE)
			return(EIO);
		return(OK);
	}
	/* Call the common code for disks and disk like devices. */
	return(do_diocntl(dp, m_ptr));

  default:
	return(ENOTTY);

  case SCSI_DEVTAPE:
	break;
  }
  /* Further ioctls are for tapes. */

  if (m_ptr->REQUEST == MTIOCTOP) {
	struct mtop op;
	long delta;
	int key;
	byte *buf = tmp_buf;

	/* Basic tape commands: rewind, space, write eof marks, ... */
	if (vir_copy(m_ptr->PROC_NR, (vir_bytes) m_ptr->ADDRESS,
		aha_tasknr, (vir_bytes) &op, sizeof(op)) != OK) return(EINVAL);

	switch(op.mt_op) {
	case MTREW:
	case MTOFFL:
	case MTRETEN:
	case MTFSF:
	case MTFSR:
	case MTBSF:
	case MTBSR:
	case MTEOM:
		/* Write an EOF mark before spacing. */
		if (sp->need_eof && sp->tstat.mt_dsreg != DS_ERR) {
			if (scsi_simple(SCSI_WREOF, 1) != SENSE_NO_SENSE)
				return(EIO);
			sp->tstat.mt_blkno = 0;
			sp->tstat.mt_fileno++;
			sp->need_eof = FALSE;
		}
		sp->at_eof = FALSE;
	}

	switch(op.mt_op) {
	case MTREW:
	case MTOFFL:
	case MTRETEN:
	case MTERASE:
		/* Rewind, Offline, Retension, Erase. */
		switch(op.mt_op) {
		case MTOFFL:
			if (scsi_simple(SCSI_LOADUNLD, 0) != SENSE_NO_SENSE)
				return(EIO);
			sp->state &= ~S_READY;
			break;
		case MTRETEN:
			if (scsi_simple(SCSI_LOADUNLD, 3) != SENSE_NO_SENSE)
				return(EIO);
			break;
		case MTERASE:
			if (scsi_simple(SCSI_REWIND, 0) != SENSE_NO_SENSE)
				return(EIO);
			if (scsi_simple(SCSI_ERASE, 1) != SENSE_NO_SENSE)
				return(EIO);
			/* Rewind once more. */
			/*FALL THROUGH*/
		case MTREW:
			if (scsi_simple(SCSI_REWIND, 0) != SENSE_NO_SENSE)
				return(EIO);
		}
		sp->tstat.mt_dsreg = DS_OK;
		sp->tstat.mt_blkno = 0;
		sp->tstat.mt_fileno = 0;
		break;
	case MTFSF:
	case MTFSR:
	case MTBSF:
	case MTBSR:
		if (sp->tstat.mt_dsreg == DS_ERR) return(EIO);
		group0();
		rq->ccb.opcode = CCB_INIT;
		ccb_cmd0(rq).scsi_op = SCSI_SPACE;
		delta = op.mt_count;
		if (op.mt_op == MTBSR) delta = -delta;
		if (op.mt_op == MTBSF) delta = -delta - 1;
		h2b24(ccb_cmd0(rq).trlength, delta);
		ccb_cmd0(rq).fixed =
				op.mt_op == MTFSR || op.mt_op == MTBSR ? 0 : 1;
		if ((key = scsi_command(0L, 0)) != SENSE_NO_SENSE) {
			if (sense_key(key) != SENSE_NO_SENSE) return(EIO);

			if (sense_eom(key)) {
				/* Banging into end of tape. */
				if (op.mt_op == MTBSF || op.mt_op == MTBSR) {
					/* Backspacing to start of tape. */
					sp->tstat.mt_dsreg = DS_EOF;
					sp->tstat.mt_blkno = 0;
					sp->tstat.mt_fileno = 0;
				} else {
					/* Not forwards please! */
					return(EIO);
				}
			}
			if (sense_eof(key)) {
				/* Reaching a filemark. */
				sp->tstat.mt_dsreg = DS_EOF;
				sp->at_eof = TRUE;
				if (op.mt_op == MTFSR) {
					/* Forwards. */
					sp->tstat.mt_blkno = 0;
					sp->tstat.mt_fileno++;
				} else {
					/* Backwards (bad idea!) */
					sp->tstat.mt_blkno = -1;
					sp->tstat.mt_fileno--;
				}
			}
		} else {
			if (op.mt_op == MTFSR || op.mt_op == MTBSR) {
				sp->tstat.mt_blkno += delta;
			} else {
				sp->tstat.mt_blkno = 0;
				sp->tstat.mt_fileno += delta;
			}
			if (op.mt_op == MTBSF) {
				/* n+1 backwards, and 1 forward. */
				group0();
				rq->ccb.opcode = CCB_INIT;
				ccb_cmd0(rq).scsi_op = SCSI_SPACE;
				h2b24(ccb_cmd0(rq).trlength, 1L);
				ccb_cmd0(rq).fixed = 1;
				if (scsi_command(0L, 0) != SENSE_NO_SENSE)
					return(EIO);
				sp->tstat.mt_fileno++;
			}
			sp->tstat.mt_dsreg = DS_OK;
		}
		break;
	case MTWEOF:
		/* Write EOF marks. */
		if (sp->tstat.mt_dsreg == DS_ERR) return(EIO);
		if (op.mt_count < 0) return(EIO);
		if (op.mt_count == 0) return(OK);
		group0();
		rq->ccb.opcode = CCB_INIT;
		ccb_cmd0(rq).scsi_op = SCSI_WREOF;
		h2b24(ccb_cmd0(rq).trlength, op.mt_count);
		if (scsi_command(0L, 0) != SENSE_NO_SENSE) return(EIO);
		sp->tstat.mt_dsreg = DS_OK;
		sp->tstat.mt_blkno = 0;
		sp->tstat.mt_fileno += op.mt_count;
		sp->need_eof = FALSE;
		break;
	case MTEOM:
		/* Forward space to end of media. */
		if (sp->tstat.mt_dsreg == DS_ERR) return(EIO);
		do {
			group0();
			rq->ccb.opcode = CCB_INIT;
			ccb_cmd0(rq).scsi_op = SCSI_SPACE;
			h2b24(ccb_cmd0(rq).trlength, 0x7FFFFF);
			ccb_cmd0(rq).fixed = 1;
			key = scsi_command(0L, 0);
			sp->tstat.mt_blkno = 0;
			sp->tstat.mt_fileno += 0x7FFFFF;
			if (key != SENSE_NO_SENSE) {
				if (key != SENSE_BLANK_CHECK) return(EIO);
				sp->tstat.mt_fileno -= sp->tstat.mt_resid;
			}
		} while (key == SENSE_NO_SENSE);
		sp->tstat.mt_dsreg = DS_OK;
		break;
	case MTBLKZ:
	case MTMODE:
		/* Select tape block size or tape density. */

		/* Rewind tape. */
		if (scsi_simple(SCSI_REWIND, 0) != SENSE_NO_SENSE)
			return(EIO);

		sp->tstat.mt_dsreg = DS_OK;
		sp->tstat.mt_blkno = 0;
		sp->tstat.mt_fileno = 0;

		if (op.mt_op == MTBLKZ && op.mt_count == 0) {
			/* Request for variable block size mode. */
			sp->tfixed = FALSE;
			sp->block_size = 1;
		} else {
			/* First a modesense to get the current values. */
			if (scsi_simple(SCSI_MDSENSE, 255) != SENSE_NO_SENSE)
				return(EIO);

			/* Must at least have one block descriptor. */
			if (buf[3] < 8) return(EIO);
			buf[0] = 0;
			buf[1] = 0;
			/* buf[2]: buffered mode & speed */
			buf[3] = 8;
			if (op.mt_op == MTMODE)		/* New density */
				buf[4 + 0] = op.mt_count;
			/* buf[4 + 1]: number of blocks */
			buf[4 + 4] = 0;
			if (op.mt_op == MTBLKZ)		/* New block size */
				h2b24(buf + 4 + 5, (long) op.mt_count);

			/* Set the new density/blocksize. */
			if (scsi_simple(SCSI_MDSELECT, 4+8) != SENSE_NO_SENSE)
				return(EIO);
			if (op.mt_op == MTBLKZ) {
				sp->tfixed = TRUE;
				sp->block_size= op.mt_count;
			}
		}
		sp->state &= ~S_READY;
		if (scsi_probe() != OK) return(EIO);
		break;
	default:
		/* Not implemented. */
		return(ENOTTY);
	}
  } else
  if (m_ptr->REQUEST == MTIOCGET) {
	/* Request tape status. */

	if (sp->tstat.mt_dsreg == DS_OK) {
		/* Old error data is never cleared (until now). */
		sp->tstat.mt_erreg = 0;
		sp->tstat.mt_resid = 0;
	}
	if (vir_copy(aha_tasknr, (vir_bytes) &sp->tstat,
		m_ptr->PROC_NR, (vir_bytes) m_ptr->ADDRESS,
		sizeof(sp->tstat)) != OK) return(EINVAL);
  } else {
	/* Not implemented. */
	return(ENOTTY);
  }
  return(OK);
}


/*===========================================================================*
 *				scsi_simple				     *
 *===========================================================================*/
PRIVATE int scsi_simple(opcode, count)
int opcode;				/* SCSI opcode */
int count;				/* count or flag */
{
/* The average group 0 SCSI command with just a simple flag or count. */

  vir_bytes len = 0;	/* Sometimes a buffer is used. */

  group0();
  rq->ccb.opcode = CCB_INIT;
  ccb_cmd0(rq).scsi_op = opcode;

  /* Fill in the count argument at the proper place. */
  switch (opcode) {
  case SCSI_REQSENSE:
  case SCSI_INQUIRY:
  case SCSI_MDSENSE:
  case SCSI_MDSELECT:
	ccb_cmd0(rq).nblocks = count;
	len = count;
	break;

  case SCSI_STRTSTP:
    /* SCSI_LOADUNLD: (synonym) */
	ccb_cmd0(rq).nblocks = count;
	break;

  case SCSI_RDLIMITS:
	len = count;
	break;

  case SCSI_WREOF:
	h2b24(ccb_cmd0(rq).trlength, (long) count);
	break;

  case SCSI_REWIND:
  case SCSI_ERASE:
	ccb_cmd0(rq).fixed = count;
	break;
  }
  return(scsi_command(tmp_phys, len));
}


/*===========================================================================*
 *				group0					     *
 *===========================================================================*/
PRIVATE void group0()
{
  /* Prepare the ccb for a group 0 SCSI command. */

  rq->ccb.cmdlen = sizeof(cdb0_t);

  /* Clear cdb to zeros the ugly way. */
  * (u32_t *) (rq->ccb.cmd + 0) = 0;
  * (u16_t *) (rq->ccb.cmd + 4) = 0;
}


/*===========================================================================*
 *				group1					     *
 *===========================================================================*/
PRIVATE void group1()
{
  rq->ccb.cmdlen = sizeof(cdb1_t);
  * (u32_t *) (rq->ccb.cmd + 0) = 0;
  * (u32_t *) (rq->ccb.cmd + 4) = 0;
  * (u16_t *) (rq->ccb.cmd + 8) = 0;
}


/*===========================================================================*
 *				scsi_command				     *
 *===========================================================================*/
PRIVATE int scsi_command(data, len)
phys_bytes data;
vir_bytes len;
{
/* Execute a SCSI command and return the results.  Unlike most other routines,
 * this routine returns the sense key of a SCSI command instead of OK or EIO.
 */
  struct scsi *sp = s_sp;
  int key;
  message intr_mess;

  rq->ccb.addrcntl = ccb_scid(s_sp->targ) | ccb_lun(s_sp->lun);

  if (rq->ccb.opcode == CCB_SCATTER) {
	/* Device read/write; add checks and use scatter/gather vector. */
	rq->ccb.addrcntl |= rq->opcode==DEV_GATHER ? CCB_INCHECK : CCB_OUTCHECK;
	data = vir2phys(rq->dmalist);
	len = (byte *) rq->dmaptr - (byte *) rq->dmalist;
	if (aha_model == AHA1540) {
		/* A plain 1540 can't do s/g. */
		rq->ccb.opcode = CCB_INIT;
		data = b2h24(rq->dmalist[0].dataptr);
		len = b2h24(rq->dmalist[0].datalen);
	}
  }
  h2b24(rq->ccb.datalen, (u32_t) len);
  h2b24(rq->ccb.dataptr, data);
  dump_scsi_cmd();

  mailbox[0].status = AHA_MBOXSTART;

  outb(AHA_DATAREG, AHACOM_STARTSCSI);  /* hey, you've got mail! */

  /* Wait for the SCSI command to complete. */
  while (mailbox[1].status == AHA_MBOXFREE) {
	/* No mail yet, wait for an interrupt. */
	receive(HARDWARE, &intr_mess);
  }
  mailbox[1].status = AHA_MBOXFREE;	/* free up inbox */

  /* Check the results of the operation. */
  if (rq->ccb.hastat != 0) {
	/* Weird host adapter status. */
	printf("%s: host adapter error 0x%02x%s\n", s_name(), rq->ccb.hastat,
		rq->ccb.hastat == HST_TIMEOUT ? " (Selection timeout)" : "");
	errordump();
	if (sp->devtype == SCSI_DEVTAPE) sp->tstat.mt_dsreg = DS_ERR;
	memset((void *) &ccb_sense(rq), 0, sizeof(sense_t));
	return(SENSE_HARDWARE);
  }

  if (rq->ccb.tarstat != 0) {
	/* A SCSI error has occurred. */
	sense_t *sense = &ccb_sense(rq);

	if (sense->len < 2) {
		/* No additional code and qualifier, zero them. */
		sense->add_code = sense->add_qual = 0;
	}

	/* Check sense data, report error if interesting. */
	if (rq->ccb.tarstat == TST_CHECK) {
		if ((sense->errc & 0x7E) == 0x70) {
			/* Standard SCSI error. */
			key = sense->key;
		} else {
			/* Blame the vendor for any other nonsense. */
			key = SENSE_VENDOR;
		}
	} else {
		if (rq->ccb.tarstat == TST_LUNBUSY) {
			/* Logical unit is too busy to react... */
			key = SENSE_NOT_READY;
		} else {
			/* The adapter shoudn't do this... */
			key = SENSE_HARDWARE;
		}
		memset((void *) sense, 0, sizeof(sense_t));
	}

	if (sense_serious(sense_key(key))) {
		/* Something bad happened. */
		printf("%s: error on command 0x%02x, ", s_name(),
							rq->ccb.cmd[0]);
		if (rq->ccb.tarstat != TST_CHECK) {
			printf("target status 0x%02x\n", rq->ccb.tarstat);
		} else {
			printf("sense key 0x%02x (%s), additional 0x%02x%02x\n",
				sense->key,
				str_scsi_sense[sense_key(key)],
				sense->add_code, sense->add_qual);
		}
		errordump();
	}

	if (sp->devtype == SCSI_DEVTAPE) {
		/* Store details of tape error. */
		sp->tstat.mt_dsreg = DS_ERR;
		sp->tstat.mt_erreg = key;
		sp->tstat.mt_resid = b2h32(sense->info);
	}

	/* Keep only the ILI, EOM and EOF bits of key 0. */
	if (sense_key(key) != SENSE_NO_SENSE) key = sense_key(key);

	return(key);
  }
  return(SENSE_NO_SENSE);
}


/*===========================================================================*
 *				aha_command				     *
 *===========================================================================*/
PRIVATE void aha_command(outlen, outptr, inlen, inptr)
int outlen, inlen;
byte *outptr, *inptr;
{
  /* Send a low level command to the host adapter. */
  int i;

  /* Send command bytes. */
  for (i = 0; i < outlen; i++) {
	while (inb(AHA_STATREG) & AHA_CDF) {}	/* !! timeout */
	outb(AHA_DATAREG, *outptr++);
  }

  /* Receive data bytes. */
  for (i = 0; i < inlen; i++) {
	while (!(inb(AHA_STATREG) & AHA_DF)
		&& !(inb(AHA_INTRREG) & AHA_HACC)) {}  /* !! timeout */
	*inptr++ = inb(AHA_DATAREG);
  }

  /* Wait for command completion. */
  while (!(inb(AHA_INTRREG) & AHA_HACC)) {}	/* !! timeout */
  outb(AHA_CNTLREG, AHA_IRST);		/* clear interrupt */
  if (aha_irq != 0) enable_irq(&aha_hook);

  /* !! should check status register here for invalid command */
}


/*===========================================================================*
 *				aha_reset				     *
 *===========================================================================*/
PRIVATE int aha_reset()
{
  int stat;
  int irq, bus_on, bus_off, tr_speed;
  unsigned sg_max;
  long v;
  static char aha0_env[] = "AHA0", aha_fmt[] = "x:d:d:x";
  byte cmd[5], haidata[4], getcdata[3], extbios[2];
  struct micro_state ms;

  /* Get the configuration info from the environment. */
  v = AHA_BASEREG;
  if (env_parse(aha0_env, aha_fmt, 0, &v, 0x000L, 0x3FFL) == EP_OFF) return 0;
  aha_basereg = v;

  v = 15;
  (void) env_parse(aha0_env, aha_fmt, 1, &v, 2L, 15L);
  bus_on = v;

  v = 1;
  (void) env_parse(aha0_env, aha_fmt, 2, &v, 1L, 64L);
  bus_off = v;

  v = 0x00;
  (void) env_parse(aha0_env, aha_fmt, 3, &v, 0x00L, 0xFFL);
  tr_speed = v;

  /* Reset controller, wait for self test to complete. */
  outb(AHA_CNTLREG, AHA_HRST);
  micro_start(&ms);
  while (((stat = inb(AHA_STATREG)) & (AHA_STST | AHA_DIAGF | AHA_INIT
		| AHA_IDLE | AHA_CDF | AHA_DF)) != (AHA_INIT | AHA_IDLE))
  {
	if (micro_elapsed(&ms) >= AHA_TIMEOUT) {
		printf(
		  "aha0: AHA154x controller not responding, status = 0x%02x\n",
			stat);
		return(0);
	}
  }

  /* Get information about controller type and configuration. */
  cmd[0] = AHACOM_HAINQUIRY;
  aha_command(1, cmd, 4, haidata);

  cmd[0] = AHACOM_GETCONFIG;
  aha_command(1, cmd, 3, getcdata);

  /* First inquiry byte tells what type of board. */
  aha_model = haidata[0];

  /* Unlock the 1540C or 1540CF's mailbox interface.  (This is to keep old
   * drivers from using the adapter if extended features are enabled.)
   */
  if (aha_model >= AHA1540C) {
	cmd[0] = AHACOM_EXTBIOS;	/* get extended BIOS information */
	aha_command(1, cmd, 2, extbios);
	if (extbios[1] != 0) {
		/* Mailbox interface is locked, so unlock it. */
		cmd[0] = AHACOM_MBOX_ENABLE;
		cmd[1] = 0;		/* bit 0 = 0 (enable mailbox) */
		cmd[2] = extbios[1];	/* lock code to unlock mailbox */
		aha_command(3, cmd, 0, 0);
	}
  }

  /* The maximum scatter/gather DMA list length depends on the board model. */
  sg_max = 16;
  if (aha_model == AHA1540) sg_max = 1;		/* 1540 has no s/g */
  if (aha_model >= AHA1540C) sg_max = 255;	/* 1540C has plenty */

  /* Set up the DMA channel. */
  switch (getcdata[0]) {
  case 0x80:		/* channel 7 */
	outb(0xD6, 0xC3);
	outb(0xD4, 0x03);
	break;
  case 0x40:		/* channel 6 */
	outb(0xD6, 0xC2);
	outb(0xD4, 0x02);
	break;
  case 0x20:		/* channel 5 */
	outb(0xD6, 0xC1);
	outb(0xD4, 0x01);
	break;
  case 0x01:		/* channel 0 */
	outb(0x0B, 0x0C);
	outb(0x0A, 0x00);
	break;
  default:
	printf("aha0: AHA154x: strange DMA channel\n");
	return(0);
  }

  /* Get the configured IRQ. */
  switch (getcdata[1]) {
  case 0x40:	irq = 15;	break;
  case 0x20:	irq = 14;	break;
  case 0x08:	irq = 12;	break;
  case 0x04:	irq = 11;	break;
  case 0x02:	irq = 10;	break;
  case 0x01:	irq =  9;	break;
  default:
	printf("aha0: strange IRQ setting\n");
	return(0);
  }

  /* Enable interrupts on the given irq. */
  put_irq_handler(&aha_hook, irq, s_handler);
  aha_irq = irq;
  enable_irq(&aha_hook);

  /* Initialize request related data: Command Control Block, mailboxes.
   * (We want to have the mailboxes initialized early, because the 1540C
   * wants to know it now.)
   */

  /* Init ccb. */
  rq->ccb.senselen = CCB_SENSEREQ;	/* always want sense info */
  h2b24(rq->ccb.linkptr, 0L);		/* never link commands */
  rq->ccb.linkid = 0;
  rq->ccb.reserved[0] = 0;
  rq->ccb.reserved[1] = 0;

  /* Scatter/gather maximum. */
  rq->dmalimit = rq->dmalist + (sg_max < NR_IOREQS ? sg_max : NR_IOREQS);

  /* Outgoing mailbox. */
  mailbox[0].status = AHA_MBOXFREE;
  h2b24(mailbox[0].ccbptr, vir2phys(&rq->ccb));

  /* Incoming mailbox. */
  mailbox[1].status = AHA_MBOXFREE;
  /* mailbox[1].ccbptr filled by adapter after command execution. */

  /* Tell controller where the mailboxes are and how many. */
  cmd[0] = AHACOM_INITBOX;
  cmd[1] = 1;
  h2b24(cmd + 2, vir2phys(mailbox));
  aha_command(5, cmd, 0, 0);

  /* !! maybe sanity check: check status reg for initialization success */

  /* Set bus on, bus off and transfer speed. */
  cmd[0] = AHACOM_BUSON;
  cmd[1] = bus_on;
  aha_command(2, cmd, 0, 0);

  cmd[0] = AHACOM_BUSOFF;
  cmd[1] = bus_off;
  aha_command(2, cmd, 0, 0);

  cmd[0] = AHACOM_SPEED;
  cmd[1] = tr_speed;
  aha_command(2, cmd, 0, 0);

  /* Set SCSI selection timeout. */
  cmd[0] = AHACOM_SETIMEOUT;
  cmd[1] = SCSI_TIMEOUT != 0;		/* timeouts on/off */
  cmd[2] = 0;				/* reserved */
  cmd[3] = SCSI_TIMEOUT / 256;		/* MSB */
  cmd[4] = SCSI_TIMEOUT % 256;		/* LSB */
  aha_command(5, cmd, 0, 0);

  return(1);
}


/*===========================================================================*
 *				s_handler				     *
 *===========================================================================*/
PRIVATE int s_handler(hook)
irq_hook_t *hook;
{
/* Host adapter interrupt, send message to SCSI task and reenable interrupts. */

  if (inb(AHA_INTRREG) & AHA_HACC) {
	/* Simple commands are polled. */
	return 0;
  } else {
	outb(AHA_CNTLREG, AHA_IRST);	/* clear interrupt */
	interrupt(aha_tasknr);
	return 1;
  }
}


/*===========================================================================*
 *				h2b16					     *
 *===========================================================================*/
PRIVATE void h2b16(b, h)
big16 b;
U16_t h;
{
/* Host byte order to Big Endian conversion. */
  b[0] = h >> 8;
  b[1] = h >> 0;
}


/*===========================================================================*
 *				h2b24					     *
 *===========================================================================*/
PRIVATE void h2b24(b, h)
big24 b;
u32_t h;
{
  b[0] = h >> 16;
  b[1] = h >>  8;
  b[2] = h >>  0;
}


/*===========================================================================*
 *				h2b32					     *
 *===========================================================================*/
PRIVATE void h2b32(b, h)
big32 b;
u32_t h;
{
  b[0] = h >> 24;
  b[1] = h >> 16;
  b[2] = h >>  8;
  b[3] = h >>  0;
}


/*===========================================================================*
 *				b2h16					     *
 *===========================================================================*/
PRIVATE u16_t b2h16(b)
big16 b;
{
  return  ((u16_t) b[0] << 8)
	| ((u16_t) b[1] << 0);
}


/*===========================================================================*
 *				b2h24					     *
 *===========================================================================*/
PRIVATE u32_t b2h24(b)
big24 b;
{
  return  ((u32_t) b[0] << 16)
	| ((u32_t) b[1] <<  8)
	| ((u32_t) b[2] <<  0);
}


/*===========================================================================*
 *				b2h32					     *
 *===========================================================================*/
PRIVATE u32_t b2h32(b)
big32 b;
{
  return  ((u32_t) b[0] << 24)
	| ((u32_t) b[1] << 16)
	| ((u32_t) b[2] <<  8)
	| ((u32_t) b[3] <<  0);
}


#if AHA_DEBUG & 2
/*===========================================================================*
 *				errordump				     *
 *===========================================================================*/
PRIVATE void errordump()
{
  int i;

  printf("aha ccb dump:");
  for (i = 0; i < sizeof(rq->ccb); i++) {
	if (i % 26 == 0) printf("\n");
	printf(" %02x", ((byte *) &rq->ccb)[i]);
  }
  printf("\n");
}
#endif /* AHA_DEBUG & 2 */


#if AHA_DEBUG & 4
/*===========================================================================*
 *				show_iov				     *
 *===========================================================================*/
PRIVATE void show_iov(iov, nr_req)
iovec_t *iov;
unsigned nr_req;
{
  printf("iov:");
  while (nr_req > 0) {
	printf(" [%lx,%u]",
		(unsigned long) iov->iov_addr, (unsigned) iov->iov_size);
	iov++;
	nr_req--;
  }
  printf("\n");
}


/*===========================================================================*
 *				show_req				     *
 *===========================================================================*/
PRIVATE void show_req()
{
  dma_t *dmap;
  unsigned count, len;

  dmap = rq->dmalist;
  count = rq->count;

  printf("%lu:%u", cv64ul(rq->position), count);

  while (count > 0) {
	printf(" (%lx,%lu)", b2h24(dmap->dataptr), len = b2h24(dmap->datalen));
	dmap++;
	count -= len;
  }
  printf("\n");
}
#endif /* AHA_DEBUG & 4 */


#if AHA_DEBUG & 8
/*===========================================================================*
 *				dump_scsi_cmd				     *
 *===========================================================================*/
PRIVATE void dump_scsi_cmd()
{
  int i;

  printf("scsi cmd:");
  for (i = 0; i < rq->ccb.cmdlen; i++) printf(" %02x", rq->ccb.cmd[i]);
  printf("\n");
}
#endif /* AHA_DEBUG & 8 */


/*============================================================================*
 *				s_geometry				      *
 *============================================================================*/
PRIVATE void s_geometry(entry)
struct partition *entry;
{
/* The geometry of a SCSI drive is a complete fake, the Adaptec onboard BIOS
 * makes the drive look like a regular drive on the outside.  A DOS program
 * takes a logical block address, computes cylinder, head and sector like the
 * BIOS int 0x13 call expects, and the Adaptec turns this back into a block
 * address again.  The only reason we care is because some idiot put cylinder,
 * head and sector numbers in the partition table, so fdisk needs to know the
 * geometry.
 */
  u64_t size = s_sp->part[0].dv_size;
  unsigned heads, sectors;

  if (cmp64ul(size, 1024L * 64 * 32 * 512) < 0) {
	/* Small drive. */
	heads = 64;
	sectors = 32;
  } else {
	/* Assume that this BIOS is configured for large drives. */
	heads = 255;
	sectors = 63;
  }
  entry->cylinders = div64u(size, SECTOR_SIZE) / (heads * sectors);
  entry->heads = heads;
  entry->sectors = sectors;
}
#endif /* ENABLE_AHA1540_SCSI */
