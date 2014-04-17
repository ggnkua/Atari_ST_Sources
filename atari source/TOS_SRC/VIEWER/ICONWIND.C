/* iconwind.c	icon window handler
 *=======================================================================
 */

#include <string.h>
#include <vdi.h>
#include "iconwind.h"
#include "gemutil.h"

#undef MLOCAL
#define MLOCAL /* */

MLOCAL	void	iw_draw __PROTO((WIND w, GRECT *rclip));
MLOCAL	void	iw_free __PROTO((WIND w));
MLOCAL	WORD	iw_closed __PROTO((WIND w, WORD *msg));
MLOCAL	WORD	iw_ontop __PROTO((WIND w, WORD *msg));
MLOCAL	WORD	iw_retop __PROTO((WIND w, WORD *msg));

WORD
iw_new(wsid, x, y, name, icon, fcolor, bcolor, wind)
	char	*name;
	UWORD	*icon;
	WIND	wind;
{
	ICONWIND iw;
	WORD	id;
	GRECT	r;

	r.g_x = x;
	r.g_y = y;
	r.g_w = ICONWIND_W;
	r.g_h = ICONWIND_H;
	id = w_new(0, &r, wsid, 1, 1, 48, 40, NULL, sizeof(struct iconwind));
	if (id < 0)
		return id;

	iw = (ICONWIND)w_lookup(id);

	/* Set the window to return button events instead of topped messages */
	wind_bevent(id, 1);

	if (name) strcpy(iw->w.name, name);
	iw->w.draw = iw_draw;
	iw->w.free = iw_free; /* this can go away if AES bevent bug is fixed */
	w_windfp(iw, WM_CLOSED) = iw_closed;
	w_windfp(iw, WM_NEWTOP) =
	w_windfp(iw, WM_ONTOP) = iw_ontop;
	w_windfp(iw, WM_UNTOPPED) = iw_retop;

	iw->icon = icon;
	iw->colors[0] = fcolor;
	iw->colors[1] = bcolor;
	iw->wind = wind;

	return iw->w.id;
}

MLOCAL void
iw_draw(w, rclip)
	WIND	w;
	GRECT	*rclip;
{
static FDB	screen_fd, icon_fd = { NULL, 32, 32, 2, 0, 1 };
	GRECT	r;
	WORD	tfill, i, txy[4], bxy[4], ixy[8];

/* Set text area fill based on whether this window is topped */
	tfill = (w->id == wind_gword(0, WF_TOP)) ? FIS_SOLID : FIS_HOLLOW;

/* Set coordinates */
	/* text box */
	txy[2] = (txy[0] = w->rwind.g_x) + w->rwind.g_w - 1;
	txy[3] = (txy[1] = w->rwind.g_y) + 8;

	/* bottom box */
	r = w->rwork;
	r.g_y += 8;
	r.g_h -= 8;
	rc_getpts(&r, bxy);

	/* icon */
	icon_fd.fd_addr = ((ICONWIND)w)->icon;
	ixy[0] = ixy[1] = 0;
	ixy[2] = ixy[3] = 31;
	r.g_x += 8;
	r.g_w -= 16;
	rc_getpts(&r, &ixy[4]);

/* Set drawing parameters: 6x6 system font aligned center, top */
	vst_alignment(w->wsid, 1, 5, &i, &i);
	vst_font(w->wsid, 1);
	vst_height(w->wsid, 4, &i, &i, &i, &i);

	vs_clip(w->wsid, 1, rc_getpts(rclip, NULL));

	/* draw text box */
	vswr_mode(w->wsid, MD_REPLACE);
	vsf_interior(w->wsid, tfill);
	vsf_perimeter(w->wsid, 1);
	vsf_color(w->wsid, BLACK);
	v_bar(w->wsid, txy);
	vswr_mode(w->wsid, MD_XOR);
	v_gtext(w->wsid, w->rwind.g_x + w->rwind.g_w/2 + 1,
					w->rwind.g_y + 2, w->name);

	/* draw icon box */
	vswr_mode(w->wsid, MD_REPLACE);
	vsf_interior(w->wsid, FIS_SOLID);
	vsf_color(w->wsid, ((ICONWIND)w)->colors[1]);
	v_bar(w->wsid, bxy);
	vrt_cpyfm(w->wsid, MD_REPLACE, ixy, &icon_fd, &screen_fd,
			 ((ICONWIND)w)->colors);
}

MLOCAL VOID
iw_free(w)
	WIND w;
{
/* AES BUG: bevent state must be explicitly cleared */
/*	wind_set(w->id, WF_BEVENT, 0); fixed?*/
	w_free(w);
}

MLOCAL WORD
iw_closed(w, msg)
	WIND	w;
	WORD	*msg;
{
	WIND	wind = ((ICONWIND)w)->wind;
	if (wind)
		wind->free(wind);
	w_free(w);
	return 1;
}

MLOCAL WORD
iw_retop(w, msg)
	WIND	w;
	WORD	*msg;
{
	wind_grect(w->id, WF_WORKXYWH, (GRECT *)&msg[4]);
	msg[7] = 8;
	return w_msg(w, WM_REDRAW, msg);
}


MLOCAL WORD
iw_ontop(w, msg)
	WIND	w;
	WORD	*msg;
{
	w_ontop(w, msg);
	return iw_retop(w, msg);
}
