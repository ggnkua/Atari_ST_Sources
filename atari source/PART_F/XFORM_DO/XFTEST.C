/* xftest.c - test program for xform_do
 *
 * 900129 kbad
 */

#include <stdlib.h>
#include <sys\gemskel.h>
#include <sys\gemerror.h>
#include "xftest.h"

WORD	xform_do( WINFO *w, WORD start_field, WORD puntmsg[] );

#define KIND NAME|CLOSER|FULLER|MOVER|INFO|SIZER|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE

OBJECT	*tree;
int		nwindows;

char	edit1[8],edit2[8],edit3[8];


BOOLEAN
rsrc_init( void )
{
	if( rsrc_load( "xftest.rsc" ) ) {
		rsrc_gaddr( R_TREE, DIAL, &tree );

		TedText(EDIT1) = edit1;
		TedText(EDIT2) = edit2;
		TedText(EDIT3) = edit3;

		rsrc_gaddr( R_TREE, MENU, &menu );
		menu_bar( menu, TRUE );
		graf_mouse( ARROW, NULL );
		return TRUE; /* Resource is okay */
	}

	return FALSE;
}


/*
 * create new window containing form `tree'
 * set *pw to point to new WINFO struct
 * return E_OK, ENHNDL if no handles free or ENSMEM if not enuf mem.
 */
WORD
new_window( WINFO **pw, OBJECT *tree )
{
	GRECT	maxwork;
static char *title = " A Form ";
static char *info = "  An Info Line";

	Wind_calc( WC_WORK, KIND, &desk, &maxwork );
/*	maxwork.g_x += nwindows * gl_wbox;*/
/*	maxwork.g_y += nwindows * gl_hbox;*/

	ObX(ROOT) = maxwork.g_x;
	ObY(ROOT) = maxwork.g_y;

	if( ObW(ROOT) > maxwork.g_w || ObH(ROOT) > maxwork.g_h ) {
		maxwork = desk;
	} else {	
		Wind_calc( WC_BORDER, KIND, &ObRect(ROOT), &maxwork );
	}

	return make_window( pw, &maxwork, &maxwork, KIND, title, info,
				 gl_wchar, gl_hchar,
				 ObW(ROOT)/gl_wchar, ObH(ROOT)/gl_hchar, tree );
}



void
do_menu( const int *msg, int *event )
{
	WORD 	ret;
	WORD	puntmsg[8];
	WINFO 	*w;

	menu_tnormal( menu, MnTitle(msg), TRUE );
	switch( MnItem(msg) ) {
		case TEST:
			ret = new_window( &w, tree );
			if( ret == (int)ENHNDL ) {
				form_alert( 1, "[1][Sorry, no more windows| are available.|Please close one| you aren't using.][ OK ]" );
			} else if( ret == (int)ENSMEM ) {
				form_alert( 1, "[1][Sorry, not enough| free memory for| another window.][ OK ]" );
			} else {
				++nwindows;
				ObX(ROOT) = w->work.g_x;
				ObY(ROOT) = w->work.g_y;
				redraw( w, &w->work );
				do {
					ret = xform_do( w, 0, puntmsg );
					if( ret == -1 ) {
						switch( MsgType(puntmsg) ) {
							case MN_SELECTED:
								do_menu( (int *)puntmsg, event );
								if( *event == 0 ) {
									ret = 0;
								} else {
									wind_get( 0, WF_TOP, &ret );
									w = id_2winfo( ret );
									if( w == NULL ) {
										form_alert( 1, "[3][Error topping window][ OK ]" );
										ret = *event = 0;
									} else {
										ObX(ROOT) = w->work.g_x;
										ObY(ROOT) = w->work.g_y;
										ret = -1;
									}
								}
							break;

							case WM_TOPPED:
							case WM_NEWTOP:
								w = id_2winfo( WmId(puntmsg) );
								if( w == NULL ) {
									form_alert( 1, "[3][Error topping window][ OK ]" );
									ret = *event = 0;
								}
								wind_set( w->id, WF_TOP );
								ObX(ROOT) = w->work.g_x;
								ObY(ROOT) = w->work.g_y;
							break;

							case WM_CLOSED:
								wind_close( w->id );
								wind_unlink( w );
								wind_delete( w->id );
								free( w );
								--nwindows;
								ret = 0;
							break;
						}
					} else {
						wind_close( w->id );
						wind_unlink( w );
						wind_delete( w->id );
						free( w );
					}
				} while( ret == -1 );
				Deselect(ret & 0x7fff);
			}
		break;

		case QUIT:
			*event = 0;
		break;
	}

}


void
wind_shifted( const WINFO *w )
{
	OBJECT	*tree;
	GRECT	rect;
	
	rect = w->work;
	wind_adjust( w, &rect );
	tree = (OBJECT *)(w->x);
	ObX(ROOT) = rect.g_x - w->vir.g_x * gl_wchar;
	ObY(ROOT) = rect.g_y - w->vir.g_y * gl_hchar;
}

BOOLEAN
wind_out( const int *msg, WINFO *w )
{
	OBJECT *tree;


	switch( MsgType(msg) ) {
		case WM_MOVED:
			tree = (OBJECT *)(w->x);
			ObX(ROOT) = w->work.g_x;
			ObY(ROOT) = w->work.g_y;
		break;
	}

	return FALSE; /* don't quit the application */
}

void
redraw( const WINFO *w, GRECT *clip )
{
	OBJECT	*tree;
	int		savex, savey;
	GRECT	rect;
	int		pxy[4];

	rect = w->work;
	wind_adjust( w, &rect );
	rc_2xy( clip, (WORD *)pxy );
	vs_clip( vhandle, 1, pxy );

	graf_mouse( M_OFF, NULL );
#if SILLY_PATTERN
	vsf_interior( vhandle, FIS_PATTERN );
	vsf_style( vhandle, 19 ); /* balls */
	vsf_color( vhandle, BLACK );
#else
	vsf_interior( vhandle, FIS_SOLID );
	vsf_color( vhandle, WHITE );
#endif
	vsf_perimeter( vhandle, FALSE );
	vswr_mode( vhandle, MD_REPLACE );
	v_bar( vhandle, pxy );
	graf_mouse( M_ON, NULL );

	tree = (OBJECT *)(w->x);
	savex = ObX(ROOT);
	savey = ObY(ROOT);

	ObX(ROOT) = rect.g_x - w->vir.g_x * gl_wchar;
	ObY(ROOT) = rect.g_y - w->vir.g_y * gl_hchar;
	Objc_draw( tree, ROOT, MAX_DEPTH, clip );
	ObX(ROOT) = savex;
	ObY(ROOT) = savey;

}



void
wind_exit( void )
{
	WINFO	*w = window1, *pw;
	while( w ) {
		wind_close( w->id );
		wind_delete( w->id );
		w = (pw=w)->next;
		free( pw );
	}
}


void
rsrc_exit( void )
{
	rsrc_free();
}
