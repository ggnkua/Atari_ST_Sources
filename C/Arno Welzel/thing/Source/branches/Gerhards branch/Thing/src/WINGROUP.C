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
 WINGROUP.C

 Thing
 Gruppenfenster
 =========================================================================*/

#include "..\include\globdef.h"
#include "..\include\types.h"
#include "rsrc\thing.h"
#include "rsrc\thgtxt.h"
#include <ctype.h>
#include <time.h>

/**-------------------------------------------------------------------------
 wgrp_open()

 ôffnen einer Gruppe
 -------------------------------------------------------------------------*/
short wgrp_open(char *name, WININFO *uwin, unsigned long wait) {
	WININFO *win;
	W_GRP *wgrp;
	WG_ENTRY *new = NULL;
	GFONT font;
	char etitle[MAX_FLEN], ename[MAX_PLEN], eparm[MAX_PLEN];
	char inbuf[1024], *inbuf5 = &inbuf[5], *tx;
	unsigned long id;
	FILE *fh;
	short x, y, w, h, n, i, b, fok, cok, gtaok, aclok, grok, bpok;
	char tbuf[33];
	double lx, ly, lw, lh;
	short realwin = 1;

	/* Falls die Gruppe schon auf ist, dann nur nach vorne holen */
	win = tb.win;
	while (win) {
		if (win->state&WSOPEN && win->class == WCGROUP) {
			wgrp = (W_GRP *) win->user;
			if (!strcmp(wgrp->name, name)) {
				if (win->state & WSICON)
					win_unicon(win, win->save.g_x, win->save.g_y, win->save.g_w, win->save.g_h);
				win_top(win);
				mn_check();
				return (1);
			}
		}
		win = win->next;
	}

	if (uwin) { /* Vorhandenes Fenster verwenden */
		win = uwin;
		if (wait == 'SND2') {
			wait = realwin = 0;
			if ((win->user = pmalloc(sizeof(W_GRP))) == NULL)
				return (0);
			goto newgrp;
		}
	} else { /* Neues Fenster einrichten */
		/* Default-Zeichensatz: von Verzeichnisfenstern */
		font.id = conf.font.id;
		font.size = conf.font.size;
		font.fcol = conf.font.fcol;
		font.bcol = conf.font.bcol;
		font.attr = (0);

		win = pmalloc(sizeof(WININFO));
		if (!win) { /* Kein Speicher mehr */
			frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
			return (0);
		}
		win->user = pmalloc(sizeof(W_GRP));
		if (!win->user) { /* Kein Speicher mehr */
			pfree(win);
			frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
			return (0);
		}
		win->name[0] = 0;
		win->info[0] = 0;
		win->class = WCGROUP;
		win->flags = CLOSER | MOVER | FULLER | SIZER | NAME | UPARROW | DNARROW | VSLIDE;
		if (conf.hscr)
			win->flags |= LFARROW | RTARROW | HSLIDE;

		/* Zusatzelemente - je nach System */
		if (tb.sys & SY_MAGX)
			win->flags |= BACKDROP;

		if (tb.sys & SY_ICONIFY)
			win->flags |= SMALLER;
		win->state = WSDESKSIZE;
		win->update = gwin_update;
		win->prepare = gwin_prepare;
		win->redraw = gwin_redraw;
		win->slide = gwin_slide;
		win->ictree = rs_trindex[ICONPATH];
		if (!win_open(win, 0)) { /* Keine GEM-Fenster mehr verfÅgbar ? */
			pfree(win->user);
			pfree(win);
			graf_mouse(ARROW, 0L);
			frm_alert(1, rs_frstr[ALNOWIN], altitle, conf.wdial, 0L);
			return (0);
		}
		newgrp: wgrp = win->user;

		wgrp->ext = 0;
		wgrp->getattr = realwin;
		wgrp->autoclose = 0;
		strcpy(wgrp->parent, "");
		strcpy(wgrp->name, name);
		wgrp->changed = 0;
		wgrp->e_num = 0;
		wgrp->text = conf.index.text;
		wgrp->entry = 0L;
		wgrp->tree = 0L;
		wgrp->wicon = 0L;
		wgrp->offx = wgrp->offy = 0;
		wgrp->focus = 0;
		wgrp->fcol16 = font.fcol;
		wgrp->bcol16 = font.bcol;
		wgrp->bpat = wgrp->bpat16 = 7;
		if (tb.colors < 16) {
			wgrp->fcol = font.fcol;
			wgrp->bcol = font.bcol;
		} else {
			wgrp->fcol = G_BLACK;
			wgrp->bcol = G_WHITE;
		}
		wgrp->img_info = glob.img_info;
		strcpy(wgrp->img, "");
		wgrp->img_planes = 32767;
		wgrp->img_ok = 0;
	}

	graf_mouse(BUSYBEE, 0L);

	/* Gruppendatei îffnen */
	fh = fopen(name, "r");
	fok = cok = gtaok = aclok = bpok = 0;
	if (!fh) {
grouperr:
		if (realwin)
			win_close(win);
		while (wgrp->entry)
			wgrp_remove(wgrp, wgrp->entry);
		pfree(wgrp);
		if (realwin)
			pfree(win);
		if (realwin || (fh != NULL)) {
			sprintf(almsg, rs_frstr[ALOPENGROUP], name);
			graf_mouse(ARROW, 0L);
			frm_alert(1, almsg, altitle, conf.wdial, 0L);
		}
		return (0);
	} else {
		grok = 0;
		while (!feof(fh)) {
			if (fgets(inbuf, 1024, fh)) {
				eparm[0] = 0;
				/* Kommentare ignorieren */
				if (inbuf[0] != '#') {
					id = *(unsigned long *) inbuf;
					if (id == 'INFO') {
						/* Gruppentitel und Fensterkoordinaten */
						grok = 1;
						if (realwin) {
							tx = get_text(inbuf5, wgrp->title, MAX_FLEN - 1);
							sscanf(tx, "%d %d %d %d %d %d", &x, &y, &w, &h, &wgrp->text, &wgrp->autosave);
							lx = (double) tb.desk.g_w * (double) x / 10000L;
							x = tb.desk.g_x + (short) (lx + 0.5);
							ly = (double) tb.desk.g_h * (double) y / 10000L;
							y = tb.desk.g_y + (short) (ly + 0.5);
							lw = (double) tb.desk.g_w * (double) w / 10000L;
							w = (short) (lw + 0.5);
							lh = (double) tb.desk.g_h * (double) h / 10000L;
							h = (short) (lh + 0.5);
							n = tb.desk.g_x + tb.desk.g_w - 16;
							if (x > n)
								x = n;
							n = tb.desk.g_y + tb.desk.g_h - 16;
							if (y > n)
								y = n;
							if (w > tb.desk.g_w)
								w = tb.desk.g_w;
							if (h > tb.desk.g_h)
								h = tb.desk.g_h;
							win->curr.g_x = x;
							win->curr.g_y = y;
							win->curr.g_w = w;
							win->curr.g_h = h;
							wind_calc(WC_WORK, win->flags, x, y, w, h, &win->work.g_x, &win->work.g_y, &win->work.g_w, &win->work.g_h);
							win->name[0] = 0;
							wgrp_title(win);
						}
					}
					if (realwin && (id == 'IGTA')) {
						/* Attribute ermitteln? */
						gtaok = 1;
						sscanf(inbuf5, "%d", &wgrp->getattr);
					}
					if (id == 'IACL') {
						/* Automatisch schlieûen? */
						aclok = 1;
						sscanf(inbuf5, "%d", &wgrp->autoclose);
					}
					if (id == 'PRNT') {
						/* Vaterobjekt */
						wgrp->parent[MAX_PLEN - 1] = 0;
						strncpy(wgrp->parent, inbuf5, MAX_PLEN - 1);
						if (strlen(wgrp->parent)) {
							tx = &wgrp->parent[strlen(wgrp->parent) - 1];
							if (*tx == '\n')
								*tx = 0;
						}
					}
					if (realwin && (id == 'FONT')) {
						/* Zeichensatz etc. */
						sscanf(inbuf5, "%d %d %d %d", &font.id, &font.size, &wgrp->fcol16, &wgrp->bcol16);
						if (font.size < 1)
							font.size = 1;
						wgrp->fcol16 &= 15;
						wgrp->bcol16 &= 15;
						/* PrÅfen, ob der Zeichensatz vorhanden ist */
						fok = 0;
						for (i = 0; i < gdos.numfonts; i++)
							if (gdos.fontid[i * 2L] == font.id)
								fok = 1;
						if (!fok) {
							/* Zeichensatz nicht verfÅgbar ... */
							font.id = vqt_name(tb.vdi_handle, 1, tbuf);
							if (tb.ch_h == 8)
								font.size = 9;
							else
								font.size = 10;
							frm_alert(1, rs_frstr[ALNOGFONT], altitle, conf.wdial, 0L);
						}
					}
					if (id == 'FCOL') {
						/* Zeichenfarben fÅr < 16 Farben */
						cok = 1;
						sscanf(inbuf5, "%d %d", &wgrp->fcol, &wgrp->bcol);
						wgrp->fcol &= 1;
						wgrp->bcol &= 1;
					}
					if (id == 'BPAT') {
						/* Pattern fÅr Hintergrund */
						bpok = 1;
						sscanf(inbuf5, "%d %d", &wgrp->bpat, &wgrp->bpat16);
						wgrp->bpat &= 7;
					}
					if (realwin && (id == 'BPIC')) {
						/* Bild fÅr Hintergrund */
						if (get_buf_entry(inbuf5, wgrp->img, &tx))
							sscanf(tx, "%d", &wgrp->img_planes);
						else
							strcpy(wgrp->img, "");
					}
					if (id == 'OFIL') {
						/* Datei */
						new = NULL;
						tx = get_text(inbuf, etitle, MAX_FLEN - 1);
						/*      sscanf(tx,"%s",ename);*/
						if (get_buf_entry(tx, ename, &tx)) {
							get_text(tx, eparm, MAX_PLEN - 1);
							if (!strstr(ename, "\\\\"))
								new = wgrp_add(wgrp, 0L, EC_FILE, etitle, ename, eparm);
						}
					}
					if (id == 'OFLD') {
						/* Ordner */
						new = NULL;
						tx = get_text(inbuf, etitle, MAX_FLEN - 1);
						if (get_buf_entry(tx, ename, 0L) && get_buf_entry(0L, tx, 0L)) {
							get_text(tx, eparm, MAX_PLEN - 1);
							if (!strstr(ename, "\\\\")) {
								i = 0;
								b = 0;
								while (ename[i]) {
									if (ename[i] == '\\')
										b++;
									i++;
								}
								if (b)
									new = wgrp_add(wgrp, 0L, EC_FOLDER, etitle, ename, eparm);
							}
						}
					}

					/* Optionen fÅr das zuletzt eingetragene Gruppenobjekt */
					if ((id == 'OOPT') && (new != NULL))
						sscanf(inbuf5, "%d", &new->paralways);
					if ((id != 'OFIL') && (id != 'OFLD'))
						new = NULL;
				}
			}
		}
		fclose(fh);
		if (!grok)
			goto grouperr;
		graf_mouse(ARROW, 0L);

		/* Objektbaum erzeugen und Fenster îffnen */
		if (realwin) {
			wgrp->font.id = font.id;
			wgrp->font.size = font.size;
			if (tb.colors < 16) {
				wgrp->font.fcol = wgrp->fcol;
				wgrp->font.bcol = wgrp->bcol;
			} else {
				wgrp->font.fcol = wgrp->fcol16;
				wgrp->font.bcol = wgrp->bcol16;
			}
			wgrp->font.attr = 0;
			wgrp_tree(win);

			/* Mausklicks auch im Hintergrund */
			if (conf.bsel)
				wind_set(win->handle, WF_BEVENT, 1, 0, 0, 0);

			/* Hintergrundbild */
			if (wgrp->img_planes <= tb.planes) {
				wgrp->img_ok = desk_iload(&wgrp->img_info, wgrp->img, 0, ALIMGERR);
			}
			if (!wgrp->img_ok)
				strcpy(wgrp->img, "");

			win_updtinfo(win);
			win_open(win, 1);
			/*
			 * Falls noch keine FONT-, BPAT-, IGTA- oder FCOL-Zeile drin war,
			 * dann fuer's Speichern sorgen
			 */
			if (!fok || !cok || !gtaok || !aclok || !bpok)
				wgrp_change(win);
			mn_check();
		}
	}

	return 1;
}

/**-------------------------------------------------------------------------
 wgrp_add()

 Gruppen-Eintrag hinzufÅgen
 -------------------------------------------------------------------------*/
WG_ENTRY *wgrp_add(W_GRP *wgrp, WG_ENTRY *gprev, short class, char *title, char *name, char *parm) {
	WG_ENTRY *entry,*eptr;

	/* Speicher reservieren */
	entry = pmalloc(sizeof(WG_ENTRY));
	if (!entry)
		return 0L;

	/* Listenverkettung */
	if (!gprev) {
		/* Kein spezieller Nachfolger angegeben */
		entry->next=0L;
		if (!wgrp->entry) {
			/* Liste bisher leer */
			wgrp->entry=entry;
			entry->prev=0L;
		} else {
			/* An das Ende der Liste anhÑngen */
			eptr=wgrp->entry;
			while(eptr->next) eptr=eptr->next;
			eptr->next=entry;
			entry->prev=eptr;
		}
	} else {
		/* Spezieller Eintrag als Nachfolger angegeben */
		if(!gprev->prev) {
			wgrp->entry = entry;
			entry->prev = 0L;
		} else {
			eptr = gprev->prev;
			eptr->next = entry;
			entry->prev = eptr;
		}
		entry->next = gprev;
		gprev->prev = entry;
	}
	/* Daten eintragen */
	wgrp->e_num++;
	entry->sel = entry->prevsel = 0;
	entry->class = class;
	strcpy(entry->title, title);
	strcpy(entry->name, name);
	strcpy(entry->parm, parm);
	entry->paralways = 0;
	wgrp_eupdate(wgrp, entry);

	return (entry);
}

/**-------------------------------------------------------------------------
 wgrp_remove()

 Gruppen-Eintrag entfernen
 -------------------------------------------------------------------------*/
void wgrp_remove(W_GRP *wgrp, WG_ENTRY *item) {
	WG_ENTRY *eprev, *enext;

	eprev = item->prev;
	enext = item->next;

	/* Aus der Liste entfernen */
	if (!eprev) {
		/* Kein Vorgaenger - dann erster Eintrag ! */
		wgrp->entry = enext;
		if (enext)
			enext->prev = 0L;
	} else {
		/* Vorgaenger vorhanden */
		eprev->next = enext;
		if (enext)
			enext->prev = eprev;
	}
	/* Reservierten Speicher freigeben */
	pfree(item);

	wgrp->e_num--;
}

/**-------------------------------------------------------------------------
 wgrp_eupdate()

 Verschiedene Daten (Icon etc.) eines Gruppen-Eintrags initialisieren
 -------------------------------------------------------------------------*/
void wgrp_eupdate(W_GRP *grp, WG_ENTRY *item) {
	ICONIMG *icon, *ticon;
	short inum, i, j;
	char *p;
	char name[MAX_FLEN], wename[MAX_FLEN], xname[MAX_PLEN];
	short isdrive;

	p = item->name;
	isdrive = wild_match1("[A-Za-z]:\\", p);
	i = (short) strlen(p) - 1;
	if (i > 0) {
		if (p[i] == '\\')
			i--;
	}
	while (p[i] != '\\' && i > 0)
		i--;
	if (p[i] == '\\')
		i++;
	j = 0;
	while (p[i] && p[i] != '\\') {
		name[j] = p[i];
		wename[j] = nkc_toupper(p[i]);
		i++;
		j++;
	}
	name[j] = 0;
	wename[j] = 0;

	wgrp_eabs(grp, item, xname);
	item->aptype = grp->getattr ? is_appl(xname) : is_app(xname, 0);

	ticon = 0L;
	inum = 0;
	while (inum < desk.maxicon) {
		icon = &desk.icon[inum];
		if ((icon->class == 2) && isdrive && (*icon->mask == *item->name)) {
			ticon = icon;
			break;
		}
		if ((icon->class == 0 && (item->class == EC_FILE || item->class == EC_DEVICE)) || (icon->class == 1 && item->class == EC_FOLDER)) {
			if (wild_match1(icon->mask, wename)) {
				ticon = icon;
				break;
			} else
				inum++;
		} else
			inum++;
	}
	if (!ticon) {
		switch (item->class) {
			case EC_DEVICE:
				ticon = &desk.ic_dev;
				break;
			case EC_FILE:
				if (item->aptype)
					ticon= &desk.ic_appl;
				else {
					if (wild_match1(GRP_MASK, wename))
						ticon = &desk.ic_grp;
					else
						ticon = &desk.ic_file;
				}
				break;
			case EC_FOLDER:
				ticon = &desk.ic_folder;
				break;
			case EC_PARENT:
				ticon = &desk.ic_parent;
				break;
		}
	}
	item->iconimg = ticon;
	item->tchar = ticon->tchar;
	item->tcolor = ticon->tcolor;
	if (item->tcolor == -1) {
		switch (item->class) {
			case EC_DEVICE:
				item->tcolor = desk.ic_dev.tcolor;
				break;
			case EC_FILE:
				if (item->aptype)
					item->tcolor = desk.ic_appl.tcolor;
				else if (wild_match1(GRP_MASK, wename))
					item->tcolor = desk.ic_grp.tcolor;
				else
					item->tcolor = desk.ic_file.tcolor;
				break;
			case EC_FOLDER:
				item->tcolor = desk.ic_folder.tcolor;
				break;
		}
	}
}

/**-------------------------------------------------------------------------
 wgrp_update()

 Update alle EintrÑge einer Gruppe (z.B. nach dem Laden von Icons)
 -------------------------------------------------------------------------*/
void wgrp_update(WININFO *win) {
	W_GRP *wgrp;
	WG_ENTRY *entry;

	wgrp = (W_GRP *) win->user;
	entry = wgrp->entry;
	while (entry) {
		wgrp_eupdate(wgrp, entry);
		entry = entry->next;
	}
}

/**-------------------------------------------------------------------------
 wgrp_title()

 Aktualisieren des Fenstertitels einer Gruppe
 -------------------------------------------------------------------------*/
void wgrp_title(WININFO *win) {
	W_GRP *wgrp;
	char title[MAX_FLEN + 2];
	short doup;

	wgrp = (W_GRP *) win->user;
	if (wgrp->changed)
		sprintf(title, "* %s", wgrp->title);
	else
		sprintf(title, " %s ", wgrp->title);
	if (strcmp(title, win->name) != 0) {
		doup = 1;
		strcpy(win->name, title);
	} else
		doup = 0;
	if ((win->state & WSOPEN) && doup)
		win_updtinfo(win);
}

/**-------------------------------------------------------------------------
 wgrp_tfree()

 Durch Objektbaum belegten Speicher freigeben.
 -------------------------------------------------------------------------*/
void wgrp_tfree(WININFO *win) {
	W_GRP *wgrp;

	wgrp = (W_GRP *) win->user;

	/* Bisherigen Objektbaum freigeben */
	if (wgrp->wicon) {
		pfree(wgrp->wicon);
		wgrp->wicon = 0L;
	}
	if (wgrp->tree) {
		pfree(wgrp->tree);
		wgrp->tree = 0L;
	}
}

/**-------------------------------------------------------------------------
 wgrp_tree()

 Baut den Objektbaum eines Gruppenfensters neu auf.
 -------------------------------------------------------------------------*/
void wgrp_tree(WININFO *win) {
	W_GRP *wgrp;
	OBJECT *tree;
	ICONBLK *iblk, *tiblk;
	short i, n, mx, my, nx, ix, iy, iw, ih;
	short tx, tw, ob;
	short out[8], namelen;
	WG_ENTRY *entry;

	/* Bisherigen Objektbaum freigeben */
	wgrp_tfree(win);
	wgrp = (W_GRP *) win->user;

	ob = 1; /* Objektnummer der Eintraege */

	/* Bei Textdarstellung keinen Objektbaum erzeugen */
	if (wgrp->text) {
		vst_font(tb.vdi_handle, wgrp->font.id);
		if (wgrp->font.size < 0) {
			vst_height(tb.vdi_handle, -wgrp->font.size, &wgrp->cw, &wgrp->ch, &wgrp->clw, &wgrp->clh);
		} else {
			vst_point(tb.vdi_handle, wgrp->font.size, &wgrp->cw, &wgrp->ch, &wgrp->clw, &wgrp->clh);
		}
		/* Workaround fuer Problem mit STEmulator + NVDI Atari */
		v_gtext(tb.vdi_handle, 0, 0, "");

		/* Bei Symboltext Mindesthîhe fÅr Symbole */
		wgrp->ch = wgrp->clh;
		if (wgrp->text == 2) {
			if (wgrp->clh < glob.sheight)
				wgrp->clh = glob.sheight;
		}

		/* Breite eines Eintrages in Pixeln berechnen */
		wgrp->ih = wgrp->clh;
		if (wgrp->clw < wgrp->clh / 2)
			wgrp->iw = wgrp->clw * 2;
		else
			wgrp->iw = wgrp->clh;

		/* Bei Symboltext Mindestbreite der Symbolspalte */
		if (wgrp->text == 2) {
			if (wgrp->iw < 20)
				wgrp->iw = 20;
		}

		wgrp->tlen = wgrp->clw; /* Linker Rand */
		wgrp->tlen += wgrp->iw + wgrp->clw / 2 + 1; /* Icon fuer Ordner */

		/* Neues Feature: Anpassen der Darstellung an den breitesten Eintrag */
		namelen = 0;
		entry = wgrp->entry;
		while (entry) {
			vqt_extent(tb.vdi_handle, entry->title, out);
			n = out[2] - out[0];
			if (n > namelen)
				namelen = n;

			/* Objektnummer setzen */
			entry->obnum = ob;
			ob++;

			entry = entry->next;
		}
		if (!namelen)
			namelen = wgrp->clw;

		wgrp->tlen += namelen; /* Titel */
		wgrp->tlen += wgrp->clw + 1; /* Rechter Rand */

		mx = (win->work.g_w - 10 + 2 * wgrp->clw) / wgrp->tlen;
		if (mx == 0)
			mx = 1;
		my = wgrp->e_num / mx;
		if ((wgrp->e_num - my * mx) > 0)
			my++;
		wgrp->imx = mx;
		wgrp->imy = my;
		return;
	}

	/* Neuen Objektbaum erzeugen */
	tree = pmalloc(sizeof(OBJECT) * (long) (wgrp->e_num + 1));
	if (!tree) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return;
	}
	wgrp->tree = tree;

	/* Fensterhintergrund */
	tree[0].ob_next = -1;
	tree[0].ob_head = -1;
	tree[0].ob_tail = -1;
	tree[0].ob_type = G_BOX;
	tree[0].ob_flags = LASTOB;
	tree[0].ob_state = NORMAL;
	tree[0].ob_spec.obspec.framesize = 0;
	tree[0].ob_spec.obspec.framecol = 0;
	tree[0].ob_spec.obspec.fillpattern = (tb.colors < 16) ? wgrp->bpat : wgrp->bpat16;
	tree[0].ob_spec.obspec.interiorcol = wgrp->font.bcol;
	tree[0].ob_x = win->work.g_x;
	tree[0].ob_y = win->work.g_y;
	tree[0].ob_width = win->work.g_w;
	tree[0].ob_height = win->work.g_h;

	if (wgrp->e_num < 1)
		return;

	/* Verzeichniseintraege */
	if (wgrp->text) {
		/* Als Text */
	} else {
		wgrp->wicon = pmalloc(sizeof(WICON) * (long) wgrp->e_num);
		if (!wgrp->wicon) {
			wgrp_tfree(win);
			frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
			return;
		}

		/* Iconraster X berechnen */
		namelen = 0;
		iw = 32;
		ih = 2;
		entry = wgrp->entry;
		while (entry) {
			n = calc_small_text_width(entry->title);
			if (n > namelen)
				namelen = n;
			/* Ergaenzung: Maximale Iconhoehe/-breite ermitteln und ggf. 'namelen' anpassen */
			tiblk = entry->iconimg->iconblk;
			if (tiblk->ib_hicon > ih)
				ih = tiblk->ib_hicon;
			if (tiblk->ib_wicon > iw)
				iw = tiblk->ib_wicon;

			entry = entry->next;
		}
		ih += 1;
		ih &= ~1;
		iw += 1;
		iw &= ~1;
		n = namelen + 8;
		/* Ergaenzung: Falls Icons breiter als Text, dann anpassen */
		if (iw > n)
			n = iw;

		wgrp->tlen = namelen = n;

		/* Breite der Icon-Texte */
		tw = namelen - 4;

		mx = win->work.g_w / namelen; /* Anzahl der Icons pro Zeile */
		if (mx > wgrp->e_num)
			mx = wgrp->e_num;
		if (!mx)
			mx = 1;
		wgrp->imx = mx;

		/* Hintergrund anpassen */
		tree[0].ob_head = 1;
		tree[0].ob_tail = wgrp->e_num;
		tree[0].ob_flags = NONE;
		if (mx * namelen > win->work.g_w)
			tree[0].ob_width = mx * namelen;

		nx = 0;
		ix = 0;
		iy = 0;
		entry = wgrp->entry;
		for (i = 0; i < wgrp->e_num; i++) {
			n = i + 1;
			tree[n].ob_head = -1;
			tree[n].ob_tail = -1;
			if (n < wgrp->e_num) {
				tree[n].ob_next = n + 1;
				tree[n].ob_flags = NONE;
			} else {
				tree[n].ob_next = 0;
				tree[n].ob_flags = LASTOB;
			}
			if (entry->sel)
				tree[n].ob_state = SELECTED;
			else
				tree[n].ob_state = NORMAL;
			if (namelen < 76)
				tree[n].ob_width = 76;
			else
				tree[n].ob_width = namelen;

			icn_setimg(&wgrp->wicon[i], &tree[n], entry->iconimg, entry->title);
			iblk = &wgrp->wicon[i].ciconblk.monoblk;
			iblk->ib_char = 0x1000;
			iblk->ib_xchar = 0;
			iblk->ib_ychar = 0;
			if (entry->class == EC_FOLDER) {
				if (wild_match1("[A-Za-z]:\\", entry->name)) {
					iblk->ib_char = 0x1000 | toupper(*entry->name);
					iblk->ib_xchar = entry->iconimg->iconblk->ib_xchar;
					iblk->ib_ychar = entry->iconimg->iconblk->ib_ychar;
				}
			}
			iblk->ib_xicon = (namelen - iblk->ib_wicon) / 2;
			iblk->ib_yicon = 0;
			tx = (namelen - tw) / 2;
			iblk->ib_xtext = tx;
			iblk->ib_ytext = (iblk->ib_hicon + 1) & ~1;
			iblk->ib_wtext = tw;
			iblk->ib_htext = tb.fs_ch + 2;
			tree[n].ob_height = iblk->ib_ytext + tb.fs_ch + 2;
			tree[n].ob_x = ix + 2;
			tree[n].ob_y = iy + 4 + (ih - iblk->ib_ytext);

			ix += namelen;
			nx++;
			if (nx >= mx) {
				nx = 0;
				ix = 0;
				iy += (ih + 2 * tb.fs_ch + 4);
			}

			/* Objektnummer setzen */
			entry->obnum = ob;
			ob++;
			entry = entry->next;
		}

		/* Anzahl der Zeilen erst hier bekannt */
		ih += 2 * tb.fs_ch + 4;
		my = iy / ih + 1;
		if (nx == 0)
			my--;
		wgrp->imy = my;
		tree[0].ob_height = my * ih;
		wgrp->ih = ih;
	}
}

/**-------------------------------------------------------------------------
 wgrp_esel()

 Selektiert einen oder mehrere EintrÑge in einem Gruppenfenster
 -------------------------------------------------------------------------*/
void wgrp_esel1(WININFO *win, WG_ENTRY *entry, short sel, GRECT *wrect, short *rd) {
	short x, y, w, h, n, osel, yg;
	W_GRP *wgrp;
	OBJECT *tree;
	ICONBLK *iconblk;

	wgrp = (W_GRP *) win->user;
	tree = wgrp->tree;
	osel = entry->sel; /* Bisherigen Status sichern */
	if (!entry->prevsel)
		entry->sel = sel; /* Status aendern, wenn mîglich */

	/* Eintrag neuzeichnen, wenn der Status geaendert wurde und
	 der Eintrag nicht auch durch 'prevsel' selektiert ist */
	if (osel != entry->sel && !entry->prevsel) {
		n = entry->obnum;

		if (wgrp->text) {
			/* Darstellung als Text */
			yg = (n - 1) / wgrp->imx;
			x = (n - 1 - yg * wgrp->imx) * wgrp->tlen + win->work.g_x + 10 - wgrp->offx;
			y = yg * (wgrp->clh + 1) + win->work.g_y + 2 - wgrp->offy;

			w = wgrp->tlen - wgrp->clw * 2;
			h = wgrp->clh;
		} else {
			/* Darstellung als Icons */
			iconblk = &wgrp->wicon[n - 1].ciconblk.monoblk;

			if (entry->sel)
				tree[n].ob_state |= SELECTED;
			else
				tree[n].ob_state &= ~SELECTED;
			x = tree->ob_x + tree[n].ob_x;
			y = tree->ob_y + tree[n].ob_y;
			w = tree[n].ob_width;
			h = tree[n].ob_height;
			if (iconblk->ib_xtext < iconblk->ib_xicon) {
				x += iconblk->ib_xtext;
				w = iconblk->ib_wtext;
			}
		}

		if (*rd == 0) {
			/* Koordinaten fuer Redraw anpassen */
			*rd = 1;
			wrect->g_x = x;
			wrect->g_y = y;
			wrect->g_w = w;
			wrect->g_h = h;
		} else {
			if (x < wrect->g_x) {
				wrect->g_w += (wrect->g_x - x);
				wrect->g_x = x;
			}
			if (x + w > wrect->g_x + wrect->g_w)
				wrect->g_w = x + w - wrect->g_x;
			if (y < wrect->g_y) {
				wrect->g_h += (wrect->g_y - y);
				wrect->g_y = y;
			}
			if (y + h > wrect->g_y + wrect->g_h)
				wrect->g_h = y + h - wrect->g_y;
		}
	}
}

/**
 * 
 */
void wgrp_esel(WININFO *win, WG_ENTRY *entry, short add, short sel) {
	W_GRP *wgrp;
	WG_ENTRY *item;
	GRECT wrect;
	short rd, i;

	wgrp = (W_GRP *) win->user;
	rd = 0;

	if (!entry) {
		/* Alle EintrÑge bearbeiten */
		item = wgrp->entry;
		for (i = 0; i < wgrp->e_num; i++) {
			if (item->class==EC_PARENT)
				wgrp_esel1(win, item, 0, &wrect, &rd);
			else
				wgrp_esel1(win, item, sel, &wrect, &rd);
			item = item->next;
		}
		if (rd)
			win_redraw(win, wrect.g_x, wrect.g_y, wrect.g_w, wrect.g_h);
	} else {
		/* Einzelnen Eintrag bearbeiten */
		if (!add) {
			/* Vorher alle EintrÑge deselektieren */
			item = wgrp->entry;
			for (i = 0; i < wgrp->e_num; i++) {
				if (item != entry)
					wgrp_esel1(win, item, 0, &wrect, &rd);
				item = item->next;
			}
			if (rd)
				win_redraw(win, wrect.g_x, wrect.g_y, wrect.g_w, wrect.g_h);
			rd = 0;
		}
		/* Status Ñndern */
		wgrp_esel1(win, entry, sel, &wrect, &rd);
		if (rd)
			win_redraw(win, wrect.g_x, wrect.g_y, wrect.g_w, wrect.g_h);
	}
}

/**-------------------------------------------------------------------------
 wgrp_showsel()

 Scrollt den Fensterinhalt bei Bedarf, damit die selektierten EintrÑge
 sichtbar sind.
 -------------------------------------------------------------------------*/
void wgrp_showsel(WININFO *win, short doscroll) {
	short rd, n, sx, sy;
	short x, y, w, h, yg;
	GRECT wrect, irect;
	W_GRP *wgrp;
	WG_ENTRY *item;
	short dx, i, c;

	rd = 0;
	wgrp = (W_GRP *) win->user;
	if (!wgrp->e_num)
		return;

	/* Ggf. Cursor berÅcksichtigen */
	if (glob.fmode && glob.fwin == win)
		c = wgrp->focus;
	else
		c = -1;

	/* Linker Rand fÅr Textdarstellung */
	if (wgrp->text)
		dx = 10;
	else
		dx = 0;
	item = wgrp->entry;
	i = 0;
	while (item) {
		if ((c == -1 && item->sel) || c == i) {
			/* Koordinaten berechnen */
			n = item->obnum;
			if (wgrp->text) {
				yg = (n - 1) / wgrp->imx;
				x = (n - 1 - yg * wgrp->imx) * wgrp->tlen + win->work.g_x + 10 - wgrp->offx;
				y = yg * (wgrp->clh + 1) + win->work.g_y + 2 - wgrp->offy;

				w = wgrp->tlen - wgrp->clw * 2;
				h = wgrp->clh;
			} else {
				x = wgrp->tree->ob_x + wgrp->tree[n].ob_x;
				y = wgrp->tree->ob_y + wgrp->tree[n].ob_y;
				w = wgrp->tree[n].ob_width;
				h = wgrp->tree[n].ob_height;
			}
			if (!rd) {
				rd = 1;
				irect.g_x = x;
				irect.g_y = y;
				irect.g_w = w;
				irect.g_h = h;
			} else {
				if (x < irect.g_x) {
					irect.g_w += (irect.g_x - x);
					irect.g_x = x;
				}
				if (x + w > irect.g_x + irect.g_w)
					irect.g_w = x + w - irect.g_x;
				if (y < irect.g_y) {
					irect.g_h += (irect.g_y - y);
					irect.g_y = y;
				}
				if (y + h > irect.g_y + irect.g_h)
					irect.g_h = y + h - irect.g_y;
			}
		}
		item = item->next;
		i++;
	}

	/* Fensterarbeitsbereich */
	memcpy(&wrect, &win->work, sizeof(GRECT));

	/* Scroll */
	if (rd) {
		wrect.g_x += dx;
		wrect.g_w -= dx;
		sx = wrect.g_x - irect.g_x;
		sy = wrect.g_y - irect.g_y;
		if (sy <= 0) {
			if (irect.g_h > wrect.g_h)
				irect.g_h = wrect.g_h;
			if (irect.g_y + irect.g_h > wrect.g_y + wrect.g_h)
				sy = -(irect.g_y - wrect.g_y - wrect.g_h + irect.g_h);
			else
				sy = 0;
		}
		if (sx <= 0) {
			if (irect.g_w > wrect.g_w)
				irect.g_w = wrect.g_w;
			if (irect.g_x + irect.g_w > wrect.g_x + wrect.g_w)
				sx = -(irect.g_x - wrect.g_x - wrect.g_w + irect.g_w);
			else
				sx = 0;
		}
		if (sx != 0 || sy != 0) {
			if (doscroll)
				win_slide(win, S_PABS, sx, sy);
			else {
				wgrp->offx -= sx;
				wgrp->offy -= sy;
				win_slide(win, S_INIT, 0, 0);
			}
		}
	}
}

/**-------------------------------------------------------------------------
 wgrp_efind()

 Ermittelt das Objekt, das an der angegebenen Position liegt, sowie
 das Objekt, das vor der Position liegt (z.B. fÅr das Umsortieren
 per D&D).
 Ist x gleich -1, wird die Nummer des ersten im Fenster sichtbaren
 Objektes + 1 geliefert.
 -------------------------------------------------------------------------*/
WG_ENTRY *wgrp_efind(WININFO *win, short x, short y, WG_ENTRY **prev) {
	W_GRP *wgrp;
	WG_ENTRY * item, *this, *lprev;
	OBJECT *tree;
	ICONBLK *iblk;
	short i, j, px, py;
	short ix, iw, ih, tx, ty, tw, th;
	short mx, my, onum;

	wgrp = (W_GRP *) win->user;
	lprev = this = 0L;

	/* Absolute Koordinaten innerhalb der Arbeitsflaeche */
	mx = x - win->work.g_x - wgrp->offx;
	my = y - win->work.g_y - wgrp->offy;

	/* Falls ikonifiziert oder keine Objekte, dann raus */
	if (win->state & WSICON || wgrp->e_num == 0) {
		*prev = 0L;
		return (0L);
	}

	/* Nur innerhalb des Arbeitsbereichs des Fensters suchen */
	if ((x == -1) || (x >= win->work.g_x && x <= win->work.g_x + win->work.g_w - 1 && y >= win->work.g_y && y <= win->work.g_y + win->work.g_h - 1)) {
		tree = wgrp->tree;

		if (wgrp->text) {
			/* Eintraege als Text */
			/* Objektnummer gemaess der absoluten Koordinaten berechnen */
			if (mx >= wgrp->imx * wgrp->tlen)
				mx = wgrp->imx * wgrp->tlen - 1;
			onum = mx / wgrp->tlen;
			onum += (my / (wgrp->clh + 1)) * wgrp->imx;
			onum++;

			item = wgrp->entry;
			i = 0;
			while (item) {
				ty = i / wgrp->imx;
				px = (i - ty * wgrp->imx) * wgrp->tlen + win->work.g_x + 10 - wgrp->offx;
				py = ty * (wgrp->clh + 1) + win->work.g_y + 2 - wgrp->offy;

				if (x == -1) {
					if (py >= win->work.g_y)
						return ((WG_ENTRY *) (i + 1));
				} else {
					iw = wgrp->tlen - wgrp->clw * 2;
					ih = wgrp->clh;

					/* Ist dieses Objekt genau an der Position? */
					if (x >= px && x <= px + iw - 1 && y >= py && y <= py + ih - 1)
						this = item;

					/* Ist es das neue Zielobjekt? */
					if (item->obnum == onum)
						lprev = item;
				}
				item = item->next;
				i++;
			}
		} else {
			/* Eintraege als Icons */
			if (!tree) {
				*prev = 0L;
				return 0L;
			}

			/* Objektnummer gemaess der absoluten Koordinaten berechnen */
			if (mx >= wgrp->imx * wgrp->tlen)
				mx = wgrp->imx * wgrp->tlen - 1;
			onum = mx / wgrp->tlen;
			onum += (my / wgrp->ih) * wgrp->imx;
			onum++;

			item = wgrp->entry;
			j = 1;
			while (item) {
				i = item->obnum;
				px = tree->ob_x + tree[i].ob_x;
				py = tree->ob_y + tree[i].ob_y;
				if (x == -1) {
					if (py >= win->work.g_y)
						return ((WG_ENTRY *) j);
				} else {
					iblk = &wgrp->wicon[i - 1].ciconblk.monoblk;
					ix = iblk->ib_xicon;
					iw = iblk->ib_wicon;
					ih = iblk->ib_hicon;
					tx = iblk->ib_xtext;
					ty = iblk->ib_ytext;
					tw = iblk->ib_wtext;
					th = iblk->ib_htext;

					/* Innerhalb des Textes ? */
					if (x >= px + tx && x <= px + tx + tw - 1 && y >= py + ty && y <= py + ty + th - 1)
						this = item;

					/* Innerhalb des Images ? */
					if (x >= px + ix && x <= px + ix + iw - 1 && y >= py && y <= py + ih)
						this = item;

					/* Ist es das neue Zielobjekt? */
					if (item->obnum == onum)
						lprev = item;
				}
				item = item->next;
				j++;
			}
		}
	}

	*prev = lprev;
	return (this);
}

/**-------------------------------------------------------------------------
 wgrp_change()

 Setzt das 'Changed'-Flag einer Gruppe und speichert diesse ggf.
 automatisch ab
 -------------------------------------------------------------------------*/
void wgrp_change(WININFO *win) {
	W_GRP *wgrp;

	wgrp = (W_GRP *) win->user;
	if (!wgrp->changed) {
		wgrp->changed = 1;
		wgrp_title(win);
	}
}

/**-------------------------------------------------------------------------
 wgrp_eabs()

 Wandelt einen Eintrag in einen absoluten Dateinamen um
 -------------------------------------------------------------------------*/
void wgrp_eabs(W_GRP *wgrp, WG_ENTRY *entry, char *buf) {
	char *p, *abs;

	switch (entry->class) {
		case EC_FILE:
		case EC_FOLDER:
			if (entry->name[1] !=':') {
				strcpy(buf, wgrp->name);
				p = strrchr(buf, '\\');
				if (p)
					p = &p[1];
				else
					p = buf;
				if (entry->name[0] == '\\')
					strcpy(p, &entry->name[1]);
				else
					strcpy(p, entry->name);
				if (!rel2abs(buf, &abs)) {
					buf[MAX_PLEN - 1] = 0;
					strncpy(buf, abs, MAX_PLEN - 1);
					free(abs);
				}
			} else
				strcpy(buf, entry->name);
			break;

		default:
			buf[0] = 0;
	}
}

/**-------------------------------------------------------------------------
 wgrp_edrag()

 Drag&Drop der Gruppenobjekte
 -------------------------------------------------------------------------*/
void wgrp_edrag(short mx, short my, short mk, short ks) {
	short lmx, lmy, lmk, lks;
	short *pxy, *obnum;
	short i, n, pn, px, py;
	short p, x, y, w, h, ix, iw, tx, ty, tw;
	short tx1, ty1, tx2, ty2;
	short otx, oty;
	short obj, obj1, whandle, drag, drag1;
	short moved = 0;
	WININFO *win, *iwin, *iwin1;
	ACWIN *accwin;
	WP_ENTRY *item, *item1;
	WG_ENTRY *gitem, *gitem1, *gprev;
	short yg, wx, wy;
	W_GRP *wgrp;
	WG_ENTRY *litem;
	GRECT irect, wrect;
	short wrd, first;
	ICONBLK *iblk;
	XATTR xattr;
	FILESYS fs;

	lmx = mx;
	lmy = my;
	lmk = mk;
	lks = ks;
	wgrp = (W_GRP *) desk.sel.win->user;
	wx = desk.sel.win->work.g_x;
	wy = desk.sel.win->work.g_y;

	/* Aktuelle Auswahl sichern und Anzahl selektierter Objekte ermitteln */
	n = 0;
	litem = wgrp->entry;
	while (litem) {
		litem->prevsel = litem->sel;
		if (litem->sel)
			n++;
		litem = litem->next;
	}

	/* Polygone fuer die Darstellung am Bildschirm aufbauen */
	if (wgrp->text)
		pxy = pmalloc(sizeof(short) * n * 10); /* Text: Je Eintrag 5 xy-Punkte */
	else
		pxy = pmalloc(sizeof(short) * n * 18); /* Icons: Je Icon 9 xy-Punkte */
	if (!pxy) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return;
	}
	obnum = pmalloc(sizeof(short) * n); /* Objektnummern */
	if (!obnum) {
		pfree(pxy);
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return;
	}

	tx1 = tb.desk.g_x + tb.desk.g_w; /* t... Position/Maûe des Gesamtrechtecks */
	ty1 = tb.desk.g_y + tb.desk.g_h;
	tx2 = ty2 = 0;

	p = 0;
	litem = wgrp->entry;
	while (litem) {
		if (litem->sel) {
			obnum[p] = litem->obnum;
			i = litem->obnum - 1;
			if (wgrp->text) {
				/* Im Textmodus */
				/* Koordinaten/Maûe holen */
				yg = i / wgrp->imx;
				x = (i - yg * wgrp->imx) * wgrp->tlen + wx + 10 - wgrp->offx;
				y = yg * (wgrp->clh + 1) + wy + 2 - wgrp->offy;
				w = wgrp->tlen - wgrp->clw * 2;
				if (w > tb.desk.g_w)
					w = tb.desk.g_w;
				h = wgrp->clh;
				if (h > tb.desk.g_h)
					h = tb.desk.g_h;
				irect.g_x = x;
				irect.g_y = y;
				irect.g_w = w;
				irect.g_h = h;
				/* Nur verwenden, wenn Icon sichtbar */
				if (rc_intersect(&tb.desk, &irect) && rc_intersect(&desk.sel.win->work, &irect)) {
					/* Polygonzug berechnen */
					wc_text(&pxy[p * 10], &x, &y, &w, &h);

					/* Gesamtrechteck anpassen */
					if (x < tx1)
						tx1 = x;
					if (y < ty1)
						ty1 = y;
					if (x + w > tx2)
						tx2 = x + w;
					if (y + h > ty2)
						ty2 = y + h;

					p++;
				}
			} else {
				/* Als Icons */
				/* Koordinaten/Maûe holen */
				objc_offset(wgrp->tree, i + 1, &x, &y);
				w = wgrp->tree[i + 1].ob_width;
				h = wgrp->tree[i + 1].ob_height;
				iblk = &wgrp->wicon[i].ciconblk.monoblk;
				ix = iblk->ib_xicon;
				iw = iblk->ib_wicon;
				tx = iblk->ib_xtext;
				ty = iblk->ib_ytext;
				tw = iblk->ib_wtext;
				irect.g_x = x;
				irect.g_y = y;
				irect.g_w = w;
				irect.g_h = h;
				/* Nur verwenden, wenn Icon sichtbar */
				if (rc_intersect((GRECT *)&tb.desk, (GRECT *)&irect) && rc_intersect((GRECT *)&desk.sel.win->work, (GRECT *)&irect)) {
					/* Polygonzug berechnen */
					wc_icon(&pxy[p * 18], &x, &y, &w, &h, ix, iw, tx, ty, tw);
					p++;
					/* Gesamtrechteck anpassen */
					if (x < tx1)
						tx1 = x;
					if (y < ty1)
						ty1 = y;
					if (x + w > tx2)
						tx2 = x + w;
					if (y + h > ty2)
						ty2 = y + h;
				}
			}
		}
		litem = litem->next;
	}
	n = p;
	otx = tx1;
	oty = ty1; /* Ausgangskoordinaten merken */

	/* Auf gehts ... */
	x = lmx;
	y = lmy;
	obj = obj1 = -1;
	iwin = iwin1 = 0L;
	item = item1 = 0L;
	gitem = gitem1 = 0L;
	win = desk.sel.win;
	accwin = 0L;
	drag = drag1 = 1;
	first = 1;
	whandle = desk.sel.win->handle;
	wind_update (BEG_MCTRL);
	graf_mouse(FLAT_HAND, 0L);
	if (wgrp->text)
		rub_ticon(n, pxy);
	else
		rub_icon(n, pxy);
	while (lmk & 3) {
		if (1) /*if(x!=lmx || y!=lmy)*//* Mausposition verÑndert ? */
		{
			evnt_timer(10L);
			first = 0;
			/* xy-Delta berechnen */
			w = lmx - x;
			h = lmy - y;
			/* Verschiebung des Gesamtrechtecks auf Desktopbereich begrenzen */
			if (tx1 + w < tb.desk.g_x)
				w = tb.desk.g_x - tx1;
			if (ty1 + h < tb.desk.g_y)
				h = tb.desk.g_y - ty1;
			if (tx2 + w > tb.desk.g_x + tb.desk.g_w)
				w = (tb.desk.g_x + tb.desk.g_w) - tx2;
			if (ty2 + h > tb.desk.g_y + tb.desk.g_h)
				h = (tb.desk.g_y + tb.desk.g_h) - ty2;

			/* Nur aktualisieren, wenn xy-Delta != 0 */
			if (w != 0 || h != 0) {
				/* Lîschen */
				if (wgrp->text)
					rub_ticon(n, pxy);
				else
					rub_icon(n, pxy);

				/* Anhand von xy-Delta verschieben */
				tx1 += w;
				ty1 += h;
				tx2 += w;
				ty2 += h;
				if (wgrp->text)
					for (i = 0; i < n * 5; i++) {
						pxy[i * 2] += w;
						pxy[i * 2 + 1] += h;
					}
				else
					for (i = 0; i < n * 9; i++) {
						pxy[i * 2] += w;
						pxy[i * 2 + 1] += h;
					}
				/* Zeichnen */
				if (wgrp->text)
					rub_ticon(n, pxy);
				else
					rub_icon(n, pxy);
			}

			/* Maus Åber einem Fenster ? */
			whandle = wind_find(lmx, lmy);
			if (whandle) {
				/* Ja */
				drag = 1;
				/* Bisher selektiertes Desktop-Objekt deselektieren */
				if (obj != -1) {
					if (wgrp->text)
						rub_ticon(n, pxy);
					else
						rub_icon(n, pxy);
					icon_select(obj1, 1, 0);
					if (wgrp->text)
						rub_ticon(n, pxy);
					else
						rub_icon(n, pxy);
					obj = -1;
				}
				/* Fenster ermitteln */
				win = win_getwinfo(whandle);
				if (win) {
					/* Fenster bekannt -> dann Drag&Drop in Fenster */
					switch (win->class) {
					case WCCON: /* Console */
						drag = 0;
						break;
					case WCPATH: /* Verzeichnisfenster */
						gitem = 0L;
						iwin = win; /* Fenster merken */
						if (drag_scroll(lmy, w, h, moved, iwin, n, pxy, wgrp->text ? rub_ticon : rub_icon)) {
							item = 0L;
							break;
						}
						item = wpath_efind(win, lmx, lmy); /* Objekt ermitteln */
						if (item) {
							if (desk.sel.devices || desk.sel.printer)
								drag = 0;
							switch(item->class) {
							case EC_FILE: /* Datei */
								/* .... aber kein Programm */
								if (!item->aptype) {
									/* Evtl. indirekt angemeldet */
									if (!app_isdrag(item->name))
										item = 0L; /* Nein */
								}
								break;
							case EC_DEVICE: /* Auf Device nur einzelne Datei */
								if (desk.sel.files>1 || desk.sel.drives || desk.sel.folders || desk.sel.clip || desk.sel.trash)
									drag = 0; /* item=0L; */
								break;
							}
						} else if (desk.sel.devices || desk.sel.printer)
							drag = 0;
						if (!drag)
							item = 0L;
						break;
					case WCGROUP:
						item = 0L;
						iwin = win; /* Fenster merken */
						if (drag_scroll(lmy, w, h, moved, iwin, n, pxy, wgrp->text ? rub_ticon : rub_icon)) {
							gitem = 0L;
							break;
						}
						if (desk.sel.devices)
							drag = 0;
						else {
							gitem = wgrp_efind(win, lmx, lmy, &gprev); /* Objekt ermitteln */
							if (gitem) {
								if (!gitem->prevsel) {
									/* Nur wenn Objekt nicht zur Gruppe gehîrt */
									switch (gitem->class) {
									case EC_FILE: /* Datei */
										/* .... aber kein Programm */
										if (!gitem->aptype) {
											/* Evtl. indirekt angemeldet */
											if (!app_isdrag(gitem->name))
												gitem = 0L; /* Nein */
										}
										break;
									}
								}
							}
						}
						break;
					case WCDIAL:
						item = 0L;
						gitem = 0L;
						if (desk.sel.numobs > 1 || desk.sel.trash || desk.sel.printer || desk.sel.clip)
							drag = 0;
						break;
					}
				} else {
					/* Fenster nicht bekannt - eventuell Acc-Fenster ? */
					item = 0L;
					gitem = 0L;
					accwin = acwin_find(whandle);
					/* Es kînnen nur Dateien, Ordner oder Laufwerke in ein
					 Accessory-Fenster gelegt werden */
					if (desk.sel.trash || desk.sel.clip || desk.sel.printer || desk.sel.devices)
						drag = 0;
					else
						drag = 1;
				}
				/* Bisher selektiertes Zielobjekt deselektieren und ggf.
				 neues Zielobjekt selektieren */
				if (item != item1) {
					if (wgrp->text)
						rub_ticon(n, pxy);
					else
						rub_icon(n, pxy);
					if (item1 != 0L)
						wpath_esel(iwin1, item1, 1, 0, 0);
					if (item != 0L)
						wpath_esel(iwin, item, 1, 1, 0);
					if (wgrp->text)
						rub_ticon(n, pxy);
					else
						rub_icon(n, pxy);
				}
				if (gitem != gitem1) {
					if (wgrp->text)
						rub_ticon(n, pxy);
					else
						rub_icon(n, pxy);
					if (gitem1 != 0L)
						wgrp_esel(iwin1, gitem1, 1, 0);
					if (gitem != 0L)
						wgrp_esel(iwin, gitem, 1, 1);
					if (wgrp->text)
						rub_ticon(n, pxy);
					else
						rub_icon(n, pxy);
				}
			} else {
				/* Maus nicht Åber einem Fenster */
				/* Bisheriges Fenster-Objekt deselektieren */
				if (item || gitem) {
					if (wgrp->text)
						rub_ticon(n, pxy);
					else
						rub_icon(n, pxy);
					if (item) {
						wpath_esel(iwin, item, 1, 0, 0);
						item = 0L;
					}
					if (gitem) {
						wgrp_esel(iwin, gitem, 1, 0);
						gitem = 0L;
					}
					if (wgrp->text)
						rub_ticon(n, pxy);
					else
						rub_icon(n, pxy);
				}
				win = 0L;
				accwin = 0L;
				obj = icon_find(lmx, lmy);
				if (obj != -1) {
					drag = 1;
					/* PrÅfen, ob das Objekt als Zielobjekt verwendet werden kann,
					 und ggf. auf NIL (-1) setzen, wenn dies nicht mîglich ist */
					if (desk.dicon[obj].prevsel)
						obj = -1;
					else {
						switch (desk.dicon[obj].class) {
						case IDDRIVE:
						case IDFOLDER:
							if (desk.sel.trash || desk.sel.clip || desk.sel.printer || desk.sel.devices)
								obj = -1;
							break;
						case IDFILE:
							if (!is_app(desk.dicon[obj].spec.file->name, desk.dicon[obj].spec.file->mode)) {
								/* Evtl. indirekt angemeldet */
								if (!app_isdrag(desk.dicon[obj].spec.file->name))
									obj = -1; /* Nein */
							}
							if (desk.sel.trash || desk.sel.clip || desk.sel.printer || desk.sel.devices)
								obj = -1;
							break;
						case IDCLIP:
							if (desk.sel.numobs > 1 || desk.sel.folders || desk.sel.drives || desk.sel.trash || desk.sel.printer || desk.sel.devices)
								obj = -1;
							break;
						case IDTRASH:
							if (desk.sel.drives && (desk.sel.files || desk.sel.folders))
								obj = -1;
							break;
						case IDDEVICE:
							if (desk.sel.files > 1 || desk.sel.drives || desk.sel.folders || desk.sel.clip || desk.sel.trash || desk.sel.printer || desk.sel.devices)
								obj = -1;
							break;
							case IDPRT:
							if(desk.sel.files > 1 || desk.sel.drives || desk.sel.folders || desk.sel.clip || desk.sel.trash || desk.sel.devices)
								obj = -1;
							break;
						}
						if (obj == -1)
							drag = 0;
					}
				} else {
					if (lmx < tb.desk.g_x || lmy < tb.desk.g_y)
						drag = 0;
					else
						drag = 1;
				}
				/* Bisher selektiertes Zielobjekt deselektieren und ggf.
				 neues Zielobjekt selektieren */
				if (obj != obj1) {
					if (wgrp->text)
						rub_ticon(n, pxy);
					else
						rub_icon(n, pxy);
					if (obj1 != -1)
						icon_select(obj1, 1, 0);
					if (obj != -1)
						icon_select(obj, 1, 1);
					if (wgrp->text)
						rub_ticon(n, pxy);
					else
						rub_icon(n, pxy);
				}
			}
			/* Neue Position berechnen */
			x += w;
			y += h;
			/* Zielobjekte auf dem Desktop/Fenster merken */
			obj1 = obj;
			iwin1 = iwin;
			item1 = item;
			gitem1 = gitem;
		}
		if (drag != drag1) {
			drag1 = drag;
			if (!drag)
				graf_mouse(USER_DEF, &mf_no);
			else
				graf_mouse(FLAT_HAND, 0L);
		}
		graf_mkstate(&lmx, &lmy, &lmk, &lks);
		moved = h | moved;
	}
	if (wgrp->text)
		rub_ticon(n, pxy);
	else
		rub_icon(n, pxy);
	graf_mouse(ARROW, 0L);
	wind_update (END_MCTRL);

	if (obj != -1)
		icon_select(obj, 1, 0); /* Zielobjekte deselektieren */
	if (item)
		wpath_esel(iwin, item, 1, 0, 0);
	if (gitem)
		wgrp_esel(iwin, gitem, 1, 0);

	/* Gesicherte Auswahl wiederherstellen */
	litem = wgrp->entry;
	while (litem) {
		litem->sel = litem->prevsel;
		litem->prevsel = 0;
		litem = litem->next;
	}

	if (obj != -1) {
		/* Zielobjekt auf dem Desktop ? */
		dl_ddrag(&desk.dicon[obj], lks);
	} else {
		/* Kein Zielobjekt auf dem Desktop */
		if (whandle) {
			/* Fenster ? */
			if (win) {
				/* Eigenes Fenster ? */
				if (drag) {
					if (!first) {
						if (!gitem || item)
							dl_wdrag(win, item, gitem, gprev, lmx, lmy, lks);
						else if (!gitem->sel)
							dl_wdrag(win, item, gitem, gprev, lmx, lmy, lks);
					}
				} else
					mybeep();
			} else {
				/* Accessory ? */
				if (drag)
					dl_awdrag(accwin, whandle, lmx, lmy, lks);
				else
					mybeep();
			}
		} else {
			/* kein Zielfenster - dann Icons auf den Desktop legen */
			short jumps = 0;

			if (drag) {
				/* Ablegen mîglich ? */
				/* Ja ... */
				i = OBUSER;
				p = 0;
				wrd = 0;

				/* FÅr Textdarstellung, Position fÅr Plazierung merken */
				otx = lmx - tb.desk.g_x - 40;
				if (otx < 0)
					otx = 0;
				oty = lmy - tb.desk.g_y - 20;
				if (oty < 0)
					oty = 0;
				px = otx;
				py = oty;
				pn = 0;

				/* Position/Maûe des Gesamtrechtecks fÅr Desktop-Redraw */
				tx1 = tb.desk.g_x + tb.desk.g_w;
				ty1 = tb.desk.g_y + tb.desk.g_h;
				tx2 = ty2 = 0;

				/* Freies Desktop-Icon suchen */
				while (desk.dicon[i].class != IDFREE && i <= MAXICON)
					i++;

				litem = wgrp->entry;
				while (litem && p < n) {
					while (litem->obnum != obnum[p]) {
						if (litem->sel)
							wgrp_esel1(desk.sel.win, litem, 0, &wrect, &wrd);
						litem = litem->next;
					}
					if (litem->sel) {
						if (i > MAXICON) {
							/* Kein Icon mehr frei ? */
							frm_alert(1, rs_frstr[ALDESKFULL], altitle, conf.wdial, 0L);
							litem = 0L;
						} else {
							/* Spezifische Daten Åbertragen */
							switch (litem->class) {
							case EC_FILE:
								desk.dicon[i].class = IDFILE;
								desk.dicon[i].spec.file = pmalloc(sizeof(D_FILE));
								if(desk.dicon[i].spec.file) {
									wgrp_eabs(wgrp, litem,desk.dicon[i].spec.file->name);
									fsinfo(desk.dicon[i].spec.file->name, &fs);
									if (!(fs.flags & UNIXATTR) || (Fxattr(0, desk.dicon[i].spec.file->name, &xattr) != 0))
										xattr.mode = 0;
									desk.dicon[i].spec.file->mode = xattr.mode;
								}
								break;
							case EC_DEVICE:
								desk.dicon[i].class = IDDEVICE;
								desk.dicon[i].spec.device = pmalloc(sizeof(D_DEVICE));
								if (desk.dicon[i].spec.device)
									wgrp_eabs(wgrp, litem, desk.dicon[i].spec.device->name);
								break;
							case EC_FOLDER:
								if (wild_match1("[A-Za-z]:\\", litem->name)) {
									desk.dicon[i].class = IDDRIVE;
									desk.dicon[i].spec.drive = pmalloc(sizeof(D_DRIVE));
									if (desk.dicon[i].spec.drive) {
										desk.dicon[i].spec.drive->drive = toupper(*litem->name) - 'A';
									}
								} else {
									desk.dicon[i].class = IDFOLDER;
									desk.dicon[i].spec.folder = pmalloc(sizeof(D_FOLDER));
									if (desk.dicon[i].spec.folder)
										wgrp_eabs(wgrp, litem, desk.dicon[i].spec.folder->path);
								}
								break;
							}
							/* War kein Speicher mehr frei ? */
							if(!desk.dicon[i].spec.data) {
								desk.dicon[i].class = IDFREE;
								frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
								litem=  0L;
							} else {
								/* Allgemeine Daten des Icons Åbertragen */
								strcpy(desk.dicon[i].title, litem->title);
								desk.dicon[i].select = 1;
								desk.dicon[i].prevsel = 0;
								if (wgrp->text) {
									if (px + 76 > tb.desk.g_w)
										px = tb.desk.g_w - 76;
									if (py + 40 > tb.desk.g_h)
										py = tb.desk.g_h - 40;
									desk.dicon[i].x = px;
									desk.dicon[i].y = py;
									px += 80;
									pn++;
									if (px + 76 > tb.desk.g_w || pn >= wgrp->imx) {
										pn = 0;
										px = otx + jumps * 80;
										py += 48;
										if ((py + 48) > tb.desk.g_h) {
											py = oty;
											px += 80 * wgrp->imx;
											jumps += wgrp->imx;
										}
									}
								} else {
									iblk = &wgrp->wicon[litem->obnum-1].ciconblk.monoblk;
									desk.dicon[i].x = pxy[p * 18 + 0] + iblk->ib_wicon / 2;
									desk.dicon[i].y = pxy[p * 18 + 1] - tb.desk.g_y;
								}
								icon_update(i);
								objc_offset(rs_trindex[DESKTOP], i, &x, &y);
								w=rs_trindex[DESKTOP][i].ob_width;
								h=rs_trindex[DESKTOP][i].ob_height;
								/* Gesamtrechteck anpassen */
								if (x < tx1)
									tx1 = x;
								if (y < ty1)
									ty1 = y;
								if (x + w > tx2)
									tx2 = x + w;
								if(y + h > ty2)
									ty2 = y + h;

								wgrp_esel1(desk.sel.win, litem, 0, &wrect, &wrd);

								/* NÑchstes freies Icon suchen */
								while (desk.dicon[i].class != IDFREE && i<= MAXICON)
									i++;
								p++;

								/* ErgÑnzen: Ggf. Icon aus der Gruppe entfernen */
							}
							if (litem)
								litem = litem->next;
						}
					} else {
						if (litem)
							litem = litem->next;
					}
				}

				litem = wgrp->entry;
				while (litem) {
					if (litem->sel)
						wgrp_esel1(desk.sel.win, litem, 0, &wrect, &wrd);
					litem = litem->next;
				}
				if (wrd)
					win_redraw(desk.sel.win, wrect.g_x, wrect.g_y, wrect.g_w, wrect.g_h);

				/* ErgÑnzen: Ggf. berÅcksichtigen, dass Icons aus der Gruppe entfernt wurden */

				desk_draw(tx1, ty1, tx2 - tx1 + 1, ty2 - ty1 + 1);
			} else
				mybeep(); /* Ablegen war nicht mîglich */
		}
	}

	/* Finito ... */pfree(obnum);
	pfree(pxy);
}

/**-------------------------------------------------------------------------
 wgrp_exsel()

 Auswahl mit "Gummiband" in einem Gruppenfenster
 -------------------------------------------------------------------------*/
short wgrp_einrect(W_GRP *wgrp, short wx, short wy, WG_ENTRY *ob, GRECT *rect) {
	OBJECT *tree;
	ICONBLK *iblk;
	GRECT irect;
	short px, py, yg, is_in, n;

	if (!wgrp->e_num)
		return (0);

	n = ob->obnum;

	if (wgrp->text) {
		/* Darstellung als Text */
		yg = (n - 1) / wgrp->imx;
		irect.g_x = (n - 1 - yg * wgrp->imx) * wgrp->tlen + wx + 10 - wgrp->offx;
		irect.g_y = yg * (wgrp->clh + 1) + wy + 2 - wgrp->offy;

		irect.g_w = wgrp->tlen - wgrp->clw * 2;
		irect.g_h = wgrp->clh;
		is_in = rc_intersect(rect, &irect);
	} else {
		/* Darstellung als Icons */
		tree = wgrp->tree;
		if (!tree)
			return 0;

		iblk = &wgrp->wicon[n - 1].ciconblk.monoblk;
		px = tree->ob_x + tree[n].ob_x;
		py = tree->ob_y + tree[n].ob_y;
		is_in = 0;

		/* Text-Bereich */
		irect.g_x = px + iblk->ib_xtext;
		irect.g_y = py + iblk->ib_ytext;
		irect.g_w = iblk->ib_wtext;
		irect.g_h = iblk->ib_htext;
		if (rc_intersect(rect, &irect))
			is_in = 1;

		/* Image-Bereich */
		irect.g_x = px + iblk->ib_xicon;
		irect.g_y = py;
		irect.g_w = iblk->ib_wicon;
		irect.g_h = iblk->ib_hicon;
		if (rc_intersect(rect, &irect))
			is_in = 1;
	}

	return (is_in);
}

void wgrp_exsel(WININFO *win, short mx, short my, short mk, short ks) {
	W_GRP *wgrp;
	WG_ENTRY *item;
	OBJECT *tree;
	short lmx, lmy, lmk, lks;
	short i, rd, dx, dy;
	GRECT sel, sel2, rsel, wrect, crect;
	short rxy[4], cxy[4], dn;
	short offx, offy, maxx, maxy;

	wgrp = (W_GRP *) win->user;
	tree = wgrp->tree;

	lmx = mx;
	lmy = my;
	lmk = mk;
	lks = ks;

	/* Clipping-Rechteck fuer Gummiband */
	crect = win->work;
	rc_intersect(&tb.desk, &crect);
	cxy[0] = crect.g_x;
	cxy[1] = crect.g_y;
	cxy[2] = cxy[0] + crect.g_w - 1;
	cxy[3] = cxy[1] + crect.g_h - 1;

	/* Maximale Offsets berechnen */
	if (wgrp->e_num == 0 || (!wgrp->text && !tree)) {
		maxx = 0;
		maxy = 0;
	} else {
		if (wgrp->text) {
			maxx = wgrp->tlen * wgrp->imx + 20 - wgrp->clw * 2 - win->work.g_w;
			maxy = wgrp->imy * (wgrp->clh + 1) + 3 - win->work.g_h;
		} else {
			maxx = tree->ob_width - win->work.g_w;
			maxy = tree->ob_height - win->work.g_h;
		}
	}

	/* Bisherigen Status der Objekte sichern */
	item = wgrp->entry;
	while (item) {
		item->prevsel = item->sel;
		item = item->next;
	}

	/* Startrechteck merken */
	sel.g_x = sel2.g_x = lmx;
	sel.g_y = sel2.g_y = lmy;
	sel.g_w = sel.g_h = 0;

	/* Auf gehts ... */
	graf_mouse(POINT_HAND, 0L);
	vs_clip(tb.vdi_handle, 1, cxy);
	rub_frame(&sel);
	while (lmk & 3) {
		/* Neue Mausposition holen */
		graf_mkstate(&lmx, &lmy, &lmk, &lks);
		/* Neues Auswahlrechteck berechnen */
		sel2.g_w = lmx - sel.g_x + 1;
		sel2.g_h = lmy - sel.g_y + 1;
		/* Begrenzung auf Fenster */
		if (sel2.g_y + sel2.g_h - 1 < crect.g_y)
			sel2.g_h = crect.g_y - sel2.g_y + 1;
		if (sel2.g_y + sel2.g_h > crect.g_y + crect.g_h)
			sel2.g_h = crect.g_y + crect.g_h - sel2.g_y;
		if (sel2.g_x + sel2.g_w - 1 < crect.g_x)
			sel2.g_w = crect.g_x - sel2.g_x + 1;
		if (sel2.g_x + sel2.g_w > crect.g_x + crect.g_w)
			sel2.g_w = crect.g_x + crect.g_w - sel2.g_x;
		/* Bei Aenderung oder Scroll Auswahlrechteck neu zeichnen */
		dn = 0;
		/* ... énderung des Auswahlrechtecks */
		if (sel.g_w != sel2.g_w || sel.g_h != sel2.g_h)
			dn = 1;
		/* ... Scroll */
		offx = wgrp->offx;
		offy = wgrp->offy;
		dx = dy = 0;
		if (lmx < crect.g_x && offx > 0)
			dx = crect.g_x - lmx;
		if (lmy < crect.g_y && offy > 0)
			dy = crect.g_y - lmy;
		if (lmx > crect.g_x + crect.g_w - 1 && offx < maxx)
			dx = (crect.g_x + crect.g_w - 1) - lmx;
		if (lmy > crect.g_y + crect.g_h - 1 && offy < maxy)
			dy = (crect.g_y + crect.g_h - 1) - lmy;
		dx *= conf.scroll;
		dy *= conf.scroll;
		if (dx != 0 || dy != 0)
			dn = 1;

		if (dn) {
			/* Lîschen und neue Maûe verwenden */
			vs_clip(tb.vdi_handle, 1, cxy);
			rub_frame(&sel);
			sel.g_w = sel2.g_w;
			sel.g_h = sel2.g_h;

			/* Fenster scrollen, wenn nîtig */
			if (dx != 0 || dy != 0) {
				win_slide(win, S_PABS, dx, dy);
				dx = offx - wgrp->offx;
				dy = offy - wgrp->offy;
				sel.g_x += dx;
				sel.g_w -= dx;
				sel.g_y += dy;
				sel.g_h -= dy;
				sel2 = sel;
			}
			vs_clip(tb.vdi_handle, 1, cxy);
			rub_frame(&sel);

			/* Icons im Auswahlbereich selektieren */
			rxy[0] = sel.g_x;
			rxy[1] = sel.g_y;
			rxy[2] = sel.g_x + sel.g_w - 1;
			rxy[3] = sel.g_y + sel.g_h - 1;
			if (rxy[2] < rxy[0]) {
				i = rxy[2];
				rxy[2] = rxy[0];
				rxy[0] = i;
			}
			if (rxy[3] < rxy[1]) {
				i = rxy[3];
				rxy[3] = rxy[1];
				rxy[1] = i;
			}
			rsel.g_x = rxy[0];
			rsel.g_y = rxy[1];
			rsel.g_w = rxy[2] - rxy[0] + 1;
			rsel.g_h = rxy[3] - rxy[1] + 1;

			rd = 0;
			item = wgrp->entry;
			while (item) {
				short psel;

				if (wgrp_einrect(wgrp, win->work.g_x, win->work.g_y, item, &rsel)) {
					if (!item->sel && !item->prevsel)
						wgrp_esel1(win, item, 1, &wrect, &rd);
					else if (item->sel && item->prevsel) {
						item->prevsel = 0;
						wgrp_esel1(win, item, 0, &wrect, &rd);
						item->prevsel = 1;
					}
				} else {
					psel = item->prevsel;
					item->prevsel = 0;
					wgrp_esel1(win, item, psel, &wrect, &rd);
					item->prevsel = psel;
				}
				item = item->next;
			}

			if (rd) {
				vs_clip(tb.vdi_handle, 1, cxy);
				rub_frame(&sel);
				win_redraw(win, wrect.g_x, wrect.g_y, wrect.g_w, wrect.g_h);
				vs_clip(tb.vdi_handle, 1, cxy);
				rub_frame(&sel);
			}
		}
	}
	vs_clip(tb.vdi_handle, 1, cxy);
	rub_frame(&sel);
	vs_clip(tb.vdi_handle, 0, cxy);
	graf_mouse(ARROW, 0L);

	/* Bisherigen Status der Objekte loeschen */
	item = wgrp->entry;
	while (item) {
		item->prevsel = 0;
		item = item->next;
	}
}
