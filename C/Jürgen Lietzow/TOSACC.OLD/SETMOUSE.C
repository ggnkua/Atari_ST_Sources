/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 11/91  <<<<<<<<<<<<<		*/
/*																		*/
/*																		*/
/*		P R O J E C T	:	TOS ACCESSORY Spezial						*/
/*							TOSACC.ACC									*/
/*																		*/
/*		M O D U L E		:	SETMOUSE.C									*/
/*																		*/
/*																		*/
/*		Author			:	Jrgen Lietzow fr TOS-Magazin				*/
/*																		*/
/*		Last Update		:	28.08.91 (JL)								*/
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

static	void	SwitchObj( TOOL *tl, int obj )
{
	int		field;

	obj &= 0x7fff;
	
	switch ( obj )
	{
		case SMOFF:		smSwitch = 0;		break;
		case SMON:		smSwitch = 1;		break;
		case SMDIREC:	if ( IsSelected(&tl->wd.tree[SMDIREC]) )
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
					SliderToEdText( &tl->wd, tl->wd.edobj, sl.pos, winHdl );
					RedrawWinObj( &tl->wd, sl.slider + SL_BOX, winHdl );
					ChgEntry( tl->wd.edobj - ( SMFIELD + 1 ), sl.pos );
				}
				break;
			}
			field = obj - SMFIELD - 1;
			if ( field >= 0 && field < 12 )
			{
				if ( obj != tl->wd.edobj )
					ChangeEdField( &tl->wd, obj, winHdl );
				EdTextToSlider( &tl->wd, obj, &sl, winHdl );
				SliderToEdText( &tl->wd, obj, sl.pos, winHdl );
				ChgEntry( obj - ( SMFIELD + 1 ), sl.pos );
				break;
			}
			break;
	}
}

static	int		HdlEvent( TOOL *tl, int evtype, EVENT *ev, int top )
{
	int		obj;
	int		temp;
	
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
			case ENTER: SwitchObj( tl, tl->wd.edobj );
						break;
			default :
				temp = tl->wd.edobj;
				obj = DialKeybd( &tl->wd, ev->kreturn, ev->kstate, winHdl );
				if ( !obj && temp != tl->wd.edobj )
					obj = tl->wd.edobj;
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

	stack = Super(0L);
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
