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
 APP.C

 Thing
 Applikationen
 =========================================================================*/

#include "..\include\globdef.h" 
#include "..\include\types.h"
#include "rsrc\thing.h"
#include "rsrc\thgtxt.h"
#include <errno.h>

#ifdef __MINT__
#include <basepage.h>
extern BASEPAGE *_base;
#define _BasPag	_base
#endif

/* FÅr Bereitstellung des Desktop-Hintergrundes beim Programmstart
 unter Single-TOS ohne Auslagerung */

OBJECT ldesk;
USERBLK lusr;

/*-------------------------------------------------------------------------
 app_start()

 Startet eine Applikation
 -------------------------------------------------------------------------*/

/**
 * FÅr Single-TOS
 */
void res_free(void) {
	free_wopen(&glob.openwin);
}

/**
 *
 */
short res_exit(char *appname) {
	WINOPEN *wopen, *wopen1;
	WININFO *win;
	W_PATH *wpath;
	W_GRP *wgrp;
	short d;

	/* Registrierung */
	if ((glob.openwin = (WINOPEN *) pmalloc(sizeof(WINOPEN))) != 0L) {
		glob.openwin->next = 0L;
		glob.openwin->class = WCDUMMY;
	} else {
		res_free();
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return (0);
	}
	wopen1 = glob.openwin;

	/* Offene Fenster merken */
	win = tb.win;
	while (win) {
		/* Dialogfenster nicht merken! */
		if (win->class != WCDIAL) {
			/* Neuen Eintrag an die Open-Liste anhaengen */
			wopen = pmalloc(sizeof(WINOPEN));
			if (!wopen) {
				res_free();
				frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
				return 0;
			} else {
				wopen1->next = wopen;
				wopen1 = wopen;
				wopen1->next = 0L;
			}
			wopen->class = win->class;
			wopen->num = -1;
			if (win == tb.topwin)
				wopen->istop = 1;
			else
				wopen->istop = 0;
			wind_get(win->handle, WF_HSLIDE, &wopen->sh, &d, &d, &d);
			wind_get(win->handle, WF_VSLIDE, &wopen->sv, &d, &d, &d);

			switch (win->class) {
			case WCPATH:
				wpath = (W_PATH *)win->user;
				strcpy(wopen->title, wpath->path);
				strcpy(wopen->wildcard, wpath->index.wildcard);
				wopen->rel = wpath->rel;
				strcpy(wopen->relname, wpath->relname);
				wopen->text = wpath->index.text;
				wopen->sortby = wpath->index.sortby;
				wopen->num = wpath->num;
				break;
			case WCGROUP:
				wgrp = (W_GRP *)win->user;
				strcpy(wopen->title, wgrp->name);
				wopen->wildcard[0] = 0;
				wopen->text = wgrp->text;
				break;
			}
		}
		win = win->next;
	}

	/* Fenster schliessen */
	while (tb.win) {
		tb.topwin = tb.win;
		dl_closewin();
	}

	/* Menues und Desktop abmelden */
	ldesk.ob_next = 0;
	ldesk.ob_head = -1;
	ldesk.ob_tail = -1;
	ldesk.ob_type = G_USERDEF;
	ldesk.ob_flags = LASTOB;
	ldesk.ob_state = 0;
	ldesk.ob_spec.userblk = &lusr;
	ldesk.ob_x = tb.desk.g_x;
	ldesk.ob_y = tb.desk.g_y;
	ldesk.ob_width = tb.desk.g_w;
	ldesk.ob_height = tb.desk.g_h;
	lusr.ub_code = desk_usr;
	lusr.ub_parm = 0L;

	menu_bar(rs_trindex[MAINMENU], 0);

	/* Angemeldete Fenster rausschmeissen */
	while (glob.accwin)
		acwin_remove(glob.accwin);

	/* Angemeldete AV-Applikationen rausschmeissen */
	while (glob.avinfo)
		avp_remove(glob.avinfo);

	/* Bei den AES abmelden und Accessories rausschmeissen */
	menu_register(-1, appname);
	wind_update (BEG_UPDATE);
	wind_new();
  {
    unsigned short *ss;
    
    ss = (unsigned short *) &ldesk;
    wind_set(0, WF_NEWDESK, ss[0], ss[1], ROOT, d);
  }
	form_dial(FMD_FINISH, tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h, tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h);
	appl_exit();

	return (1);
}

/**
 *
 */
short res_init(void) {
  short d = 0;
  
	/* Bei den AES anmelden */
	tb.app_id = appl_init();
	if (tb.app_id < 0) {
		res_free();
		return (0);
	}

	/* Mauszeiger wiederherstellen */
	v_show_c(tb.vdi_handle, 0);
	graf_mouse(ARROW, 0L);
	graf_mouse(M_OFF, 0L);
	graf_mouse(M_ON, 0L);

	/* Letzten shel_write() annulieren */
	shel_write(0, 1, 0, "", "");

	/* Accessories rausschmeissen */
	wind_new();

	/* MenÅs und Desktop anmelden */
	menu_bar(rs_trindex[MAINMENU], 1);
  {
    unsigned short *ss;
    
    ss = (unsigned short *) rs_trindex[DESKTOP];
    wind_set(0, WF_NEWDESK, ss[0], ss[1], ROOT, d);
  }

	/* Gesicherte Fenster îffnen */
	{
		short otmp;

		otmp = glob.tmp;
		glob.tmp = 1;
		wind_restore(1);
		glob.tmp = otmp;
	}

	menu_register(-1, "THING   ");

	return (1);
}

/**
 * display_alert
 *
 * Formatiert den Warnungshinweis vor einem Programmstart und stellt
 * ihn dann als Alert da.
 *
 * Eingabe:
 * aptr: Zeiger auf die Infostruktur der Applikation
 *
 * RÅckgabe:
 * 0: Benutzer hat "Abbruch" gewÑhlt, Programm nicht starten
 * sonst: Benutzer hat Hinweis bestÑtigt, Programm starten
 */
static short display_alert(APPLINFO *aptr) {
	char *src, *dst, *p, copy[61];
	short cnt;

#define LINELEN	30

	strncpy(almsg, rs_frstr[ALDUMMY], 4);
	almsg[4] = 0;
	dst = almsg + 4;
	cnt = 0;
	src = copy;

	/*
	 * FÑlle:
	 * 1. src paût noch vollstÑndig in die aktuelle Zeile
	 *    -> anhÑngen und fertig
	 * 2. Das nÑchste Wort von src paût vollstÑndig in die aktuelle Zeile
	 *    -> anhÑngen und src hinter das angehÑngten Wort setzen
	 * 3. Das nÑchste Wort von src paût nicht, ist aber nicht grîûer als
	 *    eine komplette Zeile
	 *    -> Zeile beenden und src nicht verÑndern
	 * 4. Das nÑchste Wort ist grîûer als eine Zeile oder es gibt kein
	 *    nÑchstes Wort
	 *    -> Zeile mit src auffÅllen und src dann auf den Rest setzen
	 */
	for (;;) {
		strcpy(copy, aptr->alert);
		while ((p = strpbrk(copy, "[|]")) != NULL) {
			switch (*p) {
			case '[':
				*p = '(';
				break;
			case '|':
				*p = '!';
				break;
			case ']':
				*p = ')';
				break;
			}
		}
		if ((cnt + strlen(src)) <= LINELEN) {
			/* Fall 1 */
			strcat(dst, src);
			break;
		}
		p = strpbrk(src, " ,.;:()-!?");
		if (p == NULL)
			p = strrchr(src, 0);
		p[1] = 0;
		if ((cnt + strlen(src)) <= LINELEN) {
			/* Fall 2 */
			strcat(dst, src);
			cnt += (short) strlen(src);
			src = p + 1;
			continue;
		}
		if (strlen(src) <= LINELEN) {
			/* Fall 3 */
			strcat(dst, "|");
			cnt = 0;
			continue;
		}
		/* Fall 4 */
		strncat(dst, src, LINELEN - cnt);
		strcat(dst, "|");
		src += LINELEN - cnt;
	}
	strcat(dst, rs_frstr[ALDUMMY] + 4);
	return (frm_alert(2, almsg, altitle, conf.wdial, 0L) == 1);
}

/**
 * run_conwin
 *
 * Startet ein Programm - falls mîglich - in der Thing-Console
 *
 * Eingabe:
 * aptr: Zeiger auf den Infoblock des zu startenden Programms
 * cmd: Zeiger auf die Kommandozeile
 * argv: ARGV-ParameterÅbergabe verwenden ja/nein (1/0)
 * env: Zeiger auf das Applikationsenvironment oder 0L
 * oldenv: Zeiger auf das alte Envrionment von Thing
 * copen: Console-Fenster ist schon auf ja/nein (1/0)
 *
 * RÅckgabe:
 * 0: Programm konnte nicht gestartet werden, Funktion abbrechen
 * 1: Programm wurde erfolgreich gestartet
 * -1: Programm nicht gestartet, ohne TOS2GEM nochmal probieren
 */
short run_conwin(APPLINFO *aptr, char *cmd, short argv, char *env, char *oldenv,
		short copen) {
	short aret, cret;
	char *abuf;
	long pret;

	aret = 0;
	cret = cwin_open();
	pret = 0L;
	switch (cret) {
	case 1:
		cwin_startio();
		if (argv) {
			abuf = app_argv(&cmd[1], aptr->startname, aptr->unixpaths);
			if (!abuf) {
				printf("%s\n", rs_frstr[TXNOARGVMEM]);
				fflush (stdout);
				aret = 0;
				pret = -39L;
			}
			cmd[0] = 0x7f;
		} else
			abuf = 0L;
		if (!pret) {
			pret = Pexec(0, aptr->startname, cmd, abuf);
			if (pret == 0L)
				aret = 1;
			else
				aret = 0;
			if (abuf)
				pfree(abuf);
			printf("%s\n", rs_frstr[TXTOSTERM]);
		}
		fflush (stdout);
		if (aptr->toswait && (pret == 0L) && !copen) {
			printf("%s\n", rs_frstr[TXTOSWAIT]);
			fflush(stdout);
			con.tos2gem->switch_output();
			con.tos2gem->switch_output();
			key_clr();
			evnt_keybd();
		}
		cwin_endio();
		graf_mouse(ARROW, 0L);
		clr_drv();
		if (!copen && conf.autocon && (pret == 0L))
			cwin_close();
		pfree(cmd);
		if (env) {
			pfree(env);
			_BasPag->p_env = oldenv;
		}
		/* Hier ein CH_EXIT schicken, damit die Verzeichnisse
		 aktualisiert werden */
		appl_send(tb.app_id, CH_EXIT, 0, 0, 0, 0, 0, 0);
		return(aret);
	case 0:
		sprintf(almsg, rs_frstr[ALCONRUN], aptr->title);
		if (frm_alert(1, almsg, altitle, conf.wdial, 0L) != 1) {
			graf_mouse(ARROW, 0L);
			clr_drv();
			pfree(cmd);
			if (env) {
				pfree(env);
				_BasPag->p_env = oldenv;
			}
			return (aret);
		}
		break;
	}
	return (-1);
}

/**
 * run_app
 *
 * Startet eine Applikation unter einem Multitaskingsystem nach.
 *
 * Eingabe:
 * aptr: Zeiger auf den Infoblock des zu startenden Programms
 * cmd: Zeiger auf die Kommandozeile
 * is_gr: GEM-Applikation ja/nein (1/0)
 * argv: ARGV-ParameterÅbergabe verwenden ja/nein (1/0)
 * doex: Zu benutzender shel_write()-Modus fÅr AES 4.x
 * mpar: Zeiger auf den shel_write()-Parameterblock
 * env: Zeiger auf das Applikationsenvironment oder 0L
 *
 * RÅckgabe:
 * 0: Fehler beim Aufruf des Programms
 * >0: Applikations-ID des neuen Programms
 * -1: Programm als MagiC-Overlay starten
 * -2: Programm als MultiTOS-Overlay starten
 */
short run_app(APPLINFO *aptr, char *cmd, short is_gr, short argv, short doex,
		char *mpar, char *env) {
	char *argvenv, *oldenv;
	short ret = 0;

	if (aptr->overlay || conf.texit) {
		if (tb.sys & SY_MSHELL)
			return (-1);
		else {
			if (is_gr && !(tb.sys & SY_MAGX))
				return (-2);
		}
	}
	if (argv) {
		cmd[0] = 0x7f;
		doex |= 0x800;
		argvenv = app_argv(&cmd[1], *(char **) mpar, aptr->unixpaths);
		if (argvenv == 0L)
			return(0);
		oldenv = _BasPag->p_env;
		_BasPag->p_env = ((char **) mpar)[4] = argvenv;

		/* ARGV unter MagiC ist vermutlich noch nicht endgÅltig! */
		if (tb.sys & SY_MAGX)
			ret = shel_write(doex, is_gr, SHW_PARALLEL, mpar, cmd);
		else
			ret = shel_write(doex, is_gr, 1, mpar, cmd);
		_BasPag->p_env = oldenv;
		pfree(argvenv);
	} else {
		if (tb.sys & SY_MAGX) {
			/* 'Trick 17' fÅr Environment-Vererbung mit MagiC!3 */
			if (glob.argv && (env || mpar[1]))
				ret = shel_write(doex, is_gr, SHW_PARALLEL, mpar, cmd);
			else
				ret = shel_write(1, is_gr, SHW_PARALLEL, aptr->startname, cmd);
		} else
			ret = shel_write(doex, is_gr, SHW_IMMED, mpar, cmd);
	}
	return (ret);
}

short app_start(APPLINFO *appl, char *parm, char *apath, short *rex) {
	short argv, exist;
	char *cmd, *path, name[MAX_FLEN], appname[9];
	char *abuf, acmd[2], *ps;
	long mpar[5];
	char *mpath;
	short is_gr, p, app, cmdlen;
#if 0
	short drv;
#endif
	short done, ret, atype, aret;
	char title[80];
	long ldummy;
	char *spec, *pipname;
	short copen;
	XATTR xattr;
	OBJECT *objectTree;
	short doex;
	/* FÅr Auslagerung von Thing */
	FILE *rfh;
	short multi;
	short has_wdef = 0, d;
	char *rname, *rcmd;
	/* FÅr TOSRUN */
	short trunok;
	long trunfd;
	char *trunbuf;
	/* FÅr Auswertung ausstehender shel_write()s unter Single-TOS */
	char scmd[256], stail[256];
	APPLINFO sappl;
	/* FÅr lokales Environment */
	short i, euse;
	char *env, *oldenv;
	/* FÅr indirekten Start Åber Datei */
	APPLINFO *aptr, iappl;
	/* FÅr "Abschneiden" der Pfade bei Parametern */
	char *src, *dst;
#if 0
	char *backslash;
#endif
	static char *dupparm = 0L;

	path = pmalloc(MAX_PLEN * 4L);
	if (path == NULL) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return 0;
	}
	mpath = path + MAX_PLEN;
	rname = mpath + MAX_PLEN;
	rcmd = rname + MAX_PLEN;

	acmd[0] = 127;
	acmd[1] = 0; /* Dummy-Commandozeile */

	/* Erst prÅfen, ob es eine zustÑndige Applikation gibt - evtl.
	 handelt es sich ja um eine Datei */
#if 0
	if(!is_app(appl->name,0))
	{
#endif
	aptr = app_match(0, appl->name, &trunok);
	/* Applikation vorhanden, dann indirekter Start */
	if (trunok && aptr) {
		memcpy(&iappl, aptr, sizeof(APPLINFO));
		strcpy(iappl.parm, appl->name);
		aptr = &iappl;
	} else
		aptr = appl;
#if 0
}
else aptr=appl;
#endif

	if (aptr->fullcompare || !aptr->startname[0])
		strcpy(aptr->startname, aptr->name);
	full2comp(aptr->startname, path, name);

	/* Startverzeichnis ermitteln */
	if (aptr->homepath != 1) {
		/* Aktuelles Verzeichnisfenster oder angegebener Pfad */
		if (tb.topwin && (!apath || aptr->homepath == 2)) {
			if (tb.topwin->class == WCPATH)
				apath = ((W_PATH *) tb.topwin->user)->path;
		}
	}
	if ((aptr->homepath == 1) || !apath) {
		/* Verzeichnis ist Pfad der Applikation */
		apath = path;
	}
	/*
	 * Wenn keine vollen Pfade Åbergeben werden sollen, Dateinamen
	 * extrahieren
	 */
	if (!aptr->fullpath) {
		if (!dupparm) {
			if ((dupparm = pmalloc(MAX_CMDLEN)) == 0L) {
				frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
				pfree(path);
				return 0;
			}
		}
		for (src = dst = parm; *src == *dst; src++)
			;
	}

	*rex = 0; /* Flag fÅr zwischenzeitliche 'Teilauslagerung' */

	/* Applikations-ID ermitteln */
	p = 0;
	while (name[p] != '.' && p < 8)
		p++;
	while (p < 8) {
		name[p] = ' ';
		p++;
	}
	name[p] = 0;
	strupr(name);
	/* Applikations-ID ermitteln */
	app = appl_find(name);
	strcpy(appname, name);
	/* Falls eigene ID, dann unter Multitasking abbrechen! */
	if (tb.app_id == app) {
		if (tb.sys & SY_MULTI) {
			frm_alert(1, rs_frstr[ALDOUBLE], altitle, conf.wdial, 0L);
			pfree(path);
			return 0;
		} else
			app = -1; /* Bei Single-Tasking ID ignorieren, da ungÅltig */
	}
	/* Leerzeichen abschneiden */
	for (p = 7; (name[p] == ' ') && (p >= 0); name[p--] = 0)
		;

	graf_mouse(BUSYBEE, 0L);
	/* Falls Programm noch nicht aktiv, dann angegebene Programmdatei
	 prÅfen. Falls sie nicht existiert oder gar keine Datei ist, dann
	 gleich raus */
	if (app < 0) {
		/* Bei Bedarf Warnalert ausgeben und Start ggf. abbrechen */
		if (aptr->alert[0] && !display_alert(aptr)) {
			graf_mouse(ARROW, 0L);
			pfree(path);
			return (0);
		}

		exist = !file_exists(aptr->startname, 1, &xattr);
		if (exist && ((xattr.mode & S_IFMT) != S_IFREG))
			exist = 0;
		if (!exist) {
			graf_mouse(ARROW, 0L);
			sprintf(almsg, rs_frstr[ALAPPFIND], name);
			frm_alert(1, almsg, altitle, conf.wdial, 0L);
			pfree(path);
			return (0);
		}
	}

	/* Lokalen Buffer fÅr Kommandozeile einrichten */
	cmd = pmalloc(MAX_CMDLEN + MAX_CLEN);
	if (!cmd) {
		graf_mouse(ARROW, 0L);
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		pfree(path);
		return (0);
	}

	/* Falls vorhanden, dann lokales Environment aufbauen */
	euse = 0;
	env = oldenv = 0L;
	if (aptr->euse) {
		for (i = 0; i < 20 && !euse; i++)
			if (aptr->evar[i])
				euse = 1;
	}
	if (euse) {
		env = app_env(aptr);
		if (env) {
			oldenv = _BasPag->p_env;
			_BasPag->p_env = env;
		}
	}

	/* PrÅfen, ob Console schon auf ist, damit sie spÑter bei
	 Bedarf wieder geschlossen wird */
	if (con.win.state & WSOPEN)
		copen = 1;
	else
		copen = 0;

	/* GEM-Applikation oder TOS ? */
	atype = is_app(aptr->startname, xattr.mode);
	if (atype == 2 || atype == 3)
		is_gr = 0;
	else
		is_gr = 1;

	/* Kleiner Workaround fÅr Single-TOS - falls Applikation bereits
	 aktiv, dann muss es ein Acc sein */
	if (!(tb.sys & SY_MULTI) && app >= 0 && is_gr && atype != 6)
		atype = 4;

	/*
	 * Parameter bei GEM-Applikationen verwenden wenn Applikation noch nicht
	 * aktiv ist oder fÅr einen indirekten Start benîtigt wird,  wenn ein
	 * Singletasking-System vorliegt, wenn es sich um ein TOS/TTP-
	 * Programm handelt oder wenn die Option "immer Åbergeben" gesetzt
	 * ist
	 */
	if (aptr->paralways
			|| (tb.sys & SY_MULTI && ((app <= 0) || (aptr == &iappl)))
			|| !(tb.sys & SY_MULTI) || !is_gr) {
		strcpy(&cmd[1], aptr->parm);
	} else
		cmd[1] = 0;

	if (strchr(&cmd[1], '$')) {
		/*
		 * Bei Dollar-Zeichen im Parameterstring die Kommandozeile mit
		 * Hilfe der Routine von Mario Becroft aufbauen, wenn Objekte
		 * Åbergeben wurden oder $d im Parameterstring vorkommt. Sonst
		 * nur Parameterstring bis zum ersten Dollarzeichen Åbernehmen.
		 */
		if (!*parm && (strstr(&cmd[1], "$d") == NULL))
			*strchr(&cmd[1], '$') = 0;
		else if (!build_commandline(&cmd[1], MAX_CMDLEN + MAX_CLEN - 1, aptr->parm, parm, apath)) {
			graf_mouse(ARROW, 0L);
			frm_alert(1, rs_frstr[ALCMDLINE], altitle, conf.wdial, 0L);
			pfree(cmd);
			if (env) {
				pfree(env);
				_BasPag->p_env = oldenv;
			}
			pfree(path);
			return (0);
		}
	} else {
		/* öbergebene Parameter eintragen */
		if (parm[0]) {
			if (cmd[1])
				strcat(&cmd[1], " ");
			strcat(&cmd[1], parm);
		}
	}

	/* Parameter ggf. vorher abfragen */
	if (aptr->getpar && !parm[0]) {
		objectTree = rs_trindex[PARAM];
		/* Gesicherten Buffer verwenden oder bisherige Parameter */
		if (glob.gcmd[0])
			strcpy(objectTree[PATEXT].ob_spec.tedinfo->te_ptext, glob.gcmd);
		else
			strcpy(objectTree[PATEXT].ob_spec.tedinfo->te_ptext, &cmd[1]);

#ifdef DIRCH
		spec = getObjectText(objectTree, PATITLE);
		exist = PACANCEL;
		if (spec != NULL) {
			sprintf(title, spec, aptr->title);
			setObjectText(objectTree, PATITLE, title);
#else
		spec = objectTree[PATITLE].ob_spec.free_string;
		sprintf(title, spec, aptr->title);
		objectTree[PATITLE].ob_spec.free_string = title;
#endif
		graf_mouse(ARROW, 0L);
		frm_start(&fi_param, conf.wdial, conf.cdial, 1);
		done = 0;
		while (!done) {
			ret = frm_dial(&fi_param, &mevent);
			exist = fi_param.exit_obj;
			switch (exist) {
			case PAOK:
			case PACANCEL:
				done = 1;
				break;
			case PAHELP:
				show_help(fi_param.userinfo);
				frm_norm(&fi_param);
				break;
			case PATEXT:
				if (ret & 0x8000) {
					/* Dateiauswahl */
					strcpy(scmd, "");
					strcpy(stail, "X:\\*.*");
					stail[0] = tb.homepath[0];
					fselect(stail, scmd, &ret, rs_frstr[TXOBJSEARCH], 0, 500);
					if (ret == 1) {
						strcpy(rname, stail);
						ps = strrchr(rname, '\\');
						if (ps)
							strcpy(&ps[1], scmd);
						else
							strcat(rname, scmd);
						frm_edstring(&fi_param, PATEXT, rname);
						frm_redraw(&fi_param, PATEXT);
					}
				}
				break;
			}
		}
		fi_param.exit_obj = exist;
		frm_end(&fi_param);
		/*  msg_clr(); */
#ifdef DIRCH
		setObjectText(objectTree, PATITLE, spec);
	}
#else
		objectTree[PATITLE].ob_spec.free_string = spec;
#endif
		if (exist == PAOK) {
			graf_mouse(BUSYBEE, 0L);
			strcpy(&cmd[1], objectTree[PATEXT].ob_spec.tedinfo->te_ptext);
			/* Eingabe sichern */
			strcpy(glob.gcmd, &cmd[1]);
		} else {
			pfree(cmd);
			if (env) {
				pfree(env);
				_BasPag->p_env = oldenv;
			}
			pfree(path);
			return (0);
		}
	}

app_start1:
	cmdlen = (short) strlen(&cmd[1]);
	argv = 0;
	if ((cmdlen <= 124) && !has_quotes(&cmd[1]) && !aptr->unixpaths) {
		cmd[0] = (char) cmdlen;
	} else {
		/* Auf ARGV prÅfen und ggf. mosern */
		if ((tb.sys & SY_MULTI && app <= 0)
				|| (!(tb.sys & SY_MULTI) && atype != 4 && atype != 6)) {
			argv = 1;
			/* Jammern, falls shel_write() notwendig ist, aber das Multitasking-
			 System kein ARGV unterstÅtzt */
			if (tb.sys & SY_MULTI && !glob.argv
					&& ((aptr->conwin && (Getcookie('T2GM', &ldummy) != E_OK)
					&& conf.uset2g) || !aptr->conwin)) {
				pfree(cmd);
				if (env) {
					pfree(env);
					_BasPag->p_env = oldenv;
				}
				sprintf(almsg, rs_frstr[ALNOARGV], aptr->title);
				graf_mouse(ARROW, 0L);
				frm_alert(1, almsg, altitle, conf.wdial, 0L);
				pfree(path);
				return (0);
			}
		}
	}

	/* Aktuelles Verzeichnis setzen */set_dir(apath);

	/* Accessory/CPX ? */
	if (atype == 4 || atype == 6) {
		if (app >= 0 && atype != 6) {
			/* Accessory aktiv */
			call_acc:
			/* Accessory aufrufen */
			if (aptr->vaproto) {
				/* ParameterÅbergabe/Start mit AV-Protokoll */
				strcpy(aesbuf, &cmd[1]);
				/* Accessory ggf. auf QuotingfÑhigkeit prÅfen */
				if (!has_quotes(aesbuf) || avp_can_quote(app)) {
					appl_send(app, VA_START, PT34, (long) aesbuf, 0, 0, 0, 0);
					aret = 1;
				} else {
					sprintf(almsg, rs_frstr[ALNOQUOTE], aptr->title);
					frm_alert(1, almsg, altitle, conf.wdial, 0L);
					aret = 0;
				}
			} else {
				/* Accessory unterstÅtzt kein AV-Protokoll */
				if (cmd[1]) {
					/* ParameterÅbergabe nicht mîglich */
					sprintf(almsg, rs_frstr[ALNOVA], aptr->title);
					frm_alert(1, almsg, altitle, conf.wdial, 0L);
					aret = 0;
				} else {
					appl_send(app, AC_OPEN, 0, 0, 0, 0, 0, 0);
					aret = 1;
				}
			}
		} else {
			/* Accessory nicht aktiv oder eCPX */

			/* Wenn es ein Accessory ist, nach Mîglichkeit als solches starten */
			if (atype == 4) {
				if (tb.sys & SY_MAGX) {
					if (tb.magx->aesvars->version >= 0x400) {
						/* geht ab MagiC 4 */
						run_acc: if (conf.askacc) {
							sprintf(almsg, rs_frstr[ALACCFAIL], aptr->title, name, rs_frstr[TXINSTALLACC]);
							graf_mouse(ARROW, 0L);
							if (frm_alert(1, almsg, altitle, conf.wdial, 0L) != 1) {
								aret = 0;
								goto prog_loaded;
							}
						}
						aret = shel_write(3, 1, 0, aptr->startname, "\0");
						if (aret) {
							evnt_timer(1000L);
							if ((app = appl_find(appname)) >= 0)
								goto call_acc;
							else
								aret = 0;
						}
						sprintf(almsg, rs_frstr[ALACCLOAD], aptr->title, name);
						graf_mouse(ARROW, 0L);
						frm_alert(1, almsg, altitle, conf.wdial, 0L);
						goto prog_loaded;
					}
				} else {
					if (tb.sys & SY_AGI) {
						short max_shwr, du;

						if (appl_getinfo(10, &max_shwr, &du, &du, &du)) {
							max_shwr &= 0xff;
							if (max_shwr >= 3) /* oder wenn shel_write-Modus 3 vorhanden */
								goto run_acc;
						}
					}
				}
			}
			if (conf.askacc && atype == 4) {
				sprintf(almsg, rs_frstr[ALACCFAIL], aptr->title, name,
						rs_frstr[TXRUNACC]);
				graf_mouse(ARROW, 0L);
				if (frm_alert(1, almsg, altitle, conf.wdial, 0L) == 1) {
					graf_mouse(BUSYBEE, 0L);
					atype = 1;
					goto app_start1;
				}
			} else {
				if (atype == 4) {
					/* Accessory als Programm starten */
					atype = 1;
					goto app_start1;
				} else /* CPX mit shel_write() starten */
					aret = shel_write(1, 1, SHW_PARALLEL, aptr->startname, cmd);
			}
		}
		prog_loaded: clr_drv();
		pfree(cmd);
		if (env) {
			pfree(env);
			_BasPag->p_env = oldenv;
		}
		graf_mouse(ARROW, 0L);
		pfree(path);
		return (aret);
	} else {
		/* Nein - Programm */
		/* Multitasking-System */
		if (tb.sys & SY_MULTI) {
			/* Single-Mode unter MagiC */
			if (aptr->single && tb.sys & SY_MSHELL) {
				short mode;

				magic_overlay: mode = aptr->single ? SHW_SINGLE : SHW_CHAIN;
				/* ARGV unter MagiC!3 */
				if (argv)
					cmd[0] = 0xff;
				conf_save(1);
				if (mode != SHW_SINGLE)
					shel_write(1, is_gr, SHW_SINGLE, aptr->startname, cmd);
				if (!shel_write(1, is_gr, mode, aptr->startname, cmd)) {
					clr_drv();
					pfree(cmd);
					if (env) {
						pfree(env);
						_BasPag->p_env = oldenv;
					}
					pfree(path);
					return (0);
				} else {
					pfree(cmd);
					if (env) {
						pfree(env);
						_BasPag->p_env = oldenv;
					}
					main_exit();
					Pterm0();
				}
			} else {
				/* Parallel-Start */
				/* MultiTOS-Parameter setzen */
				mpath[0] = Dgetdrv() + 65;
				mpath[1] = ':';
				Dgetpath(&mpath[2], mpath[0] - 64);
				if (!mpath[2]) {
					mpath[2] = '\\';
					mpath[3] = 0;
				}

				mpar[0] = (long) aptr->startname; /* Programmname */
				mpar[1] = aptr->memlimit * 1024L; /* Psetlimit */
				mpar[2] = 0L; /* Prenice */
				mpar[3] = (long) mpath; /* Startverzeichnis */
				mpar[4] = (long) _BasPag->p_env; /* Environment */
				doex = env ? 0x0f01 : 0x0701;

				if (app >= 0) {
					/* Applikation aktiv */

					/* GEM-Applikation mit AV-Protokoll und Parameter vorhanden,
					 oder leeres VA_START durch Voreinstellung erlaubt? */
					if (is_gr && aptr->vaproto && (cmd[1] || conf.vastart)) {
						/* Ja */
						strcpy(aesbuf, &cmd[1]);
						/* Accessory ggf. auf QuotingfÑhigkeit prÅfen */
						if (!has_quotes(aesbuf) || avp_can_quote(app)) {
							appl_send(app, VA_START, PT34, (long) aesbuf, 0, 0, 0, 0);
							aret = 1;
						} else {
							sprintf(almsg, rs_frstr[ALNOQUOTE], aptr->title);
							frm_alert(1, almsg, altitle, conf.wdial, 0L);
							aret = 0;
						}
					} else {
						/* Nein - nachfragen und ggf. nochmal starten */
						aret = 0;
						sprintf(almsg, rs_frstr[ALSTART], aptr->title, name);
						if (frm_alert(1, almsg, altitle, conf.wdial, 0L) == 1) {
							if (!is_gr && aptr->conwin && conf.uset2g) {
								/* Im Console-Fenster */
								aret = run_conwin(aptr, cmd, argv, env, oldenv, copen);
								if (aret != -1) {
									pfree(path);
									return (aret);
								} else
									aret = 0;
							}

							/* Normal */

							/* Hier zur Sicherheit nochmal auf ARGV testen, falls
							 die Applikation eigentlich mit Pexec() gestartet werden
							 sollte, was aber nicht ging, weil das Console-Fenster
							 nicht verfÅgbar war */
							if (argv && !glob.argv) {
								sprintf(almsg, rs_frstr[ALNOARGV], aptr->title);
								graf_mouse(ARROW, 0L);
								frm_alert(1, almsg, altitle, conf.wdial, 0L);
								aret = 0;
							} else {
								aret = run_app(aptr, cmd, is_gr, argv, doex, (char *) mpar, env);
								if (aret == 0) {
									sprintf(almsg, rs_frstr[ALSTARTERR], aptr->title);
									graf_mouse(ARROW, 0L);
									frm_alert(1, almsg, altitle, conf.wdial, 0L);
								}
								else if (aret == -1)
									goto magic_overlay;
								else if (aret == -2) {
									multi = 1;
									goto thingrun;
								}
							}
						} else
							magx_switch(app, 1);
					}
				} else {
					/* Applikation nicht aktiv */
					if (!is_gr && aptr->conwin && conf.uset2g) {
						/* Im Console-Fenster */
						aret = run_conwin(aptr, cmd, argv, env, oldenv, copen);
						if (aret != -1) {
							pfree(path);
							return (aret);
						}
						aret = 0;
					}

					/* Normal */

					/* Hier zur Sicherheit nochmal auf ARGV testen, falls
					 die Applikation eigentlich mit Pexec() gestartet werden
					 sollte, was aber nicht ging, weil das Console-Fenster
					 nicht verfÅgbar war */
					if (argv && !glob.argv) {
						sprintf(almsg, rs_frstr[ALNOARGV], aptr->title);
						graf_mouse(ARROW, 0L);
						frm_alert(1, almsg, altitle, conf.wdial, 0L);
						aret = 0;
					} else {
						aret = run_app(aptr, cmd, is_gr, argv, doex, (char *) mpar, env);
						if (aret == 0) {
							sprintf(almsg, rs_frstr[ALSTARTERR], aptr->title);
							graf_mouse(ARROW, 0L);
							frm_alert(1, almsg, altitle, conf.wdial, 0L);
						}
						else if (aret == -1)
							goto magic_overlay;
						else if (aret == -2) {
							multi = 1;
							goto thingrun;
						}
					}
				}
			}
		} else {
			/* Singletasking-System */
			full2comp(aptr->startname, path, name);
			if (!conf.texit && !aptr->overlay) {
				/* Thing resident im Speicher halten */
				if (!is_gr && aptr->conwin && conf.uset2g) {
					/* Im Console-Fenster */
					aret = run_conwin(aptr, cmd, argv, env, oldenv, copen);
					if (aret != -1) {
						pfree(path);
						return (aret);
					} else
						aret = 0;
				}
				/* Kein Console-Fenster - TOS/TTP und evtl. MiNT & TOSRUN vorhanden? */
				trunok = 0;
				if (!is_gr && tb.sys & SY_MINT) {
					/* TOSWIN vorhanden? */
					app = appl_find("TOSWIN  ");
					if (app >= 0) {
						/* Jo */

						/* TOSWIN anwerfen */
						appl_send(app, AC_OPEN, 0, 0, 0, 0, 0, 0);
						/* TOSWIN etwas Bedenkzeit geben */
						evnt_timer(200L);
						/* Buffer fÅr Parameter reservieren */
						cmdlen = (short) strlen(aptr->startname) + 2 + (short) strlen(cmd);
						trunbuf = pmalloc((long) cmdlen);
						if (!trunbuf)
							frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
						else {
							/* Parameter eintragen */
							strcpy(trunbuf, path);
							strcat(trunbuf, " ");
							strcat(trunbuf, name);

							if (cmd[1]) {
								strcat(trunbuf, " ");
								strcat(trunbuf, &cmd[1]);
							}

							/* Pipe fÅr TOSRUN îffnen */
							pipname = "U:\\pipe\\tosrun";
							trunfd = Fopen(pipname, 2 /* FO_RW */);
							if (trunfd >= 0L) {
								/* Parameter in die Pipe schreiben */
								cmdlen = (short) strlen(trunbuf) + 1;
								if (Fwrite((short) trunfd, (long) cmdlen, trunbuf) == (long) cmdlen) {
									trunok = 1;
									aret = 1;
								}
								/* Pipe schlieûen */
								Fclose((short) trunfd);
							} else {
								if (!glob.toserr) {
									err_file(rs_frstr[ALFLCREATE], trunfd, pipname);
									glob.toserr = 1;
								}
							}
							/* Parameterbuffer freigeben */
							pfree(trunbuf);
						}
					}
				}
				/* Normal ... */
				if (!trunok) {
					if (res_exit(appname)) {
						*rex = 1; /* Flag setzen, damit in aufrufenden Prozeduren kein
						 Bezug mehr auf geîffnete Fenster genommen wird */
						/* AES Åber die Applikation informieren */
						aret = shel_write(1, is_gr, SHW_IMMED, aptr->startname, cmd);
						if (aret) {
							/* Bildschirm-Darstellung anpassen */
							if (is_gr) {
								/* Grafik-Applikation */
								objectTree = rs_trindex[DESKAPP];
								strcpy(objectTree->ob_spec.tedinfo->te_ptext, name);
								objectTree->ob_x = 0;
								objectTree->ob_y = 0;
								objectTree->ob_width = tb.desk.g_w;
								objectTree->ob_height = tb.desk.g_y - 1;
								objc_draw(objectTree, ROOT, MAX_DEPTH, 0, 0, tb.desk.g_w, tb.desk.g_y - 1);
							} else {
								/* Text-Applikation */
								v_hide_c(tb.vdi_handle);
								v_enter_cur(tb.vdi_handle);
								/* VT52-Zeilenumbruch einschalten */
								Cconws("\33v");
							}
							if (argv) {
								abuf = app_argv(&cmd[1], aptr->startname, aptr->unixpaths);
								if (!abuf)
									aret = 0;
								else {
									if (Pexec(0, aptr->startname, acmd, abuf) == 0L)
										aret = 1;
									else
										aret = 0;
									pfree(abuf);
								}
							} else if (Pexec(0, aptr->startname, cmd, 0L) == 0L)
								aret = 1;
							else
								aret = 0;

							/* Nach Ende TOS/TTP ggf. auf Taste warten */
							if (!is_gr) {
								if (aptr->toswait) {
									printf("%s\n", rs_frstr[TXTOSTERM]);
									printf("%s\n", rs_frstr[TXTOSWAIT]);
									fflush (stdout);
									key_clr();
									evnt_keybd();
								}
								v_exit_cur(tb.vdi_handle);
								v_show_c(tb.vdi_handle, 1);
							} else {
								/* Nach Ende GEM-Applikation ggf. noch ausstehende
								 shel_write() berÅcksichtigen */
								if (aret) {
									memcpy(&sappl, aptr, sizeof(APPLINFO));
									app_start2: ;
									if (shel_read(scmd, stail) != 0) {
										/* shel_write() zulÑssig? */
										if (strcmp(scmd, sappl.name) != 0) {
											/* Ok - dann jetzt starten */
											wind_update (BEG_UPDATE);
											wind_new();
										  {
										    unsigned short *ss;
										    
										    ss = (unsigned short *) &ldesk;
										    wind_set(0, WF_NEWDESK, ss[0], ss[1], ROOT, 0);
										  }
											form_dial(FMD_FINISH, tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h, tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h);
											strcpy(sappl.name, scmd);
											if (Pexec(0, scmd, stail, 0L) == 0L)
												aret = 1;
											else
												aret = 0;
											if (aret)
												goto app_start2;
											/* Und erneut abfragen */
										}
									}
								}
							}
						}

						if (!res_init()) {
							pfree(cmd);
							if (env) {
								pfree(env);
								_BasPag->p_env = oldenv;
							}
							Pterm0();
						}
					} else {
						graf_mouse(ARROW, 0L);
						clr_drv();
						pfree(cmd);
						if (env) {
							pfree(env);
							_BasPag->p_env = oldenv;
						}
						pfree(path);
						return 0;
					}
				}
			} else {
				/* Thing auslagern */
				multi = 0;
				thingrun: strcpy(rname, tb.homepath);
				strcat(rname, FNAME_RUN);
				strcpy(&rcmd[1], tb.homepath);
				strcat(&rcmd[1], FNAME_PAR);
				rfh = fopen(&rcmd[1], "w");
				if (multi)
					strcat(&rcmd[1], " -");
				rcmd[0] = (char) strlen(&rcmd[1]);
				if (!rfh) {
					frm_alert(1, rs_frstr[ALNOPAR], altitle, conf.wdial, 0L);
					graf_mouse(ARROW, 0L);
					clr_drv();
					pfree(cmd);
					if (env) {
						pfree(env);
						_BasPag->p_env = oldenv;
					}
					pfree(path);
					return 0;
				}
				fprintf(rfh, "%s%s\n", tb.homepath, FNAME_PRG);
				fprintf(rfh, "%d\n", is_gr);
				fprintf(rfh, "%s\n", path);
				fprintf(rfh, "%s\n", name);
				fprintf(rfh, "%s\n", &cmd[1]);
				path[0] = Dgetdrv() + 65;
				path[1] = ':';
				Dgetpath(&path[2], 0);
				fprintf(rfh, "%s\n", path);
				fprintf(rfh, "%d\n", aptr->toswait);
				fclose(rfh);
				conf_save(1);
				if (tb.sys & SY_AGI) {
					if (appl_getinfo(5, &d, &d, &d, &has_wdef) == 0)
						has_wdef = 0;
				}
				if (has_wdef)
					shel_wdef(FNAME_RUN, tb.homepath);
				else
					shel_write(1, 1, SHW_CHAIN, rname, rcmd);
				clr_drv();
				main_exit();
				pfree(cmd);
				if (env) {
					pfree(env);
					_BasPag->p_env = oldenv;
				}
				Pterm0();
			}
		}
	}
	graf_mouse(ARROW, 0L);
	clr_drv();
	pfree(cmd);
	if (env) {
		pfree(env);
		_BasPag->p_env = oldenv;
	}
	pfree(path);
	return (aret);
}

/**
 app_add()
 app_remove()

 Applikationen hinzufÅgen/entfernen
 -------------------------------------------------------------------------*/
APPLINFO *app_add(void) {
	APPLINFO *appl, *aptr;

	/* Speicher reservieren */
	appl = pmalloc(sizeof(APPLINFO));
	if (!appl)
		return (0L);

	/* Listenverkettung */
	appl->next = 0L;
	if (!desk.appl) {
		/* Liste bisher leer */
		desk.appl = appl;
		appl->prev = 0L;
	} else {
		/* An das Ende der Liste anhÑngen */
		aptr = desk.appl;
		while (aptr->next)
			aptr = aptr->next;
		aptr->next = appl;
		appl->prev = aptr;
	}
	appl->startname[0] = 0;
	return (appl);
}

void app_remove(APPLINFO *appl) {
	APPLINFO *aprev, *anext;
	short i;

	aprev = appl->prev;
	anext = appl->next;

	/* Aus der Liste entfernen */
	if (!aprev) {
		/* Kein VorgÑnger - dann erster Eintrag ! */
		desk.appl = anext;
		if (anext)
			anext->prev = 0L;
	} else {
		/* VorgÑnger vorhanden */
		aprev->next = anext;
		if (anext)
			anext->prev = aprev;
	}
	/* Reservierten Speicher freigeben */
	for (i = 0; i < 20; i++)
		if (appl->evar[i])
			pfree(appl->evar[i]);
	pfree(appl);
}

/**
 app_find()

 Applikations-Struktur anhand des Dateinamens suchen
 -------------------------------------------------------------------------*/
APPLINFO *app_find(char *name) {
	APPLINFO *aptr;
	char *name1, *name2, *name3, *path, *c1, *c2;
	short i;

	name1 = pmalloc(MAX_PLEN * 4L);
	if (name1 == NULL)
		return (0L); /* !!! Fehlermeldung? */
	name2 = name1 + MAX_PLEN;
	name3 = name2 + MAX_PLEN;
	path = name3 + MAX_PLEN;

	i = 0;
	while (name[i]) {
		name1[i] = nkc_toupper(name[i]);
		i++;
	}
	name1[i] = 0;

	if (!desk.appl) {
		pfree(name1);
		return 0L;
	}
	aptr = desk.appl;
	while (aptr) {
		if (aptr->fullcompare) {
			c1 = aptr->name;
			c2 = name1;
		} else {
			full2comp(aptr->name, path, name2);
			full2comp(name1, path, name3);
			c1 = name2;
			c2 = name3;
		}
		i = 0;
		while (c1[i]) {
			name2[i] = nkc_toupper(c1[i]);
			i++;
		}
		name2[i] = 0;
		if (!strcmp(c2, name2)) {
			if (!aptr->fullcompare)
				strcpy(aptr->startname, name);
			pfree(name1);
			return aptr;
		}
		aptr = aptr->next;
	}
	pfree(name1);
	return (0L);
}

/**
 app_get()

 Applikations-Struktur anhand des Titels ermitteln
 -------------------------------------------------------------------------*/
APPLINFO *app_get(char *title) {
	APPLINFO *aptr;

	if (!desk.appl)
		return 0L;
	aptr = desk.appl;
	while (aptr) {
		if (!strcmp(aptr->title, title)) {
			aptr->startname[0] = 0;
			return aptr;
		}
		aptr = aptr->next;
	}
	return (0L);
}

/**
 app_list()

 Erzeugt eine alphabetisch sortierte Liste alle Applikationen als
 Zeiger-Array

 Ergebnis: -1 = kein Speicher mehr frei
 0  = keine Applikation vorhanden
 >0 = Anzahl der Applikationen in der Liste (Liste muss dann
 mit pfree() freigegeben werden !)
 -------------------------------------------------------------------------*/
/* qsort fÅr app_list() */

void apl_qsort(APPLINFO **list, short left, short right) {
	short i, last;
	void apl_swap(APPLINFO **list, short i, short j);

	if (left >= right)
		return;

	apl_swap(list, left, (left + right) / 2);
	last = left;
	for (i = left + 1; i <= right; i++)
		if (strcmp(list[i]->title, list[left]->title) < 0)
			apl_swap(list, ++last, i);
	apl_swap(list, left, last);
	apl_qsort(list, left, last - 1);
	apl_qsort(list, last + 1, right);
}

void apl_swap(APPLINFO **list, short i, short j) {
	APPLINFO *temp;

	temp = list[i];
	list[i] = list[j];
	list[j] = temp;
}

APPLINFO **app_list(short *n) {
	short i;
	APPLINFO *appl, **list;

	/* Anzahl der Applikationen ermitteln */
	appl = desk.appl;
	*n = 1;
	while (appl) {
		appl = appl->next;
		*n += 1;
	};

	/* Falls Applikationen vorhanden, dann Liste fÅr Dateien anzeigen
	 einrichten */
	if (*n) {
		/* Speicher fÅr Liste reservieren */
		list = pmalloc(sizeof(APPLINFO *) * (long) *n);
		if (!list) {
			frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
			*n = -1;
			return 0L;
		}
		/* Textliste erzeugen */
		appl = desk.appl;
		i = 1;
		list[0] = &defappl;
		while (appl) {
			list[i] = appl;
			i++;
			appl = appl->next;
		}
		/* Liste nach Titeln sortieren */
		apl_qsort(&list[1], 0, *n - 2);
	} else
		list = 0L;

	return list;
}

/**
 app_opensel()

 Alle selektierten Objekte an eine bestimmte Applikation Åbergeben
 -------------------------------------------------------------------------*/
void app_opensel(APPLINFO *appl) {
	char *p;
	short rex;
	char apath[MAX_PLEN], aname[MAX_FLEN];

	rex = 0;
	apath[0] = 0;

	if (appl->usesel) {
		/* Nur, wenn die entsprechende Option gesetzt ist */
		if (!sel2buf(glob.cmd, aname, apath, MAX_CMDLEN)) {
			sprintf(almsg, rs_frstr[ALTOOMANY], appl->title);
			frm_alert(1, almsg, altitle, conf.wdial, 0L);
		} else {
			if (!apath[0])
				p = 0L;
			else
				p = apath;
			app_start(appl, glob.cmd, p, &rex);
		}
		if (!rex) {
			if (desk.sel.win) {
				switch (desk.sel.win->class) {
				case WCPATH:
					((W_PATH *)desk.sel.win->user)->amask[0] = 0;
					wpath_esel(desk.sel.win, 0L, 0, 0, 1);
					break;
				case WCGROUP:
					wgrp_esel(desk.sel.win, 0L, 0, 0);
					break;
				}
			} else
				icon_select(-1, 0, 0);
		}
	} else {
		/* Ohne Auswahl starten */
		glob.cmd[0] = 0;
		app_start(appl, glob.cmd, 0L, &rex);
	}
}

/**
 app_env()

 Erzeugt ein lokales Environment
 -------------------------------------------------------------------------*/
char *app_env(APPLINFO *appl) {
	char *env,*new;
	short elen, nlen, i, j, p, done;

	/* Grîûe des aktuellen Environments ermitteln */
	elen = 0;
	done = 0;
	env = _BasPag->p_env;
	while (!done) {
		/* Einen String holen */
		while (env[elen])
			elen++;
		elen++;
		/* Ende erreicht? */
		if (!env[elen])
			done = 1;
	}
	nlen = elen; /* Merken */

	/* Grîûe des zusÑtzlichen lokalen Environments */
	for (i = 0; i < MAX_EVAR; i++)
		if (appl->evar[i])
			nlen += (short) (strlen(appl->evar[i]) + 1);

	nlen++; /* Abschliessendes Nullbyte */

	/* Buffer fÅr neues Environment */
	new = pmalloc(nlen);
	if (!new) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return (0L);
	}
	p = 0;

	/* Lokales Environment kopieren */
	for (i = 0; i < MAX_EVAR; i++) {
		if (appl->evar[i]) {
			j = 0;
			while (appl->evar[i][j]) {
				new[p] = appl->evar[i][j];
				p++;
				j++;
			}
			new[p] = 0;
			p++;
		}
	}

	/* Globales Environment kopieren */
	for (j = 0; j < elen; j++) {
		new[p] = env[j];
		p++;
	}
	new[p] = 0;
	
	return (new);
}

/**
 app_argv()

 Erzeugt ein neues Environment fÅr die öbergabe von Parametern an
 ein Programm mit dem ARGV-Verfahren, dass mit Pexec() gestartet
 wird.
 -------------------------------------------------------------------------*/
static void insert_parm(char *dest, short *destidx, char *parm, short unixpaths) {
	short i;

	if (unixpaths) {
		if (wild_match1("[a-tA-Tv-zV-Z]:\\*", parm)) {
			dest[(*destidx)++] = '/';
			dest[(*destidx)++] = nkc_tolower(parm[0]);
			i = 2;
		} else if (wild_match1("U:\\*", parm))
			i = 2;
		else
			unixpaths = i = 0;
	} else
		unixpaths = i = 0;

	while (parm[i]) {
		dest[(*destidx)++] = (unixpaths && (parm[i] == '\\')) ? '/' : parm[i];
		i++;
	}
	dest[(*destidx)++] = 0;
}

char *app_argv(char *cmd, char *prog, short unixpaths) {
	char *env, *new;
	char parm[MAX_PLEN], *buf;
	short elen, nlen, p, done;

	/* Grîûe des aktuellen Environments ermitteln */
	elen = 0;
	done = 0;
	env = _BasPag->p_env;
	while (!done) {
		/* Einen String holen */
		while (env[elen])
			elen++;
		elen++;
		/* Ende erreicht? */
		if (!env[elen])
			done = 1;
	}
	nlen = elen; /* Merken */

	/* Grîûe fÅr ARGV-Buffer berechnen */
	nlen += 9; /* 'ARGV=1\0\0' und abschliessendes Doppelnullbyte */
	nlen += ((short) strlen(prog)) + 1; /* Programmname als argv[0] */
	nlen += ((short) strlen(cmd)) + 1; /* Parameter ab argv[1] */

	/* Buffer reservieren */
	new = pmalloc(nlen);
	if (!new) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return (0L);
	}

	/* Bisheriges Environment kopieren */
	memcpy(new, env, elen);

	/* ARGV-Buffer aufbauen */
	strcpy(&new[elen], "ARGV=1");
	p = elen + 7;

	/* argv[0] - Programmname */
	insert_parm(new, &p, prog, unixpaths);

	/* argv[1..n] */
	buf = cmd;
	while (get_buf_entry(buf, parm, &buf)) {
		insert_parm(new, &p, parm, unixpaths);
	}

	/* Abschluss des Environments */
	new[p] = 0;
	
	return (new);
}

/**
 app_match()

 Sucht anhand eines Dateinamens eine dafÅr zustÑndige Applikation
 und sorgt ggf. fÅr die Auswahl, falls es mehrere gibt. Ist ok ein
 Nullpointer, wird nur geprÅft, ob es Åberhaupt mindestens eine
 zustÑndige Applikation gibt, der zurÅckgelieferte Zeiger sagt in
 diesem Fall nur "Ja" (!= NULL) oder "Nein" (== NULL) aus.
 -------------------------------------------------------------------------*/
APPLINFO *app_match(short mode, char *name, short *ok) {
	APPLINFO *appl, *aptr, *aplist[10];
	OBJECT *objectTree;
	char *aptxt[10], apall[10], *tptr, *spec;
	char mask[61], *help, *wild, wildcard[61], wname[MAX_PLEN];
	short n, i, j, match, amatch, done;
	short ret, dclick;

	aptr = 0L;
	if (ok)
		*ok = 0;
	n = 0;
	appl = desk.appl;
	i = 0;
	while (name[i]) {
		wname[i] = nkc_toupper(name[i]);
		i++;
	}
	wname[i] = 0;
	for (i = 0; i < 10; i++) {
		aplist[i] = 0L;
		apall[i] = 1;
	}

	/* Alle angemeldeten Applikationen testen */
	while (appl) {
		match = amatch = 0;
		/* Je nach Modus testen */
		switch (mode) {
		case 0:
			strcpy(mask, appl->fileopen);
			break;
		case 1:
			strcpy(mask, appl->fileview);
			break;
		case 2:
			strcpy(mask, appl->fileprint);
			break;
		}
		/* Alle Wildcards prÅfen */
		help = mask;
		while ((wild = strtok(help, ",")) != 0L) {
			help = 0L;
			if (!get_buf_entry(wild, wildcard, 0L))
				continue;
			j = 0;
			while (wildcard[j] && (j < 30)) {
				wildcard[j] = nkc_toupper(wildcard[j]);
				j++;
			}
			wildcard[j] = 0;
			if (j > 0) {
				match = wild_match1(wildcard, wname);
				if (match && n < 10) {
					amatch = 1;
					if (strcmp(wildcard, "*"))
						apall[n] = 0;
				}
			}
		}
		/* Bei Bedarf in die Liste aufnehmen */
		if (amatch && n < 10) {
			aplist[n] = appl;
			aptxt[n] = appl->title;
			n++;
		}

		appl = appl->next;
	}

	/* Mindestens eine Applikation vorhanden? */
	if (n > 0) {
		if (ok)
			*ok = 1;
		else {
			aplist[0]->startname[0] = 0;
			return (aplist[0]);
		}
		if (n > 1) {
			/* Auswahl notwendig ? */

			/* '*'-Masken rausschmeissen, falls es auch Applikationen mit
			 'genaueren' Angaben wie '*.img' etc. gibt */
			j = 0;
			for (i = 0; i < n; i++)
				if (apall[i])
					j++;
			if (n > j) {
				i = 0;
				while (aplist[i]) {
					if (apall[i]) {
						for (j = i; j < n - 1; j++) {
							apall[j] = apall[j + 1];
							aptxt[j] = aptxt[j + 1];
							aplist[j] = aplist[j + 1];
						}
						aplist[j] = 0L;
						n--;
					} else
						i++;
				}
			}
		}

		if (n > 1) {
			/* Auswahl immer noch notwendig ? */

			/* Semaphore prÅfen/setzen und ggf. Abbruch */
			if (!glob.sm_selapp)
				glob.sm_selapp = 1;
			else
				return 0L;

			/* EintrÑge sortieren */
			for (i = 0; i < n; i++)
				for (j = i; j < n; j++) {
					ret = strcmp(aptxt[i], aptxt[j]);
					if (ret > 0) {
						tptr = aptxt[i];
						aptr = aplist[i];
						aptxt[i] = aptxt[j];
						aplist[i] = aplist[j];
						aptxt[j] = tptr;
						aplist[j] = aptr;
					} else {
						if (ret < 0) {
							tptr = aptxt[j];
							aptr = aplist[j];
							aptxt[j] = aptxt[i];
							aplist[j] = aplist[i];
							aptxt[i] = tptr;
							aplist[i] = aptr;
						}
					}
				}

			/* Dialog vorbereiten */
			objectTree = rs_trindex[SELAPP];
			strcpy(objectTree[SAFILE].ob_spec.free_string, wname);

#ifdef DIRCH
			spec = getObjectText(objectTree, SATITLE);
			switch (mode) {
			case 0:
				setObjectText(objectTree, SATITLE, rs_frstr[TXSOPEN]);
				break;
			case 1:
				setObjectText(objectTree, SATITLE, rs_frstr[TXSVIEW]);
				break;
			case 2:
				setObjectText(objectTree, SATITLE, rs_frstr[TXSPRINT]);
				break;
			}
#else
			spec = objectTree[SATITLE].ob_spec.free_string;
			switch (mode) {
			case 0:
				objectTree[SATITLE].ob_spec.free_string = rs_frstr[TXSOPEN];
				break;
			case 1:
				objectTree[SATITLE].ob_spec.free_string = rs_frstr[TXSVIEW];
				break;
			case 2:
				objectTree[SATITLE].ob_spec.free_string = rs_frstr[TXSPRINT];
				break;
			}
#endif

			li_selapp.text = aptxt;
			li_selapp.num = n;
			li_selapp.offset = 0;
			li_selapp.sel = 0;
			lst_init(&li_selapp, 1, 1, 0, 0);

			/* Und auf gehts... */
			frm_start(&fi_selapp, conf.wdial, conf.cdial, 1);
			done = 0;
			aptr = 0L;
			while (!done) {
				ret = frm_dial(&fi_selapp, &mevent);
				if (lst_handle(&li_selapp, ret, &dclick)) {
					if (dclick) {
						aptr = aplist[li_selapp.sel];
						done = 1;
					}
				} else {
					switch (fi_selapp.exit_obj) {
					case -1: /* RÅckgabe von Sondertasten */
						if (fi_selapp.state == FST_WIN) {
							wind_update(BEG_UPDATE);
							wind_update(BEG_MCTRL);
						}
						lst_key(&li_selapp, fi_selapp.normkey);
						if (fi_selapp.state == FST_WIN) {
							wind_update(END_UPDATE);
							wind_update(END_MCTRL);
						}
						break;
					case SAHELP:
						show_help(fi_selapp.userinfo);
						frm_norm(&fi_selapp);
						break;
					case SAOK:
						aptr = aplist[li_selapp.sel];
						done = 1;
						break;
					case SACANCEL:
						aptr = 0L;
						done = 1;
						break;
					}
				}
			}
			frm_end(&fi_selapp);
#ifdef DIRCH
			setObjectText(objectTree, SATITLE, spec);
#else
			objectTree[SATITLE].ob_spec.free_string = spec;
#endif

			/* Semaphore lîschen */
			glob.sm_selapp = 0;
		} else {
			/* Keine Auswahl nîtig - es gibt nur eine Appl. */
			aptr = aplist[0];
		}
	}
	if (aptr)
		aptr->startname[0] = 0;
	return (aptr);
}

/**
 app_default()

 Defaultwerte fÅr Applikation eintragen
 -------------------------------------------------------------------------*/
void app_default(APPLINFO *appl) {
	char *p;
	short t, i;

	p = strrchr(appl->name, '\\');
	if (p)
		strcpy(appl->title, &p[1]);
	else
		appl->title[0] = 0;
	appl->parm[0] = 0;
	appl->paralways = 0;
	appl->fullcompare = 1;
	appl->homepath = defappl.homepath;
	appl->fullpath = defappl.fullpath;
	appl->unixpaths = defappl.unixpaths;
	appl->fileopen[0] = 0;
	appl->fileview[0] = 0;
	appl->fileprint[0] = 0;
	t = is_app(appl->name, 0111);
	if (t == 3 || t == 5)
		appl->getpar = 1;
	else
		appl->getpar = 0;
	appl->vaproto = defappl.vaproto;
	appl->single = defappl.single;
	appl->conwin = defappl.conwin;
	appl->toswait = conf.toswait;
	appl->shortcut = 0;
	appl->usesel = 0;
	appl->autostart = 0;
	appl->overlay = 0;
	appl->memlimit = 0L;
	for (i = 0; i < MAX_EVAR; i++)
		appl->evar[i] = 0L;
	appl->euse = 0;
	appl->dodrag = 0;
	appl->alert[0] = 0;
}

/**
 app_isdrag()

 PrÅft, ob eine Datei indirekt als Drag&Drop-Ziel verwendet werden kann
 -------------------------------------------------------------------------*/
APPLINFO *app_isdrag(char *name) {
	APPLINFO *appl, *aptr;
	short i, j, all, match;
	char *wild, wildcard[61], mask[61], wname[MAX_FLEN], *p;

	aptr = 0L;
	all = 1;
	p = strrchr(name, '\\');
	if (p)
		p = &p[1];
	else
		p = name;
	i = 0;
	while (p[i] && i < MAX_FLEN) {
		wname[i] = nkc_toupper(p[i]);
		i++;
	}
	wname[i] = 0;
	appl = desk.appl;

	while (appl) {
		if (appl->dodrag) {
			/* Alle Wildcards prÅfen */
			strcpy(mask, appl->fileopen);
			p = mask;
			while ((wild = strtok(p, ",")) != 0L) {
				p = 0L;
				if (!get_buf_entry(wild, wildcard, 0L))
					continue;
				j = 0;
				j = 0;
				while (wildcard[j] && (j < 30)) {
					wildcard[j] = nkc_toupper(wildcard[j]);
					j++;
				}
				wildcard[j] = 0;
				if (j > 0) {
					match = wild_match1(wildcard, wname);
					if (match) {
						if (match && all)
							aptr = appl;
						if (strcmp(wildcard, "*"))
							all = 0;
					}
				}
				if (mask[i])
					i++;
			}
		}
		appl = appl->next;
	}
	if (aptr)
		aptr->startname[0] = 0;
	return (aptr);
}

/* EOF */
