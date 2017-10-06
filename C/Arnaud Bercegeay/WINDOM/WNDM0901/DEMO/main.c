/*
 * Auth : Dominique B‚r‚ziat, 1996 - 2000
 *        This file is a part of WinDom Developer Kit
 * File : MAIN.C
 * Desc : A complet demonstration of WinDom capabilities
 *		  This file contains the main function.
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <windom.h>

#include "av.h"
#include "scancode.h"

#include "demo.h"
#include "global.h"

/* External function 
 */

char *	get_string	(int);
OBJECT *get_tree	(int);
void 	setup_read	(void);

void ap_term( WINDOW *);
void av_sendclick( WINDOW *);
void menu_desktop( WINDOW *);
void mu_button( WINDOW *);
void menu_binding( void);


int LoadBubble( char *);

/* debug */

char *list[] = {
	"",
	"WM_XTIMER", 	/* 1 */
	"WM_XKEYBD",
	"WM_XBUTTON",
	"WM_XM1",
	"WM_XM2",
	"","","","",
	"MN_SELECTED",	/* 10 */
	"","","","","","","","","",""
	"WM_REDRAW",	/* 20 */
	"WM_TOPPED",
	"WM_CLOSED",
	"WM_FULLED",
	"WM_ARROWED",
	"WM_HSLID",
	"WM_VSLID",
	"WM_SIZED",
	"WM_MOVED",
	"WM_NEWTOP",
	"WM_UNTOPPED",	/* 30 */
	"WM_ONTOP",
	"",
	"WM_BOTTOM",
	"WM_ICONIFY",
	"WM_UNICONIFY",
	"WM_ALLICONIFY",
	"WM_TOOLBAR",
	"", "",
	"AC_OPEN",		/* 40 */
	"AC_CLOSE", 
	"","","","","","","","",""
	"AP_TERM",		/* 50 */
	"AP_TFAIL"
	};


char *nom_message( int msg) {
	static char nom[50];
	
	*nom = '\0';
	if( msg < 52) {
		strcpy( nom, list[msg]);
	} else switch( msg) {
		case WM_DESTROY:
			strcpy( nom, "WM_DESTROY");
			break;
		case WM_MNSELECTED:
			strcpy( nom, "WM_MNSELECTED");
			break;
		case WM_FORM:
			strcpy( nom, "WM_FORM");
			break;
		case AP_LOADCONF:
			strcpy( nom, "AP_LOADCONF");
			break;
		case AP_BUTTON:
			strcpy( nom, "AP_BUTTON");
			break;
		case AP_KEYBD:
			strcpy( nom, "AP_KEYBD");
			break;
		}
	return nom;
}

void keybd( void) {
#if 0
	WINDOW *win;
	FILE *fp;
	void *ev;
	
	if( (evnt.keybd >> 8) == SC_F10) {
		fp = fopen( "demo.log", "w");
		if( fp) {
			fprintf( fp, "global events:\n");
			for( ev = app.binding; ev; ev = ev->next) 
				fprintf( fp, "\t%d (%s) 0x%X %ld\n", ev->msg, 
					nom_message( ev->msg), ev->flags, ev->proc);
			for( win=wglb.first; win; win = win->next) {
				fprintf( fp, "window %d events:\n", win->handle);
				for( ev = win->binding; ev; ev = ev->next) 
					fprintf( fp, "\t%d (%s) 0x%X %ld\n", ev->msg, 
							nom_message( ev->msg), ev->flags, ev->proc);
			}
			fclose( fp);
		}
	}
#endif
}

void main( void) {
	OBJECT *menu;
	
	/* WinDom initialization */
	ApplInit();
	/* Load the application resource */
	if( !RsrcLoad( "demo.rsc")) {
		if( form_alert( 1, "[1][resource file not find !][Locate|End]") == 1)
		/*	locate_resource(); */ ;
	  	else {
			ApplExit();
			exit( 0);
	  	}
	}

	sprintf( ObjcString(get_tree(DIAL1), DIAL1_COMPILER, NULL),
			 "compiled with %s and WinDom %x.%2x", 
			 WinDom.cc_name, WinDom.patchlevel>>8, WinDom.patchlevel&0x00FF);
	menu = get_tree( MENU1);

	/* Init frame environment */
	FrameInit();

	
	/* Init AVserver environnement */
	if( AvInit( "DEMO    ", A_START|A_QUOTE, 1000 ) < 0) {
		menu[MN1_AVSENDFILE].ob_state |= DISABLED;
		menu[MN1_AVOPENDIR].ob_state |= DISABLED;
		menu[MN1_AVSENDKEY].ob_state |= DISABLED;
		menu[MN1_AVVIEW].ob_state |= DISABLED;
	} else {
		INT16 *status = AvStatus();
		
		if( (status[0] & V_SENDKEY) == 0)
			menu[MN1_AVSENDKEY].ob_state |= DISABLED;	
		if( (status[1] & V_VIEW) == 0)
		{	FormAlert( 1, "[1][houpla][ok]");
		 menu[MN1_AVVIEW].ob_state |= DISABLED;	}
		if( (status[0] & V_STARTPROG) == 0)
			menu[MN1_AVSENDFILE].ob_state |= DISABLED;	
		if( (status[0] & V_OPENWIND) == 0)
			menu[MN1_AVOPENDIR].ob_state |= DISABLED;	
	}
	
	/* Install extended type for objects */
	RsrcXtype( 0x03, NULL, 0);

	/* Install menu desktop */
	MenuBar( menu, 1);

	/* Register application name in menu if possible */
	if( _AESnumapps == -1)
		menu_register( app.id, "  WinDom demo ");

	param.desk = get_tree( FORM11);
	setup_read();

	/* Install the desktop */
	if( param.setup & SETUP_INSTALL_DESKTOP) {
		param.desk->ob_x 	  = app.x;
		param.desk->ob_y 	  = app.y;
		param.desk->ob_width  = app.w;
		param.desk->ob_height = app.h;
		WindSetPtr( NULL, WF_NEWDESK, param.desk, NULL);
		/* Redraw the desktop */
		form_dial (FMD_FINISH, 0, 0, 0, 0, app.x, app.y, app.w, app.h);
	}
	
	/* BubbleGEM */
	LoadBubble( "demo.bub");

	/* set some event parameters (MU_BUTTON & MU_TIMER) */	
	evnt.bclick   = 258;
	evnt.bmask    = 3;
	evnt.bstate   = 0;
	evnt.timer = 1000L;

	/* Bind global events */
	EvntAttach( NULL, AP_TERM,      ap_term);
	EvntAttach( NULL, AV_SENDCLICK, av_sendclick);
	EvntAttach( NULL, MN_SELECTED,  menu_desktop);
	EvntAttach( NULL, WM_XBUTTON,   mu_button);
	EvntAttach( NULL, WM_XKEYBD,    keybd);
	menu_binding();

	/* Events handling */
	for(;;) EvntWindom( MU_MESAG | MU_TIMER | MU_KEYBD | MU_BUTTON);
}
