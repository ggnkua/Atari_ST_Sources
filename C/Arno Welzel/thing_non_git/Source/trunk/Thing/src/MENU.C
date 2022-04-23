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
#include "..\include\thingrsc.h"
#undef TIMER
#ifdef TIMER
#include <time.h>

static clock_t timer1;
static clock_t timer2;
#endif

/**-------------------------------------------------------------------------
 mn_istate()

 Lokale Funktion: Disablen eines Menueeintrags
 -------------------------------------------------------------------------*/
void mn_istate(int item, int enable) {
#ifdef OLD_MENU
	if(enable)
	rs_trindex[MAINMENU][item].ob_state &= ~DISABLED;
	else rs_trindex[MAINMENU][item].ob_state |= DISABLED;
#else
	dial_setopt(rs_trindex[MAINMENU], item, DISABLED, !enable);
#endif
}

/**
 *
 */
static void mn_redraw(OBJECT *tree) {
	int top;

	wind_update (BEG_MCTRL);
	if (!(tb.sys & SY_MULTI) || (tb.app_id == menu_bar(0L, -1))) {
		wind_get(0, WF_TOP, &top);
		menu_bar(tree, 1);
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
	wind_update (BEG_UPDATE);
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
	wind_update (END_UPDATE);
}

/**-------------------------------------------------------------------------
 mn_disable()

 Deaktivieren der Menueeintraege bei Fensterdialogen
 -------------------------------------------------------------------------*/
void mn_disable(void) {
#ifdef OLD_MENU
	int twin;
	int i;
#endif
	OBJECT *baum;

	baum = rs_trindex[MAINMENU];

#ifdef OLD_MENU
	wind_update(BEG_UPDATE);

	baum[MABOUT].ob_state|=DISABLED;

	baum[MNEW].ob_state|=DISABLED;
	baum[MOPEN].ob_state|=DISABLED;
	baum[MFIND].ob_state|=DISABLED;
	baum[MINFO].ob_state|=DISABLED;
	baum[MCLOSE].ob_state|=DISABLED;
	baum[MSHOW].ob_state|=DISABLED;
	baum[MPRINT].ob_state|=DISABLED;
	baum[MSAVEGROUP].ob_state|=DISABLED;
	baum[MEJECT].ob_state|=DISABLED;
	baum[MFORMAT].ob_state|=DISABLED;
	baum[MQUIT].ob_state|=DISABLED;

	baum[MCOPY].ob_state|=DISABLED;
	baum[MCUT].ob_state|=DISABLED;
	baum[MPASTE].ob_state|=DISABLED;
	baum[MDELETE].ob_state|=DISABLED;
	baum[MSELECTALL].ob_state|=DISABLED;
	baum[MSELECTNONE].ob_state|=DISABLED;

	baum[MTEXT].ob_state|=DISABLED;
	baum[MSYMTEXT].ob_state|=DISABLED;
	baum[MICONS].ob_state|=DISABLED;
	baum[MMASK].ob_state|=DISABLED;
	baum[MFONT].ob_state|=DISABLED;
	for(i=MSORTNAME;i<=MSORTNONE;i++) baum[i].ob_state|=DISABLED;

	baum[MNEXTWIN].ob_state|=DISABLED;
	baum[MCLOSEWIN].ob_state|=DISABLED;
	baum[MCLOSEALLWIN].ob_state|=DISABLED;
	baum[MDUPWIN].ob_state|=DISABLED;
	for(i=MWIN1;i<=MWIN10;i++) baum[i].ob_state|=DISABLED;

	baum[MAPPL].ob_state|=DISABLED;
	baum[MFUNC].ob_state|=DISABLED;
	baum[MTOOLS].ob_state|=DISABLED;
	baum[MCONFIG].ob_state|=DISABLED;
	baum[MDRIVE].ob_state|=DISABLED;
	baum[MCHANGEREZ].ob_state|=DISABLED;
	baum[MEDITICONS].ob_state|=DISABLED;
	baum[MLOADICONS].ob_state|=DISABLED;
	baum[MCONSOLE].ob_state|=DISABLED;
	baum[MFONTSEL].ob_state|=DISABLED;
	baum[MSAVECONFIG].ob_state|=DISABLED;
	baum[MLOADCONFIG].ob_state|=DISABLED;

	for(i=MTOOL1;i<=MTOOL1+9;i++) baum[i].ob_state|=DISABLED;

	for(i=MFILE;i<=MTOOL;i++) baum[i].ob_state|=DISABLED;
	if (!(tb.sys & SY_MULTI) || (tb.app_id == menu_bar(0L, -1)))
	{
		wind_get(0, WF_TOP, &twin);
		menu_bar(baum,0);
		menu_bar(baum,1);
		if (twin > 0)
		wind_set(twin, WF_TOP);
	}
	for(i=MFILE;i<=MTOOL;i++) baum[i].ob_flags&=~HIDETREE;
	baum[MACC-1].ob_width=
	baum[MACC].ob_x+baum[MACC].ob_width;
	wind_update(END_UPDATE);
#else
	mn_all_ienable(baum, 0);
	mn_redraw(baum);
#endif
}

/**-------------------------------------------------------------------------
 mn_check()

 "Haeckchen" in den Menueeintraegen entsprechend der Konfiguration setzen
 -------------------------------------------------------------------------*/
void mn_check(void) {
	int check, text, sortby;
	OBJECT *baum;

#ifdef TIMER
	timer1 = clock();
#endif
	baum = rs_trindex[MAINMENU];

	wind_update (BEG_UPDATE);

	menu_icheck(baum, MTEXT, 0);
	menu_icheck(baum, MSYMTEXT, 0);
	menu_icheck(baum, MICONS, 0);
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
	menu_icheck(baum, check, 1);

	for (check = MSORTNAME; check <= MSORTNONE; check++)
		menu_icheck(baum, check, 0);
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
		menu_icheck(baum, check, 1);
	menu_icheck(baum, MSORTVICE, !!(sortby & SORTREV));
	menu_icheck(baum, MSORTFOLD, !!(sortby & SORTFOLD));
	menu_icheck(baum, MAUTOSAVE, !!conf.autosave);
	menu_icheck(baum, MHKACTIVE, !!conf.hotkeys);

	wind_update (END_UPDATE);
#ifdef TIMER
	timer1 = clock() - timer1;
	fprintf(stdout, "\033H\n\nmn_check(): %ld \n", (long)timer1);
#endif
}

/*-------------------------------------------------------------------------
 mn_update()

 MenÅeintrage je nach Situation DISABLEn
 -------------------------------------------------------------------------*/
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
#ifdef OLD_MENU
	int twin;
#endif
	OBJECT *baum;

#ifndef OLD_MENU
	if (tb.sm_modal)
		return;
#endif

#ifdef TIMER
	timer2 = clock();
#endif

	baum = rs_trindex[MAINMENU];

	wind_update (BEG_UPDATE);

#ifdef OLD_MENU 
	/* Falls keine Modale Dialogbox auf ist, dann ggf. MenÅtitel
	 wieder aktivieren */
	if((baum[MFILE].ob_state&DISABLED))
	{
		if(!tb.sm_modal)
		{
			for(i=MFILE;i<=MTOOL;i++)
			{
				baum[i].ob_flags&=~HIDETREE;
				baum[i].ob_state&=~DISABLED;
			}
			baum[MTOOL].ob_flags&=~HIDETREE;
			baum[MACC-1].ob_width=
			baum[MACC].ob_x+
			baum[MTOOL].ob_x+
			baum[MTOOL].ob_width-1;
			if (!(tb.sys & SY_MULTI) || (tb.app_id == menu_bar(0L, -1)))
			{
				wind_get(0, WF_TOP, &twin);
				menu_bar(baum,0);
				menu_bar(baum,1);
				if (twin > 0)
				wind_set(twin, WF_TOP);
			}
		}
		else
		{
			wind_update(END_UPDATE);
			return; /* Modaler Dialog auf - dann raus */
		}
	}
#else
	mn_all_ienable(baum, 1);
#endif

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
			item = baum[MTOOL1 + nt].ob_spec.free_string;
			strcpy(item, "  ");
			strcat(item, conf.ttxt[i]);
			mn_istate(MTOOL1 + nt, 1);
			baum[MTOOL1 + nt].ob_flags &= ~LASTOB;
			baum[MTOOL1 + nt].ob_next = MTOOL1 + nt + 1;
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
		baum[MTOOLS].ob_flags &= ~LASTOB;
		baum[MTOOLS].ob_next = MTOOLS + 1;
		baum[MTOOL1 + i].ob_flags |= LASTOB;
		baum[MTOOL1 + i].ob_next = MTOOLS - 1;
		baum[MTOOLS - 1].ob_tail = MTOOL1 + i;
		baum[MTOOLS - 1].ob_height = tb.ch_h * (nt + 2);
	} else {
		baum[MTOOLS].ob_flags |= LASTOB;
		baum[MTOOLS].ob_next = MTOOLS - 1;
		baum[MTOOLS - 1].ob_tail = MTOOLS;
		baum[MTOOLS - 1].ob_height = tb.ch_h;
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
			switch (tb.topwin->class)
			{
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
			baum[MWIN1 + i].ob_state &= ~DISABLED;
			item = baum[MWIN1 + i].ob_spec.free_string;
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
			baum[MWIN1 + i].ob_next = MWIN1 + i + 1;
			baum[MWIN1 + 1].ob_flags &= ~LASTOB;

			/* Aktuelles Fenster abhaken */
			if (win == tb.topwin)
				baum[MWIN1 + i].ob_state |= CHECKED;
			else
				baum[MWIN1 + i].ob_state &= ~CHECKED;

			/* Und naechstes Fenster ... */
			i++;
			win = win->next;
		} while (win && i < 10);
		i--;
		baum[MWIN1 - 2].ob_next = MWIN1 - 1;
		baum[MWIN1 - 2].ob_flags &= ~LASTOB;
		baum[MWIN1 + i].ob_next = MTWINDOW;
		baum[MWIN1 + 1].ob_flags |= LASTOB;
		baum[MTWINDOW].ob_tail = MWIN1 + i;
		baum[MTWINDOW].ob_height = tb.ch_h * (6 + i);
	} else {
		/* Kein Fenster offen */
		for (i = 0; i < 10; i++) {
			baum[MWIN1 + i].ob_state |= DISABLED;
			sprintf(baum[MWIN1 + i].ob_spec.free_string, "       %d", i);
		}
		baum[MWIN1 - 2].ob_next = MTWINDOW;
		baum[MWIN1 - 2].ob_flags |= LASTOB;
		baum[MTWINDOW].ob_tail = MWIN1 - 2;
		baum[MTWINDOW].ob_height = tb.ch_h * 4;
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
		if (tb.topwin->class==WCDIAL && !(tb.topwin->state&WSICON)) {
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
	} else { /* Nî - aber vielleicht ein Fenster aktiv ? */
		m_info = m_del = m_print = 0;
		if (tb.topwin) {
			switch (tb.topwin->class)
			{
				case WCPATH:
				case WCGROUP:
				if (!(tb.topwin->state & WSICON))
				m_info = 1;
				break;
			}
		}
		else
		m_eject = 0;
	}
	if (m_eject && (desk.sel.drives != 1) && (tb.topwin) &&
	((tb.topwin->class != WCPATH) || (tb.topwin->state & WSICON) ||
			((tb.topwin->class == WCPATH) &&
					!drv_ejectable(((W_PATH *)tb.topwin->user)->filesys.biosdev)))) {
		m_eject = 0;
	}
	mn_istate(MINFO, m_info);
	mn_istate(MOPEN, m_open);
	mn_istate(MSHOW, m_show);
	mn_istate(MDELETE, m_del);
	mn_istate(MPRINT, m_print);
	mn_istate(MEJECT, m_eject);

#ifdef OLD_MENU
	/* MenÅpunkte, die durch Fensterdialoge evtl. DISABLED wurden */
	baum[MABOUT].ob_state&=~DISABLED;
	mn_istate(MNEW,1);
	if(conf.finder[0]) mn_istate(MFIND,1); else mn_istate(MFIND,0);
	mn_istate(MFORMAT,1);

	if(!(tb.sys&SY_MSHELL) || ((tb.sys&SY_MSHELL) && (tb.sys&SY_SHUT))) mn_istate(MQUIT,1);
	else mn_istate(MQUIT,0);

	mn_istate(MAPPL,1);
	mn_istate(MFUNC,1);
	mn_istate(MTOOLS,1);
	mn_istate(MCONFIG,1);
	mn_istate(MDRIVE,1);
	mn_istate(MEDITICONS,1);

	mn_istate(MLOADICONS,1);
	if ((tb.sys & SY_MSHELL) || (getenv("RSMASTER") != 0L))
	mn_istate(MCHANGEREZ,1);
	mn_istate(MCONSOLE, getcookie('T2GM', NULL));
	mn_istate(MFONTSEL,1);
	mn_istate(MSAVECONFIG,1);
	mn_istate(MLOADCONFIG,1);
#else
	/* Eventuell weitere MenÅpunkte sperren */
	mn_istate(MFIND, *conf.finder);
	mn_istate(MQUIT, !((tb.sys & SY_MSHELL) && !(tb.sys & SY_SHUT)));
	mn_istate(MCHANGEREZ,
			!(!(tb.sys & SY_MSHELL) && (getenv("RSMASTER") == 0L)));
	mn_istate(MCONSOLE, getcookie('T2GM', NULL));
	mn_redraw(baum);
#endif

	wind_update (END_UPDATE);
#ifdef TIMER
	timer2 = clock() - timer2;
	fprintf(stdout, "\033H\n\n\nmn_update(): %ld \n", (long)timer2);
#endif
}
