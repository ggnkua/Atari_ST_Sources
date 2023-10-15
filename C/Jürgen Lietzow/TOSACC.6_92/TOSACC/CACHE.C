/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 6/92  <<<<<<<<<<<<<		*/
/*																		*/
/*																		*/
/*		P R O J E C T	:	TOS ACCESSORY Spezial						*/
/*							TOSACC.ACC									*/
/*																		*/
/*		M O D U L E		:	CACHE.C										*/
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


extern	int		SelectRBut( WINDIA *wd, int but, int redraw );

static	int		Save( TOOL *tl, FILE *fp );
static	int		HdlEvent( TOOL *tl, int evtype, EVENT *ev, int top );
static	int		HandleSlider( OBJECT *tree, SLIDERBLK *sl );

static	int		drv = 0;

static	SLIDERBLK driveSl = { DCDRIVE, 16, HandleSlider, 0, 1, -1 };
static	SLIDERBLK delaySl = { DCDELAY, 9, HandleSlider, 1, 1, -1 };

static	int		ours;
static	TOOL	ourTool =	{	NULL, NULL, 0, 0, 0, 0, 1, -1,
								-1,
								NULL,	/* Steht alles in sys->tai */
								NULL,
								HdlEvent,
								NULL
							};

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
		case DCDRIVE:	drv = SlAbsToRel( sl, sl->pos );
						*ObTxt(tr+DCDRIVE+SL_SLIDER) = drv + 'A';
						if( Dsetdrv( Dgetdrv() ) & ( 1L << drv ) &&
							( drv != sys->rdDrv || !sys->rdOn ) )
							Enable(tr+DCDRIVE+SL_SLIDER);
						else
							Disable(tr+DCDRIVE+SL_SLIDER);
						if ( sys->di[drv].diWrite )
							SelectRBut( &ourTool.wd, DCDWRITE, 1 );
						else if ( sys->di[drv].diRead )
							SelectRBut( &ourTool.wd, DCDREAD, 1 );
						else
							SelectRBut( &ourTool.wd, DCDOFF, 1 );
						if ( sys->di[drv].diLocked )
						{
							Select(ourTool.wd.tree+DCDLOCK);
							RedrawWinObj( &(ourTool.wd), DCDLOCK, NULL );
						}
						else
						{
							Deselect(ourTool.wd.tree+DCDLOCK);
							RedrawWinObj( &(ourTool.wd), DCDLOCK, NULL );
						}
						break;
		case DCDELAY:	sys->tai.ciDelay = SlAbsToRel( sl, sl->pos );
						SlDigit( tr, sl, (int) sys->tai.ciDelay );
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
	OBJECT	*tr = TrPtr(CACHE);
	int		obj = FormEvent( &tl->wd, ev );
	int		t;
		
	switch ( obj & 0x7FFF )
	{
		case DCON:		sys->tai.ciOn = 1;		return ( 0 );
		case DCOFF:		sys->_ciFlush();
						sys->_ciClear();
						sys->tai.ciOn = 0;		return ( 0 );
		case DCDOFF:	sys->_ciDrSet( drv, sys->_ciDrState( drv ) & 
											D_LOCKED );
						break;
		case DCDREAD:	sys->_ciDrSet( drv, ( sys->_ciDrState( drv ) & 
											D_LOCKED ) | D_READ );
						break;
		case DCDWRITE:	sys->_ciDrSet( drv, ( sys->_ciDrState( drv ) & 
											D_LOCKED ) | D_READ | D_WRITE );
						break;
		case DCDLOCK:	if ( IsSelected(tr+DCDLOCK ) )
							sys->_ciDrSet( drv, sys->_ciDrState( drv ) | 
											D_LOCKED  );
						else
							sys->_ciDrSet( drv, sys->_ciDrState( drv ) &
											~D_LOCKED  );
						break;
		case DCRESET:	sys->_ciFlush();
						sys->_ciClear();
						sys->ciLogrd = sys->ciPhrd = sys->ciLogwrt = 
						sys->ciPhwrt = sys->ciFixederr =
						sys->ciFatalerr = 0L;
						Deselect(tr+DCRESET);
						RedrawWinObj( &tl->wd, obj, NULL );
						return ( 0 );
		default:
				if ( ObjInSl(obj, DCDRIVE) )
					HdlSlider( &tl->wd, &driveSl, obj );
				else if ( ObjInSl(obj, DCDELAY) )
					HdlSlider( &tl->wd, &delaySl, obj );
				return ( 0 );
	}
	t = 0;
	if ( sys->di[drv].diRead )
		t |= D_READ;
	if ( sys->di[drv].diWrite )
		t |= D_WRITE;
	if ( sys->di[drv].diLocked )
		t |= D_LOCKED;
	sys->tai.ciDrvTypes[drv] = t;			
	return ( 0 );
}

/*
*	DcInit()
*
*	wird bei Programmstart von TOSACC.C aufgerufen
*/

TOOL	*DcInit( FILE *fp, int handle )
{
	OBJECT	*tr = TrPtr(CACHE);
	
	ours = handle;

	InitEdObj( &ourTool.wd, tr, -1 );

	if ( sys->tai.ciOn )
		Select(tr+DCON); 
	else
		Select(tr+DCOFF); 
	
	if ( sys->di[drv].diWrite )
		SelectRBut( &ourTool.wd, DCDWRITE, 0 );
	else if ( sys->di[drv].diRead )
		SelectRBut( &ourTool.wd, DCDREAD, 0 );
	else
		SelectRBut( &ourTool.wd, DCDOFF, 0 );
	if ( sys->di[drv].diLocked )
		Select(ourTool.wd.tree+DCDLOCK);
	else
		Deselect(ourTool.wd.tree+DCDLOCK);

		
	SlInit( tr, &driveSl, drv );
	*ObTxt(tr+DCDRIVE+SL_SLIDER) = drv + 'A';
	SlInit( tr, &delaySl, (int) sys->tai.ciDelay );
	SlDigit( tr, &delaySl, (int) sys->tai.ciDelay );
	
	return ( &ourTool );
}

#pragma warn .par
