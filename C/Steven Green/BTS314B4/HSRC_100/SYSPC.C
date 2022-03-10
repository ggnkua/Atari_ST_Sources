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

#include <time.h>
#include <stdio.h>
#include <stdarg.h>
#include <ctype.h>
#include <dir.h>
#include <dos.h>
#include <io.h>
#include <process.h>
#include <signal.h>
#include <alloc.h>
#include <sys\stat.h>
#include "hydracom.h"
#include "async.h"


struct _fos_info {
       word      strsize;       /* size of the structure in bytes     */
       byte      majver;        /* FOSSIL spec driver conforms to     */
       byte      minver;        /* rev level of this specific driver  */
       char far *ident;         /* FAR pointer to ASCII ID string     */
       word      ibufr;         /* size of the input buffer (bytes)   */
       word      ifree;         /* number of bytes left in buffer     */
       word      obufr;         /* size of the output buffer (bytes)  */
       word      ofree;         /* number of bytes left in the buffer */
       byte      swidth;        /* width of screen on this adapter    */
       byte      sheight;       /* height of screen    "      "       */
       byte      speed;         /* ACTUAL speed, computer to modem    */
};

struct _fos_speedtable {
        word speed;
        byte bits;
};


/* HJW 1/4/93
   NOTE:  The topspeed compiler generates for _DX = port the following
          assembler instructions:

          Mov AX,[port]
          Mov DX, AX

          Thus AX is overwritten. Any construct that loads a register
          using the _XX register indicators should be examined carefully.
          It is very likely that other compilers use the same strategy.
          Example:
          #define fossil_int(func)   { _AH = func; _DX = port; geninterrupt(0x14); }
          should be changed to:
*/
#define fossil_int(func)   { _DX = port; _AH = func; geninterrupt(0x14); }
#define dosext_int(func)   { _AH = func;             geninterrupt(0x15); }
#define dos_int(func)      { _AH = func;             geninterrupt(0x21); }
#define dossched_int()     {                         geninterrupt(0x28); }
#define FOS_SIGNATURE   0x1954
#define FOS_SETSPEED    0x00
#define FOS_PUTC        0x01
#define FOS_GETSTATUS   0x03
#define FOS_INIT        0x04
#define FOS_DEINIT      0x05
#define FOS_SETDTR      0x06
#define FOS_DUMP        0x09
#define FOS_PURGE       0x0a
#define FOS_SETFLOW     0x0f
#define FOS_MAXBUFLEN   1024

static boolean dv_active;
static boolean fossil;
static struct _fos_info fos_info;
static byte    fos_inbuf[FOS_MAXBUFLEN];
static word    fos_inwrite,
               fos_inread;
static struct _fos_speedtable fos_speedtable [] = {
        {   300U, 0x40 },
        {  1200U, 0x80 },
        {  2400U, 0xA0 },
        {  4800U, 0xC0 },
        {  9600U, 0xE0 },
        { 19200U, 0x00 },
        { 38400U, 0x20 },
        {     0U,    0 }
};


void dtr_out (byte flag)
{
        if (fossil) {
           _AL = flag;
           fossil_int(FOS_SETDTR);
        }
        else
           AsyncHand(flag ? (DTR | RTS) : RTS);
}


void com_flow (byte flags)
{
        if (fossil) {
           _AL = flags;
           fossil_int(FOS_SETFLOW);
        }
        else {
           AsyncCTS(flags & 0x02);
        }
}


void com_setspeed (word speed)                       /* set speed of comport */
{
        register byte i;

        if (!speed) return;

        if (fossil) {
           for (i = 0; fos_speedtable[i].speed; i++) {
               if (speed == fos_speedtable[i].speed) {
                  _AL = (fos_speedtable[i].bits | (parity ? 0x1a : 0x03));
                  fossil_int(FOS_SETSPEED);
                  break;
               }
           }
        }
        else
           AsyncSet(speed,(parity ? (BITS_7 | EVEN_PARITY) : BITS_8) | STOP_1);
}


static word fos_getstatus (void)
{
        fossil_int(FOS_GETSTATUS);
        return (_AX);
}


static int get_fos_info (void)
{
        struct SREGS sregs;
        union  REGS  regs;

        regs.x.ax = 0x1b00;
        regs.x.cx = sizeof (struct _fos_info);
        regs.x.dx = port;
        segread(&sregs);
        sregs.es  = FP_SEG(&fos_info);
        regs.x.di = FP_OFF(&fos_info);
        int86x(0x14,&regs,&regs,&sregs);

        return (regs.x.ax == sizeof (struct _fos_info));
}


static int fos_fillinbuf (void)
{
        struct SREGS sregs;
        union  REGS  regs;

        if (!(fos_getstatus() & 0x0100))
           return (0);

        regs.x.ax = 0x1800;
        regs.x.dx = port;
        regs.x.cx = FOS_MAXBUFLEN;
        segread(&sregs);
        sregs.es  = FP_SEG(fos_inbuf);
        regs.x.di = FP_OFF(fos_inbuf);
        int86x(0x14,&regs,&regs,&sregs);
        fos_inwrite = regs.x.ax;
        fos_inread = 0;

        return (fos_inwrite);
}


void com_putblock (byte *s, word len)
{
        if (fossil) {
           struct SREGS sregs;
           union  REGS  regs;

           while (len && carrier()) {
                 regs.x.ax = 0x1900;
                 regs.x.dx = port;
                 regs.x.cx = len;
                 segread(&sregs);
                 sregs.es  = FP_SEG(s);
                 regs.x.di = FP_OFF(s);
                 int86x(0x14,&regs,&regs,&sregs);
                 len -= regs.x.ax;
                 s += regs.x.ax;
           }
        }
        else {
           while (len-- > 0 && carrier()) com_putbyte(*s++);
        }
}


static int fos_init (void)
{
        fossil_int(FOS_INIT);
        return ((_AX != FOS_SIGNATURE || _BH < 5 || _BL < 0x1b) ? 0 : 1);
}


void sys_init(void)         /* all system dependent init should be done here */
{
        _CX = 0x4445;   /* DE */                /* DESQview presence check   */
        _DX = 0x5351;   /* SQ */
        _AL = 0x01;
        dos_int(0x2b);
        dv_active = (_AL != 0xff && _BX) ? true : false;

        fossil = true;
        if (!noinit && !fos_init()) {
           if (AsyncInit(port)) {
              cprint("%s internal com-routines can't find a comport %u\n",
                     PRGNAME, port + 1);
              endprog(2);
           }
           fossil = false;
        }
        else if (!get_fos_info() || fos_info.majver < 5) {
           if (!noinit) fossil_int(FOS_DEINIT);
           cprint("%s requires a revision 5 FOSSIL driver (funcs upto 1B)\n",PRGNAME);
           endprog(2);
        }

        if (fossil) {
           if (fos_info.obufr < 4096)
              message(6,"!FOSSIL transmit buffer size %u, should be >= 4096",fos_info.obufr);
           if (fos_info.ibufr < 4096)
              message(6,"!FOSSIL receive buffer size %u, should be >= 4096",fos_info.ibufr);
        }

        if (!noinit) com_flow(flowflags);
        fos_inread = fos_inwrite = 0;
}


void sys_reset(void)                            /* same as above for de-init */
{
        if (!noinit) com_flow(0);

        if (fossil) {
           if (!noinit) fossil_int(FOS_DEINIT);
        }
        else
           AsyncStop();
}


void sys_idle (void)
{
#if WIN_AGL
        win_idle();
#else
        if (dv_active) {
           _AL = 0;             /* int15 ax=1000 */
           dosext_int(0x10);    /* dv time slice */
        }
        else
           dossched_int();      /* DOS scheduler */
#endif
}/*sys_idle()*/


int com_outfull (void)          /* Return the amount in fossil output buffer */
{                               /* Ie. remaining no. bytes to be transmitted */
        if (fossil) {
           get_fos_info();
           return (fos_info.obufr - fos_info.ofree);
        }
        else
           return (AsyncOutStat());
}


int carrier(void)                                   /* Return carrier status */
{
        int i;

        if (nocarrier) return (1);

        if (fossil) {
           fossil_int(FOS_GETSTATUS);
/* HJW 4/1/93
   Here we have the same problem, machinecode generated for
           return (_AX & dcdmask);
   is
           Mov AX,[dcdmask]
           And AX,AX

   so it should be changed to:
*/
           i = _AX;
           return(i & dcdmask);
        }
        else {
           i = AsyncStat();
           return (((i >> 8) & dcdmask) | ((i << 8) & dcdmask));
        }
}  


void com_flush(void)              /* wait till all characters have been sent */
{
        if (fossil) {
           while (!(fos_getstatus() & 0x4000) && carrier());
        }
        else {
           while (AsyncOutStat() && carrier());
        }
}


void com_putbyte (byte c)
{
        if (fossil) {
           _AL = c;
           fossil_int(FOS_PUTC);
        }
        else
           AsyncOut(c);
}


void com_purge (void)
{
        if (fossil) {
           fossil_int(FOS_PURGE);
           fos_inread = fos_inwrite = 0;
        }
        else
           AsyncPurge();
}


void com_dump (void)
{
        if (fossil) {
           fossil_int(FOS_DUMP);
        }
        else
           AsyncDump();
}


int com_getbyte(void)
{
        if (fossil) {
           return (((fos_inread < fos_inwrite) || fos_fillinbuf()) ?
                   fos_inbuf[fos_inread++] : EOF);
        }
        else
           return (AsyncInStat() ? AsyncIn() : EOF);
}


void setstamp(char *name,long tim)                  /* Set time/date of file */
{
        int fd;
        struct tm *t;
        union REGS regs;

        if ((fd = dos_open(name,0)) < 0)
           return;

        if (tim == 0L)
           time(&tim);
        t = localtime((time_t *) &tim);

        regs.x.cx = (t->tm_hour << 11) |
                    (t->tm_min << 5) |
                    (t->tm_sec/2);
        regs.x.dx = ((t->tm_year-80) << 9) |
                    ((t->tm_mon+1) << 5) |
                    (t->tm_mday);
        regs.x.bx = fd;
        regs.x.ax = 0x5701;     /* DOS int 21 fn 57 sub 1 */
        intdos(&regs,&regs);    /* Set a file's date/time */

        close(fd);
}


long freespace(char *drivepath)    /* get free diskspace for specified drive */
{
        union REGS regs;

        if (drivepath[0] && drivepath[1] == ':' && isalpha(drivepath[0]))
           regs.h.dl = (toupper(drivepath[0]) - 64);
        else
           regs.h.dl = 0;
        regs.h.ah = 0x36;
        intdos(&regs,&regs);
        return ((long)regs.x.cx * (long)regs.x.ax * (long)regs.x.bx);
}


static char ff_dta[58];

char *ffirst(char *filespec)
{
        struct SREGS sregs;
        union  REGS  regs;

        regs.h.ah = 0x1a;
        segread(&sregs);
        sregs.ds  = FP_SEG(ff_dta);
        regs.x.dx = FP_OFF(ff_dta);
        intdosx(&regs,&regs,&sregs);

        regs.x.cx = 0;
        regs.h.ah = 0x4e;
        sregs.ds  = FP_SEG(filespec);
        regs.x.dx = FP_OFF(filespec);
        intdosx(&regs,&regs,&sregs);
        if (regs.x.cflag)
           return (NULL);
        return (ff_dta+0x1e);
}


char *fnext(void)
{
        struct SREGS sregs;
        union  REGS  regs;

        regs.h.ah = 0x1a;
        segread(&sregs);
        sregs.ds  = FP_SEG(ff_dta);
        regs.x.dx = FP_OFF(ff_dta);
        intdosx(&regs,&regs,&sregs);

        regs.h.ah = 0x4f;
        intdosx(&regs,&regs,&sregs);
        if (regs.x.cflag)
           return (NULL);
        return (ff_dta+0x1e);
}

/* end of syspc.c */
