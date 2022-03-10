/*--------------------------------------------------------------------------*/
/*                                                                          */
/*                                                                          */
/*      ------------         Bit-Bucket Software, Co.                       */
/*      \ 10001101 /         Writers and Distributors of                    */
/*       \ 011110 /          Freely Available<tm> Software.                 */
/*        \ 1011 /                                                          */
/*         ------                                                           */
/*                                                                          */
/*  (C) Copyright 1987-90, Bit Bucket Software Co., a Delaware Corporation. */
/*                                                                          */
/*                                                                          */
/*                This module was written by Vince Perriello                */
/*                     with code from several authors                       */
/*                                                                          */
/*                                                                          */
/*                Miscellaneous routines used by BinkleyTerm                */
/*                                                                          */
/*                                                                          */
/*    For complete  details  of the licensing restrictions, please refer    */
/*    to the License  agreement,  which  is published in its entirety in    */
/*    the MAKEFILE and BT.C, and also contained in the file LICENSE.240.    */
/*                                                                          */
/*    USE  OF THIS FILE IS SUBJECT TO THE  RESTRICTIONS CONTAINED IN THE    */
/*    BINKLEYTERM  LICENSING  AGREEMENT.  IF YOU DO NOT FIND THE TEXT OF    */
/*    THIS  AGREEMENT IN ANY OF THE  AFOREMENTIONED FILES,  OR IF YOU DO    */
/*    NOT HAVE THESE FILES,  YOU  SHOULD  IMMEDIATELY CONTACT BIT BUCKET    */
/*    SOFTWARE CO.  AT ONE OF THE  ADDRESSES  LISTED BELOW.  IN NO EVENT    */
/*    SHOULD YOU  PROCEED TO USE THIS FILE  WITHOUT HAVING  ACCEPTED THE    */
/*    TERMS  OF  THE  BINKLEYTERM  LICENSING  AGREEMENT,  OR  SUCH OTHER    */
/*    AGREEMENT AS YOU ARE ABLE TO REACH WITH BIT BUCKET SOFTWARE, CO.      */
/*                                                                          */
/*                                                                          */
/* You can contact Bit Bucket Software Co. at any one of the following      */
/* addresses:                                                               */
/*                                                                          */
/* Bit Bucket Software Co.        FidoNet  1:104/501, 1:132/491, 1:141/491  */
/* P.O. Box 460398                AlterNet 7:491/0                          */
/* Aurora, CO 80046               BBS-Net  86:2030/1                        */
/*                                Internet f491.n132.z1.fidonet.org         */
/*                                                                          */
/* Please feel free to contact us at any time to share your comments about  */
/* our software and/or licensing policies.                                  */
/*                                                                          */
/*--------------------------------------------------------------------------*/

/*
 * Note that for the ATARIST most of the screen functions are simplified
 * by using the ST's inbuilt VT52 escape codes, thereby eliminating
 * the need for the OS/2 video fossil.
 * - STeVeN
 */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <ctype.h>
#include <stdarg.h>
#include <string.h>

#ifdef __TOS__
#pragma warn -sus
#include <ext.h>
#else
#include <dos.h>
#include <fcntl.h>
#endif
#ifdef __TOS__
#include <conio.h>
#endif

#ifdef LATTICE
#include <errno.h>
#include <osbind.h>
#else
#include <process.h>
#include <io.h>
#endif

#ifdef OS_2
#define  INCL_DOSPROCESS
#endif

#ifdef __TURBOC__
#include "tc_utime.h"
#ifndef __TOS__
#include <mem.h>
#endif
#else
#ifndef LATTICE
#include <sys/utime.h>
#include <memory.h>
#endif
#endif

#include "bink.h"
#include "msgs.h"
#include "com.h"
#include "sbuf.h"
#include "vfossil.h"
#include "sched.h"
#include "defines.h"
#include "zmodem.h"

#ifdef OS_2
#ifdef Snoop
#include "snserver.h"
static HSNOOP hsnoop=(HSNOOP)NULL;
#endif /* Snoop */
#endif /* OS_2  */


static char newstring[200];
static int find_addr (char *, ADDR *, char *);


int dexists (filename)
char *filename;
{
   struct FILEINFO dta;

   return (!dfind (&dta, filename, 0));
}


#ifdef LATTICE
/* #include <dos.h> */
#else

int dfind (dta, name, times)
struct FILEINFO *dta;
char *name;
int times;
{
#if !defined(OS_2) && !defined(__TOS__)
   union REGS r;

   r.x.dx = (unsigned int) dta;
   r.h.ah = 0x1a;
   (void) intdos (&r, &r);
   r.x.bx = 0;
   r.x.cx = ~0x08;
   r.x.dx = (unsigned int) name;
   r.x.si = 0;
   r.x.di = 0;
   if (times == 0)
      {
      r.h.ah = 0x4e;
      (void) intdos (&r, &r);
      dta->nill = '\0';
      if (r.x.cflag != 0)
         {
         dta->name[0] = '\0';
         return (1);
         }
      return (0);
      }
   else
      {
      r.h.ah = 0x4f;
      (void) intdos (&r, &r);
      dta->nill = '\0';
      if (r.x.cflag != 0)
         {
         dta->name[0] = '\0';
         return (1);
         }
      return (0);
      }
#else
   int retval;

   if (times == 0)
   {
      retval = dir_findfirst(name, 0x37, dta);
/*    dta->nill = '\0'; */
      if (retval)
      {
/*       dta->name[0] = '\0'; */
         return (1);
      }
      else
         return (0);
   }
   else
   {
      retval = dir_findnext(dta);
/*    dta->nill = '\0'; */
      if (retval)
      {
/*       dta->name[0] = '\0'; */
         return (1);
      }
      else
         return (0);
   }
#endif
}

#endif /* ATARIST */

int set_baud (unsigned int baudrate, BOOLEAN log)
{
   register int i;

   if (baudrate > max_baud.rate_value)
      baudrate = max_baud.rate_value;

   for (i = 0; btypes[i].rate_value; i++)
   {
      if (btypes[i].rate_value == baudrate)
      {
         if (baud != i)                          /* same as what we have?     */
         {
			if(!batch_mode)
			{
            	if (log && !un_attended)
               	status_line (msgtxt[M_SETTING_BAUD], baudrate);
            	baud = i;                            /* need this for ALT-B       */
            	MDM_ENABLE (lock_baud && (btypes[baud].rate_value >= lock_baud) ? max_baud.rate_mask : btypes[baud].rate_mask);
            }
      	    cur_baud = baudrate;
         }


         if (un_attended && fullscreen)
         {
            sb_move (settingswin, SET_PORT_ROW, SET_COL);
            sprintf (junk, "%-5u Com%d", baudrate, port_ptr + 1);
            sb_puts (settingswin, (unsigned char *) junk);
            sb_show ();
         }
         return (1);
      }
   }
   return (0);
}

/*--------------------------------------------------------------------------*/
/* THROUGHPUT                                                               */
/* Print throughput message at end of transfer                              */
/*--------------------------------------------------------------------------*/
void throughput (int opt, size_t bytes)
{
   static time_t started = 0L;
   static time_t elapsed;
   static long cps;

#ifdef ATARIST
	if(ikbdclock)
		update_time();
#endif

   if (!opt)
      started = time (NULL);
   else if (started)
      {
      elapsed = time (NULL);
      /* The next line tests for day wrap without the date rolling over */
      if (elapsed < started)
         elapsed += 86400L;		/* 24*60*60 = 1 day */
      elapsed -= started;
      if (elapsed == 0L)
         elapsed = 1L;
      cps = (long) bytes / (unsigned long) elapsed;
      started = (cps * 1000L) / ((long) cur_baud);
      status_line ((char *) msgtxt[M_CPS_MESSAGE], cps, bytes, started);
      }
}                                                /* throughput */

int got_error (string1, string2)
char *string1, *string2;
{

#ifdef __TURBOC__
/*    Since TurboC doesn't handle errno correctly, zero it and ignore. */
	errno = 0;
   status_line ("%s, %s %s %s", msgtxt[M_ERROR], msgtxt[M_CANT], string1, string2);
#else
   if (errno == 0x18)
      errno = 0;
   if (errno != 0)
      {
      status_line ("%s %d, %s %s %s", msgtxt[M_ERROR], errno, msgtxt[M_CANT], string1, string2);
      errno = 0;
      return (1);
      }
#endif
   return (0);
}

void set_xy (string)
char *string;
{
   WRITE_ANSI ('\r');
   WRITE_ANSI ('\n');
   scr_printf (string);
   locate_x = wherex ();
   locate_y = wherey ();
}

void message (string)
char *string;
{
   if (string != NULL)
      {
      status_line (" %s", string);
      }
}

void time_release(void)
{
	update_log();

#if defined(ATARIST)

	/* What shall we do? */

#elif defined(OS_2)

   DosSleep (1L);

#else

   dos_break_off ();                            /* Turn off ^C trapping */

   if (have_dv)
      {
      dv_pause ();
      }
	else if (have_mos)
		{
		mos_pause ();
		}
   else if (have_ddos)
      {
      ddos_pause ();
      }
   else if (have_tv)
      {
      tv_pause ();
      }
   else if (have_ml)
      {
      ml_pause ();
      }
	else
		{
		/* The idea for this code came from Holger Schurig */
		msdos_pause ();
		}

#endif /* OS_2 */
}

char *strToAscii(char *s)
{
	if(s)
		return s;
	else
		return "<NULL>";
}

char *fancy_str (string)
char *string;
{
   register int flag = 0;
   char *s;

   s = string;

   while (*string)
      {
      if (isalpha (*string))                     /* If alphabetic,     */
         {
         if (flag)                               /* already saw one?   */
            *string = tolower (*string);         /* Yes, lowercase it  */
         else
            {
            flag = 1;                            /* first one, flag it */
            *string = toupper (*string);         /* Uppercase it       */
            }
         }
      else /* if not alphabetic  */ flag = 0;    /* reset alpha flag   */
      string++;
      }

   return (s);
}
void timer (interval)
int interval;
{
   long timeout;

   timeout = timerset ((long)interval * 10);
   while (!timeup (timeout))
      time_release ();
}

void big_pause (secs)
int secs;
{
   long timeout;

   timeout = timerset ((long)secs * 100);
   while (!timeup (timeout))
      {
      if (CHAR_AVAIL ())
         break;
      time_release ();
      }
}

int com_getc (t)
int t;
{
   long t1;

   if (!CHAR_AVAIL ())
      {
      t1 = timerset ((long)t * 100);
      while (!CHAR_AVAIL ())
         {
         if (timeup (t1))
            {
            return (EOF);
            }

         /*
          * This should work because we only do TIMED_READ when we have
          * carrier
          */
         if (!CARRIER)
            {
            return (EOF);
            }
         time_release ();
         }
      }
   return (int)(((unsigned int)MODEM_IN ()) & 0x00ff);
}

/* Z F R E E -- Return total number of free bytes on drive specified */
#if defined(OS_2)
long zfree (char *path)
{
   int drive;
   FSALLOCATE dt;

   if (!path || !*path)
      drive = 0;
   else
      drive = tolower (*path) - 'a' + 1;
   DosQFSInfo (drive, 1, (char far *) &dt, sizeof (FSALLOCATE));
   return ( dt.cSectorUnit * dt.cUnitAvail * dt.cbSector);
}

#elif defined(ATARIST)

long zfree(char *path)
{
#ifdef __TOS__
	DISKINFO info;
#else
	struct DISKINFO info;
#endif
	int drive;
	
	if(!path || !*path)
		drive = 0;
	else
		drive = tolower(*path) - 'a' + 1;
	if(Dfree((long *)&info, drive))
		return 0;
#ifdef __TOS__
	return (long) (info.b_free * info.b_secsiz * info.b_clsiz);
#else
	return (long) (info.free * info.bps * info.spc);
#endif
}

#else

/* Default PC version */

long zfree (drive)
char *drive;
{
   union REGS r;

   unsigned char driveno;
   long stat;

   if (drive[0] != '\0' && drive[1] == ':')
      {
      driveno = (unsigned char) (islower (*drive) ? toupper (*drive) : *drive);
      driveno = (unsigned char) (driveno - 'A' + 1);
      }
   else driveno = 0;                             /* Default drive    */

   r.x.ax = 0x3600;                              /* get free space   */
   r.h.dl = driveno;                             /* on this drive    */
   (void) int86 (0x21, &r, &r);                         /* go do it      */

   if (r.x.ax == 0xffff)                         /* error return??   */
      return (0);

   stat = (long) r.x.bx                          /* bx = clusters avail  */
      * (long) r.x.ax                            /* ax = sectors/clust   */
      * (long) r.x.cx;                           /* cx = bytes/sector    */

   return (stat);

}

#endif /* OS_2 */

void scr_printf (string)
char *string;
{

   if (string != NULL)
#ifdef OS_2
      VioWrtTTY (string, (USHORT) strlen (string), (HVIO) 0L);
#else
      while (*string != 0)
         WRITE_ANSI (*string++);
#endif
}

void send_can ()
{
   int i;

   CLEAR_OUTBOUND ();
   CLEAR_INBOUND ();

   for (i = 0; i < 10; i++)
      SENDBYTE (CAN);
   for (i = 0; i < 10; i++)
      SENDBYTE (BS);
}

void invent_pkt_name (string)
char string[];

{
   struct tm *tp;
   time_t ltime;

   (void) time (&ltime);
   tp = localtime (&ltime);
   (void) sprintf (string, "%02i%02i%02i%02i.pkt",
            tp->tm_mday, tp->tm_hour, tp->tm_min, tp->tm_sec);
}



int get_number (target)
char *target;
{
   ADDR gaddr;
   int k;

   (void) fgets (target, 100, stdin);
   k = (int) strlen (target);
   if (k == 1)
      return (0);
   target[--k] = '\0';                           /* no '\n' */
   if (!isdigit(target[0]) && (target[0] != '\"') && (target[0] != '.'))
      {
      fidouser (target, &gaddr);
      if ((gaddr.Net != -1) && (gaddr.Node != -1) && (gaddr.Zone != -1))
         {
         sprintf (target, "%s", Pretty_Addr_Str (&gaddr));
         }
      else return (0);                           /* Gotta have addr */
      }
   return (1);
}

void gong ()
{
   long t;
   int i;

   if (!gong_allowed)
      return;

   for (i = 0; i < 15; i++)
      {
      WRITE_ANSI ('\07');                        /* Bell code       */
      t = timerset (100);                        /* 1 second        */
      while (!timeup (t))
         {
         if (KEYPRESS ())                        /* If key pressed, */
            {
            (void) READKB ();                           /* Throw it away   */
            return;                              /* And get out     */
            }
         }
      }
}

char *skip_blanks (string)
char *string;
{
   while (*string && isspace (*string))
      ++string;
   return (string);
}

char *skip_to_blank (string)
char *string;
{
   while (*string && (!isspace (*string)))
      ++string;
   return (string);
}


/*
 * Compare 1st word of input with the parse_list list
 * Returns:
 *  -1 : Not found
 *  +ve: list element number
 *
 * Updated 10th July 1992: SWG :
 *	Distinguish between words beginning the same
 *  e.g. "Hold" and "HoldOnUs".
 *  The terminator is any character not in a..z,A..Z,0..9
 *
 */

int parse (char *input, struct parse_list list[])
{
	int i;

	size_t wordlen;
	char *s;

	/* Advance to White space */
	
	s = input;
	wordlen = 0;
	while(isalnum(*s) || (*s == '_'))
	{
		wordlen++;
		s++;
	}

	for(i = 0; list->p_length; i++, list++)
	{
		if( (list->p_length == wordlen) &&
			(strnicmp(input, list->p_string, wordlen) == 0) )
				return i+1;
	}

   	return -1;
}

void change_prompt ()
{
   char *s;

   if (newstring[0])
      {
      (void) putenv (newstring);
      return;
      }

   (void) strcpy (newstring, "PROMPT=[");
   (void) strcat (newstring, xfer_id);
#ifdef OVERLAYS
   (void) strcat (newstring, "-Overlay");
#endif
   (void) strcat (newstring, " Shell]$_");
   s = getenv ("PROMPT");
   if (s)
      {
      (void) strcat (newstring, s);
      }
   else
      {
      (void) strcat (newstring, "$P$G");
      }

   (void) putenv (newstring);
}

void update_files (t)
int t;
{
   char s[10];

   if (un_attended && fullscreen)
      {
      if (t)
         {
         ++hist.files_out;
         }
      else
         {
         ++hist.files_in;
         }

      sb_move (historywin, HIST_FILE_ROW, HIST_COL);
      (void) sprintf (s, "%d/%d", hist.files_in, hist.files_out);
      sb_puts (historywin, (unsigned char *) s);
      sb_show ();
      }
}

static char *last_str[] = {
                           "     None    ",
                           "     WaZOO   ",
                           "     FTS-0001",
                           "     BBS     ",
                           "     Ext Mail"
};

void last_type (n, taddr)
int n;
ADDR *taddr;
{
	int i;
   	char *p;
	char j[40];	/* Space for domain! "zzz:nnnnn/nnnnn.nnnnn @ dddddddd.ddd" */

   	if (fullscreen)
    	sb_move (historywin, HIST_LAST_ROW, HIST_COL2);

   	if ((n == 1) || (n == 2))
    {
      	if ((taddr->Zone != -1000) && (taddr->Net > 0))
        {
        	(void) sprintf (j, "%s", Pretty_Addr_Str (taddr));
        	j[13] = 0;
			if ((p = strchr (j, '@')) != NULL)
				*p = '\0';
         	for (i = (int) strlen (j); i < 13; i++)
            	j[i] = ' ';
         	j[i] = '\0';
         	hist.last_zone = taddr->Zone;
         	hist.last_net = taddr->Net;
         	hist.last_node = taddr->Node;
			hist.last_point = taddr->Point;
			memset(hist.last_Domain, 0, sizeof(hist.last_Domain));
			if(taddr->Domain)
				strcpy(hist.last_Domain, taddr->Domain);
        }
      	else
        {
        	(void) strcpy (j, "     FTS-0001");
        }
      	if (fullscreen)
      	{
        	sb_puts (historywin, (unsigned char *) j);
        	last_assumed = assumed;
        	top_line();
        }
 	}
  	else
    {
    	if ((n < 0) || (n > 4))
        	n = 0;

      	if (fullscreen)
        	sb_puts (historywin, (unsigned char *) last_str[n]);
  	}

   	hist.last_caller = n;
}



/*--------------------------------------------------------------------------*/
/* UNIQUE_NAME                                                              */
/* Increments the suffix of a filename as necessary to make the name unique */
/*--------------------------------------------------------------------------*/
void unique_name (fname)
char *fname;
{
   static char suffix[] = ".001";
   register char *p;
   register int n;

   if (dexists (fname))
      {                                          /* If file already exists...      */
      p = fname;
      while (*p && *p != '.')
         p++;                                    /* ...find the extension, if
                                                  * any  */
      for (n = 0; n < 4; n++)                    /* ...fill it out if
                                                  * neccessary   */
         if (!*p)
            {
            *p = suffix[n];
            *(++p) = '\0';
            }
         else p++;

      while (dexists (fname))                    /* ...If 'file.ext' exists
                                                  * suffix++ */
         {
         p = fname + strlen (fname) - 1;
         for (n = 3; n--;)
            {
            if (!isdigit (*p))
               *p = '0';
            if (++(*p) <= '9')
               break;
            else *p-- = '0';
            }                                    /* for */
         }                                       /* while */
      }                                          /* if exist */
}                                                /* unique_name */

int got_ESC ()
{
   while (KEYPRESS ())
      {
      screen_blank = 0;
      if (fullscreen && un_attended)
         sb_show ();
      if (READKB () == 27)     /* ESC pressed?        */
         {
         while (KEYPRESS ())
            (void) READKB ();
         return (1);
         }
      }
   return (0);
}


#if !defined(ATARIST)
/* These are in stvfosil.c on Atari ST */

void screen_clear ()
{

   register int r;
   unsigned int far *q;

   if (!vfossil_installed)
      scr_printf ("\033[H\033[2J");
   else
      {
      for (r = 0; r <= SB_ROWS; r++)
         {
         q = (unsigned int far *) blanks;
#if !defined(OS_2)
         (void) VioWrtCellStr (q, SB_COLS * 2, r, 0, 0);
#else
         (void) VioWrtCellStr ((PCH) q, (USHORT) (SB_COLS * 2), (USHORT) r, (USHORT) 0, (HVIO) 0L);
#endif
         }

      gotoxy (0, 0);
      }
}

void clear_eol ()
{
   int x, y;
   unsigned int far *q;
   if (!vfossil_installed)
      (void) printf ("\033[K");
   else
      {
      x = wherex();
      y = wherey();

      q = (unsigned int far *) blanks;
#ifndef OS_2
      (void) VioWrtCellStr (q, (SB_COLS - (unsigned) x) * 2, y, x, 0);
#else
      (void) VioWrtCellStr ((PCH) q, (USHORT) ((SB_COLS - x) * 2), (USHORT) y, (USHORT) x, (HVIO) 0L);
#endif
      }
}

#endif /* ATARIST */


void log_product (product, version, subversion)
int product;
int version;
int subversion;
{
   switch (product)
      {
      case isBITBRAIN :
      case isFIDO     :
      case isSPARK    :
      case isSEA      :
      case isSlick    :
      case isHENK     :
      case isTABBIE   :
      case isWOLF     :
      case isQMM      :
      case isFD       :
      case isGSPOINT  :
      case isBGMAIL   :
      case isCROSSBOW :
      case isDBRIDGE  :
      case isDAISY    :
      case isPOLAR    :
      case isTHEBOX   :
      case isWARLOCK  :
      case isTCOMM    :
      case isBANANNA  :
      case isAPPLE    :
      case isCHAMELEON:
      case isMAJIK    :
      case isDOMAIN   :
      case isLESROBOT :
      case isROSE     :
      case isPARAGON  :
      case isBINKST   :
      case isSTARNET  :
      case isQUICKBBS :
      case isPBBS     :
      case isTRAPDOOR :
      case isWELMAT   :
      case isTIMS     :
      case isISIS     :
         status_line ("%s %s %s %d.%02d", msgtxt[M_REMOTE_USES],
             prodcode[product], msgtxt[M_VERSION], version, subversion);
         break;

      case isOPUS:
         status_line ("%s Opus %s %d.%02d", msgtxt[M_REMOTE_USES],
                      msgtxt[M_VERSION], version,
                      (subversion == 48) ? 0 : subversion);
         break;

      default:
         status_line ("%s %s '%02x' %s %d.%02d", msgtxt[M_REMOTE_USES],
                      msgtxt[M_PROGRAM], product,
                      msgtxt[M_VERSION], version, subversion);
         break;
      }
return;
}

int next_minute ()
{
   int hours, mins, secs, ths;

   /* Get the DOS time */
   dostime (&hours, &mins, &secs, &ths);

   return ((60 - (secs % 60)) * 100 + 1);
}

void can_Janus (p)
char *p;
{
   J_TYPESP j;

   janus_OK = 0;
   for (j = j_top; j != NULL; j = j->next)
      {
      if (strnicmp (p, j->j_match, strlen (j->j_match)) == 0)
         {
         janus_OK = 1;
         break;
         }
      }
   janus_OK = janus_OK && !no_Janus_Session;
}

int check_failed (fname, theirname, info, ourname)
char *fname, *theirname, *info, *ourname;
{
   FILE *abortlog;
   char linebuf[64];
	char *p, *badname;
	int ret;

	ret = 0;
   if ((abortlog = fopen (fname, read_ascii)) == NULL)
      {
      (void) got_error (msgtxt[M_OPEN_MSG], fname);
      }
   else
      {
      while (!feof (abortlog))
         {
         linebuf[0] = '\0';
         if (!fgets ((p = linebuf), 64, abortlog))
            break;
         while (*p >= ' ')
            ++p;
         *p = '\0';
         p = strchr (linebuf, ' ');
         *p = '\0';
         if (!stricmp (linebuf, theirname))
            {
            p = strchr ((badname = ++p), ' ');
            *p = '\0';
            if (!stricmp (++p, info))
               {
               strcpy (ourname, badname);
					ret = 1;
               break;
               }
            }
         }
      fclose (abortlog);
      }

	return (ret);
}

void add_abort (fname, rname, cname, cpath, info)
char *fname, *rname, *cname, *cpath, *info;
{
	FILE *abortlog;
	char namebuf[100];

   strcpy (namebuf, cpath);
   strcat (namebuf, "BadWaZOO.001");
   unique_name (namebuf);
   rename (cname, namebuf);
   if ((abortlog = fopen (fname, append_ascii)) == NULL)
      {
      (void) got_error (msgtxt[M_OPEN_MSG], fname);
      unlink (namebuf);
      }
   else
      {
      fprintf (abortlog, "%s %s %s\n", rname, namebuf + strlen (cpath), info);
      fclose (abortlog);
      }
}

void remove_abort (fname, rname)
char *fname, *rname;
{
	FILE *abortlog, *newlog;
	char namebuf[100];
	char linebuf[100];
	char *p;
	int c;

	if (!dexists (fname))
		return;

   if ((abortlog = fopen (fname, read_ascii)) == NULL)
      {
      (void) got_error (msgtxt[M_OPEN_MSG], fname);
      }
   else
      {
      strcpy (namebuf, fname);
      strcpy (namebuf + strlen (namebuf) - 1, "TMP");
      c = 0;
      if ((newlog = fopen (namebuf, write_ascii)) == NULL)
         {
         (void) got_error (msgtxt[M_OPEN_MSG], namebuf);
         fclose (abortlog);
         }
      else
         {
         while (!feof (abortlog))
            {
            linebuf[0] = '\0';
            if (!fgets (linebuf, 64, abortlog))
               break;
            p = linebuf;
            while (*p > ' ')
               ++p;
            *p = '\0';
            if (stricmp (linebuf, rname))
               {
               *p = ' ';
               fputs (linebuf, newlog);
               ++c;
               }
            }
         fclose (abortlog);
         fclose (newlog);
         unlink (fname);
         if (c)
            rename (namebuf, fname);
         else unlink (namebuf);
         }
      }
}

/*
 * The next routine is used in the count down timer during file
 * transfers, and were provided by Jon Sabol, along with the other code that
 * calls these routines.
 */

void elapse_time ()
{
   time_t ltime;
   long eh;
   long em;
   long es;


#ifdef ATARIST
	if(ikbdclock)
		update_time();
#endif

   if (fullscreen && (un_attended || doing_poll))
      {
      time (&ltime);

      if (ltime < etm)
         ltime += 86400L;

      eh = (ltime - etm) / 3600L;
      em = ((ltime - etm) / 60L) - (eh * 60L);
      es = (ltime - etm) - (eh * 3600L) - (em * 60L);

      sb_move (settingswin, SET_TASK_ROW, SET_TIME_COL);
      sprintf (junk, "%s:  %02ld:%02ld:%02ld", msgtxt[M_ELAPSED], eh, em, es);
      sb_puts (settingswin, junk);
      sb_show ();
      }
}

/*
 * Parse a string for a fidonet address
 * d is space for a domain string.
 *
 * (A better method)
 */

static int find_addr (char *s, ADDR *addr, char *d)
{
    int ret = 0;
    register char *s1, *s2;

    d[0] = 0;               /* Null the domain */
	addr->Domain = NULL;

    /* Find Zone */

    s1 = strchr(s, ':');
    if(s1)
    {
        addr->Zone = atoi(s);
        s = s1+1;
        ret++;
    }
	else
		addr->Zone = 0;

    /* Find Net */

    s1 = strchr(s, '/');
    if(s1)
    {
        addr->Net = atoi(s);
        s = s1+1;
        ret++;
    }
    else
		addr->Net = 0;

    /* Find Node */

	if(isdigit(*s))
	{
	    addr->Node = atoi(s);
	    ret++;
	}
	else
		addr->Node = alias[0].ad.Node;

    /* Find point & domain */

    s1 = strchr(s, '.');   
    s2 = strchr(s, '@');
    if(s1 && !(s2 && (s1 > s2)))        /* check if it's a real point*/
    {
        s = s1+1;
        addr->Point = atoi(s);
        ret++;
    }
    else
        addr->Point = 0;
   
    if(s2)
    {
        s = skip_blanks(s2+1);		/* Polling causes "address @ domain" to be parsed! */
		while(*s && !isspace(*s))
			*d++ = *s++;
		*d = 0;
		ret++;
    }

    return ret;
}

/*
 * Read in an address with wildcards
 *
 * Similar to find_addr but accepts ALL as a field
 * returns number of fields (0=none)
 *
 * There must be a neater way to do this!
 *
 * Format is:
 *
 *  [[[z:]net/]node][.point][@domain[.ext]]
 *  ALL
 *  z:ALL
 *  z:net/ALL
 *  z:net/node.ALL 
 *
 * Any field may be ALL or if ALL is the end of the address all other fields
 * default to ALL.
 */

int read_wild_ad(char *node, ADKEY *dest)
{
    int ret = 0;
    register char *s1, *s2, *s;
	s = node;

	/* Check for ALL */
	
	if( (strcmp(s, "ALL") == 0) || (strcmp(s, "*") == 0))
	{
		dest->wild.zone = TRUE;		
		dest->wild.net = TRUE;		
		dest->wild.node = TRUE;		
		dest->wild.point = TRUE;		
		dest->wild.domain = TRUE;		
		return 1;
	}


    /* Find Zone */

    s1 = strchr(s, ':');
    if(s1)
    {
    	*s1 = 0;
    	if(strcmp(s, "ALL") && (*s != '*'))
	        dest->ad.Zone = atoi(s);
	    else
	    	dest->wild.zone = TRUE;
        s = s1+1;
        ret++;
    }
    else
		dest->ad.Zone = 0;
    

	if( (strcmp(s, "ALL") == 0) || (*s == '*'))
	{
		dest->wild.net = TRUE;		
		dest->wild.node = TRUE;		
		dest->wild.point = TRUE;		
		dest->wild.domain = TRUE;		
		return 1;
	}

    /* Find Net */

    s1 = strchr(s, '/');
    if(s1)
    {
    	*s1 = 0;
    	if(strcmp(s, "ALL") && (*s != '*'))
	        dest->ad.Net = atoi(s);
	    else
	    	dest->wild.net = TRUE;
        s = s1+1;
        ret++;
    }
    else
		dest->ad.Net = 0;

	if( (strcmp(s, "ALL") == 0) || (*s == '*'))
	{
		dest->wild.node = TRUE;		
		dest->wild.point = TRUE;		
		dest->wild.domain = TRUE;		
		return 1;
	}

    /* Find Node */

	if(strncmp(s, "ALL", 3) && (*s != '*'))
	{
		if(isdigit(*s))
		{
		    dest->ad.Node = atoi(s);
		    ret++;
		}
		else
			dest->ad.Node = alias[0].ad.Node;
    }
    else
    {
		dest->wild.node = TRUE;
		ret++;
    }

	if( (strcmp(s, "ALL") == 0) || (*s == '*'))
	{
		dest->wild.point = TRUE;		
		dest->wild.domain = TRUE;		
		return 1;
	}

    /* Find point & domain */

    s1 = strchr(s, '.');   
    s2 = strchr(s, '@');
    if(s1 && !(s2 && (s1 > s2)))        /* check if it's a real point*/
    {
        s = s1+1;
		if(strncmp(s, "ALL", 3) && (*s != '*'))
	        dest->ad.Point = atoi(s);
	    else
	    {
	    	dest->wild.point = TRUE;
	    	if(!s2)
	    		dest->wild.domain = TRUE;
	    }
        ret++;
    }
    else
        dest->ad.Point = 0;
   
    if(s2)
    {
        s = s2+1;

		if(strncmp(s, "ALL", 3) && (*s != '*'))
		{
			while(*s2 && !isspace(*s2))
				s2++;
			*s2 = 0;
			
			dest->ad.Domain = find_domain(s);
		}
		else
			dest->wild.domain = TRUE;
		ret++;
    }
    else
		dest->ad.Domain = NULL;

	/*
	 * Make intelligent guess at address zone and domain if missing
	 *
	 * e.g. 1004/0 should expand to 90:1004/0@nest
	 *       25@n ==> 90:1004/25@nest
	 *       25   ==>  2:25/25@fidonet
	 */
	
	if(!(dest->ad.Domain || dest->wild.domain) ||
	   !(dest->ad.Zone || dest->wild.zone) ||
	   !(dest->ad.Net || dest->wild.net) )
	{
		int count = num_addrs;
		ADDRESS *ad = alias;

		
		while(count--)
		{
			if( (!dest->ad.Zone || dest->wild.zone || (ad->ad.Zone == dest->ad.Zone)) &&
				(!dest->ad.Domain || dest->wild.domain || (ad->ad.Domain == dest->ad.Domain)) &&
				(dest->wild.domain ||dest->ad.Domain ||
				 dest->wild.zone || dest->ad.Zone ||
				 dest->wild.net || !dest->ad.Net || (ad->ad.Net == dest->ad.Net)) )
			{
				dest->ad.Zone = ad->ad.Zone;
				dest->ad.Domain = ad->ad.Domain;
				if(!dest->ad.Net)
					dest->ad.Net = ad->ad.Net;
				break;
			}
			ad++;
		}
		if(!dest->ad.Domain)
			dest->ad.Domain = alias[0].ad.Domain;
		if(!dest->ad.Zone)
			dest->ad.Zone = alias[0].ad.Zone;
		if(!dest->ad.Net)
			dest->ad.Net = alias[0].ad.Net;
#ifdef DEBUG
		status_line(">expanded %s to %s", node, Pretty_Addr_Str(&dest->ad));
#endif
	}

    return ret;
}

/*
 * Parse an address in text form and put it into the address structure
 */

int parse_address (char *node, ADDR *addr)
{
	int ret;
   	char d[100];

   	ret = find_addr (node, addr, d);

   	if (d[0] != '\0')
   	{
      	addr->Domain = add_domain (d);
   	}
	return (ret);
}


int find_address (node, addr)
char *node;
ADDR *addr;
{
   	int ret;
   	char d[100];
   	char *p;

   	d[0] = '\0';
   	p = skip_blanks (node);
   	if (!isdigit (*p) && (*p != '.'))
    {
    	fidouser (p, addr);
      	if ((addr->Net == -1) || (addr->Node == -1) || (addr->Zone == -1))
        {
        	ret = 0;
        }
      	else
        {
        	ret = 1;
        }
  	}
   	else
    {
    	ret = find_addr (p, addr, d);
    }

   	if (d[0] != '\0')
    {
    	addr->Domain = find_domain (d);
    }

	/*
	 * Make intelligent guess at address zone and domain if missing
	 *
	 * e.g. 1004/0 should expand to 90:1004/0@nest
	 *       25@n ==> 90:1004/25@nest
	 *       25   ==>  2:25/25@fidonet
	 */
	
	if(!addr->Domain || !addr->Zone || !addr->Net)
	{
		int count = num_addrs;
		ADDRESS *ad = alias;

		
		while(count--)
		{
			if( (!addr->Zone || (ad->ad.Zone == addr->Zone)) &&
				(!addr->Domain || (ad->ad.Domain == addr->Domain)) &&
				(addr->Domain || addr->Zone || !addr->Net || (ad->ad.Net == addr->Net)) )
			{
				addr->Zone = ad->ad.Zone;
				addr->Domain = ad->ad.Domain;
				if(!addr->Net)
					addr->Net = ad->ad.Net;
				break;
			}
			ad++;
		}
		if(!addr->Domain)
			addr->Domain = alias[0].ad.Domain;
		if(!addr->Zone)
			addr->Zone = alias[0].ad.Zone;
		if(!addr->Net)
			addr->Net = alias[0].ad.Net;
#ifdef DEBUG
		status_line(">expanded %s to %s", node, Pretty_Addr_Str(addr));
#endif
	}

   	return (ret);
}

/*
 * Add to the domain list
 */

char *add_domain (d)
char *d;
{
   char *p;
   int i;

	/* SWG: 10th July 1991 : Domains case insensitive and pretty */
	strlwr(d);

	p = find_domain(d);		/* If we already have this domain */
	if(p)
		return p;
	
	/* Otherwise make a new entry */

	for(i = 0; domain_name[i]; i++)
		;

	if(i >= (MAXDOMAIN-1))
		return NULL;
	
   domain_name[i] = strdup (d);
   return (domain_name[i]);
}

/*
 * Find domain in domain list
 */

char *find_domain (d)
char *d;
{
   char *p, *q, *s;
   char c;
   int i;
   size_t j,k;	

	/* SWG: 10th July 1991 : Domains case insensitive */
	strlwr(d);
   j = strlen (d);
   /* First see if we can find the whole domain name at the right */
   for (i = 0; (p = domain_name[i]) != NULL; i++)
      {
      k = strlen (p);
      if (k > j)
         continue;

      q = &(d[j - k]);
      if (strnicmp (q, p, k) == 0)
         {
         return (p);
         }
      }

   /* Ok, now see if we can find the abbreviated name at the right */
   for (i = 0; (p = domain_abbrev[i]) != NULL; i++)
      {
      k = strlen (p);
      if (k > j)
         continue;

      q = &(d[j - k]);
      if (strnicmp (q, p, k) == 0)
         {
         return (domain_name[i]);
         }
      }

   /* If there is a period in it, see if we can match the abbreviated name
      just before the period */
   if ((s = strrchr (d, '.')) != NULL)
      {
      c = *s;
      *s = '\0';
      j = strlen (d);
      for (i = 0; (p = domain_abbrev[i]) != NULL; i++)
         {
         k = strlen (p);
         if (k > j)
            continue;

         q = &(d[j - k]);
         if (strnicmp (q, p, k) == 0)
            {
            *s = c;
            return (domain_name[i]);
            }
         }
      *s = c;
      }

	/* Pick first domain that matches from left, e.g. @l make pick @lifenet */
   	for (i = 0; (p = domain_abbrev[i]) != NULL; i++)
	{
		s = d;
		q = p;
		
		do
			if(!*s)
				return domain_name[i];
		while(*s++ == *q++);
	}

   return (NULL);
}

/*
 * Find out if we should ignore this address or not as it belongs to an
 * unknown domain
 *
 * Returns:
 *   TRUE: Known
 *  FALSE: Unknown
 *
 * Ignore address if it belongs to a domain that we have never heard of
 * If we only have one domain set up then assume we are one of those
 * people who set up as ...@fidonet.org even for their aka's.
 */

BOOLEAN isKnownDomain(ADDR *ad)
{

	/* If we are both using Domains */
	
	if(ad->Domain && domain_name[0] && domain_name[1])
	{
		char **domain = domain_name;

		while(*domain)
		{
			if(*domain == ad->Domain)
				return TRUE;
			domain++;
		}
#ifdef DEBUG
		status_line("#Ignoring unknown Domain %s", ad->Domain);
#endif
		return FALSE;
	}
	else
		return TRUE;
}

/*
 * Find the assumed address for a given address
 */

static ADDRESS *get_assumed(ADDR *ad)
{
	int i;				/* Alias counter */
	int k;				/* How many fields have been matched */
	ADDRESS *a;			/* Current alias */
	ADDRESS *best;		/* Best alias */
	ADKEY *key;
	
	a = best = alias;
	i = k = 0;
	while(i < num_addrs)
	{
		if( (a->ad.Domain == ad->Domain) ||
			(!ad->Domain && (a->ad.Domain == alias[0].ad.Domain)) )
		{
			if(k == 0)
			{
				k++;
				best = a;
			}
			if(a->ad.Zone == ad->Zone)
			{
				if(k == 1)
				{
					k++;
					best = a;
				}
				if(a->ad.Net == ad->Net)
				{
					if(k == 2)
					{
						k++;
						best = a;
					}
					if(a->ad.Node == ad->Node)
					{
						best = a;
						break;
					}
				}
			}
		}
		a++;
		i++;
	}

	/* Now go through the KEYs in case one overides it */
	
	key = adkeys;
	while(key)
	{
		if( (key->wild.net || (key->ad.Net == ad->Net)) &&
			(key->wild.node || (key->ad.Node == ad->Node)) &&
			(key->wild.zone || (key->ad.Zone == ad->Zone)) &&
			(key->wild.domain || (key->ad.Domain == ad->Domain)) &&
			(key->wild.point || (key->ad.Point == ad->Point)) )
		{
			/* We have a match */
			
			if(key->alias)
			{
				best = key->alias;
				break;
			}
		}

		key = key->next;
	}
	return best;
}

/*
 * Set the current assumed variable to match a given address
 */
 
int make_assumed(ADDR *ad)
{
	ADDRESS *bestAlias = get_assumed(ad);
	ADDRESS *tmp;
		
	/* Convert alias to assumed */

	assumed = 0;
	if(bestAlias != NULL)
	{
		int j = 0;
		tmp = alias;
		while(j < num_addrs)
		{
			if(bestAlias == tmp)
			{
				assumed = j;
				break;
			}
			j++;
			tmp++;
		}
	}
	return assumed;
}

/*
 * Convert a 3D address into a real 4D address
 *
 * e.g. 2:fakenet/7 ===> 2:ourad/ournode.7
 */

void make4d(ADDR *destad)
{
	/* Convert 2D to 4D if in one of our fakenets */
			

	if(destad->Point == 0)
	{
		ADDRESS *ad = alias;
		int i = 0;
	
		while(i < num_addrs)
		{
			if( (destad->Zone == ad->ad.Zone) &&
				(destad->Domain == ad->ad.Domain) &&
				(destad->Net == ad->fakenet) )
			{
				destad->Point = destad->Node;
				destad->Node = ad->ad.Node;
				destad->Net = ad->ad.Net;
				return;
			}
			ad++;
			i++;
		}
	}
}


/*
 * Make up the 8 digit packet name for an address
 *
 * Updated 7th July 1991 SWG to use 4D addresses
 * Updated 23rd July 1991 SWG to stop it sending mail for our points
 *   to points from other networks!!!
 * Updated 28th Sept 1991 SWG: Use -1/point if its a point that isnt yours!
 *
 */

char addr_str[100];

char *Hex_Addr_Str (ADDR *a)
{
	if(a->Point)
	{
		ADDRESS *assume = get_assumed(a);
		if( (assume->ad.Zone   == a->Zone  )
		  &&(assume->ad.Net    == a->Net   )
		  &&(assume->ad.Node   == a->Node  )
		  &&(!assume->ad.Domain || !a->Domain || (assume->ad.Domain == a->Domain)) )
		{
			sprintf(addr_str, "%04x%04x", assume->fakenet, a->Point);
			return addr_str;
		}
		else
		{
			sprintf(addr_str, "%04x%04x", -1, a->Point);
			return addr_str;
		}
	}
   sprintf (addr_str, "%04x%04x", a->Net, a->Node);
   return (addr_str);
}

char *Pretty_Addr_Str (ADDR *a)
{
   char t1[10];
   char t2[30];
   char t3[10];
   char t4[50];

   if (a->Zone && !no_zones)
      sprintf (t1, "%hu:", a->Zone);
   else
      t1[0] = '\0';

   sprintf (t2, "%hu/%hu", a->Net, a->Node);

   if (a->Point)
      sprintf (t3, ".%hu", a->Point);
   else
      t3[0] = '\0';

   if (a->Domain != NULL)
	/* PRETTYDOMAIN  26.08.1990 */
	{
      sprintf (t4, " @ %s", a->Domain);
      fancy_str(t4);
	}
   else
      t4[0] = '\0';

   strcpy (addr_str, t1);
   strcat (addr_str, t2);
   strcat (addr_str, t3);
   strcat (addr_str, t4);
   return (addr_str);
}

char *Full_Addr_Str (a)
ADDR *a;
{
   char t1[10];
   char t2[30];
   char t3[10];
   char t4[50];

   if (a->Zone && !no_zones)
      sprintf (t1, "%hu:", a->Zone);
   else
      t1[0] = '\0';

   sprintf (t2, "%hu/%hu", a->Net, a->Node);

   if (a->Point)
      sprintf (t3, ".%hu", a->Point);
   else
      t3[0] = '\0';

   if (a->Domain != NULL)
      sprintf (t4, "@%s", a->Domain);
   else
      t4[0] = '\0';

   strcpy (addr_str, t1);
   strcat (addr_str, t2);
   strcat (addr_str, t3);
   strcat (addr_str, t4);
   return (addr_str);
}

/*
 * Convert the Hex 2D string into an address
 * (Domain and Zone are not changed) and are assumed to be predefined
 */

BOOLEAN get2daddress(char *name, ADDR *destad)
{
	if (sscanf (name, "%04x%04x.", &destad->Net, &destad->Node) != 2)
		return FALSE;

	/* Convert 2D to 4D if in one of our fakenets */
			
	destad->Point = 0;
	{
		ADDRESS *ad = alias;
		int i = 0;
	
		while(i < num_addrs)
		{
			if( (destad->Zone == ad->ad.Zone) &&
				(destad->Domain == ad->ad.Domain) &&
				(destad->Net == ad->fakenet) )
			{
				destad->Point = destad->Node;
				destad->Node = ad->ad.Node;
				destad->Net = ad->ad.Net;
				return TRUE;
			}
			ad++;
			i++;
		}
	}
	return TRUE;
}

#ifdef IOS
/*
 * IOS support... convert filename into net/node.point
 *
 * Code provided by Rinaldo Visscher 90:4000/103
 */

unsigned int ztoi(char *str, int len)
{
	unsigned int temp;
	
	temp = 0;
	while(*str && len-- && isalnum(*str))
	{
		temp *= 36;
		temp += isdigit(*str) ? *str-'0' : toupper(*str)-'A'+10;
		str++;
	}
	return temp;
}

void getaddress(char *str, unsigned int *net, unsigned int *node, unsigned int *point)
{
	*net = ztoi(str, 3);
	*node = ztoi(str+3, 3);
	*point = ztoi(str+6, 2);
}

void put36(char *s, unsigned int n, int len)
{
	s += len;	/* Get to end of string! */
	*s-- = 0;	/* Null terminate */
	while(len--)
	{
		int d = n % 36;				/* Remainder */
		n /= 36;
		if(d < 10)
			*s-- = d + '0';
		else
			*s-- = d - 10 + 'A';
	}
}

char *Addr36(ADDR *ad)
{
	put36(addr_str, ad->Net, 3);
	put36(addr_str+3, ad->Node, 3);
	put36(addr_str+6, ad->Point, 2);
	return addr_str;
}

/*
 * Make up the name for an ArcMail packet (names are SU? MO?..etc
 */

void make_dummy_arcmail(char *s, ADDR *from, ADDR *to)
{
	static char suffixes[7][3] = { "SU", "MO", "TU", "WE", "TH", "FR", "SA" };
    char *day;
	time_t thetime;
	struct tm *t;
	static int digit = 0;	
	
	time(&thetime);
	t = localtime(&thetime);
	day = suffixes[t->tm_wday];

	/* Make a dummy *.su0 name */

	if(to->Point || from->Point)
	{
		ADDRESS *assume1 = get_assumed(to);
		ADDRESS *assume2 = get_assumed(from);
		
		sprintf(s, "%04x%04x.%s%c",
			assume2->fakenet - assume1->fakenet,
			from->Point - to->Point,
			day, digit+'0');
	}
	else
	{
		sprintf(s, "%04x%04x.%s%c",
			from->Net - to->Net,
			from->Node - to->Node,
			day, digit+'0');
	}
#if 0
	if(++digit > 9)
		digit = 0;
#endif
}

#endif

unsigned int crc_block(unsigned char *ptr, size_t count)
{
	unsigned int crc;
	int i;

   	for (crc = 0, i = 0; i < count; i++, ptr++)
   	{	
    	crc = xcrc (crc, (byte) *ptr);
	}
	return (crc & 0xFFFF);
}

void Data_Check (xtmp, mode)
XMDATAP xtmp;
int mode;
{
	int i;
	unsigned char cs;
	unsigned char *cp;
	unsigned int cs1;

	/* If we are in checksum mode, just do it */
	if (mode == CHECKSUM)
		{
		cp = xtmp->data_bytes;
		cs = 0;
		for (i = 0; i < 128; i++)
			{
			cs += *cp++;
			}
		xtmp->data_check[0] = cs;
		}
	/* If we are in CRC mode, run the characters through the CRC calculator */
	else
		{
		cs1 = crc_block (xtmp->data_bytes, 128);
		xtmp->data_check[0] = (unsigned char) (cs1 >> 8);
		xtmp->data_check[1] = (unsigned char) (cs1 & 0xff);
		}
	}

static size_t buff_bytes = 0;

FILE *buff_fopen (fname, fmode)
char *fname;
char *fmode;
{
	buff_bytes = 0;
	return (fopen (fname, fmode));
}

size_t buff_fwrite(char *buff, size_t size1, size_t size2, FILE *fp)
{
	if ((buff_bytes + (size1 * size2)) > WAZOOMAX)
		{
		(void) fwrite (Secbuf, 1, buff_bytes, fp);
		buff_bytes = 0;
		}

	memcpy (Secbuf + buff_bytes, buff, size1 * size2);
	buff_bytes += size1 * size2;
	return (size1 * size2);
}

int buff_fclose (fp)
FILE *fp;
{
	(void) fwrite (Secbuf, 1, buff_bytes, fp);
	buff_bytes = 0;
	return (fclose (fp));
}

int buff_fseek (FILE *fp, long a, int b)
{
	(void) fwrite (Secbuf, 1, buff_bytes, fp);
	buff_bytes = 0;
	return (fseek (fp, a, b));
}

#ifdef OS_2
void set_prior (int pclass)
{
	char *s;
	static USHORT regular = 0;
	static USHORT janus = 0;
	static USHORT modem = 0;
	USHORT priority;

	switch (pclass)
		{
		case 2:
			if (regular)
			   priority = regular;
			else
			   {
			   s = getenv("REGULARPRIORITY");
			   if (s)
				  priority = regular = atoi(s);
			   else
				  priority = regular = 2;
			   }
		   break;

		case 3:
			if (janus)
			   priority = janus;
			else
			   {
			   s = getenv("JANUSPRIORITY");
			   if (s)
				  priority = janus = atoi(s);
			   else
				  priority = janus = 3;
			   }
		   break;

		case 4:
			if (modem)
			   priority = modem;
			else
			   {
			   s = getenv("MODEMPRIORITY");
			   if (s)
				  priority = modem = atoi(s);
			   else
				  priority = modem = 4;
			   }
			break;

		default:
			priority = 2;
			break;
		}

   (void) DosSetPrty ((USHORT) 1, priority, (SHORT) 31, (USHORT) 0);
}

#ifdef Snoop
#pragma check_stack(off)
static int far pascal _loadds mesgfunc(int error, char far *mesg)
{
	if(!error)
		status_line(":%Fs", mesg);
	else
		status_line("!SYS%04u : %Fs", error, mesg);
	return(0);
}
#pragma check_stack()

void snoop_open(char *pipename)
{
   static char *pipe = NULL;
   if(pipe)
	  free(pipe);
   if(pipename)
	  pipe = strdup(pipename);
   SnoopOpen(pipe, &hsnoop, xfer_id, (PFNSN)mesgfunc);
}

void snoop_close(void)
{
	if(hsnoop)
		SnoopClose(hsnoop);
	hsnoop = (HSNOOP)NULL;
}
#endif /* Snoop */
#else /* OS_2 */
void set_prior (int pclass)
{
   return;
   /* pclass = 5; */
}
#endif /* OS_2 */


/*
 * Implement file locking
 */

int flag_file (int function, ADDR *address, int do_stat)
{

	FILE *fptr;
	char *HoldName;
	static ADDR last_set[3];	/* Need two of them during EMSI Janus */
	static int counts[3];		/* How many times they are locked! */
	char flagname[128];
	char tmpname[128];
	int set;

	if (!TaskNumber)
		return (FALSE);

	HoldName = HoldAreaNameMunge (address);

	switch (function)
	{
	case INITIALIZE:
		last_set[0].Zone = -1;
		last_set[1].Zone = -1;
		last_set[2].Zone = -1;
		counts[0] = counts[1] = counts[2] = 0;
		break;

	case SET_SESSION_FLAG:
		/* At the start of a session, set up the task number */
		if (flag_dir)
		{
			sprintf (flagname, "%sTask.%d",
			flag_dir, TaskNumber);
			fptr = fopen (flagname, write_binary);
			fclose (fptr);
		}
		return (FALSE);

	case CLEAR_SESSION_FLAG:
		/* At the end of a session, delete the task file */
		if (flag_dir)
		{
			sprintf (flagname, "%sTask.%d",
			flag_dir, TaskNumber);
			unlink (flagname);
		}
		return (FALSE);

	case TEST_AND_SET:

	/*
	 * First see if we already HAVE this lock! If so, return now.
	 *
	 */

		if (memcmp (&last_set[0], address, sizeof (ADDR)) == 0)
		{
			counts[0]++;
#ifdef DEBUG
			status_line(">Incremented flagfile for %s", Pretty_Addr_Str(address));
			status_line(">flag0=%s[%d]", Pretty_Addr_Str(&last_set[0]), counts[0]);
			status_line(">flag1=%s[%d]", Pretty_Addr_Str(&last_set[1]), counts[1]);
			status_line(">flag2=%s[%d]", Pretty_Addr_Str(&last_set[2]), counts[2]);
#endif
			return (FALSE);
		}
		if (memcmp (&last_set[1], address, sizeof (ADDR)) == 0)
		{
			counts[1]++;
#ifdef DEBUG
			status_line(">Incremented flagfile for %s", Pretty_Addr_Str(address));
			status_line(">flag0=%s[%d]", Pretty_Addr_Str(&last_set[0]), counts[0]);
			status_line(">flag1=%s[%d]", Pretty_Addr_Str(&last_set[1]), counts[1]);
			status_line(">flag2=%s[%d]", Pretty_Addr_Str(&last_set[2]), counts[2]);
#endif
			return (FALSE);
		}
		if (memcmp (&last_set[2], address, sizeof (ADDR)) == 0)
		{
			counts[2]++;
#ifdef DEBUG
			status_line(">Incremented flagfile for %s", Pretty_Addr_Str(address));
			status_line(">flag0=%s[%d]", Pretty_Addr_Str(&last_set[0]), counts[0]);
			status_line(">flag1=%s[%d]", Pretty_Addr_Str(&last_set[1]), counts[1]);
			status_line(">flag2=%s[%d]", Pretty_Addr_Str(&last_set[2]), counts[2]);
#endif
			return (FALSE);
		}

	/*
	 * Check for the INMAIL.$$$ file.
	 *
	 */

		if (flag_dir != NULL)
		{
			sprintf (tmpname, "%sINMAIL.$$$",flag_dir);

			if ((fptr = fopen (tmpname, read_binary)) != NULL)
			{
				fclose (fptr);
				if (!CARRIER)
					if (do_stat)
						status_line (msgtxt[M_OTHERPROC]);
				return (TRUE);
			}
		}

	/*
	 * Next create a file using a temporary name.
	 *
	 */

		sprintf (tmpname, "%sBINK%04x.BSY",HoldName,TaskNumber);
		fptr = fopen (tmpname, write_binary);
		if (fptr == NULL)
		{
			if (do_stat)
				status_line (msgtxt[M_FAILED_CREATE_FLAG],tmpname);
			return (TRUE);
		}
		fclose (fptr);

	/*
	 * Now the test&set. Attempt to rename the file.
	 * If we succeed, we have the lock. If we do not,
	 * delete the temp file.
	 *
	 */

#ifdef IOS
		if(iosmode)
			sprintf (flagname, "%s%s.BSY", HoldName, Addr36(address));
		else
#endif
			sprintf (flagname, "%s%s.BSY", HoldName, Hex_Addr_Str(address));

		if (!rename (tmpname, flagname))
		{
			if (do_stat)
				status_line (msgtxt[M_CREATED_FLAGFILE],flagname);
			if(last_set[0].Zone == -1)
			{
				memcpy (&last_set[0], address, sizeof (ADDR));
				counts[0] = 1;
			}
			else if(last_set[1].Zone == -1)
			{
				memcpy (&last_set[1], address, sizeof (ADDR));
				counts[1] = 1;
			}
			else
			{
				memcpy (&last_set[2], address, sizeof (ADDR));
				counts[2] = 1;
			}
#ifdef DEBUG
			status_line(">flag0=%s[%d]", Pretty_Addr_Str(&last_set[0]), counts[0]);
			status_line(">flag1=%s[%d]", Pretty_Addr_Str(&last_set[1]), counts[1]);
			status_line(">flag2=%s[%d]", Pretty_Addr_Str(&last_set[2]), counts[2]);
#endif
			return (FALSE);
		}
		if (do_stat)
			status_line (msgtxt[M_THIS_ADDRESS_LOCKED], Pretty_Addr_Str (address));
		unlink (tmpname);
		return (TRUE);

	case CLEAR_FLAG:

	/*
	 * Make sure we need to clear something.
	 * Zone should be something other than -1 if that's the case.
	 *
	 */
		if ( (last_set[0].Zone == -1) && (last_set[1].Zone == -1) && (last_set[2].Zone == -1))
			return (TRUE);

		/*
		 * Next compare what we want to clear with what we think we have.
		 *
		 */

		if (memcmp (&last_set[0], address, sizeof (ADDR)) == 0)
			set = 0;
		else if (memcmp (&last_set[1], address, sizeof (ADDR)) == 0)
			set = 1;
		else if (memcmp (&last_set[2], address, sizeof (ADDR)) == 0)
			set = 2;
		else
		{
			if (do_stat)
				status_line (msgtxt[M_BAD_CLEAR_FLAGFILE],
				Pretty_Addr_Str (address));
			return (TRUE);
		}

		/*
		 * Decrement counter and clear the file if zero
		 */

		if(--counts[set])
		{
#ifdef DEBUG
			status_line(">Decremented flagfile for %s", Pretty_Addr_Str(address));
			status_line(">flag0=%s[%d]", Pretty_Addr_Str(&last_set[0]), counts[0]);
			status_line(">flag1=%s[%d]", Pretty_Addr_Str(&last_set[1]), counts[1]);
			status_line(">flag2=%s[%d]", Pretty_Addr_Str(&last_set[2]), counts[2]);
#endif
			return TRUE;
		}

		/*
		 * We match. Unlink the flag file. If we're successful, jam a -1
		 * into our saved Zone.
		 *
		 */

#ifdef IOS
		if(iosmode)
			sprintf (flagname, "%s%s.BSY", HoldName, Addr36(address));
		else
#endif
			sprintf (flagname, "%s%s.BSY", HoldName, Hex_Addr_Str(address));
		if (!unlink (flagname))
		{
			if (do_stat)
				status_line (msgtxt[M_CLEARED_FLAGFILE], flagname);
			last_set[set].Zone = -1;
#ifdef DEBUG
			status_line(">flag0=%s[%d]", Pretty_Addr_Str(&last_set[0]), counts[0]);
			status_line(">flag1=%s[%d]", Pretty_Addr_Str(&last_set[1]), counts[1]);
			status_line(">flag2=%s[%d]", Pretty_Addr_Str(&last_set[2]), counts[2]);
#endif
			return (TRUE);
		}

		if (do_stat)
			status_line (msgtxt[M_FAILED_CLEAR_FLAG],flagname);
		return (FALSE);

	default:
		break;
	}

	return (TRUE);
}

#ifdef GENERIC

/*
 * Portability functions
 */

/* Both these functions actually do the same! */

/*
 * Converts from generic word to MSDOS word
 */

word PUTWORD(register word val)
{
	MWORD temp;
	
	temp.lohi.lo = val & 0xff;
	temp.lohi.hi = (val >> 8) & 0xff;

	return temp.w;
}

/*
 * This returns a normal word from an MSDOS format word
 */

word GETWORD(register word val)
{
	MWORD temp;
	temp.w = val;

	return ((word)(temp.lohi.lo + (temp.lohi.hi << 8)));
}

#endif

/* GENERALEXEC  24.09.1989 */

void exec_shell (int j)
{
    status_line (msgtxt[M_EXECSHELL], j);
    mdm_init (modem_busy);
    exit_DTR ();
    close_up ();
    vfossil_cursor (1);
    b_spawn (shells[j-1]);
    come_back ();
    set_up_outbound ();
    DTR_ON ();
    mdm_init (modem_init);
    status_line (msgtxt[M_RETSHELL]);
}

/* STR_LIST manipulation */

/*
 * Add the white space seperated text (s) to the end of STR_LIST
 */

void add_to_strlist(STR_LIST **list, char *s)
{
	char *p;
	STR_LIST *l;
	STR_LIST *lst;
	
	/* Get to end of list ready to add new data */
	
	lst = (STR_LIST *)list;
	if(lst->next)
		while(lst->next)
			lst = lst->next;

	p = strtok(s, seperators);
	while(p)
	{
		l = calloc(sizeof(STR_LIST), 1);
		if(l)
		{
			l->str = strdup(p);

			if(l->str)
			{
				l->next = NULL;
				lst->next = l;
				lst = l;
			}
			else
				free(l);
		}
		p =strtok(NULL, seperators);
	}
}

/*
 * match a string with a a sequence of a wildcard string
 * ? = any one character
 * * = remainder of field matches
 *
 * TRUE: Matches
 * FALSE: no match
 */

static BOOLEAN match_wild(char *text, char *pattern)
{

	while(*text)
	{
		char c = *pattern++;
		char c1 = *text++;
		
		if(c == '*')
			return TRUE;
		if( (c != '?') && (c != c1))
			return FALSE;
	}
	if(*pattern && (isdigit(*pattern) || (*pattern == '*') || (*pattern == '?')))
		return FALSE;

	return TRUE;
}

/*
 * Find entry for address in a string list
 *
 * The 1st character if not a digit (or wildcard) is assumed to be a special
 * character, e.g. '-' to disable a node.
 *
 * Returns the str field or NULL if not found
 */
 
char *find_strlist(STR_LIST *list, ADDR *ad, char **spec_field)
{
	char zone[6];
	char net[6];
	char node[6];
	char point[6];
	static char extra[40];		/* special field in listentry	*/
	
	/* Convert Address fields to ascii */

	sprintf(zone, "%d", ad->Zone);
	sprintf(net, "%d", ad->Net);
	sprintf(node, "%d", ad->Node);
	sprintf(point, "%d", ad->Point);

	for(; list; list = list->next)
	{
		char *s = list->str, *tmp;
		char *s1, *s2;
		
		/*
		** if spec_field is not null, extract first entry from s
		** (separeted by ! from the rest) and copy it to extra
		*/
		
		tmp = s;		
		if (spec_field != NULL)
		{
			memset (extra, 0, sizeof (extra));
			if (*spec_field = strchr (s, '!'))
			{
				strncpy (extra, s, *spec_field - s);
				s = *spec_field + 1;
				tmp = s;
				*spec_field = extra;
			}
			else
			{
				*spec_field = NULL;
			}
		}
		
		/* 1st check the zone */

		if(*s && !isdigit(*s) && (*s != '*') && (*s != '?'))	/* Skip initial character */
			s++;

		s1 = strchr(s, ':');	/* Look for zone end */
		if(s1)
		{
			if(!match_wild(zone, s))
				continue;
			s = s1 + 1;
		}
		s1 = strchr(s, '/');	/* net marker */
		if(s1)
		{
			if(!match_wild(net, s))
				continue;
			s = s1 + 1;
		}
		s1 = strchr(s, '.');	/* Point */
		s2 = strchr(s, '@');	/* Domain */

		if(s1 && s2 && (s2 < s1))	/* Ignore point if part of domain */
			s1 = NULL;

		if(*s && !match_wild(node, s))
			continue;

		if(s1)
		{
			s1++;
			if(!match_wild(point, s1))
				continue;
		}
		if(s2 && ad->Domain)
		{
			s2++;
			if(!match_wild(ad->Domain, s2))
				continue;
		}
		return tmp;
	}
	return NULL;
}

/*
 * Finds an address in string list
 *
 * returns TRUE if enabled, FALSE if not.
 *
 * An address that begins with a '-' stops the search and returns FALSE.
 */

BOOLEAN find_ad_strlist(STR_LIST *list, ADDR *ad, char **spec_field)
{
	char *s;
	
	if(list == NULL)
		return TRUE;

#ifdef DEBUG
	status_line(">find_ad_strlist(%s)", Pretty_Addr_Str(ad));
#endif

	s = find_strlist(list, ad, spec_field);
	if(s && (*s != '-'))
		return TRUE;
	else
		return FALSE;
}


BOOLEAN check_holdonus(ADDR *ad, char **spec_field)
{
	BOOLEAN flag = HoldsOnUs;
	
	if(flag)
	{
		if(ad)
			flag = find_ad_strlist(hold_list, ad, spec_field);
		else
			flag = !hold_list;
	}

#ifdef DEBUG
	status_line(">HoldOnUs %sabled for %s",
		flag ? "en" : "dis",
		ad ? Pretty_Addr_Str(ad) : "all nodes");
#endif
	return flag;
}

/*
 * Returns:
 *   TRUE: If EMSI disabled for this node
 */

BOOLEAN check_noemsi(ADDR *ad, char **spec_field)
{
	BOOLEAN flag = no_EMSI;
	
	if(flag)
	{
		if(ad)
			flag = find_ad_strlist(emsi_list, ad, spec_field);
		else
			flag = !emsi_list;
	}

#ifdef DEBUG
	status_line(">EMSI %sabled for %s",
		flag ? "dis" : "en",
		ad ? Pretty_Addr_Str(ad) : "Inbound");
#endif

	return flag;
}

BOOLEAN check_nojanus (ADDR *ad, char **spec_field)
{
	BOOLEAN flag = no_JANUS;
	
	if(flag)
	{
		if(ad)
			flag = find_ad_strlist(janus_list, ad, spec_field);
		else
			flag = !janus_list;
	}

#ifdef DEBUG
	status_line(">JANUS %sabled for %s",
		flag ? "dis" : "en",
		ad ? Pretty_Addr_Str(ad) : "Inbound");
#endif

	return flag;
}

BOOLEAN check_reqonus(ADDR *ad, char **spec_field )
{
	BOOLEAN flag = on_our_nickel;
	
	if(flag)
	{
		if(ad)
			flag = find_ad_strlist(reqonus_list, ad, spec_field);
		else
			flag = !reqonus_list;
	}

#ifdef DEBUG
	status_line(">ReqOnUs %sabled for %s",
		flag ? "en" : "dis",
		ad ? Pretty_Addr_Str(ad) : "all");
#endif

	return flag;
}

BOOLEAN check_norequest(ADDR *ad, char **spec_field )
{
	BOOLEAN flag = no_REQUEST;
	
	if(flag)
	{
		if(ad)
			flag = find_ad_strlist(request_list, ad, spec_field);
		else
			flag = !request_list;
	}

#ifdef DEBUG
	status_line(">Requests %sabled for %s",
		flag ? "en" : "dis",
		ad ? Pretty_Addr_Str(ad) : "all");
#endif

	return flag;
}

void call_fax (void)
{
	long ret;
	
	if (!fax_prg)
	{
		fax_recieve();
		return;
	}

	status_line (msgtxt[M_FAX_RECIEVER], fax_prg);
	
	ret = b_spawn(fax_prg);

	if (ret < 0)
	{
		status_line (msgtxt[M_FAX_EXEC], errno);
	}
	else
	{
		if (ret != 0) status_line (msgtxt[M_FAX_RETURN], ret);
	}

	if (afterfax_prg)
		b_spawn (afterfax_prg);
			
	return;
}

char *DirName(const char *fullname)
{
	static char	str[64];
	
	if (!fullname) return(NULL);
	
	strcpy(str, fullname);
	*(strrchr(str, '\\')+1) = '\0';
	
	return(str);
}
