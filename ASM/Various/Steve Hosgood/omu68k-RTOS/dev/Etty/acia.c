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
 *	External routines used:-
 *
 *		ttyin()		TTY handler char input
 *		ttyout()	TTY handler char out
 */

# include <sgtty.h>
#ifdef	VIWINDOWS
# include	<sys/viinfo.h>
# include	<sys/touch.h>
#endif
# include "tty.h"
# include "acia.h"
# include "../../include/excep.h"

int i_acia();
extern int intacia();
extern struct ttystruct ttys[];

/* addresses of ACIA bases */
struct acia *bases[NDEVS] = {
	(struct acia *)0xFA0035,
	(struct acia *)0xFA0031
};

/* Standard acia settings Tx and RX interupts enabled, master
 *	interupt enable off, 8 bits no parity, 1 stop bit, 9600 baud */

char aciatab[] = {
	0x00, 0x12, 0x00, 0xE1, 0x44, 0xEA, 0x00, 0x00,
	0x00, 0x04, 0x00, 0x52, 0x0E, 0x00, 0x01, 0x00
};

/* Baud rate time constant values */
short aciabaud[] = {
	0, 3166, 2100, 1438, 1175, 1054, 790, 526,
	262, 130, 82, 62, 31, 14, 6, 6
};

/*
 *	O_acia		Sets up a complete acia to std settings
 *			intvect() is called to set up the interupt vector.
 */
o_acia(mmdev)
int mmdev;
{
	int address;

	/* Sets master interupt off */
	setreg(mmdev,9,0x0);

	/* Sets up all registers */
	for(address = 0; address < 16; address++)
		setreg(mmdev,address,aciatab[address]);

	/* Set up baud rate to setting in sgtty */
	setreg(mmdev,BAUDH,(aciabaud[ttys[mmdev].sgtty.sg_ospeed] >>8));
	setreg(mmdev,BAUDL,(aciabaud[ttys[mmdev].sgtty.sg_ospeed] &0xFF));

	/* Sets up vector pointer (2 is register number for vector) */
	setreg(mmdev,2,TACIA);

	/* Sets Tx and Rx interupt re-enables on */
	setreg(mmdev,COMMAND,REN_TXINT);
	setreg(mmdev,COMMAND,REN_RXINT);

	/* Sets master interupt enable on */
	setreg(mmdev,9,0x0C);
}

/*
 *	setreg		Sets a register in the acia of your choice to
 *			the data of your choice ( What an incredably
 *			useful routine! ).
 */
setreg(mmdev,address,data)
char mmdev,address,data;
{
/*	bases[mmdev]->status;	*/		/* Dummy read to syncronise */
	bases[mmdev]->status = address;		/* Sets address */
	bases[mmdev]->status = data;		/* Sets data */
}
/*
 *	readreg		Reads a register in the acia of your choice to
 *			the data of your choice ( What an incredably
 *			useful routine! ).
 */
readreg(mmdev,address)
char mmdev,address;
{
/*	bases[mmdev]->status;	*/		/* Dummy read to syncronise */
	bases[mmdev]->status = address;		/* Sets address */
	return bases[mmdev]->status;		/* Gets data */
}
/*
 * _pchar - fundamental print-a-char routine for 8530 (Eltec board).
 *		Polled or interupt driven access
 */
char
_pchar(mmdev, ch)
char mmdev;
char ch;
{
	bases[mmdev]->data = ch;
	return;
}

/*
 * _gchar - fundamental get-char routine for 8530 (Eltec board).
 *		Polled or interupt driven access
 */
char
_gchar(mmdev)
char mmdev;
{
	return bases[mmdev]->data;
}

/*
 *	S_acia		Returns the status of the acia
 */
char
s_acia(mmdev)
char mmdev;
{
	struct acia *acia;
	char tstatus;

	tstatus = 0;
	acia = bases[mmdev];
	if(acia->status & TXRDY) tstatus |= WRDY;
	if(acia->status & RXRDY) tstatus |= RRDY;
	return tstatus;
}

/*
 *	I_acia		Interupt from mmdevice
 *			Finds out the interupt type and calls the
 *			appropriate TTY handler routines ( ttyin(), ttyout() )
 */
i_acia(){

	char tstatus;
	char ch;

	/* Switch on interupt type */
	tstatus = readreg(ACIA_A,INTPENDING);
	do{
	if(tstatus & A_RXINT){
		/* Puts character into input buffer */
		ttyin(ACIA_A);
	}

	if(tstatus & A_TXINT){
		setreg(ACIA_A,COMMAND,REN_TXINT);	/* Resets TX interupt */
		ttyout(ACIA_A);				/* Outputs a character*/
	}

	if(tstatus & B_RXINT){
		/* Puts character into input buffer */
		ttyin(ACIA_B);				/* Gets a character */
	}

	if(tstatus &  B_TXINT){
		setreg(ACIA_B,COMMAND,REN_TXINT);	/* Resets TX interupt */
		ttyout(ACIA_B);				/* Outputs a character*/
	}
	if(tstatus & A_STATUSINT){
		setreg(ACIA_A,COMMAND,REN_ERROR);	/* Resets error bits */
	}
	if(tstatus & B_STATUSINT){
		setreg(ACIA_B,COMMAND,REN_ERROR);	/* Resets error bits */
	}

	}while(0);

	/* Renable interupts */
	setreg(ACIA_A,COMMAND,REN_INT);
}
/*
 *	I_txint()	Renable TX interupts (Not requied on Eltec)
 */
i_txint(){
}
