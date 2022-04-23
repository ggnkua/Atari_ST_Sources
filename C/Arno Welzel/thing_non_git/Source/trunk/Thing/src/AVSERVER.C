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

/**=========================================================================
 AVSERVER.C

 Thing
 AV-Protokoll
 =========================================================================*/

#include "..\include\globdef.h"
#include "..\include\types.h"
#include "..\include\thingrsc.h"
#include <ctype.h>
#include <setjmp.h>
#include "..\include\dragdrop.h"

/* Lokale Prototypen */
static void cdecl handle_sigbus(long signo);

/* Lokale Variablen */
jmp_buf check;

/**-------------------------------------------------------------------------
 av_init()

 Buffer etc. initialisieren
 -------------------------------------------------------------------------*/
int av_init(void) {
	/* Speicher reservieren */
	if (tb.sys & SY_XALLOC)
		aesbuf = Mxalloc(MAX_AVLEN + 9, 0x23); /* Global, TT preferred */
	else
		aesbuf = Malloc(MAX_AVLEN + 9);

	/* Bei Fehler raus */
	if (!aesbuf) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return 0;
	}
	aesapname = &aesbuf[MAX_AVLEN];

	/* Sonst initialisieren */
	strcpy(aesapname, "THING   ");

	return 1;
}

/**-------------------------------------------------------------------------
 av_exit()

 Speicher etc. wieder freigeben
 -------------------------------------------------------------------------*/
void av_exit(void) {
	if (aesbuf)
		Mfree( aesbuf);
}

/**-------------------------------------------------------------------------
 avs_...()

 Auf AV_...-Anfragen reagieren
 -------------------------------------------------------------------------*/
/* AV_PROTOKOLL */
void avs_protokoll(int *msgbuf) {
	char *name;
	AVINFO *avinfo;
	int ability;

	name = (char *) int2long(&msgbuf[6], &msgbuf[7]);
	if (name == 0L)
		return; /* Nullpointer ignorieren! */

	if (!avp_checkbuf(msgbuf[1], AV_PROTOKOLL, "AV_PROTOKOLL", name, 0))
		return;

	avinfo = avp_get(msgbuf[1]); /* Hat diese App schon mal angefragt? */
	if (!avinfo) /* Nein */
	{
		/* Applikation merken */
		avinfo = avp_add(name, msgbuf[1], msgbuf[3]);
	} else
		strcpy(avinfo->name, name);

	/* Abfrage der unterstuetzten AV-Nachrichten */
	/* Unterstuetzung von:
	 0x0001 + AV_SENDKEY
	 0x0002 + AV_ASKFILEFONT
	 0x0004 + AV_ASKCONFONT, AV_OPENCONSOLE
	 0x0008   AV_ASKOBJECT
	 0x0010 + AV_OPENWIND
	 0x0020 + AV_STARTPROG
	 0x0040 + AV_ACCWINDOPEN, AV_ACCWINDCLOSED
	 0x0080 + AV_STATUS, AV_GETSTATUS - nur wenn Anmeldung geklappt hat
	 0x0100 + AV_COPY_DRAGGED
	 0x0200 + AV_PATH_UPDATE, AV_WHAT_IZIT, AV_DRAG_ON_WINDOW
	 0x0400 + AV_EXIT
	 0x0800 + AV_XWIND
	 0x1000 + VA_FONTCHANGED - nur wenn Anmeldung geklappt hat
	 0x2000 + AV_STARTED
	 0x4000 + Quoting
	 0x8000 + AV_FILEINFO, VA_FILECHANGED
	 0x0001 + AV_COPYFILE, VA_FILECOPIED
	 0x0002 + AV_DELFILE, VA_FILEDELETED
	 0x0004 + AV_VIEW, VA_VIEWED
	 0x0008   AV_SETWINDPOS */
	ability = 0x0001 | 0x0002 | 0x0004 | 0x0010 | 0x0020 | 0x0040 | 0x0100
			| 0x0200 | 0x0400 | 0x0800 | 0x2000 | 0x4000 | 0x8000;
	if (avinfo)
		ability |= 0x0080 | 0x1000;
	app_send(msgbuf[1], VA_PROTOSTATUS, PT67, ability, 0x1 | 0x2 | 0x4, 0,
			(long) aesapname, 0);
}

/**
 *  AV_GETSTATUS
 */
void avs_getstatus(int *msgbuf) {
	AVINFO *avinfo;
	ACSTATE *accstate;
	char *state;

	avinfo = avp_get(msgbuf[1]);
	if (avinfo)
		accstate = astate_get(avinfo->name);
	else
		accstate = 0L;

	if (accstate)
		state = accstate->state;
	else
		state = (char *) 0L;

	if (state)
		strcpy(aesbuf, state);

	app_send(msgbuf[1], VA_SETSTATUS, PT34, state ? (long) aesbuf : 0L, 0, 0,
			0, 0);
}

/**
 *  AV_STATUS
 */
void avs_status(int *msgbuf) {
	AVINFO *avinfo;
	char *state;

	avinfo = avp_get(msgbuf[1]);
	state = (char *) int2long(&msgbuf[3], &msgbuf[4]);
	if (!avp_checkbuf(msgbuf[1], AV_STATUS, "AV_STATUS", state, 0))
		return;
	if (avinfo && state) {
		astate_add(avinfo->name, state);
	}
}

/**
 *  AV_SENDKEY
 */
void avs_sendkey(int *msgbuf) {
	handle_key(msgbuf[3], msgbuf[4]);
}

/**
 *  AV_ASKFILEFONT
 */
void avs_askfilefont(int *msgbuf) {
	AVINFO *aptr;

	/* Abfrage vermerken, damit bei Bedarf VA_FONTCHANGED geschickt wird */
	aptr = avp_get(msgbuf[1]);
	if (aptr)
		aptr->state |= 0x0008;

	app_send(msgbuf[1], VA_FILEFONT, 0, conf.font.id, conf.font.size, 0, 0, 0);
}

/* AV_ASKCONFONT */
void avs_askconfont(int *msgbuf) {
	AVINFO *aptr;

	/* Abfrage vermerken, damit bei Bedarf VA_FONTCHANGED geschickt wird */
	aptr = avp_get(msgbuf[1]);
	if (aptr)
		aptr->state |= 0x0008;

	app_send(msgbuf[1], VA_CONFONT, 0, con.font.id, con.font.size, 0, 0, 0);
}

/* AV_OPENWIND */
void avs_openwind(int *msgbuf) {
	char *path, *wildcard;
	int ret;

	path = (char *) int2long(&msgbuf[3], &msgbuf[4]);
	wildcard = (char *) int2long(&msgbuf[5], &msgbuf[6]);
	if (path == 0L || wildcard == 0L)
		return; /* Nullpointer ignorieren! */

	if (!avp_checkbuf(msgbuf[1], AV_OPENWIND, "AV_OPENWIND", path, 0)
			|| !avp_checkbuf(msgbuf[1], AV_OPENWIND, "AV_OPENWIND", wildcard, 0)) {
		return;
	}

	if (!strcmp(wildcard, "*.*"))
		wildcard = "*";
	ret = wpath_open(path, wildcard, 0, 0L, conf.index.text, -1, conf.index.sortby);
	app_send(msgbuf[1], VA_WINDOPEN, 0, ret, 0, 0, 0, 0);

	mn_check();
	mn_update();
}

/* AV_STARTPROG */
void avs_startprog(int *msgbuf) {
	char *prg, *cmd, *tmp;
	int ret, l, magic;

	prg = (char *) int2long(&msgbuf[3], &msgbuf[4]);
	cmd = (char *) int2long(&msgbuf[5], &msgbuf[6]);
	if (prg == 0L)
		return; /* Nullpointer ignorieren! */

	if (!avp_checkbuf(msgbuf[1], AV_STARTPROG, "AV_STARTPROG", prg, 0) || (cmd
			&& !avp_checkbuf(msgbuf[1], AV_STARTPROG, "AV_STARTPROG", cmd, 0))) {
		return;
	}

	magic = msgbuf[7];

	ret = 1;
	tmp = 0L;
	/* Angegebener Programmname mit zulaessiger Laenge? */
	if ((int) strlen(prg) < MAX_PLEN) {
		tmp = pmalloc(MAX_AVLEN);
		if (tmp) {
			strcpy(tmp, prg);
			quote(tmp);

			if (cmd) {
				/* LÑnge insgesamt ok? */
				l = (int) strlen(tmp) + (int) strlen(cmd) + 2;
				if (l < MAX_AVLEN) {
					strcat(tmp, " ");
					strcat(tmp, cmd);
				}
			}
		}
	}

	if (tmp) {
		strcpy(aesbuf, tmp);
		pfree(tmp);
		ret = va_open(aesbuf);
	} else
		ret = 0;

	app_send(msgbuf[1], VA_PROGSTART, 0, ret, 0, 0, 0, magic);

	mn_check();
	mn_update();
}

/* AV_ACCWINDOPEN */
void avs_accwindopen(int *msgbuf) {
	acwin_add(msgbuf[1], msgbuf[3]);

	mn_check();
	mn_update();
}

/* AV_ACCWINDCLOSED */
void avs_accwindclosed(int *msgbuf) {
	ACWIN *accwin;

	accwin = acwin_find(msgbuf[3]);
	if (accwin)
		acwin_remove(accwin);

	mn_check();
	mn_update();
}

/* AV_PATH_UPDATE */
void avs_path_update(int *msgbuf) {
	W_PATH *wpath;
	char *path;
	int l, i;

	path = (char *) int2long(&msgbuf[3], &msgbuf[4]);
	if (path == 0L)
		return; /* Nullpointer ignorieren! */

	if (!avp_checkbuf(msgbuf[1], AV_PATH_UPDATE, "AV_PATH_UPDATE", path, 0))
		return;

	l = (int) strlen(path);

	for (i = 0; i < MAX_PWIN; i++) {
		if (glob.win[i].state & WSOPEN) {
			wpath = (W_PATH *) glob.win[i].user;
			if (!strncmp(path, wpath->path, (long) l)) {
				wpath->offx = wpath->offy = 0;
				wpath_update(&glob.win[i]);
				win_redraw(&glob.win[i], tb.desk.x, tb.desk.y, tb.desk.w,
						tb.desk.h);
			}
		}
	}

	mn_check();
	mn_update();
}

/* AV_COPY_DRAGGED */
void avs_copy_dragged(int *msgbuf) {
	int ks, ret, id;
	char *path, lpath[MAX_PLEN];

	id = msgbuf[1];
	ks = msgbuf[3];
	path = (char *) int2long(&msgbuf[4], &msgbuf[5]);
	if (path == 0L)
		return; /* Nullpointer ignorieren! */

	if (!avp_checkbuf(id, AV_COPY_DRAGGED, "AV_COPY_DRAGGED", path, 0))
		return;

	strcpy(lpath, path);
	if (lpath[(int) strlen(lpath) - 1] != '\\')
		strcat(lpath, "\\");
	ret = dl_copy(lpath, ks, aesbuf);

	app_send(id, VA_COPY_COMPLETE, 0, ret, 0, 0, 0, 0);

	mn_check();
	mn_update();
}

/* AV_WHAT_IZIT */
void avs_what_izit(int *msgbuf) {
	int whandle;
	WININFO *win;
	WP_ENTRY *item;
	WG_ENTRY *gitem, *gprev;
	int l, obj;
	ACWIN *accwin;

	aesmsg[0] = VA_THAT_IZIT;
	aesmsg[1] = tb.app_id;
	aesmsg[2] = 0;
	aesmsg[3] = tb.app_id;
	aesmsg[4] = VA_OB_UNKNOWN;
	strcpy(aesbuf, "");
	long2int((long) aesbuf, &aesmsg[5], &aesmsg[6]);
	aesmsg[7] = 0;

	/* Fenster ? */
	whandle = wind_find(msgbuf[3], msgbuf[4]);
	if (whandle) {
		win = win_getwinfo(whandle);
		if (win) /* Thing-Fenster */
		{
			aesmsg[4] = VA_OB_WINDOW;
			switch (win->class) /* Je nach Art des Fensters */
			{
				case WCPATH: /* Verzeichnisfenster */
				/* Objekt innerhalb des Fensters ? */
				item = wpath_efind(win, msgbuf[3], msgbuf[4]);
				if (item) /* Ja */
				{
					strcpy(aesbuf, ((W_PATH *)win->user)->path);
					switch (item->class)
					{
						case EC_FILE:
						strcat(aesbuf, item->name);
						aesmsg[4] = VA_OB_FILE;
						break;
						case EC_FOLDER:
						case EC_PARENT:
						aesmsg[4] = VA_OB_FOLDER;
						if (item->class == EC_PARENT) {
							l = (int)strlen(aesbuf) - 2;
							while (aesbuf[l] != '\\')
								l--;
							aesbuf[l + 1] = 0;
						} else {
							strcat(aesbuf, item->name);
							strcat(aesbuf, "\\");
						}
						break;
					}
				}
				else /* Nein */
				{
					aesmsg[4] = VA_OB_FOLDER;
					strcpy(aesbuf, ((W_PATH *)win->user)->path);
				}
				break;
				case WCGROUP: /* Gruppenfenster */
				/* Objekt innerhalb des Fensters ? */
				gitem = wgrp_efind(win, msgbuf[3], msgbuf[4], &gprev);
				if (gitem) /* Ja */
				{
					wgrp_eabs((W_GRP *)win->user, gitem, aesbuf);
					switch (gitem->class) {
						case EC_FILE:
							aesmsg[4] = VA_OB_FILE;
							break;
						case EC_FOLDER:
							aesmsg[4] = VA_OB_FOLDER;
							break;
					}
				}
				else /* Nein */
				{
					/* Gruppenname */
					strcpy(aesbuf, ((W_GRP *)win->user)->name);
				}
				break;
				case WCDIAL: /* Dialog */
				break;
				default: /* Sonstiges, Console */
				aesmsg[4] = VA_OB_UNKNOWN;
				aesmsg[5] =
				aesmsg[6] = 0;
				break;
			}
		}
		else /* Fenster einer Applikation */
		{
			/* Fenster angemeldet ? */
			accwin = glob.accwin;
			while (accwin) {
				if (accwin->handle == whandle) {
					aesmsg[3] = accwin->id;
					aesmsg[4] = VA_OB_WINDOW;
					aesmsg[5] =
					aesmsg[6] = 0;
				}
				accwin = accwin->next;
			}
		}
	}
	else /* Desktop-Objekt ? */
	{
		obj = icon_find(msgbuf[3] ,msgbuf[4]);
		if (obj != -1) /* Ja */
		{
			ICONDESK *p = desk.dicon + obj;

			switch (p->class) {
				case IDTRASH:
				aesmsg[4] = VA_OB_SHREDDER;
				break;
				case IDCLIP:
				aesmsg[4] = VA_OB_CLIPBOARD;
				strcpy(aesbuf, p->spec.clip->path);
				break;
				case IDFILE:
				aesmsg[4] = VA_OB_FILE;
				strcat(aesbuf, p->spec.file->name);
				break;
				case IDFOLDER:
				aesmsg[4] = VA_OB_FOLDER;
				strcpy(aesbuf, p->spec.folder->path);
				break;
				case IDDRIVE:
				aesmsg[4] = VA_OB_DRIVE;
				aesbuf[0] = 'A' + p->spec.drive->drive;
				aesbuf[1] = ':';
				aesbuf[2] = '\\';
				aesbuf[3] = 0;
				break;
			}
		}
		else /* Noe */
		{
			aesmsg[4] = VA_OB_WINDOW;
			aesmsg[5] = aesmsg[6] = 0;
		}
	}
	/* Rueckmeldung: Das isses ! */
	appl_write(msgbuf[1],16,aesmsg);
}

/* Unterfunktion zu avs_drag_on_window(): Buffer bei der
 ersten Leerstelle abschneiden */
int av_cutbuf(char *buf) {
	int i;

	if (!get_buf_entry(buf, buf, 0L)) {
		frm_alert(1, rs_frstr[ALQUOTEERR], altitle, conf.wdial, 0L);
		return (-1);
	}

	i = (int) strlen(buf);
	if (buf[i - 1] == '\\')
		return 0;
	else
		return 1;
}

/* AV_DRAG_ON_WINDOW */
void avs_drag_on_window(int *msgbuf) {
	int x, y, j, n, done;
	int id, ks, drag;
	char *buf, *help;
	int whandle;
	ACWIN *accwin;
	WININFO *win;
	W_PATH *wpath;
	WP_ENTRY *pitem;
	W_GRP *wgrp;
	WG_ENTRY *gitem, *gprev;
	FORMINFO *fi;
	int icon, obj;
	int aptype;
	APPLINFO appl, *aptr;
	char aname[MAX_FLEN], apath[MAX_PLEN];
	char name[MAX_PLEN];
	char *bptr;
	FILESYS filesys;
	int ix, iy, iw, ih, sx, sy, ry;
	int tx1, ty1, tx2, ty2;
	int l, rex;
	int ftype;
	int first;
	/* Ergaenzungen fuer MT-D&D */
	int owner, ok;
	int dfh, dret;
	char dext[32];
	long dsize;
	unsigned long dtype;
	void *dsig;

	id = msgbuf[1];
	x = msgbuf[3];
	y = msgbuf[4];
	ks = msgbuf[5];
	buf = (char *) int2long(&msgbuf[6], &msgbuf[7]);
	if (buf == 0L)
		return; /* Nullpointer ignorieren! */

	if (!avp_checkbuf(id, AV_DRAG_ON_WINDOW, "AV_DRAG_ON_WINDOW", buf, 1))
		return;

	drag = 0;

	/* Buffer aufbereiten */
	strcpy(aesbuf, "");
	help = buf;
	first = 1;
	while (get_buf_entry(help, name, &help)) {
		fsinfo(name, &filesys);
		fsconv(name, &filesys);
		quote(name);
		if ((strlen(aesbuf) + 1 + strlen(name)) >= MAX_AVLEN)
			break;
		if (first)
			strcat(aesbuf, " ");
		strcat(aesbuf, name);
		first = 0;
	}

	wind_update( BEG_UPDATE);
	whandle = wind_find(x, y);
	wind_update( END_UPDATE);

	if (whandle) /* Fenster? */
	{
		/* Vielleicht ein eigenes Fenster ? */
		win = win_getwinfo(whandle);
		if (win) {
			switch (win->class) {
				case WCDIAL: /* Dialogfenster */
					fi = (FORMINFO *)win->user;
					if (fi == &fi_cfunc) {
						obj = objc_find(fi->tree, ROOT, MAX_DEPTH, x, y);
						if (obj != -1) {
							if (!(fi->tree[obj].ob_flags & EDITABLE))
								obj = -1;
						}
					}
					if (obj != -1) {
						if (av_cutbuf(buf) != -1) {
							dl_wdrag_d(fi, obj, buf, ks);
							drag = 1;
						}
					} else
						mybeep();
					break;
				case WCCON: /* Console - kein Drag&Drop moeglich! */
					frm_alert(1, rs_frstr[ALAVEDRAG], altitle, conf.wdial, 0L);
					break;
				case WCPATH: /* Verzeichnis */
				wpath = (W_PATH *)win->user;
				pitem = wpath_efind(win,x,y);
				if (pitem) /* Auf ein Icon gelegt */
				{
					switch (pitem->class) {
						case EC_DEVICE: /* Device */
						if ((ftype = av_cutbuf(buf)) != -1) {
							if (!ftype) {
								/* Auf ein Device darf kein Ordner gelegt werden! */
								frm_alert(1,rs_frstr[ALAVEDRAGT],altitle,conf.wdial,0L);
							} else {
								strcpy(apath, wpath->path);
								strcat(apath, pitem->name);
								drag = dl_devout(buf, apath);
							}
						}
						break;
						case EC_FILE:
						if (!pitem->aptype) {
							/* Indirekt? */
							aptr=app_isdrag(pitem->name);
							if (aptr) {
								strcpy(glob.cmd,wpath->path);
								strcat(glob.cmd,pitem->name);
								strcat(glob.cmd," ");
								if ((int)strlen(glob.cmd) + (int)strlen(buf) < MAX_CLEN) {
									strcat(glob.cmd, buf);
									drag = app_start(aptr, glob.cmd, wpath->path, &rex);
								}
								else
									drag = 0;
							} else /* Nein -> Kopieren */
							{
								strcpy(apath, wpath->path);
								drag=dl_copy(apath, ks, buf);
							}
						} else /* Programm -> Mit Parametern starten */
						{
							aptype=pitem->aptype;
							strcpy(appl.name,wpath->path);
							strcat(appl.name,pitem->name);
							aptr=app_find(appl.name);
							if (!aptr) {
								app_default(&appl);
								strcpy(appl.title, pitem->name);
								aptr = &appl;
							}
							drag = app_start(aptr, buf, wpath->path, &rex);
						}
						break;
						case EC_FOLDER: /* Ordner -> Kopieren */
						strcpy(apath, wpath->path);
						strcat(apath, pitem->name);
						strcat(apath, "\\");
						drag = dl_copy(apath, ks, buf);
						break;
						case EC_PARENT: /* Parent -> Kopieren */
						strcpy(apath, wpath->path);
						l = (int)strlen(apath) - 2;
						while (apath[l] != '\\')
							l--;
						apath[l + 1] = 0;
						drag = dl_copy(apath, ks, buf);
						break;
					}
				} else /* In das Fenster gelegt -> Kopieren */
				{
					drag=dl_copy(wpath->path,ks,buf);
				}
				break;
				case WCGROUP: /* Gruppenfenster */
				wgrp=(W_GRP *)win->user;
				gitem=wgrp_efind(win,x,y,&gprev);
				drag=0;n=1;
				if (gitem) /* Auf ein Icon gelegt */
				{
					wgrp_eabs(wgrp,gitem,name);
					switch (gitem->class) {
						case EC_FOLDER: /* Drag&Drop auf einen Ordner */
						drag = dl_copy(name,ks,buf);
						break;
						case EC_FILE:
						full2comp(name,apath,aname);
						if(!gitem->aptype) /* Drag&Drop auf ein Programm */
						{
							/* Indirekt? */
							if(!is_appl(name))
							{
								drag=0;
								aptr=app_isdrag(name);
								if(aptr)
								{
									strcpy(glob.cmd,name);
									strcat(glob.cmd," ");
									if((int)strlen(glob.cmd)+(int)strlen(buf)<MAX_CLEN)
									{
										strcat(glob.cmd,buf);
										drag=app_start(aptr,glob.cmd,wpath->path,&rex);
									}
								}
							}
							else n=0; /* Nein */
						}
						else
						{
							/* Eintrag ist ein Programm */
							aptr=app_find(name);
							if(!aptr)
							{
								strcpy(appl.name,name);
								app_default(&appl);
								strcpy(appl.title,gitem->title);
								if(ks&K_ALT) strcpy(appl.parm,gitem->parm);
								aptr=&appl;
							}
							else
							{
								if(ks&K_ALT)
								{
									memcpy(&appl,aptr,sizeof(APPLINFO));
									if(ks&K_ALT) strcpy(appl.parm,gitem->parm);
									aptr=&appl;
								}
							}
							drag=app_start(aptr,buf,apath,&rex);
						}
						break;
					}
				}
				else n=0;

				if(!n) /* Kein Objekt in der Gruppe - dann Objekte aufnehmen */
				{
					bptr = buf;
					while(get_buf_entry(bptr, name, &bptr))
					{
						j = (int)strlen(name);
						if(name[j-1]=='\\') /* Ordner */
						{
							name[j - 1] = 0;
							if ((help = strrchr(name, '\\')) == 0L)
							help = name;
							else
							help++;
							strcpy(aname, help);
							name[j - 1] = '\\';
							gitem=wgrp_add(wgrp,gprev,EC_FOLDER,aname,name,"");
						}
						else
						{
							if ((help = strrchr(name, '\\')) == 0L)
							help = name;
							else
							help++;
							strcpy(aname, help);
							gitem=wgrp_add(wgrp,gprev,EC_FILE,aname,name,"");
						}
						if(!gitem)
						{
							frm_alert(1,rs_frstr[ALNOMEM],altitle,conf.wdial,0L);
							break;
						}
					}
					wgrp_tree(win);
					win_redraw(win,tb.desk.x,tb.desk.y,tb.desk.w,tb.desk.h);
					win_slide(win,S_INIT,0,0);
					wgrp_change(win);
				}
				break;
			}
		} else /* Nein */
		{
			if (buf != aesbuf)
				strcpy(aesbuf, buf);

			/* Ist das Fenster angemeldet? */
			accwin = acwin_find(whandle);
			if (accwin) /* Jo... */
			{
				/* Weiterleiten als VA_DRAGACCWIND */
				if (avp_check(accwin->id)) {
					if (!has_quotes(aesbuf) || avp_can_quote(accwin->id)) {
						app_send(accwin->id, VA_DRAGACCWIND, PT67, whandle,
								x, y, (long)aesbuf, 0);
						drag = 1;
					} else {
						sprintf(almsg, rs_frstr[ALNOQUOTE], avp_get(accwin->id)->name);
						frm_alert(1, almsg, altitle, conf.wdial, 0L);
					}
				}
			} else /* Nein - dann MultiTOS D&D */
			{
				/* Eigentuemer ermitteln */
				owner = -1;
				if (tb.sys & SY_OWNER)
					if (!wind_get(whandle,WF_OWNER,&owner))
						owner = -1;
				if (owner != -1 && owner != tb.app_id) {
					/* MultiTOS D&D probieren */
					ok = 1;
					if (tb.sys & SY_MULTI) {
						/* D&D-Pipe erzeugen */
						dfh = ddcreate(tb.app_id, owner, whandle, x, y, ks, dext, &dsig);
						if (dfh >= 0) {
							/* Pruefen, ob der EmpfÑnger 'ARGS' unterstÅtzt */
							dtype = 'ARGS';
							dsize = (long)strlen(aesbuf);
							dret = ddstry(dfh, dtype, "ARGS.TXT", dsize);
							if (dret == DD_OK) {
								/* Alles klar - dann senden */
								Fwrite(dfh,dsize,aesbuf);
							}
							ddclose(dfh, dsig);
						} else {
							ok = 0;
						}
					}

					/* D&D ging nicht, dann VA_START probieren */
					if (!ok)
						app_send(owner, VA_START, PT34, (long)aesbuf, 0, 0, 0, 0);
				} else {
					frm_alert(1, rs_frstr[ALAVEDRAG], altitle, conf.wdial, 0L);
				}
			}
		}
	}
	else /* Nein - Desktop */
	{
		icon = icon_find(x, y);
		if (icon != -1) /* Auf ein Icon gelegt */
		{
			ICONDESK *p = desk.dicon + icon;

			switch (p->class) {
				case IDPRT: /* Drucker */
				if ((ftype = av_cutbuf(buf)) != -1)
				{
					if(!ftype)
					{
						/* Auf den Drucker darf kein Ordner gelegt werden! */
						frm_alert(1,rs_frstr[ALAVEDRAGT],altitle,conf.wdial,0L);
					}
					else
					{
						quote(buf);
						drag=dl_show(1,buf);
					}
				}
				break;
				case IDDEVICE: /* Device */
				if ((ftype = av_cutbuf(buf)) != -1)
				{
					if (!ftype) {
						/* Auf ein Device darf kein Ordner gelegt werden! */
						frm_alert(1, rs_frstr[ALAVEDRAGT], altitle, conf.wdial, 0L);
					} else {
						drag = dl_devout(buf, p->spec.device->name);
					}
				}
				break;
				case IDDRIVE: /* Laufwerk -> Kopieren */
				strcpy(apath, "x:\\");
				apath[0] = p->spec.drive->drive + 'A';
				drag = dl_copy(apath, ks, buf);
				break;
				case IDTRASH: /* Papierkorb -> Lîschen */
				drag = dl_delete(buf);
				break;
				case IDCLIP: /* Ablage - Clip */
				frm_alert(1, rs_frstr[ALAVEDRAGS], altitle, conf.wdial, 0L);
				break;
				case IDFOLDER: /* Ordner -> Kopieren */
				drag = dl_copy(p->spec.folder->path, ks, buf);
				break;
				case IDFILE:
				full2comp(p->spec.file->name, apath, aname);
				aptype = is_app(p->spec.file->name, p->spec.file->mode);
				if (!aptype) /* Datei - momentan noch unzulÑssig */
				{
					/* Indirekt? */
					aptr = app_isdrag(p->spec.file->name);
					if (aptr) {
						strcpy(glob.cmd, p->spec.file->name);
						strcat(glob.cmd, " ");
						if ((int)strlen(glob.cmd) + (int)strlen(buf) < MAX_CLEN) {
							strcat(glob.cmd, buf);
							drag = app_start(aptr, glob.cmd, apath, &rex);
						} else {
							drag = 0;
						}
					} else { /* Nein */
						frm_alert(1, rs_frstr[ALAVEDRAGS], altitle, conf.wdial, 0L);
					}
				} else { /* Programm -> Mit Parametern starten */
					strcpy(appl.name, p->spec.file->name);
					aptr = app_find(appl.name);
					if (!aptr) {
						app_default(&appl);
						strcpy(appl.title, p->title);
						aptr = &appl;
					}
					drag = app_start(aptr, buf, apath, &rex);
				}
				break;
			}
		}
		else /* Auf den Desktop gelegt */
		{
			ICONDESK *p;
			/* Startposition */
			sx = x;
			sy = y - 20 - tb.desk.y;
			if (sy < 0)
				sy = 0;
			ry = sy;

			/* Position/Masse des Gesamtrechtecks fuer Desktop-Redraw */
			tx1 = tb.desk.x + tb.desk.w;
			ty1 = tb.desk.y + tb.desk.h;
			tx2 =
			ty2 = 0;

			/* Freies Icon suchen */
			icon = OBUSER;
			p = desk.dicon + OBUSER;
			while (p->class != IDFREE && icon <= MAXICON) {
				icon++;
				p++;
			}

			/* Alle Eintraege als Icons ablegen */
			done = 0;
			bptr = buf;
			while(!done && get_buf_entry(bptr, name, &bptr))
			{
				if (icon > MAXICON) /* Desktop schon voll :( */
				{
					frm_alert(1, rs_frstr[ALDESKFULL], altitle, conf.wdial, 0L);
					done = 1;
				}
				else /* Neues Icon erzeugen */
				{
					j = (int)strlen(name);
					full2comp(name, apath, aname);
					if (name[j-1] != '\\') /* Datei */
					{
						p->class = IDFILE;
						p->spec.file = pmalloc(sizeof(D_FILE));
						if (p->spec.file)
							strcpy(p->spec.file->name, name);
					}
					else /* Ordner */
					{
						name[j - 1] = 0;
						if ((help = strrchr(name, '\\')) == 0L)
							help = name;
						else
							help++;
						strcpy(aname, help);
						name[j - 1] = '\\';
						p->class = IDFOLDER;
						p->spec.folder = pmalloc(sizeof(D_FOLDER));
						if (p->spec.folder)
							strcpy(p->spec.folder->path, name);
					}
					/* War kein Speicher mehr frei? */
					if (!p->spec.data) {
						p->class = IDFREE;
						done = 1;
						frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
					} else {
						/* Restliche Daten eintragen und Desktop aktualisieren */
						strcpy(p->title,aname);
						p->select = 0;
						p->prevsel = 0;
						p->x = sx;
						p->y = sy;
						icon_update(icon);
						objc_offset(rs_trindex[DESKTOP], icon, &ix, &iy);
						iw = rs_trindex[DESKTOP][icon].ob_width;
						ih = rs_trindex[DESKTOP][icon].ob_height;

						/* Gesamtrechteck anpassen */
						if (ix < tx1)
							tx1 = ix;
						if (iy < ty1)
							ty1 = iy;
						if (ix + iw > tx2)
							tx2 = ix + iw;
						if (iy + ih > ty2)
							ty2 = iy + ih;

						/* Naechste Position */
						sy += 48;
						if ((sy + 20) > tb.desk.h) {
							sy = ry;
							sx += 80;
						}
						/* Status: Mindestens ein Icon konnte abgelegt werden */
						drag = 1;
					}
					if (!done) {
						/* Naechstes freies Icon suchen */
						do {
							icon++;
							p++;
						} while(p->class != IDFREE && icon <= MAXICON);
					}
				}
			}
			/* Desktop-Redraw */
			if(drag)
			desk_draw(tx1,ty1,tx2-tx1+1,ty2-ty1+1);
		}
	}

	/* Rueckmeldung: Drag&Drop abgeschlossen */
	app_send(id, VA_DRAG_COMPLETE, 0, drag, 0, 0, 0, 0);

	mn_check();mn_update();
}

/**
 *  AV_EXIT
 */
void avs_exit(int *msgbuf) {
	avp_exit(msgbuf[3]);

	mn_check();
	mn_update();
}

/**
 *  AV_XWIND
 */
void avs_xwind(int *msgbuf) {
	char *path, *wildcard;
	int i, j, open, select, ret;
	W_PATH *wpath;
	WP_ENTRY *item;
	int wrd,found,new;
	RECT wrect;
	WININFO *pwin;

	select = 0;

	path = (char *) int2long(&msgbuf[3], &msgbuf[4]);
	wildcard = (char *) int2long(&msgbuf[5], &msgbuf[6]);
	if (path == 0L || wildcard == 0L)
		return; /* Nullpointer ignorieren! */

	if (!avp_checkbuf(msgbuf[1], AV_XWIND, "AV_XWIND", path, 0)
			|| !avp_checkbuf(msgbuf[1], AV_XWIND, "AV_XWIND", wildcard, 0)) {
		return;
	}

	if (!strcmp(wildcard, "*.*"))
		wildcard = "*";

	if (msgbuf[7] & 0x0002)
		select = 1;
	else
		select = 0;
	pwin = 0L;
	new = 0;

	/* Evtl. vorhandenes Fenster toppen */
	if (msgbuf[7] & 0x0001) {
		open = 1;
		for (i = 0; i < MAX_PWIN && open; i++) {
			if (glob.win[i].state & WSOPEN) {
				wpath = (W_PATH *) glob.win[i].user;
				if (!strcmp(wpath->path, path)) {
					pwin = &glob.win[i];
					open = 0;
					ret = 1;
					win_top(pwin);
					magx_switch(tb.app_id, 0);
					if (select)
						strcpy(wpath->index.wildcard, "*");
					else
						strcpy(wpath->index.wildcard, wildcard);
					wpath->rel = 0;
					wpath_update(pwin);
					win_redraw(pwin, tb.desk.x, tb.desk.y, tb.desk.w, tb.desk.h);
				}
			}
		}
	}
	/* Sonst neues Fenster îffnen */
	if (!pwin) {
		new=1;
		if (!select) {
			ret = wpath_open(path, wildcard, 0, 0L, conf.index.text, -1, conf.index.sortby);
		} else {
			ret = wpath_open(path, "*", 0, 0L, conf.index.text, -1, conf.index.sortby);
		}
		if (ret)
			pwin = tb.topwin;
	}

	/* Angegebene Wildcard als Auto-Locator verwenden */
	if (select && pwin) {
		/* Desktop-Icons deselektieren */
		icon_select(-1, 0, 0);
		/* EintrÑge in anderen Fenster deselektieren */
		for (i = 0; i < MAX_PWIN; i++) {
			if (glob.win[i].state & WSOPEN) {
				wpath = (W_PATH *) glob.win[i].user;
				if (wpath != (W_PATH *) pwin->user) {
					strcpy(wpath->amask, "");
					wpath_esel(&glob.win[i], 0L, 0, 0, 1);
				}
			}
		}
		/* Gibt es passende Eintraege ? */
		wpath = (W_PATH *) pwin->user;
		wrd = 0;
		found = 0;
		for (j = 0; j < wpath->e_total; j++) {
			item = wpath->lptr[j];
			if (wild_match1(wildcard, item->name))
				found++;
		}
		/* Alle Eintraege entsprechend der Maske selektieren */
		if (found) {
			strcpy(wpath->amask, wildcard);
			for (j = 0; j < wpath->e_total; j++) {
				item = wpath->lptr[j];
				if (wild_match1(wildcard, item->name))
					wpath_esel1(pwin, item, 1, &wrect, &wrd);
				else
					wpath_esel1(pwin, item, 0, &wrect, &wrd);
			}
			/* Fensterinhalt aktualisieren */
			if (wrd) {
				if (!new) {
					if (wpath->tree)
						wpath->tree->ob_type = G_IBOX;
					win_redraw(pwin, wrect.x, wrect.y, wrect.w, wrect.h);
					if (wpath->tree)
						wpath->tree->ob_type = G_BOX;
					wpath_showsel(pwin, 1);
				} else
					wpath_showsel(pwin, 0);
			}
		}
		wpath_info(pwin);
	}

	app_send(msgbuf[1], VA_XOPEN, 0, ret, 0, 0, 0, 0);

	mn_check();
	mn_update();
}

/**
 *  VA_START
 */
void avs_vastart(int *msgbuf) {
	char *cmd;
	AVINFO *av;

	/* Workaround: falls FREEDOM der Absender ist, dann ignorieren */
	av = avp_get(msgbuf[1]);
	if (av) {
		if (!strcmp(av->name, "FREEDOM "))
			return;
	}

	cmd = (char *) int2long(&msgbuf[3], &msgbuf[4]);

	/* Falls Kommandozeile Nullpointer, dann nur aktivieren! */
	if (cmd == 0L) {
		magx_switch(tb.app_id, 0);
		return;
	}

	if (!avp_checkbuf(msgbuf[1], VA_START, "VA_START", cmd, 0))
		return;

	if (cmd != aesbuf)
		strcpy(aesbuf, cmd);
	va_open( aesbuf);

	mn_check();
	mn_update();
}

/**
 *  AV_VIEW
 */
void avs_view(int *msgbuf) {
	int ret;
	char *name;

	name = (char *) int2long(&msgbuf[3], &msgbuf[4]);
	if (name == 0L)
		return; /* Nullpointer ignorieren! */

	if (!avp_checkbuf(msgbuf[1], AV_VIEW, "AV_VIEW", name, 0))
		return;

	ret = dl_show(0, name);
	app_send(msgbuf[1], VA_VIEWED, 0, ret, 0, 0, 0, 0);
}

/**
 *  AV_FILEINFO
 */
void avs_fileinfo(int *msgbuf) {
	int id, ret, done, j, cont, doit, donext;
	char *src, *lsrc, *ldst;
	WP_ENTRY item;
	FILESYS filesys;
	char *full, *file, *path;
	XATTR xattr;
	DTA dta;
	char *bptr;
	int drv;

	id = msgbuf[1];
	ret = 1;
	src = (char *) int2long(&msgbuf[3], &msgbuf[4]);
	if (src == 0L)
		return; /* Nullpointer ignorieren! */

	if (!avp_checkbuf(id, AV_FILEINFO, "AV_FILEINFO", src, 0))
		return;

	/* Lokale Buffer einrichten */
	lsrc = pmalloc(MAX_AVLEN * 2L + MAX_PLEN * 3L);
	if (!lsrc) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		ret = 0;
	}
	ldst = lsrc + MAX_AVLEN;
	full = ldst + MAX_AVLEN;
	file = full + MAX_PLEN;
	path = file + MAX_PLEN;

	/* Falls ok, dann Info ausfuehren */
	if (ret) {
		strcpy(lsrc, src);
		ldst[0] = 0;
		done = 0;
		doit = 1;
		bptr = lsrc;
		while (!done && get_buf_entry(bptr, full, &bptr)) {
			while (*bptr == ' ')
				bptr++;
			j = (int) strlen(full);
			/* Pruefen, ob weitere Eintraege vorliegen */
			donext = *bptr;
			done = !donext;

			/* Falls gueltig, dann Info... */
			if (j > 0) {
				if(full[j-1]=='\\') /* Ordner? */
				{
					full[j-1]=0;item.class=EC_FOLDER;
				}
				else item.class=EC_FILE;

				/* In Pfad und Dateinamen zerlegen etc. */
				fsinfo(full, &filesys);
				full2comp(full, path, file);
				strcpy(item.name, file);

				drv = -1;
				if (j <= 3) {
					/* Bei gueltigen Wurzelverzeichnissen Laufwerksinfo aufrufen */
					drv = nkc_toupper(*path) - 'A';
					if ((drv < 0) || (drv >= MAXDRIVES))
						drv = -1;
					else
						ret = 0;
				}

				if (drv == -1) {
					if ((ret = file_exists(full, 0, &xattr)) == 0) {
						dta.d_time = xattr.mtime;
						dta.d_date = xattr.mdate;
						dta.d_length = xattr.size;
						dta.d_attrib = xattr.attr;
						item.mode = xattr.mode;
						item.date = dta.d_date;
						item.time = dta.d_time;
						item.size = dta.d_length;
						item.attr = dta.d_attrib;
					} else {
						mybeep();
						ret = -33;
					}
				}

				/* Info ausfuehren */
				if (doit && !ret) {
					switch (item.class)
					{
						case EC_FOLDER:
						if (drv != -1) {
							/* Bei gueltigen Wurzelverzeichnissen Laufwerksinfo aufrufen */
							cont = dl_ddriveinfo(&desk.dicon[drv + 1], donext);
							break;
						}
						/* Fall through */
						case EC_FILE:
						cont = dl_fileinfo(path, 0, &filesys, &item, 0L, donext);
						break;
					}
					if (!cont)
						doit = 0;
				}

				/* Neue Angaben uebernehmen */
				if (ldst[0])
					strcat(ldst, " ");
				strcpy(full, path);
				strcat(full, item.name);
				quote(full);
				strcat(ldst, full);
				if (item.class == EC_FOLDER)
					strcat(ldst, "\\");

				if (cont == 2) {
					/* Passendes SH_WDRAW an Thing schicken, zwecks Fenster-Update */
					app_send(tb.app_id, SH_WDRAW, 0, filesys.biosdev, 0, 0, 0, 0);
				}
			}
		}
		strcpy(aesbuf, ldst);

		/* Aufgelaufene Maus/Tastatur-Events lîschen */
		mevent.ev_mwich &= ~(MU_KEYBD | MU_BUTTON);
	}
	else /* Buffer nicht ok, dann Originalnamen verwenden */
	{
		if (src != aesbuf)
			strcpy(aesbuf, src);
	}

	/* Rueckmeldung an Absender */
	app_send(id, VA_FILECHANGED, PT34, (long)aesbuf, 0, 0, 0, 0);

	pfree(lsrc);
}

/**
 *  AV_COPYFILE, AV_DELFILE
 */
void avs_copyfile(int *msgbuf, int del) {
	int id, ret, ks, crepl;
	char *src, *dst;
	char ldst[MAX_PLEN], *lsrc;

	id = msgbuf[1];
	src = (char *) int2long(&msgbuf[3], &msgbuf[4]);
	if (src == 0L)
		return; /* Nullpointer ignorieren! */

	if (!avp_checkbuf(id, del ? AV_DELFILE : AV_COPYFILE, del ? "AV_DELFILE"
			: "AV_COPYFILE", src, 0)) {
		return;
	}

	if (!del) {
		dst = (char *) int2long(&msgbuf[5], &msgbuf[6]);
		if (dst == 0L)
			return; /* Nullpointer ignorieren! */

		if (!avp_checkbuf(id, AV_COPYFILE, "AV_COPYFILE", dst, 0))
			return;

		strcpy(ldst, dst);
	}
	lsrc = pmalloc(MAX_AVLEN);
	if (!lsrc) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		ret = 0;
	} else {
		strcpy(lsrc, src);
		if (del)
			ret = dl_delete(lsrc);
		else {
			ks = 0;
			crepl = conf.creplace;
			if (msgbuf[7] & 0x0001)
				ks |= K_CTRL;
			if (msgbuf[7] & 0x0002)
				ks |= K_ALT;
			if (msgbuf[7] & 0x0004)
				conf.creplace = 0;
			else
				conf.creplace = 1;
			if (msgbuf[7] & 0x0008)
				ks |= K_RSHIFT;
			ret = dl_copy(dst, ks, lsrc);
			conf.creplace = crepl;
		}
		pfree(lsrc);
		/* Aufgelaufene Maus/Tastatur-Events loeschen */
		mevent.ev_mwich &= ~(MU_KEYBD | MU_BUTTON);
	}

	app_send(id, del ? VA_FILEDELETED : VA_FILECOPIED, 0, ret, 0, 0, 0, 0);
}

/**------------------------------------------------------------------------
 avp_add()
 avp_remove()

 AV-Accessory/Applikation hinzufuegen/loeschen
 -------------------------------------------------------------------------*/
AVINFO *avp_add(char *name, int id, int state) {
	AVINFO *avinfo, *aptr;

	/* Speicher reservieren */
	avinfo = pmalloc(sizeof(AVINFO));
	if (!avinfo)
		return 0L;

	/* Listenverkettung */
	avinfo->next = 0L;
	if (!glob.avinfo) {
		/* Liste bisher leer */
		glob.avinfo = avinfo;
		avinfo->prev = 0L;
	} else {
		/* An das Ende der Liste anhaengen */
		aptr = glob.avinfo;
		while (aptr->next)
			aptr = aptr->next;
		aptr->next = avinfo;
		avinfo->prev = aptr;
	}

	/* Infos eintragen */
	strcpy(avinfo->name, name);
	avinfo->id = id;
	avinfo->state = state;

	return avinfo;
}

void avp_remove(AVINFO *avinfo) {
	AVINFO *aprev, *anext;

	aprev = avinfo->prev;
	anext = avinfo->next;

	/* Aus der Liste entfernen */
	if (!aprev) {
		/* Kein Vorgaenger - dann erster Eintrag ! */
		glob.avinfo = anext;
		if (anext)
			anext->prev = 0L;
	} else {
		/* Vorgaenger vorhanden */
		aprev->next = anext;
		if (anext)
			anext->prev = aprev;
	}

	/* Reservierten Speicher freigeben */
	pfree(avinfo);
}

/**------------------------------------------------------------------------
 avp_get()

 AV-Infos einer Applikation abfragen
 -------------------------------------------------------------------------*/
AVINFO *avp_get(int id) {
	AVINFO *aptr;

	aptr = glob.avinfo;
	while (aptr) {
		if (aptr->id == id)
			return aptr;
		aptr = aptr->next;
	}

	return 0L;
}

/**------------------------------------------------------------------------
 avp_exit()

 Alle Informationen einer AV-Applikation aus den Listen loeschen
 -------------------------------------------------------------------------*/
void avp_exit(int id) {
	ACWIN *aptr, *aptr1;
	AVINFO *avptr;

	/* AV-Infos */
	avptr = avp_get(id);
	if (avptr)
		avp_remove(avptr);

	/* Fenster */
	aptr = glob.accwin;
	while (aptr) {
		/* Fenster vorhanden? */
		if (aptr->id == id) {
			/* Nachfolger merken und Fenster aus der Liste entfernen */
			aptr1 = aptr->next;
			acwin_remove(aptr);
			aptr = aptr1;
		} else
			aptr = aptr->next; /* Nein - naechster Eintrag */
	}
}

/**------------------------------------------------------------------------
 avp_check()

 Prueft, ob die Applikation mit der angegebenen ID noch aktiv ist, und
 entfernt ggf. die Anmeldungen falls dies nicht der Fall ist.
 -------------------------------------------------------------------------*/
int avp_check(int id) {
	AVINFO *aptr;
	int avid, whandle;

	aptr = avp_get(id);
	/* Applikation als AV-Client angemeldet? */
	if (aptr) {
		avid = appl_find(aptr->name);
		if (avid < 0) {
			/* Nicht mehr aktiv! */
			sprintf(almsg, rs_frstr[ALAVLOST], aptr->name);
			frm_alert(1, almsg, altitle, conf.wdial, 0L);
			avp_exit(id);
			get_twin(&whandle);
			tb.topwin = win_getwinfo(whandle);
			win_newtop(tb.topwin);
			mn_check();
			mn_update();
			return 0;
		} else
			return 1;
	} else
		return 0; /* Nicht angemeldet! */
}

/**-------------------------------------------------------------------------
 acwin_add()
 acwin_remove()

 Fenster hinzufuegen/loeschen
 -------------------------------------------------------------------------*/
ACWIN *acwin_add(int id, int handle) {
	ACWIN *accwin, *aptr;

	/* Speicher reservieren */
	accwin = pmalloc(sizeof(ACWIN));
	if (!accwin)
		return 0L;

	/* Listenverkettung */
	accwin->next = 0L;
	if (!glob.accwin) /* Liste bisher leer */
	{
		glob.accwin = accwin;
		accwin->prev = 0L;
	} else /* An das Ende der Liste anhÑngen */
	{
		aptr = glob.accwin;
		while (aptr->next)
			aptr = aptr->next;
		aptr->next = accwin;
		accwin->prev = aptr;
	}

	/* Infos eintragen */
	accwin->id = id;
	accwin->handle = handle;

	return accwin;
}

void acwin_remove(ACWIN *accwin) {
	ACWIN *aprev, *anext;

	aprev = accwin->prev;
	anext = accwin->next;

	/* Aus der Liste entfernen */
	if (!aprev) {
		/* Kein Vorgaenger - dann erster Eintrag ! */
		glob.accwin = anext;
		if (anext)
			anext->prev = 0L;
	} else {
		/* Vorgaenger vorhanden */
		aprev->next = anext;
		if (anext)
			anext->prev = aprev;
	}
	/* Reservierten Speicher freigeben */
	pfree(accwin);
}

/**------------------------------------------------------------------------
 acwin_find()

 Accessory-Fenster anhand des GEM-Handles ermitteln
 -------------------------------------------------------------------------*/
ACWIN *acwin_find(int handle) {
	ACWIN *aptr;

	if (!glob.accwin)
		return 0L;
	aptr = glob.accwin;
	while (aptr) {
		if (aptr->handle == handle)
			return aptr;
		aptr = aptr->next;
	}
	return 0L;
}

/**------------------------------------------------------------------------
 astate_add()
 astate_remove()

 Status-Informationen hinzufÅgen/lîschen
 -------------------------------------------------------------------------*/
ACSTATE *astate_add(char *name, char *state) {
	int add;
	ACSTATE *accstate, *aptr;

	/* Infos schon vorhanden? */
	add = 1;
	aptr = glob.accstate;
	while (aptr && add) {
		if (!strcmp(aptr->name, name)) {
			add = 0;
			strcpy(aptr->state, state);
			accstate = aptr;
		}
		aptr = aptr->next;
	}

	/* Bisher nicht eingetragen - dann hinzufuegen */
	if (add) {
		accstate = pmalloc(sizeof(ACSTATE));
		if (!accstate)
			return 0L;
		/* Listenverkettung */
		accstate->next = 0L;
		if (!glob.accstate) /* Liste bisher leer */
		{
			glob.accstate = accstate;
			accstate->prev = 0L;
		} else /* An das Ende der Liste anhaengen */
		{
			aptr = glob.accstate;
			while (aptr->next)
				aptr = aptr->next;
			aptr->next = accstate;
			accstate->prev = aptr;
		}

		/* Infos eintragen */
		strcpy(accstate->name, name);
		strcpy(accstate->state, state);
	}

	return accstate;
}

void astate_remove(ACSTATE *accstate) {
	ACSTATE *aprev, *anext;

	aprev = accstate->prev;
	anext = accstate->next;

	/* Aus der Liste entfernen */
	if (!aprev) {
		/* Kein Vorgaenger - dann erster Eintrag ! */
		glob.accstate = anext;
		if (anext)
			anext->prev = 0L;
	} else {
		/* Vorgaenger vorhanden */
		aprev->next = anext;
		if (anext)
			anext->prev = aprev;
	}
	/* Reservierten Speicher freigeben */
	pfree(accstate);
}

/**------------------------------------------------------------------------
 astate_get()

 Status-Informationen abrufen
 -------------------------------------------------------------------------*/
ACSTATE *astate_get(char *name) {
	ACSTATE *aptr;

	aptr = glob.accstate;
	while (aptr) {
		if (!strcmp(aptr->name, name))
			return aptr;
		aptr = aptr->next;
	}

	return 0L;
}

/**
 * avp_can_quote
 *
 * Ermittelt, ob ein AV-Client Quoting unterstuetzt.
 *
 * Eingabe:
 * ap_id: AES-ID des AV-Clients. Ist dieser bei Thing nicht
 *        angemeldet, wird davon ausgegangen, dass er Quoting
 *        unterstÅtzt.
 *
 * Rueckgbae:
 * 0: Client unterstuetzt kein Quoting
 * sonst: Client versteht Quoting von Filenamen
 */
int avp_can_quote(int ap_id) {
	AVINFO *aptr;

	if ((aptr = avp_get(ap_id)) != NULL)
		return (aptr->state & 0x10);
	else
		return (1);
}

/**
 * avp_checkbuf
 *
 * Prueft, ob ein von einem AV-Client gelieferter Pufferzeiger fuer
 * Thing les- und ggf. schreibbar ist (Stichwort Speicherschutz).
 *
 * Eingabe:
 * id: AES-ID des AV-Clients
 * msg: Betroffene AV-Nachricht als Zahl
 * tmsg: Betroffene AV-Nachricht als Text
 * buf: Zeiger auf zu pruefenden Puffer
 * write: 1, wenn auch Schreibzugriff benîtigt wird
 *
 * Rueckgabe:
 * 0: Puffer nicht OK, Alert wurde angezeigt
 * sonst: Alles klar, go ahead
 */
int avp_checkbuf(int id, int msg, char *tmsg, char *buf, int write) {
	int ok;
	long old_sigbus;
	char *name, d, *origbuf;
	AVINFO *ainfo;

	old_sigbus = (long) Psignal(SIGBUS, handle_sigbus);
	if (old_sigbus == -32L)
		return (1);
	origbuf = buf;
	ok = 1;
	if (setjmp(check)) {
		ok = 0;
		ainfo = avp_get(id);
		if (ainfo)
			name = ainfo->name;
		else
			name = appl_name(id, "UNKNOWN");
		sprintf(almsg, rs_frstr[ALPRIVATEMEM], name, id, write ? "global"
				: "readable");
		if (frm_alert(2, almsg, altitle, conf.wdial, 0L) == 1) {
			sprintf(almsg, rs_frstr[ALPMDETAILS], tmsg, msg, buf, origbuf);
			frm_alert(1, almsg, altitle, conf.wdial, 0L);
		}
	} else {
		for (;; buf++) {
			d = *buf;
			if (write)
				*buf = d;
			if (!d)
				break;
		}
	}
	Psignal(SIGBUS, (void *) old_sigbus);
	return (ok);
}

/**
 * handle_sigbus
 *
 * Handler fuer SIGBUS und SIGSEGV bei avp_checkbuf(). Springt per
 * longjmp() zurÅck und meldet dabei einen Fehler.
 *
 * Eingabe:
 * signo: Signalnummer (SIGBUS)
 */
static void cdecl handle_sigbus(long signo)
{
	UNUSED(signo);
	Psigreturn();
	longjmp(check, 1);
}

/* EOF */
