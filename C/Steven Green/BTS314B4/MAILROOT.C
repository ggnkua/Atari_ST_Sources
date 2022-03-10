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
/*                 This module was written by Bob Hartman                   */
/*                                                                          */
/*                                                                          */
/*                   BinkleyTerm Mail Control Routines                      */
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
#ifndef __TOS__
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <dos.h>
#endif
#include <string.h>
#include <time.h>
#ifndef LATTICE
#include <process.h>
#endif
#include <stdlib.h>
#ifndef LATTICE
#include <io.h>
#endif

#include "bink.h"
#include "msgs.h"
#include "com.h"
#include "sched.h"
#include "sbuf.h"
#include "session.h"
#include "defines.h"
#include "vfossil.h"
#include "nodeproc.h"

static char *estring (int, int);

int do_mail( ADDR *baddr, int manual )
{
	long callstart, callend;
    long call_cost, call_cost_ths;
    long eh, em, es;

	caller = 1;
	b_init();

	no_WaZOO_Session = 0;
	sprintf (junk, "%s", Full_Addr_Str (baddr));
	remote_addr.Zone = baddr->Zone;
	remote_addr.Net = baddr->Net;
	remote_addr.Node = baddr->Node;
	remote_addr.Point = baddr->Point;
	remote_addr.Domain = baddr->Domain;
	called_addr.Zone = baddr->Zone;
	called_addr.Net = baddr->Net;
	called_addr.Node = baddr->Node;
	called_addr.Point = baddr->Point;
	called_addr.Domain = baddr->Domain;

	no_Janus_Session = check_nojanus (&called_addr, (char**) NULL);
	
	if (!net_params)
	{
		status_line (msgtxt[M_INSUFFICIENT_DATA]);
		/*set_xy ("");*/
		return (0);
	}

	if (!nodeproc (junk))
		return (0);

	if (manual)
	{
		if (flag_file (TEST_AND_SET, &called_addr, 1))
		{
			if (CARRIER)
				mdm_hangup ();
			return (0);
		}

		if (CARRIER)			                               /* called manually maybe? */
			goto process_the_damned_mail;		           /* yup, just do some mail */


		do_dial_strings ();
		try_2_connect ((char *) (newnodedes.PhoneNumber));		    /* try to connect         */
	}
	else
	{
		/* 
		** Check for cost. If UseCallSlots is set, take them
		*/
		
		if (usecallslots)
		{
			/*
			if (!strchr (e_ptrs[cur_event]->call_slot, (int)newnodedes.RealCost))
				return (0);
			*/
		}
		else
		{
			/* If this is supposed to be only local, then get out if it isn't */
			if (e_ptrs[cur_event]->behavior & MAT_LOCAL)
			{
				if (e_ptrs[cur_event]->node_cost < 0)
				{
					if ((int) newnodedes.RealCost < -e_ptrs[cur_event]->node_cost)
					{
						return (0);
					}
				}
				else
				{
					if ((int) newnodedes.RealCost > e_ptrs[cur_event]->node_cost)
					{
						return (0);
					}
				}
			}
		}
		
		/* If it is supposed to be 24 hour mail only, get out if it isn't */
#ifndef ATARIST
		if (newnodelist && (!(e_ptrs[cur_event]->behavior & MAT_NOMAIL24))
			&& (!(newnodedes.NodeFlags & B_CM)))
#else
		if ( !(e_ptrs[cur_event]->behavior & MAT_NOMAIL24)
		    && !(newnodedes.NodeFlags & B_CM) )
#endif
			return (0);
		/* If we aren't supposed to send to CM's now, get out */
#ifndef ATARIST
		if (newnodelist && (e_ptrs[cur_event]->behavior & MAT_NOCM)
			&& (newnodedes.NodeFlags & B_CM))
#else
		if ( (e_ptrs[cur_event]->behavior & MAT_NOCM)
			&& (newnodedes.NodeFlags & B_CM))
#endif
			return (0);
		/* Try to connect */

		if (flag_file (TEST_AND_SET, &called_addr, 1))
		{
			if (CARRIER)
				mdm_hangup ();
			return (0);
		}

		do_dial_strings ();
		if (un_attended && fullscreen)
		{
			sb_move (holdwin, 2, 1);
			sb_wa (holdwin, colors.calling, 31);
		}

		callstart = time (NULL);

		if (try_1_connect ((char *) (newnodedes.PhoneNumber)) == -1)
		{
			if (un_attended && fullscreen)
			{
				sb_move (holdwin, 2, 1);
				sb_wa (holdwin, colors.hold, 31);
			}
			flag_file (CLEAR_FLAG, &called_addr, 1);
			return (-1);
		}
	}

process_the_damned_mail:

	if (CARRIER)		                                  /* if we did,             */
	{
		screen_blank = 0;

		if (manual)
			callstart = time (NULL);

		b_session (1);		                             /* do a mail session      */
		flag_file (CLEAR_FLAG, &called_addr, 1);		      /* make sure flag is gone */

		callend = time (NULL);
        hist.last_Elapsed = callend - callstart;

        eh = (callend - callstart) / 3600L;
        em = ((callend - callstart) / 60L) - (eh * 60L);
        es = (callend - callstart) - (eh * 3600L) - (em * 60L);

        hist.callcost += (call_cost = cost_of_call (callstart, callend));

        call_cost_ths = call_cost % 100L;               /* Separate dollars & */
        call_cost = call_cost / 100L;                   /* cents for formats  */

        status_line (msgtxt[M_NODE_COST], Full_Addr_Str (baddr), 
                        eh, em, es, call_cost, call_cost_ths);

		mdm_hangup ();

		++hist.connects;
		if (un_attended && fullscreen)
		{
			sb_move (historywin, HIST_CONN_ROW, HIST_COL);
			(void) sprintf (junk, "%d/%ld", hist.connects, hist.callcost);
			sb_puts (historywin, (unsigned char *) junk);
		}

		write_stats ();

		if (un_attended && (got_arcmail || got_packet || got_mail))
		{
			(void) bad_call (baddr, BAD_REMOVE);
			receive_exit ();
		}

		/* Remove any $$ files for any akas that were sent with EMSI */

		if(sent_mail)
		{
			ADDR_LIST *ads = remote_ads.next;
			while(ads)
			{
				ADDR_LIST *next = ads->next;
				bad_call(&ads->ad, BAD_REMOVE);
				ads = next;
			}
		}

		if (un_attended && fullscreen)
		{
			sb_move (holdwin, 2, 1);
			sb_wa (holdwin, colors.hold, 31);
		}
		return (1);
	}
	else
	{
		status_line (msgtxt[M_END_OF_ATTEMPT]);
		flag_file (CLEAR_FLAG, &called_addr, 1);
	}
	if (un_attended && fullscreen)
	{
		sb_move (holdwin, 2, 1);
		sb_wa (holdwin, colors.hold, 31);
	}
	write_stats ();
	return (2);
}

int handle_inbound_mail( void )
{
	long t;	                          /* used for the timeouts  */
	int mr;	                                       /* Modem response */


	caller = 0;
	b_init();

inloop:

	if (!(server_mode && CARRIER) && !CHAR_AVAIL ())		           /* Any action from modem? */
	{
		time_release ();
		return (0);		                                /* No, nothing to do      */
	}

#ifdef NEVER /* should not need this any more */

	/* if outbound only, then return */
	if ((cur_event >= 0) && (e_ptrs[cur_event]->behavior & MAT_OUTONLY))
	{
		time_release ();
		return (0);
	}

#endif

	mail_only = 1;
	if ((cur_event >= 0) && (e_ptrs[cur_event]->behavior & MAT_BBS))
		mail_only = 0;

should_answer:

	screen_blank = 0;

	if (un_attended && fullscreen)
		sb_show ();

	if (server_mode && CARRIER)
		goto got_carrier;

	if (((mr = modem_response (500)) == 3) && (ans_str != NULL))		      /* RING detected */
	{
		 /*
		 * Try to make sure we don't send out the answer string while stuff is
		 * still coming from the modem.  Most modems don't like that kind of
		 * sequence (including HST's!). 
		 */
		 
		t = timerset (100);
		while (CHAR_AVAIL () && (!timeup (t)))
		{
			t = timerset (100);
			(void) MODEM_IN ();
		}
		CLEAR_INBOUND ();
		mdm_cmd_string (ans_str, 0);               /* transmit the answer
		                                                  * string */
        
		goto should_answer;
	}
	else if (mr != 2 && mr != 5)									/* NOT connect */
	{
		if (un_attended && fullscreen) 
			do_ready ("Ring");

		t = timerset (6000);		                       /* 1 minute               */
		while ((!timeup (t))
			&& (!CHAR_AVAIL ())
			&& (!KEYPRESS ()))
			time_release ();		                        /* wait for another result */
		if (KEYPRESS ())			                           /* If aborted by user,    */
		{
			/* Reinit modem after failure, SWG 24th June 1991 */

			mdm_hangup();
			FOSSIL_CHAR();
			return 1;
		}
		
	    t = timerset (3000);
	    while (!timeup(t))
	    {
	    if (CARRIER)
	    goto inloop;
	    }
	    goto got_carrier;
	    	
/*		goto inloop; */		                               /* else proceed along     */
	}

got_carrier:

	if (mr == 5)							/* Fax connects don't set DCD */
		call_fax ();
	else
		if (CARRIER)						/* if we have a carrier,  */
		{
			b_session (0);					/* do a mail session      */
		
			/* We got inbound mail */
			if (got_arcmail || got_packet || got_mail)
				receive_exit();
		}

	mdm_hangup();
	
	return (1);
}

void receive_exit( void )
{
	char junk1[150];
	int i;

	if (got_arcmail && (cur_event >= 0) && (e_ptrs[cur_event]->errlevel[2]))
	{
		status_line (msgtxt[M_EXIT_COMPRESSED],
		e_ptrs[cur_event]->errlevel[2]);

		errl_exit(e_ptrs[cur_event]->errlevel[2]);
	}

	if (cur_event >= 0)
	{
		for (i = 0; i < 6; i++)
		{
			if (user_exits[i])
			{
				status_line (msgtxt[M_EXIT_AFTER_EXTENT],
				&(e_ptrs[cur_event]->err_extent[i][0]),
				e_ptrs[cur_event]->errlevel[i + 3]);
				errl_exit (e_ptrs[cur_event]->errlevel[i + 3]);
			}
		}
	}

	if ((got_mail || got_packet) &&
		(cur_event >= 0) && (e_ptrs[cur_event]->errlevel[1]))
	{
		status_line (msgtxt[M_EXIT_AFTER_MAIL],
		e_ptrs[cur_event]->errlevel[1]);

		errl_exit (e_ptrs[cur_event]->errlevel[1]);
	}

	if ((aftermail != NULL) && (got_mail || got_packet || got_arcmail))
	{
		status_line (msgtxt[M_AFTERMAIL]);
		mdm_init (modem_busy);
		exit_DTR ();
		screen_clear ();
		vfossil_cursor (1);
		(void) strcpy (junk1, aftermail);
		if (cur_event >= 0)
			(void) strcat (junk1, e_ptrs[cur_event]->cmd);
		close_up ();
		b_spawn (junk1);
		come_back ();
		DTR_ON ();
		status_line (msgtxt[M_OK_AFTERMAIL]);
		mdm_init (modem_init);
	}

	/* b_init(); */	/* Dont clear this at all!!!! */
}

void errl_exit( int n )
{
	write_sched ();

	status_line ("+%s, %s", msgtxt[M_END], xfer_id);
	mdm_init (modem_busy);	                        /* Reinitialize the modem  */
	exit_DTR ();
	/*SCB*/ if (fullscreen)
		gotoxy (0, SB_ROWS);

	if (vfossil_installed)
		vfossil_close ();

	if (!share)
		MDM_DISABLE ();
	if (reset_port)
		exit_port();
	
	exit(n);
}


/*
 * return directory where outbound stuff for maddr should be found
 *
 * This is:
 *	hold\      : Default Zone
 *  hold.zzz\  : Other zone in our domain
 *  domainarea\abrev[.zzz]\
 */

char *HoldAreaNameMunge( ADDR *maddr )
{
	static char munged[80];
	register char *p, *q;
	int i;

	ADDRESS *ad;
	char *domain;

	/*
	 * If address hasn't got a domain and we are using domains then try to
	 * guess where the mail might be!  Basically compare zones with our
	 * aliases
	 *
	 * Or if the other guy is using our default domain consider that he might
	 * have that as the only domain.
     */
    
	ad = &alias[0];
	domain = maddr->Domain;

	/* If we are using Domains and the other guy isn't or is using our default */

	if(ad->ad.Domain && !domain)
	{
		domain = ad->ad.Domain;			/* Default domain */
		i = 0;
		while(i < num_addrs)
		{
			if(ad->ad.Zone == maddr->Zone)
			{
				domain = ad->ad.Domain;
				break;
			}
			i++;
			ad++;
		}
	}

	if (domain && (domain != alias[0].ad.Domain))
	{
		*domain_loc = '\0';
		strcpy (munged, domain_area);
		q = &munged[strlen (munged)];
		for (i = 0; domain_name[i] != NULL; i++)
		{
			if(domain_name[i] == domain)
			{
				if (domain_abbrev[i] != NULL)
				{
					p = domain_abbrev[i];
					while (*p)
						*q++ = *p++;
					if (no_zones)
						(void) sprintf (q, "\\");
					else
						(void) sprintf (q, ".%03x\\", maddr->Zone);
				}
				break;
			}
		}
	}
	else
	{
		p = hold_area;
		if((maddr->Zone == alias[0].ad.Zone) || no_zones)	/* Default zone */
#ifdef DEBUG1
		{
			status_line(">HoldAreaNameMunge(%s) = %s", Full_Addr_Str(maddr), p);
			return p;
		}
#else
			return(p);
#endif
		q = munged;
		while (*p)
			*q++ = *p++;
		--q;
		if (*(q-4) == '.') q -= 4;
		(void) sprintf(q,".%03x\\",maddr->Zone);
	}

#ifdef DEBUG1
	status_line(">HoldAreaNameMunge(%s) = %s", Full_Addr_Str(maddr), munged);
#endif

	return(munged);
}


void mailer_banner( void )
{
	if (fullscreen && un_attended)
	{
		vfossil_cursor (0);
		sb_move (settingswin, SET_EVNT_ROW, SET_COL);
		(void) sprintf (junk, "%-2d", cur_event + 1);
		sb_puts (settingswin, (unsigned char *) junk);
		(void) sprintf (junk, "%-5u Com%d", cur_baud, port_ptr + 1);
		sb_move (settingswin, SET_PORT_ROW, SET_COL);
		sb_puts (settingswin, (unsigned char *) junk);
		clear_filetransfer ();
	}

	(void) set_baud (max_baud.rate_value, 0);
}

void clear_filetransfer( void )
{
	if (fullscreen && un_attended)
		sb_fillc (filewin, ' ');
}

static char ebuf[50];
static char *estring (e, how_big)
int e;
int how_big;
{
	char j[10];

	ebuf[0] = '\0';
	if (e >= 0)
	{
		if (e_ptrs[e]->behavior & MAT_BBS)
		{
			(void) strcat (ebuf, "B");
			if (how_big)
				strcat (ebuf, " ");
		}
		if (e_ptrs[e]->behavior & MAT_CM)
		{
			(void) strcat (ebuf, "C");
			if (how_big)
				strcat (ebuf, " ");
		}
		if (e_ptrs[e]->behavior & MAT_DYNAM)
		{
			(void) strcat (ebuf, "D");
			if (how_big)
				strcat (ebuf, " ");
		}
		if (how_big && (e_ptrs[e]->behavior & MAT_FORCED))
			(void) strcat (ebuf, "F ");
		if (e_ptrs[e]->behavior & MAT_NOCM)
		{
			(void) strcat (ebuf, "K");
			if (how_big)
				strcat (ebuf, " ");
		}
		if (e_ptrs[e]->behavior & MAT_LOCAL)
		{
			(void) strcat (ebuf, "L");
			if (how_big)
			{
				if (e_ptrs[e]->node_cost > 0)
					sprintf (j, "<%d ", e_ptrs[e]->node_cost + 1);
				else
					sprintf (j, ">%d ", -e_ptrs[e]->node_cost - 1);
				(void) strcat (ebuf, j);
			}
		}
		if (how_big && (e_ptrs[e]->behavior & MAT_NOMAIL24))
			(void) strcat (ebuf, "M ");
		if (e_ptrs[e]->behavior & MAT_NOREQ)
		{
			(void) strcat (ebuf, "N");
			if (how_big)
				strcat (ebuf, " ");
		}
		if (e_ptrs[e]->behavior & MAT_OUTONLY)
		{
			(void) strcat (ebuf, "S");
			if (how_big)
				strcat (ebuf, " ");
		}
		if (e_ptrs[e]->behavior & MAT_NOOUT)
		{
			(void) strcat (ebuf, "R");
			if (how_big)
				strcat (ebuf, " ");
		}
		if (how_big && (e_ptrs[e]->behavior & MAT_NOOUTREQ))
			(void) strcat (ebuf, "X");
	}
	return (ebuf);
}

void do_ready( char *str )
{
	if (fullscreen && un_attended)
	{
		if (!doing_poll)
		{
			clear_filetransfer ();
		}

		sb_move (settingswin, SET_EVNT_ROW, SET_COL);
		(void) sprintf (junk, "%-2d/%-6.6s", cur_event + 1, estring (cur_event, 0));
		sb_puts (settingswin, (unsigned char *) junk);
		sb_move (settingswin, SET_STAT_ROW, SET_COL);
		/* SWG: truncate/pad with spaces */
		sprintf(junk, "%-11.11s", str);
		sb_puts(settingswin, (unsigned char *) junk);
#ifndef MULTITASK
		sprintf(junk, "Memory: %-10ld", Malloc(-1L));
		sb_move (settingswin, SET_TASK_ROW, 2);
		sb_puts (settingswin, (unsigned char *) junk);
#endif
		sb_show ();
	}
}

void list_next_event( void )
{
	int i;
	char *p;
	char j[100];

	i = time_to_next (0);

	if ((next_event >= 0) && fullscreen)
	{
		clear_filetransfer ();
		sb_move (filewin, 1, 2);
		sprintf (j, msgtxt[M_NEXT_EVENT], next_event + 1, i);
		sb_puts (filewin, (unsigned char *) j);
		p = estring (next_event, 1);
		if (*p != '\0')
		{
			sb_move (filewin, 2, 2);
			sprintf (j, msgtxt[M_EVENT_FLAGS], p);
			sb_puts (filewin, (unsigned char *) j);
		}
		sb_show ();
	}
}
