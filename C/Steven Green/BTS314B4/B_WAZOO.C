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
/*						BinkleyTerm "WaZOO" Processor						*/
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
/*																			*/
/*	This module is based largely on a similar module in OPUS-CBCS V1.03b.	*/
/*	The original work is (C) Copyright 1987, Wynn Wagner III. The original	*/
/*	author has graciously allowed us to use his code in this work.			*/
/*																			*/
/*--------------------------------------------------------------------------*/

#include <stdio.h>
#include <signal.h>
#include <ctype.h>
#include <conio.h>
#include <string.h>
#include <stdlib.h>
#ifdef __TOS__
#include <ext.h>
#else
#include <sys\types.h>
#include <sys\stat.h>
#endif
#include <time.h>

#include "bink.h"
#include "msgs.h"
#include "com.h"
#include "session.h"
#include "zmodem.h"
#include "wazoo.h"

/*--------------------------------------------------------------------------*/
/* WaZOO																	*/
/*--------------------------------------------------------------------------*/

void WaZOO (int originator)
{
   int stat;
   int i = 0;
   char j[100];
   char k[100];

   /*--------------------------------------------------------------------*/
   /* Initialize WaZOO													 */
   /*--------------------------------------------------------------------*/
   stat =
	  made_request =
	  got_arcmail =
	  got_packet = 0;

   Netmail_Session = 1;

   isOriginator = originator;

   if (originator &&
	  ((remote_addr.Zone != called_addr.Zone) ||
	   (remote_addr.Net != called_addr.Net) ||
	   (remote_addr.Node != called_addr.Node) ||
	   (remote_addr.Point != called_addr.Point)))
	{
		/* Do NOT say this message if the node is a host
		 * or a region-Node
		 */
		if ((called_addr.Node != 0) && (called_addr.Net >= 100))
		{
			sprintf (k, "%s", Pretty_Addr_Str (&remote_addr));
			sprintf (j, msgtxt[M_CALLED], Pretty_Addr_Str (&called_addr), k);
			status_line (j);
		}
	}
   	else
	{
		called_addr = remote_addr;
	}

   if (!CARRIER)
	  return;

   /* Try Janus first */
   if ((((unsigned) remote_capabilities) & DOES_IANUS) && ((janus_baud >= cur_baud) || (janus_OK)))
	  {
	  status_line ("%s Janus", msgtxt[M_WAZOO_METHOD]);
	  Janus ();
	  goto endwazoo;
	  }


   /* See if we can both do ZEDZAP */
   if ((remote_capabilities & ZED_ZAPPER) && (!no_zapzed))
	  {
	  status_line ("%s ZedZap", msgtxt[M_WAZOO_METHOD]);
	  remote_capabilities &= ~ZED_ZIPPER;
	  }
   else if ((remote_capabilities & ZED_ZIPPER) && (!no_zapzed))
	  {
	  status_line ("%s ZedZip", msgtxt[M_WAZOO_METHOD]);
	  remote_capabilities &= ~ZED_ZAPPER;
	  }
   else
	  {
	  status_line ("%s DietIFNA", msgtxt[M_WAZOO_METHOD]);
	  if (originator)
		 {
		 FTSC_sender (1);
		 }
	  else
		 {
		 FTSC_receiver (1);
		 }
	  goto endwazoo;
	  }

	blklen = 0;

   /*--------------------------------------------------------------------*/
   /* ORIGINATOR: send/receive/send 									 */
   /*--------------------------------------------------------------------*/
   if (originator)
	  {

	  send_WaZOO ();
	  if (!CARRIER)
		 goto endwazoo;
	  if (!get_Zmodem (CurrentNetFiles, NULL))
		 goto endwazoo;

	  if (!CARRIER)
		 goto endwazoo;
	  stat = respond_to_file_requests (i, WaZOO_callback);
#if 0	/* !!! this is what is causing delay before hangup probably! */
	  if (stat)
#endif
		 Send_Zmodem (NULL, NULL, ((stat) ? END_BATCH : NOTHING_TO_DO), DO_WAZOO);
	  mail_finished = 1;
	  }

   /*--------------------------------------------------------------------*/
   /* CALLED SYSTEM: receive/send/receive								 */
   /*--------------------------------------------------------------------*/
   else
	  {
	  if (!get_Zmodem (CurrentNetFiles, NULL))
		 goto endwazoo;
	  if (!CARRIER)
		 goto endwazoo;
	  send_WaZOO ();
	  if (!CARRIER || !made_request)
		 goto endwazoo;
	  get_Zmodem (CurrentNetFiles, NULL);
	  }

endwazoo:
   status_line (msgtxt[M_WAZOO_END]);

}												 /* wazoo */

/*--------------------------------------------------------------------------*/
/* RESPOND TO FILE REQUEST													*/
/*--------------------------------------------------------------------------*/

int respond_to_file_requests (int f_sent, int (*callback)(char *))
{
	char req[80];
	struct stat buf;
	FILE *fp;
	int np;
	byte *s;
	char *folder;
	int phase;

	int nfiles = f_sent;
												/* this is for callback */
	time_t thetime;

	time(&thetime);
	freq_accum.startTime = (long) thetime;

	if (!(matrix_mask & TAKE_REQ))
		goto done;

	if(CurrentOKFile == NULL)
		goto done;

	for (np = 0; np <= ALIAS_CNT; np++)
	{
		if (alias[np].ad.Net == 0)
			break;

		for(phase = 0; phase < 3; phase++)
		{
			if(phase == 0)
				folder = DEFAULT.sc_Inbound;
			else
			if(phase == 1)
			{
				folder = KNOWN.sc_Inbound;
				if(folder == DEFAULT.sc_Inbound)
					continue;
			}
			else
			if(phase == 2)
			{
				folder = PROT.sc_Inbound;
				if(folder == KNOWN.sc_Inbound)
					continue;
			}

			sprintf (req, request_template, folder, Hex_Addr_Str(&alias[np].ad));


			if (!stat (req, &buf))
			{
				if ((fp = fopen (req, read_ascii)) == NULL)
				{
					got_error (msgtxt[M_OPEN_MSG], req);
					unlink(req);
					goto done;
				}

				while (!feof (fp))
				{
					req[0] = 0;
					if (fgets (req, 79, fp) == NULL)
						break;

					/* ; as the first char is a comment */
					if (req[0] == ';')
						continue;

					/* Get rid of the newline at the end */
					s = (byte *) (req + strlen (req) - 1);
					while ((s >= (byte *) req) && *s && isspace (*s))
						*s-- = '\0';

					if (req[0] == '\0')
						continue;

					if ((nfiles = n_frproc (req, nfiles, callback)) < 0)
						break;
				}

				sprintf (req, request_template, folder, Hex_Addr_Str(&alias[np].ad));
				fclose (fp);

				/* Note that Opus does not delete this file, but we should I think */
				unlink (req);
				/* once we have satisfied a request, we can get out of here */
				break;
			}
		}	/* phase */
	}

done:
	return nfiles;
}
