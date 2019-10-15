/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 1/92  <<<<<<<<<<<<<		*/
/*																		*/
/*																		*/
/*		P R O J E C T	:	TOS ACCESSORY Spezial						*/
/*							TOSACC.ACC									*/
/*																		*/
/*		M O D U L E		:	TACCLIB.C									*/
/*																		*/
/*																		*/
/*		Author			:	JÅrgen Lietzow fÅr TOS-Magazin				*/
/*																		*/
/*																		*/
/*		System/Compiler	:	Atari ST/TT, TOS 1.4, Pure C				*/
/*																		*/
/*		Last Update		:	21.11.91 (JL)								*/
/*																		*/
/*																		*/
/************************************************************************/

#include <limits.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>

#define	__TACCLIB

#include "tacclib.h"

		int		work_in[11];
		int		work_out[57];
		int		xwork_out[57];
		int		applId;				/* Applikations id */
		int		vdiHdl;				/* VDI handle */
		int		physHdl;			/* physikalisches VDI handle */
		int		menuId;				/* MenÅeintrag */
		int		wchar, hchar, wbox, hbox;
		GRECT	desk;
		

static	WINDIA	*tempWD;			/* FÅr RedrawWinObj() */
static	int		tempObj;			/* FÅr RedrawWinObj() */
static	char	edText[128];		/* FÅr RedrawEdObj() */
static	TEDCOL	tedCol;				/* FÅr RedrawEdObj() */


	/*	History-Buffer mit Scheib- und Leseposition */

static	HIST	hist[MAX_HIST];
static	int		readPos;
static	int		writePos;

/*
*	OpenGEM()
*
*	Initialisiert GEM
*/

int		OpenGEM( void )
{
	int		i;
	
	applId = appl_init();

	if ( applId == -1 )
		return ( -1 );
		
	for ( i = 0; i < 10; i++ )
		work_in[i] = 1;
	work_in[10] = 2;
	physHdl = graf_handle( &wchar, &hchar, &wbox, &hbox );
	vdiHdl = physHdl;
	v_opnvwk( work_in, &vdiHdl, work_out );

	if ( vdiHdl == 0 )
	{
		return ( -1 );
	}

	if ( work_out[0] < 639 || work_out[1] < 199 )
	{
		v_clsvwk( vdiHdl );
		return ( -1 );
	}

	SetClip( NULL, 0 );
	WindGet( 0, WF_CURRXYWH, &desk );
	vq_extnd( vdiHdl, 1, xwork_out );
	return ( 0 );
}

/*
*	CloseGEM()
*
*	Beendet GEM
*/
	
void	CloseGEM( void )
{
	v_clsvwk( vdiHdl );
	appl_exit();
}

/*
*	Folgende Funktionen rufen direkt die entsprechenden GEM-Funktionen
*	auf. Allerdings ist die ParameterÅbergabe der neuen Funktionen
*	wesentlich angenehmer.
*/

void	MouseOn( void )
{
	graf_mouse( M_ON, (void *)0 );
}

void	MouseOff( void )
{
	graf_mouse( M_OFF, (void *)0 );
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
		pxy[0] = *(long *) &desk.g_x;
		pxy[1] = *(long *) &desk.g_w;
	}
	else
	{
		pxy[0] = *(long *) &gr->g_x;
		pxy[1] = *(long *) &gr->g_w;
	}
	
	pxy[1] += pxy[0];

	((int *)pxy)[2]--;
	((int *)pxy)[3]--;
	
	vs_clip( vdiHdl, flag, (int *) pxy );
}

/*
*	FormCenter()
*
*	Positioniert einen Objektbaum in der Bildschirmmitte
*/

void	FormCenter( OBJECT *tree )
{
	int		d;

	form_center( tree, &d, &d, &d, &d );
}

int		ObjcDraw( OBJECT *tree, int start, int depth, GRECT *g )
{
	return	objc_draw( tree, start, depth, g->g_x, g->g_y,
					   g->g_w, g->g_h );
}

int		WindCalc( int type, int kind, GRECT *src, GRECT *dest )
{
	return ( wind_calc( type, kind,
						src->g_x, src->g_y, src->g_w, src->g_h,
						&dest->g_x, &dest->g_y, &dest->g_w, &dest->g_h ) );
}

/*
*	Bei WindSet() und WindGet() dÅrfen nur die 'types' Åbergeben werden 
*	bei denen vier Werte gelesen oder geschrieben werden
*/

int		WindSet( int hdl, int type, GRECT *gr )
{
	return ( wind_set( hdl, type, gr->g_x, gr->g_y, gr->g_w, gr->g_h ) );
}

int		WindGet( int hdl, int type, GRECT *gr )
{
	return ( wind_get( hdl, type,
					   &gr->g_x, &gr->g_y, &gr->g_w, & gr->g_h ) );
}

/*
*	Seit Pure C gibt es eine neue Event-Funktion die hier
*	gegebenenfalls nachgebildet wird
*/

#if !defined (__PUREC__)

int		EvntMulti( EVENT *ev )
{
	int		evtype;

	evtype = evnt_multi( ev->ev_mflags, ev->ev_mbclicks, ev->ev_mbmask,
						 ev->ev_mbstate,
						 ev->ev_mm1flags, ev->ev_mm1x, ev->ev_mm1x,
						 ev->ev_mm1width, ev->ev_mm1height,
						 ev->ev_mm2flags, ev->ev_mm2x, ev->ev_mm2x,
						 ev->ev_mm2width, ev->ev_mm2height,
						 ev->ev_mmgpbuf,
						 ev->ev_mtlocount, ev->ev_mthicount,
						 &ev->ev_mmox, &ev->ev_mmoy,
						 &ev->ev_mmobutton,
						 &ev->ev_mmokstate,
						 &ev->ev_mkreturn,
						 &ev->ev_mbreturn );
	ev->ev_mwich = evtype;

	return ( evtype );
}

#endif

/*
*	Diese Event-Funktion unterdrÅckt UNENDLICH LANGE
*	Tastaturwiederholungen
*/

int		EventMulti( EVENT *ev )
{
	static	int key = 0;
	static	EVENT	tmp = {	MU_TIMER | MU_KEYBD,
							0, 0, 0,
							0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
							{ 0 },
							0, 0, 0, 0, 0, 0, 0 };
			int		evtype = EvntMulti( ev );

	if ( ev->ev_mflags & MU_KEYBD )
	{
		if ( evtype & MU_KEYBD )
		{
			if ( ev->ev_mkreturn == key )
			{
				while( EvntMulti( &tmp ) & MU_KEYBD &&
					   tmp.ev_mkreturn == key );
				ev->ev_mkreturn = tmp.ev_mkreturn;
				ev->ev_mmokstate = tmp.ev_mmokstate;
			}
			key = ev->ev_mkreturn;
		}
		else
			key = 0;
	}

	return ( evtype );
}

/*
*	StrnCpy()
*
*	kopiert len Zeichen und schlieût immer mit '\0' ab
*/

char	*StrnCpy( char *dest, const char *src, size_t len )
{
	dest[len] = '\0';
	return ( strncpy( dest, src, len ) );
}

/*
*	TransMFDB()
*
*	Transformiert gerÑteunabhÑngige	in GerÑteabhÑngige
*	Images
*/

static void TransMFDB( int *saddr, int sw, int *daddr, int dw, int h )
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
	
	vr_trnfm( vdiHdl, &src, &dest );
}

/*
*	FixImages()
*
*	Paût G_ICON und G_IMAGE an die aktuelle Bildschirmauflîsung an
*/

void	FixImages( OBJECT *tree, int num )
{
	int		i, j;
	int		h, w;
	OBSPEC	os;

	for ( i = 0; i < num; i++, tree++ )
	{
		switch ( tree->ob_type & 0xff )
		{
			case G_ICON : os = tree->ob_spec;
						w = os.iconblk->ib_wicon >> 3;
						h = os.iconblk->ib_hicon;
						if ( hchar == 8 )
						{
							h = ( os.iconblk->ib_hicon >>= 1 );
							for ( j = 1; j < h; j++ )
							{
								memcpy( os.iconblk->ib_pdata + (j * w >>1),
										os.iconblk->ib_pdata + (j * w),
										w );
								memcpy( os.iconblk->ib_pmask + (j * w >>1),
										os.iconblk->ib_pmask + (j * w),
										w );
							}
							os.iconblk->ib_ytext >>= 1;
							os.iconblk->ib_ychar >>= 1;
						}
						TransMFDB( os.iconblk->ib_pmask, w,
								   os.iconblk->ib_pmask, w, h );
						TransMFDB( os.iconblk->ib_pdata, w,
								   os.iconblk->ib_pdata, w, h );
						break;
			case G_IMAGE : os = tree->ob_spec;
						w = os.bitblk->bi_wb;
						h = os.bitblk->bi_hl;
						if ( hchar == 8 )
						{
							h = ( os.bitblk->bi_hl >>= 1 );
							for ( j = 1; j < h; j++ )
								memcpy( os.bitblk->bi_pdata + (j * w >>1),
										os.bitblk->bi_pdata + (j * w),
										w );
						}
						TransMFDB( os.bitblk->bi_pdata, w,
								   os.bitblk->bi_pdata, w, h );
			default	:	break;
		}
	}
}

#pragma warn -par

void	_RedrawWinObj( GRECT *gr, int winhdl )
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

void	RedrawWinObj( WINDIA *wd, int obj, int winhdl )
{
	tempWD = wd;
	tempObj = obj;

	if ( obj < 0 )
		obj = wd->edobj;

	RedrawWin( ObGRECT(wd->tree), winhdl, _RedrawWinObj );
}

/*
*	rc_intersect()
*
*	Ermittelt den gemeinsamen Bereich zweier Rechtecke
*/

int		rc_intersect( const GRECT *r1, GRECT *r2 )
{
	int		x, y, w, h;

	x = Max( r2->g_x, r1->g_x );
	y = Max( r2->g_y, r1->g_y );
	w = Min( r2->g_x + r2->g_w, r1->g_x + r1->g_w );
	h = Min( r2->g_y + r2->g_h, r1->g_y + r1->g_h );

	r2->g_x = x;
	r2->g_y = y;
	r2->g_w = w - x;
	r2->g_h = h - y;

	return ( ((w > x) && (h > y) ) );
}

/*
*	PosSlider()
*
*	Die Position des Sliders wird anhand 'new_pos' berechnet, und in den
*	Objektbaum eingetragen.
*/

int		PosSlider( OBJECT *tree, SLIDERBLK *sl, int new_pos )
{
	int		num;
	int		l;
	long	ln;
	int		flag;

	if ( new_pos > sl->max )
		new_pos = sl->max;
	if ( new_pos < sl->min )
		new_pos = sl->min;

	if ( new_pos == sl->pos )
		return ( 0 );

	sl->pos = new_pos;

	num = ( sl->max - sl->min ) / sl->step;

	tree += sl->slider;
	flag = ( tree[SL_BOX].ob_width > tree[SL_BOX].ob_height );

	if ( flag )
		l = tree[SL_BOX].ob_width;
	else
		l = tree[SL_BOX].ob_height;

	l /= num;

	if ( l < 16 )
		l = 16;

	if ( flag )
		tree[SL_SLIDER].ob_width = l;
	else
		tree[SL_SLIDER].ob_height = l;

	new_pos -= sl->min;
	new_pos /= sl->step;

	ln = (long)( tree[SL_BOX].ob_width - l - 1) * (long) new_pos;
	ln /= num;
	if ( flag )
		tree[SL_SLIDER].ob_x = (int) ln;
	else
		tree[SL_SLIDER].ob_y = (int) ln;
	return ( 1 );
}

/*
*	SliderToPos()
*
*	Anhand der Position des Slider-Objektes wird ein entsprechender
*	Wert zurÅckgeliefert
*/

int		SliderToPos( OBJECT *tree, SLIDERBLK *sl )
{
	long	off;
	OBJECT	*ob = tree + sl->slider;

	off = (long) ( ( sl->max - sl->min ) / sl->step );

	if ( ob[SL_BOX].ob_width > ob[SL_BOX].ob_height )
	{
		off *= (long) ob[SL_SLIDER].ob_x;
		off /= (long) (ob[SL_BOX].ob_width - ob[SL_SLIDER].ob_width );
	}
	else
	{
		off *= (long) ob[SL_SLIDER].ob_y;
		off /= (long) (ob[SL_BOX].ob_height - ob[SL_SLIDER].ob_height );
	}
	return ( PosSlider( tree, sl, (int) off ) );
}

/*
*	SliderPage()
*
*	Anhand der Slider-Grîûe und dessen Begrenzungsobjekt wird ein Wert
*	zurÅckgegeben der einer Seite entspricht.
*/

int		SliderPage( OBJECT *tree, SLIDERBLK *sl )
{
	int		off;

	tree += sl->slider;

	if ( tree[SL_BOX].ob_width > tree[SL_BOX].ob_height )
		off = tree[SL_BOX].ob_width  /
				 tree[SL_SLIDER].ob_width;
	else
		off = tree[SL_BOX].ob_height /
				 tree[SL_SLIDER].ob_height;

	off = ((sl->max - sl->min) / sl->step) / off;

	return ( off );
}

/*
*	SliderToEdTexxt()
*
*	Die aktuelle Sliderposition wird in einen EdText eingetragen, und
*	das Edobjekt wird neu gezeichnet.
*/

void	SliderToEdText( WINDIA *wd, int edobj, int pos, int window )
{
	itoa( pos, wd->tree[edobj].ob_spec.tedinfo->te_ptext, 10 );
	if ( wd->edobj == edobj )
	{
		RedrawWinObj( wd, -1, window );
		InitEdObj( wd, wd->tree, wd->edobj );
	}
	RedrawWinObj( wd, edobj, window );
}

/*
*	EdTextToSlider()
*
*	Anhand eines EdTextes wird der Slider neu positioniert und gezeichnet
*/

void	EdTextToSlider( WINDIA *wd, int edobj, SLIDERBLK *sl, int window )
{
	int		pos;

	pos = atoi( wd->tree[edobj].ob_spec.tedinfo->te_ptext );
	if ( PosSlider( wd->tree, sl, pos ) )
		RedrawWinObj( wd, sl->slider + SL_BOX, window );
}

/*
*	HdlSlider()
*
*	Verschiebt den Slider wenn die Maustaste gedrÅckt ist
*/

int	HdlSlider( OBJECT *tree, SLIDERBLK *sl, int obj )
{
	int		x, y, mstate;
	int		ox, oy;
	OBJECT	*ob;

	obj -= sl->slider;

	if ( obj == SL_UP )
		return ( PosSlider( tree, sl, sl->pos - sl->step ) );
	else if ( obj == SL_DOWN )
		return ( PosSlider( tree, sl, sl->pos + sl->step ) );
	else
	{
		graf_mkstate( &x, &y, &mstate, &obj );
		obj = sl->slider;
		objc_offset( tree, obj + SL_BOX, &ox, &oy );
		ob = tree + obj;
		if ( x >= ox + ob[SL_SLIDER].ob_x &&
			 y >= oy + ob[SL_SLIDER].ob_y &&
			 x < ox + ob[SL_SLIDER].ob_x + ob[SL_SLIDER].ob_width &&
			 y < oy + ob[SL_SLIDER].ob_y + ob[SL_SLIDER].ob_height )
		{
			if ( !(mstate & 1 ) )
				return ( 0 );
			graf_dragbox( ob[SL_SLIDER].ob_width,
						  ob[SL_SLIDER].ob_height,
						  ox + ob[SL_SLIDER].ob_x,
						  oy + ob[SL_SLIDER].ob_y,
						  ox, oy,
						  ob[SL_BOX].ob_width,
						  ob[SL_BOX].ob_height,
						  &ob[SL_SLIDER].ob_x,
						  &ob[SL_SLIDER].ob_y );
			ob[SL_SLIDER].ob_x -= ox;
			ob[SL_SLIDER].ob_y -= oy;
			return ( SliderToPos( tree, sl ) );
		}
		else if ( x >= ox && y >= oy &&
			 x < ox + ob[SL_BOX].ob_width &&
			 y < oy + ob[SL_BOX].ob_height )

		{
			obj = SliderPage( tree, sl );
			if ( ob[SL_BOX].ob_width > ob[SL_BOX].ob_height )
				if ( x < ox + ob[SL_SLIDER].ob_x )
					return PosSlider( tree, sl, sl->pos - obj );
				else
					return PosSlider( tree, sl, sl->pos + obj );
			else
				if ( y < oy + ob[SL_SLIDER].ob_y )
					return PosSlider( tree, sl, sl->pos - obj );
				else
					return PosSlider( tree, sl, sl->pos + obj );
		}
		else
			return ( 0 );
	}
}

/*
*	RedrawWin()
*
*	öbernimmt das Neuzeichnen eines Fensters bei einem WM_REDRAW
*	(Rechtecklisten)
*/

void	RedrawWin( const GRECT *gr, int hdl, void (*Redraw)( GRECT *gr, int hdl ) )
{
	GRECT	box;
	GRECT	dsk = desk;

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

void	MoveObjWin( GRECT *gr, WINDIA *wd, int window, int kind )
{
	GRECT	temp;
	OBJECT	*tr = wd->tree;

	WindCalc( WC_WORK, kind, gr, gr );

	gr->g_x -= gr->g_x % 8;
	tr->ob_x = gr->g_x;
	tr->ob_y = gr->g_y;

	InitCurPos( wd );
	WindCalc( WC_BORDER, kind, gr, &temp );

	WindSet( window, WF_CURRXYWH, &temp );

}

/*
*	CreateWin()
*
*	Erzeugt ein Fenster
*/

int		CreateWin( int kind )
{
	GRECT	gr;
	int		hdl;

	WindGet( 0, WF_CURRXYWH, &gr );

	hdl = wind_create( kind, gr.g_x, gr.g_y, gr.g_w, gr.g_h );

	return ( hdl );
}

/*
*	OpenObjWin()
*
*	Erzeugt ein Fenter um einen Objektbaum
*/

int		OpenObjWin( OBJECT *tr, int kind, int hdl )
{
	GRECT	gr;
	int		ret;

	if ( tr->ob_x == 0 )
		FormCenter( tr );
	tr->ob_x -= tr->ob_x % 8;

	ret = WindCalc( WC_BORDER, kind, ObGRECT(tr), &gr );

	if ( ret )
		if ( gr.g_w < tr->ob_width || gr.g_h < tr->ob_height )
			ret = 0;
	
	if ( ret )
		wind_open( hdl, gr.g_x, gr.g_y, gr.g_w, gr.g_h );
	return ( ret );
}

/*
*	ScanTree()
*
*	Durchsucht einen Objektbaum hyrarchisch
*	wird solange ausgefÅhrt bis fct() != 0
*
*	RÅckgabewert :	fct()
*/

int		ScanTree( OBJECT *tree, int obj, TPBLK *tp, sub_fct *fct )
{
	int		next;
	int		ret;

	tp->x += tree[obj].ob_x;
	tp->y += tree[obj].ob_y;

	ret = fct( tree, obj, tp );

	if ( ret )
		return ( ret );

	if ( ( next = tree[obj].ob_head ) != -1 )
		do
			if ( !IsHidden(tree+next) )
			{
				ret = ScanTree( tree, next, tp, fct );
				if ( ret )
					return ( ret );
			}
		while ( ( next = tree[next].ob_next ) != obj );

	tp->x -= tree[obj].ob_x;
	tp->y -= tree[obj].ob_y;

	return ( ret );
}


/*
*	SaveScreen()
*
*	Sichert einen Bildschirmausschnitt
*/

int		SaveScreen( const GRECT *gr, int frame, void **buffer, long *len )
{
	MFDB		scrn;
	MFDB		*sav;
	int			*pxy;
	long		l;
	int			off,
				x = gr->g_x, y = gr->g_y,
				rw = gr->g_h,
				co = gr->g_w;

	x -= frame;		y -= frame;
	frame <<= 1;
	rw += frame;	co += frame;

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

	if ( !*buffer )
	{
		*len = l;
		*buffer = malloc( l );
		if ( !*buffer )
			return ( 1 );
	}
	else
		if ( *len < l )
			return ( 1 );

	sav = *buffer;
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
	vro_cpyfm( vdiHdl, S_ONLY, pxy, &scrn, sav );
	MouseOn();
	return ( 0 );
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
	vro_cpyfm( vdiHdl, S_ONLY, pxy, sav, &scrn );
	MouseOn();
}

#pragma warn -par

static	int		_IsInParent( OBJECT *tree, int obj, TPBLK *tp )
{
	if ( obj == tp->cmp )
		return ( 1 );
	else
		return ( 0 );
}

#pragma warn .par

/*
*	IsParent()
*
*	Ermittelt den Vater eines Objekts
*/

int		IsInParent( OBJECT *tree, int parent, int obj )
{
	TPBLK	tp;

	tp.cmp = obj;

	return ( ScanTree( tree, parent, &tp, _IsInParent ) );
}

static	int _NextEditable( OBJECT *tree, int obj, TPBLK *tp )
{
	if ( IsEditable(tree+obj) && tp->cmp < obj && tp->obj > obj )
		tp->obj = obj;
	return ( 0 );
}

/*
*	NextEditable()
*
*	liefert das nÑchste editierbare Objekt >= obj
*/

int		NextEditable( OBJECT *tree, int obj )
{
	TPBLK	tp;

	tp.cmp = obj;
	tp.obj = INT_MAX;

	ScanTree( tree, 0, &tp, _NextEditable );

	if ( tp.obj == INT_MAX )
		return ( obj );
	else
		return ( tp.obj );
}

static	int	_LastEditable( OBJECT *tree, int obj, TPBLK *tp )
{
	if ( IsEditable(tree+obj) && tp->cmp > obj && tp->obj < obj )
		tp->obj = obj;
	return ( 0 );
}

/*
*	LastEditable()
*
*	liefert das vorherige editierbare Objekt <= obj
*/

int		LastEditable( OBJECT *tree, int obj )
{
	TPBLK	tp;

	tp.cmp = obj;
	tp.obj = INT_MIN;		

	ScanTree( tree, 0, &tp, _LastEditable );

	if ( tp.obj == INT_MIN )
		return ( obj );
	else
		return ( tp.obj );
}


/*
*	IsFirstUpper()
*
*	1 : erster Groûbuchstabe == key
*	0 : erster Groûbuchstabe != key
*/

static	int		IsFirstUpper( const char *str, int key )
{
	int		c;

	while ( ( c = *str++ ) != '\0' )
		if ( isupper( c ) )
			if ( c == key )
				return ( 1 );
			else
				return ( 0 );
	return ( 0 );
}


/* Warnung: 'Parameter XXXX never used' ausschalten */

#pragma warn -par

static	int	_RightString( OBJECT *tree, int obj, TPBLK *tp )
{
	if ( Abs( tp->y - tp->ty ) <= 4 && tp->x > tp->tx )
		if ( tp->cmp == -1 || tp->x < tp->tx )
			tp->cmp = obj;
	return ( 0 );
}

/* Warnung: 'Parameter XXXX never used' zurÅcksetzen */

#pragma warn .par

/*
*	RightString()
*
*	sucht rechts neben einem Objekt ein Objekt des Typs 'G_STRING'
*/

int		RightString( OBJECT *tree, int obj )
{
	TPBLK	tp;

	tp.cmp = -1;
	tp.x = tp.y = 0;
	objc_offset( tree, obj, &tp.tx, &tp.ty );

	ScanTree( tree, 0, &tp, _RightString );

	if ( tp.cmp != -1 &&
		 ( tree[tp.cmp].ob_type & 0xff ) == G_STRING )
		return ( tp.cmp );
	else
		return ( -1 );
}

static	int	_GetButton( OBJECT *tree, int obj, TPBLK *tp )
{
	int temp;

	if ( IsSelectable(tree+obj) )
	{
		switch ( tree[obj].ob_type & 0xff )
		{
			case G_BUTTON :
			case G_STRING :

				if ( IsFirstUpper( ObString(tree+obj), tp->cmp ) )
					if ( tp->obj < 0 )
						tp->obj = obj;
					else
						return ( -1 );
				break;
			case G_BOXCHAR	:
				if ( toupper( tree[obj].ob_spec.obspec.character ) ==
					 tp->cmp )
				{
					if ( tp->obj < 0 )
						tp->obj = obj;
					else
						return ( -1 );
				}
			case G_BOX		:
			case G_IBOX		:
			case G_USERDEF	:

				temp = RightString( tree, obj );
				if ( temp >= 0 &&
					 IsFirstUpper( ObString(tree+temp), tp->cmp ) )
					if ( tp->obj < 0 )
						tp->obj = obj;
					else
						return ( -1 );
				break;
			default		  :	break;
		}
	}
	return ( 0 );
}

/*
*	GetButton()
*
*	ermittelt ein selektierbares Objekt, dessen erster Groûbuchstabe
*	'key' entspricht
*	PrÅft auf Eindeutigkeit: Existieren mehrere Objekte, wird -1
*	                         zurÅckgegeben
*	-1 falls nicht gefunden
*/

static	int		GetButton( OBJECT *tree, int key )
{
	TPBLK	tp;

	tp.obj = -1;
	tp.cmp = key;

	if ( ScanTree( tree, 0, &tp, _GetButton ) )
		return ( -1 );
	else
		return ( tp.obj );
}

/*
*	KeyToUpper()
*
*	liefert anhand des Scancodes den Ascii-Wert als Groûbuchstabe
*/

int		KeyToUpper( int key )
{
	static	char	*shift = NULL;

#define		NIX		((void *) -1L)

	if ( !shift )
		shift = Keytbl( NIX, NIX, NIX )->capslock;

	return ( (int) shift[((unsigned int) key) >> 8] );
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

	vswr_mode( vdiHdl, 3 );
	vsf_interior( vdiHdl, 1 );

	MouseOff();
	vr_recfl( vdiHdl, pxy );
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

void	ChangeEdField( WINDIA *wd, int new, int window )
{
	if ( wd->edobj >= 0 )
		RedrawWinObj( wd, -1, window );

	InitEdObj( wd, wd->tree, new );
	RedrawWinObj( wd, -1, window );
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

void	_RedrawEdObj( GRECT *gr, int hdl )
{
	if ( !tedCol.trans )
	{
		ObjcDraw( tempWD->tree, tempWD->edobj, 8, gr );
	}
	else
	{
		vsf_color( vdiHdl, tedCol.inter );
		vsf_style( vdiHdl, tedCol.patt );
		vswr_mode( vdiHdl, 1 );

		v_gtext( vdiHdl, tempWD->x, tempWD->y, edText );
	}
	CursorChg( tempWD );
}

#pragma warn .par

/*
*	RedrawEdObj()
*
*	Zeichnet den Text und Cursor eines EdObjekts
*/

void	RedrawEdObj( WINDIA *wd, int winhdl )
{
	OBJECT	*tr = wd->tree + wd->edobj;
	char	*tmp = tr->ob_spec.tedinfo->te_ptmplt;
	char	*text = tr->ob_spec.tedinfo->te_ptext;
	char	*txt = edText;
	char	c;
	TEDCOL	tc = *(TEDCOL *) &(tr->ob_spec.tedinfo->te_color);
	int		d;

	tedCol= tc;
	vst_color( vdiHdl, tc.tecol );
	vst_effects( vdiHdl, 0 );
	vst_alignment( vdiHdl, 0, 5, &d, &d );

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
	
	RedrawWin( &desk, winhdl, _RedrawEdObj );
}
	

/*
*	ObjcInsChar()
*
*	FÅgt einen Buchstaben in einen EdText ein
*/

int		ObjcInsChar( WINDIA *wd, int key, int window )
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
						RedrawWinObj( wd, -1, window );
						wd->pos = 0;
						break;
		case BACKSPACE:	if ( i )
						{
							i--;
							RedrawWinObj( wd, -1, window );
							wd->pos = i;
							goto Delete;
						}
						else
							return ( 0 );
		case DELETE:	RedrawWinObj( wd, -1, window );
	Delete:
						txt += i;
						tmplt = txt + 1;
						if ( *txt )
							while ( ( *txt++ = *tmplt++ ) != 0 );
						break;
		case C_LEFT:	if ( i )
						{
							RedrawWinObj( wd, -1, window );
							wd->pos--;
							RedrawWinObj( wd, -1, window );
						}
						return ( 0 );
		case C_RIGHT:	if ( txt[i] && i < ted->te_txtlen - 2 )
						{
							RedrawWinObj( wd, -1, window );
							wd->pos++;
							RedrawWinObj( wd, -1, window );
						}
						return ( 0 );
		case SHFT_CL:	RedrawWinObj( wd, -1, window );
						wd->pos = 0;
						RedrawWinObj( wd, -1, window );
						return ( 0 );
		case SHFT_CR:	RedrawWinObj( wd, -1, window );
						while ( txt[i] )
							i++;
						if ( i >= ted->te_txtlen - 1 )
							i--;
						wd->pos = i;
						RedrawWinObj( wd, -1, window );
						return ( 0 );
		default		:	RedrawWinObj( wd, -1, window );
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
								RedrawWinObj( wd, wd->edobj, window );
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
	RedrawEdObj( wd, window );
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

static	void	GetHist( WINDIA *wd, char *(*fct)(char *), int window )
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
			RedrawWinObj( wd, -1, window );
			strcpy( ted->te_ptext, text );
			InitEdObj( wd, wd->tree, obj );
			RedrawWinObj( wd, obj, window );
		}
	}
}

/*
*	DialButton()
*
*	Behandelt ein Maus-Event in einer Dialogbox
*/

int		DialButton( WINDIA *wd, int x, int y, int clicks, int window )
{
	int		obj = objc_find( wd->tree, 0, 8, x, y );

	MouseOff();
	if ( obj >= 0 )
	{
		if ( !form_button( wd->tree, obj, clicks, &obj ) )
		{
			if ( clicks == 2 )
				obj |= 0x8000;
			AddAllToHist( wd->tree );
			MouseOn();
			return ( obj );
		}
		else if ( wd->edobj > 0 && wd->edobj != obj &&
				  IsEditable(wd->tree+obj) )
			ChangeEdField( wd, obj, window );
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

int		DialKeybd( WINDIA *wd, int key, int kstate, int window )
{
	OBJECT	*tree = wd->tree;
	int		obj;
	int		dummy;

	MouseOff();
	switch ( key )
	{
		case HOME	:
			ChangeEdField(wd, NextEditable(tree, -1), window);
			break;
		case SHFT_HOME:
			ChangeEdField(wd, LastEditable(tree, INT_MAX), window);
			break;
		case C_UP | '8':
			GetHist( wd, LastHist, window );
			break;
		case C_DOWN | '2':
			GetHist( wd, NextHist, window );
			break;
		default	:

		if ( !form_keybd( tree, wd->edobj,
						  wd->edobj,
						  key, &obj, &key ) )
		{
			AddAllToHist( tree );
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
				ObjcInsChar( wd, key, window );
				break;
		default:

			if ( !(kstate & K_ALT) && wd->edobj > 0 )
			{
				if ( obj != wd->edobj )
					ChangeEdField(wd, obj, window);
				else if ( key )
					ObjcInsChar( wd, key, window );
			}
			else if ( key )
			{
				key = KeyToUpper( key );
				obj = GetButton( tree, key );
				if ( obj >= 0 )
					if ( !form_button( tree, obj, 1, &dummy ) )
					{
						AddAllToHist( tree );
						MouseOn();
						return ( obj );
					}
			}
		break;
		}
		break;
	} /* switch ( key ) */
	MouseOn();
	return ( 0 );
}
