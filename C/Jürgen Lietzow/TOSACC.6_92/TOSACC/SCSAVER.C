/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 6/92  <<<<<<<<<<<<<		*/
/*																		*/
/*																		*/
/*		P R O J E C T	:	TOS ACCESSORY Spezial						*/
/*							TOSACC.ACC									*/
/*																		*/
/*		M O D U L E		:	SCSAVER.C									*/
/*																		*/
/*																		*/
/*		Author			:	Jrgen Lietzow fr TOS-Magazin				*/
/*																		*/
/*		System/Compiler	:	Atari ST/TT, TOS 1.4, Pure C				*/
/*																		*/
/*		Last Update		:	27.02.92 (JL)								*/
/*																		*/
/*																		*/
/************************************************************************/

#include <stdlib.h>

#include "tosglob.h"
#include "tosacc.h"


static	int		HdlEvent( TOOL *tl, int evtype, EVENT *ev, int top );
static	int		HandleSlider( OBJECT *tree, SLIDERBLK *sl );

static	SLIDERBLK sl = { SCSLIDER, 192, HandleSlider, 5, 5, -1 };

static	int		ours;
static	TOOL	ourTool =	{	NULL, NULL, 0, 0, 0, 0, 1, -1,
								-1,
								NULL,
								NULL,
								HdlEvent,
								NULL
							};


#pragma warn -par

static	int		HandleSlider( OBJECT *tree, SLIDERBLK *sl )
{
	sys->tai.scTime = SlAbsToRel( sl, sl->pos );
	SlDigit( tree, sl, sys->tai.scTime );
	return ( 0 );
}

/*
*	HdlEvent()
*
*	wird von TOSACC.C aufgerufen
*/

static	int		HdlEvent( TOOL *tl, int evtype, EVENT *ev, int top )
{
	int		obj = FormEvent( &tl->wd, ev );
	
	switch ( obj & 0x7fff )
	{
		case SCOFF:		sys->tai.scSwitch = 0;	break;
		case SCON:		sys->tai.scSwitch = 1;	break;
		case SCINVERT:	Supexec( (long(*)(void)) sys->_InvertScreen );
						break;
		default:
			HdlSlider( &tl->wd, &sl, obj );
			break;
	}
	return ( 0 );
}

/*
*	ScInit()
*
*	wird bei Programmstart von TOSACC.C aufgerufen
*/


TOOL	*ScInit( FILE *fp, int handle )
{
	OBJECT	*tr = TrPtr(SCSAVER);

	ours = handle;

	InitEdObj( &ourTool.wd, TrPtr(SCSAVER), -1 );
	SlInit( tr, &sl, sys->tai.scTime );
	sys->tai.scTime = SlAbsToRel( &sl, sl.pos );
	SlDigit( tr, &sl, sys->tai.scTime );

	if ( !sys->tai.scSwitch )
		Select(ObPtr(SCSAVER,SCOFF));
	else
		Select(ObPtr(SCSAVER,SCON));

	return ( &ourTool );
}

#pragma warn .par
