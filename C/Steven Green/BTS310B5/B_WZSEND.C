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
/*                    BinkleyTerm "SendWaZOO" Processor                     */
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
/*  This module is based largely on a similar module in OPUS-CBCS V1.03b.   */
/*  The original work is (C) Copyright 1987, Wynn Wagner III. The original  */
/*  author has graciously allowed us to use his code in this work.          */
/*                                                                          */
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
#include <errno.h>

#include "bink.h"
#include "msgs.h"
#include "com.h"
#include "zmodem.h"
#include "defines.h"
#include "wazoo.h"
#include "session.h"


static int fsent;


/*--------------------------------------------------------------------------*/
/* SEND WaZOO (send another WaZOO-capable Opus its mail)                    */
/*   returns TRUE (1) for good xfer, FALSE (0) for bad                      */
/*   use instead of n_bundle and n_attach for WaZOO Opera                   */
/*--------------------------------------------------------------------------*/
int send_WaZOO (void)
{
   char fname[80];
   char s[80];
   char *HoldName;
   int check_again;
   struct stat buf;
   char *extptr;


   fsent = 0;

   if (flag_file (TEST_AND_SET, &called_addr, 1))
      goto done_send;

   HoldName = HoldAreaNameMunge(&called_addr);
   check_again = 0;

just_make_sure:
   /*--------------------------------------------------------------------*/
   /* Send all waiting ?UT files (mail packets)                          */
   /*--------------------------------------------------------------------*/

	extptr = "OCDH";
	while(*extptr)
    {
		char ch = *extptr++;

      if (caller && (ch == 'H') && !check_holdonus(&called_addr, (char**)NULL) )
         continue;

		/* 2D style OUT packets */

      sprintf (fname,
               "%s%s.%cUT",
               HoldName, Hex_Addr_Str (&called_addr), ch);

      if (!stat (fname, &buf))
         {

         /*--- Build a dummy PKT file name */
         invent_pkt_name (s);

         /*--- Tell ZModem to handle this as a SEND AS then DELETE */
         status_line (msgtxt[M_PACKET_MSG]);

         if (!Send_Zmodem (fname, s, fsent++, DO_WAZOO))
            {
            net_problems = 1;
            flag_file (CLEAR_FLAG, &called_addr, 1);
            return FALSE;
            }
          CLEAR_IOERR ();
          unlink (fname);
         }

#ifdef IOS
		/*
		 * New 4D style OPT Uncompressed packets
		 */
			 
		sprintf(fname, "%s%s.%cPT", HoldName, Addr36(&called_addr), ch);
		if(!stat(fname, &buf))
		{
			invent_pkt_name(s);
			status_line(msgtxt[M_PACKET_MSG]);

			if(!Send_Zmodem(fname, s, fsent++, DO_WAZOO))
			{
			ios_error:
				net_problems = 1;
				flag_file(CLEAR_FLAG, &called_addr, 1);
#ifdef DEBUG
				status_line(">Error sending IOS packet %s", fname);
#endif
				return FALSE;
			}
			CLEAR_IOERR();
			unlink(fname);
		}

		/*
		 * 4D style OAT, compressed mail
		 */
			 
		sprintf(fname, "%s%s.%cAT", HoldName, Addr36(&called_addr), ch);
		if(!stat(fname, &buf))
		{
			make_dummy_arcmail(s, &alias[assumed].ad, &called_addr);
			status_line(msgtxt[M_PACKET_MSG]);

			if(!Send_Zmodem(fname, s, fsent++, DO_WAZOO))
				goto ios_error;
			CLEAR_IOERR();
			unlink(fname);
		}
#endif

      }                                          /* for */


   	/*--------------------------------------------------------------------*/
   	/* Send files listed in ?LO files (attached files)                    */
   	/*--------------------------------------------------------------------*/

   	if (!do_FLOfile ("FCDH", WaZOO_callback, &called_addr))
   	{
   	flo_error:
      	flag_file (CLEAR_FLAG, &called_addr, 1);
      	return FALSE;
   	}
#ifdef IOS
	if(!do_FLOfile("DHOC", WaZOO_callback, &called_addr))
		goto flo_error;
#endif	

   if (fsent && !check_again)
      {
      check_again = 1;
      goto just_make_sure;
      }

   /*--------------------------------------------------------------------*/
   /* Send our File requests to other system                             */
   /*--------------------------------------------------------------------*/
/* #ifndef NEW */  /* TRYREQ  26.08.1990 */
   if (requests_ok)
/* #endif */
      {
      sprintf (fname, request_template, HoldName, Hex_Addr_Str (&called_addr));
      if (!stat (fname, &buf))
         {
         if (!(((unsigned) remote_capabilities) & WZ_FREQ))
            status_line (msgtxt[M_FREQ_DECLINED]);
         else
            {
            status_line (msgtxt[M_OUT_REQUESTS]);
            ++made_request;
            if (Send_Zmodem (fname, NULL, fsent++, DO_WAZOO))
               unlink (fname);
            }
         }
#ifdef IOS
		extptr = "DHOC";
		while(*extptr)
		{
			char c = *extptr++;
			if (caller && (c == 'H') && !check_holdonus(&called_addr, (char**)NULL))
				continue;
			sprintf(fname, "%s%s.%cRT", HoldName, Addr36(&called_addr), c);
			if(!stat(fname, &buf))
			{
				if(!(remote_capabilities & WZ_FREQ))
					status_line (msgtxt[M_FREQ_DECLINED]);
				else
				{
					status_line (msgtxt[M_OUT_REQUESTS]);
					++made_request;
					sprintf (s, request_template, HoldName, Hex_Addr_Str(&called_addr));
					if (Send_Zmodem (fname, s, fsent++, DO_WAZOO))
						unlink (fname);
				}
			}			
		}
#endif
      }

   if(!caller || check_reqonus(&called_addr, (char**)NULL))
	   fsent = respond_to_file_requests (fsent, WaZOO_callback);

   flag_file (CLEAR_FLAG, &called_addr, 1);

done_send:

   if (!fsent)
      status_line (msgtxt[M_NOTHING_TO_SEND], Pretty_Addr_Str (&called_addr));


   Send_Zmodem (NULL, NULL, ((fsent) ? END_BATCH : NOTHING_TO_DO), DO_WAZOO);

   sent_mail = 1;

   return TRUE;

}                                                /* WaZOO */

/*
 * WaZOO_callback () -- send requested file using WaZOO method.
 *
 *
 */
int WaZOO_callback (char *reqs)
{
   return (Send_Zmodem (reqs, NULL, fsent++, DO_WAZOO));
}

