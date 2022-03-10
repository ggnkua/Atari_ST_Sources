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
/*					  BinkleyTerm Modem Handler Module						*/
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
#include <ctype.h>
#include <string.h>
/* #include <signal.h> */
/* #include <conio.h> */

#include "bink.h"
/* #include "prototyp.h" */
#include "msgs.h"
#include "com.h"
#include "zmodem.h"
#include "sbuf.h"
#include "sched.h"
#include "nodeproc.h"

static int dial_modem (char *);
static void phone_translate (char *, char *);
static char *get_response (long);
static int parse_response (char *);
static void empty_delay (void);

#undef FAILURE
#define FAILURE   0
#define IGNORE	  1
#define CONNECTED 2
#define RINGING   3
#define INCOMING  4
#define FAX	 	  5

struct resp_str
{
	char *resp;
	unsigned disp;
};

static struct resp_str mdm_resps[] = 
{
	{ "RINGING", 		1 },
	{ "RING RESPONSE", 	1 },
	{ "RING", 			3 },
	{ "+FCON",          5 },
	{ "FCON",           5 },
	{ "CONNECT FAX",	5 },
	{ "CONNECT", 		2 },
	{ "V.23 CONNECT",	2 },
	{ "RRING", 			1 },
	{ "BUSY", 			0 },
	{ "VOICE", 			0 },
	{ "ERROR", 			0 },
	{ "OK", 			0 },
	{ "NO CARRIER", 	0 },
	{ "NO DIAL", 		0 },	/* "NO DIAL TONE" or "NO DIALTONE" */ 
	{ "DIALING", 		1 },
	{ "NO ANSWER", 		0 },
	{ "DIAL TONE", 		1 },
	{ NULL, 			0 }
};

void do_dial_strings( void )
{
	MDM_TRNS *m;

	predial = normprefix;
	postdial = normsuffix;


	if(node_prefix) 				/* This is set by nodefind */
	{
		predial = node_prefix;
		return;
	}

	m = mm_head;
	while (m != NULL)
	{
		if (m->mdm & newnodedes.ModemType)
		{
			predial = m->pre;
			postdial = m->suf;
			return;
		}
		m = m->next;
	}
}

void try_2_connect( char *phnum )
{
	long t1;
	int j, k;

	for (j = 0; (j < poll_tries && !KEYPRESS ()); j++)		 /* do polltries or till keypress */
	{
		CLEAR_INBOUND ();
		k = dial_modem (phnum);

		if ((un_attended || doing_poll) && fullscreen)
		{
			++hist.calls_made;
			sb_move (historywin, HIST_ATT_ROW, HIST_COL);
			(void) sprintf (junk, "%-4d", hist.calls_made);
			sb_puts (historywin, (unsigned char *) junk);
		}

		if ((k > 0) || KEYPRESS ())
			break;
#ifndef NEW
		hang_up();		/* Futile attempt to save having to set the baud rate again */
#else
		mdm_hangup();	/* Added from 2.50 */
#endif
#ifdef NEW	/* SWG 29jun91 : What is this delay for???? */
		t1 = timerset (poll_delay * 10L);				/* time is give in 10th seconds */
		while (!timeup (t1) && !KEYPRESS () && (PEEKBYTE() == -1))
			time_release ();								/* pause for 2 seconds */
#endif
	}
	if (KEYPRESS ())									  /* If user's been busy */
	{
#ifndef NEW /* Don't lose key! */
		if (!caller)
			(void) FOSSIL_CHAR ();								 /* Eat the character	*/
#endif
		if (!CARRIER)										  /* Abort if no carrier */
		{
			status_line (msgtxt[M_CONNECT_ABORTED]);
			mdm_hangup ();
		}
	}

	predial = normprefix;
	postdial = normsuffix;
}

int try_1_connect( char *phnum )
{
	int k;

	if ((k = dial_modem (phnum)) <= 0)
	{
		mdm_hangup ();
	}

	if ((un_attended || doing_poll) && fullscreen)
	{
		++hist.calls_made;
		sb_move (historywin, HIST_ATT_ROW, HIST_COL);
		(void) sprintf (junk, "%-4d", hist.calls_made);
		sb_puts (historywin, (unsigned char *) junk);
	}

	predial = normprefix;
	postdial = normsuffix;

	return (k);
}

static void phone_translate (number, translated)
char *number;
char *translated;
{
	PN_TRNS *p;
	int suffix_position;	/* Position in number to test for Suffix */

	(void) strcpy (translated, number);
	for (p = pn_head; p != NULL; p = p->next)
	{
		suffix_position = (int) (strlen (number) - p->suflen);
		if (suffix_position < 0) suffix_position = 0;
		
		if (strncmp (p->prenum, number, p->prelen) == 0 &&
		    strncmp (p->sufnum, number + suffix_position, p->suflen) == 0
		   )
		{
			*(number + suffix_position) = '\0';
			(void) sprintf (translated, "%s%s%s", p->prematch, &(number[p->prelen]), p->sufmatch);
			break;
		}
	}
}

static int dial_modem (char *number)
{
	int resp;
	long t;
	char translated[50];

	if (!*number)
	{
		status_line (msgtxt[M_BAD_NUMBER], Pretty_Addr_Str (&called_addr));
		return (1);
	}
	
	janus_OK = 0;
	phone_translate (number, translated);
	if (translated[0] == '\"')							/* If it's a script 		 */
		return (do_script (translated));			   /* then do it that way		*/

	status_line (msgtxt[M_DIALING_NUMBER], translated);
	if (un_attended && fullscreen)
	{
		do_ready (msgtxt[M_READY_DIALING]);
	}

	/* First of all, if we have something, don't hang up on the guy! */
	if (!no_collide && CHAR_AVAIL ())
		return (-1);

	if (dial_setup != NULL)
	{
		mdm_cmd_string (dial_setup, 1);
	}
	else
	{
#ifdef NEW /* FASTMODEM  10.09.1989 */
	  hang_up ();
#else
		DTR_OFF (); 									   /* drop DTR to reset modem	*/
		timer (20); 									   /* leave it down 2 seconds	*/
#endif
		DTR_ON ();											/* then raise DTR again 	 */
		timer (5);											/* and wait .5 sec for modem */
	}

	if (!no_collide && CHAR_AVAIL ())			/* If we have something here, return */
		return (-1);

	mdm_cmd_string (predial, 0);				/* transmit the dial prefix  */
	mdm_cmd_string (translated, 0); 			/* then the phone number	 */
	mdm_cmd_string (postdial, 0);				/* finally the dial suffix	 */
	if (no_collide)
		CLEAR_INBOUND ();						/* Throw out all echo to this point  */
	mdm_cmd_char (CR);							/* terminate the string 	 */

	resp = modem_response (7500);
	if (resp)									/* we got a good response,	 */
	{
		if (resp == 3)							/* Incoming ring to be processed higher up */
			return (-1);

#ifdef NEW	/* Why waste 2 seconds waiting for character? */
		t = timerset(200);
		while(!timeup(t) && !CARRIER && !KEYPRESS())
			time_release ();
#else
		t = timerset (200); 							/* Wait up to 20 seconds	  */
		while (!timeup (t))
		{											   /* If carrier detect, AND	*/
#ifdef NEW	/* AbortCall SWG 24 June 91 */
			if (KEYPRESS() || ((CHAR_AVAIL ()) && CARRIER)) 					 /* some sign of life, */
#else
			if ((CHAR_AVAIL ()) && CARRIER) 					 /* some sign of life, */
#endif
				break;										   /* leave early...			*/
		}
#endif
		return ((int) CARRIER); 							  /* Carrier should be on now  */
	}
	return (0); 								   /* no good */
}

static char *get_response (long end_time)
{
	static char response_string[30];
	char *p = response_string;						/* points to character cell  */
	char c; 									   /* current modem character	*/
	int count = 0;									/* count of characters		 */

	while ((count < 50) 							   /* until we have 50 chars,	*/
		&& (!timeup (end_time)) 					/* or out of time,			 */
		&& (!KEYPRESS ()))							 /* or user gets impatient	  */
	{
		if (!CHAR_AVAIL ()) 								/* if nothing ready yet,	 */
		{
			time_release ();
			continue;										   /* just process timeouts 	*/
		}
		c = (char) (MODEM_IN () & 0xff);				   /* get a character			*/
		if (c == '\r' || c == '\n') 						/* if a line ending 		 */
		{
			if (count != 0) 									 /* and we have something,	  */
				break;										   /* get out					*/
			else continue;									  /* otherwise just keep going */
		}
		*p++ = c;										  /* store the character	   */
		++count;										   /* increment the counter 	*/
	}
	*p = '\0';										/* terminate the new string  */

	if (count != 0 && strnicmp (response_string, "AT", 2))
	{
		fancy_str (response_string); 				   /* make it pretty			*/
		status_line ("#%s", response_string);			 /* pop it out on the screen  */
	}

	return (response_string);						 /* return the pointer		  */
}

static int parse_response (response)
char *response;
{
	char *p;										  /* temp character pointer    */
	register int i; 							   /* array pointer 			*/

	for (i = 0; mdm_resps[i].resp != NULL; i++) 	   /* scan through array		*/
	{
		p = mdm_resps[i].resp;					   /* point at possible
														  * response */
		if (strnicmp (response, p, strlen (p)) == 0)				  /* if a match,			   */
			return ((int) (mdm_resps[i].disp)); 				 /* return disposition of it  */
	}
	
	if (fax_connect && strnicmp (response, fax_connect, strlen(fax_connect) == 0))
		return (int)FAX;
		
	return (IGNORE); 								   /* ignore all unknowns		*/
}


/*
 * given the Modem connect string work out the baud rate, MNP, etc
 * work out whether Janus is allowed
 */

void setModemValues( char *s )
{
	unsigned int baudrate;

	if ((s == NULL) || (*s == '\0')) 	 	/* if nothing there,		  */
	{
		baudrate = 300;					   	/* say that it's 300 baud	*/
	}
	else
	{
		baudrate = atoi(s); 			  	/* else do baudrate fallback */

		/* For 1200/75 split speed modems and "Connect 212" */

		if ((baudrate == 1275) || (baudrate == 7512)
			||	(baudrate == 75) || (baudrate == 212) || (baudrate == 12))
			baudrate = 1200;

		/* For "Connect 103" */

		if (baudrate == 103)
			baudrate = 300;
	}

	while (isdigit (*s))					/* Get past digits 		  */
		++s;
	s = skip_blanks(s);						/* Get rid of blanks		  */

#ifdef NEW	/* HSTV42  03.09.1990 */
	if (*s != '\0')
	{
	   if (strnicmp (s, "/None", 5) == 0)
		  *s = '\0';
	}
#endif
	if (*s != '\0') 						/* We have "reliable" info.  */
	{                                               
		strcpy (mdm_reliable, s);			/* Copy in the info		  */
		can_Janus (mdm_reliable);			/* Set the flag for Janus	  */
	}

	if (baudrate)
		set_baud (baudrate, 1);
}

/*
 * Wait for modem response
 * ths is time in milliseconds to wait
 */

int modem_response( int ths )
{
	long end_time;									/* holds time at end of 2min */
	char *response;									/* pointer to modem response */
	char *c;										/* miscellaneous pointer	  */
	int result = IGNORE;							/* result code			   */

	/* If this modem doesn't differentiate between RING and RINGING */
	if (modemring)
		mdm_resps[0].disp = IGNORE;

	end_time = timerset ((long)ths);				/* arm the timeout			 */
	while ((result == IGNORE)						/* until success or failure, */
		&& (!timeup (end_time)) 					/* or out of time,			 */
		&& (!KEYPRESS ()))							/* or user gets impatient	  */
	{
		response = get_response (end_time); 		/* get a response			 */
		result = parse_response (response); 		/* parse, determine status	 */
		time_release ();
	}

	if (result == CONNECTED || result == FAX)		/* Got to be a CONNECT msg	 */
	{
		mdm_reliable[0] = '\0';						/* Start with nothing		  */

		if (strnicmp (response, "connect", 7) == 0)	/* if this is a CONNECT,	 */
		{
			c = skip_blanks (&response[7]);			/* get past the blanks 	  */

			setModemValues(c);
		}
		else
		if(strnicmp(response, "v.23", 4) == 0)
		{
			int baudrate = 1200;
			set_baud (baudrate, 1);
			mdm_reliable[0] = 0;
			/* can_Janus(mdm_reliable); */
		}

		if (result == CONNECTED) MNP_Filter ();
	}
	return (result);								/* timeout or failure or OK  */
}

void mdm_cmd_string( char *mdm_cmd, int dospace )
{
	register char *c;

	if (mdm_cmd == NULL)								  /* defense from shit		   */
		return;

	for (c = mdm_cmd; *c; c++)
	{
		if (dospace || (*c && !isspace (*c)))						  /* don't output spaces	   */
			mdm_cmd_char (*c);							  /* output the next character */
	}
}

static void empty_delay( void )
{
	long t;

	t = timerset (500);
	while ((!OUT_EMPTY ()) && (!timeup (t)))
		time_release ();							   /* wait for output to finish */

	if (!OUT_EMPTY ())
	{
		MDM_DISABLE ();
		(void) Cominit (port_ptr);
		MDM_ENABLE (lock_baud && (btypes[baud].rate_value >= lock_baud) ? max_baud.rate_mask : btypes[baud].rate_mask);
		DTR_ON ();
		CLEAR_OUTBOUND ();
		CLEAR_INBOUND ();
		if (un_attended && fullscreen)
		{
			sb_dirty ();
			sb_show ();
		}
	}
}

void mdm_cmd_char( int outchr )
{

	switch (outchr)
	{
	case '-':										/* if it's a dash (phone no) */
		return; 									 /* ignore it				  */

	case '|':										/* if the CR character, 	 */
		outchr = CR;									/* substitute a real CR here */
		break;

	case '~':										/* if the "delay" character, */
		empty_delay (); 							 /* wait for buffer to clear, */
		timer (10); 								 /* then wait 1 second		  */
		return; 									 /* and return				  */

	case '^':										 /* Raise DTR				  */
		empty_delay (); 							 /* wait for buffer to clear, */
		DTR_ON ();									  /* Turn on DTR			   */
		return; 									 /* and return				  */

	case 'v':										 /* Lower DTR			 */
		empty_delay (); 							 /* wait for buffer to clear, */
		DTR_OFF (); 								 /* Turn off DTR			  */
		return; 									 /* and return				  */

	case '`':										 /* Short delay 		 */
		timer (1);									  /* short pause, .1 second    */
		return; 									 /* and return				  */

	default:
		break;
	}

	SENDBYTE ((unsigned char) outchr);				/* then write the character  */

	if (outchr == CR)									 /* if it was a CR, 		  */
	{
		empty_delay ();
		timer (1);										 /* allow .1 sec line quiet   */
	}
	else if (slowmodem)
	{
		timer (1);										 /* wait .1 sec for output	  */
	}
}

void mdm_hangup( void )
{

	/*
	* First, if a dial command is in progress, try to get the modem to abort
	* it...
		*/

	CLEAR_OUTBOUND ();
	CLEAR_INBOUND ();

	if (un_attended && fullscreen)
	{
		do_ready (msgtxt[M_READY_HANGUP]);
	}
	else
	{
		status_line (msgtxt[M_MODEM_HANGUP]);			  /* Tell what we are doing */
	}

	mdm_init (modem_init);							/* re-initialize the modem	 */
	timer (5);										/* Wait another .5 sec		 */

	/*set_xy ("");*/
	CLEAR_INBOUND ();								 /* then flush input and exit */
}

void mdm_init( char *str )
{
	CLEAR_OUTBOUND ();
	CLEAR_INBOUND ();
	if (init_setup != NULL)
	{
		(void) set_baud (max_baud.rate_value, 0);
		mdm_cmd_string (init_setup, 1);
	}
	else
	{
		mdm_cmd_char (CR);									/* output a CR, then		 */
#ifdef NEW /* FASTMODEM  10.09.1989 */
	  hang_up ();
#else
		DTR_OFF (); 									   /* Drop DTR to hangup		*/
		timer (10); 									   /* Hold it down for 1 sec	*/
#endif
		DTR_ON ();											/* Raise DTR,				 */
		timer (5);									  /* Then hold it up for .5
														  * sec */
		(void) set_baud (max_baud.rate_value, 0);

		mdm_cmd_char (' '); 							   /* output a space			*/
		mdm_cmd_char (CR);									/* then another CR			 */
	}
	mdm_cmd_string (str, 0);					  /* then the modem init
													  * string */
#ifdef NEW	/* NOOK  01.09.1990 */
   timer (10);									 /* Hold DTR for 1 sec more  */
#else
	timer (5);										/* Hold DTR for .5 sec more  */
#endif
	CLEAR_INBOUND ();								 /* then flush input and exit */
}

void send_break( int t)
{
	long t1;

	t1 = timerset ((long)t);
	do_break (1);
	while (!timeup (t1))
		time_release ();
	do_break (0);
}

void exit_DTR( void )
{
	if (!leave_dtr_high)
		DTR_OFF ();
}

#define MNP_QTIME 300			/* 2 Second quiet time */
#define MNP_MAXTIME 1000		/* 10 Seconds Maximum */

void MNP_Filter( void )
{
	long t, t1;
	int c;
	BOOLEAN flag = FALSE;		/* Only allow one message to be displayed */

	/*
	 * Wait up to a second for CARRIER to appear since it gets
	 * here straight after CONNECT
	 */

	t = timerset (100); 	 /* at most a one second delay	*/

	while (!CARRIER && !timeup (t))
		;

	t1 = timerset (MNP_QTIME);		/* Quiet time needed */
	t = timerset (MNP_MAXTIME); 	/* Overall timer */

	/*
	 * Loop for either:
	 *	10 seconds (t)
	 *	1 second of quiet time (t1)
	 *	user abort (keypress)
	 */

	while (CARRIER && !timeup (t) && !timeup(t1))
	{
		if(KEYPRESS())			/* User abort */
		{
			DTR_OFF();
			break;
		}

		/*
		 * If there are any characters from the modem then reset the
		 * quiet timer
		 */
		
		if ((c = PEEKBYTE ()) != -1)
		{
			TIMED_READ(0);

			/* If we get an MNP or v.42 character, eat it and wait for clear line */

			if ((c != 0) && ((strchr (BadChars, c) != NULL) || (strchr (BadChars, c&0x7f) != NULL)))
			{
				t1 = timerset (MNP_QTIME);
				if(!flag)
					status_line (msgtxt[M_FILTER]);
				flag = TRUE;
			}
		}
	}
}

#ifdef NEW /* FASTMODEM  10.09.1989 */
void hang_up( void )
{
	long t;

	t = timerset(30);  /* max 3 seconds */
	DTR_OFF ();
	while (CARRIER && !timeup(t))
	   time_release ();
	timer(2);
}
#endif

