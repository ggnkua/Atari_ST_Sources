/* deskedit.c - main module of desk accessory editor
 * using gemskel.c application skeleton, with textwind.c window manager.
 * Copyright 1990, Atari Corporation
 * ================================================================
 * 900125 kbad Split off unused functions into UNUSED.C,
 *				cleaned up comments a bit.
 * 890723 kbad Revamped text handling, split text and file functions
 *				off into another module.
 * 890709 kbad Created
 */

#include <sys\gemskel.h>	/* gets aes, aesalt, stddef, vdi */
#include <string.h>		/* strcpy, etc */
#include <ctype.h>
#include <stdio.h>		/* printf */
#include <stdlib.h>		/* free */
#include <sys\vdikeys.h>
#include <sys\gemerror.h>
#include "deskedit.h"

#define EDIT 1

#if EDIT
#define EVENTS	MU_MESAG|MU_BUTTON|MU_KEYBD|MU_TIMER
#else
#define EVENTS	MU_MESAG|MU_BUTTON|MU_KEYBD
#endif

/* local stuff
 * ================================================================
 */
static int 		new_window( void );
/* 				gimme a new window...
 */
static void		eat_events( void );
/* 				Suck up some events
 */
static void		wait_bup( void );
/*				Wait for buttons to come up
 */


/* GEMSKEL functions
 * ================================================================
 */


void
wind_init( void )
{
	int		i;

	vst_alignment( vhandle, VST_LEFT, VST_TOP, &i, &i );

	i = new_window();
	if( i ) gem_exit( i );
}


void
evnt_init( void )
{
	evnt_set( EVENTS, 1, 1, 1, NULL, NULL, 200L );
}


/* Parameter 'event' is unused in do_timer() */
#pragma warn -par

void
do_timer( int *event )
{
	int 	id;
	WINFO	*w;
/*
 * flash the cursor in the top window
 */
	wind_get( 0, WF_TOP, &id );
	if( id <= 0 ) return;
	if( (w = id_2winfo(id)) == NULL ) return;
	draw_cursor( w, &w->work );
}


/* Parameters 'kstate' and 'event' are unused in do_key() */

void
do_key( int kstate, int key, int *event )
{
	int		i, msg[8];
	WINFO	*w = NULL;
	int		junk[8];

	for( i=0; i<8; i++ ) msg[i] = 0;


	wind_get( 0, WF_TOP, &i );
	if( i > 0 )
		w = id_2winfo(i);
	i = -1;


printf("\033Hkey=0x%4x\n",key);
	switch( key ) {

		/*
		 * quit keys
		 */
		case KC_Q:
		case KS_F10:
			key = *event = 0;
		break;

		/*
		 * arrow keys move window contents
		 */
		case K_UP:		i = WA_UPLINE; key = 0; break;
		case K_DOWN:	i = WA_DNLINE; key = 0; break;
		case K_LEFT:	i = WA_LFLINE; key = 0; break;
		case K_RIGHT:	i = WA_RTLINE; key = 0; break;
		case KS_UP:		i = WA_UPPAGE; key = 0; break;
		case KS_DOWN:	i = WA_DNPAGE; key = 0; break;
		case KS_LEFT:	i = WA_LFPAGE; key = 0; break;
		case KS_RIGHT:	i = WA_RTPAGE; key = 0; break;

		/*
		 * cursor cluster keys that map to spurious ASCII values
		 */
		case KS_INSERT:
		case KS_HOME:
		break;

		/*
		 * select window
		 */
		case KC_W:
			if( w ) {
				if( w->next != NULL )
					i = w->next->id;
				else
					i = window1->id;
			}
			wind_set( i, WF_TOP );
			key = 0;
			i = -1;
		break;

		/*
		 * keypad keys move window
		 */
		case KC_NSTAR:
			if( w ) {
				msg[0] = WM_FULLED;
			}
			key = 0;
		break;
		case KC_N8:
			if( w ) {
				*(GRECT *)&msg[4] = w->r;
				msg[5] -= gl_hbox;
				if( msg[5] > desk.g_y )
					msg[0] = WM_MOVED;
			}
			key = 0;
		break;
		case KC_N2:
			if( w && (w->r.g_y < (desk.g_y + desk.g_h - gl_hbox)) ) {
				*(GRECT *)&msg[4] = w->r;
				msg[5] += gl_hbox;
				msg[0] = WM_MOVED;
			}
			key = 0;
		break;
		case KC_N4:
			if( w ) {
				*(GRECT *)&msg[4] = w->r;
				msg[4] -= gl_wbox;
				if( msg[4] > desk.g_x )
					msg[0] = WM_MOVED;
			}
			key = 0;
		break;
		case KC_N6:
			if( w && (w->r.g_x < (desk.g_x + desk.g_w - 2*gl_wbox)) ) {
				*(GRECT *)&msg[4] = w->r;
				msg[4] += gl_wbox;
				msg[0] = WM_MOVED;
			}
			key = 0;
		break;

		default:
#if EDIT
			i = key & 0xff;
#else
			key = 0;
#endif
	}

	if( key ) {
		if( isprint(i) && w != NULL )
			insert_char( i, w );
	} else if( i >= 0 && w != NULL ) {
		wind_arrowed( i, w );
	} else if( msg[0] ) {
		msg[1] = gl_apid;
		msg[2] = 0;
		msg[3] = w->id;
		appl_write( gl_apid, 16, msg );
	}

while( Evnt_multi( MU_KEYBD|MU_TIMER,0,0,0,
					(MOBLK *)junk, (MOBLK *)junk,
					junk, 0L, (MRETS *)junk, junk, junk ) != MU_TIMER );


}


/* Parameters 'nclicks' and 'event' are unused in do_button() */

void
do_button( MRETS *mrets, int nclicks, int *event )
{
	WINFO	*w;
	int		id = 0;

	id = wind_find( mrets->x, mrets->y );

	if( id <= 0 || (w = id_2winfo(id)) == NULL )
		return;

	wait_bup();
	if( xy_inrect(mrets->x, mrets->y, &w->work) )
		id = new_window();
#if BUTT_DEBUG
	else
		eat_events();
#endif

	if( id == (int)ENHNDL )
		form_alert( 1, "[1][Sorry, no more windows| are available.|Please close one| you aren't using.][ OK ]" );

}

#pragma warn .par


void
draw_cursor( const WINFO *w, GRECT *clip )
{
	GRECT	edit, rect;
	int 	pxy[4], clipxy[4];

	edit.g_x = w->vir.g_x;
	edit.g_y = w->vir.g_y;
	edit.g_w = w->phy.g_w;
	edit.g_h = w->phy.g_h;
	if( xy_inrect( WXedx(w), WXedy(w), &edit ) ) {
		rect = w->work;
		wind_adjust( w, &rect );
		pxy[0] = pxy[2] = rect.g_x + (WXedx(w) - edit.g_x) * w->wchar;
		pxy[1] = rect.g_y + (WXedy(w) - edit.g_y) * w->wchar;
		pxy[3] = pxy[1] + w->hchar - 1;
		vswr_mode( vhandle, MD_XOR );
		rc_2xy( clip, clipxy );
		vs_clip( vhandle, 1, clipxy );
		graf_mouse( M_OFF, NULL );
		v_pline( vhandle, 2, pxy );
		graf_mouse( M_ON, NULL );
	}
}


void
redraw( const WINFO *w, GRECT *clip )
{
	int		pxy[4], delta;
	int		startcol, maxcol, rightcol;
	int		row, maxrow;
	GRECT	rect;
	TLINE	*tl;

	rect = w->work;
	wind_adjust( w, &rect );

	rc_2xy( clip, pxy );
	vs_clip( vhandle, 1, pxy );

	graf_mouse( M_OFF, NULL );
	vsf_interior( vhandle, FIS_SOLID );
	vsf_color( vhandle, WHITE );
	vswr_mode( vhandle, MD_REPLACE );
	v_bar( vhandle, pxy );

	vst_point( vhandle, WXfont(w), &delta, &delta, &delta, &delta );

	delta = clip->g_x - rect.g_x;
	if( delta < 0 ) delta = 0;
	startcol = w->vir.g_x + delta/w->wchar;
	maxcol = w->vir.g_x + ((delta + clip->g_w)/w->wchar);
/* set rightmost column such that VDI doesn't clip
 * at the right window boundary
 */
	rightcol = w->vir.g_x + w->phy.g_w /*- ((rect.g_w % w->wchar) < 2)*/;
	if( maxcol > w->vir.g_w ) maxcol = w->vir.g_w;
	rect.g_x += (startcol - w->vir.g_x) * w->wchar;

	delta = clip->g_y - rect.g_y;
	if( delta < 0 ) delta = 0;
	row = w->vir.g_y + delta/w->hchar;
	maxrow = w->vir.g_y + ((delta + clip->g_h)/w->hchar) + 1;
	if( maxrow > w->vir.g_h ) maxrow = w->vir.g_h;
	rect.g_y += (row - w->vir.g_y) * w->hchar;

	if( w->hchar != gl_hchar ) /* compensate char cell for 8x8 font */
		++rect.g_y;

/*
 * Figure out what line we're supposed to start drawing,
 * draw 'em all, then draw the cursor.
 */
	tl = vy_2line( w, row );

	while( row < maxrow ) {
		if( tl->vs ) /* any chars on this line? */
			vs_draw( rect.g_x, rect.g_y, tl->vs, w->wchar,
						startcol, maxcol, rightcol );
		tl = tl->next;
		rect.g_y += w->hchar;
		++row;
	}
#if EDIT
	draw_cursor( w, clip );
#endif

	graf_mouse( M_ON, NULL );
}


void
wind_adjust( const WINFO *w, GRECT *rect )
{
	rect->g_x += w->wchar/2;
	rect->g_w -= w->wchar/2;
}


BOOLEAN
wind_out( const int *msg, WINFO *w )
{
	BOOLEAN islast = FALSE;

	if( msg[0] == WM_CLOSED ) {
		wind_delete( w->id );
	/*
	 * unlink and get rid of his WINFO struct
	 */
		islast = wind_unlink( w );
		free_tlines( WXline0(w) );
		free( w->x );
		free( w );
	}
	return islast; /* quit if last window closed */
}


void
wind_exit( void )
{
	WINFO	*w = window1, *pw;
	while( w ) {
		wind_close( w->id );
		wind_delete( w->id );
		w = (pw=w)->next;
		free_tlines( WXline0(pw) );
		free( pw->x );
		free( pw );
	}
}


/* ================================================================
 * DESKEDIT functions
 */


int
new_window( void )
{
	WX		*wx;
	WINFO	*w;
	int		ret, kind, wchar, hchar, vw, vh;
	char	*ppath, name[14], info[81];

	/*
	 * First, see if any more windows are available
	 */
	if( (ret = wind_create(0,0,0,0,0)) < 0 )
		return (int)ENHNDL; /* no more handles */
	wind_delete( ret );

	/*
	 * Then read in the file, set up the window, and make it.
	 */
	ret = open_file( &wx, &vw, &vh );
	if( ret ) return ret;

	kind = 0xFFF;
	if( (ppath = strrchr( wx->name, '\\' )) == NULL )
		ppath = wx->name;
	else ++ppath;
	strcpy( name, ppath );
	strcpy( info, " Click inside window to open a new one.");

	wx->font = 8 + form_alert(1,"[2][ What size font? ][ Small | Large ]");
	vst_point( vhandle, wx->font, &ret, &ret, &wchar, &hchar );

	if( wx->font == 9 ) /* make some room around the 8x8 font */
		hchar += 2;

	graf_mouse( BUSYBEE, NULL );
	ret = make_window( &w, NULL, NULL, kind, name, info,
						wchar, hchar, vw, vh, wx );
	graf_mouse( ARROW, NULL );

	if( ret ) {
		free_tlines( wx->line0 );
		free( wx );
	}

	return ret;
}


/* eat_events()
 * ================================================================
 * Eat all events so that fast clicking doesn't blow us out
 * of the water
 */
void
eat_events( void )
{
	int i, junk[8];

	do { for( i = 0; i < 8; ++i ) junk[i] = 0; }
	while( Evnt_multi(0x3f, 1, 1, 1, (MOBLK *)junk, (MOBLK *)junk,
					junk, 0L, (MRETS *)junk, junk, junk ) != MU_TIMER );
}

/* wait_bup()
 * ================================================================
 * Wait until all mouse buttons are up.
 */
void
wait_bup( void )
{
    MRETS mk;
    do { Graf_mkstate( &mk ); } while( mk.buttons != 0 );
}
