/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 1/92  <<<<<<<<<<<<<		*/
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
/*																		*/
/*		System/Compiler	:	Atari ST/TT, TOS 1.4, Pure C				*/
/*																		*/
/*		Last Update		:	21.11.91 (JL)								*/
/*																		*/
/*																		*/
/************************************************************************/

#include <tos.h>
#include <stdlib.h>

#include "tosglob.h"
#include "tosacc.h"

extern	void	NewMOUSE();

extern	char	xList[];
extern	char	yList[];

		void	(*OldMOUSE)();
		int		smSwitch = 1;
		int		smKeep = 0;
		
static	int		Save( TOOL *tl, FILE *fp );
static	int		HdlEvent( TOOL *tl, int evtype, EVENT *ev, int top );

static	int		smField[12] = { 5, 12, 25, 40, 50, 60, 
								6, 16, 28, 44, 55, 65  };

static	SLIDERBLK sl = { SMSLIDER, 1, 99, 1, -1 };
static	int		ours;
static	TOOL	ourTool =	{	NULL, NULL, -1, 0, 0, 0,
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
		if ( fwrite( &smSwitch, sizeof (int), 1L, fp ) != 1L ||
			 fwrite( &smKeep, sizeof (int), 1L, fp ) != 1L )
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
		ptr = xList;
	else
	{
		ptr = yList;
		num -= 6;
	}
		
	ptr[num+1] = val;
	ptr[-(num+1)] = -val;
}

/*
*	SwitchObj()
*
*	Behandelt die Benutzereingaben
*/

static	void	SwitchObj( TOOL *tl, int obj, int window )
{
	int		field;
	int		dummy, mstate;

	obj &= 0x7fff;
	
	switch ( obj )
	{
		case SMOFF:		smSwitch = 0;		break;
		case SMON:		smSwitch = 1;		break;
		case SMDIREC:	do
							graf_mkstate( &dummy, &dummy, &mstate, &dummy );
						while ( mstate );
						if ( IsSelected(&tl->wd.tree[SMDIREC]) )
							smKeep = 1;
						else
							smKeep = 0;
						break;
		default:
			field = obj - SMSLIDER;
			if ( field > 0 && field <= SL_DOWN )
			{
				if ( HdlSlider( tl->wd.tree, &sl, obj ) )
				{
					SliderToEdText( &tl->wd, tl->wd.edobj, sl.pos, window );
					RedrawWinObj( &tl->wd, sl.slider + SL_BOX, window );
					ChgEntry( tl->wd.edobj - ( SMFIELD + 1 ), sl.pos );
				}
				break;
			}
			field = obj - SMFIELD - 1;
			if ( field >= 0 && field < 12 )
			{
				sl.pos = -1;
				EdTextToSlider( &tl->wd, obj, &sl, window );
				SliderToEdText( &tl->wd, obj, sl.pos, window );
				ChgEntry( obj - ( SMFIELD + 1 ), sl.pos );
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
	int		temp;
	
	if ( evtype & MU_KEYBD )
	{
		switch ( ev->ev_mkreturn )
		{
			case PLUS:
			case ZPLUS:	SwitchObj( tl, sl.slider + SL_DOWN, winHdl );
						break;
			case MINUS:
			case ZMINUS:SwitchObj( tl, sl.slider + SL_UP, winHdl );
						break;	
			case RETURN:
			case ENTER: SwitchObj( tl, tl->wd.edobj, winHdl );
						break;
			default :
				temp = tl->wd.edobj;
				obj = DialKeybd( &tl->wd, ev->ev_mkreturn,
								 ev->ev_mmokstate, winHdl );
				if ( temp != tl->wd.edobj )
				{
					sl.pos = -1;
					EdTextToSlider( &tl->wd, temp, &sl, winHdl );
					SliderToEdText( &tl->wd, temp, sl.pos, winHdl );
					ChgEntry( temp - ( SMFIELD + 1 ), sl.pos );
					SwitchObj( tl, tl->wd.edobj, winHdl );
					break;
				}
				if ( !obj )
					break;
				SwitchObj( tl, obj, winHdl );
				break;
		}
	}					
	if ( evtype & MU_BUTTON )
	{
		temp = tl->wd.edobj;
		obj = DialButton( &tl->wd, ev->ev_mmox, ev->ev_mmoy,
						  ev->ev_mbreturn, winHdl );
		if ( temp != tl->wd.edobj )
		{
			sl.pos = -1;
			EdTextToSlider( &tl->wd, temp, &sl, winHdl );
			SliderToEdText( &tl->wd, temp, sl.pos, winHdl );
			ChgEntry( temp - ( SMFIELD + 1 ), sl.pos );
			SwitchObj( tl, tl->wd.edobj, winHdl );
			return ( 0 );
		}
		if ( !obj )
			return( 0 );
		SwitchObj( tl, obj, winHdl );
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

	ours = handle;

	if ( fp )
	{
		if ( fread( &smSwitch, sizeof (int), 1L, fp ) == 1L &&
			 fread( &smKeep, sizeof (int), 1L, fp ) == 1L &&
			 fread( smField, sizeof(smField), 1L, fp ) == 1L )
			;
	}
	for ( i = 0; i < 12; i++ )
	{
		ChgEntry( i, smField[i] );
		itoa( smField[i],
			 TrPtr(SETMOUSE)[i+SMFIELD+1].ob_spec.tedinfo->te_ptext, 10 );
	}

	InitEdObj( &ourTool.wd, TrPtr(SETMOUSE), SMFIELD + 1 );
	PosSlider( ourTool.wd.tree, &sl, smField[0] );
	
	stack = Super( 0L );
	OldMOUSE = base->kb_mousevec;
	base->kb_mousevec = NewMOUSE;
	Super( (void *) stack );		
	
	if ( smSwitch )
		Select(ObPtr(SETMOUSE,SMON));
	else
		Select(ObPtr(SETMOUSE,SMOFF));

	if ( smKeep )
		Select(ObPtr(SETMOUSE,SMDIREC));

	return ( &ourTool );
}	
