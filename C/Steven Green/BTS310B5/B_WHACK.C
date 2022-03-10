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
#include <ctype.h>
#include <conio.h>
#include <string.h>

#include "bink.h"
#include "msgs.h"
#include "sbuf.h"
#include "com.h"

int Whack_CR ()
{
   long t1, t2;
   unsigned char j;
   char m;
   int l;
   unsigned int i;
   char buf[180];

#ifdef NEW /* FASTMODEM  07/16/90 07:45pm */
	t1 = timerset (1000);
#else
   t1 = timerset (3000);                         /* set 30 second timeout */
#endif
   j = CR;
   (void) strcpy (buf, msgtxt[M_INTRO]);
   l = (int) strlen (buf);
   m = 0;
   while (!timeup (t1) && CARRIER)               /* till then or CD lost  */
      {

      /* Send either the CR or SPACE */
      SENDBYTE (j);

      /* Now switch to either CR or SPACE based on last output */

      j = (unsigned char) (' '+'\r' - j);

      /* Now read what we get back to see if we get anything useful */
      while (((i = (unsigned) TIMED_READ (0)) != (unsigned int)EOF) && (!timeup (t1)) && CARRIER)
         {
         if (i == CR)
            {
            if (m)
               {
               if (un_attended && fullscreen)
                  {
                  clear_filetransfer ();
                  sb_move (filewin, 1, 2);
                  sb_puts (filewin, (unsigned char *) buf);
                  sb_show ();
                  status_line ("*%s", buf);
                  }
               else
                  {
                  set_xy (NULL);
                  scr_printf (buf);
                  }
               /* We got what we wanted */
               /* Now try to stop output on an Opus */
               SENDBYTE ('');
               return (0);
               }
            }
         else if (i >= ' ')
            {
            buf[l++] = (char) (i & 0xff);
            buf[l] = '\0';
            if (l > SB_COLS - 6)
               l = SB_COLS - 6;
            m = 1;
            }
         }

      /* Delay for a second */
      t2 = timerset (100);
      while (!timeup (t2))
         time_release ();
      }

   if (CARRIER)
#ifdef NEW /* NOBODY  07/16/90 07:46pm */
      {
      status_line ("%s (ignored)", msgtxt[M_NOBODY_HOME]);
      return (0);           /* just ignore the possible problems */
      }                     /* 'cause this happens far too often  -  JCE */
#else                       
      status_line (msgtxt[M_NOBODY_HOME]);
#endif
   else
      status_line (msgtxt[M_NO_CARRIER]);
   return (-1);
}
