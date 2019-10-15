/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 4/92  <<<<<<<<<<<<<		*/
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
/*		Last Update		:	26.02.92 (JL)								*/
/*																		*/
/*																		*/
/************************************************************************/

#include <stdlib.h>
#include <string.h>

#include "tosglob.h"
#include "tosacc.h"

extern	long	ColdBoot( void );

static	int		Save( TOOL *tl, FILE *fp );
static	int		HdlEvent( TOOL *tl, int evtype, EVENT *ev, int top );
static	int		HandleSlider( OBJECT *tree, SLIDERBLK *sl );
static	int		Mode( TOOL *tl, int type );


static	SLIDERBLK sizeSl = { RDSIZE, 60, HandleSlider, 32, 16, -1 };
static	SLIDERBLK driveSl = { RDDRIVE, 14, HandleSlider, 2, 1, -1 };

static	int		ours;
static	TOOL	ourTool =	{	NULL, NULL, 0, 0, 0, 0, 1, -1,
								-1,
								NULL,	/* Steht alles in taccInf */
								NULL,
								HdlEvent,
							};
static	FILE_SPEC	fSpec = { "", "COPY.TTP", "*.TTP" };


static	int	SaveInf( void )
{
	FILE	*fp;

	if ( ( fp = fopen( saveFile, "r+b" ) ) == NULL )
		if ( ( fp = fopen( saveFile, "wb" ) ) == NULL )
			return ( 1 );

	if ( fwrite( &taccInf, sizeof (TACC_INF), 1L, fp ) != 1L )
	{
		fclose( fp );
		return ( 1 );
	}
	fclose( fp );
	return ( 0 );
}

/*
*	HandleSlider()
*
*	wird von 'HdlSlider()' aufgerufen, wenn der Slider einen neuen
*	Wert eingenommen hat
*/

static	int		HandleSlider( OBJECT *tr, SLIDERBLK *sl )
{
	switch( sl->slider )
	{
		case RDDRIVE:	taccInf.drive = SlAbsToRel( sl, sl->pos );
						*ObTxt(tr+RDDRIVE+SL_SLIDER) = taccInf.drive + 'A';
						break;
		case RDSIZE:	taccInf.size = SlAbsToRel( sl, sl->pos );
						SlDigit( tr, sl, taccInf.size );
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
		case RDON:		taccInf.onFlag = 1;		break;
		case RDOFF:		taccInf.onFlag = 0;		break;
		case RDINSTAL:	
						if ( sys->rd_size != taccInf.size ||
							 sys->rd_drive != taccInf.drive ||
							 sys->rd_installed != taccInf.onFlag )
						{
							if ( form_alert( 1, "[2][Dazu wird ein Reset|"
											  "durchgefhrt !]"
											  "[OK|Abbruch]" ) == 1 )
							{
								if ( SaveInf() )
								{
									form_alert( 1, "[3][RAM-Disk Konfiguration|"
												   "l„žt sich nicht abspeichern]"
												   "[OK]" );
									Deselect(tl->wd.tree+obj);
									RedrawWinObj(&tl->wd,obj,NULL);
									break;
								}
								Supexec( ColdBoot );
							}
						}
						else
							form_alert( 1, "[3][Diese RAM-Disk"
										   "Konfiguration|existiert "
										   "bereits][OK]" );
						Deselect(tl->wd.tree+obj);
						RedrawWinObj(&tl->wd,obj,NULL);
						break;		
		case RDRESET:	taccInf.execFlag = 1;	break;
		case RDONLY:	taccInf.execFlag = 0;	break;
		case RDPARAM:	break;
		case RDPRG:		if ( FselInput( &fSpec, "W„hle AUTO-Startprogramm !" ) )
						{
							if ( !fSpec.fname[0] )
								taccInf.fname[0] = '\0';
							else
							{
								strcpy( taccInf.fname, fSpec.path );
								strcat( taccInf.fname, fSpec.fname );
							}
						}
						Deselect(tl->wd.tree+obj);
						AbsObj( tl->wd.tree, 0, &gr );
						RedrawWinObj( &tl->wd, obj, &gr );
						break;
		default:
				if ( ObjInSl(obj, RDSIZE) )
					HdlSlider( &tl->wd, &sizeSl, obj );
				else if ( ObjInSl(obj, RDDRIVE) )
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

	ObTxt(tr+RDPARAM) = taccInf.params;
	ObString(tr+RDPRG) = taccInf.fname;
	InitEdObj( &ourTool.wd, tr, RDPARAM );
	if ( taccInf.onFlag )
		Select(tr+RDON); 
	else
		Select(tr+RDOFF); 
	
	if ( taccInf.execFlag )
		Select(tr+RDRESET);
	else
		Select(tr+RDONLY);
		
	SlInit( tr, &sizeSl, taccInf.size );
	SlDigit( tr, &sizeSl, taccInf.size );
	SlInit( tr, &driveSl, taccInf.drive );
	*ObTxt(tr+RDDRIVE+SL_SLIDER) = taccInf.drive + 'A';

	return ( &ourTool );
}

#pragma warn .par
