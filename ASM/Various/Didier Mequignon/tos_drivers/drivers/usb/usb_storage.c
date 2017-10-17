/*
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
 * See file CREDITS for list of people who contributed to this
 * project.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
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
/*
 * New Note:
 * Support for USB Mass Storage Devices (BBB) has been added. It has
 * only been tested with USB memory sticks.
 */

#include "config.h"
#include "usb.h"
#include "scsi.h"

#define CONFIG_USB_WRITE_ENABLE

#undef USB_STOR_DEBUG
#undef BBB_COMDAT_TRACE
#undef BBB_XPORT_TRACE

#if defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)
#ifdef CONFIG_USB_STORAGE

#ifdef	USB_STOR_DEBUG
#define USB_STOR_PRINTF(fmt, args...)	board_printf(fmt , ##args)
#else
#define USB_STOR_PRINTF(fmt, args...)
#endif

extern void udelay(long usec);
extern long install_usb_stor(int dev_num, unsigned long part_type, unsigned long part_offset, unsigned long part_size, char *vendor, char *revision, char *product);
extern void uninstall_usb_stor(int dev_num);

/* direction table -- this indicates the direction of the data
 * transfer for each command code -- a 1 indicates input
 */
unsigned char us_direction[256/8] = {
	0x28, 0x81, 0x14, 0x14, 0x20, 0x01, 0x90, 0x77,
	0x0C, 0x20, 0x00, 0x04, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x01,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
};
#define US_DIRECTION(x) ((us_direction[x>>3] >> (x & 7)) & 1)

static unsigned char *usb_stor_buf;
static ccb usb_ccb;
static short drive_ok_usb;

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
typedef struct {
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
typedef struct {
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

#define USB_MAX_STOR_DEV 5
static int usb_max_devs; /* number of highest available usb device */

static block_dev_desc_t usb_dev_desc[USB_MAX_STOR_DEV];

struct us_data;
typedef int (*trans_cmnd)(ccb *cb, struct us_data *data);
typedef int (*trans_reset)(struct us_data *data);

struct us_data {
	struct usb_device *pusb_dev;	 /* this usb_device */

	unsigned int	flags;			/* from filter initially */
	unsigned char	ifnum;			/* interface number */
	unsigned char	ep_in;			/* in endpoint */
	unsigned char	ep_out;			/* out ....... */
	unsigned char	ep_int;			/* interrupt . */
	unsigned char	subclass;		/* as in overview */
	unsigned char	protocol;		/* .............. */
	unsigned char	attention_done;		/* force attn on first cmd */
	unsigned short	ip_data;		/* interrupt data */
	int		action;			/* what to do */
	int		ip_wanted;		/* needed */
	int		*irq_handle;		/* for USB int requests */
	unsigned int	irqpipe;	 	/* pipe for release_irq */
	unsigned char	irqmaxp;		/* max packed for irq Pipe */
	unsigned char	irqinterval;		/* Intervall for IRQ Pipe */
	ccb		*srb;			/* current srb */
	trans_reset	transport_reset;	/* reset routine */
	trans_cmnd	transport;		/* transport routine */
};

static struct us_data usb_stor[USB_MAX_STOR_DEV];

#define USB_STOR_TRANSPORT_GOOD	   0
#define USB_STOR_TRANSPORT_FAILED -1
#define USB_STOR_TRANSPORT_ERROR  -2

#define DEFAULT_SECTOR_SIZE 512
#define GEMDOS_PART_TBL_OFFSET 0x1c6
#define DOS_PART_TBL_OFFSET	0x1be
#define DOS_PART_MAGIC_OFFSET	0x1fe
#define DOS_PBR_FSTYPE_OFFSET	0x36
#define DOS_PBR_MEDIA_TYPE_OFFSET	0x15
#define DOS_MBR	0
#define DOS_PBR	1
#define DOS_FS_TYPE_OFFSET 0x36

typedef struct gemdos_partition {
	unsigned char boot_ind;		/* 0x01 - active	*/
	unsigned char id[3];      /* partition type	*/
	unsigned char start4[4];	/* starting sector counting from 0 */
	unsigned char size4[4];		/* nr of sectors in partition	*/
} gemdos_partition_t;

typedef struct dos_partition {
	unsigned char boot_ind;   /* 0x80 - active */
	unsigned char head;       /* starting head */
	unsigned char sector;     /* starting sector */
	unsigned char cyl;        /* starting cylinder */
	unsigned char sys_ind;    /* What partition type */
	unsigned char end_head;   /* end head */
	unsigned char end_sector; /* end sector */
	unsigned char end_cyl;    /* end cylinder */
	unsigned char start4[4];  /* starting sector counting from 0 */
	unsigned char size4[4];   /* nr of sectors in partition */
} dos_partition_t;

typedef struct disk_partition {
	unsigned long type;
	unsigned long	start; /* # of first block in partition	*/
	unsigned long	size;  /* number of blocks in partition	*/
	unsigned long	blksz; /* block size in bytes			*/
} disk_partition_t;

extern unsigned long swap_long(unsigned long val);
#define le32_to_int(a) (int)swap_long(*(unsigned long *)a)

int usb_stor_get_info(struct usb_device *dev, struct us_data *us, block_dev_desc_t *dev_desc);
int usb_storage_probe(struct usb_device *dev, unsigned int ifnum, struct us_data *ss);
long usb_stor_read(int device, unsigned long blknr, unsigned long blkcnt, void *buffer);
long usb_stor_write(int device, unsigned long blknr, unsigned long blkcnt, const void *buffer);
void uhci_show_temp_int_td(void);

block_dev_desc_t *usb_stor_get_dev(int index)
{
	return(index < USB_MAX_STOR_DEV) ? &usb_dev_desc[index] : NULL;
}

void init_part(block_dev_desc_t *dev_desc)
{
	int i;
	unsigned char *buffer = (unsigned char *)usb_malloc(DEFAULT_SECTOR_SIZE);
	unsigned short *p = (unsigned short *)buffer;
	unsigned short sum;
	if(buffer == NULL)
		return;
	if(dev_desc->block_read(dev_desc->dev, 0, 1, (unsigned long *)buffer) != 1)
	{
		usb_free(buffer);
		return;
	}
#ifdef USB_STOR_DEBUG			
	for(i = 0; i < DEFAULT_SECTOR_SIZE; i++)
	{
		if((i & 15) == 0)
			board_printf("\r\n%04X ", i);
		board_printf("%02X ", buffer[i]);
		if((i & 15) == 15)
		{
			int k;
			for(k = i-15; k <= i; k++)
			{
				if(buffer[k] < ' ' || buffer[k] >= 127)
					board_printf(".");
				else 
					board_printf("%c", buffer[k]);
			}
		}
	}
	board_printf("\r\n");	
#endif
	sum = 0;
	for(i = 0; i < DEFAULT_SECTOR_SIZE/2; i++)
		sum += *p++;
	if(sum == 0x1234)
	{
		dev_desc->part_type = PART_TYPE_GEMDOS;
		USB_STOR_PRINTF("GEMDOS partition table found\r\n");
	}	
	else if((buffer[DOS_PART_MAGIC_OFFSET] == 0x55) && (buffer[DOS_PART_MAGIC_OFFSET + 1] == 0xaa))
	{
		dev_desc->part_type = PART_TYPE_DOS;
		USB_STOR_PRINTF("DOS partition table found\r\n");
	}
	usb_free(buffer);
}

static inline int is_extended(int part_type)
{
	return(part_type == 0x5 || part_type == 0xf || part_type == 0x85);
}

/*  Print a partition that is relative to its Extended partition table
 */
static int get_partition_info_extended(block_dev_desc_t *dev_desc, int ext_part_sector, int relative, int part_num, int which_part, disk_partition_t *info)
{
	int i;
	gemdos_partition_t *gpt;
	dos_partition_t *pt;
	unsigned char *buffer = (unsigned char *)usb_malloc(DEFAULT_SECTOR_SIZE);
	if(buffer == NULL)
		return -1;
	if(dev_desc->block_read(dev_desc->dev, ext_part_sector, 1, (unsigned long *)buffer) != 1)
	{
		USB_STOR_PRINTF("Can't read partition table on %d:%d\r\n", dev_desc->dev, ext_part_sector);
		usb_free(buffer);
		return -1;
	}
	switch(dev_desc->part_type)
	{
		case PART_TYPE_GEMDOS:
			gpt = (gemdos_partition_t *)(buffer + GEMDOS_PART_TBL_OFFSET);
			for(i = 0; i < (relative ? 2 : 4); i++, gpt++)
			{
				unsigned long type = ((unsigned long)gpt->boot_ind << 24) + ((unsigned long)gpt->id[0] << 16) + ((unsigned long)gpt->id[1] << 8) + (unsigned long)gpt->id[2];
				if((type & 0xffffff) == 0x58474D) // XGM
				{
					int lba_start = (int)*(unsigned long *)gpt->start4;
					usb_free(buffer);
					return get_partition_info_extended(dev_desc, lba_start, lba_start, part_num, which_part, info);
				}
				if(((type & 0xffffff) != 0) && (part_num == which_part))
				{
					info->type = type;
					info->blksz = 512;
					info->start = *(unsigned long *)gpt->start4;
					info->size = *(unsigned long *)gpt->size4;
					USB_STOR_PRINTF("GEMDOS partition at offset 0x%x, size 0x%x, type 0x%x\r\n", info->start, info->size, info->type & 0xffffff);
					usb_free(buffer);
					return 0;
				}	
			}
			break;
		case PART_TYPE_DOS:
			pt = (dos_partition_t *)(buffer + DOS_PART_TBL_OFFSET);
			for(i = 0; i < 4; i++, pt++)
			{
				/* fdisk does not show the extended partitions that are not in the MBR */
				if((pt->sys_ind != 0) && (part_num == which_part) && (is_extended(pt->sys_ind) == 0))
				{
					info->type = (unsigned long)pt->sys_ind;
					info->blksz = 512;
					info->start = ext_part_sector + le32_to_int(pt->start4);
					info->size = le32_to_int(pt->size4);
					USB_STOR_PRINTF("DOS partition at offset 0x%x, size 0x%x, type 0x%x %s\r\n", info->start, info->size, pt->sys_ind, (is_extended(pt->sys_ind) ? " Extd" : ""));
					usb_free(buffer);
					return 0;
				}
				/* Reverse engr the fdisk part# assignment rule! */
				if((ext_part_sector == 0) || (pt->sys_ind != 0 && !is_extended (pt->sys_ind)))
					part_num++;
			}
			/* Follows the extended partitions */
			pt = (dos_partition_t *)(buffer + DOS_PART_TBL_OFFSET);
			for(i = 0; i < 4; i++, pt++)
			{
				if(is_extended(pt->sys_ind))
				{
					int lba_start = le32_to_int(pt->start4) + relative;
					usb_free(buffer);
					return get_partition_info_extended(dev_desc, lba_start, ext_part_sector == 0 ? lba_start : relative, part_num, which_part, info);
				}
			}
			break;
	}
	usb_free(buffer);
	return -1;
}

int fat_register_device(block_dev_desc_t *dev_desc, int part_no, unsigned long *part_type, unsigned long *part_offset, unsigned long *part_size)
{
	unsigned char *buffer;
	disk_partition_t info;
	if(!dev_desc->block_read)
		return -1;
	buffer = (unsigned char *)usb_malloc(DEFAULT_SECTOR_SIZE);
	if(buffer == NULL)
		return -1;
	/* check if we have a MBR (on floppies we have only a PBR) */
	if(dev_desc->block_read(dev_desc->dev, 0, 1, (unsigned long *)buffer) != 1)
	{
		USB_STOR_PRINTF("Can't read from device %d\r\n", dev_desc->dev);
		usb_free(buffer);
		return -1;
	}
	if(buffer[DOS_PART_MAGIC_OFFSET] != 0x55 || buffer[DOS_PART_MAGIC_OFFSET + 1] != 0xaa)
	{
		/* no signature found */
		usb_free(buffer);
		return -1;
	}
	/* First we assume, there is a MBR */
	if(!get_partition_info_extended(dev_desc, 0, 0, 1, part_no, &info))
	{
		*part_type = info.type;
		*part_offset = info.start;
		*part_size = info.size;
	}
	else if(!strncmp((char *)&buffer[DOS_FS_TYPE_OFFSET], "FAT", 3))
	{
		/* ok, we assume we are on a PBR only */
		*part_type = 0;
		*part_offset = 0;
		*part_size = 0;
	}
	else
	{
		USB_STOR_PRINTF("Partition %d not valid on device %d\r\n", part_no, dev_desc->dev);
		usb_free(buffer);
		return -1;
	}
	usb_free(buffer);
	return 0;
}

void dev_print(block_dev_desc_t *dev_desc)
{
#ifdef CONFIG_LBA48
	uint64_t lba512; /* number of blocks if 512bytes block size */
#else
	lbaint_t lba512;
#endif
	if(dev_desc->type == DEV_TYPE_UNKNOWN)
	{
		board_printf("not available\r\n");
		return;
	}
	board_printf("Vendor: %s Rev: %s Prod: %s\r\n", dev_desc->vendor, dev_desc->revision, dev_desc->product);
	board_printf("\r\n");
	if((dev_desc->lba * dev_desc->blksz) > 0L)
	{
		unsigned long mb, mb_quot, mb_rem, gb, gb_quot, gb_rem;
		lbaint_t lba = dev_desc->lba;
		lba512 = (lba * (dev_desc->blksz / 512));
		mb = (10 * lba512) / 2048;	/* 2048 = (1024 * 1024) / 512 MB */
		/* round to 1 digit */
		mb_quot	= mb / 10;
		mb_rem	= mb - (10 * mb_quot);
		gb = mb / 1024;
		gb_quot	= gb / 10;
		gb_rem	= gb - (10 * gb_quot);
#ifdef CONFIG_LBA48
		if(dev_desc->lba48)
			board_printf("Supports 48-bit addressing\r\n");
#endif
		board_printf("Capacity: %ld.%ld MB = %ld.%ld GB (%ld x %ld)\r\n", mb_quot, mb_rem, gb_quot, gb_rem, (unsigned long)lba, dev_desc->blksz);
	}
	else
		board_printf("Capacity: not available\r\n");
}

/*******************************************************************************
 * show info on storage devices; 'usb start/init' must be invoked earlier
 * as we only retrieve structures populated during devices initialization
 */
int usb_stor_info(void)
{
	int i;
	if(usb_max_devs > 0)
	{
		for(i = 0; i < usb_max_devs; i++)
		{
			board_printf("Device %d: ", i);
			dev_print(&usb_dev_desc[i]);
		}
		return 0;
	}
	board_printf("No storage devices\r\n");
	return 1;
}

/*******************************************************************************
 * scan the usb and reports device info to the user
 * returns current device or -1 if no
 */
int usb_stor_scan(void)
{
	int i, j;
	struct usb_device *dev;
	usb_max_devs = 0;
	drive_ok_usb = 1;
	for(j = 0; j < USB_MAX_BUS; j++)
	{
		for(i = 0; i < USB_MAX_DEVICE; i++)
		{
			dev = usb_get_dev_index(i, j); /* get device */
			if(dev == NULL)
				break; /* no more devices available */
			usb_stor_register(dev);
		} /* for */
	} /* for */
	board_printf("%d Storage Device(s) found\r\n", usb_max_devs);
	if(usb_max_devs > 0)
		return 0;
	return -1;
}

/*******************************************************************************
 * registering usb mass storage device
 */
int usb_stor_register(struct usb_device *dev)
{
	if(!drive_ok_usb)
		return -1;
	if(usb_max_devs >= USB_MAX_STOR_DEV)
	{
		board_printf("Max USB Storage Device reached: %d\r\n", usb_max_devs);
		return -1;
	}
	if(usb_max_devs == 0)
	{
		int i;
		for(i = 0; i < USB_MAX_STOR_DEV; i++)
		{
			memset(&usb_dev_desc[i], 0, sizeof(block_dev_desc_t));
			usb_dev_desc[i].target = 0xff;
			usb_dev_desc[i].if_type = IF_TYPE_USB;
			usb_dev_desc[i].dev = i;
			usb_dev_desc[i].part_type = PART_TYPE_UNKNOWN;
			usb_dev_desc[i].block_read = usb_stor_read;
			usb_dev_desc[i].block_write = usb_stor_write;
		}	
	}
	if(usb_stor_buf == NULL)
		usb_stor_buf = (unsigned char *)usb_malloc(512);
	if(usb_stor_buf == NULL)
		return -1;
	memset(usb_stor_buf, 0, sizeof(usb_stor_buf));
	usb_disable_asynch(1); /* asynch transfer not allowed */
	if(usb_storage_probe(dev, 0, &usb_stor[usb_max_devs]))
	{
		/* ok, it is a storage devices get info and fill it in */
		USB_STOR_PRINTF("USB STORAGE found (USB: %d, devnum: %d)\r\n", dev->usbnum, dev->devnum);
		usb_dev_desc[usb_max_devs].priv = (void *)dev;
		if(usb_stor_get_info(dev, &usb_stor[usb_max_devs], &usb_dev_desc[usb_max_devs]))
		{
			block_dev_desc_t *stor_dev;
			if((stor_dev = usb_stor_get_dev(usb_max_devs)) != NULL)
			{
				int part_num = 1;
				unsigned long part_type, part_offset, part_size;
				while(!fat_register_device(stor_dev, part_num, &part_type, &part_offset, &part_size))
			  {
					USB_STOR_PRINTF("USB STORAGE install partition dev: %d\r\n", usb_max_devs);
					install_usb_stor(usb_max_devs, part_type, part_offset, part_size, stor_dev->vendor, stor_dev->revision, stor_dev->product);
					part_num++;
				}		
			}
			usb_max_devs++;			
			dev->deregister = usb_stor_deregister;
			usb_disable_asynch(0); /* asynch transfer allowed */
			return 1;
		}
		else
			usb_dev_desc[usb_max_devs].priv = NULL;
	}
	usb_disable_asynch(0); /* asynch transfer allowed */
	return -1;
}

/*******************************************************************************
 * deregistering usb mass storage device
 */
int usb_stor_deregister(struct usb_device *dev)
{
	int i;
	for (i = 0; i <= USB_MAX_STOR_DEV; i++)
	{
		if(dev == (struct usb_device *)usb_dev_desc[i].priv)
		{
			memset(&usb_dev_desc[i], 0, sizeof(block_dev_desc_t));
			usb_dev_desc[i].target = 0xff;
			usb_dev_desc[i].part_type = PART_TYPE_UNKNOWN;
			usb_dev_desc[i].priv = NULL;
			usb_max_devs--;
			uninstall_usb_stor(i);
			USB_STOR_PRINTF("USB STORAGE deregister\r\n");
			return 1;
		}
	}
	return -1;
}

static int usb_stor_irq(struct usb_device *dev)
{
	struct us_data *us;
	us = (struct us_data *)dev->privptr;
	if(us->ip_wanted)
		us->ip_wanted = 0;
	return 0;
}

#ifdef USB_STOR_DEBUG

static void usb_show_srb(ccb *pccb)
{
	int i;
	board_printf("SRB: len %d datalen 0x%lX\r\n ", pccb->cmdlen, pccb->datalen);
	for(i = 0; i < 12; i++)
		board_printf("%02X ", pccb->cmd[i]);
	board_printf("\r\n");
}

static void display_int_status(unsigned long tmp)
{
	board_printf("Status: %s %s %s %s %s %s %s\r\n",
		(tmp & USB_ST_ACTIVE) ? "Active" : "",
		(tmp & USB_ST_STALLED) ? "Stalled" : "",
		(tmp & USB_ST_BUF_ERR) ? "Buffer Error" : "",
		(tmp & USB_ST_BABBLE_DET) ? "Babble Det" : "",
		(tmp & USB_ST_NAK_REC) ? "NAKed" : "",
		(tmp & USB_ST_CRC_ERR) ? "CRC Error" : "",
		(tmp & USB_ST_BIT_ERR) ? "Bitstuff Error" : "");
}

#endif

/***********************************************************************
 * Data transfer routines
 ***********************************************************************/

static int us_one_transfer(struct us_data *us, int pipe, char *buf, int length)
{
	int this_xfer, result, partial, maxtry, stat;
	/* determine the maximum packet size for these transfers */
	int max_size = usb_maxpacket(us->pusb_dev, pipe) * 16;
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
			USB_STOR_PRINTF("Bulk xfer 0x%x(%d) try #%d\r\n", (unsigned int)buf, this_xfer, 11 - maxtry);
			result = usb_bulk_msg(us->pusb_dev, pipe, buf, this_xfer, &partial, USB_CNTL_TIMEOUT * 5);
			USB_STOR_PRINTF("bulk_msg returned %d xferred %d/%d\r\n", result, partial, this_xfer);
			if(us->pusb_dev->status != 0)
			{
				/* if we stall, we need to clear it before we go on */
#ifdef USB_STOR_DEBUG
				display_int_status(us->pusb_dev->status);
#endif
				if(us->pusb_dev->status & USB_ST_STALLED)
				{
					USB_STOR_PRINTF("stalled ->clearing endpoint halt for pipe 0x%x\r\n", pipe);
					stat = us->pusb_dev->status;
					usb_clear_halt(us->pusb_dev, pipe);
					us->pusb_dev->status = stat;
					if(this_xfer == partial)
					{
						USB_STOR_PRINTF("bulk transferred with error %X, but data ok\r\n", us->pusb_dev->status);
						return 0;
					}
					else
						return result;
				}
				if(us->pusb_dev->status & USB_ST_NAK_REC)
				{
					USB_STOR_PRINTF("Device NAKed bulk_msg\r\n");
					return result;
				}
				USB_STOR_PRINTF("bulk transferred with error");
				if(this_xfer == partial)
				{
					USB_STOR_PRINTF(" %d, but data ok\r\n", us->pusb_dev->status);
					return 0;
				}
				/* if our try counter reaches 0, bail out */
				USB_STOR_PRINTF(" %d, data %d\r\n", us->pusb_dev->status, partial);
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

static int usb_stor_BBB_reset(struct us_data *us)
{
	int result;
	unsigned int pipe;
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
	USB_STOR_PRINTF("BBB_reset\r\n");
	result = usb_control_msg(us->pusb_dev, usb_sndctrlpipe(us->pusb_dev, 0),
	 US_BBB_RESET, USB_TYPE_CLASS | USB_RECIP_INTERFACE, 0, us->ifnum, 0, 0, USB_CNTL_TIMEOUT * 5);
	if((result < 0) && (us->pusb_dev->status & USB_ST_STALLED))
	{
		USB_STOR_PRINTF("RESET:stall\r\n");
		return -1;
	}
	/* long wait for reset */
	wait_ms(150);
	USB_STOR_PRINTF("BBB_reset result %d: status %X reset\r\n", result, us->pusb_dev->status);
	pipe = usb_rcvbulkpipe(us->pusb_dev, us->ep_in);
	result = usb_clear_halt(us->pusb_dev, pipe);
	/* long wait for reset */
	wait_ms(150);
	USB_STOR_PRINTF("BBB_reset result %d: status %X clearing IN endpoint\r\n", result, us->pusb_dev->status);
	/* long wait for reset */
	pipe = usb_sndbulkpipe(us->pusb_dev, us->ep_out);
	result = usb_clear_halt(us->pusb_dev, pipe);
	wait_ms(150);
	USB_STOR_PRINTF("BBB_reset result %d: status %X clearing OUT endpoint\r\n", result, us->pusb_dev->status);
	USB_STOR_PRINTF("BBB_reset done\r\n");
	return 0;
}

/* FIXME: this reset function doesn't really reset the port, and it
 * should. Actually it should probably do what it's doing here, and
 * reset the port physically
 */
static int usb_stor_CB_reset(struct us_data *us)
{
	unsigned char cmd[12];
	int result;
	USB_STOR_PRINTF("CB_reset\r\n");
	memset(cmd, 0xff, sizeof(cmd));
	cmd[0] = SCSI_SEND_DIAG;
	cmd[1] = 4;
	result = usb_control_msg(us->pusb_dev, usb_sndctrlpipe(us->pusb_dev, 0), 
	 US_CBI_ADSC, USB_TYPE_CLASS | USB_RECIP_INTERFACE, 0, us->ifnum, cmd, sizeof(cmd), USB_CNTL_TIMEOUT * 5);
	/* long wait for reset */
	wait_ms(1500);
	USB_STOR_PRINTF("CB_reset result %d: status %X clearing endpoint halt\r\n", result, us->pusb_dev->status);
	usb_clear_halt(us->pusb_dev, usb_rcvbulkpipe(us->pusb_dev, us->ep_in));
	usb_clear_halt(us->pusb_dev, usb_rcvbulkpipe(us->pusb_dev, us->ep_out));
	USB_STOR_PRINTF("CB_reset done\r\n");
	return 0;
}

/*
 * Set up the command for a BBB device. Note that the actual SCSI
 * command is copied into cbw.CBWCDB.
 */
int usb_stor_BBB_comdat(ccb *srb, struct us_data *us)
{
	int result, actlen, dir_in;
	unsigned int pipe;
	umass_bbb_cbw_t *cbw = (umass_bbb_cbw_t *)usb_malloc(sizeof(umass_bbb_cbw_t));
	if(cbw == NULL)
	{
		USB_STOR_PRINTF("usb_stor_BBB_comdat: out of memory\r\n");
		return -1;
	}
	dir_in = US_DIRECTION(srb->cmd[0]);
#ifdef BBB_COMDAT_TRACE
	board_printf("dir %d lun %d cmdlen %d cmd %p datalen %d pdata %p\r\n", dir_in, srb->lun, srb->cmdlen, srb->cmd, srb->datalen, srb->pdata);
	if(srb->cmdlen)
	{
		for(result = 0; result < srb->cmdlen; result++)
			board_printf("cmd[%d] %#x ", result, srb->cmd[result]);
		board_printf("\r\n");
	}
#endif
	/* sanity checks */
	if(!(srb->cmdlen <= CBWCDBLENGTH))
	{
		USB_STOR_PRINTF("usb_stor_BBB_comdat: cmdlen too large\r\n");
		usb_free(cbw);
		return -1;
	}
	/* always OUT to the ep */
	pipe = usb_sndbulkpipe(us->pusb_dev, us->ep_out);
	cbw->dCBWSignature = cpu_to_le32(CBWSIGNATURE);
	cbw->dCBWTag = cpu_to_le32(CBWTag++);
	cbw->dCBWDataTransferLength = cpu_to_le32(srb->datalen);
	cbw->bCBWFlags = (dir_in ? CBWFLAGS_IN : CBWFLAGS_OUT);
	cbw->bCBWLUN = srb->lun;
	cbw->bCDBLength = srb->cmdlen;
	/* copy the command data into the CBW command data buffer */
	/* DST SRC LEN!!! */
	memcpy(&cbw->CBWCDB, srb->cmd, srb->cmdlen);
	result = usb_bulk_msg(us->pusb_dev, pipe, cbw, UMASS_BBB_CBW_SIZE, &actlen, USB_CNTL_TIMEOUT * 5);
	if(result < 0)
		USB_STOR_PRINTF("usb_stor_BBB_comdat:usb_bulk_msg error\r\n");
	usb_free(cbw);
	return result;
}

/* FIXME: we also need a CBI_command which sets up the completion
 * interrupt, and waits for it
 */
int usb_stor_CB_comdat(ccb *srb, struct us_data *us)
{
	int result = 0;
	int retry = 5;
	unsigned int pipe;
	unsigned long status;
	int dir_in = US_DIRECTION(srb->cmd[0]);
	if(dir_in)
		pipe = usb_rcvbulkpipe(us->pusb_dev, us->ep_in);
	else
		pipe = usb_sndbulkpipe(us->pusb_dev, us->ep_out);
	while(retry--)
	{
		USB_STOR_PRINTF("CBI gets a command: Try %d\r\n", 5 - retry);
#ifdef USB_STOR_DEBUG
		usb_show_srb(srb);
#endif
		/* let's send the command via the control pipe */
		result = usb_control_msg(us->pusb_dev, usb_sndctrlpipe(us->pusb_dev , 0),
		 US_CBI_ADSC, USB_TYPE_CLASS | USB_RECIP_INTERFACE, 0, us->ifnum, srb->cmd, srb->cmdlen, USB_CNTL_TIMEOUT * 5);
		USB_STOR_PRINTF("CB_transport: control msg returned %d, status %X\r\n", result, us->pusb_dev->status);
		/* check the return code for the command */
		if(result < 0)
		{
			if(us->pusb_dev->status & USB_ST_STALLED)
			{
				status = us->pusb_dev->status;
				USB_STOR_PRINTF(" stall during command found, clear pipe\r\n");
				usb_clear_halt(us->pusb_dev, usb_sndctrlpipe(us->pusb_dev, 0));
				us->pusb_dev->status = status;
			}
			USB_STOR_PRINTF(" error during command %02X Stat = %X\r\n", srb->cmd[0], us->pusb_dev->status);
			return result;
		}
		/* transfer the data payload for this command, if one exists*/
		USB_STOR_PRINTF("CB_transport: control msg returned %d, direction is %s to go 0x%lx\r\n", result, dir_in ? "IN" : "OUT", srb->datalen);
		if(srb->datalen)
		{
			result = us_one_transfer(us, pipe, (char *)srb->pdata, srb->datalen);
			USB_STOR_PRINTF("CBI attempted to transfer data, result is %d status %X, len %d\r\n", result, us->pusb_dev->status, us->pusb_dev->act_len);
			if(!(us->pusb_dev->status & USB_ST_NAK_REC))
				break;
		} /* if(srb->datalen) */
		else
			break;
	}
	/* return result */
	return result;
}

int usb_stor_CBI_get_status(ccb *srb, struct us_data *us)
{
	int timeout = 1000;
	us->ip_wanted = 1;
	usb_submit_int_msg(us->pusb_dev, us->irqpipe, (void *) &us->ip_data, us->irqmaxp, us->irqinterval);
	while(timeout--)
	{
		if((volatile int *) us->ip_wanted == 0)
			break;
		wait_ms(10);
	}
	if(us->ip_wanted)
	{
		board_printf("Did not get interrupt on CBI\r\n");
		us->ip_wanted = 0;
		return USB_STOR_TRANSPORT_ERROR;
	}
	USB_STOR_PRINTF("Got interrupt data 0x%x, transfered %d status 0x%lX\r\n", us->ip_data, us->pusb_dev->irq_act_len, us->pusb_dev->irq_status);
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

#define USB_TRANSPORT_UNKNOWN_RETRY 5
#define USB_TRANSPORT_NOT_READY_RETRY 10

/* clear a stall on an endpoint - special for BBB devices */
int usb_stor_BBB_clear_endpt_stall(struct us_data *us, __u8 endpt)
{
	int result;
	/* ENDPOINT_HALT = 0, so set value to 0 */
	result = usb_control_msg(us->pusb_dev, usb_sndctrlpipe(us->pusb_dev, 0),
	 USB_REQ_CLEAR_FEATURE, USB_RECIP_ENDPOINT, 0, endpt, 0, 0, USB_CNTL_TIMEOUT * 5);
	return result;
}

int usb_stor_BBB_transport(ccb *srb, struct us_data *us)
{
	int result, retry;
	int dir_in;
	int actlen, data_actlen;
	unsigned int pipe, pipein, pipeout;
#ifdef BBB_XPORT_TRACE
	unsigned char *ptr;
	int index;
#endif
	umass_bbb_csw_t *csw = (umass_bbb_csw_t *)usb_malloc(sizeof(umass_bbb_csw_t));
	if(csw == NULL)
	{
		USB_STOR_PRINTF("out of memory\r\n");
		return USB_STOR_TRANSPORT_FAILED;
	}
	dir_in = US_DIRECTION(srb->cmd[0]);
	/* COMMAND phase */
	USB_STOR_PRINTF("COMMAND phase\r\n");
	result = usb_stor_BBB_comdat(srb, us);
	if(result < 0)
	{
		USB_STOR_PRINTF("failed to send CBW status %X\r\n", us->pusb_dev->status);
		if(!(us->pusb_dev->status & USB_ST_NOT_PROC))
			usb_stor_BBB_reset(us);
		usb_free(csw);
		return USB_STOR_TRANSPORT_FAILED;
	}
	wait_ms(5);
	pipein = usb_rcvbulkpipe(us->pusb_dev, us->ep_in);
	pipeout = usb_sndbulkpipe(us->pusb_dev, us->ep_out);
	/* DATA phase + error handling */
	data_actlen = 0;
	/* no data, go immediately to the STATUS phase */
	if(srb->datalen == 0)
		goto st;
	USB_STOR_PRINTF("DATA phase\r\n");
	if(dir_in)
		pipe = pipein;
	else
		pipe = pipeout;
	result = usb_bulk_msg(us->pusb_dev, pipe, srb->pdata, srb->datalen, &data_actlen, USB_CNTL_TIMEOUT * 5);
	/* special handling of STALL in DATA phase */
	if((result < 0) && (us->pusb_dev->status & USB_ST_STALLED))
	{
		USB_STOR_PRINTF("DATA:stall\r\n");
		/* clear the STALL on the endpoint */
		result = usb_stor_BBB_clear_endpt_stall(us, dir_in ? us->ep_in : us->ep_out);
		if(result >= 0)
			/* continue on to STATUS phase */
			goto st;
	}
	if(result < 0)
	{
		USB_STOR_PRINTF("usb_bulk_msg error status %X\r\n", us->pusb_dev->status);
		usb_stor_BBB_reset(us);
		usb_free(csw);
		return USB_STOR_TRANSPORT_FAILED;
	}
#ifdef BBB_XPORT_TRACE
	for(index = 0; index < data_actlen; index++)
		board_printf("pdata[%d] %#x ", index, srb->pdata[index]);
	board_printf("\r\n");
#endif
	/* STATUS phase + error handling */
st:
	retry = 0;
again:
	USB_STOR_PRINTF("STATUS phase\r\n");
	result = usb_bulk_msg(us->pusb_dev, pipein, csw, UMASS_BBB_CSW_SIZE, &actlen, USB_CNTL_TIMEOUT * 5);
	/* special handling of STALL in STATUS phase */
	if((result < 0) && (retry < 1) && (us->pusb_dev->status & USB_ST_STALLED))
	{
		USB_STOR_PRINTF("STATUS:stall\r\n");
		/* clear the STALL on the endpoint */
		result = usb_stor_BBB_clear_endpt_stall(us, us->ep_in);
		if(result >= 0 && (retry++ < 1))
			/* do a retry */
			goto again;
	}
	if(result < 0)
	{
		USB_STOR_PRINTF("usb_bulk_msg error status %X\r\n", us->pusb_dev->status);
		usb_stor_BBB_reset(us);
		usb_free(csw);
		return USB_STOR_TRANSPORT_FAILED;
	}
#ifdef BBB_XPORT_TRACE
	ptr = (unsigned char *)csw;
	for(index = 0; index < UMASS_BBB_CSW_SIZE; index++)
		board_printf("ptr[%d] %#x ", index, ptr[index]);
	board_printf("\r\n");
#endif
	/* misuse pipe to get the residue */
	pipe = le32_to_cpu(csw->dCSWDataResidue);
	if(pipe == 0 && srb->datalen != 0 && srb->datalen - data_actlen != 0)
		pipe = srb->datalen - data_actlen;
	if(CSWSIGNATURE != le32_to_cpu(csw->dCSWSignature))
	{
		USB_STOR_PRINTF("!CSWSIGNATURE\r\n");
		usb_stor_BBB_reset(us);
		usb_free(csw);
		return USB_STOR_TRANSPORT_FAILED;
	}
	else if((CBWTag - 1) != le32_to_cpu(csw->dCSWTag))
	{
		USB_STOR_PRINTF("!Tag\r\n");
		usb_stor_BBB_reset(us);
		usb_free(csw);
		return USB_STOR_TRANSPORT_FAILED;
	}
	else if(csw->bCSWStatus > CSWSTATUS_PHASE)
	{
		USB_STOR_PRINTF(">PHASE\r\n");
		usb_stor_BBB_reset(us);
		usb_free(csw);
		return USB_STOR_TRANSPORT_FAILED;
	}
	else if(csw->bCSWStatus == CSWSTATUS_PHASE)
	{
		USB_STOR_PRINTF("=PHASE\r\n");
		usb_stor_BBB_reset(us);
		usb_free(csw);
		return USB_STOR_TRANSPORT_FAILED;
	}
	else if(data_actlen > srb->datalen)
	{
		USB_STOR_PRINTF("transferred %dB instead of %dB\r\n", data_actlen, srb->datalen);
		usb_free(csw);
		return USB_STOR_TRANSPORT_FAILED;
	}
	else if(csw->bCSWStatus == CSWSTATUS_FAILED)
	{
		USB_STOR_PRINTF("FAILED\r\n");
		usb_free(csw);
		return USB_STOR_TRANSPORT_FAILED;
	}
	usb_free(csw);
	return result;
}

int usb_stor_CB_transport(ccb *srb, struct us_data *us)
{
	int result, status;
	int retry = 0, notready = 0;
	ccb *psrb = (ccb *)usb_malloc(sizeof(ccb));
	if(psrb == NULL)
	{
		USB_STOR_PRINTF("out of memory\r\n");
		return USB_STOR_TRANSPORT_FAILED;
	}
	status = USB_STOR_TRANSPORT_GOOD;
	/* issue the command */
do_retry:
	result = usb_stor_CB_comdat(srb, us);
	USB_STOR_PRINTF("command / Data returned %d, status %X\r\n", result, us->pusb_dev->status);
	/* if this is an CBI Protocol, get IRQ */
	if(us->protocol == US_PR_CBI)
	{
		status = usb_stor_CBI_get_status(srb, us);
		/* if the status is error, report it */
		if(status == USB_STOR_TRANSPORT_ERROR)
		{
			USB_STOR_PRINTF(" USB CBI Command Error\r\n");
			usb_free(psrb);
			return status;
		}
		srb->sense_buf[12] = (unsigned char)(us->ip_data >> 8);
		srb->sense_buf[13] = (unsigned char)(us->ip_data & 0xff);
		if(!us->ip_data)
		{
			/* if the status is good, report it */
			if(status == USB_STOR_TRANSPORT_GOOD)
			{
				USB_STOR_PRINTF(" USB CBI Command Good\r\n");
				usb_free(psrb);
				return status;
			}
		}
	}
	/* do we have to issue an auto request? */
	/* HERE we have to check the result */
	if((result < 0) && !(us->pusb_dev->status & USB_ST_STALLED))
	{
		USB_STOR_PRINTF("ERROR %X\r\n", us->pusb_dev->status);
		us->transport_reset(us);
		usb_free(psrb);
		return USB_STOR_TRANSPORT_ERROR;
	}
	if((us->protocol == US_PR_CBI) && ((srb->cmd[0] == SCSI_REQ_SENSE) || (srb->cmd[0] == SCSI_INQUIRY)))
	{
		/* do not issue an autorequest after request sense */
		USB_STOR_PRINTF("No auto request and good\r\n");
		usb_free(psrb);
		return USB_STOR_TRANSPORT_GOOD;
	}
	/* issue an request_sense */
	memset(&psrb->cmd[0], 0, 12);
	psrb->cmd[0] = SCSI_REQ_SENSE;
	psrb->cmd[1] = srb->lun << 5;
	psrb->cmd[4] = 18;
	psrb->datalen = 18;
	psrb->pdata = &srb->sense_buf[0];
	psrb->cmdlen = 12;
	/* issue the command */
	result = usb_stor_CB_comdat(psrb, us);
	USB_STOR_PRINTF("auto request returned %d\r\n", result);
	/* if this is an CBI Protocol, get IRQ */
	if(us->protocol == US_PR_CBI)
		status = usb_stor_CBI_get_status(psrb, us);
	if((result < 0) && !(us->pusb_dev->status & USB_ST_STALLED))
	{
		USB_STOR_PRINTF(" AUTO REQUEST ERROR %d\r\n", us->pusb_dev->status);
		usb_free(psrb);
		return USB_STOR_TRANSPORT_ERROR;
	}
	USB_STOR_PRINTF("autorequest returned 0x%02X 0x%02X 0x%02X 0x%02X\r\n", srb->sense_buf[0], srb->sense_buf[2], srb->sense_buf[12], srb->sense_buf[13]);
	/* Check the auto request result */
	if((srb->sense_buf[2] == 0) && (srb->sense_buf[12] == 0) && (srb->sense_buf[13] == 0))
	{
		/* ok, no sense */
		usb_free(psrb);
		return USB_STOR_TRANSPORT_GOOD;
	}
	/* Check the auto request result */
	switch(srb->sense_buf[2])
	{
		case 0x01:
			/* Recovered Error */
			usb_free(psrb);
			return USB_STOR_TRANSPORT_GOOD;
		case 0x02: /* Not Ready */
			if(notready++ > USB_TRANSPORT_NOT_READY_RETRY)
			{
				board_printf("cmd 0x%02X returned 0x%02X 0x%02X 0x%02X 0x%02X (NOT READY)\r\n", srb->cmd[0], srb->sense_buf[0], srb->sense_buf[2], srb->sense_buf[12], srb->sense_buf[13]);
				usb_free(psrb);
				return USB_STOR_TRANSPORT_FAILED;
			}
			else
			{
				wait_ms(100);
				goto do_retry;
			}
			break;
		default:
			if(retry++ > USB_TRANSPORT_UNKNOWN_RETRY)
			{
				board_printf("cmd 0x%02X returned 0x%02X 0x%02X 0x%02X 0x%02X\r\n", srb->cmd[0], srb->sense_buf[0], srb->sense_buf[2], srb->sense_buf[12], srb->sense_buf[13]);
				usb_free(psrb);
				return USB_STOR_TRANSPORT_FAILED;
			}
			else
				goto do_retry;
			break;
	}
	usb_free(psrb);
	return USB_STOR_TRANSPORT_FAILED;
}

static int usb_inquiry(ccb *srb, struct us_data *ss)
{
	int i, retry = 5;
	do
	{
		memset(&srb->cmd[0], 0, 12);
		srb->cmd[0] = SCSI_INQUIRY;
		srb->cmd[4] = 36;
		srb->datalen = 36;
		srb->cmdlen = 12;
		i = ss->transport(srb, ss);
		USB_STOR_PRINTF("inquiry returns %d\r\n", i);
		switch(i)
		{
			case USB_STOR_TRANSPORT_GOOD : return 0;
			default :
				if(ss->pusb_dev->status & USB_ST_NOT_PROC)
					return -1;
				break;
		}
	}
	while(retry--);
	board_printf("error in inquiry\r\n");
	return -1;
}

static int usb_request_sense(ccb *srb, struct us_data *ss)
{
	char *ptr;
	ptr = (char *)srb->pdata;
	memset(&srb->cmd[0], 0, 12);
	srb->cmd[0] = SCSI_REQ_SENSE;
	srb->cmd[4] = 18;
	srb->datalen = 18;
	srb->pdata = &srb->sense_buf[0];
	srb->cmdlen = 12;
	ss->transport(srb, ss);
	USB_STOR_PRINTF("Request Sense returned %02X %02X %02X\r\n", srb->sense_buf[2], srb->sense_buf[12], srb->sense_buf[13]);
	srb->pdata = (unsigned char *)ptr;
	return 0;
}

static int usb_test_unit_ready(ccb *srb, struct us_data *ss)
{
	int retries = 10;
	do
	{
		memset(&srb->cmd[0], 0, 12);
		srb->cmd[0] = SCSI_TST_U_RDY;
		srb->datalen = 0;
		srb->cmdlen = 12;
		switch(ss->transport(srb, ss))
		{
			case USB_STOR_TRANSPORT_GOOD : return 0;
			default :
				if(ss->pusb_dev->status & USB_ST_NOT_PROC)
					return -1;
				break;
		}
		usb_request_sense(srb, ss);
		wait_ms(100);
	}
	while(retries--);
	return -1;
}

static int usb_read_capacity(ccb *srb, struct us_data *ss)
{
	int retry = 3;
	do
	{
		memset(&srb->cmd[0], 0, 12);
		srb->cmd[0] = SCSI_RD_CAPAC;
		srb->datalen = 8;
		srb->cmdlen = 12;
		switch(ss->transport(srb, ss))
		{
			case USB_STOR_TRANSPORT_GOOD : return 0;
			default :
				if(ss->pusb_dev->status & USB_ST_NOT_PROC)
					return -1;
				break;
		}
	}
	while(retry--);
	return -1;
}

static int usb_read_10(ccb *srb, struct us_data *ss, unsigned long start, unsigned short blocks)
{
	memset(&srb->cmd[0], 0, 12);
	srb->cmd[0] = SCSI_READ10;
	srb->cmd[2] = ((unsigned char) (start >> 24)) & 0xff;
	srb->cmd[3] = ((unsigned char) (start >> 16)) & 0xff;
	srb->cmd[4] = ((unsigned char) (start >> 8)) & 0xff;
	srb->cmd[5] = ((unsigned char) (start)) & 0xff;
	srb->cmd[7] = ((unsigned char) (blocks >> 8)) & 0xff;
	srb->cmd[8] = (unsigned char) blocks & 0xff;
	srb->cmdlen = 12;
	USB_STOR_PRINTF("read10: start %lx blocks %x\r\n", start, blocks);
	return ss->transport(srb, ss);
}

#ifdef CONFIG_USB_WRITE_ENABLE
static int usb_write_10(ccb *srb, struct us_data *ss, unsigned long start, unsigned short blocks)
{
	memset(&srb->cmd[0], 0, 12);
	srb->cmd[0] = SCSI_WRITE10;
	srb->cmd[2] = ((unsigned char) (start >> 24)) & 0xff;
	srb->cmd[3] = ((unsigned char) (start >> 16)) & 0xff;
	srb->cmd[4] = ((unsigned char) (start >> 8)) & 0xff;
	srb->cmd[5] = ((unsigned char) (start)) & 0xff;
	srb->cmd[7] = ((unsigned char) (blocks >> 8)) & 0xff;
	srb->cmd[8] = (unsigned char) blocks & 0xff;
	srb->cmdlen = 12;
	USB_STOR_PRINTF("write10: start %lx blocks %x\r\n", start, blocks);
	return ss->transport(srb, ss);
}
#endif /* CONFIG_USB_WRITE_ENABLE */

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
static void usb_bin_fixup(struct usb_device_descriptor descriptor, unsigned char vendor[], unsigned char product[])
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

#define USB_MAX_READ_BLK 20

long usb_stor_read(int device, unsigned long blknr, unsigned long blkcnt, void *buffer)
{
	unsigned long start, blks, buf_addr;
	unsigned short smallblks;
	struct usb_device *dev;
	unsigned char *tmp_buf;
	int retry, i, j;
	ccb *srb = &usb_ccb;
	if(blkcnt == 0)
		return -1;
	device &= 0xff;
	/* Setup  device */
	dev = NULL;
	for(j = 0; j < USB_MAX_BUS; j++)
	{
		for(i = 0; i < USB_MAX_DEVICE; i++)
		{
			dev = usb_get_dev_index(i, j);
			if(dev == NULL)
				break;
			if(dev == (struct usb_device *)usb_dev_desc[device].priv)
			{
				j = USB_MAX_BUS;
				break;
			}
		}
	}
	if((dev == NULL) || (dev->privptr == NULL))
		return -1;
	usb_disable_asynch(1); /* asynch transfer not allowed */
	srb->lun = usb_dev_desc[device].lun;
	buf_addr = (unsigned long)buffer;
	start = blknr;
	blks = blkcnt;
	if(usb_test_unit_ready(srb, (struct us_data *)dev->privptr))
	{
		board_printf("Device NOT ready\r\nRequest Sense returned %02X %02X %02X\r\n", srb->sense_buf[2], srb->sense_buf[12], srb->sense_buf[13]);
		usb_disable_asynch(0); /* asynch transfer allowed */
		return -2;
	}
	tmp_buf = (unsigned char *)usb_malloc(USB_MAX_READ_BLK * usb_dev_desc[device].blksz);
	if(tmp_buf == NULL)
	{
		USB_STOR_PRINTF("Read out of memory ERROR\r\n");
		usb_disable_asynch(0); /* asynch transfer allowed */
		return -1;
	}
	USB_STOR_PRINTF("usb_read: dev %d startblk %lx, blccnt %lx buffer %lx\r\n", device, start, blks, buf_addr);
	do
	{
		/* XXX need some comment here */
		retry = 2;
		if(blks > USB_MAX_READ_BLK)
			smallblks = USB_MAX_READ_BLK;
		else
			smallblks = (unsigned short)blks;
retry_it:
		srb->datalen = usb_dev_desc[device].blksz * smallblks;
		srb->pdata = tmp_buf;
		if(usb_read_10(srb, (struct us_data *)dev->privptr, start, smallblks))
		{
			USB_STOR_PRINTF("Read ERROR\r\n");
			usb_request_sense(srb, (struct us_data *)dev->privptr);
			if(retry--)
				goto retry_it;
			blkcnt -= blks;
			break;
		}
		memcpy((void *)buf_addr, tmp_buf, srb->datalen);
		start += smallblks;
		blks -= smallblks;
		buf_addr += srb->datalen;
	}
	while(blks != 0);
	usb_free(tmp_buf);
	USB_STOR_PRINTF("usb_read: end startblk %lx, blccnt %x buffer %lx\r\n", start, smallblks, buf_addr);
	usb_disable_asynch(0); /* asynch transfer allowed */
	return blkcnt;
}

long usb_stor_write(int device, unsigned long blknr, unsigned long blkcnt, const void *buffer)
{
#ifdef CONFIG_USB_WRITE_ENABLE
	unsigned long start, blks, buf_addr;
	unsigned short smallblks;
	struct usb_device *dev;
	unsigned char *tmp_buf;
	int retry, i, j;
	ccb *srb = &usb_ccb;
	if(blkcnt == 0)
		return -1;
	device &= 0xff;
	/* Setup  device */
	dev = NULL;
	for(j = 0; j < USB_MAX_BUS; j++)
	{
		for(i = 0; i < USB_MAX_DEVICE; i++)
		{
			dev = usb_get_dev_index(i, j);
			if(dev == NULL)
				break;
			if(dev == (struct usb_device *)usb_dev_desc[device].priv)
			{
				j = USB_MAX_BUS;
				break;
			}
		}
	}
	if((dev == NULL) || (dev->privptr == NULL))
		return -1;
	usb_disable_asynch(1); /* asynch transfer not allowed */
	srb->lun = usb_dev_desc[device].lun;
	buf_addr = (unsigned long)buffer;
	start = blknr;
	blks = blkcnt;
	if(usb_test_unit_ready(srb, (struct us_data *)dev->privptr))
	{
		board_printf("Device NOT ready\r\nRequest Sense returned %02X %02X %02X\r\n", srb->sense_buf[2], srb->sense_buf[12], srb->sense_buf[13]);
		usb_disable_asynch(0); /* asynch transfer allowed */
		return -2;
	}
	tmp_buf = (unsigned char *)usb_malloc(USB_MAX_READ_BLK * usb_dev_desc[device].blksz);
	if(tmp_buf == NULL)
	{
		USB_STOR_PRINTF("Write out of memory ERROR\r\n");
		usb_disable_asynch(0); /* asynch transfer allowed */
		return -1;
	}
	USB_STOR_PRINTF("usb_write: dev %d startblk %lx, blccnt %lx buffer %lx\r\n", device, start, blks, buf_addr);
	do
	{
		/* XXX need some comment here */
		retry = 2;
		if(blks > USB_MAX_READ_BLK)
			smallblks = USB_MAX_READ_BLK;
		else
			smallblks = (unsigned short)blks;
retry_it:
		srb->datalen = usb_dev_desc[device].blksz * smallblks;
		srb->pdata = tmp_buf;
		memcpy(tmp_buf, (void *)buf_addr, srb->datalen);
		if(usb_write_10(srb, (struct us_data *)dev->privptr, start, smallblks))
		{
			USB_STOR_PRINTF("Write ERROR\r\n");
			usb_request_sense(srb, (struct us_data *)dev->privptr);
			if(retry--)
				goto retry_it;
			blkcnt -= blks;
			break;
		}
		start += smallblks;
		blks -= smallblks;
		buf_addr += srb->datalen;
	}
	while(blks != 0);
	usb_free(tmp_buf);
	USB_STOR_PRINTF("usb_write: end startblk %lx, blccnt %x buffer %lx\r\n", start, smallblks, buf_addr);
	usb_disable_asynch(0); /* asynch transfer allowed */
	return blkcnt;
#else
	if(device);
	if(blknr);
	if(blkcnt);
	if(buffer);
	return 0;
#endif /* CONFIG_USB_WRITE_ENABLE */
}

/* Probe to see if a new device is actually a Storage device */
int usb_storage_probe(struct usb_device *dev, unsigned int ifnum, struct us_data *ss)
{
	struct usb_interface_descriptor *iface;
	int i;
	unsigned int flags = 0;
	int protocol = 0;
	int subclass = 0;
	/* let's examine the device now */
	iface = &dev->config.if_desc[ifnum];
#if 0
	USB_STOR_PRINTF("iVendor 0x%X iProduct 0x%X\r\n", dev->descriptor.idVendor, dev->descriptor.idProduct);
	/* this is the place to patch some storage devices */
	if((dev->descriptor.idVendor) == 0x066b && (dev->descriptor.idProduct) == 0x0103)
	{
		USB_STOR_PRINTF("patched for E-USB\r\n");
		protocol = US_PR_CB;
		subclass = US_SC_UFI;	    /* an assumption */
	}
#endif
	if(dev->descriptor.bDeviceClass != 0 || iface->bInterfaceClass != USB_CLASS_MASS_STORAGE
	 || iface->bInterfaceSubClass < US_SC_MIN || iface->bInterfaceSubClass > US_SC_MAX)
		/* if it's not a mass storage, we go no further */
		return 0;
	memset(ss, 0, sizeof(struct us_data));
	/* At this point, we know we've got a live one */
	USB_STOR_PRINTF("\r\n\r\nUSB Mass Storage device detected\r\n");
	/* Initialize the us_data structure with some useful info */
	ss->flags = flags;
	ss->ifnum = ifnum;
	ss->pusb_dev = dev;
	ss->attention_done = 0;
	/* If the device has subclass and protocol, then use that.  Otherwise,
	 * take data from the specific interface.
	 */
	if(subclass)
	{
		ss->subclass = subclass;
		ss->protocol = protocol;
	}
	else
	{
		ss->subclass = iface->bInterfaceSubClass;
		ss->protocol = iface->bInterfaceProtocol;
	}
	/* set the handler pointers based on the protocol */
	USB_STOR_PRINTF("Transport: ");
	switch(ss->protocol)
	{
		case US_PR_CB:
			USB_STOR_PRINTF("Control/Bulk\r\n");
			ss->transport = usb_stor_CB_transport;
			ss->transport_reset = usb_stor_CB_reset;
			break;
		case US_PR_CBI:
			USB_STOR_PRINTF("Control/Bulk/Interrupt\r\n");
			ss->transport = usb_stor_CB_transport;
			ss->transport_reset = usb_stor_CB_reset;
			break;
		case US_PR_BULK:
			USB_STOR_PRINTF("Bulk/Bulk/Bulk\r\n");
			ss->transport = usb_stor_BBB_transport;
			ss->transport_reset = usb_stor_BBB_reset;
			break;
		default:
			board_printf("USB Storage Transport unknown / not yet implemented\r\n");
			return 0;
			break;
	}
	/*
	 * We are expecting a minimum of 2 endpoints - in and out (bulk).
	 * An optional interrupt is OK (necessary for CBI protocol).
	 * We will ignore any others.
	 */
	for(i = 0; i < iface->bNumEndpoints; i++)
	{
		/* is it an BULK endpoint? */
		if((iface->ep_desc[i].bmAttributes & USB_ENDPOINT_XFERTYPE_MASK) == USB_ENDPOINT_XFER_BULK)
		{
			if(iface->ep_desc[i].bEndpointAddress & USB_DIR_IN)
				ss->ep_in = iface->ep_desc[i].bEndpointAddress & USB_ENDPOINT_NUMBER_MASK;
			else
				ss->ep_out = iface->ep_desc[i].bEndpointAddress & USB_ENDPOINT_NUMBER_MASK;
		}
		/* is it an interrupt endpoint? */
		if((iface->ep_desc[i].bmAttributes & USB_ENDPOINT_XFERTYPE_MASK) == USB_ENDPOINT_XFER_INT)
		{
			ss->ep_int = iface->ep_desc[i].bEndpointAddress & USB_ENDPOINT_NUMBER_MASK;
			ss->irqinterval = iface->ep_desc[i].bInterval;
		}
	}
	USB_STOR_PRINTF("Endpoints In %d Out %d Int %d\r\n", ss->ep_in, ss->ep_out, ss->ep_int);
	/* Do some basic sanity checks, and bail if we find a problem */
	if(usb_set_interface(dev, iface->bInterfaceNumber, 0) || !ss->ep_in || !ss->ep_out
	 || (ss->protocol == US_PR_CBI && ss->ep_int == 0))
	{
		USB_STOR_PRINTF("Problems with device\r\n");
		return 0;
	}
	/* set class specific stuff */
	/* We only handle certain protocols.  Currently, these are
	 * the only ones.
	 * The SFF8070 accepts the requests used in u-boot
	 */
	if(ss->subclass != US_SC_UFI && ss->subclass != US_SC_SCSI && ss->subclass != US_SC_8070)
	{
		board_printf("Sorry, protocol %d not yet supported.\r\n", ss->subclass);
		return 0;
	}
	if(ss->ep_int)
	{
		/* we had found an interrupt endpoint, prepare irq pipe
		 * set up the IRQ pipe and handler
		 */
		ss->irqinterval = (ss->irqinterval > 0) ? ss->irqinterval : 255;
		ss->irqpipe = usb_rcvintpipe(ss->pusb_dev, ss->ep_int);
		ss->irqmaxp = usb_maxpacket(dev, ss->irqpipe);
		dev->irq_handle = usb_stor_irq;
	}
	dev->privptr = (void *)ss;
	return 1;
}

int usb_stor_get_info(struct usb_device *dev, struct us_data *ss, block_dev_desc_t *dev_desc)
{
	unsigned char perq, modi;
	unsigned long *cap = NULL;
	unsigned long *capacity, *blksz;
	ccb *pccb = &usb_ccb;
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
		USB_STOR_PRINTF("usb_stor_get_info: skipping RESET..\r\n");
	else
		ss->transport_reset(ss);
	pccb->pdata = usb_stor_buf;
	dev_desc->target = dev->devnum;
	pccb->lun = dev_desc->lun;
	USB_STOR_PRINTF(" address %d\r\n", dev_desc->target);
	if(usb_inquiry(pccb, ss))
		return -1;
	perq = usb_stor_buf[0];
	modi = usb_stor_buf[1];
	if((perq & 0x1f) == 0x1f)
		return 0;	/* skip unknown devices */
	if((modi & 0x80) == 0x80)
		dev_desc->removable = 1; /* drive is removable */
	memcpy(&dev_desc->vendor[0], &usb_stor_buf[8], 8);
	memcpy(&dev_desc->product[0], &usb_stor_buf[16], 16);
	memcpy(&dev_desc->revision[0], &usb_stor_buf[32], 4);
	dev_desc->vendor[8] = 0;
	dev_desc->product[16] = 0;
	dev_desc->revision[4] = 0;
#ifdef CONFIG_USB_BIN_FIXUP
	usb_bin_fixup(dev->descriptor, (uchar *)dev_desc->vendor, (uchar *)dev_desc->product);
#endif /* CONFIG_USB_BIN_FIXUP */
	USB_STOR_PRINTF("ISO Vers %X, Response Data %X\r\n", usb_stor_buf[2], usb_stor_buf[3]);
	if(usb_test_unit_ready(pccb, ss))
	{
		board_printf("Device NOT ready\r\nRequest Sense returned %02X %02X %02X\r\n", pccb->sense_buf[2], pccb->sense_buf[12], pccb->sense_buf[13]);
		if(dev_desc->removable == 1)
		{
			dev_desc->type = perq;
			return 1;
		}
		return 0;
	}
	cap = (unsigned long *)usb_malloc(sizeof(unsigned long) * 2);
	if(cap == NULL)
		return 0;
	pccb->pdata = (unsigned char *)&cap[0];
	memset(pccb->pdata, 0, 8);
	if(usb_read_capacity(pccb, ss) != 0)
	{
		board_printf("READ_CAP ERROR\r\n");
		cap[0] = 2880;
		cap[1] = 0x200;
	}
	USB_STOR_PRINTF("Read Capacity returns: 0x%lx, 0x%lx\r\n", cap[0], cap[1]);
#if 0
	if(cap[0] > (0x200000 * 10)) /* greater than 10 GByte */
		cap[0] >>= 16;
#endif
	cap[0] = cpu_to_be32(cap[0]);
	cap[1] = cpu_to_be32(cap[1]);
	/* this assumes bigendian! */
	cap[0] += 1;
	capacity = &cap[0];
	blksz = &cap[1];
	USB_STOR_PRINTF("Capacity = 0x%lx, blocksz = 0x%lx\r\n", *capacity, *blksz);
	dev_desc->lba = *capacity;
	dev_desc->blksz = *blksz;
	dev_desc->type = perq;
	USB_STOR_PRINTF(" address %d\r\n", dev_desc->target);
	USB_STOR_PRINTF("partype: %d\r\n", dev_desc->part_type);
	init_part(dev_desc);
	USB_STOR_PRINTF("partype: %d\r\n", dev_desc->part_type);
	usb_free(cap);
	return 1;
}

#endif /* CONFIG_USB_STORAGE */
#endif /* CONFIG_USB_UHCI || CONFIG_USB_OHCI || CONFIG_USB_EHCI */
