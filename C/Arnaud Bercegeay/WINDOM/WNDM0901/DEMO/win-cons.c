/*
 * Auth : Dominique B‚r‚ziat, 1996 - 2000
 *        This file is a part of WinDom Developer Kit
 * File : WIN-CONS.C
 * Desc : Window construction
 */

#include <stddef.h>
#include <stdlib.h>
#include <windom.h>
#include "global.h"
#include "demo.h"

/* external function
 */
char *get_string( int);
OBJECT *get_tree( int);
void stdDESTROY( WINDOW *);
void create_infos( WINDOW *, int, int);

/*
 *	Formular 'widget'
 */

void do_form_widget( WINDOW *win) {
/* MODIF_ARNAUD pour GCC32 */
	INT16 x, y, w, h;
	
	switch( evnt.buff[4]) {
	case ATTR_ANNUL:
		ApplWrite( app.id, WM_CLOSED, win->handle, 0, 0, 0, 0);
		ObjcChange( OC_FORM, win, evnt.buff[4], NORMAL, 1);
		break;
	case ATTR_OK:
		ApplWrite( app.id, WM_CLOSED, win->handle, 0, 0, 0, 0);
	case ATTR_APPL:
		ObjcChange( OC_FORM, win, evnt.buff[4], NORMAL, 1);
		WindGet( param.winuser, WF_CURRXYWH, &x, &y, &w, &h);
		if( FORM(win)[ATTR_CLOSER].ob_state & SELECTED)
			param.winuser -> attrib |= CLOSER;
		else
			param.winuser -> attrib &= ~CLOSER;
		if( FORM(win)[ATTR_NAME].ob_state & SELECTED)
			param.winuser -> attrib |= NAME;
		else
			param.winuser -> attrib &= ~NAME;
		if( FORM(win)[ATTR_INFO].ob_state & SELECTED)
			param.winuser -> attrib |= INFO;
		else
			param.winuser -> attrib &= ~INFO;
		if( FORM(win)[ATTR_SMALLER].ob_state & SELECTED)
			param.winuser -> attrib |= SMALLER;
		else
			param.winuser -> attrib &= ~SMALLER;
		if( FORM(win)[ATTR_SIZER].ob_state & SELECTED)
			param.winuser -> attrib |= SIZER;
		else
			param.winuser -> attrib &= ~SIZER;
		if( FORM(win)[ATTR_FULLER].ob_state & SELECTED)
			param.winuser -> attrib |= FULLER;
		else
			param.winuser -> attrib &= ~FULLER;
			
		if( FORM(win)[ATTR_HSLIDER].ob_state & SELECTED)
			param.winuser -> attrib |= HSLIDE;
		else
			param.winuser -> attrib &= ~HSLIDE;
		if( FORM(win)[ATTR_VSLIDER].ob_state & SELECTED)
			param.winuser -> attrib |= VSLIDE;
		else
			param.winuser -> attrib &= ~VSLIDE;
		WindClose( param.winuser);
		wind_delete( param.winuser->handle);
		param.winuser->handle = wind_create( param.winuser->attrib,app.x,app.y,app.w,app.h);
		WindOpen( param.winuser, x, y, w, h);
		break;
	}
}

/*
 *  Formular 'Extra'
 */

	/* SEE WIN-CUST.C */

typedef struct {
	int color;		/* color or pattern */
	int type;		/* SQUARE, ELLIPSE or CIRCLE */
	int bckgrd;		/* background color */
} DRAW;

void timer_custom( WINDOW *win);
void draw_custom ( WINDOW *win);
void menu_custom( WINDOW *win);

	/* ------------- */

void do_form_extra( WINDOW *win) {	
	switch( evnt.buff[4]) {
	case EXTRA_ANNUL:
		ApplWrite( app.id, WM_CLOSED, win->handle, 0, 0, 0, 0);
		ObjcChange( OC_FORM, win, evnt.buff[4], NORMAL, 1);
		break;
	case EXTRA_OK:
		ApplWrite( app.id, WM_CLOSED, win->handle, 0, 0, 0, 0);
	case EXTRA_APPL:
		ObjcChange( OC_FORM, win, evnt.buff[4], NORMAL, 1);
		if( FORM(win)[EXTRA_GROW].ob_state & SELECTED)
			param.winuser->status |= WS_GROW;
		else
			param.winuser->status &= ~WS_GROW;
		if( FORM(win)[EXTRA_RIEN].ob_state & SELECTED)
			EvntAttach( param.winuser, WM_REDRAW, WindClear);
		if( FORM(win)[EXTRA_TIMER].ob_state & SELECTED) {
			EvntAttach( param.winuser, WM_XTIMER, timer_custom);
			EvntAttach( param.winuser, WM_REDRAW, draw_custom);
			param.winuser->data = (DRAW*)malloc(sizeof(DRAW));
			((DRAW*)param.winuser->data)->bckgrd = 2;
			((DRAW*)param.winuser->data)->type = 2;
			((DRAW*)param.winuser->data)->color = 0;
			if( param.winuser->status & WS_MENU)
				EvntAttach( param.winuser, WM_MNSELECTED, menu_custom);
		}
		if( FORM(win)[EXTRA_FORM].ob_state & SELECTED)
		{
			OBJECT *tree;
			
			rsrc_gaddr( 0, DIAL2, &tree);
				
		}
		break;
	}
}

/*
 *	WM_CLOSER event function of contruct windows
 */

void CloserUser( WINDOW *win) {
	void std_cls( WINDOW *); /* WinDom standard event function, not
                              * defined in windom.h */

	/*	res = form_alert( 1,"[2][ Terminer la construction? ][ Oui | Non]"); */
	if( form_alert( 1, get_string(ALRT_END_CONS)) == 1) {
		param.winuser = NULL;
		app.menu[MN1_ATTR].ob_state |= DISABLED;
		app.menu[MN1_MENU].ob_state |= DISABLED;
		app.menu[MN1_TOOL].ob_state |= DISABLED;
		app.menu[MN1_END].ob_state  |= DISABLED;
		app.menu[MN1_EXTRA].ob_state |= DISABLED;
		app.menu[MN1_CREATE].ob_state &= ~DISABLED;
		EvntAttach( win, WM_CLOSED, std_cls);
	}
}

void create_form_widget( void) {
	WINDOW *win = FormCreate( get_tree(ATTRIBUT), 
						  	  MOVER|NAME|SMALLER, 
						  	  do_form_widget, 
						  	  get_string( BUILD_TITLE), NULL, 1, 0);
	create_infos( win, INFOS_FORM, ATTRIBUT);
}

void create_form_extra( void) {
	WINDOW *win = FormCreate( get_tree(EXTRA), 
					 		  MOVER|NAME|SMALLER, 
					 		  do_form_extra, 
					 		  get_string( BUILD_TITLE), NULL, 1, 0);
	create_infos( win, INFOS_FORM, EXTRA);
}

void create_construct_window( void) {
	param.winuser = WindCreate( MOVER, app.x, app.y, app.w, app.h);
	EvntAdd	( param.winuser, WM_DESTROY, stdDESTROY, EV_TOP);
	WindOpen( param.winuser, app.x + app.w/5, app.y + app.w/5, 3*app.w/5, 3*app.h/5);
	app.menu[MN1_ATTR].ob_state &= ~DISABLED;
	app.menu[MN1_MENU].ob_state &= ~DISABLED;
	app.menu[MN1_TOOL].ob_state &= ~DISABLED;
	app.menu[MN1_END].ob_state &= ~DISABLED;
	app.menu[MN1_EXTRA].ob_state &= ~DISABLED;
	app.menu[MN1_CREATE].ob_state |= DISABLED;
	MenuBar( app.menu, 1);
}


/* end of file */
