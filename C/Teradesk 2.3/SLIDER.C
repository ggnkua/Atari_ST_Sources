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
#include <stddef.h>
#include <vdi.h>
#include <boolean.h>
#include <xdialog.h>
#include <xscncode.h>

#include "desk.h"
#include "events.h"
#include "slider.h"

#define min(x,y)		(((x) < (y)) ? (x) : (y))

OBJECT *dialog;

void sl_init(OBJECT *tree, SLIDER *slider)
{
	slider->set_selector(slider, FALSE, NULL);
	sl_set_slider(tree, slider, NULL);
}

void sl_set_slider(OBJECT *tree, SLIDER *sl, XDINFO *info)
{
	int sh, s;

	sl->line = ((sl->n < sl->lines) || (sl->line < 0)) ? 0 : min(sl->line, sl->n - sl->lines);

	if (sl->n > sl->lines)
	{
		sh = (int) (((long) sl->lines * (long) tree[sl->sparent].r.h) / (long) sl->n);
		if (sh < screen_info.fnt_h)
			sh = screen_info.fnt_h;
	}
	else
		sh = tree[sl->sparent].r.h;

	tree[sl->slider].r.h = sh;

	s = sl->n - sl->lines;
	tree[sl->slider].r.y = (s > 0) ? (int) (((long) (tree[sl->sparent].r.h - sh) * (long) sl->line) / (long) s) : 0;

	if (info != NULL)
		xd_draw(info, sl->sparent, MAX_DEPTH);
}

static void do_arrows(int button, OBJECT *tree, SLIDER *sl, XDINFO *info)
{
	boolean redraw, first = TRUE;
	int mstate;

	xd_change(info, button, SELECTED, 1);

	do
	{
		redraw = FALSE;

		if (button == sl->up_arrow)
		{
			if (sl->line > 0)
			{
				sl->line--;
				redraw = TRUE;
				sl_set_slider(tree, sl, info);
			}
		}
		else
		{
			if (sl->line < (sl->n - sl->lines))
			{
				sl->line++;
				redraw = TRUE;
				sl_set_slider(tree, sl, info);
			}
		}

		if (redraw == TRUE)
			sl->set_selector(sl, TRUE, info);

		mstate = xe_button_state() & 1;

		if ((first == TRUE) && mstate)
		{
			evnt_timer(250, 0);
			first = FALSE;
		}
	}
	while (mstate);

	xd_change(info, button, NORMAL, 1);
}

static void do_slider(OBJECT *tree, SLIDER *sl, XDINFO *info)
{
	int newpos;
	long lines;

	wind_update(BEG_MCTRL);
	newpos = graf_slidebox(tree, sl->sparent, sl->slider, 1);
	wind_update(END_MCTRL);

	lines = (long) (sl->n - sl->lines);
	sl->line = (int) (((long) newpos * lines + 500L) / 1000L);
	sl_set_slider(tree, sl, info);
}

static void do_bar(OBJECT *tree, SLIDER *sl, XDINFO *info)
{
	int my, oy, dummy, old, max;

	graf_mkstate(&dummy, &my, &dummy, &dummy);
	objc_offset(tree, sl->slider, &dummy, &oy);

	do
	{
		old = sl->line;

		if (my < oy)
		{
			sl->line -= sl->lines;
			if (sl->line < 0)
				sl->line = 0;
		}
		else
		{
			sl->line += sl->lines;
			max = sl->n - sl->lines;
			if (sl->line > max)
				sl->line = max;
		}

		if (sl->line != old)
		{
			sl_set_slider(tree, sl, info);
			sl->set_selector(sl, TRUE, info);
		}
	}
	while (xe_button_state() & 0x1);
}

static int keyfunc(XDINFO *info, SLIDER *sl, int scancode)
{
	boolean redraw = FALSE;
	int selected;

	switch (scancode)
	{
	case CTL_CURUP:
		if ((sl->type != 0) && ((selected = sl->findsel()) != 0))
		{
			selected += sl->first;
			dialog[selected].ob_state &= ~SELECTED;
			dialog[selected - 1].ob_state |= SELECTED;
			redraw = TRUE;
		}
		else if (sl->line > 0)
		{
			sl->line--;
			sl_set_slider(dialog, sl, info);
			redraw = TRUE;
		}
		break;
	case CTL_CURDOWN:
		if ((sl->type != 0) && ((selected = sl->findsel()) != (sl->lines - 1)))
		{
			selected += sl->first;
			dialog[selected].ob_state &= ~SELECTED;
			dialog[selected + 1].ob_state |= SELECTED;
			redraw = TRUE;
		}
		else if (sl->line < (sl->n - sl->lines))
		{
			sl->line++;
			sl_set_slider(dialog, sl, info);
			redraw = TRUE;
		}
		break;
	default:
		return 0;
	}

	if (redraw == TRUE)
		sl->set_selector(sl, TRUE, info);

	return 1;
}

int sl_handle_button(int button, OBJECT *tree, SLIDER *sl, XDINFO *dialog)
{
	int button2 = button & 0x7FFF;

	if ((button2 == sl->up_arrow) || (button2 == sl->down_arrow))
		do_arrows(button2, tree, sl, dialog);
	else if (button2 == sl->slider)
	{
		do_slider(tree, sl, dialog);
		(*sl->set_selector) (sl, TRUE, dialog);
	}
	else if (button2 == sl->sparent)
		do_bar(tree, sl, dialog);
	else
		return FALSE;

	return TRUE;
}

int sl_form_do(OBJECT *tree, int start, SLIDER *sl, XDINFO *info)
{
	int button;

	dialog = tree;

	do
	{
		button = xd_kform_do(info, start, (userkeys) keyfunc, sl);
	}
	while (sl_handle_button(button, tree, sl, info));

	return button;
}

int sl_dialog(OBJECT *tree, int start, SLIDER *slider)
{
	XDINFO info;
	int button;

	sl_init(tree, slider);

	xd_open(tree, &info);
	button = sl_form_do(tree, start, slider, &info) & 0x7FFF;
	xd_change(&info, button, NORMAL, 0);
	xd_close(&info);

	return button;
}
