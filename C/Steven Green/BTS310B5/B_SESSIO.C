/*--------------------------------------------------------------------------*/
/*																			*/
/*																			*/
/*		------------		 Bit-Bucket Software, Co.						*/
/*		\ 10001101 /		 Writers and Distributors of					*/
/*		 \ 011110 / 		 Freely Available<tm> Software. 				*/
/*		  \ 1011 /															*/
/*		   ------															*/
/*																			*/
/*	(C) Copyright 1987-90, Bit Bucket Software Co., a Delaware Corporation. */
/*																			*/
/*																			*/
/*				  This module was written by Vince Perriello				*/
/*																			*/
/*																			*/
/*					 BinkleyTerm Mail Session Initiator 					*/
/*																			*/
/*																			*/
/*	  For complete	details  of the licensing restrictions, please refer	*/
/*	  to the License  agreement,  which  is published in its entirety in	*/
/*	  the MAKEFILE and BT.C, and also contained in the file LICENSE.240.	*/
/*																			*/
/*	  USE  OF THIS FILE IS SUBJECT TO THE  RESTRICTIONS CONTAINED IN THE	*/
/*	  BINKLEYTERM  LICENSING  AGREEMENT.  IF YOU DO NOT FIND THE TEXT OF	*/
/*	  THIS	AGREEMENT IN ANY OF THE  AFOREMENTIONED FILES,	OR IF YOU DO	*/
/*	  NOT HAVE THESE FILES,  YOU  SHOULD  IMMEDIATELY CONTACT BIT BUCKET	*/
/*	  SOFTWARE CO.	AT ONE OF THE  ADDRESSES  LISTED BELOW.  IN NO EVENT	*/
/*	  SHOULD YOU  PROCEED TO USE THIS FILE	WITHOUT HAVING	ACCEPTED THE	*/
/*	  TERMS  OF  THE  BINKLEYTERM  LICENSING  AGREEMENT,  OR  SUCH OTHER	*/
/*	  AGREEMENT AS YOU ARE ABLE TO REACH WITH BIT BUCKET SOFTWARE, CO.		*/
/*																			*/
/*																			*/
/* You can contact Bit Bucket Software Co. at any one of the following		*/
/* addresses:																*/
/*																			*/
/* Bit Bucket Software Co.		  FidoNet  1:104/501, 1:132/491, 1:141/491	*/
/* P.O. Box 460398				  AlterNet 7:491/0							*/
/* Aurora, CO 80046 			  BBS-Net  86:2030/1						*/
/*								  Internet f491.n132.z1.fidonet.org 		*/
/*																			*/
/* Please feel free to contact us at any time to share your comments about	*/
/* our software and/or licensing policies.									*/
/*																			*/
/*--------------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <ctype.h>

#include "bink.h"
#include "msgs.h"
#include "sbuf.h"
#include "sched.h"
#include "emsi.h"
#include "session.h"
#include "com.h"
#include "defines.h"
#include "wazoo.h"


/*---------------------------------------------
 * Data used in sessions
 */

/* Linked list of remote addresses */

ADDR_LIST remote_ads = { NULL };


int Netmail_Session;
int isOriginator = 0;							 /* Global logical "I'm the
												  * caller"  */
int got_arcmail;
int got_packet;
int got_mail;
int mail_finished;
int sent_mail;
int made_request;								 /* WaZOO file request flag */
int net_problems;								 /* This should be external */

ADDR remote_addr;
int remote_capabilities;

long total_bytes = 0L;							 /* Total bytes transferred 		 */

char *request_template = "%s%s.REQ";
char *ext_flags = "ODCH";						 /* Change to whatever, and */

char *session_password = NULL;				/* Master EMSI session password */

BOOLEAN doing_janus = FALSE;

/*----------------------------------------------------
 * Do a session
 */

void b_session (BOOLEAN was_initiator)
{
	int i;
	ADDR tmp;

	tmp.Zone = 0;
	tmp.Net = 0;
	tmp.Node = 0;
	tmp.Point = 0;
	tmp.Domain = NULL;
	CurrentNetFiles = DEFAULT.sc_Inbound;

	mail_finished = 0;

	time (&etm);

	freq_accum.bytes = 0L;
	freq_accum.files = 0;
	freq_accum.transferRate = cur_baud / 10;

	if (un_attended && fullscreen)
	{
		do_ready (msgtxt[M_READY_CONNECT]);
	}

	/* Remove the old .REQ and .RSP files */

	for (i = 0; i < num_addrs; i++)
	{
		char *hexad;

		hexad = Hex_Addr_Str(&alias[i].ad);

		sprintf (junk, "%s%s.REQ", DEFAULT.sc_Inbound, hexad);
		unlink (junk);

		if(KNOWN.sc_Inbound != DEFAULT.sc_Inbound)
		{
			sprintf (junk, "%s%s.REQ", KNOWN.sc_Inbound, hexad);
			unlink (junk);
		}
		if(PROT.sc_Inbound != KNOWN.sc_Inbound)
		{
			sprintf (junk, "%s%s.REQ", PROT.sc_Inbound, hexad);
			unlink (junk);
		}
		sprintf (junk, "%s.RSP", hexad);
		unlink (junk);
	}

	remote_capabilities = 0;
	flag_file (SET_SESSION_FLAG, &called_addr, 0);
	if (was_initiator)
	{

		/*
		 *	  OUTBOUND -- meaning call was made by us.
		 */

		last_type (1, &remote_addr);
		switch(TxEmsiInit())
		{
		case SESSION_FTSC:
			FTSC_sender (0);
			break;

		case SESSION_WAZOO:
			if (YooHoo_Sender ())
				WaZOO (1);
			break;

		case SESSION_EMSI:
			EMSI_sender();
			break;

		default:
			break;

		}			 /* end switch */

	}
	else
	{

		/*
		 *	  INBOUND -- meaning we were connected to by another system.
		 */


		switch(i = RxEmsiInit())
		{
		case SESSION_BBS:						/* ESCape or Timeout	*/
			if (CARRIER && !mail_only)
			{
				last_type (3, &tmp);
				flag_file (CLEAR_SESSION_FLAG, &called_addr, 0);
				BBSexit ();
			}
			break;

		case SESSION_FTSC:						/* FTSC Netmail Session */
			if (CARRIER)
			{
				tmp.Zone = -1000;
				last_type (2, &tmp);
				tmp.Zone = 0;
				++hist.mail_calls;
				if (un_attended && fullscreen)
				{
					sb_move (historywin, HIST_MAIL_ROW, HIST_COL);
					sprintf (junk, "%d/%d/%d",
						hist.bbs_calls, hist.mail_calls, hist.extmails);
					sb_puts (historywin, (unsigned char *) junk);
					sb_show ();
				}
				FTSC_receiver (0);
			}
			break;

		case SESSION_WAZOO:						/* WaZOO Netmail Session*/
			if (YooHoo_Receiver ())
			{
				last_type (1, &remote_addr);
				++hist.mail_calls;
				if (un_attended && fullscreen)
				{
					sb_move (historywin, HIST_MAIL_ROW, HIST_COL);
					sprintf (junk, "%d/%d/%d",
					hist.bbs_calls, hist.mail_calls, hist.extmails);
					sb_puts (historywin, (unsigned char *) junk);
				}
				WaZOO (0);						/* do WaZOO!!!			*/
			}
			break;

		case SESSION_EMSI:
			EMSI_receiver();
			break;

		case SESSION_FAIL:
			b_init();
			break;


		default:
			if ((i >= SESSION_EXTERN) && (i < (SESSION_EXTERN + num_ext_mail)))
			{					 /*See if ext mail*/
				if (CARRIER)
				{
					last_type (4, &tmp);
					flag_file (CLEAR_SESSION_FLAG, &called_addr, 0);
					UUCPexit (lev_ext_mail[i-SESSION_EXTERN]);
				}
			}
			break;
		}				 /* end switch */
	}			 /* end if (was_initiator) */
	flag_file (CLEAR_SESSION_FLAG, &called_addr, 0);
	return;
}

/*
 * Initialise transfer variables
 */

void b_init (void)
{
	ADDR_LIST *ads;

	got_arcmail = got_packet = got_mail = sent_mail = 0;
	remote_addr.Zone = remote_addr.Net = remote_addr.Node = remote_addr.Point = 0;
	remote_addr.Domain = NULL;
	Netmail_Session = remote_capabilities = mail_finished = 0;
	CurrentNetFiles = DEFAULT.sc_Inbound;
	doing_janus = FALSE;

	/* Clear remote addresses */

	ads = remote_ads.next;
	remote_ads.next = NULL;
	while(ads)
	{
		ADDR_LIST *next = ads->next;
		free(ads);
		ads = next;
	}
}


/*
 * Send banner-type lines to remote. Since strange modems like Courier HST
 * have a propensity for thinking they are connected when talking to a dial
 * tone (but do leave CTS down just to screw us up) we have to use a timeout
 * to figure out if we are in trouble, and if so, we drop DTR to make the
 * bogus carrier go away.
 *
 * This routine is used in modules B_BBS.C and RECVSYNC.C, both of which
 * are called from this module only.
 *
 */

int SendBanner (char *string)
{
	long t1;
	register char c;

	t1 = timerset (600);						 /* 60 seconds max to put out
												  * banner */

	while (!timeup (t1) && CARRIER)
	{
		if (got_ESC ())											   /* Manual abort? 	*/
			break;											  /* Use failure logic */

		if (!OUT_FULL ())
		{
			c = *string++;
			if (!c || c == 0x1a)										   /* Test for end		*/
				return (1);											 /* Yes, success	  */
			SENDBYTE ((unsigned char) c);
		}
	}

	/*
	 * If we get here we had trouble. Drop DTR now to hopefully get out of
	 * this trouble. Flush outbound. Pause for 1 second.
	 */

	hang_up ();
	CLEAR_OUTBOUND ();
	CLEAR_INBOUND ();

	return (0);
}




/*
 * Check for user defined file extension
 */

static int is_user (char *p)
{
   char *q, *r;
   int i, j;

   if (cur_event < 0)
	  return (0);

   q = strchr (p, '.');
   if (q != NULL)
	  {
	  ++q;
	  for (i = 0; i < 6; i++)
		 {
		 r = &(e_ptrs[cur_event]->err_extent[i][0]);
		 for (j = 0; j < 3; j++)
		 {
			if ((tolower (q[j]) != tolower (r[j])) && (q[j] != '?'))
				break;
		 }
		 if (j == 3)
			user_exits[i] = 1;
		 }
	  }

   return (0);
}

/*
 * find out if packet is arcmail
 * p : filename
 * n : length of filename
 */

int is_arcmail (char *p, size_t n)
{
	size_t i;
	char c[128];
	static char *suffixes[8] = {
		"SU", "MO", "TU", "WE", "TH", "FR", "SA", NULL
	};

	if (!isdigit (p[n]))
	{
		return (is_user (p));
	}

   strcpy (c, p);
   strupr (c);

   for (i = n - 11; i < n - 3; i++)
	  {
	  if ((!isdigit (c[i])) && ((c[i] > 'F') || (c[i] < 'A')))
		 return (is_user (p));
	  }

   for (i = 0; i < 7; i++)
	  {
	  if (strnicmp (&c[n - 2], suffixes[i], 2) == 0)
		 break;
	  }

   if (i >= 7)
	  {
	  return (is_user (p));
	  }

   got_arcmail = TRUE;
   return (1);
}
/*--------------------------------------------------------------------------*/
/* CHECK_NETFILE -- find out if the file we've got is a netfile.			*/
/*--------------------------------------------------------------------------*/

char *check_netfile (char *fname)
{
   register char *p;
   register size_t n;

   p = fname;
   n = strlen (p) - 1;

   if ((p[n] == 't') && (p[n - 1] == 'k') && (p[n - 2] == 'p') && (p[n - 3] == '.'))
	  {
	  got_packet = 1;
	  got_mail = 1;
	  p = msgtxt[M_MAIL_PACKET];
	  }
   else if (is_arcmail (p, n))
	  {
	  got_mail = 1;
	  p = msgtxt[M_COMPRESSED_MAIL];
	  }
   else
	  {
	  /* Don't set 'got_mail' if it's a .REQ file */
	  if ((p[n] != 'q') || (p[n - 1] != 'e') || (p[n - 2] != 'r') || (p[n - 3] != '.'))
		 got_mail = 1;
	  p = msgtxt[M_NET_FILE];
	  }

   return (p);
}


