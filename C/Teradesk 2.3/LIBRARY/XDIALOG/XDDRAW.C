/*
 * Xdialog Library. Copyright (c) 1993, 1994, 2002 W. Klaren.
 *
 * This file is part of Teradesk.
 *
 * Teradesk is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Teradesk is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Teradesk; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#ifdef __PUREC__
 #include <np_aes.h>
 #include <vdi.h>
#else
 #include <aesbind.h>
 #include <vdibind.h>
#endif

#include <stddef.h>
#include <string.h>

#include "xdialog.h"
#include "internal.h"

static short rb_data8[] = { 0x07E0, 0x1818, 0x23C4, 0x4422, 0x23C4,
							0x1818, 0x07E0, 0x0000 };
static short rbs_data8[] = { 0x07E0, 0x1818, 0x23C4, 0x47E2, 0x23C4,
							 0x1818, 0x07E0, 0x0000 };
static short rb_mask8[] = { 0xF81F, 0xE007, 0xC003, 0x8001, 0xC003,
							0xE007, 0xF81F, 0xFFFF };
static short rb_data16[] = { 0x0000, 0x03C0, 0x0C30, 0x1008, 0x2184,
							 0x2664, 0x4422, 0x4812, 0x4812, 0x4422,
							 0x2664, 0x2184, 0x1008, 0x0C30, 0x03C0,
							 0x0000 };
static short rbs_data16[] = { 0x0000, 0x03C0, 0x0C30, 0x1008, 0x2184,
							  0x27E4, 0x47E2, 0x4FF2, 0x4FF2, 0x47E2,
							  0x27E4, 0x2184, 0x1008, 0x0C30, 0x03C0,
							  0x0000 };
static short rb_mask16[] = { 0xFFFF, 0xFC3F, 0xF00F, 0xE007, 0xC003,
							 0xC003, 0x8001, 0x8001, 0x8001, 0x8001,
							 0xC003, 0xC003, 0xE007, 0xF00F, 0xFC3F,
							 0xFFFF };

static int xd_bg_col = 8;
static int xd_ind_col = 8;
static int xd_act_col = 8;

static MFDB cursor_mfdb = {	NULL, 1, 0, 1, 0, 0, 0, 0, 0 };
/*
int xd_get_3d_color(int flags);
*/
/********************************************************************
 *																	*
 * Funkties voor het tekenen van de userdefined objects.			*
 *																	*
 ********************************************************************/

/*
 * Functie die de achtergrondkleur van een object bepaald.
 *
 * Parameters:
 *
 * flags	- De objectvlaggen van een object.
 *
 * Resultaat : kleur van het object.
 *

int xd_get_3d_color(int flags)
{
	int color;

	if (IS_ACT(flags))
		color = xd_act_col;
	else if (IS_IND(flags))
		color = xd_ind_col;
	else if (IS_BG(flags))
		color = xd_bg_col;
	else
		color = 0;

	return (color >= xd_ncolors) ? 0 : color;
}
*/
/*
 * Funktie die de dikte van de rand om een button teruggeeft.
 */

static int xd_bborder(OBJECT *tree, int object)
{
	if (tree[object].ob_flags & DEFAULT)
		return 3;
	else if (tree[object].ob_flags & EXIT)
		return 2;
	else
		return 1;
}

static long xd_strlen(char *s)
{
	long l;

	l = strlen(s);

	if (strchr(s, '#') != NULL)
		l--;

	return l;
}

#define prt_text(s, x, y, state)  prt_xtndtext(s, x, y, state, 0)

static void prt_xtndtext(char *s, int x, int y, int state, int attrib)
{
	char tmp[80], *h, *p = NULL;	/* <- buffer is enlarged! */

	if (state & DISABLED)			/* HR 151102: changed confusing name 'flags' to 'state' :-) */
		attrib ^= 2;

	vst_effects(xd_vhandle, attrib);

	h = strcpy(tmp, s);

	/* HR 151102: uses AES 4 WHITEBAK */
	if (state & WHITEBAK)
	{
		int und = (state<<1)>>9;
		if (und >= 0)
		{
			und &= 0x7f;
			if (und < strlen(tmp))
				p = tmp + und;
		}
	}
	else

	/* I_A enhanced: now you can place '#' in text itself! */

		while ((h = strchr(h, '#')) != NULL)
		{
			strcpy(h, h + 1);
			if (*h != '#')
			{
				/* remember location of single '#' in text! */
				p = h--;
			}
			/* else: double '#': make it one! */
			h++;
		}

	v_gtext(xd_vhandle, x, y, tmp);

	if (p)
	{
		/* do underline some character! */
		int xtnd[8];
		char c = *p;

		*p = 0;

		/* request position of this character! */

		vqt_extent(xd_vhandle, tmp, xtnd);
		vst_effects(xd_vhandle, attrib ^ 8);	/* XOR due to text-style extensions! */
		tmp[0] = c;
		tmp[1] = 0;
		v_gtext(xd_vhandle, x + (xtnd[2] - xtnd[0]), y, tmp);
	}
}


static void draw_rect(int x, int y, int w, int h)
{
	int pxy[10];

	pxy[0] = x;
	pxy[1] = y;
	pxy[2] = x + w - 1;
	pxy[3] = y;
	pxy[4] = x + w - 1;
	pxy[5] = y + h - 1;
	pxy[6] = x;
	pxy[7] = y + h - 1;
	pxy[8] = x;
	pxy[9] = y;

	v_pline(xd_vhandle, 5, pxy);
}

static void draw_frame(RECT *frame, int start, int eind)		/* HR 151102: reserve 'end' for lamguage */
{
	int i, s, e;

	if (start > eind)
	{
		s = eind;
		e = start;
	}
	else
	{
		s = start;
		e = eind;
	}

	for (i = s; i <= e; i++)
		draw_rect(frame->x + i, frame->y + i, frame->w - 2 * i,
				  frame->h - 2 * i);
}

static void set_linedef(int color)
{
	vsl_color(xd_vhandle, color);
	vsl_ends(xd_vhandle, 0, 0);
	vsl_type(xd_vhandle, 1);
	vsl_width(xd_vhandle, 1);
}

static void set_textdef(void)
{
	int dummy;

	vst_font(xd_vhandle, xd_regular_font.fnt_id);
	vst_rotation(xd_vhandle, 0);
	vst_alignment(xd_vhandle, 0, 5, &dummy, &dummy);
	vst_point(xd_vhandle, xd_regular_font.fnt_height, &dummy, &dummy, &dummy, &dummy);
	vst_color(xd_vhandle, 1);
}

static void set_filldef(int color)
{
	vsf_color(xd_vhandle, color);
	vsf_interior(xd_vhandle, FIS_SOLID);
	vsf_perimeter(xd_vhandle, 0);
}

static void clr_object(RECT *r, int color)
{
	int pxy[4];

	xd_rect2pxy(r, pxy);
	set_filldef(color);
	vr_recfl(xd_vhandle, pxy);
}

static int cdecl ub_drag(PARMBLK *pb)
{
	int object = pb->pb_obj, pxy[4], border;
	RECT frame, clip;
	OBJECT *tree = pb->pb_tree;
	union { bfobspec obspec; long index; } obspec;

	clip.x = pb->pb_xc;
	clip.y = pb->pb_yc;
	clip.w = pb->pb_wc;
	clip.h = pb->pb_hc;

	frame.x = pb->pb_x;
	frame.y = pb->pb_y;
	frame.w = pb->pb_w;
	frame.h = pb->pb_h;

	vswr_mode(xd_vhandle, MD_REPLACE);

	xd_clip_on(&clip);

	clr_object(&frame, /* (xd_draw_3d) ? xd_get_3d_color(tree[object].ob_flags) : */ 0);

	obspec.index = pb->pb_parm;

	set_linedef(obspec.obspec.framecol);
	draw_frame(&frame, 0, obspec.obspec.framesize - 1);
/*
	if(xd_draw_3d)
	{	
		pxy[0] = frame.x - 1;
		pxy[1] = frame.y + obspec.obspec.framesize;
		pxy[2] = frame.x - 1;
		pxy[3] = frame.y + frame.h;

		vsl_color(xd_vhandle, 0);
		v_pline(xd_vhandle, 2, pxy);

		pxy[0] = frame.x - 1;
		pxy[1] = frame.y + frame.h;
		pxy[2] = frame.x + frame.w - obspec.obspec.framesize - 1;
		pxy[3] = frame.y + frame.h;

		vsl_color(xd_vhandle, 9);
		v_pline(xd_vhandle, 2, pxy);

		border = 0;			/* schuine lijn alleen in binnenzijde */
	}
	else
*/	{
		if (tree[object].ob_state & OUTLINED)		/* HR 151102 */
		{
			vsl_color(xd_vhandle, 1);
			draw_frame(&frame, -3, -3);
			vsl_color(xd_vhandle, 0);
			draw_frame(&frame, -1, -2);
			border = 3;
		}
		else
			border = 0;
	}

	vsl_color(xd_vhandle, 1);

	pxy[0] = frame.x - border;
	pxy[1] = frame.y - border;
	pxy[2] = frame.x + frame.w - 1 + border;
	pxy[3] = frame.y + frame.h - 1 + border;

	v_pline(xd_vhandle, 2, pxy);

	xd_clip_off();

	return 0;
}

static int cdecl ub_roundrb(PARMBLK *pb)
{
	int x = pb->pb_x, y = pb->pb_y, pxy[8];
	static int ci[2] = {1, 0};
	void *data;
	MFDB smfdb, dmfdb;
	RECT clip;

	clip.x = pb->pb_xc;
	clip.y = pb->pb_yc;
	clip.w = pb->pb_wc;
	clip.h = pb->pb_hc;

	xd_clip_on(&clip);

	if (xd_regular_font.fnt_chh < 16)
	{
		smfdb.fd_addr = rb_mask8;
		data = (pb->pb_currstate & SELECTED) ? rbs_data8 : rb_data8;
		smfdb.fd_h = 8;
		pxy[3] = 7;
	}
	else
	{
		smfdb.fd_addr = rb_mask16;
		data = (pb->pb_currstate & SELECTED) ? rbs_data16 : rb_data16;
		smfdb.fd_h = 16;
		pxy[3] = 15;
	}

	smfdb.fd_stand = 0;
	smfdb.fd_nplanes = 1;
	smfdb.fd_w = 16;
	smfdb.fd_wdwidth = 1;

	dmfdb.fd_addr = NULL;

	pxy[0] = 0;
	pxy[1] = 0;
	pxy[2] = 15;
	pxy[4] = x;
	pxy[5] = y;
	pxy[6] = x + pxy[2];
	pxy[7] = y + pxy[3];

	vrt_cpyfm(xd_vhandle, MD_ERASE, pxy, &smfdb, &dmfdb, ci);
	smfdb.fd_addr = data;
	vrt_cpyfm(xd_vhandle, MD_TRANS, pxy, &smfdb, &dmfdb, ci);

	vswr_mode(xd_vhandle, /* (IS_BG(pb->pb_tree[pb->pb_obj].ob_flags) &&
						   xd_draw_3d) ? MD_TRANS : */ MD_REPLACE);
	set_textdef();
	prt_text((char *) pb->pb_parm, x + (5 * xd_regular_font.fnt_chw) / 2, y,
			 pb->pb_currstate);

	xd_clip_off();

	return 0;
}

static int cdecl ub_rectbut(PARMBLK *pb)
{
	int x = pb->pb_x, y = pb->pb_y, pxy[4];
	RECT clip;

	clip.x = pb->pb_xc;
	clip.y = pb->pb_yc;
	clip.w = pb->pb_wc;
	clip.h = pb->pb_hc;

	xd_clip_on(&clip);

	pxy[0] = x + 2;				/* <- fixed I_A: effects TRISTATE_1 too! */
	pxy[1] = y + 2;				/* <- fixed I_A */
	pxy[2] = x + xd_regular_font.fnt_chw * 2 - 2;
	pxy[3] = y + xd_regular_font.fnt_chh - 2;

	vswr_mode(xd_vhandle, MD_REPLACE);
	set_filldef(0);
	vr_recfl(xd_vhandle, pxy);
	set_linedef(1);
	draw_rect(x + 1, y + 1, 2 * xd_regular_font.fnt_chw - 1, xd_regular_font.fnt_chh - 1);

	if (pb->pb_currstate & SELECTED)
	{
		pxy[0]--;
		pxy[1]--;
		pxy[2]++;
		pxy[3]++;
		v_pline(xd_vhandle, 2, pxy);
		pxy[0] = pxy[2];
		pxy[2] = x + 1;
		v_pline(xd_vhandle, 2, pxy);
	}

	vswr_mode(xd_vhandle, /* (IS_BG(pb->pb_tree[pb->pb_obj].ob_flags) &&
						   xd_draw_3d) ? MD_TRANS : */ MD_REPLACE);
	set_textdef();
	prt_text((char *) pb->pb_parm, x + 3 * xd_regular_font.fnt_chw, y,
			 pb->pb_currstate);

	xd_clip_off();

	return 0;
}

static int cdecl ub_rectbuttri(PARMBLK *pb)
{
	int x = pb->pb_x, y = pb->pb_y, pxy[4];
	int state;
	RECT clip;

	clip.x = pb->pb_xc;
	clip.y = pb->pb_yc;
	clip.w = pb->pb_wc;
	clip.h = pb->pb_hc;

	xd_clip_on(&clip);

	pxy[0] = x + 2;				/* <- fixed I_A: effects TRISTATE_1 too! */
	pxy[1] = y + 2;				/* <- fixed I_A */
	pxy[2] = x + xd_regular_font.fnt_chw * 2 - 2;
	pxy[3] = y + xd_regular_font.fnt_chh - 2;

	vswr_mode(xd_vhandle, MD_REPLACE);
	set_filldef(0);
	vr_recfl(xd_vhandle, pxy);
	set_linedef(1);
	draw_rect(x + 1, y + 1, 2 * xd_regular_font.fnt_chw - 1, xd_regular_font.fnt_chh - 1);

	/* handle tri-state */

	state = pb->pb_tree[pb->pb_obj].ob_state;

	switch (xd_get_tristate(state))
	{
	case TRISTATE_0:
		break;
	case TRISTATE_1:
		vsf_interior(xd_vhandle, FIS_PATTERN);
		vsf_style(xd_vhandle, 4);
		vsf_color(xd_vhandle, 1);
		v_bar(xd_vhandle, pxy);
		vsf_interior(xd_vhandle, FIS_SOLID);	/* HR 021202 always return to default */
		break;
	case TRISTATE_2:
		pxy[0]--;
		pxy[1]--;
		pxy[2]++;
		pxy[3]++;
		v_pline(xd_vhandle, 2, pxy);
		pxy[0] = pxy[2];
		pxy[2] = x + 1;
		v_pline(xd_vhandle, 2, pxy);
		break;
	}

	vswr_mode(xd_vhandle, /* (IS_BG(pb->pb_tree[pb->pb_obj].ob_flags) &&
						   xd_draw_3d) ? MD_TRANS : */ MD_REPLACE);
	set_textdef();
	prt_text((char *) pb->pb_parm, x + 3 * xd_regular_font.fnt_chw, y, state);

	xd_clip_off();

	return 0;
}

static int cdecl ub_cyclebut(PARMBLK *pb)
{
	int x = pb->pb_x, y = pb->pb_y, w = pb->pb_w, h = pb->pb_h;
	RECT clip;

	clip.x = pb->pb_xc;
	clip.y = pb->pb_yc;
	clip.w = pb->pb_wc;
	clip.h = pb->pb_hc;

	xd_clip_on(&clip);

	vswr_mode(xd_vhandle, MD_REPLACE);
	clr_object(&clip, 0);
	set_linedef(1);
	draw_rect(x, y, w, h);

	xd_clip_off();

	return 0;
}

/* HR 021202: */
static int cdecl ub_scrledit(PARMBLK *pb)
{
	char s[132];
	XUSERBLK *blk = (XUSERBLK *)pb->pb_parm;
	TEDINFO *ted = blk->ob_spec.tedinfo;	/* HR 021202 */
	char *text = s,
	     *save = ted->te_ptext;
	int x = pb->pb_x,
	    y = pb->pb_y,
	    w = pb->pb_w,
	    h = pb->pb_h,
	    tw = strlen(save),
	    ow = strlen(ted->te_pvalid);
	RECT clip;

	ted->te_ptext = s;
	clip.x = pb->pb_xc;
	clip.y = pb->pb_yc;
	clip.w = pb->pb_wc;
	clip.h = pb->pb_hc;

	xd_clip_on(&clip);

	vswr_mode(xd_vhandle, MD_REPLACE);
	set_textdef();
	y += (h - xd_regular_font.fnt_chh - 1) / 2;
	if (tw > ow)
	{
		strsncpy(s, save + blk->ob_shift, ow + 1);		/* HR 120203: secure cpy */
		prt_text("< ", x - 2*xd_regular_font.fnt_chw, y, 0);
		prt_text(s, x, y, pb->pb_currstate);
		prt_text(" >", x + w, y, 0);
	}
	else
	{
		int i= ow - tw;
		strcpy(s, save);
		text += tw;
		while (i--)
			*text++ = '_';
		*text = 0;
		prt_text("  ", x - 2*xd_regular_font.fnt_chw, y, 0);
		prt_text(s, x, y, pb->pb_currstate);
		prt_text("  ", x + w, y, 0);
	}

	xd_clip_off();

	ted->te_ptext = save;
	return 0;
}

static int cdecl ub_button(PARMBLK *pb)
{
	int border, object = pb->pb_obj, pxy[8], flags, offset = 0;
	int x, y;
/*	int button_3d, act_ind_sel = FALSE;
*/	char *string;
	RECT frame, clip;
	OBJECT *tree = pb->pb_tree;

	clip.x = pb->pb_xc;
	clip.y = pb->pb_yc;
	clip.w = pb->pb_wc;
	clip.h = pb->pb_hc;

	xd_clip_on(&clip);

	border = xd_bborder(tree, object);

	if (IS_XUSER(tree[object].ob_spec.userblk))
	{
		flags = ((XUSERBLK *)(pb->pb_parm))->ob_flags;
		string = ((XUSERBLK *)(pb->pb_parm))->ob_spec.free_string;		/* HR 021202 */
	}
	else
	{
		flags = tree[object].ob_flags;
		string = (char *)pb->pb_parm;
	}

	frame.x = pb->pb_x + border;
	frame.y = pb->pb_y + border;
	frame.w = pb->pb_w - 2 * border;
	frame.h = pb->pb_h - 2 * border;

/*	button_3d = ( (IS_ACT(flags) || IS_IND(flags)) && xd_draw_3d );
*/
	if(((pb->pb_currstate & SELECTED) == (pb->pb_prevstate & SELECTED)) /* ||
		 button_3d */)
	{
		vswr_mode(xd_vhandle, MD_REPLACE);
		set_linedef(1);

/*		if (button_3d)
		{
			if (pb->pb_currstate & SELECTED)
				act_ind_sel = TRUE;
			else if (IS_ACT(flags))
				offset = -1;

			clr_object(&frame, (IS_IND(flags) && act_ind_sel) 
								? 9 : xd_get_3d_color(flags));

			pxy[0] = frame.x;
			pxy[1] = frame.y + frame.h - 2;
			pxy[2] = frame.x;
			pxy[3] = frame.y;
			pxy[4] = frame.x + frame.w - 2;
			pxy[5] = frame.y;

			vsl_color(xd_vhandle, (act_ind_sel) ? 1 : 0);
			v_pline(xd_vhandle, 3, pxy);

			pxy[0] = frame.x + 1;
			pxy[1] = frame.y + frame.h - 1;
			pxy[2] = frame.x + frame.w - 1;
			pxy[3] = frame.y + frame.h - 1;
			pxy[4] = frame.x + frame.w - 1;
			pxy[5] = frame.y + 1;

			if (act_ind_sel && IS_IND(flags))
				vsl_color(xd_vhandle, (xd_nplanes < 4) ? 0 : 8);
			else
				vsl_color(xd_vhandle, (act_ind_sel) ? 0 : 9);
			v_pline(xd_vhandle, 3, pxy);
		}
		else
*/			clr_object(&frame, 0);

		vsl_color(xd_vhandle, 1);
		draw_frame(&frame, -1, -border);

		x = pb->pb_x + (pb->pb_w - (int) xd_strlen(string) * xd_regular_font.fnt_chw) / 2 + offset;
		y = pb->pb_y + (pb->pb_h - xd_regular_font.fnt_chh) / 2 + offset;

		vswr_mode(xd_vhandle, MD_TRANS);
		set_textdef();
/*		if (act_ind_sel && IS_IND(flags))
			vst_color(xd_vhandle, 0);
*/		prt_text(string, x, y, pb->pb_currstate);
	}
	else
		goto invert;

	if ((pb->pb_currstate & SELECTED) /* && !button_3d */)
	{
	  invert:
		vswr_mode(xd_vhandle, MD_XOR);
		set_filldef(1);
		xd_rect2pxy(&frame, pxy);
		vr_recfl(xd_vhandle, pxy);
	}

	xd_clip_off();

	return 0;
}

static int cdecl ub_rbutpar(PARMBLK *pb)
{
	int x = pb->pb_x, y = pb->pb_y, w = pb->pb_w, h = pb->pb_h;
	int d = xd_regular_font.fnt_chh / 2, pxy[12], ext[8];
	RECT clip, frame;

	clip.x = pb->pb_xc;
	clip.y = pb->pb_yc;
	clip.w = pb->pb_wc;
	clip.h = pb->pb_hc;

	frame.x = pb->pb_x;
	frame.y = pb->pb_y;
	frame.w = pb->pb_w;
	frame.h = pb->pb_h;

	xd_clip_on(&clip);

	vswr_mode(xd_vhandle, MD_REPLACE);
	set_linedef(1);
	set_textdef();

/*	if (!(IS_BG(pb->pb_tree[pb->pb_obj].ob_flags) && xd_draw_3d))
*/		clr_object(&frame, 0);

	vqt_extent(xd_vhandle, (char *) pb->pb_parm, ext);

	pxy[0] = x + xd_regular_font.fnt_chw - 2;
	pxy[1] = y + d;
	pxy[2] = x;
	pxy[3] = pxy[1];
	pxy[4] = x;
	pxy[5] = y + h - 1;
	pxy[6] = x + w - 1;
	pxy[7] = pxy[5];
	pxy[8] = pxy[6];
	pxy[9] = pxy[1];
	pxy[10] = x + xd_regular_font.fnt_chw + ext[2] - ext[0] + 1;
	pxy[11] = pxy[1];

	v_pline(xd_vhandle, 6, pxy);
/*	if (IS_BG(pb->pb_tree[pb->pb_obj].ob_flags) && xd_draw_3d)
		vswr_mode(xd_vhandle, MD_TRANS);
*/	prt_text((char *) pb->pb_parm, x + xd_regular_font.fnt_chw, y, pb->pb_currstate);

	xd_clip_off();

	return 0;
}

static int cdecl ub_title(PARMBLK *pb)
{
	int x = pb->pb_x, y = pb->pb_y, w = pb->pb_w, h = pb->pb_h;
	int pxy[4];
	RECT clip;

	clip.x = pb->pb_xc;
	clip.y = pb->pb_yc;
	clip.w = pb->pb_wc;
	clip.h = pb->pb_hc;

	xd_clip_on(&clip);

	pxy[0] = x;
	pxy[1] = y + h - 1;
	pxy[2] = x + w - 1;
	pxy[3] = pxy[1];

	vswr_mode(xd_vhandle, MD_REPLACE);
	set_linedef(1);
	v_pline(xd_vhandle, 2, pxy);

/*	if (IS_BG(pb->pb_tree[pb->pb_obj].ob_flags) && xd_draw_3d)
		vswr_mode(xd_vhandle, MD_TRANS);
*/
	set_textdef();
	vswr_mode(xd_vhandle, MD_TRANS);			/* HR 151102 */
	prt_text((char *) pb->pb_parm, x, y + (h - xd_regular_font.fnt_chh - 1) / 2,
			 pb->pb_currstate);

	xd_clip_off();

	return 0;
}

static int cdecl ub_unknown(PARMBLK *pb)
{
	int x = pb->pb_x, y = pb->pb_y, w = pb->pb_w, h = pb->pb_h;
	RECT clip;

	clip.x = pb->pb_xc;
	clip.y = pb->pb_yc;
	clip.w = pb->pb_wc;
	clip.h = pb->pb_hc;

	xd_clip_on(&clip);

	vswr_mode(xd_vhandle, MD_REPLACE);
	clr_object((RECT *) & pb->pb_x, 0);
	set_linedef(1);
	draw_rect(x, y, w, h);

	xd_clip_off();

	return 0;
}

/********************************************************************
 *																	*
 * Funkties voor het tekenen van de dialoogbox.						*
 *																	*
 ********************************************************************/

/*
 * Funktie voor het berekenen van de positie en grootte van de
 * cursor.
 */

static void xd_calc_cursor(XDINFO *info, RECT *cursor)
{
	objc_offset(info->tree, info->edit_object, &cursor->x, &cursor->y);

	cursor->x += xd_abs_curx(info->tree, info->edit_object, info->cursor_x) * xd_regular_font.fnt_chw;
	cursor->y -= 2;
	cursor->w = 1;
	cursor->h = xd_regular_font.fnt_chh + 4;
}

/*
 * Funktie voor het tekenen van de tekst cursor
 */

static void xd_credraw(XDINFO *info, RECT *area)
{
	if (cursor_mfdb.fd_addr == NULL)
	{
		cursor_mfdb.fd_h = xd_regular_font.fnt_chh + 4;
		cursor_mfdb.fd_nplanes = xd_nplanes;
		cursor_mfdb.fd_addr = xd_malloc((long) cursor_mfdb.fd_wdwidth *
										(long) cursor_mfdb.fd_h *
										(long) xd_nplanes * 2L);
	}

	if (cursor_mfdb.fd_addr != NULL)
	{
		RECT cursor, r;
		MFDB smfdb;
		int pxy[8];

		xd_calc_cursor(info, &cursor);
		smfdb.fd_addr = NULL;

		if (xd_rcintersect(area, &cursor, &r))
		{
			/* Save area below cursor. */
			
			pxy[0] = r.x;
			pxy[1] = r.y;
			pxy[2] = r.x + r.w - 1;
			pxy[3] = r.y + r.h - 1;
			pxy[4] = r.x - cursor.x;
			pxy[5] = r.y - cursor.y;
			pxy[6] = pxy[4] + r.w - 1;
			pxy[7] = pxy[5] + r.h - 1;

			vro_cpyfm(xd_vhandle, S_ONLY, pxy, &smfdb,
					  &cursor_mfdb);

			/* Draw cursor. */
			
			xd_clip_on(&r);

			vswr_mode(xd_vhandle, MD_REPLACE);
			set_linedef(1);

			pxy[0] = pxy[2] = cursor.x;
			pxy[1] = cursor.y;
			pxy[3] = cursor.y + cursor.h - 1;

			v_pline(xd_vhandle, 2, pxy);

			xd_clip_off();
		}
	}
}

/*
 * Funktie voor het wissen van de cursor.
 */

static void xd_cur_remove(XDINFO *info)
{
	if (cursor_mfdb.fd_addr != NULL)
	{
		RECT cursor, r1, r2;
		MFDB dmfdb;
		int pxy[8];

		xd_calc_cursor(info, &cursor);
		xd_mouse_off();
		dmfdb.fd_addr = NULL;

		if (info->dialmode != XD_WINDOW)
		{
			xd_clip_on(&cursor);

			pxy[0] = 0;
			pxy[1] = 0;
			pxy[2] = cursor.w - 1;
			pxy[3] = cursor.h - 1;
			pxy[4] = cursor.x;
			pxy[5] = cursor.y;
			pxy[6] = cursor.x + cursor.w - 1;
			pxy[7] = cursor.y + cursor.h - 1;

			vro_cpyfm(xd_vhandle, S_ONLY, pxy, &cursor_mfdb,
					  &dmfdb);

			xd_clip_off();
		}
		else
		{
			xw_get(info->window, WF_FIRSTXYWH, &r1);

			while ((r1.w != 0) && (r1.h != 0))
			{
				if (xd_rcintersect(&r1, &cursor, &r2))
				{
					xd_clip_on(&cursor);

					pxy[0] = r2.x - cursor.x;
					pxy[1] = r2.y - cursor.y;
					pxy[2] = pxy[0] + r2.w - 1;
					pxy[3] = pxy[1] + r2.h - 1;
					pxy[4] = r2.x;
					pxy[5] = r2.y;
					pxy[6] = r2.x + r2.w - 1;
					pxy[7] = r2.y + r2.h - 1;

					vro_cpyfm(xd_vhandle, S_ONLY, pxy, &cursor_mfdb,
							  &dmfdb);

					xd_clip_off();
				}

				xw_get(info->window, WF_NEXTXYWH, &r1);
			}
		}

		xd_mouse_on();
	}
}

/* Funktie voor het tekenen van een dialoogbox in een window */

void xd_redraw(XDINFO *info, int start, int depth, RECT *area, int flags)
{
	RECT r1, r2, cursor;
	int draw_cur;
	OBJECT *tree = info->tree;

	xd_mouse_off();

	if ((flags & XD_RCURSOR) && (info->edit_object > 0))
	{
		xd_calc_cursor(info, &cursor);
		draw_cur = xd_rcintersect(area, &cursor, &cursor);
	}
	else
		draw_cur = FALSE;

	if (info->dialmode != XD_WINDOW)
	{
		if (flags & XD_RDIALOG)
			objc_draw(tree, start, depth, area->x, area->y, area->w, area->h);
		if (draw_cur)
			xd_credraw(info, &cursor);
	}
	else
	{
		xw_get(info->window, WF_FIRSTXYWH, &r1);

		while ((r1.w != 0) && (r1.h != 0))
		{
			if ((flags & XD_RDIALOG) && xd_rcintersect(&r1, area, &r2))
				objc_draw(tree, start, depth, r2.x, r2.y, r2.w, r2.h);

			if (draw_cur && xd_rcintersect(&r1, &cursor, &r2))
				xd_credraw(info, &r2);

			xw_get(info->window, WF_NEXTXYWH, &r1);
		}
	}

	xd_mouse_on();
}

/* Funkties voor het aan en uitzetten van de cursor */

void xd_cursor_on(XDINFO *info)
{
	info->curs_cnt -= 1;

	if (info->curs_cnt == 0)
		xd_redraw(info, 0, MAX_DEPTH, &info->drect, XD_RCURSOR);
}

void xd_cursor_off(XDINFO *info)
{
	info->curs_cnt += 1;

	if (info->curs_cnt == 1)
		xd_cur_remove(info);
}

/* Funktie voor het tekenen van een dialoogbox of een deel daarvan */

void xd_draw(XDINFO *info, int start, int depth)
{
	xd_wdupdate(BEG_UPDATE);

	xd_cursor_off(info);
	xd_redraw(info, start, depth, &info->drect, XD_RDIALOG);
	xd_cursor_on(info);

	xd_wdupdate(END_UPDATE);
}

/********************************************************************
 *																	*
 * Funktie voor het veranderen van de status van een object.		*
 *																	*
 ********************************************************************/

void xd_change(XDINFO *info, int object, int newstate, int draw)
{
	OBJECT *tree = info->tree;

	int twostates = (newstate&0xff) | (tree[object].ob_state&(0xff00|WHITEBAK));	/* HR 151102: preserve extended states */

	if (info->dialmode != XD_WINDOW)
		objc_change(tree, object, 0, info->drect.x, info->drect.y, info->drect.w, info->drect.h,
					twostates, (int) draw);
	else
	{
		tree[object].ob_state = twostates;

		if (draw)
			xd_draw(info, object, 1);
	}
}

/********************************************************************
 *																	*
 * Funktie ter vervanging van rsrc_gaddr.							*
 *																	*
 ********************************************************************/

/* Funktie voor het verschuiven van de kinderen van een object. */

static void xd_translate(OBJECT *tree, int parent, int offset)
{
	int i = tree[parent].ob_head;

	while ((i >= 0) && (i != parent))
	{
		tree[i].ob_y += offset;
		i = tree[i].ob_next;
	}
}

/*
 * Function for counting user-defined objects.
 *
 * Parameters:
 *
 * tree		- Pointer to the object tree.
 * n		- Pointer to a variable in which the number of
 *			  user-defined objects is placed.
 * nx		- Pointer to a variable in which the number of
 *			  extended user-defined objects is placed.
 *
 * Result	: Total number of user-defined objects (*n + *nx).
 */

static int cnt_user(OBJECT *tree, int *n, int *nx)
{
	OBJECT *object = tree;
	int etype;

	*n = 0;
	*nx = 0;

	for (;;)
	{
		etype = (object->ob_type >> 8) & 0xFF;

		if (xd_is_xtndelement(etype) && ((object->ob_type & 0xFF) != G_USERDEF))
		{
			switch(etype)
			{
			case XD_BUTTON :
				if (GET_3D(object->ob_flags) && !IS_BG(object->ob_flags))
					(*nx)++;
				else
					(*n)++;
				break;
			case XD_SCRLEDIT:		/* HR 021202 */
				(*nx)++;
				break;
			default :
				(*n)++;
				break;
			}
		}

		if (object->ob_flags & LASTOB)
			return (*n + *nx);

		object++;
	}
}

static int must_userdef(OBJECT *ob)
{
	if (!(aes_flags & GAI_WHITEBAK))
		return TRUE;
	if (ob->ob_state & WHITEBAK)
		return FALSE;
	return TRUE;
}

/* Funktie voor het zetten van de informatie van userdefined objects. */
/* HR 151102: Dont set the progdefs if the AES supports the object types. */

void xd_set_userobjects(OBJECT *tree)
{
	extern int aes_flags;				/* HR 151102 */
	int etype, n, nx, d, object = 0;
	OBJECT *c_obj;
	USERBLK *c_ub;
	XDOBJDATA *data;
	int cdecl(*c_code) (PARMBLK *parmblock);
	int xuserblk;

	if (cnt_user(tree, &n, &nx) == 0)
		return;

	if ((data = xd_malloc(sizeof(XDOBJDATA) + sizeof(USERBLK) * (long) n +
						  sizeof(XUSERBLK) * (long) nx)) == NULL)
		return;

	data->next = xd_objdata;
	xd_objdata = data;
	c_ub = (USERBLK *) &data[1];

	for (;;)
	{
		c_code = 0L;						/* HR 151102 */
		c_obj = tree + object;
		xuserblk = FALSE;
		etype = (c_obj->ob_type >> 8) & 0xFF;

		if (xd_is_xtndelement(etype) && ((c_obj->ob_type & 0xFF) != G_USERDEF))
		{
			switch (etype)
			{
			case XD_DRAGBOX :
				c_code = ub_drag;
				break;
			case XD_ROUNDRB :
				if (must_userdef(c_obj))	/* HR 151102 */
					c_code = ub_roundrb;
				break;
			case XD_RECTBUT :
				if (must_userdef(c_obj))	/* HR 151102 */
					c_code = ub_rectbut;
				break;
			case XD_RECTBUTTRI :
				if (must_userdef(c_obj))	/* HR 151102 */
					c_code = ub_rectbuttri;
				break;
			case XD_CYCLBUT :
				c_code = ub_cyclebut;
				break;
			case XD_BUTTON :
				if (must_userdef(c_obj))	/* HR 151102 */
				{
					d = xd_bborder(tree, object);
/*
					if (GET_3D(c_obj->ob_flags) && !IS_BG(c_obj->ob_flags))
					{
						xuserblk = TRUE;
						if (xd_draw_3d)
							d += 2;
					}
*/	
					c_obj->ob_x -= d;
					c_obj->ob_y -= d;
					c_obj->ob_width += 2 * d;
					c_obj->ob_height += 2 * d;
	
					c_code = ub_button;
				}
				break;
			case XD_RBUTPAR :
				if (must_userdef(c_obj))	/* HR 151102 */
				{
					d = xd_regular_font.fnt_chh / 2;
					c_obj->ob_y -= d;
					c_obj->ob_height += d;
					xd_translate(tree, object, d);
					c_code = ub_rbutpar;
				}
				break;
			case XD_TITLE :
				if (must_userdef(c_obj))	/* HR 151102 */
				{
					c_code = ub_title;
					c_obj->ob_height += 1;
				}
				break;
			case XD_SCRLEDIT:				/* HR 021202 */
				c_code = ub_scrledit;
				xuserblk = TRUE;
				break;
			default :
				/* yet unknown userdef! */
				c_code = ub_unknown;
				break;
			}

			if (c_code)				/* HR 151102 */
			{
				if (xuserblk)
				{
					XUSERBLK *c_xub = (XUSERBLK *)c_ub;
	
					xd_xuserdef(c_obj,  c_xub, c_code);
					c_ub = (USERBLK *)(c_xub + 1);
				}
				else
				{
					xd_userdef(c_obj, c_ub, c_code);
					c_ub++;
				}
			}
		}

		if (c_obj->ob_flags & LASTOB)
			return;

		object++;
	}
}

int xd_gaddr(int type, int index, void *addr)
{
	int result;

	if (((result = rsrc_gaddr(type, index, addr)) != 0) && (type == R_TREE))
		xd_set_userobjects(*(OBJECT **) addr);

	return result;
}

char *xd_set_srcl_text(OBJECT *tree, int item, char *txt)
{
	TEDINFO *ted = xd_get_obspec(tree + item).tedinfo;
	ted->te_ptext = txt;
	*txt = 0;
	return txt;
}

void xd_fixtree(OBJECT *tree)
{
	int i = 0;

	for (;;)
	{
		rsrc_obfix(tree, i);
		if (tree[i].ob_flags & LASTOB)
			break;
		i++;
	}

	xd_set_userobjects(tree);
}
