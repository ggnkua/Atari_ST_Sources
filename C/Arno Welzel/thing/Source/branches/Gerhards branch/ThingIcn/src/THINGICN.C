/**
 * ThingIcn - Thing Icon Manager
 * Copyright (C) 1995-2012 Arno Welzel, Thomas Binder, Dirk Klemmt
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
 * @copyright  Arno Welzel, Thomas Binder, Dirk Klemmt 1995-2012
 * @author     Arno Welzel, Thomas Binder, Dirk Klemmt
 * @license    LGPL
 */

#include <gem.h>
#include <mintbind.h>
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
#include "rsrc\thingicn.h"
#include "..\include\thingicn.h"
#include <dudolib.h>

/*------------------------------------------------------------------*/
/*  global functions                                                */
/*------------------------------------------------------------------*/
/*------------------------------------------------------------------*/
/*  global variables                                                */
/*------------------------------------------------------------------*/
char *aesapname, *altitle = "ThingIcn", almsg[256], *edas, **edlist;
short aesmsg[8], edobj;
EVENT mevent;
ICONINFO *edicon;
GLOB glob;

FORMINFO fi_about = { 0L, -1, 0, ROOT, 0, 0, 0, 0, 0L, 0L, 0, "%I", -1, ABHELP };
POPMENU pop_tcolor = { 0L, FOFCOL, FOFCOLS, 1, -1, 0, 0, -1, -1 }, *aseditpop[] = { &pop_tcolor, 0L };
FORMINFO fi_asedit = { 0L, -1, 0, ROOT, 0, 0, 0, 0, aseditpop, 0L, 0, "%dedit", AECANCEL, AEHELP };
LISTINFO li_asedit = { &fi_asedit, 0L, AELIST, AESLIDE, AEBOX, AEUP, AEDOWN, 0, -1, 7, 36, 0 };
FORMINFO fi_find = { 0L, -1, 0, ROOT, 0, 0, 0, 0, 0L, 0L, 1, 0L, FICANCEL, FIHELP };
LISTINFO li_find = { &fi_find, 0L, FILIST, FISLIDE, FIBOX, FIUP, FIDOWN, 0, -1, 10, 34, 0 };
RSINFO rinfo;

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
/*
 * Kennzeichnet dialoginterne Aenderungen an den Zuordnungen. Wird
 * bei OK an glob.change weitergegeben, so dass dann die Menuepunkte
 * zum Sichern, Neuladen freigeschaltet werden koennen.
 */
static short changed = FALSE;

/*
 * Iconnamen fuer "PARENTDIR" und "CLIPBOARD", duerfen ggf. naemlich
 * auch "_PARENT" und "_CLIPBRD" heissen (fuer Benutzer von IconCons,
 * das maximal 8 Zeichen im Iconnamen zulaesst).
 */
static char *parentdir, *clipboard;

/* Struktur fuer den Suchen-Dialog */
typedef struct {
	short icon; /* Was wird gesucht: Icon (1) oder Zuordnung (0) */
	char *list, /* Zeiger auf den Puffer mit den Listenelementen */
	**listp; /* Liste mit Zeigern auf die Listenelemente */
} FIND_STRUCT;
static FIND_STRUCT fstruct;

/*------------------------------------------------------------------*/
/*  local definitions                                               */
/*------------------------------------------------------------------*/
#define VERSION	"1.11"
#define STGUIDEHELPFILE "thingicn.hyp"

/**
 * add_comment
 *
 * Haengt eine Zuordnung an die verkettete Liste der Kommentare ein.
 *
 * Eingabe:
 * line: Zeiger auf Zuordnungstext
 *
 * Rueckgabe:
 * 0: Kein Speicher mehr frei, Fehlermeldung bereits erfolgt
 * 1: sonst
 */
short add_comment(char *line) {
	COMMENT *new,
	*p;

	if ((new = pmalloc(sizeof(COMMENT) + strlen(line))) == NULL) {
		frm_alert(1, rinfo.rs_frstr[ALNOMEM], altitle, 1, 0L);
		return (0);
	}
	new->next = NULL;
	strcpy(new->line, line);
	if (glob.comments != NULL) {
		for (p = glob.comments; p->next != NULL; p = p->next);
		p->next = new;
	} else
		glob.comments = new;
	return (1);
}

/**
 mn_istate()

 Disablen eines Menueeintrags
 -------------------------------------------------------------------------*/
void mn_istate(short item, short enable) {
	if (enable)
		unsetObjectDisabled(rinfo.rs_trindex[MAINMENU], item);
	else
		setObjectDisabled(rinfo.rs_trindex[MAINMENU], item);
}

/**
 mn_disable()

 Deaktivieren der Menueeintraege bei Fensterdialogen
 -------------------------------------------------------------------------*/
void mn_disable(void) {
	wind_update (BEG_UPDATE);
	mn_istate(MABOUT, 0);
	mn_istate(MSAVE, 0);
	mn_istate(MREVERT, 0);
	mn_istate(MNEXTWIN, 0);
	mn_istate(MQUIT, 0);
	mn_istate(MFINDFILE, 0);
	mn_istate(MFINDICON, 0);
	wind_update(END_UPDATE);
}

/**
 mn_update()

 Menueeintrage je nach Situation DISABLEn
 -------------------------------------------------------------------------*/
void mn_update(void) {
	wind_update (BEG_UPDATE);
	mn_istate(MABOUT, 1);
	mn_istate(MSAVE, glob.change);
	mn_istate(MREVERT, glob.change);
	mn_istate(MNEXTWIN, 1);
	mn_istate(MQUIT, 1);
	mn_istate(MEDITICON, !!glob.focus);
	mn_istate(MFINDFILE, !!glob.numassign);
	mn_istate(MFINDICON, !!glob.numicon);
	wind_update(END_UPDATE);
}

/**
 * Initialisiert und Oeffnet den Dialog 'Ueber ThingIcn'
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
 save()

 Iconzuweisungen speichern
 -------------------------------------------------------------------------*/
short save(void) {
	short i,
	j,
	max,
	new,
	class,
	tcol,
	ret;
	char wc1[33], wc2[33], buf[128], txt;
	ASINFO *aslist, *as, d;
	time_t now;
	ICONINFO *icon;
	COMMENT *p;
	FILE *handle;
	OBJECT *tree;

	if (glob.numassign) {
		if ((aslist = pmalloc(glob.numassign * sizeof(ASINFO))) == NULL) {
			frm_alert(1, rinfo.rs_frstr[ALNOMEM], altitle, 1, 0L);
			return (0);
		}
		for (i = j = 0; i < glob.numicon; i++) {
			for (as = glob.icon[i].as; as != NULL; as = as->next)
				aslist[j++] = *as;
		}
		if (glob.numicon > 1) {
			for (i = glob.numassign - 1; i >= 1; i--) {
				max = i;
				for (j = 0; j < i; j++) {
					strcpy(wc1, aslist[j].wildcard);
					strcpy(wc2, aslist[max].wildcard);
					strupr(wc1);
					strupr(wc2);
					if (((*wc1 == '*') && (*wc2 != '*')) || patternMatching(wc1, wc2)) {
						max = j;
					}
				}
				if (max != i) {
					d = aslist[max];
					aslist[max] = aslist[i];
					aslist[i] = d;
				}
			}
		}
	}
	Fdelete(glob.bname);
	Frename(0, glob.iname, glob.bname);
	if ((handle = fopen(glob.iname, "w")) == NULL) {
		frm_alert(1, rinfo.rs_frstr[ALWERR], altitle, 1, 0L);
		ret = 0;
		goto save_exit;
	}
	tree = rinfo.rs_trindex[COMMENTS];
	now = time(NULL);
	i = 1;
	do {
		if (isObjectSelected(tree, i)) {
			strftime(buf, 128, tree[i].ob_spec.free_string, localtime(&now));
			fprintf(handle, "%s\n", buf);
		} else
			fprintf(handle, "%s\n", tree[i].ob_spec.free_string);
	} while ((tree[i++].ob_flags & LASTOB) == 0);
	for (p = glob.comments; p != NULL; p = p->next)
		fprintf(handle, "#%s\n", p->line);
	new = 1;
	for (i = 0; i < glob.numassign; i++) {
		icon = as_findas(aslist[i].wildcard, class = aslist[i].class);
		tcol = aslist[i].tcol;
		txt = aslist[i].txt;
		if (new) {
			new = 0;
			switch (aslist[i].class) {
			case 0:
				fprintf(handle, "IFIL ");
				break;
			case 1:
				fprintf(handle, "IFLD ");
				break;
			case 2:
				fprintf(handle, "IDRV ");
				break;
			}
			put_text(handle, icon->name);
			for (j = 12 - (short) strlen(icon->name); j > 0; j--)
				fprintf(handle, " ");
			fprintf(handle, " ");
		}
		fprintf(handle, "%s", aslist[i].wildcard);
		if ((i == (glob.numassign - 1)) || (class != aslist[i + 1].class) || (tcol != aslist[i + 1].tcol) || (txt != aslist[i + 1].txt) ||
				strcmp(icon->name, as_findas(aslist[i + 1].wildcard, aslist[i + 1].class)->name)) {
			if (txt || (tcol != -1)) {
				fprintf(handle, " ");
				if (txt)
					fprintf(handle, "%c", txt);
				if (tcol != -1)
					fprintf(handle, "/%d", tcol);
			}
			fprintf(handle, "\n");
			new = 1;
		} else
			fprintf(handle, ",");
	}
	if (fclose(handle) != 0) {
		ret = 0;
		frm_alert(1, rinfo.rs_frstr[ALWERR], altitle, 1, 0L);
	} else {
		ret = 1;
		Fdelete(glob.bname);
		mw_change(glob.change = FALSE);
		if (glob.tid >= 0)
			appl_send(glob.tid, THING_MSG, 0, AT_ILOAD, 0, 0, 0, 0);
	}
save_exit:
	if (glob.numassign)
		pfree(aslist);

	return (ret);
}

/**
 revert()

 Aenderungen verwerfen und Icons neu einlesen
 -------------------------------------------------------------------------*/
void revert(void) {
	short i;
	ICONINFO *icon;
	COMMENT *p, *q;

	if (frm_alert(1, rinfo.rs_frstr[ALREVERT], altitle, 1, 0L) != 1)
		return;

	/* aktuelle Zuweisungen verwerfen */
	for (i = 0; i < glob.numicon; i++) {
		icon = &glob.icon[i];
		while (icon->as)
			as_remove(icon, icon->as);
	}
	glob.numassign =
	glob.multiple =
	glob.missing =
	glob.illegal = 0;

	/* Kommentare verwerfen */
	for (p = glob.comments; p != NULL;) {
		q = p;
		p = p->next;
		pfree(q);
	}
	glob.comments = NULL;

	/* alte Zuweisungen laden */
	glob.done = !loadAssignments();
	mw_info();

	mw_change(glob.change = FALSE);
}

/**
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
			appl_send(glob.avid, AV_SENDKEY, 0, K_CTRL, 0x1107, 0, 0, 0);
	}
}

/**
 dl_quit()

 Ende
 -------------------------------------------------------------------------*/
void dl_quit(void) {
	short ok, exit;

	ok = 1;
	if (glob.change) {
		exit = frm_alert(1, rinfo.rs_frstr[ALQUIT], altitle, 1, 0L);
		if (exit == 1)
			ok = save();
		else if (exit == 3)
			return;

		ok = 1;
	}
	if (ok)
		glob.done = 1;
}

/**
 * dl_edit()
 *
 * Diese Routine wird aufgerufen, wenn man die Einstellungen fuer ein
 * Icon editieren moechte.
 * Sie bereitet den Dialog vor und oeffnet ihn.
 */
void dl_edit(void) {
	char *p;
	short extent[8];
	OBJECT *tree;

	if (fi_asedit.open) {
		if (glob.focus != edobj)
			mybeep();
		frm_restore(&fi_asedit);
		return;
	}

	edobj = glob.focus;
	edicon = &glob.icon[edobj - 1];

	tree = fi_asedit.tree;

	/* Icon im Dialog einsetzen */
	tree[AEICON].ob_type = glob.rtree[edobj].ob_type;
	tree[AEICON].ob_spec = glob.rtree[edobj].ob_spec;
	tree[AEICON].ob_width = glob.rtree[edobj].ob_width;
	tree[AEICON].ob_height = glob.rtree[edobj].ob_height;
	tree[AEICON].ob_x = (tree[AEICONBACK].ob_width - glob.rtree[edobj].ob_width) / 2;
	tree[AEICON].ob_y = (tree[AEICONBACK].ob_height - glob.rtree[edobj].ob_height) / 2;

	/* Weitere Vorbereitungen */
	vqt_extent(tb.vdi_handle, edicon->name, extent);
	tree[AENAME].ob_width = extent[2] - extent[0];
	tree[AENAME].ob_spec.free_string = edicon->name;

	/* Testen, ob es sich um ein Standardicon handelt */
	if (!strcmp(edicon->name, "TRASH"))
		p = rinfo.rs_frstr[TRTRASH];
	else if (!strcmp(edicon->name, clipboard))
		p = rinfo.rs_frstr[TRCLIP];
	else if (!strcmp(edicon->name, "FILESYS"))
		p = rinfo.rs_frstr[TRDRIVE];
	else if (!strcmp(edicon->name, "FILE"))
		p = rinfo.rs_frstr[TRFILE];
	else if (!strcmp(edicon->name, "APPL"))
		p = rinfo.rs_frstr[TRAPP];
	else if (!strcmp(edicon->name, "FOLDER"))
		p = rinfo.rs_frstr[TRFOLDER];
	else if (!strcmp(edicon->name, parentdir))
		p = rinfo.rs_frstr[TRPARENT];
	else if (!strcmp(edicon->name, "PRINTER"))
		p = rinfo.rs_frstr[TRPRINTER];
	else if (!strcmp(edicon->name, "DEVICE"))
		p = rinfo.rs_frstr[TRDEVICE];
	else if (!strcmp(edicon->name, "GROUP"))
		p = rinfo.rs_frstr[TRGROUP];
	else
		p = rinfo.rs_frstr[TRNONE];

	vqt_extent(tb.vdi_handle, p, extent);
	tree[AEREM].ob_width = extent[2] - extent[0];
	tree[AEREM].ob_spec.free_string = p;

	/* Liste der Zuordnungen aufbauen */
	if (!dl_editlist(edicon))
		return;

	lst_init(&li_asedit, 1, 1, 0, 0);

	frm_start(&fi_asedit, 1, 1, 0);
	if (fi_asedit.state == FST_WIN)
		avcWindowOpen(glob.avid, fi_asedit.win.handle);
}

void dl_freeas(ASINFO *as) {
	ASINFO *p;

	while (as != 0L) {
		p = as;
		as = as->next;
		pfree(p);
	}
}

short dl_editlist(ICONINFO *icon) {
	short num, i;
	ASINFO *as;

	edas = 0L;
	edlist = 0L;
	i = 0;

	/* Anzahl der Zuordnungen ermitteln */
	num = 0;
	as = icon->as;
	while (as) {
		num++;
		as = as->next;
	}

	edas = pmalloc(38L * MAX_ASSIGN);
	if (!edas) {
		frm_alert(1, rinfo.rs_frstr[ALNOMEM], altitle, 1, 0L);
		return 0;
	}
	edlist = pmalloc(sizeof(char *) * MAX_ASSIGN);
	if (!edlist) {
		pfree(edas);
		frm_alert(1, rinfo.rs_frstr[ALNOMEM], altitle, 1, 0L);
		return 0;
	}
	for (i = 0; i < MAX_ASSIGN; i++) {
		edlist[i] = &edas[i * 38];
		edlist[i][0] = 0;
	}

	/* Liste aufbauen */
	if (num > 0) {
		as = icon->as;
		i = 0;
		while (as) {
			edlist[i][0] = rinfo.rs_frstr[TXCLASS][as->class];
			edlist[i][1] = ' ';
			if (as->txt)
				edlist[i][2] = as->txt;
			else
				edlist[i][2] = ' ';
			edlist[i][3] = ' ';
			edlist[i][37] = 1 + (char) as->tcol;
			strcpy(&edlist[i][4], as->wildcard);
			as = as->next;
			i++;
		}
	}

	li_asedit.text = edlist;
	li_asedit.num = num + 1;
	li_asedit.offset = 0;
	li_asedit.sel = 0;

	dl_selinit(0);

	return (1);
}

void dl_selinit(short i) {
	OBJECT *tree;
	char txt = 0, *wild = "";
	short tcol = -1;

	tree = rinfo.rs_trindex[ASEDIT];

	if (edlist[i][0] == rinfo.rs_frstr[TXCLASS][1]) {
		unsetObjectSelected(tree, AEFILE);
		setObjectSelected(tree, AEFOLDER);
		unsetObjectSelected(tree, AEDRIVE);
	} else if (edlist[i][0] == rinfo.rs_frstr[TXCLASS][2]) {
		unsetObjectSelected(tree, AEFILE);
		unsetObjectSelected(tree, AEFOLDER);
		setObjectSelected(tree, AEDRIVE);
	} else {
		setObjectSelected(tree, AEFILE);
		unsetObjectSelected(tree, AEFOLDER);
		unsetObjectSelected(tree, AEDRIVE);
	}

	if (*edlist[i]) {
		if ((txt = edlist[i][2]) == ' ')
			txt = 0;
		tcol = edlist[i][37] - 1;
		wild = &edlist[i][4];
	}
	tree[AECHAR].ob_spec.tedinfo->te_ptext[0] = txt;

	pop_tcolor.sel = (tcol + 1) * 2 + 2;
	pop_set(&fi_asedit, &pop_tcolor);

	if (!fi_asedit.open)
		strcpy(tree[AEWILD].ob_spec.tedinfo->te_ptext, wild);
	else {
		frm_edstring(&fi_asedit, AEWILD, wild);
		frm_redraw(&fi_asedit, AEINFOBOX);
	}
}

void de_edit(short mode, short ret) {
	short done, exob;
	short d;
	short sel;
	short class;
	short ok;
	short i, onum;
	char txt, *wild;
	ASINFO *p,
	*as,
	*new;
	OBJECT *tree;
	ICONINFO *q;

	tree = rinfo.rs_trindex[ASEDIT];
	done = 0;

	sel = li_asedit.sel;

	if (!mode) {
		if (!lst_handle(&li_asedit, ret, &d)) {
			exob = fi_asedit.exit_obj;
			switch (exob) {
			case AEOK:
				if (changed == TRUE) {
					mw_change(glob.change = TRUE);

					/*
					 * Liste der Zuordnungen fuer dieses Icon neu 
					 * aufbauen und die alte Liste loeschen.
					 */
					for (onum = 0, as = edicon->as; as != 0L; as = as->next)
						onum++;
					as = 0L;
					for (i = li_asedit.num - 2; i >= 0; i--) {
						if ((new = pmalloc(sizeof(ASINFO))) == 0L) {
							dl_freeas (as);
							frm_alert(1, rinfo.rs_frstr[ALNOMEM], altitle, 1, 0L);
							break;
						}
						if (*edlist[i] == rinfo.rs_frstr[TXCLASS][0])
							new->class = 0;
						else if (*edlist[i] == rinfo.rs_frstr[TXCLASS][1])
							new->class = 1;
						else
							new->class = 2;
						if ((txt = edlist[i][2]) == ' ')
							txt = 0;
						new->txt = txt;
						new->tcol = edlist[i][37] - 1;
						strcpy(new->wildcard, &edlist[i][4]);
						new->prev = 0L;
						new->next = as;
						if (as)
							as->prev = new;
						as = new;
					}
					if (i >= 0)
						break;
					p = edicon->as;
					edicon->as = as;
					dl_freeas (p);
					glob.numassign += li_asedit.num - onum - 1;
					mw_info();
				}
			case AECANCEL:
				done = 1;
				break;
			case AECHANGE:
			case AEDELETE:
				wild = tree[AEWILD].ob_spec.tedinfo->te_ptext;
				obj_edit(tree, fi_asedit.edit_obj, 0, 0, &fi_asedit.edit_idx, ED_END, fi_asedit.win.handle);
				if ((exob == AEDELETE) || !*wild) {
					for (i = sel + 1; i < li_asedit.num; i++)
						strcpy(edlist[i - 1], edlist[i]);
					sel = -1;
				} else {
					if (isObjectSelected(tree, AEFILE))
						class = 0;
					else if (isObjectSelected(tree, AEFOLDER))
						class = 1;
					else
						class = 2;
					ok = 1;
					switch (class) {
					case 0:
					case 1:
						if (strpbrk(wild, ", "))
							ok = 0;
						break;
					case 2:
						if (wild[1] || !isalnum(*wild))
							ok = 0;
					}
					if (!ok) {
						frm_alert(1, rinfo.rs_frstr[ALILLEGAL], altitle, 1, 0L);
						de_edit_exit: fi_asedit.edit_idx = -1;
						obj_edit(tree, fi_asedit.edit_obj, 0, 0, &fi_asedit.edit_idx, ED_INIT, fi_asedit.win.handle);
						frm_redraw(&fi_asedit, AEWILD);
						frm_norm(&fi_asedit);
						break;
					}
					for (i = 0; i < (li_asedit.num - 1); i++) {
						if (i != li_asedit.sel) {
							if (!strcasecmp(&edlist[i][4], wild) &&
							(*edlist[i] == rinfo.rs_frstr[TXCLASS][class])) {
								break;
							}
						}
					}
					if (i != (li_asedit.num - 1)) {
						mybeep();
						goto de_edit_exit;
					}
					if (((q = as_findas(wild, class)) != NULL) && (q != edicon)) {
						sprintf(almsg, rinfo.rs_frstr[ALTWICE], wild, q->name);
						frm_alert(1, almsg, altitle, 1, 0L);
						goto de_edit_exit;
					}
					if (!*edlist[sel])
						li_asedit.sel++;
					edlist[sel][1] = edlist[sel][3] = ' ';
					*edlist[sel] = rinfo.rs_frstr[TXCLASS][class];
					if ((txt = *tree[AECHAR].ob_spec.tedinfo->te_ptext) == 0)
						txt = ' ';
					edlist[sel][2] = txt;
					edlist[sel][37] = pop_tcolor.sel / 2 - 1;
					strcpy(&edlist[sel][4], wild);
				}
				changed = TRUE;
				for (i = 0; (i < (MAX_ASSIGN - 1)) && *edlist[i]; i++)
					;
				li_asedit.num = i + 1;

				if (li_asedit.sel >= li_asedit.num)
					li_asedit.sel = li_asedit.num ? (li_asedit.num - 1) : 0;
				if (li_asedit.sel >= (li_asedit.offset + li_asedit.view))
					li_asedit.offset = li_asedit.sel - li_asedit.view + 1;
				if (li_asedit.num <= li_asedit.view)
					li_asedit.offset = 0;
				else {
					if ((li_asedit.offset + li_asedit.view) > li_asedit.num)
						li_asedit.offset = li_asedit.num - li_asedit.view;
				}

				fi_asedit.edit_idx = -1;
				obj_edit(tree, fi_asedit.edit_obj, 0, 0, &fi_asedit.edit_idx, ED_INIT, fi_asedit.win.handle);
				frm_redraw(&fi_asedit, AEWILD);
				lst_init(&li_asedit, 1, 1, 1, 1);
				fi_asedit.exit_obj = exob;
				frm_norm(&fi_asedit);
				break;
			}
		}

		if (sel != li_asedit.sel)
			dl_selinit(li_asedit.sel);
	} else
		done = 1;

	if (done) {
		if (fi_asedit.state == FST_WIN)
			avcWindowClose(glob.avid, fi_asedit.win.handle);
		frm_end(&fi_asedit);
		if (edlist)
			pfree(edlist);
		if (edas)
			pfree(edas);
	}
}

/**
 * dl_find
 *
 * Funktion zum Oeffnen des Suchen-Dialogs, wird als Reaktion auf das
 * Anwaehlen des entsprechenden Menuepunktes aufgerufen.
 *
 * Eingabe:
 * icon: Icon suchen (1) oder Zuordnung (0)
 */
void dl_find(short icon) {
	short nitems, i, j, max;
	char *q;
	ASINFO *p = NULL;

	/* Ist der Dialog schon offen? */
	if (fi_find.open) {
		if (icon != fstruct.icon)
			mybeep();
		frm_restore(&fi_find);
		return;
	}

	fstruct.icon = icon;
	/* Speicher fuer die Listeneintraege anfordern */
	nitems = icon ? glob.numicon : glob.numassign;
	if ((fstruct.listp = pmalloc(nitems * 36L + nitems * sizeof(char *)))
			== NULL) {
		frm_alert(1, rinfo.rs_frstr[ALNOMEM], altitle, 1, 0L);
		return;
	}
	fstruct.list = (char *) &fstruct.listp[nitems];

	/* Listeneintraege und Zeigerliste initialisieren */
	if (!icon) {
		j = 0;
		p = glob.icon[j].as;
	}
	for (i = 0; i < nitems; i++) {
		fstruct.listp[i] = &fstruct.list[i * 36L];
		if (icon)
			strcpy(fstruct.listp[i], glob.icon[i].name);
		else {
			while (p == NULL)
				p = glob.icon[++j].as;
			sprintf(fstruct.listp[i], "%-32s %c", p->wildcard, rinfo.rs_frstr[TXCLASS][p->class]);
			fstruct.listp[i][35] = p->class;
			p = p->next;
		}
	}
	for (i = nitems - 1; i >= 1; i--) {
		max = i;
		for (j = 0; j < i; j++) {
			if (strcmp(fstruct.listp[j], fstruct.listp[max]) > 0)
				max = j;
		}
		if (max != i) {
			q = fstruct.listp[max];
			fstruct.listp[max] = fstruct.listp[i];
			fstruct.listp[i] = q;
		}
	}

	/* Auswahlbox initialisieren */
	li_find.text = fstruct.listp;
	li_find.num = nitems;
	li_find.offset = 0;
	li_find.sel = 0;
	lst_init(&li_find, 1, 1, 0, 0);

	/* Dialog vorbereiten und oeffnen */
	setObjectText(fi_find.tree, FITITLE, rinfo.rs_frstr[icon ? TXSICON : TXSMASK]);
	strcpy(fi_find.tree[FITEXT].ob_spec.tedinfo->te_ptext, "");
	fi_find.userinfo = icon ? "%mfindic" : "%mfind";
	frm_start(&fi_find, 1, 1, 0);
	if (fi_find.state == FST_WIN)
		avcWindowOpen(glob.avid, fi_find.win.handle);
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
	OBJECT *tree;
	short done,
		dclick,
		exob, sel, i;
	char *p, tmp[33];
	ICONINFO *icon;

	tree = fi_find.tree;
	done = 0;

	sel = li_find.sel;

	if (!mode) {
		if (lst_handle(&li_find, ret, &dclick)) {
			if (dclick)
				done = FIOK;
		} else {
			exob = fi_find.exit_obj;
			switch (exob) {
			case FIOK:
				done = FIOK;
				break;
			case FICANCEL:
				done = FICANCEL;
				break;
			case FITEXT:
				p = tree[FITEXT].ob_spec.tedinfo->te_ptext;
				for (sel = 0; sel < li_find.num; sel++) {
					if (fstruct.icon) {
						if (!strncmp(fstruct.listp[sel], p, strlen(p)))
							break;
					} else {
						if (!strncasecmp(fstruct.listp[sel], p, strlen(p)))
							break;
					}
				}
				if (sel == li_find.num) {
					lst_select(&li_find, sel = -1);
					break;
				}
				if (sel == li_find.sel)
					break;
				if ((sel < li_find.offset) || (sel >= (li_find.offset + li_find.view))) {
					li_find.sel = sel;
					if ((li_find.offset = sel - li_find.view + 1) < 0)
						li_find.offset = 0;
					lst_init(&li_find, 1, 1, 1, 1);
				} else
					lst_select(&li_find, sel);
				break;
			}
		}

		if (sel != li_find.sel) {
			frm_edstring(&fi_find, FITEXT, fstruct.listp[li_find.sel]);
			frm_redraw(&fi_find, FITEXT);
		}
	} else
		done = 1;

	/* Ggf. Dialog schliessen und Speicher freigeben */
	if (done) {
		if (done == FIOK) {
			fi_find.exit_obj = FIOK;
			if ((sel = li_find.sel) == -1) {
				de_find_notfound: if (fstruct.icon)
					p = rinfo.rs_frstr[ALICONNOTFOUND];
				else
					p = rinfo.rs_frstr[ALMASKNOTFOUND];
				sprintf(almsg, p, tree[FITEXT].ob_spec.tedinfo->te_ptext);
				frm_alert(1, almsg, altitle, 1, 0L);
				frm_norm(&fi_find);
				return;
			} else {
				if (fstruct.icon) {
					p = fstruct.listp[sel];
					de_find_searchicon: for (i = 0; i < glob.numicon; i++) {
						if (!strcmp(glob.icon[i].name, p)) {
							ic_sel(i + 1);
							break;
						}
					}
					/* Paranoia */
					if (i == glob.numicon)
						goto de_find_notfound;
				} else {
					for (i = 0; (tmp[i] = fstruct.listp[sel][i]) != ' '; i++)
						;
					tmp[i] = 0;
					if ((icon = as_findas(tmp, fstruct.listp[sel][35])) == NULL)
						goto de_find_notfound;
					p = icon->name;
					goto de_find_searchicon;
				}
			}
		}
		if (done != -1)
			frm_norm(&fi_find);
		if (fi_find.state == FST_WIN)
			avcWindowClose(glob.avid, fi_find.win.handle);
		frm_end(&fi_find);
		pfree(fstruct.listp);
	}
}

/*-------------------------------------------------------------------------
 drag()

 Drag&Drop eines Icons - wird von handle_button() aufgerufen
 -------------------------------------------------------------------------*/
#ifdef DRAGDROP
void drag(short obj, short mx, short my) {
	short x, y, w, h,
	tx, ty,
	dx, dy;

	/*
	 * Nur ausfuehren, wenn AV-Server vorhanden und dieser
	 * AV_WHAT_IZIT kann.
	 */
	if (glob.avid != -1 && (glob.avflags & 0x0200)) {
		objc_offset(glob.rtree, obj, &x, &y);
		w = glob.rtree[obj].ob_width;
		h = glob.rtree[obj].ob_height;

		wind_update(BEG_UPDATE);
		wind_update(BEG_MCTRL);
		graf_mouse(FLAT_HAND, 0L);
		graf_dragbox(w, h, x, y, tb.desk.x, tb.desk.y, tb.desk.w, tb.desk.h, &tx, &ty);
		graf_mouse(ARROW, 0L);
		wind_update(END_UPDATE);
		wind_update(END_MCTRL);
		dx = tx - x;
		dy = ty - y;
		mx += dx;
		my += dy;

		/* Beim AV-Server anfragen, was sich an der Zielposition *
		 * befindet */
		appl_send(glob.avid, AV_WHAT_IZIT, 0, mx, my, 0, 0, 0);
	}
	else
		mybeep();
}
#endif

/*
 * drag_on_window
 *
 * Behandelt Drag&Drop auf ein Fenster von ThingIcn.
 *
 * Eingabe:
 * handle: Handle des betroffenen Fensters
 * mx: x-Position der Maus
 * my: y-Position der Maus
 * buf: Liste der erhaltenen Filenamen, durch Leerzeichen getrennt
 *      und ggf. gequotet
 */
void drag_on_window(short handle, short mx, short my, char *buf) {
	short i,
	assigns = 0,
	class,
	d,
	ks,
	obj;
	char *p, *r, *mask, fname[MAX_PLEN];
	ICONINFO *icon, *asicon;
	ASINFO *as, *q;

	graf_mkstate(&d, &d, &d, &ks);
	aesBuffer[MAX_AVLEN - 1] = 0;
	strncpy(aesBuffer, buf, MAX_AVLEN - 1);
	if (handle != glob.rwin->handle) {
		if (!fi_asedit.open || (handle != fi_asedit.win.handle)) {
			mybeep();
			return;
		}
		obj = edobj;
	} else {
		obj = objc_find(glob.rtree, ROOT, MAX_DEPTH, mx, my);
		if (fi_asedit.open && (obj == edobj))
			handle = fi_asedit.win.handle;
	}
	if ((obj < 1) || (obj > glob.numicon)) {
		mybeep();
		return;
	}
	icon = &glob.icon[obj - 1];
	if (handle == glob.rwin->handle) {
		for (q = icon->as; q != NULL; q = q->next)
			assigns++;
	}
	buf = aesBuffer;
	while (get_buf_entry(buf, fname, &buf)) {
		class = 0; /* Datei */
		p = strrchr(fname, '\\');
		if (p != NULL) {
			if (p <= (fname + 1)) {
				mybeep();
				continue;
			}
			if (!p[1]) {
				if (p[-1] == ':') {
					class = 2; /* Laufwerk */
					*fname = toupper(p[-2]);
					fname[1] = 0;
					p = fname;
				} else {
					class = 1; /* Ordner */
					*p = 0;
					p = strrchr(fname, '\\');
					if (p == NULL)
						p = fname;
					else
						p++;
				}
			} else
				p++;
		} else
			p = fname;
		if (ks && ((r = strrchr(p, '.')) != NULL) && (strlen(r) < 32)) {
			memmove(&fname[1], r, strlen(r) + 1);
			*(p = fname) = '*';
		}
		if (!*p || (strlen(p) > 32)) {
			mybeep();
			continue;
		}
		mask = p;
		strupr(mask);
		asicon = as_findas(mask, class);
		if (handle == glob.rwin->handle) {
			if (++assigns == MAX_ASSIGN) {
				mybeep();
				break;
			}
			if (asicon != NULL) {
				if (asicon != icon) {
					sprintf(almsg, rinfo.rs_frstr[ALREPLACE], mask,
							asicon->name);
					if (frm_alert(1, almsg, altitle, 1, 0L) != 1) {
						continue;
					}
				} else {
					mybeep();
					continue;
				}
			}
			if ((as = as_add(icon)) == NULL) {
				frm_alert(1, rinfo.rs_frstr[ALNOMEM], altitle, 1, 0L);
				break;
			}
			if (asicon != NULL) {
				for (q = asicon->as; q != NULL; q = q->next) {
					if (!strcasecmp(q->wildcard, mask)) {
						as_remove(asicon, q);
						break;
					}
				}
				glob.numassign--;
			}
			as->class = class;
			as->txt = 0;
			as->tcol = -1;
			strcpy(as->wildcard, mask);
			mw_change(glob.change = TRUE);
			glob.numassign++;
			mw_info();
		} else {
			if (asicon && (asicon != icon)) {
				sprintf(almsg, rinfo.rs_frstr[ALTWICE], mask, asicon->name);
				frm_alert(1, almsg, altitle, 1, 0L);
				continue;
			}
			for (i = 0; i < (MAX_ASSIGN - 1); i++) {
				if (!*edlist[i])
					break;
				if ((rinfo.rs_frstr[TXCLASS][class] == *edlist[i]) &&
				!strcasecmp(&edlist[i][4], mask)) {
					i = MAX_ASSIGN - 1;
					break;
				}
			}
			if (i == (MAX_ASSIGN - 1)) {
				mybeep();
				break;
			}
			edlist[i][0] =
			rinfo.rs_frstr[TXCLASS][class];
			edlist[i][1] = edlist[i][2] = edlist[i][3] = ' ';
			strcpy(&edlist[i][4], mask);
			edlist[i][37] = 0;
			changed = TRUE;
			li_asedit.num++;
			if (li_asedit.sel == (li_asedit.num - 2))
				dl_selinit(li_asedit.sel);
			lst_init(&li_asedit, 1, 1, 1, 1);
		}
	}
}

/**
 key_clr()

 L”scht noch anstehende Tastatur-Events um z.B. beim Scrollen von
 Fenstern ein "Nachlaufen" zu verhindern
 -------------------------------------------------------------------------*/
void key_clr(void) {
	EVENT event;
	short done;

	event.ev_mflags = MU_TIMER | MU_KEYBD;
	event.ev_mtlocount = 10;
	event.ev_mthicount = 0;
	done = 0;
	while (!done) {
		EvntMulti(&event);
		if (event.ev_mwich != MU_KEYBD)
			done = 1;
	}
}

/**
 handle_menu()

 Verarbeiten einer Menueauswahl
 Wird auch von handle_key() bei Shortcuts aufgerufen
 -------------------------------------------------------------------------*/
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
		case MSAVE:
			stguide = showSTGuideHelp(STGUIDEHELPFILE, "%msave");
			break;
		case MREVERT:
			stguide = showSTGuideHelp(STGUIDEHELPFILE, "%mrevert");
			break;
		case MNEXTWIN:
			stguide = showSTGuideHelp(STGUIDEHELPFILE, "%mnwin");
			break;
		case MQUIT:
			stguide = showSTGuideHelp(STGUIDEHELPFILE, "%mquit");
			break;
		case MEDITICON:
			stguide = showSTGuideHelp(STGUIDEHELPFILE, "%medit");
			break;
		case MFINDFILE:
			stguide = showSTGuideHelp(STGUIDEHELPFILE, "%mfind");
			break;
		case MFINDICON:
			stguide = showSTGuideHelp(STGUIDEHELPFILE, "%mfindic");
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
		case MSAVE:
			save();
			break;
		case MREVERT:
			revert();
			break;
		case MNEXTWIN:
			dl_nextwin();
			break;
		case MQUIT:
			dl_quit();
			break;
		case MEDITICON:
			dl_edit();
			break;
		case MFINDFILE:
			dl_find(0);
			break;
		case MFINDICON:
			dl_find(1);
			break;
		}
	}
	mn_tnormal(objectTree, title, 1);
	mn_update();
}

/**
 handle_win()

 Verarbeiten von Fensterereignissen
 -------------------------------------------------------------------------*/
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
		fi = (FORMINFO *)win->user;
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
		win_newtop(tb.topwin);
		mn_update();
		break;

	case WM_REDRAW:
		win_redraw(win, f1, f2, f3, f4);
		break;

	case WM_NEWTOP:
	case WM_ONTOP:
		win_newtop(win);
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

				default:
					dl_quit();
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
 handle_button()

 Verarbeiten von Mausklicks
 -------------------------------------------------------------------------*/
void handle_button(short mx, short my, short but, short ks, short br) {
	WININFO *win;
	short obj, focus;
	short x, y, lmx, lmy, lmk, lks, dx, dy;

	UNUSED(ks);

	/* Mausklick im Hauptfenster? */
	win = win_getwinfo(wind_find(mx, my));
	if (win != glob.rwin)
		return;

	if (mx < win->work.g_x || my < win->work.g_y || mx >= win->work.g_x + win->work.g_w || my >= win->work.g_y + win->work.g_h) {
		return;
	}

	/* Maustaste immer noch gedrueckt? */
	wind_update (BEG_MCTRL);
	evnt_timer(100L);
	graf_mkstate(&lmx, &lmy, &lmk, &lks);
	wind_update (END_MCTRL);

	switch (but) {
	case 1: /* Linke Maustaste */
		handle_button1: if (tb.topwin == glob.rwin) {
			/* Objekt? */
			obj = objc_find(glob.rtree, ROOT, MAX_DEPTH, mx, my);
			if (obj >= 1 && obj <= glob.numicon) {
				focus = glob.focus;
				ic_sel(obj);

				/* Maustaste immer noch gedrueckt - Drag&Drop */
				if (lmk & 3) {
#ifdef DRAGDROP
					/* Drag&Drop */
					drag(obj, lmx, lmy);
#else
					evnt_button(1, 3, 0, &lmx, &lmy, &lmk, &lks);
#endif
				} else
				/* Bei Doppelklick oder Klick auf selektiertes * Icon
				 * ”ffnen */
				{
					if (br == 2 || obj == focus)
						dl_edit();
				}
			} else
				ic_sel(0);
		}
		break;

	case 2: /* Rechte Maustaste */
		if (lmk & 3) /* Gedrueckte Maustaste - *
		 * 'Realtime'-Scroll */
		{
			x = lmx;
			y = lmy;
			wind_update(BEG_MCTRL);
			graf_mouse(FLAT_HAND, 0L);
			while (lmk & 3) {
				dx = lmx - x;
				dy = lmy - y;
				dx *= glob.scroll;
				dy *= glob.scroll;
				if (dx != 0 || dy != 0) {
					win_slide(win, S_PABS, dx, dy);
					x = lmx;
					y = lmy;
				}
				graf_mkstate(&lmx, &lmy, &lmk, &lks);
			}
			graf_mouse(ARROW, 0L);
			wind_update(END_MCTRL);
		} else /* Einfacher Rechts-Klick */
		{
			if (glob.rclick) {
				but = 1;
				br = 2;
				goto handle_button1;
			} else {
				if (tb.topwin != glob.rwin) {
					win_top(glob.rwin);
					magx_switch(tb.app_id, 0);
				}
			}
		}
		break;
	}
}

/**
 handle_key()

 Verarbeiten von Tastatureingaben
 -------------------------------------------------------------------------*/
void handle_key(short ks, short kr) {
	unsigned short key;
	short title, item, skey;

	key = normkey(ks, kr);
	key &= ~(NKF_CAPS | NKF_RESVD); /* Nicht ben”tigte Flags *
	 * ausmaskieren */
	if (key & NKF_LSH || key & NKF_RSH)
		key |= NKF_SHIFT; /* Shift-Status */

	/* Pruefen, ob Menue-Shortcut vorliegt */
	if (menu_key(rinfo.rs_trindex[MAINMENU], key, &title, &item)) {
		/* Shortcut vorhanden, Menuehandling ausfuehren */
		handle_menu(title, item, 0);
	} else
	/* Kein Shortcut, normale Verarbeitung */
	{
		skey = 0; /* Flag fuer AV_SENDKEY */
		if (key == (NKF_FUNC | NK_HELP)) {
			if (!tb.topfi)
				if (!showSTGuideHelp(STGUIDEHELPFILE, "%I"))
					frm_alert(1, rinfo.rs_frstr[ALNOGUIDE], altitle, 1, 0L);
		} else {
			if (!(glob.rwin->state & WSICON) && tb.topwin == glob.rwin) {
				if (!glob.focus) {
					switch (key) {
					case NKF_FUNC | NK_INS:
						ic_sel(1);
						break;
					case NKF_FUNC | NK_UP:
						win_slide(tb.topwin, S_REL, 0, -1);
						key_clr();
						break;
					case NKF_FUNC | NK_DOWN:
						win_slide(tb.topwin, S_REL, 0, 1);
						key_clr();
						break;
					case NKF_FUNC | NK_LEFT:
						win_slide(tb.topwin, S_REL, -1, 0);
						key_clr();
						break;
					case NKF_FUNC | NK_RIGHT:
						win_slide(tb.topwin, S_REL, 1, 0);
						key_clr();
						break;
					case NKF_FUNC | NKF_SHIFT | NK_UP:
						win_slide(tb.topwin, S_REL, 0, -2);
						key_clr();
						break;
					case NKF_FUNC | NKF_SHIFT | NK_DOWN:
						win_slide(tb.topwin, S_REL, 0, 2);
						key_clr();
						break;
					case NKF_FUNC | NKF_SHIFT | NK_LEFT:
						win_slide(tb.topwin, S_REL, -2, 0);
						key_clr();
						break;
					case NKF_FUNC | NKF_SHIFT | NK_RIGHT:
						win_slide(tb.topwin, S_REL, 2, 0);
						key_clr();
						break;
					case NKF_FUNC | NK_CLRHOME:
						win_slide(tb.topwin, S_ABS, 0, 0);
						break;
					case NKF_FUNC | NKF_SHIFT | NK_CLRHOME:
						win_slide(tb.topwin, S_ABS, 0, 1000);
						break;
					default:
						skey = 1;
					}
				} else {
					switch (key) {
					case NKF_FUNC | NK_INS:
						ic_sel(0);
						break;
					case NKF_FUNC | NK_UP:
						ic_move(-2);
						break;
					case NKF_FUNC | NK_DOWN:
						ic_move(2);
						break;
					case NKF_FUNC | NK_LEFT:
						ic_move(-1);
						break;
					case NKF_FUNC | NK_RIGHT:
						ic_move(1);
						break;
					case NKF_FUNC | NKF_SHIFT | NK_UP:
						ic_move(-20);
						break;
					case NKF_FUNC | NKF_SHIFT | NK_DOWN:
						ic_move(20);
						break;
					case NKF_FUNC | NKF_SHIFT | NK_LEFT:
						ic_move(-1);
						break;
					case NKF_FUNC | NKF_SHIFT | NK_RIGHT:
						ic_move(1);
						break;
					case NKF_FUNC | NK_CLRHOME:
						ic_sel(1);
						break;
					case NKF_FUNC | NKF_SHIFT | NK_CLRHOME:
						ic_sel(glob.numicon);
						break;
					case NKF_FUNC | NK_RET:
						dl_edit();
						break;
					default:
						skey = 1;
					}
				}
			} else
				skey = 1;
		}
		if (skey) /* Ggf. AV_SENDKEY */
		{
			if (glob.avid >= 0 && (glob.avflags & 0x0001))
				appl_send(glob.avid, AV_SENDKEY, 0, ks, kr, 0, 0, 0);
		}
	}
}

/**
 handle_fmsg()

 Wird von der GEM-Toolbox fuer die Bearbeitung einer unbekannten
 AES-Message waehrend eines modalen Fensterdialogs aufgerufen
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
			} else {
				/* Nein - alles klar */
				glob.done = 0;
			}

		case MN_SELECTED:
			mn_tnormal(rinfo.rs_trindex[MAINMENU], mevent->ev_mmgpbuf[3], mevent->ev_mmgpbuf[4]);
			frm_alert(1, rinfo.rs_frstr[ALWDIAL], altitle, 1, 0L);
			break;

		case AP_DRAGDROP:
			ddnak(mevent);
			break;

		case VA_START:
			mybeep();
			magx_switch(tb.app_id, 0);
			break;
		}
	}

	if (mevent->ev_mwich & MU_KEYBD && fi) {
		if (fi->normkey == (NKF_FUNC | NK_HELP) && fi->userinfo) {
			if (fi->state == FST_WIN)
				if (!showSTGuideHelp(STGUIDEHELPFILE, fi->userinfo))
					frm_alert(1, rinfo.rs_frstr[ALNOGUIDE], altitle, 1, 0L);
			else
				frm_alert(1, rinfo.rs_frstr[ALNOWDIAL], altitle, 1, 0L);
		}
	}
}

/**
 w_...()

 Routinen fuer das Hauptfenster
 -------------------------------------------------------------------------*/
void w_draw(WININFO * win) {
	if (win->state & WSOPEN) {
		appl_send(tb.app_id, WM_REDRAW, 0, win->handle, win->work.g_x, win->work.g_y, win->work.g_w, win->work.g_h);
	}
}

void w_showsel(void) {
	short sx, sy;
	GRECT wrect, irect;

	if (!glob.focus)
		return;

	objc_offset(glob.rtree, glob.focus, &irect.g_x, &irect.g_y);
	irect.g_w = glob.rtree[glob.focus].ob_width;
	irect.g_h = glob.rtree[glob.focus].ob_height;

	/* Fensterarbeitsbereich */
	wrect.g_x = glob.rwin->work.g_x;
	wrect.g_y = glob.rwin->work.g_y;
	wrect.g_w = glob.rwin->work.g_w;
	wrect.g_h = glob.rwin->work.g_h;

	/* Scroll */
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
	if (sx != 0 || sy != 0)
		win_slide(glob.rwin, S_PABS, sx, sy);
}

void w_update(struct wininfo *win) {
	short mx, my, w, h;

	mx = (glob.rwin->work.g_w - 4) / glob.iw;
	if (mx < 1)
		mx = 1;
	my = (glob.rwin->work.g_h - 4) / glob.ih;
	if (my < 1)
		my = 1;
	if (mx != glob.mx) {
		glob.mx = mx;
		ic_tree();
		w_draw(win);
		win_slide(win, S_INIT, 0, 0);
	}
	glob.my = my;

	glob.rtree->ob_x = win->work.g_x - glob.offx;
	glob.rtree->ob_y = win->work.g_y - glob.offy;
	w = glob.mx * glob.iw + 4;
	if (w < glob.rwin->work.g_w)
		w = glob.rwin->work.g_w;
	h = glob.ny * glob.ih + 4;
	if (h < glob.rwin->work.g_h)
		h = glob.rwin->work.g_h;
	glob.rtree->ob_width = w;
	glob.rtree->ob_height = h;
}

void w_prepare(struct wininfo *win) {
	UNUSED(win);
}

void w_redraw(struct wininfo *win, GRECT * area) {
	UNUSED(win);

	objc_draw(glob.rtree, ROOT, MAX_DEPTH, area->g_x, area->g_y, area->g_w, area->g_h);
}

void w_slide(struct wininfo *win, short mode, short h, short v) {
	long hsize, vsize, hpos, vpos;
	short dx, dy, lv, lh, offx, offy;

	switch (mode) {
	case S_INIT:
		/* Gr”sse der Slider */
		hsize = (long) win->work.g_w * 1000L / (long) glob.rtree->ob_width;
		vsize = (long) win->work.g_h * 1000L / (long) glob.rtree->ob_height;
		/* Offset anpassen */
		offx = glob.offx;
		offy = glob.offy;
		if (glob.rtree->ob_width - offx < win->work.g_w) {
			offx = glob.rtree->ob_width - win->work.g_w;
			if (offx < 0)
				offx = 0;
		}
		if (glob.rtree->ob_height - offy < win->work.g_h) {
			offy = glob.rtree->ob_height - win->work.g_h;
			if (offy < 0)
				offy = 0;
		}
		if (offx != glob.offx || offy != glob.offy) {
			dx = glob.offx - offx;
			dy = glob.offy - offy;
			glob.offx = offx;
			glob.offy = offy;
			w_draw(win);
		}
		/* Slider-Positionen berechnen */
		if (glob.rtree->ob_width > win->work.g_w)
			hpos = (long) glob.offx * 1000L / (long) (glob.rtree->ob_width - win->work.g_w);
		else
			hpos = 0;
		if (glob.rtree->ob_height > win->work.g_h)
			vpos = (long) glob.offy * 1000L / (long) (glob.rtree->ob_height - win->work.g_h);
		else
			vpos = 0;
		/* Slider setzen */
		if (win->flags & HSLIDE) {
			wind_set(win->handle, WF_HSLIDE, (short) hpos, 0 , 0, 0);
			wind_set(win->handle, WF_HSLSIZE, (short) hsize, 0 , 0, 0);
		}
		wind_set(win->handle, WF_VSLIDE, (short) vpos, 0 , 0, 0);
		wind_set(win->handle, WF_VSLSIZE, (short) vsize, 0 , 0, 0);
		break;
	case S_ABS:
		/* Offset umrechnen */
		if (h != -1) {
			if (glob.rtree->ob_width > win->work.g_w)
				offx = (short) ((long) (glob.rtree->ob_width - win->work.g_w) * (long) h / 1000L);
			else
				offx = 0;
		} else
			offx = glob.offx;
		if (v != -1) {
			if (glob.rtree->ob_height > win->work.g_h)
				offy = (short) ((long) (glob.rtree->ob_height - win->work.g_h) * (long) v / 1000L);
			else
				offy = 0;
		} else
			offy = glob.offy;
		/* Und setzen */
		if (offx != glob.offx || offy != glob.offy) {
			dx = glob.offx - offx;
			dy = glob.offy - offy;
			glob.offx = offx;
			glob.offy = offy;
			win_scroll(win, dx, dy);
			win_slide(win, S_INIT, 0, 0);
		}
		break;
	case S_REL:
		lh = lv = 0;
		switch (h) {
		case -1:
			lh = 16;
			break;
		case -2:
			lh = win->work.g_w;
			break;
		case 1:
			lh = -16;
			break;
		case 2:
			lh = -win->work.g_w;
			break;
		}
		switch (v) {
		case -1:
			lv = 16;
			break;
		case -2:
			lv = win->work.g_h;
			break;
		case 1:
			lv = -16;
			break;
		case 2:
			lv = -win->work.g_h;
			break;
		}
	case S_PABS:
		if (mode == S_PABS) {
			lh = h;
			lv = v;
		}
		offx = glob.offx;
		offy = glob.offy;
		if (glob.rtree->ob_width > win->work.g_w) {
			offx -= lh;
			if (offx > glob.rtree->ob_width - win->work.g_w)
				offx = glob.rtree->ob_width - win->work.g_w;
			if (offx < 0)
				offx = 0;
		}
		if (glob.rtree->ob_height > win->work.g_h) {
			offy -= lv;
			if (offy > glob.rtree->ob_height - win->work.g_h)
				offy = glob.rtree->ob_height - win->work.g_h;
			if (offy < 0)
				offy = 0;
		}
		if (offx != glob.offx || offy != glob.offy) {
			dx = glob.offx - offx;
			dy = glob.offy - offy;
			glob.offx = offx;
			glob.offy = offy;
			win_scroll(win, dx, dy);
			win_slide(win, S_INIT, 0, 0);
		}
		break;
	}
}

/**
 ic_...()

 Icon-Funktionen
 -------------------------------------------------------------------------*/
/**
 * Plaziert die Icons im Fenster neu. Wird beim Oeffnen des Icon-
 * fensters und bei Groessenaenderungen aufgerufen.
 */
void ic_tree(void) {
	short x, y, nx, ny, i;
	OBJECT *tree;

	x = y = 4;
	nx = ny = 0;

	tree = glob.rtree + 1;
	for (i = 1; i <= glob.numicon; i++, tree++) {
		tree->ob_x = x + (glob.iw - tree->ob_width) / 2;
		tree->ob_y = y;
		x += glob.iw;
		nx++;
		if (nx >= glob.mx) {
			nx = 0;
			x = 4;
			y += glob.ih;
			ny++;
		}
	}
	if (nx > 0)
		ny++;
	glob.ny = ny;
}

/**
 * Zeichnet den Focus um ein Icon.
 */
void ic_fdraw(void) {
	short x, y, w, h, pxy[10], cxy[4];
	GRECT area, box;
	short whandle;

	if (glob.rwin->state & WSICON)
		return;

	objc_offset(glob.rtree, glob.focus, &x, &y);
	w = glob.rtree[glob.focus].ob_width;
	h = glob.rtree[glob.focus].ob_height;

	whandle = glob.rwin->handle;

	pxy[0] = pxy[6] = pxy[8] = x;
	pxy[1] = pxy[3] = pxy[9] = y;
	pxy[2] = pxy[4] = pxy[0] + w - 1;
	pxy[5] = pxy[7] = pxy[1] + h - 1;
	pxy[9]++;

	/* Zeichnen unter Beachtung der Rechteckliste */
	vsl_color(tb.vdi_handle, 1);
	vsl_type(tb.vdi_handle, 1);
	vsl_width(tb.vdi_handle, 1);
	vswr_mode(tb.vdi_handle, MD_XOR);

	wind_update (BEG_UPDATE);
	graf_mouse(M_OFF, 0L);

	area.g_x = tb.desk.g_x;
	area.g_y = tb.desk.g_y;
	area.g_w = tb.desk.g_w;
	area.g_h = tb.desk.g_h;

	/* Ersten Eintrag in der Rechteckliste holen */
	wind_get(whandle, WF_FIRSTXYWH, &box.g_x, &box.g_y, &box.g_w, &box.g_h);

	/* Rechteckliste abarbeiten */
	while (box.g_w && box.g_h) {
		/* Nur durchfuehren, wenn Rechteck innerhalb des zu zeichnenden Bereichs liegt */
		if (rc_intersect(&area, &box)) {
			cxy[0] = box.g_x;
			cxy[1] = box.g_y;
			cxy[2] = cxy[0] + box.g_w - 1;
			cxy[3] = cxy[1] + box.g_h - 1;
			vs_clip(tb.vdi_handle, 1, cxy);
			v_pline(tb.vdi_handle, 5, pxy);
		}
		/* Naechstes Rechteck holen */
		wind_get(whandle, WF_NEXTXYWH, &box.g_x, &box.g_y, &box.g_w, &box.g_h);
	}
	vs_clip(tb.vdi_handle, 0, cxy);
	vswr_mode(tb.vdi_handle, MD_REPLACE);

	graf_mouse(M_ON, 0L);
	wind_update (END_UPDATE);
}

/**
 * Deselektiert bisheriges, selektiert aktuelles Icon und zeichnet
 * diese neu.
 */
void ic_sel(short obj) {
	short x, y, w, h;

	if (obj != glob.focus) {
		/* Anderes, als bisher? */
		if (glob.fdraw) {
			ic_fdraw();
			glob.fdraw = 0;
		}
		/* Bisheriges Objekt deselektieren */
		if (glob.focus) {
			glob.rtree[glob.focus].ob_state &= ~SELECTED;
			objc_offset(glob.rtree, glob.focus, &x, &y);
			w = glob.rtree[glob.focus].ob_width;
			h = glob.rtree[glob.focus].ob_height;
			win_redraw(glob.rwin, x, y, w, h);
		}
		/* Neues Objekt selektieren */
		if (glob.numicon)
			glob.focus = obj;
		else
			glob.focus = 0;
		if (glob.focus) {
			glob.rtree[glob.focus].ob_state |= SELECTED;
			objc_offset(glob.rtree, glob.focus, &x, &y);
			w = glob.rtree[glob.focus].ob_width;
			h = glob.rtree[glob.focus].ob_height;
			win_redraw(glob.rwin, x, y, w, h);
			w_showsel();
		}
	}
	mn_update();
}

void ic_move(short dir) {
	short obj;

	obj = glob.focus;

	switch (dir) {
	case -1:
		obj--;
		if (obj < 1)
			obj = 1;
		break;
	case 1:
		obj++;
		if (obj > glob.numicon)
			obj = glob.numicon;
		break;
	case -2:
		obj -= glob.mx;
		if (obj < 1)
			obj = 1;
		break;
	case 2:
		obj += glob.mx;
		if (obj > glob.numicon)
			obj = glob.numicon;
		break;
	case -20:
		obj -= (glob.mx * (glob.my - 1));
		if (obj < 1)
			obj = 1;
		break;
	case 20:
		obj += (glob.mx * (glob.my - 1));
		if (obj > glob.numicon)
			obj = glob.numicon;
		break;
	}

	ic_sel(obj);
}

/**
 as_...()

 Verwaltung der Zuordnungen
 -------------------------------------------------------------------------*/
ASINFO *as_add(ICONINFO *icon) {
	ASINFO *as, *lptr;

	/* Speicher reservieren */
	as = pmalloc(sizeof(ASINFO));
	if (!as)
		return 0L;

	/* Listenverkettung */
	as->next = 0L;
	if (!icon->as) {
		icon->as = as;
		as->prev = 0L;
	} else {
		lptr = icon->as;
		while (lptr->next)
			lptr = lptr->next;
		lptr->next = as;
		as->prev = lptr;
	}

	return (as);
}

void as_remove(ICONINFO *icon, ASINFO *as) {
	ASINFO *prev, *next;

	/* Listenverkettung aufl”sen */
	prev = as->prev;
	next = as->next;
	if (!prev)
		icon->as = next;
	else
		prev->next = next;
	if (next)
		next->prev = prev;

	/* Speicher freigeben */
	pfree(as);
}

ICONINFO *as_findic(char *name) {
	ICONINFO *icon;
	short i;

	i = 0;
	icon = 0L;
	while (i < glob.numicon && !icon) {
		if (!strcmp(glob.icon[i].name, name)) {
			icon = &glob.icon[i];
			break;
		}
		i++;
	}

	return (icon);
}

/**
 * as_findas
 *
 * Findet das Icon, dem eine bestimmte Wildcard zugeordnet ist.
 *
 * Eingabe:
 * wildcard: Zu suchende Wildcard
 * class: Zu suchende Zuordnungsklasse
 *
 * Rueckgabe:
 * 0L: Kein passendes Icon gefunden
 * sonst: Zeiger auf ICONINFO-Struktur des gefundenen Icons
 */
ICONINFO *as_findas(char *wildcard, short class) {
	ICONINFO *icon;
	ASINFO *as;
	short i;

	for (icon = 0L, i = 0; i < glob.numicon; i++) {
		for (as = glob.icon[i].as; as != 0L; as = as->next) {
			if ((class == as->class) && !strcasecmp(as->wildcard, wildcard)) {
				icon = &glob.icon[i];
			}
		}
		if (icon != 0L)
			break;
	}
	return (icon);
}

/**
 mw_...()

 Funktionen fuer das Hauptfenster
 -------------------------------------------------------------------------*/
/* Infozeile aktualisieren */
void mw_info(void) {
	sprintf(glob.rwin->info, rinfo.rs_frstr[WINFO], glob.numicon,
			glob.numassign);
	if (glob.rwin->state & WSOPEN)
		win_updtinfo(glob.rwin);
}

void mw_change(short changed) {
	if (glob.rwin) {
		strcpy(glob.rwin->name, rinfo.rs_frstr[changed ? WTITLEC : WTITLE]);
		win_updtinfo(glob.rwin);
	}
	mn_update();
}

/* Strukturen initialisieren, Fenster ”ffnen */
short mw_init(void) {
	short ret, w, h, i;
	OBJECT *obj;

	/* Platz fuer Zuweisungen reservieren */
	glob.icon = pmalloc(sizeof(ICONINFO) * (long) glob.numicon);
	if (!glob.icon) {
		frm_alert(1, rinfo.rs_frstr[ALNOMEM], altitle, 1, 0L);
		return (0);
	}

	/* Zuweisungen initialisieren */
	for (i = 0; i < glob.numicon; i++) {
		obj = &glob.rtree[i + 1];
		if (obj->ob_type == G_ICON) {
			glob.icon[i].name = obj->ob_spec.iconblk->ib_ptext;
		} else {
			glob.icon[i].name = ((DRAW_CICON *) obj->ob_spec.userblk->ub_parm)->original->monoblk.ib_ptext;
		}
		glob.icon[i].as = 0L;
	}
	parentdir = "PARENTDIR";
	clipboard = "CLIPBOARD";
	if (!as_findic(parentdir) && as_findic("_PARENT"))
		parentdir = "_PARENT";
	if (!as_findic(clipboard) && as_findic("_CLIPBRD"))
		clipboard = "_CLIPBRD";

	/* Zuweisungen laden */
	glob.rwin = NULL;
	if (!loadAssignments())
		return (0);

	/* Fenster einrichten */
	glob.rwin = pmalloc(sizeof(WININFO));
	if (!glob.rwin) {
		frm_alert(1, rinfo.rs_frstr[ALNOMEM], altitle, 1, 0L);
		return (0);
	}
	glob.rwin->flags = NAME | INFO | CLOSER | MOVER | FULLER | SIZER | UPARROW | DNARROW | VSLIDE; /* |LFARROW|RTARROW|HSLIDE; */
	if (tb.sys & SY_MAGX)
		glob.rwin->flags |= BACKDROP;
	if (tb.sys & SY_ICONIFY)
		glob.rwin->flags |= SMALLER;
	glob.rwin->state = WSDESKSIZE | WSFULLOPEN;

	glob.rwin->class = WCFILE;
	glob.rwin->user = 0L;
	glob.rwin->update = w_update;
	glob.rwin->prepare = w_prepare;
	glob.rwin->redraw = w_redraw;
	glob.rwin->slide = w_slide;
	glob.rwin->ictree = rinfo.rs_trindex[ICONGRP];
	*glob.rwin->name = 0;
	*glob.rwin->info = 0;
	ret = win_open(glob.rwin, 0);
	if (ret) {
		glob.rwin->state &= ~WSFULL;
		w = h = (short) sqrt((double) glob.numicon);
		if ((w * h) < glob.numicon) {
			w++;
			if ((w * h) < glob.numicon)
				h++;
		}
		if ((4 + w * glob.iw) > glob.rwin->work.g_w) {
			w = (glob.rwin->work.g_w - 4) / glob.iw;
			h = (glob.numicon + w - 1) / w;
		}
		if ((4 + h * glob.ih) > glob.rwin->work.g_h)
			h = (glob.rwin->work.g_h - 4) / glob.ih;
		w *= glob.iw;
		w += 4;
		h *= glob.ih;
		h += 4;
		if (w < 64)
			w = 64;
		if (h < 64)
			h = 64;
		glob.rwin->work.g_w = w;
		glob.rwin->work.g_h = h;
		wind_calc(WC_BORDER, glob.rwin->flags, glob.rwin->work.g_x,
				glob.rwin->work.g_y, w, h, &glob.rwin->curr.g_x, &glob.rwin->curr.g_y,
				&glob.rwin->curr.g_w, &glob.rwin->curr.g_h);
		strcpy(glob.rwin->name, rinfo.rs_frstr[glob.change ? WTITLEC : WTITLE]);
		mw_info();
		win_updtinfo(glob.rwin);
		glob.mx = (w - 4) / glob.iw;
		if (glob.mx < 1)
			glob.mx = 1;
		glob.my = (h - 4) / glob.ih;
		if (glob.my < 1)
			glob.my = 1;
		ic_tree();
		win_open(glob.rwin, 1 | (glob.autoplace * 0x8000) | (glob.interactive * 0x4000));
		avcWindowOpen(glob.avid, glob.rwin->handle);
		return (1);
	} else {
		pfree(glob.rwin);
		glob.rwin = 0L;
		return (0);
	}
}

short loadAssignments(void) {
	short i, j, l,
	class, tcol;
	FILE *fh;
	char inbuf[1024];
	char iconName[MAX_FLEN], imask[MAX_FLEN];
	unsigned long *id;
	char *p, *t, tchar;
	ICONINFO *icon;
	ASINFO *as;

	id = (unsigned long *) &inbuf[0];
	fh = fopen(glob.iname, "r");
	if (fh) {
		while (!feof(fh)) {
			if (fgets(inbuf, 1024, fh)) {
				p = strrchr(inbuf, 0) - 1;
				if (p > inbuf) {
					if (*p == '\n') {
						*p = 0;
						if (((p - 1) > inbuf) && (p[-1] == '\r'))
							p[-1] = 0;
					}
				}
				/* Kommentare ignorieren */
				if (inbuf[0] == '#')
					continue;
				class = -1;
				if (*id == 'IFIL')
					class = 0;
				if (*id == 'IFLD')
					class = 1;
				if (*id == 'IDRV')
					class = 2;
				if (class == -1) {
					if (!add_comment(inbuf)) {
						fclose(fh);
						return (0);
					}
					glob.illegal++;
					continue;
				}

				/* Icon ermitteln */
				p = get_text(inbuf, iconName, MAX_FLEN - 1);
				icon = as_findic(iconName);

				/* Alles weitere nur, wenn Icon existiert */
				if (icon) {
					/* Text-Kennzeichen holen */
					tchar = 0;
					tcol = -1;
					t = strrchr(inbuf, 0);
					if (t[-1] == 10)
						t[-1] = 0;
					t = strrchr(inbuf, ' ');
					if ((t != NULL) && (t > p) && t[1]) {
						l = (short) (t - inbuf) + 1;
						i = l - 1;
						while (inbuf[i] == ' ')
							i--;
						if ((inbuf[i] != ',') && (inbuf[i] != '\042')) {
							t = &inbuf[l];
							tchar = *t;
							if ((*t == '/') && isdigit(t[1]))
								tchar = 0;
							else
								t++;
							if ((*t == '/') && isdigit(t[1]))
								tcol = atoi(&t[1]) & 15;
							inbuf[l - 1] = 0;
						}
					}

					/* Icon-Zuordnungen einfuegen */
					i = 0;
					while (p[i]) {
						j = 0;
						while (p[i] == ' ')
							i++;
						while (p[i] != ',' && p[i] != ' ' && p[i]) {
							if (p[i] != 10 && p[i] != 13 && j < MAX_FLEN - 1) {
								imask[j] = nkc_toupper(p[i]);
								j++;
							}
							i++;
						}
						if (p[i] == ',')
							i++;
						imask[j] = 0;
						if (j > 0) {
							/* Zuordnung eindeutig? */
							if (as_findas(imask, class) != 0L) {
								if (!add_comment(inbuf)) {
									fclose(fh);
									return (0);
								}
								sprintf(almsg, rinfo.rs_frstr[ALTWICE], imask, as_findas(imask, class)->name);
								frm_alert(1, almsg, altitle, 1, 0L);
								glob.multiple++;
							} else {
								/* Zuordnung einfuegen */
								as = as_add(icon);
								if (as) {
									as->class = class;
									as->txt = tchar;
									as->tcol = tcol;
									strcpy(as->wildcard, imask);
									glob.numassign++;
								} else {
									/*
									 * Fehlerbehandlung: 
									 * Kein Platz mehr fuer Zuordnung
									 */
									fclose(fh);
									frm_alert(1, rinfo.rs_frstr[ALNOMEM], altitle, 1, 0L);
									return (0);
								}
							}
						}
					}
				} else {
					/* Fehlerbehandlung: Icon nicht gefunden */
					if (!add_comment(inbuf)) {
						fclose(fh);
						return (0);
					}
					sprintf(almsg, rinfo.rs_frstr[ALICONMISS], iconName);
					frm_alert(1, almsg, altitle, 1, 0L);
					glob.missing++;
				}
			}
		}
		fclose(fh);
		if (glob.multiple)
			frm_alert(1, rinfo.rs_frstr[ALMULTI], altitle, 1, 0L);
		if (glob.illegal) {
			mw_change(glob.change = TRUE);
			frm_alert(1, rinfo.rs_frstr[ALILLLINES], altitle, 1, 0L);
		}
		if (glob.missing)
			mw_change(glob.change = TRUE);
	}
	return (1);
}

void mw_exit(void) {
	short i;
	ICONINFO *icon;

	if (glob.rwin) {
		avcWindowClose(glob.avid, glob.rwin->handle);
		win_close(glob.rwin);
		pfree(glob.rwin);
	}
	if (glob.icon) {
		for (i = 0; i < glob.numicon; i++) {
			icon = &glob.icon[i];
			while (icon->as)
				as_remove(icon, icon->as);
		}
		pfree(glob.icon);
	}
}

#if 0
/**
 get_text()

 Wird von mw_init() verwendet um Strings, die von Anfuehrungszeichen
 umschlossen sind, einzulesen.
 Als Ergebnis wird ein Zeiger auf die erste Position hinter dem
 zweiten Anfuehrungszeichen (einschliesslich einer Leerstelle
 Zwischenraum) geliefert.
 -------------------------------------------------------------------------*/
char *get_text(char *str, char *buf, short maxlen) {
	short i, j, p, done;
	short val;
	char vbuf[4];

	i = 0;
	while (str[i] != '"' && str[i] != 0)
		i++;
	buf[0] = 0;
	if (!str[i])
		return buf;
	i++;
	p = 0;
	done = 0;
	while (!done) {
		switch (str[i]) {
		case '"':
		case 0:
			done = 1;
			break;
		case '@':
			j = 0;
			i++;
			while (str[i] >= '0' && str[i] <= '9' && j < 2) {
				vbuf[j] = str[i];
				j++;
				i++;
			}
			vbuf[j] = 0;
			val = atoi(vbuf);
			if (val < 1)
				val = 1;
			if (val > 255)
				val = 255;
			buf[p] = (char) val;
			p++;
			break;
		default:
			buf[p] = str[i];
			i++;
			p++;
		}
		if (p == maxlen)
			done = 1;
	}
	buf[p] = 0;
	if (str[i]) {
		if (str[i] != '"') {
			while (str[i] != '"' && str[i])
				i++;
		} else
			i++;
		if (str[i] == ' ')
			i++;
	}

	return &str[i];
}
#endif

/**
 put_text()

 Gegenstueck zu get_text() -
 Konvertiert einen String und schreibt diesen in die angegebene Datei
 -------------------------------------------------------------------------*/
void put_text(FILE *fh, char *str) {
	short i, j;
	unsigned char *p;
	char outbuf[1024];

	p = (unsigned char *) str;
	i = 0;
	j = 0;
	while (p[i]) {
		if (p[i] < 32) {
			sprintf(&outbuf[j], "@%02d", (short) p[i]);
			j += 3;
		} else {
			switch (p[i]) {
			case '\042':
				sprintf(&outbuf[j], "@34");
				j += 3;
				break;
			case '@':
				sprintf(&outbuf[j], "@64");
				j += 3;
				break;
			default:
				outbuf[j] = (char) p[i];
				j++;
				break;
			}
		}
		i++;
	}
	outbuf[j] = 0;
	fprintf(fh, "\042%s\042", outbuf);
}


/**
 * get_buf_entry
 *
 * Ermittelt den naechsten Filenamen aus einem Puffer, dessen Eintraege
 * durch Leerzeichen getrennt und ggf. von Quotes (') umschlossen
 * sind. Der ermittelte Filename enthaelt keine Quotes mehr.
 *
 * Eingabe:
 * buf: Zeiger auf den Puffer, muss bzw. darf nur beim ersten Aufruf
 *      fuer buf angegeben werden, danach muss fuer buf ein Nullzeiger
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
 * Prueft, ob ein Icon eines der Standardicons "APPL", "DEVICE",
 * "FILE" und "GROUP" ist.
 *
 * Eingabe:
 * icon: Zeiger auf das zu pruefende Icon
 *
 * Rueckgabe:
 * 0: Icon ist keines der genannten Standardicons
 * sonst: Icon ist "APPL", "DEVICE", "FILE" oder "GROUP"
 */
short isDefaultIcon(ICONINFO *icon) {
	if (strcmp(icon->name, "APPL")
			&& strcmp(icon->name, "DEVICE")
			&& strcmp(icon->name, "FILE")
			&& strcmp(icon->name, "GROUP")) {
		return (FALSE);
	} else
		return (TRUE);
}

/**
 main_init()

 Programminitialisierung
 -------------------------------------------------------------------------*/
short main_init(void) {
	short i, l, x, y, w, h;
	short illtype, type;
	char *p, aname[9], rsrcName[13];
	OBJECT *tree;

	aesBuffer = 0L;
	aesapname = 0L;
	glob.menu = glob.change = 0;
	glob.numassign = glob.numicon = glob.multiple = 0;
	glob.avid = -1;
	glob.tid = -1;
	glob.avflags = 0;
	glob.rtree = 0L;
	glob.rwin = 0L;
	glob.icon = 0L;
	glob.comments = 0L;
	if ((p = getenv("THINGDIR")) == 0L) {
		glob.rname[0] = (char) Dgetdrv() + 'A';
		glob.rname[1] = ':';
		Dgetpath(&glob.rname[2], 0);
	} else
		strcpy(glob.rname, p);
	l = (short) strlen(glob.rname);
	if (glob.rname[l - 1] != '\\')
		strcat(glob.rname, "\\");
	strcpy(glob.iname, glob.rname);
	strcpy(glob.lname, glob.rname);
	strcpy(glob.bname, glob.rname);
	strcat(glob.rname, FNAME_RSC);
	strcat(glob.iname, FNAME_ICN);
	strcat(glob.lname, FNAME_LOG);
	strcat(glob.bname, FNAME_BAK);
	glob.rinfo.load_magic = 0;
	rinfo.load_magic = 0;

	/* Toolbox und Speicherverwaltung initialisieren */
#ifdef USE_PMALLOC
	pminit();
#endif
	if (!init_cicon())
		return (0);

	if (!tool_init("THINGICN.APP"))
		return (0);

	if (tb.sys & SY_MTOS) /* Eintrag im Desk-Menue */
		menu_register(tb.app_id, "  Thing Icon Manager");

	if (glob.use3d == 0)
		set3dLook (FALSE);

	/* Alice austricksen ;-) */
	i = wind_create(NAME | MOVER | CLOSER | FULLER | ICONIFIER, tb.desk.g_x, tb.desk.g_y, 10, 10);
	if (i >= 0)
		wind_delete(i);

	tb.msg_handler = handle_fmsg;

	/* Resource laden */
	sprintf(rsrcName, "%s%s\\thgicn\\%s.rsc", tb.homepath, PNAME_RSC, tb.sysLanguageCodeLong);
	if (!rsc_load(rsrcName, &rinfo)) {
		sprintf(rsrcName, "%s%s\\thgicn\\english.rsc", tb.homepath, PNAME_RSC);
		if (!rsc_load(rsrcName, &rinfo)) {
			frm_alert(1, "[3][THINGICN.RSC nicht gefunden!|THINGICN.RSC not found!][ OK ]", altitle, 1, 0L);
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
		aesapname = Mxalloc(9 + MAX_AVLEN, 0x42);
	else
		aesapname = Malloc(9 + MAX_AVLEN);
	/* Bei Fehler raus */
	if (!aesapname) {
		frm_alert(1, rinfo.rs_frstr[ALNOMEM], altitle, 1, 0L);
		return (0);
	}
	aesBuffer = &aesapname[9];
	/* Sonst initialisieren */
	strcpy(aesapname, "THINGICN");

	tb.use3d = glob.use3d; /* 3D-Effekte */
	tb.backwin = glob.backwin; /* MagiC-Fensterworkround */
	tb.fupper = glob.fupper;
	tb.flower = glob.flower;
	tb.fleft = glob.fleft;
	tb.fright = glob.fright;
	tb.fhor = glob.fhor;
	tb.fvert = glob.fvert;

	/* Sliderpositionen anpassen */
	lst_prepare(&li_asedit, rinfo.rs_trindex[ASEDIT]);
	lst_prepare(&li_find, rinfo.rs_trindex[FIND]);

	/* ThingIcn-Logo anpassen */
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
	fi_asedit.tree = rinfo.rs_trindex[ASEDIT];
	fi_asedit.exit = de_edit;
	fi_find.tree = rinfo.rs_trindex[FIND];
	fi_find.exit = de_find;

	/* Popup-Menues initialisieren */
	pop_tcolor.tree = rinfo.rs_trindex[POPCOLOR];
	pop_tcolor.offx = tb.ch_w;

	/* Handler fuer modale Dialoge */
	tb.modal_on = mn_disable;
	tb.modal_off = mn_update;

	/* Icons laden */
	if (!rsc_load(glob.rname, &glob.rinfo)) {
		frm_alert(1, rinfo.rs_frstr[ALNORSC], altitle, 1, 0L);
		return (0);
	} else {
		rsc_gaddr(R_TREE, 0, &glob.rtree, &glob.rinfo); /* Objektbaum holen */
		/* Hintergrund setzen */
		glob.rtree->ob_spec.obspec.fillpattern = 0;
		glob.rtree->ob_spec.obspec.interiorcol = 0;

		/* Anzahl der Icons ermitteln, Koordinaten berechnen, Icons pruefen */
		illtype = 0;
		glob.iw = glob.ih = 0;
		if (glob.rtree->ob_flags & LASTOB)
			i = 0;
		else {
			tree = glob.rtree + 1;
			for (i = 1;; i++) {
				w = (tree->ob_width & 0xff) * 8 + ((tree->ob_width & 0xff00) >> 8);
				h = (tree->ob_height & 0xff) * 16 + ((tree->ob_height & 0xff00) >> 8);
				tree->ob_width = w;
				tree->ob_height = h;
				tree->ob_state = 0;
				w += 4;
				h += 4;
				if (w > glob.iw)
					glob.iw = w;
				if (h > glob.ih)
					glob.ih = h;

				/* Unzulaessiger Objekttyp? */
				type = tree->ob_type & 0xff;
				if ((type != G_ICON) && (type != G_USERDEF)) {
					illtype = 1;
					break;
				}

				if (tree->ob_flags & LASTOB)
					break;
				else
					tree++;
			}
		}
		glob.numicon = i;
		if (illtype) {
			frm_alert(1, rinfo.rs_frstr[ALILLTYPE], altitle, 1, 0L);
			return (0);
		}

		/* Weitere Vorbereitungen */
		glob.mx = glob.my = 0;
		glob.offx = glob.offy = 0;
		glob.focus = 0;
		glob.fdraw = 0;
	}

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
	wind_update (BEG_UPDATE);
	menu_bar(rinfo.rs_trindex[MAINMENU], 1);
	mn_disable();
	graf_mouse(ARROW, 0L);
	glob.menu = 1;
	wind_update (END_UPDATE);

	/* Hauptfenster aufmachen */
	if (!mw_init())
		return (0);

	return (1);
}

/**
 main_loop()

 Hauptschleife des Programms
 -------------------------------------------------------------------------*/
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
		mevent.ev_mflags = MU_KEYBD | MU_BUTTON | MU_MESAG | MU_TIMER;
		if (tb.fi)
			mevent.ev_mflags |= MU_M1;
		mevent.ev_mtlocount = 400;
		mevent.ev_mthicount = 0;
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

			/*
			 * Falls aktives Fenster sich geaendert hat, dann Menues
			 * updaten
			 */
			if (tb.topwin) {
				/* Bisher aktives Fenster vorhanden */
				if (!top) {
					/* Kein Fenster mehr aktiv */
					tb.topwin = 0L;
					tb.topfi = 0L;
					mn_update();
				} else if (top != tb.topwin->handle) {
					/* Fenster aktiv */
					/* Anderes  * als * bisher  */
					tb.topwin = win_getwinfo(top);
					mn_update();
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

		/* Timer */
		if (mevent.ev_mwich & MU_TIMER) {
			if (glob.focus) {
				/* Falls Objekt selektiert, dann *
				 * 'Cursorblinken' */
				/* Blinken nur im aktiven Fenster */
				if (tb.topwin == glob.rwin) {
					ic_fdraw();
					glob.fdraw = 1 - glob.fdraw;
				}
			}
		}
		/* Falls kein Timer fuer Cursorblinken, dann hier den Cursor *
		 * abschalten */
		if ((mevent.ev_mwich & (MU_MESAG | MU_KEYBD | MU_BUTTON)) != 0) {
			if (glob.focus && glob.fdraw) {
				ic_fdraw();
				glob.fdraw = 0;
			}
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

	/* Fenster schliessen */
	mw_exit();

	/* Beim AV-Server abmelden */
	if (glob.avid != -1)
		appl_send(glob.avid, AV_EXIT, 0, tb.app_id, 0, 0, 0, 0);

	/* Sonstige Aufraeumarbeiten */
	if (glob.menu)
		menu_bar(rinfo.rs_trindex[MAINMENU], 0);
	if (glob.rtree)
		rsc_free(&glob.rinfo);

	if (aesapname)
		Mfree(aesapname);

	rsc_free(&rinfo);

	tool_exit();
	exit_cicon();
}

/*------------------------------------------------------------------*/
/*  main routine                                                    */
/*------------------------------------------------------------------*/
main(short argc, char *argv[]) {
	char *p,
	vstr[10];
	short i,
	j;

	glob.use3d = 0;
	glob.backwin = 0;
	glob.tver = 0;
	glob.scroll = 6;
	glob.rclick = 0;
	glob.autoplace =
	glob.interactive =
	glob.fleft =
	glob.fright =
	glob.fupper =
	glob.flower =
	glob.fhor =
	glob.fvert = 0;

	if (argc > 1) {
		for (i = 1; i < argc; i++) {
			if (strstr(argv[i], "-d1"))
				glob.use3d = 1;

			p = strstr(argv[i], "-v");
			if (p) {
				j = 0;
				while (p[j + 2] && p[j + 2] >= '0' && p[j + 2] <= '9' && j < 10) {
					vstr[j] = p[j + 2];
					j++;
				}
				vstr[j] = 0;
				glob.tver = atoi(vstr);
			}
			p = strstr(argv[i], "-s");
			if (p) {
				j = 0;
				while (p[j + 2] && p[j + 2] >= '0' && p[j + 2] <= '9' && j < 10) {
					vstr[j] = p[j + 2];
					j++;
				}
				vstr[j] = 0;
				glob.scroll = atoi(vstr);
				if (glob.scroll < 1)
				glob.scroll = 1;
			}
			if (strstr(argv[i], "-r1"))
				glob.rclick = 1;
			if (strstr(argv[i], "-w1"))
				glob.backwin = 1;
			if (strstr(argv[i], "-a1"))
				glob.autoplace = 1;
			if (strstr(argv[i], "-i1"))
				glob.interactive = 1;
			p = strstr(argv[i], "-f");
			if (p && (strlen(p) >= 26)) {
				char hlp[5] = "0000";

				strncpy(hlp, p + 2, 4);
				glob.fupper = atoi(hlp);
				strncpy(hlp, p + 6, 4);
				glob.flower = atoi(hlp);
				strncpy(hlp, p + 10, 4);
				glob.fleft = atoi(hlp);
				strncpy(hlp, p + 14, 4);
				glob.fright = atoi(hlp);
				strncpy(hlp, p + 18, 4);
				glob.fhor = atoi(hlp);
				strncpy(hlp, p + 22, 4);
				glob.fvert = atoi(hlp);
			}
		}
	}

	if (main_init())
	main_loop();

	main_exit();
	return(0);
}

/* EOF */
