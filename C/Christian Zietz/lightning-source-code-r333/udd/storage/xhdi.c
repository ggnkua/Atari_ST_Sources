/*
 * Copyright (c) 2012-2015 David Galvez
 *
 * Parts of this file has been inspired by code typed by:
 * Frank Naumann
 * Petr Stehlik 
 * Vincent Rivière 
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
 *
 * TODO: Fix XHMiNTInfo
 */

/*
 * This driver doesn't support lockable devices, so we don't implement XHLock.
 * It doesn't support stoppable devices, so XHStop is not implemented either.
 * According to the XHDI specification error codes from these two calls are
 * undefined. We return ENOSYS for them. If the device is not lockable XHReserve
 * doesn't make sense to be implemented either.
 *
 * The XHDI specification says that a device is ejectable if "the device can
 * physically eject the medium", I understand this describes something like
 * a CD-ROM. So this driver doesn't support ejectable devices. BUT we need a
 * way to inform the kernel from the user space that a device is going to be
 * removed so the kernel can sync disk caches, the only way I see to do this
 * through XHDI is using XHEject, so we implement this function even if USB
 * mass storage devices supported by this driver are not ejectable.
 */

#ifndef TOSONLY
#if 0
# define DEV_DEBUG	1
#endif
#endif

#ifdef TOSONLY
#include "mint/mintbind.h" /* Dcntl() */
#endif
#include "mint/mint.h"
#include "../../global.h"

#include "part.h"
#include "xhdi.h"


/*--- Defines ---*/

#define XHDI_VERSION		0x130
#define MAX_IPL			5
#define XH_TARGET_REMOVABLE	0x02L
#define XH_TARGET_EJECTABLE	0x08L
#define STRINGLEN		33 /* including termination character */
#define DRIVER_NAME_MAXLEN		17
#define DRIVER_VERSION_MAXLEN	7
#define DRIVER_COMPANY_MAXLEN	17

#ifdef TOSONLY
char *DRIVER_NAME = "TOS USB";
#else
char *DRIVER_NAME = "FreeMiNT USB";
#endif
char *DRIVER_COMPANY = "FreeMiNT list";

/*--- External variables ---*/

extern char *drv_version;
#if TOSONLY
extern short MagiC;
#endif

/* --- External functions ---*/

extern block_dev_desc_t *usb_stor_get_dev(long);
extern ulong usb_stor_read(long, ulong, ulong, void *);
extern ulong usb_stor_write(long, ulong, ulong, const void *);
extern void usb_stor_eject(long);
extern void usb_build_bpb(BPB *bpbptr, void *bs);

/*--- Functions prototypes ---*/

typedef long (*XHDI_HANDLER)(ushort opcode, ...);
static XHDI_HANDLER next_handler; /* Next handler installed by XHNewCookie() */

extern long usbxhdi(ushort opcode, ...);
long install_xhdi_driver(void);
long xhdi_handler(ushort *stack);
long dl_maxdrives = MAX_LOGICAL_DRIVE;
long XHDOSLimits(ushort which, ulong limit);

/*--- Global variables ---*/

ulong my_drvbits;
USB_PUN_INFO pun_usb;

/*---Functions ---*/

/*
 * XHDI syscall XHDOSLimits routine
 */
static long
sys_XHDOSLimits(ushort which,ulong limit)
{
#ifdef TOSONLY
	static long dl_secsiz, dl_clusts, dl_maxsec, dl_clusts12;
	static long dl_clustsiz, dl_minspc = 2, dl_maxspc = 2;
	static long dl_clusts32;
	static long dl_minfat, dl_maxfat;
	static int first_time = 1;
	long old_limit = 0;
	long unhandled = 0;
	long i;

	if (first_time)
	{
		if (MagiC >= 0)
		{
			MX_DOSLIMITS **ptr;
			ptr = (MX_DOSLIMITS **) Dcntl(KER_DOSLIMITS, 0, 0L);
			dl_secsiz = (*ptr)->max_secsizb;
			dl_minfat = (*ptr)->min_nfats;
			dl_maxfat = (*ptr)->max_nfats;
			dl_minspc = (*ptr)->min_nclsiz;
			dl_maxspc = (*ptr)->max_nclsiz;
			dl_clusts = (*ptr)->max_ncl;
			dl_maxsec = (*ptr)->max_nsec;
			dl_clusts12 = MAX_FAT12_CLUSTERS;
		}
		else
		{
			ushort version = Sversion();            /* determine GEMDOS version */
			version = (version>>8) | (version<<8);  /* swap to correct order */
			if (version > 0x0040)                   /* unknown               */
				version = 0x0000;               /* so force it to lowest */

			if (version < 0x0015)                   /* TOS 1.00, 1.02, KAOS TOS */
			{
				dl_secsiz = 8192L;
				dl_clusts = 16383L;
				dl_maxsec = 32767L;             /* max partition size = 256MB approx */
				dl_clusts12 = 2046L;
			}
			else if (version < 0x0030)              /* i.e. TOS 1.04 to TOS 3.06 */
			{
				dl_secsiz = 8192L;
				dl_clusts = 32766L;
				dl_maxsec = 65535L;             /* max partition size = 512MB approx */
				dl_clusts12 = MAX_FAT12_CLUSTERS;
			}
			else                                    /* i.e. TOS 4.0x */
			{
				dl_secsiz = MAX_LOGSEC_SIZE;
				dl_clusts = 32766L;
				dl_maxsec = 65535L;             /* max partition size = 1024MB approx */
				dl_clusts12 = MAX_FAT12_CLUSTERS;
			}
			dl_minfat = 2;
			dl_maxfat = 2;
		}
		dl_clustsiz = dl_secsiz * 2;
		if (MagiC >= 0x610)
			dl_clusts32 = 268435455L;
		else
			dl_clusts32 = 0;
		first_time = 0;
	}

	switch (which)
	{
		/* maximal sector size (BIOS level) */
		case XH_DL_SECSIZ:
			old_limit = dl_secsiz;
			if (limit != 0)
				dl_secsiz = limit;
			break;

		/* minimal number of FATs */
		case XH_DL_MINFAT:
			old_limit = dl_minfat;
			if (limit != 0)
				dl_minfat = limit;
			break;

		/* maximal number of FATs */
		case XH_DL_MAXFAT:
			old_limit = dl_maxfat;
			if (limit != 0)
				dl_maxfat = limit;
			break;

		/* sectors per cluster minimal */
		case XH_DL_MINSPC:
			old_limit = dl_minspc;
			if (limit != 0)
				dl_minspc = limit;
			break;

		/* sectors per cluster maximal */
		case XH_DL_MAXSPC:
			old_limit = dl_maxspc;
			if (limit != 0)
				dl_maxspc = limit;
			break;

		/* maximal number of clusters of a 16 bit FAT */
		case XH_DL_CLUSTS:
			old_limit = dl_clusts;
			if (limit != 0)
				dl_clusts = limit;
			break;

		/* maximal number of sectors */
		case XH_DL_MAXSEC:
			old_limit = dl_maxsec;
			if (limit != 0)
				dl_maxsec = limit;
			break;

		/* maximal number of BIOS drives supported by the DOS */
		case XH_DL_DRIVES:
			old_limit = dl_maxdrives;
			if (limit != 0)
				dl_maxdrives = limit;
			break;

		/* maximal clustersize */
		case XH_DL_CLSIZB:
			old_limit = dl_clustsiz;
			if (limit != 0)
				dl_clustsiz = limit;
			break;

		/* maximal (bpb->rdlen * bpb->recsiz / 32) */
		case XH_DL_RDLEN:
			return 1008L;   /* we return the same value as HDDRIVER */

		/* maximal number of clusters of a 12 bit FAT */
		case XH_DL_CLUSTS12:
			old_limit = dl_clusts12;
			if (limit != 0)
				dl_clusts12 = limit;
			break;

		/* maximal number of clusters of a 32 bit FAT */
		case XH_DL_CLUSTS32:
			old_limit = dl_clusts32;
			if (limit != 0)
				dl_clusts32 = limit;
			break;

		/* supported bits in bpb->bflags */
		case XH_DL_BFLAGS:
			return 0x00000001L;

		default:
			unhandled = 1;
			break;
	}

	if (unhandled) {
		return ENOSYS;
	}

	/* Rebuild BPB based on XHDOSLimit changes */
	if (limit != 0) {
		for (i = 0; i < dl_maxdrives; i++) {
			usb_build_bpb(&pun_usb.bpb[i], NULL);
		}
	}

	return old_limit;
#else
	if (limit == 0)
		/* We call the kernel to show its limits */
		return xhdoslimits(which, limit);
	else
		/* This should never happen, MiNT never will set new limit values as
		 * long as the kernel doesn't have loadable/unloadable files systems.
		 */
		return ENOSYS;
#endif /* TOSONLY */
}

static ushort
XHGetVersion(void)
{
	ushort version = XHDI_VERSION;

	if (next_handler) {
		ushort next_version = (ushort)next_handler(XHGETVERSION);
		if (next_version < version)
			version = next_version;
	}

	return version;
}

static ulong
XHDrvMap(void)
{
	ulong drvmap = my_drvbits;

	if (next_handler)
		drvmap |= next_handler(XHDRVMAP);

	return drvmap;
}

static long
XHNewCookie(ulong newcookie)
{
	if (next_handler) {
		return next_handler(XHNEWCOOKIE, newcookie);
	}

	next_handler = (XHDI_HANDLER)newcookie;

	return E_OK;
}

static long
XHInqDev2(ushort drv, ushort *major, ushort *minor, ulong *start, BPB *bpb,
	  ulong *blocks, char *partid)
{
	long pstart;
	BPB *myBPB;

	DEBUG(("XHInqDev2(%c:) drv=%d pun %x",
		'A' + drv, drv, pun_usb.pun[drv]));

	if (next_handler) {
		long ret = next_handler(XHINQDEV2, drv, major, minor, start,
					bpb, blocks, partid);
		if (ret != ENOSYS && ret != ENODEV && ret != ENXIO)
			return ret;
	}

	if (drv >= dl_maxdrives)
		return ENODEV;

	pstart = pun_usb.partition_start[drv];

	if (pun_usb.pun[drv] & PUN_VALID)
		return ENODEV;

	if (major) {
		*major = (PUN_DEV+PUN_USB) & pun_usb.pun[drv];
		DEBUG(("XHInqDev2() major: %d", *major));
	}

	if (minor)
		*minor = 0;

	if (bpb)
		bpb->recsiz = 0;

	//if (!pstart)
		//return EBUSY;

	if (start) {
		*start = pstart;
		DEBUG(("XHInqDev2() pstart: %lx", *start));
	}

	myBPB = (&pun_usb.bpb[drv]);

	if (bpb) {
		memcpy(bpb, myBPB, sizeof(BPB));

		DEBUG(("XHInqDev2() BPB"));
		DEBUG(("recsiz:	%u", bpb->recsiz));
		DEBUG(("clsiz:	%d", bpb->clsiz));
		DEBUG(("clsizb:	%u", bpb->clsizb));
		DEBUG(("rdlen:	%d", bpb->rdlen));
		DEBUG(("fsiz:	%d", bpb->fsiz));
		DEBUG(("fatrec:	%d", bpb->fatrec));
		DEBUG(("datrec:	%d", bpb->datrec));
		DEBUG(("numcl:	%u", bpb->numcl));
		DEBUG(("bflags:	%x", bpb->bflags));
	}

	if (blocks) {
		*blocks = pun_usb.psize[drv];
		DEBUG(("XHInqDev2(%c:) blocks=%ld",
			'A' + drv, *blocks));
	}

	if (partid) {
		memcpy(partid, &pun_usb.ptype[drv], sizeof(long));

		if (partid[0] == '\0') /* DOS partitiopn */
			DEBUG(("XHInqDev2(%c:) major=%d, partid=%08lx, type=0x%lx",
				'A' + drv, *major, *((long *)partid),
				pun_usb.ptype[drv]));
		else
			DEBUG(("XHInqDev2(%c:) major=%d, ID=%c%c%c",
				'A' + drv, *major, partid[0], partid[1],
				partid[2]));
	}

	return E_OK;
}

static long
XHInqDev(ushort drv, ushort *major, ushort *minor, ulong *start, BPB *bpb)
{
	if (next_handler) {
		long ret = next_handler(XHINQDEV, drv, major, minor,
					start, bpb);
		if (ret != ENOSYS && ret != ENODEV && ret != ENXIO)
			return ret;
	}

	if (drv >= dl_maxdrives)
		return ENODEV;

	if (pun_usb.pun[drv] & PUN_VALID)
		return ENODEV;

	return XHInqDev2(drv, major, minor, start, bpb, NULL, NULL);
}

static long
XHReserve(ushort major, ushort minor, ushort do_reserve, ushort key)
{
	if (next_handler) {
		long ret = next_handler(XHRESERVE, major, minor, do_reserve,
					key);
		if (ret != ENOSYS && ret != ENODEV && ret != ENXIO)
			return ret;
	}

	if ((major & PUN_USB) == 0)
		return ENODEV;

	return ENOSYS;
}

static long
XHLock(ushort major, ushort minor, ushort do_lock, ushort key)
{
	if (next_handler) {
		long ret = next_handler(XHLOCK, major, minor, do_lock, key);
		if (ret != ENOSYS && ret != ENODEV && ret != ENXIO)
			return ret;
	}

	if ((major & PUN_USB) == 0)
		return ENODEV;

	return ENOSYS;
}

static long
XHStop(ushort major, ushort minor, ushort do_stop, ushort key)
{
	if (next_handler) {
		long ret = next_handler(XHSTOP, major, minor, do_stop, key);
		if (ret != ENOSYS && ret != ENODEV && ret != ENXIO)
			return ret;
	}

	if ((major & PUN_USB) == 0)
		return ENODEV;

	return ENOSYS;
}

static long
XHEject(ushort major, ushort minor, ushort do_eject, ushort key)
{
	if (next_handler) {
		long ret = next_handler(XHEJECT, major, minor, do_eject, key);
		if (ret != ENOSYS && ret != ENODEV && ret != ENXIO)
			return ret;
	}

	if ((major & PUN_USB) == 0)
		return ENODEV;

	/* mass storage logical device number in the USB bus */
	short dev = major & PUN_DEV;

	if (do_eject == 1)
		usb_stor_eject(dev);
	else
	/* When we eject a device it's removed from the PUN struct,
	 * so we shouldn't get an insert medium parameter (do_eject=0).
	 */
		return EERROR;

	return E_OK;
}

static long
XHInqDriver(ushort dev, char *name, char *version, char *company,
		ushort *ahdi_version, ushort *max_IPL)
{
	if (next_handler) {
		long ret = next_handler(XHINQDRIVER, dev, name, version, company,
					ahdi_version, max_IPL);
		if (ret != ENOSYS && ret != ENODEV && ret != ENXIO)
			return ret;
	}

	if (dev >= dl_maxdrives)
		return ENODEV;

	if (pun_usb.pun[dev] & PUN_VALID)
		return ENODEV;

	if(name)
		strncpy(name, DRIVER_NAME, DRIVER_NAME_MAXLEN);
	if(version)
		strncpy(version, drv_version, DRIVER_VERSION_MAXLEN);
	if(company)
		strncpy(company, DRIVER_COMPANY, DRIVER_COMPANY_MAXLEN);
	if(ahdi_version)
		*ahdi_version = pun_usb.version_num;
	if(max_IPL)
		*max_IPL = MAX_IPL;

	return E_OK;
}

static long
XHDriverSpecial(ulong key1, ulong key2, ushort subopcode, void *data)
{
	if (next_handler) {
		long ret = next_handler(XHDRIVERSPECIAL, key1, key2, subopcode,
					data);
		if (ret != ENOSYS && ret != ENODEV && ret != ENXIO)
			return ret;
	}

	return ENOSYS;
}

static long
XHMediumChanged(ushort major, ushort minor)
{
	if (next_handler) {
		long ret = next_handler(XHMEDIUMCHANGED, major, minor);
		if (ret != ENOSYS && ret != ENODEV && ret != ENXIO)
			return ret;
	}

	if ((major & PUN_USB) == 0)
		return ENODEV;

	return ENOSYS;
}

static long
XHMiNTInfo(void *data)
{
	if (next_handler) {
		long ret = next_handler(XHMINTINFO, data);
		if (ret != ENOSYS && ret != ENODEV && ret != ENXIO)
			return ret;
	}

	return ENOSYS;
}

long
XHDOSLimits(ushort which, ulong limit)
{
	if (limit != 0) {
		(void)sys_XHDOSLimits(which, limit);
	}

	if (next_handler) {
		long ret = next_handler(XHDOSLIMITS, which, limit);
		if (ret != ENOSYS && ret != ENODEV && ret != ENXIO) {
			return ret;
		}
	}

	return sys_XHDOSLimits(which, limit);
}

static long
XHLastAccess(ushort major, ushort minor, ulong *ms)
{
	if (next_handler) {
		long ret = next_handler(XHLASTACCESS, major, minor, ms);
		if (ret != ENOSYS && ret != ENODEV && ret != ENXIO)
			return ret;
	}

	if ((major & PUN_USB) == 0)
		return ENODEV;

	return ENOSYS;
}

static long
XHReaccess(ushort major, ushort minor)
{
	if (next_handler) {
		long ret = next_handler(XHREACCESS, major, minor);
		if (ret != ENOSYS && ret != ENODEV && ret != ENXIO)
			return ret;
	}

	if ((major & PUN_USB) == 0)
		return ENODEV;

	return ENOSYS;
}

static long
XHInqTarget2(ushort major, ushort minor, ulong *blocksize, ulong *deviceflags,
		 char *productname, ushort stringlen)
{
	DEBUG(("XHInqTarget2(%d.%d)", major, minor));

	if (next_handler) {
		long ret = next_handler(XHINQTARGET2, major, minor, blocksize,
					deviceflags, productname, stringlen);
		if (ret != ENOSYS && ret != ENODEV && ret != ENXIO)
			return ret;
	}

	if ((major & PUN_USB) == 0)
		return ENODEV;

	{
		short dev = major & PUN_DEV;
		block_dev_desc_t *dev_desc = usb_stor_get_dev(dev);
	
		if (blocksize) {
			*blocksize = dev_desc->blksz;
			DEBUG(("XHInqTarget2(%d.%d) blocksize: %ld",
				major, minor, *blocksize));
		}

		if (deviceflags) {
			if (dev_desc->removable)
				*deviceflags = XH_TARGET_REMOVABLE | XH_TARGET_EJECTABLE;
			DEBUG(("XHInqTarget2(%d.%d) flags: %08lx",
				major, minor, *deviceflags));
		}

		if (productname) {
			char devName[64];

			DEBUG(("XHInqTarget2(%d.%d) %d", major, minor, dev));

			memset(devName, 0, 64);
			strcat(devName, dev_desc->vendor);
			strcat(devName, " ");
			strcat(devName, dev_desc->product);
			strncpy(productname, devName, stringlen);
		}
	}

	return E_OK;
}

static long
XHInqTarget(ushort major, ushort minor, ulong *blocksize, ulong *deviceflags,
		char *productname)
{
	if (next_handler) {
		long ret = next_handler(XHINQTARGET, major, minor, blocksize,
					deviceflags, productname);

		if (ret != ENOSYS && ret != ENODEV && ret != ENXIO)
			return ret;
	}

	if ((major & PUN_USB) == 0)
		return ENODEV;

	return XHInqTarget2(major, minor, blocksize, deviceflags,
				productname, STRINGLEN);
}

static long
XHGetCapacity(ushort major, ushort minor, ulong *blocks,
		ulong *blocksize)
{
	DEBUG(("XHGetCapacity(%d.%d)\n", major, minor));
	
	if (next_handler) {
		long ret = next_handler(XHGETCAPACITY, major, minor, blocks,
					blocksize);
		if (ret != ENOSYS && ret != ENODEV && ret != ENXIO)
			return ret;
	}

	if ((major & PUN_USB) == 0)
		return ENODEV;

	{
		short dev = major & PUN_DEV;
		block_dev_desc_t *dev_desc = usb_stor_get_dev(dev);

		*blocks = dev_desc->lba;
		*blocksize = dev_desc->blksz;
	}

	return E_OK;
}

static long
XHReadWrite(ushort major, ushort minor, ushort rw,
		ulong sector, ushort count, void *buf)
{
	long ret;

	DEBUG(("XH%s(device=%d.%d, sector=%ld, count=%d, buf=%lx)",
		rw ? "Write" : "Read", major, minor, sector, count, (unsigned long)buf));

	if (next_handler) {
		ret = next_handler(XHREADWRITE, major, minor, rw, sector,
				   count, buf);
		if (ret != ENOSYS && ret != ENODEV && ret != ENXIO)
			return ret;
	}

	if ((major & PUN_USB) == 0)
		return ENODEV;

	if (minor != 0)
		return ENODEV;

	if (!count)
		return EERROR;

	/* device number in the USB bus */
	short dev = major & PUN_DEV;

	if (rw & 0x0001) {
		ret = usb_stor_write(dev, sector, (long)count, buf);

		DEBUG(("usb_stor_write() returned %ld", ret));
	}
	else {
		ret = usb_stor_read(dev, sector, (long)count, buf);

		DEBUG(("usb_stor_read() returned %ld", ret));
	}

	if (ret < 0)
		return ret;

	return E_OK;
}

long
xhdi_handler(ushort *stack)
{
	ushort opcode = *stack;

	DEBUG(("XHDI handler, opcode: %d", opcode));

	switch (opcode)
	{
		case XHGETVERSION:
		{
			return XHGetVersion();
		}

		case XHINQTARGET:
		{
			struct XHINQTARGET_args
			{
				ushort opcode;
				ushort major;
				ushort minor;
				ulong *blocksize;
				ulong *deviceflags;
				char *productname;
			} *args = (struct XHINQTARGET_args *)stack;

			return XHInqTarget(args->major, args->minor,
					   args->blocksize, args->deviceflags,
					   args->productname);
		}

		case XHRESERVE:
		{
			struct XHRESERVE_args
			{
				ushort opcode;
				ushort major;
				ushort minor;
				ushort do_reserve;
				ushort key;
			} *args = (struct XHRESERVE_args *)stack;

			return XHReserve(args->major, args->minor,
					 args->do_reserve, args->key);
		}

		case XHLOCK:
		{
			struct XHLOCK_args
			{
				ushort opcode;
				ushort major;
				ushort minor;
				ushort do_lock;
				ushort key;
			} *args = (struct XHLOCK_args *)stack;

			return XHLock(args->major, args->minor,
					  args->do_lock, args->key);
		}

		case XHSTOP:
		{
			struct XHSTOP_args
			{
				ushort opcode;
				ushort major;
				ushort minor;
				ushort do_stop;
				ushort key;
			} *args = (struct XHSTOP_args *)stack;

			return XHStop(args->major, args->minor,
					  args->do_stop, args->key);
		}

		case XHEJECT:
		{
			struct XHEJECT_args
			{
				ushort opcode;
				ushort major;
				ushort minor;
				ushort do_eject;
				ushort key;
			} *args = (struct XHEJECT_args *)stack;

			return XHEject(args->major, args->minor, args->do_eject,
					   args->key);
		}

		case XHDRVMAP:
		{
			return XHDrvMap();
		}

		case XHINQDEV:
		{
			struct XHINQDEV_args
			{
				ushort opcode;
				ushort drv;
				ushort *major;
				ushort *minor;
				ulong *start;
				BPB *bpb;
			} *args = (struct XHINQDEV_args *)stack;

			return XHInqDev(args->drv, args->major, args->minor,
					args->start, args->bpb);
		}

		case XHINQDRIVER:
		{
			struct XHINQDRIVER_args
			{
				ushort opcode;
				ushort dev;
				char *name;
				char *version;
				char *company;
				ushort *ahdi_version;
				ushort *maxIPL;
			} *args = (struct XHINQDRIVER_args *)stack;

			return XHInqDriver(args->dev, args->name, args->version,
					   args->company, args->ahdi_version,
					   args->maxIPL);
		}

		case XHNEWCOOKIE:
		{
			struct XHNEWCOOKIE_args
			{
				ushort opcode;
				ulong newcookie;
			} *args = (struct XHNEWCOOKIE_args *)stack;

			return XHNewCookie(args->newcookie);
		}

		case XHREADWRITE:
		{
			struct XHREADWRITE_args
			{
				ushort opcode;
				ushort major;
				ushort minor;
				ushort rw;
				ulong sector;
				ushort count;
				void *buf;
			} *args = (struct XHREADWRITE_args *)stack;

			return XHReadWrite(args->major, args->minor, args->rw,
					   args->sector, args->count,
					   args->buf);
		}

		case XHINQTARGET2:
		{
			struct XHINQTARGET2_args
			{
				ushort opcode;
				ushort major;
				ushort minor;
				ulong *blocksize;
				ulong *deviceflags;
				char *productname;
				ushort stringlen;
			} *args = (struct XHINQTARGET2_args *)stack;

			return XHInqTarget2(args->major, args->minor,
						args->blocksize, args->deviceflags,
						args->productname, args->stringlen);
		}

		case XHINQDEV2:
		{
			struct XHINQDEV2_args
			{
				ushort opcode;
				ushort drv;
				ushort *major;
				ushort *minor;
				ulong *start;
				BPB *bpb;
				ulong *blocks;
				char *partid;
			} *args = (struct XHINQDEV2_args *)stack;

			return XHInqDev2(args->drv, args->major, args->minor,
					 args->start, args->bpb, args->blocks,
					 args->partid);
		}

		case XHDRIVERSPECIAL:
		{
			struct XHDRIVERSPECIAL_args
			{
				ushort opcode;
				ulong key1;
				ulong key2;
				ushort subopcode;
				void *data;
			} *args = (struct XHDRIVERSPECIAL_args *)stack;

			return XHDriverSpecial(args->key1, args->key2,
						   args->subopcode, args->data);
		}

		case XHGETCAPACITY:
		{
			struct XHGETCAPACITY_args
			{
				ushort opcode;
				ushort major;
				ushort minor;
				ulong *blocks;
				ulong *blocksize;
			} *args = (struct XHGETCAPACITY_args *)stack;

			return XHGetCapacity(args->major, args->minor,
						 args->blocks, args->blocksize);
		}

		case XHMEDIUMCHANGED:
		{
			struct XHMEDIUMCHANGED_args
			{
				ushort opcode;
				ushort major;
				ushort minor;
			} *args = (struct XHMEDIUMCHANGED_args *)stack;

			return XHMediumChanged(args->major, args->minor);
		}

		/* FIXME: After we figure out how to handle this call */
		case XHMINTINFO:
		{
			struct XHMINTINFO_args
			{
				ushort opcode;
				void *data;
			} *args = (struct XHMINTINFO_args *)stack;

			return XHMiNTInfo(args->data);
		}

		case XHDOSLIMITS:
		{
			struct XHDOSLIMITS_args
			{
				ushort opcode;
				ushort which;
				ulong limit;
			} *args = (struct XHDOSLIMITS_args *)stack;

			return XHDOSLimits(args->which, args->limit);
		}

		case XHLASTACCESS:
		{
			struct XHLASTACCESS_args
			{
				ushort opcode;
				ushort major;
				ushort minor;
				ulong *ms;
			} *args = (struct XHLASTACCESS_args *)stack;

			return XHLastAccess(args->major, args->minor, args->ms);
		}

		case XHREACCESS:
		{
			 struct XHREACCESS_args
			{
				ushort opcode;
				ushort major;
				ushort minor;
			} *args = (struct XHREACCESS_args *)stack;

			return XHReaccess(args->major, args->minor);
		}

		default:
		{
			return ENOSYS;
		}
	}
}

#ifdef TOSONLY
#define XHDIMAGIC 0x27011992L

typedef long (*cookie_fun)(unsigned short opcode,...);

static cookie_fun
get_fun_ptr (void)
{
	static cookie_fun XHDI = NULL;
	long *magic_test;
	
	getcookie (COOKIE_XHDI, (long *)&XHDI);

	/* check magic */
		
	magic_test = (long *)XHDI;
	if (magic_test && (magic_test[-1] != XHDIMAGIC))
		XHDI = NULL;
	
	return XHDI;
}
#endif

long
install_xhdi_driver(void)
{
#ifndef TOSONLY
	return xhnewcookie(usbxhdi);
#else
	long r = 0;

	/* For querying a limit with XHDOSLimit(), the limit parameter
	 * must be set to 0, if we place 0 as value in the functions
	 * below the compiler will push it to the satck as a short
	 * and the limit parameter must be a long. We use a long
	 * variable to avoid this.
	 */
	long query = 0;

	cookie_fun XHDI = get_fun_ptr ();

	if (XHDI) {
		long tmp;

		/* According to the XHDI specification if there
		 * is a XHDI driver already installed query from
		 * it the limit values and save them.
		 */
		tmp = XHDI(XHDOSLIMITS, XH_DL_SECSIZ, query);
		sys_XHDOSLimits(XH_DL_SECSIZ, tmp);
		tmp = XHDI(XHDOSLIMITS, XH_DL_MINFAT, query);
		sys_XHDOSLimits(XH_DL_MINFAT, tmp);
		tmp = XHDI(XHDOSLIMITS, XH_DL_MAXFAT, query);
		sys_XHDOSLimits(XH_DL_MAXFAT, tmp);
		tmp = XHDI(XHDOSLIMITS, XH_DL_MINSPC, query);
		sys_XHDOSLimits(XH_DL_MINSPC, tmp);
		tmp = XHDI(XHDOSLIMITS, XH_DL_MAXSPC, query);
		sys_XHDOSLimits(XH_DL_MAXSPC, tmp);
		tmp = XHDI(XHDOSLIMITS, XH_DL_CLUSTS, query);
		sys_XHDOSLimits(XH_DL_CLUSTS, tmp);
		tmp = XHDI(XHDOSLIMITS, XH_DL_MAXSEC, query);
		sys_XHDOSLimits(XH_DL_MAXSEC, tmp);
		/* We keep dl_maxdrives as 32 although we were
		 * running on TOS, we handle a extended PUN_INFO
		 * struct that can keep that number of partitions.
		 *
		 * tmp = XHDI(XHDOSLIMITS, XH_DL_DRIVES, query);
		 * sys_XHDOSLimits(XH_DL_DRIVES, tmp);
		 */
		tmp = XHDI(XHDOSLIMITS, XH_DL_CLSIZB, query);
		sys_XHDOSLimits(XH_DL_CLSIZB, tmp);
		tmp = XHDI(XHDOSLIMITS, XH_DL_RDLEN, query);
		sys_XHDOSLimits(XH_DL_RDLEN, tmp);
		tmp = XHDI(XHDOSLIMITS, XH_DL_CLUSTS12, query);
		sys_XHDOSLimits(XH_DL_CLUSTS12, tmp);
		tmp = XHDI(XHDOSLIMITS, XH_DL_CLUSTS32, query);
		sys_XHDOSLimits(XH_DL_CLUSTS32, tmp);
		tmp = XHDI(XHDOSLIMITS, XH_DL_BFLAGS, query);
		sys_XHDOSLimits(XH_DL_BFLAGS, tmp);

		/* HDDRIVER marks a media change internally when XHDOSLimits()
		 * is called for setting new limits. Then when the BPB is
		 * requested re-evaluates the boot sector data based on the new
		 * limit for the drives handled by it. I guess the code below was
		 * put here for that reason. Now we don't set the limits instead
		 * we query them, so this code shouldn't be necessary any more,
		 * but because I'm not 100% sure I leave it for now.
		 */
		if (Mediach(2)) (void)Getbpb(2);

		next_handler = XHDI;
	}
	else
	{
		/* If we're the first XHDI driver installed call
		 * sys_XHDOSLimits() querying any value so it has
		 * the opportunity to guess and set the limit
		 * values depending on the OS we're running on.
		 */
		sys_XHDOSLimits(0, 0);
	}

	setcookie(COOKIE_XHDI, (long)&usbxhdi);

	return r;
#endif
}
