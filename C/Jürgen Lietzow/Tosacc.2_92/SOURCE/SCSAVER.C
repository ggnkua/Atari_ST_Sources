/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 2/92  <<<<<<<<<<<<<		*/
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
/*		Last Update		:	16.12.91 (JL)								*/
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
static	TOOL	ourTool =	{	NULL, NULL, 0, 0, 0, 0, -1,
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

#pragma warn .par

/*
*	SwitchObj()
*
*	Behandelt die Benutzereingaben
*/


static	int		SwitchObj( TOOL *tl, int obj )
{
	int		d;
	int		m;

	switch ( obj & 0x7fff )
	{
		case SCOFF:		sys->scSwitch = 0;	break;
		case SCON:		sys->scSwitch = 1;	break;
		case SCINVERT:	Supexec( (long(*)(void)) sys->InvertScreen );
						do
							graf_mkstate( &d, &d, &m, &d );
						while( m );
						break;
		default:
			HdlSlider( &tl->wd, &sl, obj );
			break;
	}
	return ( 0 );
}

#pragma warn -par

/*
*	HdlEvent()
*
*	wird von TOSACC.C aufgerufen
*/

static	int		HdlEvent( TOOL *tl, int evtype, EVENT *ev, int top )
{
	int		obj;

	if ( evtype & MU_KEYBD )
	{
		obj = DialKeybd( &tl->wd, ev->ev_mkreturn,
						 ev->ev_mmokstate );
		SwitchObj( tl, obj );
	}
	if ( evtype & MU_BUTTON )
	{
		obj = DialButton( &tl->wd, ev->ev_mmox, ev->ev_mmoy,
						  ev->ev_mbreturn );
		SwitchObj( tl, obj );
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
