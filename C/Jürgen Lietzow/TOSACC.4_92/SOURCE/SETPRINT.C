/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 4/92  <<<<<<<<<<<<<		*/
/*																		*/
/*																		*/
/*		P R O J E C T	:	TOS ACCESSORY Spezial						*/
/*							TOSACC.ACC									*/
/*																		*/
/*		M O D U L E		:	SETPRINT.C									*/
/*																		*/
/*																		*/
/*		Author			:	Jrgen Lietzow fr TOS-Magazin				*/
/*																		*/
/*		System/Compiler	:	Atari ST/TT, TOS 1.4, Pure C				*/
/*																		*/
/*		Last Update		:	26.02.92 (JL)								*/
/*																		*/
/*																		*/
/************************************************************************/

#include <stdlib.h>

#include "tosglob.h"
#include "tosacc.h"


static	int		Save( TOOL *tl, FILE *fp );
static	int		HdlEvent( TOOL *tl, int evtype, EVENT *ev, int top );
static	int		Mode( TOOL *tl, int type );

static	int		printer = 0x02 + 0x04 + 0x08;
static	int		ours;
static	TOOL	ourTool =	{	NULL, NULL, 0, 0, 0, 0, 1, -1,
								-1,
								Save,
								Mode,
								HdlEvent,
							};

static	int		obList[] = {
								PRTYP, PRMATRI,
								PRCOLOR, PRMONO,
								PREPSON, PRATARI,
								PRNLQ, PRDRAFT,
								PRSER, PRCETRON,
								PRSINGL, PRUNLIM
							};

/*
*	Save()
*
*	Sichert aktuelle Einstellung
*/

#pragma warn -par

static	int		Save( TOOL *tl, FILE *fp )
{
	if ( fp )
	{
		if ( fwrite( &printer, sizeof (int), 1L, fp ) != 1L )
			return ( 1 );
	}
	return ( 0 );
}

#pragma warn .par

/*
*	HdlEvent()
*
*	wird von TOSACC.C aufgerufen
*/

#pragma warn -par

static	int		HdlEvent( TOOL *tl, int evtype, EVENT *ev, int top )
{
	FormEvent( &tl->wd, ev );
	printer = (int) SetBits( &tl->wd, obList, 6, 1 );
	Setprt( printer );
	return ( 0 );
}


/*
*	Mode()
*
*	Wird von TOSACC.C aufgerufen. Bei jedem Timer-Ereignis, bei
*	AC_CLOSE, und bei einem Toolwechsel.
*/

static	int		Mode( TOOL *tl, int type )
{
	if ( type & (MODE_TOPEN|MODE_TOPPED) )
	{
		printer = Setprt( -1 );
		return ( SetFlags( &tl->wd, obList, 6, (long) printer, 0, 1 ) );
	}
	if ( (type & (MODE_TACTIV|MODE_TIMER)) == (MODE_TACTIV|MODE_TIMER) )
	{
		printer = Setprt( -1 );
		SetFlags( &tl->wd, obList, 6, (long) printer, 1, 1 );
	}
	return ( 0 );
}

#pragma warn .par

/*
*	PrInit()
*
*	wird bei Programmstart von TOSACC.C aufgerufen
*/

TOOL	*PrInit( FILE *fp, int handle )
{
	OBJECT	*tr = TrPtr(CETRONIC);

	ours = handle;

	if ( fp )
		fread( &printer, sizeof (int), 1L, fp );

	InitEdObj( &ourTool.wd, tr, -1 );

	Setprt( printer );
	return ( &ourTool );
}
