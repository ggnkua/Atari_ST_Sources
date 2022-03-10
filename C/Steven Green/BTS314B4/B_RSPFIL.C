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
/*				 This module was written by Vince Perriello 				*/
/*																			*/
/*																			*/
/*			   BinkleyTerm File Request Failure Message Module				*/
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

#undef RSP	/* Define this for old style RSP files */


#include <stdio.h>
#include <time.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>

#ifdef __TURBOC__
#ifndef __TOS__
#include <mem.h>
#include <alloc.h>
#endif
#else
#ifndef LATTICE
#include <memory.h>
#include <malloc.h>
#endif
#endif

#include "bink.h"
#include "msgs.h"
#include "session.h"

#ifndef RSP
#include "password.h"
#include "fsc.h"		/* FSC-0048 packet header */
#endif



static struct parse_list rspverbs [] = {
	{4, "text"},
	{4, "date"},
	{4, "time"},
	{4, "bink"},
	{6, "mynode"},
	{6, "system"},
	{5, "sysop"},
	{6, "yrnode"},
	{7, "request"},
	{6, "status"},
	{5, "abort"},
	{4, "exit"},
	{4, "line"},
	{0, NULL}
};


/*
 * Build a Response packet (used to be .RSP file)
 *
 * data   : input = response, output = filename
 * failure: failure code from file req module
 */

void Make_Response( char *data, int failure )
{
	FILE *Template, *Response;
	char *dummy_text;
	char *text;
	char *failure_text[10];
	char resp_filename[13];
	char *p, *q, *s;
	struct tm *tp;
	time_t ltime;
	int i;

#ifdef DEBUG
	status_line(">Make_Response(%s,%d)", data, failure);
#endif

	if (Netmail_Session == 2)
	  {
	  text = strchr (data, ' ');
	  if (text != NULL)
		 *text = '\0';
	  }

	Template = Response = NULL;

	for (i = 0; i < 9; i++)
	   failure_text[i] = NULL;

	if (((text = malloc (256)) == NULL)
	|| ((dummy_text = malloc (256)) == NULL))
	   goto resp_failed;

	(void) time (&ltime);
	tp = localtime (&ltime);
	
	if ((Template = fopen (CurrentReqTemplate, read_ascii)) == NULL)
	  {
	  (void) got_error (msgtxt[M_OPEN_MSG], CurrentReqTemplate);
	  goto resp_failed;
	  }


#ifndef RSP
	if(!SendRSP)
		invent_pkt_name(resp_filename);
	else
#endif
		(void) sprintf (resp_filename, "%s.RSP", Hex_Addr_Str (&alias[assumed].ad));


	if ((Response = fopen (resp_filename, write_binary)) == NULL)
	  {
	  (void) got_error (msgtxt[M_OPEN_MSG], resp_filename);
	  goto resp_failed;
	  }
	
#ifndef RSP
		/* Build a packet header... mostly copied from ftsc.c */
		
		if(!SendRSP)
		{
#ifdef PKT_2_2
			struct _pkthdr packet;
			
#ifdef DEBUG
			status_line(">Writing 2.2 Response NetMail packet %s", resp_filename);
#endif

			/* Make it a type 2.2 packet */

			memset(&packet, 0, sizeof(packet));

			packet.product = isBITBRAIN;
			packet.ver.w = PUTWORD(PKTVER);
			if (n_getpassword (&remote_addr))
			{
				if (remote_password != NULL)
				{
					strupr (remote_password);
					strncpy (packet.password, remote_password, 8);
				}
			}
			packet.orig_zone.w = PUTWORD(alias[assumed].ad.Zone);
			packet.dest_zone.w = PUTWORD(remote_addr.Zone);

			packet.orig_node.w = PUTWORD(alias[assumed].ad.Node);
			packet.dest_node.w = PUTWORD(remote_addr.Node);
			packet.dest_net.w = PUTWORD(remote_addr.Net);
			packet.orig_net.w = PUTWORD(alias[assumed].ad.Net);
			packet.year.w = PUTWORD(alias[assumed].ad.Point);
			packet.month.w = PUTWORD(remote_addr.Point);
			packet.day.w = PUTWORD(0);
			packet.hour.w = PUTWORD(0);
			packet.minute.w = PUTWORD(0);
			packet.second.w = PUTWORD(0);
			packet.rate.w = PUTWORD(2);
			if(alias[assumed].ad.Domain)
			{
				for(i = 0; domain_name[i]; i++)
				{
					if(domain_name[i] == alias[assumed].ad.Domain)
						break;
				}
				if(domain_abbrev[i])
					strncpy (packet.B_fill2, domain_abbrev[i], 8);
			}
			if(remote_addr.Domain)
			{
				for(i = 0; domain_name[i]; i++)
				{
					if (domain_name[i] == remote_addr.Domain)
						break;
				}
				if(domain_abbrev[i])
					strncpy (&(packet.B_fill2[8]), domain_abbrev[i], 8);
			}
#else
		/* Generate FSC-0048 packet */
		
			PKT_HEADER packet;
			time_t thetime;
			struct tm *t;
			
#ifdef DEBUG
			status_line(">Writing FSC-0048 Response NetMail packet %s", resp_filename);
#endif
			time(&thetime);
			t = localtime(&thetime);

			memset(&packet, 0, sizeof(packet));

			packet.productCode = packet.ProductCodeCopy = isBITBRAIN;
			packet.ver.w = PUTWORD(PKTVER);
			if(n_getpassword (&remote_addr))
			{
				if (remote_password != NULL)
				{
					strupr (remote_password);
					strncpy (packet.password, remote_password, 8);
				}
			}
			packet.origZone.w = packet.origZone2.w = PUTWORD(alias[assumed].ad.Zone);
			packet.destZone.w = packet.destZone2.w = PUTWORD(remote_addr.Zone);

			packet.origNode.w = PUTWORD(alias[assumed].ad.Node);
			packet.destNode.w = PUTWORD(remote_addr.Node);
			packet.destNet.w = PUTWORD(remote_addr.Net);

			packet.AuxNet.w = PUTWORD(alias[assumed].ad.Net);
			if(alias[assumed].ad.Point)
				packet.origNet.w = PUTWORD(-1);
			else
				packet.origNet.w = PUTWORD(alias[assumed].ad.Net);
			packet.origPoint.w = PUTWORD(alias[assumed].ad.Point);
			packet.destPoint.w = PUTWORD(remote_addr.Point);

			packet.year.w = PUTWORD(t->tm_year+1900);
			packet.month.w = PUTWORD(t->tm_mon);
			packet.day.w = PUTWORD(t->tm_mday);
			packet.hour.w = PUTWORD(t->tm_hour);
			packet.minute.w = PUTWORD(t->tm_min);
			packet.second.w = PUTWORD(t->tm_sec);
			packet.baud.w = PUTWORD(cur_baud);
		
			packet.CapabilWord.w = PUTWORD(1);
			packet.CWvalidationCopy.w = PUTWORD(0x100);
#endif

			fwrite (&packet, sizeof (struct _pkthdr), 1, Response);
		}

		if(!SendRSP)
		{	/* Start a packed message */
			struct {
				MWORD ver;
				MWORD origNode;
				MWORD destNode;
				MWORD origNet;
				MWORD destNet;
				MWORD Attribute;
				MWORD cost;
			} msg;
			char thetime[20];
			time_t t;
			struct tm *tptr;

			memset(&msg, 0, sizeof(msg));
			msg.ver.w = PUTWORD(2);

#if 1	/* Use FakeNet? */
			if(alias[assumed].ad.Point)
			{
				msg.origNet.w = PUTWORD(alias[assumed].fakenet);
				msg.origNode.w = PUTWORD(alias[assumed].ad.Point);
			}
			else
#endif
			{
				msg.origNet.w = PUTWORD(alias[assumed].ad.Net);
				msg.origNode.w = PUTWORD(alias[assumed].ad.Node);
			}

#if 1
			if(remote_addr.Point &&
			   (remote_addr.Net == alias[assumed].ad.Net) &&
			   (remote_addr.Node == alias[assumed].ad.Node) )
			{
				msg.destNet.w = PUTWORD(alias[assumed].fakenet);
				msg.destNode.w = PUTWORD(remote_addr.Point);

				msg.origNet.w = PUTWORD(alias[assumed].fakenet);
				msg.origNode.w = PUTWORD(alias[assumed].ad.Point);

			}
			else
#endif
            {
				msg.destNode.w = PUTWORD(remote_addr.Node);
				msg.destNet.w = PUTWORD(remote_addr.Net);
			}

			msg.Attribute.w = PUTWORD(1);		/* Private */
			msg.cost.w = PUTWORD(0);
			fwrite(&msg, sizeof(msg), 1, Response);

			/* Make the DateTime */

			time(&t);
			tptr = localtime(&t);
			strftime(thetime, sizeof(thetime), "%d %b %y  %H:%M:%S", tptr);
			fwrite(thetime, sizeof(thetime), 1, Response);

			/* To user name */
			
			fputs("SysOp", Response);
			fputc(0, Response);
			
			/* From User name */
			
			fputs(xfer_id, Response);
			fputc(0, Response);
			
			/* Subject */
			
			fputs("File Request", Response);
			fputc(0, Response);
			
			/* Text */

			if(alias[assumed].ad.Point)
				fprintf(Response, "\001FMPT: %d\n", alias[assumed].ad.Point);
			if(remote_addr.Point)
				fprintf(Response, "\001TOPT: %d\n", remote_addr.Point);
			if(remote_addr.Zone != alias[assumed].ad.Zone)
				fprintf(Response, "\001INTL: %d:%d/%d %d:%d/%d\n",
					remote_addr.Zone, remote_addr.Net, remote_addr.Node,
					alias[assumed].ad.Zone, alias[assumed].ad.Net, alias[assumed].ad.Node);
			/* Also do ^Domain */
		}
#endif


	while (!feof (Template))
	   {

read_line:

	   e_input[0] = '\0';
	   if (fgets (text, 254, Template) == NULL)
		  break;

	   if (text[0] == '%' && text[1] == ';')
		  continue; 					/* Comment at start, no output */
	   
	   p = text;
	   q = e_input;

	   while (*p)
		  {

		  if (*p == '\n')				/* All done if newline seen    */
			 break;

		  if (*p != '%')				/* Copy until(unless) we see % */
			 {
			 *q++ = *p++;
			 continue;
			 }
			 
		  if (*++p == ';')				/* If followed by ; just skip  */
			 break;

		  if ((i = parse(p, rspverbs)) == -1)/* Check against arg list */
			 {
			 *q++ = '%';				/* No match, use the % literal */
			 continue;
			 }
		  
		  switch (i)
		  
			 {
			 
			 case 1:					/* "text"					   */

			 if (((i = atoi (p = skip_blanks (&p[4]))) < 1) || (i > 9))
				goto read_line; 

			 if (!*(p = skip_to_blank (p)) || !*++p)
				goto read_line; 
			 
			 if (failure_text[--i] != NULL)
				free(failure_text[i]);

			 failure_text[i] = s = malloc (1 + strlen (p));
			 if (s == NULL)
				goto read_line;
			 while ((*p) && (*p != '\n'))
				*s++ = *p++;
			 *s++ = '\0';

			 goto read_line;
			 
			 case 2:					/* "date"					   */
			 p += 4;
			 (void) sprintf (dummy_text,"%2d-%3s-%02d", tp->tm_mday, mtext[tp->tm_mon], tp->tm_year);
scopy:
			 s = dummy_text;
ccopy:
			 while (*s)
			   *q++ = *s++;
			 
			 break;
			 
			 case 3:					/* "time"					   */
			 p += 4;
			 (void) sprintf (dummy_text, "%2d:%02d", tp->tm_hour, tp->tm_min);
			 goto scopy;
			 
			 case 4:					/* "bink"					   */
			 p += 4;
			 s = ANNOUNCE;
			 goto ccopy;
			 
			 case 5:					/* "mynode" 				   */
			 p += 6;
			 (void) sprintf (dummy_text, "%s", Pretty_Addr_Str (&alias[assumed].ad));
			 goto scopy;
			 
			 case 6:					/* "system" 				   */
			 p += 6;
			 s = system_name;
			 goto ccopy;
			 
			 case 7:					/* "sysop"					   */
			 p += 5;
			 s = sysop;
			 goto ccopy;
			 
			 case 8:					/* "yrnode" 				   */
			 p += 6;
			 (void) sprintf (dummy_text, "%s", Pretty_Addr_Str (&remote_addr));
			 goto scopy;
			 
			 case 9:					/* "request"				   */
			 p += 7;
			 s = data;
			 goto ccopy;
			 
			 case 10:					/* "status" 				   */
			 	p += 6;
			 	strcpy (dummy_text, p);
				if(failure_text[failure-1])
					strcpy (text, failure_text [failure-1]);
			 	strcat (text, dummy_text);
			 	p = text;
			 	break;

			 case 11:					/* "abort"					   */

			 if (*(p = skip_blanks (&p[5])))/* If there's an argument, */
				{
				if (failure != atoi (p))/* See if it matches failure   */
				   goto read_line;		/* No, keep going.			   */
				}

			 fclose (Response);		   /* Abort things: Close file,   */
			 Response = NULL;			/* Keep track of closed file   */
			 unlink (resp_filename);    /* Then delete it			  */
			 goto resp_failed;			/* And take the failure exit   */

			 case 12:					/* "exit"					   */

			 if (*(p = skip_blanks (&p[4])))/* If there's an argument, */
				{
				if (failure != atoi (p))/* See if it matches failure   */
				   goto read_line;		/* No, keep going.			   */
				}
			 goto resp_done;	   /* A match, close the file	  */

			 case 13:					/* "line"					   */

			 if ((!(*(p = skip_blanks (&p[4]))))
			 || (failure != atoi (p)))	/* If argument doesn't match,  */
				   goto read_line;		/* throw out line, keep going. */
			 if (*(p = skip_to_blank (p))) /* If there's any text,	   */
				{
				(void) strcpy (text, ++p);	   /* Copy rest of line down	  */
				p = text;				/* Move pointer to front	   */
				}
			 break;

			 }			/* End switch				  */
		  } 			/* End while *p 			  */

	   *q++ = '\r';
	   *q++ = '\n';
	   *q = '\0';

	   (void) fwrite (e_input, q - e_input, 1, Response);
	   }				/* End while !feof (Template) */

resp_done:

   strcpy (data, resp_filename);

#if 0
   fclose (Template);
   Template = NULL;
#endif

#ifndef RSP
	if(!SendRSP)
	{

		/* Finish the packet */
	
		fputc(0, Response);	/* terminate text */
		fputc(0, Response);	/* terminate packet */
		fputc(0, Response);
	}

#endif

#if 0
   fclose (Response);
   Response = NULL;
#endif
   goto cleanup;

resp_failed:

   *data = '\0';

cleanup:
   if (Response != NULL)
	  fclose (Response);

   if (Template != NULL)
	  fclose (Template);


   for (i = 0; i < 9; i++)
	   {
	   if (failure_text[i] != NULL)
		  {
		  free(failure_text[i]);
		  failure_text[i] = NULL;
		  }
	   }

   if (text != NULL)
	  free (text);

   if (dummy_text != NULL)
	  free (dummy_text);

   return;
}
