/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 4/92  <<<<<<<<<<<<<		*/
/*																		*/
/*																		*/
/*		P R O J E C T	:	TOS ACCESSORY Spezial						*/
/*							TOSACC.ACC									*/
/*																		*/
/*		M O D U L E		:	HIGHGEM.C									*/
/*																		*/
/*																		*/
/*		Author			:	JÅrgen Lietzow fÅr TOS-Magazin				*/
/*																		*/
/*		System/Compiler	:	Atari ST/TT, TOS 1.4, Pure C				*/
/*																		*/
/*		Last Update		:	26.02.92 (JL)								*/
/*																		*/
/*																		*/
/************************************************************************/

#include <limits.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>

#define	__HIGHGEM

#include "tgemlib.h"

#include "xgem.h"

#define rs_tedinfo	p_tedinfo
#define rs_iconblk	p_iconblk
#define rs_bitblk	p_bitblk
#define	rs_frstr	p_frstr
#define rs_frimg	p_frimg
#define rs_object	p_object
#define rs_trindex	p_trindex

#include "xgem.rsh"

#undef	rs_tedinfo
#undef	rs_iconblk
#undef	rs_bitblk
#undef	rs_frstr
#undef	rs_frimg
#undef	rs_object
#undef	rs_trindex

#ifdef	TrPtr
	#undef	TrPtr
#endif

#define	TrPtr(t)	(p_trindex[t])

int		xobFlag = 0;
int		dpSwitch = 0;		/* FormAlert positionierung */

GEMVARS	gemv;
char	alBuf[AL_BUFLEN];
AL_INF	alInf = { AL_BUFLEN, 0, 0, (ALERTS *) alBuf };


static	USERBLK	ownObj[MAX_OWN];

static	long	cokname;			/* fÅr Ermittlung der Cookies */

static	WINDIA	*tempWD;			/* FÅr RedrawWinObj() */
static	int		tempObj;			/* FÅr RedrawWinObj() */
static	char	edText[128];		/* FÅr RedrawEdObj() */
static	TEDCOL	tedCol;				/* FÅr RedrawEdObj() */


	/*	History-Buffer mit Scheib- und Leseposition */

static	HIST	hist[MAX_HIST];
static	int		readPos;
static	int		writePos;


	/*	fÅr die Alertbox */
	
static	int		btList[] = { BUTTON1, BUTTON2, BUTTON3 };
static	int		stList[] = { STRING1, STRING2, STRING3, STRING4, STRING5 };
static	int		icList[] = { ICEXCLAM, ICQUEST, ICSTOP };


/*
*	OpenGEM()
*
*	Initialisiert GEM
*/

int		OpenGEM( void )
{
	int		i;

	gemv.applId = appl_init();

	if ( gemv.applId == -1 )
		return ( -1 );

	for ( i = 0; i < 10; i++ )
		gemv.work_in[i] = 1;
	gemv.work_in[10] = 2;
	gemv.physHdl = graf_handle( &gemv.wchar, &gemv.hchar,
								&gemv.wbox, &gemv.hbox );
	gemv.vdiHdl = gemv.physHdl;
	v_opnvwk( gemv.work_in, &gemv.vdiHdl, gemv.work_out );

	if ( gemv.vdiHdl == 0 )
	{
		appl_exit();
		return ( -1 );
	}

	WindGet( 0, WF_WORKXYWH, &gemv.work );
	WindGet( 0, WF_CURRXYWH, &gemv.desk );
	SetClip( NULL, 0 );
	vq_extnd( gemv.vdiHdl, 1, gemv.xwork_out );

	return ( 0 );
}

/*
*	CloseGEM()
*
*	Beendet GEM
*/

void	CloseGEM( void )
{
	if ( gemv.gemMalloc )
		free( gemv.gemBuf );
		
	v_clsvwk( gemv.vdiHdl );
	appl_exit();
}

/*
*	OpenXGEM()
*
*	Initialisiert GEM und reserviert Platz fÅr USER-Objekte und Fontchars
*/

void		OpenXGEM( void )
{
	GRECT	gr;
	long	len;
		
	FixTree( TrPtr(BUTIMG) );
	FixTree( TrPtr(FONTCHAR) );
	FixTree( TrPtr(ALERT) );
	
	wind_get( 0, WF_SCREEN, (int *) &gemv.gemBuf, ((int *) &gemv.gemBuf) + 1,
							(int *) &gemv.gemBufLen, ((int *) &gemv.gemBufLen) + 1 );

	FormCenter( TrPtr(ALERT) );
	gr = *ObGRECT(TrPtr(ALERT));
	rc_frame( &gr, 4 );
	len = ScreenSize( &gr );
	FormCenter( TrPtr(FONTCHAR) );
	gr = *ObGRECT( TrPtr(FONTCHAR) );
	len = Max( len, ScreenSize( &gr ) );
	
	gemv.gemMalloc = 0;
	if ( !gemv.gemBuf || gemv.gemBufLen < len )
	{
		gemv.gemBufLen = len;
		gemv.gemBuf = malloc( gemv.gemBufLen );

		if ( !gemv.gemBuf )
			gemv.gemBufLen = 0L;
		else
			gemv.gemMalloc = 1;
	}
}

/*
*	SetClip()
*
*	Setzt das Begrenzungsrechteck in dem das VDI die Grafik ausgeben darf
*/

void	SetClip( const GRECT *gr, int flag )
{
	long	pxy[2];

	if ( gr == NULL )
	{
		pxy[0] = *(long *) &gemv.desk.g_x;
		pxy[1] = *(long *) &gemv.desk.g_w;
	}
	else
	{
		pxy[0] = *(long *) &gr->g_x;
		pxy[1] = *(long *) &gr->g_w;
	}

	pxy[1] += pxy[0];

	((int *)pxy)[2]--;
	((int *)pxy)[3]--;

	vs_clip( gemv.vdiHdl, flag, (int *) pxy );
}

static	void draw_keytext( int x, int y, char *txt, int vhdl )
{
	char	*txt1;
	int		i;
	char	c;

	txt1 = txt;
	for ( i = 0; *txt1 && *txt1 != '[' ; i++, txt1++ );
	c = *txt1;
	*txt1 = '\0';

	v_gtext( vhdl, x, y, txt );
	
	if ( ( *txt1++ = c ) != '\0' )
	{
		c = txt1[1];
		txt1[1] = '\0';
		x += i * gemv.wchar;
		vst_effects( vhdl, TXT_UNDERLINED );
		v_gtext( vhdl, x, y, txt1++ );
		vst_effects( vhdl, TXT_NORMAL );
		*txt1 = c;
		v_gtext( vhdl, x + gemv.wchar, y, txt1 );
	}
}

static	int cdecl DrawSmBut( PARMBLK *pb )
{
	OBJECT	*ob = pb->pb_tree + pb->pb_obj;
	char	*text = (char *) pb->pb_parm;
	BITBLK	*bit;
	int		y;
	MFDB	s, d;
	int		pxy[8];	
	static	int		index[2] = { BLACK, WHITE };

	SetClip( (GRECT *) &pb->pb_xc, gemv.vdiHdl );
	line_default( gemv.vdiHdl );

	if ( ob->ob_flags & RBUTTON )
		if ( pb->pb_currstate & SELECTED )
			bit = ObPtr(BUTIMG,RSBUT)->ob_spec.bitblk;
		else
			bit = ObPtr(BUTIMG,RBUT)->ob_spec.bitblk;
	else
		if ( pb->pb_currstate & SELECTED )
			bit = ObPtr(BUTIMG,NSBUT)->ob_spec.bitblk;
		else
			bit = ObPtr(BUTIMG,NBUT)->ob_spec.bitblk;

	y = (pb->pb_h - gemv.hchar) >> 1;
	
	d.fd_addr = NULL;
	
	s.fd_addr = bit->bi_pdata;
	s.fd_w = bit->bi_wb << 3;
	s.fd_h = bit->bi_hl;
	s.fd_wdwidth = bit->bi_wb >> 1;
	s.fd_stand = 0;
	s.fd_nplanes = 1;
	
	*(long *) pxy = 0L;
	pxy[2] = s.fd_w - 1;
	pxy[3] = s.fd_h - 1;
	*(long *) &pxy[4] = *(long *) &pb->pb_x;
	pxy[5] += y;
	*(long *) &pxy[6] = *(long *) &pxy[4];
	pxy[6] += pxy[2];
	pxy[7] += pxy[3];

	y += pb->pb_y;
	vrt_cpyfm( gemv.vdiHdl, MD_REPLACE, pxy, &s, &d, index );

	text_default( gemv.vdiHdl, gemv.hchar );
	draw_keytext( pb->pb_x + 3 * gemv.wchar, y, text + 2, gemv.vdiHdl );

	return ( pb->pb_currstate & ~SELECTED );
}

static	int cdecl DrawBgBut( PARMBLK *pb )
{
	OBJECT	*ob = pb->pb_tree + pb->pb_obj;
	char	*text = (char *) pb->pb_parm;
	int		x, y;
	int		fr;
	int		i;
	GRECT	gr;
		
	SetClip( (GRECT *) &pb->pb_xc, gemv.vdiHdl );

	if ( ob->ob_flags & DEFAULT )
		fr = 3;
	else
		if ( ob->ob_flags & EXIT )
			fr = 2;
		else
			fr = 1;
	
	gr = *(GRECT *) &pb->pb_x;
	rc_frame( &gr, 1 );
	line_default( gemv.vdiHdl );
	DrawFrame( &gr, fr, gemv.vdiHdl );
	
	x = pb->pb_x;
	y = pb->pb_y + ( (pb->pb_h - gemv.hchar) >> 1 );

	for ( fr = 0, i = 0; text[i]; i++ )
		if ( text[i] != '[' )
			fr++;

	x += ( pb->pb_w - ( fr * gemv.wchar ) ) >> 1;

	text_default( gemv.vdiHdl, gemv.hchar );
	draw_keytext( x, y, text, gemv.vdiHdl );

	return ( pb->pb_currstate );
}

static	int cdecl DrawBoxText( PARMBLK *pb )
{
	char	*text = (char *) pb->pb_parm;
	int		x, y;
	GRECT	gr;	
	int		off;
	int		hc, wc;
	
	line_default( gemv.vdiHdl );
	SetClip( (GRECT *) &pb->pb_xc, gemv.vdiHdl );

	gr = *(GRECT *) &pb->pb_x;
	rc_frame( &gr, 1 );
	hc = gemv.hchar;
	wc = gemv.wchar;
	if ( text[0] == '}' )
	{
		text_default( gemv.vdiHdl, 6 );
		hc = 6;
	}
	else
		text_default( gemv.vdiHdl, gemv.hchar );

	off = hc >> 1;
	gr.g_y += ( off - 1 );
	gr.g_h -= ( off - 3 );
	
	DrawFrame( &gr, 1, gemv.vdiHdl );
	
	x = pb->pb_x + ( wc << 1 );
	y = pb->pb_y;
	v_gtext( gemv.vdiHdl, x, y - 2, text + 1 );
	
	set_hchar( gemv.vdiHdl, gemv.hchar );
	return ( pb->pb_currstate );
}

void	ExpandObjs( OBJECT *tr )
{
	USERBLK	*own = ownObj;
	USERBLK	*max = &own[MAX_OWN-1];
	char	*text;
	
	if ( tr->ob_state & 0x4000 )
		return;
	else
		tr->ob_state |= 0x4000;
	do
	{
		switch( tr->ob_type & 0xff )
		{
			case G_BUTTON:
				text = ObString(tr);
				if ( strchr( text, '[' ) )
				{
					if ( text[0] == ']' && text[1] == ' ' )
						own->ub_code = DrawSmBut;
					else
						own->ub_code = DrawBgBut;
					own->ub_parm = (long) text;
					ObString(tr) = (void *) own;
					*(((char *)&tr->ob_type)+1) = (char) G_USERDEF;
					own++;
				}
				else if ( text[0] == '{' || text[0] == '}' )
				{
					if ( tr->ob_flags & 
						   (SELECTABLE|DEFAULT|EXIT|TOUCHEXIT|RBUTTON) )
						break;
					own->ub_code = DrawBoxText;
					own->ub_parm = (long) text;
					ObString(tr) = (void *) own;
					*(((char *)&tr->ob_type)+1) = (char) G_USERDEF;
					own++;
				}
				break;
			default	:	break;
		}
	} while ( !( (tr++)->ob_flags & LASTOB ) && own < max );
}

void	ReduceObjs( OBJECT *tr )
{
	USERBLK	*own = ownObj;
	
	if ( tr->ob_state & 0x4000 )
		tr->ob_state &= ~0x4000;
	else
		return;
	do
	{
		if ( *(((char *)&tr->ob_type)+1) == (char) G_USERDEF &&
			 tr->ob_spec.userblk == own )
		{
			*(((char *)&tr->ob_type)+1) = (char) G_BUTTON;
			ObString(tr) = (void *) own->ub_parm;
			own++;
		}
	} while ( !( (tr++)->ob_flags & LASTOB ) );
}

int		ObjcDraw( OBJECT *tree, int start, int depth, const GRECT *g )
{
	int		ret;

	xobFlag = 1;
	ExpandObjs( tree );
	ret = objc_draw( tree, start, depth, g->g_x, g->g_y, g->g_w, g->g_h );
	ReduceObjs( tree );	
	xobFlag = 0;
	return ( ret );	
}

int		ObjcChange( OBJECT *tree, int obj, GRECT *g, int newstate,
					int redraw )
{
	int		ret;

	xobFlag = 1;
	ExpandObjs( tree );	
	ret = objc_change( tree, obj, 0, g->g_x, g->g_y, g->g_w, g->g_h,
					   newstate, redraw );
	ReduceObjs( tree );	
	xobFlag = 0;
	return ( ret );	
}

int		FormKeybd( OBJECT *tree, int obj, int next, int kchar, int *nxtobj,
				   int *nxtchar )
{
	int		ret;

	xobFlag = 1;
	ExpandObjs( tree );	
	ret = form_keybd( tree, obj, next, kchar, nxtobj, nxtchar );
	ReduceObjs( tree );	
	xobFlag = 0;
	return ( ret );	
}

int		FormButton( OBJECT *tree, int obj, int clicks, int *nxtobj )
{
	int		ret;

	xobFlag = 1;
	ExpandObjs( tree );	
	ret = form_button( tree, obj, clicks, nxtobj );
	ReduceObjs( tree );	
	xobFlag = 0;
	return ( ret );	
}

static	long volatile	_GetCookie( void )
{
	long	*ptr = _p_cookies;
	long	name = cokname;
	long	temp;

	if ( !ptr )
		return ( 0L );

	do
	{
		if ( ( temp = *ptr ) == 0L )
			break;
		if ( temp == name )
			return ( (long) ptr );
		ptr += 2;
	} while ( 1 );
	return ( 0L );
}

/*
*	GetCookie()
*
*	liefert einen Zeiger auf ein Cookie namens 'name'
*	sonst NULL
*/

void	*GetCookie( long name )
{
	cokname = name;
	return ( (void *) Supexec( (long (*)(void)) _GetCookie ) );
}

/*
*	TransMFDB()
*
*	Transformiert gerÑteunabhÑngige	in GerÑteabhÑngige
*	Images
*/

void	TransMFDB( int *saddr, int sw, int *daddr, int dw, int h )
{
	MFDB	src, dest;

	src.fd_addr = saddr;
	src.fd_w = sw << 3;
	src.fd_h = h;
	src.fd_wdwidth = sw >> 1;
	src.fd_stand = 1;
	src.fd_nplanes = 1;

	dest.fd_addr = daddr;
	dest.fd_w = dw << 3;
	dest.fd_h = h;
	dest.fd_wdwidth = dw >> 1;
	dest.fd_stand = 0;
	dest.fd_nplanes = 1;

	vr_trnfm( gemv.vdiHdl, &src, &dest );
}

#pragma warn -par

void	_RedrawWinObj( const GRECT *gr, int winhdl )
{
	WINDIA	*wd = tempWD;
	int		obj = tempObj;

	if ( obj >= 0 )
	{
		ObjcDraw( wd->tree, obj, 8, gr );
		if ( obj == wd->edobj || IsInParent( wd->tree, obj, wd->edobj ) )
			CursorChg( wd );
	}
	else
		CursorChg( wd );
}

#pragma warn .par

/*
*	RedrawWinObj()
*
*	Zeichnet einen Ausschnitt eines Fensters mit Objektbaum
*	und den Textcursor. Alle Informationen dazu sind in WINDIA.
*/

void	RedrawWinObj( WINDIA *wd, int obj, GRECT *gr )
{
	tempWD = wd;
	tempObj = obj;

	if ( obj < 0 )
		obj = wd->edobj;

	if ( !gr )
		gr = &gemv.desk;
	RedrawWin( gr, wd->window, _RedrawWinObj );
}


/*
*	SetFlags()
*
*	setzt das SELECTED-Flag von mehreren Objekten an Hand einer 'bitmap'
*/

int		SetFlags( WINDIA *wd, int *ol, int num, long bits, int draw, int flag )
{
	OBJECT	*tr = wd->tree;
	int		i;
	int		redraw = 0;

	flag++;
	for ( i = 0; i < num; i++, ol += flag, bits >>= 1 )
	{
		if ( bits & 1L )
		{
			if ( !IsSelected(tr+*ol) )
			{
				Select(tr+*ol);
				if ( draw )
					RedrawWinObj( wd, *ol, NULL );
				else
					redraw = 1;
			}
			if ( flag == 2 )
				if ( IsSelected(tr+ol[1]) )
				{
					Deselect(tr+ol[1]);
					if ( draw )
						RedrawWinObj( wd, ol[1], NULL );
					else
						redraw = 1;
				}
		}
		else
		{
			if ( IsSelected(tr+*ol) )
			{
				Deselect(tr+*ol);
				if ( draw )
					RedrawWinObj( wd, *ol, NULL );
				else
					redraw = 1;
			}
			if ( flag == 2 )
				if ( !IsSelected(tr+ol[1]) )
				{
					Select(tr+ol[1]);
					if ( draw )
						RedrawWinObj( wd, ol[1], NULL );
					else
						redraw = 1;
				}
		}
	}
	return ( redraw );
}

/*
*	SetBits()
*
*	Umkehrfunktion von 'SetFlags()'
*	Erzeugt eine 'bitmap' von mehreren selektierbaren Buttons
*/

long	SetBits( WINDIA *wd, int *ol, int num, int flag )
{
	OBJECT	*tr = wd->tree;
	int		i;
	long	bits = 0L;
	long	mask = 1L;

	flag++;

	for ( i = 0; i < num; i++, ol += flag, mask <<= 1 )
		if ( IsSelected(tr+*ol) )
			bits |= mask;

	return ( bits );
}


/*
*	SlAbsToRel()
*
*	liefert die 'relative' Slider-Position
*/

int		SlAbsToRel( SLIDERBLK *sl, int abs )
{
	if ( abs < 0 )
		abs = 0;
	else if ( abs >= sl->num )
		abs = sl->num - 1;
	return ( sl->min + abs * sl->step );
}

/*
*	SlRelToAbs()
*
*	liefert die 'absolute' Slider-Position (0 bis ...)
*/

int		SlRelToAbs( SLIDERBLK *sl, int rel )
{
	rel -= sl->min;
	rel /= sl->step;

	if ( rel < 0 )
		rel = 0;
	else if ( rel >= sl->num )
		rel = sl->num - 1;
	return ( rel );
}

/*
*	SlSetSize()
*
*	Setzt die Slider-Grîûe so, daû ein Pixel einem
*	absoluten Wert entspricht
*/

int		SlSetSize( OBJECT *tree, SLIDERBLK *sl )
{
	int		width;

	tree += sl->slider;

	if ( tree[SL_BOX].ob_width > tree[SL_BOX].ob_height )
	{
		width = tree[SL_BOX].ob_width - sl->num;
		if ( width < 16 )
			width = 16;
		if ( tree[SL_SLIDER].ob_width == width )
			return ( 0 );
		tree[SL_SLIDER].ob_width = width;
	}
	else
	{
		width = tree[SL_BOX].ob_height - sl->num;
		if ( width < 16 )
			width = 16;
		if ( tree[SL_SLIDER].ob_height == width )
			return ( 0 );
		tree[SL_SLIDER].ob_height = width;
	}
	return ( 1 );
}

/*
*	SlAbsPage()
*
*	Ermittelt den 'absoluten' Offset wenn der Slider um seine Grîûe
*	verschoben wird
*/

int		SlAbsPage( OBJECT *tree, SLIDERBLK *sl )
{
	int		width, range;

	tree += sl->slider;
	if ( tree[SL_BOX].ob_width > tree[SL_BOX].ob_height )
	{
		width = tree[SL_SLIDER].ob_width;
		range = tree[SL_BOX].ob_width - width;
	}
	else
	{
		width = tree[SL_SLIDER].ob_height;
		range = tree[SL_BOX].ob_height - width;
	}
	return ( (int) ( (long) width * (long) sl->num / range ) );
}

/*
*	SlSetAbsPos()
*
*	Positioniert den Slider
*/

int		SlSetAbsPos( OBJECT *tree, SLIDERBLK *sl, int pos )
{
	int		range, obpos;

	tree += sl->slider;

	if ( pos < 0 )
		pos = 0;
	else if ( pos >= sl->num )
		pos = sl->num - 1;

	if ( pos == sl->pos )
		return ( 0 );
	sl->pos = pos;
	if ( tree[SL_BOX].ob_width > tree[SL_BOX].ob_height )
	{
		range = tree[SL_BOX].ob_width - tree[SL_SLIDER].ob_width;
		obpos = (int) ( ( (long) pos * (long) range ) / (long) sl->num );
		tree[SL_SLIDER].ob_x = obpos;
	}
	else
	{
		range = tree[SL_BOX].ob_height - tree[SL_SLIDER].ob_height;
		obpos = (int) ( ( (long) pos * (long) range ) / (long) sl->num );
		tree[SL_SLIDER].ob_y = obpos;
	}
	return ( 1 );
}

/*
*	SlGetAbsPos()
*
*	liefert den 'absoluten' Offset an Hand der Slider-Position
*/

int		SlGetAbsPos( OBJECT *tree, SLIDERBLK *sl )
{
	int		range, obpos;

	tree += sl->slider;

	if ( tree[SL_BOX].ob_width > tree[SL_BOX].ob_height )
	{
		range = tree[SL_BOX].ob_width - tree[SL_SLIDER].ob_width;
		obpos = tree[SL_SLIDER].ob_x;
	}
	else
	{
		range = tree[SL_BOX].ob_height - tree[SL_SLIDER].ob_height;
		obpos = tree[SL_SLIDER].ob_y;
	}
	range = (int) ( ( (long) sl->num * (long) obpos ) / (long) range );
	if ( range >= sl->num )
		range = sl->num - 1;
	return ( range );
}

void	SlDigit( OBJECT *tree, SLIDERBLK *sl, int num )
{
	itoa( num, tree[sl->slider+SL_SLIDER].ob_spec.tedinfo->te_ptext, 10 );
}

static	int		SlNewPos( WINDIA *wd, SLIDERBLK *sl, int off )
{
	if ( SlSetAbsPos( wd->tree, sl, sl->pos + off ) )
	{
		sl->sl_handle( wd->tree, sl );
		RedrawWinObj( wd, sl->slider + SL_BOX, NULL );
		return ( 1 );
	}
	return ( 0 );
}
	
/*
*	HdlSlider()
*
*	verwaltet einen Klick auf ein Slider-Objekt
*	Diese Hauptfunktion steuert alle weiteren Funktionen
*/

int		HdlSlider( WINDIA *wd, SLIDERBLK *sl, int obj )
{
	int		x, y, mstate, slobj = sl->slider;
	int		ox, oy, hx, hy;
	OBJECT	*tree = wd->tree;
	OBJECT	*ob;
	int		dummy;
	GRECT	box, slider, temp;
	int		flag;

	if ( obj - slobj == SL_UP )
		return ( SlNewPos( wd, sl, -1 ) );
	if ( obj - slobj == SL_DOWN )
		return ( SlNewPos( wd, sl, 1 ) );

	ob = tree + slobj;
	graf_mkstate( &x, &y, &mstate, &dummy );

	AbsObj( tree, slobj + SL_BOX, &box );
	slider.g_x = ob[SL_SLIDER].ob_x + box.g_x;
	slider.g_y = ob[SL_SLIDER].ob_y + box.g_y;
	slider.g_w = ob[SL_SLIDER].ob_width;
	slider.g_h = ob[SL_SLIDER].ob_height;

	if ( !MInGrect(x,y,&box) )
		return ( 0 );
	if ( !MInGrect(x,y,&slider) )
	{
		obj = SlAbsPage( tree, sl );
		if ( ob[SL_BOX].ob_width > ob[SL_BOX].ob_height )
			if ( x < slider.g_x )
				return ( SlNewPos( wd, sl, -obj ) );
			else
				return ( SlNewPos( wd, sl, obj ) );
		else
			if ( y < slider.g_y )
				return ( SlNewPos( wd, sl, -obj ) );
			else
				return ( SlNewPos( wd, sl, obj ) );
	}
	if ( !mstate )
		return ( 0 );

	hx = x - slider.g_x;		/* Hot point */
	hy = y - slider.g_y;
	flag = ( box.g_w > box.g_h );
	graf_mouse( FLAT_HAND, NULL );
	do
	{
		temp = slider;
		ox = x;
		oy = y;

		graf_mkstate( &x, &y, &mstate, &dummy );

		if ( !mstate )
			break;
		if ( flag )
		{
			if ( x == ox )
				continue;
		}
		else
		{
			if ( y == oy )
				continue;
		}
		slider.g_x = x - hx;
		slider.g_y = y - hy;
		rc_constrain( &box, &slider );

		ob[SL_SLIDER].ob_x = slider.g_x - box.g_x;
		ob[SL_SLIDER].ob_y = slider.g_y - box.g_y;

		dummy = SlGetAbsPos( tree, sl );
		sl->pos = dummy;

		sl->sl_handle( tree, sl );

		rc_merge( &slider, &temp );
		rc_frame( &temp, 1 );

		RedrawWinObj( wd, sl->slider + SL_BOX, &temp );
	} while ( 1 );
	graf_mouse( ARROW, NULL );
	return ( 1 );
}

/*
*	SlInit()
*
*	Initialisiert einen Slider
*	paût die Objektgrîûen an, da sie sich wegen
*	Ñuûeren Rahmen Åberschneiden
*/

int		SlInit( OBJECT *tree, SLIDERBLK *sl, int rel )
{
	OBJECT	*ob = tree + sl->slider;

	if ( ob[SL_BOX].ob_height == ob[SL_SLIDER].ob_height )
	{
		if ( ob[SL_UP].ob_x + ob[SL_UP].ob_width == ob[SL_BOX].ob_x )
		{
			ob[SL_BOX].ob_x += 1;
			ob[SL_BOX].ob_width -= 2;
		}
	}
	else
	{
		if ( ob[SL_UP].ob_y + ob[SL_UP].ob_height == ob[SL_BOX].ob_y )
		{
			ob[SL_BOX].ob_y += 1;
			ob[SL_BOX].ob_height -= 2;
		}
	}
	return ( SlSetAbsPos( tree, sl, SlRelToAbs( sl, rel ) ) );
}

/*
*	RedrawWin()
*
*	öbernimmt das Neuzeichnen eines Fensters bei einem WM_REDRAW
*	(Rechtecklisten)
*/

void	RedrawWin( const GRECT *gr, int hdl, void (*Redraw)( const GRECT *gr, int hdl ) )
{
	GRECT	box;
	GRECT	dsk = gemv.desk;

	if ( rc_intersect( gr, &dsk ) )
	{
		MouseOff();
		if ( hdl < 0 )
		{
			SetClip( &dsk, 1 );
			Redraw( &dsk, hdl );
		}
		else
		{
			WindGet( hdl, WF_FIRSTXYWH, &box );

			while ( box.g_w && box.g_h )
			{
				if ( rc_intersect( &dsk, &box ) )
				{
					SetClip( &box, 1 );
					Redraw( &box, hdl );
				}
				WindGet( hdl, WF_NEXTXYWH, &box );
			}
		}
		SetClip( &dsk, 0 );
		MouseOn();
	}
}

/*
*	MoveObjWin()
*
*	Verschiebt ein Fenster
*/

void	MoveObjWin( GRECT *gr, WINDIA *wd, int kind )
{
	GRECT	temp;
	OBJECT	*tr = wd->tree;

	WindCalc( WC_WORK, kind, gr, gr );

	gr->g_x -= gr->g_x % 8;
	tr->ob_x = gr->g_x;
	tr->ob_y = gr->g_y;

	InitCurPos( wd );
	WindCalc( WC_BORDER, kind, gr, &temp );

	WindSet( wd->window, WF_CURRXYWH, &temp );

}

long	ScreenSize( const GRECT *gr )
{
	long		l;
	int			off,
				x = gr->g_x,
				rw = gr->g_h,
				co = gr->g_w;

	/* auf Wort-Grenze */

	off = x % 16;
	if ( off )
	{
		co += off;
		x -= off;
	}
	off = co % 16;
	if ( off )
		co += 16 - off;

	l = (long) ( co >> 3 ) * (long) rw * (long) _Planes;
	l += 8L * sizeof (int) + sizeof (MFDB);

	return ( l );
}
	
/*
*	SaveScreen()
*
*	Sichert einen Bildschirmausschnitt
*/

void	SaveScreen( const GRECT *gr, void *buffer )
{
	MFDB		scrn;
	MFDB		*sav;
	int			*pxy;
	int			off,
				x = gr->g_x, y = gr->g_y,
				rw = gr->g_h,
				co = gr->g_w;

	/* auf Wort-Grenze */

	off = x % 16;
	if ( off )
	{
		co += off;
		x -= off;
	}
	off = co % 16;
	if ( off )
		co += 16 - off;

	sav = buffer;
	pxy = (int *) &sav[1];

	sav->fd_addr = &pxy[8];
	sav->fd_wdwidth = ( co >> 4 ) * _Planes;
	sav->fd_w = --co;
	sav->fd_h = --rw;
	sav->fd_stand = 0;
	sav->fd_nplanes = _Planes;

	pxy[0] = x;
	pxy[1] = y;
	pxy[2] = x + co;
	pxy[3] = y + rw;
	pxy[4] = 0;
	pxy[5] = 0;
	pxy[6] = co;
	pxy[7] = rw;

	scrn.fd_addr = NULL;
	SetClip( NULL, 0 );
	MouseOff();
	vro_cpyfm( gemv.vdiHdl, S_ONLY, pxy, &scrn, sav );
	MouseOn();
}

/*
*	RedrawScreen()
*
*	Zeichnet einen gesicherten Bildschirmausschnitt
*/

void	RedrawScreen( void *buffer )
{
	MFDB	scrn;
	MFDB	*sav = buffer;
	int		*pxy = (int *) &sav[1];
	long	temp;

	temp = *(long *) &pxy[0];
	*(long *) &pxy[0] = *(long *) &pxy[4];
	*(long *) &pxy[4] = temp;

	temp = *(long *) &pxy[2];
	*(long *) &pxy[2] = *(long *) &pxy[6];
	*(long *) &pxy[6] = temp;

	scrn.fd_addr = NULL;
	SetClip( NULL, 0 );
	MouseOff();
	vro_cpyfm( gemv.vdiHdl, S_ONLY, pxy, sav, &scrn );
	MouseOn();
}


/*
*	CursorChg()
*
*	invertiert den Textcursor. Das Clipping Rechteck muû richtig
*	gesetzt sein.
*/

void	CursorChg( WINDIA *wd )
{
	int		pxy[4];
	int		pos, i;
	char	*tmplt;

	if ( wd->edobj <= 0 )
		return;

	if ( wd->ted->te_txtlen <= 1 )
		return;

	tmplt = wd->ted->te_ptmplt;

	for ( i = -1, pos = wd->pos + 1; pos; i++ )
		if ( *tmplt++ == '_' )
			pos--;

	pxy[0] = wd->x + (i << 3);
	pxy[1] = wd->y;
	pxy[2] = pxy[0] + 7;
	pxy[3] = pxy[1] + _Ch - 1;

	vswr_mode( gemv.vdiHdl, 3 );
	vsf_interior( gemv.vdiHdl, 1 );

	MouseOff();
	vr_recfl( gemv.vdiHdl, pxy );
	MouseOn();
}

/*
*	InitCurPos()
*
*	Initialisiert den Text-Cursor
*/

void	InitCurPos( WINDIA *wd )
{
	OBJECT	*tr = wd->tree;
	TEDINFO	*ted = wd->ted;
	int		obj = wd->edobj;

	if ( obj <= 0 )
		return;

	objc_offset( tr, obj, &wd->x, &wd->y );
	tr += obj;
	wd->y += ( tr->ob_height - _Ch ) >> 1;
	if ( ted->te_just )
	{
		obj = tr->ob_width - ( ( ted->te_tmplen - 1 ) << 3 );
		if ( ted->te_just == 2 )
			obj >>= 1;
		wd->x += obj;
	}
}

/*
*	InitEdObj()
*
*	Initialisiert ein Edit-Objekt
*/

void	InitEdObj( WINDIA *wd, OBJECT *tree, int obj )
{
	TEDINFO	*ted;

	wd->tree = tree;
	wd->edobj = obj;

	if ( obj < 0 || !IsEditable(tree + obj) )
	{
		wd->edobj = obj = NextEditable( tree, -1 );
		if ( obj < 0 )
			return;
	}
	tree += obj;
	ted = tree->ob_spec.tedinfo;
	wd->ted = ted;
	InitCurPos( wd );
	if ( ted->te_ptext[0] == '@' )
		ted->te_ptext[0] = '\0';
	obj = (int) strlen( ted->te_ptext );
	if ( obj >= ted->te_txtlen - 1 )
		obj--;
	wd->pos = obj;
}

/*
*	ChangeEdField()
*
*	wechselt ein editierbares Objekt (curEdObj), lîscht und setzt
*	den Cursor und initialisiert die Cursorposition (edPos)
*/

void	ChangeEdField( WINDIA *wd, int new )
{
	if ( wd->edobj >= 0 )
		RedrawWinObj( wd, -1, NULL );

	InitEdObj( wd, wd->tree, new );
	RedrawWinObj( wd, -1, NULL );
}

/*
*	GetValid()
*
*	öberprÅft ob ein bestimmter Buchstabe an einer bestimmten Position
*	in dem EdText erlaubt ist.
*/

int		GetValid( int key, char *valid, int pos )
{
	if ( !*valid )
		return ( 0 );

	while ( pos-- )
	{
		valid++;
		if ( !*valid )
		{
			valid--;
			break;
		}
	}

	switch ( *valid )
	{
		case '9':	if ( isdigit( key ) )
						return ( key );
					break;
		case 'A':	if ( isalpha( key ) || key == ' ' )
						return ( toupper( key ) );
					break;
		case 'a':	if ( isalpha( key ) || key == ' ' )
						return ( key );
					break;
		case 'N':	if ( isalnum(key) || key == ' ' )
						return ( toupper(key) );
					break;
		case 'n':	if ( isalnum(key) || key == ' ' )
						return ( key );
					break;
		case 'F':	if ( isalnum(key) || key == '*' || key == '?' ||
						 key == '_' || key == '$'  )
						return ( toupper(key) );
					break;
		case 'P':	if ( isalnum(key) || key == '*' || key == '?' ||
						 key == '_' || key == '$' || key == '\\' ||
						 key == ':' )
						return ( toupper(key) );
					break;
		case 'p':	if ( isalnum(key) || key == '_' || key == '$' ||
						 key == '\\' || key == ':' )
						return ( toupper(key) );
					break;
		case 'X':	return ( key );

		default :	break;
	}
	return ( 0 );
}

#pragma warn -par

static	void	_RedrawEdObj( const GRECT *gr, int hdl )
{
	if ( !tedCol.trans )
	{
		ObjcDraw( tempWD->tree, tempWD->edobj, 8, gr );
	}
	else
	{
		vsf_color( gemv.vdiHdl, tedCol.inter );
		vsf_style( gemv.vdiHdl, tedCol.patt );
		vswr_mode( gemv.vdiHdl, 1 );

		v_gtext( gemv.vdiHdl, tempWD->x, tempWD->y, edText );
	}
	CursorChg( tempWD );
}

#pragma warn .par

/*
*	RedrawEdObj()
*
*	Zeichnet den Text und Cursor eines EdObjekts
*/

void	RedrawEdObj( WINDIA *wd )
{
	OBJECT	*tr = wd->tree + wd->edobj;
	char	*tmp = tr->ob_spec.tedinfo->te_ptmplt;
	char	*text = tr->ob_spec.tedinfo->te_ptext;
	char	*txt = edText;
	char	c;
	TEDCOL	tc = *(TEDCOL *) &(tr->ob_spec.tedinfo->te_color);
	int		d;

	tedCol= tc;
	vst_color( gemv.vdiHdl, tc.tecol );
	vst_effects( gemv.vdiHdl, 0 );
	vst_alignment( gemv.vdiHdl, 0, 5, &d, &d );

	tempWD = wd;

	while ( ( c = *tmp++ ) != '\0' )
	{
		if ( c == '~' || c == '_' )
			if ( *text )
				*txt++ = *text++;
			else
				*txt++ = '_';
		else
			*txt++ = c;
	}
	*txt = '\0';

	RedrawWin( &gemv.desk, wd->window, _RedrawEdObj );
}

	
/*
*	ObjcInsChar()
*
*	FÅgt einen Buchstaben in einen EdText ein
*/

int		ObjcInsChar( WINDIA *wd, int key )
{
	OBJECT		*ob = wd->tree + wd->edobj;
	TEDINFO		*ted;
	char		*txt;
	char		*tmplt;
	int			i = wd->pos;
	int			obj;

	ted = ob->ob_spec.tedinfo;
	txt = ted->te_ptext;

	if ( ted->te_txtlen <= 1 )
		return ( key );

	switch ( key )
	{
		case ESC:		*txt = '\0';
						RedrawWinObj( wd, -1, NULL );
						wd->pos = 0;
						break;
		case BACKSPACE:	if ( i )
						{
							i--;
							RedrawWinObj( wd, -1, NULL );
							wd->pos = i;
							goto Delete;
						}
						else
							return ( 0 );
		case DELETE:	RedrawWinObj( wd, -1, NULL );
	Delete:
						txt += i;
						tmplt = txt + 1;
						if ( *txt )
							while ( ( *txt++ = *tmplt++ ) != 0 );
						break;
		case C_LEFT:	if ( i )
						{
							RedrawWinObj( wd, -1, NULL );
							wd->pos--;
							RedrawWinObj( wd, -1, NULL );
						}
						return ( 0 );
		case C_RIGHT:	if ( txt[i] && i < ted->te_txtlen - 2 )
						{
							RedrawWinObj( wd, -1, NULL );
							wd->pos++;
							RedrawWinObj( wd, -1, NULL );
						}
						return ( 0 );
		case SHFT_CL:	RedrawWinObj( wd, -1, NULL );
						wd->pos = 0;
						RedrawWinObj( wd, -1, NULL );
						return ( 0 );
		case SHFT_CR:	RedrawWinObj( wd, -1, NULL );
						while ( txt[i] )
							i++;
						if ( i >= ted->te_txtlen - 1 )
							i--;
						wd->pos = i;
						RedrawWinObj( wd, -1, NULL );
						return ( 0 );
		default		:	RedrawWinObj( wd, -1, NULL );
						obj = GetValid( key & 0xff, ted->te_pvalid, i );
						if ( obj )
						{
							while ( txt[i++] );
							if ( i > ted->te_txtlen - 2 )
								i = ted->te_txtlen - 2;
							while ( i != wd->pos )
							{
								txt[i] = txt[i-1];
								i--;
							}
							txt[i] = obj;
							if ( i < ted->te_txtlen - 2 )
								wd->pos++;
							break;
						}
						else
						{
							if ( i >= ted->te_txtlen - 2 )
							{
								RedrawWinObj( wd, wd->edobj, NULL );
								return ( key );
							}
							obj = key & 0xff;
							tmplt = ted->te_ptmplt;
							txt += i;
							do
							{
								if ( *tmplt++ == '_' )
									if ( !i-- )
										break;
							} while ( *tmplt );
							if ( !*tmplt )
								break;
							i = 1;
							while ( *tmplt == '_' )
							{
								i++;
								tmplt++;
							}
							if ( !*tmplt || *tmplt != obj )
								break;
							wd->pos += i;
							txt[i] = '\0';
							while ( i-- )
								txt[i] = ' ';
						}
						break;
	}
	RedrawEdObj( wd );
	return ( 0 );
}

/*
*	Hilfsfunktionen fÅr History
*/

/*
*	AddToHist()
*
*	nimmt 'text' und 'valid' in History-Buffer auf, wenn noch
*	nicht enthalten
*/

static	void	AddToHist( char *text, char *valid )
{
	int		i;

	if ( (int) strlen( text ) >= MAX_TLEN ||
		 (int) strlen( valid ) >= MAX_TLEN )
		return;
	for ( i = 0; i < MAX_HIST; i++ )
		if ( !strcmp( text, hist[i].text ) &&
			 !strcmp( valid, hist[i].valid ) )
			return;
	strcpy( hist[writePos].text, text );
	strcpy( hist[writePos].valid, valid );

	if ( ++writePos >= MAX_HIST )
		writePos = 0;
	readPos = writePos;
}

/*
*	AddAllToHist()
*
*	nimmt alle 'te_ptext' und 'te_pvalid' des Objektbaumes in
*	History-Buffer auf
*/

static	void	AddAllToHist( OBJECT *tree )
{
	int		obj;
	int		next;
	TEDINFO	*ted;

	obj = NextEditable( tree, -1 );	/*	liefert das erste editierbare */
									/*	Objekt */

	if ( obj >= 0 )
	{
		do
		{
			ted = tree[obj].ob_spec.tedinfo;
			AddToHist( ted->te_ptext, ted->te_pvalid );
			next = obj;
			obj = NextEditable( tree, next );
		} while ( obj != next );
	}
}

/*
*	NextHist() und LastHist()
*
*	liefern einen Zeiger auf 'text' vom History-Buffer
*/

static	char	*NextHist( char *valid )
{
	int		i = readPos;

	do
	{
		if ( ++i >= MAX_HIST )
			i = 0;
		if ( !strcmp( valid, hist[i].valid ) )
		{
			readPos = i;
			return hist[i].text;
		}
	} while ( i != readPos );

	return ( NULL );
}

static	char	*LastHist( char *valid )
{
	int		i;
	int		end = readPos - 1;

	if ( end < 0 )
		end = MAX_HIST -1;
	i = end;
	do
	{
		if ( !strcmp( valid, hist[i].valid ) )
		{
			readPos = i;
			return hist[i].text;
		}
		if ( --i < 0 )
			i = MAX_HIST - 1;
	} while ( i != end );

	return ( NULL );
}

/*
*	GetHist()
*
*	schreibt im aktuellen editierbaren Objekt einen Text aus dem
*	History-Buffer
*/

static	void	GetHist( WINDIA *wd, char *(*fct)(char *) )
{
	OBJECT	*tree = wd->tree;
	char	*text;
	TEDINFO	*ted;
	int		obj = wd->edobj;
	int		temp;

	if ( obj >= 0 )
	{
		ted = tree[obj].ob_spec.tedinfo;
		temp = readPos;
		AddToHist( ted->te_ptext, ted->te_pvalid );
		readPos = temp;
		text = fct( ted->te_pvalid );
		if ( text )
		{
			RedrawWinObj( wd, -1, NULL );
			strcpy( ted->te_ptext, text );
			InitEdObj( wd, wd->tree, obj );
			RedrawWinObj( wd, obj, NULL );
		}
	}
}

/*
*	ObjcEdit()
*
*	wird ersetzt durch die standard GEM-Funktion objc_edit()
*/

int		ObjcEdit( OBJECT *tree, int edobj, int key, int *pos, int type )
{
	static	WINDIA	wd;

	wd.window = -1;
	switch ( type )
	{
		case ED_START	:	break;
		case ED_INIT	:	InitEdObj( &wd, tree, edobj );
							*pos = wd.pos;
							RedrawWinObj( &wd, -1, NULL );
							break;
		case ED_CHAR	:	if ( *pos != wd.pos || wd.tree != tree )
								return ( 0 );

							ObjcInsChar( &wd, key );
							*pos = wd.pos;
							break;
		case ED_END		:	if ( *pos != wd.pos || wd.tree != tree )
								return ( 0 );
							RedrawWinObj( &wd, -1,NULL );
							break;
		default			:	return ( 0 );
	}
	return ( 1 );
}

/*
*	DialButton()
*
*	Behandelt ein Maus-Event in einer Dialogbox
*/

int		DialButton( WINDIA *wd, int x, int y, int clicks )
{
	OBJECT	*tr = wd->tree;
	int		obj = objc_find( tr, 0, 8, x, y );
	
	MouseOff();
	if ( obj >= 0 )
	{
		if ( !FormButton( tr, obj, clicks, &obj ) )
		{
			if ( clicks == 2 )
				obj |= 0x8000;
			else if ( wd->extflag )
			{
				tr += obj;
				if ( tr->ob_type == G_BUTTON &&
					 ( tr->ob_flags & (SELECTABLE|EXIT|TOUCHEXIT) ) ==
					 (SELECTABLE|EXIT|TOUCHEXIT) )
				{
/*					tr->ob_state ^= SELECTED;
					RedrawWinObj( wd, obj, NULL );
*/					do
					graf_mkstate( &x, &x, &y, &x );
					while ( y );
				}
			}
			AddAllToHist( wd->tree );
			MouseOn();
			return ( obj );
		}
		else if ( wd->edobj > 0 && wd->edobj != obj &&
				  IsEditable(tr+obj) )
			ChangeEdField( wd, obj );
	}
	else
		Bell();
	MouseOn();
	return ( 0 );
}

/*
*	DialKeybd()
*
*	Behandelt ein Tastatur-Event in einer Dialogbox
*/

int		DialKeybd( WINDIA *wd, int key, int kstate )
{
	OBJECT	*tr = wd->tree;
	int		obj;
	int		dummy;

	MouseOff();
	switch ( key )
	{
		case HOME	:
			ChangeEdField(wd, NextEditable(tr, -1) );
			break;
		case SHFT_HOME:
			ChangeEdField(wd, LastEditable(tr, INT_MAX) );
			break;
		case C_UP | '8':
			GetHist( wd, LastHist );
			break;
		case C_DOWN | '2':
			GetHist( wd, NextHist );
			break;
		default	:

		if ( !FormKeybd( tr, wd->edobj,
						  wd->edobj,
						  key, &obj, &key ) )
		{
			AddAllToHist( tr );
			MouseOn();
			return ( obj );
		}

		switch ( key & 0xff )
		{
		case '{':
		case '}':
		case '[':
		case ']':
		case '\\':
		case '@':
				ObjcInsChar( wd, key );
				break;
		default:

			if ( !(kstate & K_ALT) && wd->edobj > 0 )
			{
				if ( obj != wd->edobj )
					ChangeEdField(wd, obj );
				else if ( key )
					ObjcInsChar( wd, key );
			}
			else if ( key )
			{
				key = KeyToUpper( key );
				obj = GetButton( tr, key );
				if ( obj >= 0 )
					if ( !FormButton( tr, obj, 1, &dummy ) )
					{
						AddAllToHist( wd->tree );
						MouseOn();
						return ( obj );
					}
/*					else if ( wd->extflag )
					{
						tr += obj;
						if ( tr->ob_type == G_BUTTON &&
							 ( tr->ob_flags & (SELECTABLE|EXIT|TOUCHEXIT) )==
							 (SELECTABLE|EXIT|TOUCHEXIT) )
						{
							tr->ob_state ^= SELECTED;
							RedrawWinObj( wd, obj, NULL );
							AddAllToHist( wd->tree );
							MouseOn();
							return ( obj );
						}
					}
*/
			}
		break;
		}
		break;
	} /* switch ( key ) */
	MouseOn();
	return ( 0 );
}


int		FormEvent( WINDIA *wd, EVENT *ev )
{
	int		event = ev->ev_mwich;
	int		obj = 0;
	
	if ( event & MU_BUTTON )
		obj = DialButton( wd, ev->ev_mmox, ev->ev_mmoy, ev->ev_mbreturn );
	if ( event & MU_KEYBD )
		obj = DialKeybd( wd, ev->ev_mkreturn, ev->ev_mmokstate );

	if ( event & MU_TIMER && !( event & MU_BUTTON ) && !obj )
	{
		graf_mkstate( &ev->ev_mmox, &ev->ev_mmoy, &ev->ev_mmobutton, &ev->ev_mmokstate );
		if ( ev->ev_mmobutton == 2 )
			obj = DialKeybd( wd, RETURN, 0 );
	}
	return ( obj );
}

int		FormDo( OBJECT *tree, int startob )
{
			WINDIA	wd;
			int		obj = 0;
	static	EVENT	ev = {	MU_KEYBD | MU_BUTTON | MU_TIMER,
							2, 0x1, 1,
							0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
							50, 0,
							{ 0 },
							0, 0, 0, 0, 0, 0, 0 };

	wind_update( BEG_UPDATE );		/* Unsere FormDo() Åbernimmt */
	wind_update( BEG_MCTRL );		/* die Kontrolle */

	InitEdObj( &wd, tree, startob );
	wd.extflag = 0;
	wd.window = -1;
	if ( wd.edobj >= 0 )
		RedrawWinObj( &wd, -1, NULL );

	do
	{
		EventMulti( &ev );
		obj = FormEvent( &wd, &ev );

	} while ( !obj );

	if ( wd.edobj >= 0 )
		RedrawWinObj( &wd, -1, NULL );

	wind_update( END_MCTRL );
	wind_update( END_UPDATE );

	return ( obj );
}
/*
*	SwitchDefault()
*
*	setzt den Default-Button in der AlertBox()
*/

static	void	SwitchDefault( OBJECT *tree, int num )
{
	if ( --num >= 0 && num < 3 )
		tree[btList[num]].ob_flags ^= DEFAULT;
}

/*
*	SwitchIcon()
*
*	setzt das ausgewÑhlte Icon in der Alertbox
*	(Fragezeichen, Stopschild, ...)
*/

static	void	SwitchIcon( OBJECT *tree, int num )
{
	if ( --num >= 0 && num < 3 )
		tree[icList[num]].ob_flags ^= HIDETREE;
}

/*
*	StrLen()
*
*	berechnet die LÑnge eines Eintrages im Formattext der Alertbox
*/

static	int		StrLen( const char *ptr )
{
	int		l = 0;
	char	c;

	while ( ( c = *ptr++ ) != 0 )
	{
		if ( c == '|' || c == ']' )
			return ( l );
		l++;
	}
	return ( l );
}

/*
*	NextType()
*
*	Geht zum nÑchsten Eintrag im Formattext der Alertbox
*	(getrennt durch '|')
*/

static	char	*NextType( const char *ptr )
{
	char	c;

	while ( ( c = *ptr++ ) != 0 )
		if ( c == '[' || ( c == ' ' && ptr[-2] == ']' ) )
			return ( (char *) ptr );

	return ( NULL );
}

/*
*	NextString()
*
*	Geht zum nÑchsten Eintrag im Formattext der Alertbox
*	(getrennt durch '[' oder ']')
*/

static	char	*NextString( const char *ptr )
{
	char	c;

	while ( ( c = *ptr++ ) != 0 )
	{
		if ( c == '|' )
			return ( (char *) ptr );
		if ( c == ']' )
			return ( NULL );
	}
	return ( NULL );
}

/*
*	_FormAlert()
*
*	Low level Alert, wird von Alert() und DelAlerts() benutzt
*/

int		_FormAlert( int deflt, const char *fmt )
{
	OBJECT		*tree = TrPtr(ALERT);
	OBJECT		*ob;
	int			icon;
	int			ret;
	char		*ptr;
	int			lineCnt = 0;
	int			buttonCnt = 0;
	int			l;
	GRECT		gr;
	int			x, y;

	if ( !gemv.gemBuf )
		return ( form_alert( deflt, fmt ) );
	
	if ( ( fmt = NextType( fmt ) ) == NULL	)
		return ( 0 );

	if ( !isdigit( *fmt ) )
		return ( 0 );

	icon = *fmt - '0';

	if ( ( fmt = NextType( fmt ) ) == NULL )
		return ( 0 );

	do
	{
		ptr = (char *) fmt;
		if ( ( l = StrLen( fmt ) ) > MAX_STRLEN )
			return ( 0 );
		ob = &tree[stList[lineCnt++]];
		strncpy( ObString( ob ), fmt, l );
		ObString(ob)[l] = '\0';
		UnHide(ob);
		ob->ob_width = l * _Cw;
	} while ( ( fmt = NextString( fmt ) ) != NULL );

	if ( ( fmt = NextType( ptr ) ) == NULL )
		return ( 0 );

	do
	{
		ptr = (char *) fmt;

		if ( ( l = StrLen( fmt ) ) > MAX_BUTLEN )
			return ( 0 );
		ob = &tree[btList[buttonCnt++]];
		strncpy( ObString( ob ), fmt, l );
		ObString(ob)[l] = '\0';
		UnHide(ob);
	} while ( ( fmt = NextString( fmt ) ) != NULL );

	for ( l = lineCnt; l < 5; l++ )
		Hide( &tree[stList[l]] );
	for ( l = buttonCnt; l < 3; l++ )
		Hide( &tree[btList[l]] );

	SwitchDefault( tree, deflt );
	SwitchIcon( tree, icon );

	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);

	SetClip( NULL, 1 );

	if ( deflt > 0 && dpSwitch )
	{
		graf_mkstate( &x, &y, &l, &l );
		l = btList[deflt-1];
		gr.g_x = x - tree[l].ob_x - ( tree[l].ob_width >> 1 );
		gr.g_y = y - tree[l].ob_y - ( tree[l].ob_height >> 1 );
		gr.g_w = tree->ob_width;
		gr.g_h = tree->ob_height;
		rc_frame( &gr, 3 );
		rc_constrain( &gemv.desk, &gr );
		*ObGRECT(tree) = gr;
		rc_frame( ObGRECT(tree), -3 );
	}
	else
	{
		FormCenter( tree );
		gr = *ObGRECT(tree);
		rc_frame( &gr, 3 );
	}

	SaveScreen( &gr, gemv.gemBuf );
	ObjcDraw( tree, 0, 8, &gr );

	MouseOn();
	ret = FormDo( tree, 0 ) & 0x7fff;
	MouseOff();
	Deselect(tree+ret);

	RedrawScreen( gemv.gemBuf );

	wind_update(END_MCTRL);
	wind_update(END_UPDATE);

	SwitchDefault( tree, deflt );
	SwitchIcon( tree, icon );

	for ( l = 0; l < 3; l++ )
		if ( btList[l] == ret )
			return ( l + 1 );

	return ( 0 );
}

static	int	CheckList( const char *fmt_txt, int dflt )
{
	ALERTS	*al = alInf.alerts;
	int		num = alInf.num;

	while ( num-- )
	{
		if ( dflt == al->old && !strcmp( fmt_txt, al->fmt ) )
			return ( al->new );
		(char *) al += sizeof (ALERTS) + ( (int)strlen(al->fmt) & 0xfffe);
	}
	return ( 0 );
}

static	int AddToList( const char *fmt, int dflt_old, int dflt_new )
{
	ALERTS		*al;

	if ( alInf.pos + strlen( fmt ) + sizeof (ALERTS) >= alInf.buf_len )
		return ( -1 );
	alInf.num++;
	al = (ALERTS *) &(((char *) alInf.alerts)[alInf.pos]);
	al->old = dflt_old;
	al->new = dflt_new;
	strcpy( al->fmt, fmt );
	alInf.pos += (int) sizeof (ALERTS) + ( (int) strlen( fmt ) & 0xfffe );
	return ( 0 );
}

int		FormAlert( int deflt, const char *fmt )
{
	OBJECT		*tree = TrPtr(ALERT);
	int			ret;
	const char	*sav = fmt;

	ret = CheckList( fmt, deflt );
	if ( ret != 0 )
	{
		if ( ( deflt = ret ) < 0 )
			return ( -ret );
		Disable( tree + NXTAUTO );
		Disable( tree + NXTDFLT );
	}

	ret = _FormAlert( deflt, fmt );

	if ( IsSelected( tree + NXTAUTO ) )
	{
		Deselect( tree + NXTAUTO );
		Deselect( tree + NXTDFLT );
		AddToList( sav, deflt, -ret );
	}
	if ( IsSelected( tree + NXTDFLT ) )
	{
		Deselect( tree + NXTDFLT );
		AddToList( sav, deflt, ret );
	}

	Enable( tree + NXTAUTO );
	Enable( tree + NXTDFLT );

	return ( ret );
}

void	DelAlerts( void )
{
	OBJECT	*tree = TrPtr(ALERT);
	char	*sav = tree[NXTAUTO].ob_spec.tedinfo->te_ptext;
	int		i;
	ALERTS	*al = alInf.alerts;
	int		ret;
	char	*ptr;

	tree[NXTAUTO].ob_spec.tedinfo->te_ptext = "Delete";
	Hide( tree + NXTDFLT );

	evnt_timer( 0, 0 );
	for ( i = 0; i < alInf.num; i++ )
	{
		ret = _FormAlert( al->old, al->fmt );
		if ( IsSelected( tree + NXTAUTO ) )
		{
			Deselect( tree + NXTAUTO );
			alInf.num--;
			ret = (int)( sizeof (ALERTS) + ((int)strlen(al->fmt) & 0xfffe));
			ptr = (char *) al + ret;
			memmove( al, ptr, alInf.buf_len - alInf.pos );
			alInf.pos -= ret;
		}
		else
			al = (ALERTS *) ( (char *) al +
				 sizeof (ALERTS) + ((int) strlen(al->fmt) & 0xfffe ) );
	}
	tree[NXTAUTO].ob_spec.tedinfo->te_ptext = sav;
	UnHide( tree + NXTDFLT );
}
