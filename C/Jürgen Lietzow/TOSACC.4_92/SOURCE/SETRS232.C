/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 4/92  <<<<<<<<<<<<<		*/
/*																		*/
/*																		*/
/*		P R O J E C T	:	TOS ACCESSORY Spezial						*/
/*							TOSACC.ACC									*/
/*																		*/
/*		M O D U L E		:	SETRS232.C									*/
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

#include "tosglob.h"
#include "tosacc.h"

typedef struct
{
		unsigned int		dummy		: 8;
		unsigned int		clk			: 1;
		unsigned int		bpw			: 2;
		unsigned int		startbit	: 2;
		unsigned int		p_onoff		: 1;
		unsigned int		p_oddeven	: 1;
		unsigned int		free 		: 1;
}	UCR;

static	int		Save( TOOL *tl, FILE *fp );
static	int		HdlEvent( TOOL *tl, int evtype, EVENT *ev, int top );
static	int		Mode( TOOL *tl, int type );
static	int		HandleSlider( OBJECT *tree, SLIDERBLK *sl );

static	SLIDERBLK bdSl = { SLBAUD, 16, HandleSlider, 0, 1, -1 };

static	int		baud = 15-4;
		UCR		ucr = { 0, 1, 0, 1, 0, 0, 0 };
static	int		flow = 0;

static	char	*bdList[] = {	"50",
								"75",
								"110",
								"134",
								"150",
								"200",
								"300",
								"600",
								"1200",
								"1800",
								"2000",
								"2400",
								"3600",
								"4800",
								"9600",
								"19200"	};

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
		if ( fwrite( &baud, sizeof (int), 1L, fp ) == 1L )
			if ( fwrite( &flow, sizeof (int), 1L, fp ) == 1L )
				if ( fwrite( &ucr, sizeof (UCR), 1L, fp ) == 1L )
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
	baud = sl->pos;
	tr[SLBAUD+SL_SLIDER].ob_spec.tedinfo->te_ptext = bdList[baud];
	Rsconf(15-baud, -1, -1, -1, -1, -1 );
	return ( 0 );
}

#pragma warn .par

/*
*	SetButton()
*
*	setzt oder l”scht das SELECTED-Flag, und zeichnet evtl das Objekt
*	neu
*/

static	int	SetButton( WINDIA *wd, int but, int select, int redraw )
{
	OBJECT	*ob = wd->tree + but;

	if ( select )
	{
		if ( !IsSelected(ob) )
		{
			Select(ob);
			if ( redraw )
				RedrawWinObj( wd, but, NULL );
			else
				return ( 1 );
		}
	}
	else
	{
		if ( IsSelected(ob) )
		{
			Deselect(ob);
			if ( redraw )
				RedrawWinObj( wd, but, NULL );
			else
				return ( 1 );
		}
	}
	return ( 0 );
}


static	int	_SelectRBut( OBJECT *tr, int obj, TPBLK *tp )
{
	if ( obj == tp->obj )
		return ( 0 );
	tr += obj;
	if ( IsSelectable(tr) && IsRadio(tr) )
		tp->tx |= SetButton( (WINDIA *) tp->temp, obj, 0, tp->cmp );

	return ( 0 );
}

/*
*	SelectRBut()
*
*	setzt das SELECTED-Flag eines RADIO-Buttons, und l”scht gegenenfalls
*	das Flag bei den anderen Objekten
*/

static	int	SelectRBut( WINDIA *wd, int but, int redraw )
{
	TPBLK	tp;

	tp.obj = but;
	tp.temp = (long) wd;
	tp.cmp = redraw;
	tp.tx = 0;

	ScanTree( wd->tree, ObjcParent( wd->tree, but ), &tp, _SelectRBut );
	return ( tp.tx | SetButton( wd, but, 1, redraw ) );
}

/*
*	SetRS()
*
*	pažt die Dialogbox an die aktuelle Rechnerkonfiguration an
*/

int	SetRS( WINDIA *wd, int baud, int flow, int flag )
{
	OBJECT	*tr = wd->tree;
	int		redraw = 0;

	if ( baud != bdSl.pos )
	{
		if ( SlSetAbsPos( tr, &bdSl, SlRelToAbs( &bdSl, baud ) ) && flag )
		{
			tr[SLBAUD+SL_SLIDER].ob_spec.tedinfo->te_ptext = bdList[baud];
			RedrawWinObj( wd, SLBAUD, NULL );
		}
		else
			redraw = 1;
	}

	if ( flow )
	{
		if ( flow & 1 )
			redraw |= SetButton( wd, SHAKEXON, 1, flag );
		if ( flow & 2 )
			redraw |= SetButton( wd, SHAKERTS, 1, flag );
	}
	else
	{
		redraw |= SetButton( wd, SHAKEXON, 0, flag );
		redraw |= SetButton( wd, SHAKERTS, 0, flag );
	}
	if ( ucr.p_onoff )
	{
		if ( ucr.p_oddeven )
			redraw |= SelectRBut( wd, PARIEVEN, flag );
		else
			redraw |= SelectRBut( wd, PARIODD, flag );
	}
	else
		redraw |= SelectRBut( wd, PARINO, flag );

	switch ( (int) ucr.bpw )
	{
		case	0:	redraw |= SelectRBut( wd, SGN8, flag );
					break;
		case	1:	redraw |= SelectRBut( wd, SGN7, flag );
					break;
		case	2:	redraw |= SelectRBut( wd, SGN6, flag );
					break;
		case	3:	redraw |= SelectRBut( wd, SGN5, flag );
					break;
		default	:	break;
	}
	switch ( (int) ucr.startbit )
	{
		case	0:	redraw |= SelectRBut( wd, STOP00, flag );
					break;
		case	1:	redraw |= SelectRBut( wd, STOP10, flag );
					break;
		case	2:	redraw |= SelectRBut( wd, STOP15, flag );
					break;
		case	3:	redraw |= SelectRBut( wd, STOP20, flag );
					break;
		default	:	break;
	}
	return ( redraw );
}

/*
*	Mode()
*
*	Wird von TOSACC.C aufgerufen. Bei jedem Timer-Ereignis, bei
*	AC_CLOSE, und bei einem Toolwechsel.
*/

static	int		Mode( TOOL *tl, int type )
{
	long	conf;
	long	temp;
	int		t;

	if ( type & (MODE_TOPEN|MODE_TOPPED) )
	{
		conf = Rsconf( -1, -1, -1, -1, -1, -1 );
		temp = Rsconf( -2, -1, -1, -1, -1, -1 );

		if ( temp != conf )
			baud = 15 - (int) temp;
		t = (int) (conf >> 24) & 0xff;
		ucr = *(UCR *) &t;
		return ( SetRS( &tl->wd, baud, flow, 0 ) );
	}
	if ( (type & (MODE_TACTIV|MODE_TIMER)) == (MODE_TACTIV|MODE_TIMER) )
	{
		conf = Rsconf( -1, -1, -1, -1, -1, -1 );
		temp = Rsconf( -2, -1, -1, -1, -1, -1 );

		if ( temp != conf )
			baud = 15 - (int) temp;
		t = (int) (conf >> 24) & 0xff;
		ucr = *(UCR *) &t;
		SetRS( &tl->wd, baud, flow, 1 );
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
	int		obj = FormEvent( &tl->wd, ev ) & 0x7fff;

	switch ( obj )
	{
		case PARINO:	ucr.p_onoff = 0;				break;
		case PARIODD:	ucr.p_oddeven = 0;
						ucr.p_onoff = 1;
						break;
		case PARIEVEN:	ucr.p_oddeven = 1;
						ucr.p_onoff = 1;
						break;
		case SHAKEXON:	flow ^= 1;
						break;
		case SHAKERTS:	flow ^= 2;
						break;
		case SGN8:		ucr.bpw = 0;		break;
		case SGN7:		ucr.bpw = 1;		break;
		case SGN6:		ucr.bpw = 2;		break;
		case SGN5:		ucr.bpw = 3;		break;
		case STOP10:	ucr.startbit = 1;	ucr.clk = 1;	break;
		case STOP15:	ucr.startbit = 2;	ucr.clk = 1;	break;
		case STOP20:	ucr.startbit = 3;	ucr.clk = 1;	break;

		default:
			if ( ObjInSl(obj, SLBAUD) )
				HdlSlider( &tl->wd, &bdSl, obj );
			break;
	}
	ucr.dummy = 0;
	Rsconf( 15-baud, flow, *((int*) &ucr), -1, -1, -1 );

	return ( 0 );
}

#pragma warn .par


/*
*	RSInit()
*
*	wird bei Programmstart von TOSACC.C aufgerufen
*/

TOOL	*RSInit( FILE *fp, int handle )
{
	OBJECT	*tr = TrPtr(RS232);

	ours = handle;

	if ( fp )
	{
		if ( fread( &baud, sizeof (int), 1L, fp ) == 1L )
			if ( fread( &flow, sizeof (int), 1L, fp ) == 1L );
				fread( &ucr, sizeof (UCR), 1L, fp );
	}

	InitEdObj( &ourTool.wd, tr, -1 );

	SlInit( tr, &bdSl, baud );
	tr[SLBAUD+SL_SLIDER].ob_spec.tedinfo->te_ptext = bdList[baud];
	SetRS( &ourTool.wd, baud, flow, 0 );
	Rsconf( 15-baud, flow, *((int*) &ucr), -1, -1, -1 );
	return ( &ourTool );
}
