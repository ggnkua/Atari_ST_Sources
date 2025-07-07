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
#include <gemfast.h>
#include <aesbind.h>
#include <vdibind.h>
#include <osbind.h>
#include <string.h>
#include "xgem.h"

static void
draw_objwin(v, x, y, w, h)
	WINDOW *v;
	int x,y,w,h;
{
	OBJECT *t = (OBJECT *)v->extra;

	objc_draw(t, 0, 9, x, y, w, h);
}

static void
full_objwin(v)
	WINDOW *v;
{
	int newx, newy, neww, newh;
	OBJECT *t;

	if (v->flags & WFULLED) {
		wind_get(v->wi_handle, WF_PREVXYWH, &newx, &newy, &neww,
			 &newh);
	} else {
		wind_get(v->wi_handle, WF_FULLXYWH, &newx, &newy, &neww,
			&newh);
	}

	wind_set(v->wi_handle, WF_CURRXYWH, newx, newy, neww, newh);
	wind_get(v->wi_handle, WF_WORKXYWH, &v->wi_x, &v->wi_y, &v->wi_w,
		&v->wi_h);

	v->flags ^= WFULLED;
	t = v->extra;
	t->ob_x = v->wi_x;
	t->ob_y = v->wi_y;
}

static void
move_objwin(v, x, y, w, h)
	WINDOW *v;
	int x, y, w, h;
{
	int fullx, fully, fullw, fullh;
	OBJECT *t;

	wind_get(v->wi_handle, WF_FULLXYWH, &fullx, &fully, &fullw, &fullh);

	if (w > fullw) w = fullw;
	if (h > fullh) h = fullh;

	if (w != fullw || h != fullh)
		v->flags &= ~WFULLED;

	wind_set(v->wi_handle, WF_CURRXYWH, x, y, w, h);
	wind_get(v->wi_handle, WF_WORKXYWH, &v->wi_x, &v->wi_y,
		&v->wi_w, &v->wi_h);

	t = v->extra;
	t->ob_x = v->wi_x;
	t->ob_y = v->wi_y;
}

static void
size_objwin(v, x, y, w, h)
	WINDOW *v;
	int x, y, w, h;
{
	move_objwin(v, x, y, w, h);
}

WINDOW *
create_objwin(tree, title, kind, wx, wy, ww, wh)
	OBJECT *tree;
	char *title;
	int kind, wx, wy, ww, wh;
{
	WINDOW *v;

	v = create_window(title, kind, wx, wy, ww, wh);
	if (!v) return v;
	v->extra = tree;
	v->wtype = OBJ_WIN;
	v->draw = draw_objwin;
	v->fulled = full_objwin;
	v->sized = size_objwin;
	v->moved = move_objwin;

	return v;
}
