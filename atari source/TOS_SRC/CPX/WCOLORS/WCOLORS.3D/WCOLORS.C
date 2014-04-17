/* wcolors.c
 * CPX to set default top and background windows
 * 09/01/92 cjg - Recreated and Rewritten under Lattice C
 *		- Added Background window parts
 * 09/22/92 cjg - Fixed RAM-Resident Mode
 * 01/14/93 cjg - Handle new 3D format
 */

/* INCLUDE FILES
 * ================================================================
 */
#define MYTEDINFOS 1
#define PROGRAM 0
#define TESTXLATE  0

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tos.h>
#include <osbind.h>

#include <alt\gemskel.h>
#include <alt\gemerror.h>
#include <alt\vdikeys.h>
#include "wcolor.h"
#include "wcolorx.h"
#include "wcolorx.rsh"
#include "cpxdata.h"

/* PROTOTYPES
 * ================================================================
 */
CPXINFO *cpx_init( XCPB *Xcpb );
BOOLEAN  cpx_call( GRECT *rect );

void	FColor( Colorword *c, int *d );
void	ToColor( Colorword *c, int d );

#if 0
void	cgtest( void );
#endif

/* DEFINES
 * ================================================================
 */
/*#define NULLFUNC   ( void(*)())0L*/

#define COLOR_MIN 0
#define COLOR_MAX 15
#define COLOR_RANGE (COLOR_MAX - COLOR_MIN + 1)
#define WSHADOW 3
/*
#define ObColor(obj) (ObSpec(obj).obspec.cw)
*/
typedef struct
{
	int	name[2], info[2], sizer[2];
	int	closer[2], fuller[2];
	int	vbar;
	int	uparrow[2], dnarrow[2], vslid[2], velev[2];
	int	hbar;
	int	lfarrow[2], rtarrow[2], hslid[2], helev[2];
	int	c19, c20, c21, c22, c23, c24;
} WColors;


/* EXTERNALS
 * ================================================================
 */
extern WColors savecolors[4];
extern WColors defcolors;
extern WColors altcolors[10];

/* GLOBALS
 * ================================================================
 */
XCPB *xcpb;
CPXINFO cpxinfo;

GRECT norect;
int curobj, curcborder, curctext, curcfill;
Colorword curcolor;
BOOLEAN curIsTed,canSetColors;
OBJECT *tree;
int msg[8];
GRECT formrect;
int ncolors, saveindex;
LONG	dcrates[5] = {450L, 330L, 275L, 220L, 165L};
LONG	click_delay;
int     AES_Version;

WColors	*wcolors;

#define NUM_OBJECTS  19

int xobj[] = { TSIZER, TCLOSER, TFULLER, TUP, TDN,
	       TVELEV, TLF, TRT, THELEV,
	       BGSIZER, BFULLER, BUP, BDN,
	       BVELEV, BLF, BRT, BHELEV, TNAME, BGNAME
	     };


char test[50];

void
init_tree( void )
{
   int i;

   if( AES_Version < 0x0330 )
   {
	HideObj( BFULLER );
	HideObj( BUP );
	HideObj( BDN );
	HideObj( BVELEV );
	HideObj( BVSLID );
	HideObj( BLF );
	HideObj( BRT );
	HideObj( BHELEV );
	HideObj( BHSLID );

	ObX( BGNAME ) = ObX( BGINFO );
	ObW( BGNAME ) = ObW( BGINFO );	
   }
   else
   {
	/* Turn off the activator first */
	ObFlags( SAVE ) &= ~IS3DOBJ;
	ObFlags( SAVE ) &= ~IS3DACT;

	ObFlags( OK ) &= ~IS3DOBJ;
	ObFlags( OK ) &= ~IS3DACT;

	ObFlags( CANCEL ) &= ~IS3DOBJ;
	ObFlags( CANCEL ) &= ~IS3DACT;        
 

	if( ncolors > LWHITE )
	{
	  /* Activators */
	  ObFlags( SAVE ) |= IS3DOBJ;
	  ObFlags( SAVE ) |= IS3DACT;

	  ObFlags( OK ) |= IS3DOBJ;
	  ObFlags( OK ) |= IS3DACT;

	  ObFlags( CANCEL ) |= IS3DOBJ;
	  ObFlags( CANCEL ) |= IS3DACT;
	
	  ObX( SAVE ) += 2;
	  ObY( SAVE ) += 2;
 	  ObW( SAVE ) -= 4;
	  ObH( SAVE ) -= 4;

	  ObX( OK ) += 2;
	  ObY( OK ) += 2;
 	  ObW( OK ) -= 4;
	  ObH( OK ) -= 4;

	  ObX( CANCEL ) += 2;
	  ObY( CANCEL ) += 2;
 	  ObW( CANCEL ) -= 4;
	  ObH( CANCEL ) -= 4;

	  for( i = 0; i < NUM_OBJECTS; i++ )
	  {
	    ObFlags( xobj[i] ) |= IS3DOBJ;	/* Indicator */
	    ObFlags( xobj[i] ) &= ~IS3DACT;

	    ObX( xobj[i] ) += 2;
	    ObY( xobj[i] ) += 2;
 	    ObW( xobj[i] ) -= 4;
	    ObH( xobj[i] ) -= 4;
	  }
	}
   }

}


void
wait_bup( void )
{
   MRETS m;
   do
   {
	Graf_mkstate( &m );
   } while( m.buttons );
}

void
itoa2( int n, char *s )
{
    *s = n / 10 + '0';
    if (*s != '0') s++;
    *s++ = n % 10 + '0';
    *s = 0;
}

void
getrect( OBJECT *tree, int obj, GRECT *d )
{
    *d = ObRect(obj);
    objc_offset( tree, obj, &d->g_x, &d->g_y );
}

/*
 * Fix up X position of slider based on value
 */
void
sl_x( OBJECT *tree, int slid, int elev,
      int value, int min, int max, void (*foo)(void) )
{
    GRECT slidr, elevr;

#define TRUEVALUE  ( (long)(value - min) )
#define PIXELRANGE ( (long)(slidr.g_w - elevr.g_w) * 1000L )
#define VALUERANGE ( (long)(max-min+1) * 1000L )

    getrect( tree, slid, &slidr );
    getrect( tree, elev, &elevr );

    if( value == max )
	ObX(elev) = slidr.g_w - elevr.g_w;
    else
	ObX(elev) = (int)( (TRUEVALUE * PIXELRANGE) / VALUERANGE );

    if( foo ) foo();
}

void
draw_slider( OBJECT *tree, int slid, int elev,
	     int value, int min, int max, void (*foo)(void) )
{
    GRECT newr, oldr, slidr;
    int offset;
    BOOLEAN moveleft;

/* get old position */
    getrect( tree, elev, &oldr );
    offset = 0;
    if( TedBorder( elev ) < 0 )
	offset = (int)TedBorder( elev );
    rc_center( &oldr, offset, offset, &oldr );
/* set new position */
    sl_x( tree, slid, elev, value, min, max, foo );

/* draw new */
    getrect( tree, elev, &newr );
    rc_center( &newr, offset, offset, &newr );
    ObjcDraw( tree, elev, MAX_DEPTH, &newr );
/* undraw old */
    moveleft = (newr.g_x < oldr.g_x);
    if( rc_intersect(&oldr, &newr) )
    {
	newr.g_w -= 1;
	oldr.g_w -= newr.g_w;
	if (moveleft)
	    oldr.g_x += newr.g_w;
    }
    getrect( tree, slid, &slidr );
    rc_intersect( &oldr, &slidr );
    ObjcDraw( tree, slid, MAX_DEPTH, &slidr );
    oldr.g_h = 1;
    ObjcDraw( tree, TBOX, MAX_DEPTH, &oldr );
    oldr.g_y += slidr.g_h + 1;
    ObjcDraw( tree, TBOX, MAX_DEPTH, &oldr );

/* if setting info border color, or
 * at top of any slider setting up, velevator or vslider colors,
 * redraw FLOATER
 */
    if (
	( (curobj == TINFO) && (slid == BORDSLID) ) ||
	( ( (value == COLOR_MAX) ||
	    (value == COLOR_MAX-1) ) &&
	  ( (curobj == TUP)    ||
	    (curobj == TVELEV) ||
	    (curobj == TVSLID) )     )
       )
	ObjcDraw( tree, FLOATER, MAX_DEPTH, NULL );

}

void
sl_dragx( OBJECT *tree, int slid, int elev,
          int min, int max, int *numvar, void (*foo)(void) )
{
    int newvalue, xoffset, elevx, lastvalue;
    MRETS m;
    GRECT slidr, elevr;

    lastvalue = *numvar;

    TedCBorder( elev ) = 0;
    draw_slider( tree, slid, elev, lastvalue, min, max, NULLFUNC );


/* get extents */
    getrect( tree, slid, &slidr );
    getrect( tree, elev, &elevr );

/* find mouse offset into elev, and adjust box for clip */
    Graf_mkstate( &m );
    xoffset = m.x - elevr.g_x - 1;

/* While a button's down,
 *   get the current elevator coordinate,
 *   translate it to a value,
 *   draw it if it changed
 */
    while( m.buttons ) {
	elevx = m.x - xoffset;
	if( elevx <= slidr.g_x )
	    newvalue = min;
	else if( elevx >= slidr.g_x + slidr.g_w - elevr.g_w )
	    newvalue = max;
	else
#define PIXELOFFSET ( (long)(elevx - slidr.g_x) )
            newvalue = min + (int)( (VALUERANGE * PIXELOFFSET) / PIXELRANGE );

	if( newvalue != lastvalue )
	{
	    lastvalue = newvalue;
            *numvar = newvalue;
            draw_slider( tree, slid, elev, lastvalue, min, max, foo );
	}
	Graf_mkstate( &m );
    }
    TedCBorder(elev) = 1;
    draw_slider( tree, slid, elev, lastvalue, min, max, NULLFUNC );
}

void
sl_pagex( OBJECT *tree, int slid, int elev, int inc,
          int min, int max, int *numvar, void (*foo)(void) )
{
    MRETS m;
    GRECT slidr, elevr;
    int newval, dir;

    getrect( tree, slid, &slidr );
    getrect( tree, elev, &elevr );

    Graf_mkstate( &m );
    do {
	dir = (m.x < elevr.g_x + elevr.g_w/2) ? -1 : 1;
	newval = *numvar + inc*dir;
	if( (newval >= min) && (newval <= max) )
	{
	    *numvar = newval;
	    draw_slider( tree, slid, elev, newval, min, max, foo );
	    getrect( tree, elev, &elevr );
	    EvntTimer( click_delay );
	}

	Graf_mkstate( &m ); /* check _after_ delay */
	if( (m.x >= elevr.g_x + elevr.g_w/4) &&
	    (m.x < elevr.g_x + (3*elevr.g_w)/4) )
	{
	    sl_dragx( tree, slid, elev, min, max, numvar, foo );
	    m.buttons = 0;
	}

	while( m.buttons && !xy_inrect(m.x, m.y, &slidr) )
	    Graf_mkstate( &m );

    } while( m.buttons );
}

void
draw_fills( void )
{
    int i;

    for( i = FILL0; i <= FILL7; i++ )
        if( ObCBorder(i) == 0 )
        {
          ObCBorder(i) = 1;
          ObjcDraw( tree, i, MAX_DEPTH, NULL );
        }
    i = FILL0 + (int)curcolor.pattern;
    ObCBorder(i) = 0;
    ObjcDraw( tree, i, MAX_DEPTH, NULL );
}

void
draw_curborders( GRECT *r )
{
    int borderobj = NIL;

    switch( curobj )
    {
	case BHSLID:
	case BLF:
	    borderobj = BHELEV;
	break;

	case BRT:
	    ObjcDraw( tree, BHSLID, MAX_DEPTH, r );
	    borderobj = BGSIZER;
	break;

	case BHELEV:
	case BVELEV:
	break;

	case BFULLER:
	case BGNAME:
	    borderobj = BGINFO;
	break;


	case BVSLID:
	case BUP:
	    borderobj = BVELEV;
	break;

	case BDN:
	    ObjcDraw( tree, BVSLID, MAX_DEPTH, r );
	    borderobj = BGSIZER;
	break;


	case BGINFO:
	    borderobj = BGVBAR;
	break;

	case BGVBAR:
	case BGHBAR:
	    borderobj = BGSIZER;
	break;

	case BGSIZER:
	break;

	case TCLOSER:
	case TFULLER:
	case TNAME:
	    borderobj = TINFO;
	break;

	case TINFO:
	    borderobj = TUP;
	break;

	case TVSLID:
	case TUP:
	    borderobj = TVELEV;
	break;

	case TDN:
	    ObjcDraw( tree, TVSLID, MAX_DEPTH, r );
	    borderobj = TSIZER;
	break;

	case TVELEV:
	case THELEV:
	break;

	case THSLID:
	case TLF:
	    borderobj = THELEV;
	break;

	case TRT:
	    ObjcDraw( tree, THSLID, MAX_DEPTH, r );
	    borderobj = TSIZER;
	break;

	case TSIZER:
	break;
    }
    if( borderobj != NIL )
	ObjcDraw( tree, borderobj, MAX_DEPTH, r );

    if(  (  ObNext( BGBOX ) == FLOATER ) && 
	 ( 
	    ( curobj == TUP )    ||
	    ( curobj == THELEV ) ||
	    ( curobj == THSLID ) ||
	    ( curobj == TRT )    ||
	    ( curobj == TSIZER ) ||
	    ( curobj == TFULLER )||
	    ( curobj == TINFO )
	 )
      )return;

    ObjcDraw( tree, FLOATER, MAX_DEPTH, r );
}
    

void
draw_curobj( void )
{
    GRECT r, r1, r2, tr;
    int offset;

    /* fix and draw current object */
    if(curIsTed)
    {
	FColor( &curcolor, (int *)&TedColor( curobj ) );
	if( TedBorder( curobj) < 0 )
            offset = TedBorder( curobj );
    }
    else
    {
	FColor( &curcolor, (int *)&ObColor( curobj ) );

	if( ObBorder( curobj ) < 0)
            offset = ObBorder( curobj );
    }

    getrect( tree, curobj, &r );
    rc_center( &r, offset, offset, &r );

    if(( AES_Version >= 0x0330 ) && ( ncolors > LWHITE ))
    {
       r.g_x -= 2;
       r.g_y -= 2;
       r.g_w += 4;
       r.g_h += 4;
    }

    if( ( curobj == BGHBAR ) || ( curobj == BLF ) || ( curobj == BHELEV ) ||
        ( curobj == BHSLID ) )
    {
	r1 = r2 = r;
	getrect( tree, TBOX, &tr );
	rc_intersect( &tr, &r2 );
	r1.g_y += r2.g_h + WSHADOW; /* TBOX shadow compensation */
	r1.g_h -= r2.g_h + WSHADOW;
	r.g_x += r2.g_w + WSHADOW;
	r.g_w -= r2.g_w + WSHADOW;
	r.g_h -= r1.g_h;
	ObjcDraw( tree, curobj, MAX_DEPTH, &r1 );
	draw_curborders( &r1 );
	return;
    }
    else
    if( (curobj == BGNAME) || (curobj == BGINFO) )
    {
	r2 = r;
	getrect( tree, TBOX, &tr );
	rc_intersect( &tr, &r2 );
	r.g_x += r2.g_w + WSHADOW; /* TBOX shadow compensation */
	r.g_w -= r2.g_w + WSHADOW;
    }
    else
    if( curobj == BRT )
    {
       /* Below TBOX */
	r1 = r2 = r;
	getrect( tree, TBOX, &tr );
	r1.g_y = tr.g_y + tr.g_h + WSHADOW;
        ObjcDraw( tree, curobj, MAX_DEPTH, &r1 );
        draw_curborders( &r1 );

       /* Right of TBOX */
       r1 = r2 = r;
       getrect( tree, TBOX, &tr );
       r1.g_x = tr.g_x + tr.g_w + WSHADOW;      
       ObjcDraw( tree, curobj, MAX_DEPTH, &r1 );
       draw_curborders( &r1 );
 
       ObjcDraw( tree, TBOX, MAX_DEPTH, &r );
       return;        
    }

    ObjcDraw( tree, curobj, MAX_DEPTH, &r );
    draw_curborders( &r );
}

/*
 * fix elevator contents
 */
void
fix_elev( int elev, int value )
{
    itoa2( value, TedText(elev) );
    if( value == 0 )
	TedCText(elev) = 1;
    else
	TedCText(elev) = 0;
    TedCFill(elev) = value;
}

void
do_bordslid( void )
{
    curcolor.cborder = curcborder;
    fix_elev( BORDELEV, curcborder );
    draw_curobj();
}

void
do_textslid( void )
{
    curcolor.ctext = curctext;
    fix_elev( TEXTELEV, curctext );
    draw_curobj();
}
void
do_fillslid( void )
{
    curcolor.cfill = curcfill;
    fix_elev( FILLELEV, curcfill );
    draw_curobj();
}

void
set_info( void )
{
    if( curIsTed)
    {
	ToColor( &curcolor, TedColor( curobj ) );
/*        curcolor = TedColor(curobj);*/
    }
    else
        curcolor = ObColor(curobj);
    draw_fills();
    TedReplace( MODE ) = curcolor.replace;
    ObjcDraw( tree, MODE, MAX_DEPTH, NULL );

    curcborder = (int)curcolor.cborder;
    fix_elev( BORDELEV, curcborder );
    draw_slider( tree, BORDSLID, BORDELEV, curcborder, COLOR_MIN, COLOR_MAX, NULLFUNC );
    curctext = (int)curcolor.ctext;
    fix_elev( TEXTELEV, curctext );
    draw_slider( tree, TEXTSLID, TEXTELEV, curctext, COLOR_MIN, COLOR_MAX, NULLFUNC );
    curcfill = (int)curcolor.cfill;
    fix_elev( FILLELEV, curcfill );
    draw_slider( tree, FILLSLID, FILLELEV, curcfill, COLOR_MIN, COLOR_MAX, NULLFUNC );
}

/* check for incompatible text/fill color based on available palette */
int
check_tcolor( int c )
{
    Colorword cw;
    int       out;

    ToColor( &cw, c );

    if( ((cw.cfill >= ncolors) && (cw.ctext == 1)) ||
    	((cw.ctext >= ncolors) && (cw.cfill == 1)) ||
    	((cw.ctext >= ncolors) && (cw.cfill >= ncolors)) )
	cw.ctext = 0;

    FColor( &cw, &out );
    return( out );
}

int
check_elcolor( int sl, int el )
{
    Colorword slcw, elcw;
    int       out;

    ToColor( &slcw, sl );
    ToColor( &elcw, el );

    if( elcw.cfill &&
	( ((elcw.cfill >= ncolors) && (slcw.cfill == 1)) ||
	  ((slcw.cfill >= ncolors) && (elcw.cfill == 1)) ||
	  ((elcw.cfill >= ncolors) && (slcw.cfill >= ncolors)) )  )
	elcw.cfill = 0;

    FColor( &elcw, &out );
    return( out );
}


void
set_windows( void )
{
#define WDColor(obj) wind_set( 0, WF_DCOLOR, (obj), t, b )
    int t, b;

#ifdef TAKESYNC
wind_update( TRUE );
#endif

    t = check_tcolor(wcolors->name[0]);
    b = check_tcolor(wcolors->name[1]);
    WDColor(W_NAME);
    t = check_tcolor(wcolors->info[0]);
    b = check_tcolor(wcolors->info[1]);
    WDColor(W_INFO);
/*    WDColor(W_BOX);*/
    t = check_tcolor(wcolors->sizer[0]);
    b = check_tcolor(wcolors->sizer[1]);
    WDColor(W_SIZER);

    t = -1;
    b = wcolors->vbar;
    WDColor(W_VBAR);
    b = wcolors->hbar;
    WDColor(W_HBAR);

    b = -1;

    wcolors->closer[1] = wcolors->fuller[1];	/* BackGrnd is same*/
    t = check_tcolor(wcolors->closer[0]);
    if( AES_Version >= 0x0330 )
      b = check_tcolor(wcolors->closer[1]);
    WDColor(W_CLOSER);

    t = check_tcolor(wcolors->fuller[0]);
    if( AES_Version >= 0x0330 )
       b = check_tcolor(wcolors->fuller[1]);
    WDColor(W_FULLER);

    t = check_tcolor(wcolors->uparrow[0]);
    if( AES_Version >= 0x0330 )
       b = check_tcolor(wcolors->uparrow[1]);
    WDColor(W_UPARROW);

    t = check_tcolor(wcolors->dnarrow[0]);
    if( AES_Version >= 0x0330 )
       b = check_tcolor(wcolors->dnarrow[1]);
    WDColor(W_DNARROW);

    t = check_tcolor(wcolors->lfarrow[0]);
    if( AES_Version >= 0x0330 )
      b = check_tcolor(wcolors->lfarrow[1]);
    WDColor(W_LFARROW);

    t = check_tcolor(wcolors->rtarrow[0]);
    if( AES_Version >= 0x0330 )
      b = check_tcolor(wcolors->rtarrow[1]);
    WDColor(W_RTARROW);

    t = wcolors->vslid[0];
    if( AES_Version >= 0x0330 )
       b = wcolors->vslid[1];
    WDColor(W_VSLIDE);

    t = check_elcolor(t, wcolors->velev[0]);
    if( AES_Version >= 0x0330 )
       b = check_elcolor(b, wcolors->velev[1]);
    WDColor(W_VELEV);

    t = wcolors->hslid[0];
    if( AES_Version >= 0x0330 )
       b = wcolors->hslid[1];
    WDColor(W_HSLIDE);

    t = check_elcolor(t, wcolors->helev[0]);
    if( AES_Version >= 0x0330 )
       b = check_elcolor(t, wcolors->helev[1]);
    WDColor(W_HELEV);

#ifdef TAKESYNC
wind_update( FALSE );
#endif

}

void
set_wobjects( WColors *wc )
{
    if( AES_Version >= 0x0330 )
    {
/*    ToColor( &ObColor(BCLOSER), wc->closer[1] );*/
      ToColor( &ObColor(BFULLER), wc->fuller[1] );
      ToColor( &ObColor(BUP), wc->uparrow[1] );
      ToColor( &ObColor(BDN), wc->dnarrow[1] );
      ToColor( &ObColor(BVSLID), wc->vslid[1] );
      ToColor( &ObColor(BVELEV), wc->velev[1] );
      ToColor( &ObColor(BLF), wc->lfarrow[1] );
      ToColor( &ObColor(BRT), wc->rtarrow[1] );
      ToColor( &ObColor(BHSLID), wc->hslid[1] );
      ToColor( &ObColor(BHELEV), wc->helev[1] );

    }

    TedColor(BGNAME) = wc->name[1];
    TedColor(BGINFO) = wc->info[1];
    ToColor( &ObColor(BGSIZER), wc->sizer[1] );

    ToColor( &ObColor(BGVBAR), wc->vbar );
    ToColor( &ObColor(BGHBAR), wc->hbar );

    ToColor( &ObColor(TCLOSER), wc->closer[0] );
    ToColor( &ObColor(TFULLER), wc->fuller[0] );

    TedColor(TNAME) = wc->name[0];
    TedColor(TINFO) = wc->info[0];

    ToColor( &ObColor(TUP), wc->uparrow[0] );
    ToColor( &ObColor(TDN), wc->dnarrow[0] );
    ToColor( &ObColor(TVSLID), wc->vslid[0] );
    ToColor( &ObColor(TVELEV), wc->velev[0] );
    ToColor( &ObColor(TLF), wc->lfarrow[0] );
    ToColor( &ObColor(TRT), wc->rtarrow[0] );
    ToColor( &ObColor(THSLID), wc->hslid[0] );
    ToColor( &ObColor(THELEV), wc->helev[0] );
    ToColor( &ObColor(TSIZER), wc->sizer[0] );

    ObjcDraw( tree, ROOT, MAX_DEPTH, NULL );
    set_info();
}

void
set_wcolors( void )
{
    if( AES_Version >= 0x0330 )
    {
/*    FColor( &ObColor(BCLOSER), &wcolors->closer[1] );*/
      FColor( &ObColor(BFULLER), &wcolors->fuller[1] );
      FColor( &ObColor(BUP), &wcolors->uparrow[1] );
      FColor( &ObColor(BDN), &wcolors->dnarrow[1] );
      FColor( &ObColor(BVSLID), &wcolors->vslid[1] );
      FColor( &ObColor(BVELEV), &wcolors->velev[1] );
      FColor( &ObColor(BLF), &wcolors->lfarrow[1] );
      FColor( &ObColor(BRT), &wcolors->rtarrow[1] );
      FColor( &ObColor(BHSLID), &wcolors->hslid[1] );
      FColor( &ObColor(BHELEV), &wcolors->helev[1] );
    }

    wcolors->name[1] = TedColor(BGNAME);
    wcolors->info[1] = TedColor(BGINFO);

    FColor( &ObColor(BGVBAR), &wcolors->vbar );
    FColor( &ObColor(BGHBAR), &wcolors->hbar );
    FColor( &ObColor(BGSIZER), &wcolors->sizer[1] );

    FColor( &ObColor(TCLOSER), &wcolors->closer[0] );
    FColor( &ObColor(TFULLER), &wcolors->fuller[0] );

    wcolors->name[0] = TedColor(TNAME);
    wcolors->info[0] = TedColor(TINFO);

    FColor( &ObColor(TUP), &wcolors->uparrow[0] );
    FColor( &ObColor(TDN), &wcolors->dnarrow[0] );
    FColor( &ObColor(TVSLID), &wcolors->vslid[0] );
    FColor( &ObColor(TVELEV), &wcolors->velev[0] );
    FColor( &ObColor(TLF), &wcolors->lfarrow[0] );
    FColor( &ObColor(TRT), &wcolors->rtarrow[0] );
    FColor( &ObColor(THSLID), &wcolors->hslid[0] );
    FColor( &ObColor(THELEV), &wcolors->helev[0] );
    FColor( &ObColor(TSIZER), &wcolors->sizer[0] );
}

void
drag_curobj( void )
{
    MRETS     m;
    int       overobj,savecur;
    BOOLEAN   saveIsTed;
    Colorword savecol,lastcol;

    graf_mouse( FLAT_HAND, NULL );
    savecur = overobj = curobj;
    savecol = lastcol = curcolor;

    saveIsTed = curIsTed;
    do {
	if( overobj != curobj )
	    switch( overobj )
	    {
	    case BGNAME:
	    case BGINFO:
	    case BGVBAR:
	    case BGHBAR:
	    case BGSIZER:
	    case TCLOSER:
	    case TFULLER:
	    case BFULLER:
	    case TNAME:
	    case TINFO:
	    case TUP:
	    case BUP:
	    case TDN:
	    case BDN:
	    case TVSLID:
	    case BVSLID:
	    case TVELEV:
	    case BVELEV:
	    case TLF:
	    case BLF:
	    case TRT:
	    case BRT:
	    case THSLID:
	    case BHSLID:
	    case THELEV:
	    case BHELEV:
	    case TSIZER:
		if( curobj != NIL )
		{
		    curcolor = lastcol;
		    draw_curobj();
		    curcolor = savecol;
		}
		curobj = overobj;
		curIsTed = IsTed(curobj);
		if( curIsTed )
		{
		   ToColor( &lastcol, TedColor( curobj ) );
		   /*lastcol = TedColor(curobj);*/
		}
		else
		   lastcol = ObColor(curobj);
		draw_curobj();
		break;
	    default:
		if( curobj != NIL )
		{
		    curcolor = lastcol;
		    draw_curobj();
		    curcolor = savecol;
		    curobj = NIL;
		}
	    }
	Graf_mkstate( &m );
	overobj = objc_find( tree, ROOT, MAX_DEPTH, m.x, m.y );
    } while( m.buttons );
    graf_mouse( ARROW, NULL );
    curobj = savecur;
    curIsTed = saveIsTed;
}

void
do_form( void )
{
    GRECT   oldfloat, newfloat;
    int     exitobj, ox, oy, newpattern, offset;
    MRETS   m;
    BOOLEAN shuffled, quit = FALSE;
    GRECT   rect;

    click_delay = dcrates[evnt_dclick(0, 0)];
    while( !quit )
    {
        shuffled = FALSE;
#if PROGRAM
	exitobj = form_do( tree, 0 );
#else
	exitobj = xcpb->Xform_do( tree, 0, msg );
#endif
	/*
	 * If window was moved, screwit... redraw all the
	 * sliders, from the bottom up.  Otherwise, the fill pattern
	 * under the sliders get screwed.
	 */
	if( !rc_equal(&formrect, &ObRect(ROOT)) )
	{
	    formrect = ObRect(ROOT);
	    ObjcDraw( tree, BORDSLID, MAX_DEPTH, NULL );
	    ObjcDraw( tree, TEXTSLID, MAX_DEPTH, NULL );
	    ObjcDraw( tree, FILLSLID, MAX_DEPTH, NULL );
	}

	if (exitobj == NIL)
	{
	    switch( msg[0] )
	    {
	    case WM_CLOSED:
		exitobj = OK;
	    break;
	    case AC_CLOSE:
		exitobj = CANCEL;
	    break;
	    case CT_KEY:
		switch( msg[3] )
		{
		case K_UNDO:
		/* undo changes */
		    set_wobjects( wcolors );
		break;
		case K_HOME:
		/* set defaults */
		    set_wobjects( &defcolors );
		break;
		case K_F1:
		case K_F2:
		case K_F3:
		case K_F4:
		case K_F5:
		case K_F6:
		case K_F7:
		case K_F8:
		case K_F9:
		case K_F10:
		/* set preset */
		    set_wobjects( &altcolors[(msg[3]>>8)-(K_F1>>8)] );
		break;
/*		case KA_R:*/
		case K_INSERT:
		/* restore */
		    set_wobjects( &savecolors[saveindex] );
		break;
		case KA_G:
		/* spanish save */
		    if( xcpb->Country_Code == SPA )
		    {
			select( tree, SAVE );
			exitobj = SAVE;
			quit = TRUE;
		    }
		break;
		case KA_S:
		/* all other countries save */
		    if( xcpb->Country_Code != SPA )
		    {
			select( tree, SAVE );
			exitobj = SAVE;
			quit = TRUE;
		    }
		break;
		default:
		;
		}
	    default:
	    ;
	    }

	}
	if( exitobj != NIL )
	{
	    exitobj &= 0x7fff;
	    switch( exitobj )
	    {
	    case SAVE:
	    /*
	    * save current settings to disk
	    */
#if PROGRAM
#else
		if( xcpb->XGen_Alert( SAVE_DEFAULTS ) )
		{
		    set_wcolors();
		    set_windows();
		    savecolors[saveindex] = *wcolors;
		    xcpb->CPX_Save( &savecolors, sizeof(savecolors) );
		}
		else
		{
#if 0
cgtest();
#endif
		    quit = FALSE;
		}
#endif
		Deselect( SAVE );
		rect = ObRect( SAVE );
		objc_offset( tree, SAVE, &rect.g_x, &rect.g_y );
		rect.g_x -= 2;
		rect.g_y -= 2;
		rect.g_w += 4;
		rect.g_h += 4;
		ObjcDraw( tree, SAVE, MAX_DEPTH, &rect );
/*		deselect( tree, SAVE );*/
	    break;

	    case OK:
	    /*
	    * set window colors
	    */
		set_wcolors();
		set_windows();
	    /* fall through */

	    case CANCEL:
		quit = TRUE;
		Deselect(exitobj);
	    break;

	    case BGNAME:
	    case BGINFO:
	    case BGVBAR:
	    case BGHBAR:
	    case BGSIZER:
	    case BFULLER:
	    case BUP:
	    case BDN:
	    case BVSLID:
	    case BVELEV:
	    case BLF:
	    case BRT:
	    case BHSLID:
	    case BHELEV:
	    /*
	    * set up object tree so that FLOATER appears under TBOX
	    */
		shuffled = TRUE;
		ObNext(BGBOX) = FLOATER;

		ObNext(FLOATER) = TBOX;
		ObNext(TBOX) = ROOT;
		ObTail(ROOT) = TBOX;
		ObFlags(FLOATER) = TOUCHEXIT;
		ObFlags(TBOX) = LASTOB;
	    /* fall through */
	    case TCLOSER:
	    case TFULLER:
	    case TNAME:
	    case TINFO:
	    case TUP:
	    case TDN:
	    case TVSLID:
	    case TVELEV:
	    case TLF:
	    case TRT:
	    case THSLID:
	    case THELEV:
	    case TSIZER:
		if( !shuffled )
		{
		/*
		* set up object tree so that FLOATER appears over TBOX
		*/
		    ObNext(BGBOX) = TBOX;

		    ObNext(TBOX) = FLOATER;
		    ObNext(FLOATER) = ROOT;
		    ObTail(ROOT) = FLOATER;
		    ObFlags(FLOATER) = LASTOB|TOUCHEXIT;
		    ObFlags(TBOX) = NONE;
		}
		/*
		* Save old floater position for redraw,
		* set new floater position from selected object
		*/
		getrect( tree, FLOATER, &oldfloat );
		offset = 0;
		if( ObBorder(FLOATER) < 0)
		    offset = ObBorder(FLOATER);
		rc_center( &oldfloat, offset, offset, &oldfloat );

		curobj = exitobj;

		curIsTed = IsTed(curobj);
		
		getrect( tree, curobj, &ObRect(FLOATER) );
		objc_offset( tree, ROOT, &ox, &oy );
		ObX(FLOATER) -= ox;
		ObY(FLOATER) -= oy;
		
		if(( AES_Version >= 0x0330 ) && ( ncolors > LWHITE ))
		{
		   /* Adjust only if we are 3D */
		   if( ObFlags( curobj ) & IS3DOBJ )
		   {
		     ObX( FLOATER ) -= 2;
		     ObY( FLOATER ) -= 2;
		     ObW( FLOATER ) += 4;
		     ObH( FLOATER ) += 4;
		   }
		}

		rc_center( &ObRect(FLOATER), -WSHADOW, -WSHADOW, &ObRect(FLOATER) );
		getrect( tree, FLOATER, &newfloat );

		rc_center( &newfloat, offset, offset, &newfloat );


		/*
		* get color word settings, set sliders, redraw center box
		*/
		set_info();
		/*
		* undraw old floater, draw new floater
		*/
		ObjcDraw( tree, ROOT, MAX_DEPTH, &oldfloat );
		ObjcDraw( tree, ROOT, MAX_DEPTH, &newfloat );
		wait_bup();
	    break;

	    case FILL0:
	    case FILL1:
	    case FILL2:
	    case FILL3:
	    case FILL4:
	    case FILL5:
	    case FILL6:
	    case FILL7:
	    /*
	    * "slide" through fill settings while button is down
	    * setting fill pattern as it changes
	    */
		objc_offset( tree, exitobj, &ox, &oy );
		do {
		    newpattern = exitobj - FILL0;
		    if (curcolor.pattern != newpattern )
		    {
			curcolor.pattern = newpattern;
			if( curIsTed )
			    TedPattern(curobj) = newpattern;
			else
			    ObPattern( curobj) = newpattern;
			draw_fills();
			draw_curobj();
		    }
		    Graf_mkstate( &m );
		    exitobj = objc_find( tree, FILLS, MAX_DEPTH, m.x, oy );
		    if (exitobj == NIL) exitobj = (int)curcolor.pattern + FILL0;
		} while (m.buttons);
	    break;

	    case MODE:
	    /*
	    * Toggle replace/transparent mode
	    */
		if( TedReplace( MODE ) )
		    TedReplace(MODE) = 0;
		else
		    TedReplace(MODE) = 1;
		curcolor.replace = TedReplace(MODE);
		if( curIsTed )
		    TedReplace(curobj) = curcolor.replace;
		else
		    ObReplace(curobj) = curcolor.replace;
		ObjcDraw( tree, MODE, MAX_DEPTH, NULL );
		draw_curobj();
		wait_bup();
	    break;

	    case BORDSLID:
		sl_pagex( tree, BORDSLID, BORDELEV, 1,
			COLOR_MIN, COLOR_MAX, &curcborder, do_bordslid );
	    break;

	    case BORDELEV:
		fix_elev( BORDELEV, curcborder );
		sl_dragx( tree, BORDSLID, BORDELEV,
			COLOR_MIN, COLOR_MAX, &curcborder, do_bordslid );
	    break;

	    case TEXTSLID:
		sl_pagex( tree, TEXTSLID, TEXTELEV, 1,
			COLOR_MIN, COLOR_MAX, &curctext, do_textslid );
	    break;

	    case TEXTELEV:
		fix_elev( TEXTELEV, curctext );
		sl_dragx( tree, TEXTSLID, TEXTELEV,
			COLOR_MIN, COLOR_MAX, &curctext, do_textslid );
	    break;

	    case FILLSLID:
		sl_pagex( tree, FILLSLID, FILLELEV, 1,
			COLOR_MIN, COLOR_MAX, &curcfill, do_fillslid );
	    break;

	    case FILLELEV:
		fix_elev( FILLELEV, curcfill );
		sl_dragx( tree, FILLSLID, FILLELEV,
			COLOR_MIN, COLOR_MAX, &curcfill, do_fillslid );
	    break;

	    case FLOATER:
	    /*
	    * "drag" current object's settings to another object
	    */
		drag_curobj();
	    break;

	    default:
	    /*
	    * do nothing
	    */
	    ;
	    }
	}
    }
}


#if PROGRAM
void
main( void )
{

    appl_init();
    if( !rsrc_load("WCOLORX.RSC") )
    {
	appl_exit();
	return;
    }
    rsrc_gaddr( R_TREE, WCOLPANL, &tree );
    FormDial( FMD_START, &norect, &norect );
    FormCenter( tree, &ObRect(ROOT) );
    graf_mouse( ARROW, NULL );

    init_tree();

    ObjcDraw( tree, ROOT, MAX_DEPTH, NULL );
    curobj = TCLOSER;
    curIsTed = FALSE;
    set_info();
    do_form();

    FormDial( FMD_FINISH, &norect, &norect );
    rsrc_free();
    appl_exit();
}
#else

/*
 * Set text fields in resource
 */
void
set_texts( int country )
{
    OBJECT *Xtree = (OBJECT *)rs_trindex[XLATE];
    int i;

#define XText(obj,string) TedText((obj)) = Xtree[(string)].ob_spec
#define XString(obj,string) ObString((obj)) = Xtree[(string)].ob_spec

    switch ( country )
    {
   case FRG:
	XText(TNAME,FRGWIND);
	XText(TINFO,FRGINFO);
	XText(BORD,FRGBORD);
	XText(TEXT,FRGTEXT);
	XText(FILL,FRGFILL);
	XText(MODE,FRGMODE);
	XString(OK,FRGOK);
	XString(CANCEL,FRGCAN);
	XString(SAVE,FRGSAVE);
    break;
    case FRA:
	XText(TNAME,FRAWIND);
	XText(TINFO,FRAINFO);
	XText(BORD,FRABORD);
	XText(TEXT,FRATEXT);
	XText(FILL,FRAFILL);
	XText(MODE,FRAMODE);
	XString(OK,FRAOK);
	XString(CANCEL,FRACAN);
	XString(SAVE,FRASAVE);
    break;
    case SPA:
	XText(TNAME,SPAWIND);
	XText(TINFO,SPAINFO);
	XText(BORD,SPABORD);
	XText(TEXT,SPATEXT);
	XText(FILL,SPAFILL);
	XText(MODE,SPAMODE);
	XString(OK,SPAOK);
	XString(CANCEL,SPACAN);
	XString(SAVE,SPASAVE);
    break;
    case ITA:
	XText(TNAME,ITAWIND);
	XText(TINFO,ITAINFO);
	XText(BORD,ITABORD);
	XText(TEXT,ITATEXT);
	XText(FILL,ITAFILL);
	XText(MODE,ITAMODE);
	XString(OK,ITAOK);
	XString(CANCEL,ITACAN);
	XString(SAVE,ITASAVE);
    break;
    case SWE:
	XText(TNAME,SWEWIND);
	XText(TINFO,SWEINFO);
	XText(BORD,SWEBORD);
	XText(TEXT,SWETEXT);
	XText(FILL,SWEFILL);
	XText(MODE,SWEMODE);
	XString(OK,SWEOK);
	XString(CANCEL,SWECAN);
	XString(SAVE,SWESAVE);
    break;
    default:
	/* Default case is USA/UK */
	;
    }
    i = (int)strlen(TedText(TNAME));
    TedText(BGNAME) = &TedText(TNAME)[i-4];
    i = (int)strlen(TedText(TINFO));
    TedText(BGINFO) = &TedText(TINFO)[i-4];
}


#if TESTXLATE
void
cycle_country( int *country )
{

	switch ( *country )
	{
	    case FRG:
		*country = FRA;
		form_alert(1,"[0][ France ][OK]");
	    break;
	    case FRA:
	    	*country = SPA;
		form_alert(1,"[0][ Spain ][OK]");
	    break;
	    case SPA:
	    	*country = ITA;
		form_alert(1,"[0][ Italy ][OK]");
	    break;
	    case ITA:
	    	*country = SWE;
		form_alert(1,"[0][ Sweden ][OK]");
	    break;
	    case SWE:
	    	*country = USA;
		form_alert(1,"[0][ USA ][OK]");
	    break;
	    case USA:
	    	*country = FRG;
		form_alert(1,"[0][ Germany ][OK]");
	    break;
	}
}
#endif

/*
 * Initialize CPX
 */
CPXINFO
*cpx_init( XCPB *Xcpb )
{
    int work_out[57];

    xcpb = Xcpb;

    appl_init();
    canSetColors = ( _AESglobal[0] >= 0x0300 );
    AES_Version = _AESglobal[0];

#if TESTXLATE
cycle_country( &xcpb->Country_Code );
#endif

    vq_extnd( xcpb->handle, 0, work_out );
    ncolors = work_out[13];
    saveindex = 0;
    if (ncolors > 2) ++saveindex;
    if (ncolors > 4) ++saveindex;
    wcolors = (WColors *)(xcpb->Get_Buffer());

    if( xcpb->booting )
    {
	if (canSetColors)
	{
	    /* Read in defaults */
	    *wcolors = savecolors[saveindex];
	    set_windows();
	}
    }
    else
    {
	if( !xcpb->SkipRshFix )
	{
	    xcpb->rsh_fix( NUM_OBS, NUM_FRSTR, NUM_FRIMG, NUM_TREE, rs_object,
			   rs_tedinfo, rs_strings, rs_iconblk, rs_bitblk,
			   rs_frstr, rs_frimg, rs_trindex, rs_imdope );
	}

	if (canSetColors)
	{
	    tree = (OBJECT *)rs_trindex[WCOLPANL];
	    cpxinfo.cpx_call	= cpx_call;
	    cpxinfo.cpx_draw	= NULL;
	    cpxinfo.cpx_wmove	= NULL;
	    cpxinfo.cpx_timer	= NULL;
	    cpxinfo.cpx_key	= NULL;
	    cpxinfo.cpx_button	= NULL;
	    cpxinfo.cpx_m1	= NULL;
	    cpxinfo.cpx_m2	= NULL;
	    cpxinfo.cpx_hook	= NULL;
	    cpxinfo.cpx_close	= NULL;

	}
	else
	{
#define XAlert(string) form_alert(1,(char *)rs_frstr[(string)])
	    switch ( xcpb->Country_Code )
	    {
	    case FRG:
		XAlert(FRGLERT);
	    break;
	    case FRA:
	    	XAlert(FRALERT);
	    break;
	    case SPA:
	    	XAlert(SPALERT);
	    break;
	    case ITA:
	    	XAlert(ITALERT);
	    break;
	    case SWE:
	    	XAlert(SWELERT);
	    break;
	    default:
		XAlert(ALERT);
	    }
	    return NULL;
	}
    }
    return &cpxinfo;
}

/*
 * CPX user interaction
 */
BOOLEAN
cpx_call( GRECT *rect )
{
    formrect = *rect;

    ObX( ROOT ) = rect->g_x;
    ObY( ROOT ) = rect->g_y;

    set_texts( xcpb->Country_Code );


    curobj = TCLOSER;
    curIsTed = FALSE;

    if( !xcpb->SkipRshFix )
       init_tree();

    set_wobjects( wcolors );
    do_form();
    return FALSE;
}

#endif




#if 0
void
cgtest( void )
{
sprintf( test,"[1][WINDOW COLOR DEFAULTS][OK]");
form_alert( 1, test );

sprintf( test, "[1][name0: %x][OK]", wcolors->name[0] );
form_alert( 1, test );

sprintf( test, "[1][name1: %x][OK]", wcolors->name[1] );
form_alert( 1, test );

sprintf( test, "[1][info0: %x][OK]", wcolors->info[0] );
form_alert( 1, test );

sprintf( test, "[1][ info1: %x][OK]", wcolors->info[1] );
form_alert( 1, test );

sprintf( test, "[1][sizer0: %x][OK]", wcolors->sizer[0] );
form_alert( 1, test );

sprintf( test, "[1][sizer1: %x][OK]", wcolors->sizer[1] );
form_alert( 1, test );

sprintf( test,"[1][closer0: %x][OK]", wcolors->closer[0] );
form_alert( 1, test );

sprintf( test, "[1][closer1: %x][OK]", wcolors->closer[1] );
form_alert( 1, test );

sprintf( test, "[1][fuller0: %x][OK]", wcolors->fuller[0] );
form_alert( 1, test );

sprintf( test,"[1][fuller1: %x][OK]", wcolors->fuller[1] );
form_alert( 1, test );

sprintf( test,"[1][vbar: %x][OK]", wcolors->vbar );
form_alert( 1, test );

sprintf( test,"[1][uparrow0: %x][OK]", wcolors->uparrow[0] );
form_alert( 1, test );

sprintf( test, "[1][uparrow1: %x][OK]", wcolors->uparrow[1] );
form_alert( 1, test );

sprintf( test,"[1][dnarrow0: %x][OK]", wcolors->dnarrow[0] );
form_alert( 1, test );

sprintf( test,"[1][dnarrow1: %x][OK]", wcolors->dnarrow[1] );
form_alert( 1, test );

sprintf( test,"[1][vslid0: %x][OK]", wcolors->vslid[0] );
form_alert( 1, test );

sprintf( test,"[1][vslid1: %x][OK]", wcolors->vslid[1] );
form_alert( 1, test );

sprintf( test,"[1][velev0: %x][OK]", wcolors->velev[0] );
form_alert( 1, test );

sprintf( test,"[1][velev1: %x][OK]", wcolors->velev[1] );
form_alert( 1, test );

sprintf( test,"[1][hbar: %x][OK]", wcolors->hbar );
form_alert( 1, test );

sprintf( test,"[1][lfarrow0: %x][OK]", wcolors->lfarrow[0] );
form_alert( 1, test );

sprintf( test,"[1][lfarrow1: %x][OK]", wcolors->lfarrow[1] );
form_alert( 1, test );

sprintf( test,"[1][rtarrow0: %x][OK]", wcolors->rtarrow[0] );
form_alert( 1, test );

sprintf( test,"[1][rtarrow1: %x][OK]", wcolors->rtarrow[1] );
form_alert( 1, test );

sprintf( test,"[1][hslid0: %x][OK]", wcolors->hslid[0] );
form_alert( 1, test );

sprintf( test,"[1][hslid1: %x][OK]", wcolors->hslid[1] );
form_alert( 1, test );

sprintf( test,"[1][helev0: %x][OK]", wcolors->helev[0] );
form_alert( 1, test );

sprintf( test,"[1][helev1: %x][OK]", wcolors->helev[1] );
form_alert( 1, test );
}
#endif
