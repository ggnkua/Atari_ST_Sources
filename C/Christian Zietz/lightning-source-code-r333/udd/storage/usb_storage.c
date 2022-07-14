/*
 * Modified for the FreeMiNT USB subsystem by David Galvez. 2010-2019
 * Modified for Atari by Didier Mequignon 2009
 *
 * Most of this source has been derived from the Linux USB
 * project:
 *   (c) 1999-2002 Matthew Dharm (mdharm-usb@one-eyed-alien.net)
 *   (c) 2000 David L. Brown, Jr. (usb-storage@davidb.org)
 *   (c) 1999 Michael Gee (michael@linuxspecific.com)
 *   (c) 2000 Yggdrasil Computing, Inc.
 *
 *
 * Adapted for U-Boot:
 *   (C) Copyright 2001 Denis Peter, MPL AG Switzerland
 *
 * For BBB support (C) Copyright 2003
 * Gary Jennejohn, DENX Software Engineering <garyj@denx.de>
 *
 * BBB support based on /sys/dev/usb/umass.c from
 * FreeBSD.
 *
 * This file is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston,
 * MA 02111-1307 USA
 *
 */

/* Note:
 * Currently only the CBI transport protocoll has been implemented, and it
 * is only tested with a TEAC USB Floppy. Other Massstorages with CBI or CB
 * transport protocoll may work as well.
 */

#if 0
# define DEV_DEBUG	1
#endif

#ifndef TOSONLY
#include "mint/mint.h"
#include "libkern/libkern.h"
#include "mint/mdelay.h"
#else
#include "gem.h"
#endif
#include "../../global.h"

#include "part.h"
#include "scsi.h"
#include "xhdi.h"                   /* for PUN_XXX */

#include "mint/endian.h"

#include "../../usb.h"
#include "../../usb_api.h"
#include "usb_storage.h"

#define MSG_VERSION "1.0"
char *drv_version = MSG_VERSION;

#define MSG_BUILDDATE	__DATE__

#define MSG_BOOT	\
	"\033p USB mass storage class driver " MSG_VERSION " \033q\r\n"

#define MSG_GREET	\
	"Ported, mixed and shaken by David Galvez.\r\n" \
	"Atari partition support by Roger Burrows.\r\n" \
	"SCSIDRV support by Alan Hourihane.\r\n" \
	"Compiled " MSG_BUILDDATE ".\r\n\r\n"

/*
 * Debug section
 */
//#define USB_STOR_DEBUG
//#define BBB_COMDAT_TRACE
//#define BBB_XPORT_TRACE

/****************************************************************************/
/* BEGIN kernel interface */

#ifndef TOSONLY
struct kentry	*kentry;
#else
extern unsigned long _PgmSize;
#endif
struct usb_module_api	*api;

/* END kernel interface */
/****************************************************************************/

/*
 * USB device interface
 */

static long	storage_ioctl		(struct uddif *, short, long);
static long	storage_probe		(struct usb_device *, unsigned int ifnum);
static long	storage_disconnect	(struct usb_device *);

static char lname[] = "USB mass storage class driver\0";

static struct uddif storage_uif = 
{
	0,			/* *next */
	USB_API_VERSION,	/* API */
	USB_DEVICE,		/* class */
	lname,			/* lname */
	"storage",		/* name */
	0,			/* unit */
	0,			/* flags */
	storage_probe,		/* probe */
	storage_disconnect, 	/* disconnect */
	0,			/* resrvd1 */
	storage_ioctl,		/* ioctl */
	0,			/* resrvd2 */
};


/*
 * External prototypes
 */
extern long install_usb_stor	(long dev_num, unsigned long part_type, 
					 unsigned long part_offset, unsigned long part_size, 
					 char *vendor, char *revision, char *product);
extern long uninstall_usb_stor	(long dev_num);
extern long install_xhdi_driver(void);                         //xhdi.c
extern void install_vectors(void);                             //vectors.S
extern void install_scsidrv(void);                             //usb_scsidrv.c
extern long XHDOSLimits(ushort which, ulong limit);
extern void init_polling(void);
#ifdef TOSONLY
extern void SCSIDRV_MediaChange(long dev_num);
extern short InqMagX(void);
#endif

/*
 * External variables
 */
extern long dl_maxdrives;
extern short num_multilun_dev;
#ifdef TOSONLY
extern short MagiC;
#endif

extern int enable_flop_mediach; /* in storage_int.S */

/*
 * CBI style
 */

#define US_CBI_ADSC		0

/*
 * BULK only
 */
#define US_BBB_RESET		0xff
#define US_BBB_GET_MAX_LUN	0xfe

/* Command Block Wrapper */
typedef struct
{
	__u32		dCBWSignature;
#	define CBWSIGNATURE	0x43425355
	__u32		dCBWTag;
	__u32		dCBWDataTransferLength;
	__u8		bCBWFlags;
#	define CBWFLAGS_OUT	0x00
#	define CBWFLAGS_IN	0x80
	__u8		bCBWLUN;
	__u8		bCDBLength;
#	define CBWCDBLENGTH	16
	__u8		CBWCDB[CBWCDBLENGTH];
} umass_bbb_cbw_t;
#define UMASS_BBB_CBW_SIZE	31
static __u32 CBWTag;

/* Command Status Wrapper */
typedef struct
{
	__u32		dCSWSignature;
#	define CSWSIGNATURE	0x53425355
	__u32		dCSWTag;
	__u32		dCSWDataResidue;
	__u8		bCSWStatus;
#	define CSWSTATUS_GOOD	0x0
#	define CSWSTATUS_FAILED 0x1
#	define CSWSTATUS_PHASE	0x2
} umass_bbb_csw_t;
#define UMASS_BBB_CSW_SIZE	13

/* There is a copy of this struct for every logical device (LUN) */
block_dev_desc_t usb_dev_desc[MAX_TOTAL_LUN_NUM];

struct bios_partitions
{
	unsigned long biosnum[32];		/* BIOS device number belonging this USB logical device (LUN) */
	short partnum;				/* Total number of partitions this device has */
};

static struct bios_partitions bios_part[MAX_TOTAL_LUN_NUM]; /* BIOS partitions per LUN */

/* There is a copy of this struct for every physical device */
struct mass_storage_dev mass_storage_dev[USB_MAX_STOR_DEV];

#ifdef TOSONLY
/* Semaphore to avoid polling LUN status while transfer is in process */
int transfer_running;

/* Global variables for tosdelay.c. Should be defined here to avoid
 * "multiple definition" errors from the linker with -fno-common.
 */
unsigned long loopcount_1_msec;
unsigned long delay_1usec;
#endif

#define DEFAULT_SECTOR_SIZE 2048

static unsigned char readbuf[DEFAULT_SECTOR_SIZE];

/* A copy of the BPBs in globally accessible memory. */
BPB *usb_global_bpb = NULL;

#define ATARI_PART_TBL_OFFSET   0x1c6
#define XGM                     0x0058474dL     /* '\0XGM' */
#define GEM                     0x0047454dL     /* '\0GEM' */
#define BGM                     0x0042474dL     /* '\0BGM' */
#define RAW                     0x00524157L     /* '\0RAW' */
#define F32                     0x00463332L     /* '\0F32' */


typedef struct {
	unsigned long id;           /* really 1-byte flag followed by GEM, BGM, or XGM */
	unsigned long start;        /* starting sector */
	unsigned long size;         /* size in sectors */
} atari_partition_t;


#define DOS_PART_TBL_OFFSET	0x1be
#define DOS_PART_MAGIC_OFFSET	0x1fe
#define DOS_PBR_FSTYPE_OFFSET	0x36
#define DOS_PBR_MEDIA_TYPE_OFFSET	0x15
#define DOS_MBR	0
#define DOS_PBR	1
#define DOS_FS_TYPE_OFFSET 0x36

typedef struct dos_partition
{
	unsigned char boot_ind;		/* 0x80 - active			*/
	unsigned char head;		/* starting head			*/
	unsigned char sector;		/* starting sector			*/
	unsigned char cyl;		/* starting cylinder			*/
	unsigned char sys_ind;		/* What partition type			*/
	unsigned char end_head;		/* end head				*/
	unsigned char end_sector;	/* end sector				*/
	unsigned char end_cyl;		/* end cylinder				*/
	unsigned long start4;		/* starting sector counting from 0	*/
	unsigned long size4;		/* nr of sectors in partition		*/
} dos_partition_t;

typedef struct disk_partition
{
	unsigned long type;
	unsigned long	start; /* # of first block in partition	*/
	unsigned long	size;  /* number of blocks in partition	*/
	unsigned long	blksz; /* block size in bytes			*/
} disk_partition_t;

/* Functions prototypes */
long 		usb_stor_get_info	(struct usb_device *, struct us_data *, block_dev_desc_t *);
long 		usb_stor_probe		(struct usb_device *, unsigned int, struct us_data *);
static long			error_no(unsigned char asc);
long 		usb_stor_read		(long, unsigned long, unsigned long, void *);
long 		usb_stor_write		(long, unsigned long, unsigned long, void *);
void		usb_stor_eject		(long);
void		usb_stor_reset		(long);
block_dev_desc_t *	usb_stor_get_dev	(long);
static long 		usb_stor_BBB_comdat	(ccb *, struct us_data *);
static long 		usb_stor_CB_comdat	(ccb *, struct us_data *);
static long 		usb_stor_CBI_get_status	(ccb *, struct us_data *);
static long 		usb_stor_BBB_clear_endpt_stall	(struct us_data *, unsigned char, bool out);
static long 		usb_stor_BBB_transport	(ccb *, struct us_data *);
static long 		usb_stor_CB_transport	(ccb *, struct us_data *);
void 		usb_storage_init	(void);
long		usb_test_unit_ready	(ccb *srb, struct us_data *ss);
long		poll_floppy_ready(ccb *srb, struct us_data *ss);
long 		usb_request_sense	(ccb *srb, struct us_data *ss);
void		part_init		(long dev_num, block_dev_desc_t *stor_dev);

/* --- Interface functions -------------------------------------------------- */

static long _cdecl
storage_ioctl (struct uddif *u, short cmd, long arg)
{
	return E_OK;
}
/* ------------------------------------------------------------------------- */

static unsigned long usb_get_max_lun(struct us_data *us)
{
	int len;
	ALLOC_CACHE_ALIGN_BUFFER(unsigned char, result, 1);
	len = usb_control_msg(us->pusb_dev,
			      usb_rcvctrlpipe(us->pusb_dev, 0),
			      US_BBB_GET_MAX_LUN,
			      USB_TYPE_CLASS | USB_RECIP_INTERFACE | USB_DIR_IN,
			      0, us->ifnum,
			      result, sizeof(char),
		      USB_CNTL_TIMEOUT * 5);
	DEBUG(("Get Max LUN -> len = %i, result = %li", len, (long) *result));
	return (len > 0) ? *result : 0;
}

block_dev_desc_t *usb_stor_get_dev(long idx)
{
	return(idx < MAX_TOTAL_LUN_NUM) ? &usb_dev_desc[idx] : NULL;
}

void
init_part(block_dev_desc_t *dev_desc)
{
	unsigned char *buffer = readbuf;

	if((dev_desc->block_read(dev_desc->usb_logdrv, 0, 1, (unsigned long *)buffer) != 1)
	 || (buffer[DOS_PART_MAGIC_OFFSET + 0] != 0x55) || (buffer[DOS_PART_MAGIC_OFFSET + 1] != 0xaa))
	{
		return;
	}
	dev_desc->part_type = PART_TYPE_DOS;
	DEBUG(("DOS partition table found"));
#ifdef USB_STOR_DEBUG
	{
		char buf[128];
		char build_str[64];
		long j;
		
		sprintf(buf, sizeof(buf), "\0");

		for(j = 0; j < 512; j++)
		{
			if((j & 15) == 0)
			{
				sprintf(build_str, sizeof(build_str), "%04x ", j);
				strcat(buf, build_str);
			}
			sprintf(build_str, sizeof(build_str), "%02x ", buffer[j]);
			strcat(buf, build_str);
			if((j & 15) == 15)
			{
				long k;
				for(k = j-15; k <= j; k++)
				{
					if(buffer[k] < ' ' || buffer[k] >= 127)
						strcat(buf, ".");
					else 
					{
						sprintf(build_str, sizeof(build_str), "%c", buffer[k]);
						strcat(buf, build_str);
					}
				}
				DEBUG((buf));
				sprintf(buf, sizeof(buf), "\0");
			}
		}
	}
#endif
}

void
part_init(long dev_num, block_dev_desc_t *stor_dev)
{
	long r;

	long part_num = 1;
	unsigned long part_type, part_offset, part_size;

	/* Now find partitions in this storage device */
	while (!fat_register_device(stor_dev, part_num, &part_type,
				    &part_offset, &part_size))
	{
		/* install partition */
		r = install_usb_stor(dev_num, part_type, part_offset,
					     part_size, stor_dev->vendor,
				     stor_dev->revision, stor_dev->product);
		if (r == -1) {
			DEBUG(("unable to install storage device\r\n"));
		}
		else
		{
#ifdef TOSONLY
			SCSIDRV_MediaChange(dev_num);
#endif
			bios_part[dev_num].biosnum[part_num - 1] = r;
			bios_part[dev_num].partnum = part_num;
		}
		part_num++;
	}
}

/*
 *	test for valid DOS or GEMDOS partition
 *	returns 1 if valid
 */
static int is_atari_partition(unsigned long type)
{
	type &= 0x00ffffffL;

#ifdef DEBUGGING_ROUTINES
	c_conws("Found partition ");
	hex_long(type);
	c_conws("\r\n");
#endif

	if ((type == GEM) || (type == XGM) || (type == BGM) || (type == RAW))
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

static inline long
is_active_atari(long part_type)
{
	return (part_type & 0x01000000L);
}

static inline long
is_extended_atari(long part_type)
{
	return ((part_type&0x00ffffffL) == XGM);
}

/*
 * update info structure with data from partition entry
 */
static void
update_atari_info(long offset,atari_partition_t *pt, disk_partition_t *info)
{
	info->type = pt->id & 0x00ffffffL;
	info->blksz = 512;
	info->start = offset + be2cpu32(pt->start);
	info->size = be2cpu32(pt->size);
#ifdef DEV_DEBUG
	const char *extended = is_extended_atari(pt->id)?" Extd" : "";
#endif
	DEBUG(("Atari partition at offset 0x%lx, size 0x%lx, type 0x%lx%s",
			info->start, info->size, pt->id, extended));
}

/*
 *	extract partition info from chain of subpartitions within an XGM partition
 *
 *	on entry:	xgm_start = starting sector number of XGM partition
 *				part_num = number of first subpartition in XGM partition
 *				which_part = desired partition number
 *	returns:	-1	error (read failed)
 *				0	partition found, info has been filled in
 *				N	partition not found, next partition to process is N
 */
static long
get_partinfo_atari_extended(block_dev_desc_t *dev_desc, long xgm_start, long part_num, long which_part, disk_partition_t *info)
{
	unsigned char *buffer = readbuf;
	atari_partition_t part[4], *pt;
	long i, offset = 0L;

	while(1)
	{
		if (dev_desc->block_read(dev_desc->usb_logdrv, xgm_start+offset, 1, (unsigned long *)buffer) != 1)
		{
			DEBUG(("Can't read subpartition table on %d:%ld", dev_desc->usb_logdrv, xgm_start+offset));
			return -1;
		}

		memcpy(part,buffer+ATARI_PART_TBL_OFFSET,4*sizeof(atari_partition_t));

		for (i = 0, pt = part; i < 4; i++, pt++) {
			if (!is_active_atari(pt->id))
				continue;
			if (!is_atari_partition(pt->id))
				continue;

			/*
			 * links always follow the partition description, so if we get a link,
			 * we know we're finished with this subpartition.
			 */
			if (is_extended_atari(pt->id))
			{
				offset = be2cpu32(pt->start);
				break;
			}
			if (part_num == which_part)
			{
				update_atari_info(xgm_start+offset,pt,info);
				return 0;
			}
			part_num++;
		}
		if (i >= 4)				/* no more subdivisions */
			break;
	}

	return part_num;
}

/*
 * 	extract partition info for specified Atari-style partition
 *
 *  note that subpartitions of an extended partition are processed as they
 *  are encountered, rather than after all primary partitions as in MSDOS
 */
static long
get_partinfo_atari(block_dev_desc_t *dev_desc, long part_num, long which_part, disk_partition_t *info)
{
	unsigned char *buffer = readbuf;
	atari_partition_t part[4], *pt;
	long i, rc;

	if (dev_desc->block_read(dev_desc->usb_logdrv, 0, 1, (unsigned long *)buffer) != 1)
	{
		DEBUG(("Can't read partition table on %d:0", dev_desc->usb_logdrv));
		return -1;
	}

	pt = (atari_partition_t *)(buffer + ATARI_PART_TBL_OFFSET);
	if (is_active_atari(pt->id) && is_extended_atari(pt->id))
	{
		DEBUG(("Error: extended partition in slot0 of partition table on %d:0", dev_desc->usb_logdrv));
		return -1;
	}

	/* Process all partitions */
	memcpy(part,buffer+ATARI_PART_TBL_OFFSET,4*sizeof(atari_partition_t));

	for (i = 0, pt = part; i < 4; i++, pt++)
	{
		if (!is_active_atari(pt->id))
			continue;

		if (!is_atari_partition(pt->id))
			continue;

		if (is_extended_atari(pt->id))
		{
			rc = get_partinfo_atari_extended(dev_desc, be2cpu32(pt->start), part_num, which_part, info);
			if (rc <= 0)
				return rc;
			part_num = rc;
			continue;
		}

		if (part_num == which_part)
		{
			update_atari_info(0L,pt,info);
			return 0;
		}
		part_num++;
	}

	return -1;
}

static inline long
is_extended_dos(long part_type)
{
	return(part_type == 0x5 || part_type == 0xf || part_type == 0x85);
}

/*
 * 	extract partition info for specified DOS-style partition
 */
static long
get_partinfo_dos(block_dev_desc_t *dev_desc, long ext_part_sector, long relative, long part_num, long which_part, disk_partition_t *info)
{
	unsigned char *buffer = readbuf;
	dos_partition_t part[4], *pt;
	long i;

	if(dev_desc->block_read(dev_desc->usb_logdrv, ext_part_sector, 1, (unsigned long *)buffer) != 1)
	{
		DEBUG(("Can't read partition table on %d:%ld", dev_desc->usb_logdrv, ext_part_sector));
		return -1;
	}
	
	if(buffer[DOS_PART_MAGIC_OFFSET] != 0x55 || buffer[DOS_PART_MAGIC_OFFSET + 1] != 0xaa)
	{
		DEBUG(("bad MBR sector signature 0x%02x%02x", buffer[DOS_PART_MAGIC_OFFSET], buffer[DOS_PART_MAGIC_OFFSET + 1]));
		return -1;
	}

	/* Process all primary/logical partitions */
	memcpy(part,buffer+DOS_PART_TBL_OFFSET,4*sizeof(dos_partition_t));

	/* Even with the 0x55aa signature (see above), this can still be NOT an MBR but a FAT boot sector.
	   Do it like Linux: Check the boot indicator and reject it if not 0x00 or 0x80 for all partitions. */
	for(i = 0, pt = part; i < 4; i++, pt++)
	{
		if ((pt->boot_ind != 0x00) && (pt->boot_ind != 0x80))
		{
			DEBUG(("bad MBR boot indicator 0x%02x for part %ld", pt->boot_ind, (long) i));
			return -1;
		}
	}

	for(i = 0, pt = part; i < 4; i++, pt++)
	{
		/* fdisk does not show the extended partitions that are not in the MBR */
		if((pt->sys_ind != 0) && (part_num == which_part) && !is_extended_dos(pt->sys_ind))
		{
			info->type = (unsigned long)pt->sys_ind;
			info->blksz = 512;
			info->start = ext_part_sector + le2cpu32(pt->start4);
			info->size = le2cpu32(pt->size4);
			DEBUG(("DOS partition at offset 0x%lx, size 0x%lx, type 0x%x %s", 
					info->start, info->size, pt->sys_ind, 
					(is_extended_dos(pt->sys_ind) ? " Extd" : "")));
			return 0;
		}
		/* Reverse engr the fdisk part# assignment rule! */
		if((ext_part_sector == 0) || (pt->sys_ind != 0 && !is_extended_dos(pt->sys_ind)))
			part_num++;
	}

	/* Process the extended partitions */
	for(i = 0, pt = part; i < 4; i++, pt++)
	{
		if(is_extended_dos(pt->sys_ind))
		{
			long lba_start = le2cpu32(pt->start4) + relative;
			return get_partinfo_dos(dev_desc, lba_start, ext_part_sector == 0 ? lba_start : relative, part_num, which_part, info);
		}
	}
	return -1;
}

/*
 * 	extract partition info for specified partition
 *
 *  Note: the first partition is numbered as 1, not zero
 */
static long
get_partition_info_extended(block_dev_desc_t *dev_desc, long ext_part_sector, long relative, long part_num, long which_part, disk_partition_t *info)
{
	unsigned char *buffer = readbuf;

	if(dev_desc->block_read(dev_desc->usb_logdrv, 0, 1, (unsigned long *)buffer) != 1)
	{
		DEBUG(("Can't read boot sector from device %d", dev_desc->usb_logdrv));
		return -1;
	}

	/*
	* We lookup atari partitions first as they're identified with 
	* specific code such as GEM, BGM etc.
	*/
	DEBUG(("Try looking up Atari MBR sector"));
	if (get_partinfo_atari(dev_desc,part_num,which_part,info) == 0) {
		return 0;
	}

	if(buffer[DOS_PART_MAGIC_OFFSET] == 0x55 && buffer[DOS_PART_MAGIC_OFFSET+1] == 0xaa)
	{
		DEBUG(("found DOS MBR sector"));
		return get_partinfo_dos(dev_desc,ext_part_sector,relative,part_num,which_part,info);
	}

	return -1;
}

/* Heuristic to determine if we have a FAT12/FAT16 boot sector.
 * Ideas from NT's fastfat.sys, though we're more lenient, because of Atari
 * floppys. Taken from the Lightning VME driver by Ingo Uhlemann/Christian Zietz.
 */
static long
is_fat_filesystem(const unsigned char* bootsector)
{
	unsigned char temp;

	/* bytes per sector must not be null */
	if (0 == (bootsector[0xb] | bootsector[0xc]))
		return 0;

	/* reserved sectors must not be null */
	if (0 == (bootsector[0xe] | bootsector[0xf]))
		return 0;

	/* sectors per cluster must be a power of 2 */
	temp = bootsector[0xd];
	if ((temp != 1) && (temp != 2) && (temp != 4) && (temp != 8) &&
		(temp != 16) && (temp != 32) && (temp != 64) && (temp != 128))
		return 0;

	/* number of FATs must be 1 or 2 */
	temp = bootsector[0x10];
	if ((temp != 1) && (temp != 2))
		return 0;

	/* accept this as a FAT FS */
	return 1;
}

long
fat_register_device(block_dev_desc_t *dev_desc, long part_no, unsigned long *part_type, unsigned long *part_offset, unsigned long *part_size)
{
	unsigned char *buffer = readbuf;
	disk_partition_t info = { 0L, 0L, 0L, 0L };

	if(!dev_desc->block_read) {
		return -1;
	}

	/* First we assume, there is a MBR */
	if(!get_partition_info_extended(dev_desc, 0, 0, 1, part_no, &info))
	{
		*part_type = info.type;
		*part_offset = info.start;
		*part_size = info.size;
		return 0;
	}

	/* no MBR, check for PBR */
	if(dev_desc->block_read(dev_desc->usb_logdrv, 0, 1, (unsigned long *)buffer) != 1)
	{
		DEBUG(("Can't read boot sector from device %d", dev_desc->usb_logdrv));
		return -1;
	}

	if((part_no == 1) && is_fat_filesystem(buffer))
	{
		/* ok, we assume we are on a PBR only */
		*part_type = 0;
		*part_offset = 0;
		*part_size = 0;
		return 0;
	}

	DEBUG(("Partition %ld not valid on device %d", part_no, dev_desc->usb_logdrv));
	return -1;
}


void
dev_print(block_dev_desc_t *dev_desc)
{
#ifdef CONFIG_LBA48
	uint64_t lba512; /* number of blocks if 512bytes block size */
#else
	lbaint_t lba512;
#endif
	if(dev_desc->type == DEV_TYPE_UNKNOWN)
	{
		DEBUG(("not available"));
		return;
	}
	if((dev_desc->lba * dev_desc->blksz) > 0L)
	{
		unsigned long mb, mb_quot, mb_rem, gb, gb_quot, gb_rem;
		lbaint_t lba = dev_desc->lba;
		lba512 = (lba * (dev_desc->blksz / 512));
		mb = (10 * lba512) / 2048;	/* 2048 = (1024 * 1024) / 512 MB */
		/* round to 1 digit */
		mb_quot	= mb / 10;
		mb_rem	= mb - (10 * mb_quot);
		UNUSED(mb_rem);
		gb = mb / 1024;
		gb_quot	= gb / 10;
		gb_rem	= gb - (10 * gb_quot);
		UNUSED(gb_rem);
#ifdef CONFIG_LBA48
		if(dev_desc->lba48)
			DEBUG(("Supports 48-bit addressing"));
#endif
		DEBUG(("Capacity: %ld.%ld MB = %ld.%ld GB (%ld x %ld)", mb_quot, mb_rem, gb_quot, gb_rem, (unsigned long)lba, dev_desc->blksz));
	}
	else
	{
		DEBUG(("Capacity: not available\r\n"));
	}
}

//# endif /* CONFIG_USB_OHCI */


static long
usb_stor_irq(struct usb_device *dev)
{
	struct us_data *us;
	us = (struct us_data *)dev->privptr;
	if(us->ip_wanted)
		us->ip_wanted = 0;
	return 0;
}

#ifdef USB_STOR_DEBUG

static void
usb_show_srb(ccb *pccb)
{
	long i;
	DEBUG(("SRB: len %d datalen 0x%lx ", pccb->cmdlen, pccb->datalen));
	for (i = 0; i < 12; i++)
		DEBUG(("%02x ", pccb->cmd[i]));
	DEBUG((""));
}

static void
display_int_status(unsigned long tmp)
{
	DEBUG(("Status: %s %s %s %s %s %s %s",
		(tmp & USB_ST_ACTIVE) ? "Active" : "",
		(tmp & USB_ST_STALLED) ? "Stalled" : "",
		(tmp & USB_ST_BUF_ERR) ? "Buffer Error" : "",
		(tmp & USB_ST_BABBLE_DET) ? "Babble Det" : "",
		(tmp & USB_ST_NAK_REC) ? "NAKed" : "",
		(tmp & USB_ST_CRC_ERR) ? "CRC Error" : "",
		(tmp & USB_ST_BIT_ERR) ? "Bitstuff Error" : ""));
}

#endif

/***********************************************************************
 * Data transfer routines
 ***********************************************************************/

static long
us_one_transfer(struct us_data *us, long pipe, char *buf, long length)
{
	long max_size;
	long this_xfer;
	long result;
	long partial;
	long maxtry;
	long stat;
	/* determine the maximum packet size for these transfers */
	max_size = usb_maxpacket(us->pusb_dev, pipe) * 16;
	/* while we have data left to transfer */
	while(length)
	{
		/* calculate how long this will be -- maximum or a remainder */
		this_xfer = length > max_size ? max_size : length;
		length -= this_xfer;
		/* setup the retry counter */
		maxtry = 10;
		/* set up the transfer loop */
		do
		{
			/* transfer the data */
			DEBUG(("Bulk xfer 0x%lx(%ld) try #%ld", (unsigned long)buf, this_xfer, 11 - maxtry));
			result = usb_bulk_msg(us->pusb_dev, pipe, buf, this_xfer, &partial, USB_CNTL_TIMEOUT * 5, 0);
			DEBUG(("bulk_msg returned %ld xferred %ld/%ld", result, partial, this_xfer));
			if(us->pusb_dev->status != 0)
			{
				/* if we stall, we need to clear it before we go on */
#ifdef USB_STOR_DEBUG
				display_int_status(us->pusb_dev->status);
#endif
				if(us->pusb_dev->status & USB_ST_STALLED)
				{
					DEBUG(("stalled ->clearing endpoint halt for pipe 0x%lx", pipe));
					stat = us->pusb_dev->status;
					usb_clear_halt(us->pusb_dev, pipe);
					us->pusb_dev->status = stat;
					if(this_xfer == partial)
					{
						DEBUG(("bulk transferred with error %lx, but data ok", us->pusb_dev->status));
						return 0;
					}
					else
						return result;
				}
				if(us->pusb_dev->status & USB_ST_NAK_REC)
				{
					DEBUG(("Device NAKed bulk_msg"));
					return result;
				}
				DEBUG(("bulk transferred with error"));
				if(this_xfer == partial)
				{
					DEBUG((" %lx, but data ok", us->pusb_dev->status));
					return 0;
				}
				/* if our try counter reaches 0, bail out */
				DEBUG((" %lx, data %ld", us->pusb_dev->status, partial));
				if(!maxtry--)
					return result;
			}
			/* update to show what data was transferred */
			this_xfer -= partial;
			buf += partial;
			/* continue until this transfer is done */
		}
		while (this_xfer);
	}
	/* if we get here, we're done and successful */
	return 0;
}

static long
usb_stor_BBB_reset(struct us_data *us)
{
	long result;
	long pipe;
	/*
	 * Reset recovery (5.3.4 in Universal Serial Bus Mass Storage Class)
	 *
	 * For Reset Recovery the host shall issue in the following order:
	 * a) a Bulk-Only Mass Storage Reset
	 * b) a Clear Feature HALT to the Bulk-In endpoint
	 * c) a Clear Feature HALT to the Bulk-Out endpoint
	 *
	 * This is done in 3 steps.
	 *
	 * If the reset doesn't succeed, the device should be port reset.
	 *
	 * This comment stolen from FreeBSD's /sys/dev/usb/umass.c.
	 */
	DEBUG(("BBB_reset"));
	result = usb_control_msg(us->pusb_dev, usb_sndctrlpipe(us->pusb_dev, 0),
	 US_BBB_RESET, USB_TYPE_CLASS | USB_RECIP_INTERFACE, 0, us->ifnum, 0, 0, USB_CNTL_TIMEOUT * 5);
	if((result < 0) && (us->pusb_dev->status & USB_ST_STALLED))
	{
		DEBUG(("RESET:stall"));
		return -1;
	}
	/* long wait for reset */
	mdelay(150);
	DEBUG(("BBB_reset result %ld: status %lx reset", result, us->pusb_dev->status));
	pipe = usb_rcvbulkpipe(us->pusb_dev, (long)us->ep_in);
	result = usb_clear_halt(us->pusb_dev, pipe);
	/* long wait for reset */
	mdelay(150);
	DEBUG(("BBB_reset result %ld: status %lx clearing IN endpoint", result, us->pusb_dev->status));
	/* long wait for reset */
	pipe = usb_sndbulkpipe(us->pusb_dev, (long)us->ep_out);
	result = usb_clear_halt(us->pusb_dev, pipe);

	mdelay(150);
	DEBUG(("BBB_reset result %ld: status %lx clearing OUT endpoint", result, us->pusb_dev->status));
	DEBUG(("BBB_reset done"));
	return 0;
}

/* FIXME: this reset function doesn't really reset the port, and it
 * should. Actually it should probably do what it's doing here, and
 * reset the port physically
 */
static long
usb_stor_CB_reset(struct us_data *us)
{
	unsigned char cmd[12];
	long result;
	DEBUG(("CB_reset"));
	memset(cmd, 0xff, sizeof(cmd));
	cmd[0] = SCSI_SEND_DIAG;
	cmd[1] = 4;
	result = usb_control_msg(us->pusb_dev, usb_sndctrlpipe(us->pusb_dev, 0), 
	 US_CBI_ADSC, USB_TYPE_CLASS | USB_RECIP_INTERFACE, 0, us->ifnum, cmd, sizeof(cmd), USB_CNTL_TIMEOUT * 5);
	UNUSED(result);
	/* long wait for reset */
	mdelay(1500);
	DEBUG(("CB_reset result %ld: status %lx clearing endpoint halt", result, us->pusb_dev->status));
	usb_clear_halt(us->pusb_dev, usb_rcvbulkpipe(us->pusb_dev, (long)us->ep_in));
	usb_clear_halt(us->pusb_dev, usb_rcvbulkpipe(us->pusb_dev, (long)us->ep_out));
	DEBUG(("CB_reset done"));
	return 0;
}

/*
 * Set up the command for a BBB device. Note that the actual SCSI
 * command is copied into cbw.CBWCDB.
 */
static long
usb_stor_BBB_comdat(ccb *srb, struct us_data *us)
{
	long result;
	long actlen;
	unsigned long pipe;
	umass_bbb_cbw_t cbw;
	DEBUG(("usb_stor_BBB_comdat: srb->direction: %d", srb->direction));
#ifdef BBB_COMDAT_TRACE

	char buf[srb->cmdlen * 64];
	char build_str[64];

	sprintf(buf, sizeof(buf), "\0");

	DEBUG(("dir %d lun %d cmdlen %d cmd %lx datalen %ld pdata %lx", srb->direction, srb->lun, srb->cmdlen, srb->cmd, srb->datalen, srb->pdata));
	if(srb->cmdlen)
	{
		for(result = 0; result < srb->cmdlen; result++) 
		{
			sprintf(build_str, sizeof(build_str), "cmd[%ld] 0x%x ", result, srb->cmd[result]);
			strcat(buf, build_str);
		}
		DEBUG((buf));
	}
#endif

	/* sanity checks */
	if(!(srb->cmdlen <= CBWCDBLENGTH))
	{
		DEBUG(("usb_stor_BBB_comdat: cmdlen too large"));
		return -1;
	}

	/* always OUT to the ep */
	pipe = usb_sndbulkpipe(us->pusb_dev, (long)us->ep_out);
	cbw.dCBWSignature = cpu2le32(CBWSIGNATURE);
	cbw.dCBWTag = cpu2le32(CBWTag++);
	cbw.dCBWDataTransferLength = cpu2le32(srb->datalen);
	cbw.bCBWFlags = (srb->direction == USB_CMD_DIRECTION_IN? CBWFLAGS_IN : CBWFLAGS_OUT);
	cbw.bCBWLUN = srb->lun;
	cbw.bCDBLength = srb->cmdlen;
	/* copy the command data into the CBW command data buffer */
	/* DST SRC LEN!!! */
	memcpy(cbw.CBWCDB, srb->cmd, srb->cmdlen);

	result = usb_bulk_msg(us->pusb_dev, pipe, &cbw, UMASS_BBB_CBW_SIZE, &actlen, srb->timeout, 0);
	if(result < 0)
	{
		DEBUG(("usb_stor_BBB_comdat:usb_bulk_msg error"));
	}
	return result;
}

/* FIXME: we also need a CBI_command which sets up the completion
 * interrupt, and waits for it
 */
static long
usb_stor_CB_comdat(ccb *srb, struct us_data *us)
{
	long result = 0;
	long retry;
	unsigned long pipe;
	retry = 3;
	if(srb->direction == USB_CMD_DIRECTION_IN)
		pipe = usb_rcvbulkpipe(us->pusb_dev, (long)us->ep_in);
	else
		pipe = usb_sndbulkpipe(us->pusb_dev, (long)us->ep_out);
	while(retry--)
	{
		DEBUG(("CBI gets a command: Try %ld", 5 - retry));
#ifdef USB_STOR_DEBUG
		usb_show_srb(srb);
#endif
		/* let's send the command via the control pipe */
		result = usb_control_msg(us->pusb_dev, usb_sndctrlpipe(us->pusb_dev , 0),
		 US_CBI_ADSC, USB_TYPE_CLASS | USB_RECIP_INTERFACE, 0, us->ifnum, srb->cmd, srb->cmdlen, srb->timeout);
		DEBUG(("CB_transport: control msg returned %ld, status %lx", result, us->pusb_dev->status));
		/* check the return code for the command */
		if(result < 0)
			return result;
		/* Do not clear control endpoint */
#if 0
		{
			if(us->pusb_dev->status & USB_ST_STALLED)
			{
				status = us->pusb_dev->status;
				DEBUG((" stall during command found, clear pipe"));
				usb_clear_halt(us->pusb_dev, usb_sndctrlpipe(us->pusb_dev, 0));
				us->pusb_dev->status = status;
			}
			DEBUG((" error during command %02x Stat = %lx", srb->cmd[0], us->pusb_dev->status));
			return result;
		}
#endif
		/* transfer the data payload for this command, if one exists*/
		DEBUG(("CB_transport: control msg returned %ld, direction is %s to go 0x%lx", result, srb->direction == USB_CMD_DIRECTION_IN ? "IN" : "OUT", srb->datalen));
		if(srb->datalen)
		{
			result = us_one_transfer(us, pipe, (char *)srb->pdata, srb->datalen);
			DEBUG(("CBI attempted to transfer data, result is %ld status %lx, len %ld", result, us->pusb_dev->status, us->pusb_dev->act_len));
			if(!(us->pusb_dev->status & USB_ST_NAK_REC))
				break;
		} /* if(srb->datalen) */
		else
			break;
	}
	/* return result */
	return result;
}

static long
usb_stor_CBI_get_status(ccb *srb, struct us_data *us)
{
	long result;
	us->ip_wanted = 1;
	result = usb_submit_int_msg(us->pusb_dev, us->irqpipe, (void *) &us->ip_data, us->irqmaxp, us->irqinterval);
	if (result < 0) {
		return USB_STOR_TRANSPORT_ERROR;
	}
	if(us->ip_wanted)
	{
		DEBUG(("Did not get interrupt on CBI"));
		us->ip_wanted = 0;
		return USB_STOR_TRANSPORT_ERROR;
	}
	DEBUG(("Got interrupt data 0x%x, transfered %ld status 0x%lx", us->ip_data, us->pusb_dev->irq_act_len, us->pusb_dev->irq_status));
	/* UFI gives us ASC and ASCQ, like a request sense */
	if(us->subclass == US_SC_UFI)
	{
		if(srb->cmd[0] == SCSI_REQ_SENSE || srb->cmd[0] == SCSI_INQUIRY)
			return USB_STOR_TRANSPORT_GOOD; /* Good */
		else if(us->ip_data)
			return USB_STOR_TRANSPORT_FAILED;
		else
			return USB_STOR_TRANSPORT_GOOD;
	}
	/* otherwise, we interpret the data normally */
	switch(us->ip_data)
	{
		case 0x0001: return USB_STOR_TRANSPORT_GOOD;
		case 0x0002: return USB_STOR_TRANSPORT_FAILED;
		default: return USB_STOR_TRANSPORT_ERROR;
	}
	return USB_STOR_TRANSPORT_ERROR;
}

/* clear a stall on an endpoint - special for BBB devices */
static long
usb_stor_BBB_clear_endpt_stall(struct us_data *us, __u8 endpt, bool out)
{
	long result;
	/* ENDPOINT_HALT = 0, so set value to 0 */
	result = usb_control_msg(us->pusb_dev, usb_sndctrlpipe(us->pusb_dev, 0),
	 			USB_REQ_CLEAR_FEATURE, USB_RECIP_ENDPOINT, 0, endpt, 0, 0, USB_CNTL_TIMEOUT * 5);

	/* 
	 * USB standard: "For endpoints using data toggle, regardless of whether an endpoint has the
	 * Halt feature set, a ClearFeature(ENDPOINT_HALT) request always results in the data toggle
	 * being reinitialized to DATA0
	 */
	usb_settoggle(us->pusb_dev, endpt, out?1:0, 0);
	return result;
}

static long
usb_stor_BBB_transport(ccb *srb, struct us_data *us)
{
	long result, retry;
	long actlen, data_actlen;
	unsigned long pipe, pipein, pipeout;
#ifdef BBB_XPORT_TRACE
	unsigned char *ptr;
	long idx;
#endif
	umass_bbb_csw_t csw;

#ifdef TOSONLY
	transfer_running = 1;
#endif

	/* COMMAND phase */
	DEBUG(("COMMAND phase"));
	result = usb_stor_BBB_comdat(srb, us);
	if(result < 0)
	{
		DEBUG(("failed to send CBW status %lx", us->pusb_dev->status));
		usb_stor_BBB_reset(us);
#ifdef TOSONLY
		transfer_running = 0;
#endif
		return USB_STOR_TRANSPORT_FAILED;
	}
	pipein = usb_rcvbulkpipe(us->pusb_dev, (long)us->ep_in);
	pipeout = usb_sndbulkpipe(us->pusb_dev, (long)us->ep_out);
	/* DATA phase + error handling */
	data_actlen = 0;
	/* no data, go immediately to the STATUS phase */
	if(srb->datalen == 0)
		goto st;
	DEBUG(("DATA phase"));
	if(srb->direction == USB_CMD_DIRECTION_IN)
		pipe = pipein;
	else
		pipe = pipeout;
	
	result = usb_bulk_msg(us->pusb_dev, pipe, srb->pdata, srb->datalen, &data_actlen, srb->timeout, 0);
	
	/* special handling of STALL in DATA phase */
	if((result < 0) && (us->pusb_dev->status & USB_ST_STALLED))
	{
		DEBUG(("DATA:stall"));
		/* clear the STALL on the endpoint */
		result = usb_stor_BBB_clear_endpt_stall(us, srb->direction == USB_CMD_DIRECTION_IN ? us->ep_in : us->ep_out, srb->direction == USB_CMD_DIRECTION_OUT);
		if(result >= 0)
			/* continue on to STATUS phase */
			goto st;
	}
	if(result < 0)
	{
		DEBUG(("usb_bulk_msg error status %lx", us->pusb_dev->status));
		usb_stor_BBB_reset(us);
#ifdef TOSONLY
		transfer_running = 0;
#endif
		if (us->pusb_dev->status == USB_ST_CRC_ERR)
			return USB_STOR_TRANSPORT_TIMEOUT;
		else
			return USB_STOR_TRANSPORT_DATA_FAILED;
	}
#ifdef BBB_XPORT_TRACE
	char build_str[32];
	char buf[data_actlen * 16];

	sprintf(buf, sizeof(buf),"\0");
	for(idx = 0; idx < data_actlen; idx++)
	{
		sprintf(build_str, sizeof(build_str), "pdata[%ld] 0x%x ", idx, srb->pdata[idx]);
		strcat(buf, build_str);
	}
	DEBUG((buf));
#endif
	/* STATUS phase + error handling */
st:
	retry = 0;
	DEBUG(("STATUS phase"));
again:
	result = usb_bulk_msg(us->pusb_dev, pipein, &csw, UMASS_BBB_CSW_SIZE, &actlen, srb->timeout, 0);
	/* special handling of STALL in STATUS phase */

	if((result < 0) && (retry < 1) && (us->pusb_dev->status & USB_ST_STALLED))
	{
		DEBUG(("STATUS:stall"));
		/* clear the STALL on the endpoint */
		result = usb_stor_BBB_clear_endpt_stall(us, us->ep_in, FALSE);
		if(result >= 0 && (retry++ < 1))
			/* do a retry */
			goto again;
	}

	if(result < 0)
	{
		DEBUG(("usb_bulk_msg error status %lx", us->pusb_dev->status));
		usb_stor_BBB_reset(us);
		result = USB_STOR_TRANSPORT_FAILED;
		goto out;
	}
#ifdef BBB_XPORT_TRACE
	unsigned char buf2[UMASS_BBB_CSW_SIZE * 16];

	sprintf(buf2, sizeof(buf2),"\0");
	ptr = (unsigned char *)&csw;
	for(idx = 0; idx < UMASS_BBB_CSW_SIZE; idx++)
	{
		sprintf(build_str, sizeof(build_str), "ptr[%ld] 0x%x ", idx, ptr[idx]);
		strcat(buf2, build_str);
	}
	DEBUG((buf2));
#endif
	/* misuse pipe to get the residue */
	pipe = le2cpu32(csw.dCSWDataResidue);
	if(pipe == 0 && srb->datalen != 0 && srb->datalen - data_actlen != 0)
		pipe = srb->datalen - data_actlen;
	if(CSWSIGNATURE != le2cpu32(csw.dCSWSignature))
	{
		DEBUG(("!CSWSIGNATURE"));
		usb_stor_BBB_reset(us);
		result = USB_STOR_TRANSPORT_FAILED;
		goto out;
	}
	else if((CBWTag - 1) != le2cpu32(csw.dCSWTag))
	{
		DEBUG(("!Tag"));
		usb_stor_BBB_reset(us);
		result = USB_STOR_TRANSPORT_FAILED;
		goto out;
	}
	else if(csw.bCSWStatus > CSWSTATUS_PHASE)
	{
		DEBUG((">PHASE"));
		usb_stor_BBB_reset(us);
		result = USB_STOR_TRANSPORT_FAILED;
		goto out;
	}
	else if(csw.bCSWStatus == CSWSTATUS_PHASE)
	{
		DEBUG(("=PHASE"));
		usb_stor_BBB_reset(us);
		result = USB_STOR_TRANSPORT_PHASE_ERROR;
		goto out;
	}
	else if(data_actlen > srb->datalen)
	{
		DEBUG(("transferred %ldB instead of %ldB", data_actlen, srb->datalen));
		result = USB_STOR_TRANSPORT_FAILED;
		goto out;
	}
	else if(csw.bCSWStatus == CSWSTATUS_FAILED)
	{
		DEBUG(("FAILED"));
		result = USB_STOR_TRANSPORT_SENSE;
		goto out;
	}
out:
#ifdef TOSONLY
	transfer_running = 0;
#endif
	return result;
}

static long
usb_stor_CB_transport(ccb *srb, struct us_data *us)
{
	long result, status;
	ccb reqsrb;
	status = USB_STOR_TRANSPORT_GOOD;
#ifdef TOSONLY
	transfer_running = 1;
#endif
	/* issue the command */
	result = usb_stor_CB_comdat(srb, us);
	DEBUG(("command / Data returned %ld, status %lx", result, us->pusb_dev->status));
	/* if this is an CBI Protocol, get IRQ */
	if(us->protocol == US_PR_CBI)
	{
		status = usb_stor_CBI_get_status(srb, us);
		if(status == USB_STOR_TRANSPORT_ERROR)
		{
			DEBUG((" USB CBI Command Error"));
#ifdef TOSONLY
			transfer_running = 0;
#endif
			return status;
		}
		srb->sense_buf[12] = (unsigned char)(us->ip_data >> 8);
		srb->sense_buf[13] = (unsigned char)(us->ip_data & 0xff);
		if(!us->ip_data)
		{
			/* if the status is good, report it */
			if(status == USB_STOR_TRANSPORT_GOOD)
			{
				DEBUG((" USB CBI Command Good"));
#ifdef TOSONLY
				transfer_running = 0;
#endif
				return status;
			}
		}
	}
	/* do we have to issue an auto request? */
	/* HERE we have to check the result */
	if((result < 0) && !(us->pusb_dev->status & USB_ST_STALLED))
	{
		DEBUG(("ERROR %lx", us->pusb_dev->status));
		us->transport_reset(us);
#ifdef TOSONLY
		transfer_running = 0;
#endif
		return USB_STOR_TRANSPORT_ERROR;
	}
	if (srb->cmd[0] == SCSI_REQ_SENSE)
	{
		/* do not issue an autorequest after request sense */
		DEBUG(("No auto request and good"));
#ifdef TOSONLY
		transfer_running = 0;
#endif
		return USB_STOR_TRANSPORT_GOOD;
	}
	if (srb->cmd[0] == SCSI_TST_U_RDY)
	{
		/* do not issue an autorequest after TEST_UNIT_READY.
		 usb_test_unit_ready() will request sense in case of failure. */
#ifdef TOSONLY
		transfer_running = 0;
#endif
		return (result < 0)?USB_STOR_TRANSPORT_FAILED:USB_STOR_TRANSPORT_GOOD;
	}

	/* issue an request_sense */
	memset(&reqsrb.cmd[0], 0, 12);
	reqsrb.cmd[0] = SCSI_REQ_SENSE;
	reqsrb.cmd[1] = srb->lun << 5;
	reqsrb.cmd[4] = 18;
	reqsrb.datalen = 18;
	reqsrb.pdata = &srb->sense_buf[0];
	reqsrb.cmdlen = 12;
	reqsrb.direction = USB_CMD_DIRECTION_IN;
	reqsrb.timeout = USB_CNTL_TIMEOUT * 5;
	/* issue the command */
	result = usb_stor_CB_comdat(&reqsrb, us);
	DEBUG(("auto request returned %ld", result));
	/* if this is an CBI Protocol, get IRQ */
	if(us->protocol == US_PR_CBI) {
		status = usb_stor_CBI_get_status(&reqsrb, us);
	}
	if((result < 0) && !(us->pusb_dev->status & USB_ST_STALLED))
	{
		DEBUG((" AUTO REQUEST ERROR %lx", us->pusb_dev->status));
#ifdef TOSONLY
		transfer_running = 0;
#endif
		return USB_STOR_TRANSPORT_ERROR;
	}
	DEBUG(("autorequest returned 0x%02x 0x%02x 0x%02x 0x%02x", srb->sense_buf[0], srb->sense_buf[2], srb->sense_buf[12], srb->sense_buf[13]));
	/* Check the auto request result */
	if((srb->sense_buf[2] == 0) && (srb->sense_buf[12] == 0) && (srb->sense_buf[13] == 0))
	{
		/* ok, no sense */
#ifdef TOSONLY
		transfer_running = 0;
#endif
		return USB_STOR_TRANSPORT_GOOD;
	}
	/* Check the auto request result */
	switch(srb->sense_buf[2])
	{
		case 0x01:
			/* Recovered Error */
#ifdef TOSONLY
			transfer_running = 0;
#endif
			return USB_STOR_TRANSPORT_GOOD;
		case 0x02: /* Not Ready */
			DEBUG(("cmd 0x%02x returned 0x%02x 0x%02x 0x%02x 0x%02x (NOT READY)",
					srb->cmd[0], srb->sense_buf[0], srb->sense_buf[2], srb->sense_buf[12], srb->sense_buf[13]));
#ifdef TOSONLY
			transfer_running = 0;
#endif
			return USB_STOR_TRANSPORT_SENSE;

		default:
			DEBUG(("cmd 0x%02x returned 0x%02x 0x%02x 0x%02x 0x%02x",
					srb->cmd[0], srb->sense_buf[0], srb->sense_buf[2],
					srb->sense_buf[12], srb->sense_buf[13]));
#ifdef TOSONLY
			transfer_running = 0;
#endif
			return USB_STOR_TRANSPORT_SENSE;
	}
#ifdef TOSONLY
	transfer_running = 0;
#endif
	return USB_STOR_TRANSPORT_FAILED;
}

static long
usb_inquiry(ccb *srb, struct us_data *ss)
{
	DEBUG(("usb_inquiry()")); 

	long retry, i;
	retry = 5;
	while (retry--)
	{
		memset(&srb->cmd[0], 0, 12);
		srb->cmd[0] = SCSI_INQUIRY;
		srb->cmd[1] = srb->lun << 5;
		srb->cmd[4] = 36;
		srb->datalen = 36;
		srb->cmdlen = 12;
		srb->direction = USB_CMD_DIRECTION_IN;
		srb->timeout = USB_CNTL_TIMEOUT * 5;
		i = ss->transport(srb, ss);
		DEBUG(("inquiry returns %ld", i));
		if(i == 0)
			break;
	}
	if(!retry)
	{
		DEBUG(("error in inquiry"));
		return -1;
	}
	return 0;
}

long
usb_request_sense(ccb *srb, struct us_data *ss)
{
	DEBUG(("usb_request_sense()"));
	char *ptr;
	ptr = (char *)srb->pdata;
	memset(&srb->cmd[0], 0, 12);
	srb->cmd[0] = SCSI_REQ_SENSE;
	srb->cmd[1] = srb->lun << 5;
	srb->cmd[4] = 18;
	srb->datalen = 18;
	srb->pdata = &srb->sense_buf[0];
	srb->cmdlen = 12;
	srb->direction = USB_CMD_DIRECTION_IN;
	srb->timeout = USB_CNTL_TIMEOUT * 5;
	ss->transport(srb, ss);
	DEBUG(("Request Sense returned %02x %02x %02x", srb->sense_buf[2], srb->sense_buf[12], srb->sense_buf[13]));
	srb->pdata = (unsigned char *)ptr;
	return 0;
}

static long
usb_start_stop_unit(ccb *srb, struct us_data *ss, unsigned char start)
{
	DEBUG(("usb_start_stop_unit()"));
	memset(&srb->cmd[0], 0, 12);
	srb->cmd[0] = SCSI_START_STP;
	srb->cmd[4] = start;
	srb->datalen = 0;
	srb->cmdlen = 12;
	srb->direction = USB_CMD_DIRECTION_OUT;
	srb->timeout = USB_CNTL_TIMEOUT * 5;
	if (ss->transport(srb, ss) == USB_STOR_TRANSPORT_GOOD) {
		return 0;
	} else {
		return -1;
	}
}

long
usb_test_unit_ready(ccb *srb, struct us_data *ss)
{
	long retries = 10;
	DEBUG(("usb_test_unit_ready()"));
	do
	{
		memset(&srb->cmd[0], 0, 12);
		srb->cmd[0] = SCSI_TST_U_RDY;
		srb->cmd[1] = srb->lun << 5;
		srb->datalen = 0;
		srb->cmdlen = 12;
		srb->direction = USB_CMD_DIRECTION_IN;
		srb->timeout = USB_CNTL_TIMEOUT * 5;
		if(ss->transport(srb, ss) == USB_STOR_TRANSPORT_GOOD) {
			return 0;
		}
		usb_request_sense(srb, ss);
		/* Not Ready - medium not present */
		if ((srb->sense_buf[2] == 0x02) &&
			(srb->sense_buf[12] == 0x3a))
				return -1;
		/* Not Ready - need initialise command (start unit) */
		if ((srb->sense_buf[2] == 0x02) &&
			(srb->sense_buf[12] == 0x04) &&
			(srb->sense_buf[13] == 0x02))
				usb_start_stop_unit(srb, ss, 1);
		mdelay(100);
	}
	while(retries--);
	return -1;
}

/* Limit floppy polling to one command per cycle, because of the time it takes. */
long
poll_floppy_ready(ccb *srb, struct us_data *ss)
{
	static short request_sense = 0;

	if (! request_sense) {
		memset(&srb->cmd[0], 0, 12);
		srb->cmd[0] = SCSI_TST_U_RDY;
		srb->cmd[1] = srb->lun << 5;
		srb->datalen = 0;
		srb->cmdlen = 12;
		srb->direction = USB_CMD_DIRECTION_IN;
		srb->timeout = USB_CNTL_TIMEOUT * 5;
		ss->transport(srb, ss);
		request_sense = 1;
		return 1;
	}else {
		usb_request_sense(srb, ss);
		request_sense = 0;
		if (srb->sense_buf[12] == 0x00 || srb->sense_buf[12] == 0x28)
			return 0;
		else
			return -1;
	}
}

static long
usb_mode_sense_10(ccb *srb, struct us_data *ss, unsigned char pagecode, unsigned char subpagecode, unsigned short len)
{
	long retry;
	/* XXX retries */
	retry = 3;
	DEBUG(("usb_mode_sense_10()"));
	do
	{
		memset(&srb->cmd[0], 0, 12);
		srb->cmd[0] = SCSI_MODE_SEN10;
		srb->cmd[1] = srb->lun << 5;
		srb->cmd[2] = pagecode;
		srb->cmd[3] = subpagecode;
		srb->cmd[7] = ((unsigned char) (len >> 8)) & 0xff;
		srb->cmd[8] = ((unsigned char) (len)) & 0xff;
		srb->datalen = (unsigned long) len;
		srb->cmdlen = 12;
		srb->direction = USB_CMD_DIRECTION_IN;
		srb->timeout = USB_CNTL_TIMEOUT * 5;
		if(ss->transport(srb, ss) == USB_STOR_TRANSPORT_GOOD)
			return 0;
	}
	while(retry--);
	return -1;
}

static long
usb_mode_sense_6(ccb *srb, struct us_data *ss, unsigned char pagecode, unsigned char subpagecode, unsigned char len)
{
	long retry;
	/* XXX retries */
	retry = 3;
	DEBUG(("usb_mode_sense_6()"));
	do
	{
		memset(&srb->cmd[0], 0, 12);
		srb->cmd[0] = SCSI_MODE_SEN6;
		srb->cmd[2] = pagecode;
		srb->cmd[3] = subpagecode;
		srb->cmd[4] = len;
		srb->datalen = (unsigned long) len;
		srb->cmdlen = 12;
		srb->direction = USB_CMD_DIRECTION_IN;
		srb->timeout = USB_CNTL_TIMEOUT * 5;
		if(ss->transport(srb, ss) == USB_STOR_TRANSPORT_GOOD)
			return 0;
	}
	while(retry--);
	return -1;
}

static long
usb_read_capacity(ccb *srb, struct us_data *ss)
{
	long retry;
	/* XXX retries */
	retry = 3;
	DEBUG(("usb_read_capacity()"));
	do
	{
		memset(&srb->cmd[0], 0, 12);
		srb->cmd[0] = SCSI_RD_CAPAC;
		srb->cmd[1] = srb->lun << 5;
		srb->datalen = 8;
		srb->cmdlen = 12;
		srb->direction = USB_CMD_DIRECTION_IN;
		srb->timeout = USB_CNTL_TIMEOUT * 5;
		if(ss->transport(srb, ss) == USB_STOR_TRANSPORT_GOOD)
			return 0;
	}
	while(retry--);
	return -1;
}

static inline long
usb_read_10(ccb *srb, struct us_data *ss, unsigned long start, unsigned short blocks)
{
	memset(&srb->cmd[0], 0, 12);
	srb->cmd[0] = SCSI_READ10;
	srb->cmd[1] = srb->lun << 5;
	srb->cmd[2] = ((unsigned char) (start >> 24)) & 0xff;
	srb->cmd[3] = ((unsigned char) (start >> 16)) & 0xff;
	srb->cmd[4] = ((unsigned char) (start >> 8)) & 0xff;
	srb->cmd[5] = ((unsigned char) (start)) & 0xff;
	srb->cmd[7] = ((unsigned char) (blocks >> 8)) & 0xff;
	srb->cmd[8] = (unsigned char) blocks & 0xff;
	srb->cmdlen = 12;
	srb->direction = USB_CMD_DIRECTION_IN;
	srb->timeout = USB_CNTL_TIMEOUT * 5;
	DEBUG(("read10: start %lx blocks %x", start, blocks));
	return ss->transport(srb, ss);
}

static inline long
usb_write_10(ccb *srb, struct us_data *ss, unsigned long start, unsigned short blocks)
{
	memset(&srb->cmd[0], 0, 12);
	srb->cmd[0] = SCSI_WRITE10;
	srb->cmd[1] = srb->lun << 5;
	srb->cmd[2] = ((unsigned char) (start >> 24)) & 0xff;
	srb->cmd[3] = ((unsigned char) (start >> 16)) & 0xff;
	srb->cmd[4] = ((unsigned char) (start >> 8)) & 0xff;
	srb->cmd[5] = ((unsigned char) (start)) & 0xff;
	srb->cmd[7] = ((unsigned char) (blocks >> 8)) & 0xff;
	srb->cmd[8] = (unsigned char) blocks & 0xff;
	srb->cmdlen = 12;
	srb->direction = USB_CMD_DIRECTION_OUT;
	srb->timeout = USB_CNTL_TIMEOUT * 5;
	DEBUG(("write10: start %lx blocks %x", start, blocks));
	return ss->transport(srb, ss);
}

#ifdef CONFIG_USB_BIN_FIXUP
/*
 * Some USB storage devices queried for SCSI identification data respond with
 * binary strings, which if output to the console freeze the terminal. The
 * workaround is to modify the vendor and product strings read from such
 * device with proper values (as reported by 'usb info').
 *
 * Vendor and product length limits are taken from the definition of
 * block_dev_desc_t in include/part.h.
 */
static void
usb_bin_fixup(struct usb_device_descriptor descriptor, unsigned char vendor[], unsigned char product[])
{
	const unsigned char max_vendor_len = 40;
	const unsigned char max_product_len = 20;
	if(descriptor.idVendor == 0x0424 && descriptor.idProduct == 0x223a)
	{
		strncpy((char *)vendor, "SMSC", max_vendor_len);
		strncpy((char *)product, "Flash Media Cntrller", max_product_len);
	}
}
#endif /* CONFIG_USB_BIN_FIXUP */

static long
error_no(unsigned char asc)
{
	switch (asc) {
		case 0x00 : return 0;
		case 0x02 : return ESPIPE;
		case 0x03 : return EWRITE;
		case 0x04 : return EBUSY;
		case 0x0C : return EWRITE;
		case 0x10 : return ECRC;
		case 0x11 : return EREAD;
		case 0x20 : return EUKCMD;
		case 0x27 : return EROFS;
		case 0x28 : return ECHMEDIA;
		case 0x3A : return ENOMEDIUM;
		default : return EIO;
	}
}

#define USB_MAX_READ_BLK 65535 /* SCSI command read/write(10) max. block transfer */
/* returns block count or negative error code */
long
usb_stor_read(long device, unsigned long blknr, unsigned long blkcnt, void *buffer)
{
	unsigned long start, blks;
	unsigned short smallblks;
	unsigned char *buf_addr = buffer;
	struct us_data *ss;
	struct usb_device *dev;
	long retry;
	long error_code = 0;
	ccb srb;


	if(blkcnt == 0)
		return 0;

	device &= 0xff;
	/* Setup  device */
	DEBUG(("usb_read: dev %ld ", device));
	dev = usb_dev_desc[device].priv;
	ss = (struct us_data *)dev->privptr;
	usb_disable_asynch(1); /* asynch transfer not allowed */
	srb.lun = usb_dev_desc[device].lun;
	start = blknr;
	blks = blkcnt;

	DEBUG(("usb_read: dev %ld startblk %lx, blccnt %lx buffer %lx", device, start, blks, (long)buf_addr));

	do
	{
		/* XXX need some comment here */
		retry = 2;
		if(blks > USB_MAX_READ_BLK)
			smallblks = USB_MAX_READ_BLK;
		else
			smallblks = (unsigned short) blks;
retry_it:
		srb.datalen = usb_dev_desc[device].blksz * smallblks;
		srb.pdata = buf_addr;
		if(usb_read_10(&srb, ss, start, smallblks))
		{
			DEBUG(("Read ERROR"));

			if (ss->protocol != US_PR_CB)
				usb_request_sense(&srb, ss);
			error_code = error_no(srb.sense_buf[12]);

			if (retry-- && ! error_code)
				goto retry_it;

			memset(srb.pdata, 0xaa, srb.datalen);
			blkcnt -= blks;
			break;
		}
		start += smallblks;
		blks -= smallblks;
		buf_addr += srb.datalen;
	}
	while(blks != 0);
	DEBUG(("usb_read: end startblk %lx, blccnt %x buffer %lx", start, smallblks, (long)buf_addr));
	usb_disable_asynch(0); /* asynch transfer allowed */
	return (error_code)?error_code:blkcnt;
}

long
usb_stor_write(long device, unsigned long blknr, unsigned long blkcnt, void *buffer)
{
	unsigned long start, blks;
	unsigned short smallblks;
	unsigned char *buf_addr = buffer;
	struct us_data *ss;
	struct usb_device *dev;
	long retry;
	long error_code = 0;
	ccb srb;
	
	if(blkcnt == 0)
		return 0;
	device &= 0xff;
	/* Setup  device */
	DEBUG(("usb_write: dev %ld ", device));
	dev = usb_dev_desc[device].priv;
	ss = (struct us_data *)dev->privptr;
	usb_disable_asynch(1); /* asynch transfer not allowed */
	srb.lun = usb_dev_desc[device].lun;
	start = blknr;
	blks = blkcnt;

	DEBUG(("usb_write: dev %ld startblk %lx, blccnt %lx buffer %lx", device, start, blks, (long)buf_addr));

	do
	{
		/* XXX need some comment here */
		retry = 2;
		if(blks > USB_MAX_READ_BLK)
			smallblks = USB_MAX_READ_BLK;
		else
			smallblks = (unsigned short)blks;
retry_it:
		srb.datalen = usb_dev_desc[device].blksz * smallblks;
		srb.pdata = buf_addr;
		
		if(usb_write_10(&srb, ss, start, smallblks))
		{
			DEBUG(("Write ERROR"));

			if (ss->protocol != US_PR_CB)
				usb_request_sense(&srb, ss);
			error_code = error_no(srb.sense_buf[12]);

			if (retry-- && ! error_code)
				goto retry_it;

			memset(srb.pdata, 0xaa, srb.datalen);
			blkcnt -= blks;
			break;
		}
		start += smallblks;
		blks -= smallblks;
		buf_addr += srb.datalen;
	}
	while(blks != 0);
	DEBUG(("usb_write: end startblk %lx, blccnt %x buffer %lx", start, smallblks, (long)buf_addr));
	usb_disable_asynch(0); /* asynch transfer allowed */

	return (error_code)?error_code:blkcnt;
}

/* Probe to see if a new device is actually a Storage device */
long
usb_stor_probe(struct usb_device *dev, unsigned int ifnum, struct us_data *ss)
{
	struct usb_interface *iface;
	struct usb_endpoint_descriptor *ep_desc;
	long i;
	unsigned long flags = 0;
	long protocol = 0;
	long subclass = 0;

	/* let's examine the device now */
	iface = &dev->config.if_desc[ifnum];

	DEBUG(("iVendor 0x%x iProduct 0x%x", dev->descriptor.idVendor, dev->descriptor.idProduct));

	/* Patch devices....
	*/

	/* Floppy drives seem to cause problems with CBI transport. Use CB instead. */
	if ((iface->desc.bInterfaceProtocol == US_PR_CBI) && (iface->desc.bInterfaceSubClass == US_SC_UFI))
	{
		protocol = US_PR_CB;
		subclass = US_SC_UFI;
	}

	if (dev->descriptor.bDeviceClass != 0 ||
			iface->desc.bInterfaceClass != USB_CLASS_MASS_STORAGE ||
			iface->desc.bInterfaceSubClass < US_SC_MIN ||
			iface->desc.bInterfaceSubClass > US_SC_MAX) {
		/* if it's not a mass storage, we go no further */
		return 0;
	}
	memset(ss, 0, sizeof(struct us_data));
	/* At this point, we know we've got a live one */
	DEBUG(("USB Mass Storage device detected"));
	DEBUG(("Protocol: %x SubClass: %x", iface->desc.bInterfaceProtocol,
					    iface->desc.bInterfaceSubClass ));
	/* Initialize the us_data structure with some useful info */
	ss->flags = flags;
	ss->ifnum = ifnum;
	ss->pusb_dev = dev;
	ss->attention_done = 0;
	/* If the device has subclass and protocol, then use that.  Otherwise,
	 * take data from the specific interface.
	 */
	if(subclass) {
		ss->subclass = subclass;
		ss->protocol = protocol;
	} else {
		ss->subclass = iface->desc.bInterfaceSubClass;
		ss->protocol = iface->desc.bInterfaceProtocol;
	}
	/* set the handler pointers based on the protocol */
	DEBUG(("Transport: "));
	switch(ss->protocol)
	{
		case US_PR_CB:
			DEBUG(("Control/Bulk"));
			ss->transport = usb_stor_CB_transport;
			ss->transport_reset = usb_stor_CB_reset;
			break;
		case US_PR_CBI:
			DEBUG(("Control/Bulk/Interrupt"));
			ss->transport = usb_stor_CB_transport;
			ss->transport_reset = usb_stor_CB_reset;
			break;
		case US_PR_BULK:
			DEBUG(("Bulk/Bulk/Bulk"));
			ss->transport = usb_stor_BBB_transport;
			ss->transport_reset = usb_stor_BBB_reset;
			break;
		default:
			ALERT(("USB Storage Transport unknown / not yet implemented"));
			return 0;
			break;
	}
	/*
	 * We are expecting a minimum of 2 endpoints - in and out (bulk).
	 * An optional interrupt is OK (necessary for CBI protocol).
	 * We will ignore any others.
	 */
	DEBUG(("Number of endpoints: %d", iface->desc.bNumEndpoints));
	for (i = 0; i < iface->desc.bNumEndpoints; i++) {
		ep_desc = &iface->ep_desc[i];
		/* is it an BULK endpoint? */
		if ((ep_desc->bmAttributes &
			USB_ENDPOINT_XFERTYPE_MASK) == USB_ENDPOINT_XFER_BULK) {
			if (ep_desc->bEndpointAddress & USB_DIR_IN)
				ss->ep_in = ep_desc->bEndpointAddress &
						USB_ENDPOINT_NUMBER_MASK;
			else
				ss->ep_out =
					ep_desc->bEndpointAddress &
					USB_ENDPOINT_NUMBER_MASK;
		}
		/* is it an interrupt endpoint? */
		if ((ep_desc->bmAttributes &
			USB_ENDPOINT_XFERTYPE_MASK) == USB_ENDPOINT_XFER_INT) {
			ss->ep_int = ep_desc->bEndpointAddress &
						USB_ENDPOINT_NUMBER_MASK;
			ss->irqinterval = ep_desc->bInterval;
		}
	}
	DEBUG(("Endpoints In %d Out %d Int %d", ss->ep_in, ss->ep_out, ss->ep_int));
	/* Do some basic sanity checks, and bail if we find a problem */
	if (usb_set_interface(dev, iface->desc.bInterfaceNumber, 0) ||
		!ss->ep_in || !ss->ep_out ||
		(ss->protocol == US_PR_CBI && ss->ep_int == 0)) {
		DEBUG(("Problems with device"));
		return 0;
	}
	/* set class specific stuff */
	/* We only handle certain protocols.  Currently, these are
	 * the only ones.
	 * The SFF8070 accepts the requests used in u-boot
	 */
	if(ss->subclass != US_SC_UFI && 
		ss->subclass != US_SC_SCSI && 
		ss->subclass != US_SC_8020 && 
		ss->subclass != US_SC_8070)
	{
		DEBUG(("Sorry, protocol %d not yet supported.", ss->subclass));
		ALERT(("Sorry, protocol %d not yet supported.", ss->subclass));
		return 0;
	}
	if(ss->ep_int)
	{
		/* we had found an interrupt endpoint, prepare irq pipe
		 * set up the IRQ pipe and handler
		 */
		ss->irqinterval = (ss->irqinterval > 0) ? ss->irqinterval : 255;
		ss->irqpipe = usb_rcvintpipe(ss->pusb_dev, (long)ss->ep_int);
		ss->irqmaxp = usb_maxpacket(dev, ss->irqpipe);
		dev->irq_handle = usb_stor_irq;
	}
	dev->privptr = (void *)ss;
	return 1;
}

long
usb_stor_get_info(struct usb_device *dev, struct us_data *ss, block_dev_desc_t *dev_desc)
{
	unsigned char perq, modi;
	ALLOC_CACHE_ALIGN_BUFFER(unsigned long, cap, 2);
	ALLOC_CACHE_ALIGN_BUFFER(unsigned char, usb_stor_buf, 36);
	unsigned long *capacity, *blksz;
	ccb pccb;
	DEBUG(("usb_stor_get_info()"));

#if 0
	/* for some reasons a couple of devices would not survive this reset */
	if(
	 /* Sony USM256E */
	 (dev->descriptor.idVendor == 0x054c && dev->descriptor.idProduct == 0x019e)
	 /* USB007 Mini-USB2 Flash Drive */
	 || (dev->descriptor.idVendor == 0x066f && dev->descriptor.idProduct == 0x2010)
	 /* SanDisk Corporation Cruzer Micro 20044318410546613953 */
	 || (dev->descriptor.idVendor == 0x0781 && dev->descriptor.idProduct == 0x5151)
	 /* SanDisk Corporation U3 Cruzer Micro 1/4GB Flash Drive 000016244373FFB4 */
	 || (dev->descriptor.idVendor == 0x0781 && dev->descriptor.idProduct == 0x5406)
	)
	{
		DEBUG(("usb_stor_get_info: skipping RESET.."));
	}
	else {
		ss->transport_reset(ss);
	}
#endif

	pccb.pdata = usb_stor_buf;
	dev_desc->priv = dev;
	dev_desc->target = dev->devnum;
	pccb.lun = dev_desc->lun;

	if(usb_inquiry(&pccb, ss)) {
		return -1;
	}
	perq = usb_stor_buf[0];
	modi = usb_stor_buf[1];

	/* skip unknown devices */
	if((perq & 0x1f) == 0x1f) {
		return -1;
	}

	/* drive is removable */
	if((modi&0x80) == 0x80)
		dev_desc->removable = 1;
	memcpy(&dev_desc->vendor[0], &usb_stor_buf[8], 8);
	memcpy(&dev_desc->product[0], &usb_stor_buf[16], 16);
	memcpy(&dev_desc->revision[0], &usb_stor_buf[32], 4);
	dev_desc->vendor[8] = 0;
	dev_desc->product[16] = 0;
	dev_desc->revision[4] = 0;
	DEBUG(("Vendor: %s Rev: %s Prod: %s", dev_desc->vendor, dev_desc->revision, dev_desc->product)); /* Galvez debug temp */
#ifdef CONFIG_USB_BIN_FIXUP
	usb_bin_fixup(dev->descriptor, (uchar *)dev_desc->vendor, (uchar *)dev_desc->product);
#endif /* CONFIG_USB_BIN_FIXUP */
	DEBUG(("ISO Vers %x, Response Data %x", usb_stor_buf[2], usb_stor_buf[3]));
	if(usb_test_unit_ready(&pccb, ss))
	{
		DEBUG(("Device NOT ready\r\n   Request Sense returned %02x %02x %02x", pccb.sense_buf[2], pccb.sense_buf[12], pccb.sense_buf[13]));
		if(dev_desc->removable == 1)
		{
			dev_desc->type = perq;
		}
		return 0;
	}

	pccb.pdata = (unsigned char *)&cap[0];
	memset(pccb.pdata, 0, 8);
	if(usb_read_capacity(&pccb, ss) != 0)
	{
		DEBUG(("READ_CAP ERROR"));
		cap[0] = 2880;
		cap[1] = 0x200;
	}
	DEBUG(("Read Capacity returns: 0x%lx, 0x%lx", cap[0], cap[1]));
# if 0
	if(cap[0] > (0x200000 * 10)) /* greater than 10 GByte */
		cap[0] >>= 16;
# endif
	cap[0] = cpu2be32(cap[0]);
	cap[1] = cpu2be32(cap[1]);
	/* this assumes bigendian! */
	cap[0] += 1;
	capacity = &cap[0];
	blksz = &cap[1];
	DEBUG(("Capacity = 0x%lx, blocksz = 0x%lx", *capacity, *blksz));
	dev_desc->lba = *capacity;
	dev_desc->blksz = *blksz;
	dev_desc->type = perq;
	dev_desc->ready = 1;

	/* write-protection */
	/* request 8 bytes, the size of the mode parameter header
	 * write protection support is enabled just by getting the header
	 * bit 7 of byte 3 set to 1 indicate write protected
	 *
	 * like Linux we use MODE SENSE (6) if the subclass is Transparent SCSI
	 * as some USB sticks are known to fail otherwise
	 * in contrast, USB floppy drives (UFI subclass) want MODE SENSE (10)
	 */
	if ((dev_desc->type == DEV_TYPE_HARDDISK) && (ss->subclass == US_SC_SCSI))
		usb_mode_sense_6(&pccb, ss, 0x3F, 0x00, 8);
	else
		usb_mode_sense_10(&pccb, ss, 0x3F, 0x00, 8);

#if 0 /* Why? */
	init_part(dev_desc);
	DEBUG(("partype: %d", dev_desc->part_type));
#endif
	return 1;
}

void
usb_stor_reset(long i)
{
	memset(&usb_dev_desc[i], 0, sizeof(block_dev_desc_t));
	usb_dev_desc[i].target = 0xff;
	usb_dev_desc[i].lun = 0xff;
	usb_dev_desc[i].if_type = IF_TYPE_USB;
	usb_dev_desc[i].usb_logdrv = i;
	usb_dev_desc[i].usb_phydrv = 0xff;
	usb_dev_desc[i].part_type = PART_TYPE_UNKNOWN;
	usb_dev_desc[i].type = DEV_TYPE_UNKNOWN;
	usb_dev_desc[i].ready = 0;
	usb_dev_desc[i].removable = 0;
	usb_dev_desc[i].block_read = usb_stor_read;
	usb_dev_desc[i].block_write = usb_stor_write;
}

void
usb_stor_eject(long device)
{
#ifndef TOSONLY
	long usb_phydrv = usb_dev_desc[device].usb_phydrv;
#endif
	long lun = usb_dev_desc[device].lun;
	char product[20+1];
	long i = 0, f = 0;

	for (i = 0; i < MAX_TOTAL_LUN_NUM; i++) {
		if ((usb_dev_desc[i].lun == lun) && (usb_dev_desc[i].usb_logdrv == device)) {
			usb_dev_desc[i].sw_ejected = 1;
			f = 1;
		}
	}

	if (!f)
	{
		DEBUG(("USB mass storage device was already ejected"));
		return;
	}

	long idx = bios_part[device].partnum;
	while (idx > 0) {
		uninstall_usb_stor(bios_part[device].biosnum[idx - 1]);
		idx--;
	}
	bios_part[device].partnum = 0;

	strncpy(product, usb_dev_desc[device].product, PRODUCT_STRING_LENGTH);
#ifndef TOSONLY
	ALERT(("USB Mass Storage Device (%ld) LUN (%ld) ejected: %s", usb_phydrv, lun, product));
#endif
}


/*******************************************************************************
 * 
 * 
 */
static long
storage_disconnect(struct usb_device *dev)
{
	long i, f = 0, how_many_luns = 0;

	for (i = 0; i < USB_MAX_STOR_DEV; i++)
	{
		if (dev->devnum == mass_storage_dev[i].target)
			mass_storage_dev[i].target = 0xff;
	}

	for (i = 0; i < MAX_TOTAL_LUN_NUM; i++)
	{
		if (dev->devnum == usb_dev_desc[i].target)
		{
			usb_stor_reset(i);

			long idx;
			for (idx = 1; idx <= bios_part[i].partnum; idx++) {
				uninstall_usb_stor(bios_part[i].biosnum[idx - 1]);
			}
			how_many_luns++;
			bios_part[i].partnum = 0;
			f = 1;
		}
	}

	if (!f)
	{
		/* Probably the device has been already disconnected by software (XHEject) */
		DEBUG(("USB mass storage device was already disconnected"));
		return -1;
	}

	if (how_many_luns > 1)
		num_multilun_dev--;

	ALERT(("USB Storage Device disconnected: (%ld) %s", dev->devnum, dev->prod));

	return 0;
}


/*******************************************************************************
 * 
 * 
 */
static long
storage_probe(struct usb_device *dev, unsigned int ifnum)
{
	long i, r, lun, lun_global_num;
	bool device_handled = FALSE;

	if(dev == NULL)
		return -1;
	
	for (i = 0; i < USB_MAX_STOR_DEV; i++)
	{
		if (mass_storage_dev[i].target == 0xff)
		{
			break;
		}
	}

	/* if storage device */
	if(i == USB_MAX_STOR_DEV)
	{
		ALERT(("Max USB Storage Device reached: %d stopping", USB_MAX_STOR_DEV));
		return -1;
	}

	usb_disable_asynch(1); /* asynch transfer not allowed */

	if(!usb_stor_probe(dev, ifnum, &mass_storage_dev[i].usb_stor)) {
		usb_disable_asynch(0); /* asynch transfer allowed */
		return -1; /* It's not a storage device */
	}

	mass_storage_dev[i].target = dev->devnum;

	for (lun_global_num = 0; i < MAX_TOTAL_LUN_NUM; lun_global_num++)
	{
		if (usb_dev_desc[lun_global_num].target == 0xff)
		{
			break;
		}
	}

	mass_storage_dev[i].total_lun = usb_get_max_lun(&mass_storage_dev[i].usb_stor);

	for (lun = 0;
		lun <= mass_storage_dev[i].total_lun &&
		lun < MAX_LUN_NUM_PER_DEV &&
		lun_global_num < MAX_TOTAL_LUN_NUM;
		lun++) {
		/* ok, it is a storage device
		 * get info and fill it in
		 */
		usb_dev_desc[lun_global_num].lun = lun;
		r = usb_stor_get_info(dev, &mass_storage_dev[i].usb_stor, &usb_dev_desc[lun_global_num]);
		if(r < 0) {
			/* There was an error, invalidate entry */
				usb_stor_reset(lun_global_num);
				continue;
		}


		//dev_print(&usb_dev_desc[lun_global_num]);
#if 0
		if(ss->subclass == US_SC_UFI)
		{
			DEBUG(("detected USB floppy not supported at this time\r\n"));
			/* This is a floppy drive, so give it a drive letter ? B ?. */
			/* Also, we may be better to intercept the TRAP #1 floppy handlers
			 * and deal with them here. ??? */
			//usb_stor_reset(lun_global_num);
			//continue;
		}

		/* Skip everything apart from HARDDISKS and CDROM */
		if((usb_dev_desc[lun_global_num].type & 0x1f) != DEV_TYPE_HARDDISK
		   && (usb_dev_desc[lun_global_num].type & 0x1f) != DEV_TYPE_CDROM) {
/*
		c_conws(usb_dev_desc[lun_global_num].vendor);
		c_conout(' ');
		c_conws(usb_dev_desc[lun_global_num].product);
		c_conout(' ');
		c_conws(", type : ");
		hex_long(usb_dev_desc[lun_global_num].type & 0x1f);
		c_conws(" not installed\r\n");
*/
			//usb_stor_reset(lun_global_num);
			//continue;
		}
#endif
		usb_dev_desc[lun_global_num].usb_phydrv = i;
		mass_storage_dev[i].usb_dev_desc[lun] = &usb_dev_desc[lun_global_num];

		if (r > 0) /* Only init partitions when LUN is ready */
			part_init(lun_global_num, &usb_dev_desc[lun_global_num]);

		device_handled = TRUE;

		do {
			lun_global_num++;
		} while (usb_dev_desc[lun_global_num].target != 0xff && lun_global_num < MAX_TOTAL_LUN_NUM);
	}

	/* Poll multi-LUN device and floppy drive */
	if ((mass_storage_dev[i].total_lun > 0 ||
		 (enable_flop_mediach && mass_storage_dev[i].usb_stor.subclass == US_SC_UFI)) && device_handled)
		init_polling();

	usb_disable_asynch(0); /* asynch transfer allowed */

	if (device_handled)
		return 0;
	else
		return -1;
}

void
usb_storage_init(void)
{
	unsigned char i;

	for (i = 0; i < USB_MAX_STOR_DEV; i++)
	{
		mass_storage_dev[i].target = 0xff;
	}

	for(i = 0; i < MAX_TOTAL_LUN_NUM; i++)
	{
		usb_stor_reset(i);
	}
}

#define AHDI        0x41484449L     /* 'AHDI' */
extern USB_PUN_INFO pun_usb;                                //xhdi.c
#define PUN_PTR	(*((PUN_INFO **) 0x516L))

#ifdef TOSONLY
/*
 * the following routine is stolen from FreeMiNT's pun.c module
 */
#define bufl0	(*(BCB **)0x4b2L)
#define bufl1	(*(BCB **)0x4b6L)

#define BCB	struct _bcb
BCB
{
	BCB		*b_link;	/* next bcb (API)          */
	char	filler[12];	/* not relevant            */
	char	*b_bufr;	/* pointer to buffer (API) */
};

static PUN_INFO pun_ahdi;

/*
 * this routine checks if an AHDI structure exists.  if it does, and it
 * is suitable, its address is returned.  otherwise, this routine installs
 * a new one and returns that address.
 *
 * it assumes that the existing buffer pool uses 512-byte buffers (the
 * logical sector size for floppies), unless an AHDI structure with a
 * version number of 3.00 or greater exists.  in this case, the size of
 * the existing buffers is taken from the existing AHDI structure.
 */
static PUN_INFO *install_pun(void)
{
	PUN_INFO *pun;
	BCB *bcb;
	long bufsiz, bufcnt = 0L;
	long old_bufsiz = 512L;
	char *bufptr;

	bufsiz = XHDOSLimits(XH_DL_SECSIZ,0);

	memset(&pun_ahdi,0x00,sizeof(PUN_INFO));
	memset(&pun_ahdi.pun,0xff,16); 

	pun = PUN_PTR;
	if (pun)
		if (pun->cookie == AHDI)
			if (pun->cookie_ptr == &(pun->cookie))
				if (pun->version_num >= 0x300)
					old_bufsiz = pun->max_sect_siz;

	/* see if we can use the existing buffer pool */
	if (bufsiz <= old_bufsiz)
		return pun;

	/*
	 * allocate new buffers for BCB chains
	 */
	for (bcb = bufl0; bcb; bcb = bcb->b_link)
		bufcnt++;
	for (bcb = bufl1; bcb; bcb = bcb->b_link)
		bufcnt++;
	bufptr = (char *)kmalloc(bufcnt*bufsiz);
	if (!bufptr)
		return NULL;
	memset(bufptr, 0, bufcnt*bufsiz);

	pun = &pun_ahdi;
	pun->cookie = AHDI;
	pun->cookie_ptr = &pun->cookie;
	pun->version_num = 0x0300;
	pun->max_sect_siz = bufsiz;
	PUN_PTR = pun;

	/*
	 * copy existing buffers to new ones, updating the BCBs
	 */
	for (bcb = bufl0; bcb; bcb = bcb->b_link) {
		memcpy(bufptr,bcb->b_bufr,old_bufsiz);
		bcb->b_bufr = bufptr;
		bufptr += bufsiz;
	}
	for (bcb = bufl1; bcb; bcb = bcb->b_link) {
		memcpy(bufptr,bcb->b_bufr,old_bufsiz);
		bcb->b_bufr = bufptr;
		bufptr += bufsiz;
	}

	return pun;
}
#endif

PUN_INFO *get_pun(void)
{
	PUN_INFO *pun;
#ifdef TOSONLY
	long ret = 0;
#endif

#ifndef TOSONLY
	pun = PUN_PTR;
	if (pun)
		if (pun->cookie == AHDI)
			if (pun->cookie_ptr == &(pun->cookie))
				if (pun->version_num >= 0x300) {
					return pun;
				}
	return NULL;
#else
	/* goto supervisor mode because of drvbits & handlers */
	if (!Super(1L))
		ret = Super(0L);

	/*
	 * install PUN_INFO if necessary (i.e. no hard disk driver loaded)
	 */
	pun = install_pun();

	if (ret)
		SuperToUser(ret);

	return pun;
#endif
}

#ifdef TOSONLY
int init(void);
int
init (void)
#else
long _cdecl	init			(struct kentry *, struct usb_module_api *, long, long);
long _cdecl
init (struct kentry *k, struct usb_module_api *uapi, long arg, long reason)
#endif
{
	PUN_INFO *pun_ptr;
	long ret;

#ifndef TOSONLY
	kentry	= k;
	api	= uapi;

	if (check_kentry_version())
		return -1;
#endif

	c_conws (MSG_BOOT);
	c_conws (MSG_GREET);
	DEBUG (("%s: enter init", __FILE__));

#ifdef TOSONLY
	/* GET _USB COOKIE to REGISTER */
	if (!getcookie(_USB, (long *)&api)) {
		(void)Cconws("STORAGE failed to get _USB cookie\r\n");
		return -1;
	}
	/* for precise mdelay/udelay relative to CPU power */
	set_tos_delay();

	/* Are we running on MagiC */
	MagiC = InqMagX();
#endif

	pun_ptr = get_pun();
	if (!pun_ptr) {
#ifdef TOSONLY
		c_conws("Failed to initialize, out of memory\r\n");
#else
		c_conws("Failed to initialize, PUN info not available.\r\n");
#endif
		return -1;
	}

	/*
	 * install PUN_INFO if necessary
	 */
	if (pun_usb.cookie != AHDI) {
		pun_usb.cookie = AHDI;
		pun_usb.cookie_ptr = &pun_usb.cookie;
		pun_usb.puns = 0;
		pun_usb.version_num = 0x0300;
		pun_usb.max_sect_siz = pun_ptr->max_sect_siz;
		memset(pun_usb.pun,0xff,dl_maxdrives); /* mark all puns invalid */
	}

	/* Allocate memory for copy of BPBs in globally accessible memory. */
	/* Note: usb_get_bpb will check for NULL prior to using this. */
#ifndef TOSONLY
	usb_global_bpb = (BPB*)m_xalloc(MAX_LOGICAL_DRIVE * sizeof(BPB), 0x20|0);
#else
	usb_global_bpb = NULL;
#endif

	usb_storage_init();

	ret = udd_register(&storage_uif);
	if (ret)
	{
		DEBUG (("%s: udd register failed!", __FILE__));
		return -1;
	}

#ifdef TOSONLY
	if (!Super(1L))
		ret = Super(0L);
#endif
	install_vectors();
	install_xhdi_driver();
	install_scsidrv();

	DEBUG (("%s: udd register ok", __FILE__));

#ifdef TOSONLY
	if (ret)
		SuperToUser(ret);

	c_conws("USB storage driver installed.\r\n");

	Ptermres(_PgmSize,0);
#endif

	return 0;
}
