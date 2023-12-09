/*
   File: SYSTEM.H        Atari ST system variables

   Oct 1988. V1.00 T.H. Schipper
*/
/*
Copyright (c) 1988 - 1991 by Ted Schipper.

Permission to use, copy, modify, and distribute this software and its
documentation for any purpose and without fee is hereby granted,
provided that the above copyright notice appear in all copies and that
both that copyright notice and this permission notice appear in
supporting documentation.

This software is provided AS IS with no warranties of any kind.  The author
shall have no liability with respect to the infringement of copyrights,
trade secrets or any patents by this file or any part thereof.  In no
event will the author be liable for any lost revenue or profits or
other special, indirect and consequential damages.
*/

#define RESET      (*(long *) 0x0004) /* pointer to reset handler */
#define EVT_CRITIC (*(long *) 0x0404) /* pointer to error handler */
#define PHYSTOP    (*(long *) 0x042E) /* top of memory */
#define FLOCK      (*(short *) 0x043E) /* Floppy lock variable */
#define BOOTDEV    (*(short *) 0x0446) /* logical boot device */
#define HDV_BPB    (*(long *) 0x0472) /* pointer to get_bpb */
#define HDV_RW     (*(long *) 0x0476) /* pointer to rwabs */
#define HDV_MEDI   (*(long *) 0x047E) /* pointer to hdv_medi */
#define COMLOAD    (*(short *)0x0482) /* Command.prg load flag */
#define HZ_200     (*(unsigned long *) 0x04BA) /* 200 Hz system clock */
#define DRVBITS    (*(long *) 0x04C2) /* block device bitvector */
#define DSKBUFP    (*(long *) 0x04C6) /* pointer to common disk buffer */
#define SYSBASE    (*(long *) 0x04F2) /* pointer to start OS */
#define EXEC_OS    (*(long *) 0x04FE) /* pointer to entry point OS */
#define PUN_PTR    (*(long *) 0x0516) /* pointer to physical units */


/* Pool Manager Directory Control Block entry */

struct DCB {
            short  size;          /* Control block size in paragraphs */
            struct DCB *next;     /* forward link */
            char   fill[60];      /* total length of 66 bytes */
           };


