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
/*                     BinkleyTerm "YooHoo" Processor                       */
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
/*                                                                          */
/*--------------------------------------------------------------------------*/

#include <stdio.h>
#include <signal.h>
#include <ctype.h>
#include <conio.h>
#include <string.h>

#define WAZOO_SECTION
#define MATRIX_SECTION
#define isBITBRAIN 0x1b

#include "bink.h"
#include "msgs.h"
#include "com.h"
#include "sbuf.h"
#include "version.h"
#include "session.h"
#include "password.h"
#include "wazoo.h"
#include "nodeproc.h"

/*--------------------------------------------------------------------------*/
/* SEND HELLO PACKET                                                        */
/*--------------------------------------------------------------------------*/

static int Send_Hello_Packet (BOOLEAN Sender)
{
   int i;
   struct _Hello Hello;
   byte *sptr;
   long response_timer;
   word crc;
   word num_errs = 0;
   word can_do_domain = 0;
   word capabilities;
	ADDRESS *ad;
	
	make_assumed(&remote_addr);
	ad = &alias[assumed];

   /*--------------------------------------------------------------------*/
   /* Setup HELLO structure                                              */
   /*--------------------------------------------------------------------*/
   memset ((char *) &Hello, 0, sizeof (struct _Hello));

   Hello.signal.w = PUTWORD('o');
   Hello.hello_version.w = PUTWORD(1);

#ifdef ATARIST
   Hello.product.w = PUTWORD(isBINKST);
#else
   Hello.product.w = PUTWORD(isBITBRAIN);
#endif   
   Hello.product_maj.w = PUTWORD(BINK_MAJVERSION);
   Hello.product_min.w = PUTWORD(BINK_MINVERSION);

   strncpy (Hello.sysop, sysop, 19);
   Hello.sysop[19] = '\0';

   Hello.my_zone.w = PUTWORD(alias[assumed].ad.Zone);
	Hello.my_net.w = PUTWORD(ad->ad.Net);
	Hello.my_node.w = PUTWORD(ad->ad.Node);
	Hello.my_point.w = PUTWORD(ad->ad.Point);

   capabilities = (no_zapzed) ? 0 : (ZED_ZAPPER | ZED_ZIPPER);
   capabilities |= Y_DIETIFNA;
   if ((janus_baud >= cur_baud) || (janus_OK))
      capabilities |= DOES_IANUS;

   can_do_domain = alias[0].ad.Domain ? DO_DOMAIN : 0;

   if (!Sender)
      {
      can_do_domain = remote_capabilities & can_do_domain;
      if (remote_capabilities & capabilities & DOES_IANUS)
         capabilities = DOES_IANUS;
      else if (remote_capabilities & capabilities & ZED_ZAPPER)
         capabilities = ZED_ZAPPER;
      else if (remote_capabilities & capabilities & ZED_ZIPPER)
         capabilities = ZED_ZIPPER;
      else
         capabilities = Y_DIETIFNA;
      }

   strncpy (Hello.my_name, system_name, 58);
   Hello.my_name[58] = '\0';
   capabilities |= can_do_domain;
   if (can_do_domain)
      {
      if (strlen (system_name) + strlen (alias[assumed].ad.Domain) > 57)
         {
         Hello.my_name[57 - strlen (alias[assumed].ad.Domain)] = '\0';
         }
      sptr = Hello.my_name + strlen (Hello.my_name) + 1;
      strcpy (sptr, alias[assumed].ad.Domain);
      }

   if (n_getpassword (&remote_addr))
      {
      strncpy (Hello.my_password, remote_password, 8);
      }

   if ((matrix_mask & TAKE_REQ) && (DEFAULT.rq_OKFile != NULL) && 
       (!Sender || check_reqonus(&remote_addr, (char**)NULL)) )
      capabilities |= WZ_FREQ;

   Hello.capabilities.w = PUTWORD(capabilities);

   /*--------------------------------------------------------------------*/
   /* Disable handshaking and ^C/^K handling                             */
   /*--------------------------------------------------------------------*/
   XON_DISABLE ();

   /*--------------------------------------------------------------------*/
   /* Send the packet.                                                   */
   /* Load outbound buffer quickly, and get modem busy sending.          */
   /*--------------------------------------------------------------------*/

xmit_packet:

   SENDBYTE (0x1f);

   sptr = (char *) (&Hello);
   SENDCHARS (sptr, 128, 1);

   /*--------------------------------------------------------------------*/
   /* Calculate CRC while modem is sending its buffer                    */
   /*--------------------------------------------------------------------*/
   for (crc = i = 0; i < 128; i++)
      {
      crc = xcrc (crc, (byte) sptr[i]);
      }

   CLEAR_INBOUND ();

   SENDBYTE ((unsigned char) (crc >> 8));
   SENDBYTE ((unsigned char) (crc & 0xff));

   response_timer = timerset (4000);

   while (!timeup(response_timer) && CARRIER)
      {
      if (!CHAR_AVAIL ())
         {
         if (got_ESC ())
            {
            hang_up ();
            sptr  = msgtxt[M_KBD_MSG];
            goto no_response;
            }
	 time_release ();
         continue;
	 }	 

      switch (i = TIMED_READ (0))
         {
         case ACK:
            return (1);

         case '?':
            message (msgtxt[M_DRATS]);

         case ENQ:
            if (++num_errs == 2)
                {
                sptr = msgtxt[M_FUBAR_MSG];
                goto no_response;
                }
            goto xmit_packet;

         default:
            if (i > 0)                   /* Could just be line noise */
               {
               }
            break;
         }
      }

   if (!CARRIER)
      sptr = &(msgtxt[M_NO_CARRIER][1]);
   else
      sptr  = msgtxt[M_TIMEOUT];

no_response:

   message (sptr);
   return (0);

}                                                /* Send Hello */


/*--------------------------------------------------------------------------*/
/* RECEIVE HELLO PACKET                                                     */
/*--------------------------------------------------------------------------*/
static int Recv_Hello_Packet (BOOLEAN Sender)
{
   int i;
   int c;
   int j;
   struct _Hello Hello;
   byte *sptr, *p;
   byte num_errs = 0;
   word crc;
   word lsb;
   word msb;
   long master_timeout, hello_timeout;
   char junkbuff[128];
   word capabilities;

   sptr = NULL;

   /*--------------------------------------------------------------------*/
   /* Get the Hello structure                                            */
   /*--------------------------------------------------------------------*/

/* big_pause (1);  */                           /* Wait for quiet. */
   
   if (un_attended && fullscreen)
      {
      sb_move (filewin, 2, 2);
      sb_puts (filewin, "YooHoo/2U2");
      sb_show ();
      }
   else
      {
      set_xy ("YooHoo/2U2 ");
      }

   SENDBYTE (ENQ);                               /* Let the other system know
                                                  * we heard YooHoo. */

   master_timeout = timerset (12000);		/* No more than 2 mins! */

watch_for_header:

   while (1)
      {
      if (sptr)
         {
         message (sptr);
         sptr = NULL;
         }

      if ((c = TIMED_READ (20)) == 0x1f)
         break;

      if (got_ESC ())
         {
         sptr = msgtxt[M_KBD_MSG];
         goto receive_failed;
         }

      if (!CARRIER)
         {
         sptr = &(msgtxt[M_NO_CARRIER][1]);
         goto receive_failed;
         }

      if (timeup(master_timeout))
         goto timeout;

      if (c >= 0)                               /* noise? */
         {
         hello_timeout = timerset (1000);       /* Look for up to 10 secs  */
         while (((c = PEEKBYTE ()) >= 0) && (c != 0x1f) && (CARRIER))
            {
            if (timeup(hello_timeout))
               break;
            i = MODEM_IN ();                        /* Eat non-YooHoo chars    */
            }

         if (c != 0x1f)                         /* If we didn't get YooHoo */
            {
            CLEAR_INBOUND ();                   /* Throw out what we have  */
            SENDBYTE (ENQ);                     /* Start over with ENQ     */
            }
         }

      }                         /* while */


/*receive_packet:*/

   sptr = (char *) (&Hello);

   hello_timeout = timerset (3000);

   for (i = 0, crc = 0; i < 128; i++)
      {

      while (PEEKBYTE () < 0)
         {
         if (timeup (master_timeout) || timeup (hello_timeout))
            goto timeout;
        
         if (got_ESC ())
            {
            sptr = msgtxt[M_KBD_MSG];
            goto receive_failed;
            }

         if (!CARRIER)
            {
            sptr = &(msgtxt[M_NO_CARRIER][1]);
            goto receive_failed;
            }

         time_release ();
	 }

      c = TIMED_READ (0);

      sptr[i] = (char) c;
      crc = xcrc (crc, (byte) c);
      }

   if (!CARRIER)
      {
      sptr = &(msgtxt[M_NO_CARRIER][1]);
      goto receive_failed;
      }

   if (((msb = TIMED_READ (10)) < 0) || ((lsb = TIMED_READ (10)) < 0))
      {
      sptr = msgtxt[M_SHRT_MSG];
      goto hello_error;
      }

   if (((msb << 8) | lsb) == crc)
      goto process_hello;

   sptr = msgtxt[M_CRC_MSG];

hello_error:

   if (timeup(master_timeout))
      goto timeout;

   if ((num_errs++) > 2)
      {
      sptr = msgtxt[M_FUBAR_MSG];
      goto receive_failed;
      }

   CLEAR_INBOUND ();
   SENDBYTE ('?');
   goto watch_for_header;

process_hello:

	/* The idea for removing junk characters came from Holger Schurig */
	/* Get rid of junk characters */
	for (p = Hello.my_name; *p != '\0'; p++)
		if (*p < ' ')
			*p = ' ';

	/* Get rid of junk characters */
	for (p = Hello.sysop; *p != '\0'; p++)
		if (*p < ' ')
			*p = ' ';

   remote_addr.Zone = GETWORD(Hello.my_zone.w);
   remote_addr.Net = GETWORD(Hello.my_net.w);
   remote_addr.Node = GETWORD(Hello.my_node.w);
   remote_addr.Point = GETWORD(Hello.my_point.w);
   capabilities = GETWORD(Hello.capabilities.w);	
   if ((capabilities & DO_DOMAIN) && alias[0].ad.Domain)
      {
      remote_addr.Domain = find_domain (&(Hello.my_name[strlen (Hello.my_name) + 1]));
      }

#ifdef NEW
	/*
	 * Try to convert silly 3D address into 4D address if net is one of
	 * our fakenets
	 */
	
	if(remote_addr.Point == 0)
		make4d(&remote_addr);
#endif

   if (strlen (Hello.my_name) > 42)
      Hello.my_name[42] = '\0';

   Hello.sysop[19] = '\0';

   remote_capabilities = (capabilities) | Y_DIETIFNA;

   if (nodefind (&remote_addr, 0) && !remote_addr.Zone)
      remote_addr.Zone = found_zone;

   sprintf (junkbuff, "*%s (%s)",
            Hello.my_name,
            Pretty_Addr_Str (&remote_addr));
   status_line (junkbuff);

   log_product (GETWORD(Hello.product.w),
   				GETWORD(Hello.product_maj.w),
   				GETWORD(Hello.product_min.w));

   if (Hello.sysop[0])
      status_line (msgtxt[M_EMSI_SYSOP], Hello.sysop);

	if(j = n_password(&remote_addr, Hello.my_password, TRUE))
         {
         if ((j == 1) || ((j == 2) && (!Sender)))
            {
            hang_up ();
            sptr = NULL;                           /* Already logged something */
            goto receive_failed;
            }
         else
            {
            status_line (msgtxt[M_PASSWORD_OVERRIDE]);
            }
         }

   CLEAR_INBOUND ();

   SENDBYTE (ACK);
   SENDBYTE (YOOHOO);

   return (1);
 
timeout:

   sptr = msgtxt[M_TIMEOUT];

receive_failed:

   message (sptr);
   b_init ();
   return (0);
}                                               /* Recv Hello */



/*--------------------------------------------------------------------------*/
/* YOOHOO SENDER    (used when I am the CALLING system)                     */
/*--------------------------------------------------------------------------*/
int YooHoo_Sender (void)
{
   char *sptr;

   if (un_attended && fullscreen)
      {
      sb_move (filewin, 2, 2);
      sb_puts (filewin, "YooHoo");
      sb_show ();
      }
   else
      {
      set_xy ("YooHoo ");
      }

   /*--------------------------------------------------------------------*/
   /* Clean up any mess that may be around                               */
   /*--------------------------------------------------------------------*/
   CLEAR_OUTBOUND ();
   CLEAR_INBOUND ();
   XON_DISABLE ();

   if (!Send_Hello_Packet (1))
      sptr = msgtxt[M_HE_HUNG_UP];

   else
      {
      if (TIMED_READ (30) == YOOHOO)
         return Recv_Hello_Packet (1);

      status_line (msgtxt[M_NOYOOHOO]);
      sptr = IDUNNO_msg;
      }

   message (sptr);
   return (0);
}

/*--------------------------------------------------------------------------*/
/* YOOHOO RECEIVER  (Used when I am the CALLED system)                      */
/*--------------------------------------------------------------------------*/

int YooHoo_Receiver (void)
{
   int i;
   int c;

   if (un_attended && fullscreen)
      {
      sb_move (filewin, 2, 2);
      sb_puts (filewin, "YooHoo");
      sb_show ();
      }
   else
      {
      set_xy ("YooHoo ");
      }

   /*--------------------------------------------------------------------*/
   /* Clean up any mess that may be around                               */
   /*--------------------------------------------------------------------*/
   CLEAR_OUTBOUND ();
   CLEAR_INBOUND ();
   XON_DISABLE ();

   if (!(i = Recv_Hello_Packet(0)))
      return (0);

   for (i = 0; (CARRIER) && (i < 2); i++)
      {
      if ((c = TIMED_READ (10)) == ENQ)
         return Send_Hello_Packet (0) ? 1 : (b_init (), 0);

      if (c > 0)
         {
         message (NULL);
         printf ("[%x] ", c);

         /* Delay one second, then try again */
         big_pause (1);

         CLEAR_INBOUND ();
         }

      SENDBYTE (YOOHOO);
      }

   message (msgtxt[M_FUBAR_MSG]);
   b_init ();
   return (0);

}                                                /* YooHoo Receiver */

/* END OF FILE: yoohoo.c */
