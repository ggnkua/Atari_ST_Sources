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
/*                  BinkleyTerm Batch Sender State Machine                  */
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
#ifdef __TOS__
/* #pragma warn -sus */
#else
#include <fcntl.h>
#endif
#include <stdio.h>


#include "bink.h"
#include "msgs.h"
#include "com.h"
#include "sbuf.h"
#include "defines.h"
#include "ascii.h"
#include "vfossil.h"


#define NO_SEALINK_IS_TELINK 1

int cdecl BSInit (XMARGSP args, int start_state);
int cdecl BSEnd (XMARGSP args, int cur_state);
int cdecl BSMoreFiles (XMARGSP args);
int cdecl BSWaitType (XMARGSP args);
int cdecl BSCheckFNm (XMARGSP args);
int cdecl BSCheckFile (XMARGSP args);
int cdecl BSEndSend (XMARGSP args);

STATES Batch_Sender[] = {
   { "BSInit", ( void *) BSInit },
   { "BSEnd", ( void *) BSEnd },
   { "BS0", ( void *) BSMoreFiles },
   { "BS1", ( void *) BSWaitType },
   { "BS2", ( void *) BSCheckFNm },
   { "BS3", ( void *) BSCheckFile },
   { "BS4", ( void *) BSEndSend  },
};

int cdecl BSInit (XMARGSP args, int start_state)
{
   args->result = start_state;
   XON_DISABLE ();
   return (start_state);
}

int cdecl BSEnd (XMARGSP args, int cur_state)
{
   args->result = cur_state;
   return (cur_state);
}

int cdecl BSMoreFiles (XMARGSP args )
{
   if (args->filename != NULL)
      {
      /* BS0.1 */
      return (BS1);
      }
   else
      {
      /* BS0.2 */
      return (BS4);
      }
}

int cdecl BSWaitType (XMARGSP args)
{
   long BS1Timer;
   int in_char;

   BS1Timer = timerset (2000);
   while (!timeup (BS1Timer))
      {
      if ((in_char = PEEKBYTE ()) >= 0)
         {
         switch (in_char)
            {
            case NAK:
               /* State BS1.1 */
               args->result = Modem7_Send_File (args->filename);
               return (BS2);

            case WANTCRC:
               /* State BS1.2 */
               if (!no_sealink)
                  {
                  args->result = SEAlink_Send_File (args->filename, NULL);
                  return (BS3);
                  }
#ifdef NO_SEALINK_IS_TELINK
               else
                  {
                  args->result = Telink_Send_File (args->filename, NULL);
                  return (BS3);
                  }
#endif
               /* Fallthrough if we aren't doing SEAlink */

            default:
               /* State BS1.3 */
               (void) TIMED_READ (0);
               time_release ();
            }
         }
      else
         {
         if (!CARRIER)
            return (CARRIER_ERR);
         else
            time_release ();
         }
      }

   /* State BS1.4 */
   return (TIME_ERR);
}

int cdecl BSCheckFNm (XMARGSP args)
{
   if (args->result == SUCCESS)
      {
      /* State BS2.1 */
      args->result = Telink_Send_File (args->filename, NULL);
      return (BS3);
      }
   else
      {
      /* State BS2.2 */
      return (FNAME_ERR);
      }
}

int cdecl BSCheckFile (XMARGSP args)
{
   return (args->result);
}

int cdecl BSEndSend ( XMARGSP args )
{
   long BS4Timer;

   BS4Timer = timerset (1000);
   while (!timeup (BS4Timer))
      {
      switch (TIMED_READ (1))
         {
         case NAK:
         case WANTCRC:
            SENDBYTE (EOT);
            args->result = SUCCESS;
            return (SUCCESS);
         }
      }

   /* State BS4.2 */
   SENDBYTE (EOT);
   args->result = SUCCESS;
   return (SUCCESS);
}

int Batch_Send (char *filename)
{
   XMARGS batch;
   int res;

   batch.result = 0;
   batch.filename = filename;
   res = state_machine (Batch_Sender, &batch, 2);
   return (res);
}
