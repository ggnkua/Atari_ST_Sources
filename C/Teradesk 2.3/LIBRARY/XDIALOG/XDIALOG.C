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

#include <np_aes.h>

#ifdef __PUREC__
 #include <tos.h>
 #include <vdi.h>
 #include <multitos.h>
#else
 #include <aesbind.h>
 #include <osbind.h>
 #include <vdibind.h>
 #include "applgeti.h"
#endif

#include <ctype.h>
#include <stddef.h>
#include <string.h>

#include "xscncode.h"
#include "xdialog.h"

#include "internal.h"

int aes_flags    = 0,				/* HR 151102: proper appl_info protocol (works with ALL Tos */
	MagX_version = 0,
	colour_icons = 0,
	aes_hor3d    = 0,
	aes_ver3d    = 0,				/* HR 120203: 3d enlargement values */
	xresources   = 0;

#define XD_WDFLAGS	(NAME | MOVER)

int xd_dialmode = XD_NORMAL,	/* Dialog mode */
	xd_posmode = XD_CENTERED,	/* Position mode */
	xd_vhandle,					/* Vdi handle for library functions */
	xd_nplanes,					/* Number of planes the current resolution */
	xd_ncolors,					/* Number of colors in the current resolution */
	xd_min_timer;				/* Minimum time passed to xe_multi(). */

void *(*xd_malloc) (size_t size);
void (*xd_free) (void *block);
static int (*xd_usermessage) (int *message) = 0L;	/*
                                   function which is called during a 
                                   form_do, if the message is not for
                                   the dialog window */
const char *xd_prgname;			/* Name of program, used in title bar of windows */
OBJECT *xd_menu = NULL;			/* Pointer to menu tree of the program */
static int xd_nmnitems = 0,		/* Number of menu titles that have to be disabled */
		   *xd_mnitems = 0,		/* Array with indices to menu titles in xd_menu,
                                   which have to be disabled. The first index is
                                   not a title, but the index of the info item. */
		   xd_upd_ucnt = 0,		/* Counter for wind_update */
		   xd_upd_mcnt = 0,		/* Counter for wind_update */
		   xd_msoff_cnt = 0;	/* Counter for xd_mouse_on/xd_mouse_off */
int xd_multitos = FALSE,		/* MultiTOS flag, always FALSE */
	xd_aes4_0,					/* AES 4.0 flag */
	
/*	xd_draw_3d,					/* Draw objects in 3D if 3D flag of object is set. */
*/	xd_fdo_flag = FALSE;		/* Flag voor form_do */
XDOBJDATA *xd_objdata = NULL;	/* Arrays with USERBLKs */
XDINFO *xd_dialogs = NULL;		/* Chained list of modal dialog boxes. */
XDINFO *xd_nmdialogs;			/* List with non modal dialog boxes. */
RECT xd_desk;					/* Dimensions of desktop background. */
XD_FONT xd_regular_font, xd_small_font;

void __xd_redraw(WINDOW *w, RECT *area);
void __xd_moved(WINDOW *w, RECT *newpos);

static WD_FUNC xd_wdfuncs =
{
	0L,
	0L,
	__xd_redraw,
	0L,
	0L,
	0L,
	0L,
	0L,
	0L,
	0L,
	0L,
	__xd_moved,
	0L,
	0L
};

/********************************************************************
 *																	*
 * Hulpfunkties.													*
 *																	*
 ********************************************************************/

/* Funktie voor het opslaan van het scherm onder de dialoogbox. */

static void xd_save(XDINFO *info)
{
	MFDB source;
	int pxy[8];

	source.fd_addr = NULL;

	xd_rect2pxy(&info->drect, pxy);

	pxy[4] = 0;
	pxy[5] = 0;
	pxy[6] = info->drect.w - 1;
	pxy[7] = info->drect.h - 1;

	xd_mouse_off();
	vro_cpyfm(xd_vhandle, S_ONLY, pxy, &source, &info->mfdb);
	xd_mouse_on();
}

/* Funktie voor het opnieuw tekenen van het scherm. */

static void xd_restore(XDINFO *info)
{
	MFDB dest;
	int pxy[8];

	dest.fd_addr = NULL;

	pxy[0] = 0;
	pxy[1] = 0;
	pxy[2] = info->drect.w - 1;
	pxy[3] = info->drect.h - 1;

	xd_rect2pxy(&info->drect, &pxy[4]);

	xd_mouse_off();
	vro_cpyfm(xd_vhandle, S_ONLY, pxy, &info->mfdb, &dest);
	xd_mouse_on();
}

static void xd_disable_menu(void)
{
	if (xd_menu != NULL)
	{
		int i;

		for (i = 0; i < xd_nmnitems; i++)
			xd_menu[xd_mnitems[i]].ob_state = (i == 1) ? NORMAL : DISABLED;

		menu_bar(xd_menu, 1);
	}
}

static void xd_enable_menu(void)
{
	if (xd_menu != NULL)
	{
		int i;

		for (i = 0; i < xd_nmnitems; i++)
			xd_menu[xd_mnitems[i]].ob_state = NORMAL;

		menu_bar(xd_menu, 1);
	}
}

/* Funktie die ervoor zorgt dat een dialoogbox binnen het scherm
   valt. */

static void xd_clip(XDINFO *info, RECT *clip)
{
	if (info->drect.x < clip->x)
		info->drect.x = clip->x;
	if (info->drect.y < clip->y)
		info->drect.y = clip->y;
	if ((info->drect.x + info->drect.w) > (clip->x + clip->w))
		info->drect.x = clip->x + clip->w - info->drect.w;
	if ((info->drect.y + info->drect.h) > (clip->y + clip->h))
		info->drect.y = clip->y + clip->h - info->drect.h;
}

/* Funktie voor het verplaatsen van een dialoog naar een nieuwe
   positie */

static void xd_set_position(XDINFO *info, int x, int y)
{
	int dx, dy;
	OBJECT *tree = info->tree;

	dx = x - info->drect.x;
	dy = y - info->drect.y;

	tree->ob_x += dx;
	tree->ob_y += dy;

	info->drect.x = x;
	info->drect.y = y;
}

/* Funktie voor het berekenen van de rand om een dialoogbox. */

static void xd_border(OBJECT *tree, int *xl, int *xr, int *yu, int *yl)
{
	int old_x, old_y, x, y, w, h;

	old_x = tree->ob_x;
	old_y = tree->ob_y;

	form_center(tree, &x, &y, &w, &h);

	*xl = tree->ob_x - x;
	*xr = w - tree->ob_width - *xl;
	*yu = tree->ob_y - y;
	*yl = h - tree->ob_height - *yu;

	tree->ob_x = old_x;
	tree->ob_y = old_y;
}

/* Funktie voor het berekenen van de positie van de dialoog op het
   scherm. */

void xd_calcpos(XDINFO *info, XDINFO *prev, int pmode)
{
	int dummy, xl, xr, yu, yl;
	OBJECT *tree = info->tree;

	if ((pmode == XD_CENTERED) && (prev == NULL))
		form_center(tree, &info->drect.x, &info->drect.y, &info->drect.w, &info->drect.h);
	else
	{
		xd_border(tree, &xl, &xr, &yu, &yl);

		info->drect.w = tree->ob_width + xl + xr;
		info->drect.h = tree->ob_height + yu + yl;

		switch (pmode)
		{
		case XD_CENTERED:
			info->drect.x = prev->drect.x + (prev->drect.w - info->drect.w) / 2;
			info->drect.y = prev->drect.y + (prev->drect.h - info->drect.h) / 2;
			break;
		case XD_MOUSE:
			graf_mkstate(&info->drect.x, &info->drect.y, &dummy, &dummy);
			info->drect.x -= info->drect.w / 2;
			info->drect.y -= info->drect.h / 2;
			break;
		case XD_CURRPOS:
			info->drect.x = tree->ob_x - xl;
			info->drect.y = tree->ob_y - yu;
			break;
		}

		xd_clip(info, &xd_desk);

		tree->ob_x = info->drect.x + xl;
		tree->ob_y = info->drect.y + yu;
	}
}

static void xd_rbutton(XDINFO *info, int parent, int object)
{
	int i, prvstate, newstate;
	OBJECT *tree = info->tree;

	i = tree[parent].ob_head;

	if (info->dialmode == XD_WINDOW)
		xd_cursor_off(info);

	do
	{
		if (tree[i].ob_flags & RBUTTON)
		{
			prvstate = tree[i].ob_state;
			newstate = (i == object) ? tree[i].ob_state | SELECTED : tree[i].ob_state & ~SELECTED;
			if (newstate != prvstate)
				xd_change(info, i, newstate, TRUE);
		}
		i = tree[i].ob_next;
	}
	while (i != parent);

	if (info->dialmode == XD_WINDOW)
		xd_cursor_on(info);

}

/********************************************************************
 *																	*
 * Funktie ter vervanging van wind_update.							*
 *																	*
 ********************************************************************/

int xd_wdupdate(int mode)
{
	switch (mode)
	{
	case BEG_UPDATE:
		if (++xd_upd_ucnt != 1)
			return 1;
		break;
	case END_UPDATE:
		if (--xd_upd_ucnt != 0)
			return 1;
		break;
	case BEG_MCTRL:
		if (++xd_upd_mcnt != 1)
			return 1;
		break;
	case END_MCTRL:
		if (--xd_upd_mcnt != 0)
			return 1;
		break;
	}

	return wind_update(mode);
}


/********************************************************************
 *																	*
 * Hide the mouse pointer.											*
 *																	*
 ********************************************************************/

void xd_mouse_off(void)
{
	if (xd_msoff_cnt == 0)
		graf_mouse(M_OFF, NULL);
	xd_msoff_cnt++;
}

/********************************************************************
 *																	*
 * Show the mouse pointer.											*
 *																	*
 ********************************************************************/

void xd_mouse_on(void)
{
	if (xd_msoff_cnt == 1)
		graf_mouse(M_ON, NULL);
	xd_msoff_cnt--;
}

/********************************************************************
 *																	*
 * Funkties voor het afhandelen van toetsen in dialoogboxen.		*
 *																	*
 ********************************************************************/

/* Funktie voor het zetten van de informatie over de toetsen */

int xd_set_keys(OBJECT *tree, KINFO *kinfo)
{
	int i = 0, cur = 0;

	for (;;)
	{	
		char *h = NULL;				/* HR 151102 */
		OBJECT *c_obj = &tree[cur];

		int etype = (c_obj->ob_type >> 8) & 0xFF;
		int state = c_obj->ob_state;

	/* HR 151102: use AES 4 extended object state if there. */

		if (   xd_is_xtndbutton(etype)
		    || (c_obj->ob_type&0xff) == G_BUTTON
		   )
		{
			if (state & WHITEBAK)
			{
				char *p = xd_get_obspec(c_obj).free_string;
				int und = (state<<1)>>9;
				if (und >= 0)
				{
					und &= 0x7f;
					if (und < strlen(p))
						h = p + und;
				}
			}
			else if ( xd_is_xtndbutton(etype))
			{
				/* I_A: changed to let '#' through if doubled! */
	
				/* find single '#' */
				for (h = xd_get_obspec(c_obj).free_string;
					 (h = strchr(h, '#')) != 0 && (h[1] == '#');		/* HR 151102 != 0 */
					 h += 2)
					;
	
				if (h) h++;					/* HR 151102: pinpoint exactly */
			}
		}

		if (h)		/* HR 151102: one of the above options. */
		{
			int ch = toupper((int) *h);			/* HR 151102: pinpointed exactly */

			if (((ch >= 'A') && (ch <= 'Z')) || ((ch >= '0') && (ch <= '9')))
				kinfo[i].key = XD_ALT | ch;
			else
				kinfo[i].key = 0;

			kinfo[i].object = cur;
			i++;
		}

		if (xd_is_xtndspecialkey(etype))
		{
			kinfo[i].key = ckeytab[etype - XD_UP];
			kinfo[i].object = cur;
			i++;
		}

		if ((c_obj->ob_flags & LASTOB) || (i == MAXKEYS))
			return i;

		cur++;
	}
}

/* Funktie die controleert of een toets selecteerbaar is. */

static int xd_selectable(OBJECT *tree, int object)
{
	int parent;
	OBJECT *o = &tree[object];

	if ((o->ob_flags & HIDETREE) || (o->ob_state & DISABLED))
		return FALSE;

	parent = xd_obj_parent(tree, object);

	while (parent > 0)
	{
		o = tree + parent;

		if ((o->ob_flags & HIDETREE) || (o->ob_state & DISABLED))
			return FALSE;

		parent = xd_obj_parent(tree, parent);
	}

	return TRUE;
}

/* Zoek de button die bij een toets hoort. */

int xd_find_key(OBJECT *tree, KINFO *kinfo, int nk, int key)
{
	int i;

	for (i = 0; i < nk; i++)
	{
		if ((kinfo[i].key == key) && xd_selectable(tree, kinfo[i].object))
			return kinfo[i].object;
	}

	return -1;
}

/********************************************************************
 *																	*
 * Funkties voor het afhandelen van messages.						*
 *																	*
 ********************************************************************/

/*
 * Funktie, die de bij de windowhandle behorende dialoog, opzoekt.
 *
 * Parameters:
 *
 * w	- window waarvan de bijbehorende XD_INFO structuur opgezocht
 *		  moet worden.
 * flag	- als bit 0 gezet is zoek modale dialoogboxen, zoek niet
 *		  modale dialoogboxen als bit 1 gezet is.
 */

XDINFO *xd_find_dialog(WINDOW *w, int flag)
{
	XDINFO *info = NULL;

	if (flag & 1)
	{
		info = xd_dialogs;

		while ((info != NULL) && (info->window != w))
			info = info->prev;
	}

	if ((flag & 2) && (info == NULL))
	{
		info = xd_nmdialogs;

		while ((info != NULL) && (info->window != w))
			info = info->prev;
	}

	return info;
}

/*
 * Funktie voor het afhandelen van een redraw event.
 */

void __xd_redraw(WINDOW *w, RECT *area)
{
	XDINFO *info = xd_find_dialog(w, 3);

	xd_wdupdate(BEG_UPDATE);
	xd_redraw(info, ROOT, MAX_DEPTH, area, XD_RDIALOG | XD_RCURSOR);
	xd_wdupdate(END_UPDATE);
}

/*
 * Funktie voor het afhandelen van een window moved event.
 */

void __xd_moved(WINDOW *w, RECT *newpos)
{
	XDINFO *info = xd_find_dialog(w, 3);
	RECT work;

	xw_set(w, WF_CURRXYWH, newpos);
	xw_get(w, WF_WORKXYWH, &work);
	xd_set_position(info, work.x, work.y);
}

/********************************************************************
 *																	*
 * Funkties ter vervanging van objc_edit.							*
 *																	*
 ********************************************************************/

/* Funktie die de positie van de cursor in de template string bepaalt
   uit de positie van de cursor in de text string. */

int xd_abs_curx(OBJECT *tree, int object, int curx)
{
	XUSERBLK *blk = xd_get_scrled(tree, object);		/* HR 021202 */
	char *tmplt, *s, *h;

	if (blk)
		curx -= blk->ob_shift;

	tmplt = xd_get_obspec(tree + object).tedinfo->te_ptmplt;		/* HR 021202 */

	if ((s = strchr(tmplt, '_')) != NULL)
	{
		while ((curx > 0) && *s)
		{
			if (*s++ == '_')
				curx--;
		}

		if ((h = strchr(s, '_')) != NULL)
			s = h;

		return (int) (s - tmplt);
	}
	else
		return 0;
}

/* Funktie die uit de positie van de cursor in de template string
   de positie in de text string bepaald. */

static int xd_rel_curx(OBJECT *tree, int edit_obj, int curx)
{
	int x = 0, i;
	char *tmplt = xd_get_obspec(tree + edit_obj).tedinfo->te_ptmplt;	/* HR 021202 */

	for (i = 0; i < curx; i++)
	{
		if (tmplt[i] == '_')
			x++;
	}

	return x;
}

/* Funktie voor het wissen van een teken uit een string. */

static void str_delete(char *s, int pos)
{
	char *h = &s[pos], ch;

	if (*h)
	{
		do
		{
			ch = h[1];
			*h++ = ch;
		}
		while (ch);
	}
}

/* Funktie voor het tussenvoegen van een karakter in een string. */

static void str_insert(char *s, int pos, int ch, int curlen, int maxlen)
{
	int i, m;

	if (pos < maxlen)
	{
		m = curlen + ((curlen < maxlen) ? 1 : -1);
		for (i = m; i > pos; i--)
			s[i] = s[i - 1];
		s[pos] = (char) ch;
	}
}

/* Funktie die controleert of een toets is toegestaan op positie
   in string. */

static int xd_chk_key(char *valid, int pos, int key)
{
	char cvalid = valid[pos];
	int ch = key & 0xFF, cch = key & 0xDF;

	if (!(key & (XD_SCANCODE | XD_CTRL | XD_ALT)))
	{
		if (cvalid == 'X')
			return ch;
		/* DjV 026 220103 ---vvv--- */
		else if ( cvalid == 'x' )
		{
			if ((cch >= 'A') && (cch <= 'Z'))
				return cch;
			else
				return ch;
		}
		/* DjV 026 220103 ---^^^--- */

		if (ch < 0x80)
		{
			switch (cvalid)
			{
			case 'N':
			case 'n':
			case '9':
				if ((ch >= '0') && (ch <= '9'))
					return ch;
				if (cvalid == '9')
					break;
			case 'A':
			case 'a':
				if (ch == ' ')
					return ch;
				if ((cch >= 'A') && (cch <= 'Z'))
					return (cvalid & 0x20) ? ch : cch;
				break;
			case 'F':
			case 'P':
			case 'p':
				if ((cch >= 'A') && (cch <= 'Z'))
					return cch;
				if ((ch == '_') || ((ch >= '0') && (ch <= '9')) || (ch == 'œ') || (ch == ':'))
					return ch;
				if ((cvalid != 'p') && ((ch == '?') || (ch == '*')))
					return ch;
				if ((cvalid != 'F') && ((ch == '\\') || (ch == '.')))
					return ch;
				break;
			}
		}
	}

	return 0;
}

static
int xd_chk_skip(OBJECT *tree, int edit_obj, int key)
{
	char *s = xd_get_obspec(tree + edit_obj).tedinfo->te_ptmplt,	/* HR 021202 */
	     *h;

	if (key & (XD_SCANCODE | XD_CTRL | XD_ALT))
		return 0;

	if (((h = strchr(s, key & 0xFF)) != NULL) && ((h = strchr(h, '_')) != NULL))
		return xd_rel_curx(tree, edit_obj, (int) (h - s));

	return 0;
}

void *xd_get_scrled(OBJECT *tree, int edit_obj)
{
	if (((tree[edit_obj].ob_type >> 8) & 0xff) == XD_SCRLEDIT)
		return (XUSERBLK *)tree[edit_obj].ob_spec.userblk->ub_parm;
	return NULL;
}

/* HR 021202: scrolling editable texts. */
static
bool xd_shift(XUSERBLK *blk, int pos, int flen, int clen)
{
	if (blk)
	{
		int shift = blk->ob_shift;

		if (pos == clen)
			shift = clen - flen;
		if (shift < 0)
			shift = 0;
		if (pos < shift)
			shift = pos;
		if (pos > shift + flen)
			shift = pos - flen;
		if (shift != blk->ob_shift)
			return blk->ob_shift = shift, true;
	}
	return false;
}

int xd_edit_char(XDINFO *info, int key)
{
	int edit_obj, oldpos, newpos, curlen, maxlen, flen, pos, ch;
	OBJECT *tree;
	TEDINFO *tedinfo;
	RECT clip;
	XUSERBLK *blk;
	int result = TRUE;

	tree = info->tree;

	if ((edit_obj = info->edit_object) <= 0)
		return FALSE;

	tedinfo = xd_get_obspec(tree + edit_obj).tedinfo;		/* HR 021202 */
	blk = xd_get_scrled(tree, edit_obj);

	oldpos = newpos = info->cursor_x;
	curlen = (int) strlen(tedinfo->te_ptext);

	flen = (int) strlen(tedinfo->te_pvalid);
	maxlen = blk ? XD_MAX_SCRLED : flen;		/* HR 021202 */

	objc_offset(tree, edit_obj, &clip.x, &clip.y);
	clip.h = xd_regular_font.fnt_chh;
	clip.w = xd_regular_font.fnt_chw * tedinfo->te_tmplen;		/* HR 021202 */

	if (blk)
	{
		clip.x -= 2*xd_regular_font.fnt_chw;		/* HR: This temporary until ub_scrledit() handles templates properly. */
		clip.w += 4*xd_regular_font.fnt_chw;
	}

	if (!(key & (XD_SCANCODE | XD_CTRL | XD_ALT)))
		key &= 0xFF;

	switch (key)
	{
	case SHFT_CURLEFT:
		newpos = 0;
		goto setcursor;
	case SHFT_CURRIGHT:
		newpos = curlen;
		goto setcursor;
	case CURLEFT:
		if (oldpos > 0)
			newpos = oldpos - 1;
		goto setcursor;
	case CURRIGHT:
		if (oldpos < curlen)
			newpos = oldpos + 1;

	  setcursor:
		if (oldpos != newpos)
		{
			xd_mouse_off();

			xd_cursor_off(info);
			info->cursor_x = newpos;

			if (xd_shift(blk, newpos, flen, curlen))	/* HR 021202: scrolling editable texts. */
				xd_redraw(info, edit_obj, 1, &clip, XD_RDIALOG);

			xd_cursor_on(info);

			xd_mouse_on();
		}
		break;
	case BACKSPC:
	case DELETE:
	case ESCAPE:
		if (   (key == BACKSPC && oldpos > 0)
		    || (key == DELETE  && oldpos < curlen)
		    || (key == ESCAPE  && *tedinfo->te_ptext != 0)
		   )
		{
/*	HR 021202: maintaining a tiny optimization, using clipping of
                the changed character places, became far too complicated
                together with the scrolling options.
*/
			xd_mouse_off();
			xd_cursor_off(info);

			if (key == ESCAPE)
			{
				*tedinfo->te_ptext = 0;
				info->cursor_x = 0;
				curlen = 0;
			}
			else
			{
				if (key == BACKSPC)
					info->cursor_x--;
				str_delete(tedinfo->te_ptext, info->cursor_x);
				curlen--;
			}

			xd_shift(blk, info->cursor_x, flen, curlen);	/* HR 021202: scrolling editable texts. */
			xd_redraw(info, edit_obj, 1, &clip, XD_RDIALOG);

			xd_cursor_on(info);
			xd_mouse_on();
		}
		break;
	default:
		pos = oldpos - ((oldpos == maxlen) ? 1 : 0);
		if (blk)			/* HR 021202 */
			ch = key & 0xff;
		else			/* HR 051202: Dangerous stuff! relying on evaluation order of &&, || */
		{
			ch  = xd_chk_key(tedinfo->te_pvalid, pos, key);
			if (ch == 0)
				pos = xd_chk_skip(tree, edit_obj, key);
		}

		if (ch != 0 || pos > 0 )
		{
			xd_mouse_off();
			xd_cursor_off(info);

			if (ch != 0)
			{
				info->cursor_x = pos + 1;
				str_insert(tedinfo->te_ptext, pos, ch, curlen, maxlen);
			}
			else
			{
				int i;
				char *str = tedinfo->te_ptext;

				info->cursor_x = pos;

				for (i = oldpos; i < pos; i++)
					str[i] = ' ';
				str[pos] = 0;
			}

			xd_shift(blk, info->cursor_x, flen, curlen + 1);	/* HR 021202: scrolling editable texts. */
			xd_redraw(info, edit_obj, 1, &clip, XD_RDIALOG);

			xd_cursor_on(info);
			xd_mouse_on();
		}
		else
			result = FALSE;
		break;
	}

	return result;
}

void xd_edit_end(XDINFO *info)
{
	if (info->edit_object > 0)
	{
		xd_cursor_off(info);
		info->edit_object = -1;
		info->cursor_x = 0;
	}
}

void xd_edit_init(XDINFO *info, int object, int curx)
{
	OBJECT *tree = info->tree;

	if ((object > 0) && xd_selectable(tree, object))
	{
		XUSERBLK *blk = xd_get_scrled(tree, object);		/* HR 021202 */
		TEDINFO *ted = xd_get_obspec(tree + object).tedinfo;
		int x, dummy, maxlen;

		maxlen = strlen(ted->te_ptext);

		if (curx >= 0)
		{
			objc_offset(tree, object, &x, &dummy);
			x = (curx - x + xd_regular_font.fnt_chw / 2) / xd_regular_font.fnt_chw;
			
			if (blk)										/* HR 021202 */
				x += blk->ob_shift;
			else
				x = xd_rel_curx(tree, object, x);

			if (x > maxlen)
				x = maxlen;
		}

		if (info->edit_object != object)
		{
			xd_edit_end(info);
			info->edit_object = object;
			info->cursor_x = (curx == -1) ? maxlen : x;
			xd_cursor_on(info);
		}
		else if ((curx >= 0) && (x != info->cursor_x))
		{
			xd_cursor_off(info);
			info->cursor_x = x;
			xd_cursor_on(info);
		}

		xd_shift(blk, info->cursor_x, strlen(ted->te_pvalid), maxlen);	/* HR 021202 */
	}
}

/********************************************************************
 *																	*
 * Funkties ter vervanging van form_keybd.							*
 *																	*
 ********************************************************************/

/* Funktie voor het vinden van het volgende editable object. */

int xd_find_obj(OBJECT *tree, int start, int which)
{
	int obj, flag, theflag, inc;

	obj = 0;
	flag = EDITABLE;
	inc = 1;

	switch (which)
	{
	case FMD_BACKWARD:
		inc = -1;
	case FMD_FORWARD:
		obj = start + inc;
		break;
	case FMD_DEFLT:
		flag = DEFAULT;
		break;
	}

	while (obj >= 0)
	{
		theflag = tree[obj].ob_flags;
		if ((theflag & flag) && xd_selectable(tree, obj))
			return obj;
		if (theflag & LASTOB)
			obj = -1;
		else
			obj += inc;
	}

	return start;
}

static
char cancel_buttons[][18] =
{
	"cancel",
	"abbruch",
	"annuler",
	"avbryt",
	"anuluj",
	"afbryd",
	"undo",
	"\0"
};

/* HR 151102: courtesy XaAES */
static
int xd_find_cancel(OBJECT *ob)
{
	int f = 0;

	do
	{
		if (   (   (ob[f].ob_type  & 0xff)                    == G_BUTTON
		        || (ob[f].ob_type  & 0xff00)                  == (XD_BUTTON<<8)
		       )
			&& (ob[f].ob_flags & (SELECTABLE|TOUCHEXIT|EXIT)) != 0       )
		{
			int l;
			char t[32]; char *s = t,*e;
			e = xd_get_obspec(ob+f).free_string;
			l = strlen(e);
			if (l < 32)
			{
				strcpy(t,e);
				/* strip surrounding spaces */
				e = t + l;
				while (*s == ' ') s++;
				while (*--e == ' ')  ;
				*++e = 0;
				if (e-s < 16)	/* No use comparing longer strings */
				{
					int i = 0;
					while (cancel_buttons[i][0])
					{
						if (stricmp(s,cancel_buttons[i]) == 0)
							return f;
						else i++;
					}
				}
			}
		}
	}
	while ( ! (ob[f++].ob_flags & LASTOB));
	return -1;
}

int xd_form_keybd(XDINFO *info, int kobnext, int kchar,
					  int *knxtobject, int *knxtchar)
{
	int i, mode = FMD_FORWARD;
	OBJECT *tree = info->tree;

	*knxtobject = kobnext;
	*knxtchar = 0;

	if (!(kchar & (XD_SCANCODE | XD_CTRL | XD_ALT)))
		kchar &= 0xFF;

	switch (kchar)
	{
	case CURUP:
		mode = FMD_BACKWARD;
	case CURDOWN:
	case TAB:
		if ((i = xd_find_obj(tree, info->edit_object, mode)) > 0)
		{
			*knxtobject = i;
			return TRUE;
		}
		break;
	case RETURN:
		if ((i = xd_find_obj(tree, 0, FMD_DEFLT)) > 0)
		{
			xd_change(info, i, SELECTED, TRUE);
			*knxtobject = i;
			return FALSE;
		}
		break;
	case UNDO:				/* HR 151102 */
		if ((i = xd_find_cancel(tree)) > 0)
		{
			xd_change(info, i, SELECTED, TRUE);
			*knxtobject = i;
			return FALSE;
		}
		break;
	default:
		*knxtchar = kchar;
		return TRUE;
	}

	return TRUE;
}

/********************************************************************
 *																	*
 * Funkties ter vervanging van form_button.							*
 *																	*
 ********************************************************************/

int xd_form_button(XDINFO *info, int object, int clicks, int *result)
{
	OBJECT *tree = info->tree;
	int flags = tree[object].ob_flags, parent, oldstate, dummy;

	if (   xd_selectable(tree, object)
	    && ((flags & SELECTABLE) || (flags & TOUCHEXIT))
	   )
	{
		oldstate = tree[object].ob_state;

		xd_wdupdate(BEG_MCTRL);

		if (flags & RBUTTON)
		{
			if (((parent = xd_obj_parent(tree, object)) >= 0) && !(oldstate & SELECTED))
				xd_rbutton(info, parent, object);
		}
		else if (flags & SELECTABLE)
		{
			XDEVENT events;
			int evflags, newstate, state;

			/* I_A changed to fit tristate-buttons! */
			if (!xd_is_tristate(tree + object))
				newstate = (oldstate & SELECTED) ? oldstate & ~SELECTED : oldstate | SELECTED;
			else
			{
				/* switch tri-state button! */
				newstate = xd_get_tristate(oldstate);
				switch (newstate)
				{
				case TRISTATE_0:
					newstate = xd_set_tristate(oldstate, TRISTATE_1);
					break;
				case TRISTATE_1:
					newstate = xd_set_tristate(oldstate, TRISTATE_2);
					break;
				case TRISTATE_2:
					newstate = xd_set_tristate(oldstate, TRISTATE_0);
					break;
				}
			}

			events.ev_mflags = MU_BUTTON | MU_TIMER;
			events.ev_mbclicks = 1;
			events.ev_mbmask = 1;
			events.ev_mbstate = 0;
			events.ev_mm1flags = 1;
			events.ev_mm2flags = 0;
			events.ev_mtlocount = 0;
			events.ev_mthicount = 0;
			xd_objrect(tree, object, &events.ev_mm1);

			xd_change(info, object, newstate, TRUE);

			do
			{
				evflags = xe_xmulti(&events);

				if (evflags & MU_M1)
				{
					if (events.ev_mm1flags == 1)
					{
						events.ev_mm1flags = 0;
						state = oldstate;
					}
					else
					{
						events.ev_mm1flags = 1;
						state = newstate;
					}
					xd_change(info, object, state, TRUE);
				}

				events.ev_mflags = MU_BUTTON | MU_M1;
				events.ev_mtlocount = 0;
			}
			while (!(evflags & MU_BUTTON));
		}

		xd_wdupdate(END_MCTRL);

		if (flags & TOUCHEXIT)
		{
			*result = object | ((clicks > 1) ? 0x8000 : 0);
			return FALSE;
		}

		if ((flags & EXIT) && (tree[object].ob_state != oldstate))
		{
			*result = object;
			return FALSE;
		}

		evnt_button(1, 1, 0, &dummy, &dummy, &dummy, &dummy);
	}

	*result = (flags & EDITABLE) ? object : 0;

	return TRUE;
}

/********************************************************************
 *																	*
 * Funkties voor form_do.											*
 *																	*
 ********************************************************************/

/* Funktie voor het zoeken van de button waarmee de dialoogbox
   verplaatst kan worden. */

int xd_movebutton(OBJECT *tree)
{
	OBJECT *c_obj;
	int cur = 0;

	for (;;)
	{
		c_obj = &tree[cur];

		if (((c_obj->ob_type >> 8) & 0xFF) == XD_DRAGBOX)
			return cur;

		if (c_obj->ob_flags & LASTOB)
			return -1;

		cur++;
	}
}

/* Eigen form_do */

int xd_kform_do(XDINFO *info, int start, userkeys userfunc, void *userdata)
{
	int next_obj = 0, which, kr, db, nkeys, cmode = -1;
	XDEVENT events;
	int cont = TRUE;
	OBJECT *tree = info->tree;
	KINFO kinfo[MAXKEYS];

	xd_wdupdate(BEG_UPDATE);

	xd_fdo_flag = TRUE;
	db = xd_movebutton(tree);
	nkeys = xd_set_keys(tree, kinfo);

	if (info->dialmode != XD_WINDOW)
	{
		events.ev_mflags = MU_KEYBD | MU_BUTTON;
		xd_wdupdate(BEG_MCTRL);
	}
	else
		events.ev_mflags = MU_KEYBD | MU_BUTTON | MU_MESAG;

	events.ev_mbclicks = 2;
	events.ev_mbmask = 1;
	events.ev_mbstate = 1;
	events.ev_mm1flags = 0;
	events.ev_mm2flags = 0;
	events.ev_mtlocount = 0;
	events.ev_mthicount = 0;

	next_obj = 0;

	start = (start == 0) ? xd_find_obj(tree, 0, FMD_FORWARD) : start;

	xd_edit_init(info, start, cmode);

	while (cont == TRUE)
	{
		xd_wdupdate(END_UPDATE);

		which = xe_xmulti(&events);

		if ((which & MU_MESAG) && (xd_usermessage != 0L))
		{
			if (xd_usermessage(events.ev_mmgpbuf) != 0)
			{
				next_obj = -1;
				cont = FALSE;
			}
		}

		xd_wdupdate(BEG_UPDATE);

		if ((which & MU_KEYBD) && cont)
		{
			int object;

			if ((userfunc == (userkeys) 0) || (userfunc(info, userdata, events.xd_keycode) == 0))
			{
				if ((object = xd_find_key(tree, kinfo, nkeys, events.xd_keycode)) >= 0)
				{
					next_obj = object;
					cont = xd_form_button(info, next_obj, 1, &next_obj);
				}
				else
				{
					if ((cont = xd_form_keybd(info, next_obj, events.xd_keycode, &next_obj, &kr)) != FALSE)
						cmode = -1;
					if (kr)
						xd_edit_char(info, kr);
				}
			}
		}

		if ((which & MU_BUTTON) && cont)
		{
			if ((next_obj = objc_find(tree, ROOT, MAX_DEPTH, events.ev_mmox, events.ev_mmoy)) == -1)
			{
				Bconout(2, 7);
				next_obj = 0;
			}
			else
			{
				if ((cont = xd_form_button(info, next_obj, events.ev_mbreturn, &next_obj)) != FALSE)
					cmode = events.ev_mmox;

				if ((next_obj & 0x7FFF) == db)
				{
					int nx, ny;

					graf_dragbox(info->drect.w, info->drect.h, info->drect.x, info->drect.y,
								 xd_desk.x, xd_desk.y, xd_desk.w, xd_desk.h, &nx, &ny);

					xd_restore(info);

					xd_set_position(info, nx, ny);

					xd_save(info);
					xd_redraw(info, ROOT, MAX_DEPTH, &info->drect, XD_RDIALOG | XD_RCURSOR);

					cont = TRUE;
					next_obj = 0;
				}
			}
		}

		if (cont && (next_obj != 0))
		{
			xd_edit_init(info, next_obj, cmode);
			next_obj = 0;
		}
	}

	if (info->dialmode != XD_WINDOW)
		xd_wdupdate(END_MCTRL);

	xd_edit_end(info);
	xd_fdo_flag = FALSE;

	xd_wdupdate(END_UPDATE);

	return (next_obj);
}

int xd_form_do(XDINFO *info, int start)
{
	return xd_kform_do(info, start, (userkeys) 0, NULL);
}

/********************************************************************
 *																	*
 * Funkties voor het initialiseren en deinitialiseren van een		*
 * dialoog.															*
 *																	*
 ********************************************************************/

/* initialisatie voor dialoog. Berekent de positie van de box en redt
   het scherm.

   tree		- objectboom,
   info		- bevat informatie over buffer voor scherm en de positie
   			  van de dialoogbox.
*/

void xd_open(OBJECT *tree, XDINFO *info)
{
	xd_open_wzoom(tree, info, NULL, FALSE);
}

void xd_open_wzoom(OBJECT *tree, XDINFO *info, RECT *xywh,
				   int zoom)
{
	int dialmode = xd_dialmode;
	int db;
	XDINFO *prev = xd_dialogs;

	info->tree = tree;
	info->prev = prev;
	xd_dialogs = info;
	info->edit_object = -1;
	info->cursor_x = 0;
	info->curs_cnt = 1;
	info->func = NULL;

	xd_wdupdate(BEG_UPDATE);

	xd_calcpos(info, prev, xd_posmode);

	if (dialmode == XD_WINDOW)
	{
		if ((prev == NULL) || (prev->dialmode == XD_WINDOW))
		{
			WINDOW *w;
			RECT wsize;
			int error;

			xw_calc(WC_BORDER, XD_WDFLAGS, &info->drect, &wsize, NULL);

			if (wsize.x < xd_desk.x)
			{
				int d = xd_desk.x - wsize.x;

				info->drect.x += d;
				tree->ob_x += d;
				wsize.x = xd_desk.x;
			}

			if (wsize.y < xd_desk.y)
			{
				int d = xd_desk.y - wsize.y;

				info->drect.y += d;
				tree->ob_y += d;
				wsize.y = xd_desk.y;
			}

			if (zoom && xywh)
			{
				graf_growbox(xywh->x, xywh->y, xywh->w, xywh->h,
							 wsize.x, wsize.y, wsize.w, wsize.h);
				zoom = FALSE;
			}

			if ((w = xw_create(XW_DIALOG, &xd_wdfuncs, XD_WDFLAGS,
							   &wsize, sizeof(WINDOW), NULL, &error)) != NULL)
			{
				xw_set(w, WF_NAME, xd_prgname);
				xw_open(w, &wsize);

				info->window = w;

				if (prev == NULL)
					xd_disable_menu();

				xd_wdupdate(END_UPDATE);
			}
			else
				dialmode = XD_BUFFERED;
		}
		else
			dialmode = XD_BUFFERED;
	}

	if (zoom && xywh)
	{
		graf_growbox(xywh->x, xywh->y, xywh->w, xywh->h,
		info->drect.x, info->drect.y, info->drect.w, info->drect.h);
		zoom = FALSE;
	}

	if (dialmode == XD_BUFFERED)
	{
		long scr_size;

		scr_size = xd_initmfdb(&info->drect, &info->mfdb);

		if ((info->mfdb.fd_addr = (void *) Malloc(scr_size)) == NULL)
			dialmode = XD_NORMAL;
	}

	info->dialmode = dialmode;

	if ((db = xd_movebutton(tree)) >= 0)
	{
		if (dialmode != XD_BUFFERED)
			tree[db].ob_flags |= HIDETREE;
		else
			tree[db].ob_flags &= ~HIDETREE;
	}

	if (dialmode != XD_WINDOW)
	{
		if (dialmode == XD_NORMAL)
		{
			if (prev != NULL)
				xd_calcpos(info, prev, XD_CENTERED);

			if ((prev == NULL) || (prev->dialmode == XD_WINDOW))
				form_dial(FMD_START, 0, 0, 0, 0, info->drect.x, info->drect.y, info->drect.w, info->drect.h);
		}
		else
			xd_save(info);

		xd_draw(info,ROOT,MAX_DEPTH);
	}
}

/* funktie die opgeroepen moet worden na het einde van de dialoog.
   De funktie hersteld het scherm en geeft het geheugen van de
   schermbuffer weer vrij. */

void xd_close(XDINFO *info)
{
	xd_close_wzoom(info, NULL, FALSE);
}


void xd_close_wzoom(XDINFO *info, RECT *xywh, int zoom)
{
	XDINFO *prev;

	if (xd_dialogs != info)
		return;

	prev = info->prev;

	if (info->dialmode == XD_WINDOW)
	{
		WINDOW *w = info->window;

		xd_wdupdate(BEG_UPDATE);

		if (prev == NULL)
			xd_enable_menu();

		xw_close(w);
		xw_delete(w);

		if (prev != NULL)
			xw_set(prev->window, WF_TOP);
	}

	if (info->dialmode == XD_BUFFERED)
	{
		xd_restore(info);
		Mfree(info->mfdb.fd_addr);
	}

	if (info->dialmode == XD_NORMAL)
	{
		if ((prev != NULL) && (prev->dialmode != XD_WINDOW))
			objc_draw(prev->tree, ROOT, MAX_DEPTH, info->drect.x, info->drect.y, info->drect.w, info->drect.h);
		else
			form_dial(FMD_FINISH, 0, 0, 0, 0, info->drect.x, info->drect.y, info->drect.w, info->drect.h);
	}

	if (zoom && xywh)
	{
		graf_shrinkbox(xywh->x, xywh->y, xywh->w, xywh->h,
		info->drect.x, info->drect.y, info->drect.w, info->drect.h);
	}

	xd_wdupdate(END_UPDATE);

	xd_dialogs = prev;

/*!!!	if ((prev != NULL) && (prev->dialmode == XD_WINDOW))
		xd_scan_messages(XD_EVREDRAW, NULL);*/
}

/********************************************************************
 *																	*
 * Hoog niveau funkties voor het uitvoeren van dialogen. Deze		*
 * funkties voeren alles wat nodig is voor een dialoog uit,			*
 * inclusief de form_do.											*
 *																	*
 ********************************************************************/

int xd_kdialog(OBJECT *tree, int start, userkeys userfunc, void *userdata)
{
	int exit;
	XDINFO info;

	xd_open(tree, &info);
	exit = xd_kform_do(&info, start, userfunc, userdata);
	xd_change(&info, exit, NORMAL, FALSE);
	xd_close(&info);

	return exit;
}

int xd_dialog(OBJECT *tree, int start)
{
	return xd_kdialog(tree, start, (userkeys) 0, NULL);
}

/********************************************************************
 *																	*
 * Funkties voor het zetten van de dialoogmode en de mode waarmee	*
 * de plaats van de dialoog op het scherm bepaald wordt.			*
 *																	*
 ********************************************************************/

int xd_setdialmode(int new, int (*hndl_message) (int *message),
				   OBJECT *menu, int nmnitems, int *mnitems)
{
	int old;

	old = xd_dialmode;

	if ((new >= XD_NORMAL) && (new <= XD_WINDOW))
	{
		xd_dialmode = new;
		xd_usermessage = hndl_message;
		xd_menu = menu;
		xd_nmnitems = nmnitems;
		xd_mnitems = mnitems;
	}

	return old;
}

int xd_setposmode(int new)
{
	int old;

	old = xd_posmode;

	if ((new >= XD_CENTERED) && (new <= XD_CURRPOS))
		xd_posmode = new;

	return old;
}

/********************************************************************
 *																	*
 * Funkties voor de initialisatie en deinitialisatie van de module.	*
 *																	*
 ********************************************************************/

int init_xdialog(int *vdi_handle, void *(*malloc) (unsigned long size),
				 void (*free) (void *block), const char *prgname,
				 int load_fonts, int *nfonts)
{
	int dummy, i, work_in[11], work_out[57];

#ifndef __PUREC__
	extern short _global[];
#endif

	xd_malloc = malloc;
	xd_free = free;
	xd_prgname = prgname;
	xd_multitos = FALSE;
#ifdef __PUREC__
/*	xd_draw_3d = (_GemParBlk.glob.version >= 0x330);
*/	xd_aes4_0  = (_GemParBlk.glob.version >= 0x400);
#else
	xd_aes4_0 = (_global[0] >= 0x330);
/*	xd_draw_3d = (_global[0] >= 0x400);
*/
#endif
	xd_min_timer = 10;			/* Minimum time passed to xe_multi(). */

	wind_get(0, WF_WORKXYWH, &xd_desk.x, &xd_desk.y, &xd_desk.w, &xd_desk.h);
	xd_vhandle = graf_handle(&dummy, &dummy, &dummy, &dummy);

	for (i = 0; i < 10; i++)
		work_in[i] = 1;
	work_in[10] = 2;

	v_opnvwk(work_in, &xd_vhandle, work_out);

	if (xd_vhandle == 0)
		return XDVDI;
	else
	{
	/*	int pix_height; */

		xd_ncolors = work_out[13];
	/*	pix_height = work_out[4]; */

		vq_extnd(xd_vhandle, 1, work_out);
		xd_nplanes = work_out[4];

#ifdef __GNUC_INLINE__
		if (load_fonts && vq_vgdos())
#else
		if (load_fonts && vq_gdos())
#endif
			*nfonts = vst_load_fonts(xd_vhandle, 0);
		else
			*nfonts = 0;

/* HR 151102: proper appl_getinfo protocol, works also with MagiC */
		if ( appl_find( "?AGI" ) == 0 )		/* appl_getinfo() vorhanden? */
			aes_flags |= GAI_INFO;

		if (aes_flags & GAI_INFO)
		{
			int ag1, ag2, ag3, ag4;
			xd_aes4_0 |= TRUE;
			aes_hor3d = 2;			/* HR 120203 */
			aes_ver3d = 2;

			appl_getinfo(0, &xd_regular_font.fnt_height, &xd_regular_font.fnt_id,
						 &xd_regular_font.fnt_type, &dummy);
			appl_getinfo(1, &xd_small_font.fnt_height, &xd_small_font.fnt_id,
						 &xd_small_font.fnt_type, &dummy);
			appl_getinfo(2, &ag1, &ag2, &colour_icons, &xresources);		/* HR 151102 */

			if ( appl_getinfo( 13, &ag1, &ag2, &ag3, &ag4 ))		/* Unterfunktion 13, Objekte */
			{
				if ( ag4 & 0x08 )				/* G_SHORTCUT untersttzt ? */
					aes_flags |= GAI_GSHORTCUT;
				if ( ag4 & 0x04 )				/* MagiC (WHITEBAK) objects */
					aes_flags |= GAI_WHITEBAK;
/* HR 120203: get 3D enlargement value */
				if ( ag1 && ag2 )					/* 3D-Objekte und objc_sysvar() vorhanden? */
					objc_sysvar( 0, AD3DVAL, 0, 0, &aes_hor3d, &aes_ver3d );	/* 3D-Look eingeschaltet? */
			}
			if (xd_small_font.fnt_id > 0)		/* HR 051202: for some AES's (Milan) */
				xd_small_font.fnt_id = vst_font(xd_vhandle, xd_small_font.fnt_id);
			else
				xd_small_font.fnt_height = 8;

			if (xd_regular_font.fnt_id > 0)		/* HR 051202: for some AES's (Milan) */
				xd_regular_font.fnt_id = vst_font(xd_vhandle, xd_regular_font.fnt_id);
			else
			{
				int dum,effects[3],d[5];
				vqt_fontinfo(xd_vhandle,&dum,&dum,d,&dum,effects);
				xd_regular_font.fnt_height = d[4];		/* celltop to baseline */
			}
		}
		else
		{
			vqt_attributes(xd_vhandle, work_out);

			xd_regular_font.fnt_id = 1;
			xd_regular_font.fnt_type = 0;
			xd_regular_font.fnt_height = (work_out[7] <= 7) ? 9 : 10;

			xd_small_font.fnt_id = 1;
			xd_small_font.fnt_type = 0;
			xd_small_font.fnt_height = 8;
		}

		xd_small_font.fnt_height = vst_point(xd_vhandle, xd_small_font.fnt_height, &dummy, &dummy, &dummy, &xd_small_font.fnt_chh);
		vqt_width(xd_vhandle, ' ', &xd_small_font.fnt_chw, &dummy, &dummy);

		xd_regular_font.fnt_height = vst_point(xd_vhandle, xd_regular_font.fnt_height, &dummy, &dummy, &dummy, &xd_regular_font.fnt_chh);
		vqt_width(xd_vhandle, ' ', &xd_regular_font.fnt_chw, &dummy, &dummy);

		*vdi_handle = xd_vhandle;

		return 0;
	}
}

void exit_xdialog(void)
{
	XDOBJDATA *h = xd_objdata, *next;

	while (xd_dialogs)
		xd_close(xd_dialogs);

	while (xd_nmdialogs)
		xd_nmclose(xd_nmdialogs, NULL, FALSE);

	while (h != NULL)
	{
		next = h->next;
		xd_free(h);
		h = next;
	}

	xw_closeall();

	v_clsvwk(xd_vhandle);
}
