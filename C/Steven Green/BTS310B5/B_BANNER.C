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
/*          This module was originally written by Vince Perriello           */
/*                                                                          */
/*                                                                          */
/*                       BinkleyTerm Opening Banner                         */
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
#include <string.h>
#include <stdlib.h>

#include "bink.h"
#include "msgs.h"
#include "com.h"
#include "vfossil.h"
#include "sbuf.h"
#include "externs.h"
#include "prototyp.h"

#ifdef MULTITASK

static void mtask_find ()
{
   unsigned char buff[80];
   int fs1, fs2;

   fs1 = fullscreen && (un_attended || doing_poll);
   fs2 = (!fullscreen) || !(un_attended || doing_poll);

   if (fs2)
      {
      scr_printf (msgtxt[M_MULTI_TASKER]);
      }

#if defined(ATARIST)
		/* Multi-tasking on the ST???? What will they think of next */
		/* No seriously, I suppose I could provide support for the */
		/* Beckemeyer shell and anything else */
       (void) strcpy ((char *) buff, "None");
#elif !defined(OS_2)
   if ((have_dv = dv_get_version ()) != 0)
      {
      (void) sprintf ((char *) buff, "DESQview");
      }
	else if ((have_mos = mos_active ()) != 0)
      {
     	(void) sprintf ((char *) buff, "PC-MOS");
      }
   else if ((have_ddos = ddos_active ()) != 0)
      {
      (void) strcpy ((char *) buff, "DoubleDOS");
      }
   else if (have_ml)
      {
      if ((have_ml = ml_active ()) != 0)
         {
         (void) strcpy ((char *) buff, "MultiLink");
         }
      else
         {
         (void) strcpy ((char *) buff, "None");
         }
      }
   else if (have_tv)
      {
      if ((have_tv = tv_get_version ()) != 0)
         {
         (void) strcpy ((char *) buff, "T-View");
         }
      else
         {
         (void) strcpy ((char *) buff, "None");
         }
      }
   else
      {
      (void) strcpy ((char *) buff, "None");
      }

#else /* ifndef OS_2 */
   if (_osmode == DOS_MODE)
       (void) strcpy ((char *) buff, "None");
   else
       (void) strcpy ((char *) buff, "OS/2");
#endif

   if (!fs1)
       strcat ((char *) buff, "\r\n");

   if (fs2)
      {
      scr_printf ((char *) buff);
      }
   else
      {
      sb_move (settingswin, SET_TASK_ROW, 2);
      sb_puts (settingswin, "                   ");
      sb_move (settingswin, SET_TASK_ROW, 2);
      sb_puts (settingswin, (unsigned char *) "M'Task: ");
      sb_puts (settingswin, buff);
      }
}

#endif

void opening_banner ()
{
   char bd[10];

   if (!fullscreen || !un_attended)
      {
      screen_clear ();
      scr_printf (ANNOUNCE);
      scr_printf ("\r\nA Freely Available<tm> Dumb Terminal and FidoNet Mail Package\r\n");
      scr_printf (msgtxt[M_SETTING]);
      scr_printf (" COM");
      WRITE_ANSI (port_ptr + '1');
      WRITE_ANSI (':');
      scr_printf (msgtxt[M_INITIAL_SPEED]);
      (void) sprintf (bd, "%u", max_baud.rate_value);
      scr_printf (bd);
      scr_printf (msgtxt[M_INTRO_END]);
      }

#ifndef ATARIST
   fossil_ver ();
#endif

#ifdef MULTITASK
   mtask_find ();
#endif
}


