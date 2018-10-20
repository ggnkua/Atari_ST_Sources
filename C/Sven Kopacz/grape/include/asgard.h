/*TAB=3***CHAR={ATARI}**********************************************************
*
*  Project name : ADEQUATE SYSTEMS GRAPHICS TABLET DRIVER INTERFACE
*  Header name  : ASGARD definition
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
*     May 05: Introduced
*     ...
*     Jul 05: First public release (version 0x0100)
*     Nov 07: Version 0x0110
*             New macros to test if particular cookie functions are available:
*              ASG_BUFAVAIL, ASG_PARAVAIL
*             All device-specific definitions have been moved to extra files
*              (WACOM.H and MOUSEBUF.H)
*             Coordinate sampling mechanism added:
*              new macros: ASG_SAMAVAIL, ASG_SM_...
*              new type: ASG_SAMPLE
*              new members in ASG_COOKIE: samplexy, setemul
*
*******************************************************************************/
/*KEY _NAME="ASGARD interface definition" */
/*END*/

#ifndef __ASGARD
#define __ASGARD

/*******************************************************************************
*                                                                              *
*                                   INCLUDES                                   *
*                                                                              *
*******************************************************************************/

#include <stddef.h>
/*KEY _END */


/*******************************************************************************
*                                                                              *
*                                    MACROS                                    *
*                                                                              *
*******************************************************************************/


#define ASG_COOKIE_ID   'asGT'      /* cookie jar ID */
                                    /* (a cookie with this ID points to an */
                                    /*  ASG_COOKIE structure) */


   /* test if ASG_COOKIE structure contains a known version number */
#define ASG_VERSION(cookie) ((cookie)->version >= 0x0100 && \
                             (cookie)->version <  0x0200)

   /* test if parameter functions are available */
#define ASG_PARAVAIL(cookie) ((cookie)->getpar != NULL)

   /* test if pointing device buffering functions are available */
#define ASG_BUFAVAIL(cookie) ((cookie)->setbuf != NULL)

   /* test if coordinate sampling functions are available */
#define ASG_SAMAVAIL(cookie) ((cookie)->version >= 0x0110 && \
                              (cookie)->samplexy != NULL)

   /* All macros above get a pointer to an ASG_COOKIE structure and
      return a flag which is either 0 (not supported/not available) or 1
      (supported/available).
   */


                                    /* status returned by setbuf() function: */
#define ASG_BS_DENIED   (-1)        /* access denied (another process already */
                                    /*  uses mouse buffering) */
#define ASG_BS_VIRTUAL  (-2)        /* virtual memory handler couldn't lock */
                                    /*  mouse packet buffer in physical RAM */


                                    /* flags returned by getpacket() function:*/
#define ASG_P_EMPTY  0x00000001UL   /* the mouse packet buffer is empty */
                                    /* (the returned packet is invalid) */
#define ASG_P_LOST   0x00000002UL   /* data loss because of full buffer */


                                    /* coordinate sampling status codes: */
#define ASG_SM_PENUP (-3)           /* pointing device is not on tablet */
#define ASG_SM_OFF   (-4)           /* driver has been turned off by user */


/*******************************************************************************
*                                                                              *
*                               TYPE DEFINITIONS                               *
*                                                                              *
*******************************************************************************/

typedef unsigned char uchar;        /* shortcuts */
typedef unsigned short ushort;
typedef unsigned long ulong;


   /*========== POINTING DEVICE STATUS BUFFERING ==========*/


typedef struct                      /* pointing device description packet: */
   {
   ushort   mx;                     /* x position */
   ushort   my;                     /* y position */
   uchar    but;                    /* button mask: */
                                    /* bit 0 = left button */
                                    /* bit 1 = right button */
   uchar    flags;                  /* shift key flags: */
                                    /* bit 0 = right Shift */
                                    /* bit 1 = left Shift */
                                    /* bit 2 = Control */
                                    /* bit 3 = Alternate */
                                    /* bit 4 = CapsLock */
   ushort   resvd;                  /* reserved */
   ulong    pressure;               /* current pressure intensity */
                                    /*  (0...ASG_COOKIE.maxpress) */
   ulong    timer;                  /* value of 200 Hz system clock when */
                                    /*  packet was created */
   } ASG_PACKET;


   /*========== COORDINATE SAMPLING ==========*/


typedef struct                      /* pointing device position descriptor: */
   {
   long     x;                      /* x position in 1/0x10000 mm */
   long     y;                      /* y position in 1/0x10000 mm */
   long     z;                      /* z position in 1/0x10000 mm */
                                    /* (distance between tablet and device) */
   uchar    but;                    /* button mask (emulated mouse buttons): */
                                    /* bit 0 = left button */
                                    /* bit 1 = right button */
   uchar    resvd1;                 /* reserved */
   ushort   resvd2;                 /* reserved */
   ulong    physbut;                /* physical button mask */
                                    /* (hardware-dependend!) */
   ulong    pressure;               /* current pressure intensity */
                                    /*  (0...ASG_COOKIE.maxpress) */
   } ASG_SAMPLE;


   /*========== COOKIE STRUCTURE ==========*/


typedef struct                      /* cookie-referenced tablet descriptor: */
   {

      /*----- global information -----*/
      /*      (test the structure format with the ASG_VERSION macro) */

   ushort   version;                /* version number (BCD) */
   volatile ulong pressure;         /* current pressure intensity */
                                    /* (0...maxpress) */
   ulong    maxpress;               /* maximum pressure intensity */
   char     *name;                  /* ^name of graphics tablet */
   ulong    drvid;                  /* driver ID (ASG_ID_..., defined in the */
                                    /*  extra files) */

      /*----- configuration functions -----*/
      /*      (test their availability with the ASG_PARAVAIL macro) */

   void cdecl (*getpar)(            /* get current parameter settings */
             void *buffer);         /*  ^buffer to write parameters to */
   void cdecl (*setpar)(            /* change parameter settings */
             void *buffer);         /*  ^new parameter settings */

      /*----- pointing device status buffering functions -----*/
      /*      (test their availability with the ASG_BUFAVAIL macro) */

   long cdecl (*setbuf)(            /* specify packet buffer */
             short vdi_handle,      /*  handle of virtual screen workstation */
             ASG_PACKET *buffer,    /*  ^start of buffer (NULL=none) */
             ulong size);           /*  size of buffer in bytes (> 0) */
                                    /*  function returns status (ASG_BS_...) */
   ulong cdecl (*getpacket)(        /* get pointing device description packet */
             ASG_PACKET *buffer);   /*  ^buffer for packet */
                                    /*  function returns ASG_P_... flags */

      /*----- coordinate sampling functions -----*/
      /*      (test their availability with the ASG_SAMAVAIL macro) */

   long cdecl (*samplexy)(          /* sample pointing device position */
             ASG_SAMPLE *buffer);   /*  ^buffer for sampled device state */
                                    /*  function returns status (ASG_SM_...) */
   void cdecl (*setemul)(           /* turn mouse emulation on/off */
               ulong flags);        /*  0=off, 1=on */

   } ASG_COOKIE;


/* The value of a cookie with the ID <ASG_COOKIE_ID> points to an ASG_COOKIE
   structure. The members are:

   ----- global information -----

   .version          should be checked with the ASG_VERSION macro

   .pressure         is updated by the driver in an interrupt function and
                     contains the current pressure intensity

   .maxpress         indicates the maximum value which can appear in <pressure>
                     NOTE: this value may vary during runtime when the current
                           setup is changed with the <setpar> function (because
                           of different emulations which may be supported by
                           the driver)

   .name             points to a 0-terminated string which holds the graphics
                     tablet's name

   .drvid            an ID specifying the format of the parameter block returned
                     by <getpar> respectively expected by <setpar>

   ----- configuration functions -----

   .getpar           points to a function which writes the current parameter
                     settings to the specified memory location

   .setpar           points to a function which can be used to change the
                     current parameter settings

   ----- pointing device status buffering functions -----

   .setbuf           points to a function which installs a ring buffer for
                     pointing device description packets

                     NOTE: setbuf() returns an error status (ASG_BS_DENIED) if
                           you tried to overwrite an existing buffer respec-
                           tively de-install a non-existing buffer. Use this
                           status also to detect if another process has already
                           used this mechanism.

   .getpacket        points to a function which can be used to get the next
                     packet from the ring buffer

   ----- coordinate sampling functions -----

   .samplexy         points to a function which returns a data block describing
                     the current absolute physical position of the pointing
                     device on the tablet. The function may return a negative
                     status code (ASG_SM_...) which determines that something
                     went wrong and the position couldn't be sampled.

   .setemul          points to a function which can disable/enable the mouse
                     emulation part of the driver (if disabled, then samplexy()
                     will still work, but the mouse pointer on the screen won't
                     be affected by the graphics tablet).


   More about the ASGARD functions:
   --------------------------------
   The function groups "configuration", "pointing device status buffering"
   and "coordinate sampling" don't have to be included neccessarily in
   every ASGARD driver. Use the macros ASG_xxxAVAIL to test if the
   particular function block is available.

   All functions may either be called in USER or SUPERVISOR mode. They don't
   modify any registers except for those functions which have a direct
   result (which is returned in register D0). Parameters are expected on
   the stack.

   Applications using the ASGARD functions should set the memory protection
   mode in the program header to GLOBAL to work properly under Multi TOS or
   other memory-protected operating systems (or do all calls in SUPERVISOR
   mode).
*/


#endif      /* #ifndef __ASGARD */

/*EOF*/
