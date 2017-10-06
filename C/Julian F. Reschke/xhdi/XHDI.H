/*
    @(#)XHDI/xhdi.h
    
    Julian F. Reschke, 2. Oktober 1994
    
 	Bindings for the XHDI functions
	--- NOT FULLY TESTED, USE AT YOUR OWN RISK ---

    Important:
    
    Do calls only if XHGetVersion() was successful
*/

#ifndef __XHDI__
#define __XHDI__

#ifndef BPB
#include <tos.h>
#endif

#ifndef UWORD
#define UWORD unsigned int
#endif

#ifndef LONG
#define LONG long
#endif

#ifndef ULONG
#define ULONG unsigned long
#endif

#define XH_TARGET_STOPPABLE 0x00000001L
#define XH_TARGET_REMOVABLE 0x00000002L
#define XH_TARGET_LOCKABLE  0x00000004L
#define XH_TARGET_EJECTABLE 0x00000008L
#define XH_TARGET_LOCKED    0x20000000L
#define XH_TARGET_STOPPED   0x40000000L
#define XH_TARGET_RESERVED  0x80000000L

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


/* Inquire protocol version number */
UWORD
XHGetVersion (void);

/* Inquire informations about one target */
LONG
XHInqTarget (UWORD major, UWORD minor, ULONG *block_size,
             ULONG *device_flags, char *product_name);

/* Reserve or release a target */
LONG
XHReserve (UWORD major, UWORD minor, UWORD do_reserve, UWORD key);

/* Lock or unlock a target with removable media */
LONG
XHLock (UWORD major, UWORD minor, UWORD do_lock, UWORD key);

/* Stop or start target */
LONG
XHStop (UWORD major, UWORD minor, UWORD do_stop, UWORD key);

/* Eject medium */
LONG
XHEject (UWORD major, UWORD minor, UWORD do_eject, UWORD key);

/* Get bit mask of available XHDI devices */
ULONG
XHDrvMap (void);

/* Get major device number (eg. target), minor device number (eg.
   LUN), starting sector and BPB */
LONG
XHInqDev (UWORD bios_device, UWORD *major, UWORD *minor,
          ULONG *start_sector, BPB *bpb);

/* Get informations about the driver */
LONG
XHInqDriver (UWORD bios_device, char *name, char *version,
             char *company, UWORD *ahdi_version,
             UWORD *maxIPL);

/* Install additional XHDI handler */
LONG
XHNewCookie (void *newcookie);

/* Do a physical access */
LONG
XHReadWrite (UWORD major, UWORD minor, UWORD rwflag,
             ULONG recno, UWORD count, void *buf);

/* Make printable device name */
void
XHMakeName (UWORD major, UWORD minor, ULONG start_sector, char *name);

/* New version of XHInqTarget */
LONG
XHInqTarget2 (UWORD major, UWORD minor, ULONG *block_size,
              ULONG *device_flags, char *product_name,
              UWORD stringlen);
              
/* New version of XHInqDev */
LONG
XHInqDev2 (UWORD bios_device, UWORD *major, UWORD *minor,
           ULONG *start_sector, BPB *bpb, ULONG *blocks, char *partid);

/* Special opcode for custom driver extensions */
LONG
XHDriverSpecial (ULONG key1, ULONG key2, UWORD subopcode, void *data);

/* Inquire drive capacity */
LONG
XHGetCapacity (UWORD major, UWORD minor, ULONG *blocks, ULONG *bs);

/* Inform driver about media change */
LONG
XHMediumChanged (UWORD major, UWORD minor);

/* Get/set MiNT kernel information */
LONG
XHMiNTInfo (UWORD opcode, void *data);

/* Get/set DOS limits */
LONG
XHDOSLimits (UWORD which, ULONG limit);

/* Get ms since last access */
LONG
XHLastAccess (UWORD major, UWORD minor, ULONG *ms);

/* Force reaccess of device */
LONG
XHReaccess (UWORD major, UWORD minor);

#endif
