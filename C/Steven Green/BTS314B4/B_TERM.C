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
#ifdef __TOS__
#include <ext.h>
#else
#include <dos.h>
#endif

#ifdef OS_2
#define INCL_DOSPROCESS
#endif

#ifdef __TURBOC__
#ifndef __TOS__
#include <alloc.h>
#include <dir.h>
#endif
#else
#ifndef LATTICE
#include <malloc.h>
#endif
#endif

#include "bink.h"
#include "msgs.h"
#include "sbuf.h"
#include "keybd.h"
#include "vfossil.h"
#include "com.h"
#include "zmodem.h"
#include "nodeproc.h"

int b_term( void )
{
   int k;
   int c;
   int done;
   unsigned save1, save2, save3;
   char *autodl = "**\030B00";                   /* Zmodem autodl str.  */
   char *search_autodl = autodl;
   FILE *logfile = NULL;                         /* log file stream
                                                  * descriptor */
   char prot;
   char *p;                                      /* Used for external
                                                  * protocol */
   int retval = 1;                               /* What to tell the mainline */
   int err;
   ADDR baddr;

#ifdef OS_2
   struct FILEINFO fileinfo;
#else
#ifdef __TURBOC__
   struct ffblk fileinfo;
#else
#ifdef LATTICE
   struct FILEINFO fileinfo;
#else
   struct find_t fileinfo;
#endif
#endif
#endif

   set_prior(4);                                    /* Always High */
   vfossil_cursor (1);
   done = 0;
	first_block = 0;
	if ((term_init != NULL) && (!CARRIER))
		{
      (void) set_baud (max_baud.rate_value, 0);
	   mdm_cmd_string (term_init, 0);                /* then the modem init
   	                                               * string */
		}

   while (!done)
      {
      c = -1;
      if (CHAR_AVAIL ())
         {
         c = MODEM_IN ();

         if (comm_bits == BITS_7)
            c &= 0x7f;

         /* Check for Zmodem AutoDownload sequence */
         if ((c & 0x7f) == *search_autodl)
            {
            if (!*++search_autodl)
               {
               scr_printf (msgtxt[M_ZMODEM_STARTED]);
               CLEAR_INBOUND();

               save1 = comm_bits;
               save2 = parity;
               save3 = stop_bits;
               comm_bits = BITS_8;
               parity = NO_PARITY;
               stop_bits = STOP_1;
               MDM_ENABLE (lock_baud && (btypes[baud].rate_value >= lock_baud) ? max_baud.rate_mask : btypes[baud].rate_mask);
               XON_DISABLE ();

               (void) get_Zmodem (download_path, NULL);
               comm_bits = save1;
               parity = save2;
               stop_bits = save3;
               MDM_ENABLE (lock_baud && (btypes[baud].rate_value >= lock_baud) ? max_baud.rate_mask : btypes[baud].rate_mask);
               XON_ENABLE ();

               scr_printf (msgtxt[M_ZMODEM_FINISHED]);
               search_autodl = autodl;
               }
            }
         else search_autodl = autodl;

/*
 * I really don't like looking for this piece of crap, but people
 * seem to really want it, so I guess I lose.  Now if only
 * QuickBBS would do things that were ANSI compatible - ugh!
 */
         if (c == '')
            {
            screen_clear ();
            }
         else if ((c == ENQ) && (answerback != NULL))
            {
            mdm_cmd_string (answerback, 1);
            }
         else
            {
            WRITE_ANSI (c);
            }

         if (logfile != NULL)
            {
#if 1
			fputc(c, logfile);
#else
			/* This assumed byte ordering!!! */
            (void) fwrite (&c, 1, 1, logfile);
#endif
            
            }
         }
      if (KEYPRESS () || ctrlc_ctr)
         {
         c = 0;
         if (ctrlc_ctr)
            {
            /* We got a ^C, so output it properly */
            while (KEYPRESS ())                  /* Flush keyboard buffer */
               (void) FOSSIL_CHAR ();
            ctrlc_ctr = 0;
            while (Com_Tx_NW (3) == 0)
               ;
            continue;
            }
         k = (int) FOSSIL_CHAR ();
         if (term_overlay (k))
            {
            switch (k)
               {
               case ALTL:
                  if (logfile != NULL)
                     {
                     (void) fclose (logfile);
                     logfile = NULL;
                     sprintf (junk, msgtxt[M_LOG_CLOSED], capturename);
                     scr_printf(junk);
                     break;
                     }

                  if ((logptr == NULL) || (*logptr == '\0'))
                     {
                     scr_printf (msgtxt[M_INPUT_LOGFILE]);
                     (void) fgets (capturename, 100, stdin);
                     if (( k = (int) strlen (capturename)) > 0 )
                        capturename[--k] = '\0'; /* no '\n' */
                     }
                  else
                     {
                     (void) strcpy (capturename, logptr);
                     k = 1;
                     }
                  if (k)
                     {
                     logfile = fopen (capturename, append_binary);
                     if (logfile == NULL)
                        sprintf (junk, msgtxt[M_LOG_NOT_OPEN], capturename);
                     else
                        sprintf (junk, msgtxt[M_LOG_OPEN], capturename);
                     scr_printf(junk);
                     }
                  break;

                case ALTY:
#ifdef MULTIPOINT
					baddr = alias[0].ad;	/* Make up our Boss's address */
					baddr.Point = 0;
#else
                  baddr = boss_addr.ad;
#endif
                  goto polling;

                case ALTM:
                  scr_printf ("\n");
                  scr_printf (msgtxt[M_ENTER_NET_NODE]);
                  if (!get_number (junk))
                     break;
                  if ((!find_address (junk, &baddr))
					   || (baddr.Net < 1)
                  || (baddr.Node < 1)
                  || (!nodefind (&baddr,1)))
                     {
#ifdef NEW	/* SWG: 7 July 1991 : extra %s */
					printf("\n");
					printf(&msgtxt[M_NO_ADDRESS][1], junk);
					printf("\n");
#else
                     (void) printf ("\n%s '%s'\n", &(msgtxt[M_NO_ADDRESS][1]), junk);
#endif
                     break;
                     }
                  if (!baddr.Zone)
                     baddr.Zone = found_zone;
polling:
                  un_attended = 1;
                  if (fullscreen)
                     {
                     sb_dirty ();
                     opening_banner ();
                     mailer_banner ();
                     sb_fill (holdwin, ' ', colors.hold);
                     sb_move (holdwin, 2, 12);
                     sb_puts (holdwin, msgtxt[M_POLLING_COLON]);
                     (void) sprintf (junk, "%s", Pretty_Addr_Str (&baddr));
                     junk[28] = '\0';
                     sb_move (holdwin, 4, 16 - (int) strlen (junk) / 2);
                     sb_puts (holdwin, (unsigned char *) junk);
                     sb_show ();
                     }
                  else
                     {
                     scr_printf (msgtxt[M_MAILER_MODE]);
                     }
                  if (!CARRIER)
                     mdm_hangup ();
                  (void) do_mail (&baddr, 1);
                  un_attended = 0;
                  if (fullscreen)
                     {
                     screen_clear ();
                     }
                  else
                     {
                     scr_printf ("\r\n");
                     }
                  scr_printf (msgtxt[M_MANUAL_MODE]);
                  gong ();
                  vfossil_cursor (1);
                  break;

               case ALTR:
                  if (!list_search ())
                     screen_clear ();
                  break;

               case ALTU:
#ifdef ATARIST
               case UNDO:
#endif               
		   			if (port_ptr != original_port)
			   			{
				   		status_line (" %s COM%d:", msgtxt[M_SWITCHING_BACK], original_port + 1);
	                  MDM_DISABLE ();
						   port_ptr = original_port;
      	            if (Cominit (port_ptr) != 0x1954)
         	            {
            	         port_ptr = c;
               	      (void) Cominit(port_ptr);
                  	   }
	                  MDM_ENABLE (lock_baud && (btypes[baud].rate_value >= lock_baud) ? max_baud.rate_mask : btypes[baud].rate_mask);
   	               DTR_ON ();
   						}
                  retval = 0;
               /* Fall into exit code */

               case ALTX:
                  if (logfile != NULL)
                     (void) fclose (logfile);
                  done = 1;
                  break;

               case PGUP:
                  scr_printf (msgtxt[M_READY_TO_SEND]);
                  scr_printf (msgtxt[M_WHICH_PROTOCOL]);
                  scr_printf ("Z)modem     S)EAlink     T)elink     X)modem\r\n");
                  if (extern_protocols != NULL)
                     {
                     scr_printf (extern_protocols);
                     scr_printf ("\r\n");
                     }
                  scr_printf (msgtxt[M_CHOOSE]);
                  junk[0] = '\0';
                  (void) fgets (junk, 100, stdin);
                  if ((junk[0] == '\0') || (junk[0] == '\n'))
                     break;
                  if ((prot = toupper (junk[0])) == 0)
                     break;
                  p = NULL;
                  if ((strchr (native_protocols, prot) == NULL)
                      && (extern_protocols &&
                      	  ((p = strchr (extern_protocols, prot)) == NULL)))
                     {
                     scr_printf (msgtxt[M_DONT_KNOW_PROTO]);
                     break;
                     }
                  scr_printf (msgtxt[M_FILE_TO_SEND]);
                  junk[0] = '\0';
                  (void) fgets (junk, 100, stdin);
                  if ((k = (int) strlen (junk)) > 0 )
                     junk[--k] = '\0';
                  if ((junk[0] == '\0') || (junk[0] == '\n'))
                     break;

#if defined(OS_2)
                  if ((!k) || (dir_findfirst (junk, 0, &fileinfo)))
#elif defined(__TURBOC__)
                  if ((!k) || (findfirst (junk, &fileinfo, 0)))
#elif defined(LATTICE)
				  if ((!k) || dfind(&fileinfo, junk, 0))
#else
                  if ((!k) || (_dos_findfirst (junk, 0, &fileinfo)))
#endif
                     break;

                  err = 1;                          /* Xmodem, Ymodem, Telink
                                                     * flag */
                  save1 = comm_bits;
                  save2 = parity;
                  save3 = stop_bits;
                  comm_bits = BITS_8;
                  parity = NO_PARITY;
                  stop_bits = STOP_1;
                  MDM_ENABLE (lock_baud && (btypes[baud].rate_value >= lock_baud) ? max_baud.rate_mask : btypes[baud].rate_mask);
                  XON_DISABLE ();

                  /* My apologies for the 'goto's below. But this sucker
                     is much more readable this way. */

                  /* If external protocol requested, call it */

                  if (p)
                     {
                     do_extern ("Send", (int) prot, junk);
                     goto upload_done;
                     }

                  /* Check for Xmodem or Ymodem, as neither
                     has a batch mode ...                 */

                  if ((prot == 'X') || (prot == 'Y'))
                     {
                     (void) Xmodem_Send_File (junk, NULL);
                     goto upload_done;
                     }

                  /* If we get here, the protocol is Telink, SEAlink
                   * or Zmodem. All batch protocols. So we have to do
                   * a batch to support wildcard uploads. */

                  /* Find the end of the path part of the name */

                  p = strrchr (junk, '\\');
                  if (p == NULL)
                     p = strrchr (junk, '/');
                  if (p == NULL)
                     p = strchr (junk, ':');
                  if (p == NULL)
                     p = junk;
                  else
                     p++;

                  /*  At this point *p points to the location in the input
                   *  string where the prepended path information ends. All
                   *  we need to do, then, is to keep plugging in the stuff
                   *  we get from _dos_find(first|next) and transfer files.
                   *  We already have the first matching filename from the
                   *  _dos_findfirst we did above, so we use a "do" loop.
                   */

                  do
                     {
                     /* Append the current filename */
#ifndef __TURBOC__
                     (void) strcpy (p, fileinfo.name);
#else
                     (void) strcpy (p, fileinfo.ff_name);
#endif

                     /* Send the file with the proper protocol */

#ifdef NEW  /* ZMODEMBLOCKLEN */
                     blklen = 0;
#endif
                     if (prot == 'Z')
                        err = Send_Zmodem (junk, NULL, 0, 0);
                     else
                        {
                        err = !Batch_Send (junk);
                        }
#ifdef OS_2
                     } while ((err) && (!dir_findnext (&fileinfo)));
#else
#ifdef __TURBOC__
                     } while ((err) && (!findnext (&fileinfo)));
#else                     
#ifdef LATTICE
					 } while (err && !dnext(&fileinfo));
#else
                     } while ((err) && (!_dos_findnext (&fileinfo)));
#endif
#endif
#endif


                  /* Finish the proper protocol if need be */

                  if (err)
                     {
                     if (prot == 'Z')
                        (void) Send_Zmodem (NULL, NULL, END_BATCH, 0);
                     else
                        (void) Batch_Send (NULL);
                     }
upload_done:
                  comm_bits = save1;
                  parity = save2;
                  stop_bits = save3;
                  MDM_ENABLE (lock_baud && (btypes[baud].rate_value >= lock_baud) ? max_baud.rate_mask : btypes[baud].rate_mask);
                  XON_ENABLE ();
                  gong ();
                  break;

               case PGDN:
                  scr_printf (msgtxt[M_READY_TO_RECEIVE]);
                  scr_printf (msgtxt[M_WHICH_PROTOCOL]);
                  scr_printf ("Z)modem     S)EAlink     T)elink     X)modem\r\n");
                  if (extern_protocols != NULL)
                     {
                     scr_printf (extern_protocols);
                     scr_printf ("\r\n");
                     }
                  scr_printf (msgtxt[M_CHOOSE]);
                  junk[0] = '\0';
                  (void) fgets (junk, 100, stdin);
                  if ((junk[0] == '\0') || (junk[0] == '\n'))
                     break;
                  if ((prot = toupper (junk[0])) == 0)
                     break;
                  p = NULL;
                  if ((strchr (native_protocols, prot) == NULL)
                      && (extern_protocols &&
                      	  ((p = strchr (extern_protocols, prot)) == NULL)))
                     {
                     scr_printf (msgtxt[M_DONT_KNOW_PROTO]);
                     break;
                     }
                  save1 = comm_bits;
                  save2 = parity;
                  save3 = stop_bits;
                  comm_bits = BITS_8;
                  parity = NO_PARITY;
                  stop_bits = STOP_1;
                  MDM_ENABLE (lock_baud && (btypes[baud].rate_value >= lock_baud) ? max_baud.rate_mask : btypes[baud].rate_mask);
                  XON_DISABLE ();
                  if ((prot == 'X') || (prot == 'Y') || p != NULL)
                     {
                     scr_printf (msgtxt[M_FILE_TO_RECEIVE]);
                     junk[0] = '\0';
                     (void) fgets (junk, 100, stdin);
                     if ((junk[0] == '\0') || (junk[0] == '\n'))
                        break;
                     if ((k = (int) strlen (junk)) == 0)
                        break;
                     junk[--k] = '\0';

                     if (p)
                        {
                        do_extern ("Get", (int) prot, junk);
                        }
                     else
                        {
                        if (junk[0] != '\0')
                           {
                           (void) Xmodem_Receive_File (download_path, junk);
                           }
                        }
                     }
                  else if (prot == 'Z')
                     {
                     (void) get_Zmodem (download_path, NULL);
                     }
                  else
                     {
                     (void) Batch_Receive (download_path);
                     }

                  comm_bits = save1;
                  parity = save2;
                  stop_bits = save3;
                  MDM_ENABLE (lock_baud && (btypes[baud].rate_value >= lock_baud) ? max_baud.rate_mask : btypes[baud].rate_mask);
                  XON_ENABLE ();
                  gong ();
                  break;

#if N_SHELLS < 10
               case ALTF10:
#endif               
#ifdef ATARIST
               case HELP:
#endif
                  main_help ();
                  break;

               default:
                  if (comm_bits == BITS_7)
                    c = k & 0x7f;
                  else
                  	c = k & 0xff;

                  if (c != 0)
                     while (Com_Tx_NW ((unsigned char) c) == 0)
                        ;
                  else
                     ansi_map ((unsigned) k);
               }
            }
         }
      if (c == -1)
         time_release ();
      }
set_prior(2);                                          /* Regular */
return (retval);
}
