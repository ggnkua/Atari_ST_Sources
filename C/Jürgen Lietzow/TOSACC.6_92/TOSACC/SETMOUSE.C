/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 6/92  <<<<<<<<<<<<<		*/
/*																		*/
/*																		*/
/*		P R O J E C T	:	TOS ACCESSORY Spezial						*/
/*							TOSACC.ACC									*/
/*																		*/
/*		M O D U L E		:	SETMOUSE.C									*/
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
#include <stdlib.h>

#include "tosglob.h"
#include "tosacc.h"

static	int		Save( TOOL *tl, FILE *fp );
static	int		HdlEvent( TOOL *tl, int evtype, EVENT *ev, int top );
static	int		HandleSlider( OBJECT *tree, SLIDERBLK *sl );

static	int		smField[12] = { 5, 12, 25, 40, 50, 60,
								6, 16, 28, 44, 55, 65  };

static	SLIDERBLK sl[12];
static	int		ours;
static	TOOL	ourTool =	{	NULL, NULL, -1, 0, 0, 0, 1, -1,
								-1,
								Save,
								NULL,
								HdlEvent,
								NULL
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
		if ( fwrite( smField, sizeof(smField), 1L, fp ) == 1L )
			return ( 0 );
		return ( 1 );
	}
	return ( 0 );
}

#pragma warn .par

/*
*	ChgEntry()
*
*	Setzt die neuen Parameter fÅr die Interruptroutine
*/

static	void	ChgEntry( int num, int val )
{
	char	*ptr;

	smField[num] = val;

	if ( num < 6 )
		ptr = &(sys->tai.xList);
	else
	{
		ptr = &(sys->tai.yList);
		num -= 6;
	}

	ptr[num+1] = val;
	ptr[-(num+1)] = -val;
}

#pragma warn -par

/*
*	HandleSlider()
*
*	wird von 'HdlSlider()' aufgerufen, wenn der Slider einen neuen
*	Wert eingenommen hat
*/

static	int		HandleSlider( OBJECT *tree, SLIDERBLK *sl )
{
	int		num = ( sl->slider - SMSLIDER - 1 ) / 5;
	int		pos = SlAbsToRel( sl, sl->pos );

	if ( num & 1 )
		num = num / 2 + 6;
	else
		num /= 2;

	ChgEntry( num, pos );
	SlDigit( tree, sl, pos );
	return ( 0 );
}

/*
*	HdlEvent()
*
*	wird von TOSACC.C aufgerufen
*/

static	int		HdlEvent( TOOL *tl, int evtype, EVENT *ev, int top )
{
	int		i;
	int		obj = FormEvent( &tl->wd, ev ) & 0x7fff;

	switch ( obj )
	{
		case SMOFF:		sys->tai.smSwitch = 0;		break;
		case SMON:		sys->tai.smSwitch = 1;		break;
		case SMDIREC:	if ( IsSelected(&tl->wd.tree[SMDIREC]) )
							sys->tai.smKeep = 1;
						else
							sys->tai.smKeep = 0;
						break;
		default:
			for ( i = 0; i < 12; i++ )
				if ( obj >= sl[i].slider && obj < sl[i].slider + 5 )
				{
					HdlSlider( &tl->wd, &sl[i], obj );
					break;
				}
			break;
	}
	return ( 0 );
}

#pragma warn .par

/*
*	MsInit()
*
*	wird bei Programmstart von TOSACC.C aufgerufen
*/

TOOL	*MsInit( FILE *fp, int handle )
{
	int			i;
	KBDVBASE	*base = Kbdvbase();
	long		stack;
	OBJECT		*tr = TrPtr(SETMOUSE);

	ours = handle;

	if ( fp )
	{
		 fread( smField, sizeof(smField), 1L, fp );
	}

	for ( i = 0; i < 12; i++ )
	{
		if ( i < 6 )
		{
			sl[i].slider = SMSLIDER + 1 + i * 10;
			sl[i].num = (i+1) * 16;
		}
		else
		{
			sl[i].slider = SMSLIDER + 6 + (i-6) * 10;
			sl[i].num = (i-5) * 16;
		}
		sl[i].sl_handle = HandleSlider;
		sl[i].min = 1;
		sl[i].step = 1;
		sl[i].pos = smField[i] - 1;
		SlInit( tr, &sl[i], smField[i] - 1 );
		SlDigit( tr, &sl[i], SlAbsToRel( &sl[i], sl[i].pos ) );
	}
	InitEdObj( &ourTool.wd, tr, -1 );

	if ( !sys->confActiv )
	{
		stack = Super( 0L );
		*sys->_OldMOUSE = base->kb_mousevec;
		base->kb_mousevec = (void (*)()) sys->_NewMOUSE;
		Super( (void *) stack );
	}

	if ( sys->tai.smSwitch )
		Select(tr+SMON);
	else
		Select(tr+SMOFF);

	if ( sys->tai.smKeep )
		Select(tr+SMDIREC);

	return ( &ourTool );
}
