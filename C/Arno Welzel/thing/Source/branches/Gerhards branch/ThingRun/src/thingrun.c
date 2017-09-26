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
 THINGRUN.C
 
 Thing
 Utility zum Starten von Applikationen in einem Single-TOS. Wird von
 Thing als GEM-Applikation nachgeladen.
 =========================================================================*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <gem.h>
#include <mintbind.h>
#include <signal.h>
#include <magx.h>
#ifdef __MINT__
#include <basepage.h>
#define _BasPag _base
#endif
#include <portab.h>
#include <ctype.h>
#include "thingrun.h"
#include "thingrun.rh"
#include "thingrun.rsh"

char *app_argv(char *cmd, char *prog);
void sigNix(void);
void sigTerm(void);

short quit;

main(short argc, char *argv[]) {
	short i, is_gr, multi = 0, dx, dy, dw, dh;
	FILE *fh;
	char homepath[128], path[128], name[128];
	char *cmd, *abuf, acmd[2];
	short clen;
	char fname[128], tname[128];
	short work_in[] = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1 }, work_out[57];
	short vdi_handle;
	short toswait;
	char scmd[256], stail[256];

	/* Keine Parameter erhalten, dann raus */
	if (argc < 2) {
		if (appl_init() < 0)
			return (1);
		multi = 1;
		strcpy(fname, "thingrun.par");
		if (!shel_find(fname)) {
			form_alert(1, rs_fstr[ALINFO]);
			return 1;
		}
		argv[1] = fname;
	}

	if (argc > 2) {
		if (appl_init() < 0)
			return (1);
		multi = 1;
	}

	/* Resourcen initialisieren */
	for (i = 0; i < RS_NOBS; i++)
		rsrc_obfix(&rs_obj[i], 0);

	/* Virtuelle VDI-Workstation oeffnen und Desktop-Groesse ermitteln */
	vdi_handle = graf_handle(&i, &i, &i, &i);
	v_opnvwk(work_in, &vdi_handle, work_out);
	if (!vdi_handle) {
		if (multi)
			appl_exit();
		return 0;
	}
	wind_get(0, WF_WORKXYWH, &dx, &dy, &dw, &dh);

	/* Buffer fuer Kommandozeile reservieren */
	cmd = malloc(8193L);
	if (!cmd) {
		form_alert(1, rs_fstr[ALNOMEM]);
		v_clsvwk(vdi_handle);
		if (multi)
			appl_exit();
		return (0);
	}

	/* Daten der Applikation lesen */
	fh = fopen(argv[1], "r");
	if (!fh) {
		v_clsvwk(vdi_handle);
		if (multi)
			appl_exit();
		return 0;
	}

	fgets(tname, 127, fh);
	tname[(short) strlen(tname) - 1] = 0;
	fgets(path, 127, fh);
	sscanf(path, "%d", &is_gr);
	fgets(path, 127, fh);
	path[(short) strlen(path) - 1] = 0;
	fgets(name, 127, fh);
	name[(short) strlen(name) - 1] = 0;
	strcpy(fname, path);
	strcat(fname, name);
	cmd[1] = 0;
	fgets(&cmd[1], 8192, fh);
	if (cmd[1]) {
		clen = (short) strlen(&cmd[1]);
		cmd[clen] = 0;
		clen--;
		if (clen > 125) {
			/* Parameteruebergabe mit ARGV */
			acmd[0] = 127;
			acmd[1] = 0;
			abuf = app_argv(&cmd[1], fname);
		} else {
		/* Normale Parameteruebergabe */
			abuf = 0L;
			cmd[0] = (char) clen;
		}
	} else {
		cmd[0] = 0;
		cmd[1] = 0;
	}
	fgets(homepath, 127, fh);
	homepath[(short) strlen(homepath) - 1] = 0;
	if (!homepath[2]) {
		homepath[2] = '\\';
		homepath[3] = 0;
	}
	fscanf(fh, "%d", &toswait);
	fclose(fh);
	Fdelete(argv[1]);

	/* Programm starten */
	if (multi) {
		char *backslash;
		short msg[8];
		short new_app;
		short has_wdef;
		short du;
		long mpar[5];

		quit = 0;
		if (appl_getinfo(5, &du, &du, &du, &has_wdef) == 0)
			has_wdef = 0;

		/* Einige MiNT-Signal-Handler installieren */
		Psignal(SIGINT, 1L );
		Psignal(SIGSYS, 1L );
		Psignal(SIGABRT, 1L );
		Psignal(SIGTERM, (long) sigTerm );
		Psignal(SIGQUIT, 1L );
		Psignal(SIGHUP, 1L );

		/* Thing etwas Zeit geben, sich zu beenden */
		evnt_timer(1000L);

		mpar[0] = (long) fname;
		mpar[1] = 0L;
		mpar[2] = 0L;
		mpar[3] = (long) homepath;
		mpar[4] = (long) _BasPag->p_env;
		if (abuf)
			cmd[0] = 0xff;
		new_app = shel_write(0xc01, 1, abuf ? 1 : 0, (char *) mpar, cmd);
		if (!new_app)
			quit = 1;

		while (!quit) {
			evnt_multi(MU_TIMER | MU_MESAG, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, msg, 100L, &i, &i, &i, &i, &i, &i);
			if (((msg[0] == 80) || (msg[0] == 90)) && (msg[3] == new_app))
				quit = 1;
		}
		if (abuf)
			free(abuf);

		/* VDI-Workstation schliessen und Thing starten */
		v_clsvwk(vdi_handle);
		cmd[0] = 0;
		cmd[1] = 0;
		strcpy(homepath, tname);
		if ((backslash = strrchr(homepath, '\\')) != 0L) {
			strcpy(name, ++backslash);
			*backslash = 0;
		} else
			strcpy(name, "");

		if (!homepath[2]) {
			homepath[2] = '\\';
			homepath[3] = 0;
		}
#ifdef USE_WDEF
		if (has_wdef)
			shel_wdef(name, homepath);
		else {
#endif
		mpar[0] = (long) tname;
		mpar[1] = 0L;
		mpar[2] = 0L;
		mpar[3] = (long) homepath;
		mpar[4] = (long) _BasPag->p_env;
		shel_write(0x401, 1, 0, (char *) mpar, cmd);
#ifdef USE_WDEF
	}
#endif
		appl_exit();
		return (0);
	}
	Dsetdrv((homepath[0] & ~32) - 65);
	Dsetpath(&homepath[2]);

	wind_update(BEG_UPDATE);
	wind_new();
	shel_write(1, is_gr, 0, fname, cmd);

	/* Bildschirm-Darstellung anpassen */
	if (is_gr) {
		/* Grafik-Applikation */
		strcpy(rs_tree[DESKAPP]->ob_spec.tedinfo->te_ptext, name);
		rs_tree[DESKAPP]->ob_x = 0;
		rs_tree[DESKAPP]->ob_y = 0;
		rs_tree[DESKAPP]->ob_width = dw;
		rs_tree[DESKAPP]->ob_height = dy - 1;
		objc_draw(rs_tree[DESKAPP], ROOT, MAX_DEPTH, 0, 0, dw, dy - 1);
	} else {
		/* Text-Applikation */
		v_hide_c(vdi_handle);
		v_enter_cur(vdi_handle);

		/* VT52-Zeilenumbruch einschalten */
		Cconws("\33v");
	}
	if (abuf) {
		Pexec(0, fname, acmd, abuf);
		free(abuf);
	} else {
		start1: ;
		Pexec(0, fname, cmd, 0L);
	}

	if (!is_gr) {
		/* Bei Bedarf auf Tastendruck warten */
		if (toswait) {
			printf("%s\n", rs_fstr[TXTOSWAIT]);
			fflush(stdout);
			Cnecin();
		}
		v_exit_cur(vdi_handle);
		v_show_c(vdi_handle, 1);
	} else {
		/* Ende einer GEM-Applikation - hier ggf. noch ausstehende shel_write() abfragen */
		if (shel_read(scmd, stail) != 0) {
			scmd[0] = toupper(scmd[0]);
			if (scmd[0] >= 'A' && scmd[0] <= 'Z' && strcmp(scmd, fname) != 0) {
				strcpy(fname, scmd);
				strcpy(cmd, stail);
				wind_update(BEG_UPDATE);
				wind_new();
				form_dial(FMD_FINISH, dx, dy, dw, dh, dx, dy, dw, dh);
				goto start1;
			}
		}
	}

	/* VDI-Workstation schliessen und Thing starten */
	v_clsvwk(vdi_handle);
	cmd[0] = 0;
	cmd[1] = 0;
	shel_write(1, 1, 1, tname, cmd);

	return 0;
}

/*-------------------------------------------------------------------------
 app_argv()
 
 Erzeugt ein neues Environment fuer die šbergabe von Parametern an
 ein Programm mit dem ARGV-Verfahren, dass mit Pexec() gestartet
 wird.
 -------------------------------------------------------------------------*/
char *app_argv(char *cmd, char *prog) {
	char *env, *new;
	short elen, nlen, i, p, done;

	/* Groesse des aktuellen Environments ermitteln */
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

	/* Groesse fuer ARGV-Buffer berechnen */
	nlen += 9; /* 'ARGV=1\0\0' und abschliessendes Doppelnullbyte */
	nlen += ((short) strlen(prog)) + 1; /* Programmname als argv[0] */
	nlen += ((short) strlen(cmd)) + 1; /* Parameter ab argv[1] */

	/* Buffer reservieren */
	new = malloc(nlen);
	if (!new) {
		form_alert(1, rs_fstr[ALNOMEM]);
		return 0L;
	}

	/* Bisheriges Environment kopieren */
	memcpy(new, env, elen);

	/* ARGV-Buffer aufbauen */
	strcpy(&new[elen], "ARGV=1");
	p = elen + 7;

	/* argv[0] - Programmname */
	i = 0;
	while (prog[i]) {
		new[p] = prog[i];
		i++;
		p++;
	}
	new[p] = 0;
	p++;

	/* argv[1..n] */
	done = 0;
	i = 0;

	/* Leerstellen am Anfang rausschmeissen */
	while (cmd[i] && cmd[i] == ' ')
		i++;

	while (!done) {
		while (cmd[i] && cmd[i] != ' ') {
			new[p] = cmd[i];
			i++;
			p++;
		}
		new[p] = 0;
		p++;

		/* Ende erreicht? */
		if (cmd[i] == ' ') {
			while (cmd[i] == ' ')
				i++;
			if (!cmd[i])
				done = 1;
		} else
			done = 1;
	}
	/* Abschluss des Environments */
	new[p] = 0;

	return (new);
}

void sigNix(void) {
}

void sigTerm(void) {
	quit = 1;
}
