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
#include <stdlib.h>
#include <string.h>
#include <vdi.h>
#include <boolean.h>
#include <mint.h>
#include <xdialog.h>
#include <xscncode.h>

#include "desk.h"
#include "error.h"
#include "font.h"
#include "resource.h"
#include "xfilesys.h"
#include "screen.h"
#include "viewer.h"
#include "window.h"

#define TFLAGS			(NAME|CLOSER|FULLER|MOVER|SIZER|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE)
#define MAXWINDOWS		8
#define FWIDTH			256
#define HEXLEN			74
#define min(x,y)		(((x) < (y)) ? (x) : (y))
#define max(x,y)		(((x) > (y)) ? (x) : (y))
#define ASCII_PERC		80

typedef struct
{
	unsigned int fulled : 1;
	unsigned int resvd:15;
} WDFLAGS;

typedef struct
{
	XW_INTVARS;					/* Interne variabelen bibliotheek. */
	int rows;					/* hoogte en breedte van window in karakters */
	int columns;				/* (van het geselekteerde font, naar boven afgerond) */

	int nrows;					/* hoogte en breedte van window in karakters */
	int ncolumns;				/* (van het geselekteerde font, naar beneden afgerond) */

	int px;
	long py;

	int tabsize;

	const char *name;
	char title[80];

	char *buffer;				/* buffer met de tekst */
	long size;					/* aantal bytes in de tekst */
	long tlines;				/* aantal regels in de tekst */
	char **lines;				/* lijst met pointers naar het begin van alle tekstregels */

	long nlines;				/* aantal regels in het window */

	unsigned int hexmode : 1;	/* Hexmode flag. */

	struct winfo *winfo;		/* pointer naar WINFO structuur. */
} TXT_WINDOW;

typedef struct winfo
{
	int x;						/* positie van het window */
	int y;
	int w;						/* afmetingen van het werkgebied */
	int h;
	WDFLAGS flags;
	boolean used;
	TXT_WINDOW *txt_window;
} WINFO;

typedef struct
{
	int x;
	int y;
	int w;
	int h;
	WDFLAGS flags;
	int resvd;
} SINFO1;

typedef struct
{
	int index;
	int px;
	long py;
	int resvd1;
	long resvd2;
	int hexmode : 1;
	int resvd3 : 7;
	int tabsize : 8;
} SINFO2;

typedef struct
{
	int id;
	int size;
	int resvd1;
	int resvd2;
} FDATA;

static WINFO textwindows[MAXWINDOWS];
static RECT tmax;
static FONT txt_font;

static void set_menu(TXT_WINDOW *w);

static int txt_hndlkey(WINDOW *w, int scancode, int keystate);
static void txt_hndlbutton(WINDOW *w, int x, int y, int n, int button_state, int keystate);
static void txt_redraw(WINDOW *w, RECT *area);
static void txt_topped(WINDOW *w);
static void txt_closed(WINDOW *w);
static void txt_fulled(WINDOW *w);
static void txt_arrowed(WINDOW *w, int arrows);
static void txt_hslider(WINDOW *w, int newpos);
static void txt_vslider(WINDOW *w, int newpos);
static void txt_sized(WINDOW *w, RECT *newsize);
static void txt_moved(WINDOW *w, RECT *newpos);
static void txt_hndlmenu(WINDOW *w, int title, int item);
static void txt_top(WINDOW *w);

static WD_FUNC txt_functions =
{
	txt_hndlkey,
	txt_hndlbutton,
	txt_redraw,
	txt_topped,
	txt_topped,
	txt_closed,
	txt_fulled,
	txt_arrowed,
	txt_hslider,
	txt_vslider,
	txt_sized,
	txt_moved,
	txt_hndlmenu,
	txt_top
};

/********************************************************************
 *																	*
 * Hulpfuncties.													*
 *																	*
 ********************************************************************/

static int txt_width(TXT_WINDOW *w)
{
	return (w->hexmode == 1) ? HEXLEN : FWIDTH;
}

static void txt_draw(TXT_WINDOW *w, boolean message)
{
	RECT area;

	xw_get((WINDOW *) w, WF_CURRXYWH, &area);

	if (message)
		xw_send_redraw((WINDOW *) w, &area);
	else
		txt_redraw((WINDOW *) w, &area);
}

/* Funktie voor het zetten van de default grootte */

static void txt_set_defsize(WINFO *w)
{
	RECT border, work;

	xw_get((WINDOW *) w->txt_window, WF_CURRXYWH, &border);
	xw_get((WINDOW *) w->txt_window, WF_WORKXYWH, &work);

	w->x = border.x - screen_info.dsk.x;
	w->y = border.y - screen_info.dsk.y;
	w->w = work.w / screen_info.fnt_w;
	w->h = work.h / screen_info.fnt_h;
}

static void txt_calc_rc(TXT_WINDOW *w, RECT *work)
{
	w->rows = (work->h + txt_font.ch - 1) / txt_font.ch;
	w->columns = (work->w + txt_font.cw - 1) / txt_font.cw;

	w->nrows = work->h / txt_font.ch;
	w->ncolumns = work->w / txt_font.cw;
}

/* Funktie die uit opgegeven grootte de werkelijke grootte van het
   window berekent. */

static void txt_wsize(TXT_WINDOW *w, RECT *input, RECT *output)
{
	RECT work;
	int fw, fh;

	fw = screen_info.fnt_w;
	fh = screen_info.fnt_h;

	xw_calc(WC_WORK, TFLAGS, input, &work, viewmenu);

	work.x += fw / 2;
	work.w += fw / 2;
	work.h += fh / 2;

	work.x -= (work.x % fw);
	work.w -= (work.w % fw);
	work.h -= (work.h % fh);

	work.w = min(work.w, tmax.w);
	work.h = min(work.h, tmax.h);

	xw_calc(WC_BORDER, TFLAGS, &work, output, viewmenu);

	txt_calc_rc(w, &work);
}

/* Funktie voor het bereken van de grootte van een window uit de in
   w opgeslagen grootte. */

static void txt_calcsize(WINFO *w, RECT *size)
{
	if (w->flags.fulled == 1)
		txt_wsize(w->txt_window, &screen_info.dsk, size);
	else
	{
		RECT def, border;

		def.x = w->x + screen_info.dsk.x;
		def.y = w->y + screen_info.dsk.y;
		def.w = w->w * screen_info.fnt_w;	/* hoogte en breedte van het */
		def.h = w->h * screen_info.fnt_h;	/* werkgebied. */

		/* Bereken hoogte en breedte van het window */
		xw_calc(WC_BORDER, TFLAGS, &def, &border, viewmenu);

		border.x = def.x;
		border.y = def.y;

		txt_wsize(w->txt_window, &border, size);
	}
}

/********************************************************************
 *																	*
 * Funkties voor het zetten van de sliders.							*
 *																	*
 ********************************************************************/

/* Funktie voor het zetten van de grootte van de verticale
   slider. */

static void set_vslsize(TXT_WINDOW *w)
{
	long p, lines, wlines;

	wlines = w->nrows;
	lines = w->nlines;

	w->py = (lines < wlines) ? 0 : min(w->py, lines - wlines);
	p = (lines > wlines) ? (wlines * 1000L) / lines : 1000;
	xw_set((WINDOW *) w, WF_VSLSIZE, (int) p);
}

/* Funktie voor het zetten van de positie van de verticale
   slider. */

static void set_vslpos(TXT_WINDOW *w)
{
	long h, lines, wlines;
	int pos;

	wlines = w->nrows;
	lines = w->nlines;

	w->py = (lines < wlines) ? 0 : min(w->py, lines - wlines);
	h = lines - wlines;
	pos = (h > 0) ? (int) ((1000L * w->py) / h) : 0;
	xw_set((WINDOW *) w, WF_VSLIDE, pos);
}

/* Funktie voor het zetten van de grootte van de horizontale
   slider. */

static void set_hslsize(TXT_WINDOW *w)
{
	int p, width, wwidth;

	wwidth = w->ncolumns;
	width = txt_width(w);

	w->px = (width < wwidth) ? 0 : min(w->px, width - wwidth);
	p = (width > wwidth) ? (int) (((long) wwidth * 1000L) / (long) width) : 1000;
	xw_set((WINDOW *) w, WF_HSLSIZE, p);
}

/* Funktie voor het zetten van de positie van de horizontale
   slider. */

static void set_hslpos(TXT_WINDOW *w)
{
	int width, wwidth, pos;
	long h;

	wwidth = w->ncolumns;
	width = txt_width(w);

	w->px = (width < wwidth) ? 0 : min(w->px, width - wwidth);
	h = width - wwidth;
	pos = (h > 0) ? (int) ((1000L * (long) w->px) / h) : 0;
	xw_set((WINDOW *) w, WF_HSLIDE, pos);
}

/* Funktie voor het zetten van alle sliders van een window. */

static void set_sliders(TXT_WINDOW *w)
{
	set_hslsize(w);
	set_hslpos(w);
	set_vslsize(w);
	set_vslpos(w);
}

/********************************************************************
 *																	*
 * Functies voor het tekenen van de inhoud van een tekstwindow.		*
 *																	*
 ********************************************************************/

/*
 * Functie voor het converteren van een hexadecimale digit in
 * een ASCII karakter.
 *
 * Parameters:
 *
 * x		- hexadecimaal getal
 *
 * Resultaat: ASCII karakter
 */

static char hexdigit(int x)
{
	return (x <= 9) ? x + '0' : x + 'A' - 10;
}

/*
 * Functie voor het uitlezen van een regel uit de buffer van een
 * window. Afhankelijk van de mode is de presentatie in ASCII of
 * hexadecimaal.
 *
 * Parameters:
 *
 * w		- Pointer naar WINFO structuur
 * dest		- Buffer waarin de regel geplaatst moet worden
 * line		- Nummer van de regel
 *
 * Resultaat: Lengte van de regel
 */

static int txt_line(TXT_WINDOW *w, char *dest, long line)
{
	char *s, *d = dest;

	if (line >= w->nlines)
	{
		*dest = 0;
		return 0;
	}

	if (w->hexmode == 0)
	{
		char ch;
		int cnt = 0, m = w->px + w->columns, tabsize = w->tabsize;

		if ((s = w->lines[line]) == NULL)
		{
			*dest = 0;
			return 0;
		}

		while (cnt < w->px)
		{
			if ((ch = *s++) == 0)
				continue;
			if (ch == '\n')
			{
				*d = 0;
				return 0;
			}
			if (ch == '\r')
				continue;
			if (ch == '\t')
			{
				do
				{
					if (cnt >= w->px)
						*d++ = ' ';
					cnt++;
				}
				while (((cnt % tabsize) != 0) && (cnt < m));
				continue;
			}
			cnt++;
		}

		while (cnt < m)
		{
			if ((ch = *s++) == 0)
				continue;
			if (ch == '\n')
				break;
			if (ch == '\r')
				continue;
			if (ch == '\t')
			{
				do
				{
					*d++ = ' ';
					cnt++;
				}
				while (((cnt % tabsize) != 0) && (cnt < m));
				continue;
			}
			*d++ = ch;
			cnt++;
		}
		*d = 0;

		return (int) (d - dest);
	}
	else
	{
		int cnt = 0, m = w->columns;
		long a = 16L * line, i, h;
		char tmp[128], *p = &w->buffer[a];

		if (w->px >= HEXLEN)
		{
			*dest = 0;
			return 0;
		}

		h = a;
		for (i = 5; i >= 0; i--)
		{
			tmp[i] = hexdigit((int) h & 0x0F);
			h >>= 4;
		}
		tmp[6] = ':';

		for (i = 0; i < 16; i++)
		{
			h = 7 + i * 3;
			tmp[h] = ' ';
			if ((a + i) < w->size)
			{
				tmp[h + 1] = hexdigit((p[i] >> 4) & 0x0F);
				tmp[h + 2] = hexdigit(p[i] & 0x0F);
				tmp[57 + i] = (p[i] == 0) ? '\020' : p[i];
			}
			else
			{
				tmp[h + 1] = ' ';
				tmp[h + 2] = ' ';
				tmp[57 + i] = ' ';
			}
			tmp[55] = ' ';
			tmp[56] = ' ';
			tmp[73] = 0;
		}

		s = &tmp[w->px];
		while (cnt < m)
		{
			if ((*d++ = *s++) == 0)
			{
				d--;
				break;
			}
			cnt++;
		}
		*d = 0;

		return (int) (d - dest);
	}
}

/*
 * Bereken de rechthoek die de te tekenen tekst omsluit.
 *
 * Parameters:
 *
 * tw		- Pointer naar window
 * line		- Regelnummer
 * strlen	- lengte van de string
 * work		- RECT structuur met de grootte van het werkgebied van het
 *			  window.
 */

static void txt_comparea(TXT_WINDOW *w, long line, int strlen, RECT *r, RECT *work)
{
	r->x = work->x;
	r->y = work->y + (int) (line - w->py) * txt_font.ch;
	r->w = strlen * txt_font.cw;
	r->h = txt_font.ch;
}

/*
 * Functie voor het afdrukken van 1 karakter van een regel. Deze
 * functie wordt bij het naar links en rechts scrollen van een
 * window gebruikt.
 *
 * Parameters:
 *
 * w		- Pointer naar window
 * column	- Kolom waarin het karakter wordt afgedrukt
 * line		- Regel waarin het karakter wordt afgedrukt
 * area		- Clipping rechthoek
 * work		- Werkgebied van het window
 */

static void txt_prtchar(TXT_WINDOW *w, int column, long line, RECT *area, RECT *work)
{
	RECT r, in;
	int len, c;
	char s[FWIDTH];

	c = column - w->px;

	len = txt_line(w, s, line);
	txt_comparea(w, line, len, &r, work);
	r.x += c * txt_font.cw;
	r.w = txt_font.cw;

	if (xd_rcintersect(area, &r, &in) == TRUE)
	{
		if (c < len)
		{
			s[c + 1] = 0;
			pclear ( & r );							/* DjV 011 030203 */
			vswr_mode( vdi_handle, MD_TRANS );		/* DjV 011 030203 */
			v_gtext(vdi_handle, r.x, r.y, &s[c]);
		}
		else
			/* clear(&in);    DjV 011 030203 */
			pclear(&in);   /* DjV 011 030203 */
	}
}

/*
 * Functie voor het afdrukken van een regel.
 *
 * Parameters:
 *
 * w		- Pointer naar window
 * line		- Regel die wordt afgedrukt
 * area		- Clipping rechthoek
 * work		- Werkgebied van het window
 */

static void txt_prtline(TXT_WINDOW *w, long line, RECT *area, RECT *work)
{
	RECT r, in;
	int len;
	char s[FWIDTH];

	len = txt_line(w, s, line);
	txt_comparea(w, line, len, &r, work);
	if (rc_intersect2(area, &r) == TRUE)
	{										/* DjV 011 030203 */
		pclear(&r);							/* DjV 011 030203 */
		vswr_mode( vdi_handle, MD_TRANS );	/* DjV 011 030203 */
		v_gtext(vdi_handle, r.x, r.y, s);
	}										/* DjV 011 030203 */
	r.x += r.w;
	r.w = work->w - r.w;
	if (xd_rcintersect(&r, area, &in) == TRUE)
		/* clear(&in);    DjV 011 030203 */
		pclear(&in);   /* DjV 011 030203 */
}

/*
 * Functie voor het afdrukken van alle regels die zichtbaar zijn in
 * een window.
 *
 * Parameters:
 *
 * w		- Pointer naar window
 * area		- Clipping rechthoek
 */

static void txt_prtlines(TXT_WINDOW *w, RECT *area)
{
	long i;
	RECT work;

	set_txt_default(txt_font.id, txt_font.size);

	xw_get((WINDOW *) w, WF_WORKXYWH, &work);

	for (i = 0; i < w->rows; i++)
		txt_prtline(w, w->py + i, area, &work);
}

/********************************************************************
 *																	*
 * Funkties voor scrollen van tekstwindows.							*
 *																	*
 ********************************************************************/

/*
 * Functie om een pagina naar terug te scrollen.
 *
 * Parameters:
 *
 * w		- Pointer naar window
 */

static void w_pageup(TXT_WINDOW *w)
{
	long oldy;

	oldy = w->py;
	w->py -= w->nrows;

	if (w->py < 0)
		w->py = 0;

	if (w->py != oldy)
	{
		set_vslpos(w);
		txt_draw(w, FALSE);
	}
}

/*
 * Functie om een pagina naar verder te scrollen.
 *
 * Parameters:
 *
 * w		- Pointer naar window
 */

static void w_pagedown(TXT_WINDOW *w)
{
	long oldy;

	oldy = w->py;
	w->py += w->nrows;

	if ((w->py + w->nrows) > w->nlines)
		w->py = max(w->nlines - w->nrows, 0);

	if (w->py != oldy)
	{
		set_vslpos(w);
		txt_draw(w, FALSE);
	}
}

/*
 * Functie om een pagina naar links te scrollen.
 *
 * Parameters:
 *
 * w		- Pointer naar window
 */

static void w_pageleft(TXT_WINDOW *w)
{
	int oldx;

	oldx = w->px;
	w->px -= w->ncolumns;

	if (w->px < 0)
		w->px = 0;

	if (w->px != oldx)
	{
		set_hslpos(w);
		txt_draw(w, FALSE);
	}
}

/*
 * Functie om een pagina naar rechts te scrollen.
 *
 * Parameters:
 *
 * w		- Pointer naar window
 */

static void w_pageright(TXT_WINDOW *w)
{
	int oldx, width;

	oldx = w->px;
	width = txt_width(w);

	w->px += w->ncolumns;

	if ((w->px + w->ncolumns) > width)
		w->px = max(width - w->ncolumns, 0);

	if (w->px != oldx)
	{
		set_hslpos(w);
		txt_draw(w, FALSE);
	}
}

/*
 * Zoek de eerste regel van een window, die zichtbaar is binnen
 * een rechthoek.
 *
 * Parameters:
 *
 * wy		- y coordinaat werkgebied window
 * area		- rechthoek
 * prev		- pointer naar een boolean, die aangeeft of een of twee
 *			  regels opnieuw getekend moeten worden.
 *
 * Resultaat: Eerste regel
 */

static long find_firstline(int wy, RECT *area, boolean *prev)
{
	long line;

	line = (area->y - wy);
	*prev = ((line % txt_font.ch) == 0) ? FALSE : TRUE;

	return (line / txt_font.ch);
}

/*
 * Zoek de laatste regel van een window, die zichtbaar is binnen
 * een rechthoek.
 *
 * Parameters:
 *
 * wy		- y coordinaat werkgebied window
 * area		- rechthoek
 * prev		- pointer naar een boolean, die aangeeft of een of twee
 *			  regels opnieuw getekend moeten worden.
 *
 * Resultaat: Laatste regel
 */

static long find_lastline(int wy, RECT *area, boolean *prev)
{
	long line;

	line = (area->y + area->h - wy);
	*prev = ((line % txt_font.ch) == 0) ? FALSE : TRUE;

	return ((line - 1) / txt_font.ch);
}

/*
 * Zoek de eerste kolom van een window, die zichtbaar is binnen
 * een rechthoek.
 *
 * Parameters:
 *
 * wx		- x coordinaat werkgebied window
 * area		- rechthoek
 * prev		- pointer naar een boolean, die aangeeft of een of twee
 *			  regels opnieuw getekend moeten worden.
 *
 * Resultaat: Eerste regel
 */

static int find_firstcolumn(int wx, RECT *area, boolean *prev)
{
	int column;

	column = (area->x - wx);
	*prev = ((column % txt_font.cw) == 0) ? FALSE : TRUE;

	return (column / txt_font.cw);
}

/*
 * Zoek de laatste kolom van een window, die zichtbaar is binnen
 * een rechthoek.
 *
 * Parameters:
 *
 * wx		- x coordinaat werkgebied window
 * area		- rechthoek
 * prev		- pointer naar een boolean, die aangeeft of een of twee
 *			  regels opnieuw getekend moeten worden.
 *
 * Resultaat: Eerste regel
 */

static int find_lastcolumn(int wx, RECT *area, boolean *prev)
{
	int column;

	column = (area->x + area->w - wx);
	*prev = ((column % txt_font.cw) == 0) ? FALSE : TRUE;

	return ((column - 1) / txt_font.cw);
}

/*
 * Teken een kolom van een window opnieuw.
 *
 * Parameters:
 *
 * w		- pointer naar window
 * column	- kolom
 * area		- clipping rechthoek
 * work		- werkgebied window
 */

static void txt_prtcolumn(TXT_WINDOW *w, int column, RECT *area, RECT *work)
{
	int i;

	for (i = 0; i < w->rows; i++)
		txt_prtchar(w, column, w->py + i, area, work);
}

/*
 * Functie om een tekstwindow een regel te scrollen.
 *
 * Parameters:
 *
 * w		- Pointer naar window
 * type		- geeft richting van scrollen aan
 */

static void w_scroll(TXT_WINDOW *w, int type)
{
	RECT work, r, in, src, dest;
	long line;
	int column, wx, wy;
	boolean prev;

	switch (type)
	{
	case WA_UPLINE:
		if (w->py <= 0)
			return;
		w->py -= 1;
		break;
	case WA_DNLINE:
		if ((w->py + w->nrows) >= w->nlines)
			return;
		w->py += 1;
		break;
	case WA_LFLINE:
		if (w->px <= 0)
			return;
		w->px -= 1;
		break;
	case WA_RTLINE:
		if ((w->px + w->ncolumns) >= txt_width(w))
			return;
		w->px += 1;
		break;
	default:
		return;
	}

	xw_get((WINDOW *) w, WF_WORKXYWH, &work);

	wx = work.x;
	wy = work.y;

	if (clip_desk(&work) == FALSE)
		return;

	xd_wdupdate(BEG_UPDATE);

	if ((type == WA_UPLINE) || (type == WA_DNLINE))
		set_vslpos(w);
	else
		set_hslpos(w);

	graf_mouse(M_OFF, NULL);
	xw_get((WINDOW *) w, WF_FIRSTXYWH, &r);

	set_txt_default(txt_font.id, txt_font.size);

	while ((r.w != 0) && (r.h != 0))
	{
		if (xd_rcintersect(&r, &work, &in) == TRUE)
		{
			xd_clip_on(&in);

			src = in;
			dest = in;

			if ((type == WA_UPLINE) || (type == WA_DNLINE))
			{
				if (type == WA_UPLINE)
				{
					dest.y += txt_font.ch;
					line = find_firstline(wy, &in, &prev);
				}
				else
				{
					src.y += txt_font.ch;
					line = find_lastline(wy, &in, &prev);
				}
				line += w->py;
				dest.h -= txt_font.ch;
				src.h -= txt_font.ch;
			}
			else
			{
				if (type == WA_LFLINE)
				{
					dest.x += txt_font.cw;
					column = find_firstcolumn(wx, &in, &prev);
				}
				else
				{
					src.x += txt_font.cw;
					column = find_lastcolumn(wx, &in, &prev);
				}
				column += w->px;
				dest.w -= txt_font.cw;
				src.w -= txt_font.cw;
			}

			if ((src.h > 0) && (src.w > 0))
				move_screen(&dest, &src);

			if ((type == WA_UPLINE) || (type == WA_DNLINE))
			{
				txt_prtline(w, line, &in, &work);
				if (prev == TRUE)
				{
					line += (type == WA_UPLINE) ? 1 : -1;
					txt_prtline(w, line, &in, &work);
				}
			}
			else
			{
				txt_prtcolumn(w, column, &in, &work);
				if (prev == TRUE)
				{
					column += (type == WA_LFLINE) ? 1 : -1;
					txt_prtcolumn(w, column, &in, &work);
				}
			}

			xd_clip_off();
		}
		xw_get((WINDOW *) w, WF_NEXTXYWH, &r);
	}

	graf_mouse(M_ON, NULL);
	xd_wdupdate(END_UPDATE);
}

/********************************************************************
 *																	*
 * Functies voor het afhandelen van selecties van een menupunt in	*
 * een window menu.													*
 *																	*
 ********************************************************************/

/*
 * Functie voor het updaten van het window menu van een tekstwindow.
 */

static void set_menu(TXT_WINDOW *w)
{
	xw_menu_icheck((WINDOW *) w, VMHEX, w->hexmode);
}

/*
 * Functie voor het instellen van de ASCII of de HEXMODE van een
 * window.
 */

static void txt_mode(TXT_WINDOW *w)
{
	if (w->hexmode == 0)
	{
		w->hexmode = 1;
		w->nlines = (w->size + 15L) / 16L;
	}
	else
	{
		w->hexmode = 0;
		w->nlines = w->tlines;
	}

	set_sliders(w);
	txt_draw(w, TRUE);
	set_menu(w);
}

/*
 * Functie voor het instellen van de tabultorgrootte van een
 * tekstwindow.
 */

static void txt_tabsize(TXT_WINDOW *w)
{
	int oldtab;

	oldtab = w->tabsize;

	itoa(w->tabsize, vtabsize, 10);

	if (xd_dialog(stabsize, VTABSIZE) == STOK)
	{
		if ((w->tabsize = atoi(vtabsize)) < 1)
			w->tabsize = 1;

		if (w->tabsize != oldtab)
			txt_draw(w, TRUE);
	}
}

/********************************************************************
 *																	*
 * Funktie voor het vrijgeven van al het geheugen gebruikt door een	*
 * tekstwindow.														*
 *																	*
 ********************************************************************/

static void txt_rem(TXT_WINDOW *w)
{
	if (w->lines != NULL)
		x_free(w->lines);
	if (w->buffer != NULL)
		x_free(w->buffer);
	free(w->name);

	w->winfo->used = FALSE;
	w->winfo->txt_window = NULL;
}

/********************************************************************
 *																	*
 * 'Object' functies voor tekstwindows.								*
 *																	*
 ********************************************************************/

#pragma warn -par

/*
 * Keyboard event handler voor tekstwindows.
 *
 * Parameters:
 *
 * w		- Pointer naar window
 * scancode	- Scancode van de ingedrukte toets
 * keystate	- Toestand van de SHIFT, CONTROL en ALTERNATE toets
 *
 * Resultaat: 0 - toets kon niet verwerkt worden
 *			  1 - toets kon verwerkt worden
 */

static int txt_hndlkey(WINDOW *w, int scancode, int keystate)
{
	long lines;
	int result = 1;

	switch (scancode)
	{
	case CURDOWN:
	case RETURN:
		w_scroll((TXT_WINDOW *) w, WA_DNLINE);
		break;
	case CURUP:
		w_scroll((TXT_WINDOW *) w, WA_UPLINE);
		break;
	case CURLEFT:
		w_scroll((TXT_WINDOW *) w, WA_LFLINE);
		break;
	case CURRIGHT:
		w_scroll((TXT_WINDOW *) w, WA_RTLINE);
		break;
	case PAGE_DOWN:				/* HR 240103: PgUp/PgDn keys on PC keyboards (Emulators and MILAN) */
	case SHFT_CURDOWN:
	case SPACE:
		w_pagedown((TXT_WINDOW *) w);
		break;
	case PAGE_UP:				/* HR 240103: PgUp/PgDn keys on PC keyboards (Emulators and MILAN) */
	case SHFT_CURUP:
		w_pageup((TXT_WINDOW *) w);
		break;
	case SHFT_CURLEFT:
		w_pageleft((TXT_WINDOW *) w);
		break;
	case SHFT_CURRIGHT:
		w_pageright((TXT_WINDOW *) w);
		break;
	case HOME:
		((TXT_WINDOW *) w)->px = 0;
		((TXT_WINDOW *) w)->py = 0;
		set_sliders((TXT_WINDOW *) w);
		txt_draw((TXT_WINDOW *) w, FALSE);
		break;
	case SHFT_HOME:
		((TXT_WINDOW *) w)->px = 0;
		lines = ((TXT_WINDOW *) w)->nlines;
		if (((TXT_WINDOW *) w)->nrows < lines)
		{
			((TXT_WINDOW *) w)->py = lines - ((TXT_WINDOW *) w)->nrows;
			set_sliders((TXT_WINDOW *) w);
			txt_draw((TXT_WINDOW *) w, FALSE);
		}
		break;
	default:
		switch (scancode & (XD_SCANCODE | XD_ALT | 0xDF))
		{
		case 'Q':
		case 'C':
		case ESCAPE:
			txt_closed(w);
			break;
		default :
			result = 0;
			break;
		}
		break;
	}

	return result;
}

/*
 * Button event handler voor tekstwindows.
 *
 * Parameters:
 *
 * w			- Pointer naar window
 * x			- x positie muis
 * y			- y positie muis
 * n			- aantal muisklikken
 * button_state	- Toestand van de muisknoppen
 * keystate		- Toestand van de SHIFT, CONTROL en ALTERNATE toets
 */

static void txt_hndlbutton(WINDOW *w, int x, int y, int n,
						   int button_state, int keystate)
{
}

#pragma warn .par

/*
 * Window redraw handler voor tekstwindows.
 *
 * Parameters:
 *
 * w			- Pointer naar window
 * area			- Deel van het window dat opnieuw getekend moet
 *				  worden
 */

static void txt_redraw(WINDOW *w, RECT *area)
{
	RECT r1, r2, in;

	r1 = *area;

	if (clip_desk(&r1) == FALSE)
		return;

	xd_wdupdate(BEG_UPDATE);
	graf_mouse(M_OFF, NULL);
	xw_get(w, WF_FIRSTXYWH, &r2);

	while ((r2.w != 0) && (r2.h != 0))
	{
		if (xd_rcintersect(&r1, &r2, &in) == TRUE)
		{
			xd_clip_on(&in);
			txt_prtlines((TXT_WINDOW *) w, &in);
			xd_clip_off();
		}

		xw_get(w, WF_NEXTXYWH, &r2);
	}

	graf_mouse(M_ON, NULL);
	xd_wdupdate(END_UPDATE);
}

/*
 * Window topped handler voor tekstwindows.
 *
 * Parameters:
 *
 * w			- Pointer naar window
 */

static void txt_topped(WINDOW *w)
{
	xw_set(w, WF_TOP);
}

#pragma warn -par

/*
 * Window closed handler voor tekstwindows.
 *
 * Parameters:
 *
 * w			- Pointer naar window
 */

void txt_closed(WINDOW *w)
{
	txt_rem((TXT_WINDOW *) w);
	xw_close(w);
	xw_delete(w);
}

#pragma warn .par

/*
 * Window fulled handler voor tekstwindows.
 *
 * Parameters:
 *
 * w			- Pointer naar window
 */

static void txt_fulled(WINDOW *w)
{
	WINFO *wd = ((TXT_WINDOW *) w)->winfo;
	RECT size;

	wd->flags.fulled = (wd->flags.fulled == 1) ? 0 : 1;
	txt_calcsize(((TXT_WINDOW *) w)->winfo, &size);
	xw_set(w, WF_CURRXYWH, &size);
	set_sliders((TXT_WINDOW *) w);
}

/*
 * Window arrowed handler voor tekstwindows.
 *
 * Parameters:
 *
 * w			- Pointer naar window
 */

static void txt_arrowed(WINDOW *w, int arrows)
{
	switch (arrows)
	{
	case WA_UPLINE:
	case WA_DNLINE:
	case WA_LFLINE:
	case WA_RTLINE:
		w_scroll((TXT_WINDOW *) w, arrows);
		break;
	case WA_UPPAGE:
		w_pageup((TXT_WINDOW *) w);
		break;
	case WA_DNPAGE:
		w_pagedown((TXT_WINDOW *) w);
		break;
	case WA_LFPAGE:
		w_pageleft((TXT_WINDOW *) w);
		break;
	case WA_RTPAGE:
		w_pageright((TXT_WINDOW *) w);
		break;
	}
}

/*
 * Window horizontal slider handler voor tekstwindows.
 *
 * Parameters:
 *
 * w			- Pointer naar window
 */

static void txt_hslider(WINDOW *w, int newpos)
{
	long h;
	int oldx;

	h = (long) (txt_width((TXT_WINDOW *) w) - ((TXT_WINDOW *) w)->ncolumns);
	oldx = ((TXT_WINDOW *) w)->px;
	((TXT_WINDOW *) w)->px = (int) (((long) newpos * h) / 1000L);
	if (oldx != ((TXT_WINDOW *) w)->px)
	{
		set_hslpos((TXT_WINDOW *) w);
		txt_draw((TXT_WINDOW *) w, FALSE);
	}
}

/*
 * Window vertical slider handler voor tekstwindows.
 *
 * Parameters:
 *
 * w			- Pointer naar window
 */

static void txt_vslider(WINDOW *w, int newpos)
{
	long h, oldy;

	h = (long) (((TXT_WINDOW *) w)->nlines - ((TXT_WINDOW *) w)->nrows);
	oldy = ((TXT_WINDOW *) w)->py;
	((TXT_WINDOW *) w)->py = (((long) newpos * h) / 1000L);
	if (oldy != ((TXT_WINDOW *) w)->py)
	{
		set_vslpos((TXT_WINDOW *) w);
		txt_draw((TXT_WINDOW *) w, FALSE);
	}
}

/*
 * Window sized handler voor tekstwindows.
 *
 * Parameters:
 *
 * w			- Pointer naar window
 */

static void txt_sized(WINDOW *w, RECT *newsize)
{
	RECT area;
	int old_w, old_h;

	xw_get(w, WF_WORKXYWH, &area);

	old_w = area.w;
	old_h = area.h;

	txt_moved(w, newsize);

	xw_get(w, WF_WORKXYWH, &area);

	if ((area.w > old_w) || (area.h > old_h))
		txt_draw((TXT_WINDOW *) w, TRUE);

	set_sliders((TXT_WINDOW *) w);
}

/*
 * Window moved handler voor tekstwindows.
 *
 * Parameters:
 *
 * w			- Pointer naar window
 */

static void txt_moved(WINDOW *w, RECT *newpos)
{
	WINFO *wd = ((TXT_WINDOW *) w)->winfo;
	RECT size;

	txt_wsize((TXT_WINDOW *) w, newpos, &size);
	wd->flags.fulled = 0;
	xw_set(w, WF_CURRXYWH, &size);
	txt_set_defsize(wd);
}

/*
 * Window menu handler voor tekstwindows.
 *
 * Parameters:
 *
 * w			- Pointer naar window
 * title		- Menutitel die geselekteerd is
 * item			- Menupunt dat geselekteerd is
 */

static void txt_hndlmenu(WINDOW *w, int title, int item)
{
	switch (item)
	{
	case VMTAB:
		txt_tabsize((TXT_WINDOW *) w);
		break;
	case VMHEX:
		txt_mode((TXT_WINDOW *) w);
		break;
	}

	xw_menu_tnormal(w, title, 1);
}

/*
 * Functie wordt aangeroepen als deze het bovenste van de applicatie
 * is geworden.
 *
 * Parameters:
 *
 * w		- Pointer naar window
 */

#pragma warn -par

static void txt_top(WINDOW *w)
{
	int n = 0;
	WINDOW *h = xw_first();

	while (h != NULL)
	{
		n++;
		h = xw_next();
	}

	menu_ienable(menu, MCLOSE, 1);
	menu_ienable(menu, MCLOSEW, 1);
	menu_ienable(menu, MNEWDIR, 0);
	menu_ienable(menu, MSELALL, 0);
	menu_ienable(menu, MSETMASK, 0);
	menu_ienable(menu, MCYCLE, (n > 1) ? 1 : 0);
}

#pragma warn .par

/********************************************************************
 *																	*
 * Funkties voor het laden van files in een window.					*
 *																	*
 ********************************************************************/

/* Funkties voor het tellen van de regels van een file */

static long count_lines(char *buffer, long length)
{
	char cr = '\n', *s = buffer;
	long cnt = length, n = 1;

	do
	{
		if (*s++ == cr)
			n++;
	}
	while (--cnt > 0);

	return n;
}

/* Funktie voor het maken van een lijst met pointers naar het begin
   van elke regel in de file. */

static void set_lines(char *buffer, char **lines, long length)
{
	char cr = '\n', *s = buffer, **p = lines;
	long cnt = length;

	*p++ = s;
	do
	{
		if (*s++ == cr)
			*p++ = s;
	}
	while (--cnt > 0);
}

static boolean isascii(char c)
{
	if (((c >= ' ') && (c <= '~')) || (c == '\t') || (c == '\r') ||
		(c == '\n') || (c == 'ÿ'))
		return TRUE;
	else
		return FALSE;
}

/* Funktie voor het laden van een file in het geheugen.
   Bij een leesfout wordt een waarde ongelijk 0 terug gegeven.
   Alle buffers zijn dan vrijgegeven. */

static int txt_read(TXT_WINDOW *w, boolean setmode)
{
	int handle, error;
	long read, length, flength;
	XATTR attr;

	graf_mouse(HOURGLASS, NULL);

	if ((error = (int) x_attr(0, w->name, &attr)) == 0)
	{
		flength = attr.size;

		if ((handle = x_open(w->name, O_DENYW | O_RDONLY)) >= 0)
		{
			char *msg_endfile;

			rsrc_gaddr(R_STRING, MENDFILE, &msg_endfile);

			length = flength + strlen(msg_endfile) + 1;
			if ((w->buffer = x_alloc(length + 1)) == NULL)
				error = ENSMEM;
			else
			{
				read = x_read(handle, flength, w->buffer);

				if (read == flength)
				{
					strcpy(&(w->buffer[flength]), msg_endfile);
					w->tlines = count_lines(w->buffer, flength + 2);
					if ((w->lines = x_alloc(w->tlines * sizeof(char *))) != NULL)
					{
						w->size = flength;
						set_lines(w->buffer, w->lines, flength + 2);
					}
					else
					{
						error = ENSMEM;
						x_free(w->buffer);
					}
				}
				else
				{
					error = (read < 0) ? (int) read : EREAD;
					x_free(w->buffer);
				}
			}
			x_close(handle);
		}
		else
			error = handle;
	}

	graf_mouse(ARROW, NULL);

	if (error != 0)
	{
		w->lines = NULL;
		w->buffer = NULL;
	}
	else
	{
		int pl;
		const char *h;

		if (setmode == TRUE)
		{
			char *b;
			int i, e, n = 0;		/* HR 151102: reserve 'end' for language */

			b = w->buffer;
			e = (int) min(w->size, 256L);

			for (i = 0; i < e; i++)
			{
				if (isascii(b[i]) != FALSE)
					n++;
			}

			n = (n > 0) ? (n * 100) / e : 100;

			w->hexmode = (n > ASCII_PERC) ? 0 : 1;

			set_menu(w);
		}

		if (w->hexmode == 0)
			w->nlines = w->tlines;
		else
			w->nlines = (w->size + 15) / 16;

		if ((w->py + w->nrows) > w->nlines)
			w->py = max(w->nlines - w->nrows, 0);

		if ((pl = (int) strlen(w->name)) < 70)
			h = w->name;
		else
		{
			h = w->name + (pl - 70);
			h = strchr(h, '\\') + 1;
		}
		strcpy(w->title, h);
		xw_set((WINDOW *) w, WF_NAME, h);
		set_sliders(w);
	}

	return error;
}

/********************************************************************
 *																	*
 * Funkties voor het openen van een tekst window.					*
 *																	*
 ********************************************************************/

/* Open een window. file moet een gemallocde string zijn. Deze mag
   niet vrijgegeven worden door de aanroepende funktie. Bij een fout
   wordt de string vrijgegeven. */

static WINDOW *txt_do_open(WINFO *info, const char *file, int px,
						   long py, int tabsize, boolean hexmode,
						   boolean setmode, int *error)
{
	TXT_WINDOW *w;
	RECT size;
	int errcode;

	if ((w = (TXT_WINDOW *)xw_create(TEXT_WIND, &txt_functions, TFLAGS, &tmax,
									 sizeof(TXT_WINDOW), viewmenu, &errcode)) == NULL)
	{
		if (errcode == XDNMWINDOWS)
		{
			alert_printf(1, MTMWIND);
			*error = ERROR;
		}
		else if (errcode == XDNSMEM)
			*error = ENSMEM;
		else
			*error = ERROR;

		free(file);

		return NULL;
	}

	info->txt_window = w;
	w->px = px;
	w->py = py;
	w->name = file;
	w->buffer = NULL;
	w->lines = NULL;
	w->nlines = 0L;
	w->tabsize = tabsize;
	w->hexmode = hexmode;
	w->winfo = info;

	txt_calcsize(info, &size);

	graf_mouse(HOURGLASS, NULL);
	*error = txt_read(w, setmode);
	graf_mouse(ARROW, NULL);

	if (*error != 0)
	{
		txt_rem(w);
		xw_delete((WINDOW *) w);		/* HR 131202: after txt_rem (MP) */
		return NULL;
	}
	else
	{
		xw_open((WINDOW *) w, &size);
		info->used = TRUE;
		return (WINDOW *) w;
	}
}

#pragma warn -par

boolean txt_add_window(WINDOW *w, int item, int kstate)
{
	int j = 0, error;
	const char *file;

	while ((j < MAXWINDOWS - 1) && (textwindows[j].used != FALSE))
		j++;

	if (textwindows[j].used == TRUE)
	{
		alert_printf(1, MTMWIND);
		return FALSE;
	}

	if ((file = itm_fullname(w, item)) == NULL)
		return FALSE;

	if (txt_do_open(&textwindows[j], file, 0, 0, options.tabsize, FALSE, TRUE, &error) == NULL)
	{
		xform_error(error);
		return FALSE;
	}

	return TRUE;
}

#pragma warn .par

/********************************************************************
 *																	*
 * Functies voor het veranderen van het window font.				*
 *																	*
 ********************************************************************/

void txt_setfont(void)
{
	int i;
	WINFO *wd;
	RECT work;

	if (fnt_dialog(DTVFONT, &txt_font, FALSE) == TRUE)
	{
		for (i = 0; i < MAXWINDOWS; i++)
		{
			wd = &textwindows[i];
			if (wd->used != FALSE)
			{
				xw_get((WINDOW *) wd->txt_window, WF_WORKXYWH, &work);
				txt_calc_rc(wd->txt_window, &work);
				set_sliders(wd->txt_window);
				txt_draw(wd->txt_window, TRUE);
			}
		}
	}
}

/********************************************************************
 *																	*
 * Funkties voor het initialisatie, laden en opslaan.				*
 *																	*
 ********************************************************************/

void txt_init(void)
{
	RECT work;

	xw_calc(WC_WORK, TFLAGS, &screen_info.dsk, &work, viewmenu);
	tmax.x = screen_info.dsk.x;
	tmax.y = screen_info.dsk.y;
	tmax.w = work.w - (work.w % screen_info.fnt_w);
	tmax.h = work.h - (work.h % screen_info.fnt_h);
}

void txt_default(void)
{
	int i;

	txt_font = def_font;

	for (i = 0; i < MAXWINDOWS; i++)
	{
		textwindows[i].x = (i + 1) * screen_info.fnt_w - screen_info.dsk.x;
		textwindows[i].y = screen_info.dsk.y + i * screen_info.fnt_h - screen_info.dsk.y;
		textwindows[i].w = (screen_info.dsk.w * 9) / (10 * screen_info.fnt_w);
		textwindows[i].h = (screen_info.dsk.h * 8) / (10 * screen_info.fnt_h);
		textwindows[i].flags.fulled = 0;
		textwindows[i].used = FALSE;
	}
}

int txt_load(XFILE *file)
{
	int i, n;
	SINFO1 sinfo;
	WINFO *w;
	long s;
	FDATA font;

	if (options.version < 0x125)
		txt_font = def_font;
	else
	{
		if ((s = x_fread(file, &font, sizeof(FDATA))) != sizeof(FDATA))
			return (s < 0) ? (int) s : EEOF;
		fnt_setfont(font.id, font.size, &txt_font);
	}

	if (options.version == 0x119)
	{
		txt_default();
		n = 6;
	}
	else
		n = MAXWINDOWS;

	for (i = 0; i < n; i++)
	{
		w = &textwindows[i];

		if ((s = x_fread(file, &sinfo, sizeof(SINFO1))) != sizeof(SINFO1))
			return (s < 0) ? (int) s : EEOF;

		w->x = sinfo.x;
		w->y = sinfo.y;
		w->w = sinfo.w;
		w->h = sinfo.h;
		w->flags = sinfo.flags;
	}
	return 0;
}

int txt_save(XFILE *file)
{
	int i;
	SINFO1 sinfo;
	WINFO *w;
	long n;
	FDATA font;

	font.id = txt_font.id;
	font.size = txt_font.size;
	font.resvd1 = 0;
	font.resvd2 = 0;

	if ((n = x_fwrite(file, &font, sizeof(FDATA))) < 0)
		return (int) n;

	for (i = 0; i < MAXWINDOWS; i++)
	{
		w = &textwindows[i];

		sinfo.x = w->x;
		sinfo.y = w->y;
		sinfo.w = w->w;
		sinfo.h = w->h;
		sinfo.flags = w->flags;
		sinfo.resvd = 0;

		if ((n = x_fwrite(file, &sinfo, sizeof(SINFO1))) < 0)
			return (int) n;
	}

	return 0;
}

int txt_load_window(XFILE *file)
{
	SINFO2 sinfo;
	char *name;
	long n;
	int error;

	if ((n = x_fread(file, &sinfo, sizeof(SINFO2))) != sizeof(SINFO2))
		return (n < 0) ? (int) n : EEOF;

	if ((name = x_freadstr(file, NULL, sizeof(LNAME), &error)) == NULL)		/* HR 240103: max l */ /* HR 240203 */
		return error;

	if (txt_do_open(&textwindows[sinfo.index], name, sinfo.px, sinfo.py, sinfo.tabsize, sinfo.hexmode, FALSE, &error) == NULL)
	{
		if ((error == EPTHNF) || (error == EFILNF) || (error == ERROR))
			return 0;
		return error;
	}

	return 0;
}

int txt_save_window(XFILE *file, WINDOW *w)
{
	SINFO2 sinfo;
	TXT_WINDOW *tw;
	int i = 0;
	long n;

	while ((WINDOW *) textwindows[i].txt_window != w)
		i++;

	tw = textwindows[i].txt_window;

	sinfo.index = i;
	sinfo.px = tw->px;
	sinfo.py = tw->py;
	sinfo.resvd1 = 0;
	sinfo.resvd2 = 0;
	sinfo.hexmode = tw->hexmode;
	sinfo.resvd3 = 0;
	sinfo.tabsize = tw->tabsize;

	if ((n = x_fwrite(file, &sinfo, sizeof(SINFO2))) < 0)
		return (int) n;

	return x_fwritestr(file, tw->name);
}
