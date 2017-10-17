/******************************************************************************
 *	Raw acia handlers 8530	Eltec 8530 dual Acia	T.Barnaby 1/6/85
 ******************************************************************************
 *
 *	This file contains all the routines to access the serial ports
 *	on the Eltec board, for use by the TTY handler.
 *
 *	o_acia()	Sets up the hardware acia to apropriate settings
 *			baud rate etc, and sets up the interupt vectors.
 *			intvect() is called to set up the interupt vector.
 *
 *	_pchar()	Prints out a character to the given minor minor
 *			device number given.
 *
 *	_gchar()	Gets a character from the acia.
 *	
 *	s_acia()	Returns the status of the acia (WRDY, RRDY)
 *
 *	i_acia()	This is the routine entered when the acia
 *			requests an interupt. It uses the ttyin(),
 *			and ttyout() routines in the tty handler.
 *			The common interupt wrapper is in excep.c
 *			The interupt handler should be set to
 *			point to here on the acia's interupt
 *			via wrapper.
 *
 *	i_txint()	Renable tx-interupt when characters are available
 *			Normaly i_acia() will turn off tx interrupt when
 *			no more characters are to be output.
 *
 *	External routines used:-
 *
 *		ttyin()		TTY handler char input
 *		ttyout()	TTY handler char out
 */

# include <sgtty.h>
# include "tty.h"
# include "acia.h"
# include "../../include/excep.h"

int i_acia();
extern int intacia();
extern struct ttystruct ttys[];

/* Base address of ACIA */
struct Acia *acia = (struct Acia *)0x0FF000;

char	intmask;	/* Saved interupt mask */

/* Baud rate values */
short aciabaud[] = {
	0, 0, 0, 1, 2, 3, 3, 4,
	5, 6, 0xA, 8, 9, 0xB, 0xC, 0xD
};

int	fttyop;		/* First tty open */

/*
 *	O_acia		Sets up a complete acia to std settings
 *			intvect() is called to set up the interupt vector.
 */
o_acia(mmdev)
int mmdev;
{
	char	speed;

	/* Finds correct speed data from acia table */
	speed = aciabaud[ttys[mmdev].sgtty.sg_ospeed];
	speed |= (aciabaud[ttys[mmdev].sgtty.sg_ispeed] << 4);

	/* Sets baud rate */
	if(mmdev == ACIA_A){
		acia->statusa = speed;
	}
	else{
		acia->statusb = speed;
	}
	if(!fttyop){
		fttyop = 1;
		/* Enables interupts etc */
		acia->counterh = COUNT20MS / 256;
		acia->counterl = COUNT20MS;
		acia->intvec = ACIA_VECT;
		acia->acr = ACR;
		acia->intmask = intmask = INTMASK;
		startcount();
	}
	return 0;
}

/*
 * _pchar - fundamental print-a-char routine for 68681 
 *		Polled or interupt driven access
 */
char
_pchar(mmdev, ch)
char mmdev;
char ch;
{
	if(mmdev == ACIA_A){
		acia->dataa = ch;
		acia->intmask = (intmask |= TXAINT);	/* Renable interupts */
	}
	else {
		acia->datab = ch;
		acia->intmask = (intmask |= TXBINT);	/* Renable interupts */
	}
	return;
}

/*
 * _gchar - fundamental get-char routine for 68681
 *		Polled or interupt driven access
 */
char
_gchar(mmdev)
char mmdev;
{
	if(mmdev == ACIA_A) return (acia->dataa & 0xFF);
	else return (acia->datab & 0xFF);
}

/*
 *	S_acia		Returns the status of the acia
 */
char
s_acia(mmdev)
char mmdev;
{
	char tstatus;

	tstatus = 0;
	if(mmdev == ACIA_A){
		if(acia->statusa & TXRDY) tstatus |= WRDY;
		if(acia->statusa & RXRDY) tstatus |= RRDY;
	}
	else{
		if(acia->statusb & TXRDY) tstatus |= WRDY;
		if(acia->statusb & RXRDY) tstatus |= RRDY;
	}
	return tstatus;
}

/*
 *	I_acia		Interupt from mmdevice
 *			Finds out the interupt type and calls the
 *			appropriate TTY handler routines ( ttyin(), ttyout() )
 */
i_acia(){

	char tstatus;

	/* Switch on interupt type */
	tstatus = acia->intmask;

	if(tstatus & RXAINT){
		/* Puts character into input buffer */
		ttyin(ACIA_A);
	}

	if(tstatus & TXAINT){
		/* Outputs a character if no more stops tx interupt */
		if(!ttyout(ACIA_A)) acia->intmask = (intmask &= ~TXAINT);
	}

	if(tstatus & RXBINT){
		/* Puts character into input buffer */
		ttyin(ACIA_B);
	}

	if(tstatus &  TXBINT){
		/* Outputs a character if no more stops tx interupt */
		if(!ttyout(ACIA_B)) acia->intmask = (intmask &= ~TXBINT);
	}

	if(tstatus & TIMINT){
		/* Does system time keeping bit */
		stopcount();	/* Restarts counter */
		tick();
	}

	/* Renable interupts */
	return;
}

/*
 *	i_txint()	Set tx interupts on for given device
 */
i_txint(dev)
int	dev;
{
	if(dev == ACIA_A) acia->intmask = (intmask |= TXAINT);
	else acia->intmask = (intmask |= TXBINT);
}

startcount(){
	register int a;

	a = acia->outport;
}
stopcount(){
	register int a;

	a = acia->stopc;
}
