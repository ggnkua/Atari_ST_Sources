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
/*                  This module was written by Bob Hartman                  */
/*                                                                          */
/*                                                                          */
/*               BinkleyTerm "BARK" File request state machine              */
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

/* System include files */

#include <stdio.h>
#include <string.h>
#include <ctype.h>

#ifdef __TOS__
/* #pragma warn -sus */
#else
#include <fcntl.h>
#endif

#ifdef __TURBOC__
#ifndef __TOS__
#include <mem.h>
#include <alloc.h>
#endif
#else
#ifdef LATTICE
#include <stdlib.h>
#else
#include <memory.h>
#include <malloc.h>
#endif
#endif


/* Local include files */

#include "bink.h"
#include "msgs.h"
#include "defines.h"
#include "com.h"
#include "session.h"
#include "ascii.h"


static int get_req_str (char *);
static void gen_req_name (char *);
static int cdog_callback(char *);

int cdecl RBInit (BARKARGSP, int);
int cdecl RBEnd (BARKARGSP, int);
int cdecl RBHonorReq (BARKARGSP);
int cdecl RBWaitBark (BARKARGSP);
int cdecl RBAckBark (BARKARGSP);
int cdecl RBWaitStrt (BARKARGSP);
int cdecl RBSendFile (BARKARGSP);

STATES Bark_Receiver[] = {
   { "RBInit", (void *)RBInit },
   { "RBEnd", (void *)RBEnd },
   { "RB0", (void *)RBHonorReq },
   { "RB1", (void *)RBWaitBark },
   { "RB2", (void *)RBAckBark },
   { "RB3", (void *)RBWaitStrt },
   { "RB4", (void *)RBSendFile }
};

int Receive_Bark_Packet( BARKARGSP args )
{
   if (get_req_str (args->barkpacket))
      {
      gen_req_name (args->barkpacket);
      args->barkok = 1;
      return (0);
      }

   return (1);
}

int cdecl RBInit (args, start_state)
BARKARGSP args;
int start_state;
{
   XON_DISABLE ();
   args->barkok = 0;
   return (start_state);
}

int cdecl RBEnd (args, cur_state)
BARKARGSP args;
int cur_state;
{
   if ( args )
   {
   }
   
   if (!no_requests || !check_norequest(&remote_addr, (char**)NULL))
      {
      status_line (":%s %s %s", msgtxt[M_END_OF], msgtxt[M_INBOUND], msgtxt[M_FILE_REQUESTS]);
      }
   return (cur_state);
   /* args; */
}

int cdecl RBHonorReq( BARKARGSP args )
{
   args->nfiles = 0;

   if (!no_requests)
      {
      status_line (":%s %s", msgtxt[M_INBOUND], msgtxt[M_FILE_REQUESTS]);
      SENDBYTE (ENQ);
      args->T1 = timerset (200);
      return (RB1);
      }
   else
      {
      SENDBYTE (CAN);
      status_line (msgtxt[M_REFUSING_IN_FREQ]);
      return (SUCCESS);
      }
}

int cdecl RBWaitBark( BARKARGSP args )
{
   int c;
   long RB1Timer;

   RB1Timer = timerset (2000);
   for (;;)
      {
      while ((c = PEEKBYTE ()) < 0)
         {
         if (!CARRIER)
            return (CARRIER_ERR);
         time_release ();

         if (timeup (args->T1))
            {
            break;
            }
         }

      if (timeup (RB1Timer))
         {
/* Report error */
         return (SENDBLOCK_ERR);
         }

      if ((c == -1) && timeup (args->T1))
         {
         CLEAR_INBOUND ();
         SENDBYTE (ENQ);
         args->T1 = timerset (200);
         continue;
         }

      c = TIMED_READ (0);

      switch (c)
         {
         case ACK:
            if (Receive_Bark_Packet (args) == 0)
               return (RB2);
            else
               return (RB0);

         case ETB:
/* Report done */
            return (SUCCESS);

         case ENQ:
            SENDBYTE (ETB);
            break;
         }
      }

}

int cdecl RBAckBark( BARKARGSP args )
{
   if (args->barkok)
      {
      SENDBYTE (ACK);
      return (RB3);
      }
   else
      {
      SENDBYTE (NAK);
      return (RB1);
      }
}

int cdecl RBWaitStrt( BARKARGSP args )
{
   int c;
   long RB3Timer;
   long RB3Timer1;

   if ( args )
   {
   }
   
   RB3Timer = timerset (1500);
   while (CARRIER && (!timeup (RB3Timer)))
      {
      RB3Timer1 = timerset (300);
      while (!timeup (RB3Timer1))
         {
         if ((c = PEEKBYTE ()) >= 0)
            break;

         time_release ();
         }

      if (c == -1)
         SENDBYTE (ACK);
      else if ((c == 'C') || (c == NAK))
         return (RB4);
      }

/* Return error */
   return (SENDBLOCK_ERR);
   /* args; */
}

int cdecl RBSendFile( BARKARGSP args )
{
   int nfiles1;
   int n_frproc (char *, int, int (*)(char *));

   nfiles1 = args->nfiles;
   if (((args->nfiles = n_frproc (args->barkpacket, args->nfiles, cdog_callback)) < 0)
      || nfiles1 == args->nfiles)
      {
      (void) Batch_Send (NULL);
      }
   else
      {
      (void) Batch_Send (NULL);
      status_line (msgtxt[M_MATCHING_FILES], args->nfiles - nfiles1);
      }

   return (RB0);
}

int SEA_recvreq( void )
{
   BARKARGS bark;

   Netmail_Session = 2;
	CLEAR_INBOUND ();
   return (state_machine (Bark_Receiver, &bark, RB0));
}

static int get_req_str( char *req )
{
   unsigned int crc, crc1, crc2, crc3;
   int i, j;

   crc = i = 0;
   while (CARRIER)
      {
      j = TIMED_READ (2);
      if (j < 0)
         return (0);

		if ((j == ACK) && (i == 0))
			{
			/* Just skip the extra ACK */
			continue;
			}

		if (i >= 100)
			{
			/* Too long of a string */
			status_line (msgtxt[M_BAD_BARK]);
			CLEAR_INBOUND ();
			return (0);
			}

      if (j == ETX)
         {
         crc1 = (unsigned) TIMED_READ (2);
         crc2 = (unsigned) TIMED_READ (2);
         crc3 = (crc2 << 8) + crc1;
         if (crc3 != crc)
            {
            status_line (msgtxt[M_BAD_CRC]);
            return (0);
            }
         req[i] = '\0';
         return (1);
         }
      else if (j == SUB)
         {
         return (0);
         }
      else
         {
         req[i++] = (char) (j & 0xff);
      	crc = xcrc (crc, (j & 0xff));
         }
      }
   return (0);
}

/*
 * gen_req_name -- take the name [time] [password] fields from
 *                 the BARK file request format and reformat to
 *                 name [!password] [+time] WaZOO format for use
 *                 by the WaZOO file request routines.
 *
 * Input:          *req = pointer to character array with Bark string
 * Output:         *req array contents reformatted
 *
 */


static void gen_req_name( char *req )
{
   char *q, *q1;
   char buf[48];
   char *fsecs = NULL;

   q = req;
   q1 = buf;

   /* Get the filename */

   while ((*q) && (!isspace (*q)))
      {
      *q1++ = *q++;
      }
   *q1 = '\0';

   /* If we have more characters, go on */

   if (*q)
      {
      /* Skip the space */
      fsecs = q++;
      *fsecs = '+';

      /* Skip the digits */

      while ((*q) && (!isspace (*q)))
         q++;

      /* If we have more, get the password */

      if (*q)
         {
         *q++ = '\0';                   /* Skip space, terminate the time */

         *q1++ = ' ';
         *q1++ = '!';
         while (*q)
            {
            *q1++ = *q++;
            }
         *q1 = '\0';
         }

      /* If we got an update time          */
      if (fsecs != NULL)
         {
         *q1++ = ' ';
         while (*fsecs)
            {
            *q1++ = *fsecs++;
            }
         *q1 = '\0';
         }
      }

   (void) strcpy (req, buf);
   return;
}

static int cdog_callback( char *reqs )
{
   return (!Batch_Send (reqs));
}
