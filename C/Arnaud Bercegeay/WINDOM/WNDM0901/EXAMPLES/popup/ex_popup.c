/*
 *	Example of MenuPopup() calls
 *	WinDom (c) 2000
 *	All rights reserved by the author
 */

#include <stdlib.h>
#include <windom.h>
#include "ex_popup.h"

extern int MenuPopUp2( void *, int, int, int, int, int, int);

/* Popup prefs */
int a;
unsigned int popflags = 0;

/*
 *	Close resources and quit cleany application
 */

void ApTerm( void) {
	while( wglb.first) {
		ApplWrite( app.id, WM_DESTROY, wglb.first->handle); 
		EvntWindom( MU_MESAG);
	}
	RsrcXtype( 0, NULL, 0);
	RsrcFree();
	ApplExit();
	exit( 0);
}

/* close the form and quit app */

void close_and_exit( WINDOW *win, int index, int mode) {
	ObjcChange( mode, win, index, NORMAL, TRUE);
	ApplWrite( app.id, AP_TERM);
}

/* formular Prefs */

void do_prefs( WINDOW *win, int index) {
	OBJECT *frm;

	rsrc_gaddr( 0, PREFS, &frm);
	
	FormWindBegin( frm, "Popups : Prefs");
	FormWindDo( MU_MESAG);
	FormWindEnd( );
	
	ObjcChange( OC_FORM, win, index, NORMAL, TRUE);
}

/*
 * Example Popup 1 : with an object tree 
 */

void ex_popup_1( WINDOW *win, int index) {
	OBJECT *pop;
	int x, y;
	static int last_choice = -1;
	int choice;
	
	rsrc_gaddr( 0, POP1, &pop);
	objc_offset( FORM(win), index, &x, &y);

	choice = 
	MenuPopUp2( pop, 
			   x, y, 
			   -1, -1, 			/* Not used when data is object tree */
			   last_choice,	   	/* */ 
			   P_WNDW + P_CHCK );
	last_choice = choice;
	ObjcChange( OC_FORM, win, index, NORMAL, TRUE);
}

/*
 * Example Popup 2 : with a list of items 
 */

void ex_popup_2( WINDOW *win, int index) {

	char *items[] = { "  My fair lady",
					  "  Summertime",
					  "  My funny Valentine" };
	int x, y;
	static int last_choice = -1;
	int choice;
	
	objc_offset( FORM(win), index, &x, &y);

	choice = 
	MenuPopUp2( items, 
			    x, y, 
			    3, 
			    -1,
			    last_choice,	   	/* */ 
			    P_LIST + P_WNDW + P_CHCK );
	last_choice = choice;
	ObjcChange( OC_FORM, win, index, NORMAL, TRUE);
}

/*
 * Example Popup 3 : with a list of items and a slider 
 */

void ex_popup_3( WINDOW *win, int index) {

	char *items[] = { "  Maman, Papa",
					  "  Le vin",
					  "  Philistins",
					  "  Le vieux l‚on",
					  "  La ronde des jurons",
					  
					  "  A l'ombre du coeur de ma mŠre",
					  "  Le pornographe",
					  "  La femme d'hector",
					  "  Bonhomme",
					  "  Le cocu",
					  
					  "  Comme une soeur",
					  "  Le pŠre no‰l et la petite fille",
					  "  Les fun‚railles d'antan",
					  "  Le bistrot",
					  "  Embrasse-les tous",
					  
					  "  P‚n‚lope",
					  "  L'orage",
					  "  Le m‚cr‚ant",
					  "  Le verger du roi Louis",
					  "  La traŒtesse" };
	int x, y;
	static int last_choice = -1;
	int choice;
	
	objc_offset( FORM(win), index, &x, &y);

	choice = 
	MenuPopUp2( items, 
			   x, y, 
			   20, 
			   8,
			   last_choice,	   	/* */ 
			   P_LIST + P_WNDW + P_CHCK );
	last_choice = choice;
	ObjcChange( OC_FORM, win, index, NORMAL, TRUE);
}

/*
 *	Preference dialog
 */

int bgcolor  = DEFVAL;
int frcolor  = DEFVAL;
int bdcolor  = DEFVAL;
int bgpatt   = DEFVAL;

/* handle APPLY button */
void apply_pref( WINDOW *root, int index) {	
	ApplSet( APS_POPUPWIND, popflags & 0x1);
	ApplSet( APS_POPUPSTYLE, bgcolor, bdcolor, frcolor, bgpatt);
	ObjcChange( OC_FORM, root, index, NORMAL, TRUE);
	ApplWrite( app.id, WM_DESTROY, root->handle);
}

/* Handle the popup style selection */
void pop_style( WINDOW *win, int index) {
	OBJECT *tree;
	int x, y;
	int res;

	rsrc_gaddr( 0, POPSTYLE, &tree);
	objc_offset( FORM( win), index, &x, &y);
	res = MenuPopUp2( tree, x, y, -1, -1,
					  FORM( win)[index].ob_spec.obspec.fillpattern+1,
					  P_WNDW );
	if( res != -1)
		bgpatt = FORM( win)[index].ob_spec.obspec.fillpattern = res-1;
	ObjcDraw( OC_FORM, win, index, 1);
}

/* Handle the popup color selection */
void pop_color( WINDOW *win, int index, int *value) {
	OBJECT *tree;
	int x, y;
	int res;

	rsrc_gaddr( 0, POPCOLOR, &tree);
	objc_offset( FORM( win), index, &x, &y);
	res = MenuPopUp2( tree, x, y, -1, -1,
					  FORM( win)[index].ob_spec.obspec.interiorcol+1,
					  P_WNDW );
	if( res != -1)
		*value = FORM( win)[index].ob_spec.obspec.interiorcol = res-1;
	ObjcDraw( OC_FORM, win, index, 0);
}

void pop_bgcolor( WINDOW *win, int index) {
	pop_color( win, index, &bgcolor);
}

void pop_bdcolor( WINDOW *win, int index) {
	pop_color( win, index, &bdcolor);
}

void pop_frcolor( WINDOW *win, int index) {
	pop_color( win, index, &frcolor);
}


/* create dialog */
void form_pref( WINDOW *root, int index) {
	OBJECT *tree;
	WINDOW *win;

	rsrc_gaddr( 0, PREFS, &tree);
	win = FormCreate( tree, WAT_FORM, NULL, "Popup prefs", NULL, TRUE, FALSE);
	ObjcAttach( OC_FORM, win, PREF_APPLY, BIND_FUNC, apply_pref);
	ObjcAttach( OC_FORM, win, PREF_CANCEL, BIND_FUNC, form_close);
	ObjcAttach( OC_FORM, win, BUT_WINDOW, BIND_BIT, &popflags, 0x1);
	ObjcAttach( OC_FORM, win, BUT_3D,     BIND_BIT, &popflags, 0x2);
	ObjcAttach( OC_FORM, win, POP_BGCOLOR,BIND_FUNC, pop_bgcolor);
	ObjcAttach( OC_FORM, win, POP_BDCOLOR,BIND_FUNC, pop_bdcolor);
	ObjcAttach( OC_FORM, win, POP_FRCOLOR,BIND_FUNC, pop_frcolor);
	ObjcAttach( OC_FORM, win, POP_BGPATT, BIND_FUNC, pop_style);
	
	ObjcChange( OC_FORM, root, index, NORMAL, TRUE);
}

/* Handle the WINCONF button */

void call_winconf( WINDOW *win, int index) {
	char *p;
	int ret;
	
	ret = shel_envrn( &p, "WINCONF=");
	ret = ExecGemApp( ret?p:"winconf.app", "ex_popup.app", NULL, TRUE, FALSE);
	if( ret == -1) FormAlert( 1, "[1][Impossible to launch|WinConf][OK]");
	ObjcChange( OC_FORM, win, index, NORMAL, TRUE);
}


/*
 *	Main Part
 */

int main( void) {
	OBJECT *frm;
	WINDOW *wfrm;
	
	/* Some initialization */
	ApplInit();
	RsrcLoad( "ex_popup.rsc");
	RsrcXtype( 1, NULL, 0);
	
	/* Create the main form */
	rsrc_gaddr( 0, FRM1, &frm);
	wfrm = FormCreate( frm, WAT_FORM, NULL, "Example of Popup", NULL, TRUE, FALSE);
	ObjcAttach( OC_FORM, wfrm, BUT_QUIT, BIND_FUNC, close_and_exit);
	ObjcAttach( OC_FORM, wfrm, BUT_POP1, BIND_FUNC, ex_popup_1);
	ObjcAttach( OC_FORM, wfrm, BUT_POP2, BIND_FUNC, ex_popup_2);
	ObjcAttach( OC_FORM, wfrm, BUT_POP3, BIND_FUNC, ex_popup_3);
	ObjcAttach( OC_FORM, wfrm, BUT_PREF, BIND_FUNC, form_pref);
	ObjcAttach( OC_FORM, wfrm, BUT_WINCONF, BIND_FUNC, call_winconf);
	
	/* Bind some events */
	EvntAttach( NULL, AP_TERM, ApTerm);
	EvntAdd	  ( wfrm, WM_DESTROY, ApTerm, EV_BOT);

	/* Other inits */
	rsrc_gaddr( 0, PREFS, &frm);
	{
	int a,b,c,d;
	ApplGet( APS_POPUPSTYLE, &a, &b, &c, &d);
	frm[POP_BGCOLOR].ob_spec.obspec.interiorcol = a;
	frm[POP_BDCOLOR].ob_spec.obspec.interiorcol = b;
	frm[POP_FRCOLOR].ob_spec.obspec.interiorcol = c;
   	frm[POP_BGCOLOR].ob_spec.obspec.fillpattern = d;
   	}
	
	/* Handle GEM events */
	for( ;;)	EvntWindom( MU_MESAG);
}

/* EOF */
