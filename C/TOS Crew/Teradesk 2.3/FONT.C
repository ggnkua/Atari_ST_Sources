/*
 * Teradesk. Copyright (c) 1993, 1994, 2002 W. Klaren.
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

#include <np_aes.h>			/* HR 151102: modern */
#include <vdi.h>
#include <stdlib.h>
#include <string.h>
#include <mint.h>
#include <xdialog.h>

#include "desk.h"
#include "resource.h"
#include "xfilesys.h"
#include "screen.h"
#include "slider.h"
#include "error.h"
#include "font.h"
#include "va.h"		/* HR 060203 */

#define NLINES	6

typedef struct
{
	int id;
	char name[17];
	int flag;
} FONTDATA;

static FONTDATA *fd;
static int nf,						/* Number of fonts. */
		   font,
		   fsize,
		   chw,
		   chh;

int fnt_point(int height, int *cw, int *ch)
{
	int dummy, r;

	r = vst_point(vdi_handle, height, &dummy, &dummy, &dummy, ch);
	vqt_width(vdi_handle, ' ', cw, &dummy, &dummy);

	return r;
}

void fnt_setfont(int font, int height, FONT *data)
{
	data->id = vst_font(vdi_handle, font);
	data->size = fnt_point(height, &data->cw, &data->ch);
}

static int cdecl draw_text(PARMBLK *pb)
{
	int x, y, extent[8];
	RECT r;

	xd_clip_on(&pb->c);

	set_txt_default(fd[font].id, fsize);
	fnt_point(fsize, &chw, &chh);

	clear(&pb->r);

	xd_rcintersect(&pb->r, &pb->c, &r);

	xd_clip_on(&r);

	vqt_extent(vdi_handle, (char *) pb->pb_parm, extent);

	x = pb->r.x + (pb->r.w - extent[2] + extent[0] - 1) / 2;
	y = pb->r.y + (pb->r.h - extent[7] + extent[1] - 1) / 2;

	v_gtext(vdi_handle, x, y, (char *) pb->pb_parm);

	xd_clip_off();

	return 0;
}

static int find_selected(void)
{
	int object;

	return ((object = xd_get_rbutton(wdfont, WDPARENT)) < 0) ? 0 : object - WDFONT1;
}

static void set_selector(SLIDER *slider, boolean draw, XDINFO *info)
{
	int i;
	OBJECT *o;

	for (i = 0; i < NLINES; i++)
	{
		o = &wdfont[WDFONT1 + i];

		if (i + slider->line >= nf)
		{
			o->ob_spec.tedinfo->te_ptext = "                ";
			o->ob_state &= ~SELECTED;
		}
		else
		{
			if (i + slider->line == font)
				o->ob_state |= SELECTED;
			else
				o->ob_state &= ~SELECTED;			/* HR 151102 */
			o->ob_spec.tedinfo->te_ptext = fd[i + slider->line].name;
		}
	}

	if (draw == TRUE)
		xd_draw(info, WDPARENT, MAX_DEPTH);
}

static int set_font(SLIDER *sl_info, int oldfont, int *font, FONTDATA *fd, int nf)
{
	int i = 0, line;

	while ((fd[i].id != oldfont) && (i < (nf - 1)))
		i++;

	*font = line = (fd[i].id == oldfont) ? i : 0;

	if (line > (nf - sl_info->lines))
	{
		if ((line = nf - sl_info->lines) < 0)
			line = 0;
	}

	return line;
}

static int get_size(int font, FONTDATA *fd, int *fsizes, int *nfsizes, int fsize)
{
	int n = 1, height = 99, dummy, i, error, tmp, min = 0;

	vst_font(vdi_handle, fd[font].id);

	height = fsizes[0] = vst_point(vdi_handle, height, &dummy, &dummy, &dummy, &dummy);

	while (fsizes[n - 1] != (height = vst_point(vdi_handle, height - 1, &dummy, &dummy, &dummy, &dummy)))
		fsizes[n++] = height;

	error = abs(fsizes[0] - fsize);

	for (i = 1; i < n; i++)
	{
		if ((tmp = abs(fsizes[i] - fsize)) < error)
		{
			error = tmp;
			min = i;
		}
	}

	itoa(fsizes[min], wdfont[WDFSIZE].ob_spec.free_string, 10);

	*nfsizes = n;

	return min;
}

boolean fnt_dialog(int title, FONT *wd_font, boolean prop)
{
	char name[34];
	int button, i, newfont, curobj, cursize, fsizes[100], nfsizes;
	XDINFO info;
	SLIDER sl_info;
	boolean stop = FALSE, ok = FALSE;
	OBJECT *o = &wdfont[WDFTEXT];
	static USERBLK userblock;

	if ((fd = malloc((nfonts + 1) * sizeof(FONTDATA))) == NULL)
	{
		xform_error(ENSMEM);
		return FALSE;
	}

	if (o->ob_type != G_USERDEF)
		xd_userdef(o, &userblock, draw_text);

	rsc_title(wdfont, WDFTITLE, title);

	nf = 0;

	for (i = 0; i <= nfonts; i++)
	{
		FONTDATA *h = &fd[nf];
		int j, iw, mw, dummy;
		char *s = h->name;
		FONT fnt;

		h->id = vqt_name(vdi_handle, i + 1, name);
		fnt_setfont(h->id, 10, &fnt);

		vqt_width(vdi_handle, 'i', &iw, &dummy, &dummy);
		vqt_width(vdi_handle, 'm', &mw, &dummy, &dummy);

		if ((prop != FALSE) || (iw == mw))
		{
			strsncpy(s, name, sizeof(h->name));			/* HR 120203: secure cpy */
			j = (int) strlen(h->name);
			while (j < 16)
				s[j++] = ' ';
			h->flag = (int) name[32];
			nf++;
		}
	}

	sl_info.type = 0;
	sl_info.up_arrow = WDFUP;
	sl_info.down_arrow = WDFDOWN;
	sl_info.slider = FSLIDER;
	sl_info.sparent = FSPARENT;
	sl_info.lines = NLINES;
	sl_info.n = nf;
	sl_info.line = set_font(&sl_info, wd_font->id, &font, fd, nf);
	sl_info.set_selector = set_selector;
	sl_info.first = WDFONT1;
	sl_info.findsel = find_selected;

	fsize = fsizes[cursize = get_size(font, fd, fsizes, &nfsizes, wd_font->size)];

	sl_init(wdfont, &sl_info);

	xd_open(wdfont, &info);

	while (stop == FALSE)
	{
		button = sl_form_do(wdfont, 0, &sl_info, &info) & 0x7FFF;

		switch (button)
		{
		case WDFONT1:
		case WDFONT2:
		case WDFONT3:
		case WDFONT4:
		case WDFONT5:
		case WDFONT6:
			curobj = font - sl_info.line + WDFONT1;
			if (((newfont = sl_info.line + button - WDFONT1) < nf) && (curobj != button))
			{
				if ((curobj >= WDFONT1) && (curobj <= WDFONT6))
					xd_change(&info, curobj, NORMAL, 1);
				xd_change(&info, button, SELECTED, 1);
				font = newfont;
				fsize = fsizes[cursize = get_size(font, fd, fsizes, &nfsizes, fsize)];
				xd_draw(&info, WDFTEXT, 1);
				xd_draw(&info, WDFSIZE, 1);
			}
			break;
		case WDFSUP:
			if (cursize < nfsizes - 1)
			{
				cursize++;
				goto cont;
			}
			xd_change(&info, button, NORMAL, 1);
			break;
		case WDFSDOWN:
			if (cursize > 0)
			{
				cursize--;
			  cont:fsize = fsizes[cursize];
				itoa(fsize, wdfont[WDFSIZE].ob_spec.free_string, 10);
				xd_draw(&info, WDFTEXT, 1);
				xd_draw(&info, WDFSIZE, 1);
			}
			xd_change(&info, button, NORMAL, 1);
			break;
		case WDFOK:
			if ((fd[font].id != wd_font->id) || (fsize != wd_font->size))
			{
				wd_font->id = fd[font].id;
				wd_font->size = fsize;
				wd_font->cw = chw;
				wd_font->ch = chh;
				ok = TRUE;
			}
		default:
			stop = TRUE;
			break;
		}
	}

	xd_change(&info, button, NORMAL, 0);
	xd_close(&info);

	free(fd);

	return ok;
}

#if 1

/*
 * Support for system wide font selector.
 */

typedef struct
{
	SLIDER slider;
	struct fnt_dialog *fnt_dial;
} FNT_SLIDER;

typedef struct
{
	USERBLK userblock;
	struct fnt_dialog *fnt_dial;
	char *text;
} FNT_USERBLK;

typedef struct fnt_dialog
{
	XDINFO dialog;
	FNT_SLIDER sl_info;
	FNT_USERBLK userblock;

	int ap_id;					/* Application id of caller. */
	int win;					/* Window id of caller. */
	int color;					/* Color of font. */
	int effect;					/* Text effects of font. */

	FONTDATA *fd;				/* Font information. */
	int nf;						/* Number of fonts. */
	int font;					/* Current font. */
	int fsize;					/* Current size of the font. */
	int chw;					/* Width of a character. */
	int chh;					/* Height of a character. */

	int cursize;				/* Index of current size in array 'fsize'. */
	int fsizes[100];			/* Array with sizes of the current font. */
	int nfsizes;				/* Number of sizes in 'fsizes'. */
} FNT_DIALOG;

static int cdecl mdraw_text(PARMBLK *pb)
{
	int x, y, extent[8];
	RECT r;
	FNT_DIALOG *fnt_dial = ((FNT_USERBLK *) pb->pb_parm)->fnt_dial;
	char *text = ((FNT_USERBLK *) pb->pb_parm)->text;

	xd_clip_on(&pb->c);

	set_txt_default(fnt_dial->fd[fnt_dial->font].id, fnt_dial->fsize);
	fnt_point(fnt_dial->fsize, &fnt_dial->chw, &fnt_dial->chh);

	clear(&pb->r);

	xd_rcintersect(&pb->r, &pb->c, &r);

	xd_clip_on(&r);

	vqt_extent(vdi_handle, text, extent);

	x = pb->r.x + (pb->r.w - extent[2] + extent[0] - 1) / 2;
	y = pb->r.y + (pb->r.h - extent[7] + extent[1] - 1) / 2;

	v_gtext(vdi_handle, x, y, text);

	xd_clip_off();

	return 0;
}

static int mfind_selected(void)
{
	int object;

	return ((object = xd_get_rbutton(wdfont, WDPARENT)) < 0) ? 0 : object - WDFONT1;
}

static void mset_selector(SLIDER *slider, boolean draw, XDINFO *info)
{
	int i;
	OBJECT *o;
	FNT_DIALOG *fnt_dial = ((FNT_SLIDER *) slider)->fnt_dial;

	for (i = 0; i < NLINES; i++)
	{
		o = &wdfont[WDFONT1 + i];

		if (i + slider->line >= slider->n)
		{
			o->ob_spec.tedinfo->te_ptext = "                ";
			o->ob_state &= ~SELECTED;
		}
		else
		{
			if (i + slider->line == fnt_dial->font)
				o->ob_state |= SELECTED;
			else
				o->ob_state &= ~SELECTED;
			
			o->ob_spec.tedinfo->te_ptext = fnt_dial->fd[i + slider->line].name;
		}
	}

	if (draw == TRUE)
		xd_draw(info, WDPARENT, MAX_DEPTH);
}

/*
 * void fnt_close(XDINFO *dialog)
 *
 * Event handler for the close button of the dialog box.
 */

void fnt_close(XDINFO *dialog)
{
	FNT_DIALOG *fnt_dial = (FNT_DIALOG *) dialog;

	xd_nmclose(dialog, NULL, FALSE);

	free(fnt_dial->fd);
	free(fnt_dial);
}

void fnt_hndlbutton(XDINFO *dialog, int button)
{
	FNT_DIALOG *fnt_dial = (FNT_DIALOG *) dialog;
	int msg[8], curobj, newfont;

	button &= 0x7FFF;

	if (sl_handle_button(button, wdfont, &fnt_dial->sl_info.slider, dialog))
		return;

	switch (button)
	{
	case WDFONT1:
	case WDFONT2:
	case WDFONT3:
	case WDFONT4:
	case WDFONT5:
	case WDFONT6:
		curobj = fnt_dial->font - fnt_dial->sl_info.slider.line + WDFONT1;
		if (((newfont = fnt_dial->sl_info.slider.line + button - WDFONT1) < fnt_dial->nf) && (curobj != button))
		{
			if ((curobj >= WDFONT1) && (curobj <= WDFONT6))
				xd_change(dialog, curobj, NORMAL, 1);
			xd_change(dialog, button, SELECTED, 1);
			fnt_dial->font = newfont;
			fnt_dial->cursize = get_size(fnt_dial->font, fnt_dial->fd,
										 fnt_dial->fsizes, &fnt_dial->nfsizes,
										 fnt_dial->fsize);
			fnt_dial->fsize = fnt_dial->fsizes[fnt_dial->cursize];
			xd_draw(dialog, WDFTEXT, 1);
			xd_draw(dialog, WDFSIZE, 1);
		}
		break;
	case WDFSUP:
		if (fnt_dial->cursize < fnt_dial->nfsizes - 1)
		{
			fnt_dial->cursize++;
			goto cont;
		}
		xd_change(dialog, button, NORMAL, 1);
		break;
	case WDFSDOWN:
		if (fnt_dial->cursize > 0)
		{
			fnt_dial->cursize--;
		  cont:fnt_dial->fsize = fnt_dial->fsizes[fnt_dial->cursize];
			itoa(fnt_dial->fsize, wdfont[WDFSIZE].ob_spec.free_string, 10);
			xd_draw(dialog, WDFTEXT, 1);
			xd_draw(dialog, WDFSIZE, 1);
		}
		xd_change(dialog, button, NORMAL, 1);
		break;
	case WDFOK:
		msg[0] = FONT_CHANGED;
		msg[1] = fnt_dial->ap_id;
		msg[2] = 0;
		msg[3] = fnt_dial->win;
		msg[4] = fnt_dial->fd[fnt_dial->font].id;
		msg[5] = fnt_dial->fsize;
		msg[6] = fnt_dial->color;
		msg[7] = fnt_dial->effect;

		appl_write(fnt_dial->ap_id, 16, msg);
	default:
		xd_change(dialog, button, NORMAL, 0);
		fnt_close(dialog);
		break;
	}
}

XD_NMFUNC fnt_funcs =
{
	fnt_hndlbutton,
	fnt_close,
	0L,
	0L
};

void fnt_mdialog(int ap_id, int win, int id, int size, int color,
				 int effect, int prop)
{
	FNT_DIALOG *fnt_dial;
	char name[34];
	int i;
	OBJECT *o = &wdfont[WDFTEXT];

	if ((fnt_dial = malloc(sizeof(FNT_DIALOG))) == NULL)
	{
		xform_error(ENSMEM);
		return;
	}

	if ((fnt_dial->fd = malloc((nfonts + 1) * sizeof(FONTDATA))) == NULL)
	{
		free(fnt_dial);
		xform_error(ENSMEM);
		return;
	}

	fnt_dial->userblock.fnt_dial = fnt_dial;
	fnt_dial->userblock.text = (char *) o->ob_spec.index;

	fnt_dial->userblock.userblock.ub_code = mdraw_text;
	fnt_dial->userblock.userblock.ub_parm = (long) &fnt_dial->userblock;

	o->ob_type = (o->ob_type & 0xFF00) | G_USERDEF;
	o->ob_spec.userblk = &fnt_dial->userblock.userblock;

	rsc_title(wdfont, WDFTITLE, DTVFONT);

	fnt_dial->ap_id = ap_id;	/* Application id of caller. */
	fnt_dial->win = win;		/* Window id of caller. */
	fnt_dial->color = color;	/* Color of font. */
	fnt_dial->effect = effect;	/* Text effects of font. */

	fnt_dial->nf = 0;

	for (i = 0; i <= nfonts; i++)
	{
		FONTDATA *h = &fnt_dial->fd[fnt_dial->nf];
		int j, iw, mw, dummy;
		char *s = h->name;
		FONT fnt;

		h->id = vqt_name(vdi_handle, i + 1, name);
		fnt_setfont(h->id, 10, &fnt);

		vqt_width(vdi_handle, 'i', &iw, &dummy, &dummy);
		vqt_width(vdi_handle, 'm', &mw, &dummy, &dummy);

		if ((prop != FALSE) || (iw == mw))
		{
			strsncpy(s, name, sizeof(h->name));			/* HR 120203: secure cpy */
			j = (int) strlen(h->name);
			while (j < 16)
				s[j++] = ' ';
			h->flag = (int) name[32];
			fnt_dial->nf++;
		}
	}

	fnt_dial->sl_info.slider.type = 0;
	fnt_dial->sl_info.slider.up_arrow = WDFUP;
	fnt_dial->sl_info.slider.down_arrow = WDFDOWN;
	fnt_dial->sl_info.slider.slider = FSLIDER;
	fnt_dial->sl_info.slider.sparent = FSPARENT;
	fnt_dial->sl_info.slider.lines = NLINES;
	fnt_dial->sl_info.slider.n = fnt_dial->nf;
	fnt_dial->sl_info.slider.line = set_font(&fnt_dial->sl_info.slider,
											 id, &fnt_dial->font,
											 fnt_dial->fd, fnt_dial->nf);
	fnt_dial->sl_info.slider.set_selector = mset_selector;
	fnt_dial->sl_info.slider.first = WDFONT1;
	fnt_dial->sl_info.slider.findsel = mfind_selected;

	fnt_dial->sl_info.fnt_dial = fnt_dial;

	fnt_dial->cursize = get_size(fnt_dial->font, fnt_dial->fd,
								 fnt_dial->fsizes, &fnt_dial->nfsizes,
								 size);
	fnt_dial->fsize = fnt_dial->fsizes[fnt_dial->cursize];

	sl_init(wdfont, &fnt_dial->sl_info.slider);

	xd_nmopen(wdfont, &fnt_dial->dialog, &fnt_funcs, 0, -1, -1,
			  NULL, NULL, FALSE, "Font selector");
}
#endif
