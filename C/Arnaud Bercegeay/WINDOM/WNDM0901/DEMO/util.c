/*
 * Auth : Dominique B‚r‚ziat, 1996 - 2000
 *        This file is a part of WinDom Developer Kit
 * File : UTIL.C
 * Desc : Diverse and usefull functions.
 */

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <windom.h>
#include "global.h"
#include "demo.h"

/* Return a string from resource file */

char *get_string( int index) {
	char *txt;	
	rsrc_gaddr( 5, index,  &txt);
	return txt;
}

OBJECT *get_tree( int index) {
  OBJECT *tree;
  rsrc_gaddr( 0, index, &tree);
  return tree;
}

/*
 * Initialize the information of a window
 */

void create_infos( WINDOW *win, int type, int index) {
	WINFO *inf;
	
	inf = DataSearch( win, WD_WINF);
	if( inf == NULL) {
		inf = (struct infos *)malloc( sizeof(struct infos));
		inf->menu = inf->toolbar = inf->form = -1;
	}
	switch( type) {
	case INFOS_MENU:
		inf->menu = index;
		break;
	case INFOS_TOOL:
		inf->toolbar = index;
		break;
	case INFOS_FORM:
		inf->form = index;
		break;
	}
	DataAttach( win, WD_WINF, inf);
}

/*
 *	Display informations about a window 
 */

void display_info( WINDOW *win, int handle) {
	OBJECT *tree;

	rsrc_gaddr( 0, DIAL3, &tree);
	if( win != NULL) {
		sprintf( ObjcString( tree, DL3_GEM, NULL), "%d", win -> handle);
		if( win -> status & WS_FORM)
			strcpy( ObjcString( tree, DL3_TYPE, NULL), get_string( TYPE_FORM));
		else
			strcpy( ObjcString( tree, DL3_TYPE, NULL), get_string( TYPE_ANY));
		if( win -> attrib & SMALLER)
			strcpy( ObjcString( tree, DL3_ICON, NULL), get_string( ANS_YES));
		else
			strcpy( ObjcString( tree, DL3_ICON, NULL), get_string( ANS_NO));
		if( win -> status & WS_TOOLBAR)
			strcpy( ObjcString( tree, DL3_TOOL, NULL), get_string( ANS_YES));
		else
			strcpy( ObjcString( tree, DL3_TOOL, NULL), get_string( ANS_NO));
		if( win -> status & WS_MENU)
			strcpy( ObjcString( tree, DL3_MENU, NULL), get_string( TYPE_FORM));
		else
			strcpy( ObjcString( tree, DL3_MENU, NULL), get_string( TYPE_FORM));
	} else {
		sprintf( ObjcString( tree, DL3_GEM, NULL), "%d", handle);
		strcpy( ObjcString( tree, DL3_TYPE, NULL), get_string( TYPE_ALIEN));
		strcpy( ObjcString( tree, DL3_ICON, NULL), "-");
		strcpy( ObjcString( tree, DL3_TOOL, NULL), "-");
		strcpy( ObjcString( tree, DL3_MENU, NULL), "-");
	}
	FormWindBegin( tree, get_string( WINDNAME));
	FormWindDo(MU_MESAG|MU_KEYBD|MU_TIMER);
	FormWindEnd();
	ObjcChange( OC_OBJC, tree, DL3_OUI, NORMAL, 0);
}

/*
 * Example of window icon drawing function
 */

void draw_color_icon( WINDOW *win) {
	OBJECT *tree = get_tree( COLOR_ICON);
/* MODIF_ARNAUD pour GCC32 */
	INT16 w, h;
	
	WindGet( win, WF_WORKXYWH, &tree->ob_x, &tree->ob_y, &w, &h);
	objc_draw( tree, 0, 2, clip.g_x, clip.g_y, clip.g_w, clip.g_h);
}

void draw_mono_icon( WINDOW *win) {
	OBJECT *tree = get_tree( MONO_ICON);
/* MODIF_ARNAUD pour GCC32 */
	INT16 w, h;
	
	WindGet( win, WF_WORKXYWH, &tree->ob_x, &tree->ob_y, &w, &h);
	objc_draw( tree, 0, 2, clip.g_x, clip.g_y, clip.g_w, clip.g_h);
}


/*
 *	User closer event function
 */

void stdDESTROY( WINDOW *win) {
	DataDelete( win, WD_WINF);
}


/*
 * Appel de WinConf
 * pour configurer notre application
 * Il faut pr‚voir de passer un fichier
 * de configuration et une appli
 *	winconf .cnf -> fichier config
 *  winconf .app,.prg -> configuration
 */ 

#ifdef TEST_DOM

#include <av.h>

int ConfWindom( int section) {
	char app[128], dum[128], *p;
	int id;

#define WC_SECTION	0x5743	

	/* Chemin de notre application (app) */
	shel_read( app, dum);

	/* 1/ Trouver WinConf */
	/* memory */
	id = appl_find( "WINCONF ");
	if( id != -1) {
		ApplWrite( id, VA_START, app);
	}

	/* windom.cnf */
	if( id == -1 && ConfInquire( "windom.winconf", "%s", dum)) {
		id = ExecGemApp( dum, app, NULL, TRUE, FALSE);
#ifdef _GEMLIB_H_
		evnt_timer( 1000L);
#else
		evnt_timer( 1000, 0);
#endif	
	}
	
	/* Environ */
	shel_envrn( &p, "WINCONF=");
	if( id == -1 && p) {
		id = ExecGemApp( p, app, NULL, TRUE, FALSE);
#ifdef _GEMLIB_H_
		evnt_timer( 1000L);
#else
		evnt_timer( 1000, 0);
#endif
	}
	
	/* Path */
	strcpy( dum, "winconf.app");
	if( id == -1 && shel_find( dum)) {
		id = ExecGemApp( dum, app, NULL, TRUE, FALSE);
#ifdef _GEMLIB_H_
		evnt_timer( 1000L);
#else
		evnt_timer( 1000, 0);
#endif
	}

	if( id == -1)
		return -33;	/* Not found */	

	/* Choix de la section ?? */
	ApplWrite( id, WC_SECTION, section);
	return id;
}

#endif