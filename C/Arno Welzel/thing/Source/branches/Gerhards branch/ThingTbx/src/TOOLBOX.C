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

#include <gem.h>
#include <nkcc.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <slectric.h>
#define TOOLBOX_LIB
#define _TOOLBOX_
#include "..\include\thingtbx.h"
#include <dudolib.h>
#ifdef MEMDEBUG
#include <memdebug.h>
#endif
#define NOVA_PATCH


/*------------------------------------------------------------------*/
/*  global functions                                                */
/*------------------------------------------------------------------*/
/*------------------------------------------------------------------*/
/*  global variables                                                */
/*------------------------------------------------------------------*/
BYTE *aesBuffer;

/*-------------------------------------------------------------------------
 Resource fuer Popup-Listen und Bitmaps fuer Userdefs
 -------------------------------------------------------------------------*/
#include "toolbox.rsh"

/* Groesse der Listboxen in Zeilen */
#define LISTSIZE	10

/* Maximale Schachtelungstiefe bei Screen2Buffer */
#define MAX_BUFFERS	10

static WORD d_getcwd(char *buf, WORD drive, WORD len);
static void lst_arrow(LISTINFO *li, short object, short dir);

static short is_disabled(char *p);

/* Lokale Variablen */
static short work_in[] = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2 };
static short work_out[57];
static short nk_ok;
static MFDB scr_mfdb;
static short aesmsg[8];
static USERBLK *ublk;
static short unum, uused;
static short v_handle;
static FORMINFO t_fi;
static short pop_offx, pop_offy;
static OBJECT sepline = { -1, -1, -1, (SEPARATOR << 8) | G_STRING, LASTOB, DRAW3D | NORMAL, 0, 0, 1, 1 };

/**-------------------------------------------------------------------------
 mybeep()

 "Pling" ausgeben
 -------------------------------------------------------------------------*/
void mybeep(void) {
	Cconout('\a');
}

/**-------------------------------------------------------------------------
 normkey()

 Normalisierten Tastaturcode ermitteln
 -------------------------------------------------------------------------*/
unsigned short normkey(short ks, short kr) {
	long toskey;
	short nkc_ret;
	short nkc_special;

	toskey = (kr & 0xff) | ((long) (kr & 0xff00) << 8) | ((long) (ks & 0xff)
			<< 24);
	nkc_ret = nkc_tconv(toskey);

	if (!ks && ((nkc_n2gem(nkc_ret) ^ kr) & 0xff)) {
		mybeep();
		nkc_ret = NKF_FUNC | NK_INVALID;
	}
	if (nkc_ret & NKF_FUNC) {
		nkc_special = nkc_ret & 0xff00;
		switch (nkc_ret & 0xff) {
		case NK_M_PGUP:
			nkc_ret = NK_UP | NKF_SHIFT;
			break;

		case NK_M_PGDOWN:
			nkc_ret = NK_DOWN | NKF_SHIFT;
			break;

		case NK_M_END:
			nkc_ret = NK_CLRHOME | NKF_SHIFT;
			break;
		} /* switch */

		nkc_ret |= nkc_special;
	}
	return (nkc_ret);
}

/**
 * rel2abs
 *
 * Erzeugt aus einem eventuell relativen Pfad
 * einen absoluten der Form X:\...\, wobei nicht
 * darauf geachtet wird, ob der Pfad existiert
 * oder ueberhaupt ein Verzeichnis bezeichnet. Fuer
 * den absoulten Pfad wird selbstt„tig Speicher
 * angefordert, der dann vom Aufruf mittels free
 * wieder freigegeben werden muž. rel2abs versucht
 * m”glichst viele Pfadfehler wie mehrfache
 * Backslashes so gut es geht zu beheben, bei
 * v”llig unsinnigen Eingaben ist es jedoch
 * machtlos.
 *
 * Eingabe:
 * path: Zeiger auf umzuwandelnden Pfad, der
 *       absolut oder relativ sein darf, auch mit
 *       '.'- und '..'-Komponenten
 * destpath: Zeiger auf Zeiger fuer den Zielpfad,
 *           hier wird der angeforderte Speicher
 *           eingetragen, so daž er auch vom
 *           Aufrufer noch erreichbar ist.
 *           destpath wird auf NULL gesetzt, wenn
 *           w„hrend der Abarbeitung von rel2abs
 *           ein Fehler aufgetreten ist.
 *
 * Rueckgabe:
 * 0: Alles OK, in destpath findet sich Zeiger auf
 *    erzeugten absoluten Pfad
 * sonst: GEMDOS-Fehlermeldung, destpath ist NULL
 */
short rel2abs(char *path, char **destpath) {
	char *act_path, *temp, *pos, *next, rootdir[4] = "x:\\";
	WORD drive, err;
	LONG maxplen;
	_DTA mydta, *olddta;

	/*
	 * Wenn path bereits eine Laufwerksangabe enth„lt,
	 * diese auslesen, sonst das aktuelle Laufwerk
	 * ermitteln
	 */
	if (path[1] == ':') {
		drive = (path[0] & ~32) - 65;
		pos = &path[2];
	} else {
		if ((drive = Dgetdrv()) < 0)
			return (drive);
		pos = path;
	}

	/*
	 * Versuchen, maximale Pfadl„nge fuer das
	 * Wurzelverzeichnis des betroffenen Laufwerks
	 * zu ermitteln. Das muž nicht unbedingt die
	 * korrekte L„nge ergeben, ist aber verl„žlicher,
	 * als den relativen Pfad zu benutzen.
	 */
	rootdir[0] = (drive + 65);
	if (Dpathconf(rootdir, -1) >= 2) {
		maxplen = Dpathconf(rootdir, 2);
		if (maxplen == 0x7fffffffL)
			maxplen = 256;
	} else
		maxplen = 256;

	/*
	 * Plus zwei Bytes: Fuer den abschlieženden Back-
	 * slash und die Null fuer das Stringende.
	 */
	maxplen += 2;

	/*
	 * Speicher fuer zwei Pfadpuffer anfordern, dies
	 * ist gleichzeitig die Adresse, die in destpath
	 * abgelegt wird
	 */
	if ((*destpath = temp = malloc(maxplen * 2L)) == NULL)
		return (-39);

	/*
	 * Aktuellen Pfad des betroffenen Laufwerks
	 * ermittlen
	 */
	act_path = (char *) ((LONG) temp + maxplen);
	if ((err = d_getcwd(act_path, drive + 1, (WORD) maxplen)) < 0) {
		free(temp);
		*destpath = NULL;
		return (err);
	}

	/*
	 * Eventuellen Backslash am Ende des aktuellen
	 * Pfades entfernen
	 */
	if (*act_path && (act_path[strlen(act_path) - 1] == '\\'))
		act_path[strlen(act_path) - 1] = 0;

	/*
	 * Beginn des absoluten Pfades erzeugen. War path
	 * kein absoluter Pfad (erstes Zeichen nach der
	 * eventuellen Laufwerksangabe kein Backslash),
	 * wird der aktuelle Pfad angeh„ngt. Ansonsten
	 * werden eventuelle unn”tige Backslashes
	 * ueberlesen.
	 */
	sprintf(temp, "%c:", drive + 65);
	if (*pos != '\\')
		strcat(temp, act_path);
	else
		for (; *pos && (*pos == '\\'); pos++)
			;

	/*
	 * Der Rest des relativen Pfades wird jetzt
	 * komponentenweise betrachtet (immer von der
	 * momentanten Position bis zum n„chsten
	 * Backslash). Ist die Komponente '.', wird sie
	 * ignoriert, weil sie fuer das gerade aktuelle
	 * Verzeichnis steht. Bei '..' wird vom absoluten
	 * Pfad die letzte Komponente entfernt, wenn man
	 * noch nicht im Wurzelverzeichnis angekommen ist.
	 * Bei der Zerlegung in Komponenten werden wieder
	 * mehrfache Backslashes uebergangen.
	 */
	next = pos;
	while ((next != NULL) && *pos) {
		if ((next = strchr(pos, '\\')) != NULL)
			for (; *next && (*next == '\\'); *next++ = 0)
				;

		if (!strcmp(pos, "..")) {
			if (strlen(temp) > 2)
				*strrchr(temp, '\\') = 0;
		} else {
			if (strcmp(pos, ".")) {
				strcat(temp, "\\");
				strcat(temp, pos);
			}
		}
		if (next != NULL)
			pos = next;
	}

	/*
	 * Nach erfolgreicher Umwandlung noch per Fsfirst() pruefen, ob es
	 * sich um ein Verzeichnis handelt. Falls ja, wird ein Backslash
	 * angeh„ngt.
	 */
	olddta = Fgetdta();
	Fsetdta(&mydta);
	err = Fsfirst(temp, 0x10 /* FA_SUBDIR */);
	Fsetdta(olddta);
	if (!err && (mydta.dta_attribute & 0x10 /* FA_SUBDIR */))
		strcat(temp, "\\");

	return (0);
}

/**
 * d_getcwd
 *
 * Wie Dgetcwd, nur daž Dgetpath benutzt wird,
 * wenn Dgetcwd nicht vorhanden ist (dann wird
 * len ignoriert und man muž hoffen, daž buf
 * genuegend Platz bietet). Dgetpath wird auch dann
 * benutzt, wenn Dgetcwd vorhanden ist, aber
 * EDRIVE geliefert hat, weil MetaDOS kein Dgetcwd
 * bereitstellt und daher fuer die entsprechenden
 * Laufwerke das des Betriebssystems benutzt wird,
 * das von diesen Laufwerken natuerlich nichts
 * weiž.
 *
 * Eingabe:
 * buf: Zeiger auf Puffer, in den der aktuelle
 *      Pfad kopiert werden soll
 * drive: Laufwerk, von dem der aktuelle Pfad
 *        ermittelt werden soll (0 = aktuelles,
 *        1 = A, 2 = B, etc.)
 * len: Anzahl der Zeichen, fuer die buf Platz hat
 *
 * Rueckgabe:
 * Returnwert von Dgetcwd bzw. Dgetpath
 */
static WORD d_getcwd(char *buf, WORD drive, WORD len) {
	LONG err;

	err = Dgetcwd(buf, drive, len);
	if ((err != -32L) && (err != -46L)) {
		return ((WORD) err);
	}

	return (Dgetpath(buf, drive));
}

/**-------------------------------------------------------------------------
 menu_key()

 Ermittelt anhand des NKCC-Tastaturcodes den zugeh”rigen Menueeintrag
 ueber den Shortcut, der als Text am rechten Menuerand steht.
 -------------------------------------------------------------------------*/
short menu_key(OBJECT *tree, short key, short *title, short *item) {
	char match[5], text[5], *mp;
	short p, i, index, menu, mtitle, first, last;

	/* Suchmuster erstellen */
	p = 0;
	if (key & NKF_SHIFT) {
		match[p] = '\1';
		p++;
	}
	if (key & NKF_CTRL) {
		match[p] = '^';
		p++;
	}
	if (key & NKF_ALT) {
		match[p] = '\7';
		p++;
	}
	if (p == 0)
		return 0;
	match[p] = nkc_toupper(key & 0xff);
	p++;
	match[p] = 0;

	/* Ersten Menuetitel holen */
	mtitle = tree[0].ob_head;
	mtitle = tree[mtitle].ob_head;
	mtitle = tree[mtitle].ob_head;

	/* Erstes Menue holen */
	menu = tree[0].ob_tail;
	menu = tree[menu].ob_head;

	for (;;) {
		/* Ersten und letzen Menueeintrag holen */
		first = tree[menu].ob_head;
		last = tree[menu].ob_tail;

		/* Alle Eintr„ge pruefen */
		for (index = first; index <= last; index++) {
			/* Nur pruefen, falls wirklich Eintrag (und keine Niceline)
			 und anw„hlbar */
			if (tree[index].ob_type == G_STRING && !isObjectDisabled(tree, index)) {
				/* Shortcut-Text im Menue isolieren */
				mp = tree[index].ob_spec.free_string;
				i = 0;
				while (mp[i])
					i++;
				i--;
				while (mp[i] == ' ' && i > 0)
					i--;
				while (mp[i] != ' ' && i > 0)
					i--;
				if (mp[i] == ' ')
					i++;
				p = 0;
				while (p < 3 && mp[i] != ' ') {
					text[p] = mp[i];
					i++;
					p++;
				}
				text[p] = 0;
				/* Shortcut passend? */
				if (!strcmp(match, text)) {
					*title = mtitle;
					*item = index;
					return (1);
				}
			}
		}
		menu = tree[menu].ob_next;
		mtitle = tree[mtitle].ob_next;
		if (menu == -1)
			break;
	}

	return (0);
}

/**-------------------------------------------------------------------------
 shortcut()

 Ermitteln eines Shortcuts im Dialogbaum
 -------------------------------------------------------------------------*/
static short shortcut_walk(OBJECT *tree, short start, unsigned char k) {
	short i, scut, index;
	char *p;
	unsigned char s;
	OBJECT *obj;

	for (i = tree[start].ob_head; (i != start) && (i != -1); i = tree[i].ob_next) {
		obj = &tree[i];
		if ((obj->ob_flags & HIDETREE) == 0) {
			/* Umgewandelter Button? */
			if (((obj->ob_type & 0xff) == G_USERDEF) && (obj->ob_flags & SELECTABLE)) {
				scut = (obj->ob_state & 0x7f00) >> 8;
				/* Shortcut vorhanden? */
				if (scut <= 0x7e) {
					UBPARM *up = (UBPARM *) obj->ob_spec.userblk->ub_parm;

					/* Shortcut passend? */
					if (up->magic == 'DIRK')
						p = up->text;
					else
						p = (char *) up;
					s = nkc_toupper(p[scut]);
					if (s == (unsigned char) 'Ž')
						s = 'A';
					if (s == (unsigned char) '™')
						s = 'O';
					if (s == (unsigned char) 'š')
						s = 'U';
					if (k == s)
						return (i);
				}
			}
			/* Nein, also rekursiv weiter */
			index = shortcut_walk(tree, i, k);
			if (index != -1)
				return (index);
		}
	}
	/* Nix gefunden */
	return (-1);
}

/**
 * 
 */
short shortcut(OBJECT *tree, short ks, short kr, short undo_obj, short help_obj) {
	unsigned short key;

	/* Normalcode holen */
	key = normkey(ks, kr);
	key &= ~(NKF_CAPS | NKF_RESVD);

	/* Shift etc. nicht verwenden */
	if ((key & NKF_LSH) || (key & NKF_RSH) || (key & NKF_CTRL))
		return (-1);

	/* [Undo]?, [Help]? */
	if (key == (NKF_FUNC | NK_UNDO))
		return (undo_obj);
	if (key == (NKF_FUNC | NK_HELP))
		return (help_obj);

	/* Nur [Alt]-Kombinationen verwenden */
	if (!(key & NKF_ALT))
		return (-1);

	return (shortcut_walk(tree, 0, nkc_toupper(key & 0xff)));
}

/**-------------------------------------------------------------------------
 tool_init()

 Initialisierung der Toolbox (einschl. NKCC)
 -------------------------------------------------------------------------*/
short tool_init(char *apname) {
	short sret;
	long ldummy;
	char cmd[128], *p;
	SHELTAIL *tail;
	short out[4], d;

	tb.numfonts = 1;
	tb.mform = ARROW;

	tb.vdi_handle = 0;
	tb.magx = 0L;
	tb.sys = 0;
	tb.gdos = 0;
	tb.mbusy = 0;
	tb.sm_alert = 0;
	tb.sm_nowdial = 0;
	tb.sm_dial = 0;
	tb.use3d = 0;
	tb.backwin = 0;
	tb.fleft = tb.fupper = tb.fright = tb.flower = tb.fhor = tb.fvert = 0;
	tb.ictree = 0L;
	tb.ictreed = 0L;

	v_handle = 0;
	nk_ok = 0;
	unum = 0;
	uused = 0;
	ublk = 0L;

	strcpy(tb.apname, apname);

	/* Applikation unter AES anmelden */
	tb.app_id = appl_init();
	if (tb.app_id == -1)
		return (0);

	/* Dirchs Userdef-Library initialisieren */
	if (initDudolib() != USR_NOERROR) {
		form_alert(1, "[3][Failed to initialize|userdefined objects!][ OK ]");
		return (0);
	}

	tb.scr_id = appl_find("SCRENMGR");

	/* Virtuelle VDI-Workstations ”ffnen */
	tb.vdi_handle = v_handle = graf_handle(&tb.ch_w, &tb.ch_h, &tb.ch_wb, &tb.ch_hb);
	_v_opnvwk(work_in, &tb.vdi_handle, work_out);
	if (!tb.vdi_handle)
		return (0);

	_v_opnvwk(work_in, &v_handle, work_out);
	if (!v_handle)
		return (0);

	/* Bitplanes und Aufl”sung abfragen */
	vq_extnd(tb.vdi_handle, 0, work_out);
	tb.resx = work_out[0] + 1;
	tb.resy = work_out[1] + 1;
	vq_extnd(tb.vdi_handle, 1, work_out);
	tb.planes = work_out[4];
	if (tb.planes < 0)
		tb.planes = 1;
	if (tb.planes > 32)
		tb.planes = 32;

	tb.colors = 1L << min(24L, (long) tb.planes);

	/*
	 * Ermitteln, ob "True Color" vorliegt, also bei Weiss alle Pixel gesetzt sind
	 */
	{
		MFDB src, dst;
		short xy[12], buf[32], black[32];

		xy[0] = xy[8] = tb.resx - 16;
		xy[1] = xy[3] = xy[9] = xy[11] = tb.resy - 1;
		xy[2] = xy[10] = tb.resx - 1;
		src.fd_addr = 0L;
		src.fd_w = 16;
		src.fd_h = 1;
		src.fd_wdwidth = 1;
		dst = src;
		dst.fd_addr = buf;
		dst.fd_nplanes = tb.planes;
		dst.fd_stand = 0;
		xy[4] = xy[5] = xy[7] = 0;
		xy[6] = 15;
		vro_cpyfm(tb.vdi_handle, S_ONLY, xy, &src, &dst);
		v_pline(tb.vdi_handle, 2, xy);
		src.fd_addr = 0L;
		dst.fd_addr = black;
		vro_cpyfm(tb.vdi_handle, S_ONLY, xy, &src, &dst);
		src.fd_addr = 0L;
		dst.fd_addr = buf;
		vro_cpyfm(tb.vdi_handle, S_ONLY, &xy[4], &dst, &src);
		dst.fd_addr = black;
		src = dst;
		src.fd_stand = 0;
		vr_trnfm(tb.vdi_handle, &src, &dst);
		tb.truecolor = black[0] == 0;
	}

	/* NKCC initialisieren */
	nkc_init(NKI_NO200HZ, 0, 0L);
	nkc_set(0L);
	nk_ok = 1;

	/* Objekte fuer Popup-Listen, ASCII-Tabelle etc. fixen */
	rs_fix(rs_trindex[0], 8, 16);
	rs_fix(rs_trindex[1], 8, 16);
	rs_fix(rs_trindex[2], 8, 16);
	rs_fix(&sepline, 8, 16);

	/* Images im Alert plazieren */
	rs_trindex[2][2].ob_y =
	rs_trindex[2][3].ob_y =
	rs_trindex[2][1].ob_y;

	rs_trindex[2][1].ob_width =
	rs_trindex[2][2].ob_width =
	rs_trindex[2][3].ob_width =
	rs_trindex[2][1].ob_height =
	rs_trindex[2][2].ob_height =
	rs_trindex[2][3].ob_height = 32;

	/* MFDBs initialisieren */
	scr_mfdb.fd_addr = 0L; /* Bildschirm */

	/* Fenster- & Dialogverwaltung initialisieren */
	tb.win = tb.topwin = tb.alwin = 0L;
	tb.fi = tb.topfi = 0L;

	/* Desktop-Ausmasse */
	wind_get(0, WF_WORKXYWH, &tb.desk.g_x, &tb.desk.g_y, &tb.desk.g_w, &tb.desk.g_h);

	/* Message-Handler ec. fuer modale Dialoge */
	tb.msg_handler = 0L;
	tb.modal_on = 0L;
	tb.modal_off = 0L;

	/* Userdefs */

	/* Buttons in der Alert-Box und in der Popup-Liste anpassen */
	pop_offx = rs_trindex[0]->ob_width;
	pop_offy = rs_trindex[0]->ob_height;
	setUserdefs(rs_trindex[0], 0);
	setUserdefs(rs_trindex[2], 0);
	setUserdefs(&sepline, 0);
	pop_offx = rs_trindex[0]->ob_width - pop_offx;
	pop_offy = rs_trindex[0]->ob_height - pop_offy;

	/* Aktuelle Systemkonfiguration */
	if (Getcookie('MagX', (long *) &tb.magx) == E_OK )
		tb.sys |= SY_MAGX;
	else
		tb.magx = 0L;
	if (Getcookie('nAES', 0L) == E_OK )
		tb.sys |= SY_NAES;
	if (Getcookie('Gnva', 0L) == E_OK )
		tb.sys |= SY_GNVA;
	if (_AESnumapps != 1) {
		tb.sys |= SY_MULTI; /* Multitasking */
		if (_AESversion >= 0x400)
			tb.sys |= SY_MTOS; /* Und MultiTOS */
	}
	if (Getcookie('MiNT', &ldummy) == E_OK)
		tb.sys |= SY_MINT; /* MiNT */

	if (Sysconf(-1) != -32L)
		tb.sys |= SY_XALLOC;

	/* Startverzeichnis ermitteln */
	sret = shel_read(tb.homepath, cmd);
	if (tb.sys & SY_MAGX)
		tail = (SHELTAIL *) cmd;
	else
		tail = 0L;

	if (sret) {
		if (tail) {
			/* MagiC-Shell ? */
			if (tail->magic == 'SHEL' && tb.magx->aesvars->magic == 0x87654321L && tb.magx->aesvars->magic2 == 'MAGX') {
				tb.sys |= SY_MSHELL;
			} else {
				tail = 0L;
			}
		}

		p = strrchr(tb.homepath, '\\');
		if (p)
			p[1] = 0;
	}

	if (!sret || tb.sys & SY_MTOS) {
		char *hp = NULL;

		/* GGf. mit shel_find() probieren */
		strcpy(tb.homepath, tb.apname);
		if (!shel_find(tb.homepath) || rel2abs(tb.homepath, &hp)) {
			/* Hat auch nicht geklappt :( */
			tb.homepath[0] = 0;
			form_alert(1, "[1][Startverzeichnis der Applikation|nicht gefunden!|Can't find application's|home directory!][Abbruch]");
			return (0);
		} else {
			if (hp) {
				tb.homepath[255] = 0;
				strncpy(tb.homepath, hp, 255);
				free(hp);
			}
			p = strrchr(tb.homepath, '\\');
			if (p)
				p[1] = 0;
		}
	}

	/* Systemsprache ermitteln */
	tb.sysLanguageId = getSystemLanguage(tb.sysLanguageCode, tb.sysLanguageCodeLong );

	/* AES-Fonts ermitteln */
	tb.fn_id = tb.fs_id = 1;
	if (tb.ch_h == 8)
		tb.fn_size = 6;
	else
		tb.fn_size = 13;
	tb.fs_size = 5;

	if ((tb.sys & SY_MTOS) || (tb.sys & SY_MAGX) || (appl_find("?AGI\0\0\0\0") >= 0)) {
		tb.sys |= SY_AGI;
		if (appl_getinfo(0, &out[0], &out[1], &out[2], &out[3]) == 1) {
			tb.fn_size = out[0];
			tb.fn_id = out[1];
		}
		if (appl_getinfo(1, &out[0], &out[1], &out[2], &out[3]) == 1) {
			tb.fs_size = out[0];
			tb.fs_id = out[1];
		}
	}

	/* Auf WINX pruefen */
	if (wind_get(0, 'WX', &out[0], &out[1], &out[2], &out[3]) == 'WX')
		tb.sys |= SY_WINX;

	/* Auf Farbicons pruefen */
	if (tb.sys & SY_AGI) {
		if (appl_getinfo(2, &out[0], &out[1], &out[2], &out[3]) == 1) {
			if (out[2] == 1)
				tb.sys |= SY_CICON; /* Farbicons vorhanden */
			if (out[3] == 1)
				tb.sys |= SY_NRSC; /* Neues RSC-Format vorhanden */
		}
	}

	/* Fonts nachladen */
	vq_extnd(tb.vdi_handle, 0, work_out);
	tb.numfonts = work_out[10];
	if (vq_gdos() != 0)
		tb.gdos = 1;
	if (tb.gdos) {
		tb.numfonts += vst_load_fonts(tb.vdi_handle, 0);
		vst_load_fonts(v_handle, 0);
	}

	/* Ausmasse des kleinen Systemfonts ermitteln */
	vst_font(tb.vdi_handle, tb.fs_id);
	vst_height(tb.vdi_handle, tb.fs_size, &d, &d, &tb.fs_cw, &tb.fs_ch);

	/* Weitere AES-Features testen */
	if (tb.sys & SY_AGI) {
		/* Shutdown-Support testen */
		if (appl_getinfo(12, &out[0], &out[1], &out[2], &out[3]) == 1) {
			/* Falls vorhanden, dann auch gleich anmelden */
			if (out[0] & 0x0008) {
				tb.sys |= SY_SHUT;
				shel_write(9, 0x0001, 0, 0L, 0L);
			}
		}

		/* Auf Iconify testen */
		if (appl_getinfo(11, &out[0], &out[1], &out[2], &out[3]) == 1) {
			/* WF_ICONIFY vorhanden und Iconifier? */
			if ((out[0] & 0x0080) && (out[3] & 0x0001))
				tb.sys |= SY_ICONIFY;

			/* WF_OWNER vorhanden? */
			if (out[0] & 0x10)
				tb.sys |= SY_OWNER;

			/* wind_udpate() "check and set" vorhanden? */
			if (out[3])
				tb.sys |= SY_WUPDATE;
		}

		/* Ermitteln, ob appl_search() vorhanden */
		if (appl_getinfo(4, &out[0], &out[1], &out[2], &out[3]) == 1) {
			if (out[2] == 1)
				tb.sys |= SY_ASEARCH;
		}

		/* MultiTOS-Popup- bzw. Submenues vorhanden? */
		if (appl_getinfo(9, &out[0], &out[1], &out[2], &out[3]) == 1) {
			if (out[0] && out[1])
				tb.sys |= SY_POPUP;
		}
	}

	read_hlp(".hlr");
	return (1);
}

/**-------------------------------------------------------------------------
 tool_exit()

 Deinitialisierung der Toolbox (einschl. NKCC)
 -------------------------------------------------------------------------*/
#define _str(x)		__str(x)
#define __str(x)	#x
#define LINOUT	Cconws(_str(__LINE__) "\r\n\n\n");
#undef LINOUT
#define LINOUT

void tool_exit(void) {
LINOUT
	free_hlp(tb.hlp);
	if (tb.gdos) {
		vst_unload_fonts(v_handle, 0);
		vst_unload_fonts(tb.vdi_handle, 0);
	}
LINOUT
	if (ublk)
		Mfree(ublk);
LINOUT
	if (nk_ok)
		nkc_exit();
LINOUT
	if (v_handle)
		v_clsvwk(v_handle);
LINOUT
	if (tb.vdi_handle)
		v_clsvwk(tb.vdi_handle);
LINOUT
	/* Userdef-Library abmelden */
	releaseDudolib();
LINOUT
	if (tb.app_id != -1)
		appl_exit();
LINOUT
}

/*-------------------------------------------------------------------------
 find_obj()
 ini_fld()

 Routinen zu frm_do()
 -------------------------------------------------------------------------*/
short find_obj(OBJECT *tree, short start_obj, short wich) {
	short obj, flag, theflag, inc;

	obj = 0;
	flag = EDITABLE;
	inc = 1;

	switch (wich) {
	case FMD_BACKWARD:
		inc = -1;

	case FMD_FORWARD:
		obj = start_obj + inc;
		break;

	case FMD_DEFLT:
		flag = DEFAULT;
		break;
	} /* switch */

	while (obj >= 0) {
		theflag = tree[obj].ob_flags;

		if (theflag & flag)
			return (obj);

		if (theflag & LASTOB)
			obj = -1;
		else
			obj += inc;
	}

	return (start_obj);
}

short ini_field(OBJECT *tree, short start_fld) {
	if (!start_fld)
		start_fld = find_obj(tree, 0, FMD_FORWARD);

	return (start_fld);
}

/**-------------------------------------------------------------------------
 obj_cdraw()

 Zeichnet/L”scht den Cursor in einem Editfeld unter Beachtung der
 Rechteckliste eines Fensters

 Wird von obj_edit() verwendet
 -------------------------------------------------------------------------*/
void obj_cdraw(short *pxy, short whandle) {
	short cxy[4];
	GRECT area, box;
	WININFO *win;

	win = win_getwinfo(whandle);
	if (win) {
		if (win->state & WSICON)
			return;
	}

	vsl_color(v_handle, 1);
	vsl_type(v_handle, 1);
	vswr_mode(v_handle, MD_XOR);

	graf_mouse(M_OFF, 0L);
	if (whandle != -1) {
		area.g_x = tb.desk.g_x;
		area.g_y = tb.desk.g_y;
		area.g_w = tb.desk.g_w;
		area.g_h = tb.desk.g_h;

		wind_update(BEG_UPDATE);
		wind_get(whandle, WF_FIRSTXYWH, &box.g_x, &box.g_y, &box.g_w, &box.g_h);

		/* Rechteckliste abarbeiten */
		while (box.g_w && box.g_h) {
			if (rc_intersect(&area, &box)) {
				cxy[0] = box.g_x;
				cxy[1] = box.g_y;
				cxy[2] = cxy[0] + box.g_w - 1;
				cxy[3] = cxy[1] + box.g_h - 1;
				vs_clip(v_handle, 1, cxy);
				v_pline(v_handle, 2, pxy);
				vs_clip(v_handle, 0, cxy);
			}

			/* Naechstes freies Rechteck holen */
			wind_get(whandle, WF_NEXTXYWH, &box.g_x, &box.g_y, &box.g_w, &box.g_h);
		}
		wind_update(END_UPDATE);
	} else {
		cxy[0] = tb.desk.g_x;
		cxy[1] = tb.desk.g_y;
		cxy[2] = cxy[0] + tb.desk.g_w - 1;
		cxy[3] = cxy[1] + tb.desk.g_h - 1;
		vs_clip(v_handle, 1, cxy);
		v_pline(v_handle, 2, pxy);
		vs_clip(v_handle, 0, cxy);
	}

	graf_mouse(M_ON, 0L);
	vswr_mode(v_handle, MD_REPLACE);
}

/**-------------------------------------------------------------------------
 obj_idxabs()

 Berechnet aus dem Index eines Editfeldes die absolute Pixelposition unter
 Beruecksichtigung der Eingabemaske - wird von obj_edit() verwendet um
 die Position fuer den Cursor zu berechnen
 -------------------------------------------------------------------------*/
short obj_idxabs(char *tmp, char *txt, short idx) {
	short tmp_idx, txt_idx, hlp_idx, extent[8], d;
	char hlp[256];

	vst_font(tb.vdi_handle, tb.fn_id);
	vst_height(tb.vdi_handle, tb.fn_size, &d, &d, &d, &d);
	vst_effects(tb.vdi_handle, 0);

	tmp_idx = txt_idx = hlp_idx = 0;
	for (; tmp[tmp_idx]; tmp_idx++) {
		if (tmp[tmp_idx] == '_') {
			if (txt_idx == idx)
				break;
			if (txt[txt_idx])
				hlp[hlp_idx++] = txt[txt_idx++];
			else
				hlp[hlp_idx++] = '_';
		} else
			hlp[hlp_idx++] = tmp[tmp_idx];
	}
	hlp[hlp_idx] = 0;

	vqt_extent(tb.vdi_handle, hlp, extent);

	return (extent[2] - extent[0] + 1);
}

/**-------------------------------------------------------------------------
 obj_idxrel()

 Berechnet aus der absoluten Pixelposition den Index eines Editfeldes unter
 Beruecksichtigung der Eingabemaske - wird von frm_do() fuer die direkte
 Positionierung des Cursors verwendet.
 -------------------------------------------------------------------------*/
short obj_idxrel(OBJECT *tree, short obj, short pxl_idx) {
	char *txt, *tmp;
	short txt_idx, tmp_len;

	txt = tree[obj].ob_spec.tedinfo->te_ptext;
	tmp = tree[obj].ob_spec.tedinfo->te_ptmplt;

	if ((tmp_len = (short) strlen(tmp)) == 0)
		return (0);

	for (txt_idx = --tmp_len; txt_idx >= 0; txt_idx--) {
		if (obj_idxabs(tmp, txt, txt_idx) <= pxl_idx)
			return (txt_idx);
	}
	return (0);
}

/**
 * obj_xleft
 *
 * Ermittelt die linke x-Koordinate des Inhalts eines Editfeldes
 * unter Beruecksichtigung von Ausrichtung und aktuellem Inhalt
 * (Stichwort: proportionale Systemfonts).
 *
 * Eingabe:
 * tree: Zeiger auf Objektbaum
 * obj: Nummer des Objektes in tree
 *
 * Rueckgabe:
 * Absolute x-Bildschirmkoordinate des ersten Zeichens im Editfeld
 */
short obj_xleft(OBJECT *tree, short obj) {
	char *tmp, *txt;
	short tmp_len, cnt_len, x_off, width, d;

	txt = tree[obj].ob_spec.tedinfo->te_ptext;
	tmp = tree[obj].ob_spec.tedinfo->te_ptmplt;

	if ((tmp_len = (short) strlen(tmp)) == 0)
		cnt_len = 0;
	else
		cnt_len = obj_idxabs(tmp, txt, tmp_len);

	objc_offset(tree, obj, &x_off, &d);
	width = tree[obj].ob_width;
	switch (tree[obj].ob_spec.tedinfo->te_just) {
	case TE_LEFT:
		/* Do nothing */
		break;
	case TE_RIGHT:
		x_off += width - cnt_len;
		break;
	case TE_CNTR:
		if (cnt_len <= width)
			x_off += (width - cnt_len) / 2;
		break;
	}
	return (x_off);
}

/**-------------------------------------------------------------------------
 obj_edit()

 Erweiterte Version der AES-Funktion objc_edit() mit Beruecksichtigung
 des sichtbaren Fensterausschnitts etc.
 -------------------------------------------------------------------------*/
short obj_edit(OBJECT *ob_edtree, short ob_edobject, short ob_edchar, short ob_edstate,
		short *ob_edidx, short ob_edkind, short whandle) {
	short i, x, y, pxy[4];
	short maxidx, idx, vidx;
	unsigned short key;
	char *txt, *valid, *tmp;
	short txtlen;
#if 0
	short tmplen;
#endif

	/* Falls kein Eingabefeld angegeben wurde, dann raus */
	if (!ob_edobject)
		return (0);

	if (!(ob_edtree[ob_edobject].ob_flags & EDITABLE))
		return (0);

	txt = ob_edtree[ob_edobject].ob_spec.tedinfo->te_ptext;
	valid = ob_edtree[ob_edobject].ob_spec.tedinfo->te_pvalid;
	tmp = ob_edtree[ob_edobject].ob_spec.tedinfo->te_ptmplt;

	txtlen = (short) strlen(txt);
#if 0
	tmplen = ob_edtree[ob_edobject].ob_spec.tedinfo->te_tmplen - 1;
#endif

	/* Obergrenze fuer Index berechnen */
	maxidx = 0;
	i = 0;
	while (tmp[i]) {
		if (tmp[i] == '_')
			maxidx++;
		i++;
	}
	if (txtlen > maxidx)
		txtlen = maxidx;

	/* Pixel-Koordinaten fuer Cursor berechnen */
	objc_offset(ob_edtree, ob_edobject, &x, &y);
	x = obj_xleft(ob_edtree, ob_edobject);

	/* Feld vorbelegen, da immer gleich */
	pxy[1] = y - 3;
	pxy[3] = y + tb.ch_h + 2;

	switch (ob_edkind) {
	case ED_INIT: /* Feld aufbauen und Cursor einschalten */
		if (*ob_edidx == -1)
			*ob_edidx = txtlen;

		pxy[0] = x + obj_idxabs(tmp, txt, *ob_edidx);
		pxy[2] = pxy[0];
		obj_cdraw(pxy, whandle);
		break;

	case ED_CHAR: /* Zeichen einfuegen */
		idx = *ob_edidx;
		if (ob_edstate != 0x7fff) {
			key = normkey(ob_edstate, ob_edchar);
			key &= ~(NKF_CAPS | NKF_RESVD);
			if ((key & NKF_SHIFT) != 0)
				key |= NKF_SHIFT;
		} else
			key = ob_edchar;

		switch (key) {
		/* Spezielle Funktionstasten */
		case NKF_FUNC | NK_LEFT:
			if (idx > 0)
				idx--;
			break;

		case NKF_FUNC | NK_RIGHT:
			if (idx < txtlen)
				idx++;
			break;

		case NKF_FUNC | NKF_SHIFT | NK_LEFT:
			idx = 0;
			break;

		case NKF_FUNC | NKF_SHIFT | NK_RIGHT:
			idx = txtlen;
			break;

		case NKF_FUNC | NKF_CTRL | NK_LEFT:
		case NKF_FUNC | NKF_CTRL | NK_RIGHT:
			objc_edit(ob_edtree, ob_edobject, ob_edchar, ob_edidx, ob_edkind);
			idx = *ob_edidx;
			break;

		case NKF_FUNC | NK_ESC:
		case NKF_FUNC | NKF_SHIFT | NK_ESC:
			if (txt[0]) {
				pxy[0] = x + obj_idxabs(tmp, txt, idx);
				pxy[2] = pxy[0];
				obj_cdraw(pxy, whandle);

				txt[0] = 0;
				objc_draw(ob_edtree, ob_edobject, MAX_DEPTH, tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h);

				*ob_edidx = 0;
				idx = 0;
				pxy[0] = x + obj_idxabs(tmp, txt, idx);
				pxy[2] = pxy[0];
				obj_cdraw(pxy, whandle);
			}
			break;

		case NKF_FUNC | NK_BS:
			if (idx > 0) {
				pxy[0] = x + obj_idxabs(tmp, txt, *ob_edidx);
				pxy[2] = pxy[0];
				obj_cdraw(pxy, whandle);

				idx--;
				for (i = idx; i < txtlen; i++)
					txt[i] = txt[i + 1];

				*ob_edidx = idx;
				pxy[0] = x + obj_idxabs(tmp, txt, idx);
				pxy[2] = pxy[0];
				objc_draw(ob_edtree, ob_edobject, MAX_DEPTH, pxy[0], tb.desk.g_y, tb.desk.g_w, tb.desk.g_h);
				obj_cdraw(pxy, whandle);
			}
			break;

		case NKF_FUNC | NK_DEL:
			if (txt[idx]) {
				for (i = idx; i < txtlen; i++)
					txt[i] = txt[i + 1];

				pxy[0] = x + obj_idxabs(tmp, txt, idx);
				pxy[2] = pxy[0];
				obj_cdraw(pxy, whandle);
				objc_draw(ob_edtree, ob_edobject, MAX_DEPTH, pxy[0], tb.desk.g_y, tb.desk.g_w, tb.desk.g_h);
#if 0
				pxy[0] = x + obj_idxabs(tmp, txt, idx);
				pxy[1] = y - 3;
				pxy[2] = pxy[0];
				pxy[3] = y + tb.ch_h + 2;
#endif
				obj_cdraw(pxy, whandle);
			}
			break;

			/* Normale Eingabe */
		default:
			if (!(key & NKF_FUNC) || ob_edstate == 0x7fff) {
				key &= 0xff;
				vidx = idx;
				if (vidx >= maxidx)
					vidx--;

				/* Auf Gueltigkeit pruefen bzw. Umwandeln */
				switch (valid[vidx]) {
				case 'x':
					key = nkc_toupper(key);
					break;

				case '9':
					if (key < '0' || key > '9')
						key = 0;
					break;
				} /* switch */

				/* Wenn Eingabe gueltig, dann an Cursorposition einfuegen */
				if (key) {
					i = txtlen + 1;
					while (i > idx) {
						if (i < maxidx)
							txt[i] = txt[i - 1];
						i--;
					}

					txt[vidx] = key;
					pxy[0] = x + obj_idxabs(tmp, txt, *ob_edidx);
					pxy[2] = pxy[0];
					obj_cdraw(pxy, whandle);

					pxy[0] = x + obj_idxabs(tmp, txt, vidx);
					objc_draw(ob_edtree, ob_edobject, MAX_DEPTH, pxy[0],
							tb.desk.g_y, tb.desk.g_w, tb.desk.g_h);
					if (idx < maxidx) {
						idx++;
						*ob_edidx = idx;
					}
					pxy[0] = x + obj_idxabs(tmp, txt, *ob_edidx);
					pxy[2] = pxy[0];
					obj_cdraw(pxy, whandle);
				}
			}
			break;
		} /* switch */

		if (idx != *ob_edidx) {
			pxy[0] = x + obj_idxabs(tmp, txt, *ob_edidx);
			pxy[2] = pxy[0];
			obj_cdraw(pxy, whandle);

			*ob_edidx = idx;
			pxy[0] = x + obj_idxabs(tmp, txt, *ob_edidx);
			pxy[2] = pxy[0];
			obj_cdraw(pxy, whandle);
		}
		break;

	case ED_END: /* Cursor abschalten */
		pxy[0] = x + obj_idxabs(tmp, txt, *ob_edidx);
		pxy[2] = pxy[0];
		obj_cdraw(pxy, whandle);
		break;
	} /* switch */

	return (1);
}

/**-------------------------------------------------------------------------
 tree_win()

 Passt einen Objektbaum zur Verwendung in einem Fensterdialog an
 und umgekehrt
 -------------------------------------------------------------------------*/
void tree_win(OBJECT *tree, short mode) {
	if (mode) {
		/* Dialog auf Fenster anpassen */
		if (tree[1].ob_state & WHITEBAK) {
			/* Titel ausblenden */
			setBackgroundBorderOffset(tree, 0, 0, tree[1].ob_y+tree[1].ob_height, 0, 0);
			tree[1].ob_flags |= HIDETREE;
		}
	} else {
		/* Aenderungen fuer Fensterdialog wieder rueckgaengig machen */
		if (tree[1].ob_state & WHITEBAK) {
			/* Titel einblenden */
			setBackgroundBorderOffset(tree, 0, 0, 0, 0, 0);
			tree[1].ob_flags &= ~HIDETREE;
		}
	}
}

/**-------------------------------------------------------------------------
 popup_menu()

 Durchfuehrung eines Popup-Menues
 -------------------------------------------------------------------------*/
short popup_menu(POPMENU *menu, short x, short y, short center_obj, short *ok,
		OBJECT *father) {
#if 0
	short fx, fy, fw, fh;
	short sx, sy;
	MFDB mfdb;
	long msize;
	short mxy[8];
#endif
	EVENT mevent;
	OBJECT *tree = menu->tree;
	short sx, sy;
	short done, key;
	short sel, sel1, i, rt, ob;
	short first, last, mx, my;
	short d;
	short dish, disl;
	short mouse;
	MN_SET mn_set;

	/* Aktuelle Einstellungen fuer Popup-Menues auslesen */
	if (tb.sys & SY_POPUP)
		menu_settings(0, &mn_set);
	else
		mn_set.display = 200L;
	dish = (short) ((mn_set.display >> 16L) & 0xffffL);
	disl = (short) (mn_set.display & 0xffffL);
	if (!disl && !dish)
		disl = 1;

	/* Erstes und letztes w„hlbares Objekt ermitteln */
	i = 1;
	first = last = -1;

	for (;;) {
		if (tree[i].ob_flags & SELECTABLE && !(tree[i].ob_state & DISABLED)) {
			if (first == -1)
				first = last = i;
			else
				last = i;
		}
		if (tree[i].ob_flags & LASTOB)
			break;
		i++;
	}

	/* Menue positionieren */
	if (center_obj < 1)
		center_obj = 1;
	if (father != NULL)
		tree->ob_x = x;
	else
		tree->ob_x = x - tree[center_obj].ob_x - tree[center_obj].ob_width / 2;
	tree->ob_y = y - tree[center_obj].ob_y - tree[center_obj].ob_height / 2;

	/* Und auf Desktop begrenzen */
	if ((tree->ob_x + tree->ob_width + 3) > (tb.desk.g_x + tb.desk.g_w)) {
		if (father != NULL)
			tree->ob_x = father->ob_x - tree->ob_width + tb.ch_w;
		else
			tree->ob_x = tb.desk.g_x + tb.desk.g_w - tree->ob_width - 3;
	}
	if (tree->ob_x <= tb.desk.g_x)
		tree->ob_x = tb.desk.g_x + 1;
	if ((tree->ob_y + tree->ob_height + 3) > (tb.desk.g_y + tb.desk.g_h))
		tree->ob_y = tb.desk.g_y + tb.desk.g_h - tree->ob_height - 3;
	if (tree->ob_y <= tb.desk.g_y)
		tree->ob_y = tb.desk.g_y + 1;

	/* Bildschirmhintergrund sichern */
	if (!Screen2Buffer(sx = tree->ob_x - 1, sy = tree->ob_y - 1, tree->ob_width
			+ 4, tree->ob_height + 4, TRUE)) {
		*ok = 0;
		form_dial(FMD_START, sx = tree->ob_x - 1, sy = tree->ob_y - 1,
				tree->ob_width + 4, tree->ob_height + 4, tree->ob_x - 1,
				tree->ob_y - 1, tree->ob_width + 4, tree->ob_height + 4);
	} else
		*ok = 1;

	/* Menue ausgeben und los ...*/
	objc_draw(tree, ROOT, MAX_DEPTH, tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h);

	/*
	 * Pruefen, ob Maustaste noch gedrueckt ist und ggf. Flag fuer
	 * die Auswahl mit gedrueckter Maustaste setzen.
	 */
	evnt_timer(100L);
	graf_mkstate(&mx, &my, &mevent.ev_mbreturn, &d);
	if (mevent.ev_mbreturn & 3)
		rt = 1;
	else
		rt = 0;

	mevent.ev_mflags = MU_KEYBD | MU_BUTTON | MU_M1;
	mevent.ev_mbclicks = rt ? 1 : 257;
	mevent.ev_bmask = 3;
	mevent.ev_mbstate = 0;
	mevent.ev_mm1x = tree->ob_x;
	mevent.ev_mm1y = tree->ob_y;
	mevent.ev_mm1width = tree->ob_width;
	mevent.ev_mm1height = tree->ob_height;
	mevent.ev_mm1flags = 0;
	if (father) {
		if (objc_find(tree, ROOT, MAX_DEPTH, mx, my) == -1) {
			mevent.ev_mm1x = mx;
			mevent.ev_mm1y = my;
			mevent.ev_mm1width = mevent.ev_mm1height = 1;
			mevent.ev_mm1flags = 1;
		}
	}

	done = 0;
	sel = sel1 = -1;
	mx = my = -1;

	while (!done) {
		/* Auf Tastendruck/Mausklick warten */
#if 0
		if (!rt)
		{
#endif
		EvntMulti(&mevent);
		mx = mevent.ev_mmox;
		my = mevent.ev_mmoy;
		mevent.ev_mm1flags = 1;
		mevent.ev_mtlocount = disl;
		mevent.ev_mthicount = dish;
		mouse = 0;
#if 0
	}
	else
	{
		graf_mkstate(&mevent.ev_mmox, &mevent.ev_mmoy,
				&mevent.ev_mbreturn, &mevent.ev_mmokstate);
		if(mevent.ev_mbreturn & 3)
		mevent.ev_mwich = MU_BUTTON;
		else
		{
			mevent.ev_mwich = 0;
			done = 1;
		}
	}
#endif

		showsub: if ((menu->subs != NULL) && (sel != -1) && (mevent.ev_mwich
				& MU_TIMER)) {
			for (i = 0; menu->subs[i].data.popup != NULL; i++) {
				if (menu->subs[i].obj == sel) {
					objc_offset(tree, sel, &mx, &my);
					if (menu->subs[i].type) {
						ob
								= poplist_handle(menu->subs[i].data.poplist, mx
										+ tree[sel].ob_width - tb.ch_w, my,
										(menu->subs[i].data.poplist->len + 2)
												* tb.ch_w, 1, &d, tree);
					} else {
						ob = popup_menu(menu->subs[i].data.popup, mx
								+ tree[sel].ob_width - tb.ch_w, my
								+ tree[sel].ob_height / 2,
								menu->subs[i].data.popup->sel, &d, tree);
					}
					if (ob >= -1) {
						if (menu->subs[i].type)
							menu->subs[i].data.poplist->sel = ob;
						else
							menu->subs[i].data.popup->sel = ob;
						done = 1;
						if (ob == -1)
							sel = -1;
					}
					graf_mkstate(&mx, &my, &d, &d);
					mevent.ev_mwich = 0;
					break;
				}
			}
		}

		/* Mausklick auswerten */
		if (!done && (mevent.ev_mwich & MU_BUTTON || mevent.ev_mwich & MU_M1))
#if 0
		(mevent.ev_mwich & MU_M1 &&
				(mx != mevent.ev_mmox || my != mevent.ev_mmoy)))
#endif
		{
			mouse = 1;
			/* Objekt suchen */
			ob = objc_find(tree, ROOT, MAX_DEPTH, mx, my);
			/* Und bearbeiten ... */
			if (ob == -1) {
				/* Ausserhalb des Menues */
				sel = -1;
#if 0
				if (mevent.ev_mwich & MU_BUTTON && !rt)
#else
				if (mevent.ev_mwich & MU_BUTTON)
#endif
					done = 1;
				else if (father != NULL) {
					ob = objc_find(father, ROOT, MAX_DEPTH, mx, my);
					if ((ob > 0) && !(father[ob].ob_state & SELECTED)) {
						sel = -2;
						done = 1;
					}
				}
			} else {
				/* Objekte w„hlbar? */
				if (tree[ob].ob_flags & SELECTABLE && !(tree[ob].ob_state
						& DISABLED))
					sel = ob;
				else
					sel = -1;
#if 0
				if (mevent.ev_mwich & MU_BUTTON && !rt)
#else
				if (mevent.ev_mwich & MU_BUTTON)
#endif
				{
					if (mevent.ev_mwich & MU_TIMER)
						done = 1;
					else {
						mevent.ev_mwich |= MU_TIMER;
						goto showsub;
					}
				}
			}
		}

		/* Tastendruck auswerten */
		if (!done && mevent.ev_mwich & MU_KEYBD) {
			key = normkey(mevent.ev_mmokstate, mevent.ev_mkreturn);
			key &= ~(NKF_RESVD | NKF_CAPS | NKF_CTRL | NKF_ALT);
			if (key & NKF_LSH || key & NKF_RSH)
				key |= NKF_SHIFT;

			switch (key) {
			case NKF_FUNC | NK_UP:
			case NKF_FUNC | NK_UP | NKF_SHIFT:
				if (sel == -1)
					sel = last;
				else {
					sel--;
					while ((!(tree[sel].ob_flags & SELECTABLE)
							|| tree[sel].ob_state & DISABLED) && sel > first) {
						sel--;
					}

					if (!(tree[sel].ob_flags & SELECTABLE)
							|| tree[sel].ob_state & DISABLED)
						sel = last;
				}
				break;

			case NKF_FUNC | NK_DOWN:
			case NKF_FUNC | NK_DOWN | NKF_SHIFT:
				if (sel == -1)
					sel = first;
				else {
					sel++;
					while ((!(tree[sel].ob_flags & SELECTABLE)
							|| tree[sel].ob_state & DISABLED) && sel < last) {
						sel++;
					}

					if (!(tree[sel].ob_flags & SELECTABLE)
							|| tree[sel].ob_state & DISABLED)
						sel = first;
				}
				break;

			case NKF_FUNC | NK_LEFT:
				if (father) {
					sel = -2;
					done = 1;
				}
				break;

			case NKF_FUNC | NK_RIGHT:
				mevent.ev_mwich = MU_TIMER;
				goto showsub;

			case NKF_FUNC | NK_ESC:
			case NKF_FUNC | NK_UNDO:
			case NKF_FUNC | NK_ESC | NKF_SHIFT:
			case NKF_FUNC | NK_UNDO | NKF_SHIFT:
				sel = -1;
				done = 1;
				break;

			case NKF_FUNC | NK_CLRHOME:
				sel = first;
				break;

			case NKF_FUNC | NK_CLRHOME | NKF_SHIFT:
				sel = last;
				break;

			case NKF_FUNC | NKF_NUM | NK_ENTER:
			case NKF_FUNC | NKF_NUM | NK_ENTER | NKF_SHIFT:
			case NKF_FUNC | NK_RET:
			case NKF_FUNC | NK_RET | NKF_SHIFT:
				if (mevent.ev_mwich & MU_TIMER)
					done = 1;
				else {
					mevent.ev_mwich |= MU_TIMER;
					goto showsub;
				}
				break;
			} /* switch */
		}

		/* Auswahl ge„ndert ? */
		if (sel != sel1) {
			if (sel1 >= 0)
				objc_change(tree, sel1, 0, tb.desk.g_x, tb.desk.g_y, tb.desk.g_w,
						tb.desk.g_h, tree[sel1].ob_state & ~SELECTED, 1);

			if (sel >= 0) {
				objc_change(tree, sel, 0, tb.desk.g_x, tb.desk.g_y, tb.desk.g_w,
						tb.desk.g_h, tree[sel].ob_state | SELECTED, 1);
			}

			sel1 = sel;
		}
		if (mouse && (sel >= 0)) {
			objc_offset(tree, ob, &mevent.ev_mm1x, &mevent.ev_mm1y);
			mevent.ev_mm1width = tree[ob].ob_width;
			mevent.ev_mm1height = tree[ob].ob_height;
			mevent.ev_mflags |= MU_TIMER;
		} else {
			mevent.ev_mm1width = mevent.ev_mm1height = 1;
			mevent.ev_mm1x = mx;
			mevent.ev_mm1y = my;
			mevent.ev_mflags &= ~MU_TIMER;
		}
	}

	/* Zuletzt selektiertes Objekt wieder normal darstellen */
	if (sel >= 0)
		objc_change(tree, sel, 0, tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h,
				tree[sel].ob_state & ~SELECTED, 0);

	/* Bildschirmhintergrund wiederherstellen */
	if (*ok) {
		Screen2Buffer(sx, sy, tree->ob_width + 4, tree->ob_height + 4, FALSE);
	} else {
		form_dial(FMD_FINISH, sx, sy, tree->ob_width + 4, tree->ob_height + 4,
				tree->ob_x - 1, tree->ob_y - 1, tree->ob_width + 4,
				tree->ob_height + 4);
	}

	/* Loslassen der Maustaste abwarten */
	if (!rt)
		evnt_button(1, 3, 0, &d, &d, &d, &d);

	return (sel);
}

/**-------------------------------------------------------------------------
 pop_set()

 šbernimmt eine Menueauswahl eines Popup-Menues in den Dialog.
 -------------------------------------------------------------------------*/
void pop_set(FORMINFO *fi, POPMENU *pop) {
	short newtype, oldtype;
	OBJECT *form, *popup;

	form = &fi->tree[pop->formobj];
	popup = &pop->tree[pop->sel + pop->objoff];
	newtype = pop->formtype;
	if (newtype == -1)
		newtype = popup->ob_type;

	oldtype = form->ob_type;
	if ((oldtype == G_TEXT) || (oldtype == G_BOXTEXT)) {
		form->ob_spec.tedinfo->te_ptext
				= (newtype == G_STRING) ? popup->ob_spec.free_string
						: popup->ob_spec.tedinfo->te_ptext;
	} else {
		form->ob_type = newtype;
		form->ob_spec = popup->ob_spec;
	}
}

/**-------------------------------------------------------------------------
 poplist_set()

 šbernimmt eine Listenauswahl einer Popup-Liste in den Dialog.
 -------------------------------------------------------------------------*/
void poplist_set(FORMINFO *fi, POPLIST *pop) {
	OBJECT *obj;

	obj = &fi->tree[pop->formset];
	if (pop->sel != -1) {
		strcpy(obj->ob_spec.tedinfo->te_ptext, pop->list[pop->sel]);
		obj->ob_spec.tedinfo->te_color &= ~(128 | 15);
		obj->ob_spec.tedinfo->te_color |= 7 << 4;
		obj->ob_spec.tedinfo->te_color
				|= (tb.use3d && (tb.colors >= 16)) ? getBackgroundColor()
						: G_WHITE;

		if (!(obj->ob_width % tb.ch_w))
			obj->ob_width--;
	}
}

/**-------------------------------------------------------------------------
 poplist_get()

 Ermittelt die Aktuelle Auswahl einer Popup-Liste anhand des Textes
 im Eingabefeld
 -------------------------------------------------------------------------*/
void poplist_get(FORMINFO *fi, POPLIST *pop) {
	short i;

	pop->sel = -1;
	for (i = 0; i < pop->num; i++)
		if (!strcmp(pop->list[i],
				fi->tree[pop->formset].ob_spec.tedinfo->te_ptext))
			pop->sel = i;
}

/**-------------------------------------------------------------------------
 pop_do()

 Wird von frm_do() bei Tastatur- und Maus-Events aufgerufen um
 auf Popup-Menues zu pruefen. Falls ein Popup-Menue gew„hlt wurde, wird
 die Auswahl automatisch in den Dialog uebernommen.

 Funktionsergebnis: 0=Kein Popup-Menue ausgew„hlt
 1=Popup-Menue oder Shortcut eines Popup-Menues gew„hlt
 2=Auswahl durchgefuehrt und Popup-Objekt enth„lt
 "TOUCHEXIT"-Flag
 -------------------------------------------------------------------------*/
short pop_do(short mode, FORMINFO *fi, short obj, short ks, short kr, short *edit_obj,
		short *idx, short whandle, short *next_obj) {
	short px, py, pn, pok, pret, pobj, pdo;
	short sstate = 0;
	POPMENU *pop;

	if (!mode)
		pobj = shortcut(fi->tree, ks, kr, -1, -1);
	else
		pobj = obj;

	pret = 0;
	pdo = 0;

	if (pobj != -1) {
		pn = 0;
		pret = -1;

		while (fi->popup[pn]) {
			pop = fi->popup[pn];

			/*
			 * Falls Shortcut angeklickt wurde, dann an frm_do() melden,
			 * dass keine weitere Verarbeitung erfolgen soll.
			 */
			if (mode == 1 && pop->formshort == pobj)
				pdo = 1;

			/*
			 * Popup ausfuehren, falls via Mausklick oder Shortcut gew„hlt.
			 */
			if ((mode && pop->formobj == pobj) || (!mode && pop->formshort == pobj)) {
				/* Abbrechen, falls Popup DISABLED ist */
				if (fi->tree[pop->formobj].ob_state & DISABLED)
					return (1);

				if (fi->state == FST_WIN)
					wind_update (BEG_MCTRL);
				graf_mouse(ARROW, 0L);

				/* Cursor ausschalten */
				if (*edit_obj)
					obj_edit(fi->tree, *edit_obj, 0, 0, idx, ED_END, whandle);

				pdo = 1;

				/* Position fuer das Menue berechnen */
				objc_offset(fi->tree, pop->formobj, &px, &py);
				px += (fi->tree[pop->formobj].ob_width / 2) + pop->offx;
				py += (fi->tree[pop->formobj].ob_height / 2) + pop->offy;

				/* Zugeh”rigen Shortcut selektieren */
				if (pop->formshort >= 0) {
					sstate = fi->tree[pop->formshort].ob_state;
					objc_change(fi->tree, pop->formshort, 0, tb.desk.g_x,
							tb.desk.g_y, tb.desk.g_w, tb.desk.g_h, sstate | SELECTED,
							1);
				}

				/* Menueauswahl durchfuehren */
				pret = popup_menu(pop, px, py, pop->sel, &pok, NULL);

				/* Shortcut wieder deselektieren */
				if (pop->formshort >= 0) {
					objc_change(fi->tree, pop->formshort, 0, tb.desk.g_x,
							tb.desk.g_y, tb.desk.g_w, tb.desk.g_h, sstate, 1);
				}

				/*
				 * Weitere Verarbeitung nur wenn ein Menueeintrag ausgew„hlt
				 * wurde.
				 */
				if (pret != -1) {
					/*
					 * Falls die entsprechende Option im Menue gesetzt ist, dann
					 * Menueeintrag in den Dialog uebernehmen.
					 */
					if (pop->take == 1) {
						pop->sel = pret;
						pop_set(fi, pop);
						objc_draw(fi->tree, pop->formobj - 1, MAX_DEPTH, tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h);
					}
					if (fi->tree[pop->formobj].ob_flags & TOUCHEXIT) {
						*next_obj = pop->formobj;
						pdo = 2;
					}
				}

				/* Objektbaum neu zeichnen, falls n”tig */
				if (!pok && fi->state != FST_WIN)
					objc_draw(fi->tree, ROOT, MAX_DEPTH, tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h);

				/* Cursor einschalten */
				if (*edit_obj == pop->formobj)
					*idx = -1;
				if (*edit_obj)
					obj_edit(fi->tree, *edit_obj, 0, 0, idx, ED_INIT,
							fi->win.handle);

				if (!tb.mbusy)
					graf_mouse(tb.mform, 0L);
				else
					graf_mouse(BUSYBEE, 0L);

				if (fi->state == FST_WIN)
					wind_update (END_MCTRL);
			}
			pn++;
		}
	}

	return (pdo);
}

/**-------------------------------------------------------------------------
 poplist_do()

 Wird von frm_do() bei Tastatur- und Maus-Events aufgerufen um
 auf Popup-Listen zu pruefen. Falls ein Listeneintrag gew„hlt wurde, wird
 die Auswahl automatisch in den Dialog uebernommen.

 Funktionsergebnis: 0=Kein Listeneintrag ausgew„hlt
 1=Listeneintrag gew„hlt
 2=Listeneintrag gew„hlt Popup-Objekt enth„lt
 "TOUCHEXIT"-Flag
 -------------------------------------------------------------------------*/

/*
 * is_disabled
 *
 * Unterfunktion fuer poplist_handle: Testet, ob eine Zeichenkette nur
 * aus Minuszeichen besteht. Leere Zeichenketten erfuellen die
 * Bedingung nicht.
 *
 * Eingabe:
 * p: Zeiger auf zu testende Zeichenkette
 *
 * Rueckgabe:
 * 0: Zeichenkette enth„lt nicht nur Minuszeichen oder ist leer
 * sonst: Zeichenkette besteht durchgehen aus Minuszeichen
 */
static short is_disabled(char *p) {
	if (!*p)
		return (0);
	for (; *p == '-'; p++)
		;
	return (!*p);
}

/* Unterfunktion: Aktualisieren der Liste - wurde ausgelagert um das
 "Realtime"-Scrolling mit dem Slider zu erm”glichen */
void poplist_update(short *offset, short *offset1, POPLIST *pop, short vnum, short sel) {
	long spos; /* Sliderposition */
	short i, j, l, delta;
	short pxy[8];
	OBJECT *tree; /* Objekt-Baum */
	char tmp[256];

	tree = rs_trindex[0];

	/* Sliderposition aktualisieren */
	if (pop->num > vnum) {
		spos = (long) *offset * (long) (tree[POPLISTSBAR].ob_height - tree[POPLISTSLIDER].ob_height) / (long) (pop->num - vnum);
		tree[POPLISTSLIDER].ob_y = (short) spos;
		objc_draw(tree, POPLISTSBAR, MAX_DEPTH, tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h);
	}

	/* Liste aktualisieren */
	for (i = 0; i < vnum; i++) {
		tree[i + 2].ob_type = pop->copy[i].ob_type;
		tree[i + 2].ob_spec = pop->copy[i].ob_spec;
		if (i + *offset == sel)
			tree[i + 2].ob_state |= SELECTED;
		else
			tree[i + 2].ob_state &= ~SELECTED;

		strcpy(tmp, pop->list[i + *offset]);
		l = (short) strlen(pop->list[i + *offset]);
		for (j = l; j < pop->len; j++)
			tmp[j] = ' ';
		tmp[j] = 0;

		setObjectText(tree, i + 2, tmp);

		/* Eintr„ge, die nur aus '-' bestehen, sind "disabled" */
		if (is_disabled(pop->list[i + *offset])) {
			tree[i + 2].ob_state &= ~SELECTED;
			tree[i + 2].ob_type = sepline.ob_type;
			tree[i + 2].ob_spec = sepline.ob_spec;
		}
	}

	/* ... optimiertes Redraw m”glich ? */
	delta = *offset - *offset1;
	if (abs(delta) >= vnum) {
		/* Nein - komplett neuzeichnen */
		objc_draw(tree, 1, MAX_DEPTH, tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h);
	} else {
		/* Ja - nur scrollen und Teile neuzeichnen */
		pxy[0] = pxy[4] = tree->ob_x + tree[1].ob_x;
		pxy[1] = pxy[5] = tree->ob_y + tree[1].ob_y;
		pxy[2] = pxy[6] = pxy[0] + tree[1].ob_width - 1;
		pxy[3] = pxy[7] = pxy[1] + tree[1].ob_height - 1;

		delta *= tb.ch_h;
		if (delta < 0) {
			pxy[3] += delta;
			pxy[5] -= delta;
		} else {
			pxy[1] += delta;
			pxy[7] -= delta;
		}

		/* Ausschnitt verschieben */
		graf_mouse(M_OFF, 0L);
		vro_cpyfm(v_handle, S_ONLY, pxy, &scr_mfdb, &scr_mfdb);
		graf_mouse(M_ON, 0L);

		/* Žnderungen ausgeben */
		if (delta < 0) {
			objc_draw(tree, 1, MAX_DEPTH, tree->ob_x, tree->ob_y + tree[1].ob_y, tree->ob_width, -delta);
		} else {
			objc_draw(tree, 1, MAX_DEPTH, tree->ob_x, tree->ob_y + tree[1].ob_y + vnum * tb.ch_h - delta, tree->ob_width, delta);
		}
	}
	*offset1 = *offset;
}

short poplist_do(short mode, FORMINFO *fi, short obj, short ks, short kr, short *edit_obj,
		short *idx, short whandle, short *exit_obj) {
	short px, py, pn, pok, pret, pobj, pdo;
	POPLIST *pop;
	short sstate = 0;

	if (!mode)
		pobj = shortcut(fi->tree, ks, kr, -1, -1);
	else
		pobj = obj;

	pret = 0;
	pdo = 0;

	if (pobj != -1) {
		pn = 0;
		pret = -1;

		while (fi->poplist[pn]) {
			pop = fi->poplist[pn];

			/*
			 * Falls Shortcut angeklickt wurde, dann an frm_do() melden,
			 * dass keine weitere Verarbeitung erfolgen soll
			 */
			if (mode == 1 && pop->formshort == pobj)
				pdo = 1;

			/*
			 * Popup-Liste ausfuehren, falls via Mausklick oder Shortcut
			 * gew„hlt, oder das angeklickte Textfeld nicht editierbar ist.
			 */
			if ((mode && pop->formobj == pobj) || (!mode && pop->formshort == pobj) || (mode && pop->formset == pobj && !(fi->tree[pop->formset].ob_flags & EDITABLE))) {
				/* Abbrechen, falls das Popup DISABLED ist */
				if (fi->tree[pop->formobj].ob_state & DISABLED)
					return (pdo);

				pdo = 1;
				/* Position fuer die Liste berechnen */
				objc_offset(fi->tree, pop->formset, &px, &py);
				px--; /* Wegen Rahmen */

				if (fi->open) {
					/* Cursor ausschalten */
					if (*edit_obj)
						obj_edit(fi->tree, *edit_obj, 0, 0, idx, ED_END, whandle);

					/* Ausl”ser selektieren */
					objc_change(fi->tree, pop->formobj, 0, tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h, SELECTED | SHADOWED, 1);

					/* Zugeh”rigen Shortcut selektieren */
					if (pop->formshort >= 0) {
						sstate = fi->tree[pop->formshort].ob_state;
						objc_change(fi->tree, pop->formshort, 0, tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h, sstate | SELECTED, 1);
					}
				}

				pret = poplist_handle(pop, px, py, fi->tree[pop->formset].ob_width, fi->tree[pop->formset].ob_height, &pok, NULL);

				if (fi->open) {
					/* Ausl”ser deselektieren */
					objc_change(fi->tree, pop->formobj, 0, tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h, NORMAL | SHADOWED, 1);

					/* Shortcut wieder deselektieren */
					if (pop->formshort >= 0) {
						objc_change(fi->tree, pop->formshort, 0, tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h, sstate, 1);
					}
				}

				/* Weitere Verarbeitung nur wenn Menueeintrag ausgew„hlt wurde */
				if (pret != -1) {
					if (fi->tree[pop->formobj].ob_flags & TOUCHEXIT) {
						*exit_obj = pop->formobj;
						pdo = 2;
					}

					/* Listeneintrag in den Dialog uebernehmen */
					if (fi->open) {
						poplist_set(fi, pop);
						objc_draw(fi->tree, pop->formset, MAX_DEPTH, tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h);
						objc_draw(fi->tree, pop->formobj, MAX_DEPTH, tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h);
					}
				}

				/* Objektbaum neu zeichnen, falls n”tig */
				if (fi->open) {
					if (!pok && fi->state != FST_WIN)
						objc_draw(fi->tree, ROOT, MAX_DEPTH, tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h);

					/* Cursor einschalten */
					if (*edit_obj == pop->formset)
						*idx = -1;
					if (*edit_obj)
						obj_edit(fi->tree, *edit_obj, 0, 0, idx, ED_INIT, whandle);
				}
			}
			pn++;
		}
	}

	return (pdo);
}

/*
 * poplist_handle
 *
 * Unterfunktion zu poplist_do(), die aber auch direkt aufgerufen
 * werden kann.
 *
 * Eingabe:
 * pop: Zeiger auf beschreibende POPLIST-Struktur
 * px,py: Position, an der die Listbox aufgehen soll
 * width: Breite des Ausl”sers in Pixeln (oder der Listboxeintr„ge)
 * oh: H”he des Ausl”sers in Pixeln (oder 1)
 * pok: Zeiger auf int; hier steht nach Aufruf eine 1, wenn der
 *      Bildschirmhintergrund nicht aktualisiert werden muž, sonst 0
 * father: Ggf. Zeiger auf "Vaterdialog" bei Listboxen, die als
 *         Untermenue eines Popups fungieren, sonst NULL
 *
 * Rueckgabe:
 * Gew„hlter Eintrag (ggf. -1), der auch in *pop gesetzt wird
 */
short poplist_handle(POPLIST *pop, short px, short py, short width, short oh, short *pok,
		OBJECT *father) {
	EVENT mevent;
	short sel, sel1, vnum, offset, offset1, done, pret, rt, mx, my, ox, oy,
			keyflag, dir, rs, ob, key, i, j, l, d;
	long ssize, spos;
	OBJECT *tree, *line, copy[LISTSIZE];
	char tmp[256];

	tree = rs_trindex[0];

	/* Diverse Parameter vorbereiten */
	sel = pop->sel;
	tree[POPLISTLINE].ob_flags |= HIDETREE;
	if (pop->num > LISTSIZE) {
		vnum = LISTSIZE;
		tree[POPLISTUP].ob_flags &= ~HIDETREE;
		tree[POPLISTSBAR].ob_flags &= ~HIDETREE;
		tree[POPLISTDOWN].ob_flags &= ~HIDETREE;
	} else {
		vnum = pop->num;
		tree[POPLISTUP].ob_flags |= HIDETREE;
		tree[POPLISTSBAR].ob_flags |= HIDETREE;
		tree[POPLISTDOWN].ob_flags |= HIDETREE;
		if (pop->formshort != -1)
			tree[POPLISTLINE].ob_flags &= ~HIDETREE;
	}
	if (sel != -1) {
		if (pop->num > vnum) {
			offset = sel - vnum + 4;
			if (offset + vnum > pop->num)
				offset = pop->num - vnum;
			if (offset < 0)
				offset = 0;
		} else
			offset = 0;
	} else
		offset = 0;

	/* ... Liste */
	rs_textadjust(tree, (tb.use3d && (tb.colors >= 16)) ? getBackgroundColor() : G_WHITE);
	tree[1].ob_width = sepline.ob_width = width - 1;
	tree[1].ob_height = tb.ch_h * vnum;
	pop->copy = copy;
	for (i = 0; i < LISTSIZE; i++) {
		line = &tree[i + 2];
		copy[i] = *line;
		line->ob_width = tree[1].ob_width;
		line->ob_state = NORMAL;
		if (i < vnum) {
			line->ob_flags &= ~HIDETREE;
			strcpy(tmp, pop->list[i + offset]);
			l = (short) strlen(pop->list[i + offset]);
			for (j = l; j < pop->len; j++)
				tmp[j] = ' ';
			tmp[j] = 0;
			setObjectText(tree, i + 2, tmp);

			if (i + offset == sel)
				line->ob_state = SELECTED;

			/*
			 * Eintr„ge, die nur aus '-'-Zeichen bestehen, sind
			 * "disabled".
			 */
			if (is_disabled(pop->list[i + offset])) {
				line->ob_state = NORMAL;
				line->ob_type = sepline.ob_type;
				line->ob_spec = sepline.ob_spec;
			}
		} else
			line->ob_flags |= HIDETREE;
	}

	/* ... Arrow rauf */
	tree[POPLISTUP].ob_x = tree[1].ob_x + tree[1].ob_width;

	/* ... Arrow runter */
	tree[POPLISTDOWN].ob_x = tree[POPLISTUP].ob_x;
	tree[POPLISTDOWN].ob_y = tree[1].ob_y + tree[1].ob_height - tree[POPLISTDOWN].ob_height + 1;

	/* ... Scrollbar */
	tree[POPLISTSBAR].ob_x = tree[POPLISTUP].ob_x + 1;
	tree[POPLISTSBAR].ob_y = tree[1].ob_y + tree[7].ob_height + 1;
	tree[POPLISTSBAR].ob_height = tree[1].ob_height - tree[POPLISTUP].ob_height - tree[POPLISTDOWN].ob_height + 2;

	/* ... Slider */
	if (pop->num <= vnum) {
		ssize = (long) tree[POPLISTSBAR].ob_height;
		spos = 0L;
	} else {
		ssize = (long) tree[POPLISTSBAR].ob_height * (long) vnum / (long) pop->num;
		if (ssize < (long) tree[POPLISTSLIDER].ob_width)
			ssize = (long) tree[POPLISTSLIDER].ob_width;

		spos = (long) offset * ((long) tree[POPLISTSBAR].ob_height - ssize) / (long) (pop->num - vnum);
	}
	tree[POPLISTSLIDER].ob_height = (short) ssize;
	tree[POPLISTSLIDER].ob_y = (short) spos;

	/* Die Trennlinie */
	tree[POPLISTLINE].ob_x = tree[1].ob_width;
	tree[POPLISTLINE].ob_height = tree[1].ob_height;
	tree[POPLISTLINE].ob_width = 1;

	/* ... das Menue selber */
	tree->ob_x = px;
	tree->ob_y = py + oh - 1;
	if (father)
		tree->ob_y -= tree[POPLISTBOX].ob_y;
	tree->ob_width = pop_offx + tree[1].ob_width + tree[POPLISTUP].ob_width - 2;
	if ((pop->num <= LISTSIZE) && (pop->formshort == -1))
		tree->ob_width -= tree[POPLISTUP].ob_width;
	tree->ob_height = pop_offy + tree[1].ob_height - 1;

	/* ... vollst„ndig sichtbar ? */
	if ((tree->ob_x + tree->ob_width + 3) > (tb.desk.g_x + tb.desk.g_w)) {
		if (father)
			tree->ob_x = father->ob_x - tree->ob_width + tb.ch_w;
		else
			tree->ob_x = tb.desk.g_x + tb.desk.g_w - tree->ob_width - 3;
	}
	if (tree->ob_x <= tb.desk.g_x)
		tree->ob_x = tb.desk.g_x + 1;
	if ((tree->ob_y + tree->ob_height + 2) >= (tb.desk.g_y + tb.desk.g_h)) {
		/* Liste verschieben oder nach oben "aufklappen" */
		if (father) {
			oy = tree->ob_y;
			tree->ob_y = tb.desk.g_y + tb.desk.g_h - tree->ob_height - 2;
			if ((oy - tree->ob_y) % tb.ch_h)
				tree->ob_y += (oy - tree->ob_y) % tb.ch_h - tb.ch_h;
		} else {
			tree->ob_y = py - tree->ob_height - 1;

			/* Trotzdem aužerhalb des Desktops ? */
			if ((tree->ob_y + tree->ob_height + 2) >= (tb.desk.g_y + tb.desk.g_h))
				tree->ob_y = tb.desk.g_y + tb.desk.g_h - tree->ob_height - 3;
		}
	}

	/* Listenauswahl durchfuehren ... */
	pret = -1;

	wind_update( BEG_MCTRL);
	graf_mouse(ARROW, 0L);

	/* Bildschirmhintergrund sichern */
	if (!Screen2Buffer(tree->ob_x - 1, tree->ob_y - 1, tree->ob_width + 4,
			tree->ob_height + 4, TRUE)) {
		*pok = 0;
		form_dial(FMD_START, tree->ob_x - 1, tree->ob_y - 1, tree->ob_width + 4, tree->ob_height + 4, tree->ob_x - 1, tree->ob_y - 1, tree->ob_width + 4, tree->ob_height + 4);
	} else
		*pok = 1;

	/* Liste zeichnen */
	objc_draw(tree, ROOT, MAX_DEPTH, tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h);

	/* Auf gehts ... */
	done = 0;
	offset1 = offset;
	sel1 = sel;

	/*
	 * Pruefen, ob Maustaste noch gedrueckt ist und ggf. Flag fuer
	 * die Auswahl mit gedrueckter Maustaste setzen.
	 */
	evnt_timer(100L);
	graf_mkstate(&mevent.ev_mmox, &mevent.ev_mmoy, &mevent.ev_mbreturn, &mevent.ev_mmokstate);
	if (mevent.ev_mbreturn & 3)
		rt = 1;
	else
		rt = 0;

	/* Aktuelle Mausposition merken */
	mx = mevent.ev_mmox;
	my = mevent.ev_mmoy;
	keyflag = 0;

	/*
	 * Flag fuer Scrollen bei Auswahl mit gedrueckter Maustaste
	 * l”schen - Scrollen beim Verlassen der Liste wird erst
	 * durchgefuehrt, wenn man mit der Maus einen Eintrag in der
	 * Liste selektiert hat.
	 */
	rs = 0;

	mevent.ev_mflags = MU_KEYBD | MU_BUTTON | MU_M1;
	mevent.ev_mm1flags = 0;
	mevent.ev_mm1x = tb.desk.g_x;
	mevent.ev_mm1y = tb.desk.g_y;
	mevent.ev_mm1width = tb.desk.g_w;
	mevent.ev_mm1height = tb.desk.g_h;
	mevent.ev_mtlocount = 10;
	mevent.ev_mthicount = 0;
	mevent.ev_mbclicks = rt ? 1 : 257;
	mevent.ev_bmask = 3;
	mevent.ev_mbstate = 0;
	if (father) {
		if (objc_find(tree, ROOT, MAX_DEPTH, mx, my) == -1) {
			mevent.ev_mm1x = mx;
			mevent.ev_mm1y = my;
			mevent.ev_mm1width = mevent.ev_mm1height = 1;
			mevent.ev_mm1flags = 1;
		}
	}

	while (!done) {
		/* Liste bei Bedarf aktualisieren */
		if (offset != offset1)
			poplist_update(&offset, &offset1, pop, vnum, sel);

		/* Auf Tastendruck/Mausklick warten */
#if 0
		if (!rt)
		{
#endif
		EvntMulti(&mevent);
		mevent.ev_mm1flags = 1;
		mevent.ev_mm1width = mevent.ev_mm1height = 1;
		mevent.ev_mm1x = mevent.ev_mmox;
		mevent.ev_mm1y = mevent.ev_mmoy;
#if 0
	}
	else
	{
		graf_mkstate(&mevent.ev_mmox, &mevent.ev_mmoy,
				&mevent.ev_mbreturn, &mevent.ev_mmokstate);
		if(mevent.ev_mbreturn & 3)
		mevent.ev_mwich = MU_BUTTON;
		else
		{
			mevent.ev_mwich = 0;
			done = 1;
		}
	}
#endif

		/* Mausklick auswerten */
		if ((mevent.ev_mwich & MU_BUTTON) || (mevent.ev_mwich & MU_M1) || (mevent.ev_mwich & MU_TIMER)) {
			/*
			 * Falls Maus bewegt wurde, dann Sperre fuer Echtzeit-
			 * Auswahl aufheben.
			 */
			if (mx != mevent.ev_mmox || my != mevent.ev_mmoy) {
				keyflag = 0;
				mx = mevent.ev_mmox;
				my = mevent.ev_mmoy;
			}

			/* Objekt suchen */
			ob = objc_find(tree, ROOT, MAX_DEPTH, mevent.ev_mmox, mevent.ev_mmoy);

			/* Und bearbeiten ... */
			if (rs) /* Evtl. Scroll durch die Liste */
			{
				if (ob < 2 || ob > (LISTSIZE + 1)) {
					sel = -1;
					/*
					 * Scroll nur, wenn Maus horizontal im Bereich der
					 * Liste liegt.
					 */
					if (mevent.ev_mmox >= tree->ob_x && mevent.ev_mmox
							< tree->ob_x + tree[2].ob_width) {
						if (mevent.ev_mmoy < tree->ob_y) {
							/* Maus oberhalb der Liste */
							if (offset > 0) {
								offset--;
								evnt_timer(70L);
							}
						} else {
							if (mevent.ev_mmoy >= tree->ob_y + tree->ob_height) {
								/* Maus unterhalb der Liste */
								if (offset < pop->num - vnum) {
									offset++;
									evnt_timer(70L);
								}
							}
						}
					}
#if 0
					else
					{
						/*
						 * Hier optional: Wenn nicht mit gedrueckter Maustaste,
						 * dann Realtime-Scroll abschalten, wenn Maus nicht
						 * horizontal im Bereich der Liste lag.
						 */
						/*         if(!rt) rs=0; */
					}
#endif
					pret = sel;
				}
#if 0
				else /* Maus innerhalb der Liste */
				{
				}
#endif
			}

			/* Weitere Verarbeitung */
			switch (ob) {
			case -1: /* Aužerhalb der Liste */
				/* Bei Mausklick Abbruch der Auswahl */
				if (mevent.ev_mwich & MU_BUTTON) {
					pret = -1;
					done = 1;
				} else if (father) {
					ob = objc_find(father, ROOT, MAX_DEPTH, mevent.ev_mmox, mevent.ev_mmoy);
					if ((ob > 0) && !(father[ob].ob_state & SELECTED)) {
						pret = -2;
						done = 1;
					}
				}
				break;

			case POPLISTUP: /* Arrow up */
			case POPLISTDOWN: /* Arrow down */
				if (!rt && mevent.ev_mwich & MU_BUTTON) {
					objc_change(tree, ob, 0, tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h, SELECTED, 1);

					while (mevent.ev_mbreturn & 1) {
						if (ob == POPLISTUP) {
							if (offset > 0) {
								offset--;
								poplist_update(&offset, &offset1, pop, vnum, sel);
								evnt_timer(70L); /* Slow down ... */
							}
						} else {
							if (offset < pop->num - vnum) {
								offset++;
								poplist_update(&offset, &offset1, pop, vnum, sel);
								evnt_timer(70L); /* Slow down ... */
							}
						}

						/* Mausstatus */
						graf_mkstate(&mevent.ev_mmox, &mevent.ev_mmoy, &mevent.ev_mbreturn, &mevent.ev_mmokstate);
					}
					objc_change(tree, ob, 0, tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h, NORMAL, 1);
				}
				break;
			case POPLISTSBAR: /* Scrollbar */
				if (!rt && mevent.ev_mwich & MU_BUTTON) {
					if (pop->num > vnum) {
						/* Position des Sliders */
						objc_offset(tree, POPLISTSLIDER, &px, &py);
						oy = mevent.ev_mmoy;
						while (mevent.ev_mbreturn & 1) {
							if (oy < py) /* šber dem Slider angeklickt ? */
							{
								offset -= vnum;
								if (offset < 0)
									offset = 0;
							} else /* Nein, darunter */
							{
								offset += vnum;
								if (offset > pop->num - vnum)
									offset = pop->num - vnum;
							}

							/* Liste ggf. aktualisieren */
							if (offset != offset1)
								poplist_update(&offset, &offset1, pop, vnum, sel);

							/* Mausstatus */
							graf_mkstate(&mevent.ev_mmox, &mevent.ev_mmoy, &mevent.ev_mbreturn, &mevent.ev_mmokstate);
						}
					}
				}
				break;

			case POPLISTSLIDER: /* Slider */
				if (!rt && mevent.ev_mwich & MU_BUTTON) {
					if (pop->num > vnum) {
						/* Position des Scrollbar */
						objc_offset(tree, POPLISTSBAR, &ox, &oy);

						/* Position des Sliders */
						objc_offset(tree, POPLISTSLIDER, &px, &py);

						/* Abstand Slider-Maus */
						i = mevent.ev_mmoy - py - 1;
						graf_mouse(FLAT_HAND, 0L);

						/* Bei 3D-Optik Slider selektieren */
						if (tb.use3d) {
							objc_change(tree, POPLISTSLIDER, 0, tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h, SELECTED, 1);
						}
						/* Position des Sliders */
						objc_offset(tree, POPLISTSLIDER, &px, &py);

						while (mevent.ev_mbreturn & 1) {
							/* Offset berechnen */
							spos = (long) (pop->num - vnum) * (long) (mevent.ev_mmoy - oy - i) / (long) (tree[POPLISTSBAR].ob_height - tree[POPLISTSLIDER].ob_height);

							offset = (short) spos;
							if (offset < 0)
								offset = 0;
							if (offset > pop->num - vnum)
								offset = pop->num - vnum;

							/* Liste aktualisieren, falls n”tig */
							if (offset != offset1) {
								poplist_update(&offset, &offset1, pop, vnum, sel);
								/* Position des Sliders */
								objc_offset(tree, POPLISTSLIDER, &px, &py);
							}
							/* Mausstatus */
							graf_mkstate(&mevent.ev_mmox, &mevent.ev_mmoy, &mevent.ev_mbreturn, &mevent.ev_mmokstate);
						}

						/* Bei 3D-Optik Slider deselektieren */
						if (tb.use3d) {
							objc_change(tree, POPLISTSLIDER, 0, tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h, NORMAL, 1);
						}
						graf_mouse(ARROW, 0L);
					}
				}
				break;

			default:
				if (ob >= 2 && ob <= (LISTSIZE + 1) && !keyflag) {
					sel = offset + ob - 2; /* Nummer des Eintrags */
					/*
					 * Scrollen bei Auswahl mit gedrueckter Maustaste
					 * zulassen
					 */
					rs = 1;
					pret = sel;

					/* Bei Mausklick finito ... */
					if (mevent.ev_mwich & MU_BUTTON)
						done = 1;
				}
			} /* switch */
		}

		/* Tastendruck auswerten */
		if (mevent.ev_mwich & MU_KEYBD) {
			rs = 0;
			keyflag = 1;
			key = normkey(mevent.ev_mmokstate, mevent.ev_mkreturn);
			key &= ~(NKF_RESVD | NKF_CAPS | NKF_CTRL | NKF_ALT);
			if (key & NKF_LSH || key & NKF_RSH)
				key |= NKF_SHIFT;

			dir = 0;
			switch (key) {
			case NKF_FUNC | NK_LEFT:
				if (father) {
					pret = -2;
					done = 1;
				}
				break;

			case NKF_FUNC | NK_UP | NKF_SHIFT:
				dir = -1;
				if (sel == -1)
					sel = pop->num;
				sel -= LISTSIZE;
				if (sel < 0)
					sel = 0;
				break;

			case NKF_FUNC | NK_UP:
				dir = -1;
				if (sel == -1)
					sel = pop->num;
				if (--sel == -1)
					sel = pop->num - 1;
				break;

			case NKF_FUNC | NK_DOWN | NKF_SHIFT:
				dir = 1;
				if (sel == -1)
					sel = 0;
				sel += LISTSIZE;
				if (sel >= pop->num)
					sel = pop->num - 1;
				break;

			case NKF_FUNC | NK_DOWN:
				dir = 1;
				if (++sel == pop->num)
					sel = 0;
				break;

			case NKF_FUNC | NK_ESC:
			case NKF_FUNC | NK_UNDO:
			case NKF_FUNC | NK_ESC | NKF_SHIFT:
			case NKF_FUNC | NK_UNDO | NKF_SHIFT:
				pret = -1;
				done = 1;
				break;

			case NKF_FUNC | NK_CLRHOME:
				dir = 1;
				sel = 0;
				if (pop->num > vnum)
					offset = 0;
				break;

			case NKF_FUNC | NK_CLRHOME | NKF_SHIFT:
				dir = -1;
				sel = pop->num - 1;
				if (pop->num > vnum)
					offset = pop->num - vnum;
				break;

			case NKF_FUNC | NKF_NUM | NK_ENTER:
			case NKF_FUNC | NKF_NUM | NK_ENTER | NKF_SHIFT:
			case NKF_FUNC | NK_RET:
			case NKF_FUNC | NK_RET | NKF_SHIFT:
				pret = sel;
				done = 1;
			}
			if (dir && (sel != -1)) {
				i = sel;
				while (is_disabled(pop->list[sel])) {
					sel += dir;
					if (sel == pop->num)
						sel = 0;
					else if (sel == -1)
						sel = pop->num - 1;
					if (sel == i) {
						sel = -1;
						break;
					}
				}
			}
		}

		/*
		 * Ist der Mauszeiger aužerhalb des Popups, muessen auch
		 * Timer-Events ausgel”st werden, damit die Liste von
		 * selbst scrollt
		 */
		if (sel == -1)
			mevent.ev_mflags |= MU_TIMER;
		else
			mevent.ev_mflags &= ~MU_TIMER;

		/* Auswahl ge„ndert ? */
		if (sel != sel1) {
			offset = offset1;
			/* Alte Auswahl sichtbar ? */
			if (sel1 >= offset && sel1 < offset + vnum)
				objc_change(tree, 2 + sel1 - offset, 0, tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h, NORMAL, 1);

			/* Neue Auswahl sichtbar */
			if (sel != -1) {
				if (sel < offset)
					offset = sel;
				if (sel >= offset + vnum)
					offset = sel - vnum + 1;
				if (offset == offset1) {
					objc_change(tree, 2 + sel - offset, 0, tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h, SELECTED, 1);
				}
			}
			sel1 = sel;
		}
	}

	/* Bildschirmhintergrund wiederherstellen */
	if (*pok) {
		Screen2Buffer(tree->ob_x - 1, tree->ob_y - 1, tree->ob_width + 4, tree->ob_height + 4, FALSE);
	} else {
		form_dial(FMD_FINISH, tree->ob_x - 1, tree->ob_y - 1, tree->ob_width + 4, tree->ob_height + 4, tree->ob_x - 1, tree->ob_y - 1, tree->ob_width + 4, tree->ob_height + 4);
	}

	/* Auf Loslassen der Maustaste warten */
	if (!rt)
		evnt_button(1, 3, 0, &d, &d, &d, &d);

	/* Weitere Verarbeitung nur wenn Menueeintrag ausgew„hlt wurde */
	if (pret >= 0) {
		if (is_disabled(pop->list[pret]))
			pret = -1;
		else
			pop->sel = pret;
	}
	for (i = 0; i < vnum; i++) {
		tree[i + 2].ob_type = pop->copy[i].ob_type;
		tree[i + 2].ob_spec = pop->copy[i].ob_spec;
	}

	if (!tb.mbusy)
		graf_mouse(tb.mform, 0L);
	else
		graf_mouse(BUSYBEE, 0L);

	wind_update( END_MCTRL);

	return (pret);
}

/**-------------------------------------------------------------------------
 fw_...()

 Fenster-Funktion der Dialoge
 -------------------------------------------------------------------------*/
void fw_update(struct wininfo *win) {
	FORMINFO *fi;
	OBJECT *tree;

	fi = (FORMINFO *) win->user;
	tree = fi->tree;
	tree->ob_x = win->work.g_x;
	if (tree[1].ob_state & WHITEBAK)
		tree->ob_y = win->work.g_y - (tree[1].ob_y + tree[1].ob_height);
	else
		tree->ob_y = win->work.g_y;
}

/* #pragma-Direktive um Warnung "... never used ..." zu unterdruecken */
#pragma warn -par
void fw_prepare(struct wininfo *win) {
}
#pragma warn .par

void fw_redraw(struct wininfo *win, GRECT *area) {
	FORMINFO *fi;

	fi = (FORMINFO *) win->user;
	objc_draw(fi->tree, fi->drobj, MAX_DEPTH, area->g_x, area->g_y, area->g_w, area->g_h);
}

/**-------------------------------------------------------------------------
 frm_restore()

 Stellt einen non-modalen Dialog wieder her (un-iconify) und toppt ihn.
 -------------------------------------------------------------------------*/
void frm_restore(FORMINFO *fi) {
	if (fi->state != FST_WIN)
		return;

	if (fi->win.state & WSICON)
		win_unicon(&fi->win, fi->win.save.g_x, fi->win.save.g_y, fi->win.save.g_w, fi->win.save.g_h);
	win_top(&fi->win);
}

/**-------------------------------------------------------------------------
 frm_keybd()

 Erweiterte Version von form_keybd() mit Beruecksichtigung von
 Tastaturshortcuts, [Insert] und [Ctrl]-C/X/V
 -------------------------------------------------------------------------*/
short frm_keybd(FORMINFO *fi, short nobj, short *nextobj, short *nextchar, short kr,
		short ks) {
	short sobj;

	/* Erstmal auf Shortcut pruefen */
	sobj = shortcut(fi->tree, ks, kr, fi->undo_obj, fi->help_obj);
	if (sobj != -1) {
		/*
		 * An frm_do() melden, dass keine Eingabe in das aktuelle
		 * Editfeld erfolgen soll.
		 */
		*nextchar = 0;

		/* Objekt bearbeiten */
		*nextobj = sobj;
		return (form_button(fi->tree, sobj, 1, nextobj));
	} else {
		/* Kein Shortcut - dann normal weiter */
		if ((ks & 3) && ((kr & 0xff) == 0x9)) {
			ks = 0;
			kr = 72 << 8;
		}
		return (form_keybd(fi->tree, fi->edit_obj, nobj, kr, nextobj, nextchar));
	}
}

/**-------------------------------------------------------------------------
 frm_edstring()

 Text in ein Editfeld uebertragen, unter Beruecksichtigung des
 Cursors.
 -------------------------------------------------------------------------*/
void frm_edstring(FORMINFO *fi, short obj, char *str) {
	if (fi->edit_obj == obj && fi->edit_idx != -1)
		obj_edit(fi->tree, fi->edit_obj, 0, 0, &fi->edit_idx, ED_END,
				fi->win.handle);
	strcpy(fi->tree[obj].ob_spec.tedinfo->te_ptext, str);

	if (fi->edit_obj == obj && fi->edit_idx != -1) {
		fi->edit_idx = -1;
		obj_edit(fi->tree, fi->edit_obj, 0, 0, &fi->edit_idx, ED_INIT, fi->win.handle);
	}
}

/**
 * frm_gotoedit
 *
 * Setzt den Cursor in ein bestimmtes Editfeld bzw. l”scht ihn. Dabei
 * darf der gewuenschte Zustand auch schon aktiv sein, d.h. man kann
 * gefahrlos den Cursor auf Objekt x setzen, wenn er dort schon ist,
 * ohne daž es Zeichenprobleme gibt.
 *
 * Eingabe:
 * fi: Zeiger auf FORMINFO-Struktur des Dialogs
 * obj: Objektnummer des Editfelds, in das der Cursor gesetzt werden
 *      soll. 0 = Cursor l”schen
 */
void frm_gotoedit(FORMINFO *fi, short obj) {
	if (obj) {
		if (obj != fi->edit_obj) {
			if (fi->edit_obj) {
				obj_edit(fi->tree, fi->edit_obj, 0, 0, &fi->edit_idx, ED_END, fi->win.handle);
			}
			fi->edit_obj = obj;
			fi->edit_idx = -1;
			obj_edit(fi->tree, fi->edit_obj, 0, 0, &fi->edit_idx, ED_INIT, fi->win.handle);
		}
	} else if (fi->edit_obj) {
		obj_edit(fi->tree, fi->edit_obj, 0, 0, &fi->edit_idx, ED_END, fi->win.handle);
		fi->edit_obj = 0;
		fi->edit_idx = 1;
	}
}

/**-------------------------------------------------------------------------
 frm_norm()

 Stellt das Exit-Objekt eines Dialoges wieder normal dar.
 Sehr nuetzlich, wenn z.B. ein EXIT-Button selektiert wurde, aber der
 Dialog deshalb noch nicht beendet ist.
 -------------------------------------------------------------------------*/
void frm_norm(FORMINFO *fi) {
	if (fi->exit_obj == ROOT)
		return;

	/* Objekt deselektieren */
	fi->tree[fi->exit_obj].ob_state &= ~SELECTED;

	/* Und neuzeichnen */
	frm_redraw(fi, fi->exit_obj);
}

/**-------------------------------------------------------------------------
 frm_start()

 Vorbereitung eines Dialogs. Hat die Variable 'wd' den Wert 1, wird der
 Dialog als modaler Fensterdialog ausgefuehrt, sonst analog zu den
 MyDial-Dialogen. Wird 'cd' auf 1 gesetzt, wird der Dialog zentriert,
 sonst nicht.

 Kann der Dialog nicht in ein Fenster gelegt werden, wird versucht ihn
 als "FlyDial" zu starten - klappt das auch nicht (kommt das denn jemals
 vor ???) dann wird er als normaler GEM-Dialog gestartet (das geht dann
 auf jeden Fall). Die Variable 'state' der FORMINFO-Struktur wird
 entsprechend gesetzt.
 -------------------------------------------------------------------------*/
void frm_start(FORMINFO *fi, short wd, short cd, short mode) {
	short ok, pn, x, y, w, h, domode;
	FORMINFO *list;
	EVENT event;

	/* Popup-Menueeintr„ge in den Dialog uebernehmen */
	if (fi->popup) {
		pn = 0;
		while (fi->popup[pn]) {
			if (fi->popup[pn]->take == 1)
				pop_set(fi, fi->popup[pn]);
			pn++;
		}
	}

	/* Poplist-Eintr„ge in den Dialog uebernehmen */
	if (fi->poplist) {
		pn = 0;
		while (fi->poplist[pn]) {
			poplist_set(fi, fi->poplist[pn]);
			pn++;
		}
	}

	fi->open = 1;

	/* Bisherigen Dialog merken und diesen als aktiv setzen */
	if (mode || fi->state != FST_WIN)
		fi->oldtop = tb.topfi;
	else
		fi->oldtop = 0L;
	tb.topfi = fi;

	/* Dialog an die Liste anh„ngen */
	fi->next = 0L;
	list = tb.fi;
	if (!list) {
		/* Liste bisher leer */
		tb.fi = fi;
		fi->prev = 0L;
	} else {
		while (list->next)
			list = list->next;
		list->next = fi;
		fi->prev = list;
	}

	/* Dialog vorbereiten */
	domode = 0;
	if (mode || tb.sm_modal) /* Modal? */
	{
		tb.sm_modal++;
		if (tb.sm_modal == 1 && tb.modal_on != 0L)
			domode = 1;
	}
	if (wd == 1) {
		ok = 1;
		fi->drobj = ROOT; /* Bei Redraw gesamten Objektbaum zeichnen */
		/* Dialog im Fenster ausfuehren */
		fi->win.flags = NAME | MOVER;
		if (!mode && !tb.sm_modal) {
			/* Non-modal? */
			fi->win.flags |= CLOSER;
			if (tb.sys & SY_ICONIFY)
				fi->win.flags |= SMALLER;
		}

		if (tb.sys & SY_MAGX)
			fi->win.flags |= BACKDROP;

		strcpy(fi->win.name, " ");
		if (fi->tree[1].ob_state & WHITEBAK)
			strcat(fi->win.name, getObjectText(fi->tree, 1));
		else
			strcat(fi->win.name, fi->title);
		strcat(fi->win.name, " ");
		fi->win.state = WSWORKSIZE;
		fi->win.class=WCDIAL;
		fi->win.user = fi;
		fi->win.update = fw_update;
		fi->win.prepare = fw_prepare;
		fi->win.redraw = fw_redraw;
		fi->win.slide = 0L;
		fi->win.ictree = tb.ictreed;
		/* Objektbaum fuer's Fenster umbauen und als Fenstergr”že uebernehmen */
		tree_win(fi->tree, 1);
		if (cd) {
			/* Zentrieren, falls gewuenscht */
			form_center(fi->tree, &fi->win.work.g_x, &fi->win.work.g_y, &fi->win.work.g_w, &fi->win.work.g_h);
		} else {
			/* sonst aktuelle Werte beibehalten */
			fi->win.work.g_x = fi->tree->ob_x;
			fi->win.work.g_y = fi->tree->ob_y;
			fi->win.work.g_w = fi->tree->ob_width;
			fi->win.work.g_h = fi->tree->ob_height;
		}
		if (fi->tree[1].ob_state & WHITEBAK) {
			fi->win.work.g_h -= (fi->tree[1].ob_y + fi->tree[1].ob_height);
			fi->win.work.g_y += (fi->tree[1].ob_y + fi->tree[1].ob_height / 2);
		}
		/* Koordinaten sichern */
		fi->ty = fi->tree->ob_y;
		fi->wy = fi->win.work.g_y;
		/* Fenster ”ffnen */
		if (win_open(&fi->win, 0)) {
			win_open(&fi->win, 1);
			fi->state = FST_WIN;
		} else {
			ok = 0;
			tree_win(fi->tree, 0);
		}
	}

	/* Jetzt erst 'Modal' aufrufen, weil erst hier sichergestellt ist,
	 dass die Menuezeile auch sichtbar ist */
	if (domode)
		tb.modal_on();

	/* Dialog normal ausfuehren - entweder weil kein Fenster mehr frei war,
	 oder weil dies so gewuenscht wurde oder weil bereits ein non-modaler
	 Dialog auf ist */
	setBackgroundBorderLine(fi->tree, 0, 0);
	if (!wd || !ok || tb.sm_nowdial) {
		setBackgroundBorderLine(fi->tree, 0, 1);
		fi->win.handle = -1;
		fi->state = FST_NORM;

		/* Semaphore fuer Alertboxen erh”hen */
		tb.sm_nowdial++;

		wind_update( BEG_UPDATE);
		wind_update( BEG_MCTRL);
		form_center(fi->tree, &x, &y, &w, &h);
		if (cd) {
			/* Zentrieren, wenn gewuenscht */
			fi->tree->ob_x = x + (w - fi->tree->ob_width) / 2;
			fi->tree->ob_y = y + (h - fi->tree->ob_height) / 2;
		} else {
			/* Sonst aktuelle Werte fuer finish ermitteln */
			x = fi->tree->ob_x - (w - fi->tree->ob_width) / 2;
			y = fi->tree->ob_y - (h - fi->tree->ob_height) / 2;
		}
		form_dial(FMD_START, 0, 0, 0, 0, x, y, w, h);
		fi->cx = x;
		fi->cy = y;
		fi->cw = w;
		fi->ch = h;
		graf_mouse(M_OFF, 0L);
		objc_draw(fi->tree, ROOT, MAX_DEPTH, x, y, w, h);
		graf_mouse(M_ON, 0L);
	}

	/* Eingabefeld etc. auf Initialisierung setzen */
	fi->edit_obj = 0;
	fi->edit_idx = -1;
	fi->cont = 1;

	/* Mauszeiger setzen */
	if (tb.mform != ARROW) {
		tb.mform = ARROW;
		if (!tb.mbusy)
			graf_mouse(tb.mform, 0L);
	}

	/* Semaphore fuer Dialog allgemein erh”hen */
	tb.sm_dial++;

	/* Aktualisierung des Mauszeigers */
	event.ev_mwich = MU_M1;
	graf_mkstate(&event.ev_mmox, &event.ev_mmoy, &event.ev_mbreturn, &event.ev_mmokstate);
	frm_do(fi, &event);
}

/*-------------------------------------------------------------------------
 frm_end()

 Beendet einen Dialog, der mit frm_start() gestartet wurde.
 -------------------------------------------------------------------------*/
void frm_end(FORMINFO *fi) {
	FORMINFO *prev, *next;
	short handle, d;

	/* Mauszeiger wieder als Pfeil */
	tb.mform = ARROW;
	if (!tb.mbusy)
		graf_mouse(tb.mform, 0L);
	else
		graf_mouse(BUSYBEE, 0L);

	/* Falls es der aktive Dialog war, dann ggf. bisherigen
	 wiederherstellen */
	if (fi == tb.topfi)
		tb.topfi = fi->oldtop;
	fi->oldtop = 0L;

	/* Cursor ausschalten */
	if (fi->edit_idx != -1) {
		obj_edit(fi->tree, fi->edit_obj, 0, 0, &fi->edit_idx, ED_END,
				fi->win.handle);
	}
	/* Exit-Objekt deselektieren */
	fi->tree[fi->exit_obj].ob_state &= ~SELECTED;
	/* Dialog beenden ... */
	fi->open = 0;
	if (fi->state != FST_WIN) /* Normal */
	{
		/* Semaphore fuer Alertboxen heruntersetzen */
		if (tb.sm_nowdial > 0)
			tb.sm_nowdial--;

		form_dial(FMD_FINISH, 0, 0, 0, 0, fi->cx, fi->cy, fi->cw, fi->ch);

		/* Falls der bisherige Dialog nicht im Fenster lag, dann jetzt
		 neuzeichnen */
		if (tb.topfi) {
			if (tb.topfi->state != FST_WIN)
				frm_redraw(tb.topfi, ROOT);
		}
		wind_update( END_UPDATE);
		wind_update( END_MCTRL);
	} else /* Im Fenster */
	{
		win_close(&fi->win);
		tree_win(fi->tree, 0);
		/* Koordinaten wiederherstellen */
		fi->tree->ob_y = fi->ty + fi->win.work.g_y - fi->wy;
	}

	/* Semaphore fuer Dialoge allgemein heruntersetzen */
	if (tb.sm_dial > 0)
		tb.sm_dial--;
	if (tb.sm_modal > 0) {
		tb.sm_modal--;
		if (tb.sm_modal == 0 && tb.modal_off != 0L)
			tb.modal_off();
	}

	/* Dialog aus der Liste ausklinken */
	prev = fi->prev;
	next = fi->next;
	if (!prev) {
		/* Kein Vorg„nger - dann erster Eintrag ! */
		tb.fi = next;
		if (next)
			next->prev = 0L;
	} else {
		/* Vorg„nger vorhanden */
		prev->next = next;
		if (next)
			next->prev = prev;
	}

	/* Beruecksichtigen, dass evtl. kein Dialog mehr auf ist */
	if (!tb.fi)
		tb.topfi = 0L;

	/* Aktives Fenster ermitteln */
	wind_get(0, WF_TOP, &handle, &d, &d, &d);
	tb.topwin = win_getwinfo(handle);
	win_newtop(tb.topwin);
}

/*-------------------------------------------------------------------------
 frm_redraw()

 Zeichnet den Dialog komplett oder teilweise neu unter Beruecksichtigung
 eines eventuell aktiven Eingabefeldes
 -------------------------------------------------------------------------*/
void frm_redraw(FORMINFO *fi, short obj) {
	short x, y, w, h;

	if (fi->state == FST_WIN) {
		objc_offset(fi->tree, obj, &x, &y);
		w = fi->tree[obj].ob_width;
		h = fi->tree[obj].ob_height;
		fi->drobj = obj;
		win_redraw(&fi->win, x, y, w, h);
		fi->drobj = ROOT;
	} else {
		if (fi->edit_obj && fi->edit_idx != -1)
			obj_edit(fi->tree, fi->edit_obj, 0, 0, &fi->edit_idx, ED_END, fi->win.handle);

		objc_draw(fi->tree, obj, MAX_DEPTH, tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h);

		if (fi->edit_obj && fi->edit_idx != -1)
			obj_edit(fi->tree, fi->edit_obj, 0, 0, &fi->edit_idx, ED_INIT, fi->win.handle);
	}
}

/*-------------------------------------------------------------------------
 frm_event()

 Behandlung einer AES-Message (MU_MESAG) innerhalb eines modalen
 Fensterdialogs
 -------------------------------------------------------------------------*/
void frm_event(FORMINFO *fi, EVENT *mevent) {
	WININFO *win;
	short msg;

	msg = mevent->ev_mmgpbuf[0];

	switch (msg) {
	case WM_ICONIFY:
	case WM_UNICONIFY:
	case WM_ALLICONIFY:
	case WM_CLOSED:
		mybeep();
		break;
	case WM_REDRAW:
	case WM_TOPPED:
	case WM_M_BDROPPED:
	case WM_BOTTOMED:
	case WM_UNTOPPED:
	case WM_NEWTOP:
	case WM_ONTOP:
	case WM_FULLED:
	case WM_ARROWED:
	case WM_HSLID:
	case WM_VSLID:
	case WM_SIZED:
	case WM_MOVED:
		/* Fenster ermitteln, das betroffen ist */
		win = win_getwinfo(mevent->ev_mmgpbuf[3]);
		/* Nur fuer Dialogfenster selber bearbeiten,
		 alle anderen werden an den Handler der Appl. weitergereicht */
		if (win) {
			if (win->class == WCDIAL || msg == WM_TOPPED || msg == WM_NEWTOP || msg == WM_ONTOP ||
					msg == WM_UNTOPPED || msg == WM_M_BDROPPED || msg == WM_BOTTOMED) {
				switch (msg) {
				case WM_REDRAW:
					if (tb.sm_nowdial)
						break;
					win_redraw(win, mevent->ev_mmgpbuf[4], mevent->ev_mmgpbuf[5], mevent->ev_mmgpbuf[6], mevent->ev_mmgpbuf[7]);
					break;
				case WM_TOPPED:
					win_top(&fi->win);
					break;
				case WM_M_BDROPPED: /* MagiC 2.0 */
				case WM_BOTTOMED: /* WINX */
					mybeep();
					/* wind_set(fi->win.handle,WF_BOTTOM,0,0,0,0); */
					break;
				case WM_UNTOPPED:
					if (win == &fi->win)
						tb.topwin = 0L;
					break;
				case WM_NEWTOP:
				case WM_ONTOP:
					if (win != &fi->win)
						win_top(&fi->win);
					else
						win_newtop(&fi->win);
					break;
				case WM_SIZED:
				case WM_MOVED:
					win_size(win, mevent->ev_mmgpbuf[4], mevent->ev_mmgpbuf[5], mevent->ev_mmgpbuf[6], mevent->ev_mmgpbuf[7]);
					break;
				}
			} else {
				if (tb.msg_handler)
					tb.msg_handler(mevent, fi);
			}
		} else if (tb.msg_handler)
			tb.msg_handler(mevent, fi);
		break;
	default: /* Andere Messages */
		if (tb.msg_handler)
			tb.msg_handler(mevent, fi);
		break;
	}
}

/*-------------------------------------------------------------------------
 frm_insert()

 Einfuegen eines Sonderzeichens aus einem Popup-Menue an die
 aktuelle Cursorposition im Editfeld
 -------------------------------------------------------------------------*/
void frm_insert(FORMINFO *fi) {
	/*	short fx, fy, fw, fh;*/
	short pxy[4];
	short sx, sy, sx1, sy1, skey;
	/*	short mxy[8];
	 long msize;
	 MFDB mfdb;*/
	short done, mx, my;
	EVENT mevent;
	char ch;
	OBJECT *tree;

	tree = rs_trindex[1];
	graf_mouse(ARROW, 0L);

	sx = sy = -1; /* Aktuelle Auswahl: keine */

	/* Position der Zeichentabelle berechnen */
	objc_offset(fi->tree, fi->edit_obj, &tree->ob_x, &tree->ob_y);
	tree->ob_x += (fi->tree[fi->edit_obj].ob_width / 2 - tree->ob_width / 2);
	tree->ob_y += fi->tree[fi->edit_obj].ob_height;

	if (tree->ob_x + tree->ob_width + 3 > tb.desk.g_x + tb.desk.g_w)
		tree->ob_x = tb.desk.g_x + tb.desk.g_w - tree->ob_width - 3;
	if (tree->ob_x <= tb.desk.g_x)
		tree->ob_x = tb.desk.g_x + 1;
	if (tree->ob_y + tree->ob_height + 3 > tb.desk.g_y + tb.desk.g_h)
		tree->ob_y = tb.desk.g_y + tb.desk.g_h - tree->ob_height - 3;
	if (tree->ob_y <= tb.desk.g_y)
		tree->ob_y = tb.desk.g_y + 1;

	/* Bildschirmhintergrund sichern */
	if (!Screen2Buffer(tree->ob_x - 1, tree->ob_y - 1, tree->ob_width + 4, tree->ob_height + 4, TRUE)) {
		mybeep();
	}
#if 0
	/* Bildschirmhintergrund sichern */
	fx=rs_trindex[1]->ob_x-1;
	fy=rs_trindex[1]->ob_y-1;
	fw=rs_trindex[1]->ob_width+4;
	fh=rs_trindex[1]->ob_height+4;
	mfdb.fd_w=fw;
	mfdb.fd_h=fh;
	mfdb.fd_wdwidth=fw>>4;if((fw&0xf)!=0) mfdb.fd_wdwidth++;
	mfdb.fd_stand=1;
	mfdb.fd_nplanes=tb.planes;
	mfdb.fd_r1=0;
	mfdb.fd_r2=0;
	mfdb.fd_r3=0;
	msize=(long)mfdb.fd_wdwidth*2L*(long)mfdb.fd_h*(long)mfdb.fd_nplanes;
	mfdb.fd_addr=Malloc(msize);
	/* Kein Bufferspeicher mehr? - dann Auswahl nicht m”glich! */
	if(!mfdb.fd_addr)
	{
		mybeep();
	}
#endif
	else {
#if 0
		mxy[0]=fx;mxy[1]=fy;
		mxy[2]=fx+fw-1;mxy[3]=fy+fh-1;
		mxy[4]=0;mxy[5]=0;
		mxy[6]=fw-1;mxy[7]=fh-1;
		graf_mouse(M_OFF,0L);
		vro_cpyfm(v_handle,S_ONLY,mxy,&scr_mfdb,&mfdb);
		graf_mouse(M_ON,0L);
#endif

		objc_draw(tree, ROOT, MAX_DEPTH, tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h);

		/* Auswahl des Sonderzeichens */
		vsf_perimeter(v_handle, 0);
		vsf_interior(v_handle, FIS_SOLID);
		vswr_mode(v_handle, MD_XOR);
		done = 0;
		mevent.ev_mflags = MU_KEYBD | MU_BUTTON | MU_M1 | MU_M2;
		mevent.ev_mbclicks = 257;
		mevent.ev_bmask = 3;
		mevent.ev_mbstate = 0;
		mevent.ev_mm1flags = 1;
		mevent.ev_mm2flags = 0;
		mevent.ev_mm1x = mevent.ev_mm2x = tb.desk.g_x;
		mevent.ev_mm1y = mevent.ev_mm2y = tb.desk.g_y;
		mevent.ev_mm1width = mevent.ev_mm2width = tb.desk.g_w;
		mevent.ev_mm1height = mevent.ev_mm2height = tb.desk.g_h;
		mx = my = -1;

		while (!done) {
			EvntMulti(&mevent);
			sx1 = sx;
			sy1 = sy;
			if (mevent.ev_mwich & MU_KEYBD) {
				skey = normkey(mevent.ev_mmokstate, mevent.ev_mkreturn)
						& ~(NKF_RESVD | NKF_NUM | NKF_CAPS | NKF_ALT | NKF_CTRL | NKF_SHIFT);

				switch (skey) {
				case NKF_FUNC | NK_UP:
					if (sy == -1)
						sy = 9;
					else {
						sy--;
						if (sy < 0)
							sy = 9;
					}
					if (sx == -1)
						sx = 0;
					break;

				case NKF_FUNC | NK_DOWN:
					if (sy == -1)
						sy = 0;
					else {
						sy++;
						if (sy > 9)
							sy = 0;
					}
					if (sx == -1)
						sx = 0;
					break;

				case NKF_FUNC | NK_LEFT:
					if (sx == -1)
						sx = 15;
					else {
						sx--;
						if (sx < 0)
							sx = 15;
					}
					if (sy == -1)
						sy = 0;
					break;

				case NKF_FUNC | NK_RIGHT:
					if (sx == -1)
						sx = 0;
					else {
						sx++;
						if (sx > 15)
							sx = 0;
					}
					if (sy == -1)
						sy = 0;
					break;

				case NKF_FUNC | NK_UNDO:
				case NKF_FUNC | NK_ESC:
					sx = -1;
					sy = -1;
					done = 1;
					break;

				case NKF_FUNC | NK_RET:
				case NKF_FUNC | NK_ENTER:
					done = 1;
					break;
				} /* switch */
			}

			if (mevent.ev_mwich & MU_M1 || mevent.ev_mwich & MU_M2) {
				if (mx != mevent.ev_mmox || my != mevent.ev_mmoy) {
					mx = mevent.ev_mmox;
					my = mevent.ev_mmoy;
					if (objc_find(tree, ROOT, MAX_DEPTH, mevent.ev_mmox, mevent.ev_mmoy) != -1) {
						sx = (mevent.ev_mmox - tree->ob_x) / (tb.ch_w * 2);
						sy = (mevent.ev_mmoy - tree->ob_y) / tb.ch_h;
					} else {
						sx = sy = -1;
					}
				}
			}
			if (mevent.ev_mwich & MU_BUTTON) {
				if (objc_find(tree, ROOT, MAX_DEPTH, mevent.ev_mmox, mevent.ev_mmoy) != -1) {
					sx = (mevent.ev_mmox - tree->ob_x) / (tb.ch_w * 2);
					sy = (mevent.ev_mmoy - tree->ob_y) / tb.ch_h;
				} else {
					sx = sy = -1;
				}
				done = 1;
			}

			/* Aktuelle Zeichenauswahl selektieren */
			if (sx1 != sx || sy1 != sy) {
				/* Bisherige Auswahl l”schen */
				if (sx1 != -1 && sy1 != -1) {
					pxy[0] = tree->ob_x + sx1 * tb.ch_w * 2;
					pxy[1] = tree->ob_y + sy1 * tb.ch_h;
					pxy[2] = pxy[0] + tb.ch_w * 2 - 1;
					pxy[3] = pxy[1] + tb.ch_h - 1;
					graf_mouse(M_OFF, 0L);
					v_bar(v_handle, pxy);
					graf_mouse(M_ON, 0L);
				}

				/* Neue Auswahl zeichnen */
				if (sx != -1 && sy != -1) {
					pxy[0] = tree->ob_x + sx * tb.ch_w * 2;
					pxy[1] = tree->ob_y + sy * tb.ch_h;
					pxy[2] = pxy[0] + tb.ch_w * 2 - 1;
					pxy[3] = pxy[1] + tb.ch_h - 1;
					graf_mouse(M_OFF, 0L);
					v_bar(v_handle, pxy);
					graf_mouse(M_ON, 0L);
				}
			}
		}
		vswr_mode(v_handle, MD_REPLACE);

		/* Ausgew„hltes Zeichen holen */
		if (sx != -1 && sy != -1)
			ch = tree[sy + 1].ob_spec.tedinfo->te_ptext[sx * 2];
		else
			ch = 0;

		/* Auf Loslassen der Maustaste warten */
		mevent.ev_mbreturn = 1;
		while (mevent.ev_mbreturn & 1)
			graf_mkstate(&mevent.ev_mmox, &mevent.ev_mmoy, &mevent.ev_mbreturn, &mevent.ev_mmokstate);

		/* Bildschirmhintergrund wiederherstellen */
		Screen2Buffer(tree->ob_x - 1, tree->ob_y - 1, tree->ob_width + 4, tree->ob_height + 4, FALSE);
#if 0
		mxy[0]=0;mxy[1]=0;
		mxy[2]=fw-1;mxy[3]=fh-1;
		mxy[4]=fx;mxy[5]=fy;
		mxy[6]=fx+fw-1;mxy[7]=fy+fh-1;
		graf_mouse(M_OFF,0L);
		vro_cpyfm(v_handle,S_ONLY,mxy,&mfdb,&scr_mfdb);
		graf_mouse(M_ON,0L);
		Mfree(mfdb.fd_addr);
#endif
		/* Zeichen in das Editfeld einfuegen */
		if (ch)
			obj_edit(fi->tree, fi->edit_obj, ch, 0x7fff, &fi->edit_idx, ED_CHAR, fi->win.handle);
	}

	if (!tb.mbusy)
		graf_mouse(tb.mform, 0L);
	else
		graf_mouse(BUSYBEE, 0L);
}

/*-------------------------------------------------------------------------
 frm_ecopy()
 frm_epaste()
 frm_ecut()

 Aktuelles Eingabefeld in's GEM-Clipboard uebertragen bzw. von dort
 einlesen
 -------------------------------------------------------------------------*/
short frm_ecopy(FORMINFO *fi) {
	char spath[256], sname[256];
	short l;
	long fh, ret;
	char *buf;

	/* Clipboard-Inhalt l”schen */
	scrap_clear();

	/* Clipboard-Pfad ermitteln */
	if (!scrp_read(spath)) {
		mybeep();
		return (0);
	}
	l = (short) strlen(spath);
	if (spath[l - 1] != '\\') {
		strcat(spath, "\\");
		l++;
	}

	/* Inhalt des aktuellen Editfelds als Textdatei schreiben */
	buf = fi->tree[fi->edit_obj].ob_spec.tedinfo->te_ptext;
	l = (short) strlen(buf);
	strcpy(sname, spath);
	strcat(sname, "SCRAP.TXT");
	fh = Fcreate(sname, 0);
	if (fh < 0L) {
		mybeep();
		return (0);
	}
	ret = Fwrite((short) fh, (long) l, buf);
	Fclose((short) fh);
	if (ret != (long) l) {
		mybeep();
		return (0);
	}

	return (1);
}

void frm_epaste(FORMINFO *fi) {
	char spath[256], sname[256];
	short l;
	long fh, ret;
	char *buf;

	/* Clipboard-Pfad ermitteln */
	if (!scrp_read(spath)) {
		mybeep();
		return;
	}
	l = (short) strlen(spath);
	if (spath[l - 1] != '\\') {
		strcat(spath, "\\");
		l++;
	}

	/* Text aus dem Clipboard einfuegen */
	buf = fi->tree[fi->edit_obj].ob_spec.tedinfo->te_ptext;
	strcpy(sname, spath);
	strcat(sname, "SCRAP.TXT");
	fh = Fopen(sname, 0 /* FO_READ */ );
	if (fh < 0L)
		return;

	l = fi->tree[fi->edit_obj].ob_spec.tedinfo->te_txtlen - 1;
	obj_edit(fi->tree, fi->edit_obj, 0, 0, &fi->edit_idx, ED_END, fi->win.handle);
	ret = Fread((short) fh, (long) l, buf);
	Fclose((short) fh);
	if (ret >= 0L)
		buf[(short) ret] = 0;
	else {
		buf[0] = 0;
		mybeep();
	}
	fi->edit_idx = -1;
	frm_redraw(fi, fi->edit_obj);
	obj_edit(fi->tree, fi->edit_obj, 0, 0, &fi->edit_idx, ED_INIT, fi->win.handle);
}

void frm_ecut(FORMINFO *fi) {
	if (frm_ecopy(fi)) {
		obj_edit(fi->tree, fi->edit_obj, 0, 0, &fi->edit_idx, ED_END, fi->win.handle);
		fi->tree[fi->edit_obj].ob_spec.tedinfo->te_ptext[0] = 0;
		fi->edit_idx = -1;
		frm_redraw(fi, fi->edit_obj);
		obj_edit(fi->tree, fi->edit_obj, 0, 0, &fi->edit_idx, ED_INIT, fi->win.handle);
	}
}

static void bubble_message(short id, short obj, short mx, short my) {
	short bubble_gem, on_demand = 0;
	static char *global_txt = NULL;
	long id_and_obj;
	BHELP *search;

	/* BUG: global_txt wird nie freigegeben */

	if ((id < 0) || ((bubble_gem = appl_find("BUBBLE  ")) < 0))
		return;
	if (global_txt == NULL) {
		if (tb.sys & SY_XALLOC)
			global_txt = Mxalloc(256, 0x23); /* readable */
		else
			global_txt = malloc(256);
		if (global_txt == NULL)
			return;
	}
	if (!tb.hlp) {
		read_hlp(".hlp");
		on_demand = 1;
	}
	id_and_obj = ((long) id << 16L) | ((long) obj & 0xFFFFL);
	for (search = tb.hlp; search != NULL;) {
		if (id_and_obj == search->id_and_obj)
			break;
		else if (id_and_obj < search->id_and_obj)
			search = search->lt;
		else
			search = search->ge;
	}
	if (search != NULL) {
		global_txt[255] = 0;
		strncpy(global_txt, search->txt, 255);
		appl_send(bubble_gem, 0xBABB, PT56, mx, my, (long) global_txt, 0L, 0L);
		evnt_timer(100L);
	}
	if (on_demand) {
		free_hlp(tb.hlp);
		tb.hlp = NULL;
	}
}

/*-------------------------------------------------------------------------
 frm_do()

 Bearbeiten eines Dialogevents
 -------------------------------------------------------------------------*/
short frm_do(FORMINFO *fi, EVENT *mevent) {
	short edit_obj, next_obj, nobj, doini;
	short pdo, eobj, new_idx;
	char ebuf1[256], ebuf2[256];
	short x, y, tlen;
	short mobj, mform;
	short kr, mx, my, mb, ks;

	fi->cont = 1;

	/* Erstes Eingabefeld suchen */
	next_obj = ini_field(fi->tree, fi->start_obj);
	edit_obj = fi->edit_obj;
	fi->edit_obj = 0;
	if (fi->edit_idx == -1)
		doini = 1;
	else
		doini = 0;

	eobj = 0;

	/* Cursor auf aktuelles Eingabefeld, wenn vorhanden */
	if (next_obj && fi->edit_obj != next_obj) {
		/* Nur initialisieren, wenn der Cursor noch nicht pos. wurde */
		if (doini) {
			fi->edit_obj = next_obj;
			obj_edit(fi->tree, fi->edit_obj, 0, 0, &fi->edit_idx, ED_INIT, fi->win.handle);
		} else {
			doini = 1;
			fi->edit_obj = edit_obj;
			new_idx = -1;
		}
		next_obj = 0;
	}

	/* Mauszeiger ueber Editfeldern als Cursor */
	if (mevent->ev_mwich & MU_M1) {
		mform = ARROW;

		/* Nur, wenn Dialog aktiv */
		if (fi->state != FST_WIN || (fi->state == FST_WIN && tb.topwin == &fi->win && !(fi->win.state & WSICON))) {
			mobj = objc_find(fi->tree, ROOT, MAX_DEPTH, mevent->ev_mmox, mevent->ev_mmoy);
			if (mobj != -1)
				if (fi->tree[mobj].ob_flags & EDITABLE)
					mform = TEXT_CRSR;
		}

		if (tb.mform != mform) {
			tb.mform = mform;
			if (!tb.mbusy)
				graf_mouse(tb.mform, 0L);
			else
				graf_mouse(BUSYBEE, 0L);
		}
	}

	/*
	 * Alle weiteren Aktionen nur bearbeiten, wenn der Dialog
	 * entweder kein Fensterdialog ist, oder das Fenster aktiv ist.
	 */
	if (fi->state != FST_WIN || (fi->state == FST_WIN && tb.topwin == &fi->win && !(fi->win.state & WSICON))) {
		/*
		 * Aktuelles Eingabefeld fixieren, um Žnderungen feststelllen zu
		 * k”nnen.
		 */
		if (fi->edit_obj) {
			eobj = fi->edit_obj;
			strcpy(ebuf1, fi->tree[eobj].ob_spec.tedinfo->te_ptext);
		}

		/*
		 * Taste gedrueckt -> Aktuelles Eingabefeld bearbeiten oder
		 * DEFAULT.
		 */
		if (mevent->ev_mwich & MU_KEYBD) {
			if (fi->state == FST_WIN) {
				wind_update( BEG_UPDATE);
				wind_update( BEG_MCTRL);
			}

			fi->normkey = normkey(mevent->ev_mmokstate, mevent->ev_mkreturn);
			if (fi->normkey & NKF_SHIFT)
				fi->normkey |= NKF_SHIFT;
			fi->normkey &= ~(NKF_CAPS | NKF_RESVD);

			switch (fi->normkey & ~NKF_CTRL) {
			case NKF_FUNC | NK_DOWN:
			case NKF_FUNC | NK_UP:
			case NKF_FUNC | NKF_SHIFT | NK_DOWN:
			case NKF_FUNC | NKF_SHIFT | NK_UP:
			case NKF_FUNC | NK_CLRHOME:
			case NKF_FUNC | NKF_SHIFT | NK_CLRHOME:
				if (fi->keyflag == 1 || fi->normkey & NKF_CTRL) {
					fi->exit_obj = -1;
					fi->cont = 0;
					if (fi->state == FST_WIN) {
						wind_update( END_MCTRL);
						wind_update( END_UPDATE);
					}
					return (0x0000);
				}
				break;
			} /* switch */

			/* Auf Popups pruefen */
			if (fi->popup) {
				pdo = pop_do(0, fi, -1, mevent->ev_mmokstate,
						mevent->ev_mkreturn, &fi->edit_obj, &fi->edit_idx,
						fi->win.handle, &next_obj);
			} else
				pdo = 0;

			if (!pdo) {
				if (fi->poplist)
					pdo = poplist_do(0, fi, -1, mevent->ev_mmokstate,
							mevent->ev_mkreturn, &fi->edit_obj, &fi->edit_idx,
							fi->win.handle, &next_obj);
				else
					pdo = 0;
			}

			switch (pdo) {
			case 2:
				fi->cont = 0;
				break;

			case 1:
				mevent->ev_mwich &= ~MU_KEYBD;
				break;

			case 0:
				/* Hier ggf. Sondertasten abfangen */
				switch (fi->normkey) {
				/*					case NKF_FUNC|NK_HELP:
				 if(tb.msg_handler) tb.msg_handler(mevent,fi);
				 break; */

				case NKF_FUNC | NKF_CTRL | 'c':
				case NKF_FUNC | NKF_CTRL | 'C':
					if (fi->edit_obj)
						frm_ecopy(fi);
					break;

				case NKF_FUNC | NKF_CTRL | 'v':
				case NKF_FUNC | NKF_CTRL | 'V':
					if (fi->edit_obj)
						frm_epaste(fi);
					break;

				case NKF_FUNC | NKF_CTRL | 'x':
				case NKF_FUNC | NKF_CTRL | 'X':
					if (fi->edit_obj)
						frm_ecut(fi);
					break;

				case NKF_FUNC | NK_INS:
				case NKF_FUNC | NKF_SHIFT | NK_INS:
					if (fi->edit_obj)
						frm_insert(fi);
					break;

				default:
					fi->cont = frm_keybd(fi, next_obj, &next_obj, &kr, mevent->ev_mkreturn, mevent->ev_mmokstate);
					if (kr) {
						obj_edit(fi->tree, fi->edit_obj, kr,
								mevent->ev_mmokstate, &fi->edit_idx, ED_CHAR,
								fi->win.handle);
						new_idx = fi->edit_idx;
					} else {
						new_idx = -1;
						mevent->ev_mwich &= ~MU_KEYBD;
					}
					break;
				} /* switch */
				break;
			} /* switch */

			if (fi->state == FST_WIN) {
				wind_update( END_UPDATE);
				wind_update( END_MCTRL);
			}
		}

		/* Mausklick */
		if (mevent->ev_mwich & MU_BUTTON) {
			if (fi->state == FST_WIN) {
				wind_update( BEG_UPDATE);
				wind_update( BEG_MCTRL);
			}

			/* Angeklicktes Objekt suchen */
			if ((next_obj = objc_find(fi->tree, ROOT, MAX_DEPTH, mevent->ev_mmox, mevent->ev_mmoy)) == -1) /* NIL */
			{
				/* Aužerhalb des Dialogs */
				if (fi->state != FST_WIN)
					mybeep();
				next_obj = 0;
			} else {
				mevent->ev_mwich &= ~MU_BUTTON;
				if (mevent->ev_mmobutton & 2) /* Rechtsklick? */
				{
					if (fi->state != FST_WIN) /* Fensterdialog? */
						mybeep();
					else if (next_obj && (fi->tree[next_obj].ob_state & DISABLED) == 0) {
						bubble_message(fi->bub_id, next_obj, mevent->ev_mmox, mevent->ev_mmoy);
					}
					next_obj = 0;
				} else {
					/* Auf Popups pruefen */
					if (fi->popup)
						pdo = pop_do(1, fi, next_obj, mevent->ev_mmokstate,
								mevent->ev_mkreturn, &fi->edit_obj,
								&fi->edit_idx, fi->win.handle, &next_obj);
					else
						pdo = 0;

					if (!pdo) {
						if (fi->poplist)
							pdo = poplist_do(1, fi, next_obj,
									mevent->ev_mmokstate, mevent->ev_mkreturn,
									&fi->edit_obj, &fi->edit_idx,
									fi->win.handle, &next_obj);
					}

					switch (pdo) {
					case 2:
						fi->cont = 0;
						break;

					case 1:
						next_obj = 0;
						break;

					case 0:
						/* Normale Verarbeitung */
						fi->cont = form_button(fi->tree, next_obj, mevent->ev_mbreturn, &next_obj);
						nobj = next_obj & 0x7fff;

						/* Klick in ein Editfeld? */
						if (fi->cont && fi->tree[nobj].ob_flags & EDITABLE) {
							/* Falls Doppelklick, dann Rueckgabe mit Objektnummer */
							if (mevent->ev_mbreturn == 2) {
								fi->cont = 0;
/*								tb.mform=ARROW;
								 if(!tb.mbusy) graf_mouse(tb.mform,0L); */

								next_obj |= 0x8000;
							} else {
								/* Sonst Cursorpositionierung */
								objc_offset(fi->tree, nobj, &x, &y);
								x = obj_xleft(fi->tree, nobj);

								tlen = (short) strlen(fi->tree[nobj].ob_spec.tedinfo->te_ptext);
								new_idx = mevent->ev_mmox - x;
								new_idx = obj_idxrel(fi->tree, nobj, new_idx);
								if (new_idx > tlen)
									new_idx = tlen;
							}
						}

						/*
						 * Falls Exit-Objekt TOUCHEXIT & EXIT, dann auf
						 * Loslassen der Maustaste warten.
						 */
						if (!fi->cont && (fi->tree[nobj].ob_flags & (TOUCHEXIT | EXIT)) == (TOUCHEXIT | EXIT)) {
							evnt_button(1, 3, 0, &mx, &my, &mb, &ks);
						}
						break;
					} /* switch */
				}
			}
			if (fi->state == FST_WIN) {
				wind_update( END_UPDATE);
				wind_update( END_MCTRL);
			}
		}
	}

	/*
	 * Pruefen, ob der Inhalt des fixierten Eingabefelds ver„ndert
	 * wurde.
	 */
	if (eobj) {
		strcpy(ebuf2, fi->tree[eobj].ob_spec.tedinfo->te_ptext);
		if (strcmp(ebuf1, ebuf2) != 0) {
			/* Bei Žnderung: Return mit Objektnummer des ver„nderten Felds */
			next_obj = eobj;
			fi->cont = 0;
		}
	}

	/* Aktuelles Eingabefeld anschliežend bereinigen */
	if (fi->cont && next_obj) {
		/*
		 * Anderes Feld - dann Cursor im aktuellen Feld l”schen und
		 * im neuen Feld setzen.
		 */
		if (next_obj != fi->edit_obj) {
			obj_edit(fi->tree, fi->edit_obj, 0, 0, &fi->edit_idx, ED_END, fi->win.handle);
			fi->edit_idx = new_idx;
			fi->edit_obj = next_obj;
			obj_edit(fi->tree, fi->edit_obj, 0, 0, &fi->edit_idx, ED_INIT, fi->win.handle);
		} else /* Gleiches Feld, dann Cursor ggf. setzen */
		{
			if (new_idx != fi->edit_idx && new_idx != -1) {
				obj_edit(fi->tree, fi->edit_obj, 0, 0, &fi->edit_idx, ED_END, fi->win.handle);
				fi->edit_idx = new_idx;
				obj_edit(fi->tree, fi->edit_obj, 0, 0, &fi->edit_idx, ED_INIT, fi->win.handle);
			}
		}
	}

	/* Nummer des Edit- und Exit-Objekts in die FORMINFO-Struktur sichern */
	if (!fi->cont) {
		fi->edit_obj &= 0x7fff;
		fi->exit_obj = next_obj & 0x7fff;
	} else {
		fi->exit_obj = 0;
		next_obj = 0;
	}

	return (next_obj);
}

/*-------------------------------------------------------------------------
 frm_dial()

 Komplette Abwicklung eines Dialogs - analog zu form_do()
 -------------------------------------------------------------------------*/
short frm_dial(FORMINFO *fi, EVENT *mevent) {
	short done, ret, handle, d;
	WININFO *win;

	done = 0;
	while (!done) {
		mevent->ev_mbclicks = 258;
		mevent->ev_bmask = 3;
		mevent->ev_mbstate = 0;
		mevent->ev_mm1flags = 1;
		mevent->ev_mm1x = mevent->ev_mmox;
		mevent->ev_mm1y = mevent->ev_mmoy;
		mevent->ev_mm1width = 1;
		mevent->ev_mm1height = 1;
		mevent->ev_mflags = MU_MESAG | MU_KEYBD | MU_BUTTON | MU_M1;
		EvntMulti(mevent);

		/* Unter Single-TOS ggf. neues Top-Window ermitteln */
		if (!(tb.sys & SY_MULTI) && !(tb.sys & SY_WINX)) {
			wind_get(0, WF_TOP, &handle, &d, &d, &d);
			win = win_getwinfo(handle);
			win_newtop(win);
		}
		ret = frm_do(fi, mevent);
		if (mevent->ev_mwich & MU_MESAG)
			frm_event(fi, mevent);
		if (!fi->cont)
			done = 1;
	}

	return (ret);
}

/*-------------------------------------------------------------------------
 frm_alert()

 Verbesserte Version von form_alert(). Alert erscheint in einem
 Fenster und ist tastaturbedienbar.

 Bei mehr als einem Button ist der letzte immer per Undo w„hlbar!
 Gibt es nur einen Button, kann dieser gleichzeitig Default- und
 Undo-Button sein, wenn in defbut das obere Byte ungleich Null ist.

 Zus„tzlich ist in 'altitle' ein Dialogtitel anzugeben
 -------------------------------------------------------------------------*/
short frm_alert(short defbut, char *alstr, char *altitle, short wd, void *userinfo) {
	EVENT mevent;
	short icon, p, n, t, b, s;
	char *but[3];
	char buf[60];
	short alw, maxlen, butlen, done;
	short cancelbut;
	OBJECT *tree;

	tree = rs_trindex[2];

	/* Sicherheitscheck */
	if (!alstr[0])
		return (-1);

	/* Semaphore gesetzt - d.h. ist ein anderer Alert schon auf? */
	if (tb.sm_alert) {
		/* Ja - dann halt in der ueblichen Form :-/ */
		done = form_alert(defbut, alstr);
		if (!(t_fi.state & FST_WIN))
			frm_redraw(&t_fi, ROOT);

		return (done);
	}

	/* Ist Default-Button auch Cancel-Button? */
	cancelbut = (defbut & 0xff00) ? 1 : 0;
	defbut &= 0xff;

	unsetUserdefs(rs_trindex[2]);
	for (n = 0; n < 3; n++)
		but[n] = tree[9 + n].ob_spec.free_string;

	/* Icon ermitteln */
	p = 0;
	while (alstr[p] && alstr[p] != '[')
		p++;
	p++;

	n = 0;
	while (alstr[p] && alstr[p] != ']') {
		if (n < 60) {
			buf[n] = alstr[p];
			n++;
		}
		p++;
	}
	p++;

	if (alstr[p] != '[')
		return (-1);
	p++;

	buf[n] = 0;
	icon = atoi(buf);
	if (icon < 0 || icon > 3)
		return (-1);

	tree[1].ob_flags |= HIDETREE;
	tree[2].ob_flags |= HIDETREE;
	tree[3].ob_flags |= HIDETREE;
	if (icon > 0) {
		tree[icon].ob_flags &= ~HIDETREE;
		alw = tree[1].ob_x + 32 + tb.ch_w * 2;
	} else
		alw = tree[1].ob_x;

	for (t = 0; t < 5; t++) {
		tree[t + 4].ob_x = alw;
		tree[t + 4].ob_spec.free_string[0] = 0;
	}

	/* Text uebernehmen */
	t = 0;
	maxlen = 0;
	while (alstr[p] && alstr[p] != ']') {
		n = 0;
		while (alstr[p] && alstr[p] != '|' && alstr[p] != ']') {
			if (n < 40 && t < 5) {
				tree[4 + t].ob_spec.free_string[n] = alstr[p];
				n++;
				if (n > maxlen)
					maxlen = n;
			}
			p++;
		}
		if (alstr[p] == '|')
			p++;

		tree[4 + t].ob_spec.free_string[n] = 0;
		t++;
	}
	if (alstr[p] == ']')
		p++;
	if (!alstr[p])
		return (-1);
	p++;

	/* H”he der Dialogbox festlegen */
	if (t < 2)
		t = 2; /* Auf Mindesth”he begrenzen... */

	n = (t + 4) * tb.ch_h;
	s = 32 + tb.ch_h * 4;
	if (n < s)
		n = s;
	tree->ob_height = n;

	/* Button-Texte uebernehmen */
	b = 0;
	butlen = 0;
	while (alstr[p] && alstr[p] != ']') {
		n = 0;
		while (alstr[p] && alstr[p] != '|' && alstr[p] != ']') {
			if (n < 20 && b < 3) {
				but[b][n] = alstr[p];
				n++;
			}
			p++;
		}
		if (alstr[p] == '|')
			p++;
		but[b][n] = 0;
		if (n < 7)
			n = 7; /* Button auf Mindestl„nge begrenzen */

		butlen += (n + 3); /* Gesamtl„nge aller Buttons */
		tree[9 + b].ob_width = (n + 1) * tb.ch_w;
		b++;
	}

	/* Buttons initialisieren - Text, Shortcut, vertikale Ausrichtung */
	t_fi.undo_obj = -1;
	t_fi.help_obj = -1;
	for (n = 0; n < b; n++) {
		tree[n + 9].ob_flags &= ~HIDETREE;
		tree[n + 9].ob_flags |= SELECTABLE;
		tree[n + 9].ob_state &= 0x00ff;
		tree[n + 9].ob_y = tree->ob_height - 2 * tb.ch_h - 1;
#if 0 /* Gryf+ */
		rs_trindex[2][n+9].ob_height=tb.ch_h+2;
#endif

		/* Defaultbutton? */
		if (n == defbut - 1) {
			/* Ja - ohne Shortcut */
			tree[n + 9].ob_flags |= DEFAULT;
			tree[n + 9].ob_state |= 0x7f00;

			/* Auch Cancelbutton? */
			if (cancelbut) {
				/* Ja, also Objektnummer eintragen */
				t_fi.undo_obj = n + 9;
			}
		} else {
			/* Nein */
			tree[n + 9].ob_flags &= ~DEFAULT;
			if (n == b - 1 && b > 1) /* Undo-Button? */
			{
				/* Ja - ohne Shortcut, Objektnummer vormerken */
				tree[n + 9].ob_state |= 0x7f00;
				t_fi.undo_obj = n + 9;
			} else {
				/* Nein - mit Shortcut */
				s = 0;
				while (but[n][s] == ' ')
					s++;

				tree[n + 9].ob_state |= (s << 8);
			}
		}
	}

	for (n = b; n < 3; n++) /* Restliche Buttons ausblenden */
	{
		tree[n + 9].ob_flags |= HIDETREE;
		tree[n + 9].ob_flags &= ~(SELECTABLE | DEFAULT);
		tree[n + 9].ob_width = -tb.ch_w * 2;
		if (butlen > maxlen)
			alw -= 4;
	}

	/* Breite der Dialogbox festlegen */
	if (butlen > maxlen)
		maxlen = butlen;
	tree->ob_width = alw + (maxlen + 2) * tb.ch_w;

	/* Buttons horizontal plazieren */
	tree[11].ob_x = tree->ob_width - tree[11].ob_width - tb.ch_w * 2;
	tree[10].ob_x = tree->ob_width - tree[11].ob_width - tree[10].ob_width - tb.ch_w * 4;
	tree[9].ob_x = tree->ob_width - tree[11].ob_width - tree[9].ob_width - tree[10].ob_width - tb.ch_w * 6;

	/* Und Dialog abwickeln... */
	setUserdefs(rs_trindex[2], FALSE);
	t_fi.tree = tree;
	t_fi.bub_id = -1;
	t_fi.start_obj = ROOT;
	t_fi.popup = 0L;
	t_fi.poplist = 0L;
	t_fi.keyflag = 0;
	t_fi.userinfo = userinfo;
	t_fi.title = altitle;

	graf_mouse(ARROW, 0L);
	tb.sm_alert = 1; /* Semaphore setzen */
	tree->ob_x = tree->ob_y = 0;

	/* Falls entsprechende Semaphore gesetzt, dann Alert non-modal */
	if (tb.sm_nowdial || !wd)
		frm_start(&t_fi, 0, 1, 1);
	else
		frm_start(&t_fi, 1, 1, 1);

	if (t_fi.state == FST_WIN)
		tb.alwin = &t_fi.win;

	done = 0;
	mevent.ev_mmox = -1;
	mevent.ev_mmoy = -1;
	while (!done) {
		mevent.ev_mbclicks = 2;
		mevent.ev_bmask = 3;
		mevent.ev_mbstate = 1;
		mevent.ev_mm1flags = 1;
		mevent.ev_mm1x = mevent.ev_mmox;
		mevent.ev_mm1y = mevent.ev_mmoy;
		mevent.ev_mm1width = 1;
		mevent.ev_mm1height = 1;
		mevent.ev_mflags = MU_MESAG | MU_KEYBD | MU_BUTTON | MU_M1;
		EvntMulti(&mevent);
		frm_do(&t_fi, &mevent);
		if (mevent.ev_mwich & MU_MESAG)
			frm_event(&t_fi, &mevent);

		if (!t_fi.cont) {
			switch (t_fi.exit_obj) {
			case 9:
				done = 1;
				break;
			case 10:
				done = 2;
				break;
			case 11:
				done = 3;
				break;
			}
		}
	}
	frm_end(&t_fi);
	tb.sm_alert = 0; /* Semaphore l”schen */
	tb.alwin = 0L; /* Alertfenster l”schen */

	if (!tb.mbusy)
		graf_mouse(tb.mform, 0L);
	else
		graf_mouse(BUSYBEE, 0L);

	return (done);
}

/**
 * lst_prepare
 *
 * Passt in einem Dialog Position und Groesse des Sliders und der Pfeile
 * einer Auswahlliste an.
 *
 * Eingabe:
 * li: Zeiger auf betroffene LISTINFO-Struktur
 * tree: Zeiger auf zugehoerigen Objektbaum, da li->fi->tree eventuell
 *       noch ungesetzt ist
 */
void lst_prepare(LISTINFO *li, OBJECT *tree) {
	short x;

	x = tree[li->ob_list].ob_x + tree[li->ob_list].ob_width + 1;
	tree[li->ob_up].ob_x = tree[li->ob_box].ob_x = tree[li->ob_down].ob_x = x;

	tree[li->ob_box].ob_y = tree[li->ob_up].ob_y + tree[li->ob_up].ob_height + 1;
	tree[li->ob_box].ob_height = tree[li->ob_list].ob_height - tree[li->ob_up].ob_height - tree[li->ob_down].ob_height - 2;
}

/**
 lst_init()

 Initialisiert eine Auswahlliste in einem Dialog
 -------------------------------------------------------------------------*/
void lst_init(LISTINFO *li, short ilist, short islide, short dlist, short dslide) {
	short i, j;
	long ssize, spos;
	OBJECT *tree;
	char *s, *p;

	tree = li->fi->tree;

	/* Listeneintraege in den Dialog uebertragen */
	if (ilist) {
		for (i = 0; i < li->view; i++) {
			p = tree[li->ob_list + i + 1].ob_spec.tedinfo->te_ptext;
			for (j = 0; j < li->len; j++)
				p[j] = ' ';
			p[j] = 0;

			if (li->num > 0 && i + li->offset < li->num) {
				s = li->text[i + li->offset];
				j = 0;
				while (s[j]) {
					p[j] = s[j];
					j++;
				};
			}
			if (i + li->offset == li->sel)
				tree[li->ob_list + i + 1].ob_state |= SELECTED;
			else
				tree[li->ob_list + i + 1].ob_state &= ~SELECTED;
		}
	}

	/* Gr”že und Position des Sliders berechnen */
	if (islide) {
		if (li->num > li->view) {
			ssize = (long) tree[li->ob_box].ob_height * (long) li->view / (long) li->num;
			if (ssize < (long) tree[li->ob_slide].ob_width)
				ssize = (long) tree[li->ob_slide].ob_width;

			spos = (long) li->offset * ((long) tree[li->ob_box].ob_height - ssize) / (long) (li->num - li->view);
		} else {
			ssize = (long) tree[li->ob_box].ob_height;
			spos = 0;
		}
		tree[li->ob_slide].ob_y = (short) spos;
		tree[li->ob_slide].ob_height = (short) ssize;
	}

	/* Dialog aktualisieren */
	if (dlist)
		frm_redraw(li->fi, li->ob_list);
	if (dslide)
		frm_redraw(li->fi, li->ob_box);
}

/*
 * lst_handle
 *
 * Listenbehandlung fuer Dialogauswertung.
 *
 * Eingabe:
 * li: Zeiger auf betroffene Auswahlliste
 * fi: Zeiger auf dazugeh”rige FORMINFO-Struktur
 * ret: Rueckgabewert von frm_do()
 * dclick: Zeiger auf Integer, in dem vermerkt wird, ob ein
 *         Listeneintrag zur Bearbeitung ausgew„hlt wurde (1) oder
 *         nicht (0)
 *
 * Rueckgabe:
 * 0: Die Auswahlliste war vom Dialogereignis nicht betroffen
 * sonst: Auswahlliste behandelt, *dclick entsprechend gesetzt
 */
short lst_handle(LISTINFO *li, short ret, short *dclick) {
	short sx, sy, sd, mx, my, mb, ks, exob, sel, osel, retcode = 1;

	*dclick = 0;
	exob = li->fi->exit_obj;
	osel = li->sel;
	if (li->fi->state == FST_WIN) {
		wind_update( BEG_UPDATE);
		wind_update( BEG_MCTRL);
	}
	graf_mkstate(&mx, &my, &mb, &ks);
	objc_offset(li->fi->tree, li->ob_slide, &sx, &sy);
	if (exob == li->ob_up)
		lst_up(li);
	else if (exob == li->ob_down)
		lst_down(li);
	else if (exob == li->ob_box) {
		if (my < sy)
			sd = -li->view;
		else
			sd = li->view;

		do {
			lst_move(li, sd);
			graf_mkstate(&mx, &mx, &mb, &ks);
		} while (mb & 1);
	} else if (exob == li->ob_slide)
		lst_slide(li);
	else if (exob == -1) /* Sondertaste? */
		lst_key(li, li->fi->normkey & ~NKF_CTRL);
	else if ((exob > li->ob_list) && (exob <= (li->ob_list + li->view))) {
		sel = exob - li->ob_list - 1 + li->offset;
		if (li->num && (sel < li->num)) {
			lst_select(li, sel);
			if ((sel == osel) || (ret & 0x8000))
				*dclick = 1;
		}
	} else
		retcode = 0;

	if (li->fi->state == FST_WIN) {
		wind_update( END_MCTRL);
		wind_update( END_UPDATE);
	}

	return (retcode);
}

/*-------------------------------------------------------------------------
 lst_move()

 Verschiebt den sichtbaren Teil einer Auswahlliste in einem Dialog
 (wird aufgerufen, wenn man mit der Maus auf die Pfeile des Scrollbars
 oder den Scrollbar-Hintergrund geklickt hat).
 -------------------------------------------------------------------------*/
void lst_move(LISTINFO *li, short delta) {
	short pxy[8];
	short offset, odelta, omax;
	short ox, oy, ow;
	short first, last, vis;
	short ffrag = 0, lfrag = 0;
	short i;
	OBJECT *tree;

	if (li->num <= li->view)
		return;

	tree = li->fi->tree;
	objc_offset(tree, li->ob_list, &ox, &oy);
	ow = tree[li->ob_list].ob_width;

	omax = li->num - li->view; /* Maximaler Offset */
	offset = li->offset;
	li->offset += delta;
	if (li->offset < 0)
		li->offset = 0;
	if (li->offset > omax)
		li->offset = omax;
	odelta = li->offset - offset;
	if (odelta == 0)
		return;

	first = 0;
	while ((oy + first * tb.ch_h) < tb.desk.g_y)
		first++;
	if (first)
		ffrag = (oy + first * tb.ch_h - tb.desk.g_y) % tb.ch_h;

	last = li->view;
	while ((oy + last * tb.ch_h) > (tb.desk.g_y + tb.desk.g_h))
		last--;
	if (last < li->view)
		lfrag = (tb.desk.g_y + tb.desk.g_h - oy + last * tb.ch_h) % tb.ch_h;
	vis = last - first;
	if (vis <= 0)
		return;
	last--;

	/* Optimiertes Redraw m”glich? */
	if (abs(odelta) < vis) {
		/* Ja ... */
		/* Liste aktualisieren, aber ohne die Eintr„ge zu zeichnen */
		lst_init(li, 1, 1, 0, 1);

		/* Kopierkoordinaten berechnen */
		pxy[0] = ox;
		pxy[1] = oy + first * tb.ch_h - ffrag;
		pxy[2] = ox + ow - 1;
		pxy[3] = pxy[1] + lfrag + vis * tb.ch_h - 1;
		pxy[4] = pxy[0];
		pxy[5] = pxy[1];
		pxy[6] = pxy[2];
		pxy[7] = pxy[3];
		if (odelta < 0) {
			pxy[3] += odelta * tb.ch_h;
			pxy[5] -= odelta * tb.ch_h;
		} else {
			pxy[1] += odelta * tb.ch_h;
			pxy[7] -= odelta * tb.ch_h;
		}

		/* Ausschnitt verschieben */
		graf_mouse(M_OFF, 0L);
		vro_cpyfm(v_handle, S_ONLY, pxy, &scr_mfdb, &scr_mfdb);
		graf_mouse(M_ON, 0L);

		/* Fehlende Objekte zeichnen */
		if (odelta < 0) {
			for (i = first - !!ffrag; i < (first - odelta); i++)
				frm_redraw(li->fi, li->ob_list + i + 1);
		} else {
			for (i = last + !!lfrag; i > (last - odelta); i--)
				frm_redraw(li->fi, li->ob_list + i + 1);
		}
	} else {
		/* Nein ... */
		/* Liste aktualisieren und komplett zeichnen */
		lst_init(li, 1, 1, 1, 1);
	}
}

/**
 lst_slide()

 Fuehrt bei gedrueckter Maustaste ein Realtime-Scrolling einer
 Auswahlliste durch (wird aufgerufen, wenn man mit der Maus auf den
 Slider geklickt hat).
 -------------------------------------------------------------------------*/
void lst_slide(LISTINFO *li) {
	short i, offset, omax;
	short mx, my, ks, mb;
	short ox, oy, px, py;
	long spos;
	OBJECT *tree;

	if (li->num <= li->view)
		return;

	tree = li->fi->tree;
	omax = li->num - li->view; /* Maximaler Offset */
	graf_mkstate(&mx, &my, &mb, &ks);
	objc_offset(tree, li->ob_box, &ox, &oy); /* Position des Scrollbar */
	objc_offset(tree, li->ob_slide, &px, &py); /* Position des Sliders */
	i = my - py - 1; /* Abstand Slider-Maus */

	graf_mouse(FLAT_HAND, 0L);
	/* Bei 3D-Optik Slider selektieren */
	if (tb.use3d)
		objc_change(tree, li->ob_slide, 0, tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h, SELECTED, 1);

	do {
		/* Offset berechnen */
		spos = (long) (li->num - li->view) * (long) (my - oy - i)
				/ (long) (tree[li->ob_box].ob_height - tree[li->ob_slide].ob_height);
		offset = (short) spos;
		if (offset > omax)
			offset = omax;

		/* Liste aktualisieren, falls n”tig */
		if (offset != li->offset) {
			lst_move(li, offset - li->offset);
			objc_offset(tree, li->ob_slide, &px, &py); /* Position des Sliders */
		}
		graf_mkstate(&mx, &my, &mb, &ks);
	}

	/* Bei 3D-Optik Slider deselektieren */
	while (mb & 1);
	if (tb.use3d)
		objc_change(tree, li->ob_slide, 0, tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h, NORMAL, 1);

	graf_mouse(ARROW, 0L);
}

/*-------------------------------------------------------------------------
 lst_up()
 lst_down()

 Liste nach oben/unten scrollen (wird aufgerufen, wenn man mit der Maus
 den Pfeil nach unten oder oben anklickt)
 -------------------------------------------------------------------------*/
void lst_up(LISTINFO *li) {
	lst_arrow(li, li->ob_up, -1);
}

void lst_down(LISTINFO *li) {
	lst_arrow(li, li->ob_down, 1);
}

static void lst_arrow(LISTINFO *li, short object, short dir) {
	short mb, du;

	if (li->num <= li->view)
		return;

	objc_change(li->fi->tree, object, 0, tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h, SELECTED, 1);
	do {
		lst_move(li, dir);
		evnt_timer(70L);
		graf_mkstate(&du, &du, &mb, &du);
	} while (mb & 1);

	objc_change(li->fi->tree, object, 0, tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h, NORMAL, 1);
}

/*-------------------------------------------------------------------------
 lst_select()

 Selektiert einen Eintrag einer Auswahlliste.
 -------------------------------------------------------------------------*/
void lst_select(LISTINFO *li, short sel) {
	OBJECT *tree;
	short ob;

	if (sel == li->sel)
		return;

	tree = li->fi->tree;

	/* Bisherige Auswahl l”schen */
	if (li->sel != -1) {
		if (li->sel >= li->offset && li->sel <= li->offset + li->view - 1) {
			ob = li->ob_list + 1 + li->sel - li->offset;
			tree[ob].ob_state &= ~SELECTED;
			objc_draw(tree, ob, MAX_DEPTH, tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h);
		}
	}

	/* Neue Auswahl selektieren */
	li->sel = sel;
	if (li->sel != -1) {
		if (li->sel >= li->offset && li->sel <= li->offset + li->view - 1) {
			ob = li->ob_list + 1 + li->sel - li->offset;
			tree[ob].ob_state |= SELECTED;
			objc_draw(tree, ob, MAX_DEPTH, tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h);
		}
	}
}

/**-------------------------------------------------------------------------
 lst_key()

 Behandelt die Auswahl eines Listenelements mit der Tastatur
 -------------------------------------------------------------------------*/
void lst_key(LISTINFO *li, short key) {
	short sel, d, max;

	if (!li->num)
		return;

	sel = li->sel;
	max = li->num - 1;

	switch (key) {
	case NKF_FUNC | NKF_SHIFT | NK_UP:
		if (sel == -1)
			sel = max;
		else {
			sel -= li->view;
			if (sel < 0)
				sel = 0;
		}
		break;

	case NKF_FUNC | NK_UP:
		if (sel == -1)
			sel = max;
		else if (sel > 0)
			sel--;
		break;

	case NKF_FUNC | NKF_SHIFT | NK_DOWN:
		if (sel == -1)
			sel = 0;
		else {
			sel += li->view;
			if (sel > max)
				sel = max;
		}
		break;

	case NKF_FUNC | NK_DOWN:
		if (sel == -1)
			sel = 0;
		else if (sel < max)
			sel++;
		break;

	case NKF_FUNC | NK_CLRHOME:
		sel = 0;
		break;

	case NKF_FUNC | NKF_SHIFT | NK_CLRHOME:
		sel = max;
		break;
	} /* switch */

	if (sel != li->sel) {
		lst_select(li, -1);
		lst_select(li, sel);
	}
	if (sel != -1) {
		/* Auswahl in sichtbaren Bereich verschieben */
		if (li->offset > sel)
			lst_move(li, sel - li->offset);

		d = sel - li->offset;
		if (d >= li->view)
			lst_move(li, d - li->view + 1);
	}
}

/**-------------------------------------------------------------------------
 win_init()

 Initialisiert die Fensterverwaltung
 -------------------------------------------------------------------------*/
void win_init(void) {
	tb.win = 0L;
}

/**-------------------------------------------------------------------------
 win_icon()
 win_unicon()

 "Ikonifiziert" ein Fenster
 -------------------------------------------------------------------------*/
void win_icon(WININFO *win, short x, short y, short w, short h) {
	short top;

	if ((win->state & WSICON) || !(win->state & WSOPEN))
		return;

	win->save.g_x = win->curr.g_x;
	win->save.g_y = win->curr.g_y;
	win->save.g_w = win->curr.g_w;
	win->save.g_h = win->curr.g_h;
	wind_set(win->handle, WF_ICONIFY, x, y, w, h);
	win_pupdate(win);
	win->state |= WSICON;

	/* Neues aktives Fenster */
	get_twin(&top);
	tb.topwin = win_getwinfo(top);
	win_newtop(tb.topwin);
}

void win_unicon(WININFO *win, short x, short y, short w, short h) {
	short top;

	wind_set(win->handle, WF_UNICONIFY, x, y, w, h);

	/* Urspruengliche Koordinaten eintragen */
	win->curr.g_x = win->save.g_x;
	win->curr.g_y = win->save.g_y;
	win->curr.g_w = win->save.g_w;
	win->curr.g_h = win->save.g_h;
	wind_set(win->handle, WF_CURRXYWH, win->curr.g_x, win->curr.g_y, win->curr.g_w, win->curr.g_h);
	/* WININFO-Struktur aktualisieren */
	win->state &= ~WSICON;
	win_pupdate(win);

	/* Neues aktives Fenster */
	get_twin(&top);
	tb.topwin = win_getwinfo(top);
	win_newtop(tb.topwin);
}

static short win_pos_ok(WININFO *win, GRECT *pos, short *w) {
	WININFO *i;
	GRECT tst1, tst2;
	short above, wid, d, ok = 0;

	tst1 = *pos;
	tst1.g_x -= tb.fhor;
	tst1.g_y -= tb.fvert;
	tst1.g_w += 2 * tb.fhor;
	tst1.g_h += 2 * tb.fvert;
	if (tb.sys & SY_OWNER) {
		above = -1;
		wid = 0;
		if (wind_get(wid, WF_OWNER, &d, &d, &above, &d)) {
			ok = 1;
			wid = above;
			while (wid > 0) {
				wind_get(wid, WF_CURRXYWH, &tst2.g_x, &tst2.g_y, &tst2.g_w, &tst2.g_h);
				if (w != NULL)
					*w = tst2.g_x + tst2.g_w - tst1.g_x;
				if (rc_intersect(&tst1, &tst2))
					return (0);
				if (!wind_get(wid, WF_OWNER, &d, &d, &above, &d)) {
					ok = 0;
					break;
				}
				wid = above;
			}
			if (ok)
				return (1);
		}
	}
	for (i = tb.win; i != NULL; i = i->next) {
		if ((i == win) || (i->state & WSICON) || ((i->state & WSOPEN) != WSOPEN)) {
			continue;
		}
		tst2 = i->curr;
		if (rc_intersect(&tst1, &tst2)) {
			if (w != NULL)
				*w = i->curr.g_x + i->curr.g_w - tst1.g_x;
			return (0);
		}
	}
	return (1);
}

/**
 win_open()

 Initialisiert (mode=0) oder ”ffnet (mode=1) ein initialisiertes Fenster.
 Als Ergebnis erh„lt man 1, falls alles ok ist, sonst 0.
 Die uebergebene WININFO-Struktur wird an die Liste der ge”ffneten
 Fenster angeh„ngt.
 Ist das 15. Bit von mode gesetzt, wird zun„chst geprueft, ob das
 Fenster an der gewuenschten Position abgelegt werden kann, ohne dabei
 ein bereits offenes Fenster zu verdecken. Klappt das nicht, wird
 eine solche Position gesucht, falls es keine gibt, muž das Fenster
 interaktiv plaziert werden, falls das 14. Bit von mode gesetzt ist.
 Ansonsten wird das Fenster an der urspruenglichen Position ge”ffnet.
 -------------------------------------------------------------------------*/
short win_open(WININFO *win, short mode) {
	WININFO *list;

	if (!mode) {
		if (win->state & WSWORKSIZE) {
			/* Fenstergr”sse aus Arbeitsbereich berechnen */
			wind_calc(WC_BORDER, win->flags, win->work.g_x, win->work.g_y,
					win->work.g_w, win->work.g_h, &win->curr.g_x, &win->curr.g_y,
					&win->curr.g_w, &win->curr.g_h);
		}
		if (win->state & WSDESKSIZE) {
			/* Maximale Fenstergr”sse entspricht Desktopgr”sse */
			win->full.g_x = tb.desk.g_x;
			win->full.g_y = tb.desk.g_y;
			win->full.g_w = tb.desk.g_w;
			win->full.g_h = tb.desk.g_h;
		}
		if (win->state & WSFULLOPEN) {
			/* Fenster mit maximaler Gr”sse ”ffnen */
			win->curr.g_x = win->full.g_x;
			win->curr.g_y = win->full.g_y;
			win->curr.g_w = win->full.g_w;
			win->curr.g_h = win->full.g_h;
			win->state |= WSFULL;
		}
		/* Gr”že des Arbeitsbereichs berechnen */
		wind_calc(WC_WORK, win->flags, win->curr.g_x, win->curr.g_y, win->curr.g_w,
				win->curr.g_h, &win->work.g_x, &win->work.g_y, &win->work.g_w,
				&win->work.g_h);

		/* Fenster erzeugen */
		win->handle = wind_create(win->flags, win->full.g_x, win->full.g_y, win->full.g_w, win->full.g_h);
		if (win->handle <= 0)
			return (0);

		win->state |= WSINIT;

		/* Fenster-Titelzeile und -Infozeile setzen */
		win_updtinfo(win);

		/* Fenster an die Liste anh„ngen */
		win->next = 0L;
		list = tb.win;
		if (!list) {
			/* Liste bisher leer */
			tb.win = win;
			win->prev = 0L;
		} else {
			while (list->next)
				list = list->next;
			list->next = win;
			win->prev = list;
		}
		return (1);
	} else {
		/* Fenster ”ffnen */
		if (mode & 0xc000) {
			if ((mode & 0x8000) || !win_pos_ok(win, &win->curr, NULL)) {
				GRECT tst, mx;
				short x, y, w, ok;

				ok = 0;
				if (mode & 0x8000) {
					mx.g_x = tb.desk.g_x + tb.fleft;
					mx.g_y = tb.desk.g_y + tb.fupper;
					mx.g_w = tb.desk.g_w - tb.fleft - tb.fright;
					mx.g_h = tb.desk.g_h - tb.fupper - tb.flower;
					tst.g_w = win->curr.g_w = min(mx.g_w, win->curr.g_w);
					tst.g_h = win->curr.g_h = min(mx.g_h, win->curr.g_h);
					for (y = tb.desk.g_y + tb.fupper; (y + tst.g_h)
							<= (mx.g_y + mx.g_h); y += 8) {
						tst.g_y = y;
						for (x = tb.desk.g_x + tb.fleft; (x + tst.g_w) <= (mx.g_x + mx.g_w); x += 8) {
							tst.g_x = x;
							if (win_pos_ok(win, &tst, &w)) {
								win->curr.g_x = x;
								win->curr.g_y = y;
								ok = 1;
								break;
							}
							if (w >= 8)
								x += w - 8;
						}
						if (ok)
							break;
					}
				}
				if (!ok) {
					if ((mode & 0x4000) && grf_dragbox(win->curr.g_w,
							win->curr.g_h, tb.desk.g_x, tb.desk.g_y, tb.desk.g_w
									+ win->curr.g_w - 1, tb.desk.g_h + win->curr.g_h
									- 1, -1, -1, &x, &y)) {
						win->curr.g_x = x;
						win->curr.g_y = y;
					} else {
						if (mode & 0x8000) {
							if (win->curr.g_x < mx.g_x)
								win->curr.g_x = mx.g_x;
							if (win->curr.g_y < mx.g_y)
								win->curr.g_y = mx.g_y;
							if ((win->curr.g_x + win->curr.g_w) > (mx.g_x + mx.g_w))
								win->curr.g_x = mx.g_x + mx.g_w - win->curr.g_w;
							if ((win->curr.g_y + win->curr.g_h) > (mx.g_y + mx.g_h))
								win->curr.g_y = mx.g_y + mx.g_h - win->curr.g_h;
						}
					}
				}
			}
		}

		tb.topwin = win;
		win->state |= WSOPEN;
		wind_open(win->handle, win->curr.g_x, win->curr.g_y, win->curr.g_w, win->curr.g_h);
		win_pupdate(win);

		/* Slider setzen */
		win_slide(win, S_INIT, 0, 0);
		return (1);
	}
}

/**-------------------------------------------------------------------------
 win_close()

 Schliesst und entfernt ein Fenster. Die WININFO-Struktur wird aus
 der Liste der Fenster ausgeklinkt.
 -------------------------------------------------------------------------*/
void win_close(WININFO *win) {
	WININFO *prev, *next;

	if (win->state & WSINIT) {
		/* Fenster initialisiert */
		if (win->state & WSOPEN) {
			/* Fenster ge”ffnet */
			/* Bei Bedarf Fenster vorher nach hinten stellen */
			if (tb.backwin && tb.sys & SY_MAGX)
				wind_set(win->handle, WF_BOTTOM, 0, 0, 0, 0);

			/* Und schliežen */
			wind_close(win->handle);
			win->state &= ~WSOPEN;
		}

		wind_delete(win->handle);
		win->state &= ~WSINIT;
		/* Falls ikonifiziert, dann urspruengliche Koordinaten eintragen */
		if (win->state & WSICON) {
			win->curr.g_x = win->save.g_x;
			win->curr.g_y = win->save.g_y;
			win->curr.g_w = win->save.g_w;
			win->curr.g_h = win->save.g_h;
			win->state &= ~WSICON;
		}

		/* Fensterstruktur aus der Liste ausklinken */
		prev = win->prev;
		next = win->next;
		if (!prev) {
			/* Kein Vorg„nger - dann erster Eintrag ! */
			tb.win = next;
			if (next)
				next->prev = 0L;
		} else {
			/* Vorg„nger vorhanden */
			prev->next = next;
			if (next)
				next->prev = prev;
		}
	}
}

/**-------------------------------------------------------------------------
 win_redraw()

 Zeichnet einen Auschnitt des Fensterinhalts.
 -------------------------------------------------------------------------*/
void win_redraw(WININFO *win, short x, short y, short w, short h) {
	GRECT area, full, box;
	short pxy[4];
	FORMINFO *fi;

	/* AES sperren und Maus abschalten */
	wind_update( BEG_UPDATE);
	graf_mouse(M_OFF, 0L);

	/* Vorbereitungen */
	area.g_x = x;
	area.g_y = y;
	area.g_w = w;
	area.g_h = h;

	if (win->state & WSICON) {
		/* Fenster ikonifiziert */
		if (win->ictree) {
			win->ictree->ob_x = win->work.g_x;
			win->ictree->ob_y = win->work.g_y;
			win->ictree->ob_width = win->work.g_w;
			win->ictree->ob_height = win->work.g_h;
			win->ictree[1].ob_x = (win->work.g_w - win->ictree[1].ob_width) / 2;
			win->ictree[1].ob_y = (win->work.g_h - win->ictree[1].ob_height) / 2;
		} else {
			vsf_interior(tb.vdi_handle, FIS_HOLLOW);
			vsf_perimeter(tb.vdi_handle, 0);
		}
	} else {
		/* Fenster normal */
		/* Vorbereitungs-/Update-Prozedur aufrufen, falls vorhanden */
		if (win->update)
			win->update(win);
		if (win->prepare)
			win->prepare(win);
	}

	/* Falls Dialogbox, dann vor dem Redraw Cursor ausschalten */
	if (win->class == WCDIAL) {
		fi = (FORMINFO *) win->user;
		if (fi->edit_obj && fi->edit_idx != -1)
			obj_edit(fi->tree, fi->edit_obj, 0, 0, &fi->edit_idx, ED_END, win->handle);
	}

	/* Gr”že des Arbeitsbereiches */
	wind_get(win->handle, WF_CURRXYWH, &full.g_x, &full.g_y, &full.g_w, &full.g_h);

	/* Ersten Eintrag in der Rechteckliste holen */
	wind_get(win->handle, WF_FIRSTXYWH, &box.g_x, &box.g_y, &box.g_w, &box.g_h);

	/* Rechteckliste abarbeiten */
	while (box.g_w && box.g_h) {
		if (rc_intersect(&full, &box)) /* sichtbar? */
		{
			/* Nur durchfuehren, wenn freies Rechteck innerhalb des zu
			 zeichnenden Bereichs liegt */
			if (rc_intersect(&area, &box)) {
				/* Clipping ein */
				pxy[0] = box.g_x;
				pxy[1] = box.g_y;
				pxy[2] = pxy[0] + box.g_w - 1;
				pxy[3] = pxy[1] + box.g_h - 1;
				if (win->class!=WCDIAL)
					vs_clip(tb.vdi_handle, 1, pxy);

				if (win->state & WSICON) /* Fenster ikonifiziert */
				{
					if (win->ictree)
						objc_draw(win->ictree, ROOT, MAX_DEPTH, box.g_x, box.g_y, box.g_w, box.g_h);
					else
						v_bar(tb.vdi_handle, pxy);
				} else {
					/* Redraw-Prozedur aufrufen */
					win->redraw(win, &box);
				}

				/* Clipping aus */
				if (win->class!=WCDIAL)
					vs_clip(tb.vdi_handle, 0, pxy);
			}
		}
		/* N„chstes freies Rechteck holen */
		wind_get(win->handle, WF_NEXTXYWH, &box.g_x, &box.g_y, &box.g_w, &box.g_h);
	}

	/* Falls Dialog dann ggf. Cursor wieder einschalten */
	if (win->class == WCDIAL) {
		if (fi->edit_obj && fi->edit_idx != -1)
			obj_edit(fi->tree, fi->edit_obj, 0, 0, &fi->edit_idx, ED_INIT, win->handle);
	}

	/* Maus einschalten und AES freigeben */
	graf_mouse(M_ON, 0L);
	wind_update( END_UPDATE);
}

/**-------------------------------------------------------------------------
 win_scroll()

 Verschiebt den Fensterinhalt.
 -------------------------------------------------------------------------*/
void win_scroll(WININFO *win, short x, short y) {
	GRECT box, rbox;
	short pxy[8];
	short mx, my, mw, mh;

	/* AES sperren und Maus abschalten */
	wind_update( BEG_UPDATE);
	graf_mouse(M_OFF, 0L);

	/* Vorbereitungs-/Update-Prozedur aufrufen, falls vorhanden */
	if (win->update)
		win->update(win);
	if (win->prepare)
		win->prepare(win);

	/* Ersten Eintrag in der Rechteckliste holen */
	wind_get(win->handle, WF_FIRSTXYWH, &box.g_x, &box.g_y, &box.g_w, &box.g_h);

	/* Rechteckliste abarbeiten */
	while (box.g_w && box.g_h) {
		/*
		 * Nur durchfuehren, wenn Teil-Rechteck ganz oder teilweise
		 * innerhalb des Desktops liegt.
		 */
		if (rc_intersect(&tb.desk, &box)) {
			/* Absolute Verschiebung ohne Richtung */
			if (x > 0)
				mx = x;
			else
				mx = -x;
			if (y > 0)
				my = y;
			else
				my = -y;

			/* Teilbereich verschieben, wenn m”glich */
			if (mx < box.g_w && my < box.g_h) {
				mw = box.g_w - mx;
				mh = box.g_h - my;

				/* Koordinaten fuer Verschiebung berechnen */
				if (x > 0)
					pxy[0] = box.g_x;
				else
					pxy[0] = box.g_x + box.g_w - mw;
				pxy[2] = pxy[0] + mw - 1;
				pxy[4] = pxy[0] + x;
				pxy[6] = pxy[2] + x;

				if (y > 0)
					pxy[1] = box.g_y;
				else
					pxy[1] = box.g_y + box.g_h - mh;
				pxy[3] = pxy[1] + mh - 1;
				pxy[5] = pxy[1] + y;
				pxy[7] = pxy[3] + y;

				/* Ausschnitt verschieben */
				vro_cpyfm(tb.vdi_handle, S_ONLY, pxy, &scr_mfdb, &scr_mfdb);

				/* Freigewordene Fl„chen neu zeichnen */
				if (mx > 0) /* Fl„che 1 (senkrecht) */
				{
					if (x < 0)
						rbox.g_x = box.g_x + box.g_w - mx;
					else
						rbox.g_x = box.g_x;
					rbox.g_y = box.g_y;
					rbox.g_h = box.g_h;
					rbox.g_w = mx;

					/* Clipping ein */
					pxy[0] = rbox.g_x;
					pxy[1] = rbox.g_y;
					pxy[2] = pxy[0] + rbox.g_w - 1;
					pxy[3] = pxy[1] + rbox.g_h - 1;
					vs_clip(tb.vdi_handle, 1, pxy);

					/* Redraw-Prozedur aufrufen */
					win->redraw(win, &rbox);

					/* Clipping aus */
					vs_clip(tb.vdi_handle, 0, pxy);
				}
				if (my > 0) /* Fl„che 2 (waagrecht) */
				{
					if (y < 0)
						rbox.g_y = box.g_y + box.g_h - my;
					else
						rbox.g_y = box.g_y;
					rbox.g_x = box.g_x;
					rbox.g_w = box.g_w;
					rbox.g_h = my;

					/* Schnittfl„che mit Fl„che 1 abschneiden */
					if (mx > 0) {
						rbox.g_w -= mx;
						if (x > 0)
							rbox.g_x += x;
					}

					/* Clipping ein */
					pxy[0] = rbox.g_x;
					pxy[1] = rbox.g_y;
					pxy[2] = pxy[0] + rbox.g_w - 1;
					pxy[3] = pxy[1] + rbox.g_h - 1;
					vs_clip(tb.vdi_handle, 1, pxy);

					/* Redraw-Prozedur aufrufen */
					win->redraw(win, &rbox);

					/* Clipping aus */
					vs_clip(tb.vdi_handle, 0, pxy);
				}
			} else {
				/* Nicht m”glich, dann komplett neu zeichnen */
				/* Clipping ein */
				pxy[0] = box.g_x;
				pxy[1] = box.g_y;
				pxy[2] = pxy[0] + box.g_w - 1;
				pxy[3] = pxy[1] + box.g_h - 1;
				vs_clip(tb.vdi_handle, 1, pxy);

				/* Redraw-Prozedur aufrufen */
				win->redraw(win, &box);

				/* Clipping aus */
				vs_clip(tb.vdi_handle, 0, pxy);
			}
		}

		/* N„chstes freies Rechteck holen */
		wind_get(win->handle, WF_NEXTXYWH, &box.g_x, &box.g_y, &box.g_w, &box.g_h);
	}

	/* Maus einschalten und AES freigeben */
	graf_mouse(M_ON, 0L);
	wind_update( END_UPDATE);
}

/**-------------------------------------------------------------------------
 win_pupdate()

 Aktualisiert die Fensterparameter nach ge„nderte Gr”sse/Position.
 -------------------------------------------------------------------------*/
void win_pupdate(WININFO *win) {
	/* Gr”sse des Arbeitsbereiches abfragen */
	wind_get(win->handle, WF_WORKXYWH, &win->work.g_x, &win->work.g_y, &win->work.g_w, &win->work.g_h);

	/* Window-Update aufrufen, falls vorhanden */
	if (win->update)
		win->update(win);
}

/**-------------------------------------------------------------------------
 win_size()

 Žndert die Gr”sse eines Fensters.
 -------------------------------------------------------------------------*/
void win_size(WININFO *win, short x, short y, short w, short h) {
	short slide;

	if (win->curr.g_w != w || win->curr.g_h != h)
		slide = 1;
	else
		slide = 0;

	/* Neue Gr”že eintragen */
	win->curr.g_x = x;
	win->curr.g_y = y;
	win->curr.g_w = w;
	win->curr.g_h = h;

	/* Gr”že setzen */
	wind_set(win->handle, WF_CURRXYWH, x, y, w, h);

	/* "Fulled"-Status ruecksetzen */
	win->state &= ~WSFULL;

	/* Parameter aktualisieren */
	win_pupdate(win);

	/* Slider aktualisieren, falls n”tig */
	if (slide) {
		win_slide(win, S_INIT, 0, 0);
		/*
		 * Falls erwuenscht, dann Redraw-Message fuer kompletten Arbeits-
		 * bereich verschicken.
		 */
		if (win->state & WSFULLREDR) {
			aesmsg[0] = WM_REDRAW;
			aesmsg[1] = tb.app_id;
			aesmsg[2] = 0;
			aesmsg[3] = win->handle;
			aesmsg[4] = x;
			aesmsg[5] = y;
			aesmsg[6] = w;
			aesmsg[7] = h;
			appl_write(tb.app_id, 16, aesmsg);
		}
	}
}

/**-------------------------------------------------------------------------
 win_full()

 Schaltet zwischen aktueller und voller Gr”sse um, je nach aktuellem
 Zustand.
 -------------------------------------------------------------------------*/
void win_full(WININFO *win) {
	short x, y, w, h;

	/* Fulled/Actual-Gr”že ermitteln */
	if (win->state & WSFULL)
		wind_get(win->handle, WF_PREVXYWH, &x, &y, &w, &h);
	else /* wind_get(win->handle,WF_FULLXYWH,&x,&y,&w,&h); */
	{
		x = win->full.g_x;
		y = win->full.g_y;
		w = win->full.g_w;
		h = win->full.g_h;
	}
	wind_set(win->handle, WF_CURRXYWH, x, y, w, h);
	/* Parameter aktualisieren */
	win_pupdate(win);
	/* Slider aktualisieren, falls n”tig */
	if (win->curr.g_w != w || win->curr.g_h != h) {
		win_slide(win, S_INIT, 0, 0);
		/* Falls erwuenscht, dann Redraw-Message fuer kompletten Arbeits-
		 bereich verschicken */
		if (win->state & WSFULLREDR) {
			aesmsg[0] = WM_REDRAW;
			aesmsg[1] = tb.app_id;
			aesmsg[2] = 0;
			aesmsg[3] = win->handle;
			aesmsg[4] = x;
			aesmsg[5] = y;
			aesmsg[6] = w;
			aesmsg[7] = h;
			appl_write(tb.app_id, 16, aesmsg);
		}
	}
	/* Gr”sse eintragen und "Fulled"-Status setzen */
	win->curr.g_x = x;
	win->curr.g_y = y;
	win->curr.g_w = w;
	win->curr.g_h = h;
	win->state ^= WSFULL;
}

/**-------------------------------------------------------------------------
 win_newtop()
 
 Merkt sich das angegebene Fenster als neues aktives Fenster - oder
 daž keines aktiv ist
 -------------------------------------------------------------------------*/
void win_newtop(WININFO *win) {
	EVENT mevent;
	short exit_obj;

	tb.topwin = win;
	tb.topfi = 0L;
	if (tb.topwin) {
		if (tb.topwin->class==WCDIAL)
			tb.topfi = (FORMINFO *) tb.topwin->user;
	}
	if (!tb.topfi) {
		/* Kein Dialog, dann ggf. Mauszeiger wieder normal */
		if (tb.mform != ARROW) {
			tb.mform = ARROW;
			if (!tb.mbusy)
				graf_mouse(ARROW, 0L);
			else
				graf_mouse(BUSYBEE, 0L);
		}
	} else {
		/* Dialog auf, dann ggf. Mauszeiger neu setzen */
		mevent.ev_mflags = MU_M1 | MU_TIMER;
		mevent.ev_mm1flags = 0;
		mevent.ev_mm1x = tb.desk.g_x;
		mevent.ev_mm1y = tb.desk.g_y;
		mevent.ev_mm1width = tb.desk.g_w;
		mevent.ev_mm1height = tb.desk.g_h;
		mevent.ev_mtlocount = 1;
		mevent.ev_mthicount = 0;
		EvntMulti(&mevent);
		exit_obj = tb.topfi->exit_obj;
		frm_do(tb.topfi, &mevent);
		tb.topfi->exit_obj = exit_obj;
	}
}

/**-------------------------------------------------------------------------
 win_top()

 Macht das angegebene Fenster zum obersten (aktiven) Fenster.
 -------------------------------------------------------------------------*/
void win_top(WININFO *win) {
	WININFO *twin;

	/* Falls Alertfenster auf, dann nur dieses toppen! */
	if (tb.alwin)
		twin = tb.alwin;
	else
		twin = win;

	wind_set(twin->handle, WF_TOP, 0, 0, 0, 0); /* Nach oben stellen */
	win_newtop(twin);
}

/**-------------------------------------------------------------------------
 win_updtinfo()

 Aktualisiert die Titel- und Infozeile
 -------------------------------------------------------------------------*/
void win_updtinfo(WININFO *win) {
	if (win->flags & NAME)
		wind_set_str(win->handle, WF_NAME, win->name);
	if (win->flags & INFO)
		wind_set_str(win->handle, WF_INFO, win->info );
}

/**-------------------------------------------------------------------------
 win_slide()

 Verschieben des Fensterinhalts, Setzen der Slider
 -------------------------------------------------------------------------*/
void win_slide(WININFO *win, short mode, short h, short v) {
	if (win->state & WSICON)
		return;
	if (win->slide)
		win->slide(win, mode, h, v);
}

/**-------------------------------------------------------------------------
 win_getwinfo()

 Ermittelt zu einem AES-Handle die WININFO-Struktur. Als Ergebnis erh„lt
 man einen Zeiger auf die WININFO-Struktur oder 0L, falls kein Fenster
 mit dem angegebenen Handle vorhanden ist.
 -------------------------------------------------------------------------*/
WININFO *win_getwinfo(short handle) {
	WININFO *list;
	short done;

	if (tb.win) {
		list = tb.win;
		done = 0;

		do {
			if (list->handle == handle)
				return (list);
			if (list->next)
				list = list->next;
			else
				done = 1;
		} while (!done);

		return (0L);
	} else
		return (0L);
}

/**-------------------------------------------------------------------------
 rs_fix()

 Fontgroessen-Unabhaengiges rsrc_obfix.
 -------------------------------------------------------------------------*/
void rs_fix(OBJECT *tree, short orig_cw, short orig_ch) {
	OBJECT *obj;
	short rest_x, rest_y, rest_w, rest_h;

	for (obj = tree;;) {
		if (orig_cw != 0) {
			rest_x = (obj->ob_x & 0xff00) >> 8;
			rest_y = (obj->ob_y & 0xff00) >> 8;
			rest_w = (obj->ob_width & 0xff00) >> 8;
			rest_h = (obj->ob_height & 0xff00) >> 8;

			obj->ob_x &= 0xff;
			obj->ob_y &= 0xff;
			obj->ob_width &= 0xff;
			obj->ob_height &= 0xff;

			obj->ob_x *= tb.ch_w;
			obj->ob_y *= tb.ch_h;
			obj->ob_width *= tb.ch_w;
			obj->ob_height *= tb.ch_h;

			if (rest_x)
				obj->ob_x += (rest_x * tb.ch_w) / orig_cw;
			if (rest_y)
				obj->ob_y += (rest_y * tb.ch_h) / orig_ch;
			if (rest_w)
				obj->ob_width += (rest_w * tb.ch_w) / orig_cw;
			if (rest_h)
				obj->ob_height += (rest_h * tb.ch_h) / orig_ch;
		} else
			rsrc_obfix(obj, ROOT);

		if (obj->ob_flags & LASTOB)
			break;

		obj++;
	}
}

/**
 * rs_textadjust
 *
 * Wandelt alle TEXT-Felder in BOXTEXT um und setzt dann bei BOXTEXT
 * den Text auf transparent und die Hintergrundfarbe auf einen
 * bestimmten Wert.
 *
 * Eingabe:
 * tree: Zeiger auf Objektbaum
 * bg: VDI-Farbindex der Hintergrundfarbe
 */
void rs_textadjust(OBJECT *tree, short bg) {
	short i;

	bg &= 0xf;
	for (i = 0;; i++) {
		if ((tree[i].ob_type & 0xff) == G_TEXT) {
			if (((tree[i].ob_flags & EDITABLE) != EDITABLE) && (tree[i].ob_spec.tedinfo->te_color & 128)) {
				tree[i].ob_spec.tedinfo->te_thickness = 0;
				tree[i].ob_spec.tedinfo->te_color &= ~128;
				tree[i].ob_type = G_BOXTEXT | (tree[i].ob_type & 0xff00);
				tree[i].ob_spec.tedinfo->te_color |= 7 << 4;
			}
		}
		if ((tree[i].ob_type & 0xff) == G_BOXTEXT) {
			if ((tree[i].ob_spec.tedinfo->te_thickness == 0) && ((tree[i].ob_spec.tedinfo->te_color & 128) != 128)) {
				tree[i].ob_spec.tedinfo->te_color &= ~15;
				tree[i].ob_spec.tedinfo->te_color |= bg;
			}
		}
		if (tree[i].ob_flags & LASTOB)
			break;
	}
}

/**-------------------------------------------------------------------------
 scrap_clear()

 L”scht alle Dateien mit dem Namen 'SCRAP' aus dem Clipboard
 -------------------------------------------------------------------------*/
void scrap_clear(void) {
	char spath[256], l;
	_DTA *odta, dta;

	/* Aktuellen Clipboardpfad ermitteln */
	if (!scrp_read(spath))
		return;
	l = (short) strlen(spath);
	if (spath[l - 1] != '\\') {
		strcat(spath, "\\");
		l++;
	}

	/* Dateien darin l”schen */
	odta = Fgetdta();
	Fsetdta(&dta);
	if (tb.sys & SY_MAGX)
		Pdomain(0);
	strcpy(&spath[l], "SCRAP.*");
	if (!Fsfirst(spath, FA_HIDDEN | FA_SYSTEM)) {
		do {
			strcpy(&spath[l], dta.dta_name);
			Fdelete(spath);
		} while (!Fsnext());
	}
	Fsetdta(odta);

	if (tb.sys & SY_MAGX)
		Pdomain(1);
}

/*-------------------------------------------------------------------------
 mn_tnormal()

 "Multitasking-Version" von menu_tnormal()
 -------------------------------------------------------------------------*/
void mn_tnormal(OBJECT *tree, short title, short normal) {
#ifdef OLD_MENU
	short id,state;

	if(normal) state=tree[title].ob_state&~SELECTED;
	else state=tree[title].ob_state|SELECTED;

#ifndef _NAES 
	if(tb.sys&SY_MAGX)
	{
		wind_update(BEG_UPDATE);
		id=menu_bar(0L,-1);
		if(id==tb.app_id) /* Menueleiste geh”rt mir */
		objc_change(tree,title,0,0,0,tb.resx,tb.resy,state,1);
		else /* Menueleiste geh”rt jemand anderem */
		objc_change(tree,title,0,0,0,tb.resx,tb.resy,state,0);
		wind_update(END_UPDATE);
	}
	else
#endif
#if 1
	menu_tnormal(tree, title, normal);
#else
	objc_change(tree,title,0,0,0,tb.resx,tb.resy,state,1);
#endif
#else
	menu_tnormal(tree, title, normal);
#endif
}

/**-------------------------------------------------------------------------
 fselect()
 
 Erweiterte Dateiauswahl - analog zu fsel_exinput(), aber mit
 Freedom-Support
 
 fret - 0=auf Antwort von Freedom warten
 1=sofort zurueckkehren mit 'Abbruch', Freedom-Antwort
 wird sp„ter ausgewertet
 fid  - Beliebige ID fuer sp„tere Auswertung der Freedom-Antwort
 -------------------------------------------------------------------------*/
short fselect(char *fs_einpath, char *fs_einsel, short *fs_eexbutton, char *elabel,
		short fret, short fid) {
	static Fdm_Str *fdm = NULL;
	SLCT_STR *selectric;
	char lpath[256 + sizeof(Fdm_Str)];
	short ret, done;
	char *fpath, *fname;
	EVENT mevent;
	WININFO *win;
	short handle, d;
	short use_mctrl;

	/* Freedom-Daten initialisieren */
	if (!fdm)
		fdm = Mxalloc(sizeof(lpath), (tb.sys & SY_XALLOC) ? 0x23 : 0x3);

	if (fdm) {
		fdm->magic = '?Fdm';
		fdm->id = fid;
		fdm->maxsel = 1;
		fdm->flags.fullpaths = 0;
		fdm->flags.doquote = 0;
		fdm->flags.noname = 0;
		fdm->flags.sysmodal = 0;
		fdm->flags.resvd = 0;
		fpath = (char *) fdm + sizeof(Fdm_Str);
	} else
		fpath = lpath;

	strcpy(fpath, fs_einpath);
	if (fdm)
		strcpy(&fpath[(short) strlen(fpath) + 1], "?Fdm");

	/* FSEL-Cookie ermitteln */
	if (Getcookie('FSEL', (long *) &selectric) != E_OK)
		selectric = NULL;

	/* Aufrufen */
	graf_mouse(ARROW, 0L);
	wind_update( BEG_UPDATE);
	/* MCTRL nur, wenn kein FSEL-Cookie oder Version < 0x200 */
	use_mctrl = 0;
	if ((selectric == NULL) || (selectric->id != 'SLCT') || (selectric->version < 0x200)) {
		use_mctrl = 1;
	}
	if (use_mctrl)
		wind_update( BEG_MCTRL);
	ret = fsel_exinput(fpath, fs_einsel, fs_eexbutton, elabel);
	if (use_mctrl)
		wind_update( END_MCTRL);
	wind_update( END_UPDATE);
	if (!tb.mbusy)
		graf_mouse(tb.mform, 0L);

	/* Auswahl ueber Freedom? */
	if (fdm && (fdm->magic == '!Fdm')) {
		/* Falls gewuenscht, dann sofortige Rueckkehr */
		if (fret) {
			*fs_eexbutton = 0;
			return 1;
		}
		/* Jo - dann jetzt auf Antwort von Freedom warten und w„hrenddessen
		 die uebrigen AES-Messages bearbeiten */
		tb.sm_modal++;
		if ((tb.sm_modal == 1) && (tb.modal_on != 0L))
			tb.modal_on();
		done = 0;
		while (!done) {
			mevent.ev_mflags = MU_MESAG;
			EvntMulti(&mevent);

			/* Unter Single-TOS ggf. neues Top-Window ermitteln */
			if (!(tb.sys & SY_MULTI) && !(tb.sys & SY_WINX)) {
				wind_get(0, WF_TOP, &handle, &d, &d, &d);
				win = win_getwinfo(handle);
				win_newtop(win);
			}

			/* Nachrichten auswerten */
			switch (mevent.ev_mmgpbuf[0]) {
			case FILE_SELECTED: /* Freedom-Rueckantwort */
				done = 1;
				ret = 1;
				memcpy(&fpath, &mevent.ev_mmgpbuf[4], 4L);
				memcpy(&fname, &mevent.ev_mmgpbuf[6], 4L);
				if (!fname)
					*fs_eexbutton = 0;
				else {
					*fs_eexbutton = 1;
					strcpy(fs_einpath, fpath);
					strcpy(fs_einsel, fname);
				}
				break;

			case WM_ICONIFY:
			case WM_UNICONIFY:
			case WM_ALLICONIFY:
			case WM_CLOSED:
				mybeep();
				break;

			case WM_TOPPED:
			case WM_NEWTOP:
			case WM_ONTOP:
				aesmsg[0] = WIN_TOPPED;
				aesmsg[1] = tb.app_id;
				aesmsg[2] = 0;
				aesmsg[3] = fdm->handle;
				aesmsg[4] = 0;
				aesmsg[5] = 0;
				aesmsg[6] = 0;
				aesmsg[7] = 0;
				appl_write(fdm->server, 16, aesmsg);
				break;

			case WM_REDRAW:
			case WM_M_BDROPPED:
			case WM_BOTTOMED:
			case WM_UNTOPPED:
			case WM_FULLED:
			case WM_ARROWED:
			case WM_HSLID:
			case WM_VSLID:
			case WM_SIZED:
			case WM_MOVED:
				/* Fenster ermitteln, das betroffen ist */
				win = win_getwinfo(mevent.ev_mmgpbuf[3]);
				/* Falls bekannt, dann jetzt den Message-Handler der Appl.
				 aufrufen */
				if (win) {
					if (tb.msg_handler)
						tb.msg_handler(&mevent, 0L);
				}
				break;

			default: /* Sonstige Messages (AV etc.) */
				if (tb.msg_handler)
					tb.msg_handler(&mevent, 0L);
				break;
			}
		}
		if (tb.sm_modal > 0) {
			tb.sm_modal--;
			if (tb.sm_modal == 0 && tb.modal_off != 0L)
				tb.modal_off();
		}
	} else {
		/* N” - dann einfach die Rueckgabewerte vom OS verwenden */
		strcpy(fs_einpath, fpath);
	}

	return ret;
}

/**-------------------------------------------------------------------------
 magx_switch()

 Aktiviert die Menueleiste einer Applikation unter MagiC und toppt
 deren Fenster in der richtigen Reihenfolge, wenn es nicht die
 aufrufende Applikation selbst und der Parameter top ungleich Null
 ist. Tut auch unter N.AES!
 Nur wenn id die negative eigene Applikations-ID minus 1 ist (also
 id == -(app_id + 1)), werden beim Umschalten auf die eigene
 Applikation auch die Fenster mitgetoppt.
 -------------------------------------------------------------------------*/
void magx_switch(short id, short top) {
	short ap_id, twin, magictop, notme, dummy, win, owner, above, winds;
	static short windows[256];

	/* Nur wenn MagiC oder N.AES ueberhaupt vorhanden */
	if (!(tb.sys & SY_MAGX) && !(tb.sys & SY_NAES))
		return;

	notme = 1;
	if (id == -(tb.app_id + 1)) {
		id = tb.app_id;
		notme = 0;
	}
	if (id < 0)
		return;

	/* Eigentuemer der aktiven Menueleiste ermitteln */
	ap_id = menu_bar(0x0L, -1);
	/* Eigentuemer des obersten Fensters ermitteln */
	if (wind_get(0, WF_TOP, &twin, &owner, &dummy, &magictop)) {
		if ((twin == -2) && (tb.sys & SY_MAGX)) {
			if (!wind_get(magictop, WF_OWNER, &owner, &dummy, &dummy, &dummy))
				owner = -1;
		}
	} else
		owner = -1;

	/* Umschalten, wenn n”tig (und m”glich) */
	if ((ap_id == id) && (owner == id))
		return;

	if (top && (!notme || (id != tb.app_id))) {
		/* Alle Fenster der betroffenen Applikation ermitteln */
		above = -1;
		winds = win = 0;
		if (wind_get(win, WF_OWNER, &owner, &dummy, &above, &dummy)) {
			win = above;
			while (win > 0) {
				if (!wind_get(win, WF_OWNER, &owner, &dummy, &above, &dummy))
					break;
				if (owner == id)
					windows[winds++] = win;
				if (winds == 256)
					break;
				win = above;
			}
		}
	}

	if (tb.sys & SY_MAGX) {
		if (tb.scr_id >= 0) {
			aesmsg[0] = 101; /* Special-Event fuer den MagiC-Screen-Manager */
			aesmsg[1] = tb.app_id;
			aesmsg[2] = 0;
			aesmsg[3] = 0;
			aesmsg[4] = 'MA';
			aesmsg[5] = 'GX';
			aesmsg[6] = 2; /* Unterfunktion: Menueleiste umschalten */
			aesmsg[7] = id; /* ID des Eigentuemers */
			appl_write(tb.scr_id, 16, aesmsg);
		}
	} else
		appl_control(id, 12, 0L);

	/* Bei Bedarf jetzt alle Fenster toppen */
	if (top && (!notme || (id != tb.app_id))) {
		for (win = 0; win < winds; win++) {
			aesmsg[0] = WM_TOPPED;
			aesmsg[1] = tb.app_id;
			aesmsg[2] = 0;
			aesmsg[3] = windows[win];
			appl_write(id, 16, aesmsg);
		}
	}
}

/**
 * Screen2Buffer
 *
 * Kopiert einen anzugebenen Bildschirmbereich in einen Puffer oder
 * restauriert einen Bildschirmbereich wieder. Schachtelbar.
 *
 * Eingabe:
 * x, y, w, h: Koordinaten des Bildschirmbereichs
 * flag: TRUE  - Screen -> Buffer
 *       FALSE - Buffer -> Screen
 *
 * Rueckgabe:
 * FALSE: Kein Speicher mehr frei (bei flag == TRUE) oder kein
 *        zurueckzukopierender Puffer vorhanden (flag == FALSE)
 * TRUE: Alles OK. Nur dann darf nach flag == TRUE ein Aufruf
 *       mit flag == FALSE folgen
 */
short Screen2Buffer(short x, short y, short w, short h, short flag) {
	short pxy[8];
	long msize;
	static count = 0;
	static MFDB buffers[MAX_BUFFERS];

	if (flag == FALSE) {
		if (!count)
			return (FALSE);
		else
			count--;
	} else {
		if (count == MAX_BUFFERS)
			return (FALSE);
	}

	if (x < 0) {
		w += x;
		x = 0;
	}
	if (y < 0) {
		h += y;
		y = 0;
	}
	if ((x + w) > tb.resx)
		w = tb.resx - x;
	if ((y + h) > tb.resy)
		h = tb.resy - y;
	buffers[count].fd_w = w;
	buffers[count].fd_h = h;
	buffers[count].fd_wdwidth = w >> 4;
	if ((w & 0xf) != 0)
		buffers[count].fd_wdwidth++;

	buffers[count].fd_stand = 0;
	buffers[count].fd_nplanes = tb.planes;
	buffers[count].fd_r1 = 0;
	buffers[count].fd_r2 = 0;
	buffers[count].fd_r3 = 0;

	if (flag == TRUE) {
		msize = (long) buffers[count].fd_wdwidth * 2L * (long) h * (long) tb.planes;
		buffers[count].fd_addr = malloc(msize);
		if (!buffers[count].fd_addr)
			return (FALSE);

		pxy[0] = x;
		pxy[1] = y;
		pxy[2] = pxy[0] + w - 1;
		pxy[3] = pxy[1] + h - 1;
		pxy[4] = 0;
		pxy[5] = 0;
		pxy[6] = w - 1;
		pxy[7] = h - 1;
	} else {
		pxy[0] = 0;
		pxy[1] = 0;
		pxy[2] = w - 1;
		pxy[3] = h - 1;
		pxy[4] = x;
		pxy[5] = y;
		pxy[6] = pxy[4] + w - 1;
		pxy[7] = pxy[5] + h - 1;
	}

	graf_mouse(M_OFF, 0L);
	if (flag == TRUE) {
		vro_cpyfm(v_handle, S_ONLY, pxy, &scr_mfdb, &buffers[count]);
		count++;
	} else {
		vro_cpyfm(v_handle, S_ONLY, pxy, &buffers[count], &scr_mfdb);
		free(buffers[count].fd_addr);
	}
	graf_mouse(M_ON, 0L);

	return (TRUE);
}

/**
 * grf_ghostbox
 *
 * Zeichnet einen "Geisterrahmen", also einen Linienzug aus
 * gepunkteten Linien.
 *
 * Eingabe:
 * pxy: Zeiger auf ein Array mit den x/y-Koordinaten der Eckpunkte
 * n: Anzahl der Koordinatenpaare in pxy
 */
void grf_ghostbox(short *pxy, short n) {
	short i, vert, swap, style, x1, x2, y1, y2, xy[4];

	vswr_mode(tb.vdi_handle, MD_XOR);
	vsl_type(tb.vdi_handle, 7); /* LT_USERDEF */
	vsl_ends(tb.vdi_handle, 0, 0); /* LE_SQUARED */
	vsl_width(tb.vdi_handle, 1);
	vsl_color(tb.vdi_handle, G_BLACK);
	for (i = 0; i < (n - 1); i++) {
		x1 = pxy[i * 2];
		x2 = pxy[i * 2 + 2];
		y1 = pxy[i * 2 + 1];
		y2 = pxy[i * 2 + 3];
		swap = vert = 0;
		style = 0xaaaa;
		if (y1 != y2) {
			/* Vertikale Linie */
			vert = 1;
			if (y1 > y2)
				swap = 2;
		} else {
			/* Horizontale Linie */
			if (x1 > x2)
				swap = 2;
		}
		xy[0 + swap] = x1;
		xy[1 + swap] = y1;
		xy[2 - swap] = x2;
		xy[3 - swap] = y2;
		if (vert) {
			if ((xy[0] & 1) == (xy[1] & 1))
				style = 0x5555;
		} else {
			if (!(xy[1] & 1))
				style = 0x5555;
		}
		vsl_udsty(tb.vdi_handle, style);
		v_pline(tb.vdi_handle, 2, xy);
	}
	vswr_mode(tb.vdi_handle, MD_REPLACE);
	vsl_type(tb.vdi_handle, 0); /* LT_SOLID */
}

/**
 * grf_dragbox
 *
 * Wie graf_dragbox, allerdings tastaturbedienbar und auch mit nicht
 * gedrueckter Maustaste aufrufbar.
 *
 * Eingabe:
 * w/h: Ausmaže der zu plazierenden Box
 * bx/by/bw/bh: Koordinaten und Ausmaže der begrenzenden Box
 * sx/sy: Startkoordinaten (-1 fuer jeweils aktuelle Mausposition)
 * dx/dy: Zeiger auf Zielkoordinaten
 *
 * Rueckgabe:
 * 0: Fehler aufgetreten
 * sonst: Alles OK, Zielkoordinaten in *dx und *dy abgelegt.
 */
short grf_dragbox(short w, short h, short bx, short by, short bw, short bh, short sx, short sy,
		short *dx, short *dy) {
	EVENT event;
	short lx, ly, xy[10], key, d, done = 0;

	if ((w <= 0) || (h <= 0) || (bx < 0) || (by < 0) || (bw <= 0) || (bh <= 0) || (w > bw) || (h > bh)) {
		return (0);
	}
	wind_update( BEG_UPDATE);
	wind_update( BEG_MCTRL);
	graf_mouse(FLAT_HAND, 0L);
	xy[0] = tb.desk.g_x;
	xy[1] = tb.desk.g_y;
	xy[2] = tb.desk.g_x + tb.desk.g_w - 1;
	xy[3] = tb.desk.g_y + tb.desk.g_h - 1;
	vs_clip(tb.vdi_handle, 1, xy);
	event.ev_mflags = MU_TIMER;
	event.ev_mtlocount = 1;
	event.ev_mthicount = 0;
	EvntMulti(&event);
	if (event.ev_mmobutton & 1)
		event.ev_mbstate = 0;
	else
		event.ev_mbstate = 1;
	if (sx < 0)
		sx = event.ev_mmox;
	if (sy < 0)
		sy = event.ev_mmoy;
	event.ev_mflags = MU_KEYBD | MU_BUTTON | MU_M1 | MU_TIMER;
	event.ev_mbclicks = 1;
	event.ev_bmask = 3;
	event.ev_mm1x = event.ev_mmox;
	event.ev_mm1y = event.ev_mmoy;
	event.ev_mm1width = 1;
	event.ev_mm1height = 1;
	event.ev_mm1flags = 1;
	lx = ly = -1;
	while (!done) {
		EvntMulti(&event);
		event.ev_mflags &= ~MU_TIMER;
		if (event.ev_mwich & MU_M1) {
			sx = event.ev_mm1x = event.ev_mmox;
			sy = event.ev_mm1y = event.ev_mmoy;
		}
		if ((event.ev_mwich & MU_KEYBD) && (lx != -1)) {
			key = normkey(event.ev_mmokstate, event.ev_mkreturn);
			key &= ~(NKF_RESVD | NKF_CAPS | NKF_CTRL | NKF_ALT);
			if ((key & NKF_LSH) || (key & NKF_RSH))
				key |= NKF_SHIFT;
			switch (key) {
			case NKF_FUNC | NK_UP:
				sy = ly - 16;
				break;
			case NKF_FUNC | NK_UP | NKF_SHIFT:
				sy = ly - 1;
				break;
			case NKF_FUNC | NK_DOWN:
				sy = ly + 16;
				break;
			case NKF_FUNC | NK_DOWN | NKF_SHIFT:
				sy = ly + 1;
				break;
			case NKF_FUNC | NK_LEFT:
				sx = lx - 16;
				break;
			case NKF_FUNC | NK_LEFT | NKF_SHIFT:
				sx = lx - 1;
				break;
			case NKF_FUNC | NK_RIGHT:
				sx = lx + 16;
				break;
			case NKF_FUNC | NK_RIGHT | NKF_SHIFT:
				sx = lx + 1;
				break;
			case NKF_FUNC | NKF_NUM | NK_ENTER:
			case NKF_FUNC | NKF_NUM | NK_ENTER | NKF_SHIFT:
			case NKF_FUNC | NK_RET:
			case NKF_FUNC | NK_RET | NKF_SHIFT:
				done = 1;
				break;
			}
		}
		if (event.ev_mwich & MU_BUTTON)
			done = 1;
		if (sx < bx)
			sx = bx;
		if (sy < by)
			sy = by;
		if ((sx + w) > (bx + bw))
			sx = bx + bw - w;
		if ((sy + h) > (by + bh))
			sy = by + bh - h;
		if ((sx != lx) || (sy != ly)) {
			graf_mouse(M_OFF, 0L);
			if (lx != -1)
				grf_ghostbox(xy, 5);
			xy[0] = sx;
			xy[1] = sy;
			xy[2] = sx + w - 1;
			xy[3] = sy;
			xy[4] = xy[2];
			xy[5] = sy + h - 1;
			xy[6] = sx;
			xy[7] = xy[5];
			xy[8] = sx;
			xy[9] = sy;
			grf_ghostbox(xy, 5);
			graf_mouse(M_ON, 0L);
			lx = sx;
			ly = sy;
		}
	}
	evnt_button(1, 3, 0, &d, &d, &d, &d);
	*dx = sx;
	*dy = sy;
	graf_mouse(M_OFF, 0L);
	grf_ghostbox(xy, 5);
	graf_mouse(M_ON, 0L);
	graf_mouse(ARROW, 0L);
	wind_update( END_MCTRL);
	wind_update( END_UPDATE);
	return (1);
}

/**
 * _v_opnvwk
 *
 * Spezielles v_opnvwk, das einen Fehler im TrueColor-Modus des
 * NOVA-VDI umgeht.
 *
 * Eingabe:
 * wie bei v_opnvwk()
 */
void _v_opnvwk(short *work_in, short *handle, short *work_out) {
#ifdef NOVA_PATCH
	short i, aes_handle, rgb[3];

	aes_handle = *handle;
#endif
	v_opnvwk(work_in, handle, work_out);
#ifdef NOVA_PATCH
	if (*handle != 0) {
		for (i = 0; i < 16; i++) {
			vq_color(aes_handle, i, 1, rgb);
			vs_color(*handle, i, rgb);
		}
	}
#endif
}

/**
 */

#define AES_PARAMS(a,b,c,d,e) \
	static short    aes_control[AES_CTRLMAX]={a,b,c,d,e}; \
	short			aes_intin[AES_INTINMAX];			  \
	short			aes_intout[AES_INTOUTMAX];			  \
	long			aes_addrin[AES_ADDRINMAX];			  \
	long			aes_addrout[AES_ADDROUTMAX];		  \
 														  \
	AESPB aes_params;									  \
  	aes_params.control = &aes_control[0];				  \
  	aes_params.global  = &aes_global[0];				  \
  	aes_params.intin   = &aes_intin[0]; 				  \
  	aes_params.intout  = &aes_intout[0];				  \
  	aes_params.addrin  = &aes_addrin[0];				  \
  	aes_params.addrout = &aes_addrout[0]

short EvntMulti( EVENT *evnt_data )
{
	AES_PARAMS ( 25, 16, 7, 1, 0 );
	
	aes_params.intin = (const short*)&evnt_data->ev_mflags;			/* input integer array */
	aes_params.intout = (short*)&evnt_data->ev_mwich;					/* output integer array */

	aes_addrin[0] = (long)evnt_data->ev_mmgpbuf;

	aes( &aes_params );

	return evnt_data->ev_mwich;

}

/**
 * appl_name
 *
 * Ermittelt - falls m”glich - den AES-Namen einer Applikation mit
 * gegebener ID.
 *
 * Eingabe:
 * id: AES-ID der gesuchten Applikation
 * deflt: Zu liefernder Name, wenn Applikationsname nicht ermittelt
 +        werden kann.
 *
 * Rueckgabe:
 * Zeiger auf statischen Puffer mit dem Applikationsnamen oder
 * deflt
 */
char *appl_name(short id, char *deflt) {
	char namebuf[9], *p;
	static char thename[9];
	short mode, type, theid;

	strcpy(thename, "");
	if (tb.sys & SY_ASEARCH) {
		mode = 0;
		while (appl_search(mode, namebuf, &type, &theid) == 1) {
			mode = 1;
			if (theid == id)
				strcpy(thename, namebuf);
		}
		if (*thename) {
			while ((p = strrchr(thename, ' ')) != NULL)
				*p = 0;
		}
	}
	if (*thename)
		return (thename);
	else
		return (deflt);
}

/**
 * appl_send
 *
 * Verschickt eine AES-Nachricht an eine Applikation.
 *
 * Eingabe:
 * id: AES-ID der Empfaengergerapplikation
 * message: Die zu verschickende Nachricht
 * pointers: Bitvektor, der angibt, welche Parameter Pointer sind.
 *        - PT34: par1 ist Pointer, par2 wird nicht beachtet
 *        - PT45: par2  "     "   , par3   "    "       "
 *        - PT56: par3  "     "   , par4   "    "       "
 *        - PT67: par4  "     "   , par5   "    "       "
 *        Natuerlich sind Kombinationen wie BV34|BV45 sinnlos!
 * par1 - par5: Die Parameter fuerr die Nachricht, die fuer msg[3] bis
 *              msg[7] eingesetzt werden. Siehe auch pointers.
 */
void appl_send(short id, short message, short pointers, long par1, long par2,
		long par3, long par4, long par5) {
	aesmsg[0] = message;
	aesmsg[1] = tb.app_id;
	aesmsg[2] = 0;
	aesmsg[3] = (short) par1;
	aesmsg[4] = (short) par2;
	aesmsg[5] = (short) par3;
	aesmsg[6] = (short) par4;
	aesmsg[7] = (short) par5;
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
 * calc_small_text_width
 *
 * Berechnet die Pixelbreite eines Textes im kleinen Systemzeichensatz.
 *
 * Eingabe:
 * text: Zeiger auf Text
 *
 * Rueckgabe:
 * Breite von text in Pixeln
 */
short calc_small_text_width(char *text) {
	short attr[10], dim[8], d;

	if (!*text)
		return (0);
	vqt_attributes(tb.vdi_handle, attr);
	vst_font(tb.vdi_handle, tb.fs_id);
	vst_height(tb.vdi_handle, tb.fs_size, &d, &d, &d, &d);
	vst_effects(tb.vdi_handle, 0);
	vqt_extent(tb.vdi_handle, text, dim);
	vst_font(tb.vdi_handle, attr[0]);
	vst_height(tb.vdi_handle, attr[7], &d, &d, &d, &d);
	return (dim[2] - dim[0]);
}

/**
 * win_update
 *
 * Setzt eine der beiden wind_update()-Semaphoren. Unter Systemem,
 * die den "check and set"-Modus verstehen, wird dieser benutzt
 * und ein eventueller Misserfolg gemeldet.
 *
 * Eingabe:
 * mode: Zu setzende Semaphore (BEG_UPDATE oder BEG_MCTRL)
 *
 * Rueckgabe:
 * 1: Semaphore erfolgreich gesetzt
 * 0: Semaphore konnte nicht gesetzt werden
 */
short win_update(short mode) {
	if (tb.sys & SY_WUPDATE)
		return (wind_update(mode | 0x100));
	wind_update(mode);
	return (1);
}

/* EOF */
