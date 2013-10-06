/*
	XHDI

	Copyright (C) 2002	Patrice Mandin

	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with this library; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
*/

#ifndef _XHDI_H
#define _XHDI_H

/*--- Defines ---*/

/* XHInqTarget(), XHInqTarget2() */
#define XH_TARGET_STOPPABLE	0
#define XH_TARGET_REMOVABLE	1
#define XH_TARGET_LOCKABLE	2
#define XH_TARGET_EJECTABLE	3
#define XH_TARGET_LOCKED	29
#define XH_TARGET_STOPPED	30
#define XH_TARGET_RESERVED	31

/* XHReserve() */
#define XH_RESERVE	1
#define XH_RELEASE	0

/* XHLock() */
#define XH_LOCK		1
#define XH_UNLOCK	0

/* XHStop() */
#define XH_STOP		1
#define XH_START	0

/* XHEject() */
#define XH_EJECT	1
#define XH_INSERT	0

/* XHMiNTInfo() */
#define XH_MI_SET_KERINFO	0
#define XH_MI_GET_KERINFO	1

/* XHDOSLimits() */
#define XH_DL_SECSIZ	0
#define XH_DL_MINFAT	1
#define XH_DL_MAXFAT	2
#define XH_DL_MINSPC	3
#define XH_DL_MAXSPC	4
#define XH_DL_CLUSTS	5
#define XH_DL_MAXSEC	6
#define XH_DL_DRIVES	7
#define XH_DL_RDLEN		9
#define XH_DL_CLUSTS12	12
#define XH_DL_CLUSTS32	13
#define XH_DL_BFLAGS	14

/*--- Functions prototypes ---*/

unsigned short XHGetVersion(void);

long XHInqTarget(
	unsigned short major,
	unsigned short minor,
	unsigned long *blocksize,
	unsigned long *device_flags,
	char *product_name
);

long XHReserve(
	unsigned short major,
	unsigned short minor,
	unsigned short do_reserve,
	unsigned short key
);

long XHLock(
	unsigned short major,
	unsigned short minor,
	unsigned short do_lock,
	unsigned short key
);

long XHStop(
	unsigned short major,
	unsigned short minor,
	unsigned short do_stop,
	unsigned short key
);

long XHEject(
	unsigned short major,
	unsigned short minor,
	unsigned short do_eject,
	unsigned short key
);

unsigned long XHDrvMap(void);

long XHInqDev(
	unsigned short bios_device,
	unsigned short *major,
	unsigned short *minor,
	unsigned long *start_sector,
	_BPB *bpb
);

long XHInqDriver(
	unsigned short bios_device,
	char *name,
	char *version,
	char *company,
	unsigned short *ahdi_version,
	unsigned short *max_ipl
);

long XHNewCookie(unsigned long newcookie);

long XHReadWrite(
	unsigned short major,
	unsigned short minor,
	unsigned short rwflag,
	unsigned long recno,
	unsigned short count,
	void *buf
);

long XHInqTarget2(
	unsigned short major,
	unsigned short minor,
	unsigned long *blocksize,
	unsigned long *device_flags,
	char *product_name,
	unsigned short stringlen
);

long XHInqDev2(
	unsigned short bios_device,
	unsigned short *major,
	unsigned short *minor,
	unsigned long *start_sector,
	_BPB *bpb,
	unsigned long *blocks,
	char *partid
);

long XHDriverSpecial(
	unsigned long key1,
	unsigned long key2,
	unsigned short subopcode,
	void *data
);

long XHGetCapacity(
	unsigned short major,
	unsigned short minor,
	unsigned long *blocks,
	unsigned long *blocksize
);

long XHMediumChanged(
	unsigned short major,
	unsigned short minor
);

long XHMiNTInfo(
	unsigned short opcode,
	void *data
);

long XHDOSLimits(
	unsigned short which,
	unsigned long limit
);

long XHLastAccess(
	unsigned short major,
	unsigned short minor,
	unsigned long *ms
);

long XHReaccess(
	unsigned short major,
	unsigned short minor
);

#endif /* _XHDI_H */
