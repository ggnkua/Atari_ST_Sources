/* conio.c - console iosystem for lisa 					*/ 
/* nq , dq , pget , kbdcmd , modify , keyint , addchar , tmertck , cputc, 
	cntrlst , auxcmd , auxget , cinstat , cgetc , coutstat , coninit  */

#include	"portab.h"
#include	"fs.h"
#include	"io.h"
#include	"interrup.h"


/****************************************************************************
** NOTES:
** 	08/09/85 ktb	changing conio to handle only console functions.
** 			aux and prn handled by their respective drivers.
** 			bios funcs routined via (new) bios.c
** 
** 			to disable these changes, define
** 				XBCONSTAT, XBCONIN, etc to TRUE
**			and don't include fs.h
** 
**
**	08 Aug 85 ktb	M0001.  added additional parm to ratint call.
** 
** goal of this module is to define routines:
** 	bconistat(h)					-- trap13, fnct 1 
** 	bcongetc(h)					-- trap13, fnct 2 
** 	bconout(h,parm is integer char value to display)-- trap13, fnct 3 
** 	coninit()
** 		where   h = a device in which {0 == prt, 1 == aux, 2 == cons}.
** 	cntrlst (flg)					-- trap13, fnct B
**  
****************************************************************************/

/*
**  conditional compile switches
*/

#define	XBCONIN		FALSE
#define	XBCONSTAT	FALSE
#define	XCHAROUT	FALSE
#define	XBCONOUT	FALSE




/*
**  local constants
*/

#define BASE 	0xF8000				/* screen base		*/
#define LINE 	720				/* line size in bytes	*/
#define BOTTOM  0xFF8F0 			/* top raster of bottom line */

#define QSIZE 	256

/*
**  keyboard COPS Commands
**	from Lisa Hardware manual figure 2-14
**	(pg 2-28 of old manual, pg 2-20 of June 3, 1983 version)
*/

/*		       PA7-PA0		function			*/

#define	CO_ONPORT	0x00	/*  turn i/o port on			*/
#define	CO_OFFPORT	0x01	/*  turn i/o port off			*/
#define	CO_RDCLOCK	0x02	/*  read clock data			*/

#define	CO_CDWRITE	0x10	/*  clock data write			*/
				/*  data should be or'd into low nibble	*/
				/*  so that 0001nnnn (binary) writes	*/
				/*  nnnn to clock			*/

#define	CO_STMODE	0x20	/*  set clock modes			*/
				/*  low nibble defined as:		*/
				/*    spmm where:			*/
				/*      s:  0=clk mode set, 1=disable	*/
				/*      p:  0=power off, 1=power on	*/
				/*      mm: 				*/
				/*        00  clock/timer disable	*/
				/*        01  timer disable		*/
				/*        10  timer underflow interrupt	*/
				/*        11  timer underflow power on	*/

#define	CO_LOWKBD	0x30	/*  write to low kbd indicator bits	*/
				/*    where data to be writtin is in	*/
				/*    low nibble (0x32) writes 0x02 to	*/
				/*    low kbd indicator bits		*/

#define	CO_HIKBD	0x40	/*  write to high kbd indicator bits	*/
				/*    where data to be writtin is in	*/
				/*    low nibble (0x47) writes 0x07 to	*/
				/*    high kbd indicator bits		*/

#define	CO_HNMI		0x50	/*  set nmi character high nibble to 	*/
				/*  data in low nibble. ex:		*/
				/*    0x53: nmi chr hi nibble := 0x03	*/

#define	CO_LNMI		0x60	/*  set nmi character low nibble to 	*/
				/*  data in low nibble. ex:		*/
				/*    0x62: nmi chr low nibble := 0x02	*/

#define	CO_NOPMASK	0x80	/*  anything with high bit set is no-op	*/


/*
**  external declarations
*/

extern char ctltbl[], capstbl[], shiftbl[], unshift[];	/* found in biosa.s */
extern char unshft1[], shift1[], scancd[], scancd1[], alt[];	/* " " "    */
extern int newdsk;

/*
**  globals
*/

char *prntr  = (char *) 0xfc6000 ;	/* printer port */
char *kybd   = (char *) 0xfcdd80 ;	/* keyboard/mouse COPS (6522 VIA ?)*/
int  *vrtoff = (int  *) 0xfce018 ; 	/* vrtoff[0] = off, vrtoff[1] = on */



int  (*ratint)();		/* Ptr to fnctn handling user defined vectors */
				/* Set in biosa.s to equal vector 200.  It is */
				/* used for moving the mouse.		      */

char ratdat[3];			/* Mouse movement info.  The indexes mean: */
				/* 0 =mouse key down, 1= x dir, 2 = y direct  */

char kbstate;			/* bit mapped to show state of control keys: 
				   if bit = 0 key is up, if = 1 key is down   
				   bit 0 is ignorred (= Right Shift Key)
				   bit 1 is Left Shift Key
				   bit 2 is Control Key
				   bit 3 is Alt Key
				   bit 4 is Caps Lock Key
				   Goal is to provide info in GDOS compatbl form
				*/
int kdown;
int lastkey;			/* last key still down:  for autorepeat */
int tcamt;			/* timer tick counter for autorepeat */
int nxttmer;			/* value of timer tick counter f next go round*/
int keyflag;			/* boolean: iff recently char add to keybd buf*/

struct Q
{	/* structure for queueing the keyboard input in a circular buffer*/
	long	data[QSIZE];	/* this is the long character val input by usr*/
	int	front;		/* pointer to the front of the circular buffer*/
	int	rear;		/* pointer to the rear of the circular buffer */
	int	qcnt;		/* number of characters in the circular buffer*/
} kq;

/***********************************/

/*
**  nq -
*/

nq(ch,qptr)	/* put a character into kq.data[] keyboard  character buffer */
struct Q *qptr;	/* the "circular" keyboard buffer data structure */
long ch;	/* the 32 bit "character" which we got f keyboard */
{
	qptr -> data[(qptr -> rear)++] = ch ;	/* remove character f buffer*/
	if ((qptr -> rear) == QSIZE) 		/* wrap-around for circ buf */
	    qptr -> rear = 0;
	qptr -> qcnt++ ;		/* one more character in the buffer */
}

/*
**  dq -
*/

long dq(qptr)	/* takes a char from the keyboard character circular buffer */
struct Q *qptr;
{
	int q2;

	qptr -> qcnt-- ;		/* one less character in the buffer */
	q2 = qptr -> front++ ;		/* remove from front of buffer */
	if ((qptr -> front) == QSIZE)	/* wrap-around for circular buffer */
	    qptr -> front = 0;
	return(qptr -> data[q2]);	/* return char at front of buffer */
}


/*
**  pget -
*/

char pget()	/* get the second+ char in a multichar keyboard input */
{
	while (! (*(kybd + 0x1b) & 2)) 		/* poll for second char */
		/*  busy wait  */ ;
	return(*(kybd+3));			/* return the next character */
}


/*
**  kbdcmd -
*/

kbdcmd(c)	/* sends a command to the keyboard COPS 		*/
char c;		/* command to COPS, see fig 2-14 on pg 2-28 of Lisa HardWare M*/
		/*  or see top of this listing  - ktb 08/11/85		*/
{
	int i;

	kybd[7] = 0xff;				/* set latch do output */

	while (! (*(kybd + 1) & 0x40)) 
		;

	do {
		*(kybd + 0x1f) = c;
	} while( *(kybd+1) & 0x40);

	/* *(kybd + 7) = 0xff ; */

	for( i = 0 ; i < 8 ; i++ )		/* delay ? */
		;
	kybd[7] = 0; 				/* back to input */
}

/*
**  modify -
*/

modify(ch)	/* Update data structure for Control key Change of state */
char ch;	/* Scan Code of a Control Key */
{
	char k;					/* boolean */

	if (ch & 0x80)				/* T iff key was downpressed */
	    k = 1;				/* key pressed down */
	else k = 0;				/* key let up */
	switch(ch & 3)				/* examn lowest ordr scan code*/
	{
		case 0: if (k)			/* left option = ALT Key    */
			    kbstate |= 0x08;	/* set bit 3 */
			else kbstate &= 0xF7;	/* clear bit 3 */
			break;
		case 1: if (k)			/* alpha lock =  CAPS LOCK  */
			    kbstate |= 0x10;	/* set bit 4 */
			else kbstate &= 0xEF;	/* clear bit 4 */
			break;
		case 2: if (k)			/* SHIFT Key 		    */
			    kbstate |= 0x02;	/* set bit 1 */
			else kbstate &= 0xFD;	/* clear bit 1 */
			break;
		case 3:	if (k)			/* command = CONTROL Key    */
			    kbstate |= 0x04;	/* set bit 2 */
			else kbstate &= 0xFB;	/* clear bit 2 */
		default: return;		/* no other valid scan codes*/
	}
}




/*
**  keyint -
*/

		/* When a keyboard interrupt occurs, the interrupt is       */
		/* vectored over to keyint in biosa.s which saves the first */
		/* three address and data registers on the stack and then   */
		/* calls this procedure here.  Thus, this procedure handles */
keyint()	/* all of the keyboard interrupt handling.  It receives a   */
{		/* scan code value and outputs the appropriate activity/val */
	char c1;
	char c;
	int downr,icnt;

	c = *(kybd + 3);		/* get current "scancode" from keybd */
	icnt = kq.qcnt;			/* # of chars in the keyboard buffer */
	c1 = c & 0x7f ;			/* mask off t direction bit of scancd*/

	if (c == 0x80) 			/* T iff next char = spec reset char */
	{
	     c = pget(); 			/* reset code, get other part */
	     if (c == 0xfb)		/*T iff user desires to soft power off*/
	         kbdcmd (0x20);		/* Turn the power off -- EWF 4/26/85 */
					/* if not soft power off then ignore */
	}
	else if (c == 0)		/* T iff have a mouse event */
	{				/* it signals that mouse data follows*/
		ratdat[1] = pget();	/* 2nd char = change in x direction  */
		ratdat[2] = pget();	/* 3rd char = change in y direction  */
		(*ratint)(IF_RPKT,ratdat); /* move mouse w vector 200h 	     */
					/*  ^--- M0001			     */
	}
	else if (c1 >= 0x7c) 		/* T iff is shift, alt, cmd-type key */
	    modify(c);  		/* modifier key */
	else
	{
		downr = c & 0x80;	/* = 1 if key pressed down, else = 0 */
		if (c1 == 6)		/* mouse button key */
		{
			ratdat[0] = (downr == 0 ? 0 : 1);
			ratdat[1] = ratdat[2] = 0;	/* no mouse movement */
			(*ratint)(IF_RPKT,ratdat);	/*  M0001	     */
		}
		if (! downr) 		/* T iff key is now up */
		{
		    if ((c1 == 0x2c) && (kbstate & 0x08))/*Alt(. in keypad)key*/
		    {				/* simulates the mouse button */
			ratdat [0] = 0;			/* key is up */
			ratdat[1] = ratdat[2] = 0;	/* no mouse movement */
			(*ratint)(IF_RPKT,ratdat);	/*  M0001	     */
		    }
		    else if (c1 == lastkey)
		    {
			kdown = 0;
		    }
		}
		else			/* key is regular kb key pushed down */
		{
		    if ((c1 == 0x2c) && (kbstate & 0x08))/*Alt(. in keypad)key*/
		    {				/* simulates the mouse button */
			ratdat [0] = 1;			/* key is down */
			ratdat[1] = ratdat[2] = 0;	/* no mouse movement */
			(*ratint)(IF_RPKT,ratdat);	/* M0001 	     */
		    }
		    else
		    {
			tcamt = 25;		/* reinitialize count number */
			nxttmer = 10;
			kdown = 1;
			lastkey = c1;	/* preserve in case of autorepeat */
			addchar (c1);	/* add char into keybd buffer */
		    }
		}			/* end of else key pressed down */
	}				/* end of else is now reg kb key */

	if (icnt < kq.qcnt) keyflag = 1;
}




/*
**  addchar -
**	this is where the character is actually added to the buffer
*/

addchar (c1)		/*  add a char to the buffer			*/
	int	c1;	/* lisa scan code of char to be added 		*/
{
	char oops;
	long key;

	key = 0L;					/* initialize */
	if (c1 >= 0x40)
	{
		key |= scancd[c1 - 0x40];     		/* get IBM scncd*/
		key <<= 16;
		if (kbstate & 0x04)			/* CONTROL key*/
			key |= ctltbl[c1 - 0x40];
		else if (kbstate & 0x02)		/* SHIFT key  */
			key |= shiftbl[c1 - 0x40];
		else if (kbstate & 0x10)		/* CAPS LOCK  */
			key |= capstbl[c1 - 0x40];
		else if (kbstate & 0x08)		/* ALT key    */
		{
			key |= alt[c1 - 0x40];
			key <<= 16;
			key &= 0x00ff0000;
		}
		else key |= unshift[c1 - 0x40];		/* unshifted */

		nq (key, &kq);
	}
	else if ((c1 >= 0x20) && (c1 < 0x30)) 
	{
		if ((kbstate & 0x04) && (c1 == 0x2f))	/* CNTRL*/
		{
		    popit(newdsk = 1);   		/* pop out floppy*/
		    return;
		}
		if (kbstate & 0x08) 			/* Alt key depressed */
		{					/* mouse simulation */
		    oops = 0;				/* boolean init to F */
		    if (c1 == 0x22)			/* left arrow */
		    {
		        if (kbstate & 0x02)		/*caps key dep*/
			   ratdat[1] = -1;
			else ratdat[1] = -10;		/* x direction*/
			ratdat [2] = 0;			/* y direction*/
			oops = 1;
		    }
		    else if (c1 == 0x23)		/* right arrow*/
		    {
		        if (kbstate & 0x02)		/*caps key dep*/
			   ratdat[1] = 1;
			else ratdat [1] = 10;		/* x direction*/
			ratdat [2] = 0;			/* y direction*/
			oops = 1;
		    }
		    else if (c1 == 0x27)		/* up arrow*/
		    {
		        if (kbstate & 0x02)		/*caps key dep*/
			   ratdat[2] = -1;
			else ratdat [2] = -10;		/* y direction*/
			ratdat [1] = 0;			/* x direction*/
			oops = 1;
		    }
		    else if (c1 == 0x2b)		/* down arrow*/
		    {
		        if (kbstate & 0x02)		/*caps key dep*/
			   ratdat[2] = 1;
			else ratdat [2] = 10;		/* y direction*/
			ratdat [1] = 0;			/* x direction*/
			oops = 1;
		    }
		    if (oops)			/*T iff simulated mouse action*/
		    {
			(*ratint) (IF_RPKT,ratdat);	/*  M0001	      */
			return;
		    }
		}				/* end of if Alt key depressed*/
		key |= scancd1[c1 - 0x20];
		key <<= 16;
		if (! kbstate)				/* not shifted at all */
		    key |= unshft1[c1-0x20];
		else key |= shift1[c1-0x20];

		nq (key, &kq);
	}				/* end of else if scan key < 0x30 */
}
			



/*
**  tmertck -
*/

tmertck ()	/* called whenever a timer tick occurs f purpose of autorepeat*/
{
	if (kdown <= 0)			/* no key is pressed down at present */
	    return;	
	if ( ! (--tcamt))		/* T iff time for autorepeat */
	{
	    tcamt = nxttmer;		/* slightly faster next time */
	    if (nxttmer > 4)		/* incrementl autorepeating adjustment*/
		nxttmer-= 2;
	    else nxttmer = 2;
	    addchar (lastkey);		/* print out the last character again*/
	    keyflag = 1;		/* something new has been added to buf*/
	}
}



/*
**  cputc -
**	output console character
**	trap 13 func 3; no return until char output
*/

long	cputc( chx )
	int	chx ;		/*  char to output			*/
{
	return( con_out( BFHCON , chx )  ) ;
}




/*
**  cntrlst -
** This is trap13, fnct B.  It alters the control status var 
*/

long	cntrlst (flg)	/*  trap 13, func 0x0b.  alter ctrl status	*/
	int	flg;	/* if -1, inquiry only; else set according to flg */
{
	long  tmp;

	tmp = 0;			/* initialize = make sure no garbage */
	tmp |= kbstate;			/* preserve the current value */
	if ( flg != -1)			/* user wants to alter current val */
	    kbstate = flg;		/* alter the current value */
	return (tmp);
}



/*
**  cinstat -
**	console input status
**	trap13, function 1: character input status
*/

long	cinstat()
{
	return( kq.qcnt ? DEVREADY : DEVNOTREADY ) ;
}






/*
**  cgetc -
**	get console character (waits until input)
**	TRAP13, func 2.
*/

long	cgetc()
{
	/* wait until get key from keyboard if none there in buffer */

	if ( ! kq.qcnt) 			/* T iff no char in the kb buf*/
	{					/* This is for polling  kb buf*/
		keyflag = 0;			/* signl no kb input yet--EWF */
		while ( ! keyflag);		/* keyflag set to T when get  */
	}					/* char from keyint ()	      */
	return( dq (&kq));
						/*ignors any other device spec*/
}






/*
**  coutstat -
**	console output status.
*/

long	coutstat()
{
	return( DEVREADY ) ;
}






/*
**  coninit -
*/

coninit()
{
	char *via,x;

	kq.front = kq.rear = kq.qcnt = 0;	/* setup keyboard buffer */
	kbstate = 0;			/* zero out all bits */
	tcamt = 25;			/* initialize timer tick amount */
	nxttmer = 10;			/* for incremental auto repeating */
	kdown = 0; 			/* system used to start w cr key down*/
	kybd[0x05] = 0x0e; 		/* ddrb (pb1-3) is speaker volume */
	kybd[0x17] = 0x01; 		/* acr (pa latch enable) */
	kybd[0x19] = 0xc9; 		/*pcr (ca2 handshake,ca1 active ^edge)*/
	kybd[0x1d] = 0x7d; 		/* enable ca1 interrupt */
	kybd[0x07] = 0x00; 		/* ddra all input */
		/* now co-routine bconout(1); */
		/* nmi key  will now equal A1 = press down - on keypad key */
	kbdcmd(0x5a);			/* set high nibble of nmi key */
	kbdcmd(0x61);			/* set low nibble of nmi key */
		/* rat ints (7f for enable, 28 ms) */
	kbdcmd(0x7f);			/* 70 for no rat ints */
	vrtoff[0] = 0; 			/* turn off the bleeding blinkers */
	esc_init();			/* found in lisaesc.s */
}





