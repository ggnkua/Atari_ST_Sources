/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 3/92  <<<<<<<<<<<<<		*/
/*																		*/
/*																		*/
/*		P R O J E C T	:	TOS ACCESSORY Spezial						*/
/*							TOSACC.ACC									*/
/*																		*/
/*		M O D U L E		:	LOWGEM.C									*/
/*							Low level GEM-Tools							*/
/*																		*/
/*		Author			:	Jrgen Lietzow fr TOS-Magazin				*/
/*																		*/
/*		System/Compiler	:	Atari ST/TT, TOS 1.4, Pure C				*/
/*																		*/
/*		Last Update		:	31.01.92 (JL)								*/
/*																		*/
/*																		*/
/************************************************************************/

#include <limits.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>

#define	__LOWGEM

#include	"tgemlib.h"

/*
*	Diese low level GEM-Funktionen ben”tigen keinerlei Initialisierung
*	Also kein globales VDI-Handle oder die Koordinaten des Desktops,
*	und sie sind weitestgehend unabh„ngig voneinander
*	Aužerdem initialisieren sie selber keinerlei globale Variablen.
*/

/*
*	Folgende Funktionen rufen direkt die entsprechenden GEM-Funktionen
*	auf. Allerdings ist die Parameterbergabe der neuen Funktionen
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
		big = &gemv.work;

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

/********************************************************************/

int		set_hchar( int vhdl, int hc )
{
	int		i = hc;
	int		d;
	int		h;
	
	do
	{
		vst_height( vhdl, i--, &d, &d, &d, &h );
	} while ( h > hc );

	return ( h );
}
	
void	line_default( int vhdl )
{
	vsl_width( vhdl, 1 );
	vswr_mode( vhdl, MD_REPLACE );
	vsl_ends( vhdl, SQUARED, SQUARED );
	vsl_type( vhdl, SOLID );
	vsl_color( vhdl, BLACK );
}

void	text_default( int vhdl,int hchar )
{
	int	d;
	
	vst_font( vhdl, 1 );
	vswr_mode( vhdl, MD_REPLACE );
	vst_effects( vhdl, TXT_NORMAL );
	vst_color( vhdl, BLACK );
	set_hchar( vhdl, hchar );
	vst_alignment( vhdl, ALI_LEFT, ALI_TOP, &d, &d );
	vst_rotation( vhdl, 0 );
}

void	DrawFrame( GRECT *fr, int frame, int vhdl )
{
	int		off;
	long	temp;
	int		w, h;
	int		pxy[10];
	
	if ( frame < 0 )
		off = 1;
	else
		off = -1;

	temp = *(long *) fr;
	w = fr->g_w - 1;
	h = fr->g_h - 1;
	
	while ( frame )
	{
		*(long *) &pxy[0] = temp;
		*(long *) &pxy[2] = temp;
		*(long *) &pxy[4] = temp;
		*(long *) &pxy[6] = temp;

		pxy[0] -= frame;
		pxy[1] -= frame;
		pxy[2] += w + frame;
		pxy[3] -= frame;
		pxy[4] += w + frame;
		pxy[5] += h + frame;
		pxy[6] -= frame;
		pxy[7] += h + frame;
		*(long *) &pxy[8] = *(long *) &pxy[0];

		v_pline( vhdl, 5, pxy );
		frame += off;
	}
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
*	Bei WindSet() und WindGet() drfen nur die 'types' bergeben werden
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
*	Diese Event-Funktion unterdrckt UNENDLICH LANGE
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


void	InitFileSpec( FILE_SPEC *fs, char *path, char *name, char *spec )
{
	char	*ptr;
	
	if ( !path || !*path )
	{
		ptr = fs->path;
		*ptr++ = Dgetdrv() + 'A';
		*ptr++ = ':';
		Dgetpath( ptr, 0 );
	}
	if ( !name )
		fs->fname[0] = '\0';
	else
		strcpy( fs->fname, name );
	
	if ( !spec || !*spec )
		strcpy( fs->fspec, "*.*" );
	else
		strcpy( fs->fspec, spec );
}
		
int	FselInput( FILE_SPEC *fs, char *mes )
{
	char	path[128];
	char	name[14];
	char	*ptr;
	int		ret;
	int		but;
	DTA		dta;
	DTA		*dta_ptr;

	strcpy( path, fs->path );
	ptr = strrchr( path, '\\' );
	if ( ptr && !ptr[1] )
		*ptr = '\0';
	strcat( path, "\\" );
	ptr = strrchr( path, '\\' ) + 1;
	strcpy( ptr, "*.*" );
	dta_ptr = Fgetdta();
	Fsetdta( &dta );
									/* prfe ob Pfad existiert */
	if ( Fsfirst( path, 16 ) )
	{
		InitFileSpec( fs, NULL, fs->fname, NULL );
		strcpy( path, fs->path );
		ptr = strrchr( path, '\\' );
		if ( ptr && !ptr[1] )
			*ptr = '\0';
		strcat( path, "\\" );
		strcat( path, fs->fspec );
	}
	else
		strcpy( ptr, fs->fspec );

	strcpy( name, fs->fname );
	if ( _GemParBlk.global[0] < 0x0140 || !mes )
		ret = fsel_input( path, name, &but );
	else
		ret = fsel_exinput( path, name, &but, mes );

	Fsetdta( dta_ptr );
	
	if ( ret )
		ret = -1;
	ret &= but;
		
	if ( ret )
	{
		strcpy( fs->fname, name );
		strcpy( fs->path, path );
		ptr = strrchr( fs->path, '\\' );
		if ( ptr++ && *ptr )
		{
			strcpy( fs->fspec, ptr );
			*ptr = '\0';
		}
	}
	return ( ret );
}

/*
*	StrnCpy()
*
*	kopiert len Zeichen und schliežt immer mit '\0' ab
*/

char	*StrnCpy( char *dest, const char *src, size_t len )
{
	dest[len] = '\0';
	return ( strncpy( dest, src, len ) );
}


/*
*	FixImages()
*
*	Pažt G_ICON und G_IMAGE an die aktuelle Bildschirmaufl”sung an
*/

void	FixImages( OBJECT *tree, int num )
{
	int		i, j;
	int		h, w;
	OBSPEC	os;

	if ( num <= 0 )
	{
		for ( i = 0; ; i++ )
			if ( tree[i].ob_flags & LASTOB )
			{
				num = i + 1;
				break;
			}
	}

	for ( i = 0; i < num; i++, tree++ )
	{
		switch ( tree->ob_type & 0xff )
		{
			case G_ICON : os = tree->ob_spec;
						w = os.iconblk->ib_wicon >> 3;
						h = os.iconblk->ib_hicon;
						if ( gemv.hchar == 8 )
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
						if ( gemv.hchar == 8 )
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

/*
*	FixTree()
*
*	G_ICON und G_IMAGES an die Aul”sung anpassen, und Zeichen-Koordinaten
*	in Pixel-koordinaten wandeln
*/

void	FixTree( OBJECT *tree )
{
	int		i = 0;

	do
	{
		rsrc_obfix( tree, i );
		FixImages( &tree[i], 1 );
		i++;
	} while ( !( tree[i-1].ob_flags & LASTOB ) );
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
*	positioniert r2 so, daž es ganz in r1 liegt. Wenn r2 gr”žer als
*	r1 ist, wird r2 an die Gr”že von r1 angepažt.
*	Rckgabe: 1 bei neuer Positionierung
*			  2 bei Gr”ženanpassung
*/

int		rc_constrain( const GRECT *r1, GRECT *r2 )
{
	int		off;
	int		flag = 0;

	if ( r2->g_x < r1->g_x )
	{
		r2->g_x = r1->g_x;		flag |= 1;
	}
	if ( ( off = r2->g_x + r2->g_w - r1->g_x - r1->g_w  ) > 0 )
	{
		if ( r2->g_x - r1->g_x < off )
		{
			r2->g_x = r1->g_x;	r2->g_w = r1->g_w;		flag |= 3;
		}
		else
		{	
			r2->g_x -= off;		flag |= 1;
		}
	}
	if ( r2->g_y < r1->g_y )
	{
		r2->g_y = r1->g_y;		flag |= 1;
	}
	if ( ( off = r2->g_y + r2->g_h - r1->g_y - r1->g_h  ) > 0 )
	{
		if ( r2->g_y - r1->g_y < off )
		{
			r2->g_y = r1->g_y;	r2->g_h = r1->g_h;		flag |= 3;
		}
		else
		{	
			r2->g_y -= off;		flag |= 1;
		}
	}
	return ( flag );
}

/*
*	rc_merge()
*
*	liefert ein Rechteck, in dem beide Rechtecke enthalten sind
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
*	vergr”žert oder verkleinert ein Rechteck
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
*	rc_rest()
*
*	liefert eine Rechteckliste aller Rechtecke, die sich in <<frame>>
*	befinden, aber nicht Teil von <<part>> sind.
*	Die Liste endet mit <<g_h>> == 0 und <<g_w>> == 0.
*	ACHTUNG: <<gr_list>> *muž* Platz fr __fnf__ Rechtecke bieten
*/

void	rc_rest( const GRECT *frame, const GRECT *part, GRECT gr_list[5] )
{
	GRECT	*gr = gr_list;
	GRECT	t;
	int		x, y, w, h;
	
	t = *part;
	rc_intersect( frame, &t );

	x = frame->g_x;
	y = frame->g_y;
	w = frame->g_w;
	h = frame->g_h;
	
	if ( t.g_y > y )
	{
		*gr = *frame;
		gr->g_h = t.g_y - y;
		gr++;
		h -= t.g_y - y;
		y = t.g_y;
	}
	if ( t.g_x > x )
	{
		gr->g_x = x;
		gr->g_y = y;
		gr->g_w = t.g_x - x;
		gr->g_h = h;
		w = t.g_x - x;
		x = t.g_x;
		gr++;
	}
	if ( w > t.g_w )
	{
		gr->g_x = x + t.g_w;
		gr->g_y = y;
		gr->g_w = w - t.g_w;
		gr->g_h = t.g_h;
		gr++;
	}
	if ( h > t.g_h )
	{
		gr->g_x = x;
		gr->g_y = y + t.g_h;
		gr->g_w = t.g_w;
		gr->g_h = h - t.g_h;
		gr++;
	}
	*(long *) &gr->g_w = 0L;
}

/*
*	rc_center()
*
*	zentriert ein Rechteck innerhalb eines Rechteckes
*	return ( 1 ) signalisiert fehlenden Platz
*/

int		rc_center( const GRECT *fr, GRECT *box )
{
	int		x, y;
	
	if ( ( x = fr->g_w - box->g_w ) < 0 )
		return ( 1 );
	if ( ( y = fr->g_h - box->g_h ) < 0 )
		return ( 1 );

	box->g_x = ( x >> 1 ) + fr->g_x;
	box->g_y = ( y >> 1 ) + fr->g_y;
	return ( 0 );
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
*	wird solange ausgefhrt bis fct() != 0
*
*	Rckgabewert :	fct()
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
*	liefert das n„chste editierbare Objekt >= obj
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
*	2 :	erster Grožbuchstabe definitiv == key
*	1 : erster Grožbuchstabe == key
*	0 : erster Grožbuchstabe != key
*/

int		IsFirstUpper( const char *str, int key )
{
	int		c;
	int		flag = 0;

	while ( ( c = *str++ ) != '\0' )
	{
		if ( c == '[' && toupper( *str ) == key )
			return ( 2 );
		if ( !flag && c > ' ' && !islower( c ) )
			if ( c == key )
				flag = 2;
			else
				flag = 1;
	}
	return ( flag - 1 );
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

/* Warnung: 'Parameter XXXX never used' zurcksetzen */

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
				temp = IsFirstUpper( ObString(tree+obj), tp->cmp );
				if ( temp == 2 )
					return ( obj );
				if ( temp == 1 )
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
				if ( temp >= 0 )
				{
					temp = IsFirstUpper( ObString(tree+temp), tp->cmp );
					if ( temp == 2 )
						return ( obj );
					if ( temp == 1 )
						if ( tp->obj < 0 )
							tp->obj = obj;
						else
							return ( -1 );
				}
				break;
			default		  :	break;
		}
	}
	return ( 0 );
}

/*
*	GetButton()
*
*	ermittelt ein selektierbares Objekt, dessen erster Grožbuchstabe
*	'key' entspricht
*	Prft auf Eindeutigkeit: Existieren mehrere Objekte, wird -1
*	                         zurckgegeben
*	-1 falls nicht gefunden
*/

int		GetButton( OBJECT *tree, int key )
{
	TPBLK	tp;

	tp.obj = -1;
	tp.cmp = key;

	if ( ( key = ScanTree( tree, 0, &tp, _GetButton ) ) == 0 )
		key = tp.obj;
	return ( key );
}

/*
*	KeyToUpper()
*
*	liefert anhand des Scancodes den Ascii-Wert als Grožbuchstabe
*/

int		KeyToUpper( int key )
{
	static	char	*shift = NULL;

#define		NIX		((void *) -1L)

	if ( !shift )
		shift = Keytbl( NIX, NIX, NIX )->capslock;

	return ( (int) shift[((unsigned int) key) >> 8] );
}
