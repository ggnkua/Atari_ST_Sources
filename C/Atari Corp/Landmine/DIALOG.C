/*
	dialog.c

	GEM Dialog Handling Routine
	Copyright 1991 Atari Corporation

	Created: March 17, 1991 Kenneth Soohoo AETAS
*/

#include <gemdefs.h>
#include <obdefs.h>
#include <aesbind.h>
#include "dialog.h"

/* Dialog handling variables */
GRECT about, nothing;
Prect dial_bx;
extern int SCw, SCh;

void open_dialog(tree)
OBJECT *tree;
/* open_dialog(tree)
   Makes the approriate calls to draw the dialog on the screen, plus 
   extras.
 */
{
	dial_bx.x = &about.g_x; dial_bx.y = &about.g_y; 	/* Point Prect to */
	dial_bx.w = &about.g_w; dial_bx.h = &about.g_h;	/* GRECT */
	nothing.g_x = SCw / 2; nothing.g_y = SCh / 2;
	nothing.g_w = 1; nothing.g_h = 1;

	mouse_off();
	form_center(tree, dial_bx);			/* Center everything */

	form_dial(FMD_START, nothing, about);/* Redraw message */
	form_dial(FMD_GROW, nothing, about);		/* Expand box */

	objc_draw(tree, ROOT, MAX_DEPTH, about);	/* Draw on screen */
	mouse_on();
}

void close_dialog()
/*
   Performs the appropriate calls to remove the dialog box from the screen.
 */
{
	mouse_off();

	form_dial(FMD_SHRINK, nothing, about);		/* Collapse box */
	form_dial(FMD_FINISH, nothing, about);		/* Redraw message */

	mouse_on();
}

int do_dialog(tree)
OBJECT *tree;
/* 
   Puts up and gives control of a dialog box to AES.
   Returns the exit button's ID.
 */
{
	int button;

	open_dialog(tree);
	button = form_do(tree, 0);		/* Wait for EXIT */
	close_dialog();

	tree[button & 0x7FFF].ob_state = NORMAL;/* De-select exit button */

	return(button);
}
