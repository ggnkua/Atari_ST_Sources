/* support for my_form_do() */
/* this supports requested improvements for:
 *	Expand implementation of Edit Menu Cut/Copy/Paste
 *	Support moveable Dialog boxes
 *	Expand support for BubbleGEM to dialogs, etc. where possible
 *
 *	Initial code from Lattice C Volume 3
 *	Enhancements by: John Rojewski	Oct 15, 1999
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <aes.h>
#include <vdi.h>
#include <osbind.h>
#include <dos.h>
#include <time.h>
#include "global.h"

#define VERSION "0.96  Nov  2, 1999"

#define TREE_XYWH(tree) tree[0].ob_x-3,tree[0].ob_y-3,tree[0].ob_width+6,tree[0].ob_height+6
#define TREE_WHXY(tree) tree[0].ob_width+6,tree[0].ob_height+6,tree[0].ob_x-3,tree[0].ob_y-3
#define MY_OBJ_REDRAW(tree,obj)	objc_draw( tree, obj, MAX_DEPTH, TREE_XYWH(tree) )

void my_form_do_move(OBJECT *tree, int mx, int my)
{
	int rc;
	int endx,endy;

	rc = graf_mouse(FLAT_HAND, NULL);
	rc = graf_dragbox( TREE_WHXY(tree), screenx,screeny,screenw,screenh, &endx, &endy );	/* allow user to drag mouse around on screen */
/*	if moved, allow window redraws for old location */

	if ((endx!=tree[0].ob_x-3)||(endy!=tree[0].ob_y-3)) {
		form_dial(FMD_FINISH,0,0,0,0,TREE_XYWH(tree));
		wind_update(END_UPDATE);
		wind_update(END_UPDATE);	/* temporary */
	/*	allow window_redraw events */
		handle_redraw_event();	/* allow windows to refresh */
	/*	evnt_timer( 250, 0 );	/* wait quarter of a second */
		wind_update(BEG_UPDATE);
		wind_update(BEG_UPDATE);	/* temporary */
	/*	draw dialog in new location */
		tree[ROOT].ob_x = endx+3;	/* need to adjust relative to root */
		tree[ROOT].ob_y = endy+3;	/* ditto */
		form_dial(FMD_START,0,0,0,0,TREE_XYWH(tree));
		objc_draw(tree,ROOT,MAX_DEPTH,TREE_XYWH(tree));
	}
	rc = graf_mouse(ARROW, NULL);
}

void my_form_do_cut_copy_paste(int ccp, OBJECT *tree, int index, int *idx)
{
/* 1=cut, 2=copy, 3=paste */
	char buff[128];
	long len;
	TEDINFO *ted;

	if (!tree[index].ob_flags&EDITABLE) { return; }	/* if EDITABLE field only */
	if ((tree[index].ob_type==G_FTEXT)||(tree[index].ob_type==G_FBOXTEXT)) {	/* for editable objects only! */
		switch (ccp)
		{
		case 1:	get_tedinfo( tree, index, buff );
			copy_text( buff );
		 	objc_edit( tree, index, 0, idx, ED_END );	/* then hide text cursor */
			set_tedinfo( tree, index, "" );	/* terminate existing string */
			MY_OBJ_REDRAW(tree,index);
			objc_edit( tree, index, 0, idx, ED_INIT );	/* show text cursor */
			break;
		case 2:	get_tedinfo( tree, index, buff );
			copy_text( buff );
			break;
		case 3: len = (tree[index].ob_width+8)/8;	/* number of chars in STANDARD 8x16 set */
			ted = tree[index].ob_spec;
			len = ted->te_tmplen;	/* length of TEDINFO template string */
			if (len==0) { beep(); }
			paste_text( buff, len );
			objc_edit( tree, index, 0, idx, ED_END );	/* then hide text cursor */
			set_tedinfo( tree, index, buff );	/* put text into field */
			MY_OBJ_REDRAW(tree,index);
			objc_edit( tree, index, 0, idx, ED_INIT );	/* show text cursor */
			break;
		}
	}
}

int my_form_do( OBJECT *tree, int next )
{
	int edit,which,cont,idx,btn,shft;
	int mx,my,kr,br;
	int mbuff[8];

	if (tree==NULL) { return(0); }	/* must be valid address */
	if (next<0 || next>1000) { next = 0; }	/* reasonable input */

	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);
	edit = 0;
	cont = 1;
	while (cont) {	/* position the cursor on and editing field */
		if (next!=0 && edit!=next && tree[next].ob_flags&EDITABLE) {
			edit = next;
			next = 0;
			/* turn on the text cursor and initialize idx */
			objc_edit( tree, edit, 0, &idx, ED_INIT );
		}

		which = evnt_multi( MU_KEYBD | MU_BUTTON | MU_TIMER,	/* wait for mouse or key */
		/*	0x02, 0x01, 0x01, */
			0x0102, 3, 0,	/* left or right mouse */
			0, 0, 0, 0, 0,
			0, 0, 0, 0, 0,
			mbuff, 500, 0,
			&mx, &my, &btn, &shft, &kr, &br );

		if (which & MU_TIMER) {	/* process timer */
		}
		if (which & MU_KEYBD) {	/* process keystroke */
			if (shft&(K_RSHIFT+K_LSHIFT)) {	/* handle shift keys */
				if ((char)kr=='\x09') { kr=0x4800; }	/* shift-tab = up arrow */
			}
			if (shft&K_CTRL) {	/* process control keys, cut/copy/paste, etc */
				if ((char)kr=='\x18') { my_form_do_cut_copy_paste( 1, tree, edit, &idx ); }	/* ctl X = cut */
				if ((char)kr=='\x03') { my_form_do_cut_copy_paste( 2, tree, edit, &idx ); }	/* ctl C = copy */
				if ((char)kr=='\x16') { my_form_do_cut_copy_paste( 3, tree, edit, &idx ); }	/* ctl V = paste */
				kr = 0;	/* special characters handled */
			} else {
				cont = form_keybd( tree, edit, 0, kr, &next, &kr );
			}
			if (kr && tree[edit].ob_flags&EDITABLE) {	/* if not special char, edit the form */
				objc_edit( tree, edit, kr, &idx, ED_CHAR );
			}
		}
		if (which & MU_BUTTON) {	/* find the object under the mouse */
			next = objc_find( tree, ROOT, MAX_DEPTH, mx, my );
			if (btn&2) {	/* right mouse button down */
				Bconout( 2, '\a' );	/* just tell me for now */
				next = 0;
			}
			if (btn&1) {	/* left mount button down */
				if (next==ROOT) {
				 	if (edit) objc_edit( tree, edit, 0, &idx, ED_END );	/* hide text cursor */
					my_form_do_move(tree, mx, my);	/* drag dialog box */
				 	if (edit) objc_edit( tree, edit, 0, &idx, ED_INIT );	/* show text cursor */
				}
				if (next==NIL) { /* if no object, i.e. outside dialog, ring bell */
					Bconout( 2, '\a' );
					next = 0;
				}
				if (next) {	/* process the left mouse button */
					cont = form_button( tree, next, br, &next );
				}
			}
		}

		/* if finished, or moving to a new object */
		if (!cont || (next!=0 && next!=edit)) {
			if (tree[edit].ob_flags&EDITABLE) {	/* if edit field currently selected */
			 	objc_edit( tree, edit, 0, &idx, ED_END );	/* then hide text cursor */
				edit = 0;	/* no field being edited */
			}
		}
	}
	wind_update(END_MCTRL);
	wind_update(END_UPDATE);
	return( next );
}

/* end of myformdo.c */