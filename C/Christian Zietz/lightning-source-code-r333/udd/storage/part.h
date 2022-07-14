/*
 * Modified for the FreeMiNT USB subsystem by David Galvez. 2010-2019
 *
 * (C) Copyright 2000-2004
 * Wolfgang Denk, DENX Software Engineering, wd@denx.de.
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
 */
#ifndef _PART_H
#define _PART_H

typedef unsigned long long uint64_t;
typedef unsigned long lbaint_t;

#define VENDOR_STRING_LENGTH	40+1
#define PRODUCT_STRING_LENGTH	20+1
#define REVISION_STRING_LENGTH	8+1

typedef struct block_dev_desc
{
	long		if_type;	/* type of the interface */
	unsigned char	usb_phydrv;	/* USB physical drive (USB mass storage device number) */
	unsigned char	usb_logdrv;	/* USB logical drive (LUNs count between all USB Mass Storage devices) */
	unsigned char	part_type;	/* partition table type */
	unsigned char	target;		/* target SCSI ID (= USB device ID)*/
	unsigned char	lun;		/* LUN number in this target */
	unsigned char	type;		/* device type */
	unsigned char	removable;	/* removable device */
	unsigned char	ready;		/* unit ready */
	unsigned char	sw_ejected;	/* device ejected by software */
# ifdef CONFIG_LBA48
	unsigned char	lba48;		/* device can use 48bit addr (ATA/ATAPI v7) */
# endif
	lbaint_t	lba;		/* number of blocks */
	unsigned long	blksz;		/* block size */
	char		vendor[VENDOR_STRING_LENGTH];		/* IDE model, SCSI Vendor */
	char		product[PRODUCT_STRING_LENGTH];		/* IDE Serial no, SCSI product */
	char		revision[REVISION_STRING_LENGTH];	/* firmware revision */
	long		(*block_read)(long dev, unsigned long start, lbaint_t blkcnt, void *buffer);
	long		(*block_write)(long dev, unsigned long start, lbaint_t blkcnt, void *buffer);
	void		*priv;		/* driver private struct pointer */
} block_dev_desc_t;

/* Interface types: */
#define IF_TYPE_UNKNOWN		0
#define IF_TYPE_IDE		1
#define IF_TYPE_SCSI		2
#define IF_TYPE_ATAPI		3
#define IF_TYPE_USB		4
#define IF_TYPE_DOC		5
#define IF_TYPE_MMC		6
#define IF_TYPE_SD		7
#define IF_TYPE_SATA		8

/* Part types */
#define PART_TYPE_UNKNOWN	0x00
#define PART_TYPE_MAC		0x01
#define PART_TYPE_DOS		0x02
#define PART_TYPE_ISO		0x03
#define PART_TYPE_AMIGA		0x04
#define PART_TYPE_EFI		0x05

/* device types */
#define DEV_TYPE_UNKNOWN	0xff	/* not connected */
#define DEV_TYPE_HARDDISK	0x00	/* harddisk */
#define DEV_TYPE_TAPE		0x01	/* Tape */
#define DEV_TYPE_CDROM		0x05	/* CD-ROM */
#define DEV_TYPE_OPDISK		0x07	/* optical disk */

void print_part(block_dev_desc_t *dev_desc);
void init_part(block_dev_desc_t *dev_desc);
void dev_print(block_dev_desc_t *dev_desc);

long fat_register_device(block_dev_desc_t *dev_desc, long part_no, unsigned long *part_type, unsigned long *part_offset, unsigned long *part_size);

#endif /* _PART_H */
