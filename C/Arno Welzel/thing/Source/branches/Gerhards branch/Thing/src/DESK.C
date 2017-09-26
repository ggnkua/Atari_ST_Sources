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
 DESK.C

 Thing
 Desktopverwaltung
 =========================================================================*/

#include "..\include\globdef.h"
#include "..\include\types.h"
#include "rsrc\thing.h"
#include "rsrc\thgtxt.h"
#include <ctype.h>
#include <basepage.h>

/*-------------------------------------------------------------------------
 desk_init()

 Initialisiert den Desktop
 -------------------------------------------------------------------------*/
void desk_init(void) {
	ICONBLK *iblk;
	short i;
	OBJECT *tree;
	ICONDESK *p;

	tree = rs_trindex[DESKTOP];
	/* Grîûe und Position anpassen */
	tree->ob_x = tb.desk.g_x;
	tree->ob_y = tb.desk.g_y;
	tree->ob_width = tb.desk.g_w;
	tree->ob_height = tb.desk.g_h;

	/* Desktop-Bild */
	desk.iuser.ub_code = desk_usr;
	desk.iuser.ub_parm = 0;
	tree->ob_type = G_USERDEF;
	tree->ob_spec.userblk = &desk.iuser;

	/* Icons auf dem Desktop initialisieren */
	p = desk.dicon + 1;
	for (i = 1; i <= MAXICON; i++, p++) {
		p->obnum = i;
		p->class = IDFREE;
		p->select = 0;
		p->prevsel = 0;
		p->x = -1;
		p->y = -1;
		p->title[0] = 0;
		p->spec.data = 0L;

		iblk = &desk.wicon[i].ciconblk.monoblk;
		iblk->ib_pmask = rs_trindex[ICONS][DUMMYICON].ob_spec.iconblk->ib_pmask;
		iblk->ib_pdata = rs_trindex[ICONS][DUMMYICON].ob_spec.iconblk->ib_pdata;
		iblk->ib_char = 0x1041;
		iblk->ib_xchar = rs_trindex[ICONS][DUMMYICON].ob_spec.iconblk->ib_xchar;
		iblk->ib_ychar = rs_trindex[ICONS][DUMMYICON].ob_spec.iconblk->ib_ychar;
		iblk->ib_xicon = 20;
		iblk->ib_yicon = 0;
		iblk->ib_wicon = 32;
		iblk->ib_hicon = 32;
		iblk->ib_xtext = 0;
		iblk->ib_ytext = 32;
		iblk->ib_wtext = 72;
		iblk->ib_htext = tb.fs_ch + 2;
		iblk->ib_ptext = p->title;
		tree[i].ob_x = 4;
		tree[i].ob_y = 4;
		tree[i].ob_width = 76;
		tree[i].ob_height = 40;
		tree[i].ob_flags |= HIDETREE;
	}
}

/*-------------------------------------------------------------------------
 desk_pat()

 Farbe und Muster des Desktop-Hintergrundes setzen
 -------------------------------------------------------------------------*/
void desk_pat(void) {
	BFOBSPEC *spec;

	spec = (BFOBSPEC *) &desk.iuser.ub_parm;
	spec->fillpattern = conf.dpattern;
	spec->interiorcol = conf.dcolor;
}

/*-------------------------------------------------------------------------
 desk_draw()

 Desktop neuzeichnen - besser als einfach per form_dial() einen
 globalen Redraw auszulîsen.
 -------------------------------------------------------------------------*/
void desk_draw(short x, short y, short w, short h) {
	GRECT area, box;

	/* AES sperren und Maus abschalten */
	wind_update(BEG_UPDATE);
	graf_mouse(M_OFF, 0L);

	/* Vorbereitungen */
	area.g_x = x;
	area.g_y = y;
	area.g_w = w;
	area.g_h = h;

	/* Ersten Eintrag in der Rechteckliste holen */
	wind_get(0, WF_FIRSTXYWH, &box.g_x, &box.g_y, &box.g_w, &box.g_h);

	/* Rechteckliste abarbeiten */
	while (box.g_w && box.g_h) {
		/* Nur durchfÅhren, wenn Rechteck innerhalb des zu zeichnenden Bereichs liegt */
		if (rc_intersect(&area, &box))
			objc_draw(rs_trindex[DESKTOP], ROOT, MAX_DEPTH, box.g_x, box.g_y, box.g_w, box.g_h);

		/* NÑchstes Rechteck holen */
		wind_get(0, WF_NEXTXYWH, &box.g_x, &box.g_y, &box.g_w, &box.g_h);
	}

	/* Maus einschalten und AES freigeben */
	wind_update(END_UPDATE);
	graf_mouse(M_ON, 0L);
}

/*-------------------------------------------------------------------------
 rub_icon()
 rub_ticon()
 
 Icon-Umrisse auf dem Desktop zeichnen
 -------------------------------------------------------------------------*/
void rub_icon(short n, short *pxy) {
	short i;

	graf_mouse(M_OFF, 0L);
	for (i = 0; i < n; i++) {
		grf_ghostbox(&pxy[i * 18], 9);
	}
	graf_mouse(M_ON, 0L);
}

void rub_ticon(short n, short *pxy) {
	short i;

	graf_mouse(M_OFF, 0L);
	for (i = 0; i < n; i++) {
		grf_ghostbox(&pxy[i * 10], 5);
	}
	graf_mouse(M_ON, 0L);
}

/**
 * "Gummiband" auf dem Desktop zeichnen
 *
 * @param *sel
 */
void rub_frame(GRECT *sel) {
	short pxy[10];

	graf_mouse(M_OFF, 0L);
	pxy[0] = sel->g_x;
	pxy[1] = sel->g_y;
	pxy[2] = sel->g_x + sel->g_w - 1;
	pxy[3] = sel->g_y;
	pxy[4] = sel->g_x + sel->g_w - 1;
	pxy[5] = sel->g_y + sel->g_h - 1;
	pxy[6] = sel->g_x;
	pxy[7] = sel->g_y + sel->g_h - 1;
	pxy[8] = sel->g_x;
	pxy[9] = sel->g_y;
	grf_ghostbox(pxy, 5);
	graf_mouse(M_ON, 0L);
}

/**
 * Icon freigeben
 *
 * @param n
 */
void icon_free(short n) {
	ICONDESK *p = desk.dicon + n;

	p->class=IDFREE;
	if (p->spec.data) {
		pfree(p->spec.data);
		p->spec.data = 0L;
	}
}

/**
 * icon_match
 *
 * PrÅft, ob ein passendes Icon existiert.
 *
 * Eingabe:
 * mask: Zu prÅfende Maske (bei Files und Ordnern)
 * drive: Zu prÅfender Laufwerksbuchstabe (bei Laufwerken)
 * class: Gesuchte Iconklasse (0 = File, 1 = Ordner, 2 = Laufwerk)
 * def: Zeiger auf Default-Icon, falls es nichts passendes gibt
 *
 * RÅckgabe:
 * Zeiger auf gefundenes Icon, ggf. Default-Icon
 */
ICONIMG *icon_match(char *mask, char drive, short class, ICONIMG *def) {
	ICONIMG *p;
	short i;

	p = desk.icon;
	for (i = 0; i < desk.maxicon; i++, p++) {
		if (p->class == class) {
			if (class == 2) {
				if (p->mask[0] == drive)
					return(p);
			} else {
				if (wild_match(p->mask, mask))
					return(p);
			}
		}
	}
	return(def);
}

/**
 * icon_redraw
 *
 * Aktualisiert und zeichnet ein Icon auf dem Desktop
 *
 * Eingabe:
 * n: Index des Icons
 */
void icon_redraw(short n) {
	OBJECT *tree;
	short x, y, w, h, x2, y2, snap;

	tree = rs_trindex[DESKTOP];

	objc_offset(tree, n, &x, &y);
	w = tree[n].ob_width;
	h = tree[n].ob_height;
	snap = conf.isnap;
	conf.isnap = 0;
	icon_update(n);
	conf.isnap = snap;
	objc_offset(tree, n, &x2, &y2);
	if (tree[n].ob_width > w) {
		w = tree[n].ob_width;
		x = x2;
	}
	if (tree[n].ob_height > h)
		h = tree[n].ob_height;
	if (y2 < y)
		y = y2;

	desk_draw(x, y, w, h);
}

/*-------------------------------------------------------------------------
 icon_update()

 Setzt die Position und Beschriftung der Icons auf dem Desktop
 -------------------------------------------------------------------------*/
void icon_update(short n) {
	short i, j, k, s, e;
	short tw, iw, ih, ow, rd = 0;
	short x, y, w, h;
	char c;
	char *title, *p;
	char name[MAX_FLEN], wename[MAX_FLEN];
	ICONIMG *ticon;
	ICONBLK *iblk;
	OBJECT *tree;
	ICONDESK *q;

	tree = rs_trindex[DESKTOP];

	if (!n) {
		s = 1;
		e = MAXICON;
	} else
		s = e = n;

	q = desk.dicon + s;
	for (i = s; i <= e; i++, q++) {
		c = 0;

		/* Je nach Icontyp Image, Beschriftung und ggf. Laufwerksbuchstaben setzen */
		title = q->title;
		switch (q->class) {
			case IDDRIVE: /* Laufwerk */
				/* PrÅfen, ob Icon-Zuordnung existiert */
				ticon = icon_match(0L, (c = q->spec.drive->drive + 'A'), 2,
				&desk.ic_filesys);
				break;
			case IDTRASH: /* Papierkorb */
				ticon = &desk.ic_trash;
				break;
			case IDCLIP: /* Ablage */
				ticon = &desk.ic_clip;
				break;
			case IDPRT: /* Drucker */
				ticon = &desk.ic_prn;
				break;
			case IDDEVICE: /* Device */
				p = strrchr(q->spec.device->name,'\\');
				if (p)
					p = &p[1];
				else
					p = q->spec.device->name;

				j = 0;
				while (p[j]) {
					wename[j] = nkc_toupper(p[j]);
					j++;
				}
				wename[j] = 0;

				/* PrÅfen, ob Icon-Zuordnung existiert */
				ticon = icon_match(wename, 0, 0, &desk.ic_dev);
				break;
			case IDFILE: /* Datei */
				p = strrchr(q->spec.file->name,'\\');
				if (p)
					p = &p[1];
				else
					p = q->spec.file->name;

				j = 0;
				while (p[j]) {
					wename[j] = nkc_toupper(p[j]);
					j++;
				}
				wename[j] = 0;

				if (is_app(p, q->spec.file->mode)) {
					ticon = &desk.ic_appl;
				} else {
					if (wild_match1(GRP_MASK, wename))
						ticon = &desk.ic_grp;
					else
						ticon = &desk.ic_file;
				}

				/* PrÅfen, ob Icon-Zuordnung existiert */
				ticon = icon_match(wename, 0, 0, ticon);
				break;
			case IDFOLDER: /* Ordner */
				p = q->spec.folder->path;
				j = (short)strlen(p) - 2;
				while (p[j] != '\\')
					j--;
				j++;
				k = 0;
				while (p[j] != '\\') {
					name[k] = p[j];
					wename[k] = nkc_toupper(p[j]);
					k++;
					j++;
				}
				name[k] = 0;
				wename[k] = 0;
				/* PrÅfen, ob Icon-Zuordnung existiert */
				ticon = icon_match(wename, 0, 1, &desk.ic_folder);
				break;
			}

		/* Folgendes nur, wenn Icon benutzt */
		if (q->class != IDFREE) {
			/* Iconbitmap einsetzen */
			icn_setimg(&desk.wicon[i], &tree[i], ticon, q->title);

			/* Beschriftung und Laufwerksbuchstaben einsetzen */
			iblk = &desk.wicon[i].ciconblk.monoblk;
			iblk->ib_char = 0x1000 | (short) c;
			if (iblk->ib_ptext != title)
				strcpy(iblk->ib_ptext, title);
			tw = calc_small_text_width(title);
			if (tw > 0)
				tw += 4;
			iw = iblk->ib_wicon;
			ih = (iblk->ib_hicon + 1) & ~1;

			/* Objektbreite berechnen */
			if (tw > iw)
				ow = tw;
			else
				ow = iw;
			tree[i].ob_width = ow;

			/* Image und Text plazieren */
			iblk->ib_xicon = (ow - iblk->ib_wicon) / 2;
			iblk->ib_xtext = (ow - tw) / 2;
			iblk->ib_wtext = tw;
			if (tw > 0) {
				iblk->ib_htext = tb.fs_ch + 2;
				iblk->ib_ytext = ih;
			} else {
				iblk->ib_htext = 0;
				iblk->ib_ytext = ih / 2;
			}

			/* Objekthîhe */
			tree[i].ob_height = ih + iblk->ib_htext;

			/* Icon plazieren */
			w = tree[i].ob_width;
			h = tree[i].ob_height;
			/* Bei Bedarf Icon-Raster berÅcksichtigen */
			if (conf.isnap) {
				x = q->x;
				y = q->y;
				q->x = (x + 7) & 0xfff0;
				q->y = (y + 7) & 0xfff0;
				if (q->x != x || q->y != y) {
					x = q->x;
					y = q->y;
					if (x + w / 2 > tb.desk.g_w)
						x -= 16;
					if (y + h > tb.desk.g_h)
						y -= 16;
					q->x = x;
					q->y = y;
					rd = 1;
				}
			}
			tree[i].ob_x = q->x - w / 2;
			tree[i].ob_y = q->y;

			/* Icon bei Bedarf neu plazieren, falls es Åber den
			 Desktoprand hinausragt */
			objc_offset(tree, i, &x, &y);

			if (x < tb.desk.g_x) {
				x = tree[i].ob_x = 0;
				rd = 1;
			}
			if (x + w > tb.desk.g_x + tb.desk.g_w) {
				x = tree[i].ob_x = tb.desk.g_w - w;
				rd = 1;
			}
			if (y < tb.desk.g_y) {
				y = tree[i].ob_y = 0;
				rd = 1;
			}
			if (y + h > tb.desk.g_y + tb.desk.g_h) {
				y = tree[i].ob_y = tb.desk.g_h - h;
				rd = 1;
			}

			if (rd) {
				q->x = tree[i].ob_x + ow / 2;
				q->y = tree[i].ob_y;
				if (n) {
					tree[i].ob_flags |= HIDETREE;
					desk_draw(x, y, w, h);
				}
			}

			/* Icon sichtbar machen */
			tree[i].ob_flags &= ~HIDETREE;
			if (q->select || q->prevsel)
				tree[i].ob_state |= SELECTED;
			else
				tree[i].ob_state &= ~SELECTED;
		} else {
			/* Icon nicht benutzt, dann unsichtbar machen */
			tree[i].ob_flags |= HIDETREE;
		}
	}
}

/**-------------------------------------------------------------------------
 icon_select()

 Icon nach Mausklick selektieren/deselektieren
 -------------------------------------------------------------------------*/
void icon_select1(short obj, short sel, GRECT *drect, short *rd) {
	short x, y, w, h, osel;
	OBJECT *tree;
	ICONDESK *p = desk.dicon + obj;

	tree = rs_trindex[DESKTOP];

	if (p->class != IDFREE) { /* Nur benutzte Icons bearbeiten */
		osel = p->select;
		/* Status Ñndern, falls mîglich */
		if (!p->prevsel)
			p->select = sel;
		/* Objekt neuzeichnen, wenn der Status geÑndert wurde und
		 das Objekt nicht auch durch 'prevsel' selektiert ist */
		if (osel != p->select && !p->prevsel) {
			if (sel)
				tree[obj].ob_state |= SELECTED;
			else
				tree[obj].ob_state &= ~SELECTED;
			x = tree[obj].ob_x + tb.desk.g_x;
			y = tree[obj].ob_y + tb.desk.g_y;
			w = tree[obj].ob_width;
			h = tree[obj].ob_height;

			/* Koordinaten fÅr Redraw anpassen */
			if (*rd == 0) /* Koordinaten fÅr Redraw anpassen */
			{
				*rd = 1;
				drect->g_x = x;
				drect->g_y = y;
				drect->g_w = w;
				drect->g_h = h;
			} else {
				if (x < drect->g_x) {
					drect->g_w += (drect->g_x - x);
					drect->g_x = x;
				}
				if (x + w > drect->g_x + drect->g_w)
					drect->g_w = x + w - drect->g_x;
				if (y < drect->g_y) {
					drect->g_h += (drect->g_y - y);
					drect->g_y = y;
				}
				if (y + h > drect->g_y + drect->g_h)
					drect->g_h = y + h - drect->g_y;
			}
		}
	}
}

void icon_select(short obj, short add, short sel) {
	short i;
	GRECT drect;
	short rd;

	if (obj == -1) {
		/* Alle Objekte bearbeiten */
		rd = 0;
		for (i = 1; i <= MAXICON; i++)
			icon_select1(i, sel, &drect, &rd);
		if (rd) {
			desk_draw(drect.g_x, drect.g_y, drect.g_w, drect.g_h);
		}
	} else {
		/* Ein Objekt bearbeiten */
		if (!add) {
			/* Ggf. alle anderen Objekte deselektieren */
			rd = 0;
			for (i = 1; i <= MAXICON; i++)
				if (i != obj)
					icon_select1(i, 0, &drect, &rd);
			if (rd) {
				desk_draw(drect.g_x, drect.g_y, drect.g_w, drect.g_h);
			}
		}
		/* Status Ñndern */
		rd = 0;
		icon_select1(obj, sel, &drect, &rd);
		if (rd)
			desk_draw(drect.g_x, drect.g_y, drect.g_w, drect.g_h);
	}
}

/**-------------------------------------------------------------------------
 icon_drag()

 Alle selektierten Objekte via "Drag & Drop" verschieben
 -------------------------------------------------------------------------*/
void icon_drag(short mx, short my, short mk, short ks) {
	short lmx, lmy, lmk, lks;
	short *pxy, *obnum;
	short i, n;
	short p, x, y, w, h, h2, ix, iw, ih, tx, tw;
	short tx1, ty1, tx2, ty2;
	short otx, oty;
	short obj, obj1, whandle, drag, drag1;
	short moved = 0;
	WININFO *win, *iwin, *iwin1;
	ACWIN *accwin;
	WP_ENTRY *item, *item1;
	WG_ENTRY *gitem, *gitem1, *gprev;
	ICONBLK *iblk;
	OBJECT *tree;

	tree = rs_trindex[DESKTOP];

	lmx = mx;
	lmy = my;
	lmk = mk;
	lks = ks;

	/* Aktuelle Auswahl sichern und Anzahl selektierter Objekte
	 ermitteln */
	n = 0;
	for (i = 1; i <= MAXICON; i++) {
		desk.dicon[i].prevsel = desk.dicon[i].select;
		if (desk.dicon[i].select && desk.dicon[i].class != IDFREE)
			n++;
	}

	/* Polygone fÅr die Darstellung am Bildschirm aufbauen */
	pxy = pmalloc(sizeof(short) * n * 18); /* Je Icon 9 xy-Punkte */
	if (!pxy) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return;
	}
	obnum = pmalloc(sizeof(short) * n); /* Objektnummern der Icons */
	if (!obnum) {
		pfree(pxy);
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return;
	}
	p = 0;
	tx1 = tb.desk.g_x + tb.desk.g_w; /* t... Position/Maûe des Gesamtrechtecks */
	ty1 = tb.desk.g_y + tb.desk.g_h;
	tx2 = ty2 = 0;
	for (i = 1; i <= MAXICON; i++) {
		if (desk.dicon[i].select && desk.dicon[i].class != IDFREE) {
			obnum[p] = i;
			/* Koordinaten/Maûe holen */
			objc_offset(tree, i, &x, &y);
			iblk = &desk.wicon[i].ciconblk.monoblk;
			ix = iblk->ib_xicon;
			iw = iblk->ib_wicon;
			ih = (iblk->ib_hicon + 1) & ~1;
			tx = iblk->ib_xtext;
			tw = iblk->ib_wtext;
			h = ih + iblk->ib_htext;
			if (iblk->ib_htext > 0)
				h2 = tree[i].ob_height;
			else
				h2 = ih + 1;
			/* Polygonzug berechnen */
			wc_icon(&pxy[p * 18], &x, &y, &w, &h, ix, iw, tx, ih, tw);

			/* Gesamtrechteck anpassen */
			if (x < tx1)
				tx1 = x;
			if (y < ty1)
				ty1 = y;
			if (x + w > tx2)
				tx2 = x + w;
			if (y + h2 > ty2)
				ty2 = y + h2;

			p++;
		}
	}
	otx = tx1;
	oty = ty1; /* Ausgangskoordinaten merken */

	/* Und auf gehts ... */
	x = lmx;
	y = lmy;
	obj = obj1 = -1;
	iwin = iwin1 = 0L;
	item = item1 = 0L;
	gitem = gitem1 = 0L;
	win = 0L;
	accwin = 0L;
	drag = drag1 = 1;
	whandle = 0;
	wind_update (BEG_MCTRL);
	graf_mouse(FLAT_HAND, 0L);
	rub_icon(n, pxy);
	while (lmk & 1) {
		if (1) /*if(x!=lmx || y!=lmy)*//* Mausposition verÑndert ? */
		{
			evnt_timer(10L);
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
				rub_icon(n, pxy);
				/* Anhand von xy-Delta verschieben */
				tx1 += w;
				ty1 += h;
				tx2 += w;
				ty2 += h;
				for (i = 0; i < n * 9; i++) {
					pxy[i * 2] += w;
					pxy[i * 2 + 1] += h;
				}
				/* Zeichnen */
				rub_icon(n, pxy);
			}

			/* Maus Åber einem Fenster ? */
			whandle = wind_find(lmx, lmy);
			if (whandle) {
				/* Ja */
				drag = 1;
				/* Bisher selektiertes Desktop-Objekt deselektieren */
				if (obj != -1) {
					rub_icon(n, pxy);
					icon_select(obj1, 1, 0);
					rub_icon(n, pxy);
					obj = -1;
				}
				/* Fenster ermitteln */
				win = win_getwinfo(whandle);
				if (win) {
					/* Fenster bekannt -> dann Drag&Drop in Fenster */
					switch (win->class) {
					case WCCON: /* Console */
						item = 0L;
						gitem = 0L;
						drag = 0;
						break;
					case WCPATH: /* Verzeichnisfenster */
						gitem = 0L;
						if (desk.sel.trash || desk.sel.clip || desk.sel.printer || desk.sel.devices) {
							item = 0L;
							drag = 0;
						} else {
							iwin = win; /* Fenster merken */
							if (drag_scroll(lmy, w, h, moved, iwin, n, pxy, rub_icon)) {
								item = 0L;
								break;
							}
							item = wpath_efind(win, lmx, lmy); /* Objekt ermitteln */
							if(item) {
								drag = 1;
								switch (item->class) {
								case EC_FILE: /* Datei */
									if (!item->aptype) {
										/* Evtl. indirekt angemeldet */
										if (!app_isdrag(item->name))
											item = 0L; /* Nein */
									}
									break;
								case EC_DEVICE: /* Device */
									/* Nur einzelne Datei zulÑssig */
									if (desk.sel.files > 1 || desk.sel.folders || desk.sel.drives)
										drag = 0;
									break;
								}
								if (!drag)
									item = 0L;
							}
						}
						break;
					case WCGROUP: /* Gruppenfenster */
						item = 0L;
						iwin = win; /* Fenster merken */
						if (drag_scroll(lmy, w, h, moved, iwin, n, pxy, rub_icon)) {
							gitem = 0L;
							break;
						}
						gitem = wgrp_efind(win, lmx, lmy, &gprev); /* Objekt ermitteln */
						if (gitem) {
							drag = 1;
							switch (gitem->class) {
							case EC_FILE: /* Datei */
								if (!gitem->aptype) {
									/* Evtl. indirekt angemeldet */
									if (!app_isdrag(gitem->name))
										gitem = 0L; /* Nein */
								}
								break;
							case EC_DEVICE: /* Device */
								/* Nur einzelne Datei zulÑssig */
								if (desk.sel.files>1 || desk.sel.folders || desk.sel.drives)
									drag = 0;
								break;
							}
							if (!drag)
								gitem = 0L;
						}

						/* Gruppenhintergrund */
						if(!gitem) {
							/* Nur Dateien/Ordner/Laufwerke zulassen */
							if (desk.sel.trash || desk.sel.clip || desk.sel.printer || desk.sel.devices) {
								gitem = 0L;
								drag = 0;
							}
						}
						break;
					case WCDIAL:
						item = 0L;
						gitem = 0L;
						if (desk.sel.numobs>1 || desk.sel.trash || desk.sel.printer || desk.sel.clip)
							drag = 0;
						break;
					}
				} else {
					/* Fenster nicht bekannt - eventuell Acc-Fenster ? */
					item = 0L;
					gitem = 0L;
					accwin = acwin_find(whandle);
					/* Es kînnen nur Dateien, Ordner oder Laufwerke in ein Fenster gelegt werden */
					if (desk.sel.trash || desk.sel.clip || desk.sel.printer || desk.sel.devices)
						drag = 0;
					else
						drag = 1;
				}
				/* Bisher selektiertes Zielobjekt deselektieren und ggf. neues Zielobjekt selektieren */
				if (item != item1) {
					rub_icon(n, pxy);
					if (item1 != 0L)
						wpath_esel(iwin1, item1, 1, 0, 0);
					if (item != 0L)
						wpath_esel(iwin, item, 1, 1, 0);
					rub_icon(n, pxy);
				}
				if (gitem != gitem1) {
					rub_icon(n, pxy);
					if (gitem1 != 0L)
						wgrp_esel(iwin1, gitem1, 1, 0);
					if (gitem != 0L)
						wgrp_esel(iwin, gitem, 1, 1);
					rub_icon(n, pxy);
				}
			} else {
				/* Maus nicht Åber einem Fenster */
				/* Bisheriges Fenster-Objekt deselektieren */
				if (item || gitem) {
					rub_icon(n, pxy);
					if (item) {
						wpath_esel(iwin, item, 1, 0, 0);
						item = 0L;
					} else {
						wgrp_esel(iwin, gitem, 1, 0);
						gitem = 0L;
					}
					rub_icon(n, pxy);
				}
				win = 0L;
				accwin = 0L;
				/* Desktop-Objekt ermitteln */
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
							if (desk.sel.trash || desk.sel.clip || desk.sel.printer || desk.sel.devices)
								obj = -1;
							if (!is_app(desk.dicon[obj].spec.file->name, desk.dicon[obj].spec.file->mode)) {
								if (!app_isdrag(desk.dicon[obj].spec.file->name))
									obj = -1;
							}
							break;
						case IDCLIP:
							if (desk.sel.numobs > 1 || desk.sel.folders || desk.sel.drives || desk.sel.trash || desk.sel.printer || desk.sel.devices)
								obj = -1;
						case IDTRASH:
							if ((desk.sel.drives && (desk.sel.files || desk.sel.folders)) || desk.sel.printer)
								obj = -1;
							break;
						case IDPRT:
							if (desk.sel.files > 1 || desk.sel.folders || desk.sel.drives || desk.sel.clip || desk.sel.trash || desk.sel.devices)
								obj=-1;
							break;
						case IDDEVICE:
							if (desk.sel.files > 1 || desk.sel.folders || desk.sel.drives || desk.sel.clip || desk.sel.trash || desk.sel.devices || desk.sel.printer)
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
					rub_icon(n, pxy);
					if (obj1 != -1)
						icon_select(obj1, 1, 0);
					if (obj != -1)
						icon_select(obj, 1, 1);
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
		moved = h || moved;
	}
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
	for (i = 1; i <= MAXICON; i++) {
		desk.dicon[i].select = desk.dicon[i].prevsel;
		desk.dicon[i].prevsel = 0;
	}

	/* Zielobjekt auf dem Desktop ? */
	if (obj != -1) {
		dl_ddrag(&desk.dicon[obj], lks);
	} else {
		/* Kein Zielobjekt auf dem Desktop */

		/* Fenster ? */
		if (whandle) {
			/* Eigenes Fenster und Verschieben mîglich ? */
			if (win && drag) {
				dl_wdrag(win, item, gitem, gprev, lmx, lmy, lks);
			} else {
				if (drag)
					dl_awdrag(accwin, whandle, lmx, lmy, lks);
				else
					mybeep();
			}
		} else {
			/* kein Zielfenster - dann Icons auf dem Desktop verschieben */

			/* Verschieben mîglich ? */
			if (drag) {
				/* xy-Delta der Gruppe berechnen */
				tx2 = tx1 - otx;
				otx = tx2;
				ty2 = ty1 - oty;
				oty = ty2;
				if (otx != 0 || oty != 0) {
					/* Nur wenn nîtig */

					/* Position/Maûe des Gesamtrechtecks fÅr Desktop-Redraw */
					tx1 = tb.desk.g_x + tb.desk.g_w;
					ty1 = tb.desk.g_y + tb.desk.g_h;
					tx2 = ty2 = 0;
					/* An alter Positionen lîschen */
					for (i = 0; i < n; i++) {
						p = obnum[i];

						tree[p].ob_flags |= HIDETREE;
						objc_offset(tree, p, &x, &y);
						w = tree[p].ob_width;
						h = tree[p].ob_height;

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
					desk_draw(tx1, ty1, tx2 - tx1 + 1, ty2 - ty1 + 1);

					/* Position/Maûe des Gesamtrechtecks fÅr Desktop-Redraw */
					tx1 = tb.desk.g_x + tb.desk.g_w;
					ty1 = tb.desk.g_y + tb.desk.g_h;
					tx2 = ty2 = 0;
					/* Neu positionieren */
					for (i = 0; i < n; i++) {
						p = obnum[i];
						desk.dicon[p].x += otx;
						desk.dicon[p].y += oty;
						tree[p].ob_flags &= ~HIDETREE;
						icon_update(p);
						objc_offset(tree, p, &x, &y);
						w = tree[p].ob_width;
						h = tree[p].ob_height;

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
					desk_draw(tx1, ty1, tx2 - tx1 + 1, ty2 - ty1 + 1);
				}
			} else
				mybeep(); /* Verschieben war nicht mîglich */
		}
	}

	/* Finito ... */pfree(obnum);
	pfree(pxy);
}

/*-------------------------------------------------------------------------
 icon_xsel()

 Objekte auf dem Desktop mit "Gummiband" auswÑhlen
 -------------------------------------------------------------------------*/
void icon_xsel(short mx, short my, short mk, short ks) {
	short lmx, lmy, lmk, lks;
	short i;
	GRECT sel, sel2, rsel;
	short rxy[4];
	short rd;
	GRECT wrd;
	ICONDESK *p;

	lmx = mx;
	lmy = my;
	lmk = mk;
	lks = ks;
	/* Bisherigen Status der Objekte sichern */
	p = desk.dicon + 1;
	for (i = 1; i <= MAXICON; i++, p++)
		p->prevsel = p->select;
	/* Startrechteck merken */
	sel.g_x = sel2.g_x = lmx;
	sel.g_y = sel2.g_y = lmy;
	sel.g_w = sel.g_h = 0;

	/* Auf gehts ... */
	graf_mouse(POINT_HAND, 0L);
	rub_frame(&sel);
	while (lmk & 1) {
		/* Neue Mausposition holen */
		graf_mkstate(&lmx, &lmy, &lmk, &lks);

		/* Neues Auswahlrechteck berechnen */
		sel2.g_w = lmx - sel.g_x + 1;
		sel2.g_h = lmy - sel.g_y + 1;
		/* Begrenzung auf Desktop */
		if (sel2.g_y + sel2.g_h - 1 < tb.desk.g_y)
			sel2.g_h = tb.desk.g_y - sel2.g_y + 1;
		if (sel2.g_y + sel2.g_h > tb.desk.g_y + tb.desk.g_h)
			sel2.g_h = tb.desk.g_y + tb.desk.g_h - sel2.g_y;
		if (sel2.g_x + sel2.g_w - 1 < tb.desk.g_x)
			sel2.g_w = tb.desk.g_x - sel2.g_x + 1;
		if (sel2.g_x + sel2.g_w > tb.desk.g_x + tb.desk.g_w)
			sel2.g_w = tb.desk.g_x + tb.desk.g_w - sel2.g_x;

		/* Bei énderung Auswahlrechteck neu zeichnen */
		if (sel.g_w != sel2.g_w || sel.g_h != sel2.g_h) {
			/* Lîschen und neue Maûe verwenden */
			rub_frame(&sel);
			sel.g_w = sel2.g_w;
			sel.g_h = sel2.g_h;
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
			p = desk.dicon + 1;
			for (i = 1; i <= MAXICON; i++, p++) {
				short psel;

				if (p->class != IDFREE) {
					if (icon_inrect(i, &rsel)) {
						if (!p->select && !p->prevsel)
							icon_select1(i, 1, &wrd, &rd);
						else if (p->select && p->prevsel) {
							p->prevsel = 0;
							icon_select1(i, 0, &wrd, &rd);
							p->prevsel = 1;
						}
					} else {
						psel = p->prevsel;
						p->prevsel = 0;
						icon_select1(i, psel, &wrd, &rd);
						p->prevsel = psel;
					}
				}
			}
			if (rd) {
				rub_frame(&sel);
				desk_draw(wrd.g_x, wrd.g_y, wrd.g_w, wrd.g_h);
				rub_frame(&sel);
			}
		}
	}
	rub_frame(&sel);
	graf_mouse(ARROW, 0L);

	/* Bisherigen Status der Objekte lîschen */
	p = desk.dicon + 1;
	for (i = 1; i <= MAXICON; i++, p++)
		p->prevsel = 0;
}

/*-------------------------------------------------------------------------
 icon_find()

 PrÅfen, ob an der angegebenen Position ein Icon liegt
 (Wesentlich schneller als objc_find())
 -------------------------------------------------------------------------*/
short icon_find(short mx, short my) {
	short ix, iw, ih;
	short tx, ty, tw, th;
	short i;
	short px, py;
	ICONBLK *iblk;
	short obj;
	ICONDESK *p;

	obj = -1;
	p = desk.dicon + 1;
	for (i = 1; i <= MAXICON; i++, p++) {
		if (p->class != IDFREE) {
			px = tb.desk.g_x + rs_trindex[DESKTOP][i].ob_x;
			py = tb.desk.g_y + rs_trindex[DESKTOP][i].ob_y;
			iblk = &desk.wicon[i].ciconblk.monoblk;
			ix = iblk->ib_xicon;
			iw = iblk->ib_wicon;
			ih = (iblk->ib_hicon + 1) & ~1;
			tx = iblk->ib_xtext;
			ty = iblk->ib_ytext;
			tw = iblk->ib_wtext;
			th = iblk->ib_htext;
			/* Innerhalb des Textes ? */
			if (mx >= px + tx && mx <= px + tx + tw - 1 && my >= py + ty && my <= py + ty + th - 1)
				obj = i;
			/* Innerhalb des Images ? */
			if (mx >= px + ix && mx <= px + ix + iw - 1 && my >= py && my <= py + ih)
				obj = i;
		}
	}

	return (obj);
}

/*-------------------------------------------------------------------------
 icon_inrect()

 PrÅft, ob das angegebene Icon vom angegebenen Rechteck berÅhrt wird
 -------------------------------------------------------------------------*/
short icon_inrect(short n, GRECT *rect) {
	ICONBLK *iblk;
	short px, py;
	short is_in;
	GRECT orect;

	px = tb.desk.g_x + rs_trindex[DESKTOP][n].ob_x;
	py = tb.desk.g_y + rs_trindex[DESKTOP][n].ob_y;
	iblk = &desk.wicon[n].ciconblk.monoblk;
	is_in = 0;

	/* Text-Bereich */
	orect.g_x = px + iblk->ib_xtext;
	orect.g_y = py + iblk->ib_ytext;
	orect.g_w = iblk->ib_wtext;
	orect.g_h = iblk->ib_htext;
	if (rc_intersect(rect, &orect))
		is_in = 1;

	/* Image-Bereich */
	orect.g_x = px + iblk->ib_xicon;
	orect.g_y = py;
	orect.g_w = iblk->ib_wicon;
	orect.g_h = (iblk->ib_hicon + 1) & ~1;
	if (rc_intersect(rect, &orect))
		is_in = 1;

	return (is_in);
}

/*-------------------------------------------------------------------------
 icon_checksel()

 Aktualisiert die Angaben Åber die aktuelle Auswahl
 -------------------------------------------------------------------------*/
void icon_checksel(void) {
	WININFO *win;
	W_PATH *wpath;
	W_GRP *wgrp;
	WP_ENTRY *item;
	WG_ENTRY *gitem;
	short i, j;
	ICONDESK *p;

	/* Aktuelle Angaben lîschen */
	memset(&desk.sel, 0, sizeof(SEL_INFO));

	/* Icons auf dem Desktop selektiert ? ... */
	p = desk.dicon + 1;
	for (i = 1; i <= MAXICON; i++, p++) {
		if (p->class != IDFREE && p->select) {
			desk.sel.numobs++;

			switch (p->class) {
			case IDTRASH:
				desk.sel.trash++;
				break;
			case IDCLIP:
				desk.sel.clip++;
				break;
			case IDDRIVE:
				desk.sel.drives++;
				break;
			case IDFILE:
				desk.sel.files++;
				break;
			case IDFOLDER:
				desk.sel.folders++;
				break;
			case IDPRT:
				desk.sel.printer++;
				break;
			case IDDEVICE:
				desk.sel.devices++;
				break;
			}
		}
	}
	/* ... ja */
	if (desk.sel.numobs)
		desk.sel.desk = 1;
	else {
		/* ... nein, dann Fenster prÅfen */
		win = tb.win;
		while (win && !desk.sel.win) {
			switch (win->class) {
			case WCPATH:
				wpath = (W_PATH *)win->user;
				if (wpath->e_sel) {
					desk.sel.win = win;
					for (j = 0; j < wpath->e_total; j++) {
						item = wpath->lptr[j];
						if (item->sel) {
							desk.sel.numobs++;
							switch(item->class) {
							case EC_FILE:
								desk.sel.files++;
								break;
							case EC_FOLDER:
								desk.sel.folders++;
								break;
							case EC_PARENT:
								desk.sel.parent = 1;
								break;
							case EC_DEVICE:
								desk.sel.devices++;
								break;
							}
						}
					}
				}
				break;
			case WCGROUP:
				wgrp = (W_GRP *)win->user;
				gitem = wgrp->entry;
				while (gitem) {
					if (gitem->sel) {
						desk.sel.win = win;
						desk.sel.numobs++;
						switch(gitem->class) {
						case EC_FILE:
							desk.sel.files++;
							break;
						case EC_FOLDER:
							desk.sel.folders++;
							break;
						case EC_PARENT:
							desk.sel.parent = 1;
							break;
						case EC_DEVICE:
							desk.sel.devices++;
							break;
/* ErgÑnzen:			case EC_DRIVE:  desk.sel.drives++;break; */
						}
					}
					gitem = gitem->next;
				}
				break;
			}
			win = win->next;
		}
	}
}

/*-------------------------------------------------------------------------
 icn_rsrc()

 Sucht in der geladenen Resource das angegebene Icon
 -------------------------------------------------------------------------*/
void icn_rsrc(char *name, ICONIMG *img) {
	ICONBLK *iblk, *riblk;
	_CICONBLK *cblk;
	DRAW_CICON *dblk;
	char *iname;
	short i;
	void *ucode;

	/* Erst normales Icon suchen */
	i = 0;
	riblk = 0L;
	ucode = 0L;
	do {
		i++;
		if ((glob.rtree[i].ob_type & 0x00ff) == G_USERDEF) {
			ucode = glob.rtree[i].ob_spec.userblk->ub_code;
			dblk = (DRAW_CICON *) glob.rtree[i].ob_spec.userblk->ub_parm;
			cblk = dblk->original;
			iblk = &cblk->monoblk;
		} else {
			ucode = 0L;
			dblk = 0L;
			iblk = glob.rtree[i].ob_spec.iconblk;
		}
		iname = iblk->ib_ptext;
		if (!strcmp(iname, name))
			riblk = iblk;
	} while (!(glob.rtree[i].ob_flags & LASTOB) && !riblk);
	if (riblk) {
		img->iconblk = riblk;
		img->cblk = dblk;
		img->ub_code = ucode;
	} else {
		img->iconblk = rs_trindex[ICONS][DUMMYICON].ob_spec.iconblk;
		img->cblk = 0L;
		img->ub_code = 0L;
	}

	/* Jetzt noch Mini-Icon */
	i = 0;
	riblk = 0L;
	if (glob.srtree) {
		do {
			i++;
			if ((glob.srtree[i].ob_type & 0x00ff) == G_USERDEF) {
				ucode = glob.srtree[i].ob_spec.userblk->ub_code;
				dblk = (DRAW_CICON *) glob.srtree[i].ob_spec.userblk->ub_parm;
				cblk = dblk->original;
				iblk = &cblk->monoblk;
			} else {
				ucode = 0L;
				dblk = 0L;
				iblk = glob.srtree[i].ob_spec.iconblk;
			}
			iname = iblk->ib_ptext;
			if (!strcmp(iname, name))
				riblk = iblk;
			/* Weil wir eh' gerade dabei sind... Hîhe der Miniicons merken */
			glob.sheight = iblk->ib_hicon;
		} while (!(glob.srtree[i].ob_flags & LASTOB) && !riblk);
	}

	if (riblk) {
		img->siconblk = riblk;
		img->sub_code = ucode;
		img->scblk = dblk;
	} else {
		img->sub_code = 0L;
		img->scblk = 0L;
		switch (img->class) {
			case 0:
			if(is_app(img->mask,0)) {
				img->siconblk=desk.ic_appl.siconblk;
				if (desk.ic_appl.sub_code) {
					img->sub_code = desk.ic_appl.sub_code;
					img->scblk = desk.ic_appl.scblk;
				}
			} else {
				if (desk.ic_file.sub_code) {
					img->sub_code = desk.ic_file.sub_code;
					img->scblk = desk.ic_file.scblk;
				}
				img->siconblk=desk.ic_file.siconblk;
			}
			break;
			case 1:
			case 2:
			img->siconblk=desk.ic_folder.siconblk;
			if (desk.ic_folder.sub_code) {
				img->sub_code = desk.ic_folder.sub_code;
				img->scblk = desk.ic_folder.scblk;
			}
			break;
		}
		if (!img->siconblk)
			img->siconblk = rs_trindex[ICONS][SDUMMYICON].ob_spec.iconblk;
	}
}

/*-------------------------------------------------------------------------
 icn_setimg()

 éndert das Aussehen eines Icons
 -------------------------------------------------------------------------*/
void icn_setimg(WICON *wicon, OBJECT *obj, ICONIMG *img, char *txt) {
	ICONBLK *iblk, *iiblk;
	DRAW_CICON *cblk, *wcblk;

	cblk = img->cblk;
	iblk = &wicon->ciconblk.monoblk;
	iiblk = img->iconblk;

	if (!cblk) {
		/* Mono-Icon */
		obj->ob_type = G_ICON;
		obj->ob_spec.iconblk = iblk;
	} else {
		/* Farbicon */
		wcblk = &wicon->draw_cicon;

		obj->ob_type = G_USERDEF;
		obj->ob_spec.userblk = &wicon->userblk;
		obj->ob_spec.userblk->ub_code = img->ub_code;
		obj->ob_spec.userblk->ub_parm = (long) wcblk;

		wcblk->icon_data = cblk->icon_data;
		wcblk->sel_idata = cblk->sel_idata;
		wcblk->mask_data = cblk->mask_data;
		wcblk->sel_mdata = cblk->sel_mdata;
		wcblk->planes = cblk->planes;
		wcblk->free_icon = cblk->free_icon;
		wcblk->free_sel = cblk->free_sel;
		wcblk->original = &wicon->ciconblk;
		wcblk->original->mainlist = cblk->original->mainlist;
	}

	iblk->ib_wicon = iiblk->ib_wicon;
	iblk->ib_hicon = iiblk->ib_hicon;
	iblk->ib_pmask = iiblk->ib_pmask;
	iblk->ib_pdata = iiblk->ib_pdata;
	iblk->ib_ptext = txt;
	iblk->ib_xchar = iiblk->ib_xchar;
	iblk->ib_ychar = iiblk->ib_ychar;
}

/*-------------------------------------------------------------------------
 desk_freepos()

 Ermittelt einen freien Platz auf dem Desktop fÅr das Ablegen eines
 Icons (80*40 Pixel).
 -------------------------------------------------------------------------*/
void desk_freepos(short n, short *x, short *y, short start) {
	GRECT test;
	short done, i, free, sx, sy, mx, my;
	ICONDESK *p;

	test.g_w = 76;
	test.g_h = 40;
	sx = tb.desk.g_x;
	mx = 40;
	my = 24;

	if (start == 0)
		sy = tb.desk.g_y;
	else
		sy = tb.desk.g_y + tb.desk.g_h - test.g_h;

	test.g_x = sx;
	test.g_y = sy;

	done = 0;
	while (!done) {
		free = 1;

		/* Position frei? */
		p = desk.dicon + 1;
		for (i = 1; i <= MAXICON && free == 1; i++, p++) {
			if (p->class!=IDFREE && i!=n) {
				if (icon_inrect(i, &test))
					free = 0;
			}
		}

		/* Nein - Dann nÑchste Position und abbrechen, falls letzte mîgliche
		 Position bereits erreicht wurde */
		if (!free) {
			test.g_x += mx;
			if (test.g_x + test.g_w >= tb.desk.g_x + tb.desk.g_w) {
				test.g_x = sx;
				if (start == 0) {
					test.g_y += my;
					if (test.g_y + test.g_h >= tb.desk.g_y + tb.desk.g_h) {
						test.g_y = sy;
						done = 1;
					}
				} else {
					test.g_y -= my;
					if (test.g_y < tb.desk.g_y) {
						test.g_y = sy;
						done = 1;
					}
				}
			}
		} else
			done = 1;
	}

	*x = (test.g_x - tb.desk.g_x + 76 / 2);
	*y = (test.g_y - tb.desk.g_y);
}

/*
 * desk_timgload
 *
 * LÑdt das ThingImg-Overlay nach und initialisiert es.
 *
 * RÅckgabe:
 * 0L: Fehler beim Laden, Meldung bereits erfolgt
 * sonst: Zeiger auf timg-Basepage
 */
static BASEPAGE *desk_timgload(void) {
	char fname[MAX_PLEN];
	long err, plen;
	BASEPAGE *timg;

	strcpy(fname, tb.homepath);
	strcat(fname, FNAME_IMG);
	if ((err = Pexec(3, fname, "", 0L)) < 0L) {
		sprintf(almsg, rs_frstr[ALNOTIMG], err);
		frm_alert(1, almsg, altitle, conf.wdial, 0L);
		return (0L);
	}
	timg = (BASEPAGE *) err;
	plen = sizeof(BASEPAGE) + 1024L + timg->p_tlen + timg->p_dlen + timg->p_blen;
	Mshrink(timg->p_lowtpa, plen);
	timg->p_hitpa = (void *) ((long) timg->p_lowtpa + plen);
	call_thingimg = timg->p_tbase;
	vsl_type(tb.vdi_handle, SOLID);
	Pexec(4, 0L, timg, 0L);
	return (timg);
}

/*-------------------------------------------------------------------------
 desk_icheck()

 Desktop-Bild auf Format prÅfen
 -------------------------------------------------------------------------*/
short desk_icheck(THINGIMG *check, char *name, short usepal) {
	short ok;
	BASEPAGE *timg;
	THINGIMG info;

	info = *check;
	info.vdi_handle = tb.vdi_handle;
	info.filename = name;
	info.use_palette = usepal;
	if ((timg = desk_timgload()) == 0L)
		return (0);
	(call_thingimg)(TI_MAGIC, TI_INIT, &info);
	ok = (call_thingimg)(TI_MAGIC, TI_TEST, &info) ? 1 : 0;
	if (!ok)
		frm_alert(1, rs_frstr[ALILLIMG], altitle, conf.wdial, 0L);
	Mfree(timg->p_env);
	Mfree(timg);
	return (ok);
}

/*-------------------------------------------------------------------------
 desk_iload()

 Desktop-Bild laden
 -------------------------------------------------------------------------*/
short desk_iload(THINGIMG *dest, char *name, short usepal, short alert) {
	BASEPAGE *timg;
	long err;

	dest->vdi_handle = tb.vdi_handle;
	dest->filename = name;
	dest->use_palette = usepal;
	dest->first = -1;
	if ((timg = desk_timgload()) == 0L)
		return (0);

	(call_thingimg)(TI_MAGIC, TI_INIT, dest);
	err = (call_thingimg)(TI_MAGIC, TI_SIZE, dest);
	Mfree(timg->p_env);
	Mfree(timg);
	if (err) {
		frm_alert(1, rs_frstr[alert], altitle, conf.wdial, 0L);

dil_exit_error:
		if (dest->picture.fd_addr)
			pfree(dest->picture.fd_addr);
		dest->picture.fd_addr = 0L;
		return (0);
	}
	dest->picture.fd_addr = pmalloc(dest->pic_size);
	if (dest->picture.fd_addr == 0L) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		goto dil_exit_error;
	}
	if ((timg = desk_timgload()) == 0L)
		goto dil_exit_error;
	(call_thingimg)(TI_MAGIC, TI_INIT, dest);
	err = (call_thingimg)(TI_MAGIC, TI_LOAD, dest);
	Mfree(timg->p_env);
	Mfree(timg);
	if (err) {
		frm_alert(1, rs_frstr[alert], altitle, conf.wdial, 0L);
		goto dil_exit_error;
	}
	return (1);
}

/*-------------------------------------------------------------------------
 desk_ifree()

 Desktop-Bild freigeben
 -------------------------------------------------------------------------*/
void desk_ifree(THINGIMG *timg) {
	short i;

	if (timg->picture.fd_addr) {
		pfree(timg->picture.fd_addr);
		timg->picture.fd_addr = 0L;
		if (timg->use_palette && !timg->is_mono && (timg->first != -1)) {
			for (i = timg->first; i <= timg->last; i++)
				vs_color(tb.vdi_handle, i, &timg->old_palette[i * 3]);
		}
	}
}

/*-------------------------------------------------------------------------
 desk_usr()

 Darstellung des Hintergrund-Bildes
 -------------------------------------------------------------------------*/
short cdecl desk_usr(PARMBLK *parmblock) {
	short xc, yc, wc, hc, pxy[8];
	short w,h;
	BFOBSPEC *spec;
	MFDB scr,*img;
	GRECT clip, draw;
	short col[2];

	/* Clipping setzen */
	xc=parmblock->pb_xc;
	yc=parmblock->pb_yc;
	wc=parmblock->pb_wc;
	hc=parmblock->pb_hc;
	if (xc!=0 || yc!=0 || wc!=0 || hc!=0) {
		pxy[0] = xc;
		pxy[1] = yc;
		pxy[2] = xc + wc - 1;
		pxy[3] = yc + hc - 1;
	} else {
		pxy[0] = tb.desk.g_x;
		pxy[1] = tb.desk.g_y;
		pxy[2] = pxy[0] + tb.desk.g_w - 1;
		pxy[3] = pxy[1] + tb.desk.g_h - 1;
	}
	clip.g_x = pxy[0];
	clip.g_y = pxy[1];
	clip.g_w = pxy[2] - pxy[0] + 1;
	clip.g_h = pxy[3] - pxy[1] + 1;
	vs_clip(tb.vdi_handle, 1, pxy);

	/* Weitere Vorbereitungen */
	spec = (BFOBSPEC *)&desk.iuser.ub_parm;
	col[0] = spec->interiorcol;col[1] = 0;
	scr.fd_addr = 0L;
	img = &glob.img_info.picture;

	/* HintergrundfÅllmuster ausgeben, wenn kein Bild, oder Bild zentriert */

	/* FÅllmuster nur, wenn:
	 * - kein (korrektes) Bild
	 * - Bild transparent
	 * - Bild kleiner als Desktop und nicht gekachelt
	 */
	if (!conf.imguse || !glob.img_ok || glob.img_ok && (conf.imgtrans || (conf.imgcenter && ((img->fd_w < tb.desk.g_w) || (img->fd_h < tb.desk.g_h))))) {
		pxy[0] = tb.desk.g_x;
		pxy[1] = tb.desk.g_y;
		pxy[2] = pxy[0] + tb.desk.g_w - 1;
		pxy[3] = pxy[1] + tb.desk.g_h - 1;
		vsf_color(tb.vdi_handle, spec->interiorcol);
		if (spec->fillpattern > 0) {
			if (spec->fillpattern < 7) {
				vsf_interior(tb.vdi_handle, FIS_PATTERN);
				vsf_style(tb.vdi_handle, spec->fillpattern);
			}
			else
				vsf_interior(tb.vdi_handle, FIS_SOLID);
		} else {
			vsf_interior(tb.vdi_handle, FIS_HOLLOW);
		}
		vsf_perimeter(tb.vdi_handle, 0);
		vswr_mode(tb.vdi_handle, MD_REPLACE);
		v_bar(tb.vdi_handle, pxy);
	}

	/* Bild ausgeben, falls vorhanden */
	if (glob.img_ok && conf.imguse) {
		short mode;

		if (conf.imgtrans) {
			if (glob.img_info.is_mono)
				mode = MD_TRANS;
			else if (tb.truecolor)
				mode = S_AND_D;
			else
				mode = S_OR_D;
		} else {
			if (glob.img_info.is_mono)
				mode = MD_REPLACE;
			else
				mode = S_ONLY;
		}
		if (conf.imgcenter) {
			/* zentriert */

			/* Horizontal */
			if (img->fd_w > tb.desk.g_w) {
				pxy[0] = (img->fd_w - tb.desk.g_w) / 2;
				pxy[2] = pxy[0] + tb.desk.g_w - 1;
				pxy[4] = tb.desk.g_x;
				pxy[6] = tb.desk.g_x + tb.desk.g_w - 1;
			} else {
				pxy[0] = 0;
				pxy[2] = img->fd_w - 1;
				pxy[4] =  tb.desk.g_x + (tb.desk.g_w - img->fd_w) / 2;
				pxy[6] = pxy[4] + img->fd_w - 1;
			}
			/* Vertikal */
			if (img->fd_h > tb.desk.g_h) {
				pxy[1] = (img->fd_h - tb.desk.g_h) / 2;
				pxy[3] = pxy[1] + tb.desk.g_h - 1;
				pxy[5] = tb.desk.g_y;
				pxy[7] = tb.desk.g_y + tb.desk.g_h - 1;
			} else {
				pxy[1] = 0;
				pxy[3] = img->fd_h - 1;
				pxy[5] = tb.desk.g_y + (tb.desk.g_h - img->fd_h) / 2;
				pxy[7] = pxy[5] + img->fd_h - 1;
			}
			if (glob.img_info.is_mono)
				vrt_cpyfm(tb.vdi_handle, mode, pxy, img, &scr, col);
			else
				vro_cpyfm(tb.vdi_handle, mode, pxy, img, &scr);
		} else {
			/* gekachelt */
			short maxx, maxy;

			pxy[0] = pxy[1] = 0;
			if (img->fd_w > tb.desk.g_w)
				w = tb.desk.g_w;
			else
				w = img->fd_w;
			if (img->fd_h > tb.desk.g_h)
				h = tb.desk.g_h;
			else
				h = img->fd_h;
			pxy[2] = w - 1;
			pxy[3] = h - 1;

			maxx = tb.desk.g_x + tb.desk.g_w - 1;
			maxy = tb.desk.g_y + tb.desk.g_h - 1;

			for(pxy[4] = tb.desk.g_x; pxy[4] <= maxx; pxy[4] += w) {
				for(pxy[5] = tb.desk.g_y; pxy[5] <= maxy; pxy[5] += h) {
					pxy[6] = pxy[4] + w - 1;
					pxy[7] = pxy[5] + h - 1;
					draw.g_x = pxy[4];
					draw.g_y = pxy[5];
					draw.g_w = w;
					draw.g_h = h;
					/* Aktuelle Kachel Åberhaupt im zu zeichnenden Bereich? */
					if (rc_intersect(&clip, &draw)) {
						if(glob.img_info.is_mono)
							vrt_cpyfm(tb.vdi_handle, mode, pxy, img, &scr, col);
						else
							vro_cpyfm(tb.vdi_handle, mode, pxy, img, &scr);
					}
				}
			}
		}
	}

	/* Clipping ausschalten */
	vs_clip(tb.vdi_handle, 0, pxy);

	/* Keinen Status an die AES weitergeben */
	return (0);
}

/*-------------------------------------------------------------------------
 sel2buf()

 Aktuelle Auswahl als String bereitstellen
 -------------------------------------------------------------------------*/
short sel2buf(char *buf, char *aname, char *apath, short maxlen) {
	short i, cont, n, m, pn;
	char name[MAX_PLEN];
	W_PATH *wpath;
	WP_ENTRY *wpitem;
	W_GRP *wgrp;
	WG_ENTRY *wgitem;
	ICONDESK *p;

	cont = 1;
	if (buf)
		buf[0] = 0;
	pn = 0;

	if (desk.sel.desk) {
		p = desk.dicon + 1;
		for (i = 1; i <= MAXICON && cont; i++, p++) {
			if (p->class!=IDFREE && p->select) {
				name[0] = 0;
				switch (p->class) {
				case IDDRIVE:
					name[0] = 'A' + p->spec.drive->drive;
					name[1] = ':';
					name[2] = '\\';
					name[3] = 0;
					strcpy(apath, name);
					aname[0] = 0;
					break;
				case IDFILE:
					strcpy(name, p->spec.file->name);
					full2comp(name, apath, aname);
					break;
				case IDFOLDER:
					strcpy(name, p->spec.folder->path);
					strcpy(apath, p->spec.folder->path);
					aname[0] = 0;
					break;
				}
				if (buf) {
					quote(name);
					m = (short) strlen(buf);
					n = (short) strlen(name);
					if (pn)
						n++;
					if (n + m < maxlen) {
						if (pn)
							strcat(buf, " ");
						else
							pn = 1;
						strcat(buf, name);
					} else
						cont = 0;
				}
			}
		}
	} else {
		if (desk.sel.win && !(desk.sel.win->state & WSICON)) {
			switch (desk.sel.win->class) {
			case WCPATH:
				wpath = (W_PATH *)desk.sel.win->user;
				for (i = 0; i < wpath->e_total && cont; i++) {
					wpitem = wpath->lptr[i];
					if (wpitem->sel) {
						strcpy(name, wpath->path);
						strcat(name, wpitem->name);
						if (wpitem->class == EC_FILE)
							full2comp(name, apath, aname);
						else {
							strcat(name, "\\");
							strcpy(apath, name);
						}
						if (buf) {
							quote(name);
							m = (short)strlen(buf);
							n = (short)strlen(name);
							if (pn)
								n++;
							if (n + m < maxlen) {
								if (pn)
									strcat(buf, " ");
								else
									pn = 1;
								strcat(buf, name);
							} else
								cont = 0;
						}
					}
				}
				break;

			case WCGROUP:
				wgrp = (W_GRP *)desk.sel.win->user;
				wgitem = wgrp->entry;
				while (wgitem && cont) {
					if (wgitem->sel) {
						wgrp_eabs(wgrp, wgitem, name);
						if (wgitem->class == EC_FILE)
							full2comp(name, apath, aname);
						else {
							strcpy(apath, name);
							aname[0] = 0;
						}
						if (buf) {
							quote(name);
							m = (short)strlen(buf);
							n = (short)strlen(name);
							if (pn)
								n++;
							if (n + m < maxlen) {
								if (pn)
									strcat(buf, " ");
								else
									pn = 1;
								strcat(buf, name);
							} else
								cont = 0;
						}
					}
					wgitem = wgitem->next;
				}
				break;
			}
		}
	}

	return (cont);
}

short drag_scroll(short my, short w, short h, short moved, WININFO *win, short n, short *pxy,
		void (*rubbox)(short, short *)) {
	short dy = 0, old_offy, *offy;
	W_PATH *wpath;
	W_GRP *wgrp;

#define Y_OFFSET 16

	if (moved && !w && (abs(h) < 1)) {
		switch (win->class)
		{
			case WCPATH:
			wpath = (W_PATH *)win->user;
			offy = &wpath->offy;
			break;
			case WCGROUP:
			wgrp = (W_GRP *)win->user;
			offy = &wgrp->offy;
			break;
			default:
			return(0);
		}
		old_offy = *offy;
		if (my < win->work.g_y)
			dy = win->work.g_y - my;
		if (my > (win->work.g_y + win->work.g_h - Y_OFFSET))
			dy = win->work.g_y + win->work.g_h - Y_OFFSET - my;
		if (dy) {
			if (dy / 2)
				dy /= 2;
			(rubbox)(n, pxy);
			win_slide(win, S_PABS, 0, dy * conf.scroll);
			evnt_timer(20L);
			(rubbox)(n, pxy);
		}
		return (*offy != old_offy);
	}
	return (0);
}

/* EOF */
