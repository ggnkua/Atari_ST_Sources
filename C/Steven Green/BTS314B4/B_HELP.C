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
/*                       BinkleyTerm "HELP" Module                          */
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

#include "bink.h"
#include "msgs.h"
#include "com.h"
#include "keybd.h"

void main_help (void)
{
   char *c;
   int i;
   char j[100];

   screen_clear ();
   for (i = M_MAIN_HELP; i <= M_MAIN_HELP_LAST; i++)
      scr_printf (msgtxt[i]);

   for (i = 0; i < N_SHELLS; i++)
      {
      if (keys[i] != NULL)
         {
         c = keys[i];
         while (*c && (*c != '\n'))
            {
            if (*c == '\r')
               *c = '|';
            ++c;
            }

         (void) sprintf (j, msgtxt[M_MACRO_HELP], i + 1, keys[i]);
         scr_printf (j);

         c = keys[i];
         while (*c && (*c != '\n'))
            {
            if (*c == '|')
               *c = '\r';
            ++c;
            }
         }
      }

   scr_printf (msgtxt[M_PRESS_ANYKEY]);
   (void) FOSSIL_CHAR ();
   scr_printf ("\r\n");
}

void mailer_help (void)
{
   int i;
   char j[100];

   screen_clear ();
   for (i = M_MAILER_HELP; i <= M_MAILER_HELP_LAST; i++)
      scr_printf (msgtxt[i]);

   if (do_screen_blank)
      {
      scr_printf (msgtxt[M_BLANK_HELP]);
      }
      
   if (BBSreader != NULL)
      {
      sprintf (j, msgtxt[M_EDITOR_HELP], BBSreader);
      scr_printf (j);
      }

   for (i = 0; i < N_SHELLS; i++)
      {
      if (shells[i] != NULL)
         {
         (void) sprintf (j,msgtxt[M_SHELL_HELP], i + 1, shells[i]);
         scr_printf (j);
         }
      }

   scr_printf (msgtxt[M_PRESS_ANYKEY]);
   FOSSIL_CHAR ();
   scr_printf ("\r\n");
}
