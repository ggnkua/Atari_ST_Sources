/**
 * ThingFnd - Thing Find
 * Copyright (C) 1999-2012 Thomas Binder
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
 * @copyright  Thomas Binder 1999-2012
 * @author     Thomas Binder
 * @license    LGPL
 */

#include <gem.h>
#include <mintbind.h>
#include <signal.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <time.h>
#include <math.h>
#include <nkcc.h>
#include <thingtbx.h>
#include <vaproto.h>
#ifdef USE_PMALLOC
#include <malloc.h>
#else
#define pmalloc	malloc
#define pfree	free
#endif
#include <new_rsc.h>
#include "rsrc\thingfnd.h"
#include "..\include\thingfnd.h"
#include <dudolib.h>

/*------------------------------------------------------------------*/
/*  global functions                                                */
/*------------------------------------------------------------------*/
/*------------------------------------------------------------------*/
/*  global variables                                                */
/*------------------------------------------------------------------*/
char *aesapname, *altitle = "ThingFnd", almsg[256];
short aesmsg[8];
EVENT mevent;
GLOB glob;
RSINFO rinfo;
FIND_DATA find;
long lasthits;
CARD *mainCard = NULL;

FORMINFO fi_about = { 0L, ABOUT, 0, ROOT, 0, 0, 0, 0, 0L, 0L, 0, "%about", -1, ABHELP };
FORMINFO fi_find = { 0L, FIND, 0, ROOT, 0, 0, 0, 0, 0L, 0L, 0, "%find", FCANCEL, FHELP };
FORMINFO fi_status = { 0L, STATUS, 0, ROOT, 0, 0, 0, 0, 0L, 0L, 0, "%status", SCANCEL, SHELP };

/*------------------------------------------------------------------*/
/*  external variables                                              */
/*------------------------------------------------------------------*/
extern BYTE *aesBuffer;

/*------------------------------------------------------------------*/
/*  local functions                                                 */
/*------------------------------------------------------------------*/
/*------------------------------------------------------------------*/
/*  local variables                                                 */
/*------------------------------------------------------------------*/
/*------------------------------------------------------------------*/
/*  local definitions                                               */
/*------------------------------------------------------------------*/
#define VERSION	"0.20"
#define STGUIDEHELPFILE "thingfnd.hyp"

void sigTerm(long sig) {
	UNUSED(sig);
	glob.done = 1;
}

/**
 * full_fselect
 *
 * Ruft fselect() auf und kuemmert sich dabei um Sachen wie Zerlegung
 * und Zusammensetzung des Pfades, Ermittlung des Defaultpfades,
 * Neuzeichnen des Dialogs, etc.
 *
 * Eingabe:
 * full: Zeiger auf vorzuselektierende Datei inklusive Pfad. Nach dem
 *       Aufruf steht hier die tatsaechlich ausgewaehlte Datei.
 * deflt: Zeiger auf vorzusektierende Datei, wenn full leer ist.
 *          Wenn NULL, wird das aktuelle Verzeichnis benutzt.
 * ext: Zeiger auf Filterextension
 * dironly: Es soll ein Verzeichnis ausgewaehlt werden; ein eventuell
 *          auswgewaehlter Dateiname wird also ignoriert
 * title: Zeiger auf Titel fuer die Auswahlbox
 * freedret: Freedom non-modal aufrufen? (0/1)
 * freedid: ID fuer Freedom, wenn freedret = 1
 * form: Zeiger auf aufrufendes Formular, ggf. NULL
 *
 * Rueckgabe:
 * 0: Dateiauswahl mit 'Abbruch' verlassen oder Aufruf fehlgeschlagen
 * 1: Dateiauswahl erfolgreich, ausgewaehlte Datei steht in full
 * 2: Dateiauswahl erfolgreich, ausgewaehlter Ordner steht in full
 */
short full_fselect(char *full, char *deflt, char *ext, short dironly, char *title,
		short freedret, short freedid, FORMINFO *fi) {
	char path[MAX_PLEN], name[MAX_FLEN], *p;
	short exbut, ret;

	if (!*full) {
		if (deflt)
			strcpy(full, deflt);
		else {
			full[0] = Dgetdrv() + 'A';
			full[1] = ':';
			Dgetpath(&full[2], 0);
			if (strrchr(full, 0)[-1] != '\\')
				strcat(full, "\\");
		}
	}
	full2comp(full, path, name);
	strcat(path, ext);
	ret = fselect(path, name, &exbut, title, freedret, freedid);
	if (fi && (fi->state != FST_WIN))
		frm_redraw(fi, ROOT);
	if (ret && exbut) {
		if (dironly)
			*name = 0;
		p = strrchr(path, '\\');
		if (p)
			p[1] = 0;
		comp2full(full, path, name);
		*full = toupper(*full);
		if (*name)
			return (1);
		else
			return (2);
	}
	return (0);
}

/**
 *
 *
 * @param *objectTree
 */
static void mn_redraw(OBJECT *objectTree) {
	short top;
	short d;

	wind_update(BEG_MCTRL);
	if (!(tb.sys & SY_MULTI) || (tb.app_id == menu_bar(0L, -1))) {
		wind_get(0, WF_TOP, &top, &d, &d, &d);
		menu_bar(objectTree, 1);
		if (top > 0)
			wind_set(top, WF_TOP, 0, 0, 0, 0);
	}
	wind_update(END_MCTRL);
}

/**
 * mn_all_ienable
 *
 * Setzt alle Eintraege eines Menues via menu_ienable() auf ENABLED
 * oder DISABLED. Davon ausgenommen sind Eintraege, die mit einem
 * Minuszeichen beginnen, keine G_STRINGs sind oder zu den ACC-
 * Slots geh”ren.
 *
 * Eingabe:
 * objectTree: Zeiger auf zu bearbeitendes Menue (wenn objectTree auf einen Baum
 *       zeigt, der nicht die Struktur eines AES-Menues hat, ist das
 *       Verhalten der Funktion undefiniert)
 * enable: Alle Eintraege aktivieren (1) oder deaktivieren (0)
 */
static void mn_all_ienable(OBJECT *objectTree, short enable) {
	short i, j, k, in_acc = 2;
	static short state = 1;

	enable = !!enable;
	if (enable == state)
		return;
	state = enable;
	wind_update(BEG_UPDATE);
	for (i = objectTree->ob_head; objectTree[i].ob_next != 0; i = objectTree[i].ob_next)
		;
	for (j = objectTree[i].ob_head; j != i; j = objectTree[j].ob_next) {
		for (k = objectTree[j].ob_head; k != j; k = objectTree[k].ob_next) {
			if (((objectTree[k].ob_type & 0xff) == G_STRING) && (*objectTree[k].ob_spec.free_string != '-') && (in_acc != 1)) {
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
	mn_all_ienable(rinfo.rs_trindex[MAINMENU], 0);
	mn_redraw(rinfo.rs_trindex[MAINMENU]);
}

/**
 * Disablen eines Menueeintrags
 *
 * @param item
 * @param enable
 */
void mn_istate(short item, short enable) {
	if (enable)
		unsetObjectDisabled(rinfo.rs_trindex[MAINMENU], item);
	else
		setObjectDisabled(rinfo.rs_trindex[MAINMENU], item);
}

/**
 * Menueeintrage je nach Situation DISABLEn
 */
void mn_update(void) {
	OBJECT *objectTree;

	objectTree = rinfo.rs_trindex[MAINMENU];

	wind_update(BEG_UPDATE);
	if (isObjectDisabled(objectTree, MFILE))
		mn_all_ienable(objectTree, 1);
	mn_istate(MABOUT, 1);
	mn_istate(MNEXTWIN, 1);
	mn_istate(MQUIT, 1);
	mn_redraw(objectTree);
	wind_update(END_UPDATE);
}

/*
 * Initialisiert und oeffnet den Dialog 'Ueber ThingFnd'.
 */
void di_about(void) {
	if (fi_about.open) {
		frm_restore(&fi_about);
		return;
	}
	frm_start(&fi_about, 1, 1, 0);

	if (fi_about.state == FST_WIN)
		avcWindowOpen(glob.avid, fi_about.win.handle);
}

/**
 *
 */
void de_about(short mode, short ret) {
	UNUSED(ret);

	if (!mode) {
		switch (fi_about.exit_obj) {
		case ABOK:
			if (fi_about.state == FST_WIN)
				avcWindowClose(glob.avid, fi_about.win.handle);

			frm_end(&fi_about);
			break;
		}
	} else {
		if (fi_about.state == FST_WIN)
			avcWindowClose(glob.avid, fi_about.win.handle);
		frm_end(&fi_about);
	}
}

/**
 * Fenster wechseln
 */
void dl_nextwin(void) {
	WININFO *win;

	if (!tb.topwin)
		win = tb.win;
	else {
		win = tb.topwin->next;
		if (!win && glob.avid < 0)
			win = tb.win;
	}

	if (win) {
		win_top(win);
		magx_switch(tb.app_id, 0);
	} else {
		if (glob.avid >= 0 && (glob.avflags & 0x0001))
			appl_send(glob.avid, AV_SENDKEY, 0, K_CTRL, 0x1107, 0, 0, 0);
	}
}

/**
 * Ende
 */
void dl_quit(void) {
	glob.done = 1;
}

/**
 * Schreibt ein GEMDOS-Datum in einen String.
 *
 * Eingabe:
 * str: Zeiger auf Zielpuffer
 * date: Einzufuegendes GEMDOS-Datum, 0xffff = kein Datum (leer)
 */
static void insert_date(char *str, unsigned short date) {
	if (date == 0xffffU)
		strcpy(str, "");
	else
		sprintf(str, "%02d%02d%04d", date & 0x20, (date >> 5) & 0x10, (date >> 9) + 1980);
}

/**
 * Schaltet auf eine bestimmte Karteikarte im Suchen-Dialog um.
 *
 * @param page Anzuzeigende Karteikarte
 */
static void find_setpage(short page) {
	switch (page) {
	case 0:
		setActiveCard(mainCard, FGENERAL, FALSE);
		fi_find.edit_obj = FDRIVES;
		break;
	case 1:
		setActiveCard(mainCard, FATTR, FALSE);
		fi_find.edit_obj = FFROMDATE;
		break;
	}
}

/**
 * Oeffnet den Suchen-Dialog.
 */
void di_find(void) {
	short i, last;
	char *p, *max, *start;
	OBJECT *objectTree;

	objectTree = fi_find.tree;
	if (fi_find.open) {
		frm_restore(&fi_find);
		return;
	}

	setObjectState(objectTree, FON, SELECTED, !*find.searchpath);
	setObjectState(objectTree, FIN, SELECTED, *find.searchpath);
	strShortener(objectTree[FPATH].ob_spec.tedinfo->te_ptext, find.searchpath, 36);
	p = start = getObjectText(objectTree, FDRIVES);

	max = p + 31;
	last = -1;
	for (i = 0; i < 32; i++) {
		if (find.drvbits & (1L << (long) i)) {
			if (last == -1) {
				if (p > start)
					*p++ = ',';
				last = i;
				*p++ = 'A' + i;
			}
		} else {
			if ((last != -1) && (i > (last + 1))) {
				*p++ = '-';
				*p++ = 'A' + i - 1;
			}
			last = -1;
		}
		if (p >= max)
			break;
	}
	if ((last != -1) && (i > (last + 1)) && (p < max)) {
		*p++ = '-';
		*p++ = 'A' + i - 1;
	}
	*p = 0;

	setObjectState(objectTree, FGO, DISABLED, (find.drvbits == 0L) && !*find.searchpath);
	if (isObjectDisabled(objectTree, FGO))
		setObjectFlags(objectTree, FGO, DEFAULT, FALSE);

	setObjectState(objectTree, FFOLLOW, SELECTED, find.follow);
	setObjectState(objectTree, FVERBOSE, SELECTED, find.verbose);
	setObjectText(objectTree, FFMASK, find.filemask);
	setObjectState(objectTree, FFCASE, SELECTED, find.fm_case);
	setObjectState(objectTree, FDIRS, SELECTED, find.fm_dirs);

	setObjectState(objectTree, FTIME, SELECTED, find.datecheck);
	insert_date(objectTree[FFROMDATE].ob_spec.tedinfo->te_ptext, find.mindate);
	insert_date(objectTree[FTODATE].ob_spec.tedinfo->te_ptext, find.maxdate);

	setObjectState(objectTree, FSIZE, SELECTED, find.sizecheck);
	if (find.minsize != -1L) {
		sprintf(objectTree[FFROMSIZE].ob_spec.tedinfo->te_ptext, "%ld", find.minsize);
	} else
		strcpy(objectTree[FFROMSIZE].ob_spec.tedinfo->te_ptext, "");
	if (find.maxsize != -1L) {
		sprintf(objectTree[FTOSIZE].ob_spec.tedinfo->te_ptext, "%ld", find.maxsize);
	} else
		strcpy(objectTree[FTOSIZE].ob_spec.tedinfo->te_ptext, "");

	setObjectState(objectTree, FCONTENTS, SELECTED, find.grep);
	strcpy(objectTree[FCMASK].ob_spec.tedinfo->te_ptext, find.contentmask);
	setObjectState(objectTree, FCCASE, SELECTED, find.cm_case);
	setObjectState(objectTree, FCBINARY, SELECTED, find.cm_binary);

	find.page = 0;
	find_setpage(find.page);

	frm_start(&fi_find, 1, 1, 0);

	if (fi_find.state == FST_WIN)
		avcWindowOpen(glob.avid, fi_find.win.handle);
}

/**
 * search_update
 *
 * Update-Prozedur fuer die Suche, wird als Callback fuer search_main()
 * verwendet.
 *
 * Eingabe/Rueckgabe:
 * Siehe Parameter "update" bei search_main()
 */
short search_update(char *current, long hits) {
	short ret, wait;
	static short count = 0;
	OBJECT *objectTree;
	EVENT event;

	objectTree = fi_status.tree;
	if (win_update(BEG_UPDATE)) {
		if (find.verbose && (current != NULL)) {
			strShortener(objectTree[SCURRENT].ob_spec.tedinfo->te_ptext, current, 30);
			frm_redraw(&fi_status, SCURRENT);
		}
		if ((hits >= 0L) && (hits != lasthits)) {
			lasthits = hits;
			sprintf(objectTree[SHITS].ob_spec.tedinfo->te_ptext, "%ld", hits);
			frm_redraw(&fi_status, SHITS);
		}
		wind_update(END_UPDATE);
	}

	ret = 1;
	if (hits != -2L)
		wait = !(count++ % 50);
	else
		wait = !(count++ % 5);
	if (wait) {
		event = mevent;
		event.ev_mflags = MU_KEYBD | MU_BUTTON | MU_MESAG | MU_TIMER;
		event.ev_mtlocount = 1;
		event.ev_mthicount = 0;

		EvntMulti(&event);
		frm_do(&fi_status, &event);
		if (!fi_status.cont) {
			switch (fi_status.exit_obj) {
			case SHELP:
				frm_norm(&fi_status);
				if (!showSTGuideHelp(STGUIDEHELPFILE, fi_status.userinfo))
					frm_alert(1, rinfo.rs_frstr[ALNOGUIDE], altitle, 1, 0L);
				break;
			case SCANCEL:
				frm_norm(&fi_status);
				ret = 0;
				break;
			}
		}
		if (event.ev_mwich & MU_MESAG)
			frm_event(&fi_status, &event);
	}
	return (ret);
}

/**
 * de_find_go
 *
 * Reagiert auf das Anklicken von "Go" im Suchen-Dialog. Die Eingaben
 * werden geprueft und ggf. bemaengelt. Im Erfolgsfall wird die Suche
 * gestartet.
 *
 * Eingabe:
 * objectTree: Zeiger auf Suchen-Dialog
 */
static void de_find_go(OBJECT *objectTree) {
	long err;
	short start, end, i;
	long ok;
	char *p, fmask[MAX_PLEN], cmask[MAX_PLEN];
	double size;
	FIND_DATA temp;
	OBJECT *s_tree;

	temp = find;
	temp.drvbits = 0L;
	if (isObjectSelected(objectTree, FON)) {
		fprintf(stderr, "1.1 ");
		p = getObjectText(objectTree, FDRIVES);
		start = -1;
		while (*p) {
			if (isalpha(*p)) {
				if (start != -1) {
dfg_parseerr:
					frm_alert(1, rinfo.rs_frstr[ALDRVFORMAT], altitle, 1, 0L);
					return;
				}
				start = (*p & ~32) - 'A';
				temp.drvbits |= 1L << (long) start;
			} else if (*p == ',') {
				if (start == -1)
					goto dfg_parseerr;
				start = -1;
			} else if (*p == '-') {
				if (!isalpha(*++p) || (start == -1))
					goto dfg_parseerr;
				end = (*p & ~32) - 'A';
				if (end < start)
					goto dfg_parseerr;
				for (i = start + 1; i <= end; i++)
					temp.drvbits |= 1L << (long) i;
			}
			p++;
		}
	}
	temp.follow = isObjectSelected(objectTree, FFOLLOW);
	temp.fm_case = isObjectSelected(objectTree, FFCASE);
	temp.fm_dirs = isObjectSelected(objectTree, FDIRS);

	/* check filemask */
	temp.filemask = fmask;
	p = getObjectText(objectTree, FFMASK);
	if (!*p)
		strcpy(fmask, "*");
	else
		strcpy(fmask, p);

	/* check date */
	temp.datecheck = isObjectSelected(objectTree, FTIME);
	if (temp.datecheck) {
		p = getObjectText(objectTree, FFROMDATE);
		if (!*p)
			temp.mindate = 0;
		else {
			temp.mindate = parse_date(p);
			if (temp.mindate == 0xffffU) {
				frm_alert(1, rinfo.rs_frstr[ALFROMDATE], altitle, 1, 0L);
				return;
			}
		}
		p = getObjectText(objectTree, FTODATE);
		if (!*p)
			temp.maxdate = 0xffffU;
		else {
			temp.maxdate = parse_date(p);
			if (temp.maxdate == 0xffffU) {
				frm_alert(1, rinfo.rs_frstr[ALTODATE], altitle, 1, 0L);
				return;
			}
		}
		if (temp.mindate > temp.maxdate) {
			frm_alert(1, rinfo.rs_frstr[ALDATEORDER], altitle, 1, 0L);
			return;
		}
	} else {
		temp.mindate = 0;
		temp.maxdate = 0xffffU;
	}

	/* check size */
	temp.sizecheck = isObjectSelected(objectTree, FSIZE);
	if (temp.sizecheck) {
		p = getObjectText(objectTree, FFROMSIZE);
		if (!*p)
			temp.minsize = 0L;
		else {
			size = strtod(p, NULL);
			if ((size < 0.0) || (size > 2147483647.0)) {
				frm_alert(1, rinfo.rs_frstr[ALFROMSIZE], altitle, 1, 0L);
				return;
			}
			temp.minsize = size;
		}
		p = getObjectText(objectTree, FTOSIZE);
		if (!*p)
			temp.maxsize = 0x7fffffffL;
		else {
			size = strtod(p, NULL);
			if ((size < 0.0) || (size > 2147483647.0)) {
				frm_alert(1, rinfo.rs_frstr[ALTOSIZE], altitle, 1, 0L);
				return;
			}
			temp.maxsize = size;
		}
		if (temp.minsize > temp.maxsize) {
			frm_alert(1, rinfo.rs_frstr[ALSIZEORDER], altitle, 1, 0L);
			return;
		}
	} else {
		temp.minsize = 0L;
		temp.maxsize = 0x7fffffffL;
	}
	fprintf(stderr, "5 ");
	temp.grep = isObjectSelected(objectTree, FCONTENTS);
	temp.cm_case = isObjectSelected(objectTree, FCCASE);
	temp.cm_binary = isObjectSelected(objectTree, FCBINARY);
	if (temp.grep) {
		p = getObjectText(objectTree, FCMASK);
		if (!*p) {
			frm_alert(1, rinfo.rs_frstr[ALEMPTYCMASK], altitle, 1, 0L);
			return;
		}
		if (temp.cm_binary)
			strcpy(cmask, p);
		else {
			strcpy(cmask, "");
			if (*p != '^') {
				if (*p != '*')
					strcpy(cmask, "*");
				else
					strcpy(cmask, "");
				strcat(cmask, p);
			} else
				strcpy(cmask, p + 1);
			p = strrchr(cmask, 0) - 1;
			if (p >= cmask) {
				if (*p != '$') {
					if (*p != '*')
						strcat(cmask, "*");
				} else
					*p = 0;
			}
		}
		temp.contentmask = cmask;
	} else
		temp.contentmask = NULL;

	temp.verbose = isObjectSelected(objectTree, FVERBOSE);
	if ((err = Fopen(glob.tname, 0)) < 0L) {
		sprintf(almsg, rinfo.rs_frstr[ALNOTEMPLATE], FNAME_TPL);
		frm_alert(1, almsg, altitle, 1, 0L);
		return;
	}
	Fclose((short) err);
	find = temp;
	s_tree = fi_status.tree;

	setObjectText(s_tree, SCURRENT, 0);
	setObjectText(s_tree, SHITS, "0");

	if (find.verbose)
		setObjectFlags(s_tree, SCBOX, HIDETREE, FALSE);
	else
		setObjectFlags(s_tree, SCBOX, HIDETREE, TRUE);
	frm_start(&fi_status, 1, 1, 1);
	if (fi_status.state == FST_WIN)
		frm_redraw(&fi_status, ROOT);
	graf_mouse(BUSYBEE, 0L);
	lasthits = 0L;
	ok = search_main(find.drvbits, find.drvbits ? NULL : find.searchpath,
			find.follow, find.filemask, find.fm_case, find.fm_dirs,
			find.mindate, find.maxdate, find.minsize, find.maxsize,
			find.contentmask, find.cm_case, find.cm_binary, search_update,
			glob.rname, glob.tname);
	graf_mouse(ARROW, 0L);
	frm_end(&fi_status);
	if (ok) {
		frm_alert(1, rinfo.rs_frstr[ALFAILURE], altitle, 1, 0L);
	} else {
		if (glob.tid >= 0) {
			strcpy(aesBuffer, glob.rname);
			appl_send(glob.tid, AV_STARTPROG, PT34, (long) aesBuffer, 0L, 0L, 0L, 0L);
		} else
			frm_alert(1, rinfo.rs_frstr[ALNOTHING], altitle, 1, 0L);
	}
}

/**
 * de_find
 *
 * Callback-Funktion zur Reaktion auf Ereignisse im Suchen-Dialog.
 *
 * Eingabe:
 * mode: Dialog wird geschlossen (1) oder anderes Dialogereignis (0)
 * ret: Rueckgabewert von frm_do(), zu bearbeitendes Objekt (wie bei
 *      form_do())
 */
void de_find(short mode, short ret) {
	OBJECT *objectTree;
	short done, exitObject, edob, oldpage, go_disabled;
	char searchpath[MAX_PLEN];

	UNUSED(ret);

	objectTree = fi_find.tree;
	done = 0;
	oldpage = find.page;

	if (!mode) {
		exitObject = fi_find.exit_obj;
		go_disabled = isObjectDisabled(objectTree, FGO);
		switch (exitObject) {
		case FGENERAL:
			find.page = 0;
			break;
		case FATTR:
			find.page = 1;
			break;
		case FON:
			setObjectState(objectTree, FGO, DISABLED, !objectTree[FDRIVES].ob_spec.tedinfo->te_ptext[0]);
			frm_gotoedit(&fi_find, FDRIVES);
			break;
		case FDRIVES:
			if (isObjectSelected(objectTree, FON))
				setObjectState(objectTree, FGO, DISABLED, !objectTree[exitObject].ob_spec.tedinfo->te_ptext[0]);
			break;
		case FIN:
			setObjectState(objectTree, FGO, DISABLED, !*find.searchpath);
			break;
		case FPATHS:
			strcpy(searchpath, find.searchpath);
			if (full_fselect(searchpath, NULL, "*.*", 1, rinfo.rs_frstr[TXCHOOSEPATH], 0, 0, &fi_find)) {
				strcpy(find.searchpath, searchpath);
				strShortener(objectTree[FPATH].ob_spec.tedinfo->te_ptext, find.searchpath, 36);
				frm_redraw(&fi_find, FPATH);
				if (!isObjectSelected(objectTree, FIN)) {
					unsetObjectSelected(objectTree, FON);
					setObjectSelected(objectTree, FIN);
					frm_redraw(&fi_find, FON);
					frm_redraw(&fi_find, FIN);
				}
				setObjectState(objectTree, FGO, DISABLED, !*find.searchpath);
			}
			frm_norm(&fi_find);
			break;
		case FTIME:
			if (isObjectSelected(objectTree, FTIME)) {
				if (fi_find.edit_obj != FTODATE)
					frm_gotoedit(&fi_find, FFROMDATE);
			}
			break;
		case FSIZE:
			if (getObjectState(objectTree, FSIZE, SELECTED)) {
				if (fi_find.edit_obj != FTOSIZE)
					frm_gotoedit(&fi_find, FFROMSIZE);
			}
			break;
		case FCONTENTS:
			if (getObjectState(objectTree, FCONTENTS, SELECTED))
				frm_gotoedit(&fi_find, FCMASK);
			break;
		case FGO:
			de_find_go(objectTree);
			frm_norm(&fi_find);
			break;
		case FCANCEL:
			done = FCANCEL;
			break;
		}
		if (go_disabled != isObjectDisabled(objectTree, FGO)) {
			setObjectFlags(objectTree, FGO, DEFAULT, go_disabled);
			frm_redraw(&fi_find, FGOBOX);
		}
	} else
		done = glob.done = 1;

	/* Bei Bedarf Seite umschalten */
	if (find.page != oldpage) {
		frm_gotoedit(&fi_find, 0);
		find_setpage(find.page);
		edob = fi_find.edit_obj;
		fi_find.edit_obj = 0;
		frm_gotoedit(&fi_find, edob);
		frm_redraw(&fi_find, getActiveCardBodyIdx(mainCard));
		mevent.ev_mwich = MU_M1;
		frm_do(&fi_find, &mevent);
	}

	/* Ggf. Dialog schliessen */
	if (done) {
		if (done == FCANCEL)
			glob.done = 1;
		if (done != -1)
			frm_norm(&fi_find);
		if (fi_find.state == FST_WIN)
			avcWindowClose(glob.avid, fi_find.win.handle);
		frm_end(&fi_find);
	}
}

/**
 * drag_on_window
 *
 * Behandelt Drag&Drop auf ein Fenster von ThingFnd.
 *
 * Eingabe:
 * handle: Handle des betroffenen Fensters
 * mx: x-Position der Maus
 * my: y-Position der Maus
 * buf: Liste der erhaltenen Filenamen, durch Leerzeichen getrennt
 *      und ggf. gequotet
 */
void drag_on_window(short handle, short mx, short my, char *buf) {
	UNUSED(handle);
	UNUSED(mx);
	UNUSED(my);
	UNUSED(buf);
}

/**
 * Verarbeiten einer Menueauswahl
 * Wird auch von handle_key() bei Shortcuts aufgerufen
 *
 * @param title
 * @param item
 * @param ks
 */
void handle_menu(short title, short item, short ks) {
	BOOLEAN stguide;
	OBJECT *objectTree;

	objectTree = rinfo.rs_trindex[MAINMENU];
	if (isObjectDisabled(objectTree, item) || isObjectDisabled(objectTree, title)) {
		return;
	}

	mn_tnormal(objectTree, title, 0);
	mn_disable();
	mn_tnormal(objectTree, title, 1);

	/* Hilfetext anzeigen, falls [Control] gedrueckt */
	if (ks & K_CTRL) {
		switch (item) {
		case MABOUT:
			stguide = showSTGuideHelp(STGUIDEHELPFILE, "%I");
			break;
		case MNEXTWIN:
			stguide = showSTGuideHelp(STGUIDEHELPFILE, "%mnwin");
			break;
		case MQUIT:
			stguide = showSTGuideHelp(STGUIDEHELPFILE, "%mquit");
			break;
		default:
			stguide = showSTGuideHelp(STGUIDEHELPFILE, "%I");
			break;
		}
		if (!stguide)
			frm_alert(1, rinfo.rs_frstr[ALNOGUIDE], altitle, 1, 0L);
	} else {
		switch (item) {
		case MABOUT:
			fi_about.init();
			break;
		case MNEXTWIN:
			dl_nextwin();
			break;
		case MQUIT:
			dl_quit();
			break;
		}
	}
	mn_tnormal(objectTree, title, 1);
	mn_update();
}

/**
 * Verarbeiten von Fensterereignissen
 *
 * @param handle
 * @param msg
 * @param f1
 * @param f2
 * @param f3
 * @param f4
 * @param ks
 */
void handle_win(short handle, short msg, short f1, short f2, short f3, short f4, short ks) {
	WININFO *win;
	FORMINFO *fi;
	short top;
	short owner;
	short d;

	UNUSED(ks);

	win = win_getwinfo(handle);
	if (!win)
		return;

	fi = 0L;
	switch (win->class) {
	case WCDIAL:
		fi = (FORMINFO *) win->user;
		break;
	}

	switch (msg) {
	case WM_ICONIFY:
		win_icon(win, f1, f2, f3, f4);
		mn_update();
		break;

	case WM_UNICONIFY:
		win_unicon(win, f1, f2, f3, f4);
		mn_update();
		break;

	case WM_ALLICONIFY:
		mybeep();
		break;

	case WM_M_BDROPPED: /* MagiC 2.0 */
	case WM_BOTTOMED: /* WINX */
		if (!tb.alwin || (win != tb.alwin)) {
			wind_set(win->handle, WF_BOTTOM, 0, 0, 0, 0);
			get_twin(&top);
			tb.topwin = win_getwinfo(top);
			win_newtop(tb.topwin);
			mn_update();

			/* Workaround fuer MagiC */
			if (tb.sys & SY_MAGX && !tb.topwin) {
				if (wind_get(top, WF_OWNER, &owner, &d, &d, &d))
					magx_switch(owner, 0);
			}
		}
		break;

	case WM_UNTOPPED:
		get_twin(&top);
		tb.topwin = win_getwinfo(top);
		if (tb.topwin != win) {
			win_newtop(tb.topwin);
			mn_update();
		}
		break;

	case WM_REDRAW:
		win_redraw(win, f1, f2, f3, f4);
		/*
		 * Workaround fuer Einblenden bei N.AES, das in diesem
		 * Fall kein WM_ONTOP verschickt ...
		 */
		get_twin(&top);
		if (top == handle) {
			win = win_getwinfo(top);
			if (tb.topwin != win) {
				tb.topwin = win;
				win_newtop(win);
				mn_update();
			}
		}
		break;

	case WM_NEWTOP:
	case WM_ONTOP:
		win_newtop(win);
		/* 	  magx_switch(tb.app_id, 0); */
		mn_update();
		break;

	case WM_TOPPED:
		win_top(win);
		magx_switch(tb.app_id, 0);
		mn_update();
		break;

	case WM_CLOSED:
		if (tb.sm_alert) {
			/* Alert offen? - dann geht kein Close! */
			mybeep();
			if (tb.alwin)
				win_top(tb.alwin);
		} else {
			switch (win->class) {
			case WCDIAL:
				fi->exit(1, 0);
				break;
			}
			mn_update();
		}
		break;

	case WM_FULLED:
		win_full(win);
		break;

	case WM_ARROWED:
		switch (f1) {
		case WA_UPPAGE:
			win_slide(win, S_REL, 0, -2);
			break;

		case WA_DNPAGE:
			win_slide(win, S_REL, 0, 2);
			break;

		case WA_UPLINE:
			win_slide(win, S_REL, 0, -1);
			break;

		case WA_DNLINE:
			win_slide(win, S_REL, 0, 1);
			break;

		case WA_LFPAGE:
			win_slide(win, S_REL, -2, 0);
			break;

		case WA_RTPAGE:
			win_slide(win, S_REL, 2, 0);
			break;

		case WA_LFLINE:
			win_slide(win, S_REL, -1, 0);
			break;

		case WA_RTLINE:
			win_slide(win, S_REL, 1, 0);
			break;
		}
		break;

	case WM_HSLID:
		win_slide(win, S_ABS, f1, -1);
		break;

	case WM_VSLID:
		win_slide(win, S_ABS, -1, f1);
		break;

	case WM_SIZED:
		if (f3 > win->full.g_w)
			f3 = win->full.g_w;
		if (f4 > win->full.g_h)
			f4 = win->full.g_h;
		win_size(win, f1, f2, f3, f4);
		break;

	case WM_MOVED:
		win_size(win, f1, f2, f3, f4);
		break;
	}
}

/**
 * Verarbeiten von Mausklicks
 *
 * @param mx
 * @param my
 * @param but
 * @param ks
 * @param br
 */
void handle_button(short mx, short my, short but, short ks, short br) {
	UNUSED(mx);
	UNUSED(my);
	UNUSED(but);
	UNUSED(ks);
	UNUSED(br);
}

/**
 * Verarbeiten von Tastatureingaben
 *
 * @param ks
 * @param kr
 */
void handle_key(short ks, short kr) {
	unsigned short key;
	short title, item, skey;

	key = normkey(ks, kr);
	key &= ~(NKF_CAPS | NKF_RESVD); /* Nicht benoetigte Flags ausmaskieren */
	if (key & NKF_LSH || key & NKF_RSH)
		key |= NKF_SHIFT; /* Shift-Status */

	/* Pruefen, ob Menue-Shortcut vorliegt */
	if (menu_key(rinfo.rs_trindex[MAINMENU], key, &title, &item)) {
		/* Shortcut vorhanden, Menuehandling ausfuehren */
		handle_menu(title, item, 0);
	} else {
		/* Kein Shortcut, normale Verarbeitung */
		skey = 0; /* Flag fuer AV_SENDKEY */
		if (key == (NKF_FUNC | NK_HELP)) {
			if (!tb.topfi) {
				if (!showSTGuideHelp(STGUIDEHELPFILE, "%I"))
					frm_alert(1, rinfo.rs_frstr[ALNOGUIDE], altitle, 1, 0L);
			}
		} else
			skey = 1;
		if (skey) {
			/* Ggf. AV_SENDKEY */
			if (glob.avid >= 0 && (glob.avflags & 0x0001))
				appl_send(glob.avid, AV_SENDKEY, 0, ks, kr, 0, 0, 0);
		}
	}
}

/**
 * Wird von der GEM-Toolbox fuer die Bearbeitung einer unbekannten
 * AES-Message waehrend eines modalen Fensterdialogs aufgerufen.
 *
 * @param *mevent
 * @param *fi
 */
void handle_fmsg(EVENT *mevent, FORMINFO *fi) {
	aesmsg[1] = tb.app_id;
	aesmsg[2] = 0;
	aesmsg[3] = 0;
	aesmsg[4] = 0;
	aesmsg[5] = 0;
	aesmsg[6] = 0;
	aesmsg[7] = 0;

	if (mevent->ev_mwich & MU_MESAG) {
		switch (mevent->ev_mmgpbuf[0]) {
		case WM_REDRAW:
		case WM_TOPPED:
		case WM_FULLED:
		case WM_ARROWED:
		case WM_HSLID:
		case WM_VSLID:
		case WM_SIZED:
		case WM_MOVED:
		case WM_NEWTOP:
		case WM_ONTOP:
			handle_win(mevent->ev_mmgpbuf[3], mevent->ev_mmgpbuf[0],
					mevent->ev_mmgpbuf[4], mevent->ev_mmgpbuf[5],
					mevent->ev_mmgpbuf[6], mevent->ev_mmgpbuf[7],
					mevent->ev_mmokstate);
			break;

		case AP_TERM: /* Shutdown */
			/* Non-modale Dialoge auf? */
			if (tb.sm_nowdial > 0) {
				aesmsg[0] = AP_TFAIL;
				aesmsg[1] = 1;
				aesmsg[2] = 0;
				aesmsg[3] = 0;
				aesmsg[4] = 0;
				aesmsg[5] = 0;
				aesmsg[6] = 0;
				aesmsg[7] = 0;
				shel_write(SHW_AESSEND, 0, 0, (char *) aesmsg, 0L);
				frm_alert(1, rinfo.rs_frstr[ALNOSHUT], altitle, 1, 0L);
			} else {
				/* Nein - alles klar */
				glob.done = 1;
			}

		case MN_SELECTED:
			mn_tnormal(rinfo.rs_trindex[MAINMENU], mevent->ev_mmgpbuf[3], mevent->ev_mmgpbuf[4]);
			frm_alert(1, rinfo.rs_frstr[ALWDIAL], altitle, 1, 0L);
			break;

		case AP_DRAGDROP:
			ddnak(mevent);
			break;

		case VA_START:
			magx_switch(tb.app_id, 0);
			fi_find.init();
			break;
		}
	}

	if (mevent->ev_mwich & MU_KEYBD && fi) {
		if (fi->normkey == (NKF_FUNC | NK_HELP) && fi->userinfo) {
			if (fi->state == FST_WIN) {
				if (!showSTGuideHelp(STGUIDEHELPFILE, fi->userinfo))
					frm_alert(1, rinfo.rs_frstr[ALNOGUIDE], altitle, 1, 0L);
			} else
				frm_alert(1, rinfo.rs_frstr[ALNOWDIAL], altitle, 1, 0L);
		}
	}
}

/**
 * get_buf_entry
 *
 * Ermittelt den naechsten Filenamen aus einem Puffer, dessen Eintraege
 * durch Leerzeichen getrennt und ggf. von Quotes (') umschlossen
 * sind. Der ermittelte Filename enthaelt keine Quotes mehr.
 *
 * Eingabe:
 * buf: Zeiger auf den Puffer, muž bzw. darf nur beim ersten Aufruf
 *      fuer buf angegeben werden, danach muž fuer buf ein Nullzeiger
 *      uebergeben werden, damit get_buf_entry den naechsten Eintrag
 *      ermitteln kann
 * name: Hierhin wird der naechste Filename kopiert. Da dieser mit
 *       komplettem Pfad versehen sein kann, sollte name ausreichend
 *       Platz bieten.
 * newpos: Wenn ungleich NULL, wird hier der Zeiger auf die naechste
 *         Leseposition abgelegt, so dass man get_buf_entry auch
 *         wechselseitig mit zwei oder mehr Puffern verwenden kann.
 *         Der Wert wird nur gesetzt, wenn ein Eintrag gelesen werden
 *         konnte, der Returncode also 1 ist.
 *
 * Rueckgabe:
 * 0: Kein weiterer (gueltiger) Filename mehr in buf (ein Filename ist
 *    z.B. ungueltig, wenn er falsch gequotet wurde)
 * 1: name enthaelt den naechsten Filenamen
 */
short get_buf_entry(char *buf, char *name, char **newpos) {
	static char *bufpos;
	char *pos;
	short closed;

	if (buf != 0L)
		pos = buf;
	else
		pos = bufpos;

	/* Eventuell war der letzte Filename ungueltig, dann abbrechen */
	if (pos == 0L)
		return (0);

	/* Erstmal fuehrende Leerzeichen ueberlesen */
	for (; *pos == ' '; pos++)
		;
	/* Gibt es ueberhaupt noch einen Filenamen? */
	if (!*pos)
		return (0);

	if (*pos != '\'') {
		/*
		 * Wenn der Filename nicht mit einem Quote beginnt, bis zum naechsten
		 * Leerzeichen kopieren
		 */
		for (; *pos && (*pos != ' '); *name++ = *pos++)
			;
	} else {
		/* Sonst den Filenamen "entquoten" */
		closed = 0;
		for (pos++;;) {
			/* Bei einem Nullbyte abbrechen (gibt ungueltigen Filenamen) */
			if (!*pos)
				break;
			if (*pos == '\'') {
				/*
				 * Ist das aktuelle Zeichen ein Quote, gibt es folgende Faelle zu
				 * unterscheiden:
				 * 1. Danach folgt ein Leerzeichen oder das Bufferende, dann ist der
				 *    Filename an dieser Stelle korrekt beendet
				 * 2. Es folgt ein weiteres Quotezeichen, dann wird ein einzelnes
				 *    Quotezeichen in den Zielfilenamen eingetragen
				 * 3. Es folgt ein anderes Zeichen, dann ist der Filename im Puffer
				 *    nicht korrekt gequotet und das Auswerten wird abgebrochen
				 */
				if ((pos[1] == 0) || (pos[1] == ' ')) {
					closed = 1;
					pos++;
					break;
				}
				if (pos[1] != '\'')
					break;
				else
					pos++;
			}
			*name++ = *pos++;
		}
		if (!closed) {
			bufpos = 0L;
			return (0);
		}
	}
	/*
	 * Den Filenamen mit einem Nullbyte abschliessen und die Position im
	 * Puffer fuer den naechsten Aufruf merken
	 */
	*name = 0;
	bufpos = pos;
	if (newpos != 0L)
		*newpos = pos;
	return 1;
}

/**
 * Programminitialisierung
 *
 * @return
 */
BOOLEAN main_init(void) {
	short i, l, x, y, w, h;
	char *p, aname[9], rsrcName[13];
	OBJECT *objectTree;

	/* MiNT-Domain aktivieren */
	Pdomain(1);

	/* Einige MiNT-Signal-Handler installieren */
	Psignal(SIGINT, 1L);
	Psignal(SIGSYS, 1L);
	Psignal(SIGABRT, 1L);
	Psignal(SIGTERM, (long) sigTerm);
	Psignal(SIGQUIT, 1L);
	Psignal(SIGHUP, 1L);

	aesBuffer = 0L;
	aesapname = 0L;
	glob.menu = 0;
	glob.avid = -1;
	glob.tid = -1;
	glob.avflags = 0;
	rinfo.load_magic = 0;

	/* Toolbox und Speicherverwaltung initialisieren */
#ifdef USE_PMALLOC
	pminit();
#endif
	if (!tool_init("thingfnd.app"))
		return (FALSE);

	if (!init_cicon())
		return (FALSE);

	/* Startverzeichnis mit abschliessendem '\' versehen */
	l = (short) strlen(tb.homepath) - 1;
	if ((l > 0) && (tb.homepath[l] != '\\'))
		strcat(tb.homepath, "\\");

	strcpy(glob.tname, tb.homepath);
	strcpy(glob.rname, glob.tname);
	strcat(glob.tname, FNAME_TPL);
	strcat(glob.rname, FNAME_RES);

	/* Eintrag im Desk-Menue */
	if (tb.sys & SY_MTOS)
		menu_register(tb.app_id, "  Thing Find ");

	if (glob.use3d == 0)
		set3dLook(FALSE);

	/* Alice austricksen ;-) */
	i = wind_create(NAME | MOVER | CLOSER | FULLER | ICONIFIER, tb.desk.g_x, tb.desk.g_y, 10, 10);
	if (i >= 0)
		wind_delete(i);

	tb.msg_handler = handle_fmsg;

	/* Resource laden */
	sprintf(rsrcName, "%s%s\\thgfnd\\%s.rsc", tb.homepath, PNAME_RSC, tb.sysLanguageCodeLong);
	if (!rsc_load(rsrcName, &rinfo)) {
		sprintf(rsrcName, "%s%s\\thgfnd\\english.rsc", tb.homepath, PNAME_RSC);
		if (!rsc_load(rsrcName, &rinfo)) {
			frm_alert(1, "[3][THINGFND.RSC nicht gefunden!|THINGFND.RSC not found!][ OK ]", altitle, 1, 0L);
			return (FALSE);
		}
	}
	for (i = 0; i < NUM_TREE; i++) {
		if (i == MAINMENU)
			rs_fix(rinfo.rs_trindex[i], 0, 0);
		else
			rs_fix(rinfo.rs_trindex[i], 8, 16);
		rs_textadjust(rinfo.rs_trindex[i], (glob.use3d && (tb.colors >= 16)) ? getBackgroundColor() : G_WHITE);
	}
	tb.ictree = rinfo.rs_trindex[ICONWIN];
	tb.ictreed = rinfo.rs_trindex[ICONDIAL];
	sprintf(rinfo.rs_trindex[ABOUT][ABVER].ob_spec.tedinfo->te_ptext, "Version %s (%s)", VERSION, __DATE__);

	/* AV-Buffer reservieren */
	if (tb.sys & SY_XALLOC)
		aesapname = Mxalloc(9 + MAX_AVLEN, 0x23);
	else
		aesapname = Malloc(9 + MAX_AVLEN);
	/* Bei Fehler raus */
	if (!aesapname) {
		frm_alert(1, rinfo.rs_frstr[ALNOMEM], altitle, 1, 0L);
		return (FALSE);
	}
	aesBuffer = &aesapname[9];
	/* Sonst initialisieren */
	strcpy(aesapname, "THINGFND");

	tb.use3d = glob.use3d; /* 3D-Effekte */
	tb.backwin = glob.backwin; /* MagiC-Fensterworkround */

	/* ThingFnd-Logo anpassen */
	objectTree = rinfo.rs_trindex[ABOUT];
	objectTree[ABLOGOHI].ob_x = (objectTree->ob_width - objectTree[ABLOGOHI].ob_spec.bitblk->bi_wb * 8) / 2;
	objectTree[ABLOGOLO].ob_x = (objectTree->ob_width - objectTree[ABLOGOLO].ob_spec.bitblk->bi_wb * 8) / 2;
	if (tb.ch_h < 12) {
		setObjectFlags(objectTree, ABLOGOHI, HIDETREE, TRUE);
		setObjectFlags(objectTree, ABLOGOLO, HIDETREE, FALSE);
	} else {
		l = objectTree[ABLOGOHI].ob_spec.bitblk->bi_hl - objectTree[ABLOGOHI].ob_height + 4;
		objectTree->ob_height += l;
		for (i = 4; !(objectTree[i].ob_flags & LASTOB); i++)
			objectTree[i].ob_y += l;
	}

	/* Icons fuer ikon. Fenster anpassen */
	rinfo.rs_trindex[ICONWIN][1].ob_width = 64;
	rinfo.rs_trindex[ICONWIN][1].ob_height = 32;
	rinfo.rs_trindex[ICONDIAL][1].ob_width = 72;
	rinfo.rs_trindex[ICONDIAL][1].ob_height = 40;
	rinfo.rs_trindex[ICONGRP][1].ob_width = 72;
	rinfo.rs_trindex[ICONGRP][1].ob_height = 40;

	/* Userdefs erzeugen */
	setUserdefs(rinfo.rs_trindex[0], TRUE);
	for (i = 1; i < NUM_TREE; i++) {
		setUserdefs(rinfo.rs_trindex[i], FALSE);

		/* Dialogboxen zentrieren */
		form_center(rinfo.rs_trindex[i], &x, &y, &w, &h);
	}
	setBackgroundBorder(FALSE);

	/* Dialoge initialisieren */
	fi_about.tree = rinfo.rs_trindex[ABOUT];
	fi_about.init = di_about;
	fi_about.exit = de_about;
	fi_find.tree = rinfo.rs_trindex[FIND];
	fi_find.init = di_find;
	fi_find.exit = de_find;
	fi_status.tree = rinfo.rs_trindex[STATUS];

	/* Die einzelnen Karteikarten des Suchdialogs zusammenhaengen. */
	cardAdd(&mainCard, rinfo.rs_trindex[FIND], FGENERAL, FSGENERAL);
	cardAdd(&mainCard, rinfo.rs_trindex[FIND], FATTR, FSATTR);

	/* Handler fuer modale Dialoge */
	tb.modal_on = mn_disable;
	tb.modal_off = mn_update;

	/* Anmelden beim AV-Server und ermitteln der Thing-AES-ID */
	if (tb.sys & SY_MULTI) {
		p = getenv("AVSERVER");
		if (p) {
			i = 0;
			aname[8] = 0;
			while (i < 8 && p[i]) {
				aname[i] = nkc_toupper(p[i]);
				i++;
			}
			while (i < 8) {
				aname[i] = ' ';
				i++;
			}
			glob.avid = appl_find(aname);
			if (glob.avid >= 0) {
				appl_send(glob.avid, AV_PROTOKOLL, PT67, 18, 0, 0, (long) aesapname, 0);
			}
		}
		glob.tid = appl_find("THING   ");
	}

	/* Menue etc. */
	wind_update(BEG_UPDATE);
	menu_bar(rinfo.rs_trindex[MAINMENU], 1);
	mn_disable();
	graf_mouse(ARROW, 0L);
	glob.menu = 1;
	wind_update(END_UPDATE);
	fi_find.init();

	return (TRUE);
}

/**
 * Hauptschleife des Programms
 */
void main_loop(void) {
	short top, *msg, evdone, ret;

	glob.done = 0;
	graf_mkstate(&mevent.ev_mm1x, &mevent.ev_mm1y, &mevent.ev_mmokstate, &mevent.ev_mbreturn);
	mn_update();
	while (!glob.done) {
		mevent.ev_mbclicks = 258;
		mevent.ev_bmask = 3;
		mevent.ev_mbstate = 0;
		mevent.ev_mm1flags = 1;
		mevent.ev_mm1width = 1;
		mevent.ev_mm1height = 1;
		mevent.ev_mflags = MU_KEYBD | MU_BUTTON | MU_MESAG;
		if (tb.fi)
			mevent.ev_mflags |= MU_M1;
		EvntMulti(&mevent); /* Message abwarten */
		msg = mevent.ev_mmgpbuf;
		mevent.ev_mm1x = mevent.ev_mmox;
		mevent.ev_mm1y = mevent.ev_mmoy;

		/*
		 * Bei Bedarf vor der Message-Auswertung Aenderung des aktiven
		 * Fenster beruecksichtigen
		 */
		if (!(tb.sys & SY_MULTI || tb.sys & SY_WINX)) {
			get_twin(&top);

			/* Falls aktives Fenster sich geaendert hat, dann Menues updaten */
			if (tb.topwin) {
				/* Bisher aktives Fenster vorhanden */
				if (!top) {
					/* Kein Fenster mehr aktiv */
					tb.topwin = 0L;
					tb.topfi = 0L;
					mn_update();
				} else {
					/* Fenster aktiv */
					if (top != tb.topwin->handle) {
						/* Anderes als bisher */
						tb.topwin = win_getwinfo(top);
						mn_update();
					}
				}
			} else {
				/* Bisher kein Fenster aktiv */
				if (top) {
					/* Aber jetzt ist eins aktiv */
					tb.topwin = win_getwinfo(top);
					mn_update();
				}
			}
			win_newtop(tb.topwin);
		}

		/* AES-Message */
		if (mevent.ev_mwich & MU_MESAG) {
			switch (msg[0]) {
			/* Shutdown */
			case AP_TERM:
				glob.done = 1;
				break;
				/* Diverse... */
			case AP_DRAGDROP:
				ddnak(&mevent);
				break;
			case VA_DRAGACCWIND:
				drag_on_window(msg[3], msg[4], msg[5], (char *) int2long(&msg[6], &msg[7]));
				break;
			case VA_START:
				mybeep();
				magx_switch(tb.app_id, 0);
				break;
				/* Menueauswahl */
			case MN_SELECTED:
				handle_menu(msg[3], msg[4], mevent.ev_mmokstate);
				break;
				/* AV-Protokoll */
			case VA_PROTOSTATUS:
				glob.avflags = msg[3];
				break;
				/* Fensteraktionen */
			case WM_ICONIFY:
			case WM_UNICONIFY:
			case WM_ALLICONIFY:
			case WM_M_BDROPPED:
			case WM_BOTTOMED:
			case WM_UNTOPPED:
			case WM_REDRAW:
			case WM_NEWTOP:
			case WM_ONTOP:
			case WM_TOPPED:
			case WM_CLOSED:
			case WM_FULLED:
			case WM_ARROWED:
			case WM_HSLID:
			case WM_VSLID:
			case WM_SIZED:
			case WM_MOVED:
				handle_win(msg[3], msg[0], msg[4], msg[5], msg[6], msg[7], mevent.ev_mmokstate);
				break;
			}
		}

		/* Falls Dialog aktiv, dann Dialoghandler aufrufen */
		if (tb.topfi) {
			evdone = 0;
			ret = frm_do(tb.topfi, &mevent);
			if (!tb.topfi->cont) {
				/* HELP-Button? */
				if ((tb.topfi->help_obj != -1) && (tb.topfi->exit_obj == tb.topfi->help_obj)) {
					if (!showSTGuideHelp(STGUIDEHELPFILE, tb.topfi->userinfo))
						frm_alert(1, rinfo.rs_frstr[ALNOGUIDE], altitle, 1, 0L);
					frm_norm(tb.topfi);
					evdone = 1;
				} else {
					tb.topfi->exit(0, ret);
					evdone = 1;
				}
			}
			if (evdone)
				mn_update();
		} else
			evdone = 0;

		/* Jetzt die vom Handler uebriggelassenen Events bearbeiten */
		if (!evdone && !tb.sm_nowdial) {
			/* Tastatur */
			if (mevent.ev_mwich & MU_KEYBD)
				handle_key(mevent.ev_mmokstate, mevent.ev_mkreturn);

			/* Maustaste */
			if (mevent.ev_mwich & MU_BUTTON)
				handle_button(mevent.ev_mmox, mevent.ev_mmoy, mevent.ev_mmobutton, mevent.ev_mmokstate, mevent.ev_mbreturn);
		}
	}
}

/**
 * Programmdeinitialisierung
 */
void main_exit(void) {
	short i;
	FORMINFO *fi, *fi1;

	/* Offene Dialoge schliessen */
	fi = tb.fi;
	while (fi) {
		fi1 = fi->next;
		fi->exit(1, 0);
		fi = fi1;
	}

	/* Beim AV-Server abmelden */
	if (glob.avid != -1)
		appl_send(glob.avid, AV_EXIT, 0, tb.app_id, 0, 0, 0, 0);

	/* Sonstige Aufraeumarbeiten */
	if (glob.menu)
		menu_bar(rinfo.rs_trindex[MAINMENU], 0);

	/* Karteikarten freigeben. */
	cardRemoveAll(mainCard);

	/* Userdefs entfernen */
	unsetUserdefs(rinfo.rs_trindex[0]);
	for (i = 1; i < NUM_TREE; i++)
		unsetUserdefs(rinfo.rs_trindex[i]);

	if (aesapname)
		Mfree(aesapname);

	rsc_free(&rinfo);

	/* cleanup of Thing Toolbox stuff */
	exit_cicon();
	tool_exit();
}

/*------------------------------------------------------------------*/
/*  main routine                                                    */
/*------------------------------------------------------------------*/
main(short argc, char *argv[]) {
	short i;
	char *p;

	glob.use3d = 1;
	glob.backwin = 0;

	memset(&find, 0, sizeof(FIND_DATA));
	find.mindate = find.maxdate = 0xffffU;
	find.minsize = find.maxsize = -1L;
	if (argc > 1) {
		for (i = 1; i < argc; i++) {
			if (argv[i][0] == '-') {
				for (p = argv[i] + 1; *p; p++) {
					switch (*p) {
					case 'v':
						find.verbose = 1;
						break;
					case 'c':
						find.fm_case = 1;
						break;
					case 'd':
						find.fm_dirs = 1;
						break;
					case 'l':
						find.follow = 1;
						break;
					}
				}
			} else if (wild_match(argv[i], "[A-Za-z]:\\\\")) {
				/* Laufwerk */
				find.drvbits |= 1L << (long) ((argv[i][0] & ~32) - 'A');
			} else if (wild_match(argv[i], "[A-Za-z]:\\\\?*\\\\")) {
				/* Ordner */
				if (!*find.searchpath && (strlen(argv[i]) < (MAX_PLEN - 1)))
					strcpy(find.searchpath, argv[i]);
			}
		}
	}

	if (main_init())
		main_loop();

	main_exit();
	return (0);
}

/* EOF */
