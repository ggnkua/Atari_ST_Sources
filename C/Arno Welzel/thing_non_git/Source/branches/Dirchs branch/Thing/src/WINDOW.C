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
 WINDOW.C

 Thing
 Fenster allgemein
 =========================================================================*/

#include "..\include\globdef.h"
#include "..\include\types.h"
#include "rsrc\thing_de.h"
#include "rsrc\thgtxtde.h"
#include <math.h>

static void wd_ficon(int x, int y, int iw, int ih);
static void draw_minicicon(ICONIMG *ic, int *pxy, int sel);
static void winRedraw(struct wininfo *win, int type, RECT *area);
static void winSlide(struct wininfo *win, int mode, int h, int v, int type);
static void winUpdate(struct wininfo *win, int type);

#define WPATH	1
#define WGROUP	2

/**
 *
 */
static void winDrawPicture(WININFO *win, THINGIMG *timg, OBJECT *tree,
		RECT *area, int offx, int offy, int fcol, int bcol) {
	MFDB scr_mfdb;
	int pxy[8], cindx[2], sx, sy, x, y;
	RECT trect;

	scr_mfdb.fd_addr = 0L;
	if (tree)
		tree->ob_type = G_IBOX;
	pxy[0] = pxy[1] = 0;
	pxy[2] = timg->picture.fd_w - 1;
	pxy[3] = timg->picture.fd_h - 1;
#ifdef OFFSET
	sx = win->work.x - (win->offx % pxy[2]);
	sy = win->work.y - (win->offy % pxy[3]);
#else
	sx = win->work.x - (offx % pxy[2]);
	sy = win->work.y - (offy % pxy[3]);
#endif
	for (y = sy; y < (win->work.y + win->work.h); y += pxy[3]) {
		pxy[5] = y;
		for (x = sx; x < (win->work.x + win->work.w); x += pxy[2]) {
			trect.x = x;
			trect.y = y;
			trect.w = pxy[2] + 1;
			trect.h = pxy[3] + 1;
			if (rc_intersect(area, &trect)) {
				pxy[4] = x;
				pxy[6] = x + pxy[2];
				pxy[7] = y + pxy[3];
				if (timg->is_mono) {
					cindx[0] = fcol;
					cindx[1] = bcol;
					vrt_cpyfm(tb.vdi_handle, MD_REPLACE, pxy, &timg->picture, &scr_mfdb, cindx);
				} else {
					vro_cpyfm(tb.vdi_handle, S_ONLY, pxy, &timg->picture, &scr_mfdb);
				}
			}
		}
	}
}

/**
 *
 */
static void winRedraw(struct wininfo *win, int type, RECT *area) {
	OBJECT *tree;
	MFDB scr_mfdb, sym_mfdb;
	int pxy[8], cindx[2], mindx[2], sh;
	int ix, iy, imx, x, y;
	int ty;
	int i;
	int tcol; /* gewÅnschte Font-Farbe */
	int thefcol; /* Default-Font-Farbe */
	int fcol; /* tatsÑchliche Font-Farbe (bcol != tcol) */
	int bcol; /* Hintergrund-Farbe */
	int pat; /* Hintergrund-Pattern */
	int text; /* Textdarstellung */
	int fontId; /* Font-ID */
	int fontSize; /* Font-Groesse */
	int anzahlEintraege; /* Anzahl der angezeigten EintrÑge im Fenster */
	int tlen; /* LÑnge eines Eintrags */
	int clw, clh; /* Breite/Hîhe einer Textzelle */
	int class; /* Art des Eintrags */
	int selected; /* selektiert? */
	int du;
	int hasimg = 0;
	char tchar[2];
	RECT trect;

	W_GRP *wgrp;
	WG_ENTRY *WGentry; /* Eintrag in Gruppe */

	W_PATH *wpath;
	WP_ENTRY *WPentry; /* Eintrag in Verzeichnisfenster */
	int tos;
	int f;
	unsigned int fl;
	char s[20];
	int show_tosf;

	vswr_mode(tb.vdi_handle, MD_REPLACE);

	scr_mfdb.fd_addr = NULL;
	sym_mfdb.fd_w = 16;
	sym_mfdb.fd_h = glob.sheight;
	sym_mfdb.fd_wdwidth = 1;
	sym_mfdb.fd_stand = 0;
	sym_mfdb.fd_nplanes = 1;
	sym_mfdb.fd_r1 = sym_mfdb.fd_r2 = sym_mfdb.fd_r3 = 0;

	sh = glob.sheight - 1;

	if (type == WPATH) {
		wpath = (W_PATH *) win->user;
		anzahlEintraege = wpath->e_total;
		tlen = wpath->tlen;
		clw = wpath->clw;
		clh = wpath->clh;

		/*
		 * GEMDOS-Attribute rhas nur anzeigen, wenn keine
		 * MiNT-Attribute.
		 */
		show_tosf = !(wpath->filesys.flags & UNIXATTR);

		ty = (wpath->clh - wpath->ch) / 2;
		mindx[0] = 0;
		mindx[1] = wpath->font.bcol;

		if (wpath->index.text) {
			tos = !!(wpath->filesys.flags & TOS);
			if (!conf.tosmode)
				tos = 0;
		}

		tree = wpath->tree;
		pat = wpath->bpat;
		thefcol = wpath->font.fcol;
		bcol = wpath->font.bcol;
		text = wpath->index.text;
		fontId = wpath->font.id;
		fontSize = wpath->font.size;
		imx = wpath->imx;
		if (tree)
			tree->ob_type = G_BOX;
		/* Bei Bedarf Hintergrundbild kacheln */
		if (*conf.dirimg && glob.dir_ok) {
			hasimg = 1;
#ifdef OFFSET
			winDrawPicture(win, &glob.dir_img, tree, area, win->offx, win->offy, thefcol, bcol);
#else
			winDrawPicture(win, &glob.dir_img, tree, area, wpath->offx, wpath->offy, thefcol, bcol);
#endif
		}
	} else {
		wgrp = (W_GRP *) win->user;
		anzahlEintraege = wgrp->e_num;
		tlen = wgrp->tlen;
		clw = wgrp->clw;
		clh = wgrp->clh;

		ty = (wgrp->clh - wgrp->ch) / 2;
		mindx[0] = 0;
		mindx[1] = wgrp->font.bcol;

		tree = wgrp->tree;
		pat = (tb.colors < 16) ? wgrp->bpat : wgrp->bpat16;
		thefcol = wgrp->font.fcol;
		bcol = wgrp->font.bcol;
		text = wgrp->text;
		fontId = wgrp->font.id;
		fontSize = wgrp->font.size;
		imx = wgrp->imx;
		if (wgrp->img_ok) {
			hasimg = 1;
#ifdef OFFSET
			winDrawPicture(win, &wgrp->img_info, tree, area, win->offx, win->offy, thefcol, bcol);
#else
			winDrawPicture(win, &wgrp->img_info, tree, area, wgrp->offx, wgrp->offy, thefcol, bcol);
#endif
		}
	}

	if (tree) {
		objc_draw(tree, ROOT, MAX_DEPTH, area->x, area->y, area->w, area->h);
	} else if (!hasimg) {
		if (pat == 7)
			vsf_interior(tb.vdi_handle, FIS_SOLID);
		else if (pat == 0)
			vsf_interior(tb.vdi_handle, FIS_HOLLOW);
		else {
			vsf_interior(tb.vdi_handle, FIS_PATTERN);
			vsf_style(tb.vdi_handle, pat);
		}
		vsf_color(tb.vdi_handle, bcol);
		vsf_perimeter(tb.vdi_handle, 0);

		pxy[0] = area->x;
		pxy[1] = area->y;
		pxy[2] = pxy[0] + area->w - 1;
		pxy[3] = pxy[1] + area->h - 1;
		v_bar(tb.vdi_handle, pxy);
		vsf_interior(tb.vdi_handle, FIS_SOLID);
	}

	if (text) {
		int sx, sy;

		/* Attribute setzen */
		vst_font(tb.vdi_handle, fontId);
		if (fontSize < 0)
			vst_height(tb.vdi_handle, -fontSize, &du, &du, &du, &du);
		else
			vst_point(tb.vdi_handle, fontSize, &du, &du, &du, &du);
		vst_effects(tb.vdi_handle, 0);
		vst_alignment(tb.vdi_handle, 0, 5, &du, &du);
		vsl_width(tb.vdi_handle, 1);
		vsl_ends(tb.vdi_handle, 0, 0);
		vsl_type(tb.vdi_handle, 1);
		vswr_mode(tb.vdi_handle, MD_TRANS);

		/* Liste ausgeben */
		sx = win->work.x + 10;
		sy = win->work.y + 2;
#ifdef OFFSET
		sx -= win->offx;
		sy -= win->offy;
#else
		if (type == WPATH) {
			sx -= wpath->offx;
			sy -= wpath->offy;
		} else {
			sx -= wgrp->offx;
			sy -= wgrp->offy;
		}
#endif
		ix = 0;
		iy = 0;
		x = sx;
		y = sy;
		/*tchar[1] = 0;*/

		if (type != WPATH)
			WGentry = wgrp->entry;

		for (i = 0; i < anzahlEintraege; i++) {
			if (type == WPATH)
				WPentry = wpath->lptr[i];

			/* Nur ausgeben, wenn Åberhaupt sichtbar */
			trect.x = x;
			trect.y = y;
			trect.w = tlen;
			trect.h = clh;

			if (rc_intersect(area, &trect)) {
				/*
				 * FÅr jeden Eintrag testen, ob eine eigene Farbe fÅr dessen
				 * Darstellung definiert wurde und diese gegebenenfalls
				 * Åbernehmen.
				 */
				if (type == WPATH)
					tcol = WPentry->tcolor;
				else
					tcol = WGentry->tcolor;
				if (tcol >= 0 && tcol != bcol)
					fcol = tcol;
				else
					fcol = thefcol;

				/*
				 * Falls der Eintrag selektiert ist, so muû dieser invers
				 * ausgeben werden.
				 */
				if (type == WPATH)
					selected = WPentry->sel;
				else
					selected = WGentry->sel;
				if (selected) {
					vswr_mode(tb.vdi_handle, MD_REPLACE);
					vst_color(tb.vdi_handle, bcol);
					vsf_color(tb.vdi_handle, fcol);
					vsl_color(tb.vdi_handle, bcol);
					pxy[0] = x;
					pxy[1] = y;
					pxy[2] = x + (tlen - clw * 2) - 1;
					pxy[3] = y + clh - 1;
					vsf_interior(tb.vdi_handle, FIS_SOLID);
					v_bar(tb.vdi_handle, pxy);
					vswr_mode(tb.vdi_handle, MD_TRANS);
					mindx[1] = fcol;
				} else {
					vst_color(tb.vdi_handle, fcol);
					vsf_color(tb.vdi_handle, bcol);
					vsl_color(tb.vdi_handle, fcol);
					mindx[1] = bcol;
				}

				if (type == WPATH)
					class = WPentry->class;
				else
					class = WGentry->class;

				/* Miniicons */
				if (text == 2) {
					ICONIMG *ic; /* Icon-Zuordnung */

					pxy[0] = 0;
					pxy[1] = 0;
					pxy[2] = 15;
					pxy[3] = sh;
					pxy[4] = x + 1;
					pxy[5] = y;
					if (clh > glob.sheight)
						pxy[5] += ((clh - glob.sheight) / 2);
					pxy[6] = pxy[4] + 15;
					pxy[7] = pxy[5] + sh;

					if (type == WPATH)
						ic = WPentry->iconimg;
					else
						ic = WGentry->iconimg;

					if (ic->sub_code != 0L) /* Farbicon? */
						draw_minicicon(ic, pxy, selected);
					else {
						/* Monochromes Miniicon */
						/* Maske */
						sym_mfdb.fd_addr = ic->siconblk->ib_pmask;
						mindx[0] = (ic->siconblk->ib_char & 0x0f00) >> 8;
						vrt_cpyfm(tb.vdi_handle, MD_REPLACE, pxy, &sym_mfdb, &scr_mfdb, mindx);

						/* Icon */
						sym_mfdb.fd_addr = ic->siconblk->ib_pdata;
						cindx[0] = (ic->siconblk->ib_char & 0xf000) >> 12;
						vrt_cpyfm(tb.vdi_handle, MD_TRANS, pxy, &sym_mfdb, &scr_mfdb, cindx);
					}
				} else {
					/* Sonst die bisherige Darstellung */
					y += ty;

					/* Kennzeichnung fÅr Unterverzeichnis */
					if (class == EC_FOLDER || class == EC_PARENT) {
						if (type == WPATH)
							wd_ficon(x + 1, y, wpath->iw, wpath->ih);
						else
							wd_ficon(x + 1, y, wgrp->iw, wgrp->ih);
					}

					/* Kennzeichnung von Dateien */
					if (class == EC_FILE) {
						tchar[1] = 0;
						if (type == WPATH) {
							/* Symbol vorhanden? */
							if (WPentry->tchar)
								tchar[0] = WPentry->tchar;
							else /* Nein */
							{
								if (WPentry->aptype)
									tchar[0] = '.'; /* ausfÅhrbares Programm */
								else
									tchar[0] = ' '; /* normale Datei */
							}
						} else {
/*							tchar[1] = 0;*/
							if (WGentry->aptype)
								tchar[0] = '.'; /* ausfÅhrbares Programm */
							else {
								/* normale Datei */
								if (WGentry->tchar)
									tchar[0] = WGentry->tchar;
								else
									tchar[0] = ' ';
							}
						}

						vst_alignment(tb.vdi_handle, 1, 5, &du, &du);
						if (type == WPATH)
							v_gtext(tb.vdi_handle, x + wpath->iw / 2, y, tchar);
						else
							v_gtext(tb.vdi_handle, x + wgrp->iw / 2, y, tchar);
						vst_alignment(tb.vdi_handle, 0, 5, &du, &du);
					}
					y -= ty;
				}

				if (type == WPATH) {
					/* Symbolische Links kursiv */
					if (WPentry->link)
						vst_effects(tb.vdi_handle, 4 | ((WPentry->link == 2) ? 2 : 0));
					else
						vst_effects(tb.vdi_handle, 0);

					y += ty;

					/* Dateiname */
					if (tos) {
						/* Als '8+3' */
						if (WPentry->fext)
							*(WPentry->fext) = 0;
						v_gtext(tb.vdi_handle, x + wpath->iw + clw / 2, y, WPentry->name);
						if (WPentry->fext) {
							*(WPentry->fext) = '.';
							v_gtext(tb.vdi_handle, x + wpath->pext, y, WPentry->fext);
						}
					} else
						v_gtext(tb.vdi_handle, x + wpath->iw + clw / 2, y, WPentry->name);

					vst_effects(tb.vdi_handle, 0);
					vst_alignment(tb.vdi_handle, 2, 5, &du, &du);
					x--;

					/* Grîûe, falls gewÅnscht */
					if (wpath->index.show & SHOWSIZE) {
						switch (class) {
							case EC_FOLDER:
							case EC_PARENT:
								v_gtext(tb.vdi_handle, x+wpath->psize, y, "<dir>");
								break;

							case EC_DEVICE:
								v_gtext(tb.vdi_handle, x+wpath->psize, y, "<dev>");
								break;

							case EC_FILE:
								if (WPentry->size <= 999999L)
									prlong(WPentry->size, s);
								else {
									if (WPentry->size <= 9999999L)
										sprintf(s,"%ld kB", WPentry->size/1024L);
									else
										sprintf(s,"%ld MB", WPentry->size/1024L/1024L);
								}
								v_gtext(tb.vdi_handle, x+wpath->psize, y, s);
								break;
						} /* switch */
					}

					/* Datum, falls gewÅnscht */
					if (wpath->index.show & SHOWDATE && class != EC_DEVICE && class != EC_PARENT) {
						sprintf(s, rs_trindex[LANGUAGE][LANGDATE1].ob_spec.free_string, WPentry->date & 0x001f);
						v_gtext(tb.vdi_handle, x + wpath->pdate1, y, s);
						sprintf(s, rs_trindex[LANGUAGE][LANGDATE2].ob_spec.free_string, (WPentry->date & 0x01e0) >> 5, 1980 + ((WPentry->date & 0xfe00) >> 9));
						v_gtext(tb.vdi_handle, x + wpath->pdate, y, s);
					}

					/* Uhrzeit, falls gewÅnscht */
					if (wpath->index.show & SHOWTIME && class != EC_DEVICE && class != EC_PARENT) {
						sprintf(s, rs_trindex[LANGUAGE][LANGTIME1].ob_spec.free_string, (WPentry->time & 0xf800) >> 11, (WPentry->time & 0x07e0) >> 5);
						v_gtext(tb.vdi_handle, x + wpath->ptime, y, s);
					}

					vst_alignment(tb.vdi_handle, 0, 5, &du, &du);
					/* Attribute, falls gewÅnscht */
					if (wpath->index.show & SHOWATTR) {
						if (show_tosf && class == EC_FILE) {
							int attribs[] = { FA_READONLY, FA_HIDDEN, FA_SYSTEM, FA_ARCHIVE };
							char hlp[] = "rhsa";

							for (f = 0; f < 4; f++) {
								if (!(WPentry->attr & attribs[f]))
									hlp[f] = '-';
							}
							v_gtext(tb.vdi_handle, x + wpath->pattr, y, hlp);
						}
						if (!show_tosf && (class != EC_PARENT)) {
							char hlp[] = "rwxrwxrwx";

							fl = S_IRUSR;
							for (f = 0; f < 9; f++) {
								if (!(WPentry->mode & fl))
									hlp[f] = '-';
								fl >>= 1;
							}
							if (WPentry->mode & 04000) {
								if (hlp[2] == 'x')
									hlp[2] = 's';
								else
									hlp[2] = 'S';
							}
							if (WPentry->mode & 02000) {
								if (hlp[5] == 'x')
									hlp[5] = 's';
								else
									hlp[5] = 'S';
							}
							if (WPentry->mode & 01000) {
								if (hlp[8] == 'x')
									hlp[8] = 't';
								else
									hlp[8] = 'T';
							}
							v_gtext(tb.vdi_handle, x + wpath->pmode, y, hlp);

							if (wpath->filesys.flags & OWNER) {
								char hlp[9];

								char *pwd;
								char *grp;

								pwd = get_username(WPentry->uid);
								if (pwd != NULL)
									sprintf(hlp, "%s", pwd);
								else
									sprintf(hlp, "%d", WPentry->uid);
								v_gtext(tb.vdi_handle, x + wpath->pmode + 9 * wpath->cw_x + clw, y, hlp);
								grp = get_groupname(WPentry->gid);
								if (grp != NULL)
									sprintf(hlp, "%s", grp);
								else
									sprintf(hlp, "%d", WPentry->gid);
								v_gtext(tb.vdi_handle, x + wpath->pgid, y, hlp);
							}
						}
					}

					y -= ty;
					x++;
				} else {
					y += ty;

					/* Name des Eintrags */
					v_gtext(tb.vdi_handle, x + wgrp->iw + clw / 2, y, WGentry->title);
					vst_alignment(tb.vdi_handle, 0, 5, &du, &du);
					y -= ty;
				}
			}

			/* NÑchste Zeile/Spalte */
			if (conf.vert && type == WPATH) {
				/* Spaltenweise */
				iy++;
				y += clh + 1;
				if (iy >= wpath->imy) {
					iy = 0;
					y = sy;
					ix++;
					x += tlen;
				}
			} else {
				ix++;
				x += tlen;
				if (ix >= imx) {
					/* Zeilenumbruch */
					ix = 0;
					iy++;
					x = sx;
					y += clh + 1;
				}
			}
			if (type == WGROUP)
				WGentry = WGentry->next;
		}

		/* Und weiter ... */
		vswr_mode(tb.vdi_handle, MD_REPLACE);
	}
}

static void winSlide(struct wininfo *win, int mode, int h, int v, int type) {
	OBJECT *tree;
	long hsize, vsize, hpos, vpos;
	int dx, dy, lv, lh, offx, offy, imx, imy;
	int anzahlEintraege; /* Anzahl der angezeigten EintrÑge im Fenster */
	int text; /* Textdarstellung */
	int tlen; /* LÑnge eines Eintrags */
	int clw, clh; /* Breite/Hîhe einer Textzelle */
	int pat; /* Hintergrund-Pattern */
	int width, height; /* Breite und Hîhe des Bereiches (Text oder Icon)*/
	int ih; /* Hîhe des Ordner-Icons */
	int correct;

	W_PATH *wpath;
	W_GRP *wgrp;

	if (type == WPATH) {
		wpath = (W_PATH *) win->user;
		anzahlEintraege = wpath->e_total;
		tlen = wpath->tlen;
		clw = wpath->clw;
		clh = wpath->clh;
		tree = wpath->tree;
		text = wpath->index.text;
		pat = wpath->bpat;
		ih = wpath->ih;
	} else {
		wgrp = (W_GRP *) win->user;
		anzahlEintraege = wgrp->e_num;
		tlen = wgrp->tlen;
		clw = wgrp->clw;
		clh = wgrp->clh;
		tree = wgrp->tree;
		text = wgrp->text;
		pat = (tb.colors < 16) ? wgrp->bpat : wgrp->bpat16;
		ih = wgrp->ih;
	}

	/*
	 * Falls keine EintrÑge vorhanden sind bzw. kein Objektbaum fÅr die
	 * Icons erzeugt werden konnte, dann Slider auf Standardgrîûe
	 * setzen und raus.
	 */
	if (anzahlEintraege == 0 || (!text && !tree)) {
		if (mode == S_INIT) {
			if (win->flags & HSLIDE) {
				wind_set(win->handle, WF_HSLIDE, 0);
				wind_set(win->handle, WF_HSLSIZE, 1000);
			}
			wind_set(win->handle, WF_VSLIDE, 0);
			wind_set(win->handle, WF_VSLSIZE, 1000);
#ifdef OFFSET
			win->offx = 0;
			win->offy = 0;
#else
			if (type == WPATH) {
				wpath->offx = 0;
				wpath->offy = 0;
			} else {
				wgrp->offx = 0;
				wgrp->offy = 0;
			}
#endif
		}

		return;
	}

	if ((pat != 0) && (pat != 7))
		correct = ~3;
	else
		correct = ~0;

	if (text) {
		/* Breite und Hîhe des Textbereichs */
		if (type == WPATH) {
			width = tlen * wpath->imx + 20 - clw * 2;
			height = wpath->imy * (clh + 1) + 3;
		} else {
			width = tlen * wgrp->imx + 20 - clw * 2;
			height = wgrp->imy * (clh + 1) + 3;
		}
	} else {
		/* Breite und Hîhe des Icon-Dialogs */
		width = tree->ob_width;
		height = tree->ob_height;
	}

	switch (mode) {
	case S_INIT:
		/* Grîûe der Slider */
		hsize = (long) win->work.w * 1000L / (long) width;
		vsize = (long) win->work.h * 1000L / (long) height;
		hsize = min(hsize, 1000L);
		vsize = min(vsize, 1000L);

		/* Offset anpassen */
#ifdef OFFSET
		offx = win->offx;
		offy = win->offy;
#else
		if (type == WPATH) {
			offx = wpath->offx;
			offy = wpath->offy;
		} else {
			offx = wgrp->offx;
			offy = wgrp->offy;
		}
#endif
		if (width - offx < win->work.w) {
			offx = width - win->work.w;
			if (offx < 0)
				offx = 0;
		}
		if (height - offy < win->work.h) {
			offy = height - win->work.h;
			if (offy < 0)
				offy = 0;
		}

		/* Offset korrigieren wg. Hintergrundmuster */
		offx &= correct;
		offy &= correct;
#ifdef OFFSET
		if (offx != win->offx || offy != win->offy)
		{
			dx = win->offx - offx;
			dy = win->offy - offy;
			win->offx = offx;
			win->offy = offy;
			w_draw(win);
		}
#else
		if (type == WPATH) {
			if (offx != wpath->offx || offy != wpath->offy) {
				dx = wpath->offx - offx;
				dy = wpath->offy - offy;
				wpath->offx = offx;
				wpath->offy = offy;
				w_draw(win);
			}
		} else {
			if (offx != wgrp->offx || offy != wgrp->offy) {
				dx = wgrp->offx - offx;
				dy = wgrp->offy - offy;
				wgrp->offx = offx;
				wgrp->offy = offy;
				w_draw(win);
			}
		}
#endif

		/* Slider-Positionen berechnen */
		if (width > win->work.w) {
#ifdef OFFSET
			hpos = (long)win->offx * 1000L / (long)(width - win->work.w);
#else
			if (type == WPATH)
				hpos = (long) wpath->offx * 1000L / (long) (width - win->work.w);
			else
				hpos = (long) wgrp->offx * 1000L / (long) (width - win->work.w);
#endif
		} else
			hpos = 0;

		if (height > win->work.h) {
#ifdef OFFSET
			vpos = (long)win->offy * 1000L / (long)(height - win->work.h);
#else
			if (type == WPATH)
				vpos = (long) wpath->offy * 1000L / (long) (height - win->work.h);
			else
				vpos = (long) wgrp->offy * 1000L / (long) (height - win->work.h);
#endif
		} else
			vpos = 0;

		/* Slider setzen */
		if (win->flags & HSLIDE) {
			wind_set(win->handle, WF_HSLIDE, (int) hpos);
			wind_set(win->handle, WF_HSLSIZE, (int) hsize);
		}
		wind_set(win->handle, WF_VSLIDE, (int) vpos);
		wind_set(win->handle, WF_VSLSIZE, (int) vsize);
		break;

	case S_ABS:
		/* Offset umrechnen */
		if (h != -1) {
			if (width > win->work.w)
				offx = (int) ((long) (width - win->work.w) * (long) h / 1000L);
			else
				offx = 0;
		} else {
#ifdef OFFSET
			offx = win->offx;
#else
			if (type == WPATH)
				offx = wpath->offx;
			else
				offx = wgrp->offx;
#endif
		}

		if (v != -1) {
			if (height > win->work.h)
				offy = (int) ((long) (height - win->work.h) * (long) v / 1000L);
			else
				offy = 0;
		} else {
#ifdef OFFSET
			offy = win->offy;
#else
			if (type == WPATH)
				offy = wpath->offy;
			else
				offy = wgrp->offy;
#endif
		}

		/* Offset korrigieren wg. Hintergrundmuster */
		offx &= correct;
		offy &= correct;

		/* Und setzen */
#ifdef OFFSET
		if (offx != win->offx || offy != win->offy)
		{
			dx = win->offx - offx;
			dy = win->offy - offy;
			win->offx = offx;
			win->offy = offy;
			win_scroll(win, dx, dy);
			win_slide(win, S_INIT, 0, 0);
		}
#else
		if (type == WPATH) {
			if (offx != wpath->offx || offy != wpath->offy) {
				dx = wpath->offx - offx;
				dy = wpath->offy - offy;
				wpath->offx = offx;
				wpath->offy = offy;
				win_scroll(win, dx, dy);
				win_slide(win, S_INIT, 0, 0);
			}
		} else {
			if (offx != wgrp->offx || offy != wgrp->offy) {
				dx = wgrp->offx - offx;
				dy = wgrp->offy - offy;
				wgrp->offx = offx;
				wgrp->offy = offy;
				win_scroll(win, dx, dy);
				win_slide(win, S_INIT, 0, 0);
			}
		}
#endif
		break;

	case S_REL:
		lh = 0;
		lv = 0;
#if 0
		if (text)
		imx = (win->work.w - 10 + 2 * clw);
		else
#endif
		imx = win->work.w;
#if 0
		if (imx/tlen < 1)
		imx = tlen;
#else
		imx /= clw;
		if (imx < 1)
			imx = 1;
		imx *= clw;
#endif
		if (text)
			imy = (win->work.h - 2) / (clh + 1);
		else
			imy = win->work.h / ih;
		if (imy < 1)
			imy = 1;
		if (text)
			imy *= clh;
		else
			imy *= ih;

		switch (h) {
		case -1:
			if (text)
				lh = clw;
			else
				lh = tlen;
			break;

		case -2:
			lh = imx;
			break;

		case 1:
			if (text)
				lh = -clw;
			else
				lh = -tlen;
			break;

		case 2:
			lh = -imx;
			break;
		} /* switch */

		switch (v) {
		case -1:
			if (text)
				lv = clh + 1;
			else
				lv = ih;
			break;

		case -2:
			lv = imy;
			break;

		case 1:
			if (text)
				lv = -(clh + 1);
			else
				lv = -ih;
			break;

		case 2:
			lv = -imy;
			break;
		} /* switch */

	case S_PABS:
		if (mode == S_PABS) {
			lh = h;
			lv = v;
		}
#ifdef OFFSET
		offx = win->offx;
		offy = win->offy;
#else
		if (type == WPATH) {
			offx = wpath->offx;
			offy = wpath->offy;
		} else {
			offx = wgrp->offx;
			offy = wgrp->offy;
		}
#endif

		if (width > win->work.w) {
			offx -= lh;
			if (offx > width - win->work.w)
				offx = width - win->work.w;
			if (offx < 0)
				offx = 0;
		}
		if (height > win->work.h) {
			offy -= lv;
			if (offy > height - win->work.h)
				offy = height - win->work.h;
			if (offy < 0)
				offy = 0;
		}

		/* Offset korrigieren wg. Hintergrundmuster */
		offx &= correct;
		offy &= correct;
#ifdef OFFSET
		if (offx != win->offx || offy != win->offy)
		{
			dx = win->offx - offx;
			dy = win->offy - offy;
			win->offx = offx;
			win->offy = offy;
			win_scroll(win, dx, dy);
			win_slide(win, S_INIT, 0, 0);
		}
#else
		if (type == WPATH) {
			if (offx != wpath->offx || offy != wpath->offy) {
				dx = wpath->offx - offx;
				dy = wpath->offy - offy;
				wpath->offx = offx;
				wpath->offy = offy;
				win_scroll(win, dx, dy);
				win_slide(win, S_INIT, 0, 0);
			}
		} else {
			if (offx != wgrp->offx || offy != wgrp->offy) {
				dx = wgrp->offx - offx;
				dy = wgrp->offy - offy;
				wgrp->offx = offx;
				wgrp->offy = offy;
				win_scroll(win, dx, dy);
				win_slide(win, S_INIT, 0, 0);
			}
		}
#endif
		break;
	} /* switch */
}

/**
 *
 */
static void winUpdate(struct wininfo *win, int type) {
	int w, h, n, autosize;
	int asx, asy;

	int anzahlEintraege; /* Anzahl der angezeigten EintrÑge im Fenster */
	int text; /* Textdarstellung */
	int tlen; /* LÑnge eines Eintrags */
	int clw; /* Breite einer Textzelle */
	int ih; /* Hîhe des Ordner-Icons */
	int imx, imy;

	OBJECT *tree;
	W_PATH *wpath;
	W_GRP *wgrp;

	if (type == WPATH) {
		wpath = (W_PATH *)win->user;

		anzahlEintraege = wpath->e_total;
		tlen = wpath->tlen;
		clw = wpath->clw;
		tree = wpath->tree;
		text = wpath->index.text;
		ih = wpath->ih;
		imx = wpath->imx;
		imy = wpath->imy;

		autosize = conf.autosize;
		asx = conf.autosizex;
		asy = conf.autosizey;
		conf.autosize = conf.autosizex = conf.autosizey = 0;
	} else {
		wgrp = (W_GRP *)win->user;

		anzahlEintraege = wgrp->e_num;
		tlen = wgrp->tlen;
		clw = wgrp->clw;
		tree = wgrp->tree;
		text = wgrp->text;
		ih = wgrp->ih;
		imx = wgrp->imx;
		imy = wgrp->imy;
	}

	/* Anpassung des Objektbaums */
	if (anzahlEintraege > 0) {
		/* Nur wenn Objekte vorhanden sind */
		if (!text && tree) {
			/* Bei Icondarstellung */
			n = win->work.w / tlen;
			if (n > anzahlEintraege)
			n = anzahlEintraege;
		} else if (text) {
			/* Bei Textdarstellung */
			n = (win->work.w - 10 + 2 * clw) / tlen;
		}

		if (!n)
		n = 1;

		if (n != imx) {
			/* Spaltenzahl verÑndert ? */
			if (type == WPATH)
				wpath_tree(win); /* Ja - dann neu aufbauen */
			else
				wgrp_tree(win); /* Ja - dann neu aufbauen */

			w_draw(win);
			win_slide(win, S_INIT, 0, 0);
		}
	}

	if (tree) {
#ifdef OFFSET
		tree->ob_x = win->work.x - win->offx;
		tree->ob_y = win->work.y - win->offy;
#else
		if (type == WPATH)
		{
			tree->ob_x = win->work.x - wpath->offx;
			tree->ob_y = win->work.y - wpath->offy;
		}
		else
		{
			tree->ob_x = win->work.x - wgrp->offx;
			tree->ob_y = win->work.y - wgrp->offy;
		}
#endif

		/*
		 * Falls Objekte vorhanden sind, Objektbaum ggf. auf
		 * Fenstergrîûe vergrîûern
		 */
		if (anzahlEintraege > 0) {
			w = imx * tlen;
			if (w < win->work.w)
			w = win->work.w;

			h = imy * ih;
			if (h < win->work.h)
			h = win->work.h;
		} else {
			/* Keine Objekte - Baum immer Fenstergrîûe */
			w = win->work.w;
			h = win->work.h;
		}
		tree->ob_width = w;
		tree->ob_height = h;
	}

	if (type == WPATH) {
		conf.autosize = autosize;
		conf.autosizex = asx;
		conf.autosizey = asy;
	}
}

/*-------------------------------------------------------------------------
 w_draw()

 Redraw fÅr ein Fenster via AES-Message auslîsen
 -------------------------------------------------------------------------*/
void w_draw(WININFO *win) {
	if (win->state & WSOPEN) {
		appl_send(tb.app_id, WM_REDRAW, 0, win->handle, win->work.x, win->work.y, win->work.w, win->work.h);
		/* Slider initialisieren */
/*		win_slide(win,S_INIT,0,0); */
	}
}

/**
 * Zeichnen eines Ordner-'Icons' im Textmodus von Verzeichnissen/Gruppen
 *
 * @param x
 * @param y
 * @param iw
 * @param ih
 */
static void wd_ficon(int x, int y, int iw, int ih) {
	int pxy[6];
	int x1, x2, x3, x4;
	int y1, y2;

	x1 = x + iw * 1 / 16;
	x2 = x + iw * 13 / 16 - 1;
	x3 = x2 + 1;
	x4 = x + iw * 8 / 16 - 1;
	y1 = y + ih * 5 / 16;
	y2 = y + ih * 4 / 16;

	pxy[0] = x1;
	pxy[1] = y2 + 1;
	pxy[2] = x1;
	pxy[3] = y + ih * 13 / 16 - 2;
	v_pline(tb.vdi_handle, 2, pxy);

	pxy[0] = x1 + 1;
	pxy[1] = y2;
	pxy[2] = x4;
	pxy[3] = y2;
	v_pline(tb.vdi_handle, 2, pxy);

	pxy[0] = x2;
	pxy[1] = y + ih * 2 / 16 + 1;
	pxy[2] = x2;
	pxy[3] = y + ih * 13 / 16 - 1;
	pxy[4] = x + iw * 1 / 16 + 1;
	pxy[5] = y + ih * 13 / 16 - 1;
	v_pline(tb.vdi_handle, 3, pxy);

	pxy[0] = x4;
	pxy[1] = y1 - 1;
	pxy[2] = x4;
	pxy[3] = y + ih * 2 / 16 + 1;
	v_pline(tb.vdi_handle, 2, pxy);

	pxy[0] = x4 + 1;
	pxy[1] = y + ih * 2 / 16;
	pxy[2] = x + iw * 13 / 16 - 2;
	pxy[3] = y + ih * 2 / 16;
	v_pline(tb.vdi_handle, 2, pxy);

	pxy[0] = x4 + 1;
	pxy[1] = y1;
	pxy[2] = x2;
	pxy[3] = y1;
	v_pline(tb.vdi_handle, 2, pxy);

	pxy[0] = x3;
	pxy[1] = y + ih * 2 / 16 + 2;
	pxy[2] = x3;
	pxy[3] = y + ih * 13 / 16 - 1;
	v_pline(tb.vdi_handle, 2, pxy);

	pxy[0] = x2;
	pxy[1] = y + ih * 13 / 16;
	pxy[2] = x + iw * 1 / 16 + 2;
	pxy[3] = y + ih * 13 / 16;
	v_pline(tb.vdi_handle, 2, pxy);
}

/*-------------------------------------------------------------------------
 pwin_...()

 Verwaltung der Verzeichnis-Fenster
 -------------------------------------------------------------------------*/
void pwin_update(struct wininfo *win) {
	winUpdate(win, WPATH);
}

void pwin_prepare(struct wininfo *win) {
	(void) win;
}

void pwin_redraw(struct wininfo *win, RECT *area) {
	winRedraw(win, WPATH, area);
}

void pwin_slide(struct wininfo *win, int mode, int h, int v) {
	winSlide(win, mode, h, v, WPATH);
}

/*-------------------------------------------------------------------------
 gwin_...()

 Verwaltung der Gruppen-Fenster
 -------------------------------------------------------------------------*/
void gwin_update(struct wininfo *win) {
	winUpdate(win, WGROUP);
}

void gwin_prepare(struct wininfo *win) {
	(void) win;
}

void gwin_redraw(struct wininfo *win, RECT *area) {
	winRedraw(win, WGROUP, area);
}

void gwin_slide(struct wininfo *win, int mode, int h, int v) {
	winSlide(win, mode, h, v, WGROUP);
}

/*-------------------------------------------------------------------------
 wf_...()

 Verwaltung des Cursors in Verzeichnissen und Gruppen
 -------------------------------------------------------------------------*/

/**
 * wf_getfirst
 *
 * Ermittelt das erste sichtbare Objekt in einem Fenster.
 *
 * Eingabe:
 * win: Betreffendes Fenster
 *
 * RÅckgabe:
 * -1: Kein (sichtbares) Objekt im Fenster
 * sonst: Eintragsnummer des Objekts
 */
int wf_getfirst(WININFO *win) {
	WG_ENTRY *dummy;

	switch (win->class) {
	case WCPATH:
		return ((int)wpath_efind(win, -1, 0) - 1);

	case WCGROUP:
		return ((int)wgrp_efind(win, -1, 0, &dummy) - 1);
	}

	return (-1);
}

/**
 * Cursor einschalten
 */
void wf_set(WININFO *win) {
	W_PATH *wpath;
	W_GRP *wgrp;
	WG_ENTRY *gitem;
	int i;

	if (glob.fmode && win == glob.fwin)
		return;

	if (win->class == WCPATH || win->class == WCGROUP) {
		/*
		 * Cursor nur aktivieren, wenn Åberhaupt Objekte vorhanden sind.
		 */
		switch (win->class) {
		case WCPATH:
			wpath = (W_PATH *)win->user;
			if (!wpath->e_total)
				return;

			/* Focus auf das erste selektierte Objekt */
			wpath->focus = -1;
			for (i = 0; i < wpath->e_total; i++) {
				if (wpath->lptr[i]->sel) {
					wpath->focus = i;
					break;
				}
			}

			/* Ggf. versuchen, das erste sichtbare Objekt zu selektieren */
			if (wpath->focus == -1)
				wpath->focus = wf_getfirst(win);

			/* Falls Focus vorhanden, dann ggf. scrollen */
			if (wpath->focus > -1)
				wpath_showsel(win, 1);
			else {
				wpath->focus = 0;
				win_slide(win, S_ABS, 0, 0);
			}
			break;

		case WCGROUP:
			wgrp = (W_GRP *)win->user;
			if (!wgrp->e_num)
				return;

			/* Focus auf das erste selektierte Objekt */
			wgrp->focus = -1;
			gitem = wgrp->entry;
			i = 0;
			while (gitem && wgrp->focus == -1) {
				if (gitem->sel)
					wgrp->focus = i;

				gitem = gitem->next;
				i++;
			}

			/* Ggf. versuchen, das erste sichtbare Objekt zu selektieren */
			if (wgrp->focus == -1)
			wgrp->focus = wf_getfirst(win);

			/* Falls Focus vorhanden, dann ggf. scrollen */
			if (wgrp->focus > -1)
				wgrp_showsel(win, 1);
			else {
				wgrp->focus = 0;
				win_slide(win, S_ABS, 0, 0);
			}
			break;
		} /* switch */

		/* Bisherigen Cursor abschalten */
		wf_clear();

		/* Cursor neu setzen */
		glob.fmode = 1;
		glob.fdraw = 1;
		glob.fwin = win;
		wf_draw();
	}
}

/**
 * Cursor ausschalten
 */
void wf_clear(void) {
	if (glob.fmode) {
		if (glob.fdraw)
			wf_draw();

		glob.fmode = 0;
	}
}

/**
 * Cursor setzen/loeschen
 */
void wf_draw(void) {
	int whandle;
	WININFO *win;
	W_PATH *wpath;
	W_GRP *wgrp;
	int i, pxy[32], cxy[4];
	int ix, iy, iw, ih, tx, ty, tw;
	RECT area, box;
	int x, y;
#if 0
	int w, h;
#endif
	ICONBLK *iblk;
	int text; /* Textdarstellung */
	int tlen; /* LÑnge eines Eintrags */
	int clw, clh; /* Breite/Hîhe einer Textzelle */
#if 0
	int ih; /* Hîhe des Ordner-Icons */
#endif
	int imx, imy;
	int type;
	OBJECT *tree;

	win = glob.fwin;
	whandle = win->handle;

	/* Falls Fenster ikonifiziert, dann keine Ausgabe */
	if (win->state & WSICON)
		return;

	switch (win->class) {
		case WCPATH:
			type = WPATH;
			wpath = (W_PATH *)win->user;
			tlen = wpath->tlen;
			clw = wpath->clw;
			clh = wpath->clh;
			tree = wpath->tree;
			text = wpath->index.text;
			ih = wpath->ih;
			imx = wpath->imx;
			imy = wpath->imx;
			i = wpath->focus;
			break;

		case WCGROUP:
			type = WGROUP;
			wgrp = (W_GRP *)win->user;
			tlen = wgrp->tlen;
			clw = wgrp->clw;
			clh = wgrp->clh;
			tree = wgrp->tree;
			text = wgrp->text;
			ih = wgrp->ih;
			imx = wgrp->imx;
			imy = wgrp->imx;
			i = wgrp->focus;
			break;
	} /* switch */

	if (text) {
		/* Darstellung als Text */
		if (conf.vert && type == WPATH) {
			tx = i / wpath->imy;
#ifdef OFFSET
			ix = tx * tlen + win->work.x + 10 - win->offx;
			iy = (i - tx * imy) * (clh+1) + win->work.y + 2 - win->offy;
#else
			ix = tx * tlen + win->work.x + 10 - wpath->offx;
			iy = (i - tx * imy) * (clh + 1) + win->work.y + 2 - wpath->offy;
#endif
		} else {
			ty = i / imx;

#ifdef OFFSET
			ix = (i - ty * imx) * tlen + win->work.x + 10 - win->offx;
			iy = ty * (clh + 1) + win->work.y + 2 - win->offy;
#else
			ix = (i - ty * imx) * tlen + win->work.x + 10;
			iy = ty * (clh + 1) + win->work.y + 2;

			if (type == WPATH) {
				ix -= wpath->offx;
				iy -= wpath->offy;
			} else {
				ix -= wgrp->offx;
				iy -= wgrp->offy;
			}
#endif
		}

		iw = tlen - clw * 2;
		ih = clh;

		pxy[0] = ix;
		pxy[1] = iy;
		pxy[2] = pxy[0] + iw - 1;
		pxy[3] = pxy[1] + ih - 1;
	} else {
		/* Darstellung als Icons */
		objc_offset(tree, i + 1, &x, &y);
#if 0
		w = tree[i+1].ob_width;
		h = tree[i+1].ob_height;
#endif

		if (type == WPATH)
			iblk = &wpath->wicon[i].ciconblk.monoblk;
		else
			iblk = &wgrp->wicon[i].ciconblk.monoblk;

		ix = iblk->ib_xicon;
		iw = iblk->ib_wicon;
		tx = iblk->ib_xtext;
		ty = iblk->ib_ytext;
		tw = iblk->ib_wtext;

		/* Anpassung an Beschriftung */
		if (tw < iw) {
			/* Text kleiner als Icon */
			x += ix;
#if 0
			w = iw;
#endif
			tx -= ix;
			ix = 0;
		} else {
			/* Text grîûer oder gleich groû wie Icon */
			x += tx;
#if 0
			w = tw;
#endif
			ix -= tx;
			tx = 0;
		}

		/* wegen XOR, werden viele viele Koordinaten benîtigt */
		pxy[0] = x + tx;
		pxy[1] = y + ty;
		pxy[2] = x + ix;
		pxy[3] = pxy[1];
		pxy[4] = pxy[2];
		pxy[5] = pxy[1] - 1;
		pxy[6] = pxy[2];
		pxy[7] = y + 1;
		pxy[8] = pxy[2];
		pxy[9] = y;
		pxy[10] = pxy[2] + iw - 1;
		pxy[11] = y;
		pxy[12] = pxy[10];
		pxy[13] = pxy[7];
		pxy[14] = pxy[10];
		pxy[15] = pxy[1] - 1;
		pxy[16] = pxy[10];
		pxy[17] = pxy[1];
		pxy[18] = pxy[0] + tw - 1;
		pxy[19] = pxy[1];
		pxy[20] = pxy[18];
		pxy[21] = pxy[1] + 1;
		pxy[22] = pxy[18];
		pxy[23] = pxy[1] + 6;
		pxy[24] = pxy[18];
		pxy[25] = pxy[1] + 7;
		pxy[26] = pxy[0];
		pxy[27] = pxy[1] + 7;
		pxy[28] = pxy[0];
		pxy[29] = pxy[1] + 6;
		pxy[30] = pxy[0];
		pxy[31] = pxy[1] + 1;
	}

	wind_update (BEG_UPDATE);
	graf_mouse(M_OFF, NULL);

	/* Zeichnen unter Beachtung der Rechteckliste */
	vsl_color(tb.vdi_handle, 1);
	vsl_type(tb.vdi_handle, 1);
	vsf_interior(tb.vdi_handle, FIS_HOLLOW);
	vsf_perimeter(tb.vdi_handle, 1);
	vswr_mode(tb.vdi_handle, MD_XOR);

	area = tb.desk;

	/* Ersten Eintrag in der Rechteckliste holen */
	wind_get(whandle, WF_FIRSTXYWH, &box.x, &box.y, &box.w, &box.h);

	/* Rechteckliste abarbeiten */
	while (box.w && box.h) {
		/*
		 * Nur durchfÅhren, wenn Rechteck innerhalb des zu
		 * zeichnenden Bereichs liegt
		 */
		if (rc_intersect(&area, &box)) {
			cxy[0] = box.x;
			cxy[1] = box.y;
			cxy[2] = cxy[0] + box.w - 1;
			cxy[3] = cxy[1] + box.h - 1;
			vs_clip(tb.vdi_handle, 1, cxy);

			if (text)
				v_bar(tb.vdi_handle, pxy);
			else
				for (i = 0; i < 8; i++) {
					v_pline(tb.vdi_handle, 2, &pxy[i * 4]);
				}
		}

		/* NÑchstes Rechteck holen */
		wind_get(whandle, WF_NEXTXYWH, &box.x, &box.y, &box.w, &box.h);
	}

	vs_clip(tb.vdi_handle, 0, cxy);
	vswr_mode(tb.vdi_handle, MD_REPLACE);

	graf_mouse(M_ON, NULL);
	wind_update (END_UPDATE);
}

/**
 * Cursor-Objekt selektieren
 *
 * @param sel
 * @param add
 */
void wf_sel(int sel, int add) {
	WININFO *win, *win1;
	W_PATH *wpath;
	W_GRP *wgrp;
	WG_ENTRY *gitem;
	int i, f;

	win = glob.fwin;

	/*
	 * EintrÑge in anderen Fenstern und auf dem Desktop deselektieren.
	 */
	win1 = tb.win;
	while (win1) {
		if (win1 != win) {
			switch (win1->class)
			{
				case WCPATH:
				((W_PATH *)win1->user)->amask[0] = 0;
				wpath_esel(win1, NULL, 0, 0, 1);
				break;

				case WCGROUP:
				wgrp_esel(win1,0L,0,0);
				break;
			}
		}

		win1 = win1->next;
	}

	icon_select(-1, 0, 0);

	switch (win->class) {
	case WCPATH:
		wpath = (W_PATH *)win->user;
		if ((!sel && conf.autosel) || sel) {
			wpath->amask[0] = 0;
			if (sel)
				wpath_esel(win, wpath->lptr[wpath->focus], add, 1-wpath->lptr[wpath->focus]->sel, 1);
			else
				wpath_esel(win, wpath->lptr[wpath->focus], add, 1, 1);
		}

		wpath_showsel(win, 1);
		break;

	case WCGROUP:
		wgrp = (W_GRP *)win->user;
		f = wgrp->focus;
		gitem = wgrp->entry;
		for (i = 0; i < f; i++)
			gitem = gitem->next;

		/* énderung: Bei Gruppen immer selektieren */
		/*   if((!sel && conf.autosel) || sel)
		 { */

		if (sel)
			wgrp_esel(win, gitem, 0, 1-gitem->sel);
		else
			wgrp_esel(win, gitem, 0, 1);
		/*   } */

		wgrp_showsel(win, 1);
		break;
	} /* switch */

	mn_update();
}

/* Cursor bewegen */
void wf_move(int dir, int add) {
	WININFO *win;
	W_PATH *wpath;
	W_GRP *wgrp;
	int focus, max, vmove, hmove;
	int page;

	if (glob.fdraw)
		wf_draw();

	win = glob.fwin;
	switch (win->class) {
	case WCPATH:
		wpath = (W_PATH *)win->user;
		focus = wpath->focus;
		max = wpath->e_total - 1;

		if (wpath->index.text)
			page = win->work.h / (wpath->clh + 1);
		else
			page = win->work.h / (wpath->ih + 8);

		page--;
		if (page < 1)
			page = 1;

		if (wpath->index.text && conf.vert) {
			if (!conf.autosel && add)
				vmove = page;
			else
				vmove = 1;

			hmove = wpath->imy;
		} else {
			if (!conf.autosel && add)
				vmove = wpath->imx * page;
			else
				vmove = wpath->imx;

			hmove = 1;
		}

		switch (dir) {
		case 0:
			focus = 0;
			break;
		case 9:
			focus = max;
			break;
		case -1:
			focus -= hmove;
			break;
		case 1:
			focus += hmove;
			break;
		case -2:
			focus -= vmove;
			break;
		case 2:
			focus += vmove;
			break;
		}

		/* if(focus<0 || focus>max) focus=focus1; */
		if (focus < 0)
			focus = 0;
		if (focus > max)
			focus = max;

		wpath->focus = focus;
		break;

	case WCGROUP:
		wgrp = (W_GRP *)win->user;
		focus = wgrp->focus;
		max = wgrp->e_num - 1;

		if (wgrp->text)
			page = win->work.h / (wgrp->clh + 1);
		else
			page = win->work.h / wgrp->ih;

		page--;
		if (page < 1)
			page = 1;

		/* énderung: Bei Gruppen wird immer selektiert */
		if (/* !conf.autosel && */add)
			vmove = wgrp->imx * page;
		else
			vmove = wgrp->imx;

		hmove = 1;

		switch (dir) {
		case 0:
			focus = 0;
			break;
		case 9:
			focus = max;
			break;
		case -1:
			focus -= hmove;
			break;
		case 1:
			focus += hmove;
			break;
		case -2:
			focus -= vmove;
			break;
		case 2:
			focus += vmove;
			break;
		}

		if (focus < 0)
			focus = 0;
		if (focus > max)
			focus = max;
		wgrp->focus = focus;
		break;
	}

	wf_sel(0, add);
	wf_draw();
	glob.fdraw = 1;
}

/*-------------------------------------------------------------------------
 w_full()

 Berechnen der idealen Fenstergrîûe fÅr Verzeichnisse/Gruppen
 -------------------------------------------------------------------------*/
void w_full(WININFO *win) {
	int x, y, w, h, imx, imy;
	int minx, miny, maxw, maxh;
	int wx, wy;
	double f, g;
	int fi, fj, ax, ay;
	W_PATH *wpath;
	W_GRP *wgrp;

	ax = 4;
	ay = 0;
	switch (win->class) {
	case WCGROUP:
		wgrp = (W_GRP *)win->user;
		wx = wgrp->tlen;
		if (wgrp->text) {
			wy = wgrp->clh + 1;
			ax = 0;
			ay = 4;
		} else
			wy = wgrp->ih;
		f = wgrp->e_num;
		break;
	case WCPATH:
		wpath = (W_PATH *)win->user;
		wx = wpath->tlen;
		if (wpath->index.text) {
			wy = wpath->clh + 1;
			ax = 0;
			ay = 4;
		} else
			wy = wpath->ih;
		f = wpath->e_total;
		break;
	}
	if (wx < 1)
		wx = 1;
	if (wy < 1)
		wy = 1;
	minx = tb.desk.x;
	miny = tb.desk.y;
	maxw = tb.desk.w;
	maxh = tb.desk.h;
	if (1 /* conf.autoplace */) {
		minx += tb.fleft;
		miny += tb.fupper;
		maxw -= tb.fleft + tb.fright;
		maxh -= tb.fupper + tb.flower;
		if (win->state & WSOPEN) {
			/*
			 * Bei offenen Fenstern ist die zulÑssige Gesamtgrîûe ggf. hîher
			 */
			minx = min(minx, win->curr.x);
			miny = min(miny, win->curr.y);
			if ((win->curr.x + win->curr.w) > (minx + maxw))
				maxw = win->curr.x + win->curr.w - minx;
			if ((win->curr.y + win->curr.h) > (miny + maxh))
				maxh = win->curr.y + win->curr.h - miny;

			/* Auf Desktop beschrÑnken */
			minx = max(minx, tb.desk.x);
			miny = max(miny, tb.desk.y);
			if ((minx + maxw) > (tb.desk.x + tb.desk.w))
				maxw = tb.desk.x + tb.desk.w - minx;
			if ((miny + maxh) > (tb.desk.y + tb.desk.h))
				maxh = tb.desk.y + tb.desk.h - miny;
		}
		w = maxw;
		h = maxh;
		if (conf.autosizey)
			h = (int) (+((double) h * (double) (11 - conf.autosizey)) / 10.0);
		if (conf.autosizex)
			w = (int) (+((double) w * (double) (11 - conf.autosizex)) / 10.0);
		if (conf.autoplace) {
			if ((w % 8) != 7)
				w -= w % 8 + 1;
			if ((h % 8) != 7)
				h -= h % 8 + 1;
			w -= ax;
			h -= ay;
			w = max(0, w);
			h = max(0, h);
		}
	}
	wind_calc(WC_WORK, win->flags, minx, miny, w, h, &x, &y, &w, &h);
	if (!conf.autosizey)
		h = min(win->work.h, maxh);
	if (!conf.autosizex)
		w = min(win->work.w, maxw);
	else
		w -= w % wx;
	imx = w / wx;
	if (imx < 1)
		imx = 1;
	imy = h / wy;
	if (imy < 1)
		imy = 1;

	/* Rechteck berechnen */
	if (!ax) {
		/* Textmodus */
		if (imy >= (int) f)
			imx = 1; /* Alles passt in eine Spalte */
		else {
			/* Sonst nîtige bzw. mîgliche Spaltenzahl ermitteln */
			if (imx > 1) {
#if 1
				for (imx = 2; (((wx * (imx + 1)) <= w) && ((imx * imy) < f)); imx++)
					;
#else
				imx=(int)(f/imy);
				if(imx*imy<f) imx++;
#endif
			}
		}
		for (; imy && ((imx * imy) > (int) f); imy--)
			;
		wx *= imx;
		wy *= imy;
		wy += ay;
	} else {
		g = sqrt(f);
		fi = (int) g;
		if (g - (int) (g) > 0)
			fi++;
		if (fi > imx)
			fj = (int) (f / (double) imx);
		if (fj * imx < f)
			fj++;
		else
			fj = (int) (f / (double) fi);
		if (fj * fi < f)
			fj++;
		fi = min(fi, imx);
		fj = min(fj, imy);
		if ((fi * fj) < (int) f) {
			for (; (fi < imx) && ((fi * fj) < (int) f); fi++)
				;
			for (; (fj < imy) && ((fi * fj) < (int) f); fj++)
				;
		}
		wx *= fi;
		wx += ax;
		wy *= fj;
		wy += ay;
	}
	wx = max(wx, (14 * tb.ch_w));
	wy = max(wy, (7 * tb.ch_h));
	if (!conf.autosizey)
		wy = win->work.h;
	if (!conf.autosizex)
		wx = win->work.w;

	/* Auf maximale Grîûe begrenzen */
	wind_calc(WC_BORDER, win->flags, 0, 0, wx, wy, &x, &y, &wx, &wy);
	if (wx > maxw)
		wx = maxw;
	if (wy > maxh)
		wy = maxh;

#if 0 
	/* GegenÅber vorheriger Position zentrieren */
	win->full.x=win->curr.x+(win->curr.w-wx)/2;
	win->full.y=win->curr.y+(win->curr.h-wy)/2;
#else
	win->full.x = win->curr.x;
	win->full.y = win->curr.y;
	if ((win->full.x + wx) > (tb.desk.x + tb.desk.w))
		win->full.x = tb.desk.x + tb.desk.w - wx;
	if ((win->full.y + wy) > (tb.desk.y + tb.desk.h))
		win->full.y = tb.desk.y + tb.desk.h - wy;
#endif
	if (win->full.x < minx)
		win->full.x = minx;
	if (win->full.y < miny)
		win->full.y = miny;

	win->full.w = wx;
	win->full.h = wy;
	if (win->full.x + wx > minx + maxw)
		win->full.x = minx + maxw - wx;
	if (win->full.y + wy > miny + maxh)
		win->full.y = miny + maxh - wy;

	if (!(win->state & WSOPEN) || (win->state & WSICON)) {
		RECT *what;

		what = (win->state & WSICON) ? &win->save : &win->curr;
		what->x = win->full.x;
		what->y = win->full.y;
		what->w = win->full.w;
		what->h = win->full.h;
	} else
		win_full(win);
}

/*-------------------------------------------------------------------------
 wc_icon()

 Rubberframe-Koordinaten fÅr Icon/Texte berechnen
 -------------------------------------------------------------------------*/
void wc_icon(int *pxy, int *x, int *y, int *w, int *h, int ix, int iw, int tx,
		int ty, int tw) {
	/* Anpassung an Beschriftung */
	if (tw < iw) {
		/* Text kleiner als Icon */
		*x += ix;
		*w = iw;
		tx -= ix;
		ix = 0;
	} else {
		/* Text groesser oder gleich gross wie Icon */
		*x += tx;
		*w = tw;
		ix -= tx;
		tx = 0;
	}

	/* Auf Desktop begrenzen */
	if (*x < tb.desk.x)
		*x = tb.desk.x;
	if (*y < tb.desk.y)
		*y = tb.desk.y;

	if (*x + *w > tb.desk.x + tb.desk.w)
		*x = tb.desk.x + tb.desk.w - *w;
	if (*y + *h > tb.desk.y + tb.desk.h)
		*y = tb.desk.y + tb.desk.h - *h;

	/* Polygonzug berechnen */
	pxy[0] = *x + ix;
	pxy[1] = *y;
	pxy[2] = pxy[0] + iw - 1;
	pxy[3] = *y;
	pxy[4] = pxy[2];
	pxy[5] = *y + ty;
	pxy[6] = *x + tx + tw - 1;
	pxy[7] = pxy[5];
	pxy[8] = pxy[6];
	pxy[9] = *y + *h - 1;
	pxy[10] = *x + tx;
	pxy[11] = pxy[9];
	pxy[12] = pxy[10];
	pxy[13] = pxy[5];
	pxy[14] = pxy[0];
	pxy[15] = pxy[5];
	pxy[16] = pxy[0];
	pxy[17] = *y;
}

void wc_text(int *pxy, int *x, int *y, int *w, int *h) {
	/* Auf Desktop begrenzen */
	if (*x < tb.desk.x)
		*x = tb.desk.x;
	if (*y < tb.desk.y)
		*y = tb.desk.y;

	if (*x + *w > tb.desk.x + tb.desk.w)
		*x = tb.desk.x + tb.desk.w - *w;
	if (*y + *h > tb.desk.y + tb.desk.h)
		*y = tb.desk.y + tb.desk.h - *h;

	/* Polygonzug berechnen */
	pxy[0] = *x;
	pxy[1] = *y;
	pxy[2] = *x + *w - 1;
	pxy[3] = pxy[1];
	pxy[4] = pxy[2];
	pxy[5] = *y + *h - 1;
	pxy[6] = pxy[0];
	pxy[7] = pxy[5];
	pxy[8] = pxy[0];
	pxy[9] = pxy[1];
}

static void draw_minicicon(ICONIMG *ic, int *pxy, int sel) {
	OBJECT mini_icon;
	USERBLK block;
	int ext_out[57];
	RECT clip, pos;

	pos.x = pxy[4];
	pos.y = pxy[5];
	pos.w = pxy[6] - pxy[4] + 1;
	pos.h = pxy[7] - pxy[5] + 1;
	mini_icon.ob_next = mini_icon.ob_head = mini_icon.ob_tail = -1;
	mini_icon.ob_type = G_USERDEF;
	mini_icon.ob_flags = LASTOB;
	mini_icon.ob_state = sel ? SELECTED : NORMAL;
	block.ub_code = ic->sub_code;
	block.ub_parm = (long) ic->scblk;
	mini_icon.ob_spec.index = (long) &block;

	/*
	 * Die Bitmap des Icons ist innerhalb des Gesamticons u. U.
	 * versetzt, also die Position entsprechend berechnen
	 */
	mini_icon.ob_x = pos.x - ic->siconblk->ib_xicon;
	mini_icon.ob_y = pos.y - ic->siconblk->ib_yicon;
	mini_icon.ob_width = pos.w + ic->siconblk->ib_xicon;
	mini_icon.ob_height = pos.h + ic->siconblk->ib_yicon;
	vq_extnd(tb.vdi_handle, 1, ext_out);
	clip.x = ext_out[45];
	clip.y = ext_out[46];
	clip.w = ext_out[47] - ext_out[45] + 1;
	clip.h = ext_out[48] - ext_out[46] + 1;
	if (rc_intersect(&clip, &pos)) /* Ueberhaupt sichtbar? */
		objc_draw(&mini_icon, ROOT, 0, pos.x, pos.y, pos.w, pos.h);
}
