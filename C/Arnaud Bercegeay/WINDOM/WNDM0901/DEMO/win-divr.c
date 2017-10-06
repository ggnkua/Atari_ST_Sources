/*
 * Auth : Dominique B‚r‚ziat, 1996 - 2000
 *        This file is a part of WinDom Developer Kit
 * File : WIN-DIVR.C
 * Desc : Example of diverses simple windows
 */

#include <stddef.h>   /* needed for NULL definition */
#include <windom.h>
#include "global.h"
#include "demo.h"

/* External functions
 */
OBJECT *get_tree( int);
char *get_string( int);
void create_infos( WINDOW*, int, int);
void draw_mono_icon( WINDOW *);
void stdDESTROY( WINDOW *);

/*
 * A simple window
 */

void simpleDRAW( WINDOW *win) {
/* MODIF_ARNAUD pour GCC32 */
	INT16 line[4];
	INT16 x, y, w, h;
	
	WindGet( win, WF_WORKXYWH, &x, &y, &w, &h);
	
	vsl_width( win->graf.handle, 3);
	line[0] = x;
	line[1] = y;
	line[2] = x+w-1;
	line[3] = y+h-1;
	vsl_color( win->graf.handle, BLUE);
	v_pline( win->graf.handle, 2, line);
	
	line[0] = x+w-1;
	line[1] = y;
	line[2] = x;
	line[3] = y+h-1;
	vsl_color( win->graf.handle, RED);
	v_pline( win->graf.handle, 2, line);

}

void create_simple( void) {
	void simpleCLICK( WINDOW *);	
	void simpleKEY	( WINDOW *);

	/* Create the window */
	WINDOW *win = WindCreate( WAT_NOINFO, app.x, app.y, app.w, app.h);
	/* Set the window title */
	WindSetStr( win, WF_NAME, get_string( SIMPLE_TITLE));
	/* Icon settings */
	WindSetStr( win, WF_ICONTITLE, get_string( APP_NAME));
	WindSetPtr( win, WF_ICONDRAW , draw_mono_icon, NULL);
	/* Define some window events */
	EvntAttach( win, WM_XBUTTON, simpleCLICK);
	EvntAttach( win, WM_XKEYBD,  simpleKEY );
	EvntAdd	  ( win, WM_DESTROY, stdDESTROY, EV_TOP);
	EvntAdd	  ( win, WM_REDRAW,  simpleDRAW, EV_BOT);
	
	/* Open the window */
	WindOpen( win, -1, -1, app.w/2, app.h/2);

	vsf_perimeter( win->graf.handle, 0);
	create_infos( win, INFOS_MENU, -1);
}

/*
 *	Example of MU_BUTTON event function apply on a window 
 */
 
void simpleCLICK( WINDOW *win) {
	UNUSED( win);	/* prevent warning from compilation */
	FormAlert( 1 , get_string( ALRT_CLIC));
}

/*
 *	Example of MU_KEYBD event function apply on a window
 */

void simpleKEY( WINDOW *win) {
	UNUSED( win);
	FormAlert( 1, get_string( ALRT_KEY), evnt.keybd, ((char)evnt.keybd) ? (char)evnt.keybd : ' ');
}



/*
 * A simple example of calling the font selector
 */
		
void call_fontselector( void) {
	char name[60];
	int id=0, size=0;
	FontSel( get_string( FONT_TITLE), NULL, 0, &id, &size, name);
}

/*
 * A simple example of calling the file selector,
 * the last folder visited and file selected are keep in memory.
 */
		
void call_fileselector( void) {
	static char path[128];
	static char name[60];

	FselInput( path, name, "*", get_string(FSEL_TITLE), NULL, NULL);
}


/* End of file */
