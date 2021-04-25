/************************************************************************/
/* AR20NCLK.C                 by Bill Penner           28 November 1987 */
/************************************************************************/
/*      Time Load and Display Accessory for the ATARI ST Computer       */
/*                                                                      */
/*                              Bill Penner                             */
/*                              3235 Wright Avenue                      */
/*                              Bremerton, WA  98310                    */
/*----------------------------------------------------------------------*/
/* This program must be compiled using Megamax Version 1.1.  The program*/
/* may not work under version 2.0.  The interupt structure of this      */
/* program is designed to the Megamax 1.1 compiling structure.          */
/*----------------------------------------------------------------------*/
/* Update of version written in February 1987.  This version has been   */
/* rewritten for the benefit of cleaner code, and to add a couple of    */
/* options which were asked for by users.                               */
/*----------------------------------------------------------------------*/
/* This program is entered into the public domain and is NOT to be SOLD.*/
/* The program may be included on user group disks which are sold at a  */
/* small cost.                                                          */
/************************************************************************/

#include <stdio.h>
#include <osbind.h>
#include <obdefs.h>
#include <gemdefs.h>
#include "ar20pipe.h"

extern int gl_apid;

int     dpm[4][13] = { 0,31,29,31,30,31,30,31,31,30,31,30,31,
                       0,31,28,31,30,31,30,31,31,30,31,30,31 };

long    *_hz_200   = 0x4baL;  /* Location of system 200 Hz    */

long    save_ssp;             /* Hold the super user stack    */
long    clk200;               /* Temp register for 200 Hz     */
long    ntime;                /* Next update time             */
long    nxsec;                /* Counter value for next second*/

int     hour;                 /* Hold present hour            */
int     min;                  /* Hold present minute          */
int     sec;                  /* Hold present second          */
int     day;                  /* Hold present day             */
int     month;                /* Hold present month           */
int     year;                 /* Hold present year            */
int     msg[8];               /* Holds menu information       */
int     clock_en;             /* Flag for clock enabled       */
int     menu_id;              /* Keeps track of this process  */
int     fi_hand;              /* Handle for file operations   */
int     px,py,tpx,tpy;        /* Position of clock display    */
int     opflag,topflag;       /* Clock control flags          */
int     color, tcolor;        /* Clock color (t = orginal)    */
int     updat, tupdat;        /* Update rate # 0.005 secs     */
int     ret;                  /* Dummy variable               */
int	temp;                 /* Temporary general variable   */

char    inffile[] = "A:\AREAL20.INF";
char    date[12]  = "28-Nov-1987";
char    time[12]  = "XX:XX:XX PM";
char    *mname[]  = {"Jan","Feb","Mar","Apr","May","Jun",
                     "Jul","Aug","Sep","Oct","Nov","Dec"};

/************************************************************************/
/* Variables required for VBI routines                                  */
/************************************************************************/

extern  int  a4temp(),vbi_int(),vbimain();

int     *vblsem    = 0x452L;  /* Vertical blank semaphor      */
int     *nvbls     = 0x454L;  /* Number of vert blank slots   */
long    *v_bas_ad  = 0x44EL;  /* Screen Address               */
long    *_vblqueue = 0x456L;  /* Vertical Blank queue         */
long    *vbl;                 /* Value from vblqueue above    */

int     s_rez,s_bpl,s_ncr,s_rpc,s_pls;
int     colnum[16] = { 0,0xF,1,2,4,6,3,5,7,8,9,0xA,0xC,0xE,0xB,0xD };

char    *s_font;

/************************************************************************/
/*                             Main Routine                             */
/************************************************************************/

main()
  {
  int  event;

  appl_init();

  /* Gotta get some credit */
  Cconws("\033E\n\n       A-Real Time Clock\015\012");
  Cconws("         Version 2.01N\015\012");
  Cconws("    No Dallas Clock Module\015\012");
  Cconws("        by Bill Penner\015\012");

  menu_id = menu_register(gl_apid,"  A-Real Clock 2.0N");

  inffile[0] = 'A' + Dgetdrv();  /* Where am I booting from? */

  vbi_init();       /* Initialize the VBI routines */
  set_def();        /* Load a backup set of params */
  read_file();      /* Check and load the .INF file*/
  clean_val();      /* Go sanitize the values      */

  if(opflag & CKENAB)
    {
    if(clock_set()) clock_en = vbi_install();
    }
  else              clock_en = FALSE;

  while(TRUE)
    {
    event = evnt_multi(MU_MESAG | MU_TIMER,
                       1,1,1,  0,0,0,0,0,  0,0,0,0,0,
                       msg,  0xEE80,0x36,
                       &ret,&ret,&ret,&ret,&ret,&ret);

    if(event & MU_TIMER) clock_set(); /* One hour update vars */

    if(event & MU_MESAG)
      {
      if((msg[0] == AC_OPEN) && (msg[4] == menu_id))
        {
        if(! clock_en) clock_en = clock_start();
        else           clock_en = clock_stop();
        }
      else if(msg[4] == gl_apid)
        {
        switch(msg[0])
          {
          case RCLKEN:      /* Read clock flag */

            msg[3] = clock_en;
            reply_msg();
            break;

          case RPARAM:      /* Read Parameters >> Conf prog */
 
            msg[3] = topflag;
            msg[5] = ((tpx & 127) << 9) | (tpy & 511);
            msg[6] = tupdat;
            msg[7] = tcolor;
            reply_msg();
            break;

          case WPARAM:      /* Write Parameters from conf */

            set_vbl(FALSE);
            topflag = msg[3];
            tpx     = (msg[5] >> 9) & 127;
            tpy     = msg[5] & 511;
            tupdat  = msg[6];
            tcolor  = msg[7];
            clean_val();
            clock_set();
            set_vbl(TRUE);
            reply_msg();
            break;

          case RCFIG:       /* Read .INF file */

            msg[3] = read_file();
            msg[5] = VERSION;
            reply_msg();
            break;

          case WCFIG:       /* Write .INF file */

            msg[3] = write_file();
            reply_msg();
            break;

          case ENCLKD:      /* Enable clock */

            msg[5] = clock_en;
            if(!clock_en) clock_en = clock_start();
            msg[3] = clock_en;
            reply_msg();
            break;

          case DISCLKD:     /* Disable clock */

            msg[5] = clock_en;
            if(clock_en) clock_en = clock_stop();
            msg[3] = clock_en;
            reply_msg();
            break;

          case SETFDEF:     /* Set defaults */

            set_def();
            reply_msg();
            break;

          default:          /* Unknown message */

            break;          /* Oh well, who cares */
          }
        }
      }
    }
  }

/************************************************************************/
/* Routine to start the clock                                           */
/************************************************************************/

clock_start()
  {
  if(clock_set()) return(vbi_install());
  else
    {
    form_alert(1,"[0][Bad Clock Time ][No display]");
    return(FALSE);
    }
  }

/************************************************************************/
/* Routine to stop and clean up the clock                               */
/************************************************************************/

clock_stop()
  {
  vbi_remove();
  save_ssp = Super(0L);
  vbi_line(px,py,time,0);
  if(opflag & TWOLINE) vbi_line(px,py+1280,time,0);
  Super(save_ssp);
  return(FALSE);
  }

/************************************************************************/
/* Set up system defaults                                               */
/************************************************************************/

set_def()
  {
  topflag = 0;
  topflag |= TIMEFG;   /* Time shown in 12 hour fmt*/
  topflag |= TWELVE;

  tpx = 68;  tpy = 1;  /* Upper right of screen    */

  tcolor = 2;          /* Red under default colors */
  tupdat = 200;        /* Once a second            */
  }

/************************************************************************/
/* Set up scaled parameters                                             */
/************************************************************************/

clean_val()
  {
  int tflag;

  opflag = topflag;
  if((opflag & (TIMEFG | DATEFG)) == 0) opflag |= TIMEFG;
  if((opflag & (TWELVE | TIMEFG | DATEFG | TWOLINE)) == TIMEFG)
    {
    time[8] = 0;
    tflag = TRUE;
    }
  else
    {
    time[8] = ' ';
    tflag = FALSE;
    }
  color = tcolor;
  px    = tpx;
  switch(s_rez)
    {
    case 0:  /* Low Rez */

      if(color > 15) color = 1;           /* If color number hi set black */
      if ((! tflag) & (px > 29)) px = 29; /* Set right side limit */
      if ((tflag)   & (px > 32)) px = 32;
      if(tpy > 384) py = 192 * 160;       /* Set bottom limit */
      else          py = (tpy / 2) * 160;
      break;

    case 1:  /* Medium Rez */

      if(color > 3) color = 1;
      if ((! tflag) & (px > 69)) px = 69;
      if ((tflag)   & (px > 72)) px = 72;
      if(tpy > 384) py = 192 * 160;
      else          py = (tpy / 2) * 160;
      break;

    case 2:  /* Monochrome */

      if(color > 1) color = 1;
      if ((! tflag) & (px > 69)) px = 69;
      if ((tflag)   & (px > 72)) px = 72;
      if(tpy > 384) py = 384 * 80;
      else          py = tpy * 80;
      break;

    }
  updat = tupdat;
  }

/************************************************************************/
/* Set and start the clock display routine                              */
/************************************************************************/
     
int clock_set()
  {
  register  int   i,temp,timeint;

  save_ssp = Super(0L);

  ntime = *_hz_200 & 0x7FFFFFFFL;
  nxsec = ntime + 200L;

  Super(save_ssp);

  timeint = Tgettime();
  sec   =   (timeint <<  1) &  63;
  min   =   (timeint >>  5) &  63;
  hour  =   (timeint >> 11) &  31;
  timeint = Tgetdate();
  day   =    timeint        &  31;
  month =   (timeint >>  5) &  15;
  year  = (((timeint >>  9) & 127) + 80) % 100;

  if((month == 0) || (month > 12) || (day == 0)) return(FALSE);

  set_vbl(FALSE);

  temp = hour;
  if(opflag & TWELVE)
    {
    if(temp >= 12) time[9] = 'P';
    else           time[9] = 'A';
    time[10] = 'M';
    if      (temp > 12) temp -= 12;
    else if (temp == 0) temp  = 12;
    }
  else
    {
    time[ 9] = 0x20;
    time[10] = 0x20;
    }
  time[ 0] = temp / 10 + '0';
  time[ 1] = temp % 10 + '0';
  time[ 3] = min  / 10 + '0';
  time[ 4] = min  % 10 + '0';
  time[ 6] = sec  / 10 + '0';
  time[ 7] = sec  % 10 + '0';

  date[ 0] = day  / 10 + '0';
  date[ 1] = day  % 10 + '0';
  for(i=0;i<3;i++) date[i+3] = mname[month-1][i];
  date[ 9] = year / 10 + '0';
  date[10] = year % 10 + '0';

  set_vbl(TRUE);
  return(TRUE);
  }

/************************************************************************/
/* VBIMAIN Routine ... Executed during VBLANK Interupt                  */
/************************************************************************/

vbimain()
  {
  int i;

  clk200 = *_hz_200 & 0x7FFFFFFFL;

  if(clk200 >= nxsec)
    {
    nxsec += 200L;
    if(++sec > 59)                         /* Update Seconds */
      {
      sec = 0;
      if(++min > 59)                       /* Update Minutes */
        {
        min = 0;
        if(++hour >= 23)                   /* Update Hours   */
          {
          hour = 0;
          if(++day > dpm[(year | year >> 1) & 1][month]) /* Update Days */
            {
            day = 1;
            if(++month > 12)               /* Update Month   */
              {
              month = 1;
              year += 1;                   /* Update Year    */
              date[ 9] = year / 10 + '0';
              date[10] = year % 10 + '0';
              }
            for(i=0;i<3;i++) date[i+3] = mname[month][i];
            }
          date[0] = day  / 10 + '0';
          date[1] = day  % 10 + '0';
          }
        temp = hour;
        if(opflag & TWELVE)
          {
          if(temp >= 12) time[9] = 'P';
          else           time[9] = 'A';
          time[10] = 'M';
          if      (temp > 12) temp -= 12;
          else if (temp == 0) temp  = 12;
          }
        else
          {
          time[ 9] = 0x20;
          time[10] = 0x20;
          }
        time[0] = temp / 10 + '0';
        time[1] = temp % 10 + '0';
        }
      time[3] = min  / 10 + '0';
      time[4] = min  % 10 + '0';
      }
    time[6] = sec  / 10 + '0';
    time[7] = sec  % 10 + '0';
    }

  if(clk200 >= ntime)
    {
    ntime += (long)updat;
    if((opflag & TWOLINE) || ((opflag & DATEFG) && (sec & 1)) || (!(opflag & TIMEFG)))
      vbi_line(px,py,date,color);

    if(opflag & TWOLINE) vbi_line(px,py+1280,time,color);
    else if(!(opflag & DATEFG) || ((opflag & TIMEFG) && !(sec & 1)))
      vbi_line(px,py,time,color);
    }
  }

/************************************************************************/
/* Routine to write the INF file if it is available.                    */
/************************************************************************/

int write_file()
  {
  int version,fi_hand;

  fi_hand = Fcreate(inffile,0);
  if(fi_hand >= 0)
    {
    version = VERSION;
    Fwrite(fi_hand,2L,&version);
    Fwrite(fi_hand,2L,&topflag);
    Fwrite(fi_hand,2L,&tupdat);
    Fwrite(fi_hand,2L,&tcolor);
    Fwrite(fi_hand,2L,&tpx);
    Fwrite(fi_hand,2L,&tpy);
    Fclose(fi_hand);
    return(TRUE);
    }
  return(FALSE);
  }

/************************************************************************/
/* Routine to read the INF file if it is available.                     */
/************************************************************************/

int read_file()
  {
  int i,fi_hand,version;

  fi_hand = Fopen(inffile,0);  /* Check for config file   */
  if(fi_hand >= 0)
    {
    Fread(fi_hand,2L,&version);
    if(version == VERSION)
      {
      Fread(fi_hand,2L,&topflag);
      Fread(fi_hand,2L,&tupdat);
      Fread(fi_hand,2L,&tcolor);
      Fread(fi_hand,2L,&tpx);
      Fread(fi_hand,2L,&tpy);
      }
    Fclose(fi_hand);
    return(version);
    }
  return(FALSE);
  }

/************************************************************************/
/* Routine to reply to a pipe message                                   */
/************************************************************************/

reply_msg()
  {
  msg[4] = msg[1];
  msg[1] = gl_apid;
  appl_write(msg[4],16,msg);
  }

/************************************************************************/
/*                        New VBI Handler Routines                      */
/************************************************************************/

vbi_init()
  {
  long mono;
  int  i;

  s_rez = Getrez();
  s_pls = 2 - s_rez;
  switch(s_rez)
    {
    case 2:                  /* Monochrome   Monitor */

      mono  = 2 * 4L;
      s_bpl = 80;
      break;

    case 1:                  /* Medium Rez color Monitor */

      mono = 4L;
      s_bpl = 160;
      break;

    default:

      mono = 4L;
      s_bpl = 160;
      break;
    }
  asm
    {
               movem.l  D0-D7/A0-A6,-(A7)   /* Go use the stash */
               lea      a4temp,A0
               move.l   A4,(A0)
               move.l   A5,4(A0)
               dc.w     0xA000              /* Super INIT       */
               move.l   mono(A6),D1         /* Get the offset   */
               adda.l   D1,A1               /* Calc font addr   */
               move.l   (A1),A2             /* Get addr of font */

               lea      s_font(A4),A0       /* Get the storage  */
               move.l   76(A2),(A0)
               move.w   80(A2),s_ncr(A4)
               move.w   82(A2),s_rpc(A4)
               bra      exit

    exit:
               movem.l  (A7)+,D0-D7/A0-A6
    }
  }
/************************************************************************/
/* Set the vbl semaphor                                                 */
/************************************************************************/

set_vbl(a)
int a;
  {
  long save_ssp;

  save_ssp = Super(0L);
  *vblsem = a;
  Super(save_ssp);
  }

/************************************************************************/
/* Interupt handler...           Also the temporary inline variables    */
/************************************************************************/

asm
  { 
  a4temp:
               dc.l     0L
               dc.l     0L

  vbi_int:
               movem.l  D0-D7/A0-A6,-(A7)
               lea      a4temp,A0
               move.l   (A0),A4
               move.l   4(A0),A5
               jsr      vbimain
               movem.l  (A7)+,D0-D7/A0-A6
               rts

  }

/************************************************************************/
/*                       Install VBI Address                            */
/************************************************************************/

int vbi_install()
  {
  int i,vbi_int(),retflag,vbi_reset();

  if(Getrez() != s_rez) vbi_init();
  save_ssp = Super(0L);
  *vblsem = FALSE;
  vbl = (long *)*_vblqueue;
  for(i=0;((vbl[i] != NULL) && (i < *nvbls));i++);
  if(i < *nvbls)
    {
    vbl[i]  = (long)vbi_int;
    retflag = TRUE;
    }
  else retflag = FALSE;
  *vblsem = TRUE;
  Super(save_ssp);
  return(retflag);
  }

/************************************************************************/
/*                       Remove VBI Address                             */
/************************************************************************/

int vbi_remove()
  {
  int i,vbl_int(),retflag;

  save_ssp = Super(0L);
  *vblsem = FALSE;
  vbl = (long *)*_vblqueue;
  for(i=0;((vbl[i] != (long)vbi_int) && (i < *nvbls));i++);
  if(i < *nvbls)
    {
    vbl[i]  = NULL;
    retflag = TRUE;
   }
  else retflag = FALSE;
  *vblsem = TRUE;
  Super(save_ssp);
  return(retflag);
  }


/************************************************************************/
/* Routine to write out a line of text                                  */
/************************************************************************/

vbi_line(x,y,p,tcol)
int  x,y,tcol;
char *p;
  {
  int col;

  col = colnum[tcol];
  asm
    {
              movem.l  D0-D7/A0-A6,-(A7)
              move.l   0x44EL,A5
              move.l   s_font(A4),A3
              move.l   p(A6),A2
              move.w   x(A6),D7
              move.w   col(A6),D6
              move.w   s_pls(A4),D5
              move.w   s_ncr(A4),D4
              move.w   s_bpl(A4),D3
              move.w   s_rpc(A4),D2

    chr_loop: move.b   (A2),D0
              beq      exit
              andi     #0xFF,D0
              move.l   A3,A1
              adda     D0,A1        /* font address */

              move     D7,D0
              andi     #0xFE,D0
              asl      D5,D0
              move     D7,D1
              andi     #1,D1
              or       D1,D0
              add      y(A6),D0
              move.l   A5,A0
              adda     D0,A0        /* Screen Adr   */

              move     D2,D1        /* Load number of raster lines */
              subq     #1,D1

    rpc_loop: move     D6,D0        /* color number */

              lsr      #1,D0
              bcc      cbit0
              move.b   (A1),(A0)
              bra      bit1
    cbit0:    clr.b    (A0)
    bit1:     cmp      #0,D5        /* If pls = 0 then done */
              beq      bitx         /* High Resolution      */
              lsr      #1,D0
              bcc      cbit1
              move.b   (A1),2(A0)
              bra      bit2
    cbit1:    clr.b    2(A0)
    bit2:     cmp      #1,D5        /* If pls = 1 then done */
              beq      bitx         /* Medium Resolution    */
              lsr      #1,D0
              bcc      cbit2
              move.b   (A1),4(A0)
              bra      bit3
    cbit2:    clr.b    4(A0)
    bit3:     lsr      #1,D0
              bcc      cbit3
              move.b   (A1),6(A0)
              bra      bitx
    cbit3:    clr.b    6(A0)
    bitx:     adda     D4,A1
              adda     D3,A0
              dbf      D1,rpc_loop
              addq.l   #1,D7
              addq.l   #1,A2
              bra      chr_loop

    exit:     movem.l  (A7)+,D0-D7/A0-A6
    }
  }
            
