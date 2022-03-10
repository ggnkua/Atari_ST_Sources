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
/*                        BinkleyTerm ANSI mapping                          */
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
#ifndef __TOS__
#include <dos.h>
#endif

#ifdef OS_2
#define INCL_DOSPROCESS
#endif

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
#include "keybd.h"
#include "sbuf.h"
#include "ascii.h"
#include "nodeproc.h"
#include "vfossil.h"

/*--------------------------------------------------------------------------*/
/*                                                                          */
/* ansi_map() -- map function key into an ANSI escape sequence if we have   */
/* one to correspond to the key. The "emulation" is VT100-type, we map the  */
/* arrow keys to the ANSI escape sequences for up, down, right and left,    */
/* and we map the function keys into the VT100 keypad, assuming application */
/* mode, like Procomm. That is, we take the VT100 keypad, split it in two   */
/* vertically, and use the F-keys to represent the left side, and the       */
/* "shifted" F-keys to represent the right side.                            */
/*                                                                          */
/*              The result, if any, is transmitted to the host.             */
/*                                                                          */
/*--------------------------------------------------------------------------*/
/* ESC Seq        IBM key       Scan code VT100 key    */

static char *ansi_seq[] = { 
   "\033OP",   /* F1            3b00      PF1          */
   "\033OQ",   /* F2            3c00      PF2          */
   "\033Ow",   /* F3            3d00      keypad '7'   */
   "\033Ox",   /* F4            3e00      keypad '8'   */
   "\033Ot",   /* F5            3f00      keypad '4'   */
   "\033Ou",   /* F6            4000      keypad '5'   */
   "\033Oq",   /* F7            4100      keypad '1'   */
   "\033Or",   /* F8            4200      keypad '2'   */
   "\033Op",   /* F9            4300      keypad '0'   */
   "\033Op",   /* F10           4400      keypad '0'   */
   "",         /*               4500                   */
   "",         /*               4600                   */
   "",         /*               4700                   */
   "\033[A",   /* Up Arrow      4800      Up Arrow     */
   "",         /*               4900                   */
   "",         /*               4a00                   */
   "\033[D",   /* Left Arrow    4b00      Left Arrow   */
   "",         /*               4c00                   */
   "\033[C",   /* Right Arrow   4d00      Right Arrow  */
   "",         /*               4e00                   */
   "",         /*               4f00                   */
   "\033[B",   /* Down Arrow    5000      Down Arrow   */
   "",         /*               5100                   */
   "",         /*               5200                   */
   "",         /*               5300                   */
   "\033OR",   /* Shift-F1      5400      PF3          */
   "\033OS",   /* Shift-F2      5500      PF4          */
   "\033Oy",   /* Shift-F3      5600      keypad '9'   */
   "\033Om",   /* Shift-F4      5700      keypad '-'   */
   "\033Ov",   /* Shift-F5      5800      keypad '6'   */
   "\033Ol",   /* Shift-F6      5900      keypad ','   */
   "\033Os",   /* Shift-F7      5a00      keypad '3'   */
   "\033OM",   /* Shift-F8      5b00      keypad 'Enter' */
   "\033On",   /* Shift-F9      5c00      keypad '.'   */
   "\033OM",   /* Shift-F10     5d00      keypad 'Enter' */
   ""
};

void ansi_map( unsigned int ScanVal )
{
   register KeyCode;
   register char *s;

   KeyCode = ScanVal >> 8;                       /* Isolate to key scan code */
   if ((KeyCode < 0x3b) || (KeyCode > 0x5d))
      return;                                    /* Not in range, give up    */
   s = ansi_seq[KeyCode - 0x3b];                 /* Index to our sequence    */
   SENDCHARS (s, strlen (s), 0);                 /* Send the mapped string   */
}

int term_overlay( int k )
{
   int c;
   long t1;

         switch (k)
            {
            case ALTB:
               ++baud;
               if (!btypes[baud].rate_value)
                  baud = 0;
               MDM_ENABLE (lock_baud && (btypes[baud].rate_value >= lock_baud) ? max_baud.rate_mask : btypes[baud].rate_mask);
               cur_baud = btypes[baud].rate_value;
               scr_printf (msgtxt[M_BINK_NOW_AT]);
               (void) sprintf (junk, "%u baud.\r\n", btypes[baud].rate_value);
               scr_printf (junk);
               break;

            case ALTC:
               scr_printf ("\r\n7 or 8 data bits? ");
               (void) fgets (junk, 100, stdin);
               comm_bits = (atoi (junk) == 7) ? BITS_7 : BITS_8;
               if (comm_bits == BITS_8)
                  {
                  parity = NO_PARITY;
                  }
               else
                  {
                  scr_printf ("(E)ven, (O)dd, or (N)o parity? ");
                  (void) fgets (junk, 100, stdin);
                  (void) strupr (junk);
                  parity = (junk[0] == 'E') ? EVEN_PARITY :
                     ((junk[0] == 'O') ? ODD_PARITY : NO_PARITY);
                  }
               scr_printf ("1 or 2 stop bits? ");
               (void) fgets (junk, 100, stdin);
               stop_bits = (atoi (junk) == 1) ? STOP_1 : STOP_2;

               MDM_ENABLE (lock_baud && (btypes[baud].rate_value >= lock_baud) ? max_baud.rate_mask : btypes[baud].rate_mask);
               break;

            case ALTD:
               scr_printf (msgtxt[M_PHONE_OR_NODE]);
               if (!get_number (junk))
                  break;
               if (strchr (junk, '/') != NULL)
                  {
                  if (nodeproc (junk))
                     {
                     (void) strcpy (junk, (char *) (newnodedes.PhoneNumber));
                     do_dial_strings ();
                     }
                  else break;
                  }
               caller = 0;
               try_2_connect (junk);             /* try to connect         */
               gong ();
               break;

				case ALTE:
	            screen_clear ();
					break;

            case ALTH:
               t1 = timerset (300);
               while (CARRIER)
                  if (timeup (t1))
                     {
                     scr_printf (msgtxt[M_NO_DROP_DTR]);
                     break;
                     }
                  else
                     {
#ifdef NEW /* FASTMODEM  10.09.1989 */
                     hang_up ();
#else
                     DTR_OFF ();
#endif
                     }
               status_line (msgtxt[M_END_OF_CONNECT]);
               DTR_ON ();
               break;

				case ALTI:
					mdm_init (term_init);
					break;

#if 0	/* oho! We want escape to get processed! */
			case ESC:
				sb_popup(10,1,2,78, do_shell, 1);
				break;
#endif
            case ALTJ:
               scr_printf ("\r\n");
               scr_printf (&(msgtxt[M_SHELLING][1]));
               scr_printf (msgtxt[M_TYPE_EXIT]);
               MDM_DISABLE ();
               change_prompt ();
               b_spawn (NULL);
               /* Re-enable ourselves */
               if (Cominit (port_ptr) != 0x1954)
                  {
                  (void) printf ("\r\n%s\r\n", msgtxt[M_FOSSIL_GONE]);
                  if (reset_port) exit_port();
                  exit (1);
                  }
               scr_printf (msgtxt[M_WELCOME_BACK]);
               DTR_ON ();
               MDM_ENABLE (lock_baud && (btypes[baud].rate_value >= lock_baud) ? max_baud.rate_mask : btypes[baud].rate_mask);
               break;

            case ALTP:
               c = port_ptr;
               if (++port_ptr == MAXport)
                  port_ptr = 0;
               MDM_DISABLE ();
               if (Cominit (port_ptr) != 0x1954)
                  {
                  port_ptr = c;
                  (void) Cominit(port_ptr);
                  }
               MDM_ENABLE (lock_baud && (btypes[baud].rate_value >= lock_baud) ? max_baud.rate_mask : btypes[baud].rate_mask);
               DTR_ON ();
               scr_printf (msgtxt[M_BINK_NOW_USING]);
               WRITE_ANSI (port_ptr + '1');
               scr_printf (":\r\n");
               XON_ENABLE ();
               break;

            case ALTS:
#ifndef ATARIST
               if (old_fossil)
                  {
                  scr_printf (msgtxt[M_NO_BREAK]);
                  }
               else
#endif
                  {
                  scr_printf (msgtxt[M_SENDING_BREAK]);
                  send_break (100);
                  scr_printf (msgtxt[M_DONE]);
                  }
               break;

            case ALTV:
               screen_clear();
               scr_printf (msgtxt[M_YOU_ARE_USING]);
               scr_printf (ANNOUNCE);
               scr_printf ("\r\n");
               scr_printf (ver_stuff);
#ifdef NEW
			   scr_printf("Thanks to everyone for their bug reports and suggestions, including:\r\n");
			   scr_printf("  Bernd Renzing, Rinaldo Visscher, Johan Ansems, Theo Runia, Jon Webb,\r\n");
			   scr_printf("  Albi Rebmann, Udo Erdelhoff, David Thomas, Joop Koopman, Joerg Spilker,\r\n");
			   scr_printf("  Daron Brewood, Phil Gadsby, Alexander Bochmann, John Graham,\r\n");
			   scr_printf("  Stephan Slabihoud, etc...\r\n");
			   scr_printf("And of course thanks to the Binkley Trio (Vince Perriello, Bob Hartman\r\n");
			   scr_printf("and Alan Applegate) for creating BinkleyTerm in the first place!\r\n\r\n");
			   scr_printf("- STeVeN.   My Little Phoney BBS, +44-793-849044\r\n");
			   scr_printf("            FidoNet 2:255/355, NeST 90:1004/1004\r\n");
			   scr_printf("            sgreen@cix.compulink.co.uk\r\n\r\n");
#endif
               break;

            case ALTF1:
            case ALTF2:
            case ALTF3:
            case ALTF4:
            case ALTF5:
            case ALTF6:
            case ALTF7:
            case ALTF8:
            case ALTF9:
#if N_SHELLS >= 10
			case ALTF10:
#endif
               c = ((unsigned) k >> 8) - 0x68;
               if (keys[c] != NULL)
                  {
                  SENDCHARS (keys[c], strlen (keys[c]), 0);
                  }
               break;

            default:
               return (1);
            }

   return (0);
}

