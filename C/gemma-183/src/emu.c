/* Emulation for functions not directly supported by the host AES
 * (or not supported at all)
 */

/*  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

# include "dosproto.h"
# include "gemma.h"
# include "gemproto.h"
# include "emu.h"

# ifndef _HAVE_APPL_GETINFO

# define COOKIE_P	0x05a0L
# define COOKIE__AKP	0x5f414b50L

/* Helper: get the _AKP cookie value language configuration.
 * When not determinable, assume English.
 */

static short
getakp(void)
{
	long *cjar;

	cjar = (long *)_getexc(COOKIE_P);
	if (!cjar)
		return 0;

	while(*cjar)
	{
		if (cjar[0] == COOKIE__AKP)
			return (short)(cjar[1] & 0x000000ffL);
		cjar += 2;
	}

	return 0;
}

/* Emulation of the appl_getinfo()
 */

long emu_appl_getinfo(PROC_ARRAY *proc)
{
	short r = 0;

	switch(proc->gem.int_in[0])
	{
		case 0:		/* AES_LARGEFONT */
		{
			short rez;

			rez = _getrez() & 0x0002;
			if (rez)
				proc->gem.int_out[1] = 13;	/* font height */
			else
				proc->gem.int_out[1] = 6;
			proc->gem.int_out[2] = 1;		/* font id */
			r = 1;
			break;
		}

		case 1:		/* AES_SMALLFONT */
		{
			proc->gem.int_out[1] = 4;	/* font height */
			proc->gem.int_out[2] = 1;	/* font id */
			r = 1;
			break;
		}

		case 2:		/* AES_SYSTEM */
		{
			proc->gem.int_out[1] = _getrez() + 2;
			proc->gem.int_out[2] = 16;		/* number of colours supported by the objc library */
			if (proc->gem.global[0] >= 0x0330)
			{
				proc->gem.int_out[3] = 1;	/* color icons */
				proc->gem.int_out[4] = 1;	/* extended RSC format */
			}
			r = 1;
			break;
		}

		case 3:		/* AES_LANGUAGE */
		{
			proc->gem.int_out[1] = getakp();
			r = 1;
			break;
		}

		case 9:		/* AES_MENU */
		{
			if (proc->gem.global[0] >= 0x0330)
			{
				proc->gem.int_out[1] = 1;	/* submenus */
				proc->gem.int_out[2] = 1;	/* popup menus */
				proc->gem.int_out[3] = 1;	/* scrollable menus */
				proc->gem.int_out[4] = 1;	/* extended MN_SELECTED */
			}
			r = 1;
			break;
		}

		case 10:	/* AES_SHELWRITE */
		{
			proc->gem.int_out[1] = 1;	/* maximum legal value of `mode' */
			proc->gem.int_out[2] = 1;	/* shel_write(0) cancels previous shel_write() */
			proc->gem.int_out[3] = 1;	/* shel_write(1) takes effect after the current application exits */
			proc->gem.int_out[4] = 0;	/* ARGV parameter passing not possible */
			r = 1;
			break;
		}

		case 11:	/* AES_WINDOW */
		{
			short wf_mask = 0;

			if (proc->gem.global[0] >= 0x0330)
				wf_mask = 0x001f;	/* WF_TOP, WF_NEWDESK, WF_COLOR, WF_DCOLOR, WF_OWNER */
			if (proc->gem.global[0] >= 0x0331)
				wf_mask |= 0x0060;	/* WF_BEVENT, WF_BOTTOM */
			proc->gem.int_out[1] = wf_mask;
			r = 1;
			break;
		}

		case 12:	/* AES_MESSAGE */
		{
			short wm_mask = 0;

			if (proc->gem.global[0] >= 0x0330)
				wm_mask = 0x0006;	/* WM_UNTOPPED, WM_ONTOP */
			proc->gem.int_out[1] = wm_mask;
			r = 1;
			break;
		}

		case 13:	/* AES_OBJECT */
		{
			if (proc->gem.global[0] >= 0x0340)	/* as of Falcon030 TOS 4.04 */
			{
				proc->gem.int_out[1] = 1;	/* 3D objects */
				proc->gem.int_out[2] = 1;	/* MultiTOS style objc_sysvar() */
			}
			r = 1;
			break;
		}
	}

	proc->gem.int_out[0] = r;

	return r;
}

# endif /* _HAVE_APPL_GETINFO */

/* Emulation of the form_popup()
 */

# ifndef _HAVE_FORM_POPUP

long
emu_form_popup(PROC_ARRAY *proc)
{
	OBJECT *pop;
	MENU menu, mdata;
	short x, y, mx, my, mw, mh;

	pop = (OBJECT *)proc->gem.addr_in[0];
	x = proc->gem.int_in[0];
	y = proc->gem.int_in[1];

	menu.mn_tree = pop;
	menu.mn_menu = ROOT;
	menu.mn_item = 0;
	menu.mn_scroll = 1;

	if (!x)
		x = pop->ob_x;
	else
		x = x + (pop->ob_width >> 1);

	if (!y)
		y = pop->ob_y;
	else
		y = y + (pop->ob_height >> 1);

	_wind_get(proc, 0, WF_WORKXYWH);
	mx = proc->gem.int_out[1];
	my = proc->gem.int_out[2];
	mw = proc->gem.int_out[3];
	mh = proc->gem.int_out[4];

	if ((x - (pop->ob_width >> 1)) < mx)
		x = mx + (pop->ob_width >> 1);
	if ((y - (pop->ob_height >> 1)) < my)
		y = my + (pop->ob_height >> 1);
	if ((x + (pop->ob_width >> 1)) > (mx + mw))
		x = mx + mw - (pop->ob_width >> 1);
	if ((y + (pop->ob_height >> 1)) > (my + mh))
		y = my + mh - (pop->ob_height >> 1);

	if (_menu_popup(proc, &menu, x, y, &mdata) == 1)
		if (menu.mn_tree == mdata.mn_tree)
			return mdata.mn_item;

	return -1;
}

# endif /* _HAVE_FORM_POPUP */

/* EOF */
