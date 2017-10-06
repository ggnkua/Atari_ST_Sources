/*
 *	WinDom, Librairie GEM par Dominique B‚r‚ziat
 *	copyright 1997/2000
 *
 *	module: mouse.c
 *	description: librairie souris
 */

#include "globals.h"
#include "mouse.h"
#include "mouse.rh"
#include "mouse.rsh"

void MouseObjc( OBJECT *tree, int index) {
	INT16 x, y;
	long rec[2];
		
	objc_offset( tree, index, &x, &y);
	x += tree[index].ob_width/2-1;
	y += tree[index].ob_height/2-1;

	rec[0] = 2;
	rec[1] = (long)y + ((long)x << 16);
	appl_tplay( rec, 1, 100);
}

void MouseSprite( OBJECT *tree, int index) {
	MFORM mform;
	int dum;
	
	dum = tree[index].ob_spec.iconblk->ib_char;
	mform . mf_nplanes = 1;
	mform . mf_fg = (dum>>8)&0x0F;
	mform . mf_bg = dum>>12;	
	mform . mf_xhot = 0; /* pour ‚viter que l'animation */
	mform . mf_yhot = 0; /* ne joue … z‚bulon */

	for( dum = 0; dum<16; dum ++) {
		mform . mf_mask[dum] = tree[index].ob_spec.iconblk->ib_pmask[dum];
		mform . mf_data[dum] = tree[index].ob_spec.iconblk->ib_pdata[dum];
	}
	graf_mouse( USER_DEF, &mform);
}

void MouseWork( void) {
	static int mouse = 0;
	static int init = 1;
	
	if( init) {
		for( init=0; init<NUM_OBS; rsrc_obfix( rs_object, init++));
		init=0;
	}
	mouse = (mouse+1)%8 ;
	MouseSprite( rs_trindex[MOUSE], mouse+1);
}
