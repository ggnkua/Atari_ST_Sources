/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 3/92  <<<<<<<<<<<<<		*/
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
/*		System/Compiler	:	Atari ST/TT, TOS 1.4, Pure C				*/
/*																		*/
/*		Last Update		:	31.01.92 (JL)								*/
/*																		*/
/*																		*/
/************************************************************************/

#include <stdlib.h>

#include "tosglob.h"
#include "tosacc.h"


static	int		Save( TOOL *tl, FILE *fp );
static	int		HdlEvent( TOOL *tl, int evtype, EVENT *ev, int top );
static	int		HandleSlider( OBJECT *tree, SLIDERBLK *sl );
static	int		Mode( TOOL *tl, int type );

static	SLIDERBLK kbSl = { KBSLIDER, 30, HandleSlider, 0, 1, -1 };
static	SLIDERBLK rpSl = { RPSLIDER, 20, HandleSlider, 0, 1, -1 };
static	SLIDERBLK dkSl = { DKSLIDER, 5, HandleSlider, 0, 1, -1 };

static	int		kbTime = 15;		/* Default Werte */
static	int		rpTime = 2;
static	int		dkTime = 3;

static	int		ours;
static	TOOL	ourTool =	{	NULL, NULL, 0, 0, 0, 0, 1, -1,
								-1,
								Save,
								Mode,
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
				if ( fwrite( &dkTime, sizeof (int), 1L, fp ) == 1L )
					return ( 0 );
		return ( 1 );
	}
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
		case KBSLIDER:	kbTime = SlAbsToRel( sl, sl->pos );
						SlDigit( tr, &kbSl, kbTime );
						Kbrate( kbTime, rpTime );
						break;
		case RPSLIDER:	rpTime = SlAbsToRel( sl, sl->pos );
						SlDigit( tr, &rpSl, rpTime );
						Kbrate( kbTime, rpTime );
						break;
		case DKSLIDER:	dkTime = SlAbsToRel( sl, sl->pos );
						SlDigit( tr, &dkSl, dkTime );
						evnt_dclick( dkTime, 1 );
						break;
		default		 :	break;
	}
	return ( 0 );
}

#pragma warn .par

static	int		HdlMode( TOOL *tl, int redraw )
{
	int		kb, rp, dk;
	int		ret = 0;

	rp = Kbrate( -1, -1 );
	kb = (unsigned int) rp >> 8;
	rp &= 0xff;
	dk = evnt_dclick( 0, 0 );

	if ( kb != kbTime )
	{
		kbTime = kb;
		SlDigit( tl->wd.tree, &kbSl, kb );
		SlSetAbsPos( tl->wd.tree, &kbSl, SlRelToAbs( &kbSl, kb ) );
		if ( redraw )
			RedrawWinObj( &tl->wd, KBSLIDER+SL_BOX, NULL );
		ret = 1;
	}
	if ( rp != rpTime )
	{
		rpTime = rp;
		SlDigit( tl->wd.tree, &rpSl, rp );
		SlSetAbsPos( tl->wd.tree, &rpSl, SlRelToAbs( &rpSl, rp ) );
		if ( redraw )
			RedrawWinObj( &tl->wd, RPSLIDER+SL_BOX, NULL );
		ret = 1;
	}
	if ( dk != dkTime )
	{
		dkTime = dk;
		SlDigit( tl->wd.tree, &dkSl, dk );
		SlSetAbsPos( tl->wd.tree, &dkSl, SlRelToAbs( &dkSl, dk ) );
		if ( redraw )
			RedrawWinObj( &tl->wd, DKSLIDER+SL_BOX, NULL );
		ret = 1;
	}
	return ( ret );
}
/*
*	Mode()
*
*	Wird von TOSACC.C aufgerufen. Bei jedem Timer-Ereignis, bei
*	AC_CLOSE, und bei einem Toolwechsel.
*/

static	int		Mode( TOOL *tl, int type )
{
	if ( type & (MODE_TOPEN|MODE_TOPPED) )
		return ( HdlMode( tl, 0 ) );
	if ( (type & (MODE_TACTIV|MODE_TIMER)) == (MODE_TACTIV|MODE_TIMER) )
		HdlMode( tl, 1 );
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
	int		obj;
	OBJECT	*tr;
	int		i;

	obj = FormEvent( &tl->wd, ev );
	
	if ( obj == ( DKTEST | 0x8000 ) )
	{
		obj &= 0x7fff;
		tr = TrPtr(KEYBOARD);
		Select(tr+obj);
		RedrawWinObj( &tl->wd, obj, NULL );
		for ( i = 1; i < 20; i++ )
			Vsync();
		Deselect(tr+obj);
		RedrawWinObj( &tl->wd, obj, NULL );
	}
	else
		if ( ObjInSl(obj, KBSLIDER) )
			HdlSlider( &tl->wd, &kbSl, obj );
		else if ( ObjInSl(obj, RPSLIDER) )
			HdlSlider( &tl->wd, &rpSl, obj );
		else if	( ObjInSl(obj, DKSLIDER) )
			HdlSlider( &tl->wd, &dkSl, obj );

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
	OBJECT	*tr = TrPtr(KEYBOARD);

	ours = handle;

	if ( fp )
	{
		fread( &rpTime, sizeof (int), 1L, fp );
		fread( &kbTime, sizeof (int), 1L, fp );
		fread( &dkTime, sizeof (int), 1L, fp );
	}

	Kbrate( kbTime, rpTime );
	evnt_dclick( dkTime, 1 );

	InitEdObj( &ourTool.wd, tr, -1 );

	SlInit( tr, &kbSl, kbTime );
	SlDigit( tr, &kbSl, kbTime );
	SlInit( tr, &rpSl, rpTime );
	SlDigit( tr, &rpSl, rpTime );
	SlInit( tr, &dkSl, dkTime );
	SlDigit( tr, &dkSl, dkTime );

	return ( &ourTool );
}
