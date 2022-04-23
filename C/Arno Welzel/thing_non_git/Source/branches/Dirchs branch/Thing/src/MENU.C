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
 MENU.C

 Thing
 Menueverwaltung
 =========================================================================*/

#include "..\include\globdef.h"
#include "..\include\types.h"
#include "rsrc\thing_de.h"
#include "rsrc\thgtxtde.h"
#undef TIMER
#ifdef TIMER
#include <time.h>

static clock_t timer1;
static clock_t timer2;
#endif

/**
 * Lokale Funktion: Disablen eines Menueeintrags
 *
 * @param item
 * @param enable
 */
void mn_istate(int item, int enable) {
	setObjectState(rs_trindex[MAINMENU], item, DISABLED, !enable);
}

/**
 *
 *
 * @param *objectTree
 */
static void mn_redraw(OBJECT *objectTree) {
	int top;

	wind_update (BEG_MCTRL);
	if (!(tb.sys & SY_MULTI) || (tb.app_id == menu_bar(0L, -1))) {
		wind_get(0, WF_TOP, &top);
		menu_bar(objectTree, 1);
		if (top > 0)
			wind_set(top, WF_TOP);
	}
	wind_update (END_MCTRL);
}

/**
 * mn_all_ienable
 *
 * Setzt alle Eintraege eines Menues via menu_ienable() auf ENABLED
 * oder DISABLED. Davon ausgenommen sind Eintraege, die mit einem
 * Minuszeichen beginnen, keine G_STRINGs sind oder zu den ACC-
 * Slots gehoeren.
 *
 * Eingabe:
 * tree: Zeiger auf zu bearbeitendes Menue (wenn tree auf einen Baum
 *       zeigt, der nicht die Struktur eines AES-Menues hat, ist das
 *       Verhalten der Funktion undefiniert)
 * enable: Alle Eintraege aktivieren (1) oder deaktivieren (0)
 */
static void mn_all_ienable(OBJECT *tree, int enable) {
	int i, j, k, in_acc = 2;
	static int state = 1;

	enable = !!enable;
	if (enable == state)
		return;
	state = enable;
	wind_update(BEG_UPDATE);
	for (i = tree->ob_head; tree[i].ob_next != 0; i = tree[i].ob_next)
		;
	for (j = tree[i].ob_head; j != i; j = tree[j].ob_next) {
		for (k = tree[j].ob_head; k != j; k = tree[k].ob_next) {
			if (((tree[k].ob_type & 0xff) == G_STRING) && (*tree[k].ob_spec.free_string != '-') && (in_acc != 1)) {
				mn_istate(k, enable);
			}
			if (in_acc == 2)
				in_acc = 1;
		}
		in_acc = 0;
	}
	wind_update(END_UPDATE);
}

/**
 * Deaktivieren der Menueeintraege bei Fensterdialogen
 */
void mn_disable(void) {
	OBJECT *objectTree;

	objectTree = rs_trindex[MAINMENU];

	mn_all_ienable(objectTree, 0);
	mn_redraw(objectTree);
}

/**
 * "Haeckchen" in den Menueeintraegen entsprechend der Konfiguration setzen
 */
void mn_check(void) {
	int check, text, sortby;
	OBJECT *objectTree;

#ifdef TIMER
	timer1 = clock();
#endif
	objectTree = rs_trindex[MAINMENU];

	wind_update (BEG_UPDATE);

	menu_icheck(objectTree, MTEXT, 0);
	menu_icheck(objectTree, MSYMTEXT, 0);
	menu_icheck(objectTree, MICONS, 0);
	if (tb.topwin) {
		switch (tb.topwin->class) {
		case WCGROUP:
			text = ((W_GRP *)tb.topwin->user)->text;
			break;
		case WCPATH:
			text = ((W_PATH *)tb.topwin->user)->index.text;
			sortby = ((W_PATH *)tb.topwin->user)->index.sortby;
			break;
		}
	}
	switch (text) {
	case 0:
		check = MICONS;
		break;
	case 1:
		check = MTEXT;
		break;
	case 2:
		check = MSYMTEXT;
		break;
	}
	menu_icheck(objectTree, check, 1);

	for (check = MSORTNAME; check <= MSORTNONE; check++)
		menu_icheck(objectTree, check, 0);
	check = 0;
	switch (sortby & 0xff) {
	case SORTNONE:
		check = MSORTNONE;
		break;
	case SORTNAME:
		check = MSORTNAME;
		break;
	case SORTSIZE:
		check = MSORTSIZE;
		break;
	case SORTDATE:
		check = MSORTDATE;
		break;
	case SORTTYPE:
		check = MSORTEXT;
		break;
	}
	if (check)
		menu_icheck(objectTree, check, 1);
	menu_icheck(objectTree, MSORTVICE, !!(sortby & SORTREV));
	menu_icheck(objectTree, MSORTFOLD, !!(sortby & SORTFOLD));
	menu_icheck(objectTree, MAUTOSAVE, !!conf.autosave);
	menu_icheck(objectTree, MHKACTIVE, !!conf.hotkeys);

	wind_update (END_UPDATE);
#ifdef TIMER
	timer1 = clock() - timer1;
	fprintf(stdout, "\033H\n\nmn_check(): %ld \n", (long)timer1);
#endif
}

/**
 * Menueeintrage je nach Situation DISABLEn
 */
void mn_update(void) {
	int i, nt;
	int m_info, m_open, m_show, m_del, m_path, m_idx, m_sort, m_close, m_eject;
	int m_nwin, m_cwin, m_cpwin, m_ctwin, m_pwin, m_font, m_print, m_save,
			m_sall;
	WININFO *win;
	FORMINFO *fi;
	char *item, *title;
	int tlen, usewin;
	int handle;
	OBJECT *objectTree;

	if (tb.sm_modal)
		return;

#ifdef TIMER
	timer2 = clock();
#endif

	objectTree = rs_trindex[MAINMENU];

	wind_update(BEG_UPDATE);

	mn_all_ienable(objectTree, 1);

	icon_checksel(); /* Aktuelle Auswahl vorher pruefen */

	m_cpwin = m_pwin = m_ctwin = 0;
	if (desk.sel.numobs > 0 && desk.sel.win) {
		if (desk.sel.win->class==WCPATH)
			m_cpwin = m_ctwin = 1;
	}

	/* Tools */
	nt = 0;
	i = 0;
	while (i < 10) {
		if (conf.tobj[i][0]) {
			item = objectTree[MTOOL1 + nt].ob_spec.free_string;
			strcpy(item, "  ");
			strcat(item, conf.ttxt[i]);
			mn_istate(MTOOL1 + nt, 1);
			objectTree[MTOOL1 + nt].ob_flags &= ~LASTOB;
			objectTree[MTOOL1 + nt].ob_next = MTOOL1 + nt + 1;
			nt++;
		}
		i++;
	}
	while (i < 10) {
		mn_istate(MTOOL1 + i, 0);
		i++;
	}
	i = nt;
	if (i > 0) {
		i--;
		objectTree[MTOOLS].ob_flags &= ~LASTOB;
		objectTree[MTOOLS].ob_next = MTOOLS + 1;
		objectTree[MTOOL1 + i].ob_flags |= LASTOB;
		objectTree[MTOOL1 + i].ob_next = MTOOLS - 1;
		objectTree[MTOOLS - 1].ob_tail = MTOOL1 + i;
		objectTree[MTOOLS - 1].ob_height = tb.ch_h * (nt + 2);
	} else {
		objectTree[MTOOLS].ob_flags |= LASTOB;
		objectTree[MTOOLS].ob_next = MTOOLS - 1;
		objectTree[MTOOLS - 1].ob_tail = MTOOLS;
		objectTree[MTOOLS - 1].ob_height = tb.ch_h;
	}

	/* Fenster */
	i = 0;
	m_nwin = m_cwin = m_idx = m_sort = 0;
	m_font = 1;
	m_path = m_save = m_close = m_sall = 0;

	/* Fenster geoeffnet ? */
	usewin = 0;
	win = tb.win;
	while (win) {
		usewin++;
		win = win->next;
	}
	if (usewin) {
		win = tb.win;
		if (tb.topwin) {
			m_close = 1;
			m_cwin = 1;
			switch (tb.topwin->class) {
			case WCPATH:
				if (!(tb.topwin->state & WSICON)) {
					m_idx = m_sort = 1;
					m_path = 1;
					m_sall = 1;
				}
				m_cpwin = m_pwin = 1;
				break;
			case WCCON:
				m_cpwin = 1;
				break;
			case WCGROUP:
				if (((W_GRP *)tb.topwin->user)->changed)
					m_save = 1;
				if (!(tb.topwin->state & WSICON)) {
					m_idx = 1;
					m_sall = 1;
				}
				break;
			}
		}

		/* Mehr als ein Fenster? */
		if (usewin > 1)
			m_nwin = 1;

		/* Fenstertitel im Menue eintragen */
		do {
			objectTree[MWIN1 + i].ob_state &= ~DISABLED;
			item = objectTree[MWIN1 + i].ob_spec.free_string;
			strcpy(item, "  ");
			if (win->name[0] == ' ')
				title = &win->name[1];
			else
				title = &win->name[2];
			tlen = (int) strlen(title);
			if (tlen > 23) {
				strncpy(&item[2], title, 6);
				strcpy(&item[8], "...");
				strcat(item, &title[tlen - 14]);
			} else
				strcat(item, title);
			objectTree[MWIN1 + i].ob_next = MWIN1 + i + 1;
			objectTree[MWIN1 + 1].ob_flags &= ~LASTOB;

			/* Aktuelles Fenster abhaken */
			if (win == tb.topwin)
				objectTree[MWIN1 + i].ob_state |= CHECKED;
			else
				objectTree[MWIN1 + i].ob_state &= ~CHECKED;

			/* Und naechstes Fenster ... */
			i++;
			win = win->next;
		} while (win && i < 10);
		i--;
		objectTree[MWIN1 - 2].ob_next = MWIN1 - 1;
		objectTree[MWIN1 - 2].ob_flags &= ~LASTOB;
		objectTree[MWIN1 + i].ob_next = MTWINDOW;
		objectTree[MWIN1 + 1].ob_flags |= LASTOB;
		objectTree[MTWINDOW].ob_tail = MWIN1 + i;
		objectTree[MTWINDOW].ob_height = tb.ch_h * (6 + i);
	} else {
		/* Kein Fenster offen */
		for (i = 0; i < 10; i++) {
			objectTree[MWIN1 + i].ob_state |= DISABLED;
			sprintf(objectTree[MWIN1 + i].ob_spec.free_string, "       %d", i);
		}
		objectTree[MWIN1 - 2].ob_next = MTWINDOW;
		objectTree[MWIN1 - 2].ob_flags |= LASTOB;
		objectTree[MTWINDOW].ob_tail = MWIN1 - 2;
		objectTree[MTWINDOW].ob_height = tb.ch_h * 4;
	}

	/* Accessory-Fenster angemeldet? */
	if (glob.accwin) {
		get_twin(&handle);
		if (acwin_find(handle))
			m_cwin = 1;
		if (glob.accwin->next || tb.win)
			m_nwin = 1;
	}

	mn_istate(MCLOSE, m_close);
	mn_istate(MNEXTWIN, m_nwin);
	mn_istate(MCLOSEALLWIN, m_cwin);
	mn_istate(MCLOSEWIN, m_cwin);

	mn_istate(MCOPY, m_cpwin);

	/* Cut&Paste auch in aktiven Dialogen mit Editfeldern */
	m_cpwin = 0;
	if (tb.topwin) {
		if (tb.topwin->class == WCDIAL && !(tb.topwin->state & WSICON)) {
			fi = (FORMINFO *) tb.topwin->user;
			if (fi->edit_obj)
				m_cpwin = m_ctwin = m_pwin = 1;
			mn_istate(MCOPY, m_cpwin);
		}
	}
	mn_istate(MCUT, m_ctwin);
	mn_istate(MPASTE, m_pwin);

	mn_istate(MDUPWIN, m_path);
	mn_istate(MSAVEGROUP, m_save);

	mn_istate(MSELECTALL, m_sall);
	mn_istate(MSELECTNONE, m_sall);

	mn_istate(MTEXT, m_idx);
	mn_istate(MSYMTEXT, m_idx);
	mn_istate(MICONS, m_idx);
	for (i = MSORTVICE; i <= MSORTNONE; i++)
		mn_istate(i, m_sort);
	mn_istate(MMASK, m_path);
	mn_istate(MFONT, m_font);
	mn_istate(MSAVEINDEX, m_path);
	mn_istate(MDEFAULT, m_path);

	m_show = 0;
	m_open = 1;
	m_eject = 1;
	/* Objekte selektiert ? */
	if (desk.sel.numobs) {
		m_info = m_open = m_del = m_print = 1;
		m_show = 1;

		/* Falls die Auswahl in einem ikonifizierten Fenster liegt, dann keine Bearbeitung moeglich */
		if (desk.sel.win) {
			if (desk.sel.win->state & WSICON) {
				m_info = m_open = m_del = m_print = 0;
				m_show = 0;
			}
		}
		/* Devices koennen nicht geîffnet werden */
		if (desk.sel.devices) {
			m_open = 0;
			if (desk.sel.win)
				m_del = 0; /* ... und im Verzeichnis nicht lîschen */
		}
		if (desk.sel.parent)
			m_del = 0;
		if (desk.sel.trash || desk.sel.printer)
			m_open = m_del = 0;
		if ((desk.sel.drives || desk.sel.folders) && desk.sel.files)
			m_open = 0;
		if (desk.sel.folders && desk.sel.drives)
			m_open = 0;
		if (desk.sel.folders > 1 || desk.sel.drives > 1 || desk.sel.files > 1)
			m_open = 0;
		/* Nur eine einzelne Datei kann gedruckt/angezeigt werden */
		if (desk.sel.numobs > 1 || !desk.sel.files)
			m_print = m_show = 0;
		/* Nur genau ein Laufwerk kann ausgeworfen werden */
		if (desk.sel.drives > 1)
			m_eject = 0;
		else {
			ICONDESK *p = desk.dicon + 1;

			/* Laufwerk auswerfbar? */
			for (i = 1; i <= MAXDRIVES; i++, p++) {
				if (p->select) {
					if (!drv_ejectable(p->spec.drive->drive)) {
						m_eject = 0;
						break;
					}
				}
			}
		}
	} else { /* Nein - aber vielleicht ein Fenster aktiv ? */
		m_info = m_del = m_print = 0;
		if (tb.topwin) {
			switch (tb.topwin->class) {
			case WCPATH:
			case WCGROUP:
				if (!(tb.topwin->state & WSICON))
					m_info = 1;
				break;
			}
		} else
			m_eject = 0;
	}
	if (m_eject && (desk.sel.drives != 1) && (tb.topwin) &&
		((tb.topwin->class != WCPATH) || (tb.topwin->state & WSICON) ||
		((tb.topwin->class == WCPATH) && !drv_ejectable(((W_PATH *)tb.topwin->user)->filesys.biosdev)))) {
		m_eject = 0;
	}
	mn_istate(MINFO, m_info);
	mn_istate(MOPEN, m_open);
	mn_istate(MSHOW, m_show);
	mn_istate(MDELETE, m_del);
	mn_istate(MPRINT, m_print);
	mn_istate(MEJECT, m_eject);

	/* Eventuell weitere MenÅpunkte sperren */
	mn_istate(MFIND, *conf.finder);
	mn_istate(MQUIT, !((tb.sys & SY_MSHELL) && !(tb.sys & SY_SHUT)));
	mn_istate(MCHANGEREZ, !(!(tb.sys & SY_MSHELL) && (getenv("RSMASTER") == 0L)));
	mn_istate(MCONSOLE, getCookie('T2GM', NULL));
	mn_redraw(objectTree);

	wind_update (END_UPDATE);
#ifdef TIMER
	timer2 = clock() - timer2;
	fprintf(stdout, "\033H\n\n\nmn_update(): %ld \n", (long)timer2);
#endif
}
