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
/*              BinkleyTerm External Protocol Handler Module                */
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

void do_extern (cmd, prot, name)
char *cmd;                                       /* "Get" or "Send"     */
int  prot;                                       /* 1st letter of proto */
char *name;                                      /* Name of file        */
{
   int j;
   struct baud_str *i;
   char junk[100];
   char *c, *p, *m;
   FILE *ctlfile;

   for (j = 0; j < 100; j++)                     /* Make sure it's all  */
      junk[j] = '\0';                            /* zeroes...           */

   for (j = 0; j < 5; j++)
      {
      if (protos[j].first_char == (char) prot)
         break;
      }
   j = protos[j].entry;
   c = m = protocols[j];
   p = NULL;
   while (*m)                                    /* Until end of string */
      {
      if ((*m == '\\') || (*m == ':'))           /* Look for last path  */
         p = m;                                  /* Delimiter           */
      m++;
      }
   m = &junk[0];
   /* It doesn't pay to be too smart here. Dots can appear in dir names   */
   while (c != p)                                /* Copy to last '\'    */
      *m++ = *c++;
   while (*c != '.')                             /* Then to the dot     */
      *m++ = *c++;
   (void) strcat (&junk[0], ".ctl");                    /* Then add extension  */

   /*
    * At this point we have the Control File name in (junk), Now let's open
    * the file and put our good stuff in there. 
    */

   (void) unlink (junk);                                /* Delete old copies   */
   if ((ctlfile = fopen (junk, append_ascii)) == NULL)   /* Try to open it      */
      {
      status_line (msgtxt[M_NO_CTL_FILE], junk);
      return;
      }

   (void) fprintf (ctlfile, "Port %d\n", (port_ptr + 1));      /* Port n              */
   if (lock_baud && (cur_baud >= lock_baud))
      i = &max_baud;
   else i = &btypes[baud];

   (void) fprintf (ctlfile, "Modem %x %x %x %x %x\n",   /* All modem params    */
         (port_ptr + 1), i->rate_value, handshake_mask, carrier_mask, i->rate_mask);
   (void) fprintf (ctlfile, "Baud %u\n", i->rate_value);/* Baud Rate           */
   (void) fprintf (ctlfile, "%s %s\n", cmd, name);      /* Actual command      */
   (void) fclose (ctlfile);
   /* The file is now written. Turn off everything. */

   if (!share)
      MDM_DISABLE ();                            /* Turn off FOSSIL     */

#ifdef OS_2
#ifdef Snoop
   snoop_close();
#endif /* Snoop */
#endif /* OS_2  */

#ifdef NEW

	close_log();

#else

   if (status_log != NULL)
      (void) fclose (status_log);                       /* Close status log    */

#endif

   /* We're all set. Build the command and execute it. */

   c = protocols[j];
   (void) sprintf (e_input, "%s %s -p%d -b%u %s", c, c, (port_ptr + 1), i->rate_value, junk);
   b_spawn (e_input);                            /* Execute command     */

   /* Back from external protocol. Turn it all back on. */

   if (Cominit (port_ptr) != 0x1954)             /* FOSSIL back on      */
      {
      (void) printf ("\n%s\n", msgtxt[M_FOSSIL_GONE]);
      if (reset_port) exit_port();
      exit (1);
      }

#ifdef NEW

	open_log();

#else

   if (status_log != NULL)                       /* Reopen status log   */
      {
      if ((status_log = fopen (log_name, append_ascii)) == NULL)
         {
         (void) printf ("\n%s\n", msgtxt[M_NO_LOGFILE]);
         }
      }

#endif

   MDM_ENABLE (lock_baud && (btypes[baud].rate_value >= lock_baud) ? max_baud.rate_mask : btypes[baud].rate_mask);
   XON_ENABLE ();                                /* and reenable XON/XOF */
}
