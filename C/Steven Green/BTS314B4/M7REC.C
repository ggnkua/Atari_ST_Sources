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
/*                BinkleyTerm Modem7 Receiver State Machine                 */
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

int cdecl MRInit( XMARGSP args, int start_state );
int cdecl MREnd( XMARGSP args, int cur_state );
int cdecl MRSendNak( XMARGSP args );
int cdecl MRWaitAck( XMARGSP args );
int cdecl MRWaitChar( XMARGSP args );
int cdecl MRWaitOkCk( XMARGSP args );


STATES Modem7_Receiver[] = {
   { "MRInit", (void *) MRInit },
   { "MREnd", (void *) MREnd },
   { "MR0",  (void *)MRSendNak },
   { "MR1",  (void *)MRWaitAck },
   { "MR2",  (void *)MRWaitChar },
   { "MR3",  (void *)MRWaitOkCk }
};

int cdecl MRInit( XMARGSP args, int start_state )
{
   args->tries = 0;
   return (start_state);
}

int cdecl MREnd( XMARGSP args, int cur_state )
{
   args->result = cur_state;
   return (cur_state);
}

int cdecl MRSendNak( XMARGSP args )
{
   if (args->tries >= 10)
      return (FNAME_ERR);

   args->fptr = args->filename;

   SENDBYTE (NAK);
   ++(args->tries);
   return (MR1);
}

int cdecl MRWaitAck( XMARGSP args )
{
   long MR1Timer;
   int in_char;

   MR1Timer = timerset (1000);
   while (!timeup (MR1Timer))
      {
      if ((in_char = PEEKBYTE ()) >= 0)
         {
         (void) TIMED_READ (0);
         switch (in_char)
            {
            case ACK:
               return (MR2);

            case EOT:
               args->result = SUCCESS_EOT;
               return (SUCCESS_EOT);
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

   return (MR0);
}

int cdecl MRWaitChar( XMARGSP args )
{
   int in_char;
   unsigned char check;
   char *p;

   in_char = TIMED_READ (10);
   switch (in_char)
      {
      case -1:
         return (MR0);

      case EOT:
         return (SUCCESS);

      case SUB:
         for (p = args->filename, check = SUB; p != args->fptr; p++)
            check += (unsigned char) *p;
         SENDBYTE (check);
         return (MR3);

      case 'u':
         return (MR0);

      default:
         *args->fptr++ = (char) (in_char & 0xff);
         SENDBYTE (ACK);
         return (MR2);
      }

}

int cdecl MRWaitOkCk( XMARGSP args )
{
   int in_char;

   in_char = TIMED_READ (10);
   if (in_char == ACK)
      {
      args->result = SUCCESS;
      return (SUCCESS);
      }
   
   return (MR0);
}

int Modem7_Receive_File( char *filename )
{
   XMARGS batch;
   int res;

   batch.result = 0;
   batch.filename = filename;
   res = state_machine (Modem7_Receiver, &batch, 2);
   return (res);
}
