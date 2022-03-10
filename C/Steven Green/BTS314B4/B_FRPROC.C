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
/*                   BinkleyTerm File Request Processor                     */
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
/*                                                                          */
/*  This module is based largely on a similar module in OPUS-CBCS V1.03b.   */
/*  The original work is (C) Copyright 1987, Wynn Wagner III. The original  */
/*  author has graciously allowed us to use his code in this work.          */
/*                                                                          */
/*--------------------------------------------------------------------------*/

#include <stdio.h>
#include <ctype.h>
#include <signal.h>
#include <conio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>
#ifdef __TOS__
#include <ext.h>
#else
#include <sys\types.h>
#include <sys\stat.h>
#endif

#ifdef __TURBOC__
#ifndef __TOS__
#include <mem.h>
#endif
#else
#ifndef LATTICE
#include <memory.h>
#endif
#endif

#include "bink.h"
#include "msgs.h"
#include "sbuf.h"
#include "sched.h"
#include "session.h"
#include "password.h"
#include "ascii.h"
#include "com.h"
#include "vfossil.h"
#include "zmodem.h"

static int prep_match( char *template, char *buffer );
static int match( char *s1, char *s2 );
static void run_prog( char *s );
static int check_password( void );
static freq_abort( long file_size );
static int what_event( void );

static char *their_pwd;                         /* Password in REQ file */
static char required_pwd[10];                   /* Password in OK file  */


static int prep_match( char *template, char *buffer )
{
   register int i, delim;
   register char *sptr;
   int start;

   (void) memset (buffer, 0, 11);

   i = (int) strlen (template);
   sptr = template;


   for (start = i = 0; sptr[i]; i++)
      if ((sptr[i] == '\\') || (sptr[i] == ':'))
         start = i + 1;

   if (start)
      sptr += start;
   delim = 8;                                    /* last column for ? */

   (void) strupr (sptr);

   for (i = 0; *sptr && i < 12; sptr++)
      switch (*sptr)
         {
         case '.':
            if (i > 8)
               return (-1);
            while (i < 8)
               {
               buffer[i++] = ' ';
               }
            buffer[i++] = *sptr;
            delim = 12;
            break;

         case '*':
            while (i < delim)
               {
               buffer[i++] = '?';
               }
            break;

         default:
            buffer[i++] = *sptr;
            break;

         }                                       /* switch */

   while (i < 12)
      {
      if (i == 8)
         buffer[i++] = '.';
      else buffer[i++] = ' ';
      }

   buffer[i] = '\0';

   return 0;
}

static int match( char *s1, char *s2 )
{
   register char *i, *j;

   i = s1;
   j = s2;

   while (*i)
      {
      if ((*j != '?') && (*i != *j))
         {
         return 1;
         }
      i++;
      j++;
      }

   return 0;
}

/*--------------------------------------------------------------------------*/
/* Process file requests from the remote system. The filespec requested is  */
/* turned into a local filespec if possible, then transferred via the       */
/* caller-supplied routine.                                                 */
/*--------------------------------------------------------------------------*/

int n_frproc( char *request, int nfiles, int (*callback)(char *) )
{
   register int i;
   register int j = 0;
   static char s[80];
   static char s1[80];
   static char s2[80];

   FILE *approved;
   struct FILEINFO dta;
   struct stat st;
   char *sptr;

   char *after_pwd;
   long updreq = 0L;
   char updtype = 0;
   int saved_nfiles;

   char our_wildcard[15];
   char their_wildcard[15];
   int mfunc;
   int magic_state = 0;
   int tried_about = 0;
#ifndef NEW
   int do_dir = 0;
#endif

   int failure_reason = 1;                      /* 1 = not available */
                                                /* 2 = no update     */
	BOOLEAN delete = FALSE;					/* Delete file after it is sent */
#ifdef NEVER
	time_t thetime;
#endif	

                                                /* 3 = bad password  */
   approved = NULL;

   their_pwd = NULL;
   after_pwd = NULL;

   (void) strcpy (s1, request);


   /*--------------------------------------------------------------------*/
   /* Fix up the file name                                               */
   /*--------------------------------------------------------------------*/
   for (i = 0; request[i]; i++)
      {
      if (request[i] <= ' ')
         {
         request[i++] = '\0';
         j = i;
         break;
         }
      }
   
   if (j)
      {
      /* If we have a '!', find the end of the password, point j
         past it, then truncate and fold if necessary. This leaves
         j properly aligned for other fields.
       */

      if (request[j] == '!')
         {
         their_pwd = request + (++j);
         for (; request[j]; j++)
            {
            if (request[j] <= ' ')
               {
               request[j++] = '\0';
               break;
               }
            }

         if (strlen (their_pwd) > 6)
            their_pwd[6] = '\0';

         (void) fancy_str (their_pwd);
         }

      /* Test for update/backdate request */

      if (request[j] == '+' || request[j] == '-')
         {
         updtype = request[j++];
         updreq = atol (&request[j]);
         }
      }      

   if (!request[0])                             /* Still any filename?  */
      return (nfiles);                          /* If not, return df=0. */

   if (freq_abort(0L))                          /* Any reason to abort? */
      return (-2);                              /* If so, return error. */


   /*--------------------------------------------------------------------*/
   /* Initialization(s)                                                  */
   /*--------------------------------------------------------------------*/
   i = 0;
   sptr = NULL;

   (void) strupr (request);
   status_line ("*%s %s (%s)", (updreq != 0L) ? msgtxt[M_UPDATE] : msgtxt[M_FILE], msgtxt[M_REQUEST], request);

   saved_nfiles = nfiles;

   /*--------------------------------------------------------------------*/
   /* Reserved words                                                     */
   /*--------------------------------------------------------------------*/
   if (!strcmp (request, "FILES"))
      {
      if (CurrentFILES)
         (void) strcpy (s, CurrentFILES);
      else
         {
         s[0] = '\0';
         sptr = msgtxt[M_NO_AVAIL];
         }
      goto avail;
      }

   else if (!strcmp (request, "ABOUT"))
      {
      s[0] = '\0';
      goto avail;
      }

   (void) prep_match (request, their_wildcard);

   /*--------------------------------------------------------------------*/
   /* See if the file is approved for transmission                       */
   /*--------------------------------------------------------------------*/

#ifdef NEW
	if(CurrentOKFile == NULL)		/* Dont bomb if we have no okfile! */
	{
		s[0] = '\0';
		goto avail;
	}
#endif

   if ((approved = fopen (CurrentOKFile, read_ascii)) == NULL)
      {
      got_error (msgtxt[M_OPEN_MSG], CurrentOKFile);
      goto err;
      }

   while (!feof (approved))
      {
#ifndef NEW
      do_dir = 0;
#endif
      /* If we were magic, set flag to cause exit if we don't do it again */
      if (magic_state)
         magic_state = 1;                       /* 1 means done if no @ */

      s[0] = required_pwd[0] = '\0';

      (void) fgets (s, 78, approved);

      for (i = 0; s[i]; i++)
         if (s[i] == 0x09)
            s[i] = ' ';
         else if (s[i] < ' ')
            s[i] = '\0';

      if (!s[0] || s[0] == ';' || s[0] == '-')
         continue;

      /*--------------------------------------------------------------*/
      /* Check for transaction-level password                         */
      /*--------------------------------------------------------------*/
      for (i = 0; s[i]; i++)
         {
         if (s[i] == ' ')
            {
            s[i] = '\0';
            if (s[i + 1] == '!')
               {
               (void) strncpy (required_pwd, s + i + 2, 8);
               if (strlen (required_pwd) > 6)
                  required_pwd[6] = '\0';

               after_pwd = skip_blanks (s + i + 1);
               while (*after_pwd && (!isspace (*after_pwd)))
                  ++after_pwd;

			   after_pwd = skip_blanks(after_pwd);
#if 0
               if (*after_pwd)
                  ++after_pwd;
#endif
               for (i = 0; required_pwd[i]; i++)
                  if (required_pwd[i] <= ' ')
                     required_pwd[i] = '\0';

               break;
               }
            else
               {
               after_pwd = skip_blanks (s + i + 1);
               break;
               }
            }
         else if (s[i] < ' ')
            s[i] = '\0';
         }

      if (!s[0])
         continue;

      if (strchr ("@+$>",s[0]) != NULL)
         {
         /* Magic name or function */
         if ((s[0] != '>') && stricmp (&s[1], request))
            continue;

         /* Name matches, check password */
         if (!(check_password ()))
            {
            failure_reason = 3;      /* Password doesn't match */
            continue;                /* Go on                  */
            }
         
         mfunc = 0;

         if (s[0] == '$')
            {
#ifdef NEW
            sprintf (s2, after_pwd, remote_addr.Net, remote_addr.Node, remote_addr.Point);
#else
            sprintf (s2, after_pwd, remote_addr.Net, remote_addr.Node);
#endif
            mfunc = 1;
            }

         if (s[0] == '+')
            {
#ifdef NEW
			strcpy(s2, s1);
			sprintf(s2+strlen(s2), " %d %d %d",
				remote_addr.Zone,
				remote_addr.Net,
				remote_addr.Node);
			if(remote_addr.Point)
				sprintf(s2+strlen(s2), " %d", remote_addr.Point);
				
#else
            (void) sprintf (s, " %d %d %d", remote_addr.Zone, remote_addr.Net, remote_addr.Node);
            (void) strcpy (s2, s1);
            (void) strcat (s2, s);
#endif
            mfunc = 2;
            }

         if (mfunc)
            {
            run_prog (s2);
            goto check_HLO;
            }
         
         if (s[0] == '@')
            {
            (void) strcpy (s, after_pwd);
            magic_state = 2;                    /* Will be reset up above */
            }

         if (s[0] == '>')
            {
            strcpy (s, &(s[1]));
            strcat (s, "\\*.*");
#ifndef NEW
            do_dir = 1;
#endif
            }
         }

      /*
       * We're past the magic stuff here. So check for whether this is
       * a new iteration of a magic loop that somehow didn't catch.
       * If not, then check out the filespec we have on this line.
       */

      if (magic_state == 1)
         goto check_HLO;

      j = 1;

      if (Netmail_Session == 2)
         SENDBYTE (NUL);

      if (!dfind (&dta, s, 0))
         {
         do
            {
            if (!(--j))                         /* If we've looped a bit  */
               {
               i = freq_abort (0L);
               if (i)                           /* See if we want to quit */
                  {
                  if (i == 1)                   /* Yes, why? Carrier?     */
                     goto finished;             /* uh-huh -- get out fast */
                  else
                     {
                     failure_reason = i;        /* Not carrier, get reason*/
                     goto make_RSP;             /* Make a .RSP file       */
                     }
                  }
               j = 10;                          /* No, reset bounds       */
               }

            if (!magic_state)                   /* If not "magic",        */
               {
               if (prep_match (dta.name, our_wildcard) < 0)
                  continue;

               if (match (our_wildcard, their_wildcard))
                  continue;

               /* File names match, check password now */

               if (!check_password ())
                  {
                  failure_reason = 3;      /* Password doesn't match */
                  continue;                /* Go on                  */
                  }
               }

            /* Good password, get full path with wildcard from OKFILE */

            (void) strcpy (s2, s);

            /* Subtract the wild card file name, keep path */

            for (i = (int) strlen (s2); i; i--)
               if (s2[i] == '\\')
                  {
                  s2[i + 1] = 0;
                  break;
                  }

            /* Then add in the exact name found */

            (void) strcat (s2, dta.name);

            /* Got full filename, now do file update validation */

            if (updtype && !stat (s2, &st))
               {
               if ((updtype == '+' && (st.st_atime <= updreq))
               ||  (updtype == '-' && (st.st_atime >= updreq)))
                  {
                  failure_reason = 2;      /* No update available    */
                  continue;                /* Go on                  */
                  }
               }

            i = freq_abort (dta.size);     /* Check file size        */
            if (i)                         /* See if we want to quit */
               {
               if (i == 1)                 /* Yes, why? Carrier?     */
                  goto finished;           /* uh-huh -- get out fast */
               else
                  {
                  failure_reason = i;      /* Not carrier, get reason*/
                  goto make_RSP;           /* Make a .RSP file       */
                  }
               }

            /* Everything is OK, send the file if we can */
            CLEAR_INBOUND ();
            if ((*callback) (s2))
               {
               ++nfiles;
               freq_accum.bytes += dta.size;
               ++freq_accum.files;
               }

			/* New bit... if the request isn't a wild card then stop! */

			if(strchr(their_wildcard, '?') == NULL)
				break;

            j = 1;                               /* Force abort test */
            }
#ifdef LATTICE
		while(!dnext(&dta));
#else
         while (!dfind (&dta, s, 1));
#endif         
         }                                       /* if dfind */

      else status_line (msgtxt[M_OKFILE_ERR], s);  /* if not dfind */

      s[0] = '\0';
      }                                          /* while not eof(approved) */

   if (saved_nfiles != nfiles)
      failure_reason = 9;

make_RSP:

   s[0] = '\0';                                  /* Initialize string     */
   if ((CurrentReqTemplate != NULL) && (dexists(CurrentReqTemplate)))
   {
      Make_Response(s1, failure_reason);        /* Build a response      */

      if ((!s1[0]) && (failure_reason > 3))   	/* if no .RSP file,      */
        goto finished;                          /* give it up            */

      if(doing_janus)
      {
        if(s1[0])
        {
	      	s[0] = DELETE_AFTER;
    	  	strcpy(&s[1], s1);
    	}
      }
      else
      {
      	strcpy(s, s1);                             /* Copy it for xmission  */
        if(s[0])
      		delete = TRUE;
      }
   }


   /*--------------------------------------------------------------------*/
   /* File requested not found, send the system ABOUT file.              */
   /*--------------------------------------------------------------------*/
avail:

   if (!s[0])
      {
      if (CurrentAbout)
         (void) strcpy (s, CurrentAbout);
      else
         {
         if (tried_about)
            {
            sptr = msgtxt[M_NO_ABOUT];
            goto err;
            }
         else
            {
            ++tried_about;
            (void) strcpy (s1, request);
            failure_reason = 1;        /* Didn't find what we wanted */
            goto make_RSP;             /* Make a .RSP file       */
            }
         }
      }

   if ((*callback) (s))
         ++nfiles;

	if(delete && !doing_janus)	/* Janus needs file to not be deleted! */
		unlink(s);
	delete = FALSE;

   goto finished;

   /*--------------------------------------------------------------------*/
   /* See if we generated a .QLO file somehow, if so send listed files   */
   /*--------------------------------------------------------------------*/
check_HLO:

   (void) do_FLOfile ("Q", callback, &called_addr);

   /*--------------------------------------------------------------------*/
   /* Maybe the magic request made a conventional .FLO file, try that too*/
   /*--------------------------------------------------------------------*/

   *ext_flags = 'FOH';
   
   /* OH added for IOS mode, this will also search for files like */
   /* OLO, HLO but we doesn't care about this					  */
   
   (void) do_FLOfile (ext_flags, callback, &called_addr);
   goto finished;

   /*--------------------------------------------------------------------*/
   /* Error return                                                       */
   /*--------------------------------------------------------------------*/
err:
   if (sptr)
      status_line ("!%s %s %s: %s",
         (updreq != 0L) ? msgtxt[M_UPDATE] : msgtxt[M_FILE],
         msgtxt[M_REQUEST], &(msgtxt[M_ERROR][1]), sptr);

finished:
   if (approved)
      (void) fclose (approved);

   return (nfiles);
}

static void run_prog( char *s )
{
   unsigned int saved_baud;

   status_line ("%s '%s'", msgtxt[M_EXECUTING], s);
   if (fullscreen && un_attended)
      {
      screen_clear ();
      }
   scr_printf (&(msgtxt[M_EXECUTING][1]));
   scr_printf (s);
   scr_printf ("\r\n");
   vfossil_cursor (1);
   saved_baud = cur_baud;
   b_spawn (s);
   vfossil_cursor (0);
   if (fullscreen && un_attended)
      {
      screen_clear ();
      sb_dirty ();
      opening_banner ();
      mailer_banner ();
      }

   set_baud (saved_baud, 0);          /* Restore baud rate trashed by others */
}

static int check_password( void )
{
   if (required_pwd[0])
   {
      fancy_str (required_pwd);
      if ( ((their_pwd == NULL) || stricmp (required_pwd, their_pwd)) &&
           ((remote_password == NULL) || stricmp (required_pwd, remote_password)))
      {
         status_line (msgtxt[M_FREQ_PW_ERR],
                               required_pwd,
                               their_pwd ? their_pwd : "",
                               remote_password ? remote_password : "");

         return (0);
      }
   }
   return (1);
}

static int freq_abort (long file_size)
{
   int w_event;
#ifdef NEW
	time_t thetime;
#endif

   if (!CARRIER)
      {
      status_line (msgtxt[M_CARRIER_REQUEST_ERR]);
      return (1);
      }

   if (freq_accum.files >= CurrentReqLim)
      {
      status_line ("%s (%d)", msgtxt[M_FREQ_LIMIT], CurrentReqLim);
      return (4);
      }

   if ((freq_accum.bytes + file_size) > CurrentByteLim)
      {
      status_line ("%s (%ld+%ld > %ld)", msgtxt[M_BYTE_LIMIT], freq_accum.bytes, file_size, CurrentByteLim);
      return (6);
      }

#ifdef NEW

	/* Check for time */
	
	time(&thetime);
	thetime -= freq_accum.startTime;	/* Time so far */
	
	/* Update transfer rate so far */

	if(freq_accum.bytes && !doing_janus)
		freq_accum.transferRate = (int) (freq_accum.bytes / (thetime+1)) + 1;

#ifdef DEBUG
	status_line(">freq: %ld+%ld > %ld Bytes, %ld > %d sec (%d cps)",
		freq_accum.bytes, file_size, CurrentByteLim,
		(long)thetime, CurrentTimeLim, freq_accum.transferRate);
#endif

	if( (thetime + file_size / freq_accum.transferRate) > CurrentTimeLim)
	{
		status_line("%s (%ld > %d seconds CPS %d)",
			msgtxt[M_TIME_LIMIT],
			(long)thetime, CurrentTimeLim, freq_accum.transferRate);
		return 7;
	}

#endif

   w_event = what_event ();
   if ((w_event >= 0) && (w_event != cur_event))
      {
      if ((e_ptrs[w_event]->behavior & MAT_NOREQ) ||
         ((w_event != cur_event) && (e_ptrs[w_event]->behavior & MAT_FORCED)))
         {
         status_line (msgtxt[M_EVENT_OVERRUN]);
         return (5);
         }
      }

   return (0);
}

static int what_event( void )
{
   int cur_day;
   int cur_hour;
   int cur_minute;
   int cur_mday;
   int cur_mon;
   int cur_year;
   int junk;
   int our_time;
   int w_event;
   int i;

   /* Get the current time in minutes */
   dostime (&cur_hour, &cur_minute, &junk, &junk);
   our_time = cur_hour * 60 + cur_minute;

   /* Get the current day of the week */
   dosdate (&cur_mon, &cur_mday, &cur_year, &cur_day);

   cur_day = 1 << cur_day;

   w_event = -1;

   /* Go through the events from top to bottom */
   for (i = 0; i < num_events; i++)
      {
      if (our_time >= e_ptrs[i]->minute)
         {
         if ((cur_day & e_ptrs[i]->days) &&
	 ((!e_ptrs[i]->day) || (e_ptrs[i]->day == (char)cur_mday)) &&
	 ((!e_ptrs[i]->month) || (e_ptrs[i]->month == (char)cur_mon)))
            {
            if (((our_time - e_ptrs[i]->minute) < e_ptrs[i]->length) ||
            ((our_time == e_ptrs[i]->minute) && (e_ptrs[i]->length == 0)) ||
                ((e_ptrs[i]->behavior & MAT_FORCED) && (e_ptrs[i]->last_ran != cur_mday)))
               {
               /* Are we not supposed to force old events */
               if (((our_time - e_ptrs[i]->minute) > e_ptrs[i]->length) && (noforce))
                  {
                  e_ptrs[i]->last_ran = cur_mday;
                  continue;
                  }

               if ((e_ptrs[i]->last_ran == cur_mday) &&
                   (e_ptrs[i]->behavior & MAT_SKIP))
                  {
                  /* Don't do events that have been exited already */
                  continue;
                  }

               w_event = i;

               break;
               }
            }
         }
      }

   return (w_event);
}
