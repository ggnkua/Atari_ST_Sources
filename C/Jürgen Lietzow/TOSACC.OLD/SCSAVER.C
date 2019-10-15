/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 11/91  <<<<<<<<<<<<<		*/
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
/*		Last Update		:	28.08.91 (JL)								*/
/*																		*/
/*																		*/
/************************************************************************/

#include <stdlib.h>

#include "tosglob.h"

#include "tosacc.h"

		
extern	void	New200HZ( void );
extern	void	NewKEYBD( void );

		void	(*Old200HZ)( void );
		void	(*OldKEYBD)( void );

		int		scSwitch = 1;
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



static	long	Install( void )
{
	OldKEYBD = *SysKEYBD;
	Old200HZ = *Sys200HZ;
	
	*SysKEYBD = NewKEYBD;
	*Sys200HZ = New200HZ;
	
	return ( 0L );
}

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

static	int		SwitchObj( TOOL *tl, int obj )
{
	switch ( obj & 0x7fff )
	{
		case SCOFF:		scSwitch = 0;	break;
		case SCBLACK:	scSwitch = 1;	break;
		case SCINVERT:	scSwitch = 2;	break;
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

static	int		HdlEvent( TOOL *tl, int evtype, EVENT *ev, int top )
{
	int		obj;
	
	if ( evtype & MU_KEYBD )
	{
		switch ( ev->kreturn )
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
			default:	obj = DialKeybd( &tl->wd, ev->kreturn,
										 ev->kstate, winHdl );
						if ( obj )
							SwitchObj( tl, obj );
						break;
		}
	}					
	if ( evtype & MU_BUTTON )
	{
		obj = DialButton( &tl->wd, ev->mox, ev->moy, ev->mreturn, winHdl );
		SwitchObj( tl, obj );
	}
	return ( 0 );
}

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
	else if ( scSwitch == 1 )
		Select(ObPtr(SCSAVER,SCBLACK));
	else
		Select(ObPtr(SCSAVER,SCINVERT));

	Supexec( Install );
	
	return ( &ourTool );
}	
