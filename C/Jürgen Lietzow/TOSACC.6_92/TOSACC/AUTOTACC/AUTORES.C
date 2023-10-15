/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 6/92  <<<<<<<<<<<<<		*/
/*																		*/
/*																		*/
/*		P R O J E C T	:	TOS ACCESSORY Spezial						*/
/*							AUTOTACC.PRG								*/
/*																		*/
/*		M O D U L E		:	AUTORES.C									*/
/*																		*/
/*																		*/
/*		Author			:	JÅrgen Lietzow fÅr TOS-Magazin				*/
/*																		*/
/*		System/Compiler	:	Atari ST/TT, TOS 1.4, Pure C				*/
/*																		*/
/*		Last Update		:	27.04.92 (JL)								*/
/*																		*/
/*																		*/
/************************************************************************/

#include <tos.h>
#include <stdarg.h>

#include "..\transfer.h"

#if !defined (NULL)

#define	NULL	((void *) 0L)

#endif


extern	SYS		sys;

extern	void	XBconout0( long c );		/* wichtig (long) */
extern	int		XBcostat0( void );


/*	Residente Funktionen zur Verwaltung des Drucker-Spoolers */

/*
*	ResetSpooler()
*
*	Gibt die RAM-Disk fÅr Schreibzugriffe wieder frei
*/

void	ResetSpooler( void )
{
	long	*ptr = (long *)sys.spOutBlk;
	long	*p;
	
	sys.subprFlag++;
	
	sys.spNChars = 0;
	sys.spInPos = sys.spOutPos = 4;
	
	p = (long *) *ptr;
	while ( p )
	{
		ptr = (long *) *p;
		
		sys.blkFreeNum++;
		*p = (long) sys.blkFrees;
		sys.blkFrees = (void *) p;
		p = ptr;
		sys.spBlkNum--;
	}
	sys.subprFlag--;
	sys.spTChars = 0L;
}

