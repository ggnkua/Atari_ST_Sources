/*
 * emsi.c
 *
 * EMSI implementation
 *
 * This implementation written by Steven Green (2:255/355) for the
 * Atari ST version of BinkleyTerm.
 *
 * The original EMSI specifications were designed by Chris Irwin and
 * Joaquim H. Homrighausen.
 *
 * This module is based on the information given in:
 *	EMSC-0001; Electronic Mail Standards Document #001; May 3, 1991
 *	(and later republished as FSC-0056)
 *
 * This file replaces:
 *	recvsync.c sendsync.c b_whack.c
 *
 *
 * Revision history:
 *	17Jul91 : SWG : Started
 *
 */

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#ifdef __TOS__
#include <ext.h>
#else
#include <sys\types.h>
#include <sys\stat.h>
#endif
#include <errno.h>
#include <time.h>

#include "bink.h"
#include "msgs.h"
#include "emsi.h"
#include "com.h"
#include "sbuf.h"
#include "zmodem.h"
#include "wazoo.h"
/* #include "version.h" */
#include "password.h"
#include "session.h"
#include "defines.h"
#include "sched.h"
#include "nodeproc.h"

BOOLEAN cantdo_EMSI = FALSE;			/* Local EMSI disable for this session */

/*
 * define the packet strings
 */

#define EMSI_IDLEN 14

char *emsi_pkt[] = {
	"**EMSI_INQ",
	"**EMSI_REQ",
	"**EMSI_CLI",
	"**EMSI_HBT",
	"**EMSI_DAT",
	"**EMSI_ACK",
	"**EMSI_NAK",
	NULL
};

#define EMSI_INQ 0
#define EMSI_REQ 1
#define EMSI_CLI 2
#define EMSI_HBT 3
#define EMSI_DAT 4
#define EMSI_ACK 5
#define EMSI_NAK 6

#define MAX_DATLEN 4096			/* Maximum size of EMSI_DAT packet */


/*
 * Check incomming character for completion of EMSI packet name
 *
 * Return:
 *	-1 : no completion
 *	0..5 : EMSI_type
 *
 * buf must be at least EMSI_IDLEN+1 bytes and the 1st element initialised
 * to 0 before first call.
 *
 * This could be simplified by making it modal, i.e.:
 *	if(c == '*')
 *	  c = modem_in
 *	  if(c == '*')
 *		read 8 bytes
 *		compare to emsi_packet sequences
 *		read 4 byte CRC
 *
 * However this may cause the calling routine to miss characters particularly
 * if any external mailer strings have '**' in them, etc...
 */

static int check_emsi(char c, char *buf)
{
	char *s;
	size_t l;
	char **id;
	int n;

	/* Add character to end of buffer */

	s = buf;
	while(*s)
		s++;
	*s++ = c & 0x7f;
	*s = 0;

	/* Compare to Packet ID's */

	l = strlen(buf);
	if(l == EMSI_IDLEN)		/* Enough for full ID name + crc16 or len16 */
	{
		id = emsi_pkt;
		n = 0;
		while(*id)
		{
			if(strncmp(*id, buf, 10) == 0)
			{
				UWORD crc;
				UWORD val;

				buf[0] = 0;		/* Clear buffer to restart next time */

				if(sscanf(&buf[10], "%04x", &val) != 1)	/* read hex-value */
					return -1;

				if(n != EMSI_DAT)
				{
					crc = crc_block( buf + 2, 8 );
					if(crc != val)
					{
						status_line("+%s %s (CRC=%04x, VAL=%04x)", msgtxt[M_CRC_MSG], buf+2, crc, val);

						return -1;
					}
					else
						return n;
				}
				else
					return n;

			}
			n++;
			id++;
		}
		/* should never get here... */
		buf[0] = 0;
		return -1;
	}

	/*
	 * We get here if we have less than 14 characters or it doesn't match
	 * any of the packet types
	 *
	 * Shift buffer along to 1st possible match
	 *
	 * This probably doesn't need to be this complex, but I want to make
	 * it handle all cases, e.g.
	 *	 ***EMSI_REQ	  : must ignore the 1st * instead of resetting at the 3rd
	 *	 **EMS**EMSI_REQ  : Must not reset at the 2nd group of '*'.
	 *
	 * In fact we could probably assume that all sequences start at the
	 * start of a line (except for the double EMSI_INQ sent during initialisation
	 */

	l = strlen(buf);
	if(l <= 10)			/* Any bigger than 10 and we are into the <crc16> and must have already matched */
	{
		s = buf;
		while(l)
		{
			id = emsi_pkt;
			while(*id)
			{
				if(strncmp(*id, s, l) == 0)
				{
					if(s != buf)
						strcpy(buf, s);
					return -1;
				}
				id++;
			}
			l--;
			s++;
		}
		buf[0] = 0;		/* No matches */
	}


	return -1;
}

static char hex[16] = { '0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F' };

static int put_hex(UWORD val)
{

	SENDBYTE(hex[(val >> 12) & 0xf]);
	SENDBYTE(hex[(val >>  8) & 0xf]);
	SENDBYTE(hex[(val >>  4) & 0xf]);
	SENDBYTE(hex[ val		 & 0xf]);

	return 0;
}

static int byte_to_hex(int c)
{
	c = toupper(c);
	c -= '0';
	if (c > 9)
		c -= ('A' - '9' - 1);
	return c;
}

static int send_string(char *s)
{
	while(*s)
		SENDBYTE(*s++);
	return 0;
}

static int send_emsi(int type, BOOLEAN cr)
{
	char *s = emsi_pkt[type];
	UWORD crc;

	send_string(s);

	if(type != EMSI_DAT)
	{
		crc = 0;
		s += 2;		/* Skip over "**" */
		while(*s)
			crc = xcrc(crc, (unsigned)*s++);

		put_hex(crc);
		if(cr)
			SENDBYTE('\r');
	}
	SENDBYTE(XON);
	return 0;
}

/*
 * Initiate call and return type of session unless its EMSI in which
 * case it goes ahead and does it!
 */


/*
  State table for TxEmsi: This is the 1st table I've ever written

  state|function	 Conditions 			   Actions				  next
 /-----+------------+------------------------+--------------------------+------\
 | TS0 | WhackInit	|						 | Start 10 second timer	|	   |
 |	   |			|						 | Init Line buffer 		| TS1  |
 +-----+------------+------------------------+--------------------------+------+
 | TS1 | WhackCR	| 1. Timer expired		 | Nobody Home				| exit |
 |	   |			+------------------------+--------------------------+------+
 |	   |			| 2. Lost carrier		 | Lost Carrier 			| exit |
 |	   |			+------------------------+--------------------------+------+
 |	   |			| 3. Something received  | Someone home 			| TS2  |
 |	   |			+------------------------+--------------------------+------+
 |	   |			| 4. Nothing received	 | Send <CR>, wait 1 sec	| TS1  |
 |	   |------------+------------------------+--------------------------+------+
 |(TS2)| RxInit 	|						 | Init Line buffer 		|	   |
 |	   |			|						 | Start 10 second timer	| TS3  |
 |	   |------------+------------------------+--------------------------+------+
 |(TS3)| RxIntro	| 1. Timer expired		 | Nobody Home				| exit |
 |	   |			+------------------------+--------------------------+------+
 |	   |			| 2. Lost carrier		 | Lost Carrier 			| exit |
 |	   |			+------------------------+--------------------------+------+
 |	   |			| 3. EMSI_REQ recieved	 | Send EMSI_INQ twice		|	   |
 |	   |			|						 | select EMSI				| exit |
 |	   |			+------------------------+--------------------------+------+
 |	   |			| 3. <CR> received		 | Show intro				| TS4  |
 |	   |			+------------------------+--------------------------+------+
 |	   |			| 4. printable char rx	 | Put it in buffer 		| TS3  |
 +-----+------------+------------------------+--------------------------+------+
 | TS4 | InitTxEmsi |						 | Prepare 3 sec Sync timer |	   |
 |	   |			|						 | Prepare .5 sec NAK timer |	   |
 |	   |			|						 | Init NAK count			|	   |
 |	   |			|						 | Init Line buffer 		|	   |
 |	   |			|						 | Start 60 sec master tmr	| TS5  |
 |	   |------------+------------------------+--------------------------+------+
 |(TS5)| SendSync	| 1. 60 seconds elapsed  |							|	   |
 |	   |			|	 or no carrier		 | no response				| exit |
 |	   |			+------------------------+--------------------------+------+
 |	   |			| 2. 3 sec timer elapsed | Send EMSI_INQ twice		|	   |
 |	   |			|	 or never started	 | Send YOOHOO TSYNC CR 	| TS6  |
 |	   |			+------------------------+--------------------------+------+
 |	   |			| 3. EMSI_REQ received	 | Send EMSI_INQ twice		|	   |
 |	   |			|						 | Select EMSI				| exit |
 |	   |			+------------------------+--------------------------+------+
 |	   |			| 4. Otherwise...		 |							| TS6  |
 |	   |------------+------------------------+--------------------------+------+
 |(TS6)| WaitResp	| 1. Nothing received	 | need response			| TS5  |
 |	   |			+------------------------+--------------------------+------+
 |	   |			| 2. ENQ received		 | Wazoo selected			| exit |
 |	   |			+------------------------+--------------------------+------+
 |	   |			| 3. 'C' or NAK received | Maybe FTS-0001			| TS7  |
 |	   |			+------------------------+--------------------------+------+
 |	   |			| 4. CR 				 | Init Line buffer&NAK cnt | TS5  |
 |	   |			+------------------------+--------------------------+------+
 |	   |			| 5. Other character	 | Init NAK /into buffer	| TS5  |
 |	   |------------+------------------------+--------------------------+------+
 |(TS7)| NAKtmr 	| 1. Timer expired		 | NAK count++				| TS8  |
 |	   |			+------------------------+--------------------------+------+
 |	   |			| 2. Timer not expired	 | Zero NAK count			|	   |
 |	   |			|						 | Start .5 sec NAK timer	| TS5  |
 |	   |------------+------------------------+--------------------------+------+
 |(TS8)| NAKcount	| 1. Count >= 2 		 | Select FTS-0001			| exit |
 |	   |			+------------------------+--------------------------+------+
 |	   |			| 2. count < 2			 | continue 				| TS5  |
 +-----+------------+------------------------+--------------------------+------+


 I can't help feeling that this would be a lot cleaner just as a single function
 As these state diagrams when you look at them are really going back to the
 days of Spaghetti Basic!  In fact I've cut it down to just 2 states!

*/

#define INTRO_LEN 180		/* Maximum size of Intro/banner */

/*
 * Data structure used by TxEmsiInit
 */

typedef struct {
	int result;
} TSARGS;


#define TS0 	0
#define TSexit	0
#define TS1 	2
#define TS4		3

/*
 /-----+------------+------------------------+--------------------------+------\
 | TS0 | WhackInit	|						 | Start 10 second timer	|	   |
 |	   |			|						 | Init Line buffer 		| TS1  |
 +-----+------------+------------------------+--------------------------+------+
*/

static int cdecl TSWhackInit(TSARGS *args, int start_state)
{
	if ( start_state )
	{
	}
	
	args->result = SESSION_FAIL;		/* Default to failure */
	cantdo_EMSI = check_noemsi(&called_addr, (char**)NULL);

	return TS1;
}

static int cdecl TSExit(TSARGS *args, int cur_state)
{
	if ( cur_state )
	{
	}
	
	return args->result;
}

/*
 * Check for abort or timeout
 */

static int check_abort(long timer, char *msg)
{
	if(KEYPRESS())
	{
		status_line(msgtxt[M_KBD_MSG]);

		hang_up();
		READKB();			/* Eat character */
		return -1;
	}
	if(!CARRIER)
	{
		status_line(msgtxt[M_NO_CARRIER]);
		return -1;
	}
	if(timer && timeup(timer))
	{
		if(msg)
			status_line(msg);
		return -1;
	}
	return 0;
}

/*
 +-----+------------+------------------------+--------------------------+------+
 | TS1 | WhackCR	| 1. Timer expired		 | Nobody Home				| exit |
 |	   |			+------------------------+--------------------------+------+
 |	   |			| 2. Lost carrier		 | Lost Carrier 			| exit |
 |	   |			+------------------------+--------------------------+------+
 |	   |			| 3. Something received  | Someone home 			| TS2  |
 |	   |			+------------------------+--------------------------+------+
 |	   |			| 4. Nothing received	 | Send <CR>, wait 1 sec	| TS1  |
 |	   +------------+------------------------+--------------------------+------+
 |(TS2)| RxInit 	|						 | Init Line buffer 		|	   |
 |	   |			|						 | Start 10 second timer	| TS3  |
 |	   +------------+------------------------+--------------------------+------+
 |(TS3)| RxIntro	| 1. Timer expired		 | Nobody Home				| exit |
 |	   |			+------------------------+--------------------------+------+
 |	   |			| 2. Lost carrier		 | Lost Carrier 			| exit |
 |	   |			+------------------------+--------------------------+------+
 |	   |			| 3. EMSI_REQ recieved	 | Send EMSI_INQ twice		|	   |
 |	   |			|						 | select EMSI				| exit |
 |	   |			+------------------------+--------------------------+------+
 |	   |			| 3. <CR> received		 | Show intro				| TS4  |
 |	   |			+------------------------+--------------------------+------+
 |	   |			| 4. printable char rx	 | Put it in buffer 		| TS3  |
 +-----+------------+------------------------+--------------------------+------+
*/

static int cdecl TSWhackCR(TSARGS *args)
{
	long sectimer = 0L;
	long bigtimer;
	char c = '\r';
	int pos;
	char buffer[INTRO_LEN];
	char emsibuf[EMSI_IDLEN+1];

	/*
	 * Send <CR> once per second until anything is received
	 * or until carrier lost/timeout/keyboard escape
	 */

	pos = 0;
	emsibuf[0] = '\0';
	bigtimer = timerset(3000);			/* Up to 30 seconds */

	for(;;)
	{
		if(check_abort(bigtimer, msgtxt[M_NOBODY_HOME]))
		{
			args->result = SESSION_FAIL;
			return TSexit;
		}
		else if(!CHAR_AVAIL())
		{
			if(!sectimer || timeup(sectimer))
			{
				SENDBYTE(c);
				c ^= ' ' ^ '\r';	/* Alternate space/CR */
				sectimer = timerset(100);
			}
			else
				time_release();
		}
		else
		{

			/*
			 * Input line and treat it as either a banner or an EMSI_REQ
			 */

			unsigned char c = MODEM_IN();

			if(c == '\r')	/* CR = end of banner/intro */
			{
				if(pos)
				{
					buffer[pos] = '\0';	/* Make sure null terminated */
					if(un_attended && fullscreen)
					{
						clear_filetransfer ();
						sb_move (filewin, 1, 2);
						sb_puts (filewin, buffer);
						sb_show ();
						status_line ("*%s%s", msgtxt[M_INTRO], buffer);
					}
					else
					{
						set_xy (NULL);
						scr_printf(msgtxt[M_INTRO]);
						scr_printf(buffer);
					}

					SENDBYTE ('\013');		/* (''); Try to stop output on an Opus */

					return TS4;		/* Get on with next section */
				}
			}
			else
			{
				if( (c >= ' ') && (pos < (INTRO_LEN-2)) )
					buffer[pos++] = c;

				/* Check it against EMSI_REQ */

				if(!cantdo_EMSI && check_emsi(c, emsibuf) == EMSI_REQ)
				{
					if(un_attended && fullscreen)
						clear_filetransfer ();
					send_emsi(EMSI_INQ, TRUE);
					args->result = SESSION_EMSI;
					return TSexit;
				}
			}
		}
	}
}

/*

 +-----+------------+------------------------+--------------------------+------+
 | TS4 | InitTxEmsi |						 | Prepare 3 sec Sync timer |	   |
 |	   |			|						 | Prepare .5 sec NAK timer |	   |
 |	   |			|						 | Init NAK count			|	   |
 |	   |			|						 | Init Line buffer 		|	   |
 |	   |			|						 | Start 60 sec master tmr	| TS5  |
 |	   |------------+------------------------+--------------------------+------+
 |(TS5)| SendSync	| 1. 60 seconds elapsed  |							|	   |
 |	   |			|	 or no carrier		 | no response				| exit |
 |	   |			+------------------------+--------------------------+------+
 |	   |			| 2. 3 sec timer elapsed | Send EMSI_INQ twice		|	   |
 |	   |			|	 or never started	 | Send YOOHOO TSYNC CR 	| TS6  |
 |	   |			+------------------------+--------------------------+------+
 |	   |			| 3. EMSI_REQ received	 | Send EMSI_INQ twice		|	   |
 |	   |			|						 | Select EMSI				| exit |
 |	   |			+------------------------+--------------------------+------+
 |	   |			| 4. Otherwise...		 |							| TS6  |
 |	   |------------+------------------------+--------------------------+------+
 |(TS6)| WaitResp	| 1. Nothing received	 | need response			| TS5  |
 |	   |			+------------------------+--------------------------+------+
 |	   |			| 2. ENQ received		 | Wazoo selected			| exit |
 |	   |			+------------------------+--------------------------+------+
 |	   |			| 3. 'C' or NAK received | Maybe FTS-0001			| TS7  |
 |	   |			+------------------------+--------------------------+------+
 |	   |			| 4. CR 				 | Init Line buffer&NAK cnt | TS5  |
 |	   |			+------------------------+--------------------------+------+
 |	   |			| 5. Other character	 | Init NAK /into buffer	| TS5  |
 |	   |------------+------------------------+--------------------------+------+
 |(TS7)| NAKtmr 	| 1. Timer expired		 | NAK count++				| TS8  |
 |	   |			+------------------------+--------------------------+------+
 |	   |			| 2. Timer not expired	 | Zero NAK count			|	   |
 |	   |			|						 | Start .5 sec NAK timer	| TS5  |
 |	   |------------+------------------------+--------------------------+------+
 |(TS8)| NAKcount	| 1. Count >= 2 		 | Select FTS-0001			| exit |
 |	   |			+------------------------+--------------------------+------+
 |	   |			| 2. count < 2			 | continue 				| TS5  |
 +-----+------------+------------------------+--------------------------+------+

*/

static int cdecl TSInitTxEMSI(TSARGS *args)
{
	long bigtimer;
	long naktimer = 0L;
	long synctimer = 0L;
	int nakcount = 0;
	char emsibuf[EMSI_IDLEN+1];

	bigtimer = timerset(6000);		/* Up to 1 minute */
	emsibuf[0] = '\0';

	for(;;)
	{
		/*
		 * Check for:
		 *	keyboard abort
		 *	timeout
		 *	Carrier loss
		 */
		if(check_abort(bigtimer, NULL))
		{
			args->result = SESSION_FAIL;
			return TSexit;
		}

		/*
		 * Send handshake start stuff every 3 seconds...
		 */

		if(!synctimer || timeup(synctimer))
		{
			if(!cantdo_EMSI)
			{
				send_emsi(EMSI_INQ, FALSE);
				send_emsi(EMSI_INQ, FALSE);
			}
			if(!no_WaZOO && !no_WaZOO_Session)
				SENDBYTE(YOOHOO);
			SENDBYTE(TSYNC);
			if(!cantdo_EMSI)
				SENDBYTE('\r');

			synctimer = timerset(300);
		}


		if(CHAR_AVAIL())
		{
			char c = PEEKBYTE();

			/*
			 * We must fiddle about like this because FTS-0001 expects
			 * the NAK or 'C' to still be available
			 *
			 * It would be easier to implement a unget function
			 */

			switch(c)
			{
			/* Check for Wazoo */

			case ENQ:
				c = MODEM_IN();
				if(!no_WaZOO && !no_WaZOO_Session)
				{
					args->result = SESSION_WAZOO;
					return TSexit;
				}
				goto bad_char;

			case 'C':
			case NAK:
				if(!naktimer || !timeup(naktimer))
				{
					naktimer = timerset(50);
					nakcount = MODEM_IN();
					nakcount = 0;
				}
				else
				{
					nakcount++;
					if(nakcount >= 2)
					{
						args->result = SESSION_FTSC;
						return TSexit;
					}
				}
				break;

			default:
			bad_char:
			/* Check it against EMSI_REQ */
				c = MODEM_IN();
				if(!cantdo_EMSI && check_emsi(c, emsibuf) == EMSI_REQ)
				{
					send_emsi(EMSI_INQ, TRUE);
					args->result = SESSION_EMSI;
					return TSexit;
				}
				if(naktimer)
					naktimer = timerset(50);
				break;

			}
		}


	}

	/* return TSexit; */
}

/*
 * State machine table
 */

static STATES States_TxEmsiInit[] = {
  {	"TSWhackInit",	( void *)TSWhackInit		},
  {	"TSExit",		( void *)TSExit			},
  {	"TSWhackCR",	( void *)TSWhackCR		},
  {	"TSInitTxEMSI",	( void *)TSInitTxEMSI	}
};

int TxEmsiInit(void)
{
	TSARGS args;

	return state_machine(States_TxEmsiInit, &args, TS1);
}

/*-----------------------------------------------------------------
 * Receiver intialisation
 */

/*
 State Machine:

 /-----+----------+--------------------------------+--------------------+-----\
 | RS0 | IdleWait | 1. 5 seconds elapsed		   | Take initiative	| RS1 |
 |	   |		  +--------------------------------+--------------------+-----+
 |	   |		  | 2. No carrier or keypress	   | Abort				| exit|
 |	   |		  +--------------------------------+--------------------+-----+
 |	   |		  | 3. YOOHOO or TSYNC peeked	   | Get on with it!	| RS2 |
 |	   |		  +--------------------------------+--------------------+-----+
 |	   |		  | 4. CR, LF, Space, Esc		   | Something's there	| RS1 |
 |	   |		  +--------------------------------+--------------------+-----+
 |	   |		  | 5. EMSI sequence?			   | Get on with it 	| RS2 |
 |	   |		  +--------------------------------+--------------------+-----+
 |	   |		  | 6. Any other character...	   | Eat it 			| RS0 |
 +-----+----------+--------------------------------+--------------------+-----+
 | RS1 | SendIntro| 1. Error sending /carrier drop | Abort				| exit|
 |	   |  and	  +--------------------------------+--------------------+-----+
 |	   | EMSI_REQ | 2. Sent OK					   |					| RS2 |
 +-----+----------+--------------------------------+--------------------+-----+
 | RS2 | RxInit   | 							   | Init ext-mail		| RS3 |
 |	   |		  | 							   | Start 20sec time	|	  |
 |	   |		  | 							   | Init 10 sec time	|	  |
 +-----+----------+--------------------------------+--------------------+-----+
 | RS3 | SendSync | 1. Error sending / no carrier  | Abort				| exit|
 |	   |		  +--------------------------------+--------------------+-----+
 |	   |		  | 2. Sent OK					   |					| RS4 |
 +-----+----------+--------------------------------+--------------------+-----+
 | RS4 | WaitSync | 1. Carrier lost/keypress	   | Abort				| exit|
 |	   |		  +--------------------------------+--------------------+-----+
 |	   |		  | 2. YOOHOO received			   | Do WaZOO			| exit|
 |	   |		  +--------------------------------+--------------------+-----+
 |	   |		  | 3. TSYNC rx + timer not running| Start 10 sec timer | RS4 |
 |	   |		  +--------------------------------+--------------------+-----+
 |	   |		  | 4. CR received				   | resend sync		| RS3 |
 |	   |		  +--------------------------------+--------------------+-----+
 |	   |		  | 5. Esc received 			   | BBS				| exit|
 |	   |		  +--------------------------------+--------------------+-----+
 |	   |		  | 6. EMSI_INQ received		   | EMSI				| exit|
 |	   |		  +--------------------------------+--------------------+-----+
 |	   |		  | 7. 10 second timer			   | FSC001 			| exit|
 |	   |		  +--------------------------------+--------------------+-----+
 |	   |		  | 8. 20 second timer			   | BBS				| exit|
 +-----+----------+--------------------------------+--------------------+-----+

*/

typedef struct {
	int result;
} RSARGS;

#define RS0		0
#define RSexit	0
#define RS1		2
#define RS2		3

static int cdecl RSExit(RSARGS *args)
{
	return args->result;
}

/*
 * RS0:
 *
 * For a short while see if there are any shortcut characters
 */

static int cdecl RSIdleWait(RSARGS *args)
{
	long idletimer;
	char emsibuf[EMSI_IDLEN+1];

	emsibuf[0] = '\0';
	idletimer = timerset(50);		/* Up to 5 seconds.. cut down to .5 seconds! */
	for(;;)
	{
		if(check_abort(0L, NULL))		/* No carrier or keypress */
		{
			args->result = SESSION_FAIL;
			return TSexit;
		}
		if(timeup(idletimer))
			return RS1;
		if(CHAR_AVAIL())
		{
			char c = PEEKBYTE();

			switch(c)
			{
			case TSYNC:		/* Bypass intro... */
			case YOOHOO:
				return RS2;
			case CR:		/* Signs of life */
			case LF:	/* Line feed! */
			case ' ':
			case ESC:
			case ENQ:
				return RS1;
			default:
				c = MODEM_IN();		/* Eat the character */

				/* And see if its EMSI_REQ */

				if(!cantdo_EMSI && check_emsi(c, emsibuf) == EMSI_INQ)
				{
					args->result = SESSION_EMSI;
					return RSexit;
				}
			}
		}
	}

	/* return RSexit; */
}

/*
 * RS1: Send Intro and banners and things
 */

static int cdecl RSSendBanner(RSARGS *args)
{
	char buff[128];

	if(!cantdo_EMSI)
		send_emsi(EMSI_REQ, TRUE);

	/* intro = "\r\r* Address %s Using %s\r\n" */

	sprintf(buff, msgtxt[M_ADDRESS], Full_Addr_Str(&alias[0].ad), ANNOUNCE);

	if(!SendBanner(buff))
	{
	fail:
		args->result = SESSION_FAIL;
		return RSexit;
	}

	/* Banner, e.g. the BBS name */

	if(BBSbanner && strlen(BBSbanner))
	{
		SENDBYTE('\r');
		SENDBYTE('\n');
		if(!SendBanner(BBSbanner))
			goto fail;
		SENDBYTE('\r');
		SENDBYTE('\n');
	}

	/* The welcome file */

	if(!mail_only)
		if(!SendBanner(BBSwelcome))
			goto fail;

	return RS2;
}

/*
 * RS2:
 *
 *	Init Sync timers
 *	Send Sync line
 *	Wait for sync line
 */

static int cdecl RSSendSync(RSARGS *args)
{
	int k;
	BOOLEAN needbanner = TRUE;
	char *ExtMailScan[16];
	char emsibuf[EMSI_IDLEN+1];
	long bigtimer;
	long synctimer = 0L;

	/* Init external mail strings */

	for(k = 0; k < num_ext_mail; k++)
		ExtMailScan[k] = ext_mail_string[k];
	emsibuf[0] = '\0';
	bigtimer = timerset((long)BBStimeout);			/* 20 seconds timeout */

	for(;;)
	{
		/* Send synchronisation string (press esc for BBS) */

		if(needbanner)
		{
			char *c;

			if(mail_only)
				c = noBBS;
			else
				c = BBSesc;

			if(!SendBanner(c))
			{
				args->result = SESSION_FAIL;
				return RSexit;
			}
			needbanner = FALSE;
		}

		if(check_abort(0L, NULL))			/* No carrier or keyboard escape */
		{
			args->result = SESSION_FAIL;
			return RSexit;
		}

		if(CHAR_AVAIL())
		{
			unsigned char c = MODEM_IN();

			switch(c)
			{
			case YOOHOO:
				if(!no_WaZOO)
				{
					CLEAR_OUTBOUND();	/* Stop any outgoing banner */
					args->result = SESSION_WAZOO;
					return RSexit;
				}
				break;

			case TSYNC:
				CLEAR_OUTBOUND();
				if(no_WaZOO)
				{
					args->result = SESSION_FTSC;
					return RSexit;
				}
				else
				{
					if(!synctimer)
					{
						synctimer = timerset(1000);			/* 10 seconds */
						bigtimer = timerset((long)BBStimeout);	/* Reset sync timer */
					}
				}
				break;

			case CR:
				needbanner = TRUE;
				break;

			case ESC:
				if(!mail_only)
				{
					args->result = SESSION_BBS;
					return RSexit;
				}
				break;

			default:

				/* Check for EMSI */

				if(!cantdo_EMSI && check_emsi(c, emsibuf) == EMSI_INQ)
				{
					args->result = SESSION_EMSI;
					return RSexit;
				}

				/* Check for external mailer */

				c &= 0x7f;
				for(k = 0; k < num_ext_mail; k++)
				{
					if(c != *(ExtMailScan[k]++) )
						ExtMailScan[k] = ext_mail_string[k];
					else if(!*ExtMailScan[k])
					{
						args->result = SESSION_EXTERN+k;
						return RSexit;
					}
				}

				break;
			}
		}
		else	/* !CHAR_AVAIL() */
		{
			if(synctimer && timeup(synctimer))
			{
				args->result = SESSION_FTSC;
				return RSexit;
			}

			if(timeup(bigtimer))
			{
				if(mail_only)
					args->result = SESSION_FAIL;
				else
					args->result = SESSION_BBS;
				return RSexit;
			}
		}
	}
}


static STATES States_RxEmsiInit[] = {
	{ "RSIdleWait", 	( void *)RSIdleWait	},
	{ "RSExit",			( void *)RSExit			},
	{ "RSSendBanner",	( void *)RSSendBanner	},
	{ "RSSendSync",	( void *)RSSendSync		}
};


int RxEmsiInit(void)
{
	TSARGS args;

	cantdo_EMSI = check_noemsi(NULL, (char**)NULL);
	return state_machine(States_RxEmsiInit, &args, RS0);
}

/*------------------------------------------------------------
 * Send EMSI_DAT packet
 */

EMSI_CAPABILITY emsi_capability;		/* Capability we can do */
EMSI_CAPABILITY emsi_remote_capability;	/* What the other guy can do */
EMSI_CAPABILITY emsi_protocol;			/* What we are doing */
EMSI_CALL_OPTIONS emsi_options;
long ourTrx;							/* Session Identification */

static void initTrx(void)
{
	time_t thetime;
	
#if 0
	struct tm *tim;
	
	time(&thetime);
	tim = gmtime(&thetime);
	ourTrx = mktime(tim);
#else
	time(&thetime);
	ourTrx = thetime;
#endif
}

/* add character to buffer with escaping */

static char *add_char(char c, char *s)
{
	while(*s)
		s++;		/* Get to end of string */
	if( (c == '\\') || (c == '}') || (c == ']'))
	{
		*s++ = c;
		*s++ = c;
	}
	else if(isprint(c))
		*s++ = c;
	else
	{
		*s++ = '\\';
		*s++ = hex[(c >> 4) & 0xf];
		*s++ = hex[ c		& 0xf];
	}
	*s = 0;
	return s;
}

/* add's character without any escaping */

static char *add_field(char c, char *s)
{
	while(*s)
		s++;
	*s++ = c;
	*s = 0;
	return s;
}

/* Add string to buffer with escaping */

static char *add_str(char *str, char *s)
{
	while(*str)
		s = add_char(*str++, s);
	return s;
}

static int TxEMSI_DAT(BOOLEAN sender)
{
	int i;
	size_t length;
	UWORD crc;
	int tries;
	long t1, t2;
	char emsibuf[EMSI_IDLEN+1];
	char *buffer;
	char *ptr;

	/* Create the Data */

	buffer = malloc(MAX_DATLEN);
	if(!buffer)
	{
		status_line(msgtxt[M_EMSI_NOMEM]);
		return EMSI_ABORT;
	}

	ptr = buffer;
	strcpy(buffer, "**EMSI_DAT0000{EMSI}");		/* DAT+len+Fingerprint */

	/* System addresses... assumed goes first */

	ptr = add_field('{', ptr);
	make_assumed(&remote_addr);		/* Work out assumed */
	ptr = add_str(Full_Addr_Str(&alias[assumed].ad), ptr);
	for(i = 0; i < num_addrs; i++)
	{
		if(i != assumed)
		{
			ptr = add_char(' ', ptr);
			ptr = add_str(Full_Addr_Str(&alias[i].ad), ptr);
		}
	}
	ptr = add_field('}', ptr);

	/* Password */

	ptr = add_field('{', ptr);
#ifdef NORXPASSWORD
	if(sender)
#endif
		if (n_getpassword(&remote_addr))
			ptr = add_str(remote_password, ptr);
	ptr = add_field('}', ptr);

	/* Link codes */

	ptr = add_field('{', ptr);
	ptr = add_str("8N1", ptr);
	if(sender)
	{
		add_str(",PUA", ptr);		/* Pick up all mail */
	}
	else
	{
		/* Disable FREQ's */
		
		if( !(matrix_mask & TAKE_REQ) ||
#if 0
			(sender && !check_reqonus(&remote_addr)) ||
#endif
			(DEFAULT.rq_OKFile == NULL))
				ptr = add_str(",HRQ", ptr);
	}
	
	ptr = add_field('}', ptr);

	/* Compatibility codes */

	ptr = add_field('{', ptr);

	/* Work out what we can do first */

	emsi_capability = 0;
	if ((janus_baud >= cur_baud) || (janus_OK))
		emsi_capability |= EMSI_P_JAN;
	if(!no_zapzed)
		emsi_capability |= EMSI_P_ZAP;
	emsi_capability |= EMSI_P_ZMO;		/* Minimum spec of ZedZip */

	/* We can't do Kermit or DZA */

	/* MSDOS filenames, arcmail, other compression */

	emsi_capability |= EMSI_P_FNC | EMSI_P_ARC | EMSI_P_XMA;

	/* NRQ? */

	if( (DEFAULT.rq_OKFile == NULL) ||
		(sender && !check_reqonus(&remote_addr, (char**)NULL)) ||
		(!sender && check_norequest(&remote_addr, (char**)NULL)) ||
		 no_requests
		)
			emsi_capability |= EMSI_P_NRQ;

	if(sender)		/* Send everything we can do */
	{
		if(emsi_capability & EMSI_P_JAN)
			ptr = add_str("JAN,", ptr);
		if(emsi_capability & EMSI_P_ZAP)
			ptr = add_str("ZAP,", ptr);
		ptr = add_str("ZMO,", ptr);
	}
	else			/* Pick best protocol */
	{
		if(emsi_capability & emsi_remote_capability & EMSI_P_JAN)
		{
			ptr = add_str("JAN,", ptr);
			emsi_protocol = EMSI_P_JAN;
		}
		else if(emsi_capability & emsi_remote_capability & EMSI_P_ZAP)
		{
			ptr = add_str("ZAP,", ptr);
			emsi_protocol = EMSI_P_ZAP;
		}
		else
		{
			ptr = add_str("ZMO,", ptr);
			emsi_protocol = EMSI_P_ZMO;
		}
	}

	if(emsi_capability & EMSI_P_NRQ)
		ptr = add_str("NRQ,", ptr);
		
	ptr = add_str("ARC,XMA,FNC", ptr);
	ptr = add_field('}', ptr);

	/* mailer_product_code */

	ptr = add_field('{', ptr);
	sprintf(ptr, "%02x", isBINKST);
	ptr = add_field('}', ptr);

	/* mailer_name */

	ptr = add_field('{', ptr);
	ptr = add_str(MAILER_NAME, ptr);
	ptr = add_field('}', ptr);

	/* mailer_version */

	ptr = add_field('{', ptr);
	ptr = add_str(MAILER_VER, ptr);
	ptr = add_field('}', ptr);

	/* mailer_serial */

	ptr = add_field('{', ptr);
	ptr = add_str(MAILER_SER, ptr);
	ptr = add_field('}', ptr);

	/* Do the IDENT fields */

	ptr = add_field('{', ptr);
	ptr = add_str("IDENT", ptr);
	ptr = add_field('}', ptr);

	ptr = add_field('{', ptr);
	{
		/* Find ourself in the nodelist */

		BOOLEAN inlist = nodefind(&alias[assumed].ad, FALSE);

		/* System name */

		ptr = add_field('[', ptr);
		if(NL_System)
			ptr = add_str(NL_System, ptr);
		else
		if(inlist)
			ptr = add_str(newnodedes.SystemName, ptr);
		else
			ptr = add_str(system_name, ptr);
		ptr = add_field(']', ptr);

		/* City */

		ptr = add_field('[', ptr);
		if(NL_City)
			ptr = add_str(NL_City, ptr);
		else
		if(inlist)
			ptr = add_str(newnodedes.MiscInfo, ptr);
		ptr = add_field(']', ptr);

		/* Operator Name */

		ptr = add_field('[', ptr);
		ptr = add_str(sysop, ptr);
		ptr = add_field(']', ptr);

		/* Phone number */

		ptr = add_field('[', ptr);
		if(NL_Phone)
			ptr = add_str(NL_Phone, ptr);
		else
		if(inlist)
			ptr = add_str(newnodedes.PhoneNumber, ptr);
		else
			ptr = add_str("-Unpublished", ptr);
		ptr = add_field(']', ptr);

		/* baud-rate */

		ptr = add_field('[', ptr);
		if(NL_Baud)
			ptr = add_str(NL_Baud, ptr);
		else
		if(inlist)
			sprintf(ptr, "%lu", (unsigned long) newnodedes.BaudRate * 300);
		else
			sprintf(ptr, "%lu", (unsigned long) max_baud.rate_value);
		ptr = add_field(']', ptr);

		/* flags */

		ptr = add_field('[', ptr);
		if(NL_Flags)
			ptr = add_str(NL_Flags, ptr);
		else
		{
			ptr = add_str("XB", ptr);
			if(inlist)
			{
				if(newnodedes.NodeFlags & B_CM)
					ptr = add_str(",CM", ptr);
				if(newnodedes.ModemType & M_HST)
					ptr = add_str(",HST", ptr);
				if(newnodedes.ModemType & M_PEP)
					ptr = add_str(",PEP", ptr);
			}
			if(mail_only)
				ptr = add_str("MO", ptr);
		}
		ptr = add_field(']', ptr);
	}
	ptr = add_field('}', ptr);

	/* Do the TRX# fields */

	ptr = add_field('{', ptr);
	ptr = add_str("TRX#", ptr);
	ptr = add_field('}', ptr);

	ptr = add_field('{', ptr);
	  ptr = add_field('[', ptr);
  	    sprintf(ptr, "%08lx", (long)ourTrx);
	  ptr = add_field(']', ptr);
	ptr = add_field('}', ptr);


	length = strlen(buffer) - 14;		/* Length of packet [not **EMSI_DATllll] */
	buffer[10] = hex[(length >> 12) & 0xf];
	buffer[11] = hex[(length >>  8) & 0xf];
	buffer[12] = hex[(length >>  4) & 0xf];
	buffer[13] = hex[ length		& 0xf];
	length += 14;

	/*
	 * Calculate CRC
	 */

	crc = crc_block(&buffer[2], length-2);

#ifdef DEBUG
	{
		FILE *fp;
		fp = fopen("EMSI_DAT.TX", "wb");
		if(fp)
		{
			fwrite(buffer, length, 1, fp);
			fclose(fp);
		}
	}
#endif

	/*---------*
	 | State 1 |
	 ----------*/

	tries = 0;
	t1 = timerset(6000);
	emsibuf[0] = '\0';

	for(;;)
	{
		/*---------*
		 | State 2 |
		 ----------*/

		SENDCHARS(buffer, length, TRUE);		/* Transmit EMSI_DAT */
		CLEAR_INBOUND();
		put_hex(crc);
		SENDBYTE('\r');

		tries++;

		if(tries > 6)
		{
			free(buffer);
			return EMSI_ABORT;
		}

		/*---------*
		 | State 3 |
		 ----------*/

		t2 = timerset(2000);

		/*---------*
		 | State 4 |
		 ----------*/

		for(;;)
		{
			if(check_abort(t1, NULL))
			{
				free(buffer);
				return EMSI_ABORT;
			}
			if(timeup(t2))
				break;
			if(CHAR_AVAIL())
			{
				unsigned char c = MODEM_IN();
				int pkt;

				pkt = check_emsi(c, emsibuf);
				if(pkt == EMSI_ACK)
				{
					free(buffer);
					return EMSI_SUCCESS;
				}
				if((pkt >= 0) && (pkt != EMSI_REQ))
					break;
			}
		}
	}
}

/*------------------------------------------------------------
 * Receive EMSI_DAT packet
 *
 * I'm going to do this just as one function instead of a state machine
 *
 *
 * Extract a field from the data
 *
 * Similar to strtok() but understands escape sequences \ab \\ }} and ]]
 *
 * The first time it is called you should pass the buffer address
 * future calls may pass NULL to continmue with next field
 *
 * fields are {...} and [...]
 * double }} and ]] are converted to single characters
 *
 * Note the actual data buffer is altered by having nulls put in
 *
 * returns NULL if any error.
 */

static char *last_field = NULL;

static char *get_field(char *dat)
{
	char sep;
	char *s, *s1;

	if(dat == NULL)
		dat = last_field;

	if(dat == NULL)
		return NULL;

	sep = *dat++;
	if(sep == '{')
		sep = '}';
	else if(sep == '[')
		sep = ']';
	else
		return NULL;

	s = s1 = dat;
	while(*s)
	{
		unsigned char c = *s++;

		if(c == sep)
		{
			if(*s == sep)	/* Double end brace */
				s++;
			else			/* Single end brace marks end */
			{
				*s1 = 0;
				last_field = s;
				return dat;
			}
		}
		else if( (c == '\\') && (sep == '}') && (*s != '}'))	/* hex escape */
		{
			int n;

			c = *s++;
			n = byte_to_hex(c);
			if(!(n & ~15))
			{
				c = n;
				n = byte_to_hex(*s);
				if(!(n & ~15))			/* If 2nd digit is not hex?? */
				{
					s++;
					c = (c << 4) | n;
				}
			}
		}
		*s1++ = c;
	}
	return NULL;
}

/*
 * Add an address to the list of remote addresses
 */

static int add_remotead(ADDR *ad)
{
	ADDR_LIST *ads;
	ADDR_LIST *newad;
	
	ads = &remote_ads;	/* This should be empty, but we'll go to the end anyway! */
	while(ads->next)
		ads = ads->next;

	newad = malloc(sizeof(ADDR_LIST));
	if(newad)
	{
		newad->ad = *ad;	/* Structure copy */
		newad->next = NULL;
		ads->next = newad;
		ads = newad;
	}
	else
	{
		status_line(msgtxt[M_EMSI_NOMEM]);
		return EMSI_ABORT;
	}
    return EMSI_SUCCESS;
}

static void show_akas(void)
{
	ADDR_LIST *ads;
	#define AKA_BUFLEN 76
	char buffer[AKA_BUFLEN];
	size_t bufpos = 0;

	/* Process each address */

	ads = remote_ads.next;
	if(ads)						/* Skip 1st address */
		ads = ads->next;
		
	while(ads)
	{
		char *s = Full_Addr_Str(&ads->ad);
		size_t len = strlen(s);
		
		if((len + bufpos + 1) >= AKA_BUFLEN)
		{
			status_line(buffer);
			bufpos = 0;
		}
		if(bufpos == 0)
		{
			strcpy(buffer, "*Aka:");
			bufpos = strlen(buffer);
		}
		buffer[bufpos++] = ' ';			/* Space between entries */
		strcpy(buffer+bufpos, s);		/* Potential Bug... if s is long */
		bufpos += len;

		ads = ads->next;
	}
	if(bufpos != 0)
		status_line(buffer);
}

/*
 * Process the incoming EMSI_DAT packet
 */


static int process_dat(unsigned char *dat, BOOLEAN sender)
{
	char *s, *s1, *s2, *s3, *offset;
	ADDR ad;
	int n, time_offset;
	int ret = EMSI_SUCCESS;
	BOOLEAN first = TRUE;	

	/* fingerprint */

	s = get_field(dat);		/* Finger print */
	if(!s || stricmp(s, "EMSI"))
		return EMSI_ABORT;

	/* Addresses */

	s = get_field(NULL);
	if(!s)
		return EMSI_ABORT;

	n = 0;
	s = strtok(s, " ");
	while(s)
	{
		if(find_address(s, &ad))
		{
			if(fullscreen)
			{
				if(n && (n < 6))	/* Display AKA's (not 1st address) */
				{
					if(n == 1)		/* Clear Window on 1st pass */
						sb_fill(holdwin, ' ', colors.hold);

					sb_move(holdwin, n, 1);
					sb_puts(holdwin, Pretty_Addr_Str(&ad));
				}
				n++;
			}

#ifdef DEBUG
			if(debugging_log)
				status_line(">Address: %s", Pretty_Addr_Str(&ad));
#endif

			if(first)
			{
				first = FALSE;
				remote_addr = ad;				/* Make 1st address the remote_addr */
				status_line(msgtxt[M_REMOTE_ADDRESS], Pretty_Addr_Str(&ad));
			}

			if(add_remotead(&ad) != EMSI_SUCCESS)
				return EMSI_ABORT;
		}

		s = strtok(NULL, " ");
	}
	sb_show();
	show_akas();

	/* Password */

	s = get_field(NULL);
	if(!s)
		return EMSI_ABORT;

	if(sender && !s[0])
	{
		if(n_getpassword(&remote_addr))
			status_line(msgtxt[M_PASSWORD_OVERRIDE]);
	}
	else
	if(n_password(&remote_addr, s, TRUE))		/* Only receiver checks password */
	{
		if(sender)
			status_line(msgtxt[M_PASSWORD_OVERRIDE]);
		else
			ret = EMSI_ABORT;	/* Or do the hangup here? */
	}
	if(remote_password)
		session_password = strdup(remote_password);
	else
		session_password = NULL;

	/* Link codes */

	s = get_field(NULL);
	if(!s)
		return EMSI_ABORT;
	emsi_options = PUA;	/* Default to all addresses */
	s = strtok(s, ",");
	while(s)
	{
		if(!stricmp(s, "PUA"))
			emsi_options = PUA;
		else if(!stricmp(s, "PUP"))
			emsi_options = PUP;
		else if(!stricmp(s, "NPU"))
			emsi_options = NPU;
		else if(!stricmp(s, "HAT"))
			emsi_remote_capability |= EMSI_O_HAT;
		else if(!stricmp(s, "HXT"))
			emsi_remote_capability |= EMSI_O_HXT;
		else if(!stricmp(s, "HRQ"))
			emsi_remote_capability |= EMSI_O_HRQ;

		s = strtok(NULL, ",");
	}

	/* Ignore this for time being
	 *	We should be looking for:
	 *		PUA/PUP/NPU if we are receiver
	 *		HAT/HXT/HRQ if we are sender
	 */

	/* Compatibility */

	s = get_field(NULL);
	s = strtok(s, ",");
	while(s)
	{
		if(!stricmp(s, "DZA"))
			emsi_remote_capability |= EMSI_P_DZA;
		if(!stricmp(s, "ZAP"))
			emsi_remote_capability |= EMSI_P_ZAP;
		if(!stricmp(s, "ZMO"))
			emsi_remote_capability |= EMSI_P_ZMO;
		if(!stricmp(s, "JAN"))
			emsi_remote_capability |= EMSI_P_JAN;
		if(!stricmp(s, "KER"))
			emsi_remote_capability |= EMSI_P_KER;
		/* Also check for NCP/NRQ/ARC/XMA/FNC */
		if(!stricmp(s, "NRQ"))
			emsi_remote_capability |= EMSI_P_NRQ;

		s = strtok(NULL, ",");
	}
	if(sender)
		emsi_protocol = emsi_remote_capability & emsi_capability &
			(EMSI_P_DZA | EMSI_P_ZAP | EMSI_P_ZMO | EMSI_P_JAN | EMSI_P_KER);

	/* Mailer code */

	s = get_field(NULL);		/* Code */
	s1 = get_field(NULL);		/* Name */
	s2 = get_field(NULL);		/* Version */
	s3 = get_field(NULL);		/* Revision */
	status_line ("%s %s %s/%s (%s)", msgtxt[M_REMOTE_USES], s1, s2, s3, s);

	/* Extra fields */

	s = get_field(NULL);
	while(s)
	{
		/* 1st field is identifier */

		if(!stricmp(s, "IDENT"))
		{
			char *last_tok;
			s = get_field(NULL);	/* Identifier */
			last_tok = last_field;

			/* Parse IDENT */

			s = get_field(s);
			if(s && *s)
				status_line(msgtxt[M_EMSI_SYSTEM], s);	/* System name */
			s = get_field(NULL);
			if(s && *s)
				status_line(msgtxt[M_EMSI_LOCATION], s);
			s = get_field(NULL);
			if(s && *s)
				status_line(msgtxt[M_EMSI_SYSOP], s);
			s = get_field(NULL);
			if(s && *s)
				status_line(msgtxt[M_EMSI_PHONE], s);
			s = get_field(NULL);
			if(s && *s)
				status_line(msgtxt[M_EMSI_BAUD], s);
			s = get_field(NULL);
			if(s && *s)
				status_line(msgtxt[M_EMSI_FLAGS], s);

			last_field = last_tok;
		}
		else
		if(!stricmp(s, "TRX#"))
		{
			char *last_tok;
			struct tm thetime;	/* Complete structure */
			time_t newtime;

			s = get_field(NULL);
			last_tok = last_field;

			s = get_field(s);				/* Number is enclosed in [] */
			status_line(":Tranx: %s / %08lx", s, (long)ourTrx);

			/* convert s to time_t */
				
			if(sscanf(s, "%08lx", &newtime) == 1)
			{
				union {
					DOSTIME dos;
					long tos;
				} tostime;
				
				memcpy(&thetime, localtime(&newtime), sizeof(thetime));
				
				status_line("#Remote's time is %s", asctime(&thetime));

				if(tranx_list && find_ad_strlist(tranx_list, &remote_addr, &offset))
				{
					if (offset)
					{	
						time_offset = (int) (3600L * atol (offset));
						
						/*
						** if time_offset is 0 then don't display
						** corrected time
						*/
						
						if (time_offset)						
						{
							newtime += time_offset;
							memcpy(&thetime, localtime(&newtime), sizeof(thetime));
							status_line("#Corrected time is %s", asctime(&thetime));
						}
					}
						
					status_line(":Updating our clock to %s", asctime(&thetime));		
			
					tostime.dos.time = ((thetime.tm_sec + 1) >> 1)
							          + (thetime.tm_min      << 5)
							          + (thetime.tm_hour     << 11);
					tostime.dos.date = ( thetime.tm_mday            )
							         + ((thetime.tm_mon + 1 )  <<  5)
							         + ((thetime.tm_year - 80) <<  9);
					Settime(tostime.tos);	/* TOS time/date */
					Tsettime(tostime.dos.time); /* DOS time      */
					Tsetdate(tostime.dos.date); /* DOS date      */
				}
			}
			else
				status_line(":Tranx: couldn't convert %s to time", s);
			
			last_field = last_tok;
		}
		else
		if(!stricmp(s, "MOH#"))
		{
			char *last_tok;
			
			s = get_field(NULL);
			last_tok = last_field;

			s = get_field(s);				/* Number is enclosed in [] */
			status_line(":MailOnHold: %lu bytes", strtoul(s, NULL, 16));
			
			last_field = last_tok;
		}
		else
		{
#ifdef DEBUG
			status_line("#EMSI: Extra field : %s", s);
#endif
			s = get_field(NULL);
#ifdef DEBUG
			status_line("#EMSI: Field Data : %s", s);
#endif
		}
		s = get_field(NULL);
	}

	return ret;
}

/*
 * Read the actual packet and its crc
 *
 * return 0: EMSI_SUCCESS : OK
 *		 -1: EMSI_ABORT   : abort (no carrier or keyboard escape)
 *		 -2: EMSI_RETRY   : Timeout or CRC error
 *
 * emsibuf excludes the **, i.e. it is "EMSI_DAT<len16>"
 */

static int read_emsi_dat(char *emsibuf, BOOLEAN sender)
{
	unsigned char *dat;
	int length;
	char *ptr;
	int count;
	UWORD crc;
	UWORD check;

	/* Get the packet length */

	if(sscanf(&emsibuf[8], "%04x", &length) != 1)	/* read hex-value */
		return EMSI_RETRY;
#ifdef DEBUG
	if(debugging_log)
		status_line(">EMSI_DAT <len16> = %04x", length);
#endif
	if(length > 4096)		/* Assume >4K is silly */
		return EMSI_RETRY;

	dat = malloc((size_t)length);
	if(!dat)	/* Out of memory! */
	{
		status_line(msgtxt[M_EMSI_NOMEM]);
		return EMSI_ABORT;
	}

	/*
	 * Initialise the CRC:
	 * The specs aren't very clear on this, but I'll assume
	 * for now that it includes all of "EMSI_DAT<len16><data>"
	 *
	 * Also is the length and crc apply to the data before or after
	 * escaping 8 bit data?  I will assume it applies to the binary data
	 */

	crc = crc_block(emsibuf, 8+4);	/* EMSI_DAT <len16> */

	/* Read in all the data */

	count = length;
	ptr = dat;
	while(count--)
	{
		int c;

		if(check_abort(0L, NULL))	/* Abort if no carrier or keypress */
		{
			free(dat);
			return EMSI_ABORT;
		}
		c = Z_GetByte(100);			/* Wait up to 10 seconds */
		if(c < 0)
		{
			free(dat);
			return EMSI_RETRY;
		}

		crc = xcrc(crc, c);
		*ptr++ = c;
	}

	/* Get the checksum */

	count = 4;
	check = 0;
	while(count--)
	{
		int c = Z_GetByte(100);
		if(c < 0)
		{
			free(dat);
			return EMSI_RETRY;
		}
		c = byte_to_hex(c);
		if(c & ~0xf)
		{
			free(dat);
			return EMSI_RETRY;
		}
		check = (check << 4) | c;
	}

#ifdef DEBUG
	/* Dump the data into a file for perusal */
	{
		FILE *fp = fopen("EMSI_DAT.RX", "wb");
		if(fp)
		{
			fwrite(dat, (size_t)length, 1, fp);
			fclose(fp);
		}
	}
#endif

	if(check != crc)
	{
		status_line("+%s %s (crc=%04x, check=%04x)", msgtxt[M_CRC_MSG], emsibuf, crc, check);
		free(dat);
		return EMSI_RETRY;
	}

	/*
	 * Acknowledge it
	 */

	send_emsi(EMSI_ACK, TRUE);
	send_emsi(EMSI_ACK, TRUE);

	/*
	 * Process it
	 */

	if(process_dat(dat, sender) < 0)
	{
		free(dat);
		return EMSI_ABORT;
	}

	free(dat);
	return EMSI_SUCCESS;
}


static int RxEMSI_DAT(BOOLEAN sender)
{
	char emsibuf[EMSI_IDLEN+1];
	int tries;
	long t1;
	long t2;

	/*---------*
	 | State 1 |
	 *---------*/

	tries = 0;
	t1 = timerset(2000);	/* 20 seconds */
	t2 = timerset(6000);	/* 60 second timer */
	emsibuf[0] = '\0';

	for(;;)
	{
		/*---------*
		 | State 2 |
		 *---------*/

		tries++;
		if(tries > 6)
			return -1;			/* Terminate and report failure */
		if(!sender)
			send_emsi(EMSI_REQ, TRUE);
		else if(tries > 1)
			send_emsi(EMSI_NAK, TRUE);

		/*---------*
		 | State 3 |
		 *---------*/

		t1 = timerset(2000);

		/*---------*
		 | State 4 |
		 *---------*/

		for(;;)
		{
			if(check_abort(t2, NULL))		/* If Timer2 expired, terminate */
				return -1;
			if(timeup(t1))					/* If timer1 expired goto state 2 */
				break;
			if(CHAR_AVAIL())
			{
				unsigned char c = MODEM_IN();
				int pkt;

				pkt = check_emsi(c, emsibuf);

				if(pkt == EMSI_HBT)			/* Heartbeat */
					t1 = timerset(2000);
				else if(pkt == EMSI_DAT)	/* Data packet */
				{
					int val = read_emsi_dat(&emsibuf[2], sender);
					if(val == EMSI_SUCCESS)
						return EMSI_SUCCESS;
					else if(val == EMSI_ABORT)
						return EMSI_ABORT;
					else
						break;			/* Goto step 2 */
				}
			}
		}
	}
}


/*--------------------------------------------------------------------------*/
/* Send files for one address												*/
/*	 returns TRUE (1) for good xfer, FALSE (0) for bad						*/
/*--------------------------------------------------------------------------*/

static int fsent;

/*
 * EMSI_callback () -- send requested file using WaZOO method.
 *
 */

static int EMSI_callback (char *reqs)
{
#ifdef DEBUG
	if(debugging_log)
		status_line(">EMSI_callback(%s)", reqs);
#endif
   return (Send_Zmodem (reqs, NULL, fsent++, DO_WAZOO));
}

static int send_to_address(ADDR *ad)
{
	char fname[80];
	char s[80];
	char *HoldName;
	struct stat buf;

	char *extptr;

	/* Ignore unknown domains */

#ifdef DEBUG
 	status_line("#Checking mail for %s", Pretty_Addr_Str(ad));
#endif

	if(!isKnownDomain(ad))
		return TRUE;

	/* Check the password for every aka */

	if(session_password)
	{
		char *nf = CurrentNetFiles;	/* remember the inbound directory we are in! */
		BOOLEAN flag = n_password(ad, session_password, FALSE);
		CurrentNetFiles = nf;		/* Restore inbound folder */

		if(flag)
		{
#ifdef DEBUG
			if(debugging_log)
				status_line(">No session password defined for address %s",
					Pretty_Addr_Str(ad));
#endif
			return TRUE;	/* return but don't abort! */
		}
	}
	status_line(msgtxt[M_SENDING_FOR], Pretty_Addr_Str(ad));

	if (flag_file (TEST_AND_SET, ad, 1))
		goto done_send;

	HoldName = HoldAreaNameMunge(ad);

	/*--------------------------------------------------------------------*/
	/* Send all waiting ?UT files (mail packets)						 */
	/*--------------------------------------------------------------------*/

	extptr = "ODCH";
	while(*extptr)
	{
		char ch = *extptr++;
		
		if (caller && (ch == 'H') && !check_holdonus(ad, (char**)NULL))
			continue;

		/*
		 * 2D style OUT uncompressed packets
		 */
		
		sprintf (fname,
				"%s%s.%cUT",
				HoldName, Hex_Addr_Str (ad), ch);

		if (!stat (fname, &buf))
		{

			/*--- Build a dummy PKT file name */

			invent_pkt_name (s);

			/*--- Tell ZModem to handle this as a SEND AS then DELETE */

			status_line (msgtxt[M_PACKET_MSG]);

			if (!Send_Zmodem (fname, s, fsent++, DO_WAZOO))
			{
				net_problems = 1;
				flag_file (CLEAR_FLAG, ad, 1);
#ifdef DEBUG
				if(debugging_log)
					status_line(">Error sending packet %s", fname);
#endif
				return FALSE;
			}
			CLEAR_IOERR ();
			unlink (fname);
		}

#ifdef IOS
		/*
		 * New 4D style OPT Uncompressed packets
		 */
			 
		sprintf(fname, "%s%s.%cPT", HoldName, Addr36(ad), ch);
		if(!stat(fname, &buf))
		{
			invent_pkt_name(s);
			status_line(msgtxt[M_PACKET_MSG]);

			if(!Send_Zmodem(fname, s, fsent++, DO_WAZOO))
			{
			ios_error:
				net_problems = 1;
				flag_file(CLEAR_FLAG, ad, 1);
#ifdef DEBUG
				if(debugging_log)
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
			 
		if(!(emsi_remote_capability & EMSI_O_HXT))	/* Other end accepts compressed mail! */
		{
			sprintf(fname, "%s%s.%cAT", HoldName, Addr36(ad), ch);
			if(!stat(fname, &buf))
			{
				make_dummy_arcmail(s, &alias[assumed].ad, ad);
				status_line(msgtxt[M_PACKET_MSG]);

				if(!Send_Zmodem(fname, s, fsent++, DO_WAZOO))
					goto ios_error;
				CLEAR_IOERR();
				unlink(fname);
			}
		}
#endif


	}		 /* for */

	/*--------------------------------------------------------------------*/
	/* Send files listed in ?LO files (attached files)					  */
	/*--------------------------------------------------------------------*/

	if(!(emsi_remote_capability & EMSI_O_HXT))	/* Doesnt want compressed mail */
	{
		if(!do_FLOfile("FDCH", EMSI_callback, ad))
		{
		flo_error:
			flag_file (CLEAR_FLAG, ad, 1);
#ifdef DEBUG
			if(debugging_log)
				status_line(">Error processing FLOfiles", fname);
#endif
			return FALSE;
		}

#ifdef IOS
		if(!do_FLOfile("DHOC", EMSI_callback, ad))
			goto flo_error;
#endif	

	}

	/*--------------------------------------------------------------------*/
	/* Send our File requests to other system							  */
	/*--------------------------------------------------------------------*/

/* #ifndef NEW */ /* TRYREQ	26.08.1990 */
	if (requests_ok)
/* #endif */
	{
		sprintf (fname, request_template, HoldName, Hex_Addr_Str(ad));
		if (!stat (fname, &buf))
		{
			if(emsi_remote_capability & (EMSI_P_NRQ | EMSI_O_HRQ))
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
			if (caller && (c == 'H') && !check_holdonus(ad, (char**)NULL))
				continue;
			sprintf(fname, "%s%s.%cRT", HoldName, Addr36(ad), c);
			if(!stat(fname, &buf))
			{
				if(emsi_remote_capability & (EMSI_P_NRQ | EMSI_O_HRQ))
					status_line (msgtxt[M_FREQ_DECLINED]);
				else
				{
					status_line (msgtxt[M_OUT_REQUESTS]);
					++made_request;
					sprintf (s, request_template, HoldName, Hex_Addr_Str(ad));
					if (Send_Zmodem (fname, s, fsent++, DO_WAZOO))
						unlink (fname);
				}
			}			
		}
#endif
	}

	flag_file (CLEAR_FLAG, ad, 1);

done_send:

	bad_call(ad, BAD_REMOVE);		/* Clear $$ files */

	return TRUE;

}												 /* WaZOO */

/*---------------------------------------------
 * Send files for all addresses using send_to_address
 *
 * Loop through all addresses and set called_addr
 */

static void send_all_files(BOOLEAN sender)
{
	ADDR_LIST *ads;

	/* Intialise */

	fsent = 0;

	if ( sender )
	{
	}
	
	if(emsi_remote_capability & EMSI_O_HAT)
	{
		status_line("#Remote asked to Hold All Traffic");
		bad_call(&remote_addr, BAD_STOPCALL);
	}
    else
	if(emsi_options != NPU)
	{
		if(emsi_options & PUP)		/* Only send to primary address */
		{
			if(!send_to_address(&remote_addr))
				return;
		}
		else	/* Assume PUA */
		{

			/* Process each address */

			ads = remote_ads.next;	/* This should be empty, but we'll go to the end anyway! */
			while(ads)
			{
				if(!send_to_address(&ads->ad))	/* Send the mail */
					return;						/* Abort if error */
				ads = ads->next;
			}

		}

		/*
		 * respond_to_file_requests acts on all addresses so do it here
		 *
		 * If receiver then files are to be sent with main batch
		 * otherwise they are sent as a seperate phase later
		 */

		if(!caller)
			fsent = respond_to_file_requests (fsent, EMSI_callback);

		/* Finish off */

		if (!fsent)
			status_line (msgtxt[M_NOTHING_TO_SEND], Pretty_Addr_Str(&remote_addr));
	}

	status_line(msgtxt[M_EMSI_FILES], fsent);

	Send_Zmodem (NULL, NULL, fsent ? END_BATCH : NOTHING_TO_DO, DO_WAZOO);
#if 0
	Send_Zmodem (NULL, NULL, NOTHING_TO_DO, DO_WAZOO);
	Send_Zmodem (NULL, NULL, (fsent ? END_BATCH : NOTHING_TO_DO), DO_WAZOO);
	Send_Zmodem (NULL, NULL, ((fsent) ? END_BATCH : EMPTY_BATCH), DO_WAZOO);
#endif

	sent_mail = 1;
}

/*------------------------------------------------------------------
 * Do an EMSI session
 */

/* this mostly copied from b_wazoo.c and modified */

static int EMSI_session(BOOLEAN sender)
{
	int stat;
	/* int i = 0; */
	char j[100];
	char k[100];
	int error = EMSI_SUCCESS;

   /*--------------------------------------------------------------------*/
   /* Initialize WaZOO													 */
   /*--------------------------------------------------------------------*/
   stat =
	  made_request =
	  got_arcmail =
	  got_packet = 0;

   Netmail_Session = 1;

   isOriginator = sender;

   if (sender &&
	  ((remote_addr.Zone != called_addr.Zone) ||
	   (remote_addr.Net != called_addr.Net) ||
	   (remote_addr.Node != called_addr.Node) ||
	   (remote_addr.Point != called_addr.Point) ||
	   (remote_addr.Domain != called_addr.Domain)))
	{
		/* 
		 * Do NOT say this message if the node is a host
		 * or a region-Node
		 */

		if ((called_addr.Node != 0) && (called_addr.Net >= 100))
		{
			sprintf (k, "%s", Pretty_Addr_Str (&remote_addr));
			sprintf (j, msgtxt[M_CALLED], Pretty_Addr_Str (&called_addr), k);
			status_line (j);
		}
		add_remotead(&called_addr);
	}
	else
		called_addr = remote_addr;

	if (!CARRIER)
	{
		error = EMSI_ABORT;
		goto endemsi;
	}

	/* Make sure we have the correct inbound area for the remote */

	nodefind(&remote_addr, FALSE);

	/* Set up Wazoo compatible compatibilities */

	if(emsi_remote_capability & (EMSI_P_NRQ | EMSI_O_HRQ))	/* Can we do File requests? */
		remote_capabilities = 0;
	else
		remote_capabilities = WZ_FREQ;

   /* Try Janus first */
	if (emsi_protocol & EMSI_P_JAN)
	{
		status_line ("%s Janus", msgtxt[M_EMSI_METHOD]);
		remote_capabilities |= DOES_IANUS;
		Janus ();
		goto endemsi;
	}

	/* See if we can both do ZEDZAP */

	if (emsi_protocol & EMSI_P_ZAP)
	{
		status_line ("%s ZedZap", msgtxt[M_EMSI_METHOD]);
		remote_capabilities |= ZED_ZAPPER;
	}
	else if (emsi_protocol & EMSI_P_ZMO)
	{
		status_line ("%s ZedZip", msgtxt[M_EMSI_METHOD]);
		remote_capabilities |= ZED_ZIPPER;
	}
	else
	{
		status_line("%s %s", msgtxt[M_EMSI_METHOD], msgtxt[M_NONE]);
		error = EMSI_ABORT;
		goto endemsi;
	}

	/* ZMODEMBLOCKLEN  07/16/90 07:43pm */
	blklen = 0;

	/*--------------------------------------------------------------------*/
	/* ORIGINATOR: send/receive/send									  */
	/*--------------------------------------------------------------------*/

	if (sender)
	{

		send_all_files(sender);
#ifdef DEBUG
		if(debugging_log)
			status_line(">Finished SEND phase");
#endif
		if (!CARRIER)
			goto endemsi;
		if(!get_Zmodem (CurrentNetFiles, NULL))
			goto endemsi;
#ifdef DEBUG
		if(debugging_log)
			status_line(">Finished RECEIVE phase");
#endif
		if (!CARRIER)
			goto endemsi;

		if(check_reqonus(&remote_addr, (char**)NULL))
			stat = respond_to_file_requests (0, WaZOO_callback);	/* was (i, WaZOO_callback) */

		if (stat)
			Send_Zmodem (NULL, NULL, ((stat) ? END_BATCH : NOTHING_TO_DO), DO_WAZOO);
		mail_finished = 1;
	}

   /*--------------------------------------------------------------------*/
   /* CALLED SYSTEM: receive/send/receive								 */
   /*--------------------------------------------------------------------*/
	else
	{
		if (!get_Zmodem (CurrentNetFiles, NULL))
			goto endemsi;
#ifdef DEBUG
		if(debugging_log)
			status_line(">Finished RECEIVE phase");
#endif
		if (!CARRIER)
			goto endemsi;
		send_all_files(sender);
#ifdef DEBUG
		if(debugging_log)
			status_line(">Finished SEND phase");
#endif
		if (!CARRIER || !made_request)
			goto endemsi;
		get_Zmodem (CurrentNetFiles, NULL);
	}

endemsi:
	status_line (msgtxt[M_EMSI_END]);

	if(session_password)
	{
		free(session_password);
		session_password = NULL;
	}

	return error;
}

/*
 * Do session
 */

int EMSI_sender(void)
{
	if (un_attended && fullscreen)
	{
		sb_move (filewin, 2, 2);
		sb_puts (filewin, "EMSI");
		sb_show ();
	}
	else
		set_xy ("EMSI ");

	emsi_capability = emsi_remote_capability = emsi_protocol = 0;

	initTrx();

	if(TxEMSI_DAT(TRUE))
		return 0;

	if (un_attended && fullscreen)
	{
		sb_puts (filewin, "/Tx");
		sb_show ();
	}
	else
		set_xy ("EMSI/Tx");

	if(RxEMSI_DAT(TRUE))
		return 0;

	if (un_attended && fullscreen)
	{
		sb_puts (filewin, "/Rx");
		sb_show ();
	}
	else
		set_xy ("EMSI/Rx");

	EMSI_session(TRUE);

	return 0;
}

/*
 * Do Receiver session
 */

int EMSI_receiver(void)
{
	if (un_attended && fullscreen)
	{
		sb_move (filewin, 2, 2);
		sb_puts (filewin, "EMSI");
		sb_show ();
	}
	else
		set_xy ("EMSI ");

	emsi_capability = emsi_remote_capability = emsi_protocol = 0;

	initTrx();

	if(RxEMSI_DAT(FALSE))
		return 0;

	if (un_attended && fullscreen)
	{
		sb_puts (filewin, "/Rx");
		sb_show ();
	}
	else
		set_xy ("EMSI/Rx");

	if(TxEMSI_DAT(FALSE))
		return 0;

	if (un_attended && fullscreen)
	{
		sb_puts (filewin, "/Tx");
		sb_show ();
	}
	else
		set_xy ("EMSI Rx/Tx");


	last_type (1, &remote_addr);
	++hist.mail_calls;
	if (un_attended && fullscreen)
	{
		sb_move (historywin, HIST_MAIL_ROW, HIST_COL);
		sprintf (junk, "%d/%d/%d",
				hist.bbs_calls, hist.mail_calls, hist.extmails);
		sb_puts (historywin, junk);
	}

	EMSI_session(FALSE);

	return 0;
}

