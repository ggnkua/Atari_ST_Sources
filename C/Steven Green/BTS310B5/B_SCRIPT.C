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
/*               This module was written by Vince Perriello                 */
/*                                                                          */
/*                                                                          */
/*                    BinkleyTerm Script Handler Module                     */
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

#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <ctype.h>
#include <conio.h>
#include <string.h>

#ifndef LATTICE
#include <process.h>
#endif


#include "bink.h"
#include "msgs.h"
#include "sbuf.h"
#include "vfossil.h"
#include "com.h"
#include "ascii.h"

static int nextline (char *);
static int get_line (void);


/*--------------------------------------------------------------------------*/
/*   Define our current script functions for use in our dispatch table.     */
/*--------------------------------------------------------------------------*/

static int script_port (void);                   /* Chang the port being used */
static int script_baud (void);                   /* Set our baud rate to that
                                                  * of remote */
static int script_xmit (void);                   /* transmit characters out
                                                  * the port   */
static int script_rawxmit (void);                /* transmit characters out
                                                  * the port (no translation) */
static int script_pattern (void);                /* define a pattern to wait
                                                  * for       */
static int script_wait (void);                   /* wait for a pattern or
                                                  * timeout      */
static int script_dial (void);                   /* dial the whole number at
                                                  * once      */
static int script_areacode (void);               /* transmit the areacode out
                                                  * the port */
static int script_phone (void);                  /* transmit the phone number */
static int script_carrier (void);                /* Test point, must have
                                                  * carrier now  */
static int script_session (void);                /* Exit script
                                                  * "successfully"         */
static int script_if (void);                     /* Branch based on pattern
                                                  * match      */
static int script_goto (void);                   /* Absolute branch           */
static int script_timer (void);                  /* Set a master script
                                                  * timeout        */
static int script_bps100 (void);                 /* Send BPS/100 to remote
                                                  * system      */
static int script_break (void);                  /* Send a break to remote
                                                  * system      */
static int script_params (void);                 /* Set communication
                                                  * parameters       */
static int script_DOS (void);                    /* Execute a DOS command */
static int script_abort (void);                  /* Abort a script during
                                                  * certain hours */
static int script_noWaZOO (void);                /* Turn off WaZOO for this
                                                  * session only */
struct dispatch
{
   char *string;
   int (*fun) (void);
};

static struct dispatch disp_table[] = {
                                {"baud", script_baud},
                                {"xmit", script_xmit},
                                {"rawxmit", script_rawxmit},
                                {"pattern", script_pattern},
                                {"wait", script_wait},
                                {"dial", script_dial},
                                {"areacode", script_areacode},
                                {"phone", script_phone},
                                {"carrier", script_carrier},
                                {"session", script_session},
                                {"if", script_if},
                                {"goto", script_goto},
                                {"timer", script_timer},
                                {"speed", script_bps100},
                                {"break", script_break},
                                {"comm", script_params},
                                {"dos", script_DOS},
                                {"abort", script_abort},
                                {"port", script_port},
                                {"NoWaZOO", script_noWaZOO},
                                {NULL, NULL}
};

static char *script_dial_string = NULL;          /* string for 'dial'     */
static char *script_phone_string = NULL;         /* string for 'phone'    */
static char *script_areacode_string = "          ";/* string for 'areacode' */

#define PATTERNS 9
#define PATSIZE 22

static char pattern[PATTERNS][PATSIZE];          /* 'wait' patterns       */
static int scr_session_flag = 0;                 /* set by "session".     */
static int pat_matched = -1;
static char *script_function_argument;           /* argument for functions */

#define MAX_LABELS 50
#define MAX_LAB_LEN 20
static struct lab
{
   char name[MAX_LAB_LEN + 1];
   long foffset;
   int line;
} labels[MAX_LABELS];

static long offset;
static long script_alarm;                        /* used for master timeout */
static int num_labels = 0;
static int curline;
static FILE *stream;

static char temp[256];

int do_script (phone_number)
char *phone_number;
{
   register int i, j, k;
   register char *c, *f;
   char s[64], *t;

/*--------------------------------------------------------------------------*/
/* Reset everything from possible previous use of this function.            */
/*--------------------------------------------------------------------------*/

   /* Get rid of cr/lf stuff if it is there */
   if ((c = strchr (phone_number, '\r')) != NULL)
      *c = '\0';
   if ((c = strchr (phone_number, '\n')) != NULL)
      *c = '\0';

   curline = 0;
   pat_matched = -1;
   num_labels = 0;
   *script_areacode_string = '\0';               /* reset the special strings */
   script_dial_string = script_phone_string = NULL;
   script_alarm = 0L;                            /* reset timeout */
   for (i = 0; i < PATTERNS; i++)
      {
      pattern[i][0] = 1;
      pattern[i][1] = '\0';                      /* and the 'wait' patterns   */
      }
   scr_session_flag = 0;

/*--------------------------------------------------------------------------*/
/* Now start doing things with phone number:                                */
/*     1) construct the name of the script file into temp                   */
/*     2) build script_dial_string, script_areacode_string and              */
/*        script_phone_string                                               */
/*--------------------------------------------------------------------------*/

   if (script_path == NULL)
      (void) strcpy (temp, BINKpath);                   /* get our current path      */
   else (void) strcpy (temp, script_path);              /* Otherwise, use the given
                                                  * path */

   t = c = &temp[strlen (temp)];                 /* point past paths          */
   f = phone_number;                             /* then get input side       */
   while (*++f != '\"')                          /* look for end of string    */
      {
      if ((*c++ = *f) == '\0')                   /* if premature ending,      */
         return (0);
      }
   *c = '\0';                                    /* Now we have the file name */
   (void) strcpy (s, t);

   c = script_areacode_string;                   /* point to area code        */
   if (*++f)                                     /* if there's anything left, */
      {
      script_dial_string = f;                    /* dial string is rest of it */
      for (i = 0; (i < 10) && (*f != '\0') && (*f != '-'); i++)
         *c++ = *f++;                            /* copy it for 'areacode'    */
      }
   *c = '\0';                                    /* terminate areacode        */
   if (*f && *f++ == '-')                        /* If more, and we got '-',  */
      script_phone_string = f;                   /* point to phone string     */

   if (script_dial_string == NULL)               /* To make the log happy,    */
      script_dial_string ="";                    /* NULL => 0-length string   */


/*--------------------------------------------------------------------------*/
/* Finally open the script file and start doing some WORK.                  */
/*--------------------------------------------------------------------------*/

   status_line (msgtxt[M_DIALING_SCRIPT], script_dial_string, s);

   if ((stream = fopen (temp, read_binary)) == NULL)    /* OK, let's open the file   */
      {
      status_line (msgtxt[M_NOOPEN_SCRIPT], temp);
      return (0);                                /* no file, no work to do    */
      }

   k = 0;                                        /* default return is "fail"  */
   while (nextline (NULL))                       /* Now we parse the file ... */
      {
      k = 0;                                     /* default return is "fail"  */
      for (j = 0; (c = disp_table[j].string) != NULL; j++)
         {
         i = (int) strlen (c);
         if (strnicmp (temp, c, (size_t) i) == 0)
            {
            script_function_argument = temp + i + 1;
            k = (*disp_table[j].fun) ();
            break;
            }
         }

      if (script_alarm && timeup (script_alarm)) /* Check master timer */
         {
         status_line (msgtxt[M_MASTER_SCRIPT_TIMER]);
         k = 0;
         }

      if (!k || scr_session_flag)                /* get out for failure or    */
         break;                                  /* 'session'.                */

      }
   (void) fclose (stream);                              /* close input file          */
   if (!k)
      {
      status_line (msgtxt[M_SCRIPT_FAILED], s, curline);
#ifdef NEW /* FASTMODEM  10.09.1989 */
      hang_up ();
#else
      DTR_OFF ();
      timer (1);
#endif
      }
   return (k);                                   /* return last success/fail  */
}

static script_xmit ()
{
   mdm_cmd_string (script_function_argument, 1);
   return (1);
}

static script_rawxmit ()
{
   char *p;

   p = script_function_argument;

   while (*p)
      {
      SENDBYTE ((unsigned char) *p);
      ++p;
      }
   return (1);
}

static script_DOS ()
{
   close_up ();
   vfossil_cursor (1);
   b_spawn (script_function_argument);
   come_back ();
   return (1);
}

static script_abort ()
{
   int s1, s2, e1, e2;
   int cur_hour, cur_minute, j;
   int starttime, endtime, us;

   /* If we don't get everything we need, it is a true abort */
   if (sscanf (script_function_argument, "%d:%d %d:%d", &s1, &s2, &e1, &e2) != 4)
      return (0);

   dostime (&cur_hour, &cur_minute, &j, &j);
   starttime = s1 * 60 + s2;
   endtime = e1 * 60 + e2;
   us = cur_hour * 60 + cur_minute;

   if (endtime < starttime)
      {
      endtime += 60 * 60;
      }

   if (us < starttime)
      {
      us += 24 * 60;
      }

   if ((us >= starttime) && (us <= endtime))
      {
      return (0);
      }

   return (1);
}

static script_break ()
{
   int t;

   t = atoi (script_function_argument);
   if (t == 0)
      t = 100;

#ifndef ATARIST
   if (old_fossil)
      {
      status_line (msgtxt[M_NO_BREAK]);
      }
   else
      {
      send_break (t);
      }
#else
	send_break(t);
#endif
   return (1);
}

static script_params ()
{
   char c;
   int i, j;

   (void) sscanf (script_function_argument, "%d%c%d", &i, &c, &j);
   comm_bits = (i == 7) ? BITS_7 : BITS_8;
   switch (toupper (c))
      {
      case 'E':
         parity = EVEN_PARITY;
         break;

      case 'O':
         parity = ODD_PARITY;
         break;

      case 'N':
         parity = NO_PARITY;
         break;
      }
   stop_bits = (j == 1) ? STOP_1 : STOP_2;
   MDM_ENABLE (lock_baud && (btypes[baud].rate_value >= lock_baud) ? max_baud.rate_mask : btypes[baud].rate_mask);
   return (1);
}

static script_bps100 ()
{
   char junk[10];

   (void) sprintf (junk, "%d", cur_baud / 100);
   mdm_cmd_string (junk, 0);
   return (1);
}

static script_areacode ()
{
   mdm_cmd_string (script_areacode_string, 0);
   return (1);
}

static script_phone ()
{
   mdm_cmd_string (script_phone_string, 0);
   return (1);
}

static script_dial ()
{
   mdm_cmd_string (script_dial_string, 0);
   mdm_cmd_char (CR);                            /* terminate the string      */
   if (modem_response (7500) == 2)               /* we got a good response,   */
      {
      timer (20);                                /* wait for other side       */
      return (1);                                /* Carrier should be on now  */
      }
   return (0);                                   /* no good */
}

static script_carrier ()
{
   return ((int) CARRIER);
}

static script_session ()
{
   ++scr_session_flag;                           /* signal end of script */
   return (1);
}

static script_pattern ()
{
   register int i, j;
   register char *c;

   c = script_function_argument;                 /* copy the pointer   */
   i = atoi (c);                                 /* get pattern number */
   if (i < 0 || i >= PATTERNS)                   /* check bounds */
      return (0);
   c += 2;                                       /* skip digit and space */
   for (j = 1; (j <= PATSIZE) && (*c != '\0'); j++)
      pattern[i][j] = *c++;                      /* store the pattern */
   pattern[i][j] = '\0';                         /* terminate it here */
   return (1);
}

static script_wait ()
{
   long t1;
   register int i, j;
   register char c;
   int cnt;
   unsigned long wait;
   int got_it = 0;

   pat_matched = -1;
   wait = (100 * atoi (script_function_argument)); /* try to get wait length */
   if (!wait)
      wait = 4000;                               /* default is 40 seconds     */
   t1 = timerset (wait);
   (void) printf ("\n");
   clear_eol ();
   cnt = 0;
   while (!timeup (t1) && !KEYPRESS ())
      {
      if (script_alarm && timeup (script_alarm)) /* Check master timer */
         break;                                  /* Oops, out of time...      */

      if (!CHAR_AVAIL ())                        /* if nothing ready yet,     */
         {
         time_release ();                        /* give others a shot        */
         continue;                               /* just process timeouts     */
         }
      t1 = timerset (wait);                      /* reset the timeout         */
      c = (char) MODEM_IN ();                    /* get a character           */
      if (!c)
         continue;                               /* ignore null characters    */
      if (c >= ' ')
         {
         WRITE_ANSI (c & 0x7f);
         if (++cnt >= SB_COLS - 10)
            {
            cnt = 0;
            (void) printf ("\r");
            clear_eol ();
            (void) printf ("(cont): ");
            }
         }
      for (i = 0; i < PATTERNS; i++)
         {
         j = pattern[i][0];                      /* points to next match char */
         if (c == pattern[i][j])                 /* if it matches,            */
            {
            ++j;                                 /* bump the pointer          */
            pattern[i][0] = (char) j;            /* store it                  */
            if (!pattern[i][j])                  /* if at the end of pattern, */
               {
               ++got_it;
               pat_matched = i;
               goto done;
               }
            }
         else
            {
            pattern[i][0] = 1;                   /* back to start of string   */
            }
         }
      }
done:
   for (i = 0; i < PATTERNS; i++)
      {
      pattern[i][0] = 1;                         /* reset these for next time */
      }
   if (!got_it)                                  /* timed out, look for label */
      {
      /* First skip over the numeric argument for "wait"   */
      while (isdigit (*script_function_argument))
         script_function_argument++;

      /* Then skip over any spaces that follow it          */
      while (*script_function_argument && isspace (*script_function_argument))
         script_function_argument++;

      /* Now, if there's anything more, treat it as a goto */
      if (*script_function_argument)
         return (script_goto ());
      }         
   return (got_it);
}

static script_baud ()
{
   unsigned int b;

   if ((b = (unsigned int) atoi (script_function_argument)) != 0)
      {
      return set_baud (b, 0);
      }
   return (1);
}

static script_goto ()
{
   int i;

   /* First see if we already found this guy */
   for (i = 0; i < num_labels; i++)
      {
      if (stricmp (script_function_argument, labels[i].name) == 0)
         {
         /* We found it */
         (void) fseek (stream, labels[i].foffset, SEEK_SET);
         curline = labels[i].line;
         return (1);
         }
      }

   return (nextline (script_function_argument));
}

static script_if ()
{

   /* First, move past any spaces that might be between IF and value.   */

   while (isspace (*script_function_argument) && (*script_function_argument))
      ++script_function_argument;

   /* Then check for digit. Only current legal non-digit is 'B' but     *
    * that might change with time...                                    *
    *                                                                   *
    * If it's a non-digit,                                              *
    *                                                                   *
    *    a) look for "BPS". If not, return error.                       *
    *                                                                   *
    *    b) compare current baud with number that should follow         *
    *       "BPS". If no match, return error.                           *
    *                                                                   *
    * If it's a digit, compare the number of the last pattern we matched*
    * with the argument value. If no match, return error.               *
    *                                                                   */

   if (!isdigit(*script_function_argument))
      {
      if (strnicmp (script_function_argument, "BPS", 3) != 0)
         return (1);

      script_function_argument += 3;
      if (atoi (script_function_argument) != (int) cur_baud)
         return (1);
      }

   else if (atoi (script_function_argument) != pat_matched)
      return(1);
   
   /* We matched, skip the pattern number and the space                 */

   while ((*script_function_argument) &&
          (!isspace (*script_function_argument)))
      ++script_function_argument;

   while ((*script_function_argument) &&
          (isspace (*script_function_argument)))
      ++script_function_argument;

   return (script_goto ());
}

static script_timer ()                           /* Set a master timer */
{
   int i;

   /*
    * If we got a number, set the master timer. Note: this could be done many
    * times in the script, allowing you to program timeouts on individual
    * parts of the script. 
    */

   i = atoi (script_function_argument);
   if (i)
      script_alarm = timerset ((long)i * 100);

   return (1);
}

static script_port ()
{
	int c;

	c = port_ptr;
   MDM_DISABLE ();
	port_ptr = atoi (script_function_argument) - 1;
   if (Cominit (port_ptr) != 0x1954)
      {
      port_ptr = c;
      (void) Cominit(port_ptr);
		return (0);
      }
   MDM_ENABLE (lock_baud && (btypes[baud].rate_value >= lock_baud) ? max_baud.rate_mask : btypes[baud].rate_mask);
   DTR_ON ();
	return (1);
}

static script_noWaZOO ()
{
   ++no_WaZOO_Session;
   return (1);
}

static int nextline (str)
char *str;
{
   char save[256];

   if (str != NULL)
      (void) strcpy (save, str);
   else save[0] = '\0';

   while (get_line ())                           /* Now we parse the file ... */
      {
      if (!isalpha (temp[0]))
         {
         if (temp[0] != ':')
            {
            /* This line is a comment line */
            continue;
            }
         else
            {
            /* It is a label */
            if (num_labels >= MAX_LABELS)
               {
               status_line (msgtxt[M_TOO_MANY_LABELS]);
               return (0);
               }
            (void) strcpy (labels[num_labels].name, &(temp[1]));
            labels[num_labels].foffset = offset;
            labels[num_labels].line = curline;
            ++num_labels;

            if (stricmp (&temp[1], save))
               {
               continue;
               }
            else
               {
               return (1);
               }
            }
         }

      if (!save[0])
         return (1);
      }

   return (0);
}

static int get_line ()
{
   char *c;
   char j[100];

   if (fgets (temp, 255, stream) == NULL)
      return (0);

   ++curline;

   /* Deal with side effects of opening the script file in binary mode  */

   c = &temp [strlen (temp) - 1];
   while ((*c == '\r') || (*c == '\n'))
     c--;
   
   *++c = '\0';         /* Don't want newlines, terminate after text    */

   (void) sprintf (j, script_line, curline, temp);
   if ((un_attended || doing_poll) && fullscreen)
      {
      sb_move (filewin, 2, 2);
      sb_puts (filewin, (unsigned char *) j);
      sb_show ();
      }
   else
      {
      (void) printf ("\n%s", j);
      }
   offset = ftell (stream);
   return (1);
}
