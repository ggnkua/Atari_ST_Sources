/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 4/92  <<<<<<<<<<<<<		*/
/*																		*/
/*																		*/
/*		P R O J E C T	:	TOS ACCESSORY Spezial						*/
/*							TOSACC.ACC									*/
/*																		*/
/*		M O D U L E		:	SPOOLER.C									*/
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

static	int		Save( TOOL *tl, FILE *fp );
static	int		HdlEvent( TOOL *tl, int evtype, EVENT *ev, int top );
static	int		HandleSlider( OBJECT *tree, SLIDERBLK *sl );
static	int		Mode( TOOL *tl, int type );


static	SLIDERBLK rateSl = { SPRATE, 15, HandleSlider, 1, 1, -1 };

static	int		ours;
static	TOOL	ourTool =	{	NULL, NULL, 0, 0, 0, 0, 1, -1,
								-1,
								Save,
								Mode,
								HdlEvent,
							};
static	FILE_SPEC	fSpec = { "", "SPOOLER.DAT", "*.DAT" };

#pragma warn -par

static	int		Save( TOOL *tl, FILE *fp )
{
	if ( fp )
	{
		if ( fwrite( &(sys->spOn), sizeof (int), 1L, fp ) != 1L ||
			 fwrite( &(sys->spRate), sizeof (int), 1L, fp ) != 1L ||
			 fwrite( &(sys->spQuick), sizeof (int), 1L, fp ) != 1L ||
			 fwrite( &(sys->spFile), sizeof (sys->spFile), 1L, fp ) != 1L )
			return ( 1 );
	}
	return ( 0 );
}

#pragma warn .par

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
		case SPRATE:	sys->spRate = SlAbsToRel( sl, sl->pos );
						SlDigit( tr, sl, ( sys->spRate * 100 ) / 20 );
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
	OBJECT	*tr = TrPtr(SPOOLER);
	int		obj = FormEvent( &tl->wd, ev );
	GRECT	gr;
		
	switch ( obj & 0x7FFF )
	{
		case SPON:		sys->spOn = 1;		break;
		case SPOFF:		sys->spOn = 0;		break;
		case SPQUICK:	sys->spQuick ^= 1;	break;
		case SPRESET:	sys->ResetSpooler();
						Deselect(tr+SPRESET);
						sprintf ( ObTxt(tr+SPRAM), "%6ld", sys->spNBlocks );
						RedrawWinObj( &tl->wd, SPRAM, NULL );
						sprintf ( ObTxt(tr+SPCHARS), "%ld", sys->spNChars );
						RedrawWinObj( &tl->wd, SPCHARS, NULL );
						AbsObj( tr, obj, &gr );
						RedrawWinObj( &tl->wd, 0, &gr );
						break;
		case SPFILE:	if ( FselInput( &fSpec, "W„hle Spooler-Datei !" ) &&
							 fSpec.fname[0] )
						{
							if ( strlen( fSpec.fname ) +
								 strlen( fSpec.path ) >=
								 sizeof (sys->spFile) )
								form_alert( 1, "[1][Dateiname zu lang!]"
											   "[OK]" );
							else
							{
								if ( sys->spNChars )
								{
									if ( form_alert( 1, "[2][Dazu mssen die aktuellen"
												   "Spooler-Daten gel”scht"
												   "werden !][OK|Abbruch]" )
										== 1 )
									{
										strcpy( sys->spFile, fSpec.path );
										strcat( sys->spFile, fSpec.fname );
										sys->ResetSpooler();		   
									}
								}
							}
						}
						Deselect(tr+obj);
						AbsObj( tr, 0, &gr );
						RedrawWinObj( &tl->wd, obj, &gr );
						break;
		default:
				if ( ObjInSl(obj, SPRATE) )
					HdlSlider( &tl->wd, &rateSl, obj );
				break;
	}
	return ( 0 );
}

/*
*	Mode()
*
*	Wird von TOSACC.C aufgerufen. Bei jedem Timer-Ereignis, bei
*	AC_CLOSE, und bei einem Toolwechsel.
*/

static	int		Mode( TOOL *tl, int type )
{
	static	long 	num = -1L;
			OBJECT	*tr;

	if ( sys->spNChars == num )
		return ( 0 );
	
	tr = TrPtr(SPOOLER);
	num = sys->spNChars;

	if ( type & MODE_TOPEN )
	{
		sprintf ( ObTxt(tr+SPCHARS), "%ld", sys->spNChars );
		sprintf ( ObTxt(tr+SPRAM), "%6ld", sys->spNBlocks );
	}
	if ( type & MODE_TIMER )
		if ( ( type & MODE_TACTIV ) && mainWD.window >= 0 )
		{
			sprintf ( ObTxt(tr+SPCHARS), "%ld", sys->spNChars );
			RedrawWinObj( &tl->wd, SPCHARS, NULL );
			sprintf ( ObTxt(tr+SPRAM), "%6ld", sys->spNBlocks );
			RedrawWinObj( &tl->wd, SPRAM, NULL );
		}
	return ( 0 );
}

/*
*	SpInit()
*
*	wird bei Programmstart von TOSACC.C aufgerufen
*/

TOOL	*SpInit( FILE *fp, int handle )
{
	OBJECT	*tr = TrPtr(SPOOLER);
	
	ours = handle;

	if ( fp )
	{
		if ( fread( &(sys->spOn), sizeof (int), 1L, fp ) != 1L ||
			 fread( &(sys->spRate), sizeof (int), 1L, fp ) != 1L ||
			 fread( &(sys->spQuick), sizeof (int), 1L, fp ) != 1L ||
			 fread( &(sys->spFile), sizeof (sys->spFile), 1L, fp ) != 1L )
			;
	}

	sprintf( ObTxt(tr+SPRAM), "%6ld", sys->spNBlocks );
	sprintf( ObTxt(tr+SPCHARS), "%ld", sys->spNChars );
	sprintf( ObTxt(tr+SPDISK), "%6ld", (long) MAX_DBLOCKS );

	ObTxt(tr+SPFILE) = sys->spFile;
	
	InitEdObj( &ourTool.wd, tr, -1 );

	if ( sys->spOn )
		Select(tr+SPON); 
	else
		Select(tr+SPOFF); 
	
	if ( sys->spQuick )
		Select(tr+SPQUICK);
		
	SlInit( tr, &rateSl, sys->spRate );
	SlDigit( tr, &rateSl, ( sys->spRate * 100 ) / 20 );

	return ( &ourTool );
}

#pragma warn .par
