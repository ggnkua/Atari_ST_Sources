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
#include <gemfast.h>
#include "xgem.h"
#include "twdefs.h"

#define FM_COPY 3

/* given a mouse x and y coordinate
 * (msx, msy) and the x, y coordinate
 * of a menu bar, find which of the
 * bar's menus should be displayed
 * (if any), On return, the (x,y)
 * coordinate at which the drop-down
 * should be placed is put in *xp and
 * *yp
 */

/* if we're *way* outside of the menu area,
 * make the menu go away
 */

#define GOAWAY ((MENU *)-1L)

static MENU *
whichmenu(bar, barx, bary, msx, msy, xp, yp)
	MENU *bar;
	int barx, bary, msx, msy;
	int *xp, *yp;
{
	MENU *m;
	int xpixel;
	int leftx;

	if (msx < barx || msy < bary)
		return GOAWAY;

	if (msy > bary+gl_hbox)
		return 0;
	xpixel = barx;
	m = bar;
	while(m) {
		leftx = xpixel;
		xpixel += gl_wchar * (strlen(m->title)+2);
		if (msx < xpixel) {
			*xp = leftx+1;
			*yp = bary+gl_hbox;
			return m;
		}
		m = m->next;
	}
	return 0;
}


/*
 * create an object for a drop down menu, with
 * upper corner (x, y)
 */

static OBJECT *
makemenu(m, x, y)
	MENU *m;
	int x, y;
{
	extern int entrylen __PROTO(( ENTRY * ));
	extern char *entrystr __PROTO(( ENTRY *, int ));

	OBJECT *popobj;
	ENTRY *e;
	int numobjects, wide, i;

	numobjects = 1;
	wide = 0;

	for (e = m->contents; e; e = e->next) {
		numobjects++;
		if ( (i = entrylen(e)) > wide)
			wide = i;
	}
	popobj = malloc(numobjects * sizeof(OBJECT));
	if (!popobj) return 0;
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
		if (!popobj[i].ob_spec) return 0;
		popobj[i].ob_x = 0; popobj[i].ob_y = i - 1;
		popobj[i].ob_width = wide; popobj[i].ob_height = 1;
		i++;
	}
	popobj[i-1].ob_flags = LASTOB;

/* now, fix up the object tree */
	for (i = 0; i < numobjects; i++)
		rsrc_obfix(popobj, i);

	popobj[0].ob_x = x;
	popobj[0].ob_y = y;

	return popobj;
}

static void
freeobj(obj)
	OBJECT *obj;
{
	int i;

	for (i = 1; i; i++) {
		free((void *)obj[i].ob_spec);
		if (obj[i].ob_flags & LASTOB)
			break;
	}
	free(obj);
}

#define screen_planes gl_screenplanes

static MFDB scr_mfdb;

static void
savearea(mfdb, x, y, w, h)
	MFDB *mfdb;
	int x, y, w, h;
{
	int blitrec[8];

	blitrec[0] = x;
	blitrec[1] = y;
	blitrec[2] = x + w - 1;
	blitrec[3] = y + h - 1;
	blitrec[4] = 0;
	blitrec[5] = 0;
	blitrec[6] = w - 1;
	blitrec[7] = h - 1;

/* mfdb->fd_addr is assumed to be set already */
	mfdb->fd_w = w;
	mfdb->fd_h = h;
	mfdb->fd_wdwidth = ((w+15)/16);
	mfdb->fd_stand = 0;
	mfdb->fd_nplanes = screen_planes;

	hide_mouse();
	set_clip(x, y, w, h);
	vro_cpyfm(vdi_handle, FM_COPY, blitrec, &scr_mfdb, mfdb);
	show_mouse();
}

static void
restorearea(mfdb, x, y, w, h)
	MFDB *mfdb;
	int x, y, w, h;
{
	int blitrec[8];

	blitrec[0] = 0;
	blitrec[1] = 0;
	blitrec[2] = w-1;
	blitrec[3] = h-1;
	blitrec[4] = x;
	blitrec[5] = y;
	blitrec[6] = x+w-1;
	blitrec[7] = y+h-1;

	hide_mouse();
	set_clip(x, y, w, h);
	vro_cpyfm(vdi_handle, FM_COPY, blitrec, mfdb, &scr_mfdb);
	show_mouse();
}

/*
 * deal with user interactions with a drop-down menu bar
 * (x,y) is the upper left hand corner of the region
 * containing the bar
 */

void
dropdown_menu(bar, x, y)
	MENU *bar;
	int x,y;
{
	OBJECT *popobj = 0;
	MENU *m, *lastm, *tmpm;
	ENTRY *e;
	int i;
	int w, h;
	int event, msx, msy, mbutton, mbreturn, keycode, dummy;
	int curobj = -1;
	int newobj;
	unsigned lowbyte, hibyte;
	int barx, bary;
	long blitbuf;
	MFDB blit_mfdb;
	int newx, newy;
	int drawn = 0;
	int winhandle;
	int winowner;

	wind_update(BEG_MCTRL);
/* check to see that we have the right top window */
	wind_get(0, WF_TOP, &winhandle, &winowner, &dummy, &dummy);
	if (!gl_topwin ||
	    gl_topwin->wi_handle != winhandle) {
		wind_update(END_MCTRL);
		return;
	}

	barx = x;
	bary = y;

	msx = msy = 0;
	event = evnt_multi(MU_M1,
		2, 0x0001, 0x0001,
		1, msx, msy, 1, 1,
		0, 0, 0, 0, 0,
		0L, 0L,
		&msx, &msy, &mbutton, &dummy,
		&keycode, &mbreturn);

	wind_get(0, WF_SCREEN, &hibyte, &lowbyte, &dummy, &dummy);
	blitbuf = ((long)hibyte << 16L) | lowbyte;

	blit_mfdb.fd_addr = blitbuf;
/*
 * find which (if any) menu should be displayed
 */


	m = whichmenu(bar, barx, bary, msx, msy, &newx, &newy);
	if (!m || m == GOAWAY) {
		wind_update(END_MCTRL);
		return;
	}
	lastm = 0;
	w = h = 0;

/* display the tree and interact with it */

	for(;;) {
		if (m != lastm) {
			if (popobj) {
				freeobj(popobj);
				popobj = 0;
			}
			if (drawn) {
				restorearea(&blit_mfdb, x, y, w, h);
				drawn = 0;
			}
			if (!m || (m == GOAWAY)) {
				break;
			}
			lastm = m;
			x = newx;
			y = newy;

	/* create a new object tree */
			popobj = makemenu(m, x, y);
			if (!popobj) {
				break;
			}
	/* "-1" takes care of the bordering box */
			x = popobj[0].ob_x - 1;
			y = popobj[0].ob_y - 1;
			if (x >= xdesk+wdesk)
				x = xdesk+wdesk-1;
			if (y >= ydesk+hdesk) {
				break;
			};
			w = popobj[0].ob_width + 2;
			h = popobj[0].ob_height + 2;
			if (x + w > xdesk + wdesk) {
				w = xdesk + wdesk - x;
			}
			if (y + h > ydesk + hdesk)
				h = ydesk + hdesk - y;
 
	/* save the area we're about to draw over */
			savearea(&blit_mfdb, x, y, w, h);

	/* now actually draw the object */
			objc_draw(popobj, 0, 1, x, y, w, h);
			drawn = 1;
		}

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
			} else {
				newobj = -1;
				tmpm = whichmenu(bar, barx, bary, msx, msy, &newx, &newy);
				if (tmpm)
					m = tmpm;
				else if (msy - y > h + gl_hbox)
					m = GOAWAY;
				else if (msx - x > w + gl_wbox)
					m = GOAWAY;
			}

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
					break;
				} else i++;
			}
		}
		if (event & MU_BUTTON) {
			break;
		}
	}

/* free memory allocated by `entrystr' */
	if (popobj) {
		freeobj(popobj);
	}
	if (drawn)
		restorearea(&blit_mfdb, x, y, w, h);

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

char *
menustr(bar)
	MENU *bar;
{
	static char buf[80];
	char *s = buf;

	buf[0] = 0;
	while(bar) {
		strcat(s, " ");
		strcat(s, bar->title);
		strcat(s, " ");
		bar = bar->next;
	}
	return buf[0] ? buf : 0;
}

