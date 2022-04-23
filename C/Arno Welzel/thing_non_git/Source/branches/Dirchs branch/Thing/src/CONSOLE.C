/**
 * Thing
 * Copyright (C) 1994-2012 Arno Welzel, Thomas Binder
 *
 * This program is free software: you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation, either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this program. If not, see
 * <http://www.gnu.org/licenses/>.
 *
 * @copyright  Arno Welzel, Thomas Binder 1994-2012
 * @author     Arno Welzel, Thomas Binder
 * @license    LGPL
 */

/*=========================================================================
 CONSOLE.C

 Thing
 Console-Fenster fr Single-TOS
 =========================================================================*/

#include "..\include\globdef.h"
#include "..\include\types.h"
#include "rsrc\thing_de.h"
#include "rsrc\thgtxtde.h"

/* Von Thomas Binder */

#define TPOS(x,y) con.buf\
    [(long)(x)+((long)(y)+\
    (long)con.tos2gem->text_offset+\
    (long)con.tos2gem->y_offset)*\
    (long)(con.tos2gem->x_size+1)+(long)con.xoff]
/* Wie oben, zur Bestimmung des Farbwertes des Zeichens */
#define CPOS(x,y) TPOS(x,(y)+con.tos2gem->max_lines)

/*-------------------------------------------------------------------------
 cw_...()

 Routinen fr das Console-Fenster (Redraw etc.)
 -------------------------------------------------------------------------*/
/**
 *
 */
void cw_update(struct wininfo *win) {
	con.tos2gem->x_off = win->work.x;
	con.tos2gem->y_off = win->work.y;
}

/**
 *
 */
#pragma warn -par
void cw_prepare(struct wininfo *win) {
	vsl_color(con.vdi_handle, 1);
	vsl_type(con.vdi_handle, 1);
	vsl_width(con.vdi_handle, 1);
	vswr_mode(con.vdi_handle, MD_REPLACE);
	vst_color(con.tos2gem->vdi_handle, 1);
}
#pragma warn .par

/* Funktion basiert auf Beispielprogramm von Thomas Binder */
/**
 *
 */
void cw_redraw(struct wininfo *win, RECT *area) {
	int x1, x2, y1, y2, pxy[4], start, i, j, k;
	RECT to_draw;
	char temp[513], remember;
	unsigned char color;

	/* Sichtbaren Bereich ermitteln */
	x1 = (area->x - con.tos2gem->x_off) / con.tos2gem->char_w;
	if (x1 < 0)
		x1 = 0;
	x2 = (area->x + area->w - 1 - con.tos2gem->x_off) / con.tos2gem->char_w;
	if (x2 >= con.tos2gem->x_vis)
		x2 = con.tos2gem->x_vis - 1;
	y1 = (area->y - con.tos2gem->y_off) / con.tos2gem->char_h;
	if (y1 < 0)
		y1 = 0;
	y2 = (area->y + area->h - 1 - con.tos2gem->y_off) / con.tos2gem->char_h;
	if (y2 >= con.tos2gem->y_vis)
		y2 = con.tos2gem->y_vis;
	to_draw.x = con.tos2gem->x_off + x1 * con.tos2gem->char_w;
	to_draw.y = con.tos2gem->y_off + y1 * con.tos2gem->char_h;
	to_draw.w = (x2 - x1 + 1) * con.tos2gem->char_w;
	to_draw.h = (y2 - y1 + 1) * con.tos2gem->char_h;

	rc_intersect(area, &to_draw);
	pxy[0] = to_draw.x;
	pxy[1] = to_draw.y;
	pxy[2] = pxy[0] + to_draw.w - 1;
	pxy[3] = pxy[1] + to_draw.h - 1;
	vs_clip(con.vdi_handle, 1, pxy);

	for (i = y1; i <= y2; i++) {
		strncpy(temp, &TPOS(x1,i), x2 - x1 + 1);
		temp[x2 - x1 + 1] = 0;

		/* Farbsupport aktiv? */
		if (con.tos2gem->color) {
			for (k = x1 + 1; k <= (x2 + 1); k++) {
				start = k - 1, color = CPOS(start,i);
				for (j = k; j <= x2; j++) {
					if (CPOS(j,i) != color)
						break;
				}
				k = j;

				remember = temp[j - x1];
				temp[j - x1] = 0;
				vswr_mode(con.vdi_handle, MD_TRANS);
				vst_color(con.vdi_handle, color & 0x0f);
				v_gtext(con.vdi_handle, con.tos2gem->x_off + start
						* con.tos2gem->char_w, con.tos2gem->y_off + i
						* con.tos2gem->char_h, &temp[start - x1]);
				vswr_mode(con.vdi_handle, MD_ERASE);
				vst_color(con.tos2gem->vdi_handle, color >> 4);
				v_gtext(con.vdi_handle, con.tos2gem->x_off + start
						* con.tos2gem->char_w, con.tos2gem->y_off + i
						* con.tos2gem->char_h, &temp[start - x1]);
				temp[j - x1] = remember;
			}
		} else { /* Kein Farbsupport - nur Text einfarbig ausgeben */
			v_gtext(con.vdi_handle, con.tos2gem->x_off + x1
					* con.tos2gem->char_w, con.tos2gem->y_off + i
					* con.tos2gem->char_h, temp);
		}
		/* Rand des Terminalbereichs markieren */
		if (i + con.tos2gem->text_offset + con.tos2gem->y_offset + 1
				== con.tos2gem->text_offset) {
			pxy[0] = win->work.x;
			pxy[2] = pxy[0] + win->work.w - 1;
			pxy[1] = pxy[3] = win->work.y + (i + 1) * con.tos2gem->char_h - 1;
			vswr_mode(con.vdi_handle, MD_XOR);
			v_pline(con.vdi_handle, 2, pxy);
			vswr_mode(con.vdi_handle, MD_REPLACE);
		}
	}
	vs_clip(con.vdi_handle, 0, pxy);
}

/**
 *
 */
void cw_slide(struct wininfo *win, int mode, int h, int v) {
	long hsize, vsize, hpos, vpos;
	int xvis, yvis, xsize, ysize, xpos, ypos;
	int dx, dy, xposn, yposn;

	xvis = con.tos2gem->x_vis;
	xsize = con.tos2gem->x_size;
	xpos = con.xoff;
	yvis = con.tos2gem->y_vis;
	ysize = con.tos2gem->max_lines;
	ypos = con.tos2gem->y_offset + con.tos2gem->text_offset;

	switch (mode) {
	case S_INIT:
		/* Gr”že der Slider berechnen */
		hsize = (long) xvis * 1000L / (long) xsize;
		vsize = (long) yvis * 1000L / (long) ysize;
		hsize = min(hsize, 1000L);
		vsize = min(vsize, 1000L);
		/* Slider-Positionen berechnen */
		if (xsize > xvis)
			hpos = (long) xpos * 1000L / (long) (xsize - xvis);
		else
			hpos = 0;
		if (ysize > yvis)
			vpos = (long) ypos * 1000L / (long) (ysize - yvis);
		else
			vpos = 0;
		/* Slider setzen */
		if (con.win.flags & HSLIDE) {
			wind_set(win->handle, WF_HSLIDE, (int) hpos);
			wind_set(win->handle, WF_HSLSIZE, (int) hsize);
		}
		if (con.win.flags & VSLIDE) {
			wind_set(win->handle, WF_VSLIDE, (int) vpos);
			wind_set(win->handle, WF_VSLSIZE, (int) vsize);
		}
		break;
	case S_ABS:
		/* Position auf Offset umrechnen */
		dx = dy = 0;
		if (h != -1 && xsize > xvis) {
			xposn = (int) ((long) (xsize - xvis) * (long) h / 1000L);
			dx = xpos - xposn;
		} else
			xposn = xpos;
		if (v != -1 && ysize > yvis) {
			yposn = (int) ((long) (ysize - yvis) * (long) v / 1000L);
			dy = ypos - yposn;
		} else
			yposn = ypos;
		if (dx != 0 || dy != 0) {
			con.xoff = xposn;
			con.tos2gem->y_offset = yposn - con.tos2gem->text_offset;
			win_slide(win, S_INIT, 0, 0);
			win_scroll(win, dx * con.cw, dy * con.ch);
		}
		break;
	case S_REL:
		dx = 0;
		dy = 0;
		switch (h) {
		case -1:
			dx = -1;
			break;
		case 1:
			dx = 1;
			break;
		case -2:
			dx = -xvis;
			break;
		case 2:
			dx = xvis;
			break;
		}
		switch (v) {
		case -1:
			dy = -1;
			break;
		case 1:
			dy = 1;
			break;
		case -2:
			dy = -yvis;
			break;
		case 2:
			dy = yvis;
			break;
		}
		cw_slide1: xposn = xpos + dx;
		yposn = ypos + dy;
		if (xposn < 0)
			xposn = 0;
		if (xposn > xsize - xvis)
			xposn = xsize - xvis;
		if (yposn < 0)
			yposn = 0;
		if (yposn > ysize - yvis)
			yposn = ysize - yvis;
		dx = xpos - xposn;
		dy = ypos - yposn;
		if (dx != 0 || dy != 0) {
			con.xoff = xposn;
			con.tos2gem->y_offset = yposn - con.tos2gem->text_offset;
			win_slide(win, S_INIT, 0, 0);
			win_scroll(win, dx * con.cw, dy * con.ch);
		}
		break;
	case S_PABS:
		dx = -(h / con.cw);
		if (h != 0 && dx == 0) {
			if (h < 0)
				dx = 1;
			else
				dx = -1;
		}
		dy = -(v / con.ch);
		if (v != 0 && dy == 0) {
			if (v < 0)
				dy = 1;
			else
				dy = -1;
		}
		goto cw_slide1;
	}
}

/*-------------------------------------------------------------------------
 cwin_cls()

 Console-Buffer l”schen
 -------------------------------------------------------------------------*/
/**
 *
 */
void cwin_cls(void) {
	long bsize;
	int i;

	bsize = (long) (con.col + 1) * (long) (con.line + con.hist);
	/* Textseite initialisieren */
	memset(con.buf, 32, bsize);
	for (i = 0; i < (con.line + con.hist); i++)
		con.buf[(long) con.col + (long) i * (long) (con.col + 1)] = 0;
	/* Attributseite initialisieren */
	memset(con.buf + bsize, 0x01, bsize);
}

/*-------------------------------------------------------------------------
 cwin_init()

 Console initialisieren (Buffer loeschen etc.)
 -------------------------------------------------------------------------*/
/**
 *
 */
int cwin_init(void) {
	long bsize;
	char *p;

	/* LINES/COLUMNS abfragen */
	p = getenv("LINES");
	if (p)
		con.line = atoi(p);
	else
		con.line = 25;
	if (con.line < 1)
		con.line = 25;
	p = getenv("COLUMNS");
	if (p)
		con.col = atoi(p);
	else
		con.col = 80;
	if (con.col < 1)
		con.col = 80;
	if (con.col > 512)
		con.col = 512;

	con.xoff = 0;
	con.tmp = 0L;
	bsize = (long) (con.col + 1) * (long) (con.line + con.hist);
	con.buf = pmalloc(bsize * 2L);
	if (!con.buf) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return (0);
	}

	/* Buffer initialisieren */
	cwin_cls();

	/* Fensterparameter */
	con.win.class=WCCON;
	con.win.flags = 0;
	if (con.flags & 0x1)
		con.win.flags |= NAME | CLOSER | MOVER | FULLER;
	if (con.flags & 0x2)
		con.win.flags |= SIZER | UPARROW | DNARROW | VSLIDE;
	if (con.flags & 0x4)
		con.win.flags |= LFARROW | RTARROW | HSLIDE;
	if (tb.sys & SY_ICONIFY)
		con.win.flags |= SMALLER;
	if (tb.sys & SY_MAGX)
		con.win.flags |= BACKDROP;

	con.win.state = WSDESKSIZE;
	strcpy(con.win.name, rs_frstr[TXCONTITLE]);
	con.win.update = cw_update;
	con.win.prepare = cw_prepare;
	con.win.redraw = cw_redraw;
	con.win.slide = cw_slide;
	con.win.ictree = rs_trindex[ICONCON];

	return (1);
}

/*-------------------------------------------------------------------------
 cwin_exit()
 
 Buffer der Console freigeben etc.
 -------------------------------------------------------------------------*/
/**
 *
 */
void cwin_exit(void) {
	if (con.buf) {
		pfree(con.buf);
		con.buf = 0L;
	}
}

/*-------------------------------------------------------------------------
 cwin_attr()

 Setzen des Fonts und Berechnen der Fenstergr”že
 -------------------------------------------------------------------------*/
/**
 *
 */
void cwin_attr(void) {
	int dummy, x, y, w, h, cx, cy, cw, ch;
	int columns, lines, mcol, mlin, max, draw;

	/* Attribute setzen */
	vst_font(con.vdi_handle, con.font.id);
	if (con.font.size < 0)
		vst_height(con.vdi_handle, -con.font.size, &dummy, &dummy, &con.cw, &con.ch);
	else
		vst_point(con.vdi_handle, con.font.size, &dummy, &dummy, &con.cw, &con.ch);
	vst_alignment(con.vdi_handle, 0, 5, &dummy, &dummy);

	/* Maximale Zeilen/Spalten auf dem Desktop ermitteln */
	wind_calc(WC_WORK, con.win.flags, tb.desk.x, tb.desk.y, tb.desk.w,
			tb.desk.h, &x, &y, &w, &h);
	mlin = h / con.ch;
	mcol = w / con.cw;

	/* Anzahl darstellbarer Zeilen/Spalten ermitteln */
	wind_calc(WC_WORK, con.win.flags, con.win.curr.x, con.win.curr.y,
			con.win.curr.w, con.win.curr.h, &x, &y, &w, &h);

	columns = w / con.cw;
	if (w - columns * con.cw > 0)
		columns++;
	lines = h / con.ch;
	if (h - lines * con.ch > 0)
		lines++;
	if (lines > mlin)
		lines = mlin;
	if (columns > mcol)
		columns = mcol;
	if (lines > con.line)
		lines = con.line;
	if (columns > con.col)
		columns = con.col;

	/* Begrenzung auf sichtbaren Ausschnitt und ggf. Redraw vormerken */
	draw = 0;

	max = con.col - columns;
	if (con.xoff > max) {
		con.xoff = max;
		draw = 1;
	}

	max = con.tos2gem->max_lines - lines;
	if (con.tos2gem->y_offset + con.tos2gem->text_offset > max) {
		con.tos2gem->y_offset = max - con.tos2gem->text_offset;
		draw = 1;
	}

	/* Fenstergr”že an die ermittelten Werte anpassen */
	w = columns * con.cw;
	h = lines * con.ch;
	wind_calc(WC_BORDER, con.win.flags, x, y, w, h, &cx, &cy, &cw, &ch);

	/* Werte eintragen */
	con.win.curr.x = cx;
	con.win.curr.y = cy;
	con.win.curr.w = cw;
	con.win.curr.h = ch;
	wind_calc(WC_WORK, con.win.flags, cx, cy, cw, ch, &con.win.work.x,
			&con.win.work.y, &con.win.work.w, &con.win.work.h);

	/* Ggf. Redraw */
	if (draw && con.win.state & WSOPEN) {
		win_redraw(&con.win, tb.desk.x, tb.desk.y, tb.desk.w, tb.desk.h);
		win_slide(&con.win, S_INIT, 0, 0);
	}

	/* Ermittelte Parameter an TOS2GEM weitergeben */
	con.tos2gem->text_buffer = con.buf;
	con.tos2gem->max_lines = con.line + con.hist;
	con.tos2gem->x_size = con.col;
	con.tos2gem->y_size = con.line;
	con.tos2gem->x_vis = columns;
	con.tos2gem->y_vis = lines;
	con.tos2gem->x_off = con.win.work.x;
	con.tos2gem->y_off = con.win.work.y;
	con.tos2gem->char_w = con.cw;
	con.tos2gem->char_h = con.ch;
	con.tos2gem->vdi_handle = con.vdi_handle;
	con.tos2gem->cursor_handle = con.vdi_chandle;

	if (con.buffer) {
		/* Je nach Voreinstellung und TOS2GEM-Version Timer- oder
		 Size-Bufferung verwenden */
		if (con.buffer == 2 && con.tos2gem->date >= 7851)
			con.tos2gem->buffer_output = -(con.buftime / 5);
		else
			con.tos2gem->buffer_output = (lines / 4) * columns;
	} else
		con.tos2gem->buffer_output = 0;

	/* Farbsupport */
	if (con.tos2gem->date >= 7813)
		con.tos2gem->color = con.color;
	else
		con.tos2gem->color = 0;

	/* Neue Gr”že setzen und Slider aktualisieren */
	if (con.win.state & WSOPEN) {
		wind_set(con.win.handle, WF_CURRXYWH, cx, cy, cw, ch);
		win_slide(&con.win, S_INIT, 0, 0);
	}
}

/*-------------------------------------------------------------------------
 cwin_open()

 Console-Fenster ”ffnen. Das Fenster wird immer so ge”ffnet, dass es
 vollst„ndig sichtbar ist. Ist es bereits offen, wird es nur in den
 Vordergrund geholt
 -------------------------------------------------------------------------*/
/**
 *
 */
int cwin_open(void) {
	long bsize;
	int work_in[11], work_out[57];
	int dummy;
	int i, toff;

	/* Fenster schon auf? */
	if (con.win.state & WSOPEN) {
		if (con.win.state & WSICON)
			win_unicon(&con.win, con.win.save.x, con.win.save.y,
					con.win.save.w, con.win.save.h);
		win_top(&con.win);
		return (1);
	}

	/* Buffer vorhanden? */
	if (!con.buf) {
		/* Nein - dann nochmal probieren */
		cwin_init();
		if (!con.buf)
			return (0); /* Es hilft alles nichts :( */
	}

	/* TOS2GEM vorhanden? */
	if (!getCookie('T2GM', (long *) &con.tos2gem))
		return (-1);
	if (!con.tos2gem)
		return (-1);

	/* TOS2GEM reservieren */
	if (!con.tos2gem->reserve())
		return (0); /* Bei Fehler raus */

	/* Eigene Workstation fuer TOS2GEM einrichten */
	for (i = 0; i < 10; i++)
		work_in[i] = 1;
	work_in[10] = 2;
	con.vdi_handle = graf_handle(&dummy, &dummy, &dummy, &dummy);
	_v_opnvwk(work_in, &con.vdi_handle, work_out);
	if (!con.vdi_handle)
		return (0);
	if (tb.gdos)
		vst_load_fonts(con.vdi_handle, 0);

	for (i = 0; i < 10; i++)
		work_in[i] = 1;
	work_in[10] = 2;
	con.vdi_chandle = graf_handle(&dummy, &dummy, &dummy, &dummy);
	_v_opnvwk(work_in, &con.vdi_chandle, work_out);

	/* Font setzen und Fenstergroessee berechnen */
	cwin_attr();

	/* Fenster einrichten */
	if (!win_open(&con.win, 0)) {
		if (tb.gdos)
			vst_unload_fonts(con.vdi_handle, 0);
		v_clsvwk(con.vdi_handle);
		if (con.vdi_chandle)
			v_clsvwk(con.vdi_chandle);
		return (0);
	}
	win_open(&con.win, 1);

	/* TOS2GEM initialisieren */
	wind_update( BEG_UPDATE);
	graf_mouse(M_OFF, 0L);

	/* Wenn moeglich, Inhalt sichern */
	bsize = (long) (con.col + 1) * (long) (con.line + con.hist) * 2L;
	con.tmp = pmalloc(bsize);
	if (con.tmp) {
		memcpy(con.tmp, con.buf, bsize); /* Inhalt sichern */
		toff = con.tos2gem->text_offset;
	}

	for (i = 0; i < RESERVED_SIZE; i++)
		con.tos2gem->reserved[i] = 0;
	if (!con.tos2gem->init()) {
		con.tos2gem->deinit();
		win_close(&con.win);
		if (tb.gdos)
			vst_unload_fonts(con.vdi_handle, 0);
		v_clsvwk(con.vdi_handle);
		if (con.vdi_chandle)
			v_clsvwk(con.vdi_chandle);
		return (0);
	}
	con.tos2gem->switch_output(); /* Ausgabeumleitung abschalten */
	con.xoff = 0;

	/* Wenn moeglich, gesicherten Inhalt wiederherstellen */
	if (con.tmp) {
		con.tos2gem->text_offset = toff;
		memcpy(con.buf, con.tmp, bsize); /* Inhalt wiederherstellen */
		pfree(con.tmp);
		con.tmp = 0L;
	}
	win_slide(&con.win, S_INIT, 0, 0);
	graf_mouse(M_ON, 0L);
	wind_update(END_UPDATE);

	return (1);
}

/**
 * Console-Fenster an einen geaenderten Zeichensatz anpassen.
 */
void cwin_update(void) {
	con.win.state &= ~WSFULL;
	cwin_attr();
	win_redraw(&con.win, tb.desk.x, tb.desk.y, tb.desk.w, tb.desk.h);
	win_slide(&con.win, S_INIT, 0, 0);
}

/**
 * Console-Fenster schliessen.
 */
void cwin_close(void) {
	int whandle;

	con.tos2gem->deinit();
	win_close(&con.win);
	if (tb.gdos)
		vst_unload_fonts(con.vdi_handle, 0);
	v_clsvwk(con.vdi_handle);
	if (con.vdi_chandle)
		v_clsvwk(con.vdi_chandle);

	/* Aktives Fenster ermitteln */
	get_twin(&whandle);
	tb.topwin = win_getwinfo(whandle);
	win_newtop(tb.topwin);
}

/**
 * Ein-/Ausgabeumleitung in das Console-Fenster starten.
 */
void cwin_startio(void) {
	int x, y, w, h, d;

	/* Bei Bedarf Fenster un-ikonifizieren */
	if (con.win.state & WSICON)
		win_unicon(&con.win, con.win.save.x, con.win.save.y, con.win.save.w,
				con.win.save.h);

	/* Ggf. Fenster-Arbeitsbereich vorher auf Desktop begrenzen */
	wind_calc(WC_WORK, con.win.flags, con.win.curr.x, con.win.curr.y,
			con.win.curr.w, con.win.curr.h, &x, &y, &w, &h);
	if (x + w > tb.desk.x + tb.desk.w) {
		d = (tb.desk.x + tb.desk.w) - (x + w);
		x += d;
	}
	if (y + h > tb.desk.y + tb.desk.h) {
		d = (tb.desk.y + tb.desk.h) - (y + h);
		y += d;
	}
	wind_calc(WC_BORDER, con.win.flags, x, y, w, h, &con.win.curr.x,
			&con.win.curr.y, &con.win.curr.w, &con.win.curr.h);
	if (con.win.curr.x < tb.desk.x)
		con.win.curr.x = tb.desk.x;
	if (con.win.curr.y < tb.desk.y)
		con.win.curr.y = tb.desk.y;
	cwin_attr();
	graf_mouse(M_OFF, 0L);
	wind_update( BEG_UPDATE);
	wind_update( BEG_MCTRL);
	con.tos2gem->init();

	con.xoff = 0;
}

/**
 * Ein-/Ausgabeumleitung in das Console-Fenster beeenden.
 */
void cwin_endio(void) {
	con.tos2gem->switch_output();
	win_slide(&con.win, S_INIT, 0, 0);
	wind_update( END_MCTRL);
	wind_update( END_UPDATE);
	graf_mouse(M_ON, 0L);
}
