/*
    @(#)XHDI/xhdi.h
    
    Julian F. Reschke, 2. April 1993
    
 	Bindings for the XHDI functions
	--- NOT FULLY TESTED, USE AT YOUR OWN RISK ---

    Important:
    
    Do calls only if XHGetVersion() was successful
*/

#ifndef __XHDI__
#define __XHDI__

#ifdef __GNUC__
#include <osbind.h>
#define BPB _BPB
#endif

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
#define XH_TARGET_RESERVED  0x80000000L


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

#endif
