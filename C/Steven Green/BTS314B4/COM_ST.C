/*
 * com_st.c
 *
 * Atari ST specific Comms stuff
 *
 * see also com.h and com_st.h
 *
 */

#include <stdio.h>
#ifdef __TOS__
#pragma warn -sus
#include <stddef.h>
#else
#include <osbind.h>
#endif
#include <portab.h>
#include <time.h>
#include <stdlib.h>

#include "bink.h"
#include "com.h"

#ifndef min
#define min(a,b)	 ((a)<=(b)?(a):(b))
#endif

#ifdef TXINT
extern long set_txint(void);
extern long reset_txint(void);
#endif


#if !defined(LATTICE) || (__REVISION__ < 50)
/*
 * Bios I/O Record
 */

struct iorec {
	char *ibuf;
	short ibufsiz;
	volatile short ibufhd;	/* New characters written here */
	volatile short ibuftl;	/* Read characters from here */
	short ibuflow;
	short ibufhi;
};
#endif

/*
 * Variables used by BUFFER_BYTES
 */

#define TSIZE 8192					/* Default buffer sizes */
#define RSIZE 8192

static unsigned char zTxBuf[TSIZE];
static size_t zpos = 0;

#if 0
static unsigned char rbuf[RSIZE];
static unsigned char tbuf[TSIZE];
#else
static unsigned char *rbuf = NULL;	/* New RS232 buffers */
static unsigned char *tbuf = NULL;

size_t tBufSize = 8192;			/* New size of buffers */
size_t rBufSize = 8192;

#endif

static short old_obufsize = 0;		/* Old output buffer */
static char *old_obuf = NULL;
static short old_obuflow;
static short old_obufhi;
static short old_ibufsize = 0;		/* Old input buffer */
static char *old_ibuf = NULL;
static short old_ibuflow;
static short old_ibufhi;

BOOLEAN ikbdclock = FALSE;			/* IKBD clock update Disabled by default */
int ctsflow = USE_CTS;				/* RTS/CTS is enabled */
BOOLEAN hard_38400 = FALSE;			/* set if using hardware 38400 locking */
BOOLEAN rsve_board = FALSE;			/* RSVE board installed	*/

/* int xonflow = USE_XON; */		/* Xon/Xoff is enabled during Zmodem */
static unsigned int last_baud = 0;	/* Current setting */

static BOOLEAN is_installed = FALSE;

BOOLEAN HardCTS = FALSE;				/* Use Hardware CTS checking! */

/*
 * Initialise comms port
 *
 * Currently the port is ignored, but it may be possible later to provide
 * support to any device that lets you have several ports
 *
 * It may also be neccessary to fiddle with the iobuffers to make their
 * sizes configurable.
 *
 */

int Cominit(int port)
{
	struct iorec *io = Iorec(0);		/* Input buffer */

	if ( port )
	{
	}
	
	if(!is_installed)
	{

#ifdef TXINT
		Supexec(set_txint);					/* Change the interrupt vector */
#endif

		if(rBufSize)
		{
			if(rbuf == NULL)
			{
				rbuf = malloc(rBufSize);
				if(rbuf == NULL)
				{
					status_line("!Could not allocate memory for RS232 buffers");
					return -1;
				}
#ifdef DEBUG
				status_line(">Allocated %d bytes for RBUF", (int)rBufSize);
#endif
			}
			old_ibuf = io->ibuf;
			old_ibufsize = io->ibufsiz;
			old_ibuflow = io->ibuflow;
			old_ibufhi = io->ibufhi;

			Jdisint(12);				/* Disable receive buffer full interrupt */
			io->ibufhd = 0;				/* the order of these 2 is important */
			io->ibuftl = 0;
			io->ibuf = rbuf;
			io->ibufsiz = (int) rBufSize;
			io->ibuflow = (short) (rBufSize >> 2);		/* 1/4 buffer size */
			io->ibufhi = (short) (rBufSize - (rBufSize >> 2));	/* 3/4 buffer size */
			Jenabint(12);
		}
		else
		{
			rBufSize = io->ibufsiz;
			rbuf = io->ibuf;
#ifdef DEBUG
			status_line(">Using default RBUF of %d bytes", (int)rBufSize);
#endif			
		}
		
		/* Fiddle transmit buffer */	

		io++;						/* Advance to output buffer */

		if(tBufSize)
		{
			if(tbuf == NULL)
			{
				tbuf = malloc(tBufSize);
				if(tbuf == NULL)
				{
					status_line("!Could not allocate memory for RS232 buffers");
					return -1;
				}
#ifdef DEBUG
				status_line(">Allocated %d bytes for TBUF", (int)tBufSize);
#endif
			}
			
			old_obuf = io->ibuf;
			old_obufsize = io->ibufsiz;
			old_obuflow = io->ibuflow;
			old_obufhi = io->ibufhi;
	
			Jdisint(10);				/* Disable transmit buffer empty interrupt */
			io->ibuftl = 0;				/* the order of these 2 is important */
			io->ibufhd = 0;
			io->ibuf = tbuf;
			io->ibufsiz = (int) tBufSize;
			io->ibuflow = (short)(tBufSize/4);		/* 1/4 buffer size */
			io->ibufhi = (short)((tBufSize*3)/4);	/* 3/4 buffer size */
			Jenabint(10);
		}
		else
		{
			tBufSize = io->ibufsiz;
			tbuf = io->ibuf;
#ifdef DEBUG
			status_line(">Using default RBUF of %d bytes", (int)tBufSize);
#endif			
		}

		is_installed = TRUE;

	}
		
#ifndef OLDCTS
	Rsconf(-1, ctsflow,-1,-1,-1,-1);	/* Enable RTS/CTS */
#endif


	last_baud = 0;
	zpos = 0;

	return 0x1954;				/* Return magic number */
}

/*
 * Close up the comms port and restore everything to normal
 */
 
void MDM_DISABLE(void)
{
	struct iorec *io = Iorec(0);		/* Input buffer */

	if(is_installed)
	{

		/* Restore receive buffer */

		if(old_ibuf != NULL)
		{
			Jdisint(12);				/* Disable receive buffer full interrupt */
			io->ibufhd = 0;				/* the order of these 2 is important */
			io->ibuftl = 0;
			io->ibuf = old_ibuf;
			io->ibufsiz = old_ibufsize;
			io->ibuflow = old_ibuflow;
			io->ibufhi = old_ibufhi;

			Jenabint(12);
			
			old_ibuf = NULL;
		}

		/* Restore transmit buffer */	

		io++;						/* Advance to output buffer */

		if(old_obuf != NULL)
		{
			Jdisint(10);				/* Disable transmit buffer empty interrupt */
			io->ibuftl = 0;				/* the order of these 2 is important */
			io->ibufhd = 0;
			io->ibuf = old_obuf;
			io->ibufsiz = old_obufsize;
			io->ibuflow = old_obuflow;
			io->ibufhi = old_obufhi;
			Jenabint(10);
			old_obuf = NULL;
		}
		
#ifdef TXINT
		Supexec(reset_txint);		/* Restore the interrupt vector */
#endif

		is_installed = FALSE;

	}
}


/*
 * Initialise modem to give baud rate
 *
 * The baud will be the bits defined as BAUD_??? in com_st.h
 *
 * Note that baud is now the actual baud rate rather than a mask
 */


static struct {
	unsigned short rate;
	short mask;
} rates[] = {
	{ 50L,15 },
	{ 75L,14 },
	{ 110L,13 },
	{ 134L,12 },
	{ 150L,11 },
	{ 200L,10 },
	{ 300L,9 },
	{ 600L,10 },
	{ 1200L,7 },
	{ 1800L,6 },
	{ 2000L,5 },
	{ 2400L,4 },
	{ 3600L,3 },
	{ 4800L,2 },
	{ 9600L,1 },
	{ 19200L,0 },
	{ 38400L,4 },	/* Same as 2400 baud, but without /16 */
	{ 57600L,12 },	/* with rsve */
	{ 115200L,11 },
	{ 0L,-1 }			/* End of list.. unchanged rate */
};

unsigned int st_lock_baud = 0;	/* Baud rate above which to force baud rate */


void MDM_ENABLE(unsigned baud)
{
	int i;
	
   if(st_lock_baud && (baud >= st_lock_baud))
   		baud = max_baud.rate_mask;

	if(hard_38400)			/* Adjust for hardware /2 counter */
		baud >>= 1;


	if(baud != last_baud)
	{
		UBYTE ucr = stop_bits|parity|comm_bits;

		if(baud != 38400L || (baud == 38400L && rsve_board))
			ucr |= 0x80;
#if 0
		else
			ucr |= 0x18;		/* Use 2 stop bits */
#endif

		last_baud = baud;

		if(rsve_board) rates[16].mask = 13;
		i = 0;
		while( rates[i].rate && (rates[i].rate != baud) )
			i++;

		if(rates[i].rate)
			Rsconf(rates[i].mask, -1, ucr, -1, -1, -1);
	}
}


/*
 * Find out if RS232 buffer is empty
 */

/* BOOLEAN OUT_EMPTY(void)
{	struct iorec *buf = Iorec(0);
	buf++;
	return (buf->ibufhd == buf->ibuftl);
} */


/*
 * Clear the output buffer
 */

void CLEAR_OUTBOUND(void)
{
	struct iorec *buf = Iorec(0);	/* Rs232 output buffer */
	buf++;

	buf->ibufhd = buf->ibuftl;		/* head = tail (interrupt changes hd) */

	zpos = 0;						/* Clear the buffer BUFFER */
}

/*
 * Clear the input buffer
 */

void CLEAR_INBOUND(void)
{
	struct iorec *buf = Iorec(0);
	buf->ibuftl = buf->ibufhd;		/* Set tail to head (int changes tl) */
}


/*
 * Output a character, but dont wait for buffer space
 *
 * Returns TRUE if character was output
 *		  FALSE if buffer was full
 */

BOOLEAN Com_Tx_NW(char c)
{
	if(Bcostat(1))
	{
#ifdef __TOS__
		Bconout(1, c);
		return TRUE;
#else
		return (BOOLEAN)Bconout(1, c);
#endif

	}
	else
		return FALSE;

}


/*
 * Send character, but buffer it up
 * and force a send with UNBUFFER_BYTES
 * used by zsend and janus
 */


void UNBUFFER_BYTES(void)
{
   if (zpos && CARRIER)
	  if(zpos == 1)
		SENDBYTE(zTxBuf[0]);
	  else
		SENDCHARS(zTxBuf,zpos,1 );

   zpos = 0;
}

void BUFFER_BYTE(unsigned char ch)
{
	  if (zpos == tBufSize)			/* If buffer full, then empty it */
		 UNBUFFER_BYTES();
	  zTxBuf[zpos++]  = ch;			/* Add character to buffer */
}


/*
 * ST specific Timer functions
 */

/* Return the ST's 200Hz clock counter (MUST be called in Superviser mode */

#define _HZ_200 (*((long *)0x4ba))

static long get_200hz(void)
{
	return _HZ_200;
}

/* Indicate timer is to time out in t/100 second */

long timerset(unsigned long t)
{
	return (long) (Supexec((long(*)(void))get_200hz) + t*2);
}

/*
 * Return TRUE if timer as timed out
 */

int timeup(long t)
{
	long newtime = Supexec((long(*)(void))get_200hz);

	/*
	 * It is possible that it wrapped around, but that only happens
	 * every 248 days.	Is it really worth it?
	 * OK... I never took into account signed numbers, but its still
	 * 4 months!!!!
	 */

	return (newtime >= t);
}

void dostime( int *hour, int *min, int *sec, int *hdths )
{
	time_t t;
	struct tm *dt;

	if(ikbdclock)
		update_time();
	
	time(&t);
	dt = localtime(&t);

	*hour	   = dt->tm_hour;						 /* current hour */
	*min	   = dt->tm_min;					  /* current minute */
	*sec	   = dt->tm_sec;					/* current second */
	*hdths	   = 0;								/* hundredths of seconds */
}

void dosdate( int *month, int *mday, int *year, int *weekday )
{
	time_t t;
	struct tm *dt;

	if(ikbdclock)
		update_time();
	
	time(&t);
	dt = localtime(&t);

	*mday	   = dt->tm_mday;						   /* current day */
	*month	   = dt->tm_mon;						/* current month */
	*year	   = dt->tm_year;						  /* current year */
	*weekday   = dt->tm_wday;					   /* current day of week */
}

void do_break(int onoff)
{
	Rsconf(-1,-1,-1,-1, onoff ? 9 : 1,-1);
}

/*
 * Update the GEMDOS clock from the IKBD one
 *
 * Its possible that odd things can happen if interrupts occur between
 * setting the date and time.  Lets hope it doesn't happen.
 */

void update_time(void)
{
	union {
		long ikbd;
		struct {
			short tosdate;
			short tostime;
		} tos;
	} thetime;
	short gemtime;

	if(ikbdclock)
	{
		thetime.ikbd = Gettime();
		gemtime = Tgettime() - thetime.tos.tostime;

		/* If 2 times differ by more than 2 seconds then update the TOS time */
	
		if((gemtime > 2) || (gemtime < -2))
		{
			Tsettime(thetime.tos.tostime);
			Tsetdate(thetime.tos.tosdate);
		}
	}
}
