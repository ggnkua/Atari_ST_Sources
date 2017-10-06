/*
 * Auth : Dominique B‚r‚ziat, 1996 - 2000
 *        This file is a part of WinDom Developer Kit
 * File : WIN-CUST.C
 * Desc : Full example of a customized window.
 *        The window contains a menu, the work area
 *        displays geometric forms. A timer is applied
 *        to the window to change its contain.
 */

#include <stdlib.h>
#include <windom.h>
#include "demo.h"
#include "global.h"

/* external functions
 */
void display_info ( WINDOW*, int);
void create_infos( WINDOW*, int, int);
char *get_string( int);

/* First of all, we define the data related to
 * the window.
 */

typedef struct {
	int color;		/* color or pattern */
	int type;		/* SQUARE, ELLIPSE or CIRCLE */
	int bckgrd;		/* background color */
} DRAW;

/* The WM_REDRAW event function. This function is
 * called when the window is drawn.
 * Notice we must not clip the redraw area (this is
 * done by EvntWindom()).
 */

void draw_custom( WINDOW *win) {
/* MODIF_ARNAUD pour GCC32 */
	INT16 x,y,w,h;
	INT16 xy[4];
	DRAW *draw = DataSearch( win, WD_DRAW);
	
	/* get the work area coordinates */
	WindGet( win, WF_WORKXYWH, &x, &y, &w, &h);

	/* Background */
	xy[0] = x;xy[1] = y;xy[2] = x+w-1;xy[3] = y+h-1;
	vsf_interior( win->graf.handle, draw->bckgrd);
	/* color */
	switch( draw->bckgrd){
	case 0:
		vsf_color( win->graf.handle, 0);
		break;
	case 1:
		vsf_color( win->graf.handle, 1);
		break;
	case 2:
		vsf_color( win->graf.handle, 1);
		vsf_style( win->graf.handle, 4);
		break;
	}
	v_bar( win->graf.handle, xy);
	/* style */	
	if( app.color < 16) {
		/* low color resolution */
		vsf_interior( win->graf.handle, 2);
		vsf_style( win->graf.handle, draw->color);
	} else {
		/* high color resolution */
		vsf_interior( win->graf.handle, 1);
		vsf_color( win->graf.handle, draw->color);
	}
	
	/* Foreground */
	switch( draw->type){
	case MN2_SQUARE:
		xy[0] += w/8;
		xy[1] += h/8;
		xy[2] -= w/8;
		xy[3] -= h/8;
		v_bar( win->graf.handle, xy);
		break;
	case MN2_CIRCLE:
		v_circle( win->graf.handle, x+w/2-1,y+h/2-1, MIN(w,h)/3);
		break;
	case MN2_ELLIPSE:
		v_ellipse( win->graf.handle, x+w/2-1,y+h/2-1, w/3, h/3);
		break;
	}
}

/*
 *	MU_TIMER event function.
 *	When a timer event occurs, the function changes
 *  the foreground color.
 */

void timer_custom( WINDOW *win) {
	DRAW *draw = DataSearch( win, WD_DRAW);
	draw->color = ++draw->color % 16;
	snd_rdw( win);
}

/*
 * The WM_DESTROY event function.
 * The function releases the memory, closes,
 * and destroys the window.
 */

void destroy_custom( WINDOW *win) {
	DataDelete( win, WD_DRAW);
}

/*
 * The WM_MNSELECTED event function : the
 * fonction is called when the user selects an
 * item in the menu.
 */

void menu_custom( WINDOW *win) {
	DRAW *draw = DataSearch( win, WD_DRAW);
	int title = evnt.buff[4];	/* keep in memory the
								 * selected menu title */
	
	switch( evnt.buff[5]){
	case MN2_INFO:
		/* Displays info about the window */
		display_info( win, 0);
		break;
	case MN2_CIRCLE:
	case MN2_SQUARE:
	case MN2_ELLIPSE:
		/* Set the pattern */
		draw->type = evnt.buff[5];
		snd_rdw( win);
		break;
		/* Timer control */
	case MN2_FAST:
		evnt.timer = MAX( evnt.timer-300,0);
		break;
	case MN2_SLOW:
		evnt.timer = MIN( evnt.timer+300,10000);
		break;
		/* Set the color */
	case MN2_WHITE:
		draw->bckgrd = 0;
		snd_rdw( win);
		break;
	case MN2_BLACK:
		draw->bckgrd = 1;
		snd_rdw( win);
		break;
	case MN2_GREY:
		draw->bckgrd = 2;
		snd_rdw( win);
		break;
	}

	MenuTnormal( win, title, 1);
/*	snd_rdw( win); */
}


/* Create the window with its attributes */

void create_custom( void) {
	WINDOW *win;
	OBJECT *tree;
	DRAW *draw;
	
	/* Create the window */
	win = WindCreate( NAME|CLOSER|MOVER|SMALLER, app.x, app.y, app.w, app.h);
	/* Attach the menu */
	rsrc_gaddr( 0, MENU2, &tree);
	WindSetPtr( win, WF_MENU, tree, menu_custom);
	/* Give a title to window */
	WindSetStr( win, WF_NAME, get_string( MENU_TITLE));
	/* Attach event functions */
	EvntAttach( win, WM_REDRAW, draw_custom);
	EvntAdd( win, WM_DESTROY, destroy_custom, EV_TOP);
	EvntAttach( win, WM_XTIMER, timer_custom);
	/* Attach data */
	draw = (DRAW*)malloc(sizeof(DRAW));
	draw->bckgrd = 2;
	draw->type   = MN2_SQUARE;
	draw->color  = MN2_WHITE;
	DataAttach( win, WD_DRAW, draw);
	create_infos( win, INFOS_MENU, MENU2);
	/* open the window */
	WindOpen( win, -1, -1, 280, 200);
}
