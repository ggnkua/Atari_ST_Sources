/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 2/92  <<<<<<<<<<<<<		*/
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
/*		System/Compiler	:	Atari ST/TT, TOS 1.4, Pure C				*/
/*																		*/
/*		Last Update		:	16.12.91 (JL)								*/
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


static	long	cokname;			/* fÅr Ermittlung der Cookies */

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
		appl_exit();
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

/*
*	FormDial()
*
*	entspricht form_dial()
*/

void	FormDial( int flag, GRECT *ltl, GRECT *big )
{
	GRECT	temp;

	if ( !big )
		big = &desk;

	if ( !ltl )
	{
		ltl = &temp;
		ltl->g_x = big->g_x + ( big->g_w >> 1 );
		ltl->g_y = big->g_y + ( big->g_h >> 1 );
		*(long *)&ltl->g_w = 0L;
	}
	form_dial( flag, ltl->g_x, ltl->g_y, ltl->g_w, ltl->g_h,
					 big->g_x, big->g_y, big->g_w, big->g_h );
}

int		ObjcDraw( OBJECT *tree, int start, int depth, const GRECT *g )
{
	return	objc_draw( tree, start, depth, g->g_x, g->g_y,
					   g->g_w, g->g_h );
}

/*
*	AbsObj()
*
*	schreibt die absoluten Koordinaten in eine GRECT-Struktur
*/

void	AbsObj( OBJECT *tree, int obj, GRECT *abs )
{
	*(long *) &abs->g_w = *(long *) &tree[obj].ob_width;

	objc_offset( tree, obj, &abs->g_x, &abs->g_y );
}

/*
*	RelObj()
*
*	Positioniert ein Objekt in dem Objektbaum
*/

void	RelObj( OBJECT *tree, int obj, const GRECT *abs )
{
	int		x, y;

	objc_offset( tree, obj, &x, &y );

	tree[obj].ob_x += abs->g_x - x;
	tree[obj].ob_y += abs->g_y - y;
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
		gr = &desk;
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
*	rc_constrain()
*
*	positioniert r2 so, daû es ganz in r1 liegt.
*	RÅckgabe 1, wenn irgend etwas geÑndert wurde.
*/

int		rc_constrain( const GRECT *r1, GRECT *r2 )
{
	int		off;
	int		flag = 0;

	if ( r2->g_x < r1->g_x )
	{
		r2->g_x = r1->g_x;
		flag = 1;
	}
	else if ( ( off = r1->g_x + r1->g_w - r2->g_x - r2->g_w ) < 0 )
	{
		r2->g_x += off;
		flag = 1;
	}

	if ( r2->g_y < r1->g_y )
	{
		r2->g_y = r1->g_y;
		flag = 1;
	}
	else if ( ( off = r1->g_y + r1->g_h - r2->g_y - r2->g_h ) < 0 )
	{
		r2->g_y += off;
		flag = 1;
	}
	return ( flag );
}

/*
*	rc_merge()
*
*	liefert den kleinsten gemeinsamen Bereich von zwei Rechtecken
*/

void	rc_merge( const GRECT *r1, GRECT *r2 )
{
	int		x, y, w, h;

	x = Min( r2->g_x, r1->g_x );
	y = Min( r2->g_y, r1->g_y );
	w = Max( r2->g_x + r2->g_w, r1->g_x + r1->g_w );
	h = Max( r2->g_y + r2->g_h, r1->g_y + r1->g_h );

	r2->g_x = x;
	r2->g_y = y;
	r2->g_w = w - x;
	r2->g_h = h - y;
}

/*
*	rc_frame()
*
*	vergrîûert oder verkleinert ein Rechteck
*/

void	rc_frame( GRECT *r, int frame )
{
	r->g_x -= frame;
	r->g_y -= frame;
	frame += frame;
	r->g_w += frame;
	r->g_h += frame;
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

/*
*	HdlSlider()
*
*	verwaltet einen Klick auf ein Slider-Objekt
*	Diese Hauptfunktion steuert alle weiteren Funktionen
*/

int	HdlSlider( WINDIA *wd, SLIDERBLK *sl, int obj )
{
	int		x, y, mstate, slobj = sl->slider;
	int		ox, oy, hx, hy;
	OBJECT	*tree = wd->tree;
	OBJECT	*ob;
	int		dummy;
	GRECT	box, slider, temp;
	int		flag;

	if ( obj - slobj == SL_UP )
	{
		if ( SlSetAbsPos( tree, sl, sl->pos - 1 ) )
		{
			sl->sl_handle( tree, sl );
			RedrawWinObj( wd, sl->slider + SL_BOX, NULL );
			return ( 1 );
		}
		return ( 0 );
	}
	if ( obj - slobj == SL_DOWN )
	{
		if ( SlSetAbsPos( tree, sl, sl->pos + 1 ) )
		{
			sl->sl_handle( tree, sl );
			RedrawWinObj( wd, sl->slider + SL_BOX, NULL );
			return ( 1 );
		}
		return ( 0 );
	}
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
				if ( SlSetAbsPos( tree, sl, sl->pos - obj ) )
				{
					sl->sl_handle( tree, sl );
					RedrawWinObj( wd, sl->slider + SL_BOX, NULL );
					return ( 1 );
				}
				else
					return ( 0 );
			else
				if ( SlSetAbsPos( tree, sl, sl->pos + obj ) )
				{
					sl->sl_handle( tree, sl );
					RedrawWinObj( wd, sl->slider + SL_BOX, NULL );
					return ( 1 );
				}
				else
					return ( 0 );
		else
			if ( y < slider.g_y )
				if ( SlSetAbsPos( tree, sl, sl->pos - obj ) )
				{
					sl->sl_handle( tree, sl );
					RedrawWinObj( wd, sl->slider + SL_BOX, NULL );
					return ( 1 );
				}
				else
					return ( 0 );
			else
				if ( SlSetAbsPos( tree, sl, sl->pos + obj ) )
				{
					sl->sl_handle( tree, sl );
					RedrawWinObj( wd, sl->slider + SL_BOX, NULL );
					return ( 1 );
				}
				else
					return ( 0 );
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

/*
*	ObjcParent()
*
*	Liefert das Vater/Mutter-Objekt
*/

int		ObjcParent( OBJECT *tr, int obj )
{
	int		i = obj;
	int		t;

	while ( ( i = tr[i].ob_next ) > 0 )
	{
		if ( ( t = tr[i].ob_head ) >= 0 )
		{
			do
			{
				if ( t == obj )
					return ( i );
				if ( ( t = tr[t].ob_next ) <= 0 )
					return ( 0 );
			} while ( t != i );
		}
	}
	return ( 0 );
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

void	_RedrawEdObj( const GRECT *gr, int hdl )
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

	RedrawWin( &desk, wd->window, _RedrawEdObj );
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
*	DialButton()
*
*	Behandelt ein Maus-Event in einer Dialogbox
*/

int		DialButton( WINDIA *wd, int x, int y, int clicks )
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
	OBJECT	*tree = wd->tree;
	int		obj;
	int		dummy;

	MouseOff();
	switch ( key )
	{
		case HOME	:
			ChangeEdField(wd, NextEditable(tree, -1) );
			break;
		case SHFT_HOME:
			ChangeEdField(wd, LastEditable(tree, INT_MAX) );
			break;
		case C_UP | '8':
			GetHist( wd, LastHist );
			break;
		case C_DOWN | '2':
			GetHist( wd, NextHist );
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
