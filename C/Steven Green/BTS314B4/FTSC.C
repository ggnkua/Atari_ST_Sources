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
/*                 This module was written by Bob Hartman                   */
/*                                                                          */
/*                                                                          */
/*                 BinkleyTerm FTSC Mail Session Routines                   */
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
#include <errno.h>
#include <signal.h>
#include <ctype.h>
#include <conio.h>
#include <time.h>
#include <string.h>
#ifndef LATTICE
#include <io.h>
#endif
#ifdef __TOS__
#include <ext.h>
#else
#include <sys\types.h>
#include <sys\stat.h>
#endif

#ifdef __TURBOC__
#ifndef __TOS__
#include <alloc.h>
#endif
#else
#ifndef LATTICE
#include <malloc.h>
#endif
#endif

#include "bink.h"
#include "msgs.h"
#include "com.h"
#include "ascii.h"
#include "defines.h"
#include "wazoo.h"
#include "session.h"
#include "password.h"
#include "nodeproc.h"

static int FTSC_callback (char *);
static int FTSC_sendmail (void);
static int FTSC_recvmail (void);

static int is_wazoo_session;

#define NUM_FLAGS 4

void FTSC_sender( int wz )
{
   int j;
   char junkbuff[128];
   long t1;

   is_wazoo_session = wz;
   XON_DISABLE ();
   first_block = 0;

   if (!wz)
      {
	   first_block = 1;
      status_line (msgtxt[M_SEND_FALLBACK]);
      who_is_he = 0;
      (void) sprintf (junkbuff, "*%s (%s)",
               newnodedes.SystemName,
               Pretty_Addr_Str (&remote_addr));
      status_line (junkbuff);
      }

   Netmail_Session = 1;

   (void) FTSC_sendmail ();
   t1 = timerset (4500);

   /* See what the receiver would like us to do */
   while ((!timeup (t1)) && CARRIER)
      {
      if ((j = PEEKBYTE ()) >= 0)
         {
         switch (j)
            {
            case TSYNC:
               CLEAR_INBOUND ();
               if (FTSC_recvmail ())
                  goto get_out;
               t1 = timerset (4500);
               break;

            case SYN:
               CLEAR_INBOUND ();
				if(check_reqonus(&remote_addr, (char**)NULL))
                  (void) SEA_recvreq ();
               else
                  {
                  SENDBYTE (CAN);
                  status_line (msgtxt[M_REFUSING_IN_FREQ]);
                  }
               t1 = timerset (4500);
               break;

            case ENQ:
               CLEAR_INBOUND ();
               SEA_sendreq ();
               goto get_out;

            case NAK:
            case 'C':
               CLEAR_INBOUND ();
               SENDBYTE (EOT);
               t1 = timerset (4500);
               break;

            default:
               CLEAR_INBOUND ();
               SENDBYTE (SUB);
               break;
            }
         }
      else
         {
         time_release ();
         }
      }

   if (!CARRIER)
      {
      status_line (msgtxt[M_NO_CARRIER]);
      CLEAR_INBOUND ();
      first_block = 0;
      return;
      }

   if (timeup (t1))
      {
      (void) FTSC_recvmail ();
      status_line (msgtxt[M_TOO_LONG]);
      }

get_out:
   first_block = 0;
   t1 = timerset (100);
   while (!timeup (t1))
      time_release ();
   if (!wz)
      status_line (msgtxt[M_0001_END]);
}

int FTSC_receiver( int wz )
{
   char fname[64];
   int havemail, done, np;
   unsigned int i;
   long t1, t2;
   struct FILEINFO dt1;
   struct stat buf;
   char *HoldName;

   is_wazoo_session = wz;
   first_block = 0;
   XON_DISABLE ();

   if (!wz)
      {
	   first_block = 1;
      status_line (msgtxt[M_RECV_FALLBACK]);
      who_is_he = 1;
      }

   Netmail_Session = 1;

   CLEAR_INBOUND ();

   /* Save the state of pickup for now */
   done = no_pickup;
   no_pickup = 0;
   if (FTSC_recvmail ())
      {
      /* Restore the state of pickup */
      no_pickup = done;
      if (!wz)
         status_line (msgtxt[M_0001_END]);
      first_block = 0;
      return (1);
      }

   /* Restore the state of pickup */
   no_pickup = done;

	remote_addr = called_addr;

   /* If we have the flag file written, then we shouldn't send anything back */
   if (flag_file (TEST_AND_SET, &called_addr, 1))
      {
      havemail = 1;
      goto no_send;
      }

   HoldName = HoldAreaNameMunge(&called_addr);

   /* Now see if we should send anything back to him */
   (void) sprintf (fname, "%s%s.?UT", HoldName, Hex_Addr_Str(&remote_addr));
   havemail = dfind (&dt1, fname, 0);

#ifdef IOS
	if(havemail)
	{
		sprintf(fname, "%s%s.??T", HoldName, Addr36(&remote_addr));
		havemail = dfind(&dt1, fname, 0);
	}
#endif

   if (havemail)
      {
      (void) sprintf (fname, "%s%s.?LO", HoldName, Hex_Addr_Str(&remote_addr));
      havemail = dfind (&dt1, fname, 0);
      }

   if (havemail)
      {
      for (np = 0; np <= ALIAS_CNT; np++)
         {
         if (alias[np].ad.Net == 0)
            break;
         (void) sprintf (fname, "%s%s.REQ", CurrentNetFiles, Hex_Addr_Str(&alias[np].ad));
         havemail = dfind (&dt1, fname, 0);
         if (!havemail)
            break;
         }
      }

no_send:

   if (havemail)
      {
      status_line (msgtxt[M_NOTHING_TO_SEND], Pretty_Addr_Str (&remote_addr));
      }
   else
      {
      status_line (msgtxt[M_GIVING_MAIL], Pretty_Addr_Str (&remote_addr));
      /* Send the TSYNC's until we get a C or NAK or CAN back */
      t1 = timerset (3000);                      /* set 30 second timeout */
      done = 0;
      while (!timeup (t1) && CARRIER && !done)   /* till then or CD lost  */
         {
         SENDBYTE (TSYNC);

         t2 = timerset (300);
         while (CARRIER && (!timeup (t2)) && !done)
            {
            switch (TIMED_READ (0))
               {
               case 'C':
               case NAK:
                  done = 1;
                  (void) FTSC_sendmail ();
                  break;

               case CAN:
                  done = 1;
                  status_line (msgtxt[M_REFUSE_PICKUP], Pretty_Addr_Str (&remote_addr));
                  break;

               default:
                  time_release ();
               }
            }
         }
      }

   first_block = 0;

   if (wz)
      {
      flag_file (CLEAR_FLAG, &called_addr, 1);
      return TRUE;                      /* All done if this is WaZOO */
      }

   /* Now see if we want to request anything */

   sprintf (fname, "%s%s.REQ", HoldName, Hex_Addr_Str(&remote_addr));
#ifdef IOS
	if((i = stat(fname, &buf)) != 0 )
	{
		char *ext = "HOC";
		
		while(*ext)
		{
			sprintf (fname, "%s%s.%cRT", HoldName, Addr36(&remote_addr), *ext);
			if((i = stat(fname, &buf)) == 0)
				break;
			ext++;
		}
	}
	if(!i)
#else
   if (!stat (fname, &buf))
#endif
      {
      /* Send the SYN character and wait for an ENQ or CAN */
      t1 = timerset (3000);                      /* set 30 second timeout */
      done = 0;
      while (!timeup (t1) && CARRIER && !done)   /* till then or CD lost  */
         {
         SENDBYTE (SYN);

         t2 = timerset (500);
         while (CARRIER && (!timeup (t2)) && !done)
            {
            i = (unsigned) TIMED_READ (0);

            switch (i)
               {
               case ENQ:
                  SEA_sendreq ();
                  break;

               case CAN:
                  done = 1;
                  break;

               case 'C':
               case NAK:
                  SENDBYTE (EOT);
                  break;

               case SUB:
                  SENDBYTE (SYN);
                  break;

               default:
                  time_release ();
               }
            }
         }
      }

   /* Finally, can he request anything from us */
   if (!no_requests || (!check_norequest(&remote_addr, (char**)NULL)))
      (void) SEA_recvreq ();

   status_line (msgtxt[M_0001_END]);
   flag_file (CLEAR_FLAG, &called_addr, 1);
   return TRUE;
}

static int FTSC_sendmail ()
{
   FILE *fp;
   char fname[80];
   char s[80];
   char *sptr;
   char *HoldName;
   int c;
   int i;
   int j = 0;
   struct stat buf;
   struct _pkthdr *tmppkt;
   long t1;
   struct tm *tm1;

   XON_DISABLE ();

   sptr = s;
   /*--------------------------------------------------------------------*/
   /* Send all waiting ?UT files (mail packets)                          */
   /*--------------------------------------------------------------------*/
   *ext_flags = 'O';
   HoldName = HoldAreaNameMunge(&called_addr);
   for (c = 0; c < NUM_FLAGS; c++)
      {
      if (caller && (ext_flags[c] == 'H') && !check_holdonus(&called_addr, (char**)NULL))
         continue;
      (void) sprintf (fname,
               "%s%s.%cUT",
               HoldName, Hex_Addr_Str(&called_addr), ext_flags[c]);

      if (!stat (fname, &buf))
         break;

#ifdef IOS
		if(ext_flags[c] != 'D')
			sprintf(fname, "%s%s.%cPT", HoldName, Addr36(&called_addr), ext_flags[c]);
    	if(!stat(fname, &buf))
    		break;
#endif

      }                                          /* for */

   /*--- Build a dummy PKT file name */
   invent_pkt_name (s);

   status_line (msgtxt[M_PACKET_MSG]);

   if (c == NUM_FLAGS)
      {
      (void) sprintf (fname,
               "%s%s.OUT",
               HoldName, Hex_Addr_Str(&called_addr));
      if ((fp = fopen (fname, write_binary)) == NULL)
         {
         (void) got_error (msgtxt[M_OPEN_MSG], fname);
         return (1);
         }
      t1 = time (NULL);
      tm1 = localtime (&t1);

      tmppkt = (struct _pkthdr *) calloc (sizeof (struct _pkthdr), 1);
      if (tmppkt == NULL)
         {
         status_line (msgtxt[M_MEM_ERROR]);
         (void) fclose (fp);
         return (1);
         }

      tmppkt->product = isBITBRAIN;
      tmppkt->ver.w = PUTWORD(PKTVER);
      if (n_getpassword (&called_addr))
         {
         if (remote_password != NULL)
            {
            (void) strupr (remote_password);
            (void) strncpy ((char *) (tmppkt->password), remote_password, 8);
            }
         }
      tmppkt->orig_zone.w = PUTWORD(alias[assumed].ad.Zone);
      tmppkt->dest_zone.w = PUTWORD(called_addr.Zone);

      if ((called_addr.Domain != NULL) &&
          (called_addr.Domain != alias[assumed].ad.Domain) &&
		  (alias[0].ad.Domain))
		{
         /* Make it a type 2.2 packet instead */

	      tmppkt->orig_node.w = PUTWORD(alias[assumed].ad.Node);
    	  tmppkt->dest_node.w = PUTWORD(called_addr.Node);
	      tmppkt->dest_net.w = PUTWORD(called_addr.Net);
    	  tmppkt->orig_net.w = PUTWORD(alias[assumed].ad.Net);

         tmppkt->year.w = PUTWORD(alias[assumed].ad.Point);
         tmppkt->month.w = PUTWORD(called_addr.Point);
         tmppkt->day.w = PUTWORD(0);
         tmppkt->hour.w = PUTWORD(0);
         tmppkt->minute.w = PUTWORD(0);
         tmppkt->second.w = PUTWORD(0);
         tmppkt->rate.w = PUTWORD(2);
         if (alias[assumed].ad.Domain != NULL)
            {
            for (i = 0; domain_name[i] != NULL; i++)
               {
               if (domain_name[i] == alias[assumed].ad.Domain)
                  {
                  break;
                  }
               }
            if (i < 49)
               {
               strncpy (tmppkt->B_fill2, domain_abbrev[i], 8);
               }
            }
         for (i = 0; domain_name[i] != NULL; i++)
            {
            if (domain_name[i] == called_addr.Domain)
               {
               break;
               }
            }
         if (i < 49)
            {
            strncpy (&(tmppkt->B_fill2[8]), domain_abbrev[i], 8);
            }
         }
      else
         {

			if(called_addr.Point || alias[assumed].ad.Point)	/* Remap */
			{
				tmppkt->orig_node.w = PUTWORD(alias[assumed].ad.Point);
				tmppkt->orig_net.w = PUTWORD(alias[assumed].fakenet);
				tmppkt->dest_node.w = PUTWORD(called_addr.Point);
				tmppkt->dest_net.w = PUTWORD(alias[assumed].fakenet);
			}
			else
			{
		    	tmppkt->orig_node.w = PUTWORD(alias[assumed].ad.Node);
    			tmppkt->dest_node.w = PUTWORD(called_addr.Node);
	    		tmppkt->dest_net.w = PUTWORD(called_addr.Net);
	    		tmppkt->orig_net.w = PUTWORD(alias[assumed].ad.Net);
			}

         tmppkt->year.w = PUTWORD(tm1->tm_year);
         tmppkt->month.w = PUTWORD(tm1->tm_mon);
         tmppkt->day.w = PUTWORD(tm1->tm_mday);
         tmppkt->hour.w = PUTWORD(tm1->tm_hour);
         tmppkt->minute.w = PUTWORD(tm1->tm_min);
         tmppkt->second.w = PUTWORD(tm1->tm_sec);
         tmppkt->rate.w = PUTWORD(0);
         }

      (void) fwrite ((char *) tmppkt, sizeof (struct _pkthdr), 1, fp);
      free (tmppkt);
      (void) fwrite ("\0\0", 2, 1, fp);
      (void) fclose (fp);
      }
   else
      {
      if ((fp = fopen (fname, read_binary_plus)) == NULL)
         {
         (void) got_error (msgtxt[M_OPEN_MSG], fname);
         return (1);
         }
      tmppkt = (struct _pkthdr *) calloc (sizeof (struct _pkthdr), 1);
      if (tmppkt == NULL)
         {
         status_line (msgtxt[M_MEM_ERROR]);
         return (1);
         }
      if (fread (tmppkt, 1, sizeof (struct _pkthdr), fp) < sizeof (struct _pkthdr))
         {
         (void) got_error (msgtxt[M_READ_MSG], fname);
         free (tmppkt);
         (void) fclose (fp);
         return (1);
         }

      if (n_getpassword (&called_addr))
         {
         if (remote_password != NULL)
            {
            (void) strupr (remote_password);
            (void) strncpy ((char *) (tmppkt->password), remote_password, 8);
            }
         }


	/*
	 * This cant be right?
	 * Surely it needs to be different for a version 2.2 packet?
	 */

 #ifdef MULTIZONE

		/* Set the originating address in 2D */
		if(alias[assumed].ad.Point)
		{
	      tmppkt->orig_node.w = PUTWORD(alias[assumed].ad.Point);
    	  tmppkt->orig_net.w  = PUTWORD(alias[assumed].fakenet);
		}
		else
		{
	      tmppkt->orig_node.w = PUTWORD(alias[assumed].ad.Node);
    	  tmppkt->orig_net.w  = PUTWORD(alias[assumed].ad.Net);
		}
#else

      tmppkt->orig_node.w = PUTWORD(alias[assumed].ad.Node);
      tmppkt->orig_net.w  = PUTWORD(alias[assumed].ad.Net);
#endif
      /* Make sure the zone info is in there */
      tmppkt->orig_zone.w = PUTWORD(alias[assumed].ad.Zone);
      tmppkt->dest_zone.w = PUTWORD(called_addr.Zone);

      if ((called_addr.Domain != NULL) &&
          (called_addr.Domain != alias[assumed].ad.Domain) &&
		  (alias[0].ad.Domain))
         {
         /* Make it a type 2.2 packet instead */
         tmppkt->year.w = PUTWORD(alias[assumed].ad.Point);
         tmppkt->month.w = PUTWORD(called_addr.Point);
         tmppkt->day.w = PUTWORD(0);
         tmppkt->hour.w = PUTWORD(0);
         tmppkt->minute.w = PUTWORD(0);
         tmppkt->second.w = PUTWORD(0);
         tmppkt->rate.w = PUTWORD(2);
         if (alias[assumed].ad.Domain != NULL)
            {
            for (i = 0; domain_name[i] != NULL; i++)
               {
               if (domain_name[i] == alias[assumed].ad.Domain)
                  {
                  break;
                  }
               }
            if (i < 49)
               {
               strncpy (tmppkt->B_fill2, domain_abbrev[i], 8);
               }
            }
         for (i = 0; domain_name[i] != NULL; i++)
            {
            if (domain_name[i] == called_addr.Domain)
               {
               break;
               }
            }
         if (i < 49)
            {
            strncpy (&(tmppkt->B_fill2[8]), domain_abbrev[i], 8);
            }
         }

      (void) fseek (fp, 0L, SEEK_SET);
      (void) fwrite (tmppkt, 1, sizeof (struct _pkthdr), fp);
      (void) fclose (fp);
      free (tmppkt);
      }

   net_problems = (no_sealink) ? Telink_Send_File (fname, s) : SEAlink_Send_File (fname, s);

   if (net_problems != 0)
      {
      if (c == NUM_FLAGS)
         (void) unlink (fname);
      return (net_problems);
      }

   /* Delete the sent packet */
   (void) unlink (fname);

#ifdef IOS
	{
		char *ext = "HOC";
		while(*ext)
		{
			char c = *ext++;
			
			if (caller && (c == 'H') && !check_holdonus(&called_addr, (char**)NULL))
				continue;
			sprintf(fname, "%s%s.%cAT", HoldName, Addr36(&called_addr), c);
			if(!stat(fname, &buf))
			{
				make_dummy_arcmail(s, &alias[assumed].ad, &called_addr);
				net_problems = (no_sealink) 
					? Telink_Send_File (fname, s) 
					: SEAlink_Send_File (fname, s);
				if(net_problems)
					return net_problems;
				unlink(fname);
			}
		}
	}
#endif

   /*--------------------------------------------------------------------*/
   /* Send files listed in ?LO files (attached files)                    */
   /*--------------------------------------------------------------------*/
   *ext_flags = 'F';
   status_line (" %s %s", msgtxt[M_OUTBOUND], msgtxt[M_FILE_ATTACHES]);

   if (!do_FLOfile (ext_flags, FTSC_callback, &called_addr))
      return FALSE;
#ifdef IOS
	if(!do_FLOfile("HOC", FTSC_callback, &called_addr))
		return FALSE;
#endif


   /*--------------------------------------------------------------------*/
   /* Send our File requests to other system if it's a WaZOO             */
   /*--------------------------------------------------------------------*/

#ifdef NEW  /* TRYREQ  28.08.1990 */
   if (remote_capabilities)
#else
   if (requests_ok && remote_capabilities)
#endif
      {
      sprintf (fname, request_template, HoldName, Hex_Addr_Str(&called_addr));
      if (!stat (fname, &buf))
         {
         if (!(((unsigned) remote_capabilities) & WZ_FREQ))
            status_line (msgtxt[M_FREQ_DECLINED]);
         else
            {
            status_line (msgtxt[M_MAKING_FREQ]);
            if (FTSC_callback (fname))
               (void) unlink (fname);
            }
         }
#ifdef IOS
		{
		  char *extptr = "HOC";
		  while(*extptr)
		  {
			char c = *extptr++;
			if (caller && (c == 'H') && !check_holdonus(&called_addr, (char**)NULL))
				continue;
			sprintf(fname, "%s%s.%cRT", HoldName, Addr36(&called_addr), c);
			if(!stat(fname, &buf))
			{
				if(remote_capabilities & WZ_FREQ)
					status_line (msgtxt[M_FREQ_DECLINED]);
				else
				{
					status_line (msgtxt[M_MAKING_FREQ]);
					sprintf (s, request_template, HoldName, Hex_Addr_Str(&called_addr));
					rename(fname, s);
					if (FTSC_callback(s))
						unlink (s);
				}
			}
		  }
		}
#endif
      }

   /*--------------------------------------------------------------------*/
   /* Process WaZOO file requests from other system                      */
   /*--------------------------------------------------------------------*/

   j = respond_to_file_requests (j, FTSC_callback);

   /* Now close out the file attaches */
   sent_mail = 1;
   *sptr = 0;
   status_line (" %s %s %s", msgtxt[M_END_OF], msgtxt[M_OUTBOUND], msgtxt[M_FILE_ATTACHES]);
	(void) Batch_Send (NULL);
   t1 = timerset (100);
   return TRUE;
}

static int FTSC_recvmail ()
{
   char fname[80];
   char fname1[80];
   struct _pkthdr tmppkt;
   FILE *fp;
   int done;
   int j;
   char *p;

   status_line (msgtxt[M_RECV_MAIL]);

   if (!CARRIER)
      {
      status_line (msgtxt[M_NO_CARRIER]);
      CLEAR_INBOUND ();
      return (1);
      }

   XON_DISABLE ();

	done = 0;

   /* If we don't want to pickup stuff */
   if (no_pickup)
      {
      status_line (msgtxt[M_NO_PICKUP]);
      SENDBYTE (CAN);
      }
   else
      {
      status_line (" %s %s", msgtxt[M_INBOUND], msgtxt[M_MAIL_PACKET]);
      /* Invent a dummy name for the packet */
      invent_pkt_name (fname1);

      /* Receive the packet with special netmail protocol */
      CLEAR_INBOUND ();
      p = CurrentNetFiles;
      if (Xmodem_Receive_File (CurrentNetFiles, fname1) == 0)
         {
         got_packet = 1;
         }
      (void) sprintf (fname, "%s%s", p, fname1);

      /* Check the password if there is one */
      if ((!remote_capabilities) && (n_getpassword (&remote_addr)))
         {
         if (remote_password != NULL)
            {
            got_packet = 0;
            if ((fp = fopen (fname, read_binary_plus)) == NULL)
               {
               (void) got_error (msgtxt[M_OPEN_MSG], fname);
               status_line (msgtxt[M_PWD_ERR_ASSUMED]);
               return (1);
               }
            if (fread (&tmppkt, 1, sizeof (struct _pkthdr), fp) < sizeof (struct _pkthdr))
               {
               (void) got_error (msgtxt[M_OPEN_MSG], fname);
               status_line (msgtxt[M_PWD_ERR_ASSUMED]);
               (void) fclose (fp);
               return (1);
               }
            (void) fclose (fp);
            if (strnicmp (remote_password, (char *) (tmppkt.password), 8))
               {
               tmppkt.orig_zone.w = PUTWORD(0);
               strncpy (fname1, remote_password, 8);
               fname1[8] = '\0';
               status_line (msgtxt[M_PWD_ERROR], tmppkt.password, fname1);
               (void) strcpy (fname1, fname);
               j = (int) strlen (fname) - 3;
               (void) strcpy (&(fname[j]), "Bad");
               if (rename (fname1, fname))
                  {
                  status_line (msgtxt[M_CANT_RENAME_MAIL], fname1);
                  }
               else
                  {
                  status_line (msgtxt[M_MAIL_PACKET_RENAMED], fname);
                  }
               return (1);
               }
            }
         got_packet = 1;
         }
		called_addr = remote_addr;
      got_mail = got_packet;

      done = 0;
      /* Now receive the files if possible */
      status_line (" %s %s", msgtxt[M_INBOUND], msgtxt[M_FILE_ATTACHES]);
      done = Batch_Receive (CurrentNetFiles);
      }

   status_line (" %s %s %s", msgtxt[M_END_OF], msgtxt[M_INBOUND], msgtxt[M_FILE_ATTACHES]);
   CLEAR_INBOUND ();
   return (done);
}

static int FTSC_callback (sptr)
char *sptr;
{
   net_problems = Batch_Send (sptr);
   if (net_problems != 0)
      {
      net_problems = 1;
      return FALSE;
      }
   return TRUE;
}
