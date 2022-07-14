/*
 * Copyright (c) 2012 David Galvez
 *
 * This file is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#ifndef _XHDI_H
#define _XHDI_H

#include "../../../../pun.h"		/* for PUN_INFO */
/* AHDI */

/* BIOS parameter block */

struct  bpb
{
	ushort	recsiz;		/* bytes per sector */
	short	clsiz;		/* sectors per cluster */
	ushort	clsizb;		/* bytes per cluster */
	short	rdlen;		/* root directory size */
	short	fsiz;		/* size of FAT */
	short	fatrec;		/* startsector of second FAT */
	short	datrec;		/* first data sector */
	ushort	numcl;		/* total number of clusters */
	short	bflags;		/* some flags */
};
typedef struct bpb BPB;

/* Extended pun struct for USB */

#define MAX_LOGICAL_DRIVE 32

struct usb_pun_info
{
	ushort	puns;			/* Number of HD's */
	uchar	pun [MAX_LOGICAL_DRIVE];		/* AND with masks below: */
# define PUN_DEV	0x1f			/* device number of HD */
# define PUN_UNIT	0x7			/* Unit number */
# define PUN_SCSI	0x8			/* 1=SCSI 0=ACSI */
# define PUN_IDE	0x10			/* Falcon IDE */
# define PUN_USB        0x20			/* USB */
# define PUN_REMOVABLE	0x40			/* Removable media */
# define PUN_VALID	0x80			/* zero if valid */
	long	partition_start [MAX_LOGICAL_DRIVE];
	long	cookie;			/* 'AHDI' if following valid */
	long	*cookie_ptr;		/* Points to 'cookie' */
	ushort	version_num;		/* AHDI version */
	ushort	max_sect_siz;		/* Max logical sec size */
	long	ptype[MAX_LOGICAL_DRIVE];
	long	psize[MAX_LOGICAL_DRIVE];
	short	flags[MAX_LOGICAL_DRIVE];		/* B15:swap, B7:change, B0:bootable */
	BPB	bpb[MAX_LOGICAL_DRIVE];
};
typedef struct usb_pun_info USB_PUN_INFO;

/* flags in USB_PUN_INFO */
#define CHANGE_FLAG		(1<<7)

/* XHDI opcodes */
#define XHGETVERSION    0
#define XHINQTARGET     1
#define XHRESERVE       2
#define XHLOCK          3
#define XHSTOP          4
#define XHEJECT         5
#define XHDRVMAP        6
#define XHINQDEV        7
#define XHINQDRIVER     8
#define XHNEWCOOKIE     9
#define XHREADWRITE     10
#define XHINQTARGET2    11
#define XHINQDEV2       12
#define XHDRIVERSPECIAL 13
#define XHGETCAPACITY   14
#define XHMEDIUMCHANGED 15
#define XHMINTINFO      16
#define XHDOSLIMITS     17
#define XHLASTACCESS    18
#define XHREACCESS      19

/*
 * values used for XHDOSLimits()
 */
#define XH_DL_SECSIZ    0   /* maximal sector size (BIOS level) */
#define XH_DL_MINFAT    1   /* minimal number of FATs */
#define XH_DL_MAXFAT    2   /* maximal number of FATs */
#define XH_DL_MINSPC    3   /* sectors per cluster minimal */
#define XH_DL_MAXSPC    4   /* sectors per cluster maximal */
#define XH_DL_CLUSTS    5   /* maximal number of clusters of a 16 bit FAT */
#define XH_DL_MAXSEC    6   /* maximal number of sectors */
#define XH_DL_DRIVES    7   /* maximal number of BIOS drives supported by the DOS */
#define XH_DL_CLSIZB    8   /* maximal clustersize */
#define XH_DL_RDLEN     9   /* max. (bpb->rdlen * bpb->recsiz / 32) */
#define XH_DL_CLUSTS12  12  /* max. number of clusters of a 12 bit FAT */
#define XH_DL_CLUSTS32  13  /* max. number of clusters of a 32 bit FAT */
#define XH_DL_BFLAGS    14  /* supported bits in bpb->bflags */

#ifdef TOSONLY
/*
 * MagiC-specific, used for XHDOSLimits()
 */
#define KER_DOSLIMITS  0x0101

typedef struct {
	ushort	version;                 /* Version number                  */
	ushort	num_drives;              /* Max. number of drives           */
	ulong	 max_secsizb;            /* Max. sector size in bytes       */
	ushort	min_nfats;               /* Min. number of FATs             */
	ushort	max_nfats;               /* Max. number of FATs             */
	ulong	 min_nclsiz;             /* Min. number of sectors/clusters */
	ulong	 max_nclsiz;             /* Max. number of sectors/clusters */
	ulong	 max_ncl;                /* Max. number of clusters         */
	ulong	 max_nsec;               /* Max. number of sectors          */
} MX_DOSLIMITS;
#endif

/*
 * some architectural constants
 */
#define MAX_LOGSEC_SIZE     16384L		/* old versions of TOS have lower limits */
#define MAX_FAT12_CLUSTERS  4078L
#define MAX_FAT16_CLUSTERS  65518L

#endif /* _XHDI_H */
