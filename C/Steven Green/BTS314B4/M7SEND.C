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
/*                 BinkleyTerm Modem7 Sender State Machine                  */
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
#include <string.h>
#include <ctype.h>

#include "bink.h"
#include "msgs.h"
#include "com.h"
#include "sbuf.h"
#include "defines.h"
#include "ascii.h"
#include "vfossil.h"

static int cdecl MSInit( XMARGSP args, int start_state );
static int cdecl MSEnd( XMARGSP args, int cur_state );
static int cdecl MSWaitNak( XMARGSP args );
static int cdecl MSWaitChAck( XMARGSP args );
static int cdecl MSWaitCksm( XMARGSP args );

STATES Modem7_Sender[] = {
   { "MSInit", (void *) MSInit },
   { "MSEnd",  (void *)MSEnd },
   { "MS0",  (void *)MSWaitNak },
   { "MS1",  (void *)MSWaitChAck },
   { "MS2",  (void *)MSWaitCksm }
};

static int cdecl MSInit( XMARGSP args, int start_state )
{
   char *p;
   int i;
   struct FILEINFO dta;

   XON_DISABLE ();
   args->tries = 0;
   (void) dfind (&dta, args->filename, 0);
   (void) strcpy (args->m7name, "           ");
   for (i = 0, p = dta.name; i < 8; p++, i++)
      if ((*p != '.') && (*p != '\0'))
         args->m7name[i] = toupper(*p);
      else
         break;

   if (*p == '.')
      ++p;
   for (i = 8; i < 11; p++, i++)
      if ((*p != '.') && (*p != '\0'))
         args->m7name[i] = toupper(*p);
      else
         break;

   /* Now do the checksum */
   args->check = SUB;
   for (i = 0; i < 11; i++)
      args->check += (unsigned char) args->m7name[i];

   return (start_state);
}

static int cdecl MSEnd( XMARGSP args, int cur_state )
{
   args->result = cur_state;
   return (cur_state);
}

static int cdecl MSWaitNak( XMARGSP args )
{
   if (args->tries >= 10)
      return (FNAME_ERR);

   if (!CARRIER)
      return (CARRIER_ERR);

   if (TIMED_READ (10) != NAK)
      {
      ++args->tries;
      return (MS0);
      }

   SENDBYTE (ACK);
   SENDBYTE ((unsigned char) *(args->m7name));
   args->fptr = args->m7name + 1;
   return (MS1);
}

static int cdecl MSWaitChAck( XMARGSP args )
{
   if (!CARRIER)
      return (CARRIER_ERR);

   if (TIMED_READ (10) != ACK)
      {
      ++args->tries;
      SENDBYTE ('u');
      return (MS0);
      }

   /* If filename done */
   if (*(args->fptr) == '\0')
      {
      SENDBYTE (SUB);
      return (MS2);
      }
   else
      {
      /* Send next char of name */
      SENDBYTE ((unsigned char) *args->fptr++);
      return (MS1);
      }
}

static int cdecl MSWaitCksm( XMARGSP args )
{
   int in_char;

   if (!CARRIER)
      return (CARRIER_ERR);

   if (((in_char = TIMED_READ (10)) < 0) || (in_char != args->check))
      {
      SENDBYTE ('u');
      ++args->tries;
      return (MS0);
      }
   else
      {
      SENDBYTE (ACK);
      return (SUCCESS);
      }
}

int Modem7_Send_File( char *filename )
{
   XMARGS batch;
   int res;

   batch.result = 0;
   batch.filename = filename;
   res = state_machine (Modem7_Sender, &batch, 2);
   return (res);
}
