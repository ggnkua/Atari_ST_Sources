/* 
 * Auth : Dominique B‚r‚ziat, 1996 - 2000
 *        This file is a part of WinDom Developer Kit
 * File : EVNT-FNC.C
 * Desc : Some global event functions (i.e. not addressing
 *		  a window).
 */

#include <stddef.h>
#include <stdlib.h>
#include <windom.h>
#include <av.h>
#include "global.h"
#include "demo.h"

#ifndef FALSE
#define TRUE 1
#define FALSE 0
#endif

/* external functions 
 */ 
void setup_save( void);
void setup_read( void);

char *get_string( int);
OBJECT *get_tree( int);
void create_infos( WINDOW *, int, int);
void simpleMENU( WINDOW *win);
void simpleTOOL( WINDOW *win);

void create_info_form( void);		/* A simple formular */
void create_modal_form( void);		/* A modal form, first type */
void create_quit_form( void);		/* */
void create_widget_form( int);		/* */
void create_simple( void);			/* A simple window */
void create_custom( void);			/* A more complexe window */
void create_windowtoolbar( void);	/* A window with a toolbar */
void create_windowtoolmenu( void);	/* A window with a toolbar and a menu */
void create_three_frame( void);		/* A window with 3 frames */
void create_two_frame( void);		/* A window with 2 frames */

void create_form_conf( void);
void create_construct_window( void);
void create_form_widget( void);
void create_form_extra( void);

void call_fontselector( void);
void call_fileselector( void);
void display_info( WINDOW *, int);

void av_status ( void);
void av_opendir( void);
void av_sendfile( void);
void av_view( void);
void av_sendkey( void);

int  ConfWindom( void);
void UnLoadBubble( void);

/*
 * AP_TERM event function : quit properly the application
 */

void ap_term( void) {
    /* Save the Set up */
    if( param.setup & SETUP_AUTOSAVE)
    	setup_save();
	/* Close all windows */
	while( wglb.first) {
		ApplWrite( app.id, WM_CLOSED, wglb.first->handle, 0, 0, 0, 0);
		EvntWindom( MU_MESAG);
	}
	if( param.setup & SETUP_XTYPE) RsrcXtype( 0, NULL, 0);
	if( param.setup & SETUP_INSTALL_DESKTOP) WindSet( NULL, WF_NEWDESK, 0, 0, 0, 0);
	ApplWrite( evnt.buff[1], (evnt.buff[5]==AP_TERM)?SHUT_COMPLETED:RESCHG_COMPLETED, 1,0,0,0,0);
	UnLoadBubble();
	FrameExit();
	AvExit();
	RsrcFree();
	ApplExit();
	exit(0);
}

/*
 * AV_SENDCLICK event function :
 * this event is tranformed as a MU_BUTTON message
 */

void av_sendclick( void) {
	ApplWrite( app.id, AP_BUTTON, evnt.buff[3], evnt.buff[4],
			   evnt.buff[5], evnt.buff[6], evnt.buff[7]);
}

/*
 * MU_BUTTON global event : Bubble GEM handling
 */

void mu_button( void) {
	if( evnt.mbut & 0x02)
		BubbleEvnt();
}

/*
 *	desktop menu event 
 */

/*
 * handle the menu by catching a specific menu item
 * (using ObjcAttach) ...
 */

void menu_binding( void) {
	ObjcAttach( OC_MENU, NULL, MN1_INFO, BIND_FUNC, create_info_form);
	ObjcAttach( OC_MENU, NULL, MN1_FS, BIND_FUNC, create_simple);
	ObjcAttach( OC_MENU, NULL, MN1_FT, BIND_FUNC, create_windowtoolbar);
	ObjcAttach( OC_MENU, NULL, MN1_FM, BIND_FUNC, create_custom);
	ObjcAttach( OC_MENU, NULL, MN1_FTM, BIND_FUNC, create_windowtoolmenu);
	ObjcAttach( OC_MENU, NULL, MN1_FMODAL, BIND_FUNC, create_modal_form);

	ObjcAttach( OC_MENU, NULL, MN1_FONTSEL, BIND_FUNC, call_fontselector);
	ObjcAttach( OC_MENU, NULL, MN1_FILESEL, BIND_FUNC, call_fileselector);
	ObjcAttach( OC_MENU, NULL, MN1_FRAME1, BIND_FUNC, create_two_frame);
	ObjcAttach( OC_MENU, NULL, MN1_FRAME2, BIND_FUNC, create_three_frame);
	ObjcAttach( OC_MENU, NULL, MN1_QUIT, BIND_FUNC, create_quit_form);	

	ObjcAttach( OC_MENU, NULL, MN1_AVSTATUS, BIND_FUNC, av_status);
	ObjcAttach( OC_MENU, NULL, MN1_AVOPENDIR, BIND_FUNC, av_opendir);
	ObjcAttach( OC_MENU, NULL, MN1_AVSENDFILE, BIND_FUNC, av_sendfile);
	ObjcAttach( OC_MENU, NULL, MN1_AVSENDKEY, BIND_FUNC, av_sendkey);
	ObjcAttach( OC_MENU, NULL, MN1_AVVIEW, BIND_FUNC, av_view);

}

/*
 * ... or by catching the MN_SELECTED event.
 */

void menu_desktop( void) {
	WINDOW *win;
	int title = evnt.buff[ 3];
	INT16 x,y,dum;
	char *str;
	
	switch( evnt.buff[4]) {
	case MN1_FD:
		create_widget_form( FALSE);
		break;
	case MN1_DUP:
		create_widget_form( TRUE);
		break;

	/* Menu Action */
	case MN1_CLOSE:
		if( wglb.front != NULL)
			ApplWrite( app.id, WM_CLOSED, wglb.front->handle, 0, 0, 0, 0);
		break;

	case MN1_ICONIFY:
		if( wglb.front != NULL) {
			INT16 w, h;
			give_iconifyxywh( &x, &y, &w, &h);
			/*graf_dragbox( app.wicon, app.hicon, x,y, )*/
			WindSet( wglb.front, WF_ICONIFY, x, y, w, h);
		}
		break;

	case MN1_MAXIMISE:
		if( wglb.front != NULL) 
			ApplWrite( app.id, WM_FULLED, wglb.front->handle, 0, 0, 0, 0);
		break;

	case MN1_CYCLE:
		{
			int top = -1;
			
			if( !wglb.front && !wglb.appfront && wglb.first) 
				top = wglb.first->handle;
			else if( wglb.front)
				top = wglb.front->next?wglb.front->next->handle:wglb.first->handle;
			else if( wglb.appfront)
				top = wglb.appfront->next?wglb.appfront->next->handle:wglb.first->handle;
				
			if( top != -1) 
				ApplWrite( app.id, WM_TOPPED, top, 0, 0, 0, 0);
		}
		break;
		
	case MN1_REDRAW:
		if( wglb.front != NULL)
			snd_rdw( wglb.front);
		break;

	case MN1_HIDE:
		ApplControl( app.handle, APC_HIDE);
		break;

	case MN1_WINFO:
		if( wglb.front != NULL)
			display_info( wglb.front, 0);
		else {
/* MODIF_ARNAUD pour GCC32 */
			INT16 dum;
			WindGet( NULL, WF_TOP, &dum, NULL, NULL, NULL);
			display_info( NULL, dum);
		}
		break;


	case MN1_AVOPENDIR:
/*		{
            ApplWrite( app.avid, AV_OPENWIND, prg, cmd, 0);
            AvWaitfor( VA_PROGSTARTED, evnt.buf, 1000);
        } */
		break;
		
	case MN1_EXT:
		param.setup ^= SETUP_XTYPE;
		RsrcXtype( (param.setup & SETUP_XTYPE)?1:0, NULL, 0);
		win = wglb.first;
		while( win != NULL) {
			if( win->status & WS_TOOLBAR || win->status & WS_FORM)
				snd_rdw( win);
			win = win->next;
		}
		break;
	case MN1_OP2:
		create_form_conf();
		break;
	case MN1_OP3:
		rsrc_gaddr( 5, ALRT_SAVE_PAR, &str);
		form_alert( 1, str);
		setup_save();
		break;
	case MN1_READCONF:
		setup_read();
		form_dial( FMD_FINISH, 0, 0, 0, 0, app.x, app.y, app.w, app.h);
		break;
	case MN1_WINDOM:
		ConfRead();
		form_dial( FMD_FINISH, 0, 0, 0, 0, app.x, app.y, app.w, app.h);
		break;

	/* Configuration Windom par WinConf */
	case MN1_CONF_WINDOM:
		if( ConfWindom() < 0) FormAlert( 1, get_string( ALRT_WINCONF));
		break;

	}
	MenuTnormal( NULL, title, 1);
}
