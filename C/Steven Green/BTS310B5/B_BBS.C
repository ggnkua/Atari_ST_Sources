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
/*                BinkleyTerm BBS / UUCP Session Initiator                  */
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
#include <signal.h>
#include <ctype.h>
#include <conio.h>
#include <string.h>
#ifndef LATTICE
#include <process.h>
#endif
#include <stdlib.h>
#include <errno.h>


#include "bink.h"
#include "msgs.h"
#include "sched.h"
#include "sbuf.h"
#include "com.h"
#include "vfossil.h"

void BBSexit ()
{
   int retval;
   int xit = 0;
   unsigned int baudrate;
   char command[80];
   FILE *bbsbatch;
   long t1, t2;

   if (BBSnote != NULL)
      {
      (void) SendBanner ("\r\n");                /* Start with newline    */
      (void) SendBanner (BBSnote);               /* Tell user we're going */
      (void) SendBanner ("\r\n");                /* End it with a newline */
      }

   t1 = timerset (50);
   t2 = timerset (400);

   /* Wait for output complete, 4 seconds, or carrier loss */

   while (!OUT_EMPTY () && !timeup (t2) && CARRIER)
      ;

   /* Make sure we waited at least 1/2 second */
   while (CARRIER && !timeup (t1))
      ;

   /* Now if there is no carrier bag it */
   if (!CARRIER)
      {
      status_line (msgtxt[M_NO_CARRIER]);
      return;
      }

   ++hist.bbs_calls;
   if (un_attended && fullscreen)
      {
      sb_move (historywin, HIST_BBS_ROW, HIST_COL);
      (void) sprintf (junk, "%d/%d/%d",
      	hist.bbs_calls, hist.mail_calls, hist.extmails);
      sb_puts (historywin, (unsigned char *) junk);
		}

#ifndef SWGNODO
	/*
	 * It seems that we'd rather have the CONNECT baud rate rather
	 * than the DTE!
	 */
   if (lock_baud && (cur_baud >= lock_baud))
      baudrate = max_baud.rate_value;
   else baudrate = btypes[baud].rate_value;
#endif

   if (BBSopt && (strnicmp (BBSopt, "batch", 5) == 0))       /* if BBS flag is "batch" */
      {
#ifndef OS_2
      (void) strcpy (command, "BBSBATCH.BAT");          /* Batch file name        */
#else
      (void) strcpy (command, "BBSBATCH.CMD");          /* Batch file name        */
#endif
      (void) unlink (command);                          /* Delete old copies      */
      if ((bbsbatch = fopen (command, write_ascii)) == NULL)   /* Try to open it  */
         {
         (void) got_error (msgtxt[M_OPEN_MSG], command);
         return;
         }
      errno = 0;
#ifndef OS_2
      (void) fprintf (bbsbatch, "SPAWNBBS %u %d %d %s\n",
               baudrate, port_ptr + 1, time_to_next (1), mdm_reliable);
#else
      (void) fprintf (bbsbatch, "SPAWNBBS %u %d %d %s\n",
               baudrate, hfComHandle, time_to_next (1), mdm_reliable);
#endif
      (void) fclose (bbsbatch);
      xit = 1;
      }

   if ((BBSopt && (strnicmp (BBSopt, "exit", 4) == 0)) || xit)    /* "exit" or "batch" ??   */
      {
      retval = (int) (baudrate / 100);
      status_line (msgtxt[M_BBS_EXIT], retval);
      if (vfossil_installed)
         vfossil_close ();

      if (!share)                                /* Turn off FOSSIL,       */
         MDM_DISABLE ();                         /* if need be             */
      write_sched ();
      if (reset_port) exit_port();
      exit (retval);                             /* and exit with error    */
      }

   if (BBSopt && (strnicmp (BBSopt, "spawn", 5) == 0))       /* if BBS flag is "spawn" */
      {
      status_line (msgtxt[M_BBS_SPAWN]);
      gotoxy (0, SB_ROWS);
#ifndef OS_2
      (void) sprintf (command, "SPAWNBBS %u %d %d %s",
               baudrate, port_ptr + 1, time_to_next (1), mdm_reliable);
#else
      (void) sprintf (command, "SPAWNBBS %u %d %d %s",
               baudrate, hfComHandle, time_to_next (1), mdm_reliable);
#endif
      close_up ();

      /* Run the BBS */
      b_spawn (command);

      come_back ();
      status_line (msgtxt[M_BBS_RETURN]);
      }
}

void close_up ()
{
   if (!share)
       MDM_DISABLE ();

   vfossil_close ();

#ifdef NEW

	close_log();
	
#else

   /* Close the log file */
   if (status_log != NULL)
      (void) fclose (status_log);

#endif

#ifdef OS_2
#ifdef Snoop
   snoop_close();
#endif /* Snoop */
#endif /* OS_2  */
}

void come_back ()
{
#ifdef OS_2
#ifdef Snoop
   snoop_open(NULL);
#endif /* Snoop */
#endif /* OS_2  */

   /* Re-enable ourselves */
   if (Cominit (port_ptr) != 0x1954)
      {
      (void) printf ("\n%s\n", msgtxt[M_FOSSIL_GONE]);
      if (reset_port) exit_port();
      exit (1);
      }

#ifdef NEW

	open_log();

#else

   if (status_log != NULL)
      {
      if ((status_log = fopen (log_name, append_ascii)) == NULL)
         {
         (void) printf ("\n%s\n", msgtxt[M_NO_LOGFILE]);
         }
      }

#endif

   MDM_ENABLE (lock_baud && (btypes[baud].rate_value >= lock_baud) ? max_baud.rate_mask : btypes[baud].rate_mask);
   vfossil_init ();
   if (fullscreen && un_attended)
      {
      screen_clear ();
      sb_dirty ();
      opening_banner ();
      mailer_banner ();
      sb_show ();
      }
}


void UUCPexit (int n)	/* UUCP Errorlevel value */
{
   unsigned int baudrate;
   char command[80];
   FILE *mailbatch;
   long t1, t2;

   if (MAILnote != NULL)
      {
      (void) SendBanner ("\r\n");                /* Start with newline */
      (void) SendBanner (MAILnote);              /* Say it's mail time */
      (void) SendBanner ("\r\n");                /* End with a newline */
      }

   t1 = timerset (50);
   t2 = timerset (400);

   /* Wait for output complete, 4 seconds, or carrier loss */

   while (!OUT_EMPTY () && !timeup (t2) && CARRIER)
      ;

   /* Make sure we waited at least 1/2 second */
   while (CARRIER && !timeup (t1))
      ;

   /* Now if there is no carrier bag it */
   if (!CARRIER)
      {
      status_line (msgtxt[M_NO_CARRIER]);
      return;
      }


   if (lock_baud && (cur_baud >= lock_baud))
      baudrate = max_baud.rate_value;
   else baudrate = btypes[baud].rate_value;

#ifndef OS_2
  (void) strcpy (command, "MAILBAT.BAT");              /* Batch file name   */
#else
  (void) strcpy (command, "MAILBAT.CMD");              /* Batch file name   */
#endif
   (void) unlink (command);                             /* Delete old copies */
   if ((mailbatch = fopen (command, append_ascii)) == NULL) /* Try to open it */
      {
      (void) got_error (msgtxt[M_OPEN_MSG], command);
      return;
      }
#ifndef OS_2
   (void) fprintf (mailbatch, "EXTMAIL %u %d %d %d %s\n",
            baudrate, port_ptr + 1, time_to_next (1), n, mdm_reliable);
#else
   (void) fprintf (mailbatch, "EXTMAIL %u %d %d %d %s\n",
            baudrate, hfComHandle, time_to_next (1), n, mdm_reliable);
#endif
   (void) fclose (mailbatch);

   status_line (msgtxt[M_EXT_MAIL], n);
	hist.extmails++;								/* Increment extern count */

   if (vfossil_installed)
      vfossil_close ();

   if (!share)                                   /* Turn off FOSSIL,          */
      MDM_DISABLE ();                            /* if need be                */

   write_sched ();                               /* Save scheduler info       */
   if (reset_port) exit_port();
   exit (n);                                     /* and exit with UUCP error  */
}
