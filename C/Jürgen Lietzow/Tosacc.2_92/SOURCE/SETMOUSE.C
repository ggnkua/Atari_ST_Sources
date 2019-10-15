/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 2/92  <<<<<<<<<<<<<		*/
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
/*		Last Update		:	16.12.91 (JL)								*/
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
static	TOOL	ourTool =	{	NULL, NULL, -1, 0, 0, 0, -1,
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
		if ( fwrite( &(sys->smSwitch), sizeof (int), 1L, fp ) != 1L ||
			 fwrite( &(sys->smKeep), sizeof (int), 1L, fp ) != 1L )
			return ( 1 );

		if ( fwrite( smField, sizeof(smField), 1L, fp ) != 1L )
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
		ptr = &(sys->xList);
	else
	{
		ptr = &(sys->yList);
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

#pragma warn .par

/*
*	SwitchObj()
*
*	Behandelt die Benutzereingaben
*/

static	void	SwitchObj( TOOL *tl, int obj )
{
	int		dummy, mstate, i;

	obj &= 0x7fff;

	switch ( obj )
	{
		case SMOFF:		sys->smSwitch = 0;		break;
		case SMON:		sys->smSwitch = 1;		break;
		case SMDIREC:	do
							graf_mkstate( &dummy, &dummy, &mstate, &dummy );
						while ( mstate );
						if ( IsSelected(&tl->wd.tree[SMDIREC]) )
							sys->smKeep = 1;
						else
							sys->smKeep = 0;
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
		if ( fread( &(sys->smSwitch), sizeof (int), 1L, fp ) == 1L &&
			 fread( &(sys->smKeep), sizeof (int), 1L, fp ) == 1L &&
			 fread( smField, sizeof(smField), 1L, fp ) == 1L )
			;
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

	stack = Super( 0L );
	*sys->OldMOUSE = base->kb_mousevec;
	base->kb_mousevec = (void (*)()) sys->NewMOUSE;
	Super( (void *) stack );

	if ( sys->smSwitch )
		Select(ObPtr(SETMOUSE,SMON));
	else
		Select(ObPtr(SETMOUSE,SMOFF));

	if ( sys->smKeep )
		Select(ObPtr(SETMOUSE,SMDIREC));

	return ( &ourTool );
}
