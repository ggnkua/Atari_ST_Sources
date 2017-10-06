/*
 *	File this is a part of WinDom Package
 *  Copyright 1999/2000 by Dominique B‚r‚ziat
 *  See section Legal from the WinDom documentation
 *
 *	This file is a typical skeleton for yours
 *	WinDom applications.
 */

#include <av.h>
#include <windom.h>
#include <string.h>
#include <stdlib.h>
#include "ex-skel.h"

#define WD_SKEL	'SKEL'

void ex_draw( WINDOW *);
void ex_dtry( WINDOW *);

#ifndef __PUREC__
int _app = TRUE;		/* set to FALSE for a desktop accessory */
#endif

/*
 *	Quit properly the application
 */

void ap_term( void) {
	/* Close all Windows */
	while( wglb.first) {
		ApplWrite( app.id, WM_DESTROY, wglb.first->handle);
		EvntWindom( MU_MESAG);
	}
	/* free ressource & memory */
	RsrcXtype( 0, NULL, 0);
	RsrcFree();
	/* free environment */
	AvExit();
	ApplExit();
	exit( 0);
}

/*
 *	Just an exemple where we load data and
 *	display it in a window.
 */

void load_and_display( char *file) {
	WINDOW *win;
	char *p = strdup( file);
	
	win = WindCreate( WAT_NOINFO, app.x, app.y, app.w, app.h);
	EvntAttach( win, WM_REDRAW, ex_draw);
	EvntAttach( win, WM_DESTROY, ex_dtry);
	DataAttach( win, WD_SKEL, p);
	WindSet( win, WF_NAME, p);
	WindOpen( win, -1, -1, 250, 70);
}

/*
 * Handle the VA_START message
 */

void va_start( void) { 
	char *p = *(char **) &evnt.buff[3];

	if( p) {
		p = AvStrfmt( 1, p);
		load_and_display( p);
		free( p);
	}
}

/*
 *	Handle the VA_DRAGACCWIND message
 */

void va_dragaccwind( void) { 
	char *p = *(char **) &evnt.buff[6];

	if( p) {
		p = AvStrfmt( 1, p);
		load_and_display( p);
		free( p);
	}
}

/*
 *	Handle the AP_DRAGDROP message
 */

void ap_dragdrop( void) { 
	char *p = *(char **) &evnt.buff[6];

	if( p) {
		p = AvStrfmt( 1, p);
		load_and_display( p);
		free( p);
	}
}

/*
 * Handle the message AC_CLOSED :
 *	when an acc receives this message, it
 *	should close all its windows
 */

void ac_close( void) {
	while( wglb.first) {
		ApplWrite( app.id, WM_DESTROY, wglb.first->handle);
		EvntWindom( MU_MESAG);
	}
}

/*
 * Handle the desktop menu
 */

void mn_selected( void) {
	int title = evnt.buff[3];
	static char path[255] = "";
	static char name[64] = "";
	char *string;

	switch( evnt.buff[4]) {
	case QUIT:
		/* send a AP_TERM request */
		ApplWrite( app.id, AP_TERM);
		break;
	case LOAD:
		/* Use the fileselector to open a file */
		if( FselInput( path, name, "*", "Load a file", NULL, NULL)) {
			strcat( path, name);
			ApplWrite( app.id, VA_START, path);
		}
		break;
	case INFO_APP:
		rsrc_gaddr( 5, ALRT_INFO, &string);
		form_alert( 1, string);
		break;
	}	
	MenuTnormal( NULL, title, 1);
}

/*
 *	The main function
 */
 
void main( int argc, char *argv[]) {
	OBJECT *tree;
	int i;
	
	/* Some WinDom initializations */

	if( ApplInit() == -1) {
		form_alert( 1, FA_STOP "[Impossible to init AES][End]");
		exit( 0);
	}
	if( AvInit( "EX-SKEL ", A_START|A_QUOTE, 1000) < 0 ) {
		form_alert( 1, FA_ERROR "[Warning, no AV-servor!][OK]");
		exit( 0);
	}

	/* Loading ressources */
	
	if( !RsrcLoad( "ex-skel.rsc")) {
		form_alert( 1, FA_STOP "[Impossible to load ressource file!][End]");
		AvExit();
		ApplExit();
		exit( 0);		
	}
	RsrcXtype( 1, NULL, 0);
	
	/* a Pure C feature : _app == 0 if a desktop accessory */
	if( _app) {
		/* Install the desktop menu */
		rsrc_gaddr( 0, MENU_DESKTOP, &tree);
		MenuBar( tree, 1);
	}

	/* If acc or MultiTOS (or Naes or Geneva) */
	if( !_app || _AESnumapps == -1)
		menu_register( app.id, "  A windom app");

	/* Trap global GEM messages */

	EvntAttach( NULL, AP_TERM, 			ap_term);
/*	EvntAttach( NULL, AP_DRAGDROP, 		ap_dragdrop); */
	EvntAttach( NULL, VA_DRAGACCWIND, 	va_dragaccwind);
	EvntAttach( NULL, VA_START, 		va_start);
	EvntAttach( NULL, MN_SELECTED, 		mn_selected);
	/* if the application is a desktop accessory */
	EvntAttach( NULL, AC_CLOSE, 		ac_close);

	/* Read the command ligne */
	
	for( i=1; i<argc; ApplWrite( app.id, VA_START, argv[i++]));
	
	/* GEM event loop */
	
	while( 1) EvntWindom( MU_MESAG|MU_BUTTON|MU_KEYBD);
}

/*
 * A basic exemple of non predefined window ...
 */

void ex_draw( WINDOW *win) {
	int x, y, w, h;

	vswr_mode( win->graf.handle, MD_REPLACE);
	WindClear( win);
	WindGet( win, WF_WORKXYWH, &x, &y, &w, &h);
	vswr_mode( win->graf.handle, MD_TRANS);
	v_gtext( win->graf.handle, x+5, y+h/2, (char*)DataSearch( win, WD_SKEL));
}

void ex_dtry( WINDOW *win) {
	char *p = DataSearch( win, WD_SKEL);
	DataDelete( win, WD_SKEL);
	free( p);
	WindClose( win);
	WindDelete( win);
}
