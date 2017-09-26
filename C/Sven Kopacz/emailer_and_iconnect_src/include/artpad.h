/*TAB=3***CHAR={ATARI}**********************************************************
*
*  Project name : WACOM ARTPAD DRIVER
*  Header name  : ASGARD definitions
*  Symbol prefix: ASG
*
*  Author       : Harald Siegmund (HS)
*  Co-Authors   : -
*  Write access : HS
*
*  Notes        : Copyright (c) 1994-1995
*                 adequate systems
*                 Gesellschaft fÅr angemessene Systemlîsungen mbH
*
*                 Brauereistr. 2
*                 D-67549 Worms
*
*                 Tel. +49-6241-955065
*                 Fax  +49-6241-955066
*-------------------------------------------------------------------------------
*  Things to do : -
*
*-------------------------------------------------------------------------------
*  History:
*
*  1994:
*     Nov 07: introduced (as a copy of the file WACOM.H)
*
*******************************************************************************/
/*KEY _NAME="definitions for the Wacom Artpad driver" */
/*END*/

#ifndef __ASG_ARTPAD
#define __ASG_ARTPAD

/*******************************************************************************
*                                                                              *
*                                   INCLUDES                                   *
*                                                                              *
*******************************************************************************/

#ifndef __ASGARD
#  include "asgard.h"
#endif
/*KEY _END */


/*******************************************************************************
*                                                                              *
*                                    MACROS                                    *
*                                                                              *
*******************************************************************************/

#define ASG_ID_ARTPAD   'ARTP'      /* driver ID (ASG_COOKIE.drvid) */


/*******************************************************************************
*                                                                              *
*                               TYPE DEFINITIONS                               *
*                                                                              *
*******************************************************************************/

typedef struct                      /* WACOM Artpad parameter settings: */
   {                                /*  (*)=default */
   ushort   active;                 /* activity flag: */
                                    /*     0 = inactive (RS232 not touched) */
                                    /* (*) 1 = active */
   ushort   emul;                   /* tablet emulation: */
                                    /* (*) 0 = Wacom IV */
                                    /*     1 = Wacom II-S */
   ushort   device;                 /* output device (BIOS device number): */
                                    /* on machines with only one RS232 this */
                                    /*  value is 1 (AUX:) and not changeable */
                                    /* on machines with several RS232s the */
                                    /*  default is 6 (ST compatible AUX:) */
   ushort   cursorbut[8];           /* cursor button assignment table: */
                                    /*                   bit 0=right button */
                                    /*                   bit 1=left button */
                                    /* [0]: none            (*)=0 */
                                    /* [1]: upper button    (*)=2 */
                                    /* [2]: left button     (*)=2 */
                                    /* [3]: lower button    (*)=1 */
                                    /* [4]: right button    (*)=1 */
                                    /* [5]: combination     (*)=3 */
                                    /* [6]: combination     (*)=3 */
                                    /* [7]: unused          (*)=3 */
                                    /* high bytes: # of clicks to simulate */
   ushort   stylusbut[8];           /* stylus button assignment table: */
                                    /*                   bit 0=right button */
                                    /*                   bit 1=left button */
                                    /* [0]: none            (*)=0 */
                                    /* [1]: touches tablet  (*)=2 */
                                    /* [2]: stylus button   (*)=1 */
                                    /* [3]: touch+button    (*)=3 */
                                    /* [4]: must equal [3]  (*)=3 */
                                    /* [5]: must equal [3]  (*)=3 */
                                    /* [6]: must equal [3]  (*)=3 */
                                    /* [7]: unused          (*)=3 */
                                    /* high bytes: # of clicks to simulate */
   ushort   coord;                  /* coordinate handling flags: */
                                    /*  bit 0: absolute coordinates */
                                    /*  bit 1: mirror y axis */
                                    /*  bit 2: mirror x axis */
                                    /*  bit 3: swap x and y axis */
                                    /*  (*) for all flags = 0 */
                                    /*  See footnote #1 */
   long     abs_x;                  /* upper left position in 1/0x10000 mm */
   long     abs_y;                  /*  (for absolute coordinates), (*)=0,0 */
   ulong    rate;                   /* sampling rate in positions/second: */
                                    /*     0 = maximum speed */
                                    /*     50 p/s */
                                    /*     67 p/s */
                                    /* (*) 100 p/s */
   ulong    res;                    /* scan resolution: */
                                    /*     500 dpi */
                                    /*     508 dpi */
                                    /*     1000 dpi */
                                    /* (*) 1270 dpi */
                                    /*     2540 dpi (see footnote #2) */
   ulong    psens;                  /* pressure sensitivity: */
                                    /* (*) 0 = soft */
                                    /*     0xffffffffUL = hard */
   ulong    dist;                   /* reaction distance: */
                                    /* (*) 0x20000UL = max. 2 mm */
                                    /*     0x80000UL = 8 mm and more */
   ulong    inc;                    /* increment in coordinate units: */
                                    /*     (0...999), (*)=8 */
   ulong    resvd;                  /* reserved (0) */
   ulong    xmul;                   /* horizontal scaling factor (1...999) */
   ulong    xdiv;                   /*  x' = x * xmul / xdiv   (*)=1,6 */
   ulong    ymul;                   /* vertical scaling factor (1...999) */
   ulong    ydiv;                   /*  y' = y * ymul / ydiv   (*)=1,6 */
   } ASG_ARTPAD;


/* Footnote #1

   Coordinates received from the tablet are treated by the driver the
   following way:

   - get x and y coordinates from tablet
   - <coord> bit 0 set? (absolute mode)
     -> x = x - abs_x; y = y - abs_y
   - <coord> bit 1 set? (mirror y axis)
     -> x = -x
   - <coord> bit 2 set? (mirror x axis)
     -> y = -y
   - bit 3 set (swap x and y)
     -> swap coordinates (x <-> y)
   - scale coordinates due to xmul/xdiv and ymul/ydiv


   Footnote #2

   The 2540 dpi resolution is only available with the Wacom IV emulation.
*/


#endif      /* #ifndef __ASG_ARTPAD */

/*EOF*/
