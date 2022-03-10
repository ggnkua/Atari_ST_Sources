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
/*			 This module was originally written by Bob Hartman				*/
/*																			*/
/*																			*/
/*			 BinkleyTerm "Main" Module: Terminal Emulation and				*/
/*						 File Transfer dispatching							*/
/*																			*/
/*																			*/
/*						 BinkleyTerm Licensing Terms						*/
/*																			*/
/*																			*/
/* (C) Copyright 1987-90 Bit Bucket Software Co., a Delaware Corporation.	*/
/* ALL RIGHTS RESERVED. COMMERCIAL DISTRIBUTION AND/OR USE PROHIBITED		*/
/* WITHOUT WRITTEN PERMISSION FROM BIT BUCKET SOFTWARE CO.					*/
/*																			*/
/* Non-Commercial distribution and/or use is permitted under the following	*/
/* terms:																	*/
/*																			*/
/*																			*/
/* 1. You may copy and distribute verbatim copies of BinkleyTerm source,	*/
/* documentation, and executable code as you receive it, in any medium, 	*/
/* provided that you conspicuously and appropriately publish on each copy a */
/* valid copyright notice "(C) Copyright 1987-90, Bit Bucket Software Co."; */
/* keep intact the notices on all files that refer to this License			*/
/* Agreement and to the absence of any warranty;  PROVIDE UNMODIFIED COPIES */
/* OF THE DOCUMENTATION AS PROVIDED WITH THE PROGRAM; and give any other	*/
/* recipients of the BinkleyTerm program a copy of this License Agreement	*/
/* along with the program.	You may charge a distribution fee for the		*/
/* physical act of transferring a copy, but no more than is necessary to	*/
/* recover your actual costs incurred in the transfer. Under no 			*/
/* circumstances is BinkleyTerm to be distributed in such a way as to be	*/
/* construed as "value added" in a sales transaction, such as, but not		*/
/* limited to, software bundled with a modem or CD-ROM software 			*/
/* collections. 															*/
/*																			*/
/* 2. You may modify your copy or copies of BinkleyTerm or any portion of	*/
/* it, and copy and distribute such modifications under the terms of		*/
/* Paragraph 1 above, provided that you also do the following:				*/
/*																			*/
/*	   a) cause the modified files to carry prominent notices stating		*/
/*	   that you changed the files and the date of any change;				*/
/*																			*/
/*	   b) cause the executable code of such modified version to clearly 	*/
/*	   identify itself as such in the course of its normal operation;		*/
/*																			*/
/*	   c) if the modified version is not a "port", but operates in the		*/
/*	   same hardware and/or software environment as the original			*/
/*	   distribution, make the original version equally available,			*/
/*	   clearly identifying same as the original, unmodified version;		*/
/*																			*/
/*	   d) cause the whole of any work that you distribute or publish,		*/
/*	   that in whole or in part contains or is a derivative of				*/
/*	   BinkleyTerm or any part thereof, to be licensed at no charge to		*/
/*	   all third parties on terms identical to those contained in this		*/
/*	   License Agreement (except that you may choose to grant more			*/
/*	   extensive warranty protection to some or all third parties, at		*/
/*	   your option); and													*/
/*																			*/
/*	   e) send the complete source code modifications to Bit Bucket 		*/
/*	   Software Co. at one of the addresses listed below,  for the			*/
/*	   purpose of evaluation for inclusion in future releases of			*/
/*	   BinkleyTerm.  Should your source code be included in BinkleyTerm,	*/
/*	   Bit Bucket Software Co. retains all rights for redistribution of 	*/
/*	   the code as part of BinkleyTerm and all derivative works, with		*/
/*	   appropriate credit given to the author of the modification.			*/
/*																			*/
/*	   f) You may charge a distribution fee for the physical act of 		*/
/*	   transferring a copy, but no more than is necessary to recover		*/
/*	   your actual costs incurred in the transfer, and you may at your		*/
/*	   option offer warranty protection in exchange for a fee.				*/
/*																			*/
/* 3. Mere aggregation of another unrelated program with this program and	*/
/* documentation (or derivative works) on a volume of a storage or			*/
/* distribution medium does not bring the other program under the scope of	*/
/* these terms. 															*/
/*																			*/
/* 4. You may copy and distribute BinkleyTerm and its associated			*/
/* documentation (or a portion or derivative of it, under Paragraph 2) in	*/
/* object code or executable form under the terms of Paragraphs 1 and 2 	*/
/* above provided that you also do one of the following:					*/
/*																			*/
/*	   a) accompany it with the complete corresponding machine-readable 	*/
/*	   source code, which must be distributed under the terms of			*/
/*	   Paragraphs 1 and 2 above; or,										*/
/*																			*/
/*	   b) accompany it with a written offer, valid for at least three		*/
/*	   years, to give any third party free (except for a nominal			*/
/*	   shipping charge) a complete machine-readable copy of the 			*/
/*	   corresponding source code, to be distributed under the terms of		*/
/*	   Paragraphs 1 and 2 above; or,										*/
/*																			*/
/*	   c) accompany it with the information you received as to where		*/
/*	   the corresponding source code may be obtained.  (This				*/
/*	   alternative is allowed only for noncommercial distribution and		*/
/*	   only if you received the program in object code or executable		*/
/*	   form alone.) 														*/
/*																			*/
/* For an executable file, complete source code means all the source code	*/
/* for all modules it contains; but, as a special exception, it need not	*/
/* include source code for modules which are standard libraries that		*/
/* accompany the operating system on which the executable file runs.		*/
/*																			*/
/* 5. You may not copy, sublicense, distribute or transfer BinkleyTerm and	*/
/* its associated documentation  except as expressly provided under this	*/
/* License Agreement.  Any attempt otherwise to copy, sublicense,			*/
/* distribute or transfer BinkleyTerm is void and your rights to use the	*/
/* program under this License agreement shall be automatically terminated.	*/
/* However, parties who have received computer software programs from you	*/
/* with this License Agreement will not have their licenses terminated so	*/
/* long as such parties remain in full compliance, and notify Bit Bucket	*/
/* Software Co. of their intention to comply with this Agreement.			*/
/*																			*/
/* 6. If you wish to incorporate parts of BinkleyTerm into other free		*/
/* programs whose distribution conditions are different, please contact 	*/
/* Bit Bucket Software Co. at one of the addresses listed below.  We have	*/
/* not yet worked out a simple rule that can be stated here, but we will	*/
/* usually permit this.  We will be guided by the two goals of preserving	*/
/* the free status of all derivatives of our free software (as it pertains	*/
/* to Non-Commercial use as provided by this Agreement) and of promoting	*/
/* the sharing and reuse of software.										*/
/*																			*/
/* 7. For the purposes of this document, "COMMERCIAL USE" is defined as 	*/
/* operation of the software on four or more computers or data lines owned	*/
/* by the same for-profit organization. Any organization may operate this	*/
/* software under the terms of this Non-Commercial Agreement if operation	*/
/* is limited to three or less computers or data lines. 					*/
/*																			*/
/*																			*/
/*								  NO WARRANTY								*/
/*																			*/
/* BECAUSE BINKLEYTERM IS LICENSED FREE OF CHARGE, WE PROVIDE ABSOLUTELY NO */
/* WARRANTY.  EXCEPT WHEN OTHERWISE STATED IN WRITING, BIT BUCKET SOFTWARE	*/
/* CO. AND/OR OTHER PARTIES PROVIDE BINKLEYTERM "AS IS" WITHOUT WARRANTY OF */
/* ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO,	*/
/* THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR	*/
/* PURPOSE.  THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF			*/
/* BINKLEYTERM, AND THE ACCURACY OF ITS ASSOCIATED DOCUMENTATION, IS WITH	*/
/* YOU.  SHOULD BINKLEYTERM OR ITS ASSOCIATED DOCUMENTATION PROVE			*/
/* DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR 	*/
/* CORRECTION.																*/
/*																			*/
/* IN NO EVENT WILL BIT BUCKET SOFTWARE CO. BE RESPONSIBLE IN ANY WAY FOR	*/
/* THE BEHAVIOR OF MODIFIED VERSIONS OF BINKLEYTERM. IN NO EVENT WILL		*/
/* BIT BUCKET SOFTWARE CO. AND/OR ANY OTHER PARTY WHO MAY MODIFY AND		*/
/* REDISTRIBUTE BINKLEYTERM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR		*/
/* DAMAGES, INCLUDING ANY LOST PROFITS, LOST MONIES, OR OTHER SPECIAL,		*/
/* INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY	*/
/* TO USE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING RENDERED */
/* INACCURATE OR LOSSES SUSTAINED BY THIRD PARTIES OR A FAILURE OF THE		*/
/* PROGRAM TO OPERATE WITH ANY OTHER PROGRAMS) BINKLEYTERM, EVEN IF YOU 	*/
/* HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES, OR FOR ANY CLAIM	*/
/* BY ANY OTHER PARTY.														*/
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
/*																			*/
/* Please feel free to contact us at any time to share your comments about	*/
/* our software and/or licensing policies.									*/
/*																			*/
/* Our thanks to Richard Stallman and the Free Software Foundation, Inc.,	*/
/* for most of the wording of this License. 								*/
/*																			*/
/*--------------------------------------------------------------------------*/

#include <stdio.h>
#include <signal.h>
#include <ctype.h>
#include <string.h>

#ifdef LATTICE
#include <dos.h>
#else
#include <process.h>
#endif

#include <stdlib.h>

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
#include "sbuf.h"
#include "vfossil.h"
#include "com.h"
#ifdef NEW
#include "session.h"
#endif

static void handler (int);

static struct parse_list DOS_commands[] = {
	{  7, "noforce"		},
	{  4, "mail"		},
	{  5, "share"		},
	{  5, "dynam"		},
	{ 10, "unattended"	},
	{  6, "config"		},
	{  4, "poll"		},
#ifdef NEW
	{  5, "batch"		},
	{  7, "connect" 	},
	{ 12, "nofullscreen"},
#endif
	{  0, NULL			}
};

enum {
	P_NONE,
	P_NOFORCE,
	P_MAIL,
	P_SHARE,
	P_DYNAM,
	P_UNATTENDED,
	P_CONFIG,
	P_POLL,
	P_BATCH,
	P_CONNECT,
	P_NOFULLSCREEN,
	P_LAST
} PARAMETERS;


void main (int argc, char *argv[])
{
   int done;
   char *envptr;
   int mail_only = 0;							 /* if 1, do mail and exit	   */
   ADDR baddr;
   long init_timer;
#ifdef NEW
   	char *connectString = NULL;
#endif

	load_language ();

	if (signalhandler)
	{
		if (signal(SIGINT, handler) == SIG_ERR)
		{
			fprintf(stderr, msgtxt[M_NO_SIGINT]);
			return;
		}
		signal(SIGINT, SIG_IGN);
	}
	
   (void) printf (ANNOUNCE);
   (void) printf ("\n(C) Copyright 1987-90, Bit Bucket Software, Co. ALL RIGHTS RESERVED.\n\n");
#ifdef ATARIST
	printf("Atari ST conversion by STeVeN Green FidoNet 2:255/355, NeST 90:1004/1004\n");
	printf("Features since 3.02a/Beta-8 by Joerg Spilker FidoNet 2:243/6207, NeST 90:4/0\n");
	printf("Optimized RS232-Routines by Uwe Zerbe FidoNet 2:246/1414, NeST 90:400/203\n");
	printf("Optimized ZModem and Janus-Routines by Stephan Slabihoud FidoNet 2:2401/103.6\n");
	printf("Fax support by Helmut Neumann FidoNet 2:2405/6.9\n");
	printf("ST/TT/Falcon support by Michael Ziegler FidoNet 2:246/170.5\n");
	printf("RSVE support by Wolfgang Zweygart, 2:246/1104\n");

#endif
#if defined(LATTICE)
	printf("Compiled with Lattice C5\n");
#elif defined(__PUREC__)
	printf("Compiled with Pure C V1.10\n");
#elif defined(__TURBOC__)
	printf("Compiled with Turbo C V%x.%02x\n",
		__TURBOC__ / 0x100, __TURBOC__ & 0xff);
#endif
#ifdef DEBUG
	printf("Debug Version, ");
#endif
	printf(ver_stuff);
   (void) printf (msgtxt[M_SYSTEM_INITIALIZING]);
   init_timer = timerset (200);

   b_initvars ();

   while (--argc > 0)
	  {
	  ++argv;

	  switch (parse (argv[0], DOS_commands))
		 {
		 case P_NOFORCE:								/* Noforce	  */
			noforce = 1;
			break;

		 case P_MAIL:								/* Mail 	  */
			++mail_only;
			break;

		 case P_SHARE:								/* Share	  */
			++share;
			break;

		 case P_DYNAM:								/* Dynam	  */
			++redo_dynam;
			break;

		 case P_UNATTENDED:								/* Unattended */
			un_attended = 1;
			command_line_un = 1;
			break;

		 case P_CONFIG:								/* Config	  */
			config_name = argv[1];
			--argc;
			++argv;
			break;

		 case P_POLL:								/* Poll 	  */
			if (parse_address(argv[1], &baddr))
			   {
			   doing_poll = 1;
			   }
			--argc;
			++argv;
			break;
		
#ifdef NEW
		 case P_BATCH:
		 	++batch_mode;
		 	break;
		 case P_CONNECT:
		 	if(argc > 1)
		 	{
			 	connectString = argv[1];
			 	argv++;
			 	argc--;
			}
		 	break;
		 case P_NOFULLSCREEN:
		 	fullscreen = 0;
		 	break;
#endif

		 default:								/* Not there  */
			(void) printf (msgtxt[M_UNRECOGNIZED_OPTION], argv[0]);
			exit_port();
			exit (1);
		 }
	  }

   envptr = getenv ("BINKLEY"); 				 /* get path from environment */
   if ((envptr != NULL) 						 /* If there was one, and	  */
	   && (!dexists (config_name))) 			 /* No BINKLEY.CFG locally,   */
	  {
	  BINKpath = malloc (strlen (envptr) + 2);	 /* make room for new */
	  (void) strcpy (BINKpath, envptr); 				/* use BINKLEY as our path	 */
	  (void) add_backslash (BINKpath);
	  }

   read_sched ();

	if (init_driver()<0x0102)
		{	fprintf(stderr,"\n Wrong devicedriver. Try a newer one...\n");
			return;
		}

   parse_config ("Binkley.Evt");
   parse_config (config_name);

	if (set_driver()<0x0102)
		{	fprintf(stderr,"\n Wrong devicedriver. Try a newer one...\n");
			return;
		}


   b_defaultvars ();


   (void) LoadScanList (0,0);						/* Get default scan list */

   /* We expect this to fail right away, but in order to keep the copyright
	  notice displayed long enough, we check anyway */

   while (!timeup (init_timer))
		;

   done = 0;

   vfossil_init();	
   if (fullscreen)
	  b_sbinit ();

   if (mail_only)
	  {
	  doing_poll = 1;
#ifdef MULTIPOINT
		baddr = alias[0].ad;	/* Make up our Boss's address */
		baddr.Point = 0;
#else
	  baddr = boss_addr.ad;
#endif		
	  }

#ifdef NEW

/*
 * Batch Mode operation
 *
 * Carrier should be present when it is called
 * It will do an inbound mail session and the exit with an errorlevel
 *
 *  0 = nomail
 * -1 or 255 = Carrier was lost
 *  Other values depend on what is set in the event file
 */

	if (batch_mode)
	{
		FILE *tfile;
		
		un_attended = 1;
	  	opening_banner ();
	  	mailer_banner ();
	  	if (fullscreen)
		{
			sb_fill (holdwin, ' ', colors.hold);
		 	sb_move (holdwin, 2, 4);
		 	sb_puts (holdwin, "Incoming Batch Mode");
		 	sb_show ();
		}

		if ((tfile = fopen ("BINKLEY.BAN", read_binary)) != NULL)
		{
			fread (BBSwelcome, 1, 1000, tfile);
			fclose (tfile);
		}
		else
			BBSwelcome[0] = '\0';

		find_event();

		if(connectString)
			setModemValues(connectString);

	  	set_prior(4); 								   /* Always High */
	  	if (!CARRIER)
	  	{
	  		status_line(":Batch Mode: No Carrier, exitting with level -1");
	  		errl_exit(-1);							/* No carrier */
	  	}
		b_session (0);		                             /* do a mail session      */
		mdm_hangup ();		                             /* Make sure to hang up   */

		/*
		 * Exit with errorlevels depending on what happened
		 *  0 = No mail was received
		 * otherwise it will depend on the events errorlevel
		 */

		if (got_arcmail || got_packet || got_mail)
			receive_exit ();
		else
			errl_exit(0);
	}
	else
#endif

   if (doing_poll)
	  {
#ifndef NEW	/* Let something else expand it later */
	  if (baddr.Zone == 0)
		 baddr.Zone = (int) alias[0].ad.Zone;
#endif
	  un_attended = 1;
	  opening_banner ();
	  mailer_banner ();
	  if (fullscreen)
		 {
		 sb_fill (holdwin, ' ', colors.hold);
		 sb_move (holdwin, 2, 12);
		 sb_puts (holdwin, msgtxt[M_POLLING_COLON]);
		 (void) sprintf (junk, "%s", Pretty_Addr_Str (&baddr));
		 junk[28] = '\0';
		 sb_move (holdwin, 4, 16 - (int)strlen(junk) / 2);
		 sb_puts (holdwin, (unsigned char *) junk);
		 sb_show ();
		 }
	  set_prior(4); 								   /* Always High */
	  if (!CARRIER)
		 mdm_hangup ();
	  (void) do_mail (&baddr, 1);
	  set_prior(2); 								   /* Regular */
	  done = 1;
	  }
   else if (!un_attended)
	  {
	  opening_banner ();
	  }

   while (!done)
	  {
	  if (un_attended)
		 {
		 done = unattended ();
		 un_attended = 0;
		 }
	  else
		 {
		 done = b_term ();
		 un_attended = 1;
		 }
	  } 		

   b_exitproc ();
	 exit_port();
   exit (1);
}

static void handler(int sig)	/* Function called at system interrupt */
{
	signal(SIGINT, SIG_IGN); 	/* Disallow CTRL + C during handler   */

	ctrlc_ctr++;

	signal(SIGINT, handler); 	/* This is necessary so that the
								** next CTRL+C interrupt will call
								** "handler", since the DOS 3.x
								** operating system resets the
								** interrupt handler to the
								** system default after the
								** user-defined handler is called
								*/
}