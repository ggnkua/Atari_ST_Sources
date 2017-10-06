/*
 * Auth : Dominique B‚r‚ziat, 1996 - 2000
 *        This file is a part of WinDom Developer Kit
 * File : WIN-FORM.C
 * Desc : Example of simple window formulars.
 */

#include <stddef.h>
#include <string.h>  /* needed for NULL definition */
#include <windom.h>
#include "global.h"
#include "demo.h"

#ifndef TRUE
#define TRUE 1
#define FALSE 0
#endif

/* external functions 
 */ 

char *get_string( int);
OBJECT *get_tree( int);
void create_infos( WINDOW *, int, int);
void draw_color_icon( WINDOW *);

/* 
 * A generic form event function
 */

void generic_form_event( WINDOW *win) {
	ObjcChange( OC_FORM, win, evnt.buff[4], NORMAL, FALSE);
	ApplWrite( app.id, WM_CLOSED, win->handle, 0, 0, 0, 0);
}

/*
 * A Basic example, without real user action
 */

void create_info_form( void) {
	/* A simple informative formular */
	WINDOW *win = FormCreate( get_tree( DIAL1), 
					  		  WAT_FORM,
					  		  generic_form_event,
					  		  get_string( INFO_TITLE), 
					  		  NULL, 
					  		  TRUE, FALSE);
	create_infos( win, INFOS_FORM, DIAL1);
}

/*
 * A modal formular, first method (handled
 * like a non-modal formular
 */

void create_modal_form( void) {
	void close_modal( WINDOW * );
	WINDOW *win = FormCreate( get_tree( DIAL2), 
							  WAT_MFORM, 
							  generic_form_event, 
							  get_string( MFORM_TITLE), 
							  NULL, TRUE, TRUE);
	/* Set the window modal */
	WindSet( win, WF_BEVENT, B_MODAL, 0, 0, 0);
	/* New closer event function */
	EvntAttach( win, WM_CLOSED, close_modal);
	/* Disable the desktop menu */
	MenuDisable();
	create_infos( win, INFOS_FORM, DIAL2);
}

/* Because our modal window disables the desktop
 * menu, it has a special destroy function */

void close_modal( WINDOW *win) {
	/* standard closer function of formulars */
	void frm_cls( WINDOW *win);

	/* Enable the desktop menu	*/
	MenuEnable();
	/* close properly the formular */
	frm_cls( win);
}

/*
 * A modal formular, second method (may be handled like
 * a classic GEM formular.
 */

void create_quit_form( void) {
	int res;
	WINDOW *win = FormWindBegin( get_tree( ALR_QUIT), 
								 get_string( APP_NAME));
	
	MouseObjc( FORM(win), ALR1_OUI);
	res = FormWindDo(MU_MESAG|MU_BUTTON|MU_KEYBD);
	if( res == ALR1_OUI)
		ApplWrite( app.id, AP_TERM, 0, 0, 0, 0, 0);
	ObjcChange( OC_FORM, win, res, NORMAL, 0);
	FormWindEnd();
}

/* Object DIAL2_TEST : a funny example of a checkable button
 * whose label changes with the object state */
 
static int vtest = 0;

void ftest( WINDOW *win, int obj) {
	ObjcStrCpy( FORM(win), obj, vtest?"yes":"no ");
	/* Here, we used the OC_MSG flags because 3D objects
	 * are drawn in transparency. This flags sends a
	 * redraw message around the object, then foreground
	 * objects are redrawn too. */
	ObjcDraw( OC_FORM, win, obj, OC_MSG);
}

/*
 * A formular showing all extended objet available with
 * WinDom.
 */

void create_widget_form( int dup) {
	void user( WINDOW*, PARMBLK*);
	void widget_thumb_index( WINDOW *, int);
	void widget_close( WINDOW *win, int obj);
	void widget_busy ( WINDOW *win, int obj);
	void widget_dstry( WINDOW *win);
	int but[] = {ONG1,ONG2,ONG3,ONG4};
	int thb[] = {FOND1,FOND2,FOND3,FOND4};
	
	/* So, create the formular ... */
	WINDOW *win = FormCreate( get_tree( DIAL2), 
							  WAT_NOINFO,
					 	  	  NULL, 
					 	  	  get_string( FORM_TITLE), 
					 	  	  NULL, 
					 	  	  TRUE, 
					 	  	  dup);
	FormSave( win, OC_FORM);
	WindSetStr( win, WF_ICONTITLE, get_string( APP_NAME));
	WindSetPtr( win, WF_ICONDRAW, draw_color_icon, NULL);

	/* Handle the thumb indexes */
 	FormThumb( win, thb, but, 4);	

	/* Thumb should be destroy _before_ the window (EV_TOP) */
	EvntAdd( win, WM_DESTROY, widget_dstry, EV_TOP);

	/* Bind some function to object */
	ObjcAttach( OC_FORM, win, DIAL2_OK, BIND_FUNC, widget_close);
	ObjcAttach( OC_FORM, win, DIAL2_ANNUL, BIND_FUNC, widget_close);
	ObjcAttach( OC_FORM, win, DIAL2_BUSY, BIND_FUNC, widget_busy);

	/* Bind simultanously a variable and a function */
	ObjcAttach( OC_FORM, win, DIAL2_TEST, BIND_VAR, &vtest);
	ObjcAttach( OC_FORM, win, DIAL2_TEST, BIND_FUNC, ftest);
	
	/* An USERDRAW function */
	RsrcUserDraw( OC_FORM, win, USERDIAL, user);
	create_infos( win, INFOS_FORM, DIAL2);
}

void widget_close( WINDOW *win, int obj) {
	ObjcChange( OC_FORM, win, obj, NORMAL, FALSE);
	ApplWrite( app.id, WM_CLOSED, win->handle, 0, 0, 0, 0);
}

void widget_dstry( WINDOW *win) {
	FormThbFree( win);
}

void widget_busy( WINDOW *win, int obj) {
	int i;
	wind_update( BEG_MCTRL);
	for( i=0; i<50; i++) {
		MouseWork();
#ifdef _GEMLIB_H_
		evnt_timer( 100L);
#else
		evnt_timer( 100, 0);
#endif
	}
	graf_mouse( ARROW, 0L);
	wind_update( END_MCTRL);
	ObjcChange( OC_FORM, win, obj, NORMAL, TRUE);
}

/* Here an example of USERDRAW function */

void user( WINDOW *win, PARMBLK *pblk) {
	vsf_color( win->graf.handle, LRED);
	v_circle( win->graf.handle, 
			  pblk->pb_x+pblk->pb_w/2, 
			  pblk->pb_y+pblk->pb_h/2,
			  20);
	vsf_color( win->graf.handle, LGREEN);
	v_circle( win->graf.handle, 
			  pblk->pb_x+pblk->pb_w/2, 
			  pblk->pb_y+10,
			  20);
	vsf_color( win->graf.handle, LBLUE);
	v_circle( win->graf.handle, 
			  pblk->pb_x+10, 
			  pblk->pb_y+pblk->pb_h/2,
			  20);	
}

/* End of file */
