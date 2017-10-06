/*
 * Auth : Dominique B‚r‚ziat, 1996 - 2000
 *        This file is a part of WinDom Developer Kit
 * File : WIN-FRAME.C
 * Desc : Full example of a frame windows.
 */

#include <stdlib.h>
#include <windom.h>
#include "demo.h"
#include "global.h"

/* external functions
 */
char *get_string( int);

struct pat8bit {
	unsigned b1:1;
	unsigned b2:1;
	unsigned b3:1;
	unsigned b4:1;
	unsigned b5:1;
	unsigned b6:1;
	unsigned b7:1;
	unsigned b8:1;
} ;

struct pat8bit
	 atarilogo[] = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
					 0,0,0,0,0,1,0,1,1,0,1,0,0,0,0,0,
					 0,0,0,0,0,1,0,1,1,0,1,0,0,0,0,0,
					 0,0,0,0,0,1,0,1,1,0,1,0,0,0,0,0,
					 0,0,0,0,0,1,0,1,1,0,1,0,0,0,0,0,
					 0,0,0,0,1,1,0,1,1,0,1,1,0,0,0,0,
					 0,0,0,0,1,1,0,1,1,0,1,1,0,0,0,0,
					 0,0,0,1,1,1,0,1,1,0,1,1,1,0,0,0,
					 0,0,1,1,1,0,0,1,1,0,0,1,1,1,0,0,
					 0,1,1,1,1,0,0,1,1,0,0,1,1,1,1,0,
					 0,1,1,1,0,0,0,1,1,0,0,0,1,1,1,0,
					 0,1,1,1,0,0,0,1,1,0,0,0,1,1,1,0,
					 0,1,1,0,0,0,0,1,1,0,0,0,0,1,1,0,
					 0,1,0,0,0,0,0,1,1,0,0,0,0,0,1,0,
					 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
					 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

/*
 * A WM_REDRAW mevent function of a framed window :
 * it is identic to a standard window. The function
 * just draw a textured ellipse.
 */
 
void draw_frame( WINDOW *win) {
/* MODIF_ARNAUD pour GCC32 */
	INT16 x,y,w,h;
	int *img;
	
	WindClear( win);
	WindGet( win, WF_WORKXYWH, &x, &y, &w, &h);
	vsf_interior( win->graf.handle, FIS_USER);
	rsrc_gaddr( 4, PATTERN1,  &img);
/* MODIF_ARNAUD pour GCC32 */
	vsf_udpat( win->graf.handle, (INT16*)atarilogo, 1);
	v_ellipse( win->graf.handle, x+w/2, y+h/2, w/2, h/2);
}

/*
 *	A example of a frame window containing two frames
 */

void create_two_frame(void) {
	WINDOW *win, *frame;
	
	/* Create the root window */
	win = FrameCreate( MOVER|NAME|CLOSER|SMALLER);
	/* give a title to the window */
	WindSetStr( win, WF_NAME, get_string( FRAME_TITLE));
	/* adjust some specific frame parameters */
	FrameSet( win, FRAME_BORDER, param.FrameWidth);
	FrameSet( win, FRAME_COLOR, param.FrameColor);
	FrameSet( win, FRAME_NOBG, 1, 0);
	 
	/* framed window are initally standard window that
	 * we create normally */
	frame = WindCreate( WAT_NOINFO-SIZER, app.x, app.y, app.w, app.h);
	EvntAttach( frame, WM_REDRAW, draw_frame);
	/* the window is attached to the root window */
	FrameAttach( win, frame, 0, 0, 50, 100, FRAME_WSCALE|FRAME_SELECT);
	
	/* a second frame ... */
	frame = WindCreate( WAT_NOINFO, app.x, app.y, app.w, app.h);
	EvntAttach( frame, WM_REDRAW, draw_frame);
	FrameAttach( win, frame, 0, 1, 50, 100, FRAME_WSCALE|FRAME_SELECT);

	/* set the max height of the root window */
	win -> h_max = 200;
	/* open the root window */
	WindOpen( win, -1, -1, 200, 100);
}

/*
 *	A example of a frame window containing three frames
 */

void create_three_frame(void) {
	WINDOW *win, *frame;
	
	win = FrameCreate( MOVER|NAME|CLOSER|SMALLER);
	WindSetStr( win, WF_NAME, get_string( FRAME_TITLE));
	FrameSet( win, FRAME_BORDER, param.FrameWidth);
	FrameSet( win, FRAME_COLOR, param.FrameColor);

	frame = WindCreate( WAT_NOINFO-SIZER, app.x, app.y, app.w, app.h);
	EvntAttach( frame, WM_REDRAW, draw_frame);
	FrameAttach( win, frame, 0, 0, 50, 100, FRAME_WSCALE|FRAME_SELECT);
	
	frame = WindCreate( WAT_NOINFO-SIZER, app.x, app.y, app.w, app.h);
	EvntAttach( frame, WM_REDRAW, draw_frame);
	FrameAttach( win, frame, 0, 1, 50, 100, FRAME_WSCALE|FRAME_SELECT);

	frame = WindCreate( WAT_NOINFO, app.x, app.y, app.w, app.h);
	EvntAttach( frame, WM_REDRAW, draw_frame);
	FrameAttach( win, frame, 1, 0, 100, 100, FRAME_WSCALE|FRAME_SELECT);

	win -> h_max = 400;
	WindOpen( win, -1, -1, 200, 200);
}

