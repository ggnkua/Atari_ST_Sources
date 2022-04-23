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

/**=========================================================================
 WINDESK.C

 Thing
 Verzeichnisfenster
 =========================================================================*/
#include "..\include\globdef.h"
#include "..\include\types.h"
#include "rsrc\thing_de.h"
#include "rsrc\thgtxtde.h"
#include <ctype.h>
#include <time.h>

#ifdef TIMER
static clock_t timer;
#endif
static void wpath_iconupdate(W_PATH *wpath, int first, int last);

/**-------------------------------------------------------------------------
 wpath_find()

 Verzeichnisfenster anhand des Pfades ermitteln
 -------------------------------------------------------------------------*/
WININFO *wpath_find(char *path) {
	W_PATH *wpath;
	int n;

	n = 0;
	while (n < MAX_PWIN) {
		if (glob.win[n].state & WSOPEN) {
			wpath = (W_PATH *) glob.win[n].user;
			if (!strcmp(wpath->path, path))
				return &glob.win[n];
		}
		n++;
	}

	return 0L;
}

/**-------------------------------------------------------------------------
 wpath_obfind()

 Neues Verzeichnisfenster oeffnen und angegeben Datei darin selektieren
 -------------------------------------------------------------------------*/
int wpath_obfind(char *full) {
	char path[MAX_PLEN], name[MAX_FLEN];
	W_PATH *wpath;
	WP_ENTRY *item, *sitem;
	RECT wrect;
	int i, wrd;

	full2comp(full, path, name);
	if (wpath_open(path, "*", 1, 0L, conf.index.text, -1, conf.index.sortby)) {
		/* Datei selektieren */
		sitem = 0L;
		wpath = (W_PATH *) tb.topwin->user;
		for (i = 0; i < wpath->e_total; i++) {
			item = wpath->lptr[i];
			if (item->class == EC_FILE) {
				if (!strcmp(name, item->name))
					sitem = item;
			}
		}
		icon_select(-1, 0, 0);
		if (sitem) {
			wpath_esel1(tb.topwin, sitem, 1, &wrect, &wrd);
			sitem->sel = 1;
			wpath_info(tb.topwin);
			wpath_showsel(tb.topwin, 0);
		} else
			mybeep();

		return (1);
	} else
		return (0);
}

/**-------------------------------------------------------------------------
 wpath_name()

 Setzt den Fenstertitel eines Verzeichnisfensters
 -------------------------------------------------------------------------*/
void wpath_name(WININFO *win) {
	W_PATH *wpath;
	char wtitle[MAX_PLEN];
	int i, r;

	wpath = ((W_PATH *) win->user);

	strcpy(wtitle, wpath->path);
	if (wpath->rel) {
		i = (int) strlen(wpath->path) - 2;
		if (i > 0) {
			r = wpath->rel;
			while (r > 1) {
				while (wpath->path[i] != '\\')
					i--;
				i--;
				r--;
			}
			if (wpath->relname[0]) {
				strcpy(wtitle, wpath->relname);
				if (wpath->rel > 1)
					strcat(wtitle, &wpath->path[i + 1]);
				else
					strcat(wtitle, "\\");
			} else {
				while (wpath->path[i] != '\\')
					i--;
				i++;
				strcpy(wtitle, &wpath->path[i]);
			}
		}
	}

	if (!strcmp(wpath->index.wildcard, "*"))
		sprintf(win->name, " %s ", wtitle);
	else
		sprintf(win->name, " %s%s ", wtitle, wpath->index.wildcard);
	wind_set(win->handle, WF_NAME, win->name);
}

/**-------------------------------------------------------------------------
 wpath_parent()

 Zum Parentverzeichnis wechseln - ist das Verzeichnis bereits ein
 Hauptverzeichnis, oder tritt ein Fehler auf wird als Ergebnis 0
 zurueckgeliefert
 -------------------------------------------------------------------------*/
int wpath_parent(WININFO *win, int new, int rel) {
	W_PATH *wpath;
	WP_ENTRY *item, *sitem;
	RECT wrect;
	int wrd;
	int i, p, l,ret, wrel;
	char path[MAX_PLEN], foldr[MAX_FLEN];
	WININFO *lwin;

	if (conf.relwin)
		wrel = rel;
	else
		wrel = 0;

	/* Ggf. Wildcard-Dialog schliessen */
	if (fi_mask.open) {
		if (dmask->win == win) {
			fi_mask.exit(1, 0);
		}
	}

	wpath = (W_PATH *)win->user;

	/* Falls Verzeichnis relativ und entsprechender Modus,
	 dann abbrechen, damit die aufrufende Routine das Fenster
	 schliesst */
	if (new != 1) {
		if (wpath->rel) {
			wpath->rel--;
			if (!wpath->rel && wrel) {
				if (new == 2) {
					wpath->rel = 1;
					wpath_name(win);
				}
				return (0);
			}
			/* else wpath_name(win); */
		}
	}

	l = (int)strlen(wpath->path);
	if (l == 3)
		return (0);
	else {
		strcpy(path,wpath->path);
		i = l - 2;
		while (path[i] != '\\')
			i--;
		i++;
		p = i;
		l = 0;
		while (path[i] != '\\' && path[i]) {
			foldr[l] = path[i];
			i++;
			l++;
		};
		foldr[l] = 0;
		path[p] = 0;

		if (new != 1) {
			/* Inhalt aktualisieren */
			wpath->offx = wpath->offy = 0;
			strcpy(wpath->path, path);
			if (new != 2) {
				ret = wpath_update(win);
				/* Alten Ordner ggf. selektieren */
				if (ret) {
					sitem = 0L;
					for (i = 0; i < wpath->e_num; i++) {
						item = wpath->lptr[i];
						if (item->used && item->class == EC_FOLDER) {
							if (!strcmp(item->name, foldr))
								sitem = item;
						}
					}
					if (sitem) {
						icon_select(-1, 0, 0);
						lwin = tb.win;
						while (lwin) {
							switch (lwin->class) {
								case WCPATH:
									((W_PATH *)lwin->user)->amask[0] = 0;
									wpath_esel(lwin, 0L, 0, 0, 1);
								break;
							}
							lwin = lwin->next;
						}
						wpath_esel1(win, sitem, 1, &wrect, &wrd);
						wpath->focus = sitem->obnum - 1;
					}
				}
				wpath_showsel(win, 0);
				win_slide(win, S_INIT, 0, 0);
#if 1
				w_draw(win);
#else
				win_redraw(win,tb.desk.x,tb.desk.y,tb.desk.w,tb.desk.h);
#endif
			}
			else
			{
				wpath_name(win);
				ret = 1;
			}
			wpath_info(win);
		} else {
			ret = wpath_open(path,wpath->index.wildcard, 1, 0L, wpath->index.text, -1, wpath->index.sortby);
		}

		return (ret);
	}
}

/**-------------------------------------------------------------------------
 wpath_lfree()

 Durch Verzeichniseintr„ge belegten Speicher freigeben
 -------------------------------------------------------------------------*/
void wpath_lfree(WININFO *win) {
	W_PATH *wpath;

	wpath = (W_PATH *) win->user;
	if (wpath->list) {
		Mfree(wpath->list);
		wpath->list = 0L;
	}
	if (wpath->lptr) {
		pfree(wpath->lptr);
		wpath->lptr = 0L;
	}
	wpath->e_num = 0;
	wpath->iconok = 0;
}

/**-------------------------------------------------------------------------
 wpath_tfree()

 Durch Objektbaum belegten Speicher freigeben.
 -------------------------------------------------------------------------*/
void wpath_tfree(WININFO *win) {
	W_PATH *wpath;

	wpath = (W_PATH *) win->user;

	/* Bisherigen Objektbaum freigeben */
	if (wpath->wicon) {
		pfree(wpath->wicon);
		wpath->wicon = 0L;
	}
	if (wpath->tree) {
		pfree(wpath->tree);
		wpath->tree = 0L;
	}
}

/**-------------------------------------------------------------------------
 wpath_pat()

 Žndert Muster und Farbe des Hintergrunds der Verzeichnisfenster
 -------------------------------------------------------------------------*/
void wpath_pat(void) {
	int i;
	W_PATH *wpath;
	OBJECT *tree;

	for (i = 0; i < MAX_PWIN; i++) {
		if (glob.win[i].state & WSINIT) {
			wpath = (W_PATH *) glob.win[i].user;
			tree = wpath->tree;
			if (tree) {
				tree->ob_spec.obspec.interiorcol = conf.font.bcol;
				tree->ob_spec.obspec.fillpattern = conf.bpat;
				win_redraw(&glob.win[i], tb.desk.x, tb.desk.y, tb.desk.w, tb.desk.h);
			}
		}
	}
}

/**-------------------------------------------------------------------------
 wpath_tree()

 Baut den Objektbaum eines Verzeichnisfensters neu auf.
 -------------------------------------------------------------------------*/
void wpath_tree(WININFO *win) {
	W_PATH *wpath;
	OBJECT *tree;
	ICONBLK *iblk, *tiblk;
	int i, n, nname, next, mx, my, nx, ix, iy, iw, ih;
	int tx, tw;
	int out[8], namelen;
	int uidlen, gidlen;
	WP_ENTRY *entry;
	int cld, crd;
	int tos;
	char *xch = "rhaswx";

	/* Bisherigen Objektbaum freigeben */
	wpath_tfree(win);
	wpath = (W_PATH *) win->user;

	/* Fuer 'optimiererenden Fuller' Fulled-Status loeschen */
	win->state &= ~WSFULL;

	/* Falls n”tig, Icons holen/aktualisieren */
	if ((wpath->index.text != 1 || !conf.qread) && !wpath->iconok) {
		wpath->iconok = 1;
		wpath_iconupdate(wpath, -1, -1);
	}

	/* Bei Textdarstellung keinen Objektbaum erzeugen */
	if (wpath->index.text) {
		vst_font(tb.vdi_handle, wpath->font.id);
		if (wpath->font.size < 0) {
			vst_height(tb.vdi_handle, -wpath->font.size, &wpath->cw,
					&wpath->ch, &wpath->clw, &wpath->clh);
		} else {
			vst_point(tb.vdi_handle, wpath->font.size, &wpath->cw, &wpath->ch,
					&wpath->clw, &wpath->clh);
		}
		/* Workaround fr Problem mit STEmulator + NVDI Atari */
		v_gtext(tb.vdi_handle, 0, 0, "");

		/* Bei Symboltext Mindesth”he fr Symbole */
		wpath->ch = wpath->clh;
		if (wpath->index.text == 2) {
			if (wpath->clh < glob.sheight)
				wpath->clh = glob.sheight;
		}

		/* Breite eines Eintrages in Pixeln berechnen */
		vqt_width(tb.vdi_handle, '.', &wpath->cw_p1, &cld, &crd);
		vqt_width(tb.vdi_handle, ':', &wpath->cw_p2, &cld, &crd);
		vqt_width(tb.vdi_handle, '9', &wpath->cw_nine, &cld, &crd);
		vqt_width(tb.vdi_handle, '-', &wpath->cw_sl, &cld, &crd);
		wpath->cw_x = 0;
		for (i = 0; i < 5; i++) {
			vqt_width(tb.vdi_handle, xch[i], &n, &cld, &crd);
			if (n > wpath->cw_x)
				wpath->cw_x = n;
		}

		wpath->ih = wpath->clh;
		if (wpath->clw < wpath->clh / 2)
			wpath->iw = wpath->clw * 2;
		else
			wpath->iw = wpath->clh;

		/* Bei Symboltext Mindestbreite der Symbolspalte */
		if (wpath->index.text == 2) {
			if (wpath->iw < 20)
				wpath->iw = 20;
		}

		wpath->tlen = wpath->clw; /* Linker Rand */
		wpath->tlen += wpath->iw + wpath->clw / 2 + 1; /* Icon fuer Ordner */

		/* Neues Feature: Anpassen der Darstellung an den breitesten Eintrag */
		namelen = nname = next = 0;
		uidlen = gidlen = 0;
		tos = !!(wpath->filesys.flags & TOS);
		if (!conf.tosmode)
			tos = 0;
		for (i = 0; i < wpath->e_total; i++) {
			entry = wpath->lptr[i];
			if (entry->link)
				vst_effects(tb.vdi_handle, 4 | ((entry->link == 2) ? 2 : 0));
			else
				vst_effects(tb.vdi_handle, 0);

			/* Darstellung als 'AAAAAAAA.AAA' */
			if (tos) {
				/* Laenge des Dateinamens */
				if (entry->fext)
					*(entry->fext) = 0;
				vqt_extent(tb.vdi_handle, entry->name, out);
				n = out[2] - out[0];
				if (n > nname)
					nname = n;

				/* Laenge der Extension */
				if (entry->fext) {
					*(entry->fext) = '.';
					vqt_extent(tb.vdi_handle, entry->fext + 1, out);
					n = out[2] - out[0] + wpath->cw_p1;
				} else
					n = 0;
				if (n > next)
					next = n;
				n = nname + next;
			} else {
				/* Normale Darstellung */
				vqt_extent(tb.vdi_handle, entry->name, out);
				n = out[2] - out[0];
			}
			if (n > namelen)
				namelen = n;

			/* Ggf. Laenge von UID und GID anpassen */
			if (wpath->filesys.flags & OWNER) {
				char hlp[8], *ptr;

				itoa(entry->uid, hlp, 10);
				ptr = get_username(entry->uid);
				vqt_extent(tb.vdi_handle, ptr ? ptr : hlp, out);
				n = out[2] - out[0];
				if (n > uidlen)
					uidlen = n;
				itoa(entry->gid, hlp, 10);
				ptr = get_groupname(entry->gid);
				vqt_extent(tb.vdi_handle, ptr ? ptr : hlp, out);
				n = out[2] - out[0];
				if (n > gidlen)
					gidlen = n;
			}
		}
		if (!namelen)
			namelen = wpath->clw * wpath->filesys.namelen;
		if (!nname)
			nname = namelen;
		if (!uidlen)
			uidlen = wpath->clw * 8;
		if (!gidlen)
			gidlen = wpath->clw * 8;
		wpath->pext = wpath->iw + wpath->clw / 2 + nname;

		wpath->tlen += namelen;

		/* Groesse: ' 999.999' oder ' 9999 kB'*/
		if (wpath->index.show & SHOWSIZE) {
			wpath->tlen += wpath->cw_nine * 7;
			wpath->psize = wpath->tlen;
			wpath->tlen += wpath->clw;
		}

		/* Datum: ' 99-99-9999' */
		if (wpath->index.show & SHOWDATE) {
			wpath->tlen += wpath->cw_nine * 2;
			wpath->tlen += wpath->cw_sl;
			wpath->pdate1 = wpath->tlen;
			wpath->tlen += wpath->cw_nine * 6;
			wpath->tlen += wpath->cw_sl;
			wpath->pdate = wpath->tlen;
			wpath->tlen += wpath->clw;
		}

		/* Uhrzeit: ' 99:99' */
		if (wpath->index.show & SHOWTIME) {
			wpath->tlen += wpath->cw_nine * 4;
			wpath->tlen += wpath->cw_p2;
			wpath->ptime = wpath->tlen;
			wpath->tlen += wpath->clw;
		}

		/* Attribute: ' rhsa rwxrwxrwx' */
		if (wpath->index.show & SHOWATTR) {
			if (!(wpath->filesys.flags & UNIXATTR)) {
				/* TOS-FS: rhsa */
				wpath->pattr = wpath->tlen;
				wpath->tlen += (wpath->cw_x * 4);
				wpath->tlen += wpath->clw;
			} else {
				/* sonst: rwxrwxrwx und ggf. uid/gid */
				wpath->pmode = wpath->tlen;
				wpath->tlen += (wpath->cw_x * 9);
				if (wpath->filesys.flags & OWNER) {
					wpath->tlen += 2 * wpath->clw + uidlen;
					wpath->pgid = wpath->tlen;
					wpath->tlen += gidlen;
				}
				wpath->tlen += wpath->clw;
			}
		}
		wpath->tlen += wpath->clw + 1; /* Rechter Rand */

		mx = (win->work.w - 10 + 2 * wpath->clw) / wpath->tlen;
		if (mx == 0)
			mx = 1;
		my = wpath->e_total / mx;
		if ((wpath->e_total - my * mx) > 0)
			my++;
		wpath->imx = mx;
		wpath->imy = my;

		goto wpath_tree_r;
	}

	/* Neuen Objektbaum erzeugen */
	tree = pmalloc(sizeof(OBJECT) * (long) (wpath->e_total + 1));
	if (!tree) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		goto wpath_tree_r;
	}
	wpath->tree = tree;

	/* Fensterhintergrund */
	tree->ob_next = -1;
	tree->ob_head = -1;
	tree->ob_tail = -1;
	tree->ob_type = G_BOX;
	tree->ob_flags = LASTOB;
	tree->ob_state = NORMAL;
	tree->ob_spec.obspec.framesize = 0;
	tree->ob_spec.obspec.framecol = 0;
	tree->ob_spec.obspec.fillpattern = conf.bpat;
	tree->ob_spec.obspec.interiorcol = conf.font.bcol;
	tree->ob_x = win->work.x;
	tree->ob_y = win->work.y;
	tree->ob_width = win->work.w;
	tree->ob_height = win->work.h;

	if (wpath->e_total < 1)
		return;

	/* Verzeichniseintr„ge */
	if (wpath->index.text) {
		/* Als Text */
	} else {
		wpath->wicon = pmalloc(sizeof(WICON) * (long) wpath->e_total);
		if (!wpath->wicon) {
			wpath_tfree(win);
			frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
			goto wpath_tree_r;
		}

		/* Iconraster X berechnen */
		iw = 32;
		ih = 2;
		namelen = 0;
		for (i = 0; i < wpath->e_total; i++) {
			entry = wpath->lptr[i];
			n = calc_small_text_width(entry->name);
			if (n > namelen)
				namelen = n;
			/* Ergaenzung: Maximale Iconhoehe/-breite ermitteln und ggf.
			 'namelen' anpassen */
			tiblk = entry->iconimg->iconblk;
			if (tiblk->ib_hicon > ih)
				ih = tiblk->ib_hicon;
			if (tiblk->ib_wicon > iw)
				iw = tiblk->ib_wicon;
		}
		ih += 1;
		ih &= ~1;
		iw += 1;
		iw &= ~1;
		n = namelen + 8;
		/* Ergaenzung: Falls Icons breiter als Text, dann anpassen */
		if (iw > n)
			n = iw;

		wpath->tlen = namelen = n;

		/* Breite der Icon-Texte */
		tw = namelen - 4;

		mx = win->work.w / namelen; /* Anzahl der Icons pro Zeile */
		if (mx > wpath->e_total)
			mx = wpath->e_total;
		if (!mx)
			mx = 1;
		wpath->imx = mx;

		/* Hintergrund anpassen */
		tree->ob_head = 1;
		tree->ob_tail = wpath->e_total;
		tree->ob_flags = NONE;
		if (mx * namelen > win->work.w)
			tree->ob_width = mx * namelen;

		nx = 0;
		ix = 0;
		iy = 0;
		for (i = 0; i < wpath->e_total; i++) {
			entry = wpath->lptr[i];
			n = i + 1;
			tree[n].ob_head = -1;
			tree[n].ob_tail = -1;
			if (n < wpath->e_total) {
				tree[n].ob_next = n + 1;
				tree[n].ob_flags = NONE;
			} else {
				tree[n].ob_next = 0;
				tree[n].ob_flags = LASTOB;
			}
			if (entry->sel)
				setObjectSelected(tree, n);
			else
				tree[n].ob_state = NORMAL;
			if (entry->link == 2)
				tree[n].ob_state |= DISABLED;
			tree[n].ob_width = namelen;

			icn_setimg(&wpath->wicon[i], &tree[n], entry->iconimg, entry->name);
			iblk = &wpath->wicon[i].ciconblk.monoblk;
			iblk->ib_char = 0x1000;
			iblk->ib_xchar = 0;
			iblk->ib_ychar = 0;
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
		}

		/* Anzahl der Zeilen erst hier bekannt */
		ih += 4 + 2 * tb.fs_ch;
		my = iy / ih + 1;
		if (nx == 0)
			my--;
		wpath->imy = my;
		tree->ob_height = my * ih;
		wpath->ih = ih;
	}
	wpath_tree_r: ;
	if (conf.autosize) {
		win->state &= ~WSFULL;
		w_full(win);
	}
}

/**-------------------------------------------------------------------------
 wpath_update()

 Liest ein Verzeichnis ein und baut daraus eine verkettete Liste auf
 -------------------------------------------------------------------------*/
int wpath_update(WININFO *win) {
	W_PATH *wpath;
	WP_ENTRY *entry;
	char *p, *ename;
	char full[MAX_PLEN];
	int num, i, wret, fs, toolong;
	long lret, xret;
	DTA dta, *odta;
	long dhandle;
	unsigned int fmode;
	int usemint, usexr;
	char dbuf[MAX_FLEN + 4];
	char *fname;
	XATTR xattr, xattrl;
	int link, retry, useit, lmax;
	int uid, gid;
	int adate, atime, cdate, ctime;
	char inbuf[1024];
	FILE *handle;
	unsigned long id;
	int depth;
#if 0
	/* Workaround fuer Links */
	char lbuf[MAX_PLEN];
	int llen;
#endif

#ifdef TIMER
	timer = clock();
#endif
	graf_mouse(BUSYBEE, 0L);
	wpath = (W_PATH *) win->user;
DEBUGLOG((0, "wpath_update(%s)\n", wpath->path));
	strcpy(full, wpath->path);
	strcat(full, FNAME_IDX);
	if (memcmp(&wpath->index, &wpath->cindex, sizeof(INDEX))) {
		for (i = 0; i < 10; i++)
			wpath->oindex[i] = wpath->index;
	}
	depth = count_char(wpath->path, '\\');
	if ((handle = fopen(full, "r")) != NULL) {
		while (fgets(inbuf, 1024, handle)) {
			if ((p = strrchr(inbuf, '\r')) != NULL)
				*p = 0;
			if ((p = strrchr(inbuf, '\n')) != NULL)
				*p = 0;
			id = *(unsigned long *) inbuf;
			if (id == 'IDEX') {
				sscanf(&inbuf[5], "%d %d", &wpath->index.text, &wpath->index.sortby);
			}
			if (id == 'MASK') {
				if (get_buf_entry(&inbuf[5], wpath->index.wildcard, NULL)) {
					if (!*wpath->index.wildcard)
						strcpy(wpath->index.wildcard, "*");
				} else
					strcpy(wpath->index.wildcard, "*");
			}
		}
		fclose(handle);
	} else {
		if (depth <= 10)
			wpath->index = wpath->oindex[depth - 1];
	}
	for (i = depth - 1; i < 10; i++)
		wpath->oindex[i] = wpath->index;
	wpath->cindex = wpath->index;
	retry = 0;

	/* Bisherige Eintraege, Auto-Locator und Cursor loeschen */
	wpath_lfree(win);
	wpath->amask[0] = 0;
	wpath->focus = 0;
	wpath_iupdate(win, 1);

	odta = Fgetdta();
	Fsetdta(&dta);

	/* Neue Buffer reservieren */
	wpath->e_num = 0;
	lmax = 8192;
	while (!wpath->list && lmax > 0) {
		wpath->list = Malloc((long) lmax * sizeof(WP_ENTRY));
		if (!wpath->list)
			lmax = lmax / 2;
	}
	if (!wpath->list) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		wret = 0;
		goto wpath_update1;
	}

wpath_update2:
	if (getCookie('MgMc', 0L) && getCookie('SCSI', 0L)) {
		DISKINFO dummy;

		Dfree(&dummy, (wpath->path[0] & ~32) - 'A');
	}

	/* Art des Dateisystems ermitteln */
	fsinfo(wpath->path, &wpath->filesys);

	/* Bei Bedarf Schreibweise der Maske und des Pfades anpassen */
	/* if(wpath->filesys.flags & UPCASE)
	 { */
	i = 0;
	p = wpath->index.wildcard;
	while (p[i]) {
		p[i] = nkc_toupper(p[i]);
		i++;
	}
	/* fsconv(wpath->path,&wpath->filesys); */
	/* } */

	/* Verzeichnis lesen */
	fs = toolong = 0; /* Flag fr Fehler l”schen */
	usexr = 1;
	if ((int) strlen(wpath->path) > 3) {
		strcpy(full, wpath->path);
		full[(int) strlen(full) - 1] = 0;

		dhandle = Dopendir(wpath->path, 0);
		if (dhandle == -32L) {
			/* Kein MiNT-Zugriff moeglich */
			usemint = 0;
			lret = (long) Fsfirst(full, FA_SUBDIR | FA_HIDDEN | FA_SYSTEM);
			if (lret != 0L)
				fs = 1; /* Fehler? */
			wpath->fdate = dta.d_date;
			wpath->ftime = dta.d_time;
			fmode = 0;
		} else {
			/* Eventuell Fehler bei Dopendir() aufgetreten? */
			usemint = 1;
			/* Fehlerflag ggf. setzen */
			if ((dhandle & 0xff000000L) == 0xff000000L) {
				lret = dhandle;
				fs = 1;
			} else {
				/* Keine Fehler... */

				/* Attribute ermitteln - da Dopendir() nicht mit DTAs arbeitet */
				Fxattr(1, wpath->path, &xattr);
				wpath->fdate = xattr.mdate;
				wpath->ftime = xattr.mtime;
				fmode = xattr.mode; /* Dateityp ggf. maskieren */
				if (!(wpath->filesys.flags & UNIXATTR))
					fmode &= S_IFMT;
				lret = 0L;
			}
		}
	} else {
		lret = 0L;
		dhandle = Dopendir(wpath->path, 0);
		/* Kein MiNT-Zugriff moeglich */
		if (dhandle == -32L) {
			usemint = 0;
		} else {
			/* Eventuell Fehler bei Dopendir() aufgetreten? */
			usemint = 1;
			if ((dhandle & 0xff000000L) == 0xff000000L) {
				lret = dhandle;
				fs = 1;
			}
		}
	}

DEBUGLOG((0, "After opening %s: fs: %d, lret: %ld\n", wpath->path, fs, lret));
	/* Fehler aufgetreten? */
	if (fs) {
		if (wpath->path[3] && (lret == -34L || lret == -33L || lret == -49L)) {
			/* Erst mal Parent probieren */
			/* Falls relativer Pfad, dann abbrechen */
			if (wpath->rel) {
				wret = 0;
			} else {
				i = (int) strlen(wpath->path) - 2;
				while (wpath->path[i] != '\\')
					i--;
				i++;
				wpath->path[i] = 0;
				goto wpath_update2;
			}
		} else {
			/* Media-Change oder Lock? */
			if (lret == -14L || lret == -58L) {
				/* Bei Lock kurze Pause einlegen */
				if (lret == -58L)
					evnt_timer(500, 0);
				retry++;
				if (retry < 2)
					goto wpath_update2;
			}
			err_file(rs_frstr[ALPREAD], lret, wpath->path);
			wret = 0;
		}
	} else {
		/* Keine Fehler... */
		if (!usemint) {
			fname = dta.d_fname;
			fmode = 0;
			strcpy(full, wpath->path);
			strcat(full, "*.*");
			lret = (long) Fsfirst(full, FA_SUBDIR | FA_HIDDEN | FA_SYSTEM);
			if (lret == 0L) {
				adate = cdate = dta.d_date;
				atime = ctime = dta.d_time;
				uid = gid = 0;
			}
		} else {
			fname = &dbuf[4];

			/* Aktuelles Verzeichnis setzen, damit bei Fxattr() nicht
			 jedesmal ein kompletter Pfad Uebergeben werde muss */
DEBUGLOG((0, "wpath_update: Setting dir to %s\n", wpath->path));
			set_dir(wpath->path);

			/* Dxreaddir() probieren und merken, falls das nicht geht */
			if (usexr) {
				lret = Dxreaddir(MAX_FLEN + 4, dhandle, dbuf, &xattr, &xret);
				if (lret == -32L)
					usexr = 0;
			}

			/* Dxreaddir() hat nicht geklappt - dann Dreaddir()/Fxattr() */
			if (!usexr) {
				lret = Dreaddir(MAX_FLEN + 4, dhandle, dbuf);
				if (lret == 0L)
					xret = Fxattr(1, fname, &xattr);
			}

			if (lret == 0L) {
				if (xret != 0L)
					lret = xret;
				else {
					dta.d_date = xattr.mdate;
					dta.d_time = xattr.mtime;
					dta.d_attrib = xattr.attr;
					dta.d_length = xattr.size;
					fmode = xattr.mode;
					if (!(wpath->filesys.flags & UNIXATTR))
						fmode &= S_IFMT;
					uid = xattr.uid;
					gid = xattr.gid;
					adate = xattr.adate;
					atime = xattr.atime;
					cdate = xattr.cdate;
					ctime = xattr.ctime;
				}
			}
		}

		if (lret) {
			if (lret == -64L)
				toolong = 1; /* Merken, dass ein zu langer Eintrag vorhanden ist */
			else
				fs = 1; /* Ggf. Fehlerflag setzen */
		}

		/* Ggf. '..'-Objekt erzeugen */
		num = 0;
		if (wpath->path[3]) {
			entry = &wpath->list[0];
			wpath->e_num++;

			entry->link = 0;
			strcpy(entry->name, "..");
			entry->fext = NULL;
			entry->mode = 0;
			entry->class = EC_PARENT;
			entry->size = 0L;
			entry->attr = 0;
			entry->date = 0;
			entry->time = 0;
			entry->uid = 0;
			entry->gid = 0;
			entry->adate = entry->atime = 0;
			entry->cdate = entry->ctime = 0;
			entry->sel = entry->prevsel = 0;
			entry->tchar = 0;
			entry->tcolor = -1;
			entry->num = num;
			entry->obnum = num + 1;
			num++;
		}

		while (!fs) {
			/* War letzter Eintrag zu lang, gleich naechsten bearbeiten */
			if (lret == -64L)
				goto get_next;

			/* Bei Bedarf Schreibweise anpassen */
			if (wpath->filesys.flags & UPCASE) {
				i = 0;
#if 0
				while(fname[i]) {fname[i]=nkc_toupper(fname[i]);i++;}
#else
				while (fname[i]) {
					fname[i] = toupper(fname[i]);
					i++;
				}
#endif
			}
			/* Pruefen, ob der Eintrag verwendet wird */
			useit = 1;
			if (dta.d_attrib & FA_SUBDIR && (fname[0] == '.' && fname[1] == 0) || (fname[0] == '.' && fname[1] == '.' && fname[2] == 0))
				useit = 0;

			if (!conf.hidden) {
				if ((dta.d_attrib & FA_HIDDEN) || (!(wpath->filesys.flags & TOS) && (fname[0] == '.'))) {
					useit = 0;
				}
			}

			/* Win '95-Eintraege ausfiltern */
			if (dta.d_attrib & FA_VOLUME)
				useit = 0;

			if (useit) {
				link = 0;
				/* Falls ein sym. Link vorliegt, dann Daten ermitteln */
				if ((fmode & S_IFMT) == S_IFLNK) {
DEBUGLOG((0, "wpath_update: Following link %s\n", fname));
					if (Fxattr(0, fname, &xattrl) == 0L) {
						/* Alles klar - Attribute des Originals merken */
						dta.d_attrib = xattrl.attr;
						dta.d_date = xattrl.mdate;
						dta.d_time = xattrl.mtime;
						dta.d_attrib = xattrl.attr;
						dta.d_length = xattrl.size;
						fmode = xattrl.mode;
						if (!(wpath->filesys.flags & UNIXATTR))
							fmode &= S_IFMT;
						link = 1;
					} else {
DEBUGLOG((0, "wpath_update: Link is orphaned\n"));
						/* Fehler - also "zielloser" Link */
						link = 2; /* Kennzeichen fuer Link ohne Ziel */
						fmode = 0;
					}
				}
			}

			if (useit) {
				/* Verzeichniseintrag merken */
				if (wpath->e_num >= lmax) {
					/* Freier Eintrag verfuegbar? */
					if (usemint)
						Dclosedir(dhandle);
					frm_alert(1, rs_frstr[ALTOOMUCH], altitle, conf.wdial, 0L);
					wret = 1;
					goto wpath_update3;
				} else {
					entry = &wpath->list[wpath->e_num];
					wpath->e_num++;

					entry->link = link;

					ename = entry->name;
					strcpy(ename, fname);

					/* Zugriffsrechte/Dateityp, falls vorhanden, sichern */
					if (usemint)
						entry->mode = fmode;
					else
						entry->mode = 0;

					/* Name und Extension fuer Sortierung trennen */
					entry->fext = strrchr(ename, '.');

					/* Directory? */
					if (dta.d_attrib & FA_SUBDIR) {
						entry->class = EC_FOLDER;
						entry->size = 0L;
						entry->attr = 0;
					} else {
						/* BIOS-Device? */
						if ((fmode & S_IFMT) == S_IFCHR) {
							entry->class = EC_DEVICE;
					} else {
						/* Nein - Datei */
						entry->class = EC_FILE;
						entry->size = dta.d_length;
						entry->attr = dta.d_attrib;
						if (entry->link != 2)
							entry->aptype = is_app(ename, fmode);
						else
							entry->aptype = 0;
					}
				}
				entry->date = dta.d_date;
				entry->time = dta.d_time;
				entry->uid = uid;
				entry->gid = gid;
				entry->adate = adate;
				entry->atime = atime;
				entry->cdate = cdate;
				entry->ctime = ctime;
				entry->sel = entry->prevsel = 0;
				entry->tchar = 0;
				entry->tcolor = -1;
				entry->num = num;
				entry->obnum = num + 1;
				num++;
			}
		}

get_next:
			if (!usemint) {
				lret = (long)Fsnext();
				if (lret == 0L) {
					uid = gid = 0;
					adate = cdate = dta.d_date;
					atime = ctime = dta.d_time;
				}
			} else {
				/* Wenn moeglich, Dxreaddir() verwenden */
				if (usexr)
					lret = Dxreaddir(MAX_FLEN + 4, dhandle, dbuf, &xattr, &xret);
				else {
					/* Sonst Dreaddir()/Fxattr() */
					lret = Dreaddir(MAX_FLEN + 4, dhandle, dbuf);

					/* Attribute ermitteln - da Dopendir() nicht mit DTAs arbeitet */
					if (lret == 0L)
						xret = Fxattr(1, fname, &xattr);
				}
				dta.d_date = xattr.mdate;
				dta.d_time = xattr.mtime;
				dta.d_attrib = xattr.attr;
				dta.d_length = xattr.size;
				fmode = xattr.mode; /* Dateityp maskieren */
				if (!(wpath->filesys.flags & UNIXATTR))
					fmode &= S_IFMT;
				uid = xattr.uid;
				gid = xattr.gid;
				adate = xattr.adate;
				atime = xattr.atime;
				cdate = xattr.cdate;
				ctime = xattr.ctime;
			}

			if (lret) {
				if (lret == -64L)
					toolong = 1; /* Merken, dass ein zu langer Eintrag vorhanden ist */
				else
					fs = 1; /* Ggf. Fehlerflag setzen */
			}
		}

		if (usemint)
			Dclosedir(dhandle);

DEBUGLOG((0, "Directory read finished, lret: %ld\n", lret));
		/* Ggf. Fehler melden */
		if (lret != -33L && lret != -49L && lret != -14L) {
			err_file(rs_frstr[ALPREAD], lret, wpath->path);
			wret = 0;
		} else {
			wret = 1;
			if (toolong) {
				char folder[31];

				strShortener(folder, wpath->path, 30);
				sprintf(almsg, rs_frstr[ALTOOLONG], folder);
				frm_alert(1, almsg, altitle, conf.wdial, 0L);
			}
		}
	}

	/* Falls Mediachange aufgetreten war, dann nochmal probieren */
	if (lret == -14L) {
		retry++;
		if (retry < 2)
			goto wpath_update2;
	}

	/* Buffer auf ben”tigte Gr”že zurechtstutzen */
wpath_update3:
	if (wpath->e_num<lmax) {
		if (wpath->e_num == 0) /* Gar keine Eintr„ge? */
		{
			Mfree(wpath->list);
			wpath->list = 0L;
		}
		else
		Mshrink(0, wpath->list, (long)wpath->e_num*sizeof(WP_ENTRY));
	}

	/* Liste anlegen */
	if (wpath->e_num) {
		wpath->lptr = pmalloc((size_t)wpath->e_num * sizeof(WP_ENTRY *));
		if (wpath->lptr == NULL) {
			frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
			Mfree(wpath->list);
			wpath->list = 0L;
			wret = 0;
			goto wpath_update1;
		}
		for (i = 0; i < wpath->e_num; i++)
			wpath->lptr[i] = &wpath->list[i];
	}

wpath_update1:;
	/* Fensterinhalt aktualisieren */
	if (usemint)
		clr_drv();
	Fsetdta(odta);
	wpath_iupdate(win, 1);
	wpath_tree(win);
	win_slide(win, S_INIT, 0, 0);

	/* Cursor ausschalten, falls keine Eintr„ge mehr */
	if (!wpath->e_total && win == glob.fwin)
		wf_clear();

	graf_mouse(ARROW, 0L);
#ifdef TIMER
	timer = clock() - timer;
	fprintf(stderr, "\033H\n\nwpath_update(): %ld \n", (long)timer);
#endif
	return (wret);
}

/**-------------------------------------------------------------------------
 wpath_iupdate()

 Inhalt der Verzeichnisfenster aktualisieren, falls sich Index oder
 Maske geaendert hat.
 -------------------------------------------------------------------------*/
/* qsort fuer wpath_iupdate */

#define wpi_swap(a, b, c) \
 {\
  WP_ENTRY *tmp;\
  \
  tmp = a[b];\
  a[b] = a[c];\
  a[c] = tmp;\
 }

void wpi_qsort(WP_ENTRY **list, int left, int right, int mode) {
	int i, last;
	int v, m, f;
	int f1, f2, n1, n2, u1, u2;
	long r;
	WP_ENTRY *li, *lleft;
	char *exti, *extl;

	if (left >= right)
		return; /* Weniger als zwei Elemente - raus */

	m = mode & 0xff;

	wpi_swap(list,left,(left+right)/2);
	last = left;

	if (conf.casesort)
		strcompare = strcmp;
	else
		strcompare = stricmp;
	for (i = left + 1; i <= right; i++) {
		r = 0;
		v = mode & SORTREV;
		f = mode & SORTFOLD;

		li = list[i];
		lleft = list[left];

		f1=li->class;f2=lleft->class;
		u1 = li->used;
		u2 = lleft->used;
		n1 = li->num;
		n2 = lleft->num;

		if (f1 == EC_DEVICE)
			f1 = EC_FILE;
		if (f2 == EC_DEVICE)
			f2 = EC_FILE;

		/* Unbenutzte Eintraege nach hinten */
		if (!u1 && u2)
			r = 1;
		else if (u1 && !u2)
			r = -1;
		else {
			/* Falls Index nicht "unsortiert" dann Verzeichnisse an
			 den Anfang */
			if ((m != SORTNONE) && !f) {
				if (f1 == EC_FILE && f2 != EC_FILE)
					r = 1;
				else if (f1 != EC_FILE && f2 == EC_FILE)
					r = -1;
				if (f1 == EC_FOLDER && f2 == EC_PARENT)
					r = 1;
				else if (f1 == EC_PARENT && f2 == EC_FOLDER)
					r = -1;
			}
			/* Die obigen Sortierungen duerfen nicht umgekehrt werden! */
			if (r)
				v = 0;
			else {
				/* Je nach Index sortieren */
				switch (m) {
				case SORTNAME:
					if ((exti = li->fext) != NULL)
						*(exti++) = 0;
					else
						exti = "";
					if ((extl = lleft->fext) != NULL)
						*(extl++) = 0;
					else
						extl = "";
					r = (strcompare)(li->name, lleft->name);
					if (r == 0)
						r = (strcompare)(exti, extl);
					if (li->fext)
						exti[-1] = '.';
					if (lleft->fext)
						extl[-1] = '.';
					break;
				case SORTSIZE:
					r = li->size - lleft->size;
					break;
				case SORTDATE:
					if (li->date == lleft->date)
						r = (long) lleft->time - (long) li->time;
					else
						r = (long) lleft->date - (long) li->date;
					break;
				case SORTTYPE:
					if ((exti = li->fext) != NULL)
						*(exti++) = 0;
					else
						exti = "";
					if ((extl = lleft->fext) != NULL)
						*(extl++) = 0;
					else
						extl = "";
					r = (strcompare)(exti, extl);
					if (r == 0)
						r = (strcompare)(li->name, lleft->name);
					if (li->fext)
						exti[-1] = '.';
					if (lleft->fext)
						extl[-1] = '.';
					break;
				}
			}
			/* Ggf. Reihenfolge umkehren */
			if ((v == SORTREV) && (m != SORTNONE))
				r = -r;

			/* Falls keine Sortierung nach Index erforderlich, dann
			 die Originalreihenfolge beibehalten */
			if ((mode == SORTNONE) || (r == 0))
				r = n1 - n2;
		}

		if (r < 0) {
			last++;
			wpi_swap(list, last, i);
		}
	}

	wpi_swap(list,left,last);
	wpi_qsort(list, left, last - 1, mode);
	wpi_qsort(list, last + 1, right, mode);
}

void wpath_iupdate(WININFO *win, int dosort) {
	W_PATH *wpath;
	WP_ENTRY *entry;
	int i, n, wi, wj, wdone, showall;
	char wildcard[MAX_FLEN], iwild[MAX_FLEN];

	for (i = 0; i < MAX_PWIN; i++) {
		if (glob.win[i].state & WSINIT && (&glob.win[i] == win || !win)) {
			wpath = (W_PATH *) glob.win[i].user;
			memcpy(&wpath->font, &conf.font, sizeof(GFONT));
			/*
			 wpath->index.sortby=conf.index.sortby;
			 */
			wpath->index.show = conf.index.show;
			wpath->bpat = conf.bpat;
			showall = !strcmp(wpath->index.wildcard, "*");

			/* Verzeichniseintraege entsprechend dem Index und Wildcard
			 aufbereiten */
			for (n = 0; n < wpath->e_num; n++) {
				/* Sortierung */
#if 0
				if(dosort)
				{
					entry=&wpath->list[n];
					wpath->lptr[n]=entry;
				}
				else
#endif
				entry = wpath->lptr[n];

				if (entry->class==EC_FILE) /* Datei */
				{
					/* Auf Wildcards pruefen */
					if (!showall) {
						entry->used = 0;
						wdone = 0;
						wi = 0;
						while (!wdone) {
							wj = 0;
							while (wpath->index.wildcard[wi]
									&& wpath->index.wildcard[wi] != ',') {
								wildcard[wj] = wpath->index.wildcard[wi];
								wi++;
								wj++;
							}
							wildcard[wj] = 0;
							if (wpath->index.wildcard[wi] == ',')
								wi++;
							if (!wpath->index.wildcard[wi])
								wdone = 1;

							if (wj > 0) {
								strcpy(iwild, entry->name);
								strupr(iwild);
								strupr(wildcard);
								if (wild_match1(wildcard, iwild)) {
									entry->used = 1;
									wdone = 1;
								}
							} else
								wdone = 1;
						}
						/* Falls Eintrag nicht benutzt, dann deselektieren */
						if (!entry->used) {
							entry->sel = 0;
							entry->prevsel = 0;
						}
					} else
						entry->used = 1; /* Bei Maske '*' alles anzeigen */
				} else
					entry->used = 1; /* Ordner - wird immer angezeigt */
			}

			/* Liste sortieren */
			if (dosort && wpath->e_num > 1) {
				wpi_qsort(wpath->lptr, 0, wpath->e_num - 1, wpath->index.sortby);
				for (n = 0; n < wpath->e_num; n++) {
					entry = wpath->lptr[n];
					entry->obnum = n + 1;
				}
			}

			/* Titel- und Infozeile */
			wpath_name(&glob.win[i]);
			wpath_info(&glob.win[i]);

			/* Falls kein spezielles Fenster angegeben wurde, dann auch Objektbaum
			 erzeugen und neu zeichnen */
			if (!win) {
				wpath_tree(&glob.win[i]);
				win_slide(&glob.win[i], S_INIT, 0, 0);
				win_redraw(&glob.win[i], tb.desk.x, tb.desk.y, tb.desk.w,
						tb.desk.h);
			}
		}
	}
}

/**-------------------------------------------------------------------------
 wpath_open()

 oeffnet ein Verzeichnisfenster
 -------------------------------------------------------------------------*/
int wpath_open(char *path, char *wildcard, int rel, char *relname, int text,
		int num, int sortby) {
	WININFO *win;
	W_PATH *wpath;
	int n, wret;
	char full[MAX_PLEN];
	long dhandle, fret;

	/* Freies Fenster suchen, falls nicht explizit angegeben */
	n = 0;
	if (num >= 0 && num <= 15) {
		n = num;
		if (glob.win[n].state & WSOPEN)
			n = 0;
	}
	if (!n) {
		while (n < MAX_PWIN && glob.win[n].state & WSOPEN)
			n++;

		/* Maximale Fensterzahl erreicht ? */
		if (n == MAX_PWIN) {
			/* Ja ... */
			sprintf(almsg, rs_frstr[ALNOPWIN], MAX_PWIN);
			frm_alert(1, almsg, altitle, conf.wdial, 0L);
			return (0);
		}
	}

	/* Pfad verfuegbar ? */
	graf_mouse(BUSYBEE, 0L);
	dhandle = Dopendir(path, 0);
	if (dhandle == -32L) {
		strcpy(full, path);
		strcat(full, "*.*");
		fret = (long) Fsfirst(full, FA_SUBDIR);
	} else {
		if ((dhandle & 0xff000000L) != 0xff000000L) {
			Dclosedir(dhandle);
			fret = 0L;
		} else
			fret = dhandle;
	}

	if (fret != 0L && fret != -33L && fret != -49L) {
		graf_mouse(ARROW, 0L);
		err_file(rs_frstr[ALPREAD], fret, path);
		return (0);
	}

	/* Fenster einrichten */
	win = &glob.win[n];
	win->user = pmalloc(sizeof(W_PATH));
	/* Kein Speicher mehr frei ? */
	if (!win->user) {
		graf_mouse(ARROW, 0L);
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return (0);
	}

	win->name[0] = 0;
	win->info[0] = 0;
	win->class = WCPATH;
	win->flags = CLOSER | MOVER | FULLER | SIZER | NAME | INFO | UPARROW | DNARROW | VSLIDE;
	if (conf.hscr)
		win->flags |= LFARROW | RTARROW | HSLIDE;

	/* Zusatzelemente - je nach System */
	if (tb.sys & SY_ICONIFY)
		win->flags |= SMALLER;
	if (tb.sys & SY_MAGX)
		win->flags |= BACKDROP;
	if (!conf.nohotcloser && (tb.sys & SY_MAGX))
		win->flags |= HOTCLOSEBOX;

	win->state = WSDESKSIZE;
	win->update = pwin_update;
	win->prepare = pwin_prepare;
	win->redraw = pwin_redraw;
	win->slide = pwin_slide;
	win->ictree = rs_trindex[ICONPATH];

	/* Keine GEM-Fenster mehr verfuegbar? */
	if (!win_open(win, 0)) {
		pfree(win->user);
		graf_mouse(ARROW, 0L);
		frm_alert(1, rs_frstr[ALNOWIN], altitle, conf.wdial, 0L);
		return (0);
	}

	/* Weitere Infos eintragen... */
	wpath = (W_PATH *) win->user;
	wpath->num = n; /* Lfd. Nummer */
	if (path[3] && conf.relwin)
		wpath->rel = rel;
	else
		wpath->rel = 0; /* Relativer Modus */
	if (relname)
		strcpy(wpath->relname, relname);
	else
		wpath->relname[0] = 0;
	strcpy(wpath->path, path); /* Pfad */
	wpath->index.sortby = sortby; /* Sort. */
	wpath->index.show = conf.index.show; /* Anzeigen */
	wpath->index.text = text; /* Text/Icon */
	strcpy(wpath->index.wildcard, wildcard); /* Maske */
	{
		int i;

		for (i = 0; i < 10; i++)
			wpath->oindex[i] = wpath->index;
	}
	wpath->cindex = wpath->index;
	wpath->list = 0L;
	wpath->lptr = 0L;
	wpath->tree = 0L;
	wpath->wicon = 0L;
	wpath->offx = wpath->offy = 0;

	/* Fensterinhalt aktualisieren */
	graf_mouse(ARROW, 0L);
	wret = wpath_update(win);

	/* Mausklicks auch im Hintergrund */
	if (conf.bsel)
		wind_set(win->handle, WF_BEVENT, 1);

	/* Fenster ”ffnen */
	if (!glob.placement)
		win_open(win, 1);
	else
		win_open(win, 1 | (conf.autoplace * 0x8000 + conf.interactive * 0x4000));
	mn_check();
	return (wret);
}

/**-------------------------------------------------------------------------
 wpath_info()

 Aktualisiert Infos eines Verzeichnisfensters (Anzahl selektierter
 Objekte etc.) und gibt die Infozeile neu aus
 -------------------------------------------------------------------------*/
void wpath_info(WININFO *win) {
	W_PATH *wpath;
	WP_ENTRY *item;
	char is[128], s[128], fs[20];
	int i;

	wpath = (W_PATH *) win->user;
	wpath->e_total = 0;
	wpath->o_total = 0;
	wpath->e_files = 0;
	wpath->e_sel = 0;
	wpath->o_sel = 0;
	wpath->s_total = 0L;
	wpath->s_sel = 0L;

	for (i = 0; i < wpath->e_num; i++) {
		item = wpath->lptr[i];
		if (item->used) {
			wpath->e_total++;
			if (item->class != EC_PARENT)
				wpath->o_total++;
			if (item->class == EC_FILE) {
				wpath->e_files++;
				wpath->s_total += item->size;
			}
#if 0
			if(item->sel || item->prevsel)
#else
			if (item->sel)
#endif
			{
				wpath->e_sel++;
				if (item->class != EC_PARENT)
					wpath->o_sel++;
				if (item->class == EC_FILE)
					wpath->s_sel += item->size;
			}
		}
	}

	if (!wpath->o_total) {
		if (wpath->amask[0])
			sprintf(s, "[%s] %s", wpath->amask, rs_frstr[TXWPNONE]);
		else
			sprintf(s, " %s", rs_frstr[TXWPNONE]);
	} else {
		/* Auto-Locator */
		if (wpath->amask[0])
			sprintf(s, "[%s] ", wpath->amask);
		else
			strcpy(s, " ");

		/* Anzahl der Objekte */
		if (!wpath->o_sel) {
			prlong11(wpath->s_total, fs);
			if (wpath->o_total == 1)
				sprintf(is, rs_frstr[TXWPINFO1], fs);
			else
				sprintf(is, rs_frstr[TXWPINFO], fs, wpath->o_total);
		} else {
			prlong(wpath->s_sel, fs);
			if (wpath->o_sel == 1)
				sprintf(is, rs_frstr[TXWPINFOS1], fs);
			else
				sprintf(is, rs_frstr[TXWPINFOS], fs, wpath->o_sel);
		}

		strcat(s, is);
	}

	if (strcmp(win->info, s) != 0) {
		strcpy(win->info, s);
		wind_set(win->handle, WF_INFO, win->info);
	}
}

/**-------------------------------------------------------------------------
 wpath_efind()

 Ermittelt das Objekt, das an der angegebenen Position liegt.
 Ist x gleich -1, wird die Nummer des ersten im Fenster sichtbaren
 Objektes + 1 geliefert.
 -------------------------------------------------------------------------*/
WP_ENTRY *wpath_efind(WININFO *win, int x, int y) {
	W_PATH *wpath;
	WP_ENTRY *item;
	OBJECT *tree;
	ICONBLK *iblk;
	int i, px, py;
	int ix, iw, ih, tx, ty, tw, th;

	/* Falls ikonifiziert, dann gibt es keine Objekte */
	if (win->state & WSICON)
		return (0L);

	/* Nur innerhalb des Arbeitsbereichs des Fensters suchen */
	if ((x == -1) || (x >= win->work.x && x <= win->work.x + win->work.w - 1
			&& y >= win->work.y && y <= win->work.y + win->work.h - 1)) {
		wpath = (W_PATH *) win->user;
		tree = wpath->tree;

		if (wpath->e_total == 0)
			return (0L);

		if (wpath->index.text) {
			/* Eintraege als Text */
			for (i = 0; i < wpath->e_total; i++) {
				item = wpath->lptr[i];

				if (conf.vert) {
					tx = i / wpath->imy;
					px = tx * wpath->tlen + win->work.x + 10 - wpath->offx;
					py = (i - tx * wpath->imy) * (wpath->clh + 1) + win->work.y + 2 - wpath->offy;
				} else {
					ty = i / wpath->imx;
					px = (i - ty * wpath->imx) * wpath->tlen + win->work.x + 10 - wpath->offx;
					py = ty * (wpath->clh + 1) + win->work.y + 2 - wpath->offy;
				}

				if (x == -1) {
					if (py >= win->work.y)
						return ((WP_ENTRY *) (i + 1));
					continue;
				}

				iw = wpath->tlen - wpath->clw * 2;
				ih = wpath->clh;

				if (x >= px && x <= px + iw - 1 && y >= py && y <= py + ih - 1)
					return item;
			}
			return (0L);
		} else {
			/* Eintraege als Icons */
			if (!tree)
				return (0L);

			for (i = 1; i <= wpath->e_total; i++) {
				item = wpath->lptr[i - 1];

				px = tree->ob_x + tree[i].ob_x;
				py = tree->ob_y + tree[i].ob_y;
				if (x == -1) {
					if (py >= win->work.y)
						return ((WP_ENTRY *) i);
					continue;
				}
				iblk = &wpath->wicon[i - 1].ciconblk.monoblk;
				ix = iblk->ib_xicon;
				iw = iblk->ib_wicon;
				ih = iblk->ib_hicon;
				tx = iblk->ib_xtext;
				ty = iblk->ib_ytext;
				tw = iblk->ib_wtext;
				th = iblk->ib_htext;

				/* Innerhalb des Textes ? */
				if (x >= px + tx && x <= px + tx + tw - 1 && y >= py + ty && y <= py + ty + th - 1)
					return (item);

				/* Innerhalb des Images ? */
				if (x >= px + ix && x <= px + ix + iw - 1 && y >= py && y <= py + ih)
					return (item);
			}
			return (0L);
		}
	} else
		return (0L);
}

/**-------------------------------------------------------------------------
 wpath_esel()

 Selektiert eines oder mehrere Eintraege in einem Verzeichnisfenster
 -------------------------------------------------------------------------*/
void wpath_esel1(WININFO *win, WP_ENTRY *entry, int sel, RECT *wrect, int *rd) {
	int x, y, w, h, n, osel, xg, yg;
	W_PATH *wpath;
	OBJECT *tree;
	ICONBLK *iconblk;

	wpath = (W_PATH *) win->user;
	tree = wpath->tree;
	osel = entry->sel; /* Bisherigen Status sichern */
	if (!entry->prevsel)
		entry->sel = sel; /* Status aendern, wenn moeglich */

	/* Eintrag neuzeichnen, wenn der Status geaendert wurde und
	 der Eintrag nicht auch durch 'prevsel' selektiert ist */
	if (osel != entry->sel && !entry->prevsel) {
		n = entry->obnum;

		if (wpath->index.text) {
			/* Darstellung als Text */
			if (conf.vert) {
				xg = (n - 1) / wpath->imy;
				x = xg * wpath->tlen + win->work.x + 10 - wpath->offx;
				y = (n - 1 - xg * wpath->imy) * (wpath->clh + 1) + win->work.y + 2 - wpath->offy;
			} else {
				yg = (n - 1) / wpath->imx;
				x = (n - 1 - yg * wpath->imx) * wpath->tlen + win->work.x + 10 - wpath->offx;
				y = yg * (wpath->clh + 1) + win->work.y + 2 - wpath->offy;
			}

			w = wpath->tlen - wpath->clw * 2;
			h = wpath->clh;
		} else {
			/* Darstellung als Icons */
			if (entry->sel)
				tree[n].ob_state |= SELECTED;
			else
				tree[n].ob_state &= ~SELECTED;
			x = tree->ob_x + tree[n].ob_x;
			y = tree->ob_y + tree[n].ob_y;
			w = tree[n].ob_width;
			h = tree[n].ob_height;
			iconblk = &wpath->wicon[n - 1].ciconblk.monoblk;
			if (iconblk->ib_xtext < iconblk->ib_xicon) {
				x += iconblk->ib_xtext;
				w = iconblk->ib_wtext;
			}
		}

		/* Koordinaten fuer Redraw anpassen */
		if (*rd == 0) {
			*rd = 1;
			wrect->x = x;
			wrect->y = y;
			wrect->w = w;
			wrect->h = h;
		} else {
			if (x < wrect->x) {
				wrect->w += (wrect->x - x);
				wrect->x = x;
			}
			if (x + w > wrect->x + wrect->w)
				wrect->w = x + w - wrect->x;

			if (y < wrect->y) {
				wrect->h += (wrect->y - y);
				wrect->y = y;
			}
			if (y + h > wrect->y + wrect->h)
				wrect->h = y + h - wrect->y;
		}
	}
}

/**
 *
 */
void wpath_esel(WININFO *win, WP_ENTRY *entry, int add, int sel, int doinfo) {
	W_PATH *wpath;
	WP_ENTRY *item;
	RECT wrect;
	int rd, i;

	if (!win)
		return;
	wpath = (W_PATH *) win->user;
	rd = 0;

	/* Alle Eintraege bearbeiten */
	if (!entry) {
		for (i = 0; i < wpath->e_total; i++) {
			item = wpath->lptr[i];
			if (item->class==EC_PARENT)
				wpath_esel1(win, item, 0, &wrect, &rd);
			else
				wpath_esel1(win, item, sel, &wrect, &rd);
		}
		if (rd)
			win_redraw(win, wrect.x, wrect.y, wrect.w, wrect.h);
		if (doinfo)
			wpath_info(win);
	} else {
		/* Einzelnen Eintrag bearbeiten */

		/* Vorher alle Eintraege deselektieren */
		if (!add) {
			for (i = 0; i < wpath->e_total; i++) {
				item = wpath->lptr[i];
				if (item != entry)
					wpath_esel1(win, item, 0, &wrect, &rd);
			}
			if (rd)
				win_redraw(win, wrect.x, wrect.y, wrect.w, wrect.h);
			rd = 0;

		}
		/* Status aendern */
		wpath_esel1(win, entry, sel, &wrect, &rd);
		if (rd)
			win_redraw(win, wrect.x, wrect.y, wrect.w, wrect.h);
		if (doinfo)
			wpath_info(win);
	}
}

/**-------------------------------------------------------------------------
 wpath_exsel()

 Auswahl mit "Gummiband" in einem Verzeichnisfenster
 -------------------------------------------------------------------------*/
int wpath_einrect(W_PATH *wpath, int wx, int wy, WP_ENTRY *ob, RECT *rect) {
	OBJECT *tree;
	ICONBLK *iblk;
	RECT irect;
	int px, py, xg, yg, is_in, n;

	if (!wpath->e_total || ob->class==EC_PARENT)
		return 0;

	n = ob->obnum;

	if (wpath->index.text) {
		/* Darstellung als Text */
		if (conf.vert) {
			xg = (n - 1) / wpath->imy;
			irect.x = xg * wpath->tlen + wx + 10 - wpath->offx;
			irect.y = (n - 1 - xg * wpath->imy) * (wpath->clh + 1) + wy + 2
					- wpath->offy;
		} else {
			yg = (n - 1) / wpath->imx;
			irect.x = (n - 1 - yg * wpath->imx) * wpath->tlen + wx + 10
					- wpath->offx;
			irect.y = yg * (wpath->clh + 1) + wy + 2 - wpath->offy;
		}

		irect.w = wpath->tlen - wpath->clw * 2;
		irect.h = wpath->clh;
		is_in = rc_intersect(rect, &irect);
	} else {
		/* Darstellung als Icons */
		tree = wpath->tree;
		if (!tree)
			return 0;

		px = tree->ob_x + tree[n].ob_x;
		py = tree->ob_y + tree[n].ob_y;
		is_in = 0;
		iblk = &wpath->wicon[n - 1].ciconblk.monoblk;

		/* Text-Bereich */
		irect.x = px + iblk->ib_xtext;
		irect.y = py + iblk->ib_ytext;
		irect.w = iblk->ib_wtext;
		irect.h = iblk->ib_htext;
		if (rc_intersect(rect, &irect))
			is_in = 1;

		/* Image-Bereich */
		irect.x = px + iblk->ib_xicon;
		irect.y = py;
		irect.w = iblk->ib_wicon;
		irect.h = iblk->ib_hicon;
		if (rc_intersect(rect, &irect))
			is_in = 1;
	}

	return (is_in);
}

/**
 *
 */
void wpath_exsel(WININFO *win, int mx, int my, int mk, int ks) {
	W_PATH *wpath;
	WP_ENTRY *item;
	OBJECT *tree;
	int lmx, lmy, lmk, lks;
	int i, rd, dx, dy;
	RECT sel, sel2, rsel, wrect, crect;
	int rxy[4], cxy[4], dn;
	int offx, offy, maxx, maxy;

	wpath = (W_PATH *) win->user;
	tree = wpath->tree;

	/* Falls Parentverzeichnis vorhanden, dann deslektieren */
	if (wpath->list) {
		if (wpath->list->used && wpath->list->class==EC_PARENT) {
			wind_update( END_UPDATE);
			wpath_esel(win, wpath->list, 1, 0, 1);
			wind_update( BEG_UPDATE);
		}
	}

	lmx = mx;
	lmy = my;
	lmk = mk;
	lks = ks;

	/* Clipping-Rechteck fuer Gummiband */
#if 0
	crect.x=win->work.x;crect.y=win->work.y;
	crect.w=win->work.w;crect.h=win->work.h;
#else
	crect = win->work;
#endif
	rc_intersect(&tb.desk, &crect);
	cxy[0] = crect.x;
	cxy[1] = crect.y;
	cxy[2] = cxy[0] + crect.w - 1;
	cxy[3] = cxy[1] + crect.h - 1;

	/* Maximale Offsets berechnen */
	if (wpath->e_total == 0 || (!wpath->index.text && !tree)) {
		maxx = 0;
		maxy = 0;
	} else {
		if (wpath->index.text) {
			maxx = wpath->tlen * wpath->imx + 20 - wpath->clw * 2 - win->work.w;
			maxy = wpath->imy * (wpath->clh + 1) + 3 - win->work.h;
		} else {
			maxx = tree->ob_width - win->work.w;
			maxy = tree->ob_height - win->work.h;
		}
	}

	/* Bisherigen Status der Objekte sichern */
	for (i = 0; i < wpath->e_total; i++) {
		item = wpath->lptr[i];
		item->prevsel = item->sel;
	}

	/* Startrechteck merken */
	sel.x = sel2.x = lmx;
	sel.y = sel2.y = lmy;
	sel.w = sel.h = 0;

	/* Auf gehts ... */
	graf_mouse(POINT_HAND, 0L);
	vs_clip(tb.vdi_handle, 1, cxy);
	rub_frame(&sel);
	while (lmk & 3) {
		/* Neue Mausposition holen */
		graf_mkstate(&lmx, &lmy, &lmk, &lks);

		/* Neues Auswahlrechteck berechnen */
		sel2.w = lmx - sel.x + 1;
		sel2.h = lmy - sel.y + 1;

		/* Begrenzung auf Fenster */
		if (sel2.y + sel2.h - 1 < crect.y)
			sel2.h = crect.y - sel2.y + 1;
		if (sel2.y + sel2.h > crect.y + crect.h)
			sel2.h = crect.y + crect.h - sel2.y;
		if (sel2.x + sel2.w - 1 < crect.x)
			sel2.w = crect.x - sel2.x + 1;
		if (sel2.x + sel2.w > crect.x + crect.w)
			sel2.w = crect.x + crect.w - sel2.x;

		/* Bei Aenderung oder Scroll Auswahlrechteck neu zeichnen */
		dn = 0;
		/* ... Aenderung des Auswahlrechtecks */
		if (sel.w != sel2.w || sel.h != sel2.h)
			dn = 1;
		/* ... Scroll */
		offx = wpath->offx;
		offy = wpath->offy;
		dx = dy = 0;
		if (lmx < crect.x && offx > 0)
			dx = crect.x - lmx;
		if (lmy < crect.y && offy > 0)
			dy = crect.y - lmy;
		if (lmx > crect.x + crect.w - 1 && offx < maxx)
			dx = (crect.x + crect.w - 1) - lmx;
		if (lmy > crect.y + crect.h - 1 && offy < maxy)
			dy = (crect.y + crect.h - 1) - lmy;
		dx *= conf.scroll;
		dy *= conf.scroll;
		if (dx != 0 || dy != 0)
			dn = 1;

		if (dn) {
			/* Loeschen und neue Masse verwenden */
			vs_clip(tb.vdi_handle, 1, cxy);
			rub_frame(&sel);
			sel.w = sel2.w;
			sel.h = sel2.h;

			/* Fenster scrollen, wenn noetig */
			if (dx != 0 || dy != 0) {
				win_slide(win, S_PABS, dx, dy);
				dx = offx - wpath->offx;
				dy = offy - wpath->offy;
				sel.x += dx;
				sel.w -= dx;
				sel.y += dy;
				sel.h -= dy;
#if 0
				sel2.x=sel.x;sel2.y=sel.y;
				sel2.w=sel.w;sel2.h=sel.h;
#else
				sel2 = sel;
#endif
			}
			vs_clip(tb.vdi_handle, 1, cxy);
			rub_frame(&sel);

			/* Icons im Auswahlbereich selektieren */
			rxy[0] = sel.x;
			rxy[1] = sel.y;
			rxy[2] = sel.x + sel.w - 1;
			rxy[3] = sel.y + sel.h - 1;
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
			rsel.x = rxy[0];
			rsel.y = rxy[1];
			rsel.w = rxy[2] - rxy[0] + 1;
			rsel.h = rxy[3] - rxy[1] + 1;

			rd = 0;
			for (i = 0; i < wpath->e_total; i++) {
				int psel;

				item = wpath->lptr[i];
				if (wpath_einrect(wpath, win->work.x, win->work.y, item, &rsel)) {
					if (!item->sel && !item->prevsel)
						wpath_esel1(win, item, 1, &wrect, &rd);
					else if (item->sel && item->prevsel) {
						item->prevsel = 0;
						wpath_esel1(win, item, 0, &wrect, &rd);
						item->prevsel = 1;
					}
				} else {
					psel = item->prevsel;
					item->prevsel = 0;
					wpath_esel1(win, item, psel, &wrect, &rd);
					item->prevsel = psel;
				}
			}

			if (rd) {
				vs_clip(tb.vdi_handle, 1, cxy);
				rub_frame(&sel);
				win_redraw(win, wrect.x, wrect.y, wrect.w, wrect.h);
				wpath_info(win);
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
	for (i = 0; i < wpath->e_total; i++) {
		item = wpath->lptr[i];
		item->prevsel = 0;
	}
}

/**
 * wpath_iconupdate
 *
 * Aktualisiert bzw. ermittelt die Icons fuer bestimmte (oder alle)
 * Verzeichniseintraege. Ersetzt die alte Funktion wpath_eupdate().
 *
 * Eingabe:
 * wpath: Zeiger auf die Verzeichnisfensterdaten
 * first: Nummer des ersten Eintrags, dessen Icon aktualisiert werden
 *        soll. uebergibt man -1, werden alle Eintraege im Verzeichnis
 *        bearbeitet.
 * last: Nummer des letzten Eintrags
 */
static void wpath_iconupdate(W_PATH *wpath, int first, int last) {
	int i, ec, ic, inum;
	WP_ENTRY *item;
	ICONIMG *icon, *ticon;
	char wename[MAX_FLEN], *s, *d;

	if (first == -1) {
		first = 0;
		last = wpath->e_num - 1;
	}
	item = wpath->list;
	for (i = first; i <= last; i++) {
		for (s = item->name, d = wename; *s;)
			*(d++) = nkc_toupper(*(s++));
		*d = 0;

		ec = item->class;
		ticon = 0L;
		inum = 0;
		icon = desk.icon;
		while (inum < desk.maxicon) {
			ic = icon->class;
			if (((ic == 0) && ((ec == EC_FILE) || (ec == EC_DEVICE))) || ((ic
					== 1) && ((ec == EC_PARENT) || (ec == EC_FOLDER)))) {
				if (wild_match1(icon->mask, wename)) {
					ticon = icon;
					break;
				}
			}
			icon++;
			inum++;
		}

		if (!ticon) {
			switch (ec) {
			case EC_DEVICE:
				ticon = &desk.ic_dev;
				break;
			case EC_FILE:
				if (item->aptype)
					ticon = &desk.ic_appl;
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
			switch (ec) {
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
		item++;
	}
}

/**-------------------------------------------------------------------------
 wpath_edrag()

 Drag&Drop von Objekten in Verzeichnisfenstern
 -------------------------------------------------------------------------*/
void wpath_edrag(int mx, int my, int mk, int ks) {
	int lmx, lmy, lmk, lks;
	int *pxy, *obnum;
	int i, j, n, pn, px, py;
	int p, x, y, w, h, ix, iw, tx, ty, tw;
	int tx1, ty1, tx2, ty2;
	int otx, oty;
	int obj, obj1, whandle, drag, drag1;
	int moved = 0;
	WININFO *win, *iwin, *iwin1;
	ACWIN *accwin;
	WP_ENTRY *item, *item1;
	WG_ENTRY *gitem, *gitem1, *gprev;
	int xg, yg, wx, wy;
	W_PATH *wpath;
	WP_ENTRY *litem;
	RECT irect, wrect;
	int wrd, first;
	ICONBLK *iblk;
	APPLINFO *aptr;
	EVENT Event = { MU_BUTTON | MU_TIMER | MU_M1, 1, 3, 0, 1, 0, 0, 1, 1, 0, 0,
			0, 0, 0, 1500, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
	int popfold = -1;
	W_PATH *wpath2;
#ifdef TB_EXTENSIONS
	WININFO *new_one = 0L;
	int wret,loop = 0;
	char temp[MAX_PLEN + MAX_FLEN + 2];
#endif

	lmx = mx;
	lmy = my;
	lmk = mk;
	lks = ks;
	wpath = (W_PATH *) desk.sel.win->user;
	wx = desk.sel.win->work.x;
	wy = desk.sel.win->work.y;

	/* Falls Parentverzeichnis selektiert ist, dann erst deselektieren */
	if (wpath->list->class == EC_PARENT) {
		wind_update( END_UPDATE);
		wpath_esel(desk.sel.win, wpath->list, 1, 0, 1);
		wind_update( BEG_UPDATE);
	}

	/* Aktuelle Auswahl sichern und Anzahl selektierter Objekte
	 ermitteln */
	n = 0;
	for (i = 0; i < wpath->e_total; i++) {
		litem = wpath->lptr[i];
		litem->prevsel = litem->sel;
		if (litem->sel)
			n++;
	}

	/* Polygone fuer die Darstellung am Bildschirm aufbauen */
	if (wpath->index.text)
		pxy = pmalloc(sizeof(int) * n * 10); /* Text: Je Eintrag 5 xy-Punkte */
	else
		pxy = pmalloc(sizeof(int) * n * 18); /* Icons: Je Icon 9 xy-Punkte */
	if (!pxy) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return;
	}
	obnum = pmalloc(sizeof(int) * n); /* Objektnummern */
	if (!obnum) {
		pfree(pxy);
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return;
	}

	tx1 = tb.desk.x + tb.desk.w; /* t... Position/Masse des Gesamtrechtecks */
	ty1 = tb.desk.y + tb.desk.h;
	tx2 = ty2 = 0;

	i = 0;
	p = 0;
	for (j = 0; j < wpath->e_total; j++) {
		litem = wpath->lptr[j];
		if (litem->sel) {
			obnum[p] = litem->obnum;
			/* Im Textmodus */
			if (wpath->index.text) {
				/* Koordinaten/Masse holen */
				if (conf.vert) {
					xg = i / wpath->imy;
					x = xg * wpath->tlen + wx + 10 - wpath->offx;
					y = (i - xg * wpath->imy) * (wpath->clh + 1) + wy + 2
							- wpath->offy;
				} else {
					yg = i / wpath->imx;
					x = (i - yg * wpath->imx) * wpath->tlen + wx + 10
							- wpath->offx;
					y = yg * (wpath->clh + 1) + wy + 2 - wpath->offy;
				}

				w = wpath->tlen - wpath->clw * 2;
				if (w > tb.desk.w)
					w = tb.desk.w;
				h = wpath->clh;
				if (h > tb.desk.h)
					h = tb.desk.h;
				irect.x = x;
				irect.y = y;
				irect.w = w;
				irect.h = h;
				/* Nur verwenden, wenn Icon sichtbar */
				if (rc_intersect(&tb.desk, &irect) && rc_intersect(
						&desk.sel.win->work, &irect)) {
					/* Polygonzug berechnen */
#if 1
					wc_text(&pxy[p * 10], &x, &y, &w, &h);
#else
					/* Auf Desktop begrenzen */
					if(x<tb.desk.x) x=tb.desk.x;
					if(y<tb.desk.y) y=tb.desk.y;
					if(x+w>tb.desk.x+tb.desk.w) x=tb.desk.x+tb.desk.w-w;
					if(y+h>tb.desk.y+tb.desk.h) y=tb.desk.y+tb.desk.h-h;
					/* Polygonzug berechnen */
					pxy[p*10]=x; pxy[p*10+1]=y;
					pxy[p*10+2]=x+w-1;pxy[p*10+3]=y;
					pxy[p*10+4]=x+w-1;pxy[p*10+5]=y+h-1;
					pxy[p*10+6]=x; pxy[p*10+7]=y+h-1;
					pxy[p*10+8]=x; pxy[p*10+9]=y;
#endif
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

				/* Koordinaten/Masse holen */
				objc_offset(wpath->tree, i + 1, &x, &y);
				w = wpath->tree[i + 1].ob_width;
				h = wpath->tree[i + 1].ob_height;
				iblk = &wpath->wicon[i].ciconblk.monoblk;
				ix = iblk->ib_xicon;
				iw = iblk->ib_wicon;
				tx = iblk->ib_xtext;
				ty = iblk->ib_ytext;
				tw = iblk->ib_wtext;
				irect.x = x;
				irect.y = y;
				irect.w = w;
				irect.h = h;

				/* Nur verwenden, wenn Icon sichtbar */
				if (rc_intersect(&tb.desk, &irect) && rc_intersect(
						&desk.sel.win->work, &irect)) {
#if 0
					/* Anpassung an Beschriftung */
					if(tw<iw) /* Text kleiner als Icon */
					{	x+=ix;w=iw;tx-=ix;ix=0;}
					else /* Text gr”žer oder gleich grož wie Icon */
					{	x+=tx;w=tw;ix-=tx;tx=0;}
					/* Begrenzung auf Desktop */
					if(x<tb.desk.x) x=tb.desk.x;
					if(y<tb.desk.y) y=tb.desk.y;
					if(x+w>tb.desk.x+tb.desk.w) x=tb.desk.x+tb.desk.w-w;
					if(y+h>tb.desk.y+tb.desk.h) y=tb.desk.y+tb.desk.h-h;
#endif
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
		i++;
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
	wind_update( BEG_MCTRL);
	graf_mouse(FLAT_HAND, 0L);
	if (wpath->index.text)
		rub_ticon(n, pxy);
	else
		rub_icon(n, pxy);
	while (lmk & 3) {
#ifdef TB_EXTENSIONS
		if(x!=lmx || y!=lmy || loop) /* Mausposition veraendert ? */
#else
		if (1) /*(x!=lmx || y!=lmy)*//* Mausposition veraendert ? */
#endif
		{
			evnt_timer(10, 0);
			first = 0;
			/* xy-Delta berechnen */
			w = lmx - x;
			h = lmy - y;
			/* Verschiebung des Gesamtrechtecks auf Desktopbereich begrenzen */
			if (tx1 + w < tb.desk.x)
				w = tb.desk.x - tx1;
			if (ty1 + h < tb.desk.y)
				h = tb.desk.y - ty1;
			if (tx2 + w > tb.desk.x + tb.desk.w)
				w = (tb.desk.x + tb.desk.w) - tx2;
			if (ty2 + h > tb.desk.y + tb.desk.h)
				h = (tb.desk.y + tb.desk.h) - ty2;
			/* Nur aktualisieren, wenn xy-Delta != 0 */
#ifdef TB_EXTENSIONS
			if(w!=0 || h!=0 || loop)
#else
			if (w != 0 || h != 0)
#endif
			{
				/* Loeschen */
				if (wpath->index.text)
					rub_ticon(n, pxy);
				else
					rub_icon(n, pxy);
				/* Anhand von xy-Delta verschieben */
				tx1 += w;
				ty1 += h;
				tx2 += w;
				ty2 += h;
				if (wpath->index.text)
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
				if (wpath->index.text)
					rub_ticon(n, pxy);
				else
					rub_icon(n, pxy);
			}

			/* Maus ueber einem Fenster? */
			whandle = wind_find(lmx, lmy);
			if (whandle) /* Ja */
			{
				drag = 1;
				/* Bisher selektiertes Desktop-Objekt deselektieren */
				if (obj != -1) {
					if (wpath->index.text)
						rub_ticon(n, pxy);
					else
						rub_icon(n, pxy);
					icon_select(obj1, 1, 0);
					if (wpath->index.text)
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
						if (drag_scroll(lmy, w, h, moved, iwin, n, pxy, wpath->index.text ? rub_ticon : rub_icon)) {
							item = 0L;
							break;
						}
						item = wpath_efind(win, lmx, lmy); /* Objekt ermitteln */
						if (item) {
							if(!item->prevsel) /* Nur wenn Objekt nicht zur Gruppe geh”rt */
							{
								if(desk.sel.devices || desk.sel.printer) drag=0;
								switch(item->class)
								{
									case EC_FOLDER: /* Ordner... */
									case EC_PARENT: /* ... oder bergeordnetes Verzeichnis */
									if (desk.sel.trash || desk.sel.clip)
									{
										drag = 0;
										break;
									}
									if (!item->sel)
									break;
									evnt_timer(10, 0);
									Event.ev_mm1x = lmx;
									Event.ev_mm1y = lmy;
									Event.ev_mtlocount = 1500;
									Event.ev_mthicount = 0;
									EvntMulti(&Event);
									if (Event.ev_mwich == MU_TIMER) {
										if ((popfold = appl_find("POPFOLD ")) >= 0) {
											static char dest[MAX_PLEN + MAX_FLEN + 2];
											char aname[MAX_FLEN], apath[MAX_PLEN];

											item->sel = 0;
											sel2buf(aesbuf, aname, apath, MAX_AVLEN);
											item->sel = 1;
											wpath2 = (W_PATH *)iwin->user;
											strcpy(dest, wpath2->path);
											strcat(dest, item->name);
											strcat(dest, "\\");
											appl_send(popfold, AV_COPYFILE, PT34|PT56, (long)aesbuf, 0,(long) dest, 0, 0);
											drag = first = 1;
											goto drag_exit;
										}
									}
									break;
#ifdef TB_EXTENSIONS
									case EC_FOLDER: /* Ordner... */
									case EC_PARENT: /* ... oder bergeordnetes Verzeichnis */
									if (desk.sel.trash || desk.sel.clip) {
										drag = 0;
										break;
									}
									evnt_timer(10, 0);
									Event.ev_mm1x = lmx;
									Event.ev_mm1y = lmy;
									Event.ev_mtlocount = 1500;
									Event.ev_mthicount = 0;
									EvntMulti(&Event);
									if (Event.ev_mwich == MU_TIMER) {
										if(wpath->index.text)
											rub_ticon(n,pxy); else rub_icon(n,pxy);
										if(item1!=0L)
											wpath_esel(iwin1,item1,1,0,0);
										if(gitem1!=0L)
											wgrp_esel(iwin1,gitem1,1,0);
										if (item->class == EC_FOLDER) {
											wpath2 = (W_PATH *)win->user;
											if ((strlen(wpath2->path) + strlen(item->name) > MAX_PLEN))
											mybeep();
											else {
												strcpy(temp, wpath2->path);
												strcat(temp, item->name);
												strcat(temp, "\\");
												if (new_one == 0L) {
													wret = wpath_open(temp, wpath2->index.wildcard, 1, 0L, wpath2->index.text, -1, wpath2->index.sortby);
													if (wret)
													new_one = tb.topwin;
												} else {
													wpath2 = (W_PATH *)new_one->user;
													strcpy(wpath2->path, temp);
													if (wpath2->rel)
													wpath2->rel++;
													wpath2->offx = wpath2->offy = 0;
													wret = wpath_update(new_one);
													w_draw(win);
												}
												if (!wret)
												drag = 0;
											}
										} else {
											if (new_one == 0L) {
												wret = wpath_parent(win, 1, 0);
												if (wret)
												new_one = tb.topwin;
											} else
												wret = wpath_parent(new_one, 0, 0);
											if (!wret)
												drag = 0;
										}
										if (wret) {
											wpath_esel(new_one, 0L, 0, 0, 1);
											msg_clr();
											evnt_timer(10, 0);
											msg_clr();
										}
										if(item1!=0L)
											wpath_esel(iwin,item1,1,1,0);
										if(gitem1!=0L)
											wgrp_esel(iwin,gitem1,1,1);
										if(wpath->index.text)
											rub_ticon(n,pxy);
										else
											rub_icon(n,pxy);
										if (wret) {
											item = 0L;
											loop = 1;
										}
									}
									else
									evnt_timer(10, 0);
									break;
#endif
									case EC_FILE: /* Datei */
									/* .... aber kein Programm */
									if(!item->aptype) {
										/* Evtl. indirekt angemeldet */
										if(!app_isdrag(item->name))
											item=0L; /* Nein */
									}
									break;
									case EC_DEVICE: /* Auf Device nur einzelne Datei */
									if (desk.sel.files>1 || desk.sel.drives || desk.sel.folders || desk.sel.clip || desk.sel.trash)
										drag=0; /* item=0L; */
									break;
								}
							}
						} else if (desk.sel.devices || desk.sel.printer)
							drag = 0;
						if (!drag)
							item = 0L;
						break;
						case WCGROUP:
						item = 0L;
						iwin = win; /* Fenster merken */
						if (drag_scroll(lmy, w, h, moved, iwin, n, pxy,
								wpath->index.text ? rub_ticon : rub_icon))
						{
							gitem = 0L;
							break;
						}
						gitem = wgrp_efind(win, lmx, lmy, &gprev); /* Objekt ermitteln */
						if (gitem) {
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
							if (!drag)
								gitem = 0L;
						}
						/* Gruppenhintergrund */
						if (!gitem) {
							/* Nur Dateien/Ordner zulassen */
							if (desk.sel.devices)
								drag = 0;
						}
						break;
						case WCDIAL:
						item = 0L;
						gitem = 0L;
						if (desk.sel.numobs>1 || desk.sel.trash || desk.sel.printer || desk.sel.clip)
							drag = 0;
						break;
					}
				}
				else /* Fenster nicht bekannt - eventuell Acc-Fenster ? */
				{
					item = 0L;
					gitem = 0L;
					accwin = acwin_find(whandle);
					/* Es koennen nur Dateien, Ordner oder Laufwerke in ein
					 Accessory-Fenster gelegt werden */
					if (desk.sel.trash || desk.sel.clip || desk.sel.printer || desk.sel.devices)
						drag = 0;
					else
						drag = 1;
				}
				/* Bisher selektiertes Zielobjekt deselektieren und ggf.
				 neues Zielobjekt selektieren */
				if (item != item1) {
					if (wpath->index.text)
						rub_ticon(n, pxy);
					else
						rub_icon(n, pxy);
					if (item1 != 0L)
						wpath_esel(iwin1, item1, 1, 0, 0);
					if (item != 0L)
						wpath_esel(iwin, item, 1, 1, 0);
					if (wpath->index.text)
						rub_ticon(n, pxy);
					else
						rub_icon(n, pxy);
				}
				if (gitem != gitem1) {
					if (wpath->index.text)
						rub_ticon(n, pxy);
					else
						rub_icon(n, pxy);
					if (gitem1 != 0L)
						wgrp_esel(iwin1, gitem1, 1, 0);
					if (gitem != 0L)
						wgrp_esel(iwin, gitem, 1, 1);
					if (wpath->index.text)
						rub_ticon(n, pxy);
					else
						rub_icon(n, pxy);
				}
			}
			else /* Maus nicht ueber einem Fenster */
			{
				/* Bisheriges Fenster-Objekt deselektieren */
				if (item || gitem) {
					if (wpath->index.text)
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
					if (wpath->index.text)
						rub_ticon(n, pxy);
					else
						rub_icon(n, pxy);
				}
				win = 0L;
				accwin = 0L;
				obj = icon_find(lmx, lmy);
				if (obj!=-1) {
					drag = 1;
					/* Pruefen, ob das Objekt als Zielobjekt verwendet werden kann,
					 und ggf. auf NIL (-1) setzen, wenn dies nicht moeglich ist */
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
							if (desk.sel.numobs > 1 || desk.sel.folders ||
									desk.sel.drives || desk.sel.trash || desk.sel.printer || desk.sel.devices)
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
							if (desk.sel.files > 1 || desk.sel.drives || desk.sel.folders || desk.sel.clip || desk.sel.trash || desk.sel.devices)
								obj = -1;
							break;
						}
						if (obj==-1)
							drag = 0;
					}
				} else {
					if (lmx < tb.desk.x || lmy < tb.desk.y)
						drag = 0;
					else
						drag = 1;
				}
				/* Bisher selektiertes Zielobjekt deselektieren und ggf.
				 neues Zielobjekt selektieren */
				if (obj != obj1) {
					if (wpath->index.text)
						rub_ticon(n, pxy);
					else
						rub_icon(n, pxy);
					if (obj1 != -1)
						icon_select(obj1, 1, 0);
					if (obj != -1) 
						icon_select(obj, 1, 1);
					if (wpath->index.text)
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
#ifdef TB_EXTENSIONS
		loop = 0;
#endif
		graf_mkstate(&lmx, &lmy, &lmk, &lks);
		moved = h || moved;
	}
	drag_exit:
	if (wpath->index.text)
		rub_ticon(n, pxy);
	else
		rub_icon(n, pxy);
	graf_mouse(ARROW, 0L);
	wind_update(END_MCTRL);

	if (popfold >= 0) {
		wind_update(END_UPDATE);
		evnt_timer(250, 0);
		wind_update(BEG_UPDATE);
	}

	if (obj != -1)
		icon_select(obj, 1, 0); /* Zielobjekte deselektieren */
	if (item)
		wpath_esel(iwin,item,1,0,0);
	if (gitem)
		wgrp_esel(iwin,gitem,1,0);

	/* Gesicherte Auswahl wiederherstellen */
	for (i = 0; i < wpath->e_total; i++) {
		litem = wpath->lptr[i];
		litem->sel = litem->prevsel;
		litem->prevsel = 0;
	}

	if (obj != -1) /* Zielobjekt auf dem Desktop ? */
	{
		dl_ddrag(&desk.dicon[obj], lks);
	}
	else /* Kein Zielobjekt auf dem Desktop */
	{
		if (whandle) /* Fenster ? */
		{
			if (win) /* Eigenes Fenster ? */
			{
				if (drag)
				{
					if (!first) {
						if (!item || gitem)
							dl_wdrag(win, item, gitem, gprev, lmx, lmy, lks);
						else
							if (!item->sel)
								dl_wdrag(win, item, gitem, gprev, lmx, lmy, lks);
					}
				}
				else mybeep();
			}
			else /* Accessory ? */
			{
				if (drag)
					dl_awdrag(accwin, whandle, lmx, lmy, lks);
				else
					mybeep();
			}
		}
		else /* kein Zielfenster - dann Icons auf den Desktop legen */
		{
			int jumps = 0;

			if (drag) /* Ablegen m”glich ? */
			{
				/* Ja ... */
				i = OBUSER;
				p = 0;
				wrd = 0;

				/* Fuer Textdarstellung, Position fuer Plazierung merken */
				otx=lmx-tb.desk.x-40;
				if(otx<0)
					otx=0;
				oty=lmy-tb.desk.y-20;
				if(oty<0)
					oty=0;
				px=otx;
				py=oty;
				pn=0;

				/* Position/Maže des Gesamtrechtecks fr Desktop-Redraw */
				tx1=tb.desk.x+tb.desk.w;
				ty1=tb.desk.y+tb.desk.h;
				tx2=ty2=0;

				/* Freies Desktop-Icon suchen */
				while(desk.dicon[i].class!=IDFREE && i<=MAXICON) i++;

				j=0;
				while(j<wpath->e_total && p<n) {
					litem=wpath->lptr[j];
					while(litem->used && litem->obnum!=obnum[p]) {
						if(litem->sel) {
							wpath->amask[0]=0;
							wpath_esel1(desk.sel.win,litem,0,&wrect,&wrd);
						}
						j++;litem=wpath->lptr[j];
					}
					if(litem->sel) {
						if(i>MAXICON) /* Kein Icon mehr frei ? */
						{
							frm_alert(1,rs_frstr[ALDESKFULL],altitle,conf.wdial,0L);
							j=wpath->e_total;
						} else {
							strcpy(desk.dicon[i].title,litem->name);
							/* Spezifische Daten bertragen */
							switch(litem->class) {
								case EC_FILE:
								desk.dicon[i].class=IDFILE;
								desk.dicon[i].spec.file=pmalloc(sizeof(D_FILE));
								if(desk.dicon[i].spec.file) {
									strcpy(desk.dicon[i].spec.file->name,wpath->path);
									strcat(desk.dicon[i].spec.file->name,litem->name);
									desk.dicon[i].spec.file->mode=litem->mode;
									aptr=app_find(desk.dicon[i].spec.file->name);
									if(aptr)
									strcpy(desk.dicon[i].title,aptr->title);
								}
								break;
								case EC_DEVICE:
								desk.dicon[i].class=IDDEVICE;
								desk.dicon[i].spec.device=pmalloc(sizeof(D_DEVICE));
								if(desk.dicon[i].spec.device) {
									strcpy(desk.dicon[i].spec.device->name,wpath->path);
									strcat(desk.dicon[i].spec.device->name,litem->name);
								}
								break;
								case EC_FOLDER:
								desk.dicon[i].class=IDFOLDER;
								desk.dicon[i].spec.folder=pmalloc(sizeof(D_FOLDER));
								if(desk.dicon[i].spec.folder) {
									strcpy(desk.dicon[i].spec.folder->path,wpath->path);
									strcat(desk.dicon[i].spec.folder->path,litem->name);
									strcat(desk.dicon[i].spec.folder->path,"\\");
								}
								break;
							}
							/* War kein Speicher mehr frei ? */
							if(!desk.dicon[i].spec.data) {
								desk.dicon[i].class=IDFREE;
								frm_alert(1,rs_frstr[ALNOMEM],altitle,conf.wdial,0L);
								litem=0L;
							} else {
								/* Allgemeine Daten des Icons bertragen */
								desk.dicon[i].select=1;
								desk.dicon[i].prevsel=0;
								if(wpath->index.text) {
									if(px+76>tb.desk.w)
										px=tb.desk.w-76;
									if(py+40>tb.desk.h)
										py=tb.desk.h-40;
									desk.dicon[i].x=px;
									desk.dicon[i].y=py;
									px+=80;pn++;
									if(px+76>tb.desk.w || pn>=wpath->imx) {
										pn=0;
										px=otx + jumps * 80;
										py+=48;
										if ((py + 48) > tb.desk.h) {
											py = oty;
											px += 80 * wpath->imx;
											jumps += wpath->imx;
										}
									}
								} else {
									iblk=&wpath->wicon[j].ciconblk.monoblk;
									desk.dicon[i].x=pxy[p*18+0]+iblk->ib_wicon/2;
									desk.dicon[i].y=pxy[p*18+1]-tb.desk.y;
								}
								icon_update(i);
								objc_offset(rs_trindex[DESKTOP],i,&x,&y);
								w=rs_trindex[DESKTOP][i].ob_width;
								h=rs_trindex[DESKTOP][i].ob_height;
								/* Gesamtrechteck anpassen */
								if(x<tx1)
									tx1=x;
								if(y<ty1)
									ty1=y;
								if(x+w>tx2)
									tx2=x+w;
								if(y+h>ty2)
									ty2=y+h;

								wpath->amask[0]=0;
								wpath_esel1(desk.sel.win,litem,0,&wrect,&wrd);

								/* N„chstes freies Icon suchen */
								while(desk.dicon[i].class!=IDFREE && i<=MAXICON) i++;
								p++;
							}
							j++;litem=wpath->lptr[j];
						}
					} else {
						j++;
						litem=wpath->lptr[j];
					}
				}

				for(j=0;j<wpath->e_total;j++) {
					litem=wpath->lptr[j];
					if(litem->sel) {
						wpath->amask[0]=0;
						wpath_esel1(desk.sel.win,litem,0,&wrect,&wrd);
					}
				}
				if(wrd)
					win_redraw(desk.sel.win,wrect.x,wrect.y,wrect.w,wrect.h);
				wpath_info(desk.sel.win);
				desk_draw(tx1,ty1,tx2-tx1+1,ty2-ty1+1);
			}
			else mybeep(); /* Ablegen war nicht m”glich */
		}
	}
	pfree(pxy);
	pfree(obnum);
#ifdef TB_EXTENSIONS
	if (new_one) {
		tb.topwin=new_one;
		dl_closewin();
	}
#endif
}

/**
 wpath_showsel()

 Scrollt den Fensterinhalt bei Bedarf, damit die selektierten Eintr„ge
 sichtbar sind. Wird z.B. vom Auto-Locator gebraucht.
 -------------------------------------------------------------------------*/
void wpath_showsel(WININFO *win, int doscroll) {
	int rd, n, sx, sy;
	int x, y, w, h, xg, yg;
	RECT wrect, irect;
	W_PATH *wpath;
	WP_ENTRY *item;
	int dx, i, c;

	rd = 0;
	wpath = (W_PATH *) win->user;
	if (!wpath->e_total)
		return;

	/* Ggf. Cursor bercksichtigen */
	if (glob.fmode && glob.fwin == win)
		c = wpath->focus;
	else
		c = -1;

	/* Linker Rand fr Textdarstellung */
	if (wpath->index.text)
		dx = 10;
	else
		dx = 0;
	for (i = 0; i < wpath->e_total; i++) {
		item = wpath->lptr[i];
		if ((c == -1 && item->sel) || c == i) {
			/* Koordinaten berechnen */
			n = item->obnum;
			if (wpath->index.text) {
				if (conf.vert) {
					xg = (n - 1) / wpath->imy;
					x = xg * wpath->tlen + win->work.x + 10 - wpath->offx;
					y = (n - 1 - xg * wpath->imy) * (wpath->clh + 1) + win->work.y + 2 - wpath->offy;
				} else {
					yg = (n - 1) / wpath->imx;
					x = (n - 1 - yg * wpath->imx) * wpath->tlen + win->work.x + 10 - wpath->offx;
					y = yg * (wpath->clh + 1) + win->work.y + 2 - wpath->offy;
				}

				w = wpath->tlen - wpath->clw * 2;
				h = wpath->clh;
			} else {
				x = wpath->tree->ob_x + wpath->tree[n].ob_x;
				y = wpath->tree->ob_y + wpath->tree[n].ob_y;
				w = wpath->tree[n].ob_width;
				h = wpath->tree[n].ob_height;
			}
			if (!rd) {
				rd = 1;
				irect.x = x;
				irect.y = y;
				irect.w = w;
				irect.h = h;
			} else {
				if (x < irect.x) {
					irect.w += (irect.x - x);
					irect.x = x;
				}
				if (x + w > irect.x + irect.w)
					irect.w = x + w - irect.x;
				if (y < irect.y) {
					irect.h += (irect.y - y);
					irect.y = y;
				}
				if (y + h > irect.y + irect.h)
					irect.h = y + h - irect.y;
			}
		}
	}

	/* Fensterarbeitsbereich */
	memcpy(&wrect, &win->work, sizeof(RECT));

	/* Scroll */
	if (rd) {
		wrect.x += dx;
		wrect.w -= dx;
		sx = wrect.x - irect.x;
		sy = wrect.y - irect.y;
		if (sy <= 0) {
			if (irect.h > wrect.h)
				irect.h = wrect.h;
			if (irect.y + irect.h > wrect.y + wrect.h)
				sy = -(irect.y - wrect.y - wrect.h + irect.h);
			else
				sy = 0;
		}
		if (sx <= 0) {
			if (irect.w > wrect.w)
				irect.w = wrect.w;
			if (irect.x + irect.w > wrect.x + wrect.w)
				sx = -(irect.x - wrect.x - wrect.w + irect.w);
			else
				sx = 0;
		}
		if (sx != 0 || sy != 0) {
			if (doscroll)
				win_slide(win, S_PABS, sx, sy);
			else {
				wpath->offx -= sx;
				wpath->offy -= sy;
				win_slide(win, S_INIT, 0, 0);
			}
		}
	}
}

/* EOF */
