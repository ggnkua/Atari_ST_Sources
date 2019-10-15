/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 1/92  <<<<<<<<<<<<<		*/
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

		
extern	void	New200HZ( void );
extern	void	NewKEYBD( void );
extern	void	InvertScreen( void );

		void	(*Old200HZ)( void );
		void	(*OldKEYBD)( void );

		int		scSwitch = 1;		/* Default Werte */
		int		scTime = 90;


static	int		Save( TOOL *tl, FILE *fp );
static	int		HdlEvent( TOOL *tl, int evtype, EVENT *ev, int top );

static	SLIDERBLK sl = { SCSLIDER, 1, 1800, 1, -1 };
static	int		ours;
static	TOOL	ourTool =	{	NULL, NULL, 0, 0, 0, 0,
								-1,
								Save,
								NULL,
								HdlEvent,
							};


/*
*	Install()
*
*	Setzt neuen Timer-Vektor und Keyboard-Vektor (im Super Modus)
*/

static	long	Install( void )
{
	OldKEYBD = *SysKEYBD;
	Old200HZ = *Sys200HZ;
	
	*SysKEYBD = NewKEYBD;
	*Sys200HZ = New200HZ;
	
	return ( 0L );
}

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
		if ( fwrite( &scSwitch, sizeof (int), 1L, fp ) == 1L )
			if ( fwrite( &scTime, sizeof (int), 1L, fp ) == 1L )
				return ( 0 );
		return ( 1 );
	}
	return ( 0 );
}

/*
*	SwitchObj()
*
*	Behandelt die Benutzereingaben
*/

#pragma warn .par

static	int		SwitchObj( TOOL *tl, int obj )
{
	int		d;
	int		m;
	
	switch ( obj & 0x7fff )
	{
		case SCOFF:		scSwitch = 0;	break;
		case SCON:		scSwitch = 1;	break;
		case SCINVERT:	Supexec( (long(*)(void)) InvertScreen );
						do
							graf_mkstate( &d, &d, &m, &d );
						while( m );
						break;
		case SCTIME:	EdTextToSlider( &tl->wd, SCTIME, &sl, winHdl );
						scTime = sl.pos;
						SliderToEdText( &tl->wd, SCTIME, sl.pos, winHdl );
						break;
		default:	
			if ( HdlSlider( tl->wd.tree, &sl, obj ) )
			{
				SliderToEdText( &tl->wd, SCTIME, sl.pos, winHdl );
				RedrawWinObj( &tl->wd, sl.slider + SL_BOX, winHdl );
				scTime = sl.pos;
			}
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
		switch ( ev->ev_mkreturn )
		{
			case PLUS:
			case ZPLUS:	SwitchObj( tl, sl.slider + SL_DOWN );
						break;
			case MINUS:
			case ZMINUS:SwitchObj( tl, sl.slider + SL_UP );
						break;
			case RETURN:
			case ENTER:	SwitchObj( tl, SCTIME );
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
		obj = DialButton( &tl->wd, ev->ev_mmox, ev->ev_mmoy,
						  ev->ev_mbreturn, winHdl );
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
	ours = handle;
	
	if ( fp )
	{
		fread( &scSwitch, sizeof (int), 1L, fp );
		fread( &scTime, sizeof (int), 1L, fp );
	}
	
	itoa( scTime, ObPtr(SCSAVER,SCTIME)->ob_spec.tedinfo->te_ptext, 10 );
	InitEdObj( &ourTool.wd, TrPtr(SCSAVER), SCTIME );
	PosSlider( ourTool.wd.tree, &sl, scTime );

	if ( !scSwitch )
		Select(ObPtr(SCSAVER,SCOFF));
	else
		Select(ObPtr(SCSAVER,SCON));

	Supexec( Install );
	
	return ( &ourTool );
}	
