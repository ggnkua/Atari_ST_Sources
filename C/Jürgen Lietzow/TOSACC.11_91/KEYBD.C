/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 1/92  <<<<<<<<<<<<<		*/
/*																		*/
/*																		*/
/*		P R O J E C T	:	TOS ACCESSORY Spezial						*/
/*							TOSACC.ACC									*/
/*																		*/
/*		M O D U L E		:	KEYBD.C										*/
/*																		*/
/*																		*/
/*		Author			:	Jrgen Lietzow fr TOS-Magazin				*/
/*																		*/
/*																		*/
/*		System/Compiler	:	Atari ST/TT, TOS 1.4, Pure C				*/
/*																		*/
/*		Last Update		:	21.11.91 (JL)								*/
/*																		*/
/*																		*/
/************************************************************************/

#include <stdlib.h>

#include "tosglob.h"
#include "tosacc.h"


static	int		Save( TOOL *tl, FILE *fp );
static	int		HdlEvent( TOOL *tl, int evtype, EVENT *ev, int top );

static	SLIDERBLK kbSl = { KBSLIDER, 0, 50, 1, -1 };
static	SLIDERBLK rpSl = { RPSLIDER, 0, 50, 1, -1 };

static	int		kbTime = 15;		/* Default Werte */
static	int		rpTime = 2;

static	int		ours;
static	TOOL	ourTool =	{	NULL, NULL, 0, 0, 0, 0,
								-1,
								Save,
								NULL,
								HdlEvent,
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
		if ( fwrite( &rpTime, sizeof (int), 1L, fp ) == 1L )
			if ( fwrite( &kbTime, sizeof (int), 1L, fp ) == 1L )
				return ( 0 );
		return ( 1 );
	}
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
	obj &= 0x7fff;
	
	switch ( obj )
	{
		case KBTIME :	if ( obj != tl->wd.edobj )
							ChangeEdField( &tl->wd, obj, winHdl );
						EdTextToSlider( &tl->wd, obj, &kbSl, winHdl );
						kbTime = kbSl.pos;
						SliderToEdText( &tl->wd, KBTIME, kbSl.pos, winHdl );
						break;
		case RPTIME :	if ( obj != tl->wd.edobj )
							ChangeEdField( &tl->wd, obj, winHdl );
						EdTextToSlider( &tl->wd, RPTIME, &rpSl, winHdl );
						kbTime = rpSl.pos;
						SliderToEdText( &tl->wd, RPTIME, rpSl.pos, winHdl );
						break;
		default :
			if ( obj > KBSLIDER && obj <= KBSLIDER + SL_DOWN )
			{
				if ( HdlSlider( tl->wd.tree, &kbSl, obj ) )
				{
					SliderToEdText( &tl->wd, KBTIME, kbSl.pos, winHdl );
					RedrawWinObj( &tl->wd, kbSl.slider + SL_BOX, winHdl );
					kbTime = kbSl.pos;
				}
			}
			else if ( obj > RPSLIDER && obj <= RPSLIDER + SL_DOWN )
			{
				if ( HdlSlider( tl->wd.tree, &rpSl, obj ) )
				{
					SliderToEdText( &tl->wd, RPTIME, rpSl.pos, winHdl );
					RedrawWinObj( &tl->wd, rpSl.slider + SL_BOX, winHdl );
					rpTime = rpSl.pos;
				}
			}
	}
}


/*
*	HdlEvent()
*
*	wird von TOSACC.C aufgerufen
*/

#pragma warn -par

static	int		HdlEvent( TOOL *tl, int evtype, EVENT *ev, int top )
{
	int		obj;
	
	if ( evtype & MU_KEYBD )
	{
		switch ( ev->ev_mkreturn )
		{
			case PLUS:
			case ZPLUS:	if ( tl->wd.edobj == KBTIME )
							SwitchObj( tl, kbSl.slider + SL_DOWN );
						else
							SwitchObj( tl, rpSl.slider + SL_DOWN );
						break;
			case MINUS:
			case ZMINUS:if ( tl->wd.edobj == KBTIME )
							SwitchObj( tl, kbSl.slider + SL_UP );
						else
							SwitchObj( tl, rpSl.slider + SL_UP );
						break;
			case RETURN:
			case ENTER:	SwitchObj( tl, tl->wd.edobj );
						break;
			default:	obj = DialKeybd( &tl->wd, ev->ev_mkreturn,
										 ev->ev_mmokstate, winHdl );
						if ( obj )
							SwitchObj( tl, obj );
						break;
		}
	}					
	if ( evtype & MU_BUTTON )
	{
		obj = DialButton( &tl->wd, ev->ev_mmox, ev->ev_mmoy, ev->ev_mbreturn, winHdl );
		SwitchObj( tl, obj );
	}
	Kbrate( kbTime, rpTime );
	return ( 0 );
}

#pragma warn .par


/*
*	KbInit()
*
*	wird bei Programmstart von TOSACC.C aufgerufen
*/

TOOL	*KbInit( FILE *fp, int handle )
{
	ours = handle;
	
	if ( fp )
	{
		fread( &rpTime, sizeof (int), 1L, fp );
		fread( &kbTime, sizeof (int), 1L, fp );
	}
	
	Kbrate( kbTime, rpTime );
	itoa( kbTime, ObPtr(KEYBOARD,KBTIME)->ob_spec.tedinfo->te_ptext, 10 );
	itoa( rpTime, ObPtr(KEYBOARD,RPTIME)->ob_spec.tedinfo->te_ptext, 10 );
	InitEdObj( &ourTool.wd, TrPtr(KEYBOARD), KBTIME );
	PosSlider( ourTool.wd.tree, &rpSl, rpTime );
	PosSlider( ourTool.wd.tree, &kbSl, kbTime );

	return ( &ourTool );
}	
