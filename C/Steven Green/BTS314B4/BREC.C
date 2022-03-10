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
/*                 BinkleyTerm Batch Receiver State Machine                 */
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
#ifndef __TOS__
#include <fcntl.h>
#endif
#include <stdio.h>
#include <string.h>

#ifdef __TURBOC__
#ifdef __TOS__
/* #pragma warn -sus */
#include <stdlib.h>
#else
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

#include "bink.h"
#include "msgs.h"
#include "com.h"
#include "sbuf.h"
#include "defines.h"
#include "ascii.h"
#include "vfossil.h"

int cdecl BRInit (XMARGSP args, int start_state);
int cdecl BREnd (XMARGSP args, int cur_state);
int cdecl BRTestSL (XMARGSP args);
int cdecl BRCheckSL (XMARGSP args);
int cdecl BRCheckFNm (XMARGSP args);
int cdecl BRCheckFile (XMARGSP args);
int cdecl BRFindType (XMARGSP args);

STATES Batch_Receiver[] = {
   { "BRInit", ( void *) BRInit },
   { "BREnd", ( void *) BREnd },
   { "BR0", ( void *) BRTestSL },
   { "BR1", ( void *) BRCheckSL },
   { "BR2", ( void *) BRCheckFNm },
   { "BR3", ( void *) BRCheckFile },
   { "BR4", ( void *) BRFindType },
};

int cdecl BRInit (XMARGSP args, int start_state)
{
   XON_DISABLE ();
   args->filename = calloc ( 1, 14 );
   return (start_state);
}

int cdecl BREnd (XMARGSP args, int cur_state)
{
   free (args->filename);
   return (cur_state);
}

int cdecl BRTestSL (XMARGSP args)
{
   if (!no_sealink)
      SENDBYTE (WANTCRC);

   args->T1 = timerset (1000);
   args->T2 = timerset (12000);

   return (BR1);
}

int cdecl BRCheckSL (XMARGSP args)
{
   long BR1Timer;

   BR1Timer = timerset (200);
   while (!timeup (BR1Timer))
      {
      if (timeup (args->T2) || no_sealink)
         {
         args->result = Modem7_Receive_File (args->filename);
         return (BR2);
         }
      if ((args->CHR = PEEKBYTE ()) >= 0)
         {
         return (BR4);
         }
      if (timeup (args->T1))
         {
         args->result = Modem7_Receive_File (args->filename);
         return (BR2);
         }
      else
         {
         if (!CARRIER)
            return (CARRIER_ERR);
         else
            time_release ();
         }
      }

   SENDBYTE (WANTCRC);
   return (BR1);
}

int cdecl BRCheckFNm (XMARGSP args)
{
   char buff1[20];
   char *p;
   int i;

   (void) memset (buff1, 0, 19);

   /* Was it the last file */
#ifdef NEW	/* SWG: 9th July 1991 : I think is wrong.. it stops FTS receiver from sending! */
	if(args->result == SUCCESS_EOT)
#else
   if (args->result == EOT_RECEIVED)
#endif
      {
      return (SUCCESS);
      }
   /* Did we get a valid filename */
   else if (args->result == SUCCESS)
      {
      /* First set up the filename buffer */
      p = buff1;
      for (i = 0; i < 8; ++p, i++)
         {
         if (args->filename[i] != ' ')
            {
            *p = args->filename[i];
            }
         else
            break;
         }

      *p = '.';
      ++p;
      *p = '\0';
      for (i = 8; i < 11; ++p, i++)
         {
         if (args->filename[i] != ' ')
            {
            *p = args->filename[i];
            }
         else
            break;
         }
      *p = '\0';
      (void) strcpy (args->filename, buff1);
      args->result = Xmodem_Receive_File (args->path, args->filename);
      return (BR3);
      }
   /* Otherwise, we have to exit */
   else
      return (args->result);
}

int cdecl BRCheckFile (XMARGSP args)
{
   /* Was the file transfer good */
   if ((args->result == SUCCESS) || (args->result == SUCCESS_EOT))
      {
      return (BR0);
      }
   else
      {
      return (args->result);
      }
}

int cdecl BRFindType (XMARGSP args)
{
   switch (args->CHR)
      {
      case NUL:
         (void) TIMED_READ (0);
         args->T1 = timerset (2000);
         return (BR1);

      case SOH:
      case SYN:
         args->result = Batch_Xmodem_Receive_File (args->path, args->filename);
         return (BR3);

      case EOT:
         (void) TIMED_READ (0);
         SENDBYTE (ACK);
         return (SUCCESS);

      default:
         (void) TIMED_READ (0);
         return (BR1);
      }

}

int Batch_Receive (char *where)
{
   XMARGS batch;
   int res;

   batch.result = 0;
   batch.path = where;
   res = state_machine (Batch_Receiver, &batch, 2);
   return (res);
}
