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
/*                BinkleyTerm SEAdog Mail Session Routines                  */
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

#ifdef __TOS__
/* #pragma warn -sus */
#endif
#include <stdio.h>
#include <signal.h>
#include <ctype.h>
#include <conio.h>
#include <time.h>
#include <string.h>
#include <stdlib.h>

#include "bink.h"
#include "msgs.h"
#include "com.h"
#include "ascii.h"
#include "defines.h"

void SEA_sendreq ()
{
   	char fname[80];
   	char reqf[80];
   	char *reqtime = " 0";
   	char *p, *name, *pw;
   	char *updtime;
   	FILE *fp;
   	char *HoldName;
#ifdef IOS
	BOOLEAN flag;
#endif

   	HoldName = HoldAreaNameMunge(&called_addr);
   	sprintf (fname, "%s%s.REQ", HoldName, Hex_Addr_Str (&called_addr));
#ifdef IOS
	if(!(flag = dexists(fname)))
	{
		char *ext = "HOC";
		while(*ext)
		{
			sprintf (fname, "%s%s.%cRT", HoldName, Addr36(&called_addr), *ext);
			if(flag = dexists(fname))
				break;
			ext++;
		}
	}
	if(!flag)
#else
   	/* If we have file requests, then do them */
   	if (!dexists (fname))
#endif
      	status_line (msgtxt[M_NO_OUT_REQUESTS]);
   else
      {
      status_line (msgtxt[M_OUT_REQUESTS]);
      /* Open the .REQ file */
      if ((fp = fopen (fname, read_ascii)) == NULL)
         {
         Bark_Request (CurrentNetFiles, NULL, NULL, NULL);
         return;
         }

      /* As long as we do not have EOF, read the request */
      while ((fgets (reqf, 79, fp) != NULL) && (CARRIER))
         {
         /* Properly format the request */

         /* First get rid of the trailing junk */

         p = reqf + strlen (reqf) - 1;
         while ((p >= reqf) && *p && (isspace (*p)))
            *p-- = '\0';

         /* Now get rid of the beginning junk */

         p = reqf;
         while ((*p) && (isspace (*p)))
            p++;

         /* This is where the name starts */
         name = p;

         /* If the first char is ; then ignore the line */
         if (*name == ';')
            continue;

         /* Now get to where the name ends */
         while ((*p) && (!isspace (*p)))
            p++;

         updtime = reqtime;             /* Default to request        */
         pw = p;                        /* This is or will be a null */
req_scan:
         if (*p)
            {
            *p++ = '\0';

            while ((*p) && (*p != '!') && (*p != '-') && (*p != '+'))
               p++;

            /* Check for a password */

            if (*p == '!')
               {
               *p = ' ';
               pw = p++;

               /* Now get to where the password ends */

               while ((*p) && (!isspace (*p)))
                  p++;
               goto req_scan;
               }

            /* Try for an update request */

            if (*p == '+')
               {
               *p = ' ';
               updtime = p++;

               /* Now get to where the update time ends */

               while ((*p) && (!isspace (*p)))
                  p++;

               *p = '\0';

               /* Request time is last thing we care about on line, so
                  we just drop out of the loop after finding it.
                */
               }

            /* Note: since SEAdog doesn't do "backdate" requests, all we
               have to do if we see a '-' is to do a full request. Hence
               we only process a '+' here.
             */

            }

         if (Bark_Request (CurrentNetFiles, name, pw, updtime))
            continue;
         }
      (void) fclose (fp);
      (void) unlink (fname);
      status_line (msgtxt[M_END_OUT_REQUESTS]);
      }

   /* Finish the file requests off */
   Bark_Request (CurrentNetFiles, NULL, NULL, NULL);

}

int cdecl SBInit (BARKARGSP, int);
int cdecl SBEnd (BARKARGSP, int);
int cdecl SBSendBark (BARKARGSP);
int cdecl SBAskFile (BARKARGSP);
int cdecl SBRcvFile (BARKARGSP);
int cdecl SBNxtFile (BARKARGSP);

STATES Bark_Sender[] = {
   { "SBInit", SBInit },
   { "SBEnd", SBEnd },
   { "SB0", SBSendBark },
   { "SB1", SBAskFile },
   { "SB2", SBRcvFile },
   { "SB3", SBNxtFile },
};

void Build_Bark_Packet (args)
BARKARGSP args;
{
   char *p, *q;
   unsigned int crc;

   p = args->barkpacket;
   *p++ = ACK;
   crc = 0;
   q = args->filename;
   while (*q)
      {
      *p++ = *q;
      crc = xcrc (crc, (byte) (*q));
      ++q;
      }
   q = args->barktime;
   while (*q)
      {
      *p++ = *q;
      crc = xcrc (crc, (byte) (*q));
      ++q;
      }
   q = args->barkpw;
   while (*q)
      {
      *p++ = *q;
      crc = xcrc (crc, (byte) (*q));
      ++q;
      }

   *p++ = ETX;
   *p++ = (char) (crc & 0xff);
   *p++ = (char) (crc >> 8);

   args->barklen = (size_t) (p - args->barkpacket);
}

int cdecl SBInit (args, start_state)
BARKARGSP args;
int start_state;
{
   XON_DISABLE ();
   return (start_state);
   /* args; */
}

int cdecl SBEnd (args, cur_state)
BARKARGSP args;
int cur_state;
{
   return (cur_state);
   /* args; */
}

int cdecl SBSendBark (args)
BARKARGSP args;
{
   if ((args->filename != NULL) && (args->filename[0] != '\0'))
      {
      status_line ("%s '%s' %s%s", msgtxt[M_MAKING_FREQ], args->filename, (*(args->barkpw)) ? "with password" : "", args->barkpw);
      args->tries = 0;
      Build_Bark_Packet (args);
      return (SB1);
      }
   else
      {
      SENDBYTE (ETB);

      /* Delay one second */
      big_pause (1);

      return (SUCCESS);
      }
}

int cdecl SBAskFile (args)
BARKARGSP args;
{
   SENDCHARS (args->barkpacket, args->barklen, 1);
   return (SB2);
}

int cdecl SBRcvFile (args)
BARKARGSP args;
{
   int c;
   int ret;

   ret = SB2;
   while (CARRIER && (ret == SB2))
      {
      c = TIMED_READ (10);

      if (c == ACK)
         {
         Batch_Receive (args->inbound);
         ret = SB3;
         break;
         }

      if (args->tries > 5)
         {
/* Report transfer failed */
         SENDBYTE (ETB);
         ret = SENDBLOCK_ERR;
         break;
         }

      CLEAR_INBOUND ();
      ++(args->tries);
      ret = SB1;
      }

   if (!CARRIER)
      return (CARRIER_ERR);
   else
      return (ret);
}

int cdecl SBNxtFile (args)
BARKARGSP args;
{
   int c;
   long SB3Timer;

   SB3Timer = timerset (4500);

   while (CARRIER && !timeup (SB3Timer))
      {
      if ((c = TIMED_READ (5)) == 0xffff)
         {
         SENDBYTE (SUB);
         continue;
         }

      if (c == ENQ)
         return (SUCCESS);
      }

   if (CARRIER)
      return (CARRIER_ERR);
   else
      return (TIME_ERR);
   /* args; */
}

int Bark_Request (where, filename, pw, updtime)
char *where;
char *filename;
char *pw;
char *updtime;
{
   BARKARGS bark;

   bark.inbound = where;
   bark.filename = filename;
   bark.barkpw = pw;
   bark.barktime = updtime;
   return (state_machine (Bark_Sender, &bark, SB0));
}


