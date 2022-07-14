/*
 *      install.c: install functions for USB storage under TOS/FreeMiNT
 *      
 *      Based on the assembler code by David Galvez (2010-2012), which
 *      was itself extracted from the USB disk utility assembler code by
 *      Didier Mequignon (2005-2009).
 *
 *      Copyright 2014 Roger Burrows <rfburrows@ymail.com>
 *      
 *      This program is free software; you can redistribute it and/or modify
 *      it under the terms of the GNU General Public License as published by
 *      the Free Software Foundation; either version 2 of the License, or
 *      (at your option) any later version.
 *      
 *      This program is distributed in the hope that it will be useful,
 *      but WITHOUT ANY WARRANTY; without even the implied warranty of
 *      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *      GNU General Public License for more details.
 *      
 *      You should have received a copy of the GNU General Public License
 *      along with this program; if not, write to the Free Software
 *      Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 *      MA 02110-1301, USA.
 */
#ifdef TOSONLY
#include <gem.h>
#endif
#include "../../global.h"
#include "xhdi.h"					/* for USB_PUN_XXX */

/*
 * the following should be in headers for other modules
 */
#define RWFLAG			0x0001		/* for Rwabs() 'mode' */
#define NOTRANSLATE		0x0008

#define bootdev			*(short *)0x446
#define drvbits			*(unsigned long *)0x4C2
#define DEFAULT_SECTOR_SIZE 2048						//usb_storage.c
unsigned long usb_stor_read(long device,unsigned long blknr,
		unsigned long blkcnt,void *buffer);				//usb_storage.c
unsigned long usb_stor_write(long device,unsigned long blknr,
		unsigned long blkcnt,const void *buffer);		//usb_storage.c

extern USB_PUN_INFO pun_usb;							//xhdi.c
extern unsigned long my_drvbits;						//xhdi.c
extern long dl_maxdrives;
#if TOSONLY
extern short MagiC;
#endif
extern long XHDOSLimits(ushort which, ulong limit);

extern BPB* usb_global_bpb;

/*
 * end of stuff for other headers
 */


/*
 * these should be in e.g. install.h
 */
long install_usb_stor(long dev_num,unsigned long part_type,unsigned long part_offset,
					unsigned long part_size,char *vendor,char *revision,char *product);
long uninstall_usb_stor(long logdrv);
BPB *usb_getbpb(long logdrv);
long usb_mediach(long logdrv);
long usb_rwabs(long logdrv,long start,long count,void *buffer,long mode);
void usb_build_bpb(BPB *bpbptr,void *bs);


/*
 * extended FAT12/FAT16 bootsector
 */
typedef struct {
  /*   0 */	uchar bra[2];
  /*   2 */	uchar loader[6];
  /*   8 */	uchar serial[3];
  /*   b */	uchar bps[2];		/* bytes per sector */
  /*   d */	uchar spc;		/* sectors per cluster */
  /*   e */	uchar res[2];		/* number of reserved sectors */
  /*  10 */	uchar fat;		/* number of FATs */
  /*  11 */	uchar dir[2];		/* number of DIR root entries */
  /*  13 */	uchar sec[2];		/* total number of sectors */
  /*  15 */	uchar media;		/* media descriptor */
  /*  16 */	uchar spf[2];		/* sectors per FAT */
  /*  18 */	uchar spt[2];		/* sectors per track */
  /*  1a */	uchar sides[2];		/* number of sides */
  /*  1c */	uchar hid[4];		/* number of hidden sectors (earlier: 2 bytes) */
  /*  20 */	uchar sec2[4];		/* total number of sectors (if not in sec) */
  /*  24 */	uchar ldn;		/* logical drive number */
  /*  25 */	uchar dirty;		/* dirty filesystem flags */
  /*  26 */	uchar ext;		/* extended signature */
  /*  27 */	uchar serial2[4];	/* extended serial number */
  /*  2b */	uchar label[11];	/* volume label */
  /*  36 */	uchar fstype[8];	/* file system type */
  /*  3e */	uchar data[0x1c0];
  /* 1fe */	uchar cksum[2];
} FAT16_BS;

/*
 * various text values access as longs
 */
#define AHDI		0x41484449L		/* 'AHDI' */
#define GEM		0x0047454dL		/* '\0GEM' */
#define BGM		0x0042474dL		/* '\0BGM' */
#define RAW		0x00524157L		/* '\0RAW' */
#define F32		0x00463332L		/* '\0F32' */
#define MINIX		0x00004481L
#define LNX		0x00004483L

/*
 * DOS & Linux partition ids that we support
 */
#define FAT12 		0x01 /* FAT12 */
#define FAT16LESS32	0x04 /* FAT16 less than 32MB */
#define FAT16		0x06 /* FAT16 */
#define FAT16LBA	0x0e /* FAT16 W95 LBA */
#define FAT32		0x0b /* FAT32 W95 */
#define FAT32LBA	0x0c /* FAT32 W95 LBA */
#define OLDLINUX	0x81 /* OLD LINUX */
#define LINUX		0x83 /* LINUX */
static const unsigned long valid_dos[] = { FAT12, FAT16LESS32, FAT16, FAT16LBA, FAT32, FAT32LBA, OLDLINUX, LINUX, 0 };

/*
 *	local function prototypes
 */
static unsigned long getilong(uchar *byte);
static unsigned short getiword(uchar *byte);
static long valid_drive(long logdrv);

//#define DEBUGGING_ROUTINES
#ifdef DEBUGGING_ROUTINES
static void display_error(long dev_num,char *vendor,char *revision,char *product,char *msg);
static void display_installed(long dev_num,char *vendor,char *revision,char *product,int logdrv);
static void display_usb(long dev_num,char *vendor,char *revision,char *product);
#endif

/*
 *	convert Intel (little-endian) values to big-endian
 */
static unsigned short getiword(uchar *byte)
{
	union {
		char c[2];
		unsigned short w;
	} u;

	u.c[1] = *byte++;
	u.c[0] = *byte;

	return u.w;
}

static unsigned long getilong(uchar *byte)
{
	union {
		char c[4];
		unsigned long l;
	} u;

	u.c[3] = *byte++;
	u.c[2] = *byte++;
	u.c[1] = *byte++;
	u.c[0] = *byte;

	return u.l;
}

/*
 *	build the BPB from the boot sector
 *
 *	we set 'clsizb' to zero, meaning this partition is unavailable, for
 *	any of the following reasons:
 *	1. too many clusters for the current TOS version
 *	2. logical sectors too large for the current TOS version
 */
void usb_build_bpb(BPB *bpbptr, void *bs)
{
	bpbptr->clsizb = 0;	/* default to invalid size */

	/*
	 * check for valid BPB
	 */
	if (bs) {
		FAT16_BS *dosbs = (FAT16_BS*)bs;
		unsigned short bps, spf;
		unsigned long res, sectors, clusters;

		if (dosbs->spc == 0) {
			return;
		}

		bps = getiword(dosbs->bps);				/* bytes per sector */

		if (bps == 0) {
			return;
		}

		bpbptr->recsiz = bps;
		bpbptr->rdlen = 0;
		bpbptr->clsiz = dosbs->spc;				/* sectors per cluster */
		bpbptr->rdlen = (32L*getiword(dosbs->dir)) / bps;/* root dir len, rounded up */

		res = getiword(dosbs->res);				/* reserved sectors */
		if (res == 0)							/* shouldn't happen:          */
			res = 1;							/*  we use the TOS assumption */
		spf = getiword(dosbs->spf);				/* sectors per fat */
		bpbptr->fsiz = spf;
		bpbptr->fatrec = res + spf;				/* start of fat #2 */
		bpbptr->datrec = res + dosbs->fat*spf + bpbptr->rdlen;	/* start of data */

		sectors = getiword(dosbs->sec);			/* old sector count */
		if (!sectors) 							/* zero => more than 65535, */
			sectors = getilong(dosbs->sec2);	/*  so use new sector count */

		clusters = (sectors - bpbptr->datrec) / dosbs->spc;	/* number of clusters */

		if (clusters > MAX_FAT16_CLUSTERS) {		/* FAT32 doesn't have a BPB */
		/*
		 * Mark clsizb as non-zero, otherwise usb_rwabs()
		 * would think it's an unavailable partition.
		 */
			bpbptr->clsizb = -1;
			return;
		}

		bpbptr->numcl = clusters;
	}

	/*
	 * Do this here and we can re-evaluate the BPB when XHDI changes.
	 */
	if (bpbptr->recsiz > XHDOSLimits(XH_DL_SECSIZ,0)) {
		bpbptr->clsizb = 0;
		return;
	}

	if (bpbptr->numcl > XHDOSLimits(XH_DL_CLUSTS,0)) {
		bpbptr->clsizb = 0;
		return;
	}

	if (bpbptr->numcl > XHDOSLimits(XH_DL_CLUSTS12,0))
		bpbptr->bflags = 1;				/* FAT16 */
	else 
		bpbptr->bflags = 0;				/* FAT12 */

	bpbptr->clsizb = bpbptr->clsiz * bpbptr->recsiz;
}

#ifdef DEBUGGING_ROUTINES
static void display_usb(long dev_num,char *vendor,char *revision,char *product)
{
	c_conws("USB ");
	c_conout('0'+dev_num);		/* we assume dev_num <= 9 */
	c_conws(".0 ");
	c_conws(vendor);
	c_conout(' ');
	c_conws(revision);
	c_conout(' ');
	c_conws(product);
}

static void display_error(long dev_num,char *vendor,char *revision,char *product,char *msg)
{
	display_usb(dev_num,vendor,revision,product);
	c_conws(": ");
	c_conws(msg);
	c_conws("\r\n");
}

static void display_installed(long dev_num,char *vendor,char *revision,char *product,int logdrv)
{
#ifdef TOSONLY
	char string[128];
	char drv[2];

	memset(string, 0, 128);

	drv[0] = ('A' + logdrv);
	drv[1] = 0;

	strcat(string, "[1][Installed|");
	strcat(string, vendor);
	strcat(string, " ");
	strcat(string, product);
	strcat(string, "|as drive ");
	strcat(string, drv);
	strcat(string, ":][OK]");
	form_alert(1, string);
#else
	display_usb(dev_num,vendor,revision,product);
	c_conws(": installed as drive ");
	c_conout(logdrv<26?'A'+logdrv:'1'+(logdrv-26));	/* drives are A:->Z:, 1:->6: */
	c_conws("\r\n");
#endif
}
#endif

/*
 *	test for valid DOS or GEMDOS partition
 *	returns 1 if valid
 */
static int valid_partition(unsigned long type)
{
	const unsigned long *valid;

	for (valid = valid_dos; *valid; valid++)
		if (type == *valid)
			return 1;

	type &= 0x00ffffffL;

#ifdef DEBUGGING_ROUTINES
	c_conws("Found partition ");
	hex_long(type);
	c_conws("\r\n");
#endif

	if ((type == GEM) || (type == BGM) || (type == RAW))
		return 1;
#ifdef TOSONLY
	if (MagiC >= 0x610 && type == F32)
		return 1;
#else
	if (type == F32)
		return 1;
#endif
	return 0;
}

#ifdef TOSONLY
#define restore_old_state(ret) { if (ret) SuperToUser(ret); }
#else
#define restore_old_state(ret)
#endif

/*
 *  install the new device
 *
 *	returns -1 for error, otherwise the drive number assigned
 */
long install_usb_stor(long dev_num,unsigned long part_type,unsigned long part_offset,
			unsigned long part_size,char *vendor,char *revision,char *product)
{
	char boot_sector[DEFAULT_SECTOR_SIZE];
	int logdrv;
	long mask;

#ifdef TOSONLY
	/* goto supervisor mode because of drvbits & handlers */
	long ret = 0;
	if (!Super(1L))
		ret = Super(0L);
#endif

	/*
	 * check input parameters
	 */
	if (dev_num > PUN_DEV) {
		restore_old_state(ret);
#ifdef DEBUGGING_ROUTINES
		display_error(dev_num,vendor,revision,product,"invalid device number");
#endif
		return -1L;
	}
	/* superfloppy-type devices will have a part_type of 0 */
	if (!valid_partition(part_type) && (part_type != 0)) {
		restore_old_state(ret);
#ifdef DEBUGGING_ROUTINES
		display_error(dev_num,vendor,revision,product,"invalid partition type");
#endif
		return -1L;
	}

	/*
	 * find first free non-floppy drive
	 */
	for (logdrv = 'C'-'A', mask = (1L<<logdrv); logdrv < dl_maxdrives; logdrv++, mask<<=1)
		if (!(drvbits&mask))
			break;
	if (logdrv >= dl_maxdrives) {
		restore_old_state(ret);
#ifdef DEBUGGING_ROUTINES
		display_error(dev_num,vendor,revision,product,"no drives available");
#endif
		return -1L;
	}

	/*
	 * read in the first sector, which we'll get BPB info from
	 */
	if (usb_stor_read(dev_num,part_offset,1,boot_sector) != 1) {
		restore_old_state(ret);
#ifdef DEBUGGING_ROUTINES
		display_error(dev_num,vendor,revision,product,"boot sector not readable");
#endif
		return -1L;
	}

	/*
	 * update the usb_pun_info structure
	 */
	pun_usb.puns++;
	pun_usb.pun[logdrv] = dev_num | PUN_USB;
	pun_usb.partition_start[logdrv] = part_offset;

	part_type <<= 8;					/* for XHDI, make it a 3-character string */
	if (part_type&0xff000000L)		    				/* i.e. GEM/BGM/RAW */
		pun_usb.ptype[logdrv] = part_type;				/* e.g. 0x47454d00 */
	else 
		pun_usb.ptype[logdrv] = 0x00440000L | part_type;/* e.g. 0x00440600 */

	pun_usb.psize[logdrv] = part_size;
	pun_usb.flags[logdrv] = CHANGE_FLAG;
	usb_build_bpb(&pun_usb.bpb[logdrv],(FAT16_BS *)boot_sector);

	/* For superfloppy-type devices update the "partition" size & type from the
	 * boot sector / BPB. Superfloppy support taken from the Lightning VME
	 * driver by Ingo Uhlemann/Christian Zietz.
	 */
	if (part_type == 0) {
		unsigned long sectors;
		FAT16_BS *dos_bs = (FAT16_BS *)boot_sector;
		sectors = getiword(dos_bs->sec);
		if (!sectors)
			sectors = getilong(dos_bs->sec2);
		pun_usb.psize[logdrv] = sectors;
		/* fake partition type according to FAT16/FAT12 */
		pun_usb.ptype[logdrv] = pun_usb.bpb[logdrv].bflags?0x00440600L:0x00440100L;
	}

	/*
	 * update drive bits etc
	 */
	drvbits |= 1L << logdrv;
	my_drvbits |= 1L << logdrv;			/* used for XHDI */
	if (logdrv == 'C'-'A') {			/* if drive C, make it the boot drive */
		//bootdev = logdrv;				/* (is this correct?)                 */
		d_setdrv(logdrv);
	}

	/* Force media change, the recommended AHDI way..... */
	{
		char tmpname[16];
		char drv[2];
		long fh;

		drv[0] = ('A' + logdrv);
		drv[1] = 0;

		memset(tmpname, 0, sizeof(tmpname));
		strcat(tmpname, drv);
		strcat(tmpname, ":\\test");
		fh = f_open(tmpname, 0);
		if (fh < 0) {
			/* don't worry about it for now, unless it presents problems. */
		} else {
			f_close(fh);
		}
	}

	restore_old_state(ret);

#ifdef DEBUGGING_ROUTINES
	display_installed(dev_num,vendor,revision,product,logdrv);
#endif

	return logdrv;
}

long uninstall_usb_stor(long logdrv)
{
	if ((logdrv < 0) || (logdrv >= dl_maxdrives))
		return -1L;

	pun_usb.puns--;
	pun_usb.pun[logdrv] = 0xff;
	pun_usb.partition_start[logdrv] = 0L;	/* probably unnecessary */

#ifdef TOSONLY
	/* goto supervisor mode because of drvbits */
	long ret = 0;
	if (!Super(1L))
		ret = Super(0L);
#endif
	drvbits &= ~(1L<<logdrv);
	my_drvbits &= ~(1L<<logdrv);

	changedrv(logdrv);

	restore_old_state(ret);

	return 0L;
}

/*
 *	the following functions are called from the various intercepts
 */

/*
 *	validity check (paranoia, should already have been done by the caller)
 */
static long valid_drive(long logdrv)
{
	if ((logdrv < 0) || (logdrv >= dl_maxdrives))
		return 0;

	if (pun_usb.pun[logdrv] & PUN_VALID)	/* means invalid ... */
		return 0;

	if (!(pun_usb.pun[logdrv] & PUN_USB))
		return 0;

	return 1;
}

/*
 *	return BPB pointer for specified drive
 */
BPB *usb_getbpb(long logdrv)
{
	unsigned long type;
	BPB *bpbptr;

	if (!valid_drive(logdrv))
		return NULL;

	type = pun_usb.ptype[logdrv] >> 8;

	/*
	 * We allow the partition through to get a drive letter, but stop
	 * access to the drives BPB as there isn't one.
	 */
	if ((type == LNX) || (type == MINIX) || (type == RAW)  || (type == F32)) {
		bpbptr = NULL;
		goto exit;
	}

	/* Make a copy of the BPB in globally accessible memory.
	 * Taken from the Lightning VME driver by Ingo Uhlemann/Christian Zietz.
	 */
	if (usb_global_bpb != NULL) {
		usb_global_bpb[logdrv] = pun_usb.bpb[logdrv];
		bpbptr = &(usb_global_bpb[logdrv]);
	} else {
		/* Fall back to using protected kernel memory */
		bpbptr = &pun_usb.bpb[logdrv];
	}

 	/*
 	 * ensure that filesystem inside partition is suitable for TOS
	 * (paranoia rules).
 	 */
	if (bpbptr->clsizb == 0) {
		bpbptr = NULL;
	}
exit:
	/* clear the media change flag */
	pun_usb.flags[logdrv] &= ~CHANGE_FLAG;

	return bpbptr;
}

/*
 *	perform Rwabs()
 */
long usb_rwabs(long logdrv,long start,long count,void *buffer,long mode)
{
	long rc;
	long physdev;				/* physical device */

	if (count == 0L)
		return 0;

	if ((start < 0L) || (count < 0L) || !buffer)
		return EBADR;			/* same as EBADRQ */

	/* 
	 * Tell the user that the media has changed, so call getbpb first !
	 */
	if (mode & NOTRANSLATE) {		/* if physical mode, the rwabs intercept */
		physdev = logdrv & PUN_DEV;	/*  has already allowed for floppies     */
	} else {
		BPB *bpbptr;
		unsigned short phys_per_log;	/* physical sectors per logical sector */
		if (!valid_drive(logdrv))
			return ENXIO;		/* same as EDRIVE */

		if (pun_usb.flags[logdrv] & CHANGE_FLAG)
			return ECHMEDIA;

		bpbptr = &pun_usb.bpb[logdrv];
		if (!bpbptr->clsizb)
			return ENXIO;

		phys_per_log = bpbptr->recsiz / 512;

		start = start * phys_per_log;
		count = count * phys_per_log;

		if ((start+count) > pun_usb.psize[logdrv])
			return EBADR;

		start += pun_usb.partition_start[logdrv];
		physdev = pun_usb.pun[logdrv] & PUN_DEV;
	}

	/*
	 * set up for read or write
	 */
	if (mode&RWFLAG)
		rc = usb_stor_write(physdev,start,count,buffer);
	else 
		rc = usb_stor_read(physdev,start,count,buffer);

	return (rc==count) ? 0 : rc;
}

/*
 *	perform Mediach()
 */
long usb_mediach(long logdrv)
{
	long rc;

	if (!valid_drive(logdrv))
		return ENXIO;

	rc = (pun_usb.flags[logdrv] & CHANGE_FLAG) ? 2 : 0;
	pun_usb.flags[logdrv] &= ~CHANGE_FLAG;

	return rc;
}
