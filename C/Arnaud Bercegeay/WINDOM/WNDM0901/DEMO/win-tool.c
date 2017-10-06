/*
 * Auth : Dominique B‚r‚ziat, 1996 - 2000
 *        This file is a part of WinDom Developer Kit
 * File : WIN-TOOL.C
 * Desc : Example of window with toolbar
 */

#include <stddef.h>
#include <string.h>
#include <windom.h>
#include "global.h"
#include "demo.h"

/* External function
 */
char *get_string( int);
OBJECT *get_tree( int);
void create_infos( WINDOW*, int, int);
void stdDESTROY( WINDOW *);

/* *********************************
 *	A simple window with a toolbar
 * ********************************* */
 

/* The toolbar event function */

void toolbarTOOL1( WINDOW *win) {
	int obj = evnt.buff[4];	/* Selected object */
	
	switch( obj) {
	case TL1_FERM:
		/* Button closing the window */
		ApplWrite( app.id, WM_CLOSED, win->handle, 0, 0, 0, 0);
		break;
	case TL1_POPUP:
		/* Call of a list-popup  */
		{
			char *plist[] = { "item 1 ", "item 2 ", "item 3 ", "item 4 " };
/* MODIF_ARNAUD pour GCC32 */
			INT16 x, y;
			/* remember the previous choice in popup */
			static int prev = -1;
			
			objc_offset( win->tool.root, TL1_POPUP, &x, &y);
			x = MenuPopUp( plist, 
						   x, y, 
						   4, -1, prev, 
						   P_LIST | P_WNDW);
			if( x != -1) {
				prev = x;
				strcpy( ObjcString(TOOL(win), TL1_POPUP, NULL), "  ");
				strcat( ObjcString(TOOL(win), TL1_POPUP, NULL), plist[x-1]);
				ObjcDraw( OC_TOOLBAR, win, TL1_POPUP, 1);
			}
		}
		break;
	}
	
	/* object state to normal and redraw object */
	ObjcChange( OC_TOOLBAR, win, obj, NORMAL, 1);	
}


/* Create the window with the toolbar */

void create_windowtoolbar( void) {
	/* Create the window */
	WINDOW *win = WindCreate( NAME|CLOSER|MOVER|SIZER|FULLER|SMALLER, 
					  		  app.x, app.y, app.w, app.h);
	/* Set the window title */
	WindSetStr( win, WF_NAME, get_string( TOOLBAR_TITLE));
	/* Set the window toolbar */
	WindSetPtr( win, WF_TOOLBAR, get_tree( TOOL1), toolbarTOOL1);
	/* bind some events */
	EvntAdd( win, WM_DESTROY, stdDESTROY, EV_TOP);
	/* initalize info about window */
	create_infos( win, INFOS_TOOL, TOOL1);
	/* Open the window, centered at screen */
	WindOpen( win, -1, -1, app.w/3, app.h/2);
}

/* ****************************************************
 * A second example of window with a toolbar and a menu
 * **************************************************** */

void simpleMENU( WINDOW *win) {
	MenuTnormal( win, evnt.buff[4], 1);
}

void simpleTOOL( WINDOW *win) {
	ObjcChange( OC_TOOLBAR, win, evnt.buff[4], NORMAL, 1);
}

void create_windowtoolmenu( void) {
	/* Create the window */
	WINDOW *win = WindCreate( NAME|CLOSER|MOVER|SMALLER, app.x, app.y, app.w, app.h);
	/* set the menu and the toolbar */
	WindSetPtr( win, WF_MENU, 	  get_tree( MENU2), simpleMENU);
	WindSetPtr( win, WF_TOOLBAR, get_tree( TOOL2), simpleTOOL);
	/* set the window title */
	WindSetStr( win, WF_NAME, get_string( MENUTOOL_TITLE));
	/* bind of events */
	EvntAdd( win, WM_DESTROY, stdDESTROY, EV_TOP);
	/* usefull to save parameters */
	create_infos( win, INFOS_TOOL, TOOL2);
	create_infos( win, INFOS_MENU, MENU2);
	/* open the window */
	WindOpen( win, app.x+50, app.y+50, app.x+350, app.x+200);
}
