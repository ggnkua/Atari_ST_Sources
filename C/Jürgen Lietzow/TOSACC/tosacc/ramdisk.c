/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 6/92  <<<<<<<<<<<<<		*/
/*																		*/
/*																		*/
/*		P R O J E C T	:	TOS ACCESSORY Spezial						*/
/*							TOSACC.ACC									*/
/*																		*/
/*		M O D U L E		:	RAMDISK.C									*/
/*																		*/
/*																		*/
/*		Author			:	Jrgen Lietzow fr TOS-Magazin				*/
/*																		*/
/*		System/Compiler	:	Atari ST/TT, TOS 1.4, Pure C				*/
/*																		*/
/*		Last Update		:	27.04.92 (JL)								*/
/*																		*/
/*																		*/
/************************************************************************/

#include <stdlib.h>
#include <string.h>

#include "tosglob.h"
#include "tosacc.h"

static	int		Save( TOOL *tl, FILE *fp );
static	int		HdlEvent( TOOL *tl, int evtype, EVENT *ev, int top );
static	int		HandleSlider( OBJECT *tree, SLIDERBLK *sl );
static	int		Mode( TOOL *tl, int type );


static	SLIDERBLK driveSl = { RDDRIVE, 14, HandleSlider, 2, 1, -1 };

static	int		ours;
static	TOOL	ourTool =	{	NULL, NULL, 0, 0, 0, 0, 1, -1,
								-1,
								NULL,	/* Steht alles in sys->tai */
								NULL,
								HdlEvent,
								NULL
							};
static	FILE_SPEC	fSpec = { "", "COPY.TTP", "*.TTP" };

/*
*	HandleSlider()
*
*	wird von 'HdlSlider()' aufgerufen, wenn der Slider einen neuen
*	Wert eingenommen hat
*/

static	int		HandleSlider( OBJECT *tr, SLIDERBLK *sl )
{
	switch ( sl->slider )
	{
		case RDDRIVE:	sys->tai.rdNxtDrv = SlAbsToRel( sl, sl->pos );
						*ObTxt(tr+RDDRIVE+SL_SLIDER) = sys->tai.rdNxtDrv + 'A';
						break;
		default		 :	break;
	}
	return ( 0 );
}

/*
*	HdlEvent()
*
*	wird von TOSACC.C aufgerufen
*/

#pragma warn -par

static	int		HdlEvent( TOOL *tl, int evtype, EVENT *ev, int top )
{
	int		obj = FormEvent( &tl->wd, ev );
	GRECT	gr;
		
	switch ( obj & 0x7FFF )
	{
		case RDON:		sys->tai.rdNxtOn = 1;			break;
		case RDOFF:		sys->tai.rdNxtOn = 0;			break;
		case RDRESET:	sys->tai.rdExecFlag = 1;	break;
		case RDONLY:	sys->tai.rdExecFlag = 0;	break;
		case RDPARAM:	break;
		case RDPRG:		if ( FselInput( &fSpec, "W„hle AUTO-Startprogramm !" ) )
						{
							if ( !fSpec.fname[0] )
								sys->tai.rdFname[0] = '\0';
							else
							{
								strcpy( sys->tai.rdFname, fSpec.path );
								strcat( sys->tai.rdFname, fSpec.fname );
							}
						}
						Deselect(tl->wd.tree+obj);
						AbsObj( tl->wd.tree, 0, &gr );
						RedrawWinObj( &tl->wd, obj, &gr );
						break;
		default:
				if ( ObjInSl(obj, RDDRIVE) )
					HdlSlider( &tl->wd, &driveSl, obj );
				break;
	}
	return ( 0 );
}

/*
*	RdInit()
*
*	wird bei Programmstart von TOSACC.C aufgerufen
*/

TOOL	*RdInit( FILE *fp, int handle )
{
	OBJECT	*tr = TrPtr(RAMDISK);
	
	ours = handle;

	ObTxt(tr+RDPARAM) = sys->tai.rdParams;
	ObString(tr+RDPRG) = sys->tai.rdFname;
	InitEdObj( &ourTool.wd, tr, RDPARAM );
	if ( sys->tai.rdNxtOn )
		Select(tr+RDON); 
	else
		Select(tr+RDOFF); 
	
	if ( sys->tai.rdExecFlag )
		Select(tr+RDRESET);
	else
		Select(tr+RDONLY);

	SlInit( tr, &driveSl, sys->tai.rdNxtDrv );
	*ObTxt(tr+RDDRIVE+SL_SLIDER) = sys->tai.rdNxtDrv + 'A';

	return ( &ourTool );
}

#pragma warn .par
