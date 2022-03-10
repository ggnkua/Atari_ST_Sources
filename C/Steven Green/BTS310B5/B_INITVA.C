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
/*                   BinkleyTerm Variable Initialization                    */
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
#include <time.h>
#include <string.h>
#include <stdlib.h>

#ifdef __TURBOC__
#ifndef __TOS__
#include <mem.h>
#endif
#else
#ifdef LATTICE
/* #define tzset() _tzset() */
#else
#include <memory.h>
#endif
#endif

#include "bink.h"
#include "defines.h"
#include "msgs.h"
#include "com.h"
#include "sbuf.h"
#include "sched.h"
#include "zmodem.h"
#include "vfossil.h"

static void compile_externs (void);

/**
 ** b_initvars -- called before parse_config. Sets defaults that we want
 ** to have set FIRST.
 **/


void b_initvars ()
{
   int k;

   DEFAULT.rq_OKFile = DEFAULT.rq_FILES = DEFAULT.rq_About = DEFAULT.rq_Template = DEFAULT.sc_Inbound = NULL;
   DEFAULT.rq_Limit = 30;                        /* This seems a good default */
   DEFAULT.byte_Limit = 1000000L;
#ifdef NEW
   DEFAULT.time_Limit = 60*60;
#endif

   KNOWN.rq_OKFile = KNOWN.rq_FILES = KNOWN.rq_About = KNOWN.rq_Template = KNOWN.sc_Inbound = NULL;
   KNOWN.rq_Limit = -1;
   KNOWN.byte_Limit = -1L;
#ifdef NEW
   KNOWN.time_Limit = -1;
#endif

   PROT.rq_OKFile = PROT.rq_FILES = PROT.rq_About = PROT.rq_Template = PROT.sc_Inbound = NULL;
   PROT.rq_Limit = -1;
   PROT.byte_Limit = -1L;
#ifdef NEW
   PROT.time_Limit = -1;
#endif

   for (k = 0; k < 10; k++)                      /* Zero the phone scan list  */
      {
      scan_list[k] = NULL;
      }

   for (k = 0; k < MAX_EXTERN; k++)              /* And the external protocols*/
      {
      protocols[k] = NULL;
      }

   for (k = 1; k < ALIAS_CNT; k++)               /* And the alias list        */
      {
      alias[k].ad.Zone = alias[k].ad.Net = alias[k].ad.Node = alias[k].ad.Point = 0;
      alias[k].ad.Domain = NULL;
      }

   alias[0].ad.Zone = 0;							/* 0 means undefined */
   alias[0].ad.Net = alias[0].ad.Node = (unsigned) -1;      /* Default Fidonet address   */
   alias[0].ad.Point = 0;
   alias[0].ad.Domain = NULL;

#ifndef NEW	/* SWG: Do this during session anyway! */
   b_init ();
#endif

   baud = 2;
   cur_baud = btypes[baud].rate_value;
   command_line_un = 0;
}

/**
 ** b_defaultvars -- called after all parse_config passes complete.
 ** sets anything not handled by parse_config to default if we know it.
 **/


void b_defaultvars ()
{
  int i;
   char *p, *s;
#ifdef NEW	/* SWG: 4th July 1991 */
	ADDRESS *ad;
	ADKEY *key;
#endif

   if (!fullscreen)
      do_screen_blank = 0;

#ifndef NEW	/* Set these up statically in the data */
   if (modem_init == NULL)
      modem_init = ctl_string ("|AT|");
   if (modem_busy == NULL)
      modem_busy = ctl_string ("|AT|");

   if (net_info == NULL)
      net_info = ctl_string (".\\");
#endif

#ifndef NEW
   /* Set up "boss" and "point" addresses correctly if we can */

   if (boss_addr.ad.Zone == 0)
      boss_addr.ad.Zone = alias[0].ad.Zone;

   if (!boss_addr.ad.Net)
      {
      boss_addr.ad.Net  = alias[0].ad.Net;
      boss_addr.ad.Node = alias[0].ad.Node;
      boss_addr.ad.Domain = alias[0].ad.Domain;
      }

   my_addr = alias[0];
   if (alias[0].ad.Point)
      {
      alias[0].ad.Net   = (unsigned) pvtnet;
      alias[0].ad.Node  = alias[0].ad.Point;
      alias[0].ad.Point = 0;
#ifndef NEW	/* SWG 29jun91 : Sort out addressing properly! */
      my_addr.ad.Net = boss_addr.ad.Net;
      my_addr.ad.Node = boss_addr.ad.Node;
      my_addr.ad.Domain = boss_addr.ad.Domain;
#endif
      }
#endif

#ifdef NEW	/* SWG: 4th July 1991 [American Independance Day!] */
	/*
	 * Fill in default zone and fakenet
	 *
	 * Note that unlike the previous version, the full 4D address is stored
	 * for points rather than converting to a fakenet address
	 *
	 * this makes the following variables redundant, though I am currently
	 * still using them as defaults.
	 *
	 *	boss_addr
	 *	my_addr
	 *	pvtnet
	 *	Zone
	 *
	 * The use of privatenet, zone, bossphone and bosspwd are to be discouraged
	 * but are still left in the configuration and understand as intelligently
	 * as possible.
	 *
	 * Example:
	 *   address 252/25.7 25225 44-793-849044
	 *   address 90:1004/105
	 *   address 250/123.9
	 *   privatenet 12345
	 *   zone 2
	 *   bossphone 44-61-429-9803
	 *
	 * Would end up with the 3 addresses:
	 *
	 *   2:252 / 25.7 25225 44-793-849044
	 *  90:1004/105   12345 [irrelevant because it is not a point]
	 *   2:250 /123.9 12345 44-61-429-9803
	 *
	 * The fakenet addresses 2:25225/7 and 2:12345/9 are implied and sorted
	 * out during the call negotiation.
	 *
	 */

	i = 0;
	ad = alias;
	while(i < num_addrs)
	{
		if(ad->ad.Zone == 0)
			ad->ad.Zone = Zone;					/* or alias[o].ad.Zone */
		if(ad->fakenet == -1)
			ad->fakenet = pvtnet;				/* or alias[0].fakenet */
		if(ad->phone == NULL)
			ad->phone = BOSSphone;				/* or alias[0].phone */
		if(ad->ad.Domain == NULL)
			ad->ad.Domain = domain_name[0];		/* or alias[0].ad.Domain; */
		i++;
		ad++;
	}

	/*
	 * Make sure KEYs are set up properly as well
	 */
	
	key = adkeys;
	while(key)
	{
		if(key->ad.Zone == 0)
			key->ad.Zone = Zone;				/* alias[0].ad.Zone */
		if(key->ad.Domain == NULL)
			key->ad.Domain = domain_name[0];	/* alias[0].ad.Domain; */
		key = key->next;
	}

#ifndef MULTIPOINT
	/* Temporarily still fill in the boss_addr and my_addr */
	
	if(boss_addr.ad.Zone == 0)
		boss_addr.ad.Zone = Zone;
	if(!boss_addr.ad.Net)
		boss_addr.ad = alias[0].ad;
#endif
#ifndef MULTIPOINT
	my_addr = alias[0];
#endif

#ifndef MULTIPOINT
	/*
	 * What the hell!  Until I fix up the yoohoo and other startup stuff
	 * I'd better make up the fakenet address at least for alias[0] like
	 * the old version did
	 */
	 
	if(alias[0].ad.Point)
	{
		alias[0].ad.Net = alias[0].fakenet;
		alias[0].ad.Node = alias[0].ad.Point;
		alias[0].ad.Point = 0;
	}
#endif
#endif


   /* If we have the minimum information to do netmail, set the flag */

   if ((alias[0].ad.Zone      != 0)
   &&  (alias[0].ad.Net       != 0)
   &&  (system_name        != NULL)
   &&  (sysop              != NULL)
   &&  (hold_area          != NULL)
   &&  (DEFAULT.sc_Inbound != NULL))
   {
      net_params = 1;
      flag_file (INITIALIZE, &alias[0].ad, 0);
   }

   /* Make the "higher class" requests at least as well off as the
      "lowest class"... */

   if (KNOWN.time_Limit == -1)
      KNOWN.time_Limit = DEFAULT.time_Limit;
   if (KNOWN.byte_Limit == -1L)
      KNOWN.byte_Limit = DEFAULT.byte_Limit;
   if (KNOWN.rq_Limit == -1)
      KNOWN.rq_Limit = DEFAULT.rq_Limit;
   if (KNOWN.rq_FILES == NULL)
      KNOWN.rq_FILES = DEFAULT.rq_FILES;
   if (KNOWN.rq_OKFile == NULL)
      KNOWN.rq_OKFile = DEFAULT.rq_OKFile;
   if (KNOWN.rq_About == NULL)
      KNOWN.rq_About = DEFAULT.rq_About;
   if (KNOWN.rq_Template == NULL)
      KNOWN.rq_Template = DEFAULT.rq_Template;
   if (KNOWN.sc_Inbound == NULL)
      KNOWN.sc_Inbound = DEFAULT.sc_Inbound;

   if (PROT.time_Limit == -1)
      PROT.time_Limit = KNOWN.time_Limit;
   if (PROT.byte_Limit == -1L)
      PROT.byte_Limit = KNOWN.byte_Limit;
   if (PROT.rq_Limit == -1)
      PROT.rq_Limit = KNOWN.rq_Limit;
   if (PROT.rq_FILES == NULL)
      PROT.rq_FILES = KNOWN.rq_FILES;
   if (PROT.rq_OKFile == NULL)
      PROT.rq_OKFile = KNOWN.rq_OKFile;
   if (PROT.rq_About == NULL)
      PROT.rq_About = KNOWN.rq_About;
   if (PROT.rq_Template == NULL)
      PROT.rq_Template = KNOWN.rq_Template;
   if (PROT.sc_Inbound == NULL)
      PROT.sc_Inbound = KNOWN.sc_Inbound;

   if (!num_events)
      e_ptrs[0] = calloc (sizeof (BTEVENT), 1);

   if (extern_index)
      compile_externs ();                        /* generate extern_protocols */

   if (!colors.calling && colors.hold)
      colors.calling = ((colors.hold & 0x70) >> 4) | ((colors.hold & 0x7) << 4) | (colors.hold & 0x8);

   if ((!colors.popup) && colors.call)
      colors.popup = colors.call;

   first_block = 0;

	/* Make our domain first in the list */

#ifdef MULTIPOINT
	if(alias[0].ad.Domain && (alias[0].ad.Domain != domain_name[0]))	
#else
   	if (my_addr.ad.Domain != NULL)
#endif
    {
    	for (i = 0; domain_name[i] != NULL; i++)
        {
#ifdef MULTIPOINT
			if (domain_name[i] == alias[0].ad.Domain)
#else
         	if (domain_name[i] == my_addr.ad.Domain)
#endif
            	break;
         }

#ifdef MULTIPOINT
      	if ((i > 0) && (domain_name[i] == alias[0].ad.Domain))
#else
      	if ((i > 0) && (domain_name[i] == my_addr.ad.Domain))
#endif
        {
         	p = domain_name[0];
         	domain_name[0] = domain_name[i];
         	domain_name[i] = p;
         	p = domain_nodelist[0];
         	domain_nodelist[0] = domain_nodelist[i];
         	domain_nodelist[i] = p;
         	p = domain_abbrev[0];
         	domain_abbrev[0] = domain_abbrev[i];
         	domain_abbrev[i] = p;
       	}
   	}

	for(i = 0; domain_name[i]; i++)
	{
		if(domain_abbrev[i] == NULL)
		{
			char *s;
			domain_abbrev[i] = strdup(domain_name[i]);
			s = strchr(domain_abbrev[i], '.');
			if(s)
				*s = 0;
		}
		if(domain_nodelist[i] == NULL)
			domain_nodelist[i] = strdup("nodelist");
#ifdef DEBUG
		status_line(">Domain %s %s %s", domain_name[i], domain_abbrev[i], domain_nodelist[i]);
#endif
	}

   	set_prior(4);                                    /* Always High */

#ifdef OS_2
#ifdef Snoop
   if (getenv("SNOOPPIPE"))
	  snoop_open(getenv("SNOOPPIPE"));
#endif /* Snoop */
#endif /* OS_2  */

   if (Cominit (port_ptr) != 0x1954)
      {
      (void) printf (msgtxt[M_DRIVER_DEAD_1]);
      (void) printf (msgtxt[M_DRIVER_DEAD_2]);
      (void) printf (msgtxt[M_DRIVER_DEAD_3]);
      set_prior(2);                                 /* Regular */
	  if (reset_port) exit_port();
      exit (1);
      }

   set_prior(2);                                    /* Regular */

   i = un_attended;
   un_attended = 0;

   set_prior(4);                                    /* Always High */

   (void) set_baud (max_baud.rate_value, 0);
   un_attended = i;

   MDM_ENABLE (lock_baud && (btypes[baud].rate_value >= lock_baud) ? max_baud.rate_mask : btypes[baud].rate_mask);
   DTR_ON ();
   XON_ENABLE ();
   
   /*
   ** Send startup init sequence
   */

   if (modem_firstinit) mdm_init(modem_firstinit);
   
   set_prior(2);                                    /* Regular */

   Txbuf = Secbuf = (char *) malloc (WAZOOMAX + 16);
   if (!Txbuf)
      {
      status_line (msgtxt[M_MEM_ERROR]);
      if (reset_port) exit_port();
      exit (2);
      }

#ifdef POPBUF
   /*
    * Pointing it to the middle of the buffer allows us to pop up
    * file transfer windows if we choose to do so.
    */

   popbuf = Secbuf + 1500;
#endif

#ifdef NEW 

	/* 
	** Set global variable timezone 
	*/
	
	if (!time_zone)
	{
		/*
		** TimeZone not in BINKLEY.CFG. Try getting it from the 
		** environment
		*/
		
		if ((s = getenv ("TZ")) != NULL)
		{
			time_zone = strdup (s);
		}
	}
	
	/*
	** did we now have a setting for timezone ?
	*/
	
	if (time_zone)
	{
		/*
		** we will only accepts a GMT+x string
		*/
		
		if (strnicmp (time_zone, "GMT", 3) == 0)
		{
			timezone = 3600L * atol (time_zone+3);
		}
	}
	
	/*
	** Get RBUF/TBUF settings from the environment
	*/
	
	s = getenv("RBUF");
	if (s)
		rBufSize = atoi(s);

	s = getenv("TBUF");
	if (s)
		tBufSize = atoi(s);

#endif

		
}

static void compile_externs ()
{
   register char *c;
   register i;
   char junk[100];
   int j, k, l;
   char *p;
   char x;

   i = l = 0;                                    /* start at beginning  */
   junk [0] = '\0';

   for (k = 0; protocols[k] != NULL; k++)        /* Total no. of protos */
      {
      c = protocols[k];                          /* Point at filename   */
      if (!dexists (c))                          /* Is it there?        */
         {
         (void) printf ("%s %s\n", msgtxt[M_NO_PROTOCOL], c);
         continue;
         }
      p = NULL;
      while (*c)                                 /* Until end of string */
         {
         if ((*c == '\\') || (*c == ':'))        /* Look for last path  */
            p = c;                               /* Delimiter           */
         c++;
         }
      if (strlen (p) < 3)                        /* If no name,         */
         continue;                               /* No protocol...      */

      p++;                                       /* Point to the        */
      x = toupper (*p);                          /* First character     */
      if (strchr (junk, x) != NULL)
         {
         (void) printf ("%s %s\n", msgtxt[M_DUP_PROTOCOL], c);
         continue;
         }

      protos[l].first_char = x;                  /* Makes lookup fast   */
      protos[l++].entry = k;                     /* Now we know where   */

      junk[i++] = x;                             /* Store first char    */
      junk[i++] = ')';                           /* Then a ')'          */
      c = ++p;                                   /* Point to 2nd char   */
      for (j = 0; j < 9; j++)                    /* Up to 9 chars more  */
         {
         if (*c != '.')                          /* If no comma yet,    */
            {
            junk[i++] = tolower (*c);            /* store the char and  */
            ++c;                                 /* bump the pointer    */
            }
         else junk[i++] = ' ';                   /* otherwise pad it    */
         }
      junk[i++] = ' ';                           /* And one more space  */
      junk[i] = '\0';                            /* Need for testing    */
      }

   if (!i)                                       /* If we got none,     */
      return;                                    /* Return now.         */

   i += 2;                                       /* Total for malloc    */
   if ((extern_protocols = malloc ((size_t)i)) == NULL)  /* Allocate string     */
      return;                                    /* Return on failure   */
   (void) strcpy (extern_protocols, junk);              /* Copy the string     */
   return;                                       /* Back to caller      */
}



/**
 ** b_exitproc -- called by mainline to do exit processing.
 **/

void b_exitproc ()
{
   if (command_line_un)
      {
      set_prior(4);                                    /* Always High */
      mdm_init (modem_reset);
      /*mdm_init (modem_busy);*/
      exit_DTR ();
      set_prior(2);                                    /* Regular */
      }

   vfossil_cursor (1);

   while (KEYPRESS ())
      {
      (void) FOSSIL_CHAR ();
      }

   gotoxy (0, SB_ROWS);
   clear_eol ();
   (void) printf (msgtxt[M_THANKS], ANNOUNCE);
   clear_eol ();
   (void) printf (msgtxt[M_ANOTHER_FINE_PRODUCT]);

   if (vfossil_installed)
      vfossil_close ();

   if (!share) {
      set_prior(4);                                    /* Always High */
      MDM_DISABLE ();
      set_prior(2);                                    /* Regular */
   }
}

