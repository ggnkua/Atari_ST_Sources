/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 3/92  <<<<<<<<<<<<<		*/
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
/*		Last Update		:	31.01.92 (JL)								*/
/*																		*/
/*																		*/
/************************************************************************/

#include <stdlib.h>

#include "tosglob.h"
#include "tosacc.h"


static	int		Save( TOOL *tl, FILE *fp );
static	int		HdlEvent( TOOL *tl, int evtype, EVENT *ev, int top );
static	int		HandleSlider( OBJECT *tree, SLIDERBLK *sl );

static	SLIDERBLK sl = { SCSLIDER, 192, HandleSlider, 5, 5, -1 };

static	int		ours;
static	TOOL	ourTool =	{	NULL, NULL, 0, 0, 0, 0, 1, -1,
								-1,
								Save,
								NULL,
								HdlEvent,
							};


#pragma warn -par

/*
*	Save()
*
*	Sichert aktuelle Einstellung
*/

static	int		Save( TOOL *tl, FILE *fp )
{
	if ( fp )
	{
		if ( fwrite( &(sys->scSwitch), sizeof (int), 1L, fp ) == 1L )
			if ( fwrite( &(sys->scTime), sizeof (int), 1L, fp ) == 1L )
				return ( 0 );
		return ( 1 );
	}
	return ( 0 );
}

static	int		HandleSlider( OBJECT *tree, SLIDERBLK *sl )
{
	sys->scTime = SlAbsToRel( sl, sl->pos );
	SlDigit( tree, sl, sys->scTime );
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
		case SCOFF:		sys->scSwitch = 0;	break;
		case SCON:		sys->scSwitch = 1;	break;
		case SCINVERT:	Supexec( (long(*)(void)) sys->InvertScreen );
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

#pragma warn .par

TOOL	*ScInit( FILE *fp, int handle )
{
	OBJECT	*tr = TrPtr(SCSAVER);

	ours = handle;

	if ( fp )
	{
		fread( &(sys->scSwitch), sizeof (int), 1L, fp );
		fread( &(sys->scTime), sizeof (int), 1L, fp );
	}

	InitEdObj( &ourTool.wd, TrPtr(SCSAVER), -1 );
	SlInit( tr, &sl, sys->scTime );
	sys->scTime = SlAbsToRel( &sl, sl.pos );
	SlDigit( tr, &sl, sys->scTime );

	if ( !sys->scSwitch )
		Select(ObPtr(SCSAVER,SCOFF));
	else
		Select(ObPtr(SCSAVER,SCON));

	return ( &ourTool );
}
