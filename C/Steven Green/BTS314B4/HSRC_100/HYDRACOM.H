/*=============================================================================

                              HydraCom Version 1.00

                         A sample implementation of the
                   HYDRA Bi-Directional File Transfer Protocol

                             HydraCom was written by
                   Arjen G. Lentz, LENTZ SOFTWARE-DEVELOPMENT
                  COPYRIGHT (C) 1991-1993; ALL RIGHTS RESERVED

                       The HYDRA protocol was designed by
                 Arjen G. Lentz, LENTZ SOFTWARE-DEVELOPMENT and
                             Joaquim H. Homrighausen
                  COPYRIGHT (C) 1991-1993; ALL RIGHTS RESERVED


  Revision history:
  06 Sep 1991 - (AGL) First tryout
  .. ... .... - Internal development
  11 Jan 1993 - HydraCom version 1.00, Hydra revision 001 (01 Dec 1992)


  For complete details of the Hydra and HydraCom licensing restrictions,
  please refer to the license agreements which are published in their entirety
  in HYDRACOM.C and LICENSE.DOC, and also contained in the documentation file
  HYDRACOM.DOC

  Use of this file is subject to the restrictions contained in the Hydra and
  HydraCom licensing agreements. If you do not find the text of this agreement
  in any of the aforementioned files, or if you do not have these files, you
  should immediately contact LENTZ SOFTWARE-DEVELOPMENT and/or Joaquim
  Homrighausen at one of the addresses listed below. In no event should you
  proceed to use this file without having accepted the terms of the Hydra and
  HydraCom licensing agreements, or such other agreement as you are able to
  reach with LENTZ SOFTWARE-DEVELOMENT and Joaquim Homrighausen.


  Hydra protocol design and HydraCom driver:         Hydra protocol design:
  Arjen G. Lentz                                     Joaquim H. Homrighausen
  LENTZ SOFTWARE-DEVELOPMENT                         389, route d'Arlon
  Langegracht 7B                                     L-8011 Strassen
  3811 BT  Amersfoort                                Luxembourg
  The Netherlands
  FidoNet 2:283/512, AINEX-BBS +31-33-633916         FidoNet 2:270/17
  arjen_lentz@f512.n283.z2.fidonet.org               joho@ae.lu

  Please feel free to contact us at any time to share your comments about our
  software and/or licensing policies.

=============================================================================*/

#ifndef WIN_AGL
#define WIN_AGL 0        /* set to 1 for AGL's MS-DOS/AtariST window package */
#endif

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <ctype.h>
#include <dos.h>
#include <time.h>
#include <sys\stat.h>
#include <process.h>
#include <signal.h>
#if WIN_AGL
#include "window.h"     /* AGL's window library */
#endif
#include <conio.h>      /* MS-DOS Turbo/Borland C(++) console stuff */
#include "2types.h"
#include "hydra.h"


#ifdef __MSDOS__
#define inteli(x) (x)
#define intell(x) (x)
#endif
#if !WIN_AGL
#define Esc   0x01b
#define Alt_B 0x130
#define Alt_C 0x12e
#define Alt_E 0x112
#define Alt_H 0x123
#define Alt_X 0x12D
#define PgUp  0x149
#define PgDn  0x151
#endif


#define PRGNAME "HydraCom"
#define LOGID   "HCom"
#define VERSION "1.00"
#ifdef __MSDOS__
#  define HC_OS  "PC"
#else /*!MSDOS*/
#  ifdef __OS2__
#    define HC_OS  "OS/2"
#  else /*!OS2*/
#    ifdef __TOS__
#      define HC_OS  "ST"
#    endif /*TOS*/
#  endif /*OS2*/
#endif /*MSDOS*/




#define PATHLEN 90
#define MAXARGS 50

#define DENY_ALL   0x0000
#define DENY_RDWR  0x0010
#define DENY_WRITE 0x0020
#define DENY_READ  0x0030
#define DENY_NONE  0x0040

#ifdef MAIN
#define global
#else
#define global extern
#endif

global  char     ourname[PATHLEN];
global  char     work[256],
                 buffer[256];
global  int      port;
global  word     cur_speed;
global  word     com_speed;
global  boolean  parity;
global  boolean  noinit;
global  boolean  nocarrier;
global  boolean  dropdtr;
global  int      flowflags;
global  int      dcdmask;
global  boolean  nobell;
global  boolean  mailer;
global  boolean  nooriginator;
global  boolean  hdxsession;
global  long     hydra_txwindow,
                 hydra_rxwindow;
global  char    **av;
global  int      loglevel;
global  FILE    *logfp;
global  char    *result;
global  char    *download;
global  char     single_file[20];
global  boolean  single_done;
global  boolean  noresume;
global  boolean  nostamp;
global  dword    hydra_options;
global  int      opustask;
global  char    *opuslog;
global  boolean  didsome;
#if WIN_AGL
global  WIN_IDX  file_win,
                 log_win,
                 remote_win,
                 local_win;
global  boolean  log_first;
#else
global  void    *term_scr;
global  int      term_x,   term_y,
                 file_x,   file_y,
                           log_y,
                 remote_x, remote_y,
                 local_x,  local_y;
#endif

#define CHAT_TIMEOUT 60
global  word     chatfill;
global  long     chattimer,
                 lasttimer;


#ifdef __PROTO__
# define        PROTO(s) s
#else
# define        PROTO(s) ()
#endif


/* hydracom.c */
void endprog     PROTO((int errcode ));
int  config      PROTO((int argc , char *argv []));
void init        PROTO((void ));
int  batch_hydra PROTO((char *filespec, char *alias ));
void hydracom    PROTO((void ));

/* fmisc.c */
void     unique_name PROTO((char *pathname ));
char    *xfer_init   PROTO((char *fname , long fsize , long ftime ));
boolean  xfer_bad    PROTO((void ));
char    *xfer_okay   PROTO((void ));
void    xfer_del     PROTO((void ));

/* misc.c */
int   keyabort     PROTO((void ));
void  rem_chat     PROTO((byte *data, word len ));
int   parse        PROTO((char *string ));
void  splitpath    PROTO((char *filepath , char *path , char *file ));
void  mergepath    PROTO((char *filepath , char *path , char *file ));
int   fexist       PROTO((char *filename ));
void  any_key      PROTO((void ));
int   get_key      PROTO((void ));
int   get_str      PROTO((char *prompt , char *s , int maxlen ));
void  resultlog    PROTO((boolean xmit , char *fname , long bytes , long xfertime ));
char *h_revdate    PROTO((long revstamp ));
void  message      PROTO((int level , char *fmt , ...));
void  cprint       PROTO((char *fmt , ...));
void  hydra_gotoxy PROTO((int x, int y ));
void  hydra_printf PROTO((char *fmt, ...));
void  hydra_clreol PROTO((void ));

/* dos_file.c */
void  dos_sharecheck PROTO((void ));
int   dos_open       PROTO((char *pathname , byte create ));
int   dos_sopen      PROTO((char *pathname , byte create ));
int   dos_sappend    PROTO((char *pathname , byte create ));
int   dos_close      PROTO((int handle ));
int   dos_lock       PROTO((int handle , long offset , long len ));
int   dos_unlock     PROTO((int handle , long offset , long len ));
long  dos_seek       PROTO((int handle , long offset , int fromwhere ));
long  dos_tell       PROTO((int handle ));
int   dos_read       PROTO((int handle , void *buf , word len ));
int   dos_write      PROTO((int handle , void *buf , word len ));
FILE *sfopen         PROTO((char *name, char *mode, int shareflag));

/* syspc.c */
void  dtr_out      PROTO((byte flag ));
void  com_flow     PROTO((byte flags ));
void  com_setspeed PROTO((word speed ));
void  com_putblock PROTO((byte *s , word len ));
void  sys_init     PROTO((void ));
void  sys_reset    PROTO((void ));
void  sys_idle     PROTO((void ));
int   com_outfull  PROTO((void ));
int   carrier      PROTO((void ));
void  com_flush    PROTO((void ));
void  com_putbyte  PROTO((byte c ));
void  com_purge    PROTO((void ));
void  com_dump     PROTO((void ));
int   com_getbyte  PROTO((void ));
void  setstamp     PROTO((char *name , long tim ));
long  freespace    PROTO((char *drivepath ));
char *ffirst       PROTO((char *filespec ));
char *fnext        PROTO((void ));

#undef PROTO

/* end of hydracom.h */
