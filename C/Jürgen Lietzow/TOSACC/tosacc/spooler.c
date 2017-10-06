/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 6/92  <<<<<<<<<<<<<		*/
/*																		*/
/*																		*/
/*		P R O J E C T	:	TOS ACCESSORY Spezial						*/
/*							TOSACC.ACC									*/
/*																		*/
/*		M O D U L E		:	SPOOLER.C									*/
/*																		*/
/*																		*/
/*		Author			:	Jrgen Lietzow fr TOS-Magazin				*/
/*																		*/
/*		System/Compiler	:	Atari ST/TT, TOS 1.4, Pure C				*/
/*																		*/
/*		Last Update		:	27.04.92 (JL)								*/
/*																		*/
/*																		*/
/************************************************************************/

#include <stdlib.h>
#include <string.h>

#include "tosglob.h"
#include "tosacc.h"

static	int		Save( TOOL *tl, FILE *fp );
static	int		HdlEvent( TOOL *tl, int evtype, EVENT *ev, int top );
static	int		HandleSlider( OBJECT *tree, SLIDERBLK *sl );
static	int		Mode( TOOL *tl, int type );


static	SLIDERBLK rateSl = { SPRATE, 15, HandleSlider, 1, 1, -1 };

static	int		ours;
static	TOOL	ourTool =	{	NULL, NULL, 0, 0, 0, 0, 1, -1,
								-1,
								NULL,
								Mode,
								HdlEvent,
								NULL
							};

/*
*	HandleSlider()
*
*	wird von 'HdlSlider()' aufgerufen, wenn der Slider einen neuen
*	Wert eingenommen hat
*/

static	int		HandleSlider( OBJECT *tr, SLIDERBLK *sl )
{
	switch( sl->slider )
	{
		case SPRATE:	sys->tai.spRate = SlAbsToRel( sl, sl->pos );
						SlDigit( tr, sl, ( (int) sys->tai.spRate * 100 ) / 20 );
						break;
		default		 :	break;
	}
	return ( 0 );
}

/*
*	HdlEvent()
*
*	wird von TOSACC.C aufgerufen
*/

#pragma warn -par

static	int		HdlEvent( TOOL *tl, int evtype, EVENT *ev, int top )
{
	OBJECT	*tr = TrPtr(SPOOLER);
	int		obj = FormEvent( &tl->wd, ev );
	GRECT	gr;
		
	switch ( obj & 0x7FFF )
	{
		case SPON:		sys->tai.spOn = 1;		break;
		case SPOFF:		sys->tai.spOn = 0;		break;
		case SPQUICK:	sys->tai.spQuick ^= 1;	break;
		case SPRESET:	sys->_ResetSpooler();
						Deselect(tr+SPRESET);
						sprintf ( ObTxt(tr+SPCHARS), "%ld", sys->spNChars );
						RedrawWinObj( &tl->wd, SPCHARS, NULL );
						AbsObj( tr, obj, &gr );
						RedrawWinObj( &tl->wd, 0, &gr );
						break;
		default:
				if ( ObjInSl(obj, SPRATE) )
					HdlSlider( &tl->wd, &rateSl, obj );
				break;
	}
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
	static	long 	num = -1L;
			OBJECT	*tr;

	if ( sys->spNChars == num )
		return ( 0 );
	
	tr = TrPtr(SPOOLER);
	num = sys->spNChars;

	if ( type & MODE_TOPEN )
	{
		sprintf ( ObTxt(tr+SPCHARS), "%ld", sys->spNChars );
	}
	if ( type & MODE_TIMER )
		if ( ( type & MODE_TACTIV ) && mainWD.window >= 0 )
		{
			sprintf ( ObTxt(tr+SPCHARS), "%ld", sys->spNChars );
			RedrawWinObj( &tl->wd, SPCHARS, NULL );
		}
	return ( 0 );
}

/*
*	SpInit()
*
*	wird bei Programmstart von TOSACC.C aufgerufen
*/

TOOL	*SpInit( FILE *fp, int handle )
{
	OBJECT	*tr = TrPtr(SPOOLER);
	
	ours = handle;

	sprintf( ObTxt(tr+SPCHARS), "%ld", sys->spNChars );

	InitEdObj( &ourTool.wd, tr, -1 );

	if ( sys->tai.spOn )
		Select(tr+SPON); 
	else
		Select(tr+SPOFF); 

	if ( sys->OSVers < 0x0102 )
	{
		sys->tai.spQuick = 1;	
		Disable(tr+SPQUICK);
	}
	if ( sys->tai.spQuick )
		Select(tr+SPQUICK);
		
	SlInit( tr, &rateSl, (int) sys->tai.spRate );
	SlDigit( tr, &rateSl, ( (int) sys->tai.spRate * 100 ) / 20 );

	return ( &ourTool );
}

#pragma warn .par
