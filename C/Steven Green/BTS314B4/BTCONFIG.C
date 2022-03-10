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
/*					BinkleyTerm Configuration File Parser					*/
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
#include <signal.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>

#ifndef LATTICE
#include <io.h>
#endif

#ifdef __TOS__
#include <conio.h>
#include <ext.h>
#else
#include <dos.h>
#include <sys\types.h>
#include <sys\stat.h>
#endif

#include "bink.h"
#include "msgs.h"
#include "keybd.h"
#include "com.h"
#include "sbuf.h"
#include "vfossil.h"
#include "config.h"
#include "nodeproc.h"

/* Change values in externs.h when adding or removing entries */
struct parse_list config_lines[] = {
									{8,  "SameRing"},
									{10, "Answerback"},
									{5,  "Macro"},
									{5,  "Shell"},
									{4,  "Dial"},
									{5,  "Event"},
									{4,  "Zone"},
									{6,  "MaxReq"},
									{8,  "LogLevel"},
									{4,  "Baud"},
									{7,  "MaxPort"},
									{4,  "Port"},
									{9,  "ResetPort"},
									{7,  "Carrier"},
									{9,  "StatusLog"},
									{6,  "Reader"},
									{9,  "BossPhone"},
									{7,  "BossPwd"},
									{8,  "Protocol"},
									{6,  "System"},
									{5,  "Sysop"},
									{4,  "Boss"},
									{5,  "Point"},
									{3,  "Aka"},
									{4,  "Hold"},
									{9,  "DownLoads"},
									{7,  "NetFile"},
									{9,  "FirstInit"},
									{4,  "Init"},
									{5,  "Reset"},
									{4,  "Busy"},
									{6,  "Prefix"},
									{8,  "NodeList"},
									{3,  "Fax"},
									{10, "FaxInbound"},
									{8,  "AfterFax"},
									{10, "FaxConnect"},
									{4,  "BTNC" },
									{9,  "NodeCache" },
									{5,  "Avail"},
									{6,  "OKFile"},
									{5,  "About"},
									{8,  "MailNote"},
									{6,  "Banner"},
									{10, "UnAttended"},
									{9,  "OverWrite"},
									{7,  "ReqOnUs"},
									{8,  "LockBaud"},
									{7,  "TimeOut"},
									{5,  "NoSLO"},
									{9,  "SlowModem"},
									{11, "SmallWindow"},
									{8,  "NoPickup"},
									{10, "NoRequests"},
									{7,  "NetMail"},
									{6,  "Suffix"},
									{12, "NoFullScreen"},
									{13, "SignalHandler"},
									{8,  "AutoBaud"},
									{4,  "Gong"},
									{9,  "NoCollide"},
									{9,  "ExtrnMail"},
									{7,  "BBSNote"},
									{3,  "BBS"},
									{10, "ScriptPath"},
									{7,  "BoxType"},
									{7,  "Include"},
									{11, "CaptureFile"},
									{9,  "CursorCol"},
									{9,  "CursorRow"},
									{9,  "DoingMail"},
									{8,  "EnterBBS"},
									{10, "PrivateNet"},
									{6,  "Packer"},
									{7,  "Cleanup"},
									{9,  "AfterMail"},
									{6,  "Colors"},
									{9,  "JanusBaud"},
									{11, "ReqTemplate"},
									{10, "KnownAvail"},
									{12, "KnownReqList"},
									{10, "KnownAbout"},
									{12, "KnownInbound"},
									{11, "KnownReqLim"},
									{11, "KnownReqTpl"},
									{9,  "ProtAvail"},
									{11, "ProtReqList"},
									{9,  "ProtAbout"},
									{11, "ProtInbound"},
									{10, "ProtReqLim"},
									{10, "ProtReqTpl"},
									{11, "Application"},
									{7,  "NoZones" },
									{6,  "Answer"},
									{9,  "PollTries"},
									{ 9, "PollDelay" },
									{7,  "Address"},
									{3,  "Key" },
									{10, "CurMudgeon"},
									{7,  "NoWaZOO"},
									{ 6, "NoEMSI" },
									{ 9, "NoRequest" },
									{ 7, "NoJanus" },
									{ 3, "IOS" },
									{ 6, "Hold4D" },
									{11, "ScreenBlank"},
									{10, "Mark_Kromm"},
									{6,  "Server"},
									{10, "ModemTrans"},
									{7,  "PreDial"},
									{7,  "PreInit"},
									{7,  "DTRHigh"},
									{5,  "Debug"},
									{8,  "NoZedZap"},
									{8,  "NoResync"},
									{9,  "NoSEAlink"},
									{8,  "FTS_0001"},
									{10, "LineUpdate"},
									{7,  "JanusOK" },
									{8,  "TermInit" },
									{6,  "Domain" },
									{5,  "Flags" },
									{10, "TaskNumber"},
									{8,  "MaxBytes"},
									{13, "KnownMaxBytes"},
									{12, "ProtMaxBytes"},
									{7,  "MaxTime"},
									{12, "KnownMaxTime"},
									{11, "ProtMaxTime"},
									{7,  "NoLineA" },
#ifdef BIOSDISPLAY
									{11, "BIOSdisplay" },
#endif									
									{9,  "UseColors" },
									{9,  "IKBDclock" },
									{5,  "NoCTS" },
									{7,  "HardCTS" },
									{10, "STlockBaud" },
									{9,  "SlowJanus" },
									{9,  "Hard38400" },
									{9,  "RSVEBoard" },
									{4,  "Rbuf" },
									{4,  "Tbuf" },
									{8,  "TimeZone" },
									{12, "NiceOutbound"},
									{10, "ReInitTime"},
									{12, "ReadHoldTime"},
									{ 8, "HoldOnUs" },
									{ 7, "SendRSP" },
									{12, "UseCallSlots"},
									{ 8, "FDBugfix"},
#if defined(__PUREC__) || defined(__TURBOC__)
									{ 10, "CLIcommand" },
#endif
#if 0
									{7,  "CostLog"},
									{11, "NoWildcards"},
									{11, "SuckerLimit"},
									{10, "HstLs2400c"},
									{8,  "CostUnit"},
#endif
									{ 8, "NLsystem" },
									{ 5, "Phone" },
									{ 4, "City" },
									{ 7, "NLflags" },
									{ 6, "NLbaud" },
									{ 5, "Tranx" },
									{0, NULL}
};


static char *ctl_slash_string (char *source);

int ST_altport = 0;

void parse_config( char *config_file )
{
   FILE *stream;
   char temp[256];
   char *c;
   int i,ST_port;
   unsigned long temp_num;
   char *p, *p1, *p2;
   PN_TRNS *tpn;
   MDM_TRNS *tmm;
   J_TYPES *tjt;

   (void) sprintf (temp, "%s%s", BINKpath, config_file);
   if ((stream = fopen (temp, read_ascii)) == NULL) 	/* OK, let's open the file	 */
	  return;									 /* no file, no work to do	  */

   while ((fgets (temp, 255, stream)) != NULL)	 /* Now we parse the file ... */
	  {
	  c = temp; 								 /* Check out the first char  */
	  if ((*c == '%') || (*c == ';'))			 /* See if it's a comment
												  * line */
		 continue;

	  i = (int) strlen (temp);						   /* how long this line is 	*/

	  if (i < 3)
		 continue;								 /* If too short, ignore it   */

	  c = &temp[--i];							 /* point at last character   */
	  if (*c == '\n')							 /* if it's a newline,		  */
		 *c = '\0'; 							 /* strip it off			  */

	  switch (parse (temp, config_lines))
		 {
		 case C_SameRing:								 /* "SameRing"		*/
			modemring = 1;
			break;

		 case C_Answerback: 							   /* "Answerback"	*/
			answerback = ctl_string (&temp[10]);
			break;

		 case C_Macro:								  /* "Macro"		 */
			c = skip_blanks (&temp[5]);
			i = atoi (c);
			if ((i <= 0) || (i > N_SHELLS))
			   {
			   (void) printf ("%s %d %s\n", msgtxt[M_MACRO_NUMBER], i, msgtxt[M_OUT_OF_RANGE]);
			   break;
			   }
			c = skip_to_blank (c);
			c = skip_blanks (c);
			p = keys[i - 1] = (char *) malloc (strlen (c) + 1);
			while (*c && (*c != '\n'))
			   {
			   if (*c == '|')
				  *p++ = '\r';
			   else *p++ = *c;
			   ++c;
			   }
			*p = '\0';
			break;

		 case C_Shell:								  /* "Shell"		*/
			c = skip_blanks (&temp[5]);
			i = atoi (c);
			if ((i <= 0) || (i > N_SHELLS))
			   {
			   (void) printf ("%s %d %s\n", msgtxt[M_SHELL_NUMBER], i, msgtxt[M_OUT_OF_RANGE]);
			   break;
			   }
			c = skip_to_blank (c);
			c = skip_blanks (c);
			shells[i-1] = strdup(c);
			break;

		 case C_Dial:								 /* "Dial"		   */
			p = &temp[4];
			while ((*p) && (isspace (*p)))
			   ++p;

			if ((*p == ';') || (*p == '\0'))
			   {
			   break;
			   }

			tpn = (PN_TRNS *) malloc (sizeof (PN_TRNS));

			p1 = tpn->prenum;
			while ((*p) && (*p != '/') && (!isspace (*p)))
			   {
			   *p1++ = *p++;
			   }
			*p1 = '\0';

			p1 = tpn->sufnum;
			if ((*p == '\0') || (isspace (*p)))
			   {
			   *p1 = '\0';
			   }
			else
			   {
			   ++p;

			   while ((*p) && (!isspace (*p)))
				  {
				  *p1++ = *p++;
				  }
			   *p1 = '\0';
			   }

			while ((*p) && (isspace (*p)))
			   ++p;

			p1 = tpn->prematch;
			while ((*p) && (*p != '/') && (!isspace (*p)))
			   {
			   *p1++ = *p++;
			   }
			*p1 = '\0';

			p1 = tpn->sufmatch;
			if ((*p == '\0') || (isspace (*p)))
			   {
			   *p1 = '\0';
			   }
			else
			   {
			   ++p;

			   while ((*p) && (!isspace (*p)))
				  {
				  *p1++ = *p++;
				  }
			   *p1 = '\0';
			   }

			tpn->prelen = (int) strlen (tpn->prenum);
			tpn->suflen = (int) strlen (tpn->sufnum);
			tpn->next = NULL;
			if (pn_head == NULL)
			   {
			   pn_head = tpn;
			   }
			else
			   {
			   pn->next = tpn;
			   }
			pn = tpn;
			break;

		 case C_Event:								  /* "Event"		*/
			c = skip_blanks (&temp[5]);
			(void) parse_event (c);
			break;

		 case C_Zone:								 /* "Zone"		   */
			c = skip_blanks (&temp[4]);
			Zone = atoi (c);
			if (!Zone)							/* if we didn't find a zone  */
			   (void) printf (msgtxt[M_ILLEGAL_ZONE], &temp[4]);
			break;

		 case C_MaxReq: 							  /* "MaxReq"		*/
			c = skip_blanks (&temp[6]);
			DEFAULT.rq_Limit = atoi (c);
			if (!DEFAULT.rq_Limit)				/* No requests??? */
			   (void) printf ("0 %s\n", msgtxt[M_REQUESTS_ALLOWED]);
			break;

		 case C_LogLevel:								/* "LogLevel"	  */
			c = skip_blanks (&temp[8]);
			i = atoi (c);
			if ((i <= 5) && (i > 0))
			   {
			   loglevel = i;
			   }
			else
			   {
			   (void) printf (msgtxt[M_BAD_LOGLEVEL], &temp[8]);
			   }
			break;

		 case C_Baud:								/* "Baud"		  */
			c = skip_blanks (&temp[4]);
			temp_num = (unsigned long) atoi (c);
			max_baud.rate_value = 0;
			for (i = 0; btypes[i].rate_value; i++)
			   {
			   if (btypes[i].rate_value == temp_num)
				  {
				  max_baud.rate_mask = btypes[i].rate_mask;
				  max_baud.rate_value = temp_num;
				  break;
				  }
			   }
			if (!max_baud.rate_value)
			   goto bad_line;
			break;

		 case C_ResetPort:							   /* "ResetPort" 	 */
		 	reset_port = TRUE;
			break;

		 case C_MaxPort:							   /* "MaxPort" 	 */
			c = skip_blanks (&temp[7]);
			i = atoi (c);						 /* make it binary			  */
			if ((i > 0) && (i < 33))			 /* if range is reasonable,   */
			   MAXport = i; 					 /* Make it the max value	  */
			else
			   (void) printf (msgtxt[M_BAD_MAXPORT], &temp[7]);
			break;

		 case C_Port:							 /* "Port"		  */
			c = skip_blanks (&temp[4]);
			i = atoi (c);						 /* make it binary			  */
			if ((i > 0) || (i < 33))			 /* see if it's OK			  */
			{
			   port_ptr = i - 1;				 /* store it if so			  */
			   if (MAXport < i) 				 /* See if MAXport is less	  */
				  MAXport = i;					 /* If so, increase MAXport   */
			   original_port = port_ptr;


				ST_port = (int) Bconmap( -1);		/* ask for active PortNo */
				if ((ST_port < 0) || (ST_port > 9)) /* wenn Bconmap nicht untersttzt */
					ST_altport = ST_port = 1;
				else
				{
					ST_altport = ST_port;
					set_new_port(port_ptr+1);
				}
			}
			else
			   (void) printf (msgtxt[M_ILLEGAL_PORT], &temp[4]);
			break;

		 case C_Carrier:							   /* "Carrier" 	 */
			c = skip_blanks (&temp[7]);
			i = 0;
			(void) sscanf (c, "%x", &i);				/* convert it to binary 	 */
			if (i != 0) 						 /* if we got anything		  */
			   carrier_mask = (unsigned int) i;
			else
			   (void) printf (msgtxt[M_ILLEGAL_CARRIER], &temp[7]);
			break;

		 case C_StatusLog:								 /* "StatusLog"    */
			c = strtok(&temp[9], seperators);
			if(c)
			{
				long length = 0;
				
				p = strtok(NULL, seperators);	/* Optional length */
				if(p && isdigit(*p))
					length = atol(p);
				init_log(c, length);
			}
			break;

		 case C_Reader: 							  /* "Reader"		*/
			BBSreader = ctl_string (&temp[6]);
			break;

		 case C_BossPhone:								 /* "BossPhone"    */
			BOSSphone = ctl_string (&temp[9]);
			break;

		 case C_BossPwd:							   /* "BossPwd" 	 */
			break;

		 case C_Protocol:								/* "Protocol"	  */
			if (extern_index == 5)
			   break;
			protocols[extern_index++] = ctl_string (&temp[8]);
			break;

		 case C_System: 							  /* "System"		*/
			system_name = ctl_string (&temp[6]);
			break;

		 case C_Sysop:								 /* "Sysop" 	   */
			sysop = ctl_string (&temp[5]);
			break;

		case C_NLsystem:							/* NLsystem */
			NL_System = ctl_string(&temp[8]);
			break;

		case C_Phone:								/* "Phone" */
			NL_Phone = ctl_string(&temp[5]);
			break;
			
		case C_City:								/* "City" */
			NL_City = ctl_string(&temp[4]);
			break;
			
		case C_NLfLags:								/* "NLflags" */
			NL_Flags = ctl_string(&temp[7]);
			break;
			
		case C_NLbaud:								/* "NLbaud" */
			NL_Baud = ctl_string(&temp[6]);
			break;


		 case C_Boss:								/* "Boss"		  */
			break;

		 case C_Point:								 /* "Point" 	   */
			i = 5;
			goto address;

		 case C_Aka:							   /* "Aka" 		 */
			i = 3;
			goto address;

		 case C_Address:							   /* "Address" 	 */
			i = 7;
address:

			/* extended Address similar to The Box
			 *	address zone:net/node.point[@domain] [fakenet] [flag] [bossphone]
			 *
			 * flag is:
			 *	+ : Use 4D Addressing
			 *	* : Use FakeNet for our net
			 *
			 * This isn't very well error trapped, but neither is the
			 * rest of the stuff in here!!!
			 *
			 * Note that the address must be a single word i.e. dont leave
			 * any spaces between the "@domain"
			 */
			
			{	/* Give me some local variables */

				ADDRESS *ad = &alias[num_addrs];

				/* Set up default values */

				ad->ad.Zone = Zone;		/* or alias[0].ad.Zone */
				ad->fakenet = pvtnet;	/* or alias[0].fakenet */
				ad->phone = BOSSphone;	/* or alias[0].phone */

				/* Get the address zone:net/node.point@domain */

				p = strtok(&temp[i], seperators);
				if(p)
				{
					parse_address(p, &ad->ad);
					if(!num_addrs && !Zone)			/* Make default zone */
						Zone = ad->ad.Zone;
					p = strtok(NULL, seperators);
				}
				else
					break;
					
				/* Optional Fakenet */
				
				if(p && isdigit(*p))
				{						/* If there is any more */
					ad->fakenet = atoi(p);
					if(!num_addrs && (pvtnet != -1))	/* If this is the 1st pvtnet */
						pvtnet = ad->fakenet;			/* Then make it the default */
					p = strtok(NULL, seperators);		/* Get next word */
				}

				/* Optional flag */
				
				if(p && (*p == '+'))				/* 4D character */
				{
					ad->flags.use4d = TRUE;
					p = strtok(NULL, seperators);
				}
				else if(p && (*p == '*'))			/* Use 2D for out net */
				{
					ad->flags.usenet = TRUE;
					p = strtok(NULL, seperators);
				}

				/* Optional Boss address */
				
				if(p)
				{
					ad->phone = strdup(p);
					if(!BOSSphone && !num_addrs)		/* Make it the default */
						BOSSphone = ad->phone;
				}
#ifdef DEBUG
				/* this will only get printed if debug is set first */
			   	sprintf(junk, ">Address: %s", Pretty_Addr_Str(&ad->ad));
				if(ad->fakenet != -1U)
					sprintf(&junk[strlen(junk)], ", Fakenet: %d", ad->fakenet);
				if(ad->phone)
					sprintf(&junk[strlen(junk)], ", BOSSphone: %s", ad->phone);
				status_line(junk);
#endif				
			}
			++num_addrs;
			break;

		case C_Key:		/* Key [#alias] [%phone] [!password] [&poll_slot] address */
			/*
			 * Note that the address statement with the
			 * alias must be defined first!
			 */

			{	/* Need local variables */

				ADKEY *new = NULL;
				ADKEY newkey;	/* Temporary ADKEY */

				memset(&newkey, 0, sizeof(ADKEY));	/* Initialise newkey */

				
				for(p = strtok(&temp[3], seperators); p != NULL; p = strtok(NULL, seperators))
				{
				  switch(*p)
				  {
				 	case '#':	/* Our alias */
				      	{
							ADDR ad;
							ADDRESS *fullad;
					
							/* Search alias list for it! */
					
							if(!find_address(&p[1], &ad))	/* error */
								break;
						
							fullad = alias;
    	             		i = 0;
        	         		while(i < num_addrs)
            	     		{
	                 			if( (fullad->ad.Zone   == ad.Zone  ) &&
    	             				(fullad->ad.Net    == ad.Net   ) &&
	    	             			(fullad->ad.Node   == ad.Node  ) &&
    	    	         			(fullad->ad.Point  == ad.Point ) &&
        	    	     			(fullad->ad.Domain == ad.Domain) )
	                 			{
    	             				newkey.alias = fullad;
									break;
            	     			}
                	 			i++;
                 				fullad++;
	                 		}
    	             		if(i == num_addrs)	/* Address was not found! */
        	         		{
								status_line(msgtxt[M_KEYWARN1], Pretty_Addr_Str(&ad));
								status_line(msgtxt[M_KEYWARN2]);
								break;
	                 		}
                 	  	}
                 	  	break;
                 	

					/*
				 	 * Phone number:
					 *
					 * Format is: %[prefix/][number]
					 *
					 * e.g. %ATB1DT/012-345-67 	; prefix=ATB1DT, number=012-345-67
					 *      %ATB1DT/			; prefix=ATB1DT, number=default
					 *      %012-345-67			; prefix=default, number=012-345-67
					 */

					case '%':	/* prefix/number */
						p++;
						p1 = strchr(p, '/');	/* Seperator */
						if(p1)
						{
							*p1 = 0;
							newkey.prefix = ctl_string(p);
							p = p1+1;
						}
						if(*p)
							newkey.phone = ctl_string(p);
						break;

					case '!':	/* Password */
						newkey.password = ctl_string(&p[1]);
						break;
					
					case '&':	/* Pollslot	*/
						newkey.call_slot = p[1];
						break;
						
					default:	/* Node (with wildcards) */
						if(read_wild_ad(p, &newkey))
						{
							new = (ADKEY *) malloc(sizeof(ADKEY));	/* Make new structure */
							if(new)
							{
								memcpy (new, &newkey, sizeof(ADKEY));
								if(adkeys)
								{
									ADKEY *list = adkeys;	/* Tag it onto end of list */
									while(list->next)
										list = list->next;
									list->next = new;
								}
								else
									adkeys = new;
							}
						}
						break;
				  }
				}
#ifdef DEBUG
				sprintf(junk, ">KEY");
				if(newkey.alias)
					sprintf(&junk[strlen(junk)], " #%s", Pretty_Addr_Str(&newkey.alias->ad));
				if(newkey.prefix)
					sprintf(&junk[strlen(junk)], " prefix:%s,", newkey.prefix);
				if(newkey.phone)
					sprintf(&junk[strlen(junk)], " phone:%s,", newkey.phone);
				if(newkey.password)
					sprintf(&junk[strlen(junk)], " !%s", newkey.password);
				if(new)
					sprintf(&junk[strlen(junk)], " %s", Pretty_Addr_Str(&new->ad));
				else
					sprintf(&junk[strlen(junk)], "No address was specified!");
				status_line(junk);
#endif
			}

			break;

		 case C_Hold:								/* "Hold"		  */
			hold_area = ctl_slash_string (&temp[4]);
			if(hold_area)	/* SWG: 20 July 1991 : Stop it bombing! */
			{
				domain_area = strdup (hold_area);

				domain_area[strlen (domain_area) - 1] = '\0';
				p = strrchr (domain_area, '\\');
				if (p == NULL)
				{
					p = strrchr (domain_area, '/');
				   	if (p == NULL)
					{
						p = strrchr (domain_area, ':');
					  	if(p == NULL)
							p = domain_area;
					}
				}
				if (p != domain_area)
					++p;

				domain_loc = p;
				*p = '\0';
			}
			break;

		 case C_DownLoads:								 /* "DownLoads"    */
			download_path = ctl_slash_string (&temp[9]);
			break;

		 case C_NetFile:							   /* "NetFile" 	 */
			DEFAULT.sc_Inbound = ctl_slash_string (&temp[7]);
			break;

		 case C_FirstInit:								/* "FirstInit"		  */
			modem_firstinit = ctl_string (&temp[9]);
			break;

		 case C_Init:								/* "Init"		  */
			modem_init = ctl_string (&temp[4]);
			break;

		 case C_Reset:								/* "Reset"		  */
			modem_reset = ctl_string (&temp[5]);
			break;

		 case C_Busy:								/* "Busy"		  */
			modem_busy = ctl_string (&temp[4]);
			break;

		 case C_Prefix: 							  /* "Prefix"		*/
			predial = ctl_string (&temp[6]);
			normprefix = predial;
			break;

		 case C_NodeList:								/* "NodeList"	  */
			net_info = ctl_slash_string (&temp[8]);
			break;

		 case C_Fax:									/* "Fax"	  */
			fax_prg = ctl_string (&temp[3]);
			break;

		 case C_FaxInbound:								/* "FaxInBound"	  */
			fax_inbound = ctl_slash_string (&temp[10]);
			break;

		 case C_AfterFax:								/* "AfterFax"	  */
			afterfax_prg = ctl_string (&temp[8]);
			break;

		 case C_FaxConnect:								/* "FaxConnect"	  */
			fax_connect = ctl_string (&temp[10]);
			break;

		 case C_BTNC:
		 	nodeListType = BTNC;
		 	break;
		 	
		 case C_NodeCache:
			c = skip_blanks (&temp[9]);
			cacheSize = atoi(c);
			break;

		 case C_Avail:								 /* "Avail" 	   */
			DEFAULT.rq_FILES = ctl_string (&temp[5]);
			break;

		 case C_OKFile: 							  /* "OKFile"		*/
			DEFAULT.rq_OKFile = ctl_string (&temp[6]);
			break;

		 case C_About:								 /* "About" 	   */
			DEFAULT.rq_About = ctl_string (&temp[5]);
			break;

		 case C_MailNote:								/* "MAILnote"	  */
			MAILnote = ctl_string (&temp[8]);
			break;

		 case C_Banner: 							  /* "Banner"		*/
			BBSbanner = ctl_string (&temp[6]);
			break;

		 case C_UnAttended: 							  /* "UnAttended"	*/
			un_attended = 1;
			command_line_un = 1;
			break;

		 case C_OverWrite:								 /* "OverWrite"    */
			overwrite = 1;
			break;

		 case C_ReqOnUs:							   /* "ReqOnUs" 	 */
			on_our_nickel = 1;
			c = skip_blanks(&temp[7]);
			if(*c)
				add_to_strlist(&reqonus_list, c);
			break;

		 case C_LockBaud:								/* "LockBaud"	  */
			c = skip_blanks (&temp[8]); 		/* Skip to baud   */
			if (*c)
			   lock_baud = (unsigned) (atoi (c));
			if (!lock_baud) 					/* If none, 	  */
			   lock_baud = 1;					/* Use a small no.*/

			break;

		 case C_TimeOut:							   /* "TimeOut" 	 */
			c = skip_blanks (&temp[7]);
			BBStimeout = (unsigned) (atoi (c) * 100);
			if (BBStimeout < 2000)
			   BBStimeout = 2000;
			break;

		 case C_NoSLO:								 /* "NoSLO" 	   */
			no_overdrive = 1;
			break;

		 case C_SlowModem:								 /* "SlowModem"    */
			slowmodem = 1;
			break;

		 case C_SmallWindow:							   /* "SmallWindow"  */
			small_window = 1;
			break;

		 case C_NoPickup:								/* "NoPickup"	  */
			no_pickup = 1;
			break;

		 case C_NoRequests: 							  /* "NoRequests"	*/
			no_requests = 1;
			break;

		 case C_NetMail:							   /* "NetMail" 	 */
			break;								 /* for BTCTL & MAIL.SYS	  */

		 case C_Suffix: 							  /* "Suffix"		*/
			postdial = ctl_string (&temp[6]);
			normsuffix = postdial;
			break;

		 case C_NoFullScreen:								/* "NoFullScreen" */
			fullscreen = 0;
			break;

		 case C_SignalHandler:							/* Install SignalHandler */
		 	signalhandler = 1;
		 	break;
		 	
		 case C_AutoBaud:								/* "AutoBaud"	  */
			autobaud = 1;
			break;

		 case C_Gong:								/* "Gong"		  */
			gong_allowed = 1;
			break;

		 case C_NoCollide:								 /* "NoCollide"    */
			no_collide = 1;
			break;

		 case C_ExtrnMail:								 /* "ExtrnMail"    */
			c = skip_blanks (&temp[9]);
			if (isdigit (*c))
			   {
			   lev_ext_mail[num_ext_mail] = atoi (c);
			   while ((*c) && (!isspace (*c)))
				  ++c;
			   }
			else
			   {
			   lev_ext_mail[num_ext_mail] = 99;
			   }
			c = ctl_string(c);
			if(c)
			{
				ext_mail_string[num_ext_mail++] = c;
				while(*c)
					*c++ &= 0x7f;
			}
			break;

		 case C_BBSNote:							   /* "BBSnote" 	 */
			BBSnote = ctl_string (&temp[7]);
			break;

		 case C_BBS:							   /* "BBS" 		 */
			BBSopt = ctl_string (&temp[3]);
			break;

		 case C_ScriptPath: 							  /* "ScriptPath"	*/
			script_path = ctl_slash_string (&temp[10]);
			break;

		 case C_BoxType:							   /* "BoxType" 	 */
			c = skip_blanks (&temp[7]);
			boxtype = atoi (c);
			if ((boxtype > 4) || (boxtype < 0))
			   boxtype = 1;
			break;

		 case C_Include:							   /* "Include" 	 */
			c = skip_blanks (&temp[7]);
			parse_config (c);
			break;

		 case C_CaptureFile:							   /* "CaptureFile"  */
			logptr = ctl_string (&temp[11]);
			break;

		 case C_CursorCol:								 /* "CursorCol"    */
			c = skip_blanks (&temp[9]);
			cursor_col = atoi (c) - 1;
			if ((cursor_col < 0) || (cursor_col > 79))
			   cursor_col = 79;
			break;

		 case C_CursorRow:								 /* "CursorRow"    */
			c = skip_blanks (&temp[9]);
			cursor_row = atoi (c) - 1;
			if ((cursor_row < 0) || (cursor_row > 23))
			   cursor_row = 22;
			break;

		 case C_DoingMail:								 /* "DoingMail"    */
			c = skip_blanks (&temp[9]);
			noBBS = (char *) malloc(strlen(c) + 5);
			if(noBBS)
				sprintf(noBBS, "\r\r%s\r\r", c);
			break;

		 case C_EnterBBS:								/* "EnterBBS"	  */
			c = skip_blanks (&temp[8]);
			BBSesc = (char *) malloc(strlen(c) + 3);
			if(BBSesc)
				sprintf(BBSesc, "\r%s\r", c);
			break;

		 case C_PrivateNet: 							  /* "PrivateNet"	*/
			c = skip_blanks (&temp[10]);
			pvtnet = atoi (c);
			break;

		 case C_Packer: 							  /* "Packer"		*/
			packer = ctl_string (&temp[6]);
			break;

		 case C_Cleanup:							   /* "Cleanup" 	 */
			cleanup = ctl_string (&temp[7]);
			break;

		 case C_AfterMail:								 /* "AfterMail"    */
			aftermail = ctl_string (&temp[9]);
			break;

		 case C_Colors: 							  /* "Colors"		*/
			c = skip_blanks (&temp[6]);
			colors.background = (unsigned char) (atoi (c) & 0xff);
			c = skip_to_blank (c);
			c = skip_blanks (c);
			colors.settings = (unsigned char) (atoi (c) & 0xff);
			c = skip_to_blank (c);
			c = skip_blanks (c);
			colors.history	= (unsigned char) (atoi (c) & 0xff);
			c = skip_to_blank (c);
			c = skip_blanks (c);
			colors.hold 	= (unsigned char) (atoi (c) & 0xff);
			c = skip_to_blank (c);
			c = skip_blanks (c);
			colors.call 	= (unsigned char) (atoi (c) & 0xff);
			c = skip_to_blank (c);
			c = skip_blanks (c);
			colors.file 	= (unsigned char) (atoi (c) & 0xff);
			c = skip_to_blank (c);
			c = skip_blanks (c);
			colors.calling	= (unsigned char) (atoi (c) & 0xff);
			c = skip_to_blank (c);
			c = skip_blanks (c);
			colors.popup	= (unsigned char) (atoi (c) & 0xff);
#ifdef NEW /* COLORS  22.09.1989 */
			c = skip_blanks (c);
			c = skip_to_blank (c);
			colors.headers	= (unsigned char) (atoi (c) & 0xff);
			c = skip_blanks (c);
			c = skip_to_blank (c);
			colors.borders	= (unsigned char) (atoi (c) & 0xff);
#endif
			UseColors = TRUE;
			break;

		 case C_JanusBaud:								 /* "JanusBaud"    */
			c = skip_blanks (&temp[9]);
			janus_baud = (unsigned) atoi(c);
			break;

		 case C_ReqTemplate:							   /* "ReqTemplate"  */
			DEFAULT.rq_Template = ctl_string (&temp[11]);
			break;

		 case C_KnownAvail: 							  /* "KnownAvail"	*/
			KNOWN.rq_FILES = ctl_string(&temp[10]);
			break;

		 case C_KnownReqList:								/* "KnownReqList" */
			KNOWN.rq_OKFile = ctl_string(&temp[12]);
			break;

		 case C_KnownAbout: 							  /* "KnownAbout"	*/
			KNOWN.rq_About = ctl_string (&temp[10]);
			break;

		 case C_KnownInbound:								/* "KnownInbound" */
			KNOWN.sc_Inbound = ctl_slash_string (&temp[12]);
			break;

		 case C_KnownReqLim:							   /* "KnownReqLim"  */
			c = skip_blanks (&temp[11]);
			KNOWN.rq_Limit = atoi (c);
			break;		   

		 case C_KnownReqTpl:							   /* "KnownReqTpl"  */
			KNOWN.rq_Template = ctl_string (&temp[11]);
			break;

		 case C_ProtAvail:								 /* "ProtAvail"   */
			PROT.rq_FILES = ctl_string(&temp[9]);
			break;

		 case C_ProtReqList:							   /* "ProtReqList" */
			PROT.rq_OKFile = ctl_string(&temp[11]);
			break;

		 case C_ProtAbout:								 /* "ProtAbout"   */
			PROT.rq_About = ctl_string (&temp[9]);
			break;

		 case C_ProtInbound:							   /* "ProtInbound" */
			PROT.sc_Inbound = ctl_slash_string (&temp[11]);
			break;

		 case C_ProtReqLim: 							  /* "ProtReqLim"  */
			c = skip_blanks (&temp[10]);
			PROT.rq_Limit = atoi (c);
			break;		   

		 case C_ProtReqTpl: 							  /* "ProtReqTpl"  */
			PROT.rq_Template = ctl_string (&temp[10]);
			break;

		 case C_Application:							   /* "Application" */
			break;

		 case C_NoZones:							   /* "NoZones" 	*/
			no_zones = 1;
			break;

		 case C_Answer: 							  /* "Answer"		 */
			ans_str = ctl_string (&temp[6]);
			break;

		 case C_PollTries:								 /* "PollTries"   */
			c = skip_blanks (&temp[9]);
			poll_tries = atoi (c);
			break;

		case C_PollDelay:							/* PollDelay */
			c = skip_blanks(&temp[9]);
			poll_delay = atoi(c);				/* Specify in 10th of a second */
			break;

		 case C_CurMudgeon: 							  /* "Curmudgeon"  */
			++curmudgeon;						/* Do it like Randy */
			break;

		 case C_NoWaZOO:							   /* "NoWaZOO" 	*/
			++no_WaZOO; 						/* FTSC sessions */
			break;

		case C_NoEMSI:
			no_EMSI = TRUE;
			c = skip_blanks(&temp[6]);
			if(*c)
				add_to_strlist(&emsi_list, c);
			break;

		case C_NoRequest:
			no_REQUEST = TRUE;
			c = skip_blanks(&temp[6]);
			if(*c)
				add_to_strlist(&request_list, c);
			break;
			
		case C_NoJanus:
			no_JANUS = TRUE;
			c = skip_blanks(&temp[7]);
			if(*c)
				add_to_strlist(&janus_list, c);
			break;
		case C_IOS:
		case C_Hold4D:
			iosmode = TRUE;
			break;
		case C_UseCallSlots:								/* If true, then use CallSlots instead of Cost */
			usecallslots = TRUE;
			break;
		case C_FDBugfix:
			FDBugfix = TRUE;
			break;
		 case C_ScreenBlank:							   /* "ScreenBlank" */
			do_screen_blank = 1;
			p = skip_blanks (&temp[11]);
			if (strnicmp (p, msgtxt[M_KEY], 3) == 0)
			   {
			   blank_on_key = 1;
			   }
			else if (strnicmp (p, msgtxt[M_CALL], 4) == 0)
			   {
			   blank_on_key = 0;
			   }
			break;

		 case C_Mark_Kromm: 							  /* "Mark_Kromm"  */

			/* These colors from Mark Kromm, Fidonet 1:261/1034  */

			colors.background = 112;			/* The			 */
			colors.settings   =   9;			/* Great		 */
			colors.history	  =  10;			/* BinkleyTerm	 */
			colors.hold 	  =  11;			/* Colors		 */
			colors.call 	  =  14;			/* Contest		 */
			colors.file 	  =  12;			/* Winner!!!!	 */
			colors.calling	  =  56;
			colors.popup	  =  15;
			UseColors = TRUE;
			break;

		 case C_Server: 							  /* "Server"	   */
			server_mode = 1;
			break;

		 case C_ModemTrans: 							 /* "ModemTrans"  */
			p = &temp[10];
			while ((*p) && (isspace (*p)))
			   ++p;

			if ((*p == ';') || (*p == '\0'))
			   {
			   break;
			   }

			tmm = (MDM_TRNS *) malloc (sizeof (MDM_TRNS));

			tmm->mdm = (byte) atoi (p);
			while ((*p) && (!isspace (*p)))
			   {
			   p++;
			   }

			while ((*p) && (isspace (*p)))
			   {
			   ++p;
			   }

			p1 = tmm->pre;
			while ((*p) && (*p != '/') && (!isspace (*p)))
			   {
			   *p1++ = *p++;
			   }
			*p1 = '\0';

			p1 = tmm->suf;
			if ((*p == '\0') || (isspace (*p)))
			   {
			   *p1 = '\0';
			   }
			else
			   {
			   ++p;

			   while ((*p) && (!isspace (*p)))
				  {
				  *p1++ = *p++;
				  }
			   *p1 = '\0';
			   }

			tmm->next = NULL;
			if (mm_head == NULL)
			   {
			   mm_head = tmm;
			   }
			else
			   {
			   mm->next = tmm;
			   }
			mm = tmm;
			break;

		 case C_PreDial:							  /* "PreDial" */
			dial_setup = ctl_string (&temp[7]);
			break;

		 case C_PreInit:							  /* "PreInit" */
			init_setup = ctl_string (&temp[7]);
			break;

		 case C_DTRHigh:							  /* "DTRHigh" */
			leave_dtr_high = 1;
			break;

		 case C_Debug:								/* "Debug" */
			debugging_log = 1;      /* !debugging_log; */
			break;

		 case C_NoZedZap:							   /* "NoZedZap" */
			no_zapzed = !no_zapzed;
			break;

		 case C_NoResync:							   /* "NoResync" */
			no_resync = !no_resync;
			break;

		 case C_NoSEAlink:								/* "NoSEAlink" */
			no_sealink = !no_sealink;
			break;

		 case C_FTS_0001:							   /* "FTS-0001" */
			no_sealink = 1;
			no_resync = 1;
			no_overdrive = 1;
			++no_WaZOO; 						/* FTSC sessions */
			no_EMSI = TRUE;
			break;

		 case C_LineUpdate: 							 /* "LineUpdate" */
			immed_update = !immed_update;
			break;

		 case C_JanusOK:							  /* "JanusOK"		*/
			p = &temp[7];
			while ((*p) && (isspace (*p)))
			   ++p;

			if ((*p == ';') || (*p == '\0'))
			   {
			   break;
			   }

			tjt = (J_TYPES *) malloc (sizeof (J_TYPES));

			p1 = tjt->j_match;
			while ((*p) && (!isspace (*p)))
			   {
			   *p1++ = *p++;
			   }
			*p1 = '\0';

			tjt->next = NULL;
			if (j_top == NULL)
			   {
			   j_top = tjt;
			   }
			else
			   {
			   j_next->next = tjt;
			   }
			j_next = tjt;
			break;

		 case C_TermInit:							   /* "TermInit"	 */
			term_init = ctl_string (&temp[8]);
			break;

		case C_Domain: 							 /* "Domain"	   */
			p = skip_blanks (&temp[6]);
			p = strtok (p, seperators);
			if (p != NULL)
			{
				/* Have the domain name, now get the abbreviated name */
			   	p2 = strtok (NULL, seperators);
				if(p2)
			   	{

			   		if (strlen (p2) > 8)		/* Limit it to 8 characters */
				  		p2[8] = '\0';

				  	/* Have the domain name and abbreviated, now get the list name */

				  	p1 = strtok (NULL, seperators);
				  	if (p1 == NULL)
						p1 = p2;

					{
						char *d = find_domain(p);
						
						for(i = 0; domain_name[i]; i++)
						{
							if(d && (d == domain_name[i]))
								break;
						}
						if(i < (MAXDOMAIN-1))
						{
							if(!domain_name[i])
								domain_name[i] = strlwr(strdup(p));
							domain_nodelist[i] = strlwr(strdup(p1));
							domain_abbrev[i] = strlwr(strdup(p2));
						}
					}

			   }

			}
			break;

		 case C_Flags:								 /* "Flags" 	   */
			flag_dir = ctl_slash_string (&temp[5]);
			break;

		 case C_TaskNumber: 							  /* "Tasknumber"	*/
			c = skip_blanks (&temp[10]);
			TaskNumber = atoi (c);
			break;

		 case C_MaxBytes:								/* "MaxBytes"	  */
			c = skip_blanks (&temp[8]);
			DEFAULT.byte_Limit = atol (c);
			break;

		 case C_KnownMaxBytes:								 /* "KnownMaxBytes"*/
			c = skip_blanks (&temp[13]);
			KNOWN.byte_Limit = atol (c);
			break;

		 case C_ProtMaxBytes:								/* "ProtMaxBytes" */
			c = skip_blanks (&temp[12]);
			PROT.byte_Limit = atol (c);
			break;

		 case C_MaxTime:									/* "MaxTime"	  */
			c = skip_blanks (&temp[8]);
			DEFAULT.time_Limit = atoi (c);
			break;

		 case C_KnownMaxTime:								/* "KnownMaxTime"*/
			c = skip_blanks (&temp[13]);
			KNOWN.time_Limit = atoi (c);
			break;

		 case C_ProtMaxTime:								/* "ProtMaxTime" */
			c = skip_blanks (&temp[12]);
			PROT.time_Limit = atoi (c);
			break;

		case C_NoLineA:								/* NoLineA, force use of VT52 */
			nolinea = TRUE;
			break;
#ifdef BIOSDISPLAY
		case C_BIOSdisplay:
			BIOSdisplay = TRUE;
			break;
#endif
		case C_UseColors:
			UseColors = TRUE;
			break;
		case C_IKBDclock:								/* ikbdclock, enable IKBD update */
			ikbdclock = TRUE;
			break;
		case C_NoCTS:								/* nocts */
			ctsflow = 0;
			break;
		case C_HardCTS:								/* USe hardware CTS control */
			HardCTS = TRUE;
			break;
		case C_STlockBaud:								/* STlockBaud */
			c = skip_blanks (&temp[10]);		/* Skip to baud   */
			if (*c)
			   st_lock_baud = (unsigned) (atoi (c));
			if (!st_lock_baud)					 /* If none,	   */
			   st_lock_baud = 1;				 /* Use a small no.*/
			break;
		case C_SlowJanus:								/* SlowJanus */
			slowjanus = TRUE;
			break;
		case C_Hard38400:
			hard_38400 = TRUE;
			break;
		case C_RSVEBoard:
			rsve_board = TRUE;
			break;
		case C_Rbuf:
			c = skip_blanks(&temp[4]);
			if(*c)
				rBufSize = atoi(c);
			break;
		case C_Tbuf:
			c = skip_blanks(&temp[4]);
			if(*c)
				tBufSize = atoi(c);
			break;
		case C_TZ:											/* Timezone */
			time_zone = ctl_string (&temp[8]);
			break;
		 case C_NiceOutbound: /* 09.09.1990 */				/* "NiceOutbound" */
			niceoutbound = 1;			/* not niceoutbound++  !!! */
			break;
		 case C_ReInitTime:   /* 14.11.89 */			  /* "ReInitTime"  */
			c = skip_blanks (&temp[10]);
			reinit_time = atoi (c);
			if ((reinit_time <= 0) || (reinit_time > 15))
			   reinit_time = 10;
			reinit_ctr = reinit_time;
			break;
		 case C_ReadHoldTime: /* 10.11.89 */				/* "ReadHoldTime" */
			c = skip_blanks (&temp[12]);
			readhold_time = atoi (c);
			if ((readhold_time <= 0) || (readhold_time> 1440))
			   readhold_time = 30;
			readhold_ctr = readhold_time;
			break;
		case C_HoldsOnUs:	/* SWG 5th August */		/* "HoldsOnUs */
			HoldsOnUs = TRUE;
			c = skip_blanks(&temp[9]);
			if(*c)
				add_to_strlist(&hold_list, c);
			break;
		case C_SendRSP:		/* SWG 10th August */		/* SendRSP */
			SendRSP = TRUE;
			break;
#if defined(__PUREC__) || defined(__TURBOC__)
		case C_CLIcommand:	/* SWG 12th November 1991 */
			c = skip_blanks(&temp[10]);
			useCLIcommand = TRUE;
			if(*c)
				CLIcommand = strdup(c);
			break;
#endif
#if 0
		 case C_CostLog:							   /* "CostLog"    */
			cost_log_name = ctl_string (&temp[7]);
			if ((cost_log = fopen (cost_log_name, "a")) == NULL)
			   {
			   free (cost_log_name);
			   cost_log_name = NULL;
			   }
			break;

		 case C_NoWildcards:   /* 12.11.89 */			   /* "NoWildcards" */
			no_wildcards++;
			break;

		 case C_SuckerLimit:   /* 11.12.89 */			   /* "SuckerLimit" */
			c = skip_blanks (&temp[11]);
		if ((toupper(*c) >= 'A') && (toupper(*c) <= 'F'))
		   SuckerFlag = 1 << (toupper(*c) - 55);
			c = skip_to_blank (c);
			SuckerTimeLimit = atoi (c);
			if ((SuckerTimeLimit <= 0) || (SuckerTimeLimit > 1439))
			   SuckerTimeLimit = 1439;
			break;

		 case C_hstls2400c: /* 22.11.89 */				  /* "hstls2400c" */
			hstls2400c++;
			break;

		 case C_CostUnit: /* 28.01.90 */				/* "CostUnit" */
			c = skip_blanks (&temp[8]);
			cost_unit = atoi (c);
			break;

#endif	/* 0 */

		 case C_Tranx:									/* Tranx node */
			c = skip_blanks(&temp[5]);
			if(*c)
				add_to_strlist(&tranx_list, c);
			break;

bad_line:
		 default:
			(void) printf (msgtxt[M_UNKNOWN_LINE], temp);
		 }
	  }
   (void) fclose (stream);								/* close input file 		 */

   if (debugging_log)
	  loglevel = 6;
}

char *ctl_string( char *source )						 /* malloc & copy to ctl	  */
{
   char *c;

   c = skip_blanks (source);					 /* get over the blanks 	  */
	if(*c)	/* Avoid 0 length strings */
		return strdup(c);
	else
		return NULL;
}

static char *ctl_slash_string( char *source )			 /* malloc & copy to ctl	  */
{
   char *dest, *c;
   size_t i;
   struct stat buffer;
	int val;

   c = skip_blanks (source);					 /* get over the blanks 	  */
   i = strlen (c);								 /* get length of remainder   */
   if (i < 1)									 /* must have at least 1	  */
	  return (NULL);							 /* if not, return NULL 	  */
   dest = (char *) malloc (i + 2);				 /* allocate space for string */
   if (dest == NULL)							 /* If we failed to get it,   */
	  return (NULL);							 /* Just return NULL		  */
   strcpy (dest, c);							 /* copy the stuff over 	  */
   delete_backslash (dest); 					 /* get rid of trailing stuff */

   /* See if its a root directory, e.g. m: */

   if((strlen(dest) == 3) && (dest[2] == '\\') && (dest[1] == ':'))
   {
	 long map;
	 int drv;
	 
	 map = Dsetdrv(Dgetdrv());
	 drv = toupper(dest[0]) - 'A';
	 if((drv < 0) || (drv >= 16) || !(map & (1 << drv)))
		goto error;
   }
   else
   {
	   /* Check to see if the directory exists */

	   val = stat (dest, &buffer);

		if(val)
		{
			/* Try and create a directory */
		
			if(mkdir(dest) == 0)
			{
				printf(msgtxt[M_CREATED_DIR], dest);
		  		printf("\n");
			}
			else
			{
		  		printf (msgtxt[M_BAD_DIR], dest);
				printf ("\n%s\n", msgtxt[M_NO_CREATE_DIR]);
		  		printf (msgtxt[M_FAIL_EXEC]);
		  		return(NULL);
			}
		}
		else
		if(!(buffer.st_mode & S_IFDIR))		/* We found it but it wasnt a directory */
	   {
	   error:
		  	printf (msgtxt[M_BAD_DIR], dest);
		  	printf ("\n%s", msgtxt[M_FAIL_EXEC]);
		  	return(NULL);
	   }
	}
   (void) add_backslash (dest); 						/* add the backslash		 */
   return (dest);								 /* return the directory name */
}


char *add_backslash( char *str )
{
   char 		  *p;

   p = str + strlen (str) - 1;

   if (p >= str)
	  {
	  /* Strip off the trailing blanks */
	  while ((p >= str) && *p && (isspace (*p)))
		 {
		 *p = '\0';
		 --p;
		 }

	  /* Put a backslash if there isn't one */
	  if ((p >=str) && (*p != '\\') && (*p != '/'))
		 {
		 *(++p) = '\\';
		 *(++p) = '\0';
		 }
	  }

   return (fancy_str (str));
}

char *delete_backslash (char *str)
{
   char 		  *p;

   p = str + strlen (str) - 1;

   if (p >= str)
	  {
	  /* Strip off the trailing blanks */
	  while ((p >= str) && *p && (isspace (*p)))
		 {
		 *p = '\0';
		 --p;
		 }

	  /* Get rid of backslash if there is one */
	  if ((p >=str) && ((*p == '\\') || (*p == '/')))
		 {
		 if ((p > str) && (*(p-1) != ':'))		/* Don't delete on root */
			*p = '\0';
		 }
	  }

   return (fancy_str (str));
}

void exit_port(void)
{
	if (ST_altport>=6 && ST_altport<=9)
		Bconmap (ST_altport);
}
