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

#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <time.h>
#include <math.h>
#include <assert.h>
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
#include "..\include\proto.h"
#include <dudolib.h>

/*------------------------------------------------------------------*/
/*  global functions                                                */
/*------------------------------------------------------------------*/

/*------------------------------------------------------------------*/
/*  global variables                                                */
/*------------------------------------------------------------------*/
char *aesbuf, *aesapname, *altitle = "ThingFnd", almsg[256];
int aesmsg[8];
EVENT mevent;
GLOB glob;
RSINFO rinfo;
FIND_DATA find;
long lasthits;

FORMINFO fi_about = { 0L, ABOUT, 0, ROOT, 0, 0, 0, 0, 0L, 0L, 0, "%about", -1, ABHELP };
FORMINFO fi_find = { 0L, FIND, 0, ROOT, 0, 0, 0, 0, 0L, 0L, 0, "%find", FCANCEL, FHELP };
FORMINFO fi_status = { 0L, STATUS, 0, ROOT, 0, 0, 0, 0, 0L, 0L, 0, "%status", SCANCEL, SHELP };

/*------------------------------------------------------------------*/
/*  external variables                                              */
/*------------------------------------------------------------------*/
/*------------------------------------------------------------------*/
/*  local functions                                                 */
/*------------------------------------------------------------------*/
/*------------------------------------------------------------------*/
/*  local variables                                                 */
/*------------------------------------------------------------------*/

/*------------------------------------------------------------------*/
/*  local definitions                                               */
/*------------------------------------------------------------------*/
#define VERSION	"0.10"

#define UNUSED(x)	(void)(x)

void sigTerm(long sig) {
	UNUSED(sig);
	glob.done = 1;
}

/**
 full2comp()
 comp2full()
 
 Erzeugt aus einen vollen Dateienamen Pfad und Datei und umgekehrt
 -------------------------------------------------------------------------*/
void full2comp(char *full, char *path, char *file) {
	char *p;

	strcpy(path, full);
	if (!path[0]) {
		path[0] = (char) Dgetdrv() + 'A';
		path[1] = ':';
		Dgetpath(&path[2], 0);
		strcat(path, "\\");
	}
	p = strrchr(path, '\\');
	if (p) {
		strcpy(file, &p[1]);
		p[1] = 0;
	} else
		strcpy(file, "");
}

void comp2full(char *full, char *path, char *file) {
	strcpy(full, path);
	if (strrchr(full, 0)[-1] != '\\')
		strcat(full, "\\");
	strcat(full, file);
}

/**
 * full_fselect
 *
 * Ruft fselect() auf und kÅmmert sich dabei um Sachen wie Zerlegung
 * und Zusammensetzung des Pfades, Ermittlung des Defaultpfades,
 * Neuzeichnen des Dialogs, etc.
 *
 * Eingabe:
 * full: Zeiger auf vorzuselektierende Datei inklusive Pfad. Nach dem
 *       Aufruf steht hier die tatsÑchlich ausgewÑhlte Datei.
 * deflt: Zeiger auf vorzusektierende Datei, wenn full leer ist.
 *          Wenn NULL, wird das aktuelle Verzeichnis benutzt.
 * ext: Zeiger auf Filterextension
 * dironly: Es soll ein Verzeichnis ausgewÑhlt werden; ein eventuell
 *          auswgewÑhlter Dateiname wird also ignoriert
 * title: Zeiger auf Titel fÅr die Auswahlbox
 * freedret: Freedom non-modal aufrufen? (0/1)
 * freedid: ID fÅr Freedom, wenn freedret = 1
 * form: Zeiger auf aufrufendes Formular, ggf. NULL
 *
 * RÅckgabe:
 * 0: Dateiauswahl mit 'Abbruch' verlassen oder Aufruf fehlgeschlagen
 * 1: Dateiauswahl erfolgreich, ausgewÑhlte Datei steht in full
 * 2: Dateiauswahl erfolgreich, ausgewÑhlter Ordner steht in full
 */
int full_fselect(char *full, char *deflt, char *ext, int dironly, char *title,
		int freedret, int freedid, FORMINFO *fi) {
	char path[MAX_PLEN], name[MAX_FLEN], *p;
	int exbut, ret;

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

/*-------------------------------------------------------------------------
 str230()
 str236()
 
 Begrenzt eine Pfadangabe etc. auf 20/36 Zeichen - z.B. fÅr Dialoge
 -------------------------------------------------------------------------*/
void str230(char *dest, char *src) {
	int l;

	l = (int) strlen(src);
	if (l > 30) {
		strncpy(dest, src, 10);
		strcpy(&dest[10], "...");
		strcat(dest, &src[l - 17]);
	} else
		strcpy(dest, src);
}

void str236(char *dest, char *src) {
	int l;

	l = (int) strlen(src);
	if (l > 36) {
		strncpy(dest, src, 10);
		strcpy(&dest[10], "...");
		strcat(dest, &src[l - 23]);
	} else
		strcpy(dest, src);
}

/**
 * app_send
 *
 * Verschickt eine AES-Nachricht an eine Applikation.
 *
 * Eingabe:
 * id: AES-ID der EmpfÑngerapplikation
 * message: Die zu verschickende Nachricht
 * pointers: Bitvektor, der angibt, welche Parameter Pointer sind.
 *        - PT34: par1 ist Pointer, par2 wird nicht beachtet
 *        - PT45: par2  "     "   , par3   "    "       "
 *        - PT56: par3  "     "   , par4   "    "       "
 *        - PT67: par4  "     "   , par5   "    "       "
 *        NatÅrlich sind Kombinationen wie BV34|BV45 sinnlos!
 * par1 - par5: Die Parameter fÅr die Nachricht, die fÅr msg[3] bis
 *              msg[7] eingesetzt werden. Siehe auch pointers.
 */
void app_send(int id, int message, int pointers, long par1, long par2,
		long par3, long par4, long par5) {
	aesmsg[0] = message;
	aesmsg[1] = tb.app_id;
	aesmsg[2] = 0;
	aesmsg[3] = (int) par1;
	aesmsg[4] = (int) par2;
	aesmsg[5] = (int) par3;
	aesmsg[6] = (int) par4;
	aesmsg[7] = (int) par5;
	if (pointers & PT34)
		long2int(par1, &aesmsg[3], &aesmsg[4]);
	if (pointers & PT45)
		long2int(par2, &aesmsg[4], &aesmsg[5]);
	if (pointers & PT56)
		long2int(par3, &aesmsg[5], &aesmsg[6]);
	if (pointers & PT67)
		long2int(par4, &aesmsg[6], &aesmsg[7]);
	appl_write(id, 16, aesmsg);
}

/**
 * long2int
 *
 * Wandelt einen long in zwei ints
 *
 * Eingabe:
 * lword: Zu wandelnder 32-Bit-Wert
 * hi: Zeiger auf die Adresse fÅr die oberen 16 Bit
 * lo: Zeiger auf die Adresse fÅr die unteren 16 Bit
 */
void long2int(long lword, int *hi, int *lo) {
	*hi = (int) (lword >> 16L);
	*lo = (int) (lword & 0xffffL);
}

/**
 * int2long
 *
 * Wandelt zwei unsigned ints in ein unsigned long.
 *
 * Eingabe:
 * hi: Obere 16 Bit fÅr den unsigned long.
 * lo: Untere 16 Bit fÅr den unsigned long.
 *
 * RÅckgabe:
 * lo + hi * 65536UL
 */
unsigned long int2long(unsigned int hi, unsigned int lo) {
	return ((unsigned long) lo + ((unsigned long) hi << 16UL));
}

/**
 show_help()
 
 Anzeige eines Hilfetextes mit ST-Guide
 -------------------------------------------------------------------------*/
void show_help(char *helpfile, char *ref) {
	int ap_id;

	/* ST-Guide vorhanden ? */
	ap_id = appl_find("ST-GUIDE");
	if (ap_id < 0) {
		frm_alert(1, rinfo.rs_frstr[ALNOGUIDE], altitle, 1, 0L);
		return;
	}

	strcpy(aesbuf, "*:\\");
	strcat(aesbuf, helpfile);
	if (ref) {
		strcat(aesbuf, " ");
		strcat(aesbuf, ref);
	}
	app_send(ap_id, VA_START, PT34, (long) aesbuf, 0, 0, 0, 0);
}

static void mn_redraw(OBJECT *tree) {
	int top;

	wind_update(BEG_MCTRL);
	if (!(tb.sys & SY_MULTI) || (tb.app_id == menu_bar(0L, -1))) {
		wind_get(0, WF_TOP, &top);
		menu_bar(tree, 1);
		if (top > 0)
			wind_set(top, WF_TOP);
	}
	wind_update(END_MCTRL);
}

/**
 * mn_all_ienable
 *
 * Setzt alle EintrÑge eines MenÅs via menu_ienable() auf ENABLED
 * oder DISABLED. Davon ausgenommen sind EintrÑge, die mit einem
 * Minuszeichen beginnen, keine G_STRINGs sind oder zu den ACC-
 * Slots gehîren.
 *
 * Eingabe:
 * tree: Zeiger auf zu bearbeitendes MenÅ (wenn tree auf einen Baum
 *       zeigt, der nicht die Struktur eines AES-MenÅs hat, ist das
 *       Verhalten der Funktion undefiniert)
 * enable: Alle EintrÑge aktivieren (1) oder deaktivieren (0)
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
			if (((tree[k].ob_type & 0xff) == G_STRING)
					&& (*tree[k].ob_spec.free_string != '-') && (in_acc != 1)) {
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
 mn_disable()
 
 Deaktivieren der MenÅeintrÑge bei Fensterdialogen
 -------------------------------------------------------------------------*/
void mn_disable(void) {
	OBJECT *baum;

	baum = rinfo.rs_trindex[MAINMENU];

	mn_all_ienable(baum, 0);
	mn_redraw(baum);
}

/**
 mn_istate()
 
 Disablen eines MenÅeintrags
 -------------------------------------------------------------------------*/
void mn_istate(int item, int enable) {
	if (enable)
		rinfo.rs_trindex[MAINMENU][item].ob_state &= ~DISABLED;
	else
		rinfo.rs_trindex[MAINMENU][item].ob_state |= DISABLED;
}

/**
 mn_update()
 
 MenÅeintrage je nach Situation DISABLEn
 -------------------------------------------------------------------------*/
void mn_update(void) {
	OBJECT *tree;

	tree = rinfo.rs_trindex[MAINMENU];

	wind_update(BEG_UPDATE);
	if (tree[MFILE].ob_state & DISABLED)
		mn_all_ienable(tree, 1);
	mn_istate(MABOUT, 1);
	mn_istate(MNEXTWIN, 1);
	mn_istate(MQUIT, 1);
	mn_redraw(tree);
	wind_update(END_UPDATE);
}

/*-------------------------------------------------------------------------
 av_...()
 
 AV-Protokoll
 -------------------------------------------------------------------------*/

void av_wopen(int handle) {
	if (glob.avid < 0)
		return;

	app_send(glob.avid, AV_ACCWINDOPEN, 0, handle, 0, 0, 0, 0);
}

void av_wclose(int handle) {
	if (glob.avid < 0)
		return;

	app_send(glob.avid, AV_ACCWINDCLOSED, 0, handle, 0, 0, 0, 0);
}

/*-------------------------------------------------------------------------
 dl_about()
 
 öber ThingFnd
 -------------------------------------------------------------------------*/

/* Initialisiert und oeffnet den Dialog 'Ueber ThingFnd' */
void di_about(void) {
	if (fi_about.open) {
		frm_restore(&fi_about);
		return;
	}
	frm_start(&fi_about, 1, 1, 0);

	if (fi_about.state == FST_WIN)
		av_wopen(fi_about.win.handle);
}

void de_about(int mode, int ret) {
	UNUSED(ret);
	if (!mode) {
		switch (fi_about.exit_obj) {
		case ABOK:
			if (fi_about.state == FST_WIN)
				av_wclose(fi_about.win.handle);

			frm_end(&fi_about);
			break;
		}
	} else {
		if (fi_about.state == FST_WIN)
			av_wclose(fi_about.win.handle);
		frm_end(&fi_about);
	}
}

/*-------------------------------------------------------------------------
 dl_nextwin()
 
 Fenster wechseln
 -------------------------------------------------------------------------*/

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
			app_send(glob.avid, AV_SENDKEY, 0, K_CTRL, 0x1107, 0, 0, 0);
	}
}

/*-------------------------------------------------------------------------
 dl_quit()
 
 Ende
 -------------------------------------------------------------------------*/

void dl_quit(void) {
	glob.done = 1;
}

/*
 * insert_date
 *
 * Schreibt ein GEMDOS-Datum in einen String.
 *
 * Eingabe:
 * str: Zeiger auf Zielpuffer
 * date: EinzufÅgendes GEMDOS-Datum, 0xffff = kein Datum (leer)
 */
static void insert_date(char *str, unsigned int date) {
	if (date == 0xffffU)
		strcpy(str, "");
	else {
		sprintf(str, "%02d%02d%04d", date & 0x20, (date >> 5) & 0x10, (date >> 9) + 1980);
	}
}

/*
 * find_setpage
 *
 * Schaltet auf eine bestimmte Karteikarte im Suchen-Dialog um.
 *
 * Eingabe:
 * tree: Zeiger auf Dialogbaum
 * page: Anzuzeigende Seite
 */
static void find_setpage(OBJECT *tree, int page) {
	int child;

	/*
	 * Alle Editfelder abschalten, da in nicht sichtbaren Seiten
	 * keine Eingaben mîglich sein dÅrfen
	 */
	tree[FDRIVES].ob_flags &= ~EDITABLE;
	tree[FFMASK].ob_flags &= ~EDITABLE;
	tree[FFROMDATE].ob_flags &= ~EDITABLE;
	tree[FTODATE].ob_flags &= ~EDITABLE;
	tree[FFROMSIZE].ob_flags &= ~EDITABLE;
	tree[FTOSIZE].ob_flags &= ~EDITABLE;
	tree[FCMASK].ob_flags &= ~EDITABLE;

	dial_setopt(tree, FGENERAL, SELECTED, 0);
	dial_setopt(tree, FATTR, SELECTED, 0);

	switch (page) {
	case 0:
		dial_setopt(tree, FGENERAL, SELECTED, 1);
		tree[FDRIVES].ob_flags |= EDITABLE;
		tree[FFMASK].ob_flags |= EDITABLE;
		child = FSGENERAL;
		fi_find.edit_obj = FDRIVES;
		break;
	case 1:
		dial_setopt(tree, FATTR, SELECTED, 1);
		tree[FFROMDATE].ob_flags |= EDITABLE;
		tree[FTODATE].ob_flags |= EDITABLE;
		tree[FFROMSIZE].ob_flags |= EDITABLE;
		tree[FTOSIZE].ob_flags |= EDITABLE;
		tree[FCMASK].ob_flags |= EDITABLE;
		fi_find.edit_obj = FFROMDATE;
		child = FSATTR;
		break;
	}
	tree[FSUB].ob_head = tree[FSUB].ob_tail = child;
	tree[child].ob_next = FSUB;
}

/*
 * di_find
 *
 * ôffnet den Suchen-Dialog.
 */
void di_find(void) {
	int i, last;
	char *p, *max, *start;
	OBJECT *tree;

	tree = fi_find.tree;
	if (fi_find.open) {
		frm_restore(&fi_find);
		return;
	}

	dial_setopt(tree, FON, SELECTED, !*find.searchpath);
	dial_setopt(tree, FIN, SELECTED, *find.searchpath);
	str236(tree[FPATH].ob_spec.tedinfo->te_ptext, find.searchpath);
	p = start = tree[FDRIVES].ob_spec.tedinfo->te_ptext;
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
	dial_setopt(tree, FGO, DISABLED, (find.drvbits == 0L) && !*find.searchpath);
	if (dial_getopt(tree, FGO, DISABLED))
		tree[FGO].ob_flags &= ~DEFAULT;

	dial_setopt(tree, FFOLLOW, SELECTED, find.follow);
	dial_setopt(tree, FVERBOSE, SELECTED, find.verbose);
	strcpy(tree[FFMASK].ob_spec.tedinfo->te_ptext, find.filemask);
	dial_setopt(tree, FFCASE, SELECTED, find.fm_case);
	dial_setopt(tree, FDIRS, SELECTED, find.fm_dirs);

	dial_setopt(tree, FTIME, SELECTED, find.datecheck);
	insert_date(tree[FFROMDATE].ob_spec.tedinfo->te_ptext, find.mindate);
	insert_date(tree[FTODATE].ob_spec.tedinfo->te_ptext, find.maxdate);

	dial_setopt(tree, FSIZE, SELECTED, find.sizecheck);
	if (find.minsize != -1L) {
		sprintf(tree[FFROMSIZE].ob_spec.tedinfo->te_ptext, "%ld", find.minsize);
	} else
		strcpy(tree[FFROMSIZE].ob_spec.tedinfo->te_ptext, "");
	if (find.maxsize != -1L) {
		sprintf(tree[FTOSIZE].ob_spec.tedinfo->te_ptext, "%ld", find.maxsize);
	} else
		strcpy(tree[FTOSIZE].ob_spec.tedinfo->te_ptext, "");

	dial_setopt(tree, FCONTENTS, SELECTED, find.grep);
	strcpy(tree[FCMASK].ob_spec.tedinfo->te_ptext, find.contentmask);
	dial_setopt(tree, FCCASE, SELECTED, find.cm_case);
	dial_setopt(tree, FCBINARY, SELECTED, find.cm_binary);

	find_setpage(tree, find.page);

	frm_start(&fi_find, 1, 1, 0);

	if (fi_find.state == FST_WIN)
		av_wopen(fi_find.win.handle);
}

/*
 * search_update
 *
 * Update-Prozedur fÅr die Suche, wird als Callback fÅr search_main()
 * verwendet.
 *
 * Eingabe/RÅckgabe:
 * Siehe Parameter "update" bei search_main()
 */
int search_update(char *current, long hits) {
	int ret, wait;
	static int count = 0;
	OBJECT *tree;
	EVENT event;

	tree = fi_status.tree;
	if (win_update(BEG_UPDATE)) {
		if (find.verbose && (current != NULL)) {
			str230(tree[SCURRENT].ob_spec.tedinfo->te_ptext, current);
			frm_redraw(&fi_status, SCURRENT);
		}
		if ((hits >= 0L) && (hits != lasthits)) {
			lasthits = hits;
			sprintf(tree[SHITS].ob_spec.tedinfo->te_ptext, "%ld", hits);
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
				show_help("thingfnd.hyp", fi_status.userinfo);
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

/*
 * de_find_go
 *
 * Reagiert auf das Anklicken von "Go" im Suchen-Dialog. Die Eingaben
 * werden geprÅft und ggf. bemÑngelt. Im Erfolgsfall wird die Suche
 * gestartet.
 *
 * Eingabe:
 * tree: Zeiger auf Suchen-Dialog
 */
static void de_find_go(OBJECT *tree) {
	long err;
	int start, end, i;
	long ok;
	char *p, fmask[MAX_PLEN], cmask[MAX_PLEN];
	double size;
	FIND_DATA temp;
	OBJECT *s_tree;

	temp = find;

	temp.drvbits = 0L;
	if (dial_getopt(tree, FON, SELECTED)) {
		p = tree[FDRIVES].ob_spec.tedinfo->te_ptext;
		start = -1;
		while (*p) {
			if (isalpha(*p)) {
				if (start != -1) {
					dfg_parseerr: frm_alert(1, rinfo.rs_frstr[ALDRVFORMAT],
							altitle, 1, 0L);
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
	temp.follow = dial_getopt(tree, FFOLLOW, SELECTED);
	temp.fm_case = dial_getopt(tree, FFCASE, SELECTED);
	temp.fm_dirs = dial_getopt(tree, FDIRS, SELECTED);
	temp.filemask = fmask;
	p = tree[FFMASK].ob_spec.tedinfo->te_ptext;
	if (!*p)
		strcpy(fmask, "*");
	else
		strcpy(fmask, p);
	temp.datecheck = dial_getopt(tree, FTIME, SELECTED);
	if (temp.datecheck) {
		p = tree[FFROMDATE].ob_spec.tedinfo->te_ptext;
		if (!*p)
			temp.mindate = 0;
		else {
			temp.mindate = parse_date(p);
			if (temp.mindate == 0xffffU) {
				frm_alert(1, rinfo.rs_frstr[ALFROMDATE], altitle, 1, 0L);
				return;
			}
		}
		p = tree[FTODATE].ob_spec.tedinfo->te_ptext;
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
	temp.sizecheck = dial_getopt(tree, FSIZE, SELECTED);
	if (temp.sizecheck) {
		p = tree[FFROMSIZE].ob_spec.tedinfo->te_ptext;
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
		p = tree[FTOSIZE].ob_spec.tedinfo->te_ptext;
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
	temp.grep = dial_getopt(tree, FCONTENTS, SELECTED);
	temp.cm_case = dial_getopt(tree, FCCASE, SELECTED);
	temp.cm_binary = dial_getopt(tree, FCBINARY, SELECTED);
	if (temp.grep) {
		p = tree[FCMASK].ob_spec.tedinfo->te_ptext;
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
	temp.verbose = dial_getopt(tree, FVERBOSE, SELECTED);
	if ((err = Fopen(glob.tname, 0)) < 0L) {
		sprintf(almsg, rinfo.rs_frstr[ALNOTEMPLATE], FNAME_TPL);
		frm_alert(1, almsg, altitle, 1, 0L);
		return;
	}
	Fclose((int) err);
	find = temp;
	s_tree = fi_status.tree;
	s_tree[SCURRENT].ob_spec.tedinfo->te_ptext[0] = 0;
	strcpy(s_tree[SHITS].ob_spec.tedinfo->te_ptext, "0");
	if (find.verbose)
		s_tree[SCBOX].ob_flags &= ~HIDETREE;
	else
		s_tree[SCBOX].ob_flags |= HIDETREE;
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
			strcpy(aesbuf, glob.rname);
			app_send(glob.tid, AV_STARTPROG, PT34, (long) aesbuf, 0L, 0L, 0L,
					0L);
		} else
			frm_alert(1, rinfo.rs_frstr[ALNOTHING], altitle, 1, 0L);
	}
}

/*
 * de_find
 *
 * Callback-Funktion zur Reaktion auf Ereignisse im Suchen-Dialog.
 *
 * Eingabe:
 * mode: Dialog wird geschlossen (1) oder anderes Dialogereignis (0)
 * ret: RÅckgabewert von frm_do(), zu bearbeitendes Objekt (wie bei
 *      form_do())
 */
void de_find(int mode, int ret) {
	OBJECT *tree;
	int done, exob, edob, oldpage, go_disabled;
	char searchpath[MAX_PLEN];

	UNUSED(ret);

	tree = fi_find.tree;
	done = 0;
	oldpage = find.page;

	if (!mode) {
		exob = fi_find.exit_obj;
		go_disabled = dial_getopt(tree, FGO, DISABLED);
		switch (exob) {
		case FGENERAL:
			find.page = 0;
			break;
		case FATTR:
			find.page = 1;
			break;
		case FON:
			dial_setopt(tree, FGO, DISABLED,
					!tree[FDRIVES].ob_spec.tedinfo->te_ptext[0]);
			frm_gotoedit(&fi_find, FDRIVES);
			break;
		case FDRIVES:
			if (dial_getopt(tree, FON, SELECTED)) {
				dial_setopt(tree, FGO, DISABLED,
						!tree[exob].ob_spec.tedinfo->te_ptext[0]);
			}
			break;
		case FIN:
			dial_setopt(tree, FGO, DISABLED, !*find.searchpath);
			break;
		case FPATHS:
			strcpy(searchpath, find.searchpath);
			if (full_fselect(searchpath, NULL, "*.*", 1,
					rinfo.rs_frstr[TXCHOOSEPATH], 0, 0, &fi_find)) {
				strcpy(find.searchpath, searchpath);
				str236(tree[FPATH].ob_spec.tedinfo->te_ptext, find.searchpath);
				frm_redraw(&fi_find, FPATH);
				if (!dial_getopt(tree, FIN, SELECTED)) {
					dial_setopt(tree, FON, SELECTED, 0);
					dial_setopt(tree, FIN, SELECTED, 1);
					frm_redraw(&fi_find, FON);
					frm_redraw(&fi_find, FIN);
				}
				dial_setopt(tree, FGO, DISABLED, !*find.searchpath);
			}
			frm_norm(&fi_find);
			break;
		case FTIME:
			if (dial_getopt(tree, FTIME, SELECTED)) {
				if (fi_find.edit_obj != FTODATE)
					frm_gotoedit(&fi_find, FFROMDATE);
			}
			break;
		case FSIZE:
			if (dial_getopt(tree, FSIZE, SELECTED)) {
				if (fi_find.edit_obj != FTOSIZE)
					frm_gotoedit(&fi_find, FFROMSIZE);
			}
			break;
		case FCONTENTS:
			if (dial_getopt(tree, FCONTENTS, SELECTED))
				frm_gotoedit(&fi_find, FCMASK);
			break;
		case FGO:
			de_find_go(tree);
			frm_norm(&fi_find);
			break;
		case FCANCEL:
			done = FCANCEL;
			break;
		}
		if (go_disabled != dial_getopt(tree, FGO, DISABLED)) {
			if (go_disabled)
				tree[FGO].ob_flags |= DEFAULT;
			else
				tree[FGO].ob_flags &= ~DEFAULT;
			frm_redraw(&fi_find, FGOBOX);
		}
	} else
		done = glob.done = 1;

	/* Bei Bedarf Seite umschalten */
	if (find.page != oldpage) {
		frm_gotoedit(&fi_find, 0);
		find_setpage(tree, find.page);
		edob = fi_find.edit_obj;
		fi_find.edit_obj = 0;
		frm_gotoedit(&fi_find, edob);
		frm_redraw(&fi_find, FSUB);
		mevent.ev_mwich = MU_M1;
		frm_do(&fi_find, &mevent);
	}

	/* Ggf. Dialog schlieûen */
	if (done) {
		if (done == FCANCEL)
			glob.done = 1;
		if (done != -1)
			frm_norm(&fi_find);
		if (fi_find.state == FST_WIN)
			av_wclose(fi_find.win.handle);
		frm_end(&fi_find);
	}
}

/*
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
void drag_on_window(int handle, int mx, int my, char *buf) {
	UNUSED(handle);
	UNUSED(mx);
	UNUSED(my);
	UNUSED(buf);
}

/*-------------------------------------------------------------------------
 ddnak()
 
 Drag&Drop-Protokoll abweisen
 -------------------------------------------------------------------------*/

void ddnak(EVENT * mevent) {
	char *pipename = "U:\\PIPE\\DRAGDROP.AA";
	long fd;
	char c;

	pipename[18] = mevent->ev_mmgpbuf[7] & 0x00ff;
	pipename[17] = (mevent->ev_mmgpbuf[7] & 0xff00) >> 8;
	fd = Fopen(pipename, FO_RW);
	if (fd >= 0L) {
		c = 1; /* DD_NAK */
		Fwrite((int) fd, 1, &c);
		Fclose((int) fd);
	}
}

/*-------------------------------------------------------------------------
 handle_menu()

 Verarbeiten einer MenÅauswahl
 Wird auch von handle_key() bei Shortcuts aufgerufen
 -------------------------------------------------------------------------*/

void handle_menu(int title, int item, int ks) {
	WININFO *win;
	OBJECT *tree;

	tree = rinfo.rs_trindex[MAINMENU];
	if ((tree[item].ob_state & DISABLED) || (tree[title].ob_state & DISABLED)) {
		return;
	}

	mn_tnormal(tree, title, 0);
	mn_disable();
	mn_tnormal(tree, title, 1);

	/* Hilfetext anzeigen, falls [Control] gedrÅckt */
	if (ks & K_CTRL) {
		switch (item) {
		case MABOUT:
			show_help("thingfnd.hyp", "%I");
			break;

		case MNEXTWIN:
			show_help("thingfnd.hyp", "%mnwin");
			break;

		case MQUIT:
			show_help("thingfnd.hyp", "%mquit");
			break;

		default:
			show_help("thingfnd.hyp", "%I");
			break;
		}
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
	mn_tnormal(tree, title, 1);
	mn_update();
}

/*-------------------------------------------------------------------------
 handle_win()

 Verarbeiten von Fensterereignissen
 -------------------------------------------------------------------------*/

void handle_win(int handle, int msg, int f1, int f2, int f3, int f4, int ks) {
	WININFO *win;
	FORMINFO *fi;
	int top;
	int owner;

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

			/* Workaround fÅr MagiC */
			if (tb.sys & SY_MAGX && !tb.topwin) {
				if (wind_get(top, WF_OWNER, &owner))
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
		 * Workaround fÅr Einblenden bei N.AES, das in diesem
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
		if (tb.sm_alert) /* Alert offen? - dann geht kein Close! */
		{
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
		if (f3 > win->full.w)
			f3 = win->full.w;
		if (f4 > win->full.h)
			f4 = win->full.h;
		win_size(win, f1, f2, f3, f4);
		break;

	case WM_MOVED:
		win_size(win, f1, f2, f3, f4);
		break;
	}
}

/*-------------------------------------------------------------------------
 handle_button()

 Verarbeiten von Mausklicks
 -------------------------------------------------------------------------*/

void handle_button(int mx, int my, int but, int ks, int br) {
	UNUSED(mx);
	UNUSED(my);
	UNUSED(but);
	UNUSED(ks);
	UNUSED(br);
}

/*-------------------------------------------------------------------------
 handle_key()

 Verarbeiten von Tastatureingaben
 -------------------------------------------------------------------------*/

void handle_key(int ks, int kr) {
	unsigned int key;
	int title, item, skey;

	key = normkey(ks, kr);
	key &= ~(NKF_CAPS | NKF_RESVD); /* Nicht benîtigte Flags *
	 * ausmaskieren */
	if (key & NKF_LSH || key & NKF_RSH)
		key |= NKF_SHIFT; /* Shift-Status */

	/* PrÅfen, ob MenÅ-Shortcut vorliegt */
	if (menu_key(rinfo.rs_trindex[MAINMENU], key, &title, &item)) {
		/* Shortcut vorhanden, MenÅhandling ausfÅhren */
		handle_menu(title, item, 0);
	} else
	/* Kein Shortcut, normale Verarbeitung */
	{
		skey = 0; /* Flag fÅr AV_SENDKEY */
		if (key == (NKF_FUNC | NK_HELP)) {
			if (!tb.topfi)
				show_help("thingfnd.hyp", "%I");
		} else
			skey = 1;
		if (skey) /* Ggf. AV_SENDKEY */
		{
			if (glob.avid >= 0 && (glob.avflags & 0x0001))
				app_send(glob.avid, AV_SENDKEY, 0, ks, kr, 0, 0, 0);
		}
	}
}

/*-------------------------------------------------------------------------
 handle_fmsg()

 Wird von der GEM-Toolbox fÅr die Bearbeitung einer unbekannten
 AES-Message wÑhrend eines modalen Fensterdialogs aufgerufen
 -------------------------------------------------------------------------*/

void handle_fmsg(EVENT * mevent, FORMINFO * fi) {
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
			} else /* Nein - alles klar */
			{
				glob.done = 1;
			}

		case MN_SELECTED:
			mn_tnormal(rinfo.rs_trindex[MAINMENU], mevent->ev_mmgpbuf[3],
					mevent->ev_mmgpbuf[4]);
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
			if (fi->state == FST_WIN)
				show_help("thingnd.hyp", fi->userinfo);
			else
				frm_alert(1, rinfo.rs_frstr[ALNOWDIAL], altitle, 1, 0L);
		}
	}
}

/*
 * get_buf_entry
 *
 * Ermittelt den nÑchsten Filenamen aus einem Puffer, dessen EintrÑge
 * durch Leerzeichen getrennt und ggf. von Quotes (') umschlossen
 * sind. Der ermittelte Filename enthÑlt keine Quotes mehr.
 *
 * Eingabe:
 * buf: Zeiger auf den Puffer, muû bzw. darf nur beim ersten Aufruf
 *      fÅr buf angegeben werden, danach muû fÅr buf ein Nullzeiger
 *      Åbergeben werden, damit get_buf_entry den nÑchsten Eintrag
 *      ermitteln kann
 * name: Hierhin wird der nÑchste Filename kopiert. Da dieser mit
 *       komplettem Pfad versehen sein kann, sollte name ausreichend
 *       Platz bieten.
 * newpos: Wenn ungleich NULL, wird hier der Zeiger auf die nÑchste
 *         Leseposition abgelegt, so daû man get_buf_entry auch
 *         wechselseitig mit zwei oder mehr Puffern verwenden kann.
 *         Der Wert wird nur gesetzt, wenn ein Eintrag gelesen werden
 *         konnte, der Returncode also 1 ist.
 *
 * RÅckgabe:
 * 0: Kein weiterer (gÅltiger) Filename mehr in buf (ein Filename ist
 *    z.B. ungÅltig, wenn er falsch gequotet wurde)
 * 1: name enthÑlt den nÑchsten Filenamen
 */
int get_buf_entry(char *buf, char *name, char **newpos) {
	static char *bufpos;
	char *pos;
	int closed;

	if (buf != 0L)
		pos = buf;
	else
		pos = bufpos;

	/* Eventuell war der letzte Filename ungÅltig, dann abbrechen */
	if (pos == 0L)
		return (0);

	/* Erstmal fÅhrende Leerzeichen Åberlesen */
	for (; *pos == ' '; pos++)
		;
	/* Gibt es Åberhaupt noch einen Filenamen? */
	if (!*pos)
		return (0);

	if (*pos != '\'') {
		/*
		 * Wenn der Filename nicht mit einem Quote beginnt, bis zum nÑchsten
		 * Leerzeichen kopieren
		 */
		for (; *pos && (*pos != ' '); *name++ = *pos++)
			;
	} else {
		/* Sonst den Filenamen "entquoten" */
		closed = 0;
		for (pos++;;) {
			/* Bei einem Nullbyte abbrechen (gibt ungÅltigen Filenamen) */
			if (!*pos)
				break;
			if (*pos == '\'') {
				/*
				 * Ist das aktuelle Zeichen ein Quote, gibt es folgende FÑlle zu
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
	 * Puffer fÅr den nÑchsten Aufruf merken
	 */
	*name = 0;
	bufpos = pos;
	if (newpos != 0L)
		*newpos = pos;
	return 1;
}

/*-------------------------------------------------------------------------
 main_init()
 
 Programminitialisierung
 -------------------------------------------------------------------------*/

int main_init(void) {
	int i, l, x, y, w, h;
	char *p, aname[9];
	OBJECT *tree;

	/* MiNT-Domain aktivieren */
	Pdomain(1);

	/* Einige MiNT-Signal-Handler installieren */
	Psignal(SIGINT, (void *) 1L);
	Psignal(SIGSYS, (void *) 1L);
	Psignal(SIGABRT, (void *) 1L);
	Psignal(SIGTERM, sigTerm);
	Psignal(SIGQUIT, (void *) 1L);
	Psignal(SIGHUP, (void *) 1L);

	aesbuf = 0L;
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
		return (0);

	if (!init_cicon())
		return (0);

#if 0
	if ((p = getenv("THINGDIR")) == 0L)
	{
		glob.tname[0] = (char) Dgetdrv() + 'A';
		glob.tname[1] = ':';
		Dgetpath(&glob.tname[2], 0);
	}
	else
	strcpy(glob.tname, p);
#else
	strcpy(glob.tname, tb.homepath);
#endif
	l = (int) strlen(glob.tname);
	if (glob.tname[l - 1] != '\\')
		strcat(glob.tname, "\\");
	strcpy(glob.rname, glob.tname);
	strcat(glob.tname, FNAME_TPL);
	strcat(glob.rname, FNAME_RES);

	if (tb.sys & SY_MTOS) /* Eintrag im Desk-MenÅ */
		menu_register(tb.app_id, "  Thing Find ");

	if (glob.use3d == 0)
		set3dLook(FALSE);

	/* Alice austricksen ;-) */
	i = wind_create(NAME | MOVER | CLOSER | FULLER | ICONIFIER, tb.desk.x, tb.desk.y, 10, 10);
	if (i >= 0)
		wind_delete(i);

	tb.msg_handler = handle_fmsg;

	/* Resource laden */
	if (!rsc_load("thingfnd.rsc", &rinfo)) {
		frm_alert(1, "[3][THINGFND.RSC nicht gefunden!|"
				"THINGFND.RSC not found!][ OK ]", altitle, 1, 0L);
		return (0);
	}
	for (i = 0; i < NUM_TREE; i++) {
		if (i == MAINMENU)
			rs_fix(rinfo.rs_trindex[i], 0, 0);
		else
			rs_fix(rinfo.rs_trindex[i], 8, 16);
		rs_textadjust(rinfo.rs_trindex[i], (glob.use3d && (tb.colors >= 16)) ? getBackgroundColor() : WHITE);
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
		return (0);
	}
	aesbuf = &aesapname[9];
	/* Sonst initialisieren */
	strcpy(aesapname, "THINGFND");

	tb.use3d = glob.use3d; /* 3D-Effekte */
	tb.backwin = glob.backwin; /* MagiC-Fensterworkround */

	/* ThingFnd-Logo anpassen */
	tree = rinfo.rs_trindex[ABOUT];
	tree[ABLOGOHI].ob_x = (tree->ob_width - tree[ABLOGOHI].ob_spec.bitblk->bi_wb * 8) / 2;
	tree[ABLOGOLO].ob_x = (tree->ob_width - tree[ABLOGOLO].ob_spec.bitblk->bi_wb * 8) / 2;
	if (tb.ch_h < 12) {
		tree[ABLOGOHI].ob_flags |= HIDETREE;
		tree[ABLOGOLO].ob_flags &= ~HIDETREE;
	} else {
		l = tree[ABLOGOHI].ob_spec.bitblk->bi_hl - tree[ABLOGOHI].ob_height + 4;
		tree->ob_height += l;
		for (i = 4; !(tree[i].ob_flags & LASTOB); i++)
			tree[i].ob_y += l;
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

	for (i = 1; i < NUM_TREE; i++)
		setUserdefs(rinfo.rs_trindex[i], FALSE);
	setBackgroundBorder(FALSE);

	/* Dialogboxen zentrieren */
	for (i = 0; i < NUM_TREE; i++)
		if (i != 0)
			form_center(rinfo.rs_trindex[i], &x, &y, &w, &h);

	/* Dialoge initialisieren */
	fi_about.tree = rinfo.rs_trindex[ABOUT];
	fi_about.init = di_about;
	fi_about.exit = de_about;
	fi_find.tree = rinfo.rs_trindex[FIND];
	fi_find.init = di_find;
	fi_find.exit = de_find;
	fi_status.tree = rinfo.rs_trindex[STATUS];

	/* Handler fÅr modale Dialoge */
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
				app_send(glob.avid, AV_PROTOKOLL, PT67, 18, 0, 0, (long) aesapname, 0);
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

	return (1);
}

/*-------------------------------------------------------------------------
 main_loop()
 
 Hauptschleife des Programms
 -------------------------------------------------------------------------*/

void main_loop(void) {
	int top, *msg, evdone, ret;

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
		 * Bei Bedarf vor der Message-Auswertung énderung des aktiven
		 * Fenster berÅcksichtigen
		 */
		if (!(tb.sys & SY_MULTI || tb.sys & SY_WINX)) {
			get_twin(&top);

			/*
			 * Falls aktives Fenster sich geÑndert hat, dann MenÅs
			 * updaten
			 */
			if (tb.topwin) /* Bisher aktives Fenster vorhanden */
			{
				if (!top) /* Kein Fenster mehr aktiv */
				{
					tb.topwin = 0L;
					tb.topfi = 0L;
					mn_update();
				} else
				/* Fenster aktiv */if (top != tb.topwin->handle)
				/* Anderes  * als  * bisher  */
				{
					tb.topwin = win_getwinfo(top);
					mn_update();
				}
			} else
			/* Bisher kein Fenster aktiv */
			{
				if (top) /* Aber jetzt ist eins aktiv */
				{
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
				drag_on_window(msg[3], msg[4], msg[5], (char *) int2long(msg[6], msg[7]));
				break;
			case VA_START:
				mybeep();
				magx_switch(tb.app_id, 0);
				break;
				/* MenÅauswahl */
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
					show_help("thingfnd.hyp", tb.topfi->userinfo);
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

		/* Jetzt die vom Handler Åbriggelassenen Events bearbeiten */
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

/*-------------------------------------------------------------------------
 main_exit()
 
 Programmdeinitialisierung
 -------------------------------------------------------------------------*/

void main_exit(void) {
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
		app_send(glob.avid, AV_EXIT, 0, tb.app_id, 0, 0, 0, 0);

	/* Sonstige AufrÑumarbeiten */
	if (glob.menu)
		menu_bar(rinfo.rs_trindex[MAINMENU], 0);

	if (aesapname)
		Mfree(aesapname);

	rsc_free(&rinfo);

	exit_cicon();
	tool_exit();
}

/*------------------------------------------------------------------*/
/*  main routine                                                    */
/*------------------------------------------------------------------*/
main(int argc, char *argv[]) {
	int i;
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
