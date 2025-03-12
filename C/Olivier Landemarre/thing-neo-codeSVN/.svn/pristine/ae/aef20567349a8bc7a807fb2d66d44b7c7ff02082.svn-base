/*
    @(#)XHDI/xhdi.h
    
    Julian F. Reschke, 1999-05-02
    
 	Bindings for the XHDI functions
	--- NOT FULLY TESTED, USE AT YOUR OWN RISK ---

    Important:
    
    Do calls only if XHGetVersion() was successful
*/

#ifndef __XHDI__
#define __XHDI__

#ifndef _BPB
/*#include <mintbind.h>*/
#define _BPB BPB
#endif

#define XH_TARGET_STOPPABLE     0x00000001L
#define XH_TARGET_REMOVABLE     0x00000002L
#define XH_TARGET_LOCKABLE      0x00000004L
#define XH_TARGET_EJECTABLE     0x00000008L
#define XH_TARGET_LOCKED        0x20000000L
#define XH_TARGET_STOPPED       0x40000000L
#define XH_TARGET_RESERVED      0x80000000L

#define XH_MI_SETKERINFO	0
#define XH_MI_GETKERINFO	1

#define XH_DL_SECSIZ	0
#define XH_DL_MINFAT	1
#define XH_DL_MAXFAT	2
#define XH_DL_MINSPC	3
#define XH_DL_MAXSPC	4
#define XH_DL_CLUSTS	5
#define XH_DL_MAXSEC	6
#define XH_DL_DRIVES	7
#define XH_DL_CLSIZB	8
#define XH_DL_RDLEN		9
#define XH_DL_CLUSTS12	12
#define XH_DL_CLUSTS32	13
#define XH_DL_BFLAGS	14


/* Inquire protocol version number */
unsigned short
XHGetVersion (void);

/* Inquire informations about one target */
long
XHInqTarget (unsigned short major, unsigned short minor, unsigned long *block_size,
             unsigned long *device_flags, char *product_name);

/* Reserve or release a target */
long
XHReserve (unsigned short major, unsigned short minor, unsigned short do_reserve, unsigned short key);

/* Lock or unlock a target with removable media */
long
XHLock (unsigned short major, unsigned short minor, unsigned short do_lock, unsigned short key);

/* Stop or start target */
long
XHStop (unsigned short major, unsigned short minor, unsigned short do_stop, unsigned short key);

/* Eject medium */
long
XHEject (unsigned short major, unsigned short minor, unsigned short do_eject, unsigned short key);

/* Get bit mask of available XHDI devices */
unsigned long
XHDrvMap (void);

/* Get major device number (eg. target), minor device number (eg.
   LUN), starting sector and BPB */
long
XHInqDev (unsigned short bios_device, unsigned short *major, unsigned short *minor,
          unsigned long *start_sector, _BPB *bpb);

/* Get informations about the driver */
long
XHInqDriver (unsigned short bios_device, char *name, char *version,
             char *company, unsigned short *ahdi_version,
             unsigned short *maxIPL);

/* Install additional XHDI handler */
long
XHNewCookie (void *newcookie);

/* Do a physical access */
long
XHReadWrite (unsigned short major, unsigned short minor, unsigned short rwflag,
             unsigned long recno, unsigned short count, void *buf);

/* Make printable device name */
void
XHMakeName (unsigned short major, unsigned short minor, unsigned long start_sector, char *name);

/* New version of XHInqTarget */
long
XHInqTarget2 (unsigned short major, unsigned short minor, unsigned long *block_size,
              unsigned long *device_flags, char *product_name,
              unsigned short stringlen);
              
/* New version of XHInqDev */
long
XHInqDev2 (unsigned short bios_device, unsigned short *major, unsigned short *minor,
           unsigned long *start_sector, _BPB *bpb, unsigned long *blocks, char *partid);

/* Special opcode for custom driver extensions */
long
XHDriverSpecial (unsigned long key1, unsigned long key2, unsigned short subopcode, void *data);

/* Inquire drive capacity */
long
XHGetCapacity (unsigned short major, unsigned short minor, unsigned long *blocks, unsigned long *bs);

/* Inform driver about media change */
long
XHMediumChanged (unsigned short major, unsigned short minor);

/* Get/set MiNT kernel information */
long
XHMiNTInfo (unsigned short opcode, void *data);

/* Get/set DOS limits */
long
XHDOSLimits (unsigned short which, unsigned long limit);

/* Get ms since last access */
long
XHLastAccess (unsigned short major, unsigned short minor, unsigned long *ms);

/* Force reaccess of device */
long
XHReaccess (unsigned short major, unsigned short minor);

#endif
