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
 MAIN.C

 Thing
 Hauptmodul
 =========================================================================*/

#include "..\include\globdef.h"
#include "..\include\types.h"
#include "rsrc\thing.h"
#include "rsrc\thgtxt.h"
#include "..\include\dragdrop.h"
#include "..\include\tcmd.h"
#include <new_rsc.h>
#include <signal.h>
#include <math.h>
#include <pwd.h>
#include <grp.h>
#include <errno.h>

#define _str(x)		__str(x)
#define __str(x)	#x
#define LINOUT	Cconws(_str(__LINE__) "\r\n\n\n");
#undef LINOUT
#define LINOUT

extern char *version_str(char *langver, short vers);

/*
 * Wird nur hier fuer die Reservierung/Freigabe gebraucht,
 * da die Verbindung ueber desk.dicons[n].spec.drive erfolgt.
 */
static D_DRIVE *drive;

static WORD tos256pal[] = { 1000, 1000, 1000, 0, 0, 0, 1000, 0, 0, 0, 1000, 0,
		0, 0, 1000, 0, 1000, 1000, 1000, 1000, 0, 1000, 0, 1000, 871, 871, 871,
		631, 631, 631, 667, 0, 0, 0, 667, 0, 0, 0, 667, 0, 667, 667, 667, 667,
		0, 667, 0, 667, 1000, 1000, 1000, 933, 933, 933, 871, 871, 871, 792,
		792, 792, 729, 729, 729, 667, 667, 667, 600, 600, 600, 537, 537, 537,
		459, 459, 459, 396, 396, 396, 329, 329, 329, 267, 267, 267, 204, 204,
		204, 125, 125, 125, 63, 63, 63, 0, 0, 0, 1000, 0, 0, 1000, 0, 63, 1000,
		0, 125, 1000, 0, 204, 1000, 0, 267, 1000, 0, 329, 1000, 0, 396, 1000,
		0, 459, 1000, 0, 537, 1000, 0, 600, 1000, 0, 667, 1000, 0, 729, 1000,
		0, 792, 1000, 0, 871, 1000, 0, 933, 1000, 0, 1000, 933, 0, 1000, 871,
		0, 1000, 792, 0, 1000, 729, 0, 1000, 667, 0, 1000, 600, 0, 1000, 537,
		0, 1000, 459, 0, 1000, 396, 0, 1000, 329, 0, 1000, 267, 0, 1000, 204,
		0, 1000, 125, 0, 1000, 63, 0, 1000, 0, 0, 1000, 0, 63, 1000, 0, 125,
		1000, 0, 204, 1000, 0, 267, 1000, 0, 329, 1000, 0, 396, 1000, 0, 459,
		1000, 0, 537, 1000, 0, 600, 1000, 0, 667, 1000, 0, 729, 1000, 0, 792,
		1000, 0, 871, 1000, 0, 933, 1000, 0, 1000, 1000, 0, 1000, 933, 0, 1000,
		871, 0, 1000, 792, 0, 1000, 729, 0, 1000, 667, 0, 1000, 600, 0, 1000,
		537, 0, 1000, 459, 0, 1000, 396, 0, 1000, 329, 0, 1000, 267, 0, 1000,
		204, 0, 1000, 125, 0, 1000, 63, 0, 1000, 0, 63, 1000, 0, 125, 1000, 0,
		204, 1000, 0, 267, 1000, 0, 329, 1000, 0, 396, 1000, 0, 459, 1000, 0,
		537, 1000, 0, 600, 1000, 0, 667, 1000, 0, 729, 1000, 0, 792, 1000, 0,
		871, 1000, 0, 933, 1000, 0, 1000, 1000, 0, 1000, 933, 0, 1000, 871, 0,
		1000, 792, 0, 1000, 729, 0, 1000, 667, 0, 1000, 600, 0, 1000, 537, 0,
		1000, 459, 0, 1000, 396, 0, 1000, 329, 0, 1000, 267, 0, 1000, 204, 0,
		1000, 125, 0, 1000, 63, 0, 729, 0, 0, 729, 0, 63, 729, 0, 125, 729, 0,
		204, 729, 0, 267, 729, 0, 329, 729, 0, 396, 729, 0, 459, 729, 0, 537,
		729, 0, 600, 729, 0, 667, 729, 0, 729, 667, 0, 729, 600, 0, 729, 537,
		0, 729, 459, 0, 729, 396, 0, 729, 329, 0, 729, 267, 0, 729, 204, 0,
		729, 125, 0, 729, 63, 0, 729, 0, 0, 729, 0, 63, 729, 0, 125, 729, 0,
		204, 729, 0, 267, 729, 0, 329, 729, 0, 396, 729, 0, 459, 729, 0, 537,
		729, 0, 600, 729, 0, 667, 729, 0, 729, 729, 0, 729, 667, 0, 729, 600,
		0, 729, 537, 0, 729, 459, 0, 729, 396, 0, 729, 329, 0, 729, 267, 0,
		729, 204, 0, 729, 125, 0, 729, 63, 0, 729, 0, 63, 729, 0, 125, 729, 0,
		204, 729, 0, 267, 729, 0, 329, 729, 0, 396, 729, 0, 459, 729, 0, 537,
		729, 0, 600, 729, 0, 667, 729, 0, 729, 729, 0, 729, 667, 0, 729, 600,
		0, 729, 537, 0, 729, 459, 0, 729, 396, 0, 729, 329, 0, 729, 267, 0,
		729, 204, 0, 729, 125, 0, 729, 63, 0, 459, 0, 0, 459, 0, 63, 459, 0,
		125, 459, 0, 204, 459, 0, 267, 459, 0, 329, 459, 0, 396, 459, 0, 459,
		396, 0, 459, 329, 0, 459, 267, 0, 459, 204, 0, 459, 125, 0, 459, 63, 0,
		459, 0, 0, 459, 0, 63, 459, 0, 125, 459, 0, 204, 459, 0, 267, 459, 0,
		329, 459, 0, 396, 459, 0, 459, 459, 0, 459, 396, 0, 459, 329, 0, 459,
		267, 0, 459, 204, 0, 459, 125, 0, 459, 63, 0, 459, 0, 63, 459, 0, 125,
		459, 0, 204, 459, 0, 267, 459, 0, 329, 459, 0, 396, 459, 0, 459, 459,
		0, 459, 396, 0, 459, 329, 0, 459, 267, 0, 459, 204, 0, 459, 125, 0,
		459, 63, 0, 267, 0, 0, 267, 0, 63, 267, 0, 125, 267, 0, 204, 267, 0,
		267, 204, 0, 267, 125, 0, 267, 63, 0, 267, 0, 0, 267, 0, 63, 267, 0,
		125, 267, 0, 204, 267, 0, 267, 267, 0, 267, 204, 0, 267, 125, 0, 267,
		63, 0, 267, 0, 63, 267, 0, 125, 267, 0, 204, 267, 0, 267, 267, 0, 267,
		204, 0, 267, 125, 0, 267, 63, 0, 1000, 1000, 1000, 0, 0, 0 };

/*-------------------------------------------------------------------------
 Verschiedene Handler fuer einige MiNT-Signale
 -------------------------------------------------------------------------*/
#pragma warn -par
void sigTerm(long sig) {
	glob.done = 1;
}
#pragma warn .par

void cdecl sigFatal(long sig) {
	char msg[256] = "ARGH! Thing received ";

	switch ((short)sig) {
	case SIGBUS:
		strcat(msg, "SIGBUS!");
		break;
	case SIGILL:
		strcat(msg, "SIGILL!");
		break;
	case SIGPRIV:
		strcat(msg, "SIGPRIV!");
		break;
	case SIGSEGV:
		strcat(msg, "SIGSEGV!");
		break;
	}
	Salert(msg);
}

/*-------------------------------------------------------------------------
 wind_restore()

 Anhand der 'open list' Fenster îffnen
 -------------------------------------------------------------------------*/

/**
 *
 *
 * @param **wopen
 */
void free_wopen(WINOPEN **wopen) {
	WINOPEN *help, *list;

	list = *wopen;
	while (list != 0L) {
		help = list;
		list = list->next;
		pfree(help);
	}
	*wopen = 0L;
}

/**
 *
 *
 * @param desk_redraw
 */
void wind_restore(short desk_redraw) {
	WINOPEN *wopen;
	WININFO *twin;
	short wret;
	twin = 0L;
	wopen = glob.openwin;

	/*
	 * Liste aller offenen Fenster der letzten Sitzung durchgehen und entsprechend
	 * ihrem Typ oeffnen.
	 */
	while (wopen) {
		/* manuelles Platzieren der Fenster temporaer ausschalten */
		glob.placement = 0;
		switch (wopen->class) {
		case WCPATH:
			wret = wpath_open(wopen->title, wopen->wildcard, wopen->rel, wopen->relname, wopen->text, wopen->num, wopen->sortby);
			break;

		case WCGROUP:
			wret = wgrp_open(wopen->title, 0L, 0L);
			break;

		case WCCON:
			dl_conwin();
			if (con.win.state & WSOPEN)
				wret = 1;
			else
				wret = 0;
			break;

		default:
			wret = 0;
		}

		/* manuelles Platzieren der Fenster wieder einschalten */
		glob.placement = 1;

		if (wret) {
			/* Slider setzen */
			win_slide(tb.topwin, S_ABS, wopen->sh, wopen->sv);

			/* Falls Fenster aktiv war, dann merken */
			if (wopen->istop)
				twin = tb.topwin;

			msg_clr();
		}

		/* Naechsten Eintrag holen und jetzigen Eintrag freigeben */
		wopen = wopen->next;
		if (desk_redraw) {
			desk_draw(tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h);
			desk_redraw = 0;
		}
	}
	free_wopen(&glob.openwin);
	if (twin)
		win_top(twin);
}

/**
 * Programminitialisierung
 *
 * @return
 */
short main_init(void) {
	short i, j, l, x, y, w, h, fok, rex;
	char tbuf[34];
	char name[MAX_PLEN];
	char *p, *sp, rsrcName[13];
	WINOPEN *openwin;
	APPLINFO *aptr;
	OBJECT *tree;
	struct passwd *pwd;
	struct group *grp;
	UGNAME *new, *last;
	ICONBLK *logoh;
	ICONDESK *q;
	long err;
#ifdef _DEBUG
	FILE *fh;

	glob.debug_level = 0;
#endif

	/* Globale Teile initialisieren */
	if ((err = Pumask(0)) == -32L)
		err = 022;
	glob.umask = (unsigned short) err;
	Pumask(glob.umask);
	glob.toserr = 0;
	glob.argv = 0;
	glob.menu = 0;
	glob.accwin = 0L;
	glob.accstate = 0L;
	glob.avinfo = 0L;
	glob.rtree = 0L;
	glob.srtree = 0L;
	glob.sheight = 16;
	glob.openwin = 0L;
	glob.gcmd[0] = 0;
	glob.fmode = 0;
	glob.sm_selapp = 0;
	glob.sm_fontsel = 0;
	glob.sm_copy = 0;
	glob.sm_info = 0;
	glob.sm_format = 0;
	glob.mode_config = 0;
	glob.alice = 0L;
	glob.alicewin = 0L;
	glob.img_ok = 0;
	glob.img_info.version = THINGIMG_VERS;
	glob.img_info.picture.fd_addr = 0L;
	/* homepath, confpath, desk_w und desk_h erst spaeter! */
	con.vdi_handle = 0;
	con.vdi_chandle = 0;
	gdos.fontlist = 0L;
	gdos.fontname = 0L;
	gdos.mfontname = 0L;
	gdos.fontid = 0L;
	gdos.mfontid = 0L;
	desk.wicon = 0L;
	desk.dicon = 0L;
	desk.icon = 0L;
	desk.maxicon = 0;
	desk.appl = 0L;
	drive = 0L;
	aesapname = 0L;
	aesbuf = 0L;
	dcopy = 0L;
	dapp = 0L;
	lbuf = 0L;
	conf.cdial = 1;
	conf.wdial = 1;
	conf.userdef = 1;
	conf.nicelines = 1;

	glob.initialisation = 0;
	glob.autoclose = 0;
	glob.closeall = 0;
	glob.placement = 1;

	rinfo.dinfo.first = 0L;
	rinfo2.dinfo.first = 0L;
	glob.rinfo.dinfo.first = 0L;

	/* Toolbox und Speicherverwaltung initialisieren */
#ifdef USE_PMALLOC
	pminit();
#else
#ifdef __MINT__
	/* _mallocChunkSize(32768L);*/
#endif
#endif
#ifdef MEMDEBUG
	set_MemdebugOptions(c_On, c_On, c_On, c_Off, c_On, c_Off, c_Off, c_Off, c_Off, "c:\\memdebug.out", "c:\\memdebug.err");
#endif

	if (!tool_init(FNAME_PRG))
		return (0);

DEBUGLOG((1, "main_init: Toolbox initialised, logging enabled\n"));

	{
		short handle;
		long err;

		sprintf(name, "%s%s", tb.homepath, FNAME_PAL);
		if ((err = Fopen(name, 0)) >= 0L) {
			handle = (short) err;
			Fread(handle, 256L * 6L, tos256pal);
			Fclose(handle);
		}
	}

	if (!init_cicon_with_palette(tos256pal))
		return (0);

	glob.img_info.homepath = tb.homepath;
	glob.img_info.desk_w = tb.desk.g_w;
	glob.img_info.desk_h = tb.desk.g_h;
	glob.img_info.confpath = glob.cpath;
	glob.dir_img = glob.img_info;
	menu_register(-1, "THING   ");

#if 0
	/* is_wild-Array fuellen */
	memset(is_wild, 0, 256L);
	is_wild['*'] = 1;
	is_wild['?'] = 1;
	is_wild['['] = 1;
	is_wild[']'] = 1;
#endif

	/* NAES-Cookie holen */
	if (Getcookie('nAES', (long *) &glob.naesinfo) != E_OK )
		glob.naesinfo = 0L;

#ifdef _DEBUG
	/* Debug-Info laden */
	glob.debug_level = 1;
	strcpy(glob.debug_name, tb.homepath);
	strcat(glob.debug_name, "debug.log");
	strcpy(name, tb.homepath);
	strcat(name, "debug.inf");
	fh = fopen(name, "r");
	if (fh) {
		fscanf(fh, "%d", &glob.debug_level);
		fclose(fh);
		if (glob.debug_level == 1)
			form_alert(1, "[0][Debug active][ OK ]");
	}
DEBUGLOG((1, "..3\n"));
	debugMain("-------------------------------------------------");
	debugMain("THING DEBUG NOW STARTING");
	debugMain("See DEBUG.INF for configuration");
	debugMain("-------------------------------------------------");
	sprintf(almsg, "MAIN: sys.machine=0x%04x", tb.sys); debugMain(almsg);
	sprintf(almsg, "MAIN: sys.appid=%d", tb.app_id); debugMain(almsg);
	sprintf(almsg, "MAIN: sys.apname=%s", tb.apname); debugMain(almsg);
	sprintf(almsg, "MAIN: sys.appath=%s", tb.homepath); debugMain(almsg);
	sprintf(almsg, "MAIN: sys.vdi.planes=%d", tb.planes); debugMain(almsg);
	sprintf(almsg, "MAIN: sys.vdi.resxy=%d/%d", tb.resx,tb.resy); debugMain(almsg);
	sprintf(almsg, "MAIN: sys.vdi.colors=%d", tb.colors); debugMain(almsg);
	sprintf(almsg, "MAIN: sys.aes.fontwh=%d/%d", tb.ch_w, tb.ch_h); debugMain(almsg);
	sprintf(almsg, "MAIN: sys.aes.bigfontsize=%d", tb.fn_size); debugMain(almsg);
	sprintf(almsg, "MAIN: sys.aes.smallfontsize=%d", tb.fs_size); debugMain(almsg);
	sprintf(almsg, "MAIN: sys.aes.screenmanager=%d", tb.scr_id); debugMain(almsg);
	sprintf(almsg, "MAIN: sys.gdos=%d",tb.gdos); debugMain(almsg);
	sprintf(almsg, "MAIN: sys.gdos.fonts=%d", tb.numfonts); debugMain(almsg);
#endif

	/* THINGDIR und HOME beruecksichtigen */
	strcpy(glob.cpath, tb.homepath);

	p = getenv("HOME");
	if (p) {
		XATTR xattr;

		if (p[1] != ':') {
			strcpy(glob.cpath, "U:");
			if ((*p != '\\') && (*p != '/'))
				strcat(glob.cpath, "\\");
			strcat(glob.cpath, p);
		} else
			strcpy(glob.cpath, p);

		/* '/' in '\\' umwandeln */
		p = glob.cpath;
		while ((p = strchr(p, '/')) != NULL)
			*p = '\\';
		p = strchr(glob.cpath, 0);
		if (*(--p) != '\\') {
			strcat(p, "\\");
			p++;
		}
		strcat(glob.cpath, "defaults\\Thing.cnf");
		if (file_exists(glob.cpath, 1, &xattr) || ((xattr.mode & S_IFMT) != S_IFDIR)) {
			*p = 0;
		}
	}

	p = getenv("THINGDIR");
	if (p) {
		strcpy(tb.homepath, p);
		strcpy(glob.cpath, p);
	}

	/* Startverzeichnis mit abschliessendem '\' versehen */
	l = (short) strlen(tb.homepath) - 1;
	if ((l > 0) && (tb.homepath[l] != '\\'))
		strcat(tb.homepath, "\\");
	l = (short) strlen(glob.cpath) - 1;
	if ((l > 0) && (glob.cpath[l] != '\\')) {
		strcat(glob.cpath, "\\");
	}
	strcat(glob.cpath, PNAME_CON);
	strcat(glob.cpath, "\\");

#ifdef _DEBUG
  sprintf(almsg, "MAIN: glob.cpath=%s", glob.cpath); debugMain(almsg);
#endif

	/* Externes THINGIMG.PRG laden */

#ifdef _DEBUG
	debugMain("MAIN: external image handler missing");
#endif

	/* Handler fuer Modale Dialoge installieren, Teil 1 */
	tb.msg_handler = handle_fmsg;

#ifdef _DEBUG
	debugMain("MAIN: aes message handler active");
#endif

	/* Workaround fuer MagiC!Mint */
	if ((tb.sys & SY_MAGX) && (tb.sys & SY_MINT))
		tb.sys &= ~SY_MULTI;

#ifdef _DEBUG
	debugMain("MAIN: MagiC!MiNT patches active");
#endif

	/* Alice austricksen ;-) */
	i = wind_create(NAME | MOVER | CLOSER | FULLER | ICONIFIER, tb.desk.g_x, tb.desk.g_y, 10, 10);
	if (i >= 0)
		wind_delete(i);

	/* Resource laden */
	sprintf(rsrcName, "%s%s\\thing\\%s.rsc", tb.homepath, PNAME_RSC, tb.sysLanguageCodeLong);
	if (!rsc_load(rsrcName, &rinfo)) {
		sprintf(rsrcName, "%s%s\\thing\\english.rsc", tb.homepath, PNAME_RSC);
		if (!rsc_load(rsrcName, &rinfo)) {
			frm_alert(1, "[3][THING.RSC nicht gefunden!|THING.RSC not found!][ OK ]", altitle, 1, 0L);
			return (FALSE);
		}
	}
	rs_trindex = rinfo.rs_trindex;

	sprintf(rsrcName, "%s%s\\thgtxt\\%s.rsc", tb.homepath, PNAME_RSC, tb.sysLanguageCodeLong);
	if (!rsc_load(rsrcName, &rinfo2)) {
		sprintf(rsrcName, "%s%s\\thgtxt\\english.rsc", tb.homepath, PNAME_RSC);
		if (!rsc_load(rsrcName, &rinfo2)) {
			frm_alert(1, "[3][THINGTXT.RSC nicht gefunden!|THINGTXT.RSC not found!][ OK ]", altitle, 1, 0L);
			return (FALSE);
		}
	}
	rs_frstr = rinfo2.rs_frstr;

#ifdef _DEBUG
	debugMain("MAIN: resources - checking");
#endif

	/* Version ueberpruefen */
	tree = rs_trindex[LANGUAGE];
	i = atoi(tree[LANGVER].ob_spec.free_string);
	if (i != _VERS) {
		frm_alert(1, "[3][Bitte richtige THING.RSC installieren!|Please install correct THING.RSC!][ OK ]", altitle, 1, 0L);
		return (FALSE);
	}
	sscanf(tree[LANGFONT].ob_spec.free_string, "%d %d", &rcw, &rch);
	glob.langdec = tree[LANGCHAR].ob_spec.free_string[0];
	glob.dateformat = tree[LANGDATE].ob_spec.free_string;
	glob.timeformat = tree[LANGTIME].ob_spec.free_string;

#ifdef _DEBUG
	debugMain("MAIN: resources - ok");
#endif

	tb.use3d = 1; /* 3D-Effekte benutzen */
	tb.ictree = rs_trindex[ICONWIN]; /* Iconify-Trees setzen */
	tb.ictreed = rs_trindex[ICONDIAL];

	/* if(tb.sys&SY_MINT)*//* Anpassungen an MiNT */
	{
#ifdef _DEBUG
		debugMain("MAIN: MiNT signal handlers active");
#endif
		/* MiNT-Domain aktivieren */
		Pdomain(1);

		/* Einige MiNT-Signal-Handler installieren */
		Psignal(SIGINT, 1L);
		Psignal(SIGSYS,  1L);
		Psignal(SIGABRT, 1L);
		Psignal(SIGTERM, (long) sigTerm);
/*
		 Psignal(SIGBUS, sigFatal);
		 Psignal(SIGILL, sigFatal);
		 Psignal(SIGPRIV, sigFatal);
		 Psignal(SIGSEGV, sigFatal);
 */
		Psignal(SIGQUIT, 1L);
		Psignal(SIGHUP,  1L);
	}

	/* Device-Lock initialisieren */
	init_device_locking();

#ifdef _DEBUG
	debugMain("MAIN: device locking active");
#endif

	/* Name der Konfigurationsdatei fuer aufloesungsabhaengige Infos */
	sprintf(glob.rname, "%04d%04d.", tb.resx, tb.resy);
	sprintf(glob.rnamesfx, "i%02d", tb.planes);
	strcpy(glob.rnamefb, "");

	graf_mouse(BUSYBEE, 0);

	/* Resourcen initialisieren */
	{
		size_t edlen = 0L;
		OBJECT *obj;
		char *p;
		TEDINFO *ti;

		glob.editfields = NULL;
		for (j = 0; j < 2; j++) {
			if (j == 0) {
				for (i = 0; i < rinfo.rsc_file->rsh_ntree; i++) {
					obj = rs_trindex[i];
					if (i == MAINMENU)
						rs_fix(obj, 0, 0);
					else
						rs_fix(obj, rcw, rch);

					for (l = 0;; l++) {
						if ((obj[l].ob_type & 0xff) == G_FBOXTEXT) {
							ti = obj[l].ob_spec.tedinfo;
							if (*ti->te_ptmplt == '#') {
								edlen += (atoi(obj[l].ob_spec.tedinfo->te_ptmplt + 1) + 1) * 3;
							}
						}
						if (obj[l].ob_flags & LASTOB)
							break;
					}
				}
			} else if (edlen) {
				glob.editfields = p = pmalloc(edlen);
				if (p == NULL) {
					frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
					return (0);
				}
				memset(p, 0, edlen);
				for (i = 0; i < rinfo.rsc_file->rsh_ntree; i++) {
					obj = rs_trindex[i];
					for (l = 0;; l++) {
						if ((obj[l].ob_type & 0xff) == G_FBOXTEXT) {
							ti = obj[l].ob_spec.tedinfo;
							if (*ti->te_ptmplt == '#') {
								ti->te_txtlen = ti->te_tmplen = atoi(ti->te_ptmplt + 1) + 1;
								ti->te_ptext = p;
								p += ti->te_txtlen;
								memset(p, '_', ti->te_txtlen - 1);
								ti->te_ptmplt = p;
								p += ti->te_txtlen;
								memset(p, *ti->te_pvalid, ti->te_txtlen - 1);
								ti->te_pvalid = p;
								p += ti->te_txtlen;
							}
						}
						if (obj[l].ob_flags & LASTOB)
							break;
					}
				}
			}
		}
	}

	/* Name der Default-Applikation eintragen */
	strcpy(defappl.title, rs_frstr[DEFAULTAPPL]);

	/* Icons fuer ikonifizierte Fenster anpassen */
	rs_trindex[ICONWIN][1].ob_width = 64;
	rs_trindex[ICONWIN][1].ob_height = 32;
	rs_trindex[ICONDIAL][1].ob_width = 72;
	rs_trindex[ICONDIAL][1].ob_height = 40;
	rs_trindex[ICONPATH][1].ob_width = 72;
	rs_trindex[ICONPATH][1].ob_height = 40;
	rs_trindex[ICONCON][1].ob_width = 72;
	rs_trindex[ICONCON][1].ob_height = 40;

	/* Sliderposition in den jeweiligen Dialogen anpassen */
	lst_prepare(&li_defappl, rs_trindex[DEFAPPL]);
	lst_prepare(&li_selapp, rs_trindex[SELAPP]);
	lst_prepare(&li_hotkeys, rs_trindex[HOTKEYS]);

	/*
	 * Im Dialog "Info ueber Applikation" Verweise auf den Programmnamen
	 * in den Unterseiten einrichten.
	 */
	tree = rs_trindex[DAPPINFO];
	tree[DAINAME2].ob_spec.free_string =
	tree[DAINAME3].ob_spec.free_string =
	tree[DAINAME4].ob_spec.free_string =
	tree[DAINAME].ob_spec.tedinfo->te_ptext;

	lst_prepare(&li_dappinfo, tree);
	lst_prepare(&li_mask, rs_trindex[MASK]);

	/* 'Mini-Fenster' in der Voreinstellung */
	tree = rs_trindex[CONFIG];
	tree[COTWVSLIDE].ob_y = tb.ch_h - 1;
	tree[COTWVSLIDE].ob_height = tb.ch_h * 2 + tb.ch_h / 2 + 1;
	tree[COTWHSLIDE].ob_width = tb.ch_w * 12 + 1;

	/* Font-ID im Dialog "Schriftart" anpassen */
	rs_trindex[FONT][FOID].ob_width = 9 * tb.fs_cw;
	rs_trindex[FONT][FOID].ob_height = tb.fs_ch;

	/* Versionsnummer in 'About' eintragen */
	tree = rs_trindex[ABOUT];
	p = tree[ABVER].ob_spec.tedinfo->te_ptext;
	strcpy(p, version_str(rs_trindex[LANGUAGE][LANGTVER].ob_spec.free_string, _VERS));

	/* Thing-Logo anpassen */
	if ((tree[ABLOGOHI].ob_type & 0xff) == G_USERDEF) {
		logoh = &((DRAW_CICON *) (tree[ABLOGOHI].ob_spec.userblk->ub_parm))->original->monoblk;
	} else
		logoh = tree[ABLOGOHI].ob_spec.iconblk;
	logoh->ib_htext = logoh->ib_wtext = 0;
	logoh->ib_xtext = logoh->ib_wicon / 2;
	logoh->ib_ytext = logoh->ib_hicon / 2;
	tree[ABLOGOHI].ob_x = (tree->ob_width - logoh->ib_wicon - logoh->ib_xicon) / 2;
	tree[ABLOGOLO].ob_x = (tree->ob_width - tree[ABLOGOLO].ob_spec.bitblk->bi_wb * 8) / 2;
	if (tb.ch_h < 12) {
		tree[ABLOGOHI].ob_flags |= HIDETREE;
		tree[ABLOGOLO].ob_flags &= ~HIDETREE;
	} else {
		l = logoh->ib_yicon + logoh->ib_hicon - tree[ABLOGOHI].ob_height + 4;
		tree->ob_height += l;
		for (i = ABVER; i <= ABINFO; i++)
			tree[i].ob_y += l;
	}

#if 0
	/* Falls kein MiNT, dann keine Minix-Attribute zulassen */
	if(!(tb.sys & SY_MINT)) {
		rs_trindex[FLINFO][FLATTR].ob_state |= DISABLED;
		rs_trindex[FLINFO][FLATTR].ob_flags& = ~(SELECTABLE | TOUCHEXIT);
	}
#endif

	/* Falls kein MagiC, dann keine MagiC-Speicherlimitierung */
	if (!(tb.sys & SY_MAGX))
		setObjectDisabled(rs_trindex[FLINFO], FPMAGIC);

	/* Unter MultiTOS einen schoeneren Eintrag im Desk-Menue */
	if (tb.sys & SY_MTOS)
		menu_register(tb.app_id, "  Thing Desktop");

#ifdef _DEBUG
	sprintf(almsg, "MAIN: homepath is now  =%s", tb.homepath); debugMain(almsg);
	sprintf(almsg, "MAIN: configpath is now=%s", glob.cpath); debugMain(almsg);
#endif

	/* Defaults, falls Single-TOS */
	setObjectDisabled(rs_trindex[MAINMENU], MCHANGEREZ);
	setObjectDisabled(rs_trindex[DAPPINFO], DAOSINGLE);
	setObjectFlags(rs_trindex[DAPPINFO], DAOSINGLE, SELECTABLE, FALSE);

	/* Wenn $RSMASTER gesetzt, ist Aufloesungswechsel moeglich */
	tree = rs_trindex[MAINMENU];
	if (getenv("RSMASTER") != NULL)
		unsetObjectDisabled(tree, MCHANGEREZ);

	/* Thing laeuft unter MultiTOS - dann geht auf jeden Fall ARGV */
	if (tb.sys & SY_MTOS)
		glob.argv = 1;

	/* Thing laeuft unter MagiC */
	if (tb.sys & SY_MAGX) {
		/* Wenn Shutdown vorhanden ist, dann geht sicher auch ARGV */
		if (tb.sys & SY_SHUT)
			glob.argv = 1;

		/* ... und als Shell */
		if (tb.sys & SY_MSHELL) {
			/* Aufloesungswechsel moeglich */
			unsetObjectDisabled(tree, MCHANGEREZ);

			/* Single-Mode moeglich */
			unsetObjectDisabled(rs_trindex[DAPPINFO], DAOSINGLE);
			setObjectFlags(rs_trindex[DAPPINFO], DAOSINGLE, SELECTABLE, TRUE);

			/* Falls Thing unter MagiC 2 laeuft, dann Menuepunkt 'Quit' rausschmeissen */
			if (!(tb.sys & SY_SHUT)) {
				tree[MQUIT].ob_state |= DISABLED;
				tree[MQUIT - 2].ob_next = MTFILE;
				tree[MQUIT - 2].ob_flags |= LASTOB;
				tree[MTFILE].ob_tail = MQUIT - 2;
				tree[MTFILE].ob_height -= (tb.ch_h * 2);
			} else {
				/* Unter MagiC 3 'Ausschalten' statt 'Quit' */
				tree[MQUIT].ob_spec.free_string = rs_frstr[TXMSHUT];
			}
		}
	}

#if 0
	/* Multitasking allgemein */
	if (tb.sys & SY_MULTI) {
		/* Keine Auslagerung von Thing beim Programmstart, wenn nicht MagiC */
		if (!(tb.sys & SY_MAGX)) {
			rs_trindex[CONFIG][COEXIT].ob_state |= DISABLED;
			rs_trindex[CONFIG][COEXIT].ob_flags &= ~SELECTABLE;
			rs_trindex[DAPPINFO][DAOOVERLAY].ob_state |= DISABLED;
			rs_trindex[DAPPINFO][DAOOVERLAY].ob_flags &= ~SELECTABLE;
		}
	}
#endif

	/* Falls mehr als zwei Farben, dann Slider im 'Wait'-Dialog
	 und 'Laufwerks-Info' auf Farbe 2 (Rot) setzen */
	if (tb.planes > 1) {
		rs_trindex[WAIT][WFSLIDE].ob_spec.obspec.fillpattern = IP_SOLID;
		rs_trindex[WAIT][WFSLIDE].ob_spec.obspec.interiorcol = G_RED;
		rs_trindex[WAITCOPY][WCSLIDE].ob_spec.obspec.fillpattern = IP_SOLID;
		rs_trindex[WAITCOPY][WCSLIDE].ob_spec.obspec.interiorcol = G_RED;
		rs_trindex[DIINFO][DIBUSED].ob_spec.obspec.fillpattern = IP_SOLID;
		rs_trindex[DIINFO][DIBUSED].ob_spec.obspec.interiorcol = G_RED;
	}

	/* Default-Parameter fuer Kobold */
	strcpy(conf.kb_prog, tb.homepath);
	strcat(conf.kb_prog, "KOBOLD_2.PRG");
	conf.kbf_use = conf.kbc_use = conf.kbd_use = conf.kbd_two = conf.kb_tosonly = 0;
	conf.kbc_files = conf.kbd_files = 1;
	conf.kbc_size = 1L;

	/* AV-Protokoll initialisieren */
	if (!av_init())
		return (FALSE);

	/* DTA setzen */
	Fsetdta(&glob.dta);

#ifdef _DEBUG
	debugMain("MAIN: DTA active");
#endif

	/* Externe Resourcen fuer die Icons laden */
	strcpy(name, tb.homepath);
	strcat(name, FNAME_RSC);
	if (!rsc_load(name, &glob.rinfo)) {
		frm_alert(1, rs_frstr[ALNORSC], altitle, conf.wdial, 0L);
		return (FALSE);
	} else {
		rsc_gaddr(R_TREE, 0, &glob.rtree, &glob.rinfo);
		rs_fix(glob.rtree, rcw, rch);
		if (rsc_gaddr(R_TREE, 1, &glob.srtree, &glob.rinfo) != 0)
			rs_fix(glob.srtree, rcw, rch);
		else {
			/* frm_alert(1,rs_frstr[ALNOMINI],altitle,conf.wdial,0L); */
			glob.srtree = 0L;
			glob.sheight = 16;
		}
	}

	/* Dialoge initialisieren */
	fi_wait.tree = rs_trindex[WAIT];
	fi_wait.userinfo = rs_frstr[HMWAIT];
	fi_wait.title = fi_waitcopy.title = "Thing";
	fi_wait.exit = de_wait;
	fi_waitcopy.tree = rs_trindex[WAITCOPY];
	fi_waitcopy.userinfo = rs_frstr[HMWAIT];
	fi_waitcopy.exit = de_wait;
	fi_param.tree = rs_trindex[PARAM];
	fi_param.userinfo = rs_frstr[HMPAR];
	fi_selapp.tree = rs_trindex[SELAPP];
	fi_selapp.userinfo = rs_frstr[HMSELAPP];
	fi_about.tree = rs_trindex[ABOUT];
	fi_about.userinfo = rs_frstr[HMABOUT];
	fi_about.init = di_about;
	fi_about.exit = de_about;
	fi_ainfo1.tree = rs_trindex[AINFO1];
	fi_ainfo1.userinfo = rs_frstr[HMABOUT];
	fi_ainfo1.init = di_ainfo1;
	fi_ainfo1.exit = de_ainfo1;
	fi_diinfo.tree = rs_trindex[DIINFO];
	fi_diinfo.userinfo = rs_frstr[HMDIINFO];
	fi_trashinfo.tree = rs_trindex[TRASHINFO];
	fi_trashinfo.userinfo = rs_frstr[HMTRASHINFO];
	fi_clipinfo.tree = rs_trindex[CLIPINFO];
	fi_clipinfo.userinfo = rs_frstr[HMCLIPINFO];
	fi_dappinfo.tree = rs_trindex[DAPPINFO];
	fi_dappinfo.exit = de_dappinfo;
	fi_fileinfo.tree = rs_trindex[FLINFO];
	fi_fileinfo.userinfo = rs_frstr[HMDFILEINFO];
	fi_prtinfo.tree = rs_trindex[PRTINFO];
	fi_prtinfo.userinfo = rs_frstr[HMDPRTINFO];
	fi_devinfo.tree = rs_trindex[DEVINFO];
	fi_devinfo.userinfo = rs_frstr[HMDEVICE];
	fi_parent.tree = rs_trindex[PAINFO];
	fi_parent.userinfo = rs_frstr[HMPARENT];
	fi_grpinfo.tree = rs_trindex[GROUPINFO];
	fi_grpinfo.userinfo = rs_frstr[HMGRPINFO];
	fi_gobinfo.tree = rs_trindex[GOBINFO];
	fi_gobinfo.userinfo = rs_frstr[HMGOBINFO];
	fi_selinfo.tree = rs_trindex[SELINFO];
	fi_selinfo.userinfo = rs_frstr[HMSELINFO];
	fi_delete.tree = rs_trindex[DELETE];
	fi_delete.userinfo = rs_frstr[HMDELCONF];
	fi_copy.tree = rs_trindex[COPY];
	fi_copy.userinfo = rs_frstr[HMCOPYCONF];
	fi_format.tree = rs_trindex[FORMAT];
	fi_format.userinfo = rs_frstr[HMFORMAT];
	fi_format.init = di_format;
	fi_format.exit = de_format;
	fi_mask.tree = rs_trindex[MASK];
	fi_mask.userinfo = rs_frstr[HMMASK];
	fi_mask.init = di_mask;
	fi_mask.exit = de_mask;
	fi_font.tree = rs_trindex[FONT];
	fi_font.exit = de_font;
	fi_config.tree = rs_trindex[CONFIG];
	fi_config.init = di_config;
	fi_config.exit = de_config;
	fi_cfunc.tree = rs_trindex[CFUNC];
	fi_cfunc.userinfo = rs_frstr[HMFUNC];
	fi_cfunc.exit = de_cfunc;
	fi_defappl.tree = rs_trindex[DEFAPPL];
	fi_defappl.userinfo = rs_frstr[HMAPPL];
	fi_defappl.init = di_appl;
	fi_defappl.exit = de_appl;
	fi_rez.tree = rs_trindex[CHANGEREZ];
	fi_rez.userinfo = rs_frstr[HMCHANGEREZ];
	fi_rez.init = di_rez;
	fi_rez.exit = de_rez;
	fi_cren.tree = rs_trindex[RENAMEFILE];
	fi_cren.userinfo = rs_frstr[HMRENAME];
	fi_new.tree = rs_trindex[NEWOBJ];
	fi_new.userinfo = rs_frstr[HMNEW];
	fi_new.init = di_new;
	fi_new.exit = de_new;
	fi_hotkeys.tree = rs_trindex[HOTKEYS];
	fi_hotkeys.userinfo = rs_frstr[HMHOTKEYS];
	fi_hotkeys.init = di_hotkeys;
	fi_hotkeys.exit = de_hotkeys;

	/* Im Dialog "Schriftart" User-Objekt zur Anzeige der Schriftart einbinden */
	rs_trindex[FONT][FOSAMPLE].ob_type = G_USERDEF;
	rs_trindex[FONT][FOSAMPLE].ob_spec.userblk = &usr_fontsample;

	pop_tcolor.tree = rs_trindex[POPCOLOR];
	pop_tcolor.offx = tb.ch_w;
	pop_bcolor.tree = rs_trindex[POPCOLOR];
	pop_bcolor.offx = tb.ch_w;
	pop_bpat.tree = rs_trindex[POPPAT];
	pop_bpat.offx = tb.ch_w;
	pop_dcol.tree = rs_trindex[POPCOLOR];
	pop_dcol.offx = tb.ch_w;
	pop_dpat.tree = rs_trindex[POPPAT];
	pop_dpat.offx = tb.ch_w;
	pop_autox.tree = rs_trindex[POPAUTOSIZE];
	pop_autoy.tree = rs_trindex[POPAUTOSIZE];
	pop_rez.tree = rs_trindex[POPREZ];
	pop_short.tree = rs_trindex[POPSHORT];
	pop_fkeyfd.tree = pop_fkeydgi.tree = rs_trindex[POPFSHORT];
	pop_mem.tree = rs_trindex[POPPMEM];

	/* Im Dialog "Formatieren" Standardeinstellungen setzen */
	tree = rs_trindex[FORMAT];
	setObjectSelected(tree, FMDRIVEA);
	unsetObjectSelected(tree, FMDRIVEB);
	setObjectSelected(tree, FMFORMDD);
	unsetObjectSelected(tree, FMFORMHD);
	setObjectText(tree, FMNAME, "");
	unsetObjectSelected(tree, FMQUICK);

	/* Alle aktuellen Gruppen- und Usernamen ermitteln */
	glob.usernames =
	glob.groupnames =
	last = 0L;
	setpwent();
	while ((pwd = getpwent()) != NULL) {
		if (strlen(pwd->pw_name) <= 8) {
			new = pmalloc(sizeof(UGNAME));
			if (new == NULL) {
				frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
				return (FALSE);
			}

			new->next = NULL;
			strcpy(new->name, pwd->pw_name);
			new->id = (short)pwd->pw_uid;
			if (glob.usernames != NULL)
				last->next = new;
			else
				glob.usernames = new;

			last = new;
		}
	}
	endpwent();

	setgrent();
	while ((grp = getgrent()) != NULL) {
		UGNAME *new;

		if (strlen(grp->gr_name) <= 8) {
			new = pmalloc(sizeof(UGNAME));
			if (new == NULL) {
				frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
				return (0);
			}
			new->next = NULL;
			strcpy(new->name, grp->gr_name);
			new->id = (short)grp->gr_gid;
			if (glob.groupnames != NULL)
				last->next = new;
			else
				glob.groupnames = new;

			last = new;
		}
	}
	endgrent();

#ifdef _DEBUG
	debugMain("MAIN: initializing desktop and color icons...");
#endif

	desk.wicon = pmalloc(sizeof(WICON)*(long)(MAXICON + 1));
	if(!desk.wicon) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return (FALSE);
	}
	desk.dicon = pmalloc(sizeof(ICONDESK)*(long)(MAXICON + 1));
	if (!desk.dicon) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return (FALSE);
	}

	/* Desktop initialisieren */
	desk_init();

	/* Icons laden */
	conf_iload();

	/* Speicher Laufwerksicons reservieren */
	drive = pmalloc(sizeof(D_DRIVE)*MAXDRIVES);
	if (!drive) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return (FALSE);
	}

	/* ... und mit desk... verbinden */
	q = desk.dicon + 1;
	for (i = 0; i < MAXDRIVES; i++, q++) {
		q->spec.drive=&drive[i];
		q->spec.drive->uselabel = q->spec.drive->autoinstall = 0;
		q->x = q->y = -1;
		drive[i].drive = i;
	}

	/* Desktop-Icon "Papierkorb" einrichten */
	q = desk.dicon + OBTRASH;
	q->class = IDTRASH;
	q->x = tb.desk.g_w - 72;
	q->y = tb.desk.g_h - 40;
	strcpy(q->title, rs_frstr[TXTRASH]);

	/* Desktop-Icon "Ablage" einrichten */
	q = desk.dicon + OBCLIP;
	q->class = IDCLIP;
	q->x = tb.desk.g_w - 148;
	q->y = tb.desk.g_h - 40;
	strcpy(q->title, rs_frstr[TXCLIP]);
	q->spec.clip = pmalloc(sizeof(D_CLIP));
	if (!q->spec.clip) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return (FALSE);
	}
	/* Aktuellen Clipboard-Pfad abfragen */
	p = q->spec.clip->path;
	if (!scrp_read(p) || !*p) {
		/* Nicht gesetzt .. */

		/* Eventuell CLIPBRD? */
		sp = getenv("CLIPBRD");
		if(sp)
			sp = getenv("SCRAPDIR"); /* Eventuell SCRAPDIR? */

		/* Nichts dergleichen ... */
		if(sp) {
			strcpy(p, "C:\\CLIPBRD\\");
			p[0] = (char)boot_drv();
		}
	} else {
		if (p[(short)strlen(p) - 1] != '\\')
			strcat(p, "\\");
	}

	/* Desktop-Icon "Drucker" einrichten */
	q = desk.dicon + OBPRT;
	q->class = IDPRT;
	q->x = tb.desk.g_w - 220;
	q->y = tb.desk.g_h - 40;
	strcpy(q->title, rs_frstr[TXPRT]);

	/* Bisherige Icons erzeugen */
	icon_update(0);

#ifdef _DEBUG
	debugMain("MAIN: desktop and color icons active");
#endif

	/* Standard-Konfiguration */
	conf.hotkeys = 0;
	conf.autosave = 0;
	conf.texit = 0;
	conf.bsel = 1;
	conf.hscr = 0;
	conf.closebox = 0;
	conf.nohotcloser = 0;
	conf.autoupdate = 0;
	conf.tosmode = 0;
	conf.relwin = 1;
	conf.autosel = 1;
	conf.autosize = conf.autosizex = conf.autosizey = 0;
	conf.autoplace = 0;
	conf.interactive = 0;
	conf.casesort = 0;
	conf.caseloc = 0;
	conf.rdouble = 0;
	conf.autocomp = 1;
	conf.altapp = 1;
	conf.askacc = 1;
	conf.vastart = 0;
	conf.cdel = 1;
	conf.ccopy = 1;
	conf.creplace = 1;
	conf.cbuf = 16L;
	conf.dcolor = 1;
	conf.dpattern = 4;
	conf.isnap = 0;
	conf.snapx = 80;
	conf.snapy = 48;
	conf.imguse = conf.imgcenter = conf.imgpal = conf.imgtrans = 0;
	conf.nowin = 0;
	conf.autocon = 1;
	conf.toswait = 1;
	conf.uset2g = 1;
	conf.scroll = 4;
	conf.hidden = 0;
	conf.vert = 1;
	conf.qread = 1;
	conf.usedel = 1;
	strcpy(conf.finder, "");
	strcpy(conf.format, "");

	default_defappl = defappl;

	/* Auf ECPX-Support testen */
	if (appl_find("SPACE   ") >= 0)
		conf.altcpx = 1;
	else
		conf.altcpx = 0;

	/* Laufwerksicons erzeugen */
	dl_drives(0, 0, 0);

	conf.font.id = 1;
	if (tb.ch_h == 8)
		conf.font.size = 9;
	else
		conf.font.size = 10;

	conf.font.fcol = 1;
	conf.font.bcol = 0;
	conf.font.attr = 0;
	conf.bpat = 7;
	conf.index.text = 0;
	conf.index.sortby = SORTNAME;
	conf.index.show = 0;

	/* Funktionstasten */
	for (i = 0; i < 40; i++)
		conf.fkey[i][0] = 0;
	for (i = 0; i < 10; i++) {
		conf.tobj[i][0] = 0;
		conf.ttxt[i][0] = 0;
	}

	/* Verzoegerung in ms fuer Erkennen von Drag&Drop oder Gummiband */
	conf.clickms = 100;

	/* Verzeichnisfenster */
	for (i = 0; i < MAX_PWIN; i++) {
		glob.win[i].class = 0;
		glob.win[i].state = 0;
		glob.win[i].curr.g_x = tb.desk.g_x + tb.ch_w * 2 + i * 8;
		glob.win[i].curr.g_y = tb.desk.g_y + 40 + tb.ch_h + i * 8;
		glob.win[i].curr.g_w = tb.desk.g_w * 2 / 3;
		glob.win[i].curr.g_h = tb.desk.g_h / 2;
	}

	/* Console */
	con.tos2gem = 0L;
	con.font.id = conf.font.id;
	con.font.size = conf.font.size;
	con.font.fcol = 1;
	con.font.bcol = 0;
	con.font.attr = 0;
	con.hist = 0;
	con.buffer = 0;
	con.color = 0;
	con.buftime = 150;
	con.flags = 0x7;
	con.win.curr = tb.desk;

	/* Konfiguration laden */
	glob.tmp = 0;
	glob.sendto = NULL;
	glob.hotkeys = NULL;
	if (!conf_load())
		icon_update(0);
	dl_drives(0, 1, 0);
	if (tb.use3d == 0)
		set3dLook(FALSE);
	else
		setShortcutLineColor(G_RED);

	/* Userdefs erzeugen */
	if (conf.userdef) {
		for (i = 0; i < rinfo.rsc_file->rsh_ntree; i++) {
			if (i != MAINMENU)
				setUserdefs(rs_trindex[i], FALSE);
			else if (conf.nicelines)
				setUserdefs(rs_trindex[i], TRUE);
			adjust_text(tb.use3d, getBackgroundColor(), -1);
		}
	}
	setBackgroundBorder(FALSE);

	/* Dialogboxen zentrieren */
	for (i = 0; i < rinfo.rsc_file->rsh_ntree; i++) {
		/* Desktop-Workaround wg. MultiDialog */
		if ((i != MAINMENU) && (i != DESKTOP))
			form_center(rs_trindex[i], &x, &y, &w, &h);
	}

	/* Und weitere Initialisierungen */
	cwin_init();
	clip_init();
	desk_pat();
	mn_check();

	/* Bei Alice anmelden */
	glob.alice = 0L;
	if (Getcookie('ALIC', (long *)&glob.alice) == E_OK ) {
		if (glob.alice->magic == 'ALIC')
			glob.alice->redraw_ap_id = tb.app_id;
	}

#ifdef _DEBUG
	debugMain("MAIN: Alice-Support active");
#endif

	/* Installierte GDOS-Fonts eintragen */
	gdos.numfonts=tb.numfonts;

#ifdef _DEBUG
	debugMain("MAIN: getting GDOS fonts ...");
#endif

	/* Font-Listen initialisieren */
	gdos.fontlist = pmalloc((long)(34L * gdos.numfonts));
	gdos.fontname = pmalloc(sizeof(char *)*(long)gdos.numfonts);
	gdos.mfontname = pmalloc(sizeof(char *)*(long)gdos.numfonts);
	gdos.fontid = pmalloc(sizeof(short)*(long)gdos.numfonts * 2L);
	gdos.mfontid = pmalloc(sizeof(short)*(long)gdos.numfonts * 2L);
	if (!gdos.fontlist || !gdos.fontname || !gdos.fontid || !gdos.mfontname || !gdos.mfontid) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return (0);
	}

	/* Fonts abfragen */
	gdos.mnumfonts = 0;
	for (i = 0; i < gdos.numfonts; i++) {
		gdos.fontname[i] = &gdos.fontlist[i * 34L];
		gdos.fontid[i * 2L] = vqt_name(tb.vdi_handle, i + 1, gdos.fontname[i]);
		gdos.fontid[i *2L + 1] = i + 1;
	}
	/* Liste nach Namen sortieren */
	for (i = 0; i < gdos.numfonts; i++) {
		for (j = i; j < gdos.numfonts; j++) {
			if (stricmp(gdos.fontname[i], gdos.fontname[j]) > 0) {
				p = gdos.fontname[i];
				gdos.fontname[i] = gdos.fontname[j];
				gdos.fontname[j] = p;
				l = gdos.fontid[i * 2L];
				gdos.fontid[i * 2L] = gdos.fontid[j * 2L];
				gdos.fontid[j * 2L] = l;
				l = gdos.fontid[i * 2L + 1];
				gdos.fontid[i * 2L + 1] = gdos.fontid[j * 2L + 1];
				gdos.fontid[j * 2L + 1] = l;
			}
		}
	}

#ifdef _DEBUG
	debugMain("MAIN: GDOS fonts active");
#endif

	/* PrÅfen, ob der Font fÅr Verzeichnisse verfÅgbar ist */
	fok = 0;
	for (i = 0; i < gdos.numfonts; i++) {
		if (gdos.fontid[i * 2L] == conf.font.id)
			fok = 1;
	}
	if (!fok) {
		/* Zeichensatz nicht verfÅgbar ... */
		conf.font.id = vqt_name(tb.vdi_handle, 1, tbuf);
		if (tb.ch_h == 8)
			conf.font.size = 9;
		else
			conf.font.size = 10;
		frm_alert(1, rs_frstr[ALNOPFONT], altitle, conf.wdial, 0L);
	}

	/* PrÅfen, ob der Font fÅr das Console-Fenster verfÅgbar ist */
	fok = 0;
	for (i = 0; i < gdos.numfonts; i++) {
		if (gdos.fontid[i * 2L] == con.font.id)
			fok = 1;
	}
	if (!fok) {
		/* Zeichensatz nicht verfÅgbar ... */
		con.font.id = vqt_name(tb.vdi_handle, 1, tbuf);
		if (tb.ch_h == 8)
			con.font.size = 9;
		else
			con.font.size = 10;
		frm_alert(1, rs_frstr[ALNOCFONT], altitle, conf.wdial, 0L);
	}

	/* MenÅ, Desktop, Maus */
	menu_bar(rs_trindex[MAINMENU], 1);
	if (conf.imguse)
		glob.img_ok =
		conf.imguse = desk_iload(&glob.img_info, conf.imgname, conf.imgpal, ALIMGERR);
	else
	glob.img_ok = 0;
	if (*conf.dirimg)
		glob.dir_ok = desk_iload(&glob.dir_img, conf.dirimg, 0, ALDIRIMGERR);

	{
		short parm1, parm2;
		long2int ( (long )rs_trindex[DESKTOP], &parm1, &parm2);
	  wind_set(0, WF_NEWDESK, parm1, parm2, ROOT, 0);
	}
	mn_update();
	graf_mouse(ARROW, 0L);
	glob.menu = 1;

	/* Handler fÅr Modale Dialoge installieren, Teil 2 */
	tb.modal_on = mn_disable;
	tb.modal_off = mn_update;

#ifdef _DEBUG
	debugMain("MAIN: final startup (draw desktop, open windows etc.) ...");
#endif

	/* Desktop aufbauen, Fenster îffnen */
	if (tb.sys & SY_MULTI) {
		glob.initialisation = 1;
		wind_restore(1);
		glob.initialisation = 0;
	} else {
		openwin = glob.openwin;
		glob.openwin = 0L;
	}

	/* Autostart-Applikationen anwerfen */
	rex = 0;
	if (!glob.tmp) {
		aptr = desk.appl;
		while (aptr) {
			if (aptr->autostart)
				app_start(aptr, "", 0L, &rex);
			aptr = aptr->next;
		}
	}

	if (!(tb.sys & SY_MULTI)) {
		glob.openwin = openwin;
		glob.initialisation = 1;
		wind_restore(!rex);
		glob.initialisation = 0;
	}

#ifdef _DEBUG
	debugMain("MAIN: ... final startup done");
#endif

	return (1); /* Rueckgabe: OK */
}

/**-------------------------------------------------------------------------
 main_exit()

 Programmdeinitialisierung
 -------------------------------------------------------------------------*/
void main_exit(void) {
	FORMINFO *fi, *fi1;
	short i, d, ks;
	UGNAME *j, *hlp;
	ICONDESK *p;

#ifdef _DEBUG
	debugMain("MAIN: ... exit start");
#endif

	/* Ggf. Einstellungen sichern */
	graf_mkstate(&d, &d, &d, &ks);
	if ((ks == K_LSHIFT) || (ks == K_RSHIFT))
		glob.done = 1;
LINOUT
	if (conf.autosave && (glob.done == 2))
		conf_save(0);
LINOUT
	/* Offene Dialoge schliessen */
	fi = tb.fi;
LINOUT
	while (fi) {
		fi1 = fi->next;
		fi->exit(1, 0);
		fi = fi1;
	}

	/* SendTo-Gruppe freigeben */
LINOUT
	if (glob.sendto != NULL) {
LINOUT
		while (glob.sendto->entry)
			wgrp_remove(glob.sendto, glob.sendto->entry);
		pfree(glob.sendto);
	}

	/* Hotkeys freigeben */
LINOUT
	free_hotkeys();

	/* Fenster schlieûen */
	glob.closeall = 1;
LINOUT
	while (tb.win) {
		tb.topwin = tb.win;
		dl_closewin();
	}
LINOUT
	glob.closeall = 0;

	/* Userdefs aus den Dialogen entfernen */
	if (conf.userdef) {
LINOUT
		for (i = 0; i < rinfo.rsc_file->rsh_ntree; i++)
			unsetUserdefs(rs_trindex[i]);
	}

	/* Bei Alice abmelden und angemeldete Fenster rauswerfen */
LINOUT
	if (glob.alice) {
LINOUT
		if (glob.alice->magic == 'ALIC')
			glob.alice->redraw_ap_id = -1;
	}
	while (glob.alicewin)
		alw_remove(glob.alicewin);

	/* Sonstige Aufraeumarbeiten */
LINOUT
	if (desk.wicon)
		pfree(desk.wicon);
LINOUT
	if (desk.dicon) {
LINOUT
		/* Laufwerks-Infos wurden _nicht_ Åber desk... reserviert ! */
		p = desk.dicon + 1;
LINOUT
		for (i = 1; i <= MAXDRIVES; i++, p++)
			p->spec.data = 0L;
LINOUT
		if (drive)
			pfree(drive);
LINOUT

		p = desk.dicon + 1;
LINOUT
		for (i = 1; i <= MAXICON; i++, p++)
			if (p->spec.data)
				pfree(p->spec.data);
LINOUT
		pfree(desk.dicon);
LINOUT
	}
LINOUT
	while (desk.appl)
		app_remove(desk.appl);
LINOUT
	if (desk.icon)
		Mfree(desk.icon);
LINOUT

	/* Deinitialisieren */
	if (glob.menu) {
		wind_set(0, WF_NEWDESK, 0, 0, 0, 0);
LINOUT
		menu_bar(rs_trindex[MAINMENU], 0);
LINOUT
	}

LINOUT
	desk_ifree(&glob.img_info);
LINOUT
	desk_ifree(&glob.dir_img);
LINOUT
	glob.img_ok = glob.dir_ok = 0;

	/* AV-Infos loeschen */
LINOUT
	while(glob.accstate)
		astate_remove(glob.accstate);
LINOUT
	while(glob.avinfo)
		avp_remove(glob.avinfo);
LINOUT
	while(glob.accwin)
		acwin_remove(glob.accwin);

LINOUT
	av_exit();
LINOUT

	/* Farbicons freigeben */
LINOUT
	if (glob.rtree)
		rsc_free(&glob.rinfo);
LINOUT

	/* GDOS freigeben */
	if (gdos.mfontid)
		pfree(gdos.mfontid);
LINOUT
	if (gdos.fontid)
		pfree(gdos.fontid);
LINOUT
	if (gdos.mfontname)
		pfree(gdos.mfontname);
LINOUT
	if (gdos.fontname)
		pfree(gdos.fontname);
LINOUT
	if (gdos.fontlist)
		pfree(gdos.fontlist);

	/* Console deinitialisieren */
LINOUT
	cwin_exit();

LINOUT
	for (j = glob.usernames; j != NULL;) {
LINOUT
		hlp = j;
		j = j->next;
		free(hlp);
	}
	for (j = glob.groupnames; j != NULL;) {
LINOUT
		hlp = j;
		j = j->next;
		free(hlp);
	}

LINOUT
	if (glob.editfields != NULL)
		pfree(glob.editfields);
LINOUT
	/* Hauptresourcen freigeben */
	rsc_free(&rinfo2);
LINOUT
	rsc_free(&rinfo);
LINOUT
	exit_cicon();
LINOUT
	tool_exit();
LINOUT
}

/**-------------------------------------------------------------------------
 main_loop()

 Hauptschleife des Programms
 -------------------------------------------------------------------------*/
void main_loop(void) {
	short i, j, top, fdraw;
	short evdone, ret;
	WININFO *win, *twin;
	W_GRP *wgrp;
	char *fname, *fpath, *p;
	char full[MAX_PLEN];
	short fid;
	EVENT copy;

	graf_mkstate(&mevent.ev_mm1x, &mevent.ev_mm1y, &mevent.ev_mmokstate, &mevent.ev_mbreturn);
	clr_drv();
	mn_update();

	glob.done = 0;
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

		/* Message abwarten */
		EvntMulti(&mevent);

		mevent.ev_mm1x = mevent.ev_mmox;
		mevent.ev_mm1y = mevent.ev_mmoy;

		/*
		 * Bei Bedarf vor der Message-Auswertung Aenderung des aktiven Fenster
		 * beruecksichtigen.
		 */
		if (!(tb.sys & SY_MULTI || tb.sys & SY_WINX)) {
			get_twin(&top);

			/* Falls aktives Fenster sich geaendert hat, dann Menues updaten */

			/* Bisher aktives Fenster vorhanden */
			if (tb.topwin) {
				if (top <= 0) {
					/* Kein Fenster mehr aktiv! */
					tb.topwin = 0L;
					tb.topfi = 0L;
					mn_update();
				} else if (top != tb.topwin->handle) {
					/* Fenster aktiv, aber anderes als bisher! */
					tb.topwin = win_getwinfo(top);
					mn_update();
				}
			} else {
				/* Bisher kein Fenster aktiv, aber jetzt ist eins aktiv? */
				if (top) {
					tb.topwin = win_getwinfo(top);
					mn_update();
				}
			}
			win_newtop(tb.topwin);

			/* Cursor ggf. abschalten */
			if (glob.fmode && tb.topwin != glob.fwin)
				wf_clear();
		}

		/* Timer */
		if (mevent.ev_mwich & MU_TIMER) {
			/* Geaenderte Gruppen ggf. sichern */
			glob.gtimer--;
			if (glob.gtimer <= 0) {
				glob.gtimer = 0;
				win = tb.win;
				while (win) {
					if (win->class==WCGROUP) {
						wgrp = (W_GRP *) win->user;
						if (wgrp->changed && wgrp->autosave) {
							twin = tb.topwin;
							tb.topwin = win;
							dl_savegrp();
							tb.topwin = twin;
						}
					}
					win = win->next;
				}
			}

			/* Ggf. Laufwerke aktualisieren */
			dl_drives(1, 1, 0);

			/* Cursorblinken */
			if (glob.fmode) {
				/* Blinken nur im aktiven Fenster */
				if (tb.topwin) {
					wf_draw();
					glob.fdraw = 1 - glob.fdraw;
				}
				fdraw = glob.fdraw;
			} else
				fdraw = 0;
		}

		/* Falls kein Timer fuer Cursorblinken, dann hier den Cursor abschalten */
		fdraw = 0;
		if ((mevent.ev_mwich & (MU_MESAG | MU_KEYBD | MU_BUTTON)) != 0) {
			if (glob.fmode && glob.fdraw) {
				fdraw = 1;
				wf_draw();
				glob.fdraw = 0;
			}
		}

		/* AES-Message */
		if (mevent.ev_mwich & MU_MESAG) {
			short *msg;

			msg = mevent.ev_mmgpbuf;
			switch (msg[0]) {
			/* Freedom-Dateiauswahl */
			case FILE_SELECTED:
				fid = msg[3];
				memcpy(&fpath, &msg[4], 4L);
				memcpy(&fname, &msg[6], 4L);
				if (fname != 0L) {
					strcpy(full, fpath);
					p = strrchr(full, '\\');
					if (p)
						strcpy(&p[1], fname);
					else
						strcat(full, fname);
					p = strrchr(full, '\\');
					if (!p)
						p = full;
					/* Je nach ID reagieren */
					switch (fid) {
					case 1: /* Datei - oeffnen */
						if (p[1])
							va_open(full);
						else
							wpath_open(full, "*", 0, "", conf.index.text, -1, conf.index.sortby);
						break;
					}
				}
				break;

			/* Shutdown */
			case AP_TERM:
				/* Shutdown unter MagiC 3.x? */
				if ((tb.sys & SY_MSHELL) && (msg[1] == -1))
					dl_shutdown();
				else
					glob.done = 2;
				break;

			/* Drag&Drop */
			case AP_DRAGDROP:
				handle_dd(msg);
				break;

			/* Verschiedenes */
			case FONT_CHANGED:
			case FONT_SELECT:
				handle_fontmsg(msg);
				break;

			/* Messages des AV-Protokolls */
			case AV_PROTOKOLL:
				avs_protokoll(msg);
				break;
			case AV_GETSTATUS:
				avs_getstatus(msg);
				break;
			case AV_STATUS:
				avs_status(msg);
				break;
			case AV_SENDKEY:
				avs_sendkey(msg);
				break;
			case AV_ASKFILEFONT:
				avs_askfilefont(msg);
				break;
			case AV_ASKCONFONT:
				avs_askconfont(msg);
				break;
			case AV_OPENWIND:
				avs_openwind(msg);
				break;
			case AV_STARTPROG:
				avs_startprog(msg);
				break;
			case AV_ACCWINDOPEN:
				avs_accwindopen(msg);
				break;
			case AV_ACCWINDCLOSED:
				avs_accwindclosed(msg);
				break;
			case AV_PATH_UPDATE:
				avs_path_update(msg);
				break;
			case AV_COPY_DRAGGED:
				avs_copy_dragged(msg);
				break;
			case AV_WHAT_IZIT:
				avs_what_izit(msg);
				break;
			case AV_DRAG_ON_WINDOW:
				avs_drag_on_window(msg);
				break;
			case AV_EXIT:
				avs_exit(msg);
				break;
			case AV_XWIND:
				avs_xwind(msg);
				break;
			case VA_START:
				avs_vastart(msg);
				break;
			case AV_VIEW:
				avs_view(msg);
				break;
			case AV_FILEINFO:
				avs_fileinfo(msg);
				break;
			case AV_COPYFILE:
				avs_copyfile(msg, 0);
				break;
			case AV_DELFILE:
				avs_copyfile(msg, 1);
				break;
			case AV_SETWINDPOS:
				break;

			/* Menueauswahl */
			case MN_SELECTED:
				copy = mevent;
				handle_menu(msg[3], msg[4], mevent.ev_mmokstate);
				mevent = copy;
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

			/* Weitere Messages */
			case 80: /* CH_EXIT bei Geneva *grummel* */
				if (!(tb.sys & SY_GNVA))
					break;
				/* else Fall through */
			case CH_EXIT: /* Programm wurde beendet */
				if (conf.autoupdate) {
					/* Verzeichnisse und Menues aktualisieren */
					for (j = 0; j < 2; j++) {
						for (i = 0; i < MAX_PWIN; i++) {
							if (glob.win[i].state & WSOPEN) {
								if (j == 0) {
									wpath_lfree(&glob.win[i]);
								} else {
									wpath_update(&glob.win[i]);
									win_redraw(&glob.win[i], tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h);
								}
							}
						}
					}
					mn_update();
				}
				break;

			case SH_WDRAW: /* Unter Mag!X/MultiTOS: Inhalt eines Laufwerks wurde geaendert. */
				for (i = 0; i < MAX_PWIN; i++) {
					if (glob.win[i].state & WSOPEN) {
						if (msg[3] == -1) {
							wpath_update(&glob.win[i]);
							win_redraw(&glob.win[i], tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h);
						} else {
							if (((W_PATH *) glob.win[i].user)->filesys.biosdev == msg[3]) {
								wpath_update(&glob.win[i]);
								win_redraw(&glob.win[i], tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h);
							}
						}
					}
				}
				mn_update();
				break;

			case THING_MSG: /* Thing-Command */
				/* Job - nur wenn MagiC stimmt und Thing selber der Absender war */
				if (msg[3] == TI_JOB && msg[5] == 0x4711 && msg[1] == tb.app_id) {
					handle_job(&mevent);
				} else {
					tp_handle(&mevent);
					mn_update();
				}
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
					show_help(tb.topfi->userinfo);
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
			if (mevent.ev_mwich & MU_KEYBD) {
				handle_key(mevent.ev_mmokstate, mevent.ev_mkreturn);
				mevent.ev_mwich &= ~MU_BUTTON;
			}

			/* Maustaste */
			if (mevent.ev_mwich & MU_BUTTON)
				handle_button(mevent.ev_mmox, mevent.ev_mmoy, mevent.ev_mmobutton, mevent.ev_mmokstate, mevent.ev_mbreturn);
		}

		/* Falls Cursor-Fenster nicht mehr aktiv, aber ein Anderes von
		 Thing, dann den Cursor ebenfalls deaktivieren */
		if (glob.fmode && tb.topwin && glob.fwin != tb.topwin) {
			wf_clear();
		} else {
			/* Andernfalls den Cursor wieder einschalten, falls er vorher
			 vor der Event-Behandlung ausgeschaltet wurde */
			if (glob.fmode && fdraw) {
				wf_draw();
				glob.fdraw = 1 - glob.fdraw;
			}
		}
	}
}

/**-------------------------------------------------------------------------
 Programmstart
 -------------------------------------------------------------------------*/
short main(void) {
	short ret;

	ret = main_init();
	if (ret) {
DEBUGLOG((0, "main: Initialisation complete - entering main_loop()\n"));
		main_loop();
DEBUGLOG((0, "main: Exit from main_loop() - cleaning up..."));
		main_exit();
DEBUGLOG((0, "done.\n"));
		return (0);
	} else {
		main_exit();
		return (10);
	}
}

/* EOF */
