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
 CONFIG.C

 Thing
 Einstellungen sichern/laden
 =========================================================================*/

#include "..\include\globdef.h"
#include "..\include\types.h"
#include "..\include\thingrsc.h"
#include <ctype.h>

#undef VERY_OLD_CONFIG

/*-------------------------------------------------------------------------
 conf_save()
 conf_load()

 Einstellungen laden/sichern
 -------------------------------------------------------------------------*/

int conf_save(int tmp) {
	FILE *fh;
	int i, sh, sv, x, y, w, h;
	char *name, *rname;
	char *bname, *brname;
	APPLINFO *appl;
	char *fname;
	WININFO *win;
	double lx, ly, lw, lh;
	ACSTATE *accstate;
	AVINFO *avinfo;
	ACWIN *acwin;
	char *buf;
	HOTKEY *hkey;
	ICONDESK *p;

	name = pmalloc(MAX_PLEN * 5L);
	if (name == NULL) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return (0);
	}
	rname = name + MAX_PLEN;
	bname = rname + MAX_PLEN;
	brname = bname + MAX_PLEN;
	buf = brname + MAX_PLEN;

	if (tmp)
		fname = FNAME_INT; /* TemporÑre Datei */
	else
		fname = FNAME_INF; /* Normale Datei */

	/* Dateinamen erzeugen und Datei îffnen */
	strcpy(name, glob.cpath);
	strcat(name, fname);
#ifdef _DEBUG
	sprintf(almsg,"CSAV: name.inf=%s",fname);main_debug(almsg);
#endif

	/* Falls nicht temporÑr, dann vorher Backup erzeugen */
	if (!tmp) {
		strcpy(bname, glob.cpath);
		strcat(bname, "thing.bak");
		Fdelete(bname);
		Frename(0, name, bname);
#ifdef _DEBUG
		sprintf(almsg,"CSAV: backup.inf=%s",bname);main_debug(almsg);
#endif
	}

	fh = fopen(name, "w");
	if (fh) /* Nur schreiben, wenn Datei erzeugt wurde! */
	{
#ifdef _DEBUG
		sprintf(almsg,"CSAV: inf save begin");main_debug(almsg);
#endif
		/* Kurzinfo - wird beim Laden ignoriert */
		file_header(fh, "Thing general configuration", fname);
		fprintf(fh, "VERS %d\n", _VERS);

		/* Einstellungen */
		fprintf(fh,
				"CONF %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d\n",
				conf.wdial, conf.bsel, conf.hscr, conf.texit, conf.cdel,
				conf.ccopy, conf.creplace, conf.scroll, conf.isnap, conf.altcpx,
				conf.askacc, conf.nowin, conf.autocon, conf.toswait,
				conf.uset2g, conf.closebox, conf.altapp, conf.tosmode,
				conf.autoupdate, conf.cdial, conf.autocomp, conf.hidden,
				conf.vert, conf.vastart, conf.relwin, conf.autosel,
				conf.rdouble, conf.qread, conf.autosize, conf.usedel);
		fprintf(fh, "CNFG %d %d %d %d %d %d %d %d %d 0 "
				"0 0 0 0 0 0 0 0 0 0 0 0 0 0\n", conf.autosizex, conf.autosizey,
				conf.autoplace, conf.interactive, conf.nohotcloser,
				conf.autosave, conf.casesort, conf.caseloc, conf.hotkeys);
		fprintf(fh, "CBUF %ld\n", conf.cbuf);
		fprintf(fh, "US3D %d\n", tb.use3d);
		fprintf(fh, "UDEF %d\n", conf.userdef);
		fprintf(fh, "USBW %d\n", tb.backwin);
		fprintf(fh, "T2GM %d %d %d %d %d\n", con.buffer, con.color, con.hist,
				con.buftime, con.flags);
		fprintf(fh, "EXFI ");
		put_text(fh, conf.finder);
		fprintf(fh, "\n");
		fprintf(fh, "EXFO ");
		put_text(fh, conf.format);
		fprintf(fh, "\n");

		/* Clipboard-Pfad */
		strcpy(buf, desk.dicon[OBCLIP].spec.clip->path);
		quote(buf);
		fprintf(fh, "SCRP %s\n", buf);

		/* Einstellungen fuer Kobold */
		strcpy(buf, conf.kb_prog);
		quote(buf);
		fprintf(fh, "KBD2 %d %d %d %ld %d %s %d %d\n", conf.kbc_use,
				conf.kbd_use, conf.kbc_files, conf.kbc_size, conf.kbd_files,
				buf, conf.kbf_use, conf.kb_tosonly);
		fprintf(fh, "OKBD %d\n", conf.kbd_two);

		/* Nicelines verwenden? */
		fprintf(fh, "NICE %d\n", conf.nicelines);

		/* Index */
		fprintf(fh, "IDEX %d %d %d\n", conf.index.text, conf.index.sortby,
				conf.index.show);

		/* Funktionstasten */
		for (i = 0; i < 40; i++)
			if (conf.fkey[i][0]) {
				fprintf(fh, "FCKY %d ", i);
				put_text(fh, conf.fkey[i]);
				fprintf(fh, "\n");
			}

		/* Tool-Menue */
		for (i = 0; i < 10; i++)
			if (conf.tobj[i]) {
				fprintf(fh, "TOOL %d ", i);
				put_text(fh, conf.ttxt[i]);
				fprintf(fh, " ");
				put_text(fh, conf.tobj[i]);
				fprintf(fh, "\n");
			}

		/* Default-Applikation */
		fprintf(fh, "DFLT %d %d %d %d %d 0 0 0 0 0 0 0 0 0 0 0\n",
				defappl.homepath, defappl.single, defappl.vaproto,
				defappl.conwin, defappl.unixpaths);

		/* Applikationen */
		appl = desk.appl;
		while (appl) {
			fprintf(fh, "APPL ");
			put_text(fh, appl->title);
			strcpy(buf, appl->name);
			quote(buf);
			fprintf(fh, " %s ", buf);
			put_text(fh, appl->parm);
			fprintf(fh, " %d ", appl->homepath);
			put_text(fh, appl->fileopen);
			fprintf(fh, " ");
			put_text(fh, appl->fileview);
			fprintf(fh, " ");
			put_text(fh, appl->fileprint);
			fprintf(fh, " %d %d %d %d %d %d %d %d %d %d %d\n", appl->single,
					appl->vaproto, appl->getpar, appl->conwin, appl->shortcut,
					appl->autostart, appl->overlay, appl->usesel, appl->euse,
					appl->toswait, appl->dodrag);

			/* Zusaetzliche Applikationsoptionen */
			fprintf(fh, "AOPT %d %ld %d %d 1 0 0 0 0 0 ", appl->paralways,
					appl->memlimit, !appl->fullcompare, appl->unixpaths);
			put_text(fh, appl->alert);
			fprintf(fh, "\n");

			/* Environment */
			for (i = 0; i < MAX_EVAR; i++) {
				if (appl->evar[i]) {
					fprintf(fh, "AENV ");
					put_text(fh, appl->evar[i]);
					fprintf(fh, "\n");
				}
			}
			appl = appl->next;
		}

		/* Hotkeys */
		for (hkey = glob.hotkeys; hkey != NULL; hkey = hkey->next) {
			strcpy(buf, hkey->object);
			quote(buf);
			fprintf(fh, "HKEY %d %s\n", hkey->key, buf);
		}

		/* Laufwerksinformationen */
		p = desk.dicon + 1;
		for (i = 0; i < MAXDRIVES; i++, p++) {
			fprintf(fh, "DRIV %d %d %d 0 0 0 0 0 0 0 0\n", i,
					p->spec.drive->uselabel, p->spec.drive->autoinstall);
		}

		/* Verzeichnisfenster */
		for (i = 0; i < 16; i++) {
			if (glob.win[i].state & WSICON) {
				x = glob.win[i].save.x;
				y = glob.win[i].save.y;
				w = glob.win[i].save.w;
				h = glob.win[i].save.h;
			} else {
				x = glob.win[i].curr.x;
				y = glob.win[i].curr.y;
				w = glob.win[i].curr.w;
				h = glob.win[i].curr.h;
			}
			lx = (double) (x - tb.desk.x) * 10000L / (double) tb.desk.w;
			ly = (double) (y - tb.desk.y) * 10000L / (double) tb.desk.h;
			lw = (double) w * 10000L / (double) tb.desk.w;
			lh = (double) h * 10000L / (double) tb.desk.h;
			fprintf(fh, "WIXY %d %d %d %d %d\n", i, (int) lx, (int) ly,
					(int) lw, (int) lh);
		}

		/* Console-Fenster */
		if (con.win.state & WSICON) {
			x = con.win.save.x;
			y = con.win.save.y;
			w = con.win.save.w;
			h = con.win.save.h;
		} else {
			x = con.win.curr.x;
			y = con.win.curr.y;
			w = con.win.curr.w;
			h = con.win.curr.h;
		}
		lx = (double) (x - tb.desk.x) * 10000L / (double) tb.desk.w;
		ly = (double) (y - tb.desk.y) * 10000L / (double) tb.desk.h;
		lw = (double) w * 10000L / (double) tb.desk.w;
		lh = (double) h * 10000L / (double) tb.desk.h;
		fprintf(fh, "VTXY %d %d %d %d\n", (int) lx, (int) ly, (int) lw,
				(int) lh);

		/* Offene Fenster */
		if (tmp || !conf.nowin) {
			win = tb.win;
			while (win) {
				/* Dialogfenster nicht sichern! */
				if (win->class!=WCDIAL) {
					/* Angaben bei allen Fenstern */
					wind_get(win->handle, WF_HSLIDE, &sh);
					wind_get(win->handle, WF_VSLIDE, &sv);
					fprintf(fh,"WOPN %d %d %d %d ",win->class,win==tb.topwin,sh,sv);
					/* Weitere Angaben je nach Fenstertyp */
					switch (win->class) {
						case WCPATH: /* Verzeichnis */
						strcpy(buf, ((W_PATH *)win->user)->index.wildcard);
						quote(buf);
						fprintf(fh, "%s ", buf);
						strcpy(buf, ((W_PATH *)win->user)->path);
						quote(buf);
						fprintf(fh,"%s %d ", buf, ((W_PATH *)win->user)->rel);
						put_text(fh,((W_PATH *)win->user)->relname);
						fprintf(fh, " %d %d %d\n", ((W_PATH *)win->user)->index.text,
						((W_PATH *)win->user)->num,
						((W_PATH *)win->user)->index.sortby);
						break;
						case WCGROUP: /* Gruppe */
						strcpy(buf, ((W_GRP *)win->user)->name);
						quote(buf);
						fprintf(fh,". %s 0 \042\042 %d\n", buf,
						((W_GRP *)win->user)->text);
						break;
						case WCCON: /* Console */
						fprintf(fh,". . 0 \042\042\n");
						break;
					}
				}
				win = win->next;
			}
		}

		/* Status-Infos von AV-Applikationen */
		accstate = glob.accstate;
		while (accstate) {
			fprintf(fh, "AVST ");
			put_text(fh, accstate->name);
			fprintf(fh, " %s\n", accstate->state);
			accstate = accstate->next;
		}

		/* Falls Thing als Shell laeuft und temporaer gesichert wird,
		 dann auch angemeldete AV-Applikationen und AV-Fenster sichern */
		if (tb.sys & SY_MSHELL && tmp) {
			/* Applikationen */
			avinfo = glob.avinfo;
			while (avinfo) {
				fprintf(fh, "_AVA %d ", avinfo->id);
				put_text(fh, avinfo->name);
				fprintf(fh, " %d\n", avinfo->state);
				avinfo = avinfo->next;
			}
			/* Fenster */
			acwin = glob.accwin;
			while (acwin) {
				fprintf(fh, "_AVW %d %d\n", acwin->id, acwin->handle);
				acwin = acwin->next;
			}
		}

		/* Das wars ... */
		fclose(fh);

#ifdef _DEBUG
		sprintf(almsg,"CSAV: inf save done");main_debug(almsg);
#endif

		/* Aufloesungsabhaengige Informationen sichern - Desktop */
		strcpy(rname, glob.rname);
		if (tmp)
			strcat(rname, "tmp");
		else {
			/*
			 * Wenn nicht temporaer und "Fallback"-Datei existent, dann fragen,
			 * ob wieder in "Fallback" gespeichert werden soll. Frage entfuellt,
			 * wenn automatisch gesichert wird, dann grundsÑtzlich nicht in
			 * Fallback speichern.
			 */
			strcat(rname, glob.rnamesfx);
			if (glob.rnamefb[0] && (glob.done != 2)) {
				sprintf(almsg, rs_frstr[ALASKFALLBACK], glob.rnamefb);
				if (frm_alert(2, almsg, altitle, conf.wdial, 0L) == 1)
					strcpy(rname, glob.rnamefb);
			}
		}
		strcpy(name, glob.cpath);
		strcat(name, rname);

#ifdef _DEBUG
		sprintf(almsg,"CSAV: name.res=%s",rname);main_debug(almsg);
#endif

		/* Falls nicht temporaer, dann vorher Backup erzeugen */
		if (!tmp) {
			strcpy(brname, glob.cpath);
			strcat(brname, glob.rname);
			strcat(brname, "bak");
			Fdelete(brname);
			Frename(0, name, brname);
#ifdef _DEBUG
			sprintf(almsg,"CSAV: backup.res=%s",brname);main_debug(almsg);
#endif
		}

		fh = fopen(name, "w");
		if (fh) {
			ICONDESK *p = desk.dicon + 1;

#ifdef _DEBUG
			sprintf(almsg,"CSAV: res save begin");main_debug(almsg);
#endif
			/* Kurzinfo - wird beim Laden ignoriert */
			file_header(fh, "Thing display configuration", rname);
			/* Ggf. Information Åber Fallback-Datei */
			if (tmp && *glob.rnamefb)
				fprintf(fh, "FBCK %s\n", glob.rnamefb);
			/* Zeichensatz fÅr Fenster */
			fprintf(fh, "FONT %d %d\n", conf.font.id, conf.font.size);
			fprintf(fh, "CFNT %d %d\n", con.font.id, con.font.size);
			/* Icons auf dem Desktop */
			for (i = 1; i <= MAXICON; i++, p++) {
				switch (p->class) {
					case IDTRASH: /* Papierkorb */
						fprintf(fh, "OTRS %d %d ", p->x, p->y);
						put_text(fh, p->title);
						fprintf(fh, "\n");
						break;
					case IDCLIP: /* Ablage */
						fprintf(fh, "OCLP %d %d ", p->x, p->y);
						put_text(fh, p->title);
						fprintf(fh, "\n");
						break;
					case IDDRIVE: /* Laufwerk */
						fprintf(fh, "ODRV %d %d %d ", p->x, p->y, p->spec.drive->drive);
						put_text(fh, p->spec.drive->deftitle);
						fprintf(fh, "\n");
						break;
					case IDFREE: /* Unbenutztes Laufwerk ? */
						if (i <= MAXDRIVES)
							fprintf(fh, "NDRV %d\n", i-1);
						break;
					case IDFILE: /* Datei */
						fprintf(fh, "OFIL %d %d ", p->x, p->y);
						put_text(fh, p->title);
						strcpy(buf, p->spec.file->name);
						quote(buf);
						fprintf(fh," %s %d\n", buf, p->spec.file->mode);
						break;
					case IDFOLDER: /* Ordner */
						fprintf(fh, "OFLD %d %d ", p->x, p->y);
						put_text(fh, p->title);
						strcpy(buf, p->spec.folder->path);
						quote(buf);
						fprintf(fh," %s\n", buf);
						break;
					case IDPRT: /* Drucker */
						fprintf(fh, "OPRT %d %d ", p->x, p->y);
						put_text(fh, p->title);
						fprintf(fh, "\n");
						break;
					case IDDEVICE: /* Device */
						fprintf(fh,"ODEV %d %d ", p->x, p->y);
						put_text(fh, p->title);
						strcpy(buf, p->spec.device->name);
						quote(buf);
						fprintf(fh," %s\n", buf);
						break;
				}
			}
			/* Desktop-Farbeinstellung */
			fprintf(fh, "COLR %d %d %d %d\n", conf.font.bcol, conf.font.fcol,
					conf.dcolor, conf.dpattern);
			/* Muster fÅr Verzeichnisfenster */
			fprintf(fh, "BPAT %d\n", conf.bpat);
			/* Hintergrundbild */
			fprintf(fh, "DIMG %d %d %d ", conf.imguse, conf.imgcenter,
					conf.imgpal);
			strcpy(buf, conf.imgname);
			quote(buf);
			fprintf(fh, "%s %d\n", buf, conf.imgtrans);
			fprintf(fh, "WIMG 0 0 0 0 %s\n", conf.dirimg);
			/* AbstÑnde fÅr automatisches Plazieren */
			fprintf(fh, "FRAM %d %d %d %d %d %d\n", tb.fleft, tb.fright,
					tb.fupper, tb.flower, tb.fhor, tb.fvert);
			/* Das wars ... */
			fclose(fh);

			/* Falls nîtig, dann Backups lîschen */
			if (!tmp) {
				Fdelete(bname);
				Fdelete(brname);
			}

#ifdef _DEBUG
			sprintf(almsg,"CSAV: all done - no errors");main_debug(almsg);
#endif
			pfree(name);
			return 1; /* "Alles ok" melden */
		} else {
			pfree(name);
			return 0; /* Fehler melden */
		}
	} else {
		pfree(name);
		return 0; /* Fehler melden */
	}
}

int conf_load(void) {
	FILE *fh;
	char inbuf[1024], *inbuf5 = &inbuf[5];
	unsigned long id;
	int i, p, x, y, w, h, n;
	char *text, wildcard[MAX_FLEN], *name;
	D_DRIVE ddrive;
	D_FILE dfile;
	D_FOLDER dfolder;
	D_DEVICE ddevice;
	APPLINFO appl, *aptr;
	char *tx;
	int tmp, vers;
	WINOPEN *wopen, *wopen1;
	double lx, ly, lw, lh;
	ACSTATE accstate;
#ifdef VERY_OLD_CONFIG
	char ext[8][4];
#endif
	char evar[51];
	int old_format, format;
	char filelist[61], *mask, *buf;
	int has_staropen, first;
	int ok = 0;

	text = pmalloc(MAX_PLEN * 3L);
	if (text == NULL) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return (0);
	}
	name = text + MAX_PLEN;
	buf = name + MAX_PLEN;

	/* SendTo-Gruppe lesen */
	read_sendto();

	vers = 0;

	/* TemporÑre Konfigurations-Datei vorhanden ? */
	strcpy(name, glob.cpath);
	strcat(name, FNAME_INT);
	if (!file_exists(name, 1, 0L))
		tmp = 1; /* Ja */
	else /* Nein */
	{
		strcpy(name, glob.cpath);
		strcat(name, FNAME_INF);
		tmp = 0;
	}
	glob.tmp = tmp;

#ifdef _DEBUG
	sprintf(almsg,"CLOD: name.inf=%s, using backup=%d",name,tmp);main_debug(almsg);
#endif

	/* Registrierung */
	if ((glob.openwin = (WINOPEN *) pmalloc(sizeof(WINOPEN))) != 0L) {
		glob.openwin->next = 0L;
		glob.openwin->class = WCDUMMY;
	} else
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);

	wopen1 = glob.openwin;

	/* Datei îffnen */
	fh = fopen(name, "r");
	if (fh) /* Nur lesen, falls Datei geîffnet wurde! */
	{
		ok = 1;
#ifdef _DEBUG
		sprintf(almsg,"CLOD: inf begin load");main_debug(almsg);
#endif
		while (!feof(fh)) {
			if (fgets(inbuf, 1024, fh)) {
				if ((tx = strrchr(inbuf, '\r')) != 0L)
					*tx = 0;
				else if ((tx = strrchr(inbuf, '\n')) != 0L)
					*tx = 0;
				/* Kommentare ignorieren */
				if (inbuf[0] != '#') {
					id = *(unsigned long *) inbuf;
					if ((id != 'AENV') && (id != 'AOPT')
						)
						aptr = 0L;
					/* Versionskennung */
					if (id == 'VERS') {
						sscanf(inbuf5, "%d", &vers);
#ifdef _DEBUG
						sprintf(almsg,"CLOD: version found=%d",vers);main_debug(almsg);
#endif
					}
					/* Einstellungen */
					if (id == 'CONF') {
						sscanf(inbuf5,
								"%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d",
								&conf.wdial, &conf.bsel, &conf.hscr,
								&conf.texit, &conf.cdel, &conf.ccopy,
								&conf.creplace, &conf.scroll, &conf.isnap,
								&conf.altcpx, &conf.askacc, &conf.nowin,
								&conf.autocon, &conf.toswait, &conf.uset2g,
								&conf.closebox, &conf.altapp, &conf.tosmode,
								&conf.autoupdate, &conf.cdial, &conf.autocomp,
								&conf.hidden, &conf.vert, &conf.vastart,
								&conf.relwin, &conf.autosel, &conf.rdouble,
								&conf.qread, &conf.autosize, &conf.usedel);
						conf.autosizex = conf.autosizey = conf.autosize;
						conf.autoplace = conf.interactive = conf.nohotcloser =
								conf.autosave = conf.casesort = conf.caseloc =
										conf.hotkeys = 0;
#ifdef _DEBUG
						sprintf(almsg,"CLOD: conf found");main_debug(almsg);
#endif
						/* Versionsspezifische Teile auf Defaultwerte setzen */
						if (vers < 63) {
							conf.usedel = 1;
							if (vers < 61) {
								conf.autosize = 0;
#ifdef VERY_OLD_CONFIG
								if(vers<52)
								{
									conf.altcpx=0;
									conf.askacc=1;
									if(vers<46)
									{
										conf.qread=1;
										if(vers<42)
										{
											conf.rdouble=0;
											if(vers<41)
											{
												conf.relwin=1;
												conf.autosel=1;
												if(vers<32)
												{
													conf.hscr=0;
													if(vers<31)
													{
														conf.vert=0;
														if(vers<30)
														{
															conf.autocomp=1;
															if(vers<25)
															{
#ifdef _DEBUG
																sprintf(almsg,"CLOD: !! WARNING !! version < 0.25 ???");main_debug(almsg);
#endif
																conf.tosmode=0;
																conf.autoupdate=0;
																conf.closebox=0;
																conf.altapp=1;
															}
														}
													}
												}
											}
										}
									}
								}
#endif
							}
						}
						/* Dialoge sind immer im Fenster und zentriert */
						conf.wdial = 1;
						conf.cdial = 1;
#ifdef _DEBUG
						sprintf(almsg,"CLOD: disabling fly dials, enabling center dials");main_debug(almsg);
#endif
					}
					/* Einstellungen Teil II */
					if (id == 'CNFG') {
						sscanf(inbuf5, "%d %d %d %d %d %d %d %d %d",
								&conf.autosizex, &conf.autosizey,
								&conf.autoplace, &conf.interactive,
								&conf.nohotcloser, &conf.autosave,
								&conf.casesort, &conf.caseloc, &conf.hotkeys);
					}
					/* Kopierbuffer */
					if (id == 'CBUF') {
						sscanf(inbuf5, "%ld", &conf.cbuf);
						if (conf.cbuf < 0L)
							conf.cbuf = 0L;
#ifdef _DEBUG
						sprintf(almsg,"CLOD: cbuf found, value=%ld",conf.cbuf);main_debug(almsg);
#endif
					}
					/* 3D-Effekte, Userdef erzeugen, MagiC-Workaround */
					if (id == 'US3D')
						sscanf(inbuf5, "%d", &tb.use3d);
					if (id == 'UDEF')
						sscanf(inbuf5, "%d", &conf.userdef);
					if (id == 'USBW')
						sscanf(inbuf5, "%d", &tb.backwin);
					/* Console-Parameter */
					if (id == 'T2GM') {
						sscanf(inbuf5, "%d %d %d %d %d", &con.buffer,
								&con.color, &con.hist, &con.buftime,
								&con.flags);
						if (con.hist < 0)
							con.hist = 0;
						if (con.hist > 9999)
							con.hist = 9999;
						if (con.buffer > 2)
							con.buffer = 2;
						if (con.buffer < 0)
							con.buffer = 0;
						if (con.color > 2)
							con.color = 2;
						if (con.color < 0)
							con.color = 0;
#ifdef VERY_OLD_CONFIG
						if(vers<57)
						{
							con.flags=0x7;
							if(vers<52) con.buftime=150;
						}
						else
#endif
						{
							if (con.buftime < 20)
								con.buftime = 20;
							if (con.buftime > 999)
								con.buftime = 999;
						}
					}
					if (id == 'EXFI') {
						get_text(inbuf, conf.finder, MAX_PLEN);
						if (conf.finder[1] != ':' || strlen(conf.finder) < 3L)
							conf.finder[0] = 0;
					}
					if (id == 'EXFO') {
						get_text(inbuf, conf.format, MAX_PLEN);
						if (conf.format[1] != ':' || strlen(conf.format) < 3L)
							conf.format[0] = 0;
					}

					/* Einstellungen fÅr Kobold */
					if (id == 'KBD2') {
						sscanf(inbuf5, "%d %d %d %ld %d", &conf.kbc_use,
								&conf.kbd_use, &conf.kbc_files, &conf.kbc_size,
								&conf.kbd_files);
						tx = inbuf5;
						for (i = 0; i < 6; i++)
							get_buf_entry(tx, buf, &tx);
						strcpy(conf.kb_prog, buf);
#ifdef VERY_OLD_CONFIG
						if (vers < 41)
						conf.kbf_use = 0;
						else
#endif
						{
							if (vers < 124) {
								sscanf(tx, "%d", &conf.kbf_use);
								conf.kb_tosonly = 0;
							} else
								sscanf(tx, "%d %d", &conf.kbf_use,
										&conf.kb_tosonly);
						}
					}
					if (id == 'OKBD')
						sscanf(inbuf5, "%d", &conf.kbd_two);
					/* Nicelines benutzen? */
					if (id == 'NICE')
						sscanf(inbuf5, "%d", &conf.nicelines);
					/* Pfad fÅr Clipboard */
					if (id == 'SCRP') {
						get_buf_entry(inbuf5, desk.dicon[OBCLIP].spec.clip->path, 0L);
					}
					/* Index */
					if (id == 'IDEX') {
						sscanf(inbuf5, "%d %d %d", &conf.index.text, &conf.index.sortby, &conf.index.show);
					}
					/* Funktionstasten */
					if (id == 'FCKY') {
						sscanf(inbuf5, "%d", &n);
						if (n >= 0 && n <= 39)
							get_text(inbuf, conf.fkey[n], MAX_PLEN);
					}
					/* Tool-MenÅ */
					if (id == 'TOOL') {
						sscanf(inbuf5, "%d", &n);
						if (n >= 0 && n <= 9) {
							tx = get_text(inbuf, conf.ttxt[n], 16);
							get_text(tx, conf.tobj[n], MAX_PLEN);
						}
					}
					/* Default-Applikation */
					if (id == 'DFLT') {
						if (vers < 110) {
							sscanf(inbuf5, "%d %d %d", &defappl.homepath, &defappl.single, &defappl.vaproto);
						} else if (vers < 129) {
							defappl.unixpaths = 0;
							sscanf(inbuf5, "%d %d %d %d", &defappl.homepath,
									&defappl.single, &defappl.vaproto,
									&defappl.conwin);
						} else {
							sscanf(inbuf5, "%d %d %d %d %d", &defappl.homepath,
									&defappl.single, &defappl.vaproto,
									&defappl.conwin, &defappl.unixpaths);
						}
					}
					/* Applikation */
					if (id == 'APPL') {
						/*      fprintf(stderr, "%s\n", inbuf);*/
						tx = get_text(inbuf, appl.title, MAX_FLEN - 1);
						get_buf_entry(tx, appl.name, &tx);
						while (*tx == ' ')
							tx++;
						tx = get_text(tx, appl.parm, 45);
						if (vers >= 30) /* Neueres Format >=0.30 */
						{
							sscanf(tx, "%d", &appl.homepath);
							tx = get_text(tx, appl.fileopen, 60);
							tx = get_text(tx, appl.fileview, 60);
							tx = get_text(tx, appl.fileprint, 60);
							/*
							 * Alle einzelnen '*' sowie '*.*' aus fileopen herausfiltern
							 * und bei Bedarf in fileview einfÅgen, um Probleme zu
							 * vermeiden. '*.*' aber nur bei alten INF-Dateien!
							 */
							strcpy(filelist, appl.fileopen);
							strcpy(appl.fileopen, "");
							has_staropen = 0;
							first = 1;
							mask = strtok(filelist, ",");
							while (mask != NULL) {
								if (!strcmp(mask, "*") || ((vers <= 101) && !strcmp(mask, "*.*"))) {
									has_staropen = 1;
								} else {
									if (!first)
										strcat(appl.fileopen, ",");
									else
										first = 0;
									strcat(appl.fileopen, mask);
								}
								mask = strtok(NULL, ",");
							}
							if (has_staropen) {
								strcpy(filelist, appl.fileview);
								mask = strtok(filelist, ",");
								while (mask != NULL) {
									if (!strcmp(mask, "*") || !strcmp(mask, "*.*"))
										break;
									mask = strtok(NULL, ",");
								}
								if (!mask) {
									if (appl.fileview[0])
										strcat(appl.fileview, ",");
									strcat(appl.fileview, "*");
								}
							}
							/*       fprintf(stderr, "fileopen = %s, fileview = %s, fileprint = %s\n",
							 appl.fileopen, appl.fileview, appl.fileprint);*/
							sscanf(tx, "%d %d %d %d %d %d %d %d %d %d %d",
									&appl.single, &appl.vaproto, &appl.getpar,
									&appl.conwin, &appl.shortcut,
									&appl.autostart, &appl.overlay,
									&appl.usesel, &appl.euse, &appl.toswait,
									&appl.dodrag);
#ifdef _DEBUG
							sprintf(almsg,"CLOD: appl found, name=%s",appl.name);main_debug(almsg);
#endif
							if (vers < 100) {
								appl.dodrag = 0;
								if (vers < 60) {
									appl.toswait = conf.toswait;
#ifdef VERY_OLD_CONFIG
									if (vers < 57) {
										appl.euse = 0;
										if (vers < 32)
											appl.usesel = 1;
									}
#endif
								}
							}
						}
#ifdef VERY_OLD_CONFIG
						else /* Einlesen des alten Formats <=0.26 */
						{
							appl.toswait=conf.toswait;

							sscanf(tx,"%d %s %s %s %s %s %s %s %s %d %d %d %d %d %d %d",
									&appl.homepath,
									ext[0],ext[1],ext[2],ext[3],
									ext[4],ext[5],ext[6],ext[7],
									&appl.single,&appl.vaproto,&appl.getpar,&appl.conwin,
									&appl.shortcut,&appl.autostart,&appl.overlay);

							if(vers<1) /* Oh ... gaanz alt ;-) */
							{
								appl.overlay=1;
								appl.usesel=1;
							}

							appl.fileopen[0]=0;
							for(i=0;i<8;i++)
							{
								if(ext[i][0] && ext[i][0]!='.')
								{
									if(!appl.fileopen[0]) strcpy(appl.fileopen,"*.");
									else strcat(appl.fileopen,",*.");
									strcat(appl.fileopen,ext[i]);
								}
							}
							appl.fileview[0]=0;
							appl.fileprint[0]=0;
						}
#endif
						/* Neue Applikation einrichten, wenn die Angaben plausibel sind */
						if (appl.name[1] == ':' && strlen(appl.name) >= 3L) {
#ifdef _DEBUG
							sprintf(almsg,"CLOD: try to create new appl-object ...");main_debug(almsg);
#endif
							aptr = app_add();
							if (!aptr) {
#ifdef _DEBUG
								sprintf(almsg,"CLOD: ... !! WARNING !! app_add() failed!");main_debug(almsg);
#endif
								frm_alert(1, rs_frstr[ALNOMEM], altitle,
										conf.wdial, 0L);
							} else {
#ifdef _DEBUG
								sprintf(almsg,"CLOD: ... app_add() ok :-)");main_debug(almsg);
#endif
								/* Informationen Åber die Applikation eintragen */
								strcpy(aptr->title, appl.title);
								strcpy(aptr->name, appl.name);
								strcpy(aptr->parm, appl.parm);
								aptr->fullpath = 1;
								aptr->unixpaths = 0;
								aptr->fullcompare = 1;
								aptr->paralways = 0;
								aptr->homepath = appl.homepath;
								strcpy(aptr->fileopen, appl.fileopen);
								strcpy(aptr->fileview, appl.fileview);
								strcpy(aptr->fileprint, appl.fileprint);
								aptr->single = appl.single;
								aptr->vaproto = appl.vaproto;
								aptr->getpar = appl.getpar;
								aptr->conwin = appl.conwin;
								aptr->shortcut = appl.shortcut;
								aptr->usesel = appl.usesel;
								aptr->autostart = appl.autostart;
								aptr->overlay = appl.overlay;
								aptr->memlimit = 0L;
								aptr->euse = appl.euse;
								aptr->toswait = appl.toswait;
								for (i = 0; i < MAX_EVAR; i++)
									aptr->evar[i] = 0L;
								aptr->dodrag = appl.dodrag;
/*        fprintf(stderr, "fileopen = %s, fileview = %s, fileprint = %s\n", aptr->fileopen, aptr->fileview, aptr->fileprint);*/
							}
						}
					}
					/* ZusÑtzliche Optionen fÅr die vorherige Applikation */
					if ((id == 'AOPT') && aptr) {
						int alert;

						sscanf(inbuf5, "%d %ld %d %d %d", &aptr->paralways,
								&aptr->memlimit, &aptr->fullcompare,
								&aptr->unixpaths, &alert);
						aptr->fullcompare = !aptr->fullcompare;
						aptr->alert[0] = 0;
						if (alert)
							get_text(inbuf5, aptr->alert, 50);
					}
					/* Environemnt fÅr die zuletzt definierte Applikation */
					if (id == 'AENV' && aptr) {
						evar[0] = 0;
						get_text(inbuf5, evar, 50);
						if (evar[0]) {
							i = 0;
							while (aptr->evar[i] && i < 20)
								i++;
							if (i < 20) {
								aptr->evar[i] = pmalloc(strlen(evar) + 1L);
								if (aptr->evar[i]) {
									strcpy(aptr->evar[i], evar);
								} else
									frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
							}
						}
					}
					/* Hotkey */
					if (id == 'HKEY') {
						HOTKEY *new;

						tx = inbuf5;
						if (get_buf_entry(tx, text, &tx)
								&& get_buf_entry(tx, buf, &tx)) {
							new = pmalloc(sizeof(HOTKEY));
							if (new == NULL)
								frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
							else {
								new->key = atoi(text) & 0xff;
								strcpy(new->object, buf);
								new->prev = NULL;
								new->next = glob.hotkeys;
								if (glob.hotkeys != NULL)
									glob.hotkeys->prev = new;
								glob.hotkeys = new;
						}
					}
				}
					if (id == 'DRIV') {
						int drv, ul, ai;

						sscanf(inbuf5, "%d %d %d", &drv, &ul, &ai);
						if ((drv >= 0) && (drv < MAXDRIVES)) {
							desk.dicon[drv + 1].spec.drive->uselabel = ul;
							desk.dicon[drv + 1].spec.drive->autoinstall = ai;
						}
					}
					/* Fenster */
					if (id == 'WIXY') {
						sscanf(inbuf5, "%d %d %d %d %d", &p, &x, &y, &w, &h);
						if (p >= 0 && p <= 15) {
							lx = (double) tb.desk.w * (double) x / 10000L;
							x = tb.desk.x + (int) (lx + 0.5);
							ly = (double) tb.desk.h * (double) y / 10000L;
							y = tb.desk.y + (int) (ly + 0.5);
							lw = (double) tb.desk.w * (double) w / 10000L;
							w = (int) (lw + 0.5);
							lh = (double) tb.desk.h * (double) h / 10000L;
							h = (int) (lh + 0.5);
							n = tb.desk.x + tb.desk.w - 16;
							if (x > n)
								x = n;
							n = tb.desk.y + tb.desk.h - 16;
							if (y > n)
								y = n;
							if (w > tb.desk.w)
								w = tb.desk.w;
							if (h > tb.desk.h)
								h = tb.desk.h;
							glob.win[p].curr.x = x;
							glob.win[p].curr.y = y;
							glob.win[p].curr.w = w;
							glob.win[p].curr.h = h;
						}
					}
					/* Console-Fenster */
					if (id == 'VTXY') {
						sscanf(inbuf5, "%d %d %d %d", &x, &y, &w, &h);
						lx = (double) tb.desk.w * (double) x / 10000L;
						x = tb.desk.x + (int) (lx + 0.5);
						ly = (double) tb.desk.h * (double) y / 10000L;
						y = tb.desk.y + (int) (ly + 0.5);
						lw = (double) tb.desk.w * (double) w / 10000L;
						w = (int) (lw + 0.5);
						lh = (double) tb.desk.h * (double) h / 10000L;
						h = (int) (lh + 0.5);
						n = tb.desk.x + tb.desk.w - 16;
						if (x > n)
							x = n;
						n = tb.desk.y + tb.desk.h - 16;
						if (y > n)
							y = n;
						if (w > tb.desk.w)
							w = tb.desk.w;
						if (h > tb.desk.h)
							h = tb.desk.h;
						con.win.curr.x = x;
						con.win.curr.y = y;
						con.win.curr.w = w;
						con.win.curr.h = h;
					}
					/* Offenes Fenster */
					if (id == 'WOPN') {
						sscanf(inbuf5, "%d %d %d %d", &x, &y, &w, &h);
						tx = inbuf5;
						for (i = 0; i < 4; i++)
							get_buf_entry(tx, buf, &tx);
						get_buf_entry(tx, wildcard, &tx);
						get_buf_entry(tx, text, &tx);
						sscanf(tx, "%d", &p);
						/* Neuen Eintrag an die Open-Liste anhÑngen */
						wopen = pmalloc(sizeof(WINOPEN));
						if (!wopen) {
							frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
						} else {
							wopen1->next = wopen;
							wopen1 = wopen;
							wopen1->next = 0L;

							wopen->class=x;
							wopen->num = n;
							wopen->istop = y;
							wopen->sh = w;
							wopen->sv = h;
							wopen->rel = p;
							wopen->sortby = conf.index.sortby;
							strcpy(wopen->title, text);
							strcpy(wopen->wildcard, wildcard);
							if (wopen->class==WCPATH) {
								tx = get_text(inbuf5, wopen->relname, MAX_FLEN - 1);
								if (vers >= 123) {
									sscanf(tx, "%d %d %d", &wopen->text, &wopen->num, &wopen->sortby);
								} else {
									sscanf(tx, "%d %d", &wopen->text, &wopen->num);
								}
							}
							if (vers < 72) {
								wopen->num = -1;
#ifdef VERY_OLD_CONFIG
								if(vers<44)
								{
									wopen->text=0;
									if(vers<41) {wopen->rel=0;wopen->relname[0]=0;}
								}
#endif
							}
						}
					}
					/* Status-Info einer AV-Applikation */
					if (id == 'AVST') {
						tx = get_text(inbuf, accstate.name, 8);
						i = 0;
						while (tx[i] >= 32 && i < 256) {
							accstate.state[i] = tx[i];
							i++;
						}
						accstate.state[i] = 0;
						astate_add(accstate.name, accstate.state);
					}
					/* öber AV angemeldete Applikation */
					if (id == '_AVA') {
						if (tb.sys & SY_MSHELL && tmp) {
							sscanf(inbuf5, "%d", &x);
							tx = get_text(inbuf, text, 8);
							sscanf(tx, "%d", &y);
							avp_add(text, x, y);
						}
					}
					/* öber AV angemeldetes Fenster */
					if (id == '_AVW') {
						if (tb.sys & SY_MSHELL && tmp) {
							sscanf(inbuf5, "%d %d", &x, &y);
							acwin_add(x, y);
						}
					}
				}
			}
		}
		fclose(fh);
		/* Falls es die temporÑre Datei war, dann lîschen */
		if (tmp) {
			Fdelete(name);
#ifdef _DEBUG
			sprintf(almsg,"CLOD: removing temporary backup, name=%s",name);main_debug(almsg);
#endif
		}

#ifdef _DEBUG
		sprintf(almsg,"CLOD: skipping rest of log");main_debug(almsg);
#endif

		/* AuflîsungsabhÑngige Informationen lesen */
		old_format = 0;
		strcpy(glob.rnamefb, "");
		strcpy(name, glob.cpath);
		strcat(name, glob.rname);
		if (tmp)
			strcat(name, "tmp");
		else
			strcat(name, glob.rnamesfx);
		conf.bpat = 7;

		/* Datei îffnen */
		fh = fopen(name, "r");
		if (!fh && !tmp) /* NÑchst kleinere Datei suchen */
		{
			XATTR xattr;
			int maxx, maxy, maxc, x, y, c;
			char *pos;

			maxx = maxy = maxc = 0;
			/* Alle Filenamen im Konfig-Verzeichnis lesen */
			while (get_dir_entry(glob.cpath, inbuf, 1023, &xattr) >= 0) {
				strupr(&inbuf[4]);
				if (!wild_match1("[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9].I[0-9][0-9]", &inbuf[4])) {
					continue;
				}
				for (pos = &inbuf[4]; *pos; pos++)
					*pos -= '0';
				/* Die drei Zahlen (x-Auflîsung, y-Auflîsung, Farbtiefe) ermitteln... */
				x = inbuf[4] * 1000 + inbuf[5] * 100 + inbuf[6] * 10 + inbuf[7];
				y = inbuf[8] * 1000 + inbuf[9] * 100 + inbuf[10] * 10 + inbuf[11];
				c = inbuf[14] * 10 + inbuf[15];
				/* ... und prÅfen, ob sie besser als die bisher gefundenen sind */
				if ((x >= maxx) && (x <= tb.resx) && (y >= maxy) && (y <= tb.resy) && (c <= tb.planes)) {
					if ((maxx == x) && (maxy == y)) {
						if (maxc <= c)
							maxc = c;
					} else
						maxc = c;
					maxx = x;
					maxy = y;
				}
			}
			/* Gegebenenfalls die so ermittelte Datei îffnen */
			if (maxx && maxy && maxc) {
				sprintf(name, "%s%04d%04d.i%02d", glob.cpath, maxx, maxy, maxc);
				fh = fopen(name, "r");
				if (fh)
					sprintf(glob.rnamefb, "%04d%04d.i%02d", maxx, maxy, maxc);
			}
		}
		/* Immer noch keine Datei gefunden? Altes Format probieren */
		if (!fh && !tmp) {
			sprintf(name, "%s%04d%04d.inf", glob.cpath, tb.resx, tb.resy);
			fh = fopen(name, "r");
			if (fh)
				old_format = 1;
		}
		tb.fleft = tb.fupper = tb.fright = tb.flower = tb.fhor = tb.fvert = 0;
		for (format = 0; format <= old_format; format++) {
			ICONDESK *q;

			/* Nur lesen, falls Datei geîffnet wurde! */
			if (fh) {
				while (!feof(fh)) {
					if (fgets(inbuf, 1024, fh)) {
						if ((tx = strrchr(inbuf, '\r')) != 0L)
							*tx = 0;
						else if ((tx = strrchr(inbuf, '\n')) != 0L)
							*tx = 0;
						id = *(unsigned long *) inbuf;
						/* Kommentare ignorieren */
						if (inbuf[0] != '#') {
							/* Ggf. Info Åber Fallback-Datei */
							if (tmp && (id == 'FBCK'))
								sscanf(inbuf5, "%s", glob.rnamefb);
							/* Zeichensatz */
							if (id == 'FONT')
								sscanf(inbuf5, "%d %d", &conf.font.id, &conf.font.size);
							if (id == 'CFNT')
								sscanf(inbuf5, "%d %d", &con.font.id, &con.font.size);
							/* Papierkorb */
							if (id == 'OTRS') {
								sscanf(inbuf5, "%d %d", &x, &y);
								tx = get_text(inbuf, text, MAX_FLEN - 1);
								/* Papierkorb-Icon Ñndern */
								q = desk.dicon + OBTRASH;
								strcpy(q->title, text);
								q->x = x;
								q->y = y;
							}
							/* Ablage */
							if (id == 'OCLP') {
								sscanf(&inbuf[5], "%d %d", &x, &y);
								tx = get_text(inbuf, text, MAX_FLEN - 1);
								/* Ablage-Icon Ñndern */
								q = desk.dicon + OBCLIP;
								strcpy(q->title, text);
								q->x = x;
								q->y = y;
							}
							/* Laufwerk */
							if (id == 'ODRV') {
								char label[MAX_FLEN];

								sscanf(inbuf5, "%d %d %d", &x, &y, &ddrive.drive);
								tx = get_text(inbuf, text, MAX_FLEN - 1);
								/* Laufwerks-Icon einrichten */
								if (ddrive.drive >= 0 && ddrive.drive < MAXDRIVES) {
									q = desk.dicon + ddrive.drive + 1;
									q->class = IDDRIVE;
									strcpy(q->title, text);
									strcpy(q->spec.drive->deftitle, text);
									if (q->spec.drive->uselabel) {
										*label = 0;
										if (get_label(ddrive.drive, label, MAX_FLEN))
											*label = 0;
										if (*label)
											strcpy(q->title, label);
									}
									q->x = x;
									q->y = y;
									q->spec.drive->drive = ddrive.drive;
								}
							}
								/* Unbenutztes Laufwerk */
							if (id == 'NDRV') {
								sscanf(inbuf5, "%d", &ddrive.drive);
								if (ddrive.drive >= 0 && ddrive.drive < MAXDRIVES) {
									q = desk.dicon + ddrive.drive + 1;
									if (q->class == IDDRIVE) {
										q->class = IDFREE;
										q->title[0] = 0;
										q->x = -1;
										q->y = -1;
									}
								}
							}
								/* Datei */
							if (id == 'OFIL') {
								dfile.mode = 0;
								sscanf(inbuf5, "%d %d", &x, &y);
								tx = get_text(inbuf, text, MAX_FLEN - 1);
								get_buf_entry(tx, dfile.name, &tx);
								sscanf(tx, "%d", &dfile.mode);
#ifdef VERY_OLD_CONFIG
								if(vers<58) dfile.mode=0;
#endif
								/* Neues Icon fÅr eine Datei einrichten */
								p = OBUSER;
								q = desk.dicon + p;
								while (p <= MAXICON && q->class != IDFREE) {
									p++;
									q++;
								}
								if (p <= MAXICON) {
									q->spec.file = pmalloc(sizeof(D_FILE));
									if (!q->spec.file) {
										frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
									} else {
										q->class=IDFILE;
										strcpy(q->title, text);
										q->x = x;
										q->y = y;
										strcpy(q->spec.file->name, dfile.name);
										q->spec.file->mode = dfile.mode;
									}
								}
							}
							/* Ordner */
							if (id == 'OFLD') {
								sscanf(inbuf5, "%d %d", &x, &y);
								tx = get_text(inbuf, text, MAX_FLEN - 1);
								get_buf_entry(tx, dfolder.path, &tx);

								/* Sicherheitscheck auf GÅltigkeit */
								w = (int) strlen(dfolder.path);
								if (w > 4 && dfolder.path[w - 1] == '\\') {
									/* Neues Icon fÅr einen Ordner einrichten */
									p = OBUSER;
									q = desk.dicon + p;
									while (p <= MAXICON && q->class != IDFREE) {
										p++;
										q++;
									}
									if (p <= MAXICON) {
										q->spec.folder = pmalloc(
												sizeof(D_FOLDER));
										if (!q->spec.folder) {
											frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
										} else {
											q->class=IDFOLDER;
											strcpy(q->title, text);
											q->x = x;
											q->y = y;
											strcpy(q->spec.folder->path, dfolder.path);
										}
									}
								}
							}
							/* Drucker */
							if (id == 'OPRT') {
								sscanf(inbuf5, "%d %d", &x, &y);
								tx = get_text(inbuf, text, MAX_FLEN - 1);
								/* Daten eintragen */
								q = desk.dicon + OBPRT;
								q->x = x;
								q->y = y;
								strcpy(q->title, text);
							}
							/* Device */
							if (id == 'ODEV') {
								sscanf(inbuf5, "%d %d", &x, &y);
								tx = get_text(inbuf, text, MAX_FLEN - 1);
								get_buf_entry(tx, ddevice.name, &tx);
								/* Neues Icon fÅr ein Device einrichten */
								p = OBUSER;
								q = desk.dicon + p;
								while (p <= MAXICON && q->class != IDFREE) {
									p++;
									q++;
								}
								if (p <= MAXICON) {
									q->spec.device = pmalloc(sizeof(D_DEVICE));
									if (!q->spec.device) {
										frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
									} else {
										q->class=IDDEVICE;
										strcpy(q->title, text);
										q->x = x;
										q->y = y;
										strcpy(q->spec.device->name, ddevice.name);
									}
								}
							}
							/* Farben */
							if (id == 'COLR' && (!old_format || format)) {
								sscanf(inbuf5, "%d %d %d %d", &conf.font.bcol,
										&conf.font.fcol, &conf.dcolor,
										&conf.dpattern);
							}
							/* Pattern */
							if (id == 'BPAT')
								sscanf(inbuf5, "%d", &conf.bpat);
							/* Hintergrundbild */
							if (id == 'DIMG' && (!old_format || format)) {
								sscanf(inbuf5, "%d %d %d", &conf.imguse, &conf.imgcenter, &conf.imgpal);
								tx = inbuf5;
								for (i = 0; i < 3; i++)
									get_buf_entry(tx, buf, &tx);
								if (*tx && (tx[1] == ' '))
									*conf.imgname = 0;
								else {
									get_buf_entry(tx, buf, &tx);
									strcpy(conf.imgname, buf);
								}
								if (vers >= 113) {
									if (*tx && (tx[1] == ' '))
										*conf.imgname = 0;
									sscanf(tx, "%d", &conf.imgtrans);
								} else
									conf.imgtrans = 0;
							}
							if (id == 'WIMG') {
								tx = inbuf5;
								for (i = 0; i < 4; i++)
									get_buf_entry(tx, buf, &tx);
								while (*tx == ' ')
									tx++;
								if (*tx)
									strcpy(conf.dirimg, tx);
								else
									*conf.dirimg = 0;
							}
							/* RÑnder fÅr automatisches Plazieren */
							if (id == 'FRAM') {
								sscanf(inbuf5, "%d %d %d %d %d %d", &tb.fleft,
										&tb.fright, &tb.fupper, &tb.flower,
										&tb.fhor, &tb.fvert);
							}
						}
					}
				}
			}
			fclose(fh);
			/* Falls es die temporÑre Datei war, dann lîschen */
			if (tmp)
				Fdelete(name);
			if (old_format && !format) {
				sprintf(name, "%scolor%03d.inf", glob.cpath, tb.planes);
				fh = fopen(name, "r");
			}
		}
		/* Icons aktualisieren */
		icon_update(0);

#ifdef _DEBUG
		sprintf(almsg,"CLOD: all done, no errors");main_debug(almsg);
#endif
	}
	pfree(text);
	return (ok);
}

/*-------------------------------------------------------------------------
 conf_isave()
 conf_iload()

 Icon-Informationen sichern/laden
 -------------------------------------------------------------------------*/

int conf_isave(void) {
	return 1;
}

int conf_iload(void) {
	FILE *fh;
	char name[MAX_PLEN];
	char inbuf[512];
	char iname[MAX_FLEN], imask[MAX_FLEN];
	ICONIMG *icon;
	unsigned long id;
	char *p, *t, tchar;
	int i, j, ret, num, maxnum, l, altapp, altcpx;
	int tcol;
	long bufsize;
	ICONBLK *dummy;

#ifdef _DEBUG
	sprintf(almsg,"CILO: start icon load");main_debug(almsg);
#endif

	altapp = conf.altapp;
	altcpx = conf.altapp;
	conf.altapp = 1;
	conf.altcpx = 1;

	/* FÅr Neu-Initialisierung der Mini-Icon-Hîhe sorgen */
	glob.sheight = 16;

#ifdef _DEBUG
	sprintf(almsg,"CILO: creating default icons ...");main_debug(almsg);
#endif

	/* Standard-Icons eintragen */
	dummy = rs_trindex[ICONS][DUMMYICON].ob_spec.iconblk;
	icn_rsrc("TRASH", &desk.ic_trash);
	icn_rsrc("CLIPBOARD", &desk.ic_clip);
#if 0
	icn_rsrc("FLOPPY",&desk.ic_floppy);
	desk.ic_floppy.tchar=0;
	icn_rsrc("HARDDISK",&desk.ic_hard);
	desk.ic_hard.tchar=0;
	icn_rsrc("RAMDISK",&desk.ic_ramdisk);
	desk.ic_ramdisk.tchar=0;
#endif
	icn_rsrc("FILESYS", &desk.ic_filesys);
	icn_rsrc("FILE", &desk.ic_file);
	icn_rsrc("APPL", &desk.ic_appl);
	icn_rsrc("FOLDER", &desk.ic_folder);
	icn_rsrc("PARENTDIR", &desk.ic_parent);
	icn_rsrc("PRINTER", &desk.ic_prn);
	icn_rsrc("DEVICE", &desk.ic_dev);
	icn_rsrc("GROUP", &desk.ic_grp);
	/*
	 * Spezialmaûnahmen fÅr Leute, die IconCons verwenden und daher nur
	 * 8 Zeichen im Iconnamen unterbringen kînnen
	 */
	if (desk.ic_clip.iconblk == dummy)
		icn_rsrc("_CLIPBRD", &desk.ic_clip);
	if (desk.ic_parent.iconblk == dummy)
		icn_rsrc("_PARENT", &desk.ic_parent);
	desk.ic_trash.tchar = 0;
	desk.ic_clip.tchar = 0;
	desk.ic_filesys.tchar = 0;
	desk.ic_file.tchar = 0;
	desk.ic_appl.tchar = 0;
	desk.ic_folder.tchar = 0;
	desk.ic_parent.tchar = 0;
	desk.ic_prn.tchar = 0;
	desk.ic_dev.tchar = 0;
	desk.ic_grp.tchar = 'G';
	desk.ic_trash.tcolor = -1;
	desk.ic_clip.tcolor = -1;
	desk.ic_filesys.tcolor = -1;
	desk.ic_file.tcolor = -1;
	desk.ic_appl.tcolor = -1;
	desk.ic_folder.tcolor = -1;
	desk.ic_parent.tcolor = -1;
	desk.ic_prn.tcolor = -1;
	desk.ic_dev.tcolor = -1;
	desk.ic_grp.tcolor = -1;

#ifdef _DEBUG
	sprintf(almsg,"CILO: ... default icons ok");main_debug(almsg);
#endif

	/* Dateinamen erzeugen */
	strcpy(name, tb.homepath);
	strcat(name, FNAME_ICN);
	fh = fopen(name, "r");
	if (fh) /* Nur lesen, falls Datei geîffnet wurde ! */
	{
#ifdef _DEBUG
		sprintf(almsg,"CILO: reading inf, name=%s",name);main_debug(almsg);
#endif
		/* Buffer reservieren */
		maxnum = 1000;
		while (!desk.icon && maxnum > 0) {
			bufsize = (long) maxnum * sizeof(ICONIMG);
			desk.icon = Malloc(bufsize);
			if (!desk.icon)
				maxnum = maxnum / 2;
		}
		/* Bei Fehler abbrechen */
		if (!desk.icon) {
			/* INSERT:Fehlermeldung */
			fclose(fh);
			return 0;
		}

#ifdef _DEBUG
		sprintf(almsg,"CILO: buffers ok, num=%d",maxnum);main_debug(almsg);
#endif

		ret = 1;
		num = 0;

		while (!feof(fh) && ret) {
			if (fgets(inbuf, 511, fh)) {
				/* Kommentare ignorieren */
				if (inbuf[0] != '#') {
					id = *(unsigned long *) inbuf;
					if (id == 'IFIL' || id == 'IFLD' || id == 'IDRV') {
						p = get_text(inbuf, iname, MAX_FLEN - 1);

						/* Text-Kennzeichen und -Farbe holen */
						tchar = 0;
						tcol = -1;
						t = strrchr(inbuf, 0);
						if (t[-1] == 10)
							t[-1] = 0;
						t = strrchr(inbuf, ' ');
						if ((t != NULL) && (t > p) && t[1]) {
							l = (int) (t - inbuf) + 1;
							i = l - 1;
							while (inbuf[i] == ' ')
								i--;
							if (inbuf[i] != ',' && inbuf[i] != '\042') {
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

						/* Icon-Zuordnungen einfÅgen */
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
								if (num < maxnum) /* Noch Platz im Buffer? */
								{
									/* Ja ... Daten eintragen */
									icon = &desk.icon[num];
									strcpy(icon->mask, imask);
									icon->class = 0;
									if (id=='IFLD')
										icon->class = 1;

									if(id=='IDRV')
										icon->class = 2;

									icon->tchar = tchar;
									icon->tcolor = tcol;
									/*
									 * Wenn es ein Standardicon ist und die Maske "*" oder "**"
									 * lautet, nur den Farbwert fÅr das Standardicon Åbernehmen
									 * und die Zuordnung "vergessen".
									 */
									if (!strcmp(imask, "*") || !strcmp(imask, "**")) {
										int used = 1;

										if (icon->class == 0) {
											if (!strcmp(iname, "FILE"))
												desk.ic_file.tcolor = tcol;
											else if (!strcmp(iname, "APPL"))
												desk.ic_appl.tcolor = tcol;
											else if (!strcmp(iname, "GROUP"))
												desk.ic_grp.tcolor = tcol;
											else if (!strcmp(iname, "DEVICE"))
												desk.ic_dev.tcolor = tcol;
											else
												used = 0;
										} else if (icon->class == 1) {
											if (!strcmp(iname, "FOLDER"))
												desk.ic_folder.tcolor = tcol;
											else
												used = 0;
										}
										if (used)
											continue;
									}
#ifdef _DEBUG
													sprintf(almsg,"CILO: adding icon, name=%s, mask=%s",iname,imask);main_debug(almsg);
#endif

									/* Icon in der Resourcedatei suchen */
									icn_rsrc(iname, icon);
									/* Und merken */
									num++;
								} else /* Nî - kein Platz mehr */
								{
									/* INSERT:Fehlermeldung */
									ret = 0;
								}
							}
						}
					}
				}
			}
		}
		fclose(fh);
		/* Buffer auf tatsÑchlich benîtigte Grîûe zurechtstutzen */
		if (num < maxnum) {
#ifdef _DEBUG
							sprintf(almsg,"CILO: shrinking buffer, old=%d, new=%d",maxnum,num);main_debug(almsg);
#endif
			if (num > 0)
				Mshrink(0, desk.icon, (long) num * sizeof(ICONIMG));
			else {
				Mfree(desk.icon);
				desk.icon = 0L;
			}
		}
		desk.maxicon = num;
	} else
		ret = 0;
	conf.altapp = altapp;
	conf.altcpx = altcpx;

	return ret;
}

/*
 * read_sendto
 *
 * Liest die "sendto"-Gruppe im HOME von Thing ein.
 */
void read_sendto(void) {
	WININFO dummy, *win;
	char sendto_path[MAX_PLEN];

	if (glob.sendto != NULL) {
		while (glob.sendto->entry)
			wgrp_remove(glob.sendto, glob.sendto->entry);
		pfree(glob.sendto);
	}
	glob.sendto = NULL;
	strcpy(sendto_path, glob.cpath);
	strcat(sendto_path, FNAME_SND);
	win = tb.win;
	tb.win = NULL;
	if (wgrp_open(sendto_path, &dummy, 'SND2'))
		glob.sendto = dummy.user;
	tb.win = win;
}

/*
 * free_hotkeys
 *
 * Gibt die EintrÑge fÅr die Schnellstarttasten frei.
 */
void free_hotkeys(void) {
	HOTKEY *p, *q;

	for (p = glob.hotkeys; p != NULL;) {
		q = p;
		p = p->next;
		pfree(q);
	}
	glob.hotkeys = NULL;
}

/* EOF */
