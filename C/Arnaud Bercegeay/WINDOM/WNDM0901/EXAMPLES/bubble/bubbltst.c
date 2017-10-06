/*
 *	How use BubbleGEM with WinDom
 *	Copyright D.B‚r‚ziat 1997/2000
 */

#include <stdio.h>
#include <stdlib.h>
#include <windom.h>
#include <av.h>
#include "test.h"

/* An example of control of the BubbleGEM
 * cookie */

/* Get new settings ... and set cookie */

void SetBubble( OBJECT *tree) {
	BHLP bhlp;
	long *dum;
	
	bhlp . delay = atoi( ObjcString( tree, BHLP_DELAY, NULL));
	set_bit( &bhlp.flag, BGC_FONTCHANGED, tree[BHLP_FONTES].ob_state & SELECTED);
	set_bit( &bhlp.flag, BGC_NOWINSTYLE,  !(tree[BHLP_WINDOWS].ob_state & SELECTED));
	set_bit( &bhlp.flag, BGC_DEMONACTIVE, tree[BHLP_DEMON].ob_state & SELECTED);
	set_bit( &bhlp.flag, BGC_SENDKEY, tree[BHLP_SENDKEY].ob_state & SELECTED);
	set_bit( &bhlp.flag, BGC_TOPONLY, tree[BHLP_TOP].ob_state & SELECTED);
	dum = (long*)&bhlp;
	set_cookie( 'BHLP', *dum);
}

/* AP_TERM message */

void ApTerm( void) {
	BubbleFree();
	RsrcXtype( 0, NULL, 0);
	RsrcFree();
	ApplExit();
}

/* The right mouse button calls BubbleGEM */

void CallBubble( void) {
	if( evnt.mbut & 0x2) 
		BubbleEvnt();
}

/* Formular event */

void Form( WINDOW *win) {
	switch( evnt.buff[4]) {
	case OK:
		ObjcChange( OC_FORM, win, OK, NORMAL, 1);
		ApplWriteVA( app.id, WM_CLOSED, win->handle);
		break;
	case APPLIQUE:
		SetBubble( FORM(win));
		ObjcChange( OC_FORM, win, APPLIQUE, NORMAL, 1);
		break;
	}
}

/* Important : to improve the user feeling, use the
 * AV_SENDKEY/AV_SENDCLICK send by BubbleGEM (see documentation) */

void AvSendclick( void) {
	ApplWrite( app.id, AP_BUTTON, evnt.buff[3], evnt.buff[4], evnt.buff[5], evnt.buff[6], evnt.buff[7]);
}

void AvSendkey( void) {
	ApplWrite( app.id, AP_KEYBD, evnt.buff[3], evnt.buff[4], evnt.buff[5], evnt.buff[6], evnt.buff[7]);
}

int main(void) {
	OBJECT *tree;
	int res;
	BHLP bhlp;
	char *string;

	ApplInit();
	RsrcLoad( "TEST.RSC");
	RsrcXtype( 1, NULL, 0);
	rsrc_gaddr( 0, FORM1, &tree);

	/* Attach a bubble to the objects
	 * REM: there is a better way to attach
	 * bubbles to objects (see LOADBUBBLE.C)
	 */
	 
	rsrc_gaddr( 5, H_WINDOWS, &string);
	BubbleAttach( tree, BHLP_WINDOWS, string);
	rsrc_gaddr( 5, H_FONTES, &string);
	BubbleAttach( tree, BHLP_FONTES , string);
	rsrc_gaddr( 5, H_DEMON, &string);
	BubbleAttach( tree, BHLP_DEMON, string);
	rsrc_gaddr( 5, H_TOP, &string);
	BubbleAttach( tree, BHLP_TOP, string);
	rsrc_gaddr( 5, H_SENDKEY, &string);
	BubbleAttach( tree, BHLP_SENDKEY, string);
	rsrc_gaddr( 5, H_OK, &string);
	BubbleAttach( tree, OK, string);
	rsrc_gaddr( 5, H_APPLIQUE, &string);
	BubbleAttach( tree, APPLIQUE, string);
	rsrc_gaddr( 5, H_FOND, &string);
	BubbleAttach( tree, 0, string);
	rsrc_gaddr( 5, H_DELAY, &string);
	BubbleAttach( tree, BHLP_DELAY, string);
	
	/* An example of control of the BubbleGEM
	 * cookie */

	/* Read the cookie and initialize the form */
	if( get_cookie( 'BHLP', (long*)&bhlp)) {
		sprintf( ObjcString( tree, BHLP_DELAY, NULL), "%d", bhlp.delay);
		set_bit( &tree[BHLP_WINDOWS].ob_state, SELECTED, !(bhlp.flag & BGC_NOWINSTYLE));
		set_bit( &tree[BHLP_FONTES].ob_state, SELECTED, bhlp.flag & BGC_FONTCHANGED);
		set_bit( &tree[BHLP_SENDKEY].ob_state, SELECTED, bhlp.flag & BGC_SENDKEY);
		set_bit( &tree[BHLP_DEMON].ob_state, SELECTED, bhlp.flag & BGC_DEMONACTIVE);
		set_bit( &tree[BHLP_TOP].ob_state, SELECTED, bhlp.flag & BGC_TOPONLY);
	} else {
		rsrc_gaddr( 5, NO_BUBBLE, &string);
		form_alert( 1, string);
	}

	evnt.bclick = 258;
	evnt.bmask = 0x1|0x2;
	evnt.bstate = 0;
	
	/* Bind Some events */
	EvntAttach( NULL, WM_XBUTTON, CallBubble);
	EvntAttach( NULL, AP_TERM, 	  ApTerm);
	EvntAttach( NULL, AV_SENDCLICK, AvSendclick);
	EvntAttach( NULL, AV_SENDKEY, AvSendkey);

	rsrc_gaddr( 5, CHOIX_FORM, &string);
	switch( form_alert( 1, string)) {
	case 1:
		/* 
		 * Example with a non modal formular 
		 */
		FormCreate( tree, WAT_FORM, Form, "Non modal formular", NULL, 1, 0);
		while( wglb.first) EvntWindom( MU_MESAG|MU_BUTTON);
		break;

	case 2:
		/*
		 * Example with a modal formular
		 */
	
		FormWindBegin(tree, "Modal formular");
		do {
			res = FormWindDo( MU_MESAG|MU_BUTTON);
			if( res == APPLIQUE) {
				SetBubble( tree);
				ObjcChange( OC_FORM, wglb.first, APPLIQUE, NORMAL, 1);	
			}
		} while( res != OK);
		ObjcChange( OC_FORM, wglb.first, OK, NORMAL, 0);
		FormWindEnd();
		break;
		
	case 3:
		/* 
		 * From BubbleGEM R05, it is possible to handle
		 * bubble in classic formulars (i.e. non window).
		 */

		/* Load BUBBLE.APP if needed : it must be performed outside
		 * FormBegin() because GEM events are stopped inside
		 * this function. */

		BubbleGet();

		FormBegin( tree, NULL);
		do {
			res = BubbleDo( tree, BHLP_DELAY);
			if( res == APPLIQUE) {
				SetBubble( tree);
				ObjcChange( OC_OBJC, tree, APPLIQUE, NORMAL, 1);
			}

		} while( res != OK);
		FormEnd( tree, NULL);
		break;
	}
	
	BubbleFree();
	RsrcXtype( 0, NULL, 0);
	RsrcFree();
	ApplExit();
	return 0;
}
