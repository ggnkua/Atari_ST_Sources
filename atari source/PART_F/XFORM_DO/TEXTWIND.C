/* textwind.c - text window handling for gem application skeleton
 * Copyright 1990, Atari Corporation
 * ================================================================
 * 900201 kbad Changed "fulled" behaviour, added wind_shifted call
 * 900125 kbad Cleaned up comments
 * 890716 kbad Modified to use *event as a quit flag.
 * 890708 kbad Created
 */

#include <sys\gemskel.h>	/* gets aesalt, aes, vdi, stddef */
#include <stdlib.h>		/* malloc(), free() */
#include <string.h>		/* strcpy() */
#include <sys\gemerror.h>
#include <errno.h>


/* External, app-specific stuff (see gemskel.h)
 * ================================================================
 */
void	redraw( const WINFO *w, GRECT *clip );
BOOLEAN	wind_in( int *msg, WINFO *w );
BOOLEAN wind_out( const int *msg, WINFO *w );
void	wind_adjust( const WINFO *w, GRECT *rect );
void	wind_shifted( const WINFO *w );


/* Global stuff defined here (see gemskel.h)
 * ================================================================
 */
WINFO	*window1 = NULL;

int		make_window( WINFO **pwind, GRECT *full, GRECT *open,
					int kind, char *name, char *info,
					int wchar, int hchar, int vw, int vh, void *wx );
void	do_windows( int *msg, int *event );
void	wind_arrowed( int how, WINFO *w );
void	byte_align( WINFO *w, BOOLEAN toright );
void	wind_extent( WINFO *w );
void	wind_sliders( BOOLEAN v, BOOLEAN h, WINFO *w );
void	screenblit( GRECT *clip, GRECT *rs, GRECT *rd );
void	erase_right( WINFO *w );

WINFO	*id_2winfo( int id );
/* return pointer to WINFO whose id matches `id'
 */
BOOLEAN	wind_unlink( WINFO *w );
/* Unlink window `w' from the linked list,
 * Return TRUE if this is the last window.
 */

/* Local stuff
 * ================================================================
 */
static	GRECT	rectstack[MAX_WINDOWS];

/*
 * Slider calculation macros
 */
#define Slider_to_xy( slider, vsize, psize ) \
		(int)( ((long)((vsize)) - (long)((psize)))*( (long)((slider)) )/1000L )
#define XY_to_slider( xy, vsize, psize ) \
		(int)( 1000L * (long)((xy)) / (long)(vsize - psize) )
#define Size_slider( psize, vsize ) \
		(int)( 1000L * ((long)((psize))) / ((long)(vsize)) )


/* ================================================================
 * Global functions
 */

/* make_window()
 * ================================================================
 * Take a WINFO struct, create a window and link it in.
 * If either GRECT is NULL, attempt
 * to come up with a reasonable window position (see below).
 * Returns:
 * AE_OK	(everything's hunky dory)
 * AENHNDL	(no more window handles available)
 * AENSMEM	(not enuf memory for the WINFO)
 */
int
make_window( WINFO **pwind, GRECT *full, GRECT *open,
			int kind, char *name, char *info,
			int wchar, int hchar, int vw, int vh, void *wx )
{
	int		top = 0;
	WINFO	*w, *wp, *wq;
	GRECT	*prect;

	if( (w = calloc(1L, sizeof(WINFO))) == NULL ) return (int)ENSMEM;
	w->kind = kind;

/* try to create it */
	prect = ( full ) ? full : &desk;
	if( (w->id = Wind_create(w->kind, prect)) < 0 ) {
		free( w );
		return (int)ENHNDL; /* no more handles */
	}

/* fill in the WINFO */
	strcpy( w->name, name );
	strcpy( w->info, info );
	w->wchar = wchar;
	w->hchar = hchar;
	w->vir.g_w = vw;
	w->vir.g_h = vh;
	w->x = wx;

/* tack it onto the end of the list */
	if( (wp = window1) == NULL ) window1 = w;
	else {
		while( wp ) wp = (wq=wp)->next;
		wq->next = w;
	}

/* set strings */
	wind_set( w->id, WF_NAME, w->name );
	wind_set( w->id, WF_INFO, w->info );

/* get the size to open */
	if( open ) w->r = *open;
	else {
	/* check the rect stack */
		prect = rectstack;
		if( !rc_empty(prect) ) {
		/* use the size on the stack */
			while( !rc_empty(prect) ) ++prect;
			w->r = *(--prect);
			prect->g_w = prect->g_h = 0;
		} else {
		/* if we have the top window, open downleft of the top guy */
			wind_get( 0, WF_TOP, &top );
			if( (wp = id_2winfo(top)) != NULL ) {
				w->r = wp->r;
				++w->r.g_x;	/* count on byte_align to bump it over */
				w->r.g_y += gl_hbox/2;
		/* otherwise, open it full, less a bit */
			} else {
				if( full )
					w->r = *full;
				else {
					w->r = desk;
					w->r.g_w -= gl_wbox*2;
					w->r.g_h -= gl_hbox*2;
				}
			}
		}
	}

	byte_align( w, YES );
 /* don't open a window with any of the borders hiding */
	if( w->r.g_x + w->r.g_w  > xres ) w->r.g_w = xres - w->r.g_x;
	if( w->r.g_y + w->r.g_h  > yres ) w->r.g_h = yres - w->r.g_y;
	Wind_open( w->id, &w->r );
	wind_extent( w );
	wind_sliders( YES, YES, w );
	*pwind = w;
	return (int)E_OK;
}

/* do_windows()
 * ================================================================
 * Main window message handler, includes app-specific hooks.
 * Sets *event to 0 to quit the application.
 */
void
do_windows( int *msg, int *event )
{
	WINFO	*w;
	GRECT	rect, *prect;
	int		scale;

/* Get the WINFO structure for this window */
	for( w = window1; w && (w->id != msg[3]); w = w->next );
/* Punt if we couldn't find it */
	if( !w ) return;

	if( wind_in(msg, w) ) return;

	switch( msg[0] ) {

	case WM_REDRAW:
	/* get the extent of this redraw */
		prect = (GRECT *)&msg[4];
	/* and the redraw rect */
		Wind_get( w->id, WF_FIRSTXYWH, (WARGS *)&rect );
		while( !rc_empty(&rect) ) {
		/* if we have something to redraw, redraw it */
			if( rc_intersect(prect, &rect) ) redraw( w, &rect );
		/* then get the next redraw rect */
			Wind_get( w->id, WF_NEXTXYWH, (WARGS *)&rect );
		}
		break;

	case WM_TOPPED:
	case WM_NEWTOP:
		wind_set( w->id, WF_TOP );
		break;

	case WM_CLOSED:
	/* save window position */
		prect = rectstack; 
		while( prect < &rectstack[MAX_WINDOWS+1] && !rc_empty(prect) )
			 ++prect;
		w->r = *prect;
	/* close this guy -	he can be deleted in wind_out(), if needed */
		wind_close( w->id );
		break;

	case WM_ARROWED:
		wind_arrowed( msg[4], w );
		break;

	case WM_HSLID:
		scale = w->vir.g_x;
		if( msg[4] == 0 ) {
			w->vir.g_x = 0;
		} else {
			wind_get( w->id, WF_HSLIDE, &scale );
			w->vir.g_x +=
				Slider_to_xy((msg[4]-scale), w->vir.g_w, w->phy.g_w);
		}
		if( w->vir.g_x != scale ) {
			wind_sliders( NO, YES, w );
			redraw( w, &w->work );
		}
		break;

	case WM_VSLID:
		scale = w->vir.g_y;
		if( msg[4] == 0 ) {
			w->vir.g_y = 0;
		} else {
			wind_get( w->id, WF_VSLIDE, &scale );
			w->vir.g_y +=
				Slider_to_xy( (msg[4]-scale), w->vir.g_h, w->phy.g_h );
		}
		if( w->vir.g_y != scale ) {
			wind_sliders( YES, NO, w );
			redraw( w, &w->work );
		}
		break;

	case WM_FULLED:
		/* toggle fulled status, set its position */
		if( w->fulled ) {
			w->r = w->save;
			w->fulled = FALSE;
		} else {
		/* save current position & full it */
			w->save = w->r;
			Wind_get( w->id, WF_FULLXYWH, (WARGS *)&w->r );
			w->fulled = TRUE;
		}

		/* if the _fulled_  size is less than full screen,
		 * leave the x,y coordinates as they were
		 */
		if( w->fulled &&
			(w->r.g_w < desk.g_w && w->r.g_h < desk.g_h) ) {
			w->r.g_x = w->save.g_x;
			w->r.g_y = w->save.g_y;
		}
		byte_align( w, YES );

		Wind_set( w->id, WF_CURRXYWH, (WARGS *)&w->r );
		wind_extent( w );
		wind_sliders( YES, YES, w );
		if( !w->fulled )
			erase_right( w );
		break;

	case WM_SIZED:
	case WM_MOVED:
	/* set window size */
		prect = (GRECT *)&msg[4];
		if( rc_equal( &w->r, prect ) ) break;
		w->fulled = FALSE;
		rect = w->r;
		w->r = *prect;
		byte_align( w, (prect->g_x > rect.g_x) );
		Wind_set( w->id, WF_CURRXYWH, (WARGS *)&w->r );
		wind_extent( w );
		wind_sliders((rect.g_h != prect->g_h), (rect.g_w != prect->g_w), w);
		if( msg[0] == WM_SIZED && rect.g_w > w->r.g_w )
			erase_right( w );
		break;
	}

	if( wind_out( msg, w ) ) *event = 0;
}

/* wind_arrowed()
 * ================================================================
 * Handle WM_ARROWED message
 */
void
wind_arrowed( int how, WINFO *w )
{
	GRECT	clip, rect, dest;
	int 	scale;
	MRETS	mrets;

/*	wind_update( BEG_MCTRL );*/
	clip = w->work;
	wind_adjust( w, &clip );
	do {
		dest = rect = clip;

		switch( how ) {

		case WA_UPPAGE:
			if( w->vir.g_y ) {
				w->vir.g_y -= w->phy.g_h;
				if( w->vir.g_y < 0 ) w->vir.g_y = 0;
				wind_sliders( YES, NO, w );
				redraw( w, &rect );
			}
			break;

		case WA_DNPAGE:
			if( w->vir.g_y < w->vir.g_h - w->phy.g_h ) {
				w->vir.g_y += w->phy.g_h;
				if( w->vir.g_y > (w->vir.g_h - w->phy.g_h) )
					w->vir.g_y = w->vir.g_h - w->phy.g_h;
				wind_sliders( YES, NO, w );
				redraw( w, &rect );
			}
			break;

		case WA_UPLINE:
			if( w->vir.g_y > 0 ) {
				--(w->vir.g_y);
				wind_sliders( YES, NO, w );
				dest.g_h = (rect.g_h -= w->hchar);
				dest.g_y += w->hchar;
				screenblit( &clip, &rect, &dest );
				rect.g_h = w->hchar;
				redraw( w, &rect );
			}
			break;

		case WA_DNLINE:
			if( w->vir.g_y < (w->vir.g_h - w->phy.g_h) ) {
				++(w->vir.g_y);
				wind_sliders( YES, NO, w );
				dest.g_h = (rect.g_h -= w->hchar);
				rect.g_y += w->hchar;
				screenblit( &clip, &rect, &dest );
				scale = w->hchar * (w->phy.g_h - 1);
				rect.g_y = clip.g_y + scale;
				rect.g_h = clip.g_h - scale;
				redraw( w, &rect );
			}
			break;

		case WA_LFPAGE:
			if( w->vir.g_x ) {
				w->vir.g_x -= w->phy.g_w;
				if( w->vir.g_x < 0 ) w->vir.g_x = 0;
				wind_sliders( NO, YES, w );
				redraw( w, &rect );
			}
			break;

		case WA_RTPAGE:
			if( w->vir.g_x < w->vir.g_w - w->phy.g_w ) {
				w->vir.g_x += w->phy.g_w;
				if( w->vir.g_x > (w->vir.g_w - w->phy.g_w) )
					w->vir.g_x = (w->vir.g_w - w->phy.g_w);
				wind_sliders( NO, YES, w );
				redraw( w, &rect );
			}
			break;

		case WA_LFLINE:
			if( w->vir.g_x > 0 ) {
				--(w->vir.g_x);
				wind_sliders( NO, YES, w );
				dest.g_w = (rect.g_w -= w->wchar);
				dest.g_x += w->wchar;
				screenblit( &clip, &rect, &dest );
				rect.g_w = w->wchar;
				redraw( w, &rect );
				erase_right( w );
			}
			break;

		case WA_RTLINE:
			if( w->vir.g_x < (w->vir.g_w - w->phy.g_w) ) {
				++(w->vir.g_x);
				wind_sliders( NO, YES, w );
				dest.g_w = (rect.g_w -= w->wchar);
				rect.g_x += w->wchar;
				screenblit( &clip, &rect, &dest );
				scale = (w->phy.g_w - 1) * w->wchar;
				rect.g_x = clip.g_x + scale;
				rect.g_w = clip.g_w - scale;
				redraw( w, &rect );
			}
			break;
		}

		Graf_mkstate( &mrets );

	} while( mrets.buttons );
/*	wind_update( END_MCTRL );*/
}

/* byte_align()
 * ================================================================
 * Ensure that the drawing coordinates of the window are byte-aligned.
 * This makes v_gtext significantly faster.
 */
void
byte_align( WINFO *w, BOOLEAN toright )
{
	GRECT	rect;

	Wind_calc( WC_WORK, w->kind, &w->r, &rect );
	wind_adjust( w, &rect );
	if( rect.g_x % 8 ) {
		w->r.g_x -= rect.g_x % 8;
		if( toright || w->r.g_x < 0 ) w->r.g_x += 8;
	}
}

/* wind_extent()
 * ================================================================
 * Calculate the physical extent of a window and fill in the
 * w->work and w->phy GRECTs.
 */
void
wind_extent( WINFO *w )
{
	GRECT rect;

	Wind_calc( WC_WORK, w->kind, &w->r, &w->work );
	rect = w->work;
	wind_adjust( w, &rect );
	w->phy.g_h = (rect.g_h)/w->hchar;
	w->phy.g_w = (rect.g_w)/w->wchar;
}

/* wind_sliders()
 * ================================================================
 * Set vertical and/or horizontal window slider positions and
 * sizes, based on physical and virtual coordinates in `w'.
 */
void
wind_sliders( BOOLEAN v, BOOLEAN h, WINFO *w )
{
	int slider;

	if( v ) {
	/* snap to top if display is taller than length of file */
		if( w->vir.g_h < w->phy.g_h )
			w->vir.g_y = 0;
	/* snap to fill window if there's white space at the bottom */
		else if( w->vir.g_y + w->phy.g_h > w->vir.g_h )
			w->vir.g_y = w->vir.g_h - w->phy.g_h;

		wind_set( w->id, WF_VSLSIZE, Size_slider(w->phy.g_h, w->vir.g_h) );
		slider = (w->vir.g_h > w->phy.g_h) ?
					XY_to_slider( w->vir.g_y, w->vir.g_h, w->phy.g_h ) : 0;
		wind_set( w->id, WF_VSLIDE, slider );
	}
	if( h ) {
	/* snap to left if display is wider than widest line */
		if( w->vir.g_w < w->phy.g_w )
			w->vir.g_x = 0;
	/* snap to fill window if there's white space at the right */
		else if( w->vir.g_x + w->phy.g_w > w->vir.g_w )
			w->vir.g_x = w->vir.g_w - w->phy.g_w;
		wind_set( w->id, WF_HSLSIZE, Size_slider(w->phy.g_w, w->vir.g_w) );
		slider = ( w->vir.g_w > w->phy.g_w ) ?
					XY_to_slider( w->vir.g_x, w->vir.g_w, w->phy.g_w ) : 0;
		wind_set( w->id, WF_HSLIDE, slider );
	}

	wind_shifted( w );
}

BOOLEAN
wind_unlink( WINFO *w )
{
	WINFO *wp;

	if( w == window1 ) {
		window1 = w->next;
	} else {
		for( wp = window1; wp->next != w; wp = wp->next );
		wp->next = w->next;
	}
	return ( window1 == NULL );
}

WINFO *
id_2winfo( int id )
{
	WINFO *wp;

	for( wp = window1; wp && wp->id != id; wp = wp->next);
	return wp;
}

void
screenblit( GRECT *clip, GRECT *rs, GRECT *rd )
{
	int pxy[8], clipxy[4];

	rc_2xy( clip, (WORD *)clipxy );
	rc_2xy( rs, (WORD *)pxy );
	rc_2xy( rd, (WORD *)&pxy[4] );

/*	wind_update( BEG_UPDATE );*/
	graf_mouse( M_OFF, NULL );
	vs_clip( vhandle, 1, clipxy );
	vro_cpyfm( vhandle, 3, pxy, &mfdb0, &mfdb0 );
	vs_clip( vhandle, 0, clipxy );
	graf_mouse( M_ON, NULL );
/*	wind_update( END_UPDATE );*/
}

void
erase_right( WINFO *w )
{
	GRECT rect = w->work;
	rect.g_x += rect.g_w - (2 * w->wchar);
	rect.g_w = 2 * w->wchar;
	redraw( w, &rect );
}
