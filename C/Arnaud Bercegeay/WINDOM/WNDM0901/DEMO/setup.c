/*
 * Auth : Dominique B‚r‚ziat, 1996 - 2000
 *        This file is a part of WinDom Developer Kit
 * File : CONF.C
 * Desc : Example of easy configuration of an application
 *		  using the WinDom functions.
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <windom.h>
#include "demo.h"
#include "global.h"

#ifndef TRUE
#define TRUE 1
#define FALSE 0
#endif

/* External functions
 */
char *get_string( int);
OBJECT *get_tree( int);

/*
 *	Save parameters into the WinDom
 *  configuration file using ConfWrite()
 */

void setup_save( void) {
	WINDOW *win;
	WINFO  *inf;
	char name[80];
/* MODIF_ARNAUD pour GCC32 */
	INT16 x, y, w, h;
	int count, max;

	MouseWork();
	switch( app.color) {
	case 2:
		ConfWrite( "demo.bg2", "%d,%d", param.desk->ob_spec.obspec.interiorcol, param.desk->ob_spec.obspec.fillpattern);
		break;
	case 4:
		ConfWrite( "demo.bg4", "%d,%d", param.desk->ob_spec.obspec.interiorcol, param.desk->ob_spec.obspec.fillpattern);
		break;
	case 16:
		ConfWrite( "demo.bg16", "%d,%d", param.desk->ob_spec.obspec.interiorcol, param.desk->ob_spec.obspec.fillpattern);
		break;
	default:
		ConfWrite( "demo.bg256", "%d,%d", param.desk->ob_spec.obspec.interiorcol, param.desk->ob_spec.obspec.fillpattern);
		break;
	}

	MouseWork();
	ConfWrite( "demo.options.desktop", "%s", (param.setup & SETUP_INSTALL_DESKTOP)?"true":"false");
	MouseWork();
	ConfWrite( "demo.options.autosave", "%s", (param.setup & SETUP_AUTOSAVE)?"true":"false");
	MouseWork();
	ConfWrite( "demo.options.windowsave", "%s", (param.setup & SETUP_SAVE_WINDOWS)?"true":"false");
	MouseWork();
	ConfWrite( "demo.options.frame.width", "%d", param.FrameWidth);
	MouseWork();
	ConfWrite( "demo.options.frame.color", "%d", param.FrameColor);

	/* How many windows opened ? */
	for( win = wglb.first,count=0; win; win = win->next, count++);
	MouseWork();
	ConfWrite( "demo.window.max", "%d", count);

	/* Delete old values */
	max = 0;
	ConfInquire( "demo.window.max", "%d", &max);
	for( count++; count <= max; count++) {
		sprintf( name, "demo.window.%d.title", count);
		ConfWrite( name, NULL);
		sprintf( name, "demo.window.%d.info", count);
		ConfWrite( name, NULL);
		sprintf( name, "demo.window.%d.xywh", count);
		ConfWrite( name, NULL);
		sprintf( name, "demo.window.%d.menu", count);
		ConfWrite( name, NULL);
		sprintf( name, "demo.window.%d.toolbar", count);
		ConfWrite( name, NULL);
		sprintf( name, "demo.window.%d.form", count);
		ConfWrite( name, NULL);
		sprintf( name, "demo.window.%d.iconified", count);
		ConfWrite( name, NULL);
		sprintf( name, "demo.window.%d.effect", count);
		ConfWrite( name, NULL);
		sprintf( name, "demo.window.%d.widget", count);
		ConfWrite( name, NULL);
		sprintf( name, "demo.window.%d.modal", count);
		ConfWrite( name, NULL);
		count ++;
	}
	
	for( win = wglb.first,count=1; win && (param.setup & SETUP_SAVE_WINDOWS) ; win = win->next, count++) {
		inf = DataSearch( win, WD_WINF);
		MouseWork();
		if( win->attrib & NAME) {
			sprintf( name, "demo.window.%d.title", count);
			ConfWrite( name, "\"%s\"", win->name);
		}
		if( win->attrib & INFO) {
			sprintf( name, "demo.window.%d.info", count);
			ConfWrite( name, "\"%s\"", win->info);
		}
		WindGet( win, WF_CURRXYWH, &x, &y, &w, &h);
		sprintf( name, "demo.window.%d.xywh", count);
		ConfWrite( name, "%d,%d,%d,%d", x,y,w,h);
		sprintf( name, "demo.window.%d.menu", count);
		ConfWrite( name, "%d", inf?inf->menu:-1);
		sprintf( name, "demo.window.%d.toolbar", count);
		ConfWrite( name, "%d", inf?inf->toolbar:-1);
		sprintf( name, "demo.window.%d.form", count);
		ConfWrite( name, "%d", inf?inf->form:-1);
		sprintf( name, "demo.window.%d.iconified", count);
		ConfWrite( name, "%s", (win->status & WS_ICONIFY)?"true":"false");
		sprintf( name, "demo.window.%d.modal", count);
		ConfWrite( name, "%s", (win->status & WS_UNTOPPABLE)?"true":"false");
		sprintf( name, "demo.window.%d.effect", count);
		ConfWrite( name, "%s", (win->status & WS_GROW)?"true":"false");
		sprintf( name, "demo.window.%d.widget", count);
		ConfWrite( name, "0x%X", win->attrib);	
	}

	graf_mouse( ARROW, 0L);
}

/*
 * Read setup in the WinDom configuration file
 * using ConfInquire().
 */

void setup_read( void) {
	char name[80], buf[128];
	int x, y, w, h, max, count;
	WINDOW *win=wglb.first;
	OBJECT *tree;

	/* fermer toutes les fenˆtres */
	
	while( wglb.first) {
		ApplWrite( app.id, WM_DESTROY, wglb.first->handle, 0, 0, 0, 0);
		EvntWindom( MU_MESAG);
	}
	
	ConfInquire("demo.options.desktop", "%B", &param.setup, SETUP_INSTALL_DESKTOP);	
	switch( app.color) {
	case 2:
		ConfInquire( "demo.bg2", "%d,%d",  &x, &y);
		param.desk->ob_spec.obspec.interiorcol = x;
		param.desk->ob_spec.obspec.fillpattern = y;
		break;
	case 4:
		ConfInquire( "demo.bg4", "%d,%d",  &x, &y);
		param.desk->ob_spec.obspec.interiorcol = x;
		param.desk->ob_spec.obspec.fillpattern = y;
		break;
	case 16:
		ConfInquire( "demo.bg16", "%d,%d",  &x, &y);
		param.desk->ob_spec.obspec.interiorcol = x;
		param.desk->ob_spec.obspec.fillpattern = y;
		break;
	default:
		ConfInquire( "demo.bg256", "%d,%d",  &x, &y);
		param.desk->ob_spec.obspec.interiorcol = x;
		param.desk->ob_spec.obspec.fillpattern = y;
		break;
	}
	
	ConfInquire( "demo.options.windowsave", "%B", &param.setup, SETUP_SAVE_WINDOWS);
	ConfInquire( "demo.options.autosave",   "%B", &param.setup, SETUP_AUTOSAVE);

	ConfInquire( "demo.options.frame.width", "%d", &param.FrameWidth);
	ConfInquire( "demo.options.frame.color", "%d", &param.FrameColor);
	max = 0;
	ConfInquire( "demo.window.max", "%d", &max);
	
	for( count = 1; count <= max; count++) {
		sprintf( name, "demo.window.%d.widget", count);
		ConfInquire( name, "%x", &x);
		win = WindCreate( x, app.x, app.y, app.w, app.h);
		if( x & NAME) {
			sprintf( name, "demo.window.%d.title", count);
			ConfInquire( name, "%s", buf);
			WindSetStr( win, WF_NAME, strdup( buf));
		}
		if( x & INFO) {
			sprintf( name, "demo.window.%d.info", count);
			ConfInquire( name, "%s", buf);
			WindSetStr( win, WF_INFO, strdup( buf));
		}
		sprintf( name, "demo.window.%d.form", count);
		if( ConfInquire( name, "%d", &x) && x!=-1) {
			rsrc_gaddr( 0, x, &tree);
			FormAttach( win, tree, NULL);
		}
		sprintf( name, "demo.window.%d.menu", count);
		if( ConfInquire( name, "%d", &x) && x!=-1) {
			rsrc_gaddr( 0, x, &tree);
			WindSetPtr( win, WF_MENU, tree, NULL);
		}
		sprintf( name, "demo.window.%d.form", count);
		if( ConfInquire( name, "%d", &x) && x!=-1) {
			rsrc_gaddr( 0, x, &tree);
			WindSetPtr( win, WF_TOOLBAR, tree, NULL);

		}
		sprintf( name, "demo.window.%d.effect", count);
		if( ConfInquire( name, "%b", &x) && x) {
			win -> status |= WS_GROW;
		}
		sprintf( name, "demo.window.%d.modal", count);
		if( ConfInquire( name, "%b", &x) && x) {
			win -> status |= WS_MODAL;
		}
		/* On fini par ouvrir la fenˆtre */
		sprintf( name, "demo.window.%d.xywh", count);
		ConfInquire( name, "%d,%d,%d,%d", &x, &y, &w, &h);
		WindOpen( win, x, y, w, h);
		EvntWindom( MU_MESAG);
		/* Cas iconification */
		sprintf( name, "demo.window.%d.iconified", count);
		if( ConfInquire( name, "%b", &x) && x) {
			WindSet( win,  WF_ICONIFY, -1, -1, -1, -1);
		}
	}
}

static struct _param copypar;		/* Parameters are locally store in this
									 * variable then eventually apply */

/*
 * Create and initalize the formular of configuration.
 * This example uses the new WinDom function ObjcAttach()
 * where it is perticulary approriate because many variables
 * can be linked to objects.
 */
 
void create_form_conf( void) {
	WINDOW *conf;
	OBJECT *tree;
	void conf_ok( WINDOW *, int);
	void conf_cancel( WINDOW *, int);
	void conf_apply( WINDOW *, int);
	void conf_popcolor( WINDOW *, int);
	void conf_popstyle( WINDOW *, int);

	/* Create the formular */
	tree = get_tree( CONFIGURE);
	conf = FormCreate( tree, 			/* formular object tree */
					   WAT_FORM,		/* window widgets */
					   NULL,			/* No event function ! */
					   get_string(CONF_TITLE),	/* window title */
					   NULL,			/* center at screen */
					   1,				/* graphic effects ON */
					   0);				/* no duplication */

	copypar = param;
	
	/* link objects to variables */
	ObjcAttach( OC_FORM, conf, CONF_INSTALL , BIND_BIT, &copypar.setup, SETUP_INSTALL_DESKTOP);
	ObjcAttach( OC_FORM, conf, CONF_WINDSAVE, BIND_BIT, &copypar.setup, SETUP_SAVE_WINDOWS);
	ObjcAttach( OC_FORM, conf, CONF_AUTOSAVE, BIND_BIT, &copypar.setup, SETUP_AUTOSAVE);
	
	/* link objects to function */
	ObjcAttach( OC_FORM, conf, CONF_OK, 		BIND_FUNC, conf_ok);
	ObjcAttach( OC_FORM, conf, CONF_CANCEL, 	BIND_FUNC, conf_cancel);
	ObjcAttach( OC_FORM, conf, CONF_APPL, 		BIND_FUNC, conf_apply);
	ObjcAttach( OC_FORM, conf, CONF_BTRAME, 	BIND_FUNC, conf_popstyle);
	ObjcAttach( OC_FORM, conf, CONF_BTRAME_POP, BIND_FUNC, conf_popstyle);
	ObjcAttach( OC_FORM, conf, CONF_FCOL, 		BIND_FUNC, conf_popcolor);
	ObjcAttach( OC_FORM, conf, CONF_FCOL_POP, 	BIND_FUNC, conf_popcolor);
	ObjcAttach( OC_FORM, conf, CONF_BCOL, 		BIND_FUNC, conf_popcolor);
	ObjcAttach( OC_FORM, conf, CONF_BCOL_POP, 	BIND_FUNC, conf_popcolor);
	
	/* Some object inits */
	tree[CONF_BCOL_POP].ob_spec.obspec.interiorcol 	 = param.desk->ob_spec.obspec.interiorcol;
	tree[CONF_BTRAME_POP].ob_spec.obspec.fillpattern = param.desk->ob_spec.obspec.fillpattern;
	tree[CONF_FCOL_POP].ob_spec.obspec.interiorcol   = copypar.FrameColor;
#ifdef __GNUC__
	sprintf( ObjcString( tree, CONF_FEPAI, NULL), "%d", param.FrameWidth);
#else
	itoa( param.FrameWidth, ObjcString( tree, CONF_FEPAI, NULL), 10);
#endif
}

/* Next, comes the function linked to objects */

/* sub function */

void apply_settings(void) {
	OBJECT *tree = get_tree( CONFIGURE);
	param = copypar;
	param.desk->ob_spec.obspec.interiorcol = tree[CONF_BCOL_POP].ob_spec.obspec.interiorcol;
	param.desk->ob_spec.obspec.fillpattern = tree[CONF_BTRAME_POP].ob_spec.obspec.fillpattern;
	param.FrameWidth = atoi( ObjcString( tree, CONF_FEPAI, NULL));
	param.FrameColor = tree[CONF_FCOL_POP].ob_spec.obspec.interiorcol;
}

/* button OK */

void conf_ok( WINDOW *win, int obj) {
	/* Close the form */
	ApplWrite( app.id, WM_CLOSED, win->handle, 0, 0, 0, 0);
	/* change state to normal */
	ObjcChange( OC_FORM, win, obj, NORMAL, FALSE);
	/* apply settings */
	apply_settings();
}

/* button APPLY */
void conf_apply( WINDOW *win, int obj) {
	/* apply settings */
	apply_settings();
	/* change state to normal and redraw the object */
	ObjcChange( OC_FORM, win, obj, NORMAL, TRUE);	
}

/* button CANCEL */
void conf_cancel( WINDOW *win, int obj) {
	/* Close the form */
	ApplWrite( app.id, WM_CLOSED, win->handle, 0, 0, 0, 0);
	/* normal state for the button */
	ObjcChange( OC_FORM, win, obj, NORMAL, FALSE);	
}

/* color popup */
void conf_popcolor( WINDOW *win, int obj) {
	OBJECT *tree;
/* MODIF_ARNAUD pour GCC32 */
	INT16 x, y, res;
	
	rsrc_gaddr( 0, COLORS, &tree);
	objc_offset( FORM( win), obj, &x, &y);
	res = MenuPopUp( tree, 
					 x, y, 
					 0, 0, 
					 FORM( win)[obj].ob_spec.obspec.interiorcol+1,
					 P_WNDW);
	
	if( res > 0 && tree[res].ob_flags & SELECTABLE) {
		FORM( win)[obj].ob_spec.obspec.interiorcol = res-1;
		ObjcDraw( OC_FORM, win, obj, 1);
	}
}

/* style popup */
void conf_popstyle( WINDOW *win, int obj) {
	OBJECT *tree;
/* MODIF_ARNAUD pour GCC32 */
	INT16 x, y, res;
	
	rsrc_gaddr( 0, TRAME, &tree);
	objc_offset( FORM( win), obj, &x, &y);
	res = MenuPopUp( tree, 
					 x, y, 
					 0, 0, 
					 FORM(win)[obj].ob_spec.obspec.fillpattern+1, 
					 P_WNDW);
	if( res > 0) {
		FORM(win)[obj].ob_spec.obspec.fillpattern = tree[ res].ob_spec.obspec.fillpattern;
		ObjcChange( OC_FORM, win, obj, NORMAL, 1);
	}
}

/* End of file */
