/*
 * Copyright 1992 Eric R. Smith. All rights reserved.
 * Redistribution is permitted only if the distribution
 * is not for profit, and only if all documentation
 * (including, in particular, the file "copying")
 * is included in the distribution in unmodified form.
 * THIS PROGRAM COMES WITH ABSOLUTELY NO WARRANTY, NOT
 * EVEN THE IMPLIED WARRANTIES OF MERCHANTIBILITY OR
 * FITNESS FOR A PARTICULAR PURPOSE. USE AT YOUR OWN
 * RISK.
 */
#include <stdlib.h>
#include <stddef.h>
#include <string.h>
#include <osbind.h>
#include "xgem.h"

/*
 * pop up a menu at screen location (x, y), and deal with user
 * interactions with it
 */

void
popup_menu( m, x, y )
	MENU *m;
	int x,y;
{
	extern int entrylen __PROTO(( ENTRY * ));
	extern char *entrystr __PROTO(( ENTRY *, int ));
	OBJECT *popobj;
	ENTRY *e;
	int numobjects = 1;
	int wide = 0;
	int i;
	int w, h;
	int event, msx, msy, mbutton, mbreturn, keycode, dummy;
	int curobj = -1;
	int newobj;
	int lowbyte;

	msx = x; msy = y;
	for (e = m->contents; e; e = e->next) {
		numobjects++;
		if ( (i = entrylen(e)) > wide)
			wide = i;
	}
	popobj = malloc(numobjects * sizeof(OBJECT));
	if (!popobj) return;

/* first, create the box around the menu */
	popobj[0].ob_next = -1;
	popobj[0].ob_head = 1;
	popobj[0].ob_tail = numobjects - 1;
	popobj[0].ob_type = G_BOX;
	popobj[0].ob_flags = LASTOB; popobj[0].ob_state = NORMAL;
	popobj[0].ob_spec = 0x00ff1100L;
	popobj[0].ob_x = x/gl_wchar; popobj[0].ob_y = y/gl_hchar;
	popobj[0].ob_width = wide;
	popobj[0].ob_height = numobjects - 1;
	i = 1;
	for (e = m->contents; e; e = e->next) {
		popobj[i].ob_next = (e->next) ? i+1 : 0;
		popobj[i].ob_head = popobj[i].ob_tail = -1;
		popobj[i].ob_type = G_STRING;
		popobj[i].ob_flags = NONE;
		popobj[i].ob_state = e->state;
		popobj[i].ob_spec = (long)entrystr(e, wide);
		if (!popobj[i].ob_spec) return;
		popobj[i].ob_x = 0; popobj[i].ob_y = i - 1;
		popobj[i].ob_width = wide; popobj[i].ob_height = 1;
		i++;
	}
	popobj[i-1].ob_flags = LASTOB;

/* now, fix up the object tree */
	for (i = 0; i < numobjects; i++)
		rsrc_obfix(popobj, i);

/* find the rectangle the tree will appear in; make sure the whole menu
 * will appear on-screen
 */
	x = popobj[0].ob_x - 1; y = popobj[0].ob_y - 1;
	w = popobj[0].ob_width + 2; h = popobj[0].ob_height + 2;

	if (x + w > xdesk + wdesk) x = xdesk + wdesk - w;
	if (y + h > ydesk + hdesk) y = ydesk + hdesk - h;
	if (x < xdesk) x = xdesk;
	if (y < ydesk) y = ydesk;

	popobj[0].ob_x = x+1; popobj[0].ob_y = y+1;

/* display the tree */
	wind_update(BEG_MCTRL);
	form_dial(0, x, y, w, h, x, y, w, h);

	objc_draw(popobj, 0, 1, x, y, w, h);

/* interact with it */

	for(;;) {
		event = evnt_multi(MU_BUTTON|MU_M1|MU_KEYBD,
			2, 0x0001, 0x0001,
			1, msx, msy, 1, 1,
			0, 0, 0, 0, 0,
			0L, 0L,
			&msx, &msy, &mbutton, &dummy,
			&keycode, &mbreturn);

		if (event & MU_M1) {
			if (msx >= x && msx <= x+w && msy >= y && msy <= y+h) {
				newobj = objc_find(popobj, 0, 1, msx, msy);
			} else newobj = -1;

			if (curobj > 0 && curobj != newobj) {
				objc_change(popobj, curobj, 0, x, y, w, h,
					NORMAL, 1);
			}
			curobj = newobj;
			if (curobj > 0 && popobj[curobj].ob_state != DISABLED) {
				objc_change(popobj, curobj, 0,x,y,w,h,
						SELECTED, 1);
			} else {
				curobj = -1;
			}
		}
		if (event & MU_KEYBD) {
			lowbyte = keycode & 0x00ff;
			i = 1;
			for (e = m->contents; e; e = e->next) {
				if ((lowbyte && e->keycode == lowbyte) ||
				     e->keycode == keycode) {
					curobj = i;
					event |= MU_BUTTON;
					break;
				} else i++;
			}
		}
		if (event & MU_BUTTON) {
			break;
		}
	}

/* free memory allocated by `entrystr' */
	for (i = 1; i < numobjects; i++)
		free((void *)popobj[i].ob_spec);
	free(popobj);
	form_dial(3, x, y, w, h, x, y, w, h);
	wind_update(END_MCTRL);
	if (curobj > 0) {
		for (e = m->contents; e; e = e->next) {
			--curobj;
			if (curobj == 0) {
				(*e->func)(e->arg);
				break;
			}
		}
	}
}

