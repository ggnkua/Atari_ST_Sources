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

/**
 * Kobold-Einbindung
 */

#include "..\include\globdef.h"
#include "..\include\types.h"
#include "rsrc\thing_de.h"
#include "rsrc\thgtxtde.h"
#include <ctype.h>

/*-------------------------------------------------------------------------
 KOBOLD-Messages und lokale Variablen
 -------------------------------------------------------------------------*/
#define KBD_JOB    0x2f10  /* Job ausfuehren */
#define KBD_JOB_NW 0x2f11  /* Job ohne Hauptdialog ausfuehren */
#define KBD_CLOSE  0x2f16  /* Hauptdialog schliessen */
#define KBD_FREE   0x2f17  /* Laufwerke freigeben */
#define KBD_ANS    0x2f12  /* Antwort von Kobold */

static char *kbuf; /* Puffer fuer den Kobold-Job */

/**
 * Puffer fuer Kobold-Job anlegen.
 *
 * @return 1 - alles OK, 0 - sonst
 */
int kbd_newjob(void) {
#ifdef _DEBUG
	sprintf(almsg, "KOBD: allocating new job buffer, len=%ld, xalloc=%d", MAX_KBDLEN, tb.sys & SY_XALLOC); debugMain(almsg);
#endif
	if (tb.sys & SY_XALLOC)
		kbuf = Mxalloc(MAX_KBDLEN, 0x23); /* Global, TT preferred */
	else
		kbuf = Malloc(MAX_KBDLEN);
	if (!kbuf) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return (0);
	}
	kbuf[0] = 0;

	return (1);
}

/**
 * Kommando in den Kobold-Job aufnehmen.
 *
 * @return 1 - alles OK, 0 - sonst
 */
int kbd_addcmd(char *cmd) {
	long blen, clen;

#ifdef _DEBUG
	sprintf(almsg, "KOBD: add job command, text=%s", cmd); debugMain(almsg);
#endif

	blen = strlen(kbuf);
	clen = strlen(cmd);
	if (blen + clen < MAX_KBDLEN) {
		strcat(kbuf, cmd);
		return (1);
	}

	return (0);
}

/*-------------------------------------------------------------------------
 kbd_startjob()

 Erzeugten Kobold-Job ausfhren
 -------------------------------------------------------------------------*/
void kbd_startjob(void) {
	int kid, i, j, done, rex, reply = -1;
	char kname[9], *p;
	EVENT kevent;
	APPLINFO appl, *aptr;
	int whandle;
	char kcmd[MAX_PLEN];
	int was_there = 0;

#ifdef _DEBUG
	sprintf(almsg, "KOBD: start job"); debugMain(almsg);
#endif

	/* Pruefen, ob Kobold bereits aktiv ist */
	strcpy(kname, "KOBOLD  ");
	kid = -1;
	p = strrchr(conf.kb_prog, '\\');
	if (p) {
		if (p[1]) {
			i = 1;
			j = 0;
			while (j < 8 && p[i] && p[i] != '.') {
				kname[j] = p[i];
				i++;
				j++;
			}
			while (j < 8) {
				kname[j] = ' ';
				j++;
			}
			kname[j] = 0;
			strupr(kname);
			kid = appl_find(kname);
		}
	}

	/* Wenn Kobold schon lief, den Job mit QUIT beenden, sonst mit EXIT */
	if (kid >= 0) {
		kbd_addcmd("QUIT\n");
		was_there = 1;
	} else
		kbd_addcmd("EXIT\n");

	/* APPLINFO fuer Kobold vorbereiten */
	strcpy(appl.name, conf.kb_prog);
	aptr = app_find(appl.name);
	if (!aptr) {
		app_default(&appl);
		strcpy(appl.title, "Kobold 2");
		aptr = &appl;
	}

	/* Kobold nicht aktiv - unter Multitasking jetzt starten */
	if (kid < 0 && (tb.sys & SY_MULTI)) {
		int ao, as, ct;

		ao = aptr->overlay;
		as = aptr->single;
		ct = conf.texit;
		aptr->overlay = aptr->single = conf.texit = 0;
#ifdef _DEBUG
		sprintf(almsg, "KOBD: kobold not active, multitasking present, now launching"); debugMain(almsg);
#endif
		app_start(aptr, "KOBOLD_JOB_NO_WINDOW 0", 0L, &rex);
		aptr->overlay = ao;
		aptr->single = as;
		conf.texit = ct;
		kid = appl_find(kname);
		evnt_timer(500, 0);
		kid = appl_find(kname);
	}

	if (kid >= 0) {
#ifdef _DEBUG
		sprintf(almsg, "KOBD: kobold active, sending job-command"); debugMain(almsg);
#endif
		/* Kobold aktiv, dann via Job-Protokoll uebergeben */
		mn_disable();
		tb.sm_modal++;

		aesmsg[0] = KBD_JOB_NW;
		aesmsg[1] = tb.app_id;
		aesmsg[2] = 0;
		long2int((long) kbuf, &aesmsg[3], &aesmsg[4]);
		appl_write(kid, 16, aesmsg);

#ifdef _DEBUG
		sprintf(almsg, "KOBD: now waiting for reply"); debugMain(almsg);
#endif
		/* Antwort abwarten */
		kevent.ev_mflags = MU_MESAG;
		done = 0;
		while (!done) {
			EvntMulti(&kevent);
			if (kevent.ev_mwich & MU_MESAG) {
				switch (kevent.ev_mmgpbuf[0]) {
				case WM_CLOSED:
				case WM_ICONIFY:
				case WM_ALLICONIFY:
				case WM_UNICONIFY:
					mybeep();
					break;
				case WM_M_BDROPPED:
				case WM_BOTTOMED:
				case WM_UNTOPPED:
				case WM_REDRAW:
				case WM_NEWTOP:
				case WM_ONTOP:
				case WM_FULLED:
				case WM_ARROWED:
				case WM_HSLID:
				case WM_VSLID:
				case WM_SIZED:
				case WM_MOVED:
				case WM_TOPPED:
					handle_win(kevent.ev_mmgpbuf[3], kevent.ev_mmgpbuf[0],
							kevent.ev_mmgpbuf[4], kevent.ev_mmgpbuf[5],
							kevent.ev_mmgpbuf[6], kevent.ev_mmgpbuf[7],
							kevent.ev_mmokstate);
					break;
				case AV_PROTOKOLL:
					avs_protokoll(kevent.ev_mmgpbuf);
					break;
				case AV_ACCWINDOPEN:
					avs_accwindopen(kevent.ev_mmgpbuf);
					break;
				case AV_ACCWINDCLOSED:
					avs_accwindclosed(kevent.ev_mmgpbuf);
					break;
				case AV_EXIT:
					avs_exit(kevent.ev_mmgpbuf);
					break;
				case AV_GETSTATUS:
					avs_getstatus(kevent.ev_mmgpbuf);
					break;
				case AV_STATUS:
					avs_status(kevent.ev_mmgpbuf);
					break;
				case AV_WHAT_IZIT:
					aesmsg[0] = VA_THAT_IZIT;
					aesmsg[3] = tb.app_id;
					appl_write(kevent.ev_mmgpbuf[1], 16, aesmsg);
					break;
				case AP_TERM: /* Shutdown zu diesem Zeitpunkt nicht moeglich! */
					aesmsg[0] = AP_TFAIL;
					aesmsg[1] = 1;
					aesmsg[2] = 0;
					aesmsg[3] = 0;
					aesmsg[4] = 0;
					aesmsg[5] = 0;
					aesmsg[6] = 0;
					aesmsg[7] = 0;
					shel_write(SHW_AESSEND, 0, 0, (char *) aesmsg, 0L);
					break;
				case KBD_ANS:
#ifdef _DEBUG
					sprintf(almsg, "KOBD: got reply :-)"); debugMain(almsg);
#endif
					/* Hat Kobold etwas anderes als 'Finish' gemeldet? */
					if ((reply = kevent.ev_mmgpbuf[3]) != -1) {
						/* An Kobold: Laufwerke freigeben und ggf. schliessen */
						if (was_there)
							aesmsg[0] = KBD_FREE;
						else
							aesmsg[0] = KBD_CLOSE;
						appl_write(kid, 16, aesmsg);
					}
					done = 1;
					break;
				}
			}
		}
		get_twin(&whandle);
		tb.topwin = win_getwinfo(whandle);
		win_newtop(tb.topwin);
		tb.sm_modal--;
		mn_update();
	} else {
		/* Kobold nicht aktiv - dann direkt mit Job starten */
		sprintf(&kcmd[1], "KOBOLD_JOB_NO_WINDOW %ld", kbuf);
		kcmd[0] = (char) strlen(&kcmd[1]);
		{
#if 1
			char path[MAX_PLEN], name[MAX_FLEN];

			full2comp(aptr->name, path, name);
			set_dir(path);
#endif
			Pexec(0, aptr->name, kcmd, 0L);
#if 1
			form_dial(FMD_FINISH, tb.desk.x, tb.desk.y, tb.desk.w, tb.desk.h, tb.desk.x, tb.desk.y, tb.desk.w, tb.desk.h);
#endif
		}
	}
	/* Job-Buffer freigeben */
	Mfree(kbuf);

#ifdef _DEBUG
	sprintf(almsg, "KOBD: releasing buffer"); debugMain(almsg);
#endif

	/* 'Patch' - Verzeichnisse aktualisieren */
#ifdef _DEBUG
	sprintf(almsg, "KOBD: updating path windows - may not be neccessary!"); debugMain(almsg);
	sprintf(almsg, "KOBD: explanation: kobold 2.x does not send SH_WDRAW some times!"); debugMain(almsg);
#endif
	if (reply != 3) {
		for (i = 0; i < MAX_PWIN; i++) {
			if (glob.win[i].state & WSOPEN) {
				wpath_update(&glob.win[i]);
				win_redraw(&glob.win[i], tb.desk.x, tb.desk.y, tb.desk.w, tb.desk.h);
			}
		}
	}
	mn_update();
}
