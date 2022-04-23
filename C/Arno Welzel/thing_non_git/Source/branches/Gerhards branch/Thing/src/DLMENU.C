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
 DLMENU.C

 Thing
 Dialoge, die direkt vom Menue aus aufgerufen werden
 =========================================================================*/

#include "..\include\globdef.h"
#include "..\include\types.h"
#include "rsrc\thing.h"
#include "rsrc\thgtxt.h"
#include <ctype.h>
#include "..\include\jobid.h"
#include <new_rsc.h>
#include <basepage.h>
#include <errno.h>
#include <mt_gemx.h>
#include "..\xhdi\xhdi.h"

#ifdef __MINT__
extern BASEPAGE *_base;
#define _BasPag	_base
#endif

static short viewprint(short mode, char *path, char *name, short *rex);
static char *get_xxmaster(char *which);

static DCONF *dconf;
static DFORMAT *dformat;
static DNEWFOLD *dnewfold;
static DFUNC *dfunc;
static DFONT *dfont;
static char link[MAX_PLEN];

/**-------------------------------------------------------------------------
 dl_about()

 Ueber Thing
 -------------------------------------------------------------------------*/

/**
 * Initialisierung des Dialogs
 */
void di_about(void) {
	if (fi_about.open) {
		mybeep();
		frm_restore(&fi_about);
		return;
	}
	frm_start(&fi_about, conf.wdial, conf.cdial, 0);
}

#pragma warn -par
void de_about(short mode, short ret) {
	if (!mode) {
		switch (fi_about.exit_obj) {
		case ABINFO:
			fi_ainfo1.init();
			frm_norm(&fi_about);
			break;
		case ABOK:
			frm_end(&fi_about);
			break;
		}
	} else
		frm_end(&fi_about);
}
#pragma warn .par

void di_ainfo1(void) {
	char *ios, *iview, *it2g, *p;
	long dummy;
	TOS2GEM_COOKIE *t2g;
	OSHEADER *sys;
	short naes;
	OBJECT *objectTree;

	objectTree = rs_trindex[AINFO1];

	if (fi_ainfo1.open) {
		mybeep();
		frm_restore(&fi_ainfo1);
		return;
	}

	/* System-Infos eintragen - Betriebssystem */
	ios = getObjectText(objectTree, AIOS);
	iview = getObjectText(objectTree, AIDISPLAY);
	it2g = getObjectText(objectTree, AITOS2GEM);
	if (tb.sys & SY_MAGX) {
		if (Getcookie('MgMc', &dummy) == E_OK )
			strcpy(ios, "MagiC Mac");
		else if (Getcookie('MgMx', &dummy) == E_OK )
			strcpy(ios, "MagiC Mac X");
		else if (Getcookie('MgPC', &dummy) == E_OK )
			strcpy(ios, "MagiC PC");
		else
			sprintf(ios, "MagiC %x", (tb.magx->aesvars->version >> 8) & 0xff);

		/* MagiC-Versionsnummer */
		p = &ios[(short) strlen(ios)];
		sprintf(p, rs_trindex[LANGUAGE][LANGMGXVER].ob_spec.free_string,
				tb.magx->aesvars->version >> 8, tb.magx->aesvars->version & 0xff,
				(tb.magx->aesvars->date & 0xff000000L) >> 24,
				(tb.magx->aesvars->date & 0xff0000L) >> 16,
				tb.magx->aesvars->date & 0xffffL);
	} else {
		sys = get_oshdr();
		if (tb.sys & SY_MULTI) {
			if (glob.naesinfo) {
				naes = glob.naesinfo->version;
				sprintf(ios, "N.AES %d.%d.%d (", naes >> 8, (naes >> 4) & 15, naes & 15);
				naes = glob.naesinfo->date;
				p = &ios[strlen(ios)];
				sprintf(p, glob.dateformat, naes & 0x001f, (naes & 0x1e0) >> 5, 1980 + ((naes & 0xfe00) >> 9));
				strcat(ios, ")");
			}
			else if (tb.sys & SY_GNVA) {
				strcpy(ios, "Geneva");
				if (tb.sys & SY_MINT)
					strcat(ios, " + MiNT");
			} else {
				strcpy(ios, "MultiTOS");
				if (!(tb.sys & SY_MINT))
					strcat(ios, "(?)");
			}
		} else {
			strcpy(ios, "TOS");
			p = &ios[(short) strlen(ios)];
			sprintf(p, rs_trindex[LANGUAGE][LANGOSVER].ob_spec.free_string,
					sys->os_version >> 8, sys->os_version & 0xff,
					(sys->os_date & 0xff0000L) >> 16,
					(sys->os_date & 0xff000000L) >> 24,
					sys->os_date & 0xffffL);
			if (tb.sys & SY_MINT)
				strcat(ios, " & MiNT");
		}
	}

	/* System-Infos eintragen - Bildschirm */
	if (tb.planes <= 8)
		sprintf(iview, rs_trindex[LANGUAGE][LANGSCR1].ob_spec.free_string, tb.resx, tb.resy, tb.colors);
	else
		sprintf(iview, rs_trindex[LANGUAGE][LANGSCR2].ob_spec.free_string, tb.resx, tb.resy, tb.planes);

	/* System-Infos eintragen - TOS2GEM */
	if (Getcookie('T2GM', (long *) &t2g) == E_OK) {
		sprintf(it2g, rs_trindex[LANGUAGE][LANGT2GVER].ob_spec.free_string,
				t2g->date & 0x001f, (t2g->date & 0x1e0) >> 5,
				1980 + ((t2g->date & 0xfe00) >> 9));
	} else {
		sprintf(it2g, rs_trindex[LANGUAGE][LANGT2GMISS].ob_spec.free_string);
	}

	frm_start(&fi_ainfo1, conf.wdial, conf.cdial, 0);
}

/**
 *
 */
void de_ainfo1(short mode, short ret) {
	short done, exit_obj;
	UNUSED(ret);

	done = 0;
	if (!mode) {
		exit_obj = fi_ainfo1.exit_obj;
		switch (exit_obj) {
		case AIOK:
			done = 1;
			break;
		}
		fi_ainfo1.exit_obj = exit_obj;
		frm_norm(&fi_ainfo1);
	} else
		done = 1;

	if (done)
		frm_end(&fi_ainfo1);
}

/**-------------------------------------------------------------------------
 dl_new()

 Neues Objekt
 -------------------------------------------------------------------------*/
void dl_new_mode(short mode) {
	OBJECT *objectTree;

	objectTree = rs_trindex[NEWOBJ];

	setObjectFlags(objectTree, NFNAME, EDITABLE, FALSE);
	setObjectFlags(objectTree, NGFILE, EDITABLE, FALSE);
	setObjectFlags(objectTree, NGTITLE, EDITABLE, FALSE);
	setObjectFlags(objectTree, NSRDEST, EDITABLE, FALSE);
	setObjectFlags(objectTree, NSNAME, EDITABLE, FALSE);

	setObjectState(objectTree, NSREL, SELECTED, FALSE);
	setObjectFlags(objectTree, NSRDESC, HIDETREE, TRUE);
	setObjectFlags(objectTree, NSRDEST, HIDETREE, TRUE);

	switch (mode) {
	case 0:
		objectTree[NOSUB].ob_head = NOSFILE;
		objectTree[NOSUB].ob_tail = NOSFILE;
		objectTree[NOSFILE].ob_next = NOSUB;

		setObjectFlags(objectTree, NFNAME, EDITABLE, TRUE);
		fi_new.edit_obj = NFNAME;
		break;
	case 1:
		objectTree[NOSUB].ob_head = NOSGROUP;
		objectTree[NOSUB].ob_tail = NOSGROUP;
		objectTree[NOSGROUP].ob_next = NOSUB;

		setObjectFlags(objectTree, NGFILE, EDITABLE, TRUE);
		setObjectFlags(objectTree, NGTITLE, EDITABLE, TRUE);

		fi_new.edit_obj = NGFILE;
		break;
	case 2:
		objectTree[NOSUB].ob_head = NOSLINK;
		objectTree[NOSUB].ob_tail = NOSLINK;
		objectTree[NOSLINK].ob_next = NOSUB;

		setObjectFlags(objectTree, NSNAME, EDITABLE, TRUE);

		setObjectState(objectTree, NSABS, SELECTED, TRUE);
		setObjectFlags(objectTree, NSASEL, HIDETREE, FALSE);
		setObjectFlags(objectTree, NSADEST, HIDETREE, FALSE);

		fi_new.edit_obj = NSNAME;
		break;
	}
}

/**
 *
 */
void di_new(void) {
	W_PATH *wpath;
	char *fmask;
	short i;
	OBJECT *objectTree;

	objectTree = rs_trindex[NEWOBJ];

	if (fi_new.open) {
		mybeep();
		frm_restore(&fi_new);
		return;
	}

	dnewfold = pmalloc(sizeof(DNEWFOLD));
	if (!dnewfold) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return;
	}

	objectTree[NOFOLD].ob_state &= ~SELECTED;
	objectTree[NOFILE].ob_state &= ~SELECTED;
	objectTree[NOLINK].ob_state &= ~SELECTED;
	objectTree[NOFOLD].ob_state |= DISABLED;
	objectTree[NOFILE].ob_state |= DISABLED;
	objectTree[NOLINK].ob_state |= DISABLED;
	objectTree[NOFOLD].ob_flags &= ~(SELECTABLE | TOUCHEXIT);
	objectTree[NOFILE].ob_flags &= ~(SELECTABLE | TOUCHEXIT);
	objectTree[NOLINK].ob_flags &= ~(SELECTABLE | TOUCHEXIT);
	objectTree[NOGROUP].ob_state |= SELECTED;

	dl_new_mode(1);

	strShortener(objectTree[NGPATH].ob_spec.free_string, dnewfold->gpath = tb.homepath, 30);

	/* Falls Verzeichnisfenster aktiv, dann 'Ordner/Datei' als Standardvorgabe */
	if (tb.topwin) {
		if (tb.topwin->class == WCPATH) {
			dl_new_mode(0);
			objectTree[NOFOLD].ob_state |= SELECTED;
			objectTree[NOFOLD].ob_state &= ~DISABLED;
			objectTree[NOFILE].ob_state &= ~DISABLED;
			objectTree[NOFOLD].ob_flags |= (SELECTABLE | TOUCHEXIT);
			objectTree[NOFILE].ob_flags |= (SELECTABLE | TOUCHEXIT);
			objectTree[NOGROUP].ob_state &= ~SELECTED;

			wpath = (W_PATH *) tb.topwin->user;
			if (wpath->filesys.flags & SYMLINKS) {
				objectTree[NOLINK].ob_state &= ~DISABLED;
				objectTree[NOLINK].ob_flags |= (SELECTABLE | TOUCHEXIT);
			}

			strcpy(dnewfold->gpath = dnewfold->path, wpath->path);

			strShortener(objectTree[NFPATH].ob_spec.free_string, dnewfold->path, 30);
			strShortener(objectTree[NSPATH].ob_spec.free_string, dnewfold->path, 30);
			strShortener(objectTree[NGPATH].ob_spec.free_string, dnewfold->path, 30);

			objectTree[NFNAME].ob_spec.tedinfo->te_ptext[0] = 0;

			/* Falls Dateisystem nicht case-sensitiv, dann im Dialog nur Grosbuchstaben */
			fmask = objectTree[NFNAME].ob_spec.tedinfo->te_pvalid;
			i = 0;
			if (wpath->filesys.flags & (TOS | UPCASE))
				while (fmask[i]) {
					fmask[i] = 'x';
					i++;
				}
			else
				while (fmask[i]) {
					fmask[i] = 'X';
					i++;
				}

			fmask = objectTree[NSNAME].ob_spec.tedinfo->te_pvalid;
			i = 0;
			if (wpath->filesys.flags & (TOS | UPCASE)) {
				while (fmask[i]) {
					fmask[i] = 'x';
					i++;
				}
			} else {
				while (fmask[i]) {
					fmask[i] = 'X';
					i++;
				}
			}
		}
	}

	/* Weitere Vorbereitungen... */
	link[0] = 0;
	objectTree[NSNAME].ob_spec.tedinfo->te_ptext[0] = 0;
	objectTree[NSRDEST].ob_spec.tedinfo->te_ptext[0] = 0;
	objectTree[NSADEST].ob_spec.tedinfo->te_ptext[0] = 0;
	objectTree[NGTITLE].ob_spec.tedinfo->te_ptext[0] = 0;
	objectTree[NGFILE].ob_spec.tedinfo->te_ptext[0] = 0;
	objectTree[NGICON].ob_state |= SELECTED;
	objectTree[NGAUTOSAVE].ob_state |= SELECTED;

	frm_start(&fi_new, conf.wdial, conf.cdial, 0);
}

void de_new(short mode, short ret) {
	short dmode, dmode1;
	short done, ok, dret, exit_obj, i, fold, exist;
	short n, x, y, w, h;
	long fret;
	char fname[MAX_PLEN], folder[MAX_FLEN], name[MAX_PLEN];
	FILESYS filesys;
	XATTR xattr;
	FILE *fh;
	char *title, *file;
	WININFO *win;
	OBJECT *objectTree;

	UNUSED(ret);

	objectTree = rs_trindex[NEWOBJ];

	title = objectTree[NGTITLE].ob_spec.tedinfo->te_ptext;
	file = objectTree[NGFILE].ob_spec.tedinfo->te_ptext;

	done = 0;
	if (!mode) {
		exit_obj = fi_new.exit_obj;
		dmode = 0;
		if (objectTree[NOSUB].ob_tail == NOSGROUP)
			dmode = 1;
		if (objectTree[NOSUB].ob_tail == NOSLINK)
			dmode = 2;
		dmode1 = dmode;

		switch (exit_obj) {
		case NOFILE:
		case NOFOLD:
			dmode = 0;
			break;
		case NOGROUP:
			dmode = 1;
			break;
		case NOLINK:
			dmode = 2;
			break;
		case NSABS:
			if (objectTree[NSASEL].ob_flags & SELECTABLE)
				break;
		case NSREL:
			if ((exit_obj == NSREL) && (objectTree[NSRDEST].ob_flags & EDITABLE))
				break;
			objectTree[NSRDESC].ob_flags |= HIDETREE;
			objectTree[NSRDEST].ob_flags |= HIDETREE;
			objectTree[NSASEL].ob_flags |= HIDETREE;
			objectTree[NSADEST].ob_flags |= HIDETREE;
			objectTree[NSRDEST].ob_flags &= ~EDITABLE;
			objectTree[NSASEL].ob_flags &= ~SELECTABLE;
			obj_edit(fi_new.tree, fi_new.edit_obj, 0, 0, &fi_new.edit_idx, ED_END, fi_new.win.handle);
			fi_new.edit_obj = 0;
			fi_new.edit_idx = -1;
			switch (exit_obj) {
			case NSABS:
				objectTree[NSASEL].ob_flags &= ~HIDETREE;
				objectTree[NSASEL].ob_flags |= SELECTABLE;
				objectTree[NSADEST].ob_flags &= ~HIDETREE;
				fi_new.edit_obj = NSNAME;
				break;
			case NSREL:
				objectTree[NSRDESC].ob_flags &= ~HIDETREE;
				objectTree[NSRDEST].ob_flags &= ~HIDETREE;
				objectTree[NSRDEST].ob_flags |= EDITABLE;
				fi_new.edit_obj = NSRDEST;
				break;
			}
			obj_edit(fi_new.tree, fi_new.edit_obj, 0, 0, &fi_new.edit_idx, ED_INIT, fi_new.win.handle);
			frm_redraw(&fi_new, NOSLINK);
			mevent.ev_mwich = MU_M1;
			frm_do(&fi_new, &mevent);
			break;
		case NSASEL:
			if (full_fselect(link, NULL, "*.*", 0, rs_frstr[TXOBJSEARCH], 0, 305, &fi_new)) {
				strShortener(objectTree[NSADEST].ob_spec.tedinfo->te_ptext, link, 30);
				frm_redraw(&fi_new, NSADEST);
			}
			fi_new.exit_obj = exit_obj;
			frm_norm(&fi_new);
			break;
		case NOOK:
			switch (dmode) {
			char *p;

			case 0:
				ok = 1;
				fold = isObjectSelected(objectTree, NOFOLD);

				/* Dateinamen pruefen */
				p = objectTree[NFNAME].ob_spec.tedinfo->te_ptext;
				if (!*p || !isValidFileMask(p, FALSE)) {
					if (fold)
						frm_alert(1, rs_frstr[ALILLFNAME], altitle, conf.wdial, 0L);
					else
						frm_alert(1, rs_frstr[ALILLNAME], altitle, conf.wdial, 0L);
					ok = 0;
				}
				if (ok)
					done = NOOK;
				else {
					fi_new.exit_obj = exit_obj;
					frm_norm(&fi_new);
				}
				break;

			case 1:
				ok = 1;
				/* Pruefen, ob ein zulaessiger Dateiname vorliegt */
				if (!file[0]) {
					frm_alert(1, rs_frstr[ALNONAME], altitle, conf.wdial, 0L);
					ok = 0;
				}
				if (ok) {
					if (!isValidFileMask(file, FALSE) || strchr(file, '.')) {
						frm_alert(1, rs_frstr[ALILLNAME], altitle, conf.wdial, 0L);
						ok = 0;
					}
				}
				/* Pruefen, ob die Datei schon existiert */
				if (ok) {
					/* Dateinamen erzeugen */
					strcpy(fname, file);
					strcat(fname, ".grp");
					strcpy(name, dnewfold->gpath);
					strcat(name, fname);
					fsinfo(name, &filesys);
					fsconv(name, &filesys);
					fsconv(fname, &filesys);

					/* Datei suchen */
					i = file_exists(name, 0, 0L);

					/* Bei Bedarf nachfragen */
					if (i == 0) {
						if (frm_alert(2, rs_frstr[ALGROUPEXIST], altitle, conf.wdial, 0L) != 1)
							ok = 0;
					}
				}

				if (!ok) {
					fi_new.exit_obj = exit_obj;
					frm_norm(&fi_new);
				} else
					done = NOOK;
				break;

			case 2:
				ok = 1;
				if (objectTree[NSABS].ob_state & SELECTED) {
					if (!objectTree[NSADEST].ob_spec.tedinfo->te_ptext[0])
						ok = 0;
				} else {
					if (!*objectTree[NSRDEST].ob_spec.tedinfo->te_ptext)
						ok = 0;
				}
				if (!ok)
					frm_alert(1, rs_frstr[ALILLDEST], altitle, conf.wdial, 0L);
				else {
					p = objectTree[NSNAME].ob_spec.tedinfo->te_ptext;
					if (!*p || !isValidFileMask(p, FALSE)) {
						frm_alert(1, rs_frstr[ALILLNAME], altitle, conf.wdial, 0L);
						ok = 0;
					}
				}
				if (ok)
					done = NOOK;
				else {
					fi_new.exit_obj = exit_obj;
					frm_norm(&fi_new);
				}
				break;
			}
			break;

		case NOCANCEL:
			done = NOCANCEL;
			break;
		}

		if (dmode != dmode1) {
			if (fi_new.edit_obj) {
				obj_edit(fi_new.tree, fi_new.edit_obj, 0, 0, &fi_new.edit_idx, ED_END, fi_new.win.handle);
				fi_new.edit_obj = 0;
				fi_new.edit_idx = -1;
			}
			dl_new_mode(dmode);
			if (fi_new.edit_obj)
				obj_edit(fi_new.tree, fi_new.edit_obj, 0, 0, &fi_new.edit_idx, ED_INIT, fi_new.win.handle);
			frm_redraw(&fi_new, NOSUB);
			mevent.ev_mwich = MU_M1;
			frm_do(&fi_new, &mevent);
		}
	} else
		done = NOCANCEL;

	if (done) {
		frm_end(&fi_new);
		if (done == NOOK) {
			switch (dmode) {
			case 0:
				strcpy(folder, objectTree[NFNAME].ob_spec.tedinfo->te_ptext);
				strcpy(fname, dnewfold->path);
				strcat(fname, folder);

				/* Bei Bedarf Schreibweise anpassen */
				fsinfo(fname, &filesys);
				fsconv(fname, &filesys);

				/* Ordner/Datei erzeugen */
				dret = 1;
				if (fold)
					dret = Dcreate(fname);
				else {
					/* Auf existierende Datei hin pruefen */
					exist = !file_exists(fname, 0, &xattr);
					if (exist) {
						/* Ggf. vor Ueberschreiben warnen */
						if ((xattr.mode & S_IFMT) != S_IFDIR) {
							if (frm_alert(1, rs_frstr[ALFEXIST], altitle, conf.wdial, 0L) == 1)
								exist = 0;
						} else
							exist = 0;
					}
					if (!exist) {
						Fdelete(fname);
						fret = Fcreate(fname, 0);
						if (fret >= 0L) {
							Fclose((short) fret);
							dret = 0;
						} else
							dret = (short) fret;
					}
				}

				/* Fehler ggf. melden */
				if (dret != 0) {
					if (dret < 0) {
						if (fold)
							err_file(rs_frstr[ALPCREATE], (long) dret, fname);
						else
							err_file(rs_frstr[ALFLCREATE], (long) dret, fname);
					}
				}
				break;
			case 1:
				if (!title[0]) {
					title[0] = nkc_toupper(file[0]);
					i = 1;
					while (file[i]) {
						title[i] = nkc_tolower(file[i]);
						i++;
					}
					title[i] = 0;
				}
				/* Evtl. schon vorhandene Gruppe schliessen */
				win = tb.win;
				while (win) {
					if (win->class == WCGROUP) {
						if (!strcmp(((W_GRP *) win->user)->name, name)) {
							tb.topwin = win;
							dl_closewin();
							win = 0L;
						}
					}
					if (win)
						win = win->next;
				}

				/* Gruppendatei anlegen und oeffnen */
				graf_mouse(BUSYBEE, 0L);

				/* Auf gehts... */
				dret = 0;
				fh = fopen(name, "w");
				if (!fh) {
					dret = 1;
					sprintf(almsg, rs_frstr[ALNEWGROUP], title);
					graf_mouse(ARROW, 0L);
					frm_alert(1, almsg, altitle, conf.wdial, 0L);
				} else {
					file_header(fh, "Thing object group", fname);
					fprintf(fh, "INFO ");
					put_text(fh, title);
					fprintf(fh, " 2000 2000 6000 6000 %d ", conf.index.text);
					if (objectTree[NGAUTOSAVE].ob_state & SELECTED)
						fprintf(fh, "1\n");
					else
						fprintf(fh, "0\n");
					fclose(fh);
					graf_mouse(ARROW, 0L);

					/* Falls gewuenscht, dann Icon auf dem Desktop erzeugen */
					if (objectTree[NGICON].ob_state & SELECTED) {
						ICONDESK *p = desk.dicon + OBUSER;

						/* Freies Icon suchen */
						n = 0;
						for (i = OBUSER; i <= MAXICON && n == 0; i++, p++) {
							/* Freies Icon */
							if (p->class == IDFREE)
								n = i;
							else {
								/* Bereits vorhandenes Desktop-Icon */
								if (p->class == IDFILE) {
									if (!strcmp(p->spec.file->name, name)) {
										p->class = IDFREE;
										pfree(p->spec.file);
										icon_update(i);
										objc_offset(rs_trindex[DESKTOP], i, &x, &y);
										w = rs_trindex[DESKTOP][i].ob_width;
										h = rs_trindex[DESKTOP][i].ob_height;
										desk_draw(x, y, w, h);
										n = i;
									}
								}
							}
						}
						if (!n) {
							frm_alert(1, rs_frstr[ALDESKFULL], altitle, conf.wdial, 0L);
						} else {
							p = desk.dicon + n;
							p->spec.file = pmalloc(sizeof(D_FILE));
							if (!p->spec.file) {
								frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
							} else {
								p->class = IDFILE;
								p->select = 0;
								p->prevsel = 0;
								strcpy(p->title, title);
								strcpy(p->spec.file->name, name);
								p->spec.file->mode = 0;
								desk_freepos(n, &p->x, &p->y, 1);
								icon_update(n);
								objc_offset(rs_trindex[DESKTOP], n, &x, &y);
								w = rs_trindex[DESKTOP][n].ob_width;
								h = rs_trindex[DESKTOP][n].ob_height;
								desk_draw(x, y, w, h);
							}
						}
					}
					wgrp_open(name, 0L, 0L);
				}
				break;
			case 2:
				strcpy(fname, dnewfold->path);
				strcat(fname, objectTree[NSNAME].ob_spec.tedinfo->te_ptext);

				/* Bei Bedarf Schreibweise anpassen */
				fsinfo(fname, &filesys);
				fsconv(fname, &filesys);

				/* Link anlegen */
				if (objectTree[NSABS].ob_state & SELECTED)
					fret = Fsymlink(link, fname);
				else
					fret = Fsymlink(objectTree[NSRDEST].ob_spec.tedinfo->te_ptext, fname);

				/* Fehler ggf. melden */
				if ((dret = (short) fret) != 0) {
					if (fret < 0)
						err_file(rs_frstr[ALLCREATE], fret, fname);
				}
				break;
			}
			if (!dret) {
				char *path;

				if (dmode == 1)
					path = dnewfold->gpath;
				else
					path = dnewfold->path;
				for (i = 0; i < MAX_PWIN; i++) {
					if (glob.win[i].state & WSOPEN) {
						if (!strcmp(((W_PATH *) glob.win[i].user)->path, path)) {
							wpath_update(&glob.win[i]);
							win_redraw(&glob.win[i], tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h);
							win_slide(&glob.win[i], S_INIT, 0, 0);
						}
					}
				}
			}
		}
		if (dnewfold)
			pfree(dnewfold);
	}
}

/**-------------------------------------------------------------------------
 dl_font()

 Schriftart
 -------------------------------------------------------------------------*/

/**
 * Unterfunktion: Routine fuer das User-Objekt zur Darstellung der
 * gewaehlten Schriftart im Beispiel
 *
 * @param *parmblock
 */
short cdecl dl_font_usr(PARMBLK *parmblock) {
	GFONT *font;
	short dummy,pxy[4],ah,av,cw,ch,tx,ty;
	GRECT orect,crect;
	char *sample;

	font = (GFONT *)parmblock->pb_parm;
	sample = "Murphy's word is law!";

	/* Clipping-Rechteck und Objekt-Rechteck holen */
	crect.g_x = parmblock->pb_xc;
	crect.g_y = parmblock->pb_yc;
	crect.g_w = parmblock->pb_wc;
	crect.g_h = parmblock->pb_hc;

	orect.g_x = parmblock->pb_x;
	orect.g_y = parmblock->pb_y;
	orect.g_w = parmblock->pb_w;
	orect.g_h = parmblock->pb_h;

	/* Schnittflaeche bilden und nur ausgeben, wenn noetig */
	if (rc_intersect((GRECT *)&crect, (GRECT *)&orect)) {
		/* Attribute setzen */
		vst_font(tb.vdi_handle,font->id);
		if (font->size < 0)
			vst_height(tb.vdi_handle, -font->size, &cw, &ch, &dummy, &dummy);
		else
			vst_point(tb.vdi_handle, font->size, &cw, &ch, &dummy, &dummy);
		vst_alignment(tb.vdi_handle, 0, 3, &ah, &av);
		if (font->attr&0x0040) {
			vst_color(tb.vdi_handle, font->bcol);
			vsf_color(tb.vdi_handle, font->fcol);
		} else {
			vst_color(tb.vdi_handle, font->fcol);
			vsf_color(tb.vdi_handle, font->bcol);
		}
		if (dfont->bpat == 7)
			vsf_interior(tb.vdi_handle, FIS_SOLID);
		else if (dfont->bpat == 0)
			vsf_interior(tb.vdi_handle, FIS_HOLLOW);
		else {
			vsf_interior(tb.vdi_handle, FIS_PATTERN);
			vsf_style(tb.vdi_handle, dfont->bpat);
		}
		vsf_perimeter(tb.vdi_handle, 0);

		/* Clipping aktivieren und Mauszeiger abschalten */
		pxy[0] = orect.g_x;
		pxy[1] = orect.g_y;
		pxy[2] = pxy[0] + orect.g_w - 1;
		pxy[3] = pxy[1] + orect.g_h - 1;
		vs_clip(tb.vdi_handle, 1, pxy);

		/* Hintergrund zeichnen */
		pxy[0] = parmblock->pb_x;
		pxy[1] = parmblock->pb_y;
		pxy[2] = pxy[0] + parmblock->pb_w - 1;
		pxy[3] = pxy[1] + parmblock->pb_h - 1;
		vswr_mode(tb.vdi_handle, MD_REPLACE);
		v_bar(tb.vdi_handle, pxy);

		/* Beispieltext ausgeben */
		vswr_mode(tb.vdi_handle, MD_TRANS);
		tx = parmblock->pb_x;
		ty = parmblock->pb_y + parmblock->pb_h - 1;
		if (font->attr & 0x0020) {
			vst_effects(tb.vdi_handle, (font->attr & 0x001f) | 0x0002);
			cw >>= 3;
			if (cw < 2)
				cw = 2;
			ch >>= 3;
			if (ch < 2)
				ch = 2;
			v_gtext(tb.vdi_handle, tx + cw, ty, sample);
			ty -= ch;
		}
		vst_effects(tb.vdi_handle, font->attr & 0x001f);
		v_gtext(tb.vdi_handle, tx, ty, sample);

		/* Mauszeiger einschalten, Clipping aus */
		vs_clip(tb.vdi_handle, 0, pxy);

		/* "Standard"-Attribute setzen */
		vswr_mode(tb.vdi_handle, MD_REPLACE);
		vst_alignment(tb.vdi_handle, ah,av, &ah, &av);
		vst_font(tb.vdi_handle, 1);
		vst_point(tb.vdi_handle, 10, &dummy, &dummy, &dummy, &dummy);
	}

	return (parmblock->pb_currstate);
}

/**
 * Unterfunktion: Ermitteln aller Schriftgroessen eines Fonts
 *
 * @param fid
 * @param **list
 * @param size
 */
void dl_font_size(short fid, char **list, short size) {
	short i, fontsize, du;

	pl_size.sel = -1;
	pl_size.num = 0;

	if (fid != -1) {
		/* Font setzen */
		vst_font(tb.vdi_handle, fid);

		/* Schriftgroessen ermitteln */
		for (i = 0; i < 100; i++) {
			fontsize = vst_point(tb.vdi_handle, i, &du, &du, &du, &du);
			if (fontsize == i) {
				itoa(fontsize, list[pl_size.num], 10);
				if (size == fontsize)
					pl_size.sel = pl_size.num;
				pl_size.num++;
			}
		}
		vst_font(tb.vdi_handle, 1);
	}
}

/**
 *
 *
 * @param mode
 * @param ret
 */
#pragma warn -par
void de_font(short mode, short ret) {
	short done, dos, show;
	AVINFO *avinfo, *avnext;
	WININFO *win;
	W_GRP *wgrp = NULL;
	GRECT frec;
	short mx, my, mb, ks, mx1, my1, dx, dy;
	short tx1, ty1, tx2, ty2;
	short w, d;
	short whandle, owner;
	ACWIN *acwin;
	OBJECT *objectTree;
	short fret;
	char path[MAX_PLEN];
	THINGIMG *timg = NULL;

	objectTree = rs_trindex[FONT];

	done = 0;
	if (!mode) {
		if (dfont->intern) {
			switch (dfont->class) {
			case WCPATH:
				timg = &glob.dir_img;
				break;
			case WCGROUP:
				wgrp = (W_GRP *)dfont->fwin->user;
				timg = &wgrp->img_info;
				break;
			}
		}
		dos = 0;
		wind_update(BEG_UPDATE);
		switch (fi_font.exit_obj) {
		case FOCANCEL:
		case FOOK:
			done = fi_font.exit_obj;
			break;
		case FOSAMPLE:
			/* Font D&D */
			if (!dfont->intern) {
				/* Rechteck berechnen */
				objc_offset(objectTree, FOSAMPLE, &frec.g_x, &frec.g_y);
				frec.g_w = objectTree[FOSAMPLE].ob_width;
				frec.g_h = objectTree[FOSAMPLE].ob_height;
				if (frec.g_x < tb.desk.g_x)
					frec.g_x = tb.desk.g_x;
				if (frec.g_y < tb.desk.g_y)
					frec.g_y = tb.desk.g_y;
				if (frec.g_x + frec.g_w > tb.desk.g_x + tb.desk.g_w)
					frec.g_x = tb.desk.g_x + tb.desk.g_w - frec.g_w;
				if (frec.g_y + frec.g_h > tb.desk.g_y + tb.desk.g_h)
					frec.g_y = tb.desk.g_y + tb.desk.g_h - frec.g_h;

				/* Ausgangskoordinaten sichern */
				tx1 = frec.g_x;
				ty1 = frec.g_y;
				tx2 = tx1 + frec.g_w;
				ty2 = ty1 + frec.g_h;

				/* Auf gehts... */
				wind_update(BEG_MCTRL);
				graf_mouse(FLAT_HAND, 0L);
				rub_frame(&frec);
				graf_mkstate(&mx, &my, &mb, &ks);
				mx1 = mx;
				my1 = my;
				while (mb&1) {
					/* Mausposition veraendert? */
					if (mx1 != mx || my1 != my) {
						dx = mx - mx1;
						dy = my - my1;
						/* Delta auf Desktop begrenzen */
						if (tx1 + dx < tb.desk.g_x)
							dx = tb.desk.g_x - tx1;
						if (ty1 + dy < tb.desk.g_y)
							dy = tb.desk.g_y - ty1;
						if (tx2 + dx > tb.desk.g_x + tb.desk.g_w)
							dx = (tb.desk.g_x + tb.desk.g_w) - tx2;
						if( ty2 + dy > tb.desk.g_y + tb.desk.g_h)
							dy = (tb.desk.g_y + tb.desk.g_h) - ty2;

						/* Nur aktualisieren, wenn Delta immer noch !=0 */
						if (dx != 0 || dy != 0) {
							rub_frame(&frec);
							tx1 += dx;
							ty1 += dy;
							tx2 += dx;
							ty2 += dy;
							frec.g_x = tx1;
							frec.g_y = ty1;
							rub_frame(&frec);
						}

						mx1 += dx;
						my1 += dy;
					}
					graf_mkstate(&mx, &my, &mb, &ks);
				}
				rub_frame(&frec);
				graf_mouse(ARROW, 0L);
				wind_update(END_MCTRL);

				/* Pruefen, ob Zielfenster vorhanden ist */
				whandle = wind_find(mx, my);
				if (whandle) {
					/* Ja, dann Eigentuemer ermitteln */
					owner = -1;
					if (tb.sys & SY_OWNER) {
						if (!wind_get(whandle, WF_OWNER, &owner, &d, &d, &d))
						owner = -1;
					} else {
						acwin = acwin_find(whandle);
						if (acwin)
							owner = acwin->id;
					}
					/* Falls vorhanden, dann an Eigentuemer FONT_CHANGED schicken */
					if (owner != -1 && owner != tb.app_id) {
						appl_send(owner, FONT_CHANGED, 0, whandle, dfont->lfont.id, dfont->lfont.size, dfont->lfont.fcol, dfont->lfont.attr);
					}
				}
			}
			break;
		case FOFONTA:
			/* Anderer Font, dann ID setzen und Groessen ermitteln */
			if (dfont->class == WCCON)
				dfont->lfont.id = gdos.mfontid[pl_font.sel * 2L];
			else
				dfont->lfont.id = gdos.fontid[pl_font.sel * 2L];

			dl_font_size(dfont->lfont.id, dfont->sizelist, dfont->lfont.size);
			sprintf(objectTree[FOID].ob_spec.tedinfo->te_ptext, "ID: %-5d", dfont->lfont.id);
			frm_redraw(&fi_font, FOID);
			dos = 1;
			break;
		case FOSIZE:
			poplist_get(&fi_font, &pl_size);
		case FOSIZEA:
			dfont->lfont.size = atoi(objectTree[FOSIZE].ob_spec.tedinfo->te_ptext);
			if (dfont->lfont.size < 1)
				dfont->lfont.size = dfont->font->size;
			dos = 1;
			break;
		case FOFCOL:
			dfont->lfont.fcol = pop_tcolor.sel / 2 - 1;
			dos = 1;
		break;
		case FOBCOL:
			dfont->lfont.bcol=pop_bcolor.sel / 2 - 1;
			dos = 1;
			break;
		case FOBPAT:
			dfont->bpat = pop_bpat.sel / 2 - 1;
			dos = 1;
			break;
		case FOATTR1:
		case FOATTR2:
		case FOATTR3:
		case FOATTR4:
		case FOATTR5:
		case FOATTR6:
		case FOATTR7:
			w = 1 << (fi_font.exit_obj - FOATTR1);
			if (isObjectSelected(objectTree, fi_font.exit_obj))
				dfont->lfont.attr |= w;
			else
				dfont->lfont.attr &= ~w;
			dos = 1;
			break;
		case FOIMGF:
			if (dfont->class == WCGROUP) {
				if (wgrp->img_ok && (wgrp->img_planes < tb.planes)) {
					if (frm_alert(1, rs_frstr[ALNEWIMG], altitle, conf.wdial, 0L) == 2) {
						frm_norm(&fi_font);
						break;
					}
				}
				frm_redraw(&fi_font, ROOT);
			}
			strcpy(path, dfont->dirimg);
			wind_update(END_UPDATE);
			fret = full_fselect(path, NULL, "*.IMG", 0, rs_frstr[TXIMGSEARCH], 0, 0, &fi_font);
			wind_update(BEG_UPDATE);
			if (fret) {
				if (fret == 2)
					*dfont->dirimg = 0;
				else if (desk_icheck(timg, path, 0))
					strcpy(dfont->dirimg, path);
				strShortener(objectTree[FOIMG].ob_spec.tedinfo->te_ptext, dfont->dirimg, 30);
				frm_redraw(&fi_font, FOIMG);
			}
			frm_norm(&fi_font);
			break;
		}
		/* Beispiel neu zeichnen, wenn noetig */
		if (dos) {
			dos = 0;
			frm_redraw(&fi_font, FOSAMPLE);
		}
		wind_update(END_UPDATE);
	} else {
		done = FOCANCEL;
	}

	if (done) {
		frm_end(&fi_font);

		/* Speicher fuer die Popup-Listen wieder freigeben */
		pfree(dfont->sizelist);
		pfree(dfont->sizename);

		/* Falls "OK" angeklickt, dann Einstellungen uebernehmen */
		if (done == FOOK) {
			if (dfont->intern) {
				/* Thing-intern */
				memcpy(dfont->font, &dfont->lfont, sizeof(GFONT));
				graf_mouse(BUSYBEE, 0L);
				/* Fenster aktualisieren */
				switch(dfont->class) {
				case WCCON: /* Console */
					cwin_update();
					break;
				case WCPATH: /* Verzeichnisse */
					conf.bpat = dfont->bpat;
					if (strcmp(conf.dirimg, dfont->dirimg)) {
						desk_ifree(&glob.dir_img);
						strcpy(conf.dirimg, dfont->dirimg);
						if (*conf.dirimg) {
							glob.dir_ok = desk_iload(&glob.dir_img, conf.dirimg, 0, ALDIRIMGERR);
						}
					}
					win = tb.win;
					while (win) {
						if (win->class == WCPATH) {
							show = 0;
							if (isObjectSelected(objectTree, FOVSIZE))
								show |= SHOWSIZE;
							if (isObjectSelected(objectTree, FOVDATE))
								show |= SHOWDATE;
							if (isObjectSelected(objectTree, FOVTIME))
								show |= SHOWTIME;
							if (isObjectSelected(objectTree, FOVFLAG))
								show |= SHOWATTR;
							if (show != conf.index.show) {
								conf.index.show = show;
								mn_check();
								graf_mouse(BUSYBEE, 0L);
								wpath_iupdate(0L, 1);
								graf_mouse(ARROW, 0L);
							} else {
								wpath_iupdate(win, 0);
								wpath_tree(win);
								w_draw(win);
								win_slide(win, S_INIT, 0, 0);
							}
						}
						win = win->next;
					}
					break;
					case WCGROUP: /* Gruppe */
					if (strcmp(wgrp->img, dfont->dirimg)) {
						if (wgrp->img_ok)
							desk_ifree(&wgrp->img_info);
						strcpy(wgrp->img, dfont->dirimg);
						if (*wgrp->img) {
							wgrp->img_ok = desk_iload(&wgrp->img_info, wgrp->img, 0, ALDIRIMGERR);
							wgrp->img_planes = tb.planes;
						} else
						wgrp->img_ok = 0;
					}
					wgrp->font.id = dfont->lfont.id;
					wgrp->font.size = dfont->lfont.size;
					wgrp->font.fcol = dfont->lfont.fcol;
					wgrp->font.bcol = dfont->lfont.bcol;
					if (tb.colors < 16) {
						wgrp->fcol = wgrp->font.fcol;
						wgrp->bcol = wgrp->font.bcol;
						wgrp->bpat = dfont->bpat;
					} else {
						wgrp->fcol16 = wgrp->font.fcol;
						wgrp->bcol16 = wgrp->font.bcol;
						wgrp->bpat16 = dfont->bpat;
					}
					wgrp_tree(dfont->fwin);
					win_redraw(dfont->fwin, tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h);
					win_slide(dfont->fwin, S_INIT, 0, 0);
					wgrp_change(dfont->fwin);
					break;
				}

				/* Bei Bedarf VA_FONTCHANGED an die betroffenen Applikationen schicken */
				if (dfont->class == WCPATH || dfont->class == WCCON) {
					avinfo = glob.avinfo;
					while (avinfo) {
						avnext = avinfo->next;
						if (avinfo->state & 0x0008) {
							/* Nur, falls entsprechend angemeldet */
							if (avp_check(avinfo->id)) {
								appl_send(avinfo->id, VA_FONTCHANGED, 0, conf.font.id, conf.font.size, con.font.id, con.font.size, 0);

								/* Spezialbehandlung von TreeView */
								if (!strcmp(avinfo->name, "TREEVIEW"))
									appl_send(avinfo->id, VA_FILEFONT, 0, conf.font.id, conf.font.size, 0, 0, 0);
							}
						}
						avinfo = avnext;
					}
				}
				graf_mouse(ARROW, 0L);
			} else {
				/* Font-Protokoll */
				/* Antwort an den Absender schicken */
				if(dfont->fmsg[1]!=-1) {
					appl_send(dfont->fmsg[1], FONT_CHANGED, 0, dfont->fmsg[3],
							dfont->lfont.id, dfont->lfont.size, dfont->lfont.fcol,
							dfont->lfont.attr);
				}
			}
		}

		/* Semaphore loeschen, Speicher freigeben */
		pfree(dfont);
		glob.sm_fontsel = 0;
	}
}
#pragma warn .par

/**
 *
 *
 * @param *msg
 */
void dl_font(short *msg) {
	short i, j;
	short minade, maxade, dist[5], mw, eff[3];
	short w, wmin, wmax, dummy;
	short dotest;
	short hlp;
	char name[40];
	short ret, font_format, flags;
	OBJECT *objectTree;

	objectTree = rs_trindex[FONT];

	if (fi_font.open) {
		mybeep();
		frm_restore(&fi_font);
		return;
	}

	dfont = pmalloc(sizeof(DFONT));
	if (!dfont) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return;
	}

	glob.sm_fontsel = 1; /* Semaphore setzen */

	/* Spezielle Attribute komplett abschalten */
	objectTree[FOSUB].ob_head = NIL;
	objectTree[FOSUB].ob_tail = NIL;
	for (i = FOATTR1; i <= FOATTR7; i++) {
		objectTree[i].ob_state |= DISABLED;
		objectTree[i].ob_flags &= ~(SELECTABLE | TOUCHEXIT);
	}

	objectTree[FOIMG].ob_flags |= HIDETREE;
	objectTree[FOIMGF].ob_flags |= HIDETREE;

	wind_update(BEG_UPDATE);
	if (!msg) {
		/* Thing-intern */
		dfont->intern = 1;
		/* Einstellungen abhaengig vom aktiven Fenster */
		dfont->class = WCPATH;
		dfont->fwin = tb.topwin;
		if (tb.topwin)
			dfont->class = tb.topwin->class;

		switch (dfont->class) {
		case WCCON: /* Console-Fenster */
			dfont->intern = 2;
			/* Bei Bedarf Liste der moeglichen Console-Fonts aufbauen */
			if (!gdos.mnumfonts) {
				graf_mouse(BUSYBEE, 0L);
				for (i = 0; i < gdos.numfonts; i++) {
					dotest = 1;
					/* Sicherheitshalber nur mit GDOS ;-) */
					if (tb.gdos) {
						ret = vqt_ext_name (tb.vdi_handle, gdos.fontid[i * 2L + 1], name, &font_format, &flags);

						/* Function present?, Font monospaced? */
						if (ret)
						{
							dotest=0; /* Keine weiteren Tests noetig */
							if ( flags & 0x01)
								wmin = wmax = 0;
							else {
								wmin = 0;
								wmax = 1;
							}
						}
					}

					/* Hat nicht geklappt ... also wie bisher :( */
					if (dotest) {
						vst_font(tb.vdi_handle,gdos.fontid[i * 2L]);
						vqt_fontinfo(tb.vdi_handle, &minade, &maxade, dist, &mw, eff);
						wmin = 32767;
						wmax = 0;
						for (j = minade; j <= maxade; j++) {
							vqt_width(tb.vdi_handle, (char)j, &w, &dummy, &dummy);
							if (w > wmax)
								wmax = w;
							if (w < wmin)
								wmin = w;
						}
					}

					if (wmin == wmax) {
						gdos.mfontname[gdos.mnumfonts] = gdos.fontname[i];
						gdos.mfontid[gdos.mnumfonts * 2L] = gdos.fontid[i * 2L];
						gdos.mfontid[gdos.mnumfonts * 2L + 1] = gdos.fontid[i * 2L + 1];
						gdos.mnumfonts++;
					}
				}
				graf_mouse(ARROW, 0L);
			}

			setObjectText(objectTree, FOTITLE, rs_frstr[TXFTCONSOLE]);

			dfont->bpat = 7;
			dfont->font = &con.font;
			pl_font.list = gdos.mfontname;
			pl_font.num = gdos.mnumfonts;
			for (i = 0; i < gdos.mnumfonts; i++)
				if (gdos.mfontid[i * 2L] == dfont->font->id)
					pl_font.sel = i;

			setObjectDisabled(objectTree, FOFCOL);
			setObjectDisabled(objectTree, FOFCOLS);
			setObjectDisabled(objectTree, FOBCOL);
			setObjectDisabled(objectTree, FOBCOLS);
			setObjectDisabled(objectTree, FOBPAT);
			setObjectDisabled(objectTree, FOBPATS);
			break;

		case WCPATH: /* Verzeichnis */
			objectTree[FOSUB].ob_head = FOSVIEW;
			objectTree[FOSUB].ob_tail = FOSVIEW;
			objectTree[FOSVIEW].ob_next = FOSUB;

			objectTree[FOIMG].ob_flags &= ~HIDETREE;
			objectTree[FOIMGF].ob_flags &= ~HIDETREE;

			hlp = conf.index.show;
			setObjectState(objectTree, FOVSIZE, SELECTED, hlp & SHOWSIZE);
			setObjectState(objectTree, FOVDATE, SELECTED, hlp & SHOWDATE);
			setObjectState(objectTree, FOVTIME, SELECTED, hlp & SHOWTIME);
			setObjectState(objectTree, FOVFLAG, SELECTED, hlp & SHOWATTR);

			strcpy(dfont->dirimg, conf.dirimg);
			strShortener(objectTree[FOIMG].ob_spec.tedinfo->te_ptext, dfont->dirimg, 30);

			setObjectText(objectTree, FOTITLE, rs_frstr[TXFTPATH]);

			dfont->font = &conf.font;
			pl_font.list = gdos.fontname;
			pl_font.num = gdos.numfonts;
			for (i = 0; i < gdos.numfonts; i++)
			if (gdos.fontid[i * 2L] == dfont->font->id)
				pl_font.sel = i;
			dfont->bpat = conf.bpat;

			unsetObjectDisabled(objectTree, FOFCOL);
			unsetObjectDisabled(objectTree, FOFCOLS);
			unsetObjectDisabled(objectTree, FOBCOL);
			unsetObjectDisabled(objectTree, FOBCOLS);
			unsetObjectDisabled(objectTree, FOBPAT);
			unsetObjectDisabled(objectTree, FOBPATS);
			break;

		case WCGROUP: /* Gruppe */
			dfont->intern = 2;
			setObjectText(objectTree, FOTITLE, rs_frstr[TXFTGRP]);

			dfont->font = &((W_GRP *)tb.topwin->user)->font;
			if (tb.colors < 16)
				dfont->bpat = ((W_GRP *)tb.topwin->user)->bpat;
			else
				dfont->bpat = ((W_GRP *)tb.topwin->user)->bpat16;
			pl_font.list = gdos.fontname;
			pl_font.num = gdos.numfonts;
			for (i = 0; i < gdos.numfonts; i++)
				if (gdos.fontid[i * 2L] == dfont->font->id)
					pl_font.sel = i;
			strcpy(dfont->dirimg, ((W_GRP *)tb.topwin->user)->img);
			strShortener(objectTree[FOIMG].ob_spec.tedinfo->te_ptext, dfont->dirimg, 30);

			unsetObjectDisabled(objectTree, FOFCOL);
			unsetObjectDisabled(objectTree, FOFCOLS);
			unsetObjectDisabled(objectTree, FOBCOL);
			unsetObjectDisabled(objectTree, FOBCOLS);
			unsetObjectDisabled(objectTree, FOBPAT);
			unsetObjectDisabled(objectTree, FOBPATS);

			objectTree[FOIMG].ob_flags &= ~HIDETREE;
			objectTree[FOIMGF].ob_flags &= ~HIDETREE;
			break;
		}
	} else {
		/* Auswahl durch Font-Protokoll */
		dfont->intern = 0;

		objectTree[FOSUB].ob_head = FOSATTR;
		objectTree[FOSUB].ob_tail = FOSATTR;
		objectTree[FOSATTR].ob_next = FOSUB;
		for (i = FOATTR1; i <= FOATTR7; i++) {
			unsetObjectDisabled(objectTree, i);
			objectTree[i].ob_flags |= (SELECTABLE | TOUCHEXIT);
		}

		for (i = 0; i < 8; i++)
			dfont->fmsg[i] = msg[i];

		dfont->mfont.id = msg[4];
		dfont->mfont.size = msg[5];
		dfont->mfont.fcol = msg[6];
		dfont->mfont.bcol = 0;
		dfont->mfont.attr = msg[7];

		pl_font.list = gdos.fontname;
		pl_font.num = gdos.numfonts;
		pl_font.sel = 0;
		for (i = 0; i < gdos.numfonts; i++)
			if (gdos.fontid[i * 2L] == dfont->mfont.id)
				pl_font.sel = i;

		dfont->mfont.id = gdos.fontid[pl_font.sel * 2L];
		if (dfont->mfont.size == 0)
			dfont->mfont.size = 10;
		dfont->font = &dfont->mfont;
		dfont->bpat = 7;

		unsetObjectDisabled(objectTree, FOFCOL);
		unsetObjectDisabled(objectTree, FOFCOLS);
		setObjectDisabled(objectTree, FOBCOL);
		setObjectDisabled(objectTree, FOBCOLS);
		setObjectDisabled(objectTree, FOBPAT);
		setObjectDisabled(objectTree, FOBPATS);

		setObjectText(objectTree, FOTITLE, rs_frstr[TXFTFONTSEL]);
	}

	/* Parameter lokal sichern */
	memcpy(&dfont->lfont, dfont->font, sizeof(GFONT));

	/* Einige Sicherheitschecks */
	if (dfont->lfont.size < 1)
		dfont->lfont.size = 1;
	dfont->lfont.fcol &= 15;
	dfont->lfont.bcol &= 15;
	dfont->bpat &= 7;

	/* User-Objekt fuer Schriftgroesse initialisieren */
	usr_fontsample.ub_parm = (long)&dfont->lfont;

	/* Attribute eintragen */
	w = 0x0001;
	hlp = dfont->lfont.attr;
	for (i = 0; i < 7; i++) {
		setObjectState(objectTree, FOATTR1 + i, SELECTED, hlp & w);
		w <<= 1;
	}

	/* Popup-Liste fuer Schriftgroessen einrichten */
	pl_size.sel = -1;
	pl_size.num = 0;

	/* ... Speicher fuer Schriftgroessen (maximal 1-100) reservieren */
	dfont->sizename=pmalloc((long)(100*4));
	if (!dfont->sizename) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		glob.sm_fontsel = 0;
		pfree(dfont);
		return;
	}

	/* ... Speicher fuer Zeigerarray auf die Schriftgroessen reservieren */
	dfont->sizelist = pmalloc(sizeof(char *)*(long)100);
	if (!dfont->sizelist) {
		pfree(dfont->sizename);
		pfree(dfont);
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		glob.sm_fontsel = 0;
		return;
	}

	/* ... Zeigerarray initialisieren und Fontgroessen eintragen */
	for (i = 0; i < 100; i++)
		dfont->sizelist[i] = &dfont->sizename[i * 4];
	pl_size.list = dfont->sizelist;
	dl_font_size(dfont->lfont.id, dfont->sizelist, dfont->lfont.size);

	/* Sonstige Dialogelemente */
	itoa(dfont->lfont.size, objectTree[FOSIZE].ob_spec.tedinfo->te_ptext,10);
	pop_tcolor.sel = dfont->lfont.fcol * 2 + 2;
	pop_bcolor.sel = dfont->lfont.bcol * 2 + 2;
	pop_bpat.sel = dfont->bpat * 2 + 2;
	sprintf(objectTree[FOID].ob_spec.tedinfo->te_ptext, "ID: %-5d", dfont->lfont.id);

	/* Kontexthilfe */
	if (dfont->intern)
		fi_font.userinfo = rs_frstr[HMFONT];
	else
		fi_font.userinfo = rs_frstr[HMFONTSEL];
	wind_update(END_UPDATE);

	frm_start(&fi_font, conf.wdial, conf.cdial,0);
}

/**-------------------------------------------------------------------------
 dl_config()

 Voreinstellung
 -------------------------------------------------------------------------*/
void dl_config_mode(short mode) {
	switch (mode) {
	case 0:
		setActiveCard(dconf->configCard, CODESK, FALSE);
		fi_config.edit_obj = 0;
		fi_config.userinfo = rs_frstr[HMCONFIG0];
		break;

	case 1:
		setActiveCard(dconf->configCard, COWIN, FALSE);
		fi_config.edit_obj = COSCROLL;
		fi_config.userinfo = rs_frstr[HMCONFIG1];
		break;

	case 2:
		setActiveCard(dconf->configCard, COPROG, FALSE);
		fi_config.edit_obj = 0;
		fi_config.userinfo = rs_frstr[HMCONFIG2];
		break;

	case 3:
		setActiveCard(dconf->configCard, COCOPY, FALSE);
		fi_config.edit_obj = COBUFSIZE;
		fi_config.userinfo = rs_frstr[HMCONFIG3];
		break;

	case 4:
		setActiveCard(dconf->configCard, COT2G, FALSE);
		fi_config.edit_obj = COT2GHIST;
		fi_config.userinfo = rs_frstr[HMCONFIG4];
		break;

	case 5:
		setActiveCard(dconf->configCard, COWIN2, FALSE);
		fi_config.edit_obj = COFLEFT;
		fi_config.userinfo = rs_frstr[HMCONFIG5];
		break;
	}
}

/**
 *
 */
short dl_config_loadpic(short redraw) {
	short ret = 0;
	OBJECT *objectTree = rs_trindex[CONFIG];

	conf.imguse = isObjectSelected(objectTree, COIMGUSE);
	conf.imgcenter = isObjectSelected(objectTree, COIMGCENTER);
	conf.imgpal = isObjectSelected(objectTree, COIMGPAL);
	conf.imgtrans = isObjectSelected(objectTree, COIMGTRANS);
	if (dconf->imguse != conf.imguse || dconf->imgcenter != conf.imgcenter
			|| dconf->imgpal != conf.imgpal || (dconf->imgtrans != conf.imgtrans)
			|| (conf.imguse && strcmp(dconf->imgname, conf.imgname) != 0)) {
		if (strcmp(conf.imgname, dconf->imgname) != 0 || dconf->imguse != conf.imguse || dconf->imgpal != conf.imgpal) {
			desk_ifree(&glob.img_info);
			glob.img_ok = 0;
			if (conf.imguse) {
				strcpy(conf.imgname, dconf->imgname);
				glob.img_ok = conf.imguse = desk_iload(&glob.img_info, conf.imgname, conf.imgpal, ALIMGERR);
			}
		}
		redraw = ret = 1;
	}
	if (redraw)
		desk_draw(tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h);

	return (ret);
}

/**
 *
 */
void di_config(void) {
	short i;
	OBJECT *objectTree;
	short hlp;

	objectTree = rs_trindex[CONFIG];

	if (fi_config.open) {
		mybeep();
		frm_restore(&fi_config);
		return;
	}

	dconf = pmalloc(sizeof(DCONF));
	if (!dconf) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return;
	}

	/* Die einzelnen Karteikarten des Dialogs zusammenhaengen. */
	dconf->configCard = NULL;
	if (cardAdd(&dconf->configCard, objectTree, CODESK, COSDESK) == USR_OUTOFMEMORY) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		pfree(dconf);
		return;
	}
	if (cardAdd(&dconf->configCard, objectTree, COWIN, COSWIN) == USR_OUTOFMEMORY) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		cardRemoveAll(dconf->configCard);
		pfree(dconf);
		return;
	}
	if (cardAdd(&dconf->configCard, objectTree, COPROG, COSPROG) == USR_OUTOFMEMORY) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		cardRemoveAll(dconf->configCard);
		pfree(dconf);
		return;
	}
	if (cardAdd(&dconf->configCard, objectTree, COCOPY, COSCOPY) == USR_OUTOFMEMORY) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		cardRemoveAll(dconf->configCard);
		pfree(dconf);
		return;
	}
	if (cardAdd(&dconf->configCard, objectTree, COT2G, COST2G) == USR_OUTOFMEMORY) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		cardRemoveAll(dconf->configCard);
		pfree(dconf);
		return;
	}
	if (cardAdd(&dconf->configCard, objectTree, COWIN2, COSWIN2) == USR_OUTOFMEMORY) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		cardRemoveAll(dconf->configCard);
		pfree(dconf);
		return;
	}

	/* Aktuelle Einstellungen merken */
	dconf->mode = glob.mode_config;

	dconf->imguse = conf.imguse;
	dconf->imgcenter = conf.imgcenter;
	dconf->imgpal = conf.imgpal;
	dconf->imgtrans = conf.imgtrans;
	strcpy(dconf->imgname, conf.imgname);
	dconf->tosmode = conf.tosmode;
	dconf->hidden = conf.hidden;
	dconf->vert = conf.vert;
	dconf->bsel = conf.bsel;
	dconf->ccolor = con.color;
	dconf->chist = con.hist;
	dconf->cflags = con.flags;
	strcpy(dconf->finder, conf.finder);
	strcpy(dconf->format, conf.format);
	dconf->altapp = conf.altapp;
	dconf->altcpx = conf.altcpx;
	dconf->use3d = tb.use3d;
	strcpy(dconf->kprog, conf.kb_prog);

	/* Dialog - Desktop */
	pop_dcol.sel = dconf->dcol = conf.dcolor * 2 + 2;
	pop_dpat.sel = dconf->dpat = conf.dpattern * 2 + 2;
	setObjectState(objectTree, COISNAP, SELECTED, conf.isnap);
	setObjectState(objectTree, CORDOUBLE, SELECTED, conf.rdouble);
	setObjectState(objectTree, COUSE3D, SELECTED, tb.use3d);
	setObjectState(objectTree, COIMGUSE, SELECTED, conf.imguse);
	setObjectState(objectTree, COIMGCENTER, SELECTED, conf.imgcenter);
	setObjectState(objectTree, COIMGPAL, SELECTED, conf.imgpal);
	setObjectState(objectTree, COIMGTRANS, SELECTED, conf.imgtrans);
	strShortener(objectTree[COIMG].ob_spec.tedinfo->te_ptext, dconf->imgname, 30);

	/* Dialog - Fenster 1 und 2 */
	setObjectState(objectTree, CONOWIN, SELECTED, conf.nowin);
	setObjectState(objectTree, COBSEL, SELECTED, conf.bsel);
	setObjectState(objectTree, CONOHSCROLL, SELECTED, !conf.hscr);
	setObjectState(objectTree, CORELWIN, SELECTED, conf.relwin);
	setObjectState(objectTree, COAUTOSEL, SELECTED, conf.autosel);
	setObjectState(objectTree, COCLOSEBOX, SELECTED, conf.closebox);
	setObjectState(objectTree, COTOSMODE, SELECTED, conf.tosmode);
	setObjectState(objectTree, COAUTOUPDATE, SELECTED, conf.autoupdate);
	setObjectState(objectTree, COAUTOCOMP, SELECTED, conf.autocomp);
	setObjectState(objectTree, COHIDDEN, SELECTED, conf.hidden);
	setObjectState(objectTree, COVERT, SELECTED, conf.vert);
	setObjectState(objectTree, COQREAD, SELECTED, conf.qread);
	setObjectState(objectTree, CONOHOTCLOSER, SELECTED, conf.nohotcloser);
	setObjectState(objectTree, COCASESORT, SELECTED, conf.casesort);
	setObjectState(objectTree, COCASELOC, SELECTED, conf.caseloc);
	pop_autox.sel = conf.autosizex + 1;
	pop_autoy.sel = conf.autosizey + 1;
	setObjectState(objectTree, COAUTOPLACE, SELECTED, conf.autoplace);
	setObjectState(objectTree, COINTERACTIVE, SELECTED, conf.interactive);
	itoa(conf.scroll, objectTree[COSCROLL].ob_spec.tedinfo->te_ptext, 10);
	itoa(tb.fleft, objectTree[COFLEFT].ob_spec.tedinfo->te_ptext, 10);
	itoa(tb.fupper, objectTree[COFUPPER].ob_spec.tedinfo->te_ptext, 10);
	itoa(tb.fright, objectTree[COFRIGHT].ob_spec.tedinfo->te_ptext, 10);
	itoa(tb.flower, objectTree[COFLOWER].ob_spec.tedinfo->te_ptext, 10);
	itoa(tb.fhor, objectTree[COFHOR].ob_spec.tedinfo->te_ptext, 10);
	itoa(tb.fvert, objectTree[COFVERT].ob_spec.tedinfo->te_ptext, 10);

	/* Dialog - System */
	setObjectState(objectTree, COEXIT, SELECTED, conf.texit);
	setObjectState(objectTree, COTOSWAIT, SELECTED, conf.toswait);
	setObjectState(objectTree, COALTEXT, SELECTED, conf.altapp);
	setObjectState(objectTree, COALTCPX, SELECTED, conf.altcpx);
	setObjectState(objectTree, COASKACC, SELECTED, conf.askacc);
	setObjectState(objectTree, COVASTART, SELECTED, conf.vastart);
	setObjectState(objectTree, CODEL, SELECTED, conf.usedel);
	setObjectState(objectTree, COBACKWIN, SELECTED, tb.backwin);
	strShortener(objectTree[COFINDER].ob_spec.tedinfo->te_ptext, conf.finder, 45);
	strShortener(objectTree[COFORMAT].ob_spec.tedinfo->te_ptext, conf.format, 45);

	/* Dialog - Kopieren/Kobold 2 */
	if (conf.cbuf > 0L)
		ltoa(conf.cbuf, objectTree[COBUFSIZE].ob_spec.tedinfo->te_ptext, 10);
	else
		objectTree[COBUFSIZE].ob_spec.tedinfo->te_ptext[0] = 0;
	setObjectState(objectTree, COCDELETE, SELECTED, conf.cdel);
	setObjectState(objectTree, COCCOPY, SELECTED, conf.ccopy);
	setObjectState(objectTree, COCREPLACE, SELECTED, conf.creplace);
	setObjectState(objectTree, COKTOSONLY, SELECTED, conf.kb_tosonly);
	setObjectState(objectTree, COKFORMAT, SELECTED, conf.kbf_use);
	setObjectState(objectTree, COKCOPY, SELECTED, conf.kbc_use);
	setObjectState(objectTree, COKDELETE, SELECTED, conf.kbd_use);
	itoa(conf.kbc_files, objectTree[COKCOPYN].ob_spec.tedinfo->te_ptext, 10);
	ltoa(conf.kbc_size, objectTree[COKCOPYS].ob_spec.tedinfo->te_ptext, 10);
	itoa(conf.kbd_files, objectTree[COKDELETEN].ob_spec.tedinfo->te_ptext, 10);
	strShortener(objectTree[COKPROG].ob_spec.tedinfo->te_ptext, conf.kb_prog, 45);

	/* Dialog - TOS2GEM */
	setObjectState(objectTree, COUSET2G, SELECTED, conf.uset2g);
	setObjectState(objectTree, COAUTOCON, SELECTED, conf.autocon);
	itoa(con.hist, objectTree[COT2GHIST].ob_spec.tedinfo->te_ptext, 10);
	for (i = 0; i < 3; i++) {
		unsetObjectSelected(objectTree, COTBUFNONE + i);
		unsetObjectSelected(objectTree, COTCOLNONE + i);
	}
	setObjectSelected(objectTree, COTBUFNONE + con.buffer);
	setObjectSelected(objectTree, COTCOLNONE + con.color);

	itoa(con.buftime, objectTree[COBUFTIME].ob_spec.tedinfo->te_ptext, 10);
	hlp = con.flags;
	setObjectState(objectTree, COTWTITLE, SELECTED, hlp & 0x1);
	setObjectState(objectTree, COTWVSLIDE, SELECTED, hlp & 0x2);
	setObjectState(objectTree, COTWHSLIDE, SELECTED, hlp & 0x4);

	dl_config_mode(dconf->mode);

	frm_start(&fi_config, conf.wdial, conf.cdial, 0);
}

#pragma warn -par
void de_config(short mode, short ret) {
	short done, i, exit_obj, fid;
	short redraw = 0;
	char fname[MAX_PLEN];
	char *pf, *pt;
	short ob, mode1, fret;
	WININFO *win;
	OBJECT *objectTree;

	objectTree = rs_trindex[CONFIG];

	done = exit_obj = 0;
	if (!mode) {
		mode1 = dconf->mode;
		exit_obj = fi_config.exit_obj;
		switch (exit_obj) {
		case COCANCEL:
		case COOK:
			done = exit_obj;
			break;

		/* Hintergrundbild uebernehmen */
		case COIMGAPPLY:
			if (!dl_config_loadpic(0))
				mybeep();
			dconf->imguse = conf.imguse;
			dconf->imgcenter = conf.imgcenter;
			dconf->imgpal = conf.imgpal;
			dconf->imgtrans = conf.imgtrans;
			fi_config.exit_obj = exit_obj;
			frm_norm(&fi_config);
			break;

		/* Hintergrundbild suchen */
		case COFIMG:
			if (dconf->mode == 0) {
				strcpy(fname, dconf->imgname);
				if (full_fselect(fname, NULL, "*.IMG", 0, rs_frstr[TXIMGSEARCH], 0, 301, &fi_config) == 1) {
					if (desk_icheck(&glob.img_info, fname, 0)) {
						strcpy(dconf->imgname, fname);
						strShortener(objectTree[COIMG].ob_spec.tedinfo->te_ptext, dconf->imgname, 30);
						frm_redraw(&fi_config, COIMG);
					}
				}
				fi_config.exit_obj = exit_obj;
				frm_norm(&fi_config);
			}
			break;

		/* Programm 'Finder' und 'Format' suchen */
		case COFFINDER:
		case COFFORMAT:
		case COFKPROG:
			if (exit_obj == COFFINDER) {
				pf = dconf->finder;
				pt = rs_frstr[TXAPSEARCH];
				ob = COFINDER;
				fid = 302;
			} else if (exit_obj == COFFORMAT) {
				pf = dconf->format;
				pt = rs_frstr[TXAPSEARCH];
				ob = COFORMAT;
				fid = 303;
			} else {
				pf = dconf->kprog;
				pt = rs_frstr[TXKBSEARCH];
				ob = COKPROG;
				fid = 304;
			}
			strcpy(fname, pf);
			if ((fret = full_fselect(fname, NULL, "*.*", 0, pt, 0, fid, &fi_config)) != 0) {
				if (fret == 1)
					strcpy(pf, fname);
				else
					*pf = 0;
			}
			strShortener(objectTree[ob].ob_spec.tedinfo->te_ptext, pf, 45);
			frm_redraw(&fi_config, ob);
			fi_config.exit_obj = exit_obj;
			frm_norm(&fi_config);
			break;

		/* Umschalten der Seite */
		case CODESK:
			dconf->mode = 0;
			break;
		case COWIN:
			dconf->mode = 1;
			break;
		case COPROG:
			dconf->mode = 2;
			break;
		case COCOPY:
			dconf->mode = 3;
			break;
		case COT2G:
			dconf->mode = 4;
			break;
		case COWIN2:
			dconf->mode = 5;
			break;
		}

		if (dconf->mode != mode1) {
			/* Cursor vor Umschalten aus */
			if (fi_config.edit_obj) {
				obj_edit(fi_config.tree, fi_config.edit_obj, 0, 0, &fi_config.edit_idx, ED_END, fi_config.win.handle);
				fi_config.edit_obj = 0;
				fi_config.edit_idx = -1;
			}

			/* Umschalten */
			dl_config_mode(dconf->mode);

			/* Cursor ggf. einschalten */
			if (fi_config.edit_obj)
				obj_edit(fi_config.tree, fi_config.edit_obj, 0, 0, &fi_config.edit_idx, ED_INIT, fi_config.win.handle);

			/* Formular redraw */
			frm_redraw(&fi_config, getActiveCardBodyIdx(dconf->configCard));

			mevent.ev_mwich = MU_M1;
			frm_do(&fi_config, &mevent);
		}
	} else
		done = COCANCEL;

	if (done) {
		fi_config.exit_obj = exit_obj;
		frm_end(&fi_config);
		if (done == COOK) {
			/* Einstellungen - Desktop */
			conf.isnap = isObjectSelected(objectTree, COISNAP);
			conf.rdouble = isObjectSelected(objectTree, CORDOUBLE);
			tb.use3d = isObjectSelected(objectTree, COUSE3D);
			/* Bilderoptionen werden in dl_config_loadpic() uebernommen */

			/* Einstellungen - Fenster */
			conf.nowin = isObjectSelected(objectTree, CONOWIN);
			conf.bsel = isObjectSelected(objectTree, COBSEL);
			conf.hscr = !isObjectSelected(objectTree, CONOHSCROLL);
			conf.relwin = isObjectSelected(objectTree, CORELWIN);
			conf.autosel = isObjectSelected(objectTree, COAUTOSEL);
			conf.closebox = isObjectSelected(objectTree, COCLOSEBOX);
			conf.tosmode = isObjectSelected(objectTree, COTOSMODE);
			conf.autoupdate = isObjectSelected(objectTree, COAUTOUPDATE);
			conf.autocomp = isObjectSelected(objectTree, COAUTOCOMP);
			conf.hidden = isObjectSelected(objectTree, COHIDDEN);
			conf.vert = isObjectSelected(objectTree, COVERT);
			conf.qread = isObjectSelected(objectTree, COQREAD);
			conf.nohotcloser = isObjectSelected(objectTree, CONOHOTCLOSER);
			conf.scroll = max(1, atoi(objectTree[COSCROLL].ob_spec.tedinfo->te_ptext));

			/* Einstellungen - Fenster 2 */
			conf.casesort = isObjectSelected(objectTree, COCASESORT);
			conf.caseloc = isObjectSelected(objectTree, COCASELOC);
			conf.autosizex = pop_autox.sel - 1;
			conf.autosizey = pop_autoy.sel - 1;
			conf.autosize = conf.autosizex || conf.autosizey;
			conf.autoplace = isObjectSelected(objectTree, COAUTOPLACE);
			conf.interactive = isObjectSelected(objectTree, COINTERACTIVE);
			tb.fleft = atoi(objectTree[COFLEFT].ob_spec.tedinfo->te_ptext);
			tb.fupper = atoi(objectTree[COFUPPER].ob_spec.tedinfo->te_ptext);
			tb.fright = atoi(objectTree[COFRIGHT].ob_spec.tedinfo->te_ptext);
			tb.flower = atoi(objectTree[COFLOWER].ob_spec.tedinfo->te_ptext);
			tb.fhor = atoi(objectTree[COFHOR].ob_spec.tedinfo->te_ptext);
			tb.fvert = atoi(objectTree[COFVERT].ob_spec.tedinfo->te_ptext);

			/* Einstellungen - System */
			conf.texit = isObjectSelected(objectTree, COEXIT);
			conf.toswait = isObjectSelected(objectTree, COTOSWAIT);
			conf.altapp = isObjectSelected(objectTree, COALTEXT);
			conf.altcpx = isObjectSelected(objectTree, COALTCPX);
			conf.askacc = isObjectSelected(objectTree, COASKACC);
			conf.vastart = isObjectSelected(objectTree, COVASTART);
			conf.usedel = isObjectSelected(objectTree, CODEL);
			tb.backwin = isObjectSelected(objectTree, COBACKWIN);
			strcpy(conf.finder, dconf->finder);
			strcpy(conf.format, dconf->format);

			/* Einstellungen - Kopieren/Kobold 2 */
			conf.cbuf = atol(objectTree[COBUFSIZE].ob_spec.tedinfo->te_ptext);
			conf.cdel = isObjectSelected(objectTree, COCDELETE);
			conf.ccopy = isObjectSelected(objectTree, COCCOPY);
			conf.creplace = isObjectSelected(objectTree, COCREPLACE);
			conf.kb_tosonly = isObjectSelected(objectTree, COKTOSONLY);
			conf.kbf_use = isObjectSelected(objectTree, COKFORMAT);
			conf.kbc_use = isObjectSelected(objectTree, COKCOPY);
			conf.kbd_use = isObjectSelected(objectTree, COKDELETE);
			conf.kbc_files = atoi(objectTree[COKCOPYN].ob_spec.tedinfo->te_ptext);
			conf.kbc_size = atol(objectTree[COKCOPYS].ob_spec.tedinfo->te_ptext);
			conf.kbd_files = atoi(objectTree[COKDELETEN].ob_spec.tedinfo->te_ptext);
			strcpy(conf.kb_prog, dconf->kprog);

			/* Einstellungen - TOS2GEM */
			conf.uset2g = isObjectSelected(objectTree, COUSET2G);
			conf.autocon = isObjectSelected(objectTree, COAUTOCON);
			con.hist = atoi(objectTree[COT2GHIST].ob_spec.tedinfo->te_ptext);
			for (i = 0; i < 3; i++) {
				if (isObjectSelected(objectTree, COTBUFNONE + i))
					con.buffer = i;
				if (isObjectSelected(objectTree, COTCOLNONE + i))
					con.color = i;
			}
			con.buftime = atoi(objectTree[COBUFTIME].ob_spec.tedinfo->te_ptext);
			if (con.buftime < 20)
				con.buftime = 20;
			con.flags &= ~0x7;
			if (isObjectSelected(objectTree, COTWTITLE))
				con.flags |= 0x1;
			if (isObjectSelected(objectTree, COTWVSLIDE))
				con.flags |= 0x2;
			if (isObjectSelected(objectTree, COTWHSLIDE))
				con.flags |= 0x4;

			/* Falls Console-Parameter geandert, dann neu initialisieren */
			if (con.hist != dconf->chist || con.flags != dconf->cflags) {
				dconf->chist = 0;
				if (con.win.state & WSOPEN) {
					cwin_close();
					dconf->chist = 1;
				}
				cwin_exit();
				if (cwin_init()) {
					/* Falls Neu-Initialisierung erfolgreich, dann Console ggf. wieder aufmachen */
					if (dconf->chist)
						cwin_open();
				}
			}

			/* Falls Farbdarstellung ein/ausgeschaltet wurde, dann Redraw */
			if (con.color != dconf->ccolor && con.hist == dconf->chist) {
				if (con.win.state & WSOPEN) {
					if (con.tos2gem->date >= 7813)
						con.tos2gem->color = con.color;
					else
						con.tos2gem->color = 0;
					win_redraw(&con.win, tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h);
				}
			}

			/* Direkte Auswirkungen der Voreinstellung */
			if (dconf->dcol != pop_dcol.sel || dconf->dpat != pop_dpat.sel) {
				conf.dcolor = pop_dcol.sel / 2 - 1;
				conf.dpattern = pop_dpat.sel / 2 - 1;
				desk_pat();
				redraw = 1;
			}
			dl_config_loadpic(redraw);
			strcpy(conf.imgname, dconf->imgname);

			if (dconf->tosmode != conf.tosmode || dconf->hidden != conf.hidden
					|| dconf->vert != conf.vert || dconf->altapp != conf.altapp
					|| dconf->altcpx != conf.altcpx || dconf->bsel != conf.bsel
					|| dconf->use3d != tb.use3d) {
				if (tb.use3d == 0)
					set3dLook(FALSE);
				else {
					set3dLook(TRUE);
					setShortcutLineColor(G_RED);
				}

				adjust_text(tb.use3d, getBackgroundColor(), -1);
				win = tb.win;
				while (win) {
					if (win->class != WCCON && dconf->bsel != conf.bsel) {
						if (conf.bsel)
							wind_set(win->handle, WF_BEVENT, 1, 0, 0, 0);
						else
							wind_set(win->handle, WF_BEVENT, 0, 0, 0, 0);
					}
					switch (win->class) {
					case WCDIAL:
						if (dconf->use3d != tb.use3d)
							frm_redraw((FORMINFO *)win->user,ROOT);
						break;
					case WCPATH:
						if (dconf->hidden != conf.hidden || dconf->altapp != conf.altapp || dconf->altcpx != conf.altcpx) {
							wpath_update(win);
						} else {
							if (dconf->vert != conf.vert || dconf->tosmode != conf.tosmode)
								wpath_tree(win);
						}
						win_redraw(win, tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h);
						break;
					case WCGROUP:
						if (dconf->altapp != conf.altapp || dconf->altcpx != conf.altcpx) {
							wgrp_update(win);
							wgrp_tree(win);
							win_redraw(win, tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h);
						}
						break;
					}
					win = win->next;
				}
			}
		}
		glob.mode_config = dconf->mode;

		cardRemoveAll(dconf->configCard);
		pfree(dconf);
	}
}
#pragma warn .par

/*-------------------------------------------------------------------------
 dl_cfunc()

 Funktionstastenbelegung
 -------------------------------------------------------------------------*/
void dl_cfunc(short tool) {
	short i, j;
	char *txt, *tmp, *val;
	OBJECT *objectTree;

	objectTree = rs_trindex[CFUNC];

	if (fi_cfunc.open) {
		mybeep();
		frm_restore(&fi_cfunc);
		return;
	}

	dfunc = pmalloc(sizeof(DFUNC));
	if (!dfunc) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return;
	}

	for (i = 0; i < 4; i++)
		unsetObjectSelected(objectTree, CFSNORM + i);
	unsetObjectSelected(objectTree, CFSTOOL);
	if (tool) {
		setObjectSelected(objectTree, CFSTOOL);
		dfunc->off = 4;
	} else {
		setObjectSelected(objectTree, CFSNORM);
		dfunc->off = 0;
	}

	for (i = 0; i < 10; i++) {
		if (dfunc->off == 0)
			objectTree[CFLABEL + i + 1].ob_spec.tedinfo->te_ptext[0] = 'F';
		else
			objectTree[CFLABEL + i + 1].ob_spec.tedinfo->te_ptext[0] = 'T';
		txt = dfunc->txt[i];
		val = dfunc->val[i];
		tmp = dfunc->tmp[i];
		objectTree[CFENTRY + i].ob_spec.tedinfo->te_txtlen = 61;
		objectTree[CFENTRY + i].ob_spec.tedinfo->te_tmplen = 61;
		objectTree[CFENTRY + i].ob_spec.tedinfo->te_ptext = txt;
		objectTree[CFENTRY + i].ob_spec.tedinfo->te_pvalid = val;
		objectTree[CFENTRY + i].ob_spec.tedinfo->te_ptmplt = tmp;
		for (j = 0; j < 60; j++) {
			txt[j] = 0;
			val[j] = 'X';
			tmp[j] = '_';
		}
		txt[j] = val[j] = tmp[j] = 0;
	}

	for (i = 0; i < 50; i++) {
		if (i < 40)
			strcpy(dfunc->fkey[i], conf.fkey[i]);
		else {
			j = i - 40;
			if (conf.tobj[j][0]) {
				sprintf(dfunc->fkey[i], "%s|%s", conf.ttxt[j], conf.tobj[j]);
			} else {
				dfunc->fkey[i][0] = 0;
			}
		}
		if (i < 10 && dfunc->off == 0)
			strcpy(objectTree[CFENTRY + i].ob_spec.tedinfo->te_ptext, dfunc->fkey[i]);
		if (i >= 40 && dfunc->off == 4)
			strcpy(objectTree[CFENTRY + i - 40].ob_spec.tedinfo->te_ptext, dfunc->fkey[i]);
	}

	frm_start(&fi_cfunc, conf.wdial, conf.cdial, 0);
}

void de_cfunc(short mode, short ret) {
	short i, j, k, off1, fret, done, ob, exob;
	char *p, *pk, path[MAX_PLEN], file[MAX_FLEN];
	char buf[MAX_PLEN], parm[61];
	FILESYS filesys;
	OBJECT *objectTree;

	objectTree = rs_trindex[CFUNC];

	if (!mode) {
		done = 0;
		exob = fi_cfunc.exit_obj;
		switch (exob) {
		case CFOK:
			for (i = 0; i < 10; i++)
				strcpy(dfunc->fkey[dfunc->off * 10 + i], objectTree[CFENTRY + i].ob_spec.tedinfo->te_ptext);
			for (i = 0; i < 40; i++) {
				if (!get_buf_entry(dfunc->fkey[i], buf, &pk))
					continue;

				while (*pk == ' ')
					pk++;
				strcpy(parm, pk);
				p = buf;
				/* Laufwerksbezeichnung immer gross */
				p[0] = nkc_toupper(p[0]);

				/* Bei Bedarf Schreibweise anpassen */
				fsinfo(p, &filesys);
				fsconv(p, &filesys);
				quote(buf);
				p = dfunc->fkey[i];
				strcpy(p, buf);
				if (*parm) {
					strcat(p, " ");
					strcat(p, parm);
				}
			}
			for (i = 0; i < 10; i++) {
				j = 0;
				p = dfunc->fkey[i + 40];
				if (p[0]) {
					k = 0;
					while (p[j] != '|' && p[j]) {
						if (k < 16) {
							conf.ttxt[i][k] = p[j];
							k++;
						}
						j++;
					}
					conf.ttxt[i][k] = 0;
					if ((p[j] == '|') && p[j + 1]) {
						j++;
						get_buf_entry(&p[j], buf, &pk);
						while (*pk == ' ')
							pk++;
						p = buf;
						p[0] = nkc_toupper(p[0]);
						fsinfo(p, &filesys);
						fsconv(p, &filesys);
						quote(buf);
						p = conf.tobj[i];
						strcpy(p, buf);
						if (*pk) {
							strcat(p, " ");
							strcat(p, pk);
						}
					} else {
						conf.ttxt[i][0] = 0;
						conf.tobj[i][0] = 0;
					}
				} else {
					conf.ttxt[i][0] = 0;
					conf.tobj[i][0] = 0;
				}
			}
			/* Fall through */
		case CFCANCEL:
			done = 1;
			break;
		case CFCLEAR:
			if (frm_alert(1, rs_frstr[ALDELALL], altitle, conf.wdial, 0L) == 1) {
				for (i = 0; i < 10; i++) {
					dfunc->fkey[dfunc->off * 10 + i][0] = 0;
					frm_edstring(&fi_cfunc, CFENTRY + i, "");
				}
				frm_redraw(&fi_cfunc, CFLIST);
			}
			fi_cfunc.exit_obj = exob;
			frm_norm(&fi_cfunc);
			break;
		case CFSNORM:
		case CFSSHIFT:
		case CFSCTRL:
		case CFSALT:
		case CFSTOOL:
			off1 = dfunc->off;
			switch (fi_cfunc.exit_obj) {
			case CFSNORM:
				dfunc->off = 0;
				break;
			case CFSSHIFT:
				dfunc->off = 1;
				break;
			case CFSCTRL:
				dfunc->off = 2;
				break;
			case CFSALT:
				dfunc->off = 3;
				break;
			case CFSTOOL:
				dfunc->off = 4;
				break;
			}
			if (dfunc->off != off1) {
				if ((dfunc->off != 4 && off1 == 4) || (dfunc->off == 4 && off1 != 4)) {
					for (i = 1; i < 11; i++) {
						if (dfunc->off != 4)
							objectTree[CFLABEL + i].ob_spec.tedinfo->te_ptext[0] = 'F';
						else
							objectTree[CFLABEL + i].ob_spec.tedinfo->te_ptext[0] = 'T';
					}
					frm_redraw(&fi_cfunc, CFLABEL);
				}

				obj_edit(fi_cfunc.tree, fi_cfunc.edit_obj, 0, 0, &fi_cfunc.edit_idx, ED_END, fi_cfunc.win.handle);
				ob = fi_cfunc.edit_obj;
				for (i = 0; i < 10; i++) {
					fi_cfunc.edit_obj = CFENTRY + i;
					strcpy(dfunc->fkey[off1 * 10 + i], objectTree[fi_cfunc.edit_obj].ob_spec.tedinfo->te_ptext);
					strcpy(objectTree[fi_cfunc.edit_obj].ob_spec.tedinfo->te_ptext, dfunc->fkey[dfunc->off * 10 + i]);
				}
				fi_cfunc.edit_obj = ob;
				fi_cfunc.edit_idx = -1;
				obj_edit(fi_cfunc.tree, fi_cfunc.edit_obj, 0, 0, &fi_cfunc.edit_idx, ED_INIT, fi_cfunc.win.handle);
				frm_redraw(&fi_cfunc, CFLIST);
			}
			break;
		default:
			if (!(ret & 0x8000))
				break;
			i = fi_cfunc.exit_obj - CFENTRY + dfunc->off * 10;
			strcpy(dfunc->fkey[i], objectTree[fi_cfunc.exit_obj].ob_spec.tedinfo->te_ptext);
			pk = dfunc->fkey[i];
			if (dfunc->off == 4) {
				j = 0;
				while (pk[j] && pk[j] != '|')
					j++;
				if (pk[j] == '|')
					pk = &pk[j + 1];
			}
			if (get_buf_entry(pk, buf, &p)) {
				while (*p == ' ')
					p++;
				strcpy(parm, p);
			} else {
				strcpy(buf, "");
				*parm = 0;
			}
			if (!*buf) {
				path[0] = (char) Dgetdrv() + 65;
				path[1] = ':';
				Dgetpath(&path[2], 0);
				strcat(path, "\\*.*");
				file[0] = 0;
			} else {
				/* Pfad und Dateiname ermitteln */
				full2comp(buf, path, file);
				strcat(path, "*.*");
			}

			/* Dateiauswahl durchfuehren */
			fselect(path, file, &fret, rs_frstr[TXOBJSEARCH], 0, 400 + fi_cfunc.exit_obj);

			if (fi_cfunc.state != FST_WIN)
				frm_redraw(&fi_cfunc, ROOT);

			if (fret == 1) {
				/* Dateiauswahl mit "OK" beendet */
				p = strrchr(path, '\\');
				if (p)
					p[1] = 0;
				comp2full(pk, path, file);
				p = pk;

				/* Laufwerksbezeichnung immer gross */
				pk[0] = nkc_toupper(pk[0]);

				/* Bei Bedarf Schreibweise anpassen */
				fsinfo(pk, &filesys);
				fsconv(pk, &filesys);
				quote(pk);
				if (dfunc->off == 4) {
					if (pk == dfunc->fkey[i]) {
						j = 0;
						while (file[j] && j < 16) {
							buf[j] = file[j];
							j++;
						}
						buf[j] = '|';
						strcpy(&buf[j + 1], pk);
						strcpy(dfunc->fkey[i], buf);
					}
				}
				if (*parm) {
					strcat(pk, " ");
					strcat(pk, parm);
				}
				frm_edstring(&fi_cfunc, fi_cfunc.exit_obj, dfunc->fkey[i]);
				frm_redraw(&fi_cfunc, fi_cfunc.exit_obj);
			}
			break;
		}

		if (done) {
			if (fi_cfunc.exit_obj == CFOK) {
				for (i = 0; i < 40; i++)
					strcpy(conf.fkey[i], dfunc->fkey[i]);
			}
			frm_end(&fi_cfunc);
			pfree(dfunc);
		}
	} else {
		frm_end(&fi_cfunc);
		pfree(dfunc);
	}
}

/**-------------------------------------------------------------------------
 dl_saveconf()
 
 Einstellungen sichern
 -------------------------------------------------------------------------*/
void dl_saveconf(void) {
	short ret;
	char savepath[MAX_PLEN];
	char path[MAX_PLEN];
	char file[MAX_FLEN];
	char *backslash;
	char alpath[46];

	strcpy(savepath, glob.cpath);
	for (;;) {
		strShortener(alpath, savepath, 45);
		sprintf(almsg, rs_frstr[ALDOSAVECONF], alpath);

		ret = frm_alert(2, almsg, altitle, conf.wdial, 0L);

		/* Abbruch */
		if (ret == 3)
			break;

		/* Fileselector */
		if (ret == 1) {
			/* Neuen Pfad auswaehlen */
			strcpy(path, savepath);
			strcpy(file, "");
			fselect(path, file, &ret, rs_frstr[TXFOLDSEARCH], 0, 0);
			if ((ret == 1) && *path) {
				backslash = strrchr(path, '\\');
				if (backslash)
					*backslash = 0;
				if (*path) {
					if (path[strlen(path) - 1] != '\\')
						strcat(path, "\\");
					strcpy(savepath, path);
				}
			}
			continue;
		}

		/* OK */
		if (ret == 2) {
			strcpy(path, glob.cpath);
			strcpy(glob.cpath, savepath);
			graf_mouse(BUSYBEE, 0L);
			ret = conf_save(0);
			graf_mouse(ARROW, 0L);
			strcpy(glob.cpath, path);
			if (!ret)
				frm_alert(1, rs_frstr[ALCOSAVE], altitle, conf.wdial, 0L);
			else {
				/* Neuen Pfad uebernehmen? */
				if (strcmp(savepath, glob.cpath)) {
					sprintf(almsg, rs_frstr[ALUSENEWCPATH], savepath);
					if (frm_alert(1, almsg, altitle, conf.wdial, 0L) == 1)
						strcpy(glob.cpath, savepath);
				}
			}
		}
		break;
	}
}

/**-------------------------------------------------------------------------
 dl_loadconf()

 Einstellungen laden
 -------------------------------------------------------------------------*/
void dl_loadconf(void) {
	short ret, i;
	ICONDESK *p = desk.dicon + OBUSER, *q;

	if (frm_alert(1, rs_frstr[ALDOLOADCONF], altitle, conf.wdial, 0L) == 1) {
		graf_mouse(BUSYBEE, 0L);

		/* Aktuelle Einstellungen verwerfen */
		desk_ifree(&glob.img_info);
		desk_ifree(&glob.dir_img);
		glob.img_ok = glob.dir_ok = 0;
		while (desk.appl)
			app_remove(desk.appl); /* Applikationen */

		while (tb.win) {
			tb.topwin = tb.win;
			dl_closewin();
		} /* Fenster */
		free_hotkeys(); /* Hotkeys */

		/* Laufwerksinformationen */
		q = desk.dicon + 1;
		for (i = 0; i < MAXDRIVES; i++, q++)
			q->spec.drive->uselabel = q->spec.drive->autoinstall = 0;

		/* Icons auf dem Desktop */
		icon_select(-1, 0, 0);
		for (i = OBUSER; i <= MAXICON; i++, p++) {
			p->select = 0;
			p->class = IDFREE;
			if (p->spec.data) {
				pfree(p->spec.data);
				p->spec.data = 0L;
			}
		}

		/* Funktionstasten */
		for (i = 0; i < 40; i++)
			conf.fkey[i][0] = 0;

		/* Default-Applikation */
		defappl = default_defappl;

		/* Cursor abschalten */
		wf_clear();

		/* Alte Einstellungen laden */
		con.win.curr = tb.desk;
		ret = conf_load();
		dl_drives(0, 1, 0);

		if (tb.use3d == 0)
			set3dLook(FALSE);
		else {
			set3dLook(TRUE);
			setShortcutLineColor(G_RED);
		}
		adjust_text(tb.use3d, getBackgroundColor(), -1);

		clip_init();
		cwin_exit();
		cwin_init();
		icon_update(0);
		if (conf.imguse) {
			conf.imguse = desk_iload(&glob.img_info, conf.imgname, conf.imgpal, ALIMGERR);
		}
		glob.img_ok = conf.imguse;
		if (*conf.dirimg) {
			glob.dir_ok = desk_iload(&glob.dir_img, conf.dirimg, 0, ALDIRIMGERR);
		}
		desk_pat();
		mn_check();
		if (ret)
			wind_restore(1);
		else
			desk_draw(tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h);

		graf_mouse(ARROW, 0L);
	}
}

/**-------------------------------------------------------------------------
 dl_drives()
 
 Laufwerke anmelden
 -------------------------------------------------------------------------*/
short dl_drives(short draw, short _auto, short showall) {
	short i, d;
	ICONDESK *p;
	short redraw = 0;
	short x, y, w, h;
	char label[MAX_FLEN];
	OBJECT *objectTree;

	objectTree = rs_trindex[DESKTOP];
	/* Laufwerke anmelden */
	p = desk.dicon + 1;
	for (i = 0; i < MAXDRIVES; i++, p++) {
		if (_auto && !p->spec.drive->autoinstall)
			continue;
		d = showall ? 1 : chk_drive(i); /* Typ ermitteln */
		if (showall && (chk_drive(i) == -1))
			p->spec.drive->autoinstall = 0;

		/* Lauferk vorhanden ? */
		if (d != -1) {
			/* Daten nur eintragen, wenn noetig */
			if ((p->class == IDFREE) && (!_auto || p->spec.drive->autoinstall)) {
				p->class = IDDRIVE;
				p->spec.drive->drive = i;

				if (!_auto || ((p->x == -1) && (p->y == -1))) {
					strcpy(p->spec.drive->deftitle, rs_frstr[TXFILESYS]);
					strcpy(p->title, p->spec.drive->deftitle);
					desk_freepos(i + 1, &p->x, &p->y, 0);
				}
				if (p->spec.drive->uselabel) {
					*label = 0;
					if (get_label(i, label, MAX_FLEN))
						*label = 0;
					if (!*label)
						strcpy(label, p->spec.drive->deftitle);
					strcpy(p->title, label);
				}
				redraw = 1;
			}
		} else {
			/* Laufwerk nicht mehr bekannt - ggf. entfernen und Pos. merken */
			if ((p->class == IDDRIVE) && (!_auto || p->spec.drive->autoinstall)) {
				p->class = IDFREE;
				p->select = 0;
				if (!_auto) {
					p->x = -1;
					p->y = -1;
					p->title[0] = 0;
				}
				redraw = 1;
			}
		}
		if (redraw) {
			icon_update(i + 1);
			if (draw && _auto) {
				objc_offset(objectTree, i + 1, &x, &y);
				w = objectTree[i + 1].ob_width;
				h = objectTree[i + 1].ob_height;
				desk_draw(x, y, w, h);
				redraw = 0;
			}
		}
	}

	/* Icons auf dem Desktop aktualisieren */
	if (redraw && draw) {
		icon_select(-1, 0, 0);
		desk_draw(tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h);
	}

	return 1;
}

/**-------------------------------------------------------------------------
 dl_rez()

 Aufloesung wechseln
 -------------------------------------------------------------------------*/
void di_rez(void) {
	if (fi_rez.open) {
		mybeep();
		frm_restore(&fi_rez);
		return;
	}
	pop_rez.sel = 1;
	frm_start(&fi_rez, conf.wdial, conf.cdial, 0);
}

void de_rez(short mode, short ret) {
	short done, newrez;

	UNUSED(ret);

	if (!mode) {
		switch (fi_rez.exit_obj) {
		case CROK:
			if (frm_alert(2, rs_frstr[ALNEWREZ], altitle, conf.wdial, 0L) == 1)
				done = CROK;
			else {
				frm_norm(&fi_rez);
				done = CRCANCEL;
			}
			break;
		case CRCANCEL:
			done = CRCANCEL;
			break;
		}
	} else
		done = CRCANCEL;

	if (done) {
		frm_end(&fi_rez);

		if (done == CROK) {
			newrez = pop_rez.sel;
			if (tb.sys & SY_MAGX) /* Aufloesungswechsel unter MagiC */
				tb.magx->aesvars->chgres(newrez, 0);
		}
	}
}

/**-------------------------------------------------------------------------
 dl_itext()

 Darstellung in Fenstern als Text/Icons
 -------------------------------------------------------------------------*/
void dl_itext(short text) {
	W_GRP *wgrp;
	W_PATH *wpath;

	if (tb.topwin) {
		graf_mouse(BUSYBEE, 0L);
		switch (tb.topwin->class) {
		case WCGROUP:
			wgrp = (W_GRP *) tb.topwin->user;
			if (wgrp->text != text) {
				wgrp->text = text;
				wgrp_tree(tb.topwin);
				win_redraw(tb.topwin, tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h);
				win_slide(tb.topwin, S_INIT, 0, 0);
				wgrp_change(tb.topwin);
			}
			break;
		case WCPATH:
			wpath = (W_PATH *) tb.topwin->user;
			if (wpath->index.text != text) {
				wpath->index.text = text;
				wpath_tree(tb.topwin);
				w_draw(tb.topwin);
				win_slide(tb.topwin, S_INIT, 0, 0);
			}
			break;
		}
		mn_check();
		graf_mouse(ARROW, 0L);
	}
};

/**-------------------------------------------------------------------------
 dl_isort()

 Sortierung in Fenstern aendern
 -------------------------------------------------------------------------*/
void dl_isort(short sort) {
	short newsort;
	short pwin;
	short *sortby;

	sortby = &conf.index.sortby;
	pwin = 0;
	if (tb.topwin) {
		if (tb.topwin->class == WCPATH) {
			sortby = &((W_PATH *) tb.topwin->user)->index.sortby;
			pwin = 1;
		}
	}

	if (sort & (SORTREV | SORTFOLD))
		newsort = *sortby ^ sort;
	else
		newsort = (sort | (*sortby & (SORTREV | SORTFOLD)));

	if (*sortby != newsort) {
		*sortby = newsort;
		mn_check();
		graf_mouse(BUSYBEE, 0L);
		/* Fenster aktualisieren */
		wpath_iupdate(pwin ? tb.topwin : 0L, 1);
		if (pwin) {
			wpath_tree(tb.topwin);
			win_slide(tb.topwin, S_INIT, 0, 0);
			win_redraw(tb.topwin, tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h);
		}
		graf_mouse(ARROW, 0L);
	}
}

/**-------------------------------------------------------------------------
 dl_ishow()

 Anzeige von Groesse, Datum etc. in Fenstern aendern
 -------------------------------------------------------------------------*/
void dl_ishow(short show) {
	if (conf.index.show & show)
		conf.index.show &= ~show;
	else
		conf.index.show |= show;

	mn_check();
	graf_mouse(BUSYBEE, 0L);
	wpath_iupdate(0L, 0);
	graf_mouse(ARROW, 0L);
}

/**-------------------------------------------------------------------------
 dl_imask()
 
 Maske fuer Fensterinhalt setzen
 -------------------------------------------------------------------------*/
/* qsort fuer di_mask() */
void wl_qsort(char **list, short left, short right) {
	short i, last;
	void wl_swap(char **list, short i, short j);

	if (left >= right)
		return;

	wl_swap(list, left, (left + right) / 2);
	last = left;
	for (i = left + 1; i <= right; i++) {
		if (strcmp(list[i], list[left]) < 0)
			wl_swap(list, ++last, i);
	}
	wl_swap(list, left, last);
	wl_qsort(list, left, last - 1);
	wl_qsort(list, last + 1, right);
}

void wl_swap(char **list, short i, short j) {
	char *temp;

	temp = list[i];
	list[i] = list[j];
	list[j] = temp;
}

void di_mask(void) {
	short i, j, l, n, new;
	char *fmask, nmask[34], *p;
	WP_ENTRY *item;

	if (fi_mask.open) {
		mybeep();
		if (fi_mask.state == FST_WIN)
			win_top(dmask->win);
		frm_restore(&fi_mask);
		return;
	}

	if (!tb.topwin)
		return;
	if (tb.topwin->class!=WCPATH)
		return;

	dmask = pmalloc(sizeof(DMASK));
	if (!dmask) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return;
	}

	dmask->win = tb.topwin;
	dmask->wpath = (W_PATH *) tb.topwin->user;
	dmask->wildcard = dmask->wpath->index.wildcard;
	strShortener(rs_trindex[MASK][MAPATH].ob_spec.free_string, dmask->wpath->path, 30);

	strcpy(rs_trindex[MASK][MAMASK].ob_spec.tedinfo->te_ptext, dmask->wildcard);

	/* Falls Dateisystem nicht case-sensitiv, dann Dialog entsprechend anpassen */
	fmask = rs_trindex[MASK][MAMASK].ob_spec.tedinfo->te_pvalid;
	i = 0;
	if (dmask->wpath->filesys.flags & (TOS | UPCASE)) {
		while (fmask[i]) {
			fmask[i] = 'x';
			i++;
		}
	} else {
		while (fmask[i]) {
			fmask[i] = 'X';
			i++;
		}
	}

	/* Alle vorkommenden Extensions in einer Liste sammeln */
	n = 1;
	strcpy(dmask->wlist[0], "*");
	for (i = 0; i < dmask->wpath->e_num && n < WLMAX; i++) {
		item = dmask->wpath->lptr[i];
		if (item->class == EC_FILE) {
			fmask = item->name;
			p = strrchr(fmask, '.');
			if (p) {
				if (p[1]) {
					/* Aus Dateinamen Maske bilden */
					strcpy(nmask, "*");
					strncat(nmask, p, 32);
					strupr(nmask);
					/* In der Liste schon vorhanden? */
					new = 1;
					for (j = 0; j < n && new; j++)
						if (!strcmp(nmask, dmask->wlist[j]))
							new = 0;
					/* Nein - dann aufnehmen */
					if (new) {
						strcpy(dmask->wlist[n], nmask);
						n++;
					}
				}
			}
		}
	}

	/* Eintraege sortieren */
	for (i = 0; i < n; i++)
		dmask->wtext[i] = dmask->wlist[i];
	wl_qsort(dmask->wtext, 0, n - 1);

	/* Liste initialisieren */
	li_mask.text = dmask->wtext;
	li_mask.num = n;
	li_mask.offset = 0;
	li_mask.sel = -1;
	l = (short) strlen(dmask->wildcard);
	j = -1;
	for (i = 0; i < n && j == -1; i++)
		if (!strnicmp(dmask->wildcard, dmask->wtext[i], (long) l))
			j = i;
	li_mask.sel = j;
	lst_init(&li_mask, 1, 1, 0, 0);

	frm_start(&fi_mask, conf.wdial, conf.cdial, 0);
}

void de_mask(short mode, short ret) {
	short done, i, l, n, sel, off, exit_obj;
	short ks, d;
	short dclick;
	short new_len;
	char *w;

	UNUSED(ret);

	if (!mode) {
		exit_obj = fi_mask.exit_obj;
		done = 0;
		sel = li_mask.sel;
		n = li_mask.num;
		w = rs_trindex[MASK][MAMASK].ob_spec.tedinfo->te_ptext;
		graf_mkstate(&d, &d, &d, &ks);
		if (lst_handle(&li_mask, ret, &dclick)) {
			if (dclick)
				done = MAOK;
		} else {
			switch (exit_obj) {
			case MAOK:
				if (!isValidFileMask(w, TRUE)) {
					frm_alert(1, rs_frstr[ALILLMASK], altitle, conf.wdial, 0L);
					fi_mask.exit_obj = exit_obj;
					frm_norm(&fi_mask);
				} else
					done = MAOK;
				break;
			case MACANCEL:
				done = MACANCEL;
				break;
			case MAMASK:
				off = li_mask.offset;
				sel = -1;
				l = (short) strlen(w);
				for (i = 0; i < n && sel == -1; i++)
					if (!strnicmp(w, dmask->wtext[i], (long) l))
						sel = i;
				if (sel != li_mask.sel && sel != -1) {
					if (sel < off)
						off = sel;
					if (sel >= off + li_mask.view)
						off = sel - li_mask.view + 1;
					if (off != li_mask.offset) {
						li_mask.sel = sel;
						li_mask.offset = off;
						lst_init(&li_mask, 1, 1, 1, 1);
					}
				}
				if (fi_mask.state == FST_WIN) {
					wind_update( BEG_UPDATE);
					wind_update( BEG_MCTRL);
				}
				lst_select(&li_mask, sel);
				if (fi_mask.state == FST_WIN) {
					wind_update( END_UPDATE);
					wind_update( END_MCTRL);
				}
				break;
			}
		}

		if (sel != li_mask.sel) {
			obj_edit(fi_mask.tree, fi_mask.edit_obj, 0, 0, &fi_mask.edit_idx, ED_END, fi_mask.win.handle);
			if ((ks & (K_LSHIFT | K_RSHIFT)) == 0) /* Ohne Shift */
				strcpy(w, dmask->wtext[li_mask.sel]);
			else /* Mit Shift */
			{
				new_len = (short) (strlen(w) + strlen(dmask->wtext[li_mask.sel]));
				if (*w)
					new_len++;
				if (new_len <= 32) {
					if (w[0])
						strcat(w, ",");
					strcat(w, dmask->wtext[li_mask.sel]);
				} else
					mybeep();
			}
			fi_mask.edit_idx = -1;
			obj_edit(fi_mask.tree, fi_mask.edit_obj, 0, 0, &fi_mask.edit_idx, ED_INIT, fi_mask.win.handle);
			frm_redraw(&fi_mask, MAMASK);
		}
	} else
		done = MACANCEL;

	if (done) {
		frm_end(&fi_mask);

		if (done == MAOK) {
			strcpy(dmask->wildcard, w);

			/* Falls keine Maske angegeben ist, dann "*" setzen */
			if (!*dmask->wildcard)
				strcpy(dmask->wildcard, "*");

			/* Schreibweise ggf. anpassen */
			if (dmask->wpath->filesys.flags & (TOS | UPCASE)) {
				i = 0;
				while (dmask->wildcard[i]) {
					dmask->wildcard[i] = nkc_toupper(dmask->wildcard[i]);
					i++;
				}
			}

			/* Und Maske setzen */
			dmask->wpath->amask[0] = 0;
			strcpy(dmask->wpath->index.wildcard, dmask->wildcard);
			graf_mouse(BUSYBEE, 0L);
			wpath_iupdate(dmask->win, 1);
			wpath_tree(dmask->win);
			w_draw(dmask->win);
			win_slide(dmask->win, S_INIT, 0, 0);
			graf_mouse(ARROW, 0L);
		}

		/* Speicher freigeben */
		pfree(dmask);
		dmask = 0L;
	}
}

/*-------------------------------------------------------------------------
 dl_open()

 Oeffnen eines Objekts nach Doppelklick oder beim Anwaehlen des
 Menuepunkts "Oeffnen"
 -------------------------------------------------------------------------*/
short dl_openit(char *full, char *aname, char *apath, short isap, short *rex, short ks,
		char *parm) {
	short intern, aok, ret;
	APPLINFO *appl, app;

	/* Handelt es sich hier evtl. um eine Datei von Thing? */
	intern = sys_open(apath, aname);

	if (!intern) {
		/* Nein */
		ret = 0;
		if (!isap) {
			/* Datei? */
			quote(full);
			/* Applikation fuer diese Datei angemeldet ? */
			appl = app_match(0, aname, &aok);
			if (appl) {
				ret = app_start(appl, full, apath, rex);
				goto dl_openit1;
			} else {
				/* Aehm - eventuell ein Viewer vorhanden? */
				if (!aok) {
					appl = app_match(1, aname, &aok);
					if (appl) {
						ret = app_start(appl, full, apath, rex);
						goto dl_openit1;
					}
				}
			}
			/* Keine Applikation und kein Viewer verfuegbar */
			if (!aok) {
				sprintf(almsg, rs_frstr[ALNOAPP], aname);
				frm_alert(1, almsg, altitle, conf.wdial, 0L);
			}
			dl_openit1: ;
		} else {
			/* Ausfuehrbares Programm */
			appl = app_find(full); /* Bekannt? */
			if (!appl) {
				/* Noe */
				strcpy(app.name, full);
				app_default(&app);
				strcpy(app.title, aname);
				if ((ks & (K_LSHIFT | K_RSHIFT)) != 0)
					app.single = 1;
				appl = &app;
			}
			ret = app_start(appl, parm, 0L, rex);
		}
	} else {
		*rex = 0;
		ret = 1;
	}

	return (ret);
}

short dl_open_p(char *path, char *rname, short rel, char *mask, short ks) {
	short ok, ret;
	W_PATH *wpath;

	ok = 0;
	if ((ks & K_LSHIFT) || (ks & K_RSHIFT)) {
		if (tb.topwin) {
			if ((tb.topwin->class == WCPATH) && !(tb.topwin->state & WSICON)) {
				/* Ggf. Wildcard-Dialog schliessen */
				if (fi_mask.open) {
					if (dmask->win == tb.topwin)
						fi_mask.exit(1, 0);
				}

				wpath = (W_PATH *) tb.topwin->user;
				strcpy(wpath->path, path);
				strcpy(wpath->index.wildcard, mask);
				wpath->amask[0] = 0;
				wpath->rel = rel;
				wpath->offx = wpath->offy = 0;
				if (rname)
					strcpy(wpath->relname, rname);
				else
					wpath->relname[0] = 0;
				ret = wpath_update(tb.topwin);
				if (glob.fmode && tb.topwin == glob.fwin && wpath->e_total > 0)
					wpath_esel(tb.topwin, wpath->lptr[0], 0, 1, 1);
				w_draw(tb.topwin);
				ok = 1;
			}
		}
	}
	if (!ok) {
		ret = wpath_open(path, mask, rel, rname, conf.index.text, -1, conf.index.sortby);
	}

	return (ret);
}

short dl_open_chk(char *name, ICONDESK *icon) {
	XATTR xattr;
	short ret, l, abut;
	long fret;
	char file[MAX_FLEN], path[MAX_PLEN], *p;
	short x, y, w, h;

	/* Bei Ordner vor dem Test abschliessendes '\' loeschen */
	l = (short) strlen(name);
	if (icon->class == IDFOLDER && l > 1)
		name[l - 1] = 0;

	/* Auf Existenz pruefen */
	fret = (long) file_exists(name, 1, &xattr);

	/* Und evtl. entferntes '\' wieder anhaengen */
	if (icon->class == IDFOLDER && l > 1)
		name[l - 1] = '\\';

	/* Bei Fehler jammern und nachfragen */
	if (fret != 0L) {
		objc_offset(rs_trindex[DESKTOP], icon->obnum, &x, &y);
		w = rs_trindex[DESKTOP][icon->obnum].ob_width;
		h = rs_trindex[DESKTOP][icon->obnum].ob_height;

		if ((abut = frm_alert(1, rs_frstr[ALICONMISS], altitle, 1, 0L)) == 1) {
			full2comp(name, path, file);
			strcat(path, "*.*");
			fselect(path, file, &ret, rs_frstr[TXOBJSEARCH], 0, 0);
			if (ret == 1) {
				strcpy(name, path);
				p = strrchr(name, '\\');
				if (p)
					p[1] = 0;
				if (icon->class == IDFILE)
					strcat(name, file);
			} else
				ret = 0;
		} else {
			if (abut == 2) {
				icon_free(icon->obnum);
				icon_update(icon->obnum);
				desk_draw(x, y, w, h);
			}
			ret = 0;
		}
	} else
		ret = 1;

	return (ret);
}

void dl_open(short new) {
	short i,isap,rex;
	short fret;
	W_PATH *wpath;
	WP_ENTRY *item;
	W_GRP *wgrp;
	WG_ENTRY *gitem;
	ICONDESK *icon;
	char name[MAX_PLEN], full[MAX_PLEN], apath[MAX_PLEN], aname[MAX_FLEN];
	char mask[MAX_PLEN];
	char *p;
	WININFO *win;
	short lshift, rshift, alt;

	lshift = rshift = alt = 0;
	if (new & K_LSHIFT)
	lshift = 1;
	if (new & K_RSHIFT)
	rshift = 1;
	if (new & K_ALT)
	alt = 1;

	/* Objekt auf dem Desktop  */
	if (desk.sel.desk) {
		/* Selektiertes Objekt holen */
		icon = desk.dicon + 1;
		i = 1;
		while (icon->class == IDFREE || !icon->select) {
			i++;
			icon++;
		}

		switch (icon->class) {
		/* Datei */
		case IDFILE:
			/* Check auf Existenz der Datei */
			if (dl_open_chk(icon->spec.file->name,icon)) {
				/* Dateinamen holen */
				strcpy(name, icon->spec.file->name);
				full2comp(name, apath, aname);
				isap = is_appl(name);

				/* Und oeffnen */
				if (dl_openit(name, aname, apath, isap, &rex, new, "")) {
					if (!rex)
						icon_select(-1,0,0);
				}
			}
			break;

		/* Device */
		case IDDEVICE:
			p = icon->title;
			if (!p[0]) {
				p = strrchr(icon->spec.device->name, '\\');
				p = &p[1];
			}
			sprintf(almsg, rs_frstr[ALDEVICE], p);
			frm_alert(1, almsg, altitle, conf.wdial, 0L);
			break;

		/* Drucker - kann nicht geoeffnet werden */
		case IDPRT:
			frm_alert(1,rs_frstr[ALPROPEN], altitle, conf. wdial, 0L);
			break;

		case IDTRASH: /* Papierkorb - kann nicht geoeffnet werden */
			frm_alert(1, rs_frstr[ALTRASH], altitle, conf.wdial, 0L);
			break;
		case IDCLIP: /* Ablage */
			dl_open_p(icon->spec.clip->path, icon->title, 1, "*", new);
			break;
		case IDDRIVE: /* Laufwerk */
			/* Laufwerk vorhanden? */
			if (chk_drive(icon->spec.drive->drive) != -1) {
				strcpy(full, "X:\\");
				full[0] = icon->spec.drive->drive + 65;
				dl_open_p(full, 0L, 0, "*", new);
			} else
				mybeep(); /* Ergaenzen: Evtl. Fehlermeldung? */
			break;
		case IDFOLDER: /* Ordner */
			/* Check auf Existenz des Ordners */
			if (dl_open_chk(icon->spec.folder->path, icon)) {
				dl_open_p(icon->spec.folder->path, icon->title, 1, "*", new);
			}
			break;
		}
		icon_select(-1, 0, 0);
	}
	else {
		/* Objekte in einem Fenster? */
		if (!desk.sel.numobs) {
			/* Nein - dann Fileselector */
			strcpy(apath,"X:\\*.*");
			apath[0] = tb.homepath[0];
			aname[0] = 0;
			fselect(apath, aname, &fret, rs_frstr[TXOBJOPEN], 1, 1);
			if (fret == 1) {
				strcpy(full, apath);
				p = strrchr(full, '\\');
				if (p)
					strcpy(&p[1], aname);
				else
					strcat(full, aname);
				if (aname[0])
					va_open(full);
				else
					wpath_open(full, "*", 0, "", conf.index.text, -1, conf.index.sortby);
			}
			return;
		}

		win = desk.sel.win;
		switch (win->class) {
			case WCPATH:
			wpath = (W_PATH *)win->user;
			for (i = 0; i < wpath->e_total; i++) {
				item = wpath->lptr[i];
				if (item->sel)
					break;
			}

			/* Siehe oben ... */
			if (item->class == EC_FILE) {
				/* Dateinamen holen */
				strcpy(name, wpath->path);
				strcat(name, item->name);
				full2comp(name, apath, aname);
				isap=item->aptype;

				if (dl_openit(name, aname, apath, isap, &rex, new, "")) {
					if (!rex) {
						wpath->amask[0] = 0;
						wpath_esel(win, 0L, 0, 0, 1);
					}
				}
			}
			else {
				/* Keine Datei */
				if (item->class == EC_DEVICE) {
					/* Device? */
					sprintf(almsg, rs_frstr[ALDEVICE], item->name);
					frm_alert(1, almsg, altitle, conf.wdial, 0L);
					wpath->amask[0] = 0;
					wpath_esel(win, 0L, 0, 0, 1);
				} else {
					strcpy(name, wpath->path);
					if (item->class == EC_PARENT) {
						if (alt) {
							wpath->amask[0] = 0;
							wpath_esel(win, 0L, 0, 0, 1);
							new = 1;
						} else
							new = 0;
						wpath_parent(win, new, 0);
					} else {
						/* Sicherheitscheck: Pfadlaenge fuer Thing noch zulaessig? */
						if ((short)strlen(name) + (short)strlen(item->name) >= MAX_PLEN) {
							/* Nein - dann abbrechen */
							frm_alert(1, rs_frstr[ALRECURS], altitle, conf.wdial, 0L);
						} else {
							strcat(name, item->name);
							strcat(name, "\\");

							if (alt) {
								/* In einem neuen Fenster */
								wpath->amask[0] = 0;
								wpath_esel(win, item, 1, 0, 1);
								wpath_open(name, wpath->index.wildcard, 1, 0L, wpath->index.text, -1, wpath->index.sortby);
							} else {
								/* Im aktuellen Fenster */
								/* Ggf. Wildcard-Dialog schliessen */
								if (fi_mask.open) {
									if (dmask->win == win) {
										fi_mask.exit(1, 0);
									}
								}

								strcpy(wpath->path,name);
								if (wpath->rel)
									wpath->rel++;
								wpath->offx = wpath->offy = 0;
								wpath_update(win);
								w_draw(win);
								/* Falls Cursor aktiv ist, dann ersten Eintrag selektieren */
								if (glob.fmode && win == glob.fwin && wpath->e_total > 0)
									wpath_esel(win, wpath->lptr[0], 0, 1, 1);
							}
						}
					}
				}
			}
			break;
		case WCGROUP:
			wgrp = (W_GRP *)win->user;
			gitem = wgrp->entry;
			while (!gitem->sel)
				gitem = gitem->next;

			wgrp_eabs(wgrp, gitem, name);

			/* Bei Bedarf Verzeichnisfenster fuer das Objekt oeffnen */
			if (alt) {
				if (gitem->class != EC_FILE)
					mybeep();
				else {
					if (wpath_obfind(name))
						wgrp_esel(win, gitem, 0, 0);
				}
			} else {
				/* Sonst normal */
				/* Siehe oben ... */
				if (gitem->class == EC_FILE) {
					full2comp(name, apath, aname);
					if (!wgrp->getattr)
						gitem->aptype = is_appl(name);
					isap = gitem->aptype;
					if (dl_openit(name, aname, apath, isap, &rex, new, gitem->parm)) {
						if (!rex) {
							if (wgrp->autoclose && !lshift && !rshift) {
								tb.topwin = win;
								glob.autoclose = 1;
								dl_closewin();
								glob.autoclose = 0;
							} else
								wgrp_esel(win, 0L, 0, 0);
						}
						return;
					}
				} else {
					/* Keine Datei - dann Ordner/Laufwerk oeffnen */
					if (!gitem->parm[0])
						strcpy(mask, "*");
					else {
						strcpy(mask, gitem->parm);
						mask[MAX_FLEN] = 0;
					}
					if (dl_open_p(name, gitem->title, 1, mask, new)) {
						if (wgrp->autoclose && !lshift && !rshift) {
							tb.topwin = win;
							glob.autoclose = 1;
							dl_closewin();
							glob.autoclose = 0;
						} else
							wgrp_esel(win, 0L, 0, 0);
					}
				}
			}
			break;
		}
	}
}

/**-------------------------------------------------------------------------
 dl_show()

 Anzeigen/Drucken der aktuell selektierten Datei (Menuepunkt "Anzeigen",
 bzw. Menuepunkt "Drucken")
 -------------------------------------------------------------------------*/
short dl_show(short mode, char *buf) {
	char full[MAX_CLEN + MAX_PLEN];
	char path[MAX_PLEN];
	char name[MAX_FLEN];
	W_PATH *wpath;
	short rex, ret;
	WININFO *win;

	/* Nur einzelne Dateien koennen angezeigt werden */
	if (!buf && ((desk.sel.numobs > 1) || !desk.sel.files)) {
		mybeep();
		return (0);
	}
	ret = rex = 0;
	if (!buf) {
		if (!sel2buf(full, name, path, MAX_CLEN + MAX_PLEN)) {
			mybeep();
			return (0);
		}
	}
	if (!get_buf_entry(full, path, NULL)) {
		mybeep();
		return (0);
	}
	strcpy(full, path);
	full2comp(full, path, name);

	/* Datei anzeigen/drucken */
	if (viewprint(mode, path, name, &rex) == 0) {
		ret = 1;
		if (!buf && !rex) {
			if (desk.sel.win) {
				win = desk.sel.win;
				switch (win->class) {
				case WCPATH:
					wpath = (W_PATH *)win->user;
					wpath->amask[0] = 0;
					wpath_esel(win, 0L, 0, 0, 1);
					break;
				case WCGROUP:
					wgrp_esel(win, 0L, 0, 0);
					break;
				}
			}
			else
			icon_select(-1,0,0);
		}
	}

	return (ret);
}

/**
 * viewprint
 *
 * Zeigt oder druckt die angegebene Datei.
 *
 * Eingabe:
 * mode: 0 = anzeigen, 1 = drucken
 * path: Pfad der Datei (ohne Namen)
 * name: Name der Datei
 * rex: Zeiger auf zusaetzlichen Rueckgabewert von app_start
 *
 * Rueckgabe:
 * 0: Alles OK, zustaendige Applikation gestartet
 * 1: Zustaendige Applikation konnte nicht gestartet werden
 * 2: Keine zustaendige Applikation gestartet, aber vorhanden
 * 3: Keine zustaendige Applikation vorhanden (Meldung erfolgt hier)
 */
static short viewprint(short mode, char *path, char *name, short *rex) {
	char full[MAX_CLEN + MAX_PLEN];
	APPLINFO *appl;
	short am_ok;

	strcpy(full, path);
	strcat(full, name);

	/* Zustaendige Applikation ermitteln */
	appl = app_match(mode + 1, name, &am_ok);
	if (appl) {
		/* Applikation vorhanden */
		quote(full);
		if (app_start(appl, full, path, rex))
			return (0);
		else
			return (1);
	} else {
		/* Keine Applikation vorhanden */
		if (!am_ok) {
			/* Wirklich keine vorhanden */
			sprintf(almsg, rs_frstr[mode ? ALNOPRINT : ALNOVIEW], name);
			frm_alert(1, almsg, altitle, conf.wdial, 0L);
			return (3);
		}
		/* Auswahl bei mehreren zustaendigen Applikationen abgebrochen */
		return (2);
	}
}

/**-------------------------------------------------------------------------
 dl_info()
 
 Info ueber die selektieren Objekte oder das aktuelle Fenster anzeigen
 -------------------------------------------------------------------------*/
void dl_info(void) {
	short i, cont, donext, num, doit;
	short ok, l, doup, done;
	W_PATH *wpath, *uwpath;
	WP_ENTRY *item, iobj;
	WG_ENTRY *gitem;
	char ipath[MAX_PLEN];
	short nfiles, nfolders, nlinks;
	unsigned long size;
	WININFO *win;
	ICONDESK *p;
	short d, ks;
	short msg[8];

	graf_mkstate(&d, &d, &d, &ks);

	/* Objekte auf dem Desktop  */
	if (desk.sel.desk) {
		num = desk.sel.numobs;
		cont = 1;
		p = desk.dicon + 1;
		for (i = 1; i <= MAXICON && cont; i++, p++) {
			if (p->class != IDFREE && p->select) {
				/* Letztes Icon ? */
				num--;
				if (num > 0)
					donext = 1;
				else
					donext = 0;

				switch (p->class) {
				case IDDRIVE: /* Laufwerks-Info */
					cont = dl_ddriveinfo(p, donext);
					break;
				case IDTRASH: /* Papierkorb-Info */
					cont = dl_dtrashinfo(p, donext);
					break;
				case IDCLIP: /* Ablagen-Info */
					cont = dl_dclipinfo(p, donext);
					break;
				case IDFILE: /* Datei-Info */
				case IDFOLDER: /* Ordner-Info */
					if ((desk.sel.numobs == 1) && (ks & K_ALT)) {
						memset(msg, 0, sizeof(msg));
						msg[0] = AV_FILEINFO;
						msg[1] = tb.app_id;
						if (p->class == IDFOLDER)
							long2int((long)p->spec.folder->path, &msg[3], &msg[4]);
						else
							long2int((long)p->spec.file->name, &msg[3], &msg[4]);
						avs_fileinfo(msg);
						cont = 0;
					} else
						cont = dl_fileinfo(0L, 0, 0L, 0L, p, donext);
					break;
				case IDPRT: /* Drucker-Info */
					cont = dl_prtinfo(p, donext);
					break;
				case IDDEVICE: /* Device-Info */
					cont = dl_devinfo(p, donext);
					break;
				}
			}
			if (cont == 2) {
				icon_redraw(i);
				cont = 1;
			}
		}
	} else {
		/* Objekte in einem Fenster ? */
		if (desk.sel.numobs) {
			/* Jo ... */
			num = desk.sel.numobs;
			cont = 1;

			win = desk.sel.win;
			switch (win->class) {
			case WCPATH:
				wpath = (W_PATH *)win->user;
				ok = 1;

				/* Mehr als ein Objekt, dann erst Gesamtinfo */
				if (desk.sel.numobs > 1) {
					nfiles = nfolders = nlinks = 0;
					size = 0L;
					item = wpath->list;
					graf_mouse(BUSYBEE, 0L);
					i = 0;
					while (i < wpath->e_total && ok) {
						item = wpath->lptr[i];
						if (item->sel) {
							if (item->class == EC_FILE || item->class == EC_DEVICE) {
								nfiles++;
								size += item->size;
							} else {
								if (item->class == EC_FOLDER) {
									strcpy(ipath, wpath->path);
									strcat(ipath, item->name);
									ok = !dir_check(ipath, &nfiles, &nfolders, &size, &nlinks, 0, 0);
								}
							}
						}
						i++;
					}
					graf_mouse(ARROW, 0L);
					if (ok) {
						OBJECT *baum2;

						baum2 = rs_trindex[SELINFO];

						l = (short)strlen(wpath->path);
						strShortener(baum2[SIPATH].ob_spec.free_string, wpath->path, 30);
						prlong11(size, baum2[SISIZE].ob_spec.free_string);
						sprintf(baum2[SIFILES].ob_spec.free_string, "%-6d", nfiles);
						sprintf(baum2[SIFOLDERS].ob_spec.free_string, "%-6d", nfolders);
						frm_start(&fi_selinfo, conf.wdial, conf.cdial, 1);
						done = 0;
						while (!done) {
							frm_dial(&fi_selinfo, &mevent);
							switch (fi_selinfo.exit_obj) {
							case SICANCEL:
							case SIDETAILS:
								done = 1;
								break;
							case SIHELP:
								show_help(fi_selinfo.userinfo);
								frm_norm(&fi_selinfo);
								break;
							}
						}
						frm_end(&fi_selinfo);
						if (fi_selinfo.exit_obj == SIDETAILS)
							doit = 1;
						else
							doit = 0;
					}
				} else
					doit = 1;

				if (doit && ok) {
					/* Info durchfuehren */
					i = 0;
					doup = 0;
					while (i < wpath->e_total && cont) {
						item = wpath->lptr[i];
						if (item->sel) {
							OBJECT *baum2;

							baum2 = rs_trindex[DEVINFO];

							/* Letztes Icon ? */
							num--;
							if (num > 0)
								donext = 1;
							else
								donext = 0;
							switch (item->class) {
							case EC_FILE:
							case EC_FOLDER:
								cont = dl_fileinfo(wpath->path, 0, &wpath->filesys, item, 0L, donext);
								break;
							case EC_PARENT:
								cont = 1;
								frm_start(&fi_parent, conf.wdial, conf.cdial, 1);
								done = 0;
								while (!done) {
									frm_dial(&fi_parent, &mevent);
									switch (fi_parent.exit_obj) {
									case PNHELP:
										show_help(fi_parent.userinfo);
										frm_norm(&fi_parent);
										break;
									case PNOK:
										done = 1;
										break;
									}
								}
								frm_end(&fi_parent);
								break;
							case EC_DEVICE:
								cont = 1;
								strcpy(baum2[DVNAME].ob_spec.free_string,item->name);
								baum2[DVLABEL].ob_flags |= HIDETREE;
								baum2[DVLABEL].ob_flags &=~ EDITABLE;
								baum2[DVLABEL-1].ob_flags |= HIDETREE;
								if (!donext)
									baum2[DVNEXT].ob_state |= DISABLED;
								frm_start(&fi_devinfo, conf.wdial, conf.cdial, 1);
								done = 0;
								while (!done) {
									frm_dial(&fi_devinfo, &mevent);
									switch(fi_devinfo.exit_obj) {
									case DVHELP:
										show_help(fi_devinfo.userinfo);
										frm_norm(&fi_devinfo);
										break;
									case DVCANCEL:
										cont = 0;
										done = 1;
										break;
									case DVOK:
									case DVNEXT:
										done = 1;
										break;
									}
								}
								frm_end(&fi_devinfo);
								baum2[DVLABEL].ob_flags &= ~HIDETREE;
								baum2[DVLABEL].ob_flags |= EDITABLE;
								baum2[DVLABEL-1].ob_flags &= ~HIDETREE;
								baum2[DVNEXT].ob_state &= ~DISABLED;
								break;
							}
							if (cont == 2)
								doup = 1;
						}
						i++; /* Naechstes Objekt pruefen */
					}
					/* Fenster aktualisieren */
					if (doup) {
						for (i = 0; i < MAX_PWIN; i++) {
							if (glob.win[i].state & WSOPEN) {
								uwpath = (W_PATH *)glob.win[i].user;
								if ((win == &glob.win[i]) || ((win!=&glob.win[i]) && !strcmp(wpath->path,uwpath->path))) {
									wpath_update(&glob.win[i]);
									win_redraw(&glob.win[i], tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h);
									win_slide(&glob.win[i], S_INIT, 0, 0);
								}
							}
						}
					}
				}
				break;
			case WCGROUP:
				num = desk.sel.numobs;
				cont = 1;
				gitem = ((W_GRP *)win->user)->entry;
				while (gitem && cont) {
					if (gitem->sel) {
						num--;
						if (num > 0)
							donext = 1;
						else
							donext = 0;
						if ((desk.sel.numobs == 1) && (ks & K_ALT)) {
							memset(msg, 0, sizeof(msg));
							msg[0] = AV_FILEINFO;
							msg[1] = tb.app_id;
							long2int((long)gitem->name, &msg[3], &msg[4]);
							avs_fileinfo(msg);
							cont = 0;
						} else {
							cont = dl_giteminfo(win, gitem, donext);
							if (cont == 2) {
								wgrp_update(win);
								wgrp_tree(win);
								win_redraw(win, tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h);
								win_slide(win, S_INIT, 0, 0);
								wgrp_change(win);
							}
						}
					}
					gitem = gitem->next;
				}
				break;
			}
		} else {
			if (tb.topwin) {
				/* Keine Objekte, dann Verzeichnisinfo */
				switch(tb.topwin->class) {
				case WCPATH:
					/* Rootverzeichnis ? */
					wpath=(W_PATH *)tb.topwin->user;
					if ((short)strlen(wpath->path) == 3) {
						/* Jo ... */
						i = wpath->path[0] - 64;
						if (dl_ddriveinfo(desk.dicon + i,0) == 2)
							icon_redraw(i);
					} else {
						/* Nein - dann Ordnerobjekt erzeugen und Info anzeigen */
						XATTR xattr;

						strrchr(wpath->path, 0)[-1] = 0;
						file_exists(wpath->path, 1, &xattr);
						*strrchr(wpath->path, 0) = '\\';
						iobj.used = 1;
						iobj.link = 0;
						iobj.time = xattr.mtime;
						iobj.date = xattr.mdate;
						iobj.atime = xattr.atime;
						iobj.adate = xattr.adate;
						iobj.ctime = xattr.ctime;
						iobj.cdate = xattr.cdate;
						iobj.uid = xattr.uid;
						iobj.gid = xattr.gid;
						iobj.mode = xattr.mode;
						if (!(wpath->filesys.flags & UNIXATTR))
							iobj.mode &= S_IFMT;
						iobj.class = EC_FOLDER;
						iobj.name[0] = 0;
						if (dl_fileinfo(wpath->path, 1, &wpath->filesys, &iobj, 0L, 0) == 2) {
							/* Ggf. Fenster aktualisieren */
							wpath_iupdate(tb.topwin, 0);
							for (i = 0; i < MAX_PWIN; i++) {
								if (glob.win[i].state & WSOPEN) {
									if (tb.topwin != &glob.win[i]) {
										uwpath = (W_PATH *)glob.win[i].user;
										l = (short)strlen(uwpath->path);
										if (!strncmp(wpath->path, uwpath->path, (long)l)) {
											wpath_update(&glob.win[i]);
											win_redraw(&glob.win[i], tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h);
											win_slide(&glob.win[i], S_INIT, 0, 0);
										}
									}
								}
							}
						}
					}
					break;
				case WCGROUP:
					dl_groupinfo(tb.topwin);
					break;
				}
			}
		}
	}
}

/*-------------------------------------------------------------------------
 dl_selall()

 Alle Objekte im aktiven Fenster auswaehlen
 -------------------------------------------------------------------------*/
void dl_selall(short sel) {
	WININFO *win;

	if (tb.topwin) {
		/* Desktop-Objekte und Objekte in anderen Fenstern deselektieren */
		icon_select(-1, 0, 0);
		win = tb.win;
		while (win) {
			switch (win->class) {
			case WCPATH:
				((W_PATH *)win->user)->amask[0] = 0;
				if (win != tb.topwin)
					wpath_esel(win, 0L, 0, 0, 1);
				else
					wpath_esel(win, 0L, 0, sel, 1);
				break;
			case WCGROUP:
				if (win != tb.topwin)
					wgrp_esel(win, 0L, 0, 0);
				else
					wgrp_esel(win, 0L, 0, sel);
				break;
			}
			win = win->next;
		}
	}
}

/*-------------------------------------------------------------------------
 dl_delete()
 
 Objekt/e loeschen bei Drag&Drop in den Papierkorb oder ueber das Menue
 
 Optional kann auch ein String mit Objektnamen angegeben werden,
 der dann statt der aktuellen Auswahl in Thing verwendet wird.
 -------------------------------------------------------------------------*/
static short dstop;

/* Unterfunktion: Datei loeschen */

short dl_del_file(char *name, short *nfiles, short *nfolders, short total, char *dlst) {
	short fret;
	long s;
	short mx, my, mb, ks;
	short stop, alret, i;
	char *p;
	OBJECT *objectTree;
	FILESYS fs;

	objectTree = rs_trindex[WAITCOPY];

	stop = dl_waitevent();
	if (!dstop)
		dstop = stop;

	/* Auf Abbruch pruefen und ggf. raus */
	graf_mkstate(&mx, &my, &mb, &ks);
	if ((ks & (K_LSHIFT | K_RSHIFT)) == (K_LSHIFT | K_RSHIFT) || dstop) {
		alret = frm_alert(1, rs_frstr[ALBREAK], altitle, conf.wdial, 0L);
		graf_mouse(BUSYBEE, 0L);
		dl_waitevent();
		if (alret == 1)
			return -1;
		else
			dstop = stop = 0;
	}

	/* Dateinamen im Dialog aktualisieren */
	p = objectTree[WCSRC].ob_spec.tedinfo->te_ptext;
	strShortener(p, name, 45);
	i = (short) strlen(p);
	while (i < 45) {
		p[i] = ' ';
		i++;
	}
	frm_redraw(&fi_waitcopy, WCSRC);

	/* Datei loeschen */
	fret = Fdelete(name);
	*nfiles = *nfiles - 1;

	/* Laufwerks-Update vormerken */
	fsinfo(name, &fs);
	i = fs.biosdev;
	if ((i >= 0) && (i <= 31))
		dlst[i] = 1;

	/* Fehler? */
	if (fret < 0)
		err_file(rs_frstr[ALFLDELETE], (long) fret, name);

	/* Status-Box aktualisieren */
	p = objectTree[WCFILES].ob_spec.tedinfo->te_ptext;
	itoa(*nfiles, p, 10);
	i = (short) strlen(p);
	while (i < 7) {
		p[i] = ' ';
		i++;
	}
	p = objectTree[WCFOLDERS].ob_spec.tedinfo->te_ptext;
	itoa(*nfolders, p, 10);
	i = (short) strlen(p);
	while (i < 7) {
		p[i] = ' ';
		i++;
	}

	s = (long) objectTree[WCBOX].ob_width * (total - (long) (*nfolders + *nfiles)) / total;
	if (s < 1L)
		s = 1L;
	if (s > (long) objectTree[WCBOX].ob_width)
		s = (long) objectTree[WCBOX].ob_width;
	objectTree[WCSLIDE].ob_width = (short) s;

	frm_redraw(&fi_waitcopy, WCFILES);
	frm_redraw(&fi_waitcopy, WCFOLDERS);
	frm_redraw(&fi_waitcopy, WCBOX);

	return fret;
}

/* Unterfunktion: Rekursives Loeschen eines Ordners */

short dl_del_folder(char *name, short *nfiles, short *nfolders, short total, char *dlst) {
	FILESYS filesys;
	_DTA dta, *odta;
	short usemint;
	long fret, dhandle;
	XATTR xattr;
	char dbuf[MAX_FLEN + 4];
	char path[MAX_PLEN];
	short done;
	long s;
	short mx, my, mb, ks;
	short stop, alret;
	short i, l;
	W_PATH *wpath;
	char *p;
	OBJECT *objectTree;

	objectTree = rs_trindex[WAITCOPY];

	stop = dl_waitevent();
	if (!dstop)
		dstop = stop;

	/* Art des Dateisystems ermitteln */
	fsinfo(name, &filesys);

	dhandle = Dopendir(name, 0);
	if (dhandle == -32L) {
		usemint = 0;
		odta = Fgetdta();
		Fsetdta(&dta);
		strcpy(path, name);
		strcat(path, "\\*.*");
		fret = (long) Fsfirst(path, FA_SUBDIR | FA_HIDDEN | FA_SYSTEM);
		while (!fret && (dta.dta_attribute == 0xf)) /* VFAT unter TOS ausfiltern */
			fret = (long) Fsnext();
		if (fret == 0L) {
			xattr.attr = dta.dta_attribute;
			strcpy(&dbuf[4], dta.dta_name);
		}
	} else {
		usemint = 1;
		fret = Dreaddir(MAX_FLEN + 4, dhandle, dbuf);
	}

	done = 0;
	if (fret < 0L) {
		if (fret != -49L && fret != -33L) {
			strcpy(path, name);
			strcat(path, "\\");
			err_file(rs_frstr[ALPREAD], fret, path);
		} else
			fret = 0L;
		done = 1;
	}

	/* Alle Eintraege rekursiv bearbeiten */
	while (!done) {
		stop = dl_waitevent();
		if (!dstop)
			dstop = stop;

		/* Auf Abbruch pruefen und ggf. raus */
		graf_mkstate(&mx, &my, &mb, &ks);
		if ((ks & (K_LSHIFT | K_RSHIFT)) == (K_LSHIFT | K_RSHIFT) || dstop) {
			alret = frm_alert(1, rs_frstr[ALBREAK], altitle, conf.wdial, 0L);
			graf_mouse(BUSYBEE, 0L);
			dl_waitevent();
			if (alret == 1) {
				if (!usemint)
					Fsetdta(odta);
				else
					Dclosedir(dhandle);
				return -1;
			} else
				dstop = stop = 0;
		}

		strcpy(path, name);
		strcat(path, "\\");
		strcat(path, &dbuf[4]);
		if (usemint)
			Fxattr(1, path, &xattr); /* !!! Follow links? */

		/* Laufwerksbezeichnung immer gross */
		path[0] = nkc_toupper(path[0]);
		/* Dateinamen ggf. anpassen */
		fsconv(path, &filesys);

		/* Eintrag bearbeiten */
		if (strcmp(&dbuf[4], ".") != 0 && strcmp(&dbuf[4], "..") != 0) {
			if (xattr.attr & FA_SUBDIR) /* Weiterer Ordner */
				fret = (long) dl_del_folder(path, nfiles, nfolders, total, dlst);
			else
				/* Datei oder symbolischer Link */
				fret = (long) dl_del_file(path, nfiles, nfolders, total, dlst);
		} else
			fret = 0L;

		/* Naechsten Eintrag holen */
		if (fret == 0L) {
			if (!usemint) {
				do {
					fret = (long) Fsnext();
				} while (!fret && (dta.dta_attribute == 0xf)); /* VFAT unter TOS ausfiltern */
				if (fret == 0L) {
					xattr.attr = dta.dta_attribute;
					strcpy(&dbuf[4], dta.dta_name);
				}
			} else {
				fret = Dreaddir(MAX_FLEN + 4, dhandle, dbuf);
			}
			if (fret < 0L) {
				done = 1;
				if (fret != -49L && fret != -33L) {
					strcpy(path, name);
					strcat(path, "\\");
					err_file(rs_frstr[ALPREAD], fret, path);
				} else
					fret = 0L;
			}
		} else
			done = 1;
	}
	if (!usemint)
		Fsetdta(odta);
	else
		Dclosedir(dhandle);

	strcpy(path, name);
	strcat(path, "\\");

	/* Dateinamen im Dialog aktualisieren */
	p = objectTree[WCSRC].ob_spec.tedinfo->te_ptext;
	strShortener(p, name, 45);
	i = (short) strlen(p);
	while (i < 45) {
		p[i] = ' ';
		i++;
	}
	frm_redraw(&fi_waitcopy, WCSRC);

	/* Ordner loeschen */
	if (fret == 0L) {
		fret = (long) Ddelete(name);
		*nfolders = *nfolders - 1;
		/* Laufwerks-Update vormerken */
		i = filesys.biosdev;
		if ((i >= 0) && (i <= 31))
			dlst[i] = 1;

		if (fret < 0L) {
			err_file(rs_frstr[ALPDELETE], fret, path);
		}
	}

	/* Status-Box aktualisieren */
	p = objectTree[WCFILES].ob_spec.tedinfo->te_ptext;
	itoa(*nfiles, p, 10);
	i = (short) strlen(p);
	while (i < 7) {
		p[i] = ' ';
		i++;
	}
	p = objectTree[WCFOLDERS].ob_spec.tedinfo->te_ptext;
	itoa(*nfolders, p, 10);
	i = (short) strlen(p);
	while (i < 7) {
		p[i] = ' ';
		i++;
	}

	s = (long) objectTree[WCBOX].ob_width * (total - (long) (*nfolders + *nfiles)) / total;
	if (s < 1L)
		s = 1L;
	if (s > (long) objectTree[WCBOX].ob_width)
		s = (long) objectTree[WCBOX].ob_width;
	objectTree[WCSLIDE].ob_width = (short) s;

	frm_redraw(&fi_waitcopy, WCFILES);
	frm_redraw(&fi_waitcopy, WCFOLDERS);
	frm_redraw(&fi_waitcopy, WCBOX);

	/* Ggf. betroffene Verzeichnisfenster zum Schliežen vormerken */
	l = (short) strlen(path);
	for (i = 0; i < MAX_PWIN; i++) {
		if (glob.win[i].state & WSOPEN) {
			wpath = (W_PATH *) glob.win[i].user;
			if (!strncmp(path, wpath->path, l))
				wpath->rel = -1;
		}
	}

	return (short) fret;
}

short dl_delete(char *buf) {
	short i, j, x, y, w, h, n, done;
	short tx1, ty1, tx2, ty2, rd;
	char ipath[MAX_PLEN], iname[MAX_FLEN];
	short ok, go;
	char kcmd[20], kstr[MAX_CLEN];
	short kdrv, kdrv1, kuse;
	short whandle;
	W_PATH *wpath;
	W_GRP *wgrp;
	WG_ENTRY *gitem, *gitem1;
	OBJECT *objectTree;
	XATTR xattr;
	short (*delfunc)(char *, short *, short *, short, char *);
	char *readbuf;
	short nlinks;

	objectTree = rs_trindex[WAITCOPY];

	/* String mit Objektnamen */
	if (buf) {
		/* Loeschen waehrend des Kopierens nicht moeglich! */
		if (glob.sm_copy) {
			if (fi_waitcopy.open && fi_waitcopy.state == FST_WIN)
				win_top(&fi_waitcopy.win);
			mybeep();
			return 0;
		}

		dcopy = pmalloc(sizeof(DCOPY));
		if (!dcopy) {
			frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
			return 0;
		}
		glob.sm_copy = 1;
		dstop = 0;

		dcopy->follow = 0;
		dcopy->mode = 1;
		dcopy->avid = -1;
		dcopy->j_step = 0;
		dcopy->stack = dcopy->curr = 0L;
		dcopy->nfiles = dcopy->nfolders = 0;
		dcopy->size = dcopy->bsrc = dcopy->bdst = 0L;
		dcopy->infh = dcopy->outfh = -1L;
		dcopy->buf = 0L;
		dcopy->buflen = 0L;
		for (i = 0; i < 32; i++)
			dcopy->dlst[i] = 0;

		ok = 0;

		/* Umfang der Daten ermitteln */
		go = 1;
		dcopy->nfiles = dcopy->nfolders = 0;
		dcopy->size = 0L;
		graf_mouse(BUSYBEE, 0L);

		i = 0;
		if (conf.kbd_use && (conf.kbd_files == 1))
			kuse = ok = 1;
		else {
			readbuf = buf;
			while (get_buf_entry(readbuf, ipath, &readbuf) && go) {
				go = !dir_check(ipath, &dcopy->nfiles, &dcopy->nfolders, &dcopy->size, &nlinks, 0, 0);
			}
			graf_mouse(ARROW, 0L);
			dcopy->total = (long) (dcopy->nfiles + dcopy->nfolders);

			/* Pruefen, ob Kobold verwendet wird */
			if (conf.kbd_use && dcopy->nfiles >= conf.kbd_files)
				kuse = 1;
			else
				kuse = 0;
			if (kuse && conf.kb_tosonly) {
				FILESYS fs;

				readbuf = buf;
				while (get_buf_entry(readbuf, ipath, &readbuf)) {
					fsinfo(ipath, &fs);
					if ((fs.flags & (TOS | UPCASE)) != (TOS | UPCASE)) {
						kuse = 0;
						break;
					}
				}
			}

			if (go) {
				if (conf.cdel && !kuse) {
					/* Falls Bestaetigung fuer Loeschen ... */
					char drv;
					OBJECT *tree;

					if (buf[0] == '\'')
						drv = buf[1];
					else
						drv = buf[0];
					tree = rs_trindex[DELETE];
					tree[DLSOURCE].ob_spec.free_string[0] = drv;
					prlong11(dcopy->size, tree[DLSIZE].ob_spec.free_string);
					sprintf(tree[DLFILES].ob_spec.free_string, "%-6d", dcopy->nfiles);
					sprintf(tree[DLFOLDERS].ob_spec.free_string, "%-6d", dcopy->nfolders);
					frm_start(&fi_delete, conf.wdial, conf.cdial, 1);
					done = 0;
					while (!done) {
						frm_dial(&fi_delete, &mevent);
						switch (fi_delete.exit_obj) {
						case DLOK:
						case DLCANCEL:
							done = 1;
							break;
						case DLHELP:
							show_help(fi_delete.userinfo);
							frm_norm(&fi_delete);
							break;
						}
					}
					frm_end(&fi_delete);
					if (fi_delete.exit_obj == DLOK)
						ok = 1;
					else
						ok = 0;
				} else
					ok = 1;
			}
		}

		/* Kobold-Job */
		if (ok && kuse) {
			/* Kobold ueberhaupt verwenden? */
			graf_mouse(BUSYBEE, 0L);

			strcpy(kcmd, "DELETE\n");

			/* Job anlegen */
			if (kbd_newjob()) {
				kdrv = kdrv1 = -1;
				kbd_addcmd("* Thing\n");
				if (conf.cdel)
					kbd_addcmd("DIALOG_LEVEL = 2\n");
				else
					kbd_addcmd("DIALOG_LEVEL = 0\n");

				i = 0;
				readbuf = buf;
				while (get_buf_entry(readbuf, ipath, &readbuf)) {
					j = (short) strlen(ipath);
					if (ipath[j - 1] == '\\')
						j--;
					ipath[j] = 0;

					kdrv = nkc_toupper(ipath[0]);
					if (kdrv1 == -1) {
						kdrv1 = kdrv;
						sprintf(kstr, "SRC_SELECT %c:\\\n", ipath[0]);
						kbd_addcmd(kstr);
					} else {
						if (kdrv != kdrv1) {
							kdrv1 = kdrv;
							kbd_addcmd(kcmd);
							sprintf(kstr, "SRC_SELECT %c:\\\n", ipath[0]);
							kbd_addcmd(kstr);
						}
					}
					if (!(conf.kbd_two & 2))
						quote(&ipath[2]);
					sprintf(kstr, "SRC_SELECT + %s\n", &ipath[2]);
					kbd_addcmd(kstr);
				}
				kbd_addcmd(kcmd);
				kbd_addcmd("DIALOG_LEVEL = 0\nSRC_SELECT ?\n");

				/* Job ausfuehren */
				kbd_startjob();
			}
			graf_mouse(ARROW, 0L);
			ok = 0;
		}

		/* Auf gehts ... */
		if (ok && go) {
			/* Status-Box vorbereiten und ausgeben */
			strcpy(objectTree[WCTEXT].ob_spec.free_string, rs_frstr[MSDEL1]);
			itoa(dcopy->nfiles, objectTree[WCFILES].ob_spec.tedinfo->te_ptext, 10);
			itoa(dcopy->nfolders, objectTree[WCFOLDERS].ob_spec.tedinfo->te_ptext, 10);
			objectTree[WCSRC].ob_spec.tedinfo->te_ptext[0] = 0;
			objectTree[WCSIZE].ob_flags |= HIDETREE;
			objectTree[WCSTXT].ob_flags |= HIDETREE;
			objectTree[WCDST].ob_flags |= HIDETREE;
			objectTree[WCDTXT].ob_flags |= HIDETREE;
			objectTree[WCSLIDE].ob_width = 1;
			frm_start(&fi_waitcopy, conf.wdial, conf.cdial, 1);
			if (fi_waitcopy.state == FST_WIN)
				frm_redraw(&fi_waitcopy, ROOT);
			/* Rekursiv Loeschen */
			graf_mouse(BUSYBEE, 0L);
			i = 0;
			readbuf = buf;
			while (get_buf_entry(readbuf, ipath, &readbuf) && ok) {
				j = (short) strlen(ipath);

				delfunc = dl_del_file;
				if (ipath[j - 1] == '\\') {
					delfunc = dl_del_folder;
					ipath[j - 1] = 0;
					if ((Fxattr(1, ipath, &xattr) == 0) && ((xattr.mode & S_IFMT) != S_IFDIR)) {
						delfunc = dl_del_file;
					}
				}
				if (delfunc(ipath, &dcopy->nfiles, &dcopy->nfolders, (short) dcopy->total, dcopy->dlst) != 0)
					ok = 0;
			}

			/* Status-Box wieder entfernen */
			frm_end(&fi_waitcopy);
			objectTree[WCSIZE].ob_flags &= ~HIDETREE;
			objectTree[WCSTXT].ob_flags &= ~HIDETREE;
			objectTree[WCDST].ob_flags &= ~HIDETREE;
			objectTree[WCDTXT].ob_flags &= ~HIDETREE;

			/* Verzeichnisse aktualisieren */
			for (i = 0; i < MAX_PWIN; i++) {
				if (glob.win[i].state & WSOPEN) {
					wpath = (W_PATH *) glob.win[i].user;
					if (wpath->rel == -1) {
						/* Nicht mehr benoetigte Verzeichnisfenster schliessen */
						tb.topwin = &glob.win[i];
						dl_closewin();
					} else {
						/* Veraenderte Laufwerke aktualisieren */
						j = wpath->filesys.biosdev;
						if (j >= 0 && j <= 31) {
							if (dcopy->dlst[j]) {
								wpath_update(&glob.win[i]);
								win_redraw(&glob.win[i], tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h);
								win_slide(&glob.win[i], S_INIT, 0, 0);
							}
						}
					}
				}
			}
			/* Aktives Fenster neu ermitteln - koennte veraendert sein! */
			get_twin(&whandle);
			tb.topwin = win_getwinfo(whandle);
			win_newtop(tb.topwin);

			graf_mouse(ARROW, 0L);
		}

		pfree( dcopy);
		glob.sm_copy = 0;
		return (ok);
	}

	if (desk.sel.desk) {
		/* Objekte auf dem Desktop */
		ICONDESK *p = desk.dicon + 1;

		/* Position/Maže des Gesamtrechtecks fuer Desktop-Redraw */
		tx1 = tb.desk.g_x + tb.desk.g_w;
		ty1 = tb.desk.g_y + tb.desk.g_h;
		tx2 = ty2 = 0;
		rd = 0;

		for (i = 1; i <= MAXICON; i++, p++) {
			if ((p->class != IDFREE) && p->select) {
				objc_offset(rs_trindex[DESKTOP], i, &x, &y);
				w = rs_trindex[DESKTOP][i].ob_width;
				h = rs_trindex[DESKTOP][i].ob_height;
				switch (p->class) {
				case IDDEVICE:
				case IDFILE:
				case IDFOLDER:
					icon_free(i);
					p->select = 0;
					icon_update(i);
					/* Gesamtrechteck anpassen */
					if (x < tx1)
						tx1 = x;
					if (y < ty1)
						ty1 = y;
					if (x + w > tx2)
						tx2 = x + w;
					if (y + h > ty2)
						ty2 = y + h;
					rd = 1;
					break;
				case IDCLIP:
					scrap_clear();
					icon_select(i, 1, 0);
					clip_update();
					break;
				case IDDRIVE:
					/* Alle betroffenen Verzeichnisfenster schliežen */
					for (j = 0; j < MAX_PWIN; j++) {
						if (glob.win[j].state & WSOPEN) {
							if (((W_PATH *)glob.win[j].user)->filesys.biosdev == p->spec.drive->drive) {
								tb.topwin=&glob.win[j];
								dl_closewin();
							}
						}
					}
					/* Icon freigeben */
#if 0
					p->title[0]=0;
#endif
					p->class = IDFREE;
					p->select = 0;
					icon_update(i);
#if 0
					p->x=-1;
					p->y=-1;
#endif
					/* Gesamtrechteck anpassen */
					if (x < tx1)
						tx1 = x;
					if (y < ty1)
						ty1 = y;
					if (x + w > tx2)
						tx2 = x + w;
					if (y + h > ty2)
						ty2 = y+h;
					rd = 1;
					break;
				}
			}
		}
		if (rd)
			desk_draw(tx1, ty1, tx2 - tx1 + 1, ty2 - ty1 + 1);
	} else {
		/* Objekte in einem Fenster ? */
		if (desk.sel.win) {
			/* Jo ... */
			switch (desk.sel.win->class) {
			case WCPATH:
				ok = 0;
				lbuf = pmalloc(MAX_KBDLEN);
				if (lbuf) {
					ok = sel2buf(lbuf, iname, ipath, (short)MAX_KBDLEN);
					if (ok)
						ok = dl_delete(lbuf);
					pfree(lbuf);
				} else {
					frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
					return (0);
				}
				break;
			case WCGROUP:
				/* Gruppenobjekt entfernen ... */
				ok = 0;
				wgrp = (W_GRP *)desk.sel.win->user;

				/* Selektiertes Objekt ermitteln */
				n = 0;
				gitem = wgrp->entry;
				while (gitem) {
					if (gitem->sel)
						n++;
					gitem = gitem->next;
				}

				/* Selektierte Objekte entfernen */
				if (n) {
					if (frm_alert(1, rs_frstr[ALDELENTRY], altitle, conf.wdial, 0L) == 1) {
						gitem = wgrp->entry;
						while (gitem) {
							if (gitem->sel) {
								gitem1 = gitem->next;
								wgrp_remove(wgrp, gitem);
								gitem = gitem1;
							} else
								gitem = gitem->next;
						}
						/* Ggf. Cursor abschalten */
						wgrp->focus = 0;
						if (!wgrp->e_num && glob.fwin == desk.sel.win) {
							glob.fmode = 0;
							glob.fwin = 0L;
						}
						/* Gruppe aktualisieren */
						wgrp_tree(desk.sel.win);
						win_redraw(desk.sel.win, tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h);
						win_slide(desk.sel.win, S_INIT, 0, 0);
						wgrp_change(desk.sel.win);
						ok = 1;
					}
				}
				break;
			}
		}
	}

	return (ok);
}

/**
 * Dateien suchen
 */
void dl_find(void) {
	APPLINFO appl, *aptr;

	if (*conf.finder) {
		aptr = app_find(conf.finder);
		if (aptr == NULL) {
			strcpy(appl.name, conf.finder);
			app_default(&appl);
			appl.usesel = 1;
			aptr = &appl;
		}
		app_opensel(aptr);
	}
}

/**
 * Aktuelles Medium auswerfen (entweder gerade selektiertes Laufwerk,
 * oder oberstes Fenster).
 */
void dl_eject(void) {
	char help[4], *ejectdir, *errtype;
	W_PATH *wpath;
	short i, ejected = 0, drv;
	unsigned short maj, min;
	long err;
	ICONDESK *p;

	ejectdir = 0L;
	if ((desk.sel.numobs == 1) && (desk.sel.drives == 1)) {
		p = desk.dicon + 1;
		for (i = 1; i <= MAXICON; i++, p++) {
			if ((p->class == IDDRIVE) && p->select) {
				drv = p->spec.drive->drive;
				sprintf(help, "%c:\\", drv + 'A');
				ejectdir = help;
				break;
			}
		}
	} else if (!desk.sel.drives) {
		if (tb.topwin && (tb.topwin->class == WCPATH)) {
			wpath = (W_PATH *) tb.topwin->user;
			drv = wpath->filesys.biosdev;
			ejectdir = wpath->path;
		}
	}
	if ((ejectdir == 0L) || (drv < 0) || (drv > 32)) {
		mybeep();
		return;
	}
	graf_mouse(BUSYBEE, 0L);
	errtype = "TOS";
	err = Dcntl(0x4309, ejectdir, 0L); /* CDROMEJECT */
	if (err == 0L)
		ejected = 1;
	else {
		if (err == -32L) {
			if (XHGetVersion()) {
				errtype = "XHDI";
				if ((err = XHInqDev(drv, &maj, &min, 0L, 0L)) == 0L) {
					if ((err = XHEject(maj, min, 1, 0)) == 0L)
						ejected = 1;
				}
			}
		}
	}
	graf_mouse(ARROW, 0L);
	if (!ejected) {
		sprintf(almsg, rs_frstr[ALNOEJECT], drv + 'A', errtype, (short) err);
		frm_alert(1, almsg, altitle, conf.wdial, 0L);
		return;
	}
	for (i = 0; i < MAX_PWIN; i++) {
		if (glob.win[i].state & WSOPEN) {
			if ((((W_PATH *) glob.win[i].user)->filesys.biosdev == drv)
					|| !strcmp(((W_PATH *) glob.win[i].user)->path, ejectdir)) {
				tb.topwin = &glob.win[i];
				dl_closewin();
			}
		}
	}
}

/*-------------------------------------------------------------------------
 dl_format()
 
 Diskette formatieren
 -------------------------------------------------------------------------*/

/* Job - formatieren */

void job_format(void) {
	long s, fh;
	short state, side, cont, dret, i;
	_DISKINFO diskinfo;

	if (glob.sm_format > 1)
		return;

	cont = 1;
	switch (dformat->j_step) {
	case 0:
		sprintf(rs_trindex[WAIT][WTEXT2].ob_spec.tedinfo->te_ptext, rs_frstr[MSFORMAT2], dformat->track, dformat->side);
		s = (long) rs_trindex[WAIT][WFBOX].ob_width * (long) (79 - dformat->track) / 79L;
		if (s == 0L)
			s = 1L;
		rs_trindex[WAIT][WFSLIDE].ob_width = (short) s;

		frm_redraw(&fi_wait, WTEXT2);
		frm_redraw(&fi_wait, WFSLIDE);

		state = Flopfmt(dformat->buf, 0L, dformat->drive, dformat->sec, dformat->track, dformat->side, 1, 0x87654321L, 0xe5e5);

		/* Bei Fehlern den Job canceln */
		if (state != 0) {
			unlock_device(dformat->drive);
			glob.sm_format = 2;
			frm_alert(1, rs_frstr[ALFORMERR], altitle, conf.wdial, 0L);
			cont = 0;
		} else {
			/* Sonst weitermachen */
			dformat->side++;
			if (dformat->side > 1) {
				dformat->side = 0;
				dformat->track--;
				if (dformat->track < 0)
					dformat->j_step = 1;
			}
		}
		break;
	case 1:
		/* FATs und Rootdirectory erzeugen */
		memset(dformat->buf, 0, 512L * 18L * 2L);
		dformat->buf[1 * 512] = 0xf9;
		dformat->buf[1 * 512 + 1] = 0xff;
		dformat->buf[1 * 512 + 2] = 0xff;
		if (dformat->sec == 9) {
			dformat->buf[4 * 512] = 0xf9;
			dformat->buf[4 * 512 + 1] = 0xff;
			dformat->buf[4 * 512 + 2] = 0xff;
		} else {
			dformat->buf[6 * 512] = 0xf9;
			dformat->buf[6 * 512 + 1] = 0xff;
			dformat->buf[6 * 512 + 2] = 0xff;
		}

		for (side = 0; side < 2 && cont; side++) {
			if (Flopwr(&dformat->buf[side * 512 * dformat->sec], 0L, dformat->drive, 1, 0, side, dformat->sec) != 0) {
				unlock_device(dformat->drive);
				glob.sm_format = 2;
				frm_alert(1, rs_frstr[ALFORMERR], altitle, conf.wdial, 0L);
				cont = 0;
			}
		}
		dformat->j_step = 2;
		break;
	case 2:
		/* Bootsektor erzeugen */
		memset(dformat->buf, 0, 512L * 18L * 2L);
		dformat->buf[0] = 0xe9;
		dformat->buf[1] = 0x00;
		dformat->buf[2] = 0x4e;
		for (i = 3; i < 8; i++)
			dformat->buf[i] = 0;
		s = Gettime();
		dformat->buf[8] = (unsigned char) (s & 0xffL);
		dformat->buf[9] = (unsigned char) ((s & 0xff00L) >> 8) & ~(unsigned char) ((s & 0xff000000L) >> 24);
		dformat->buf[10] = (unsigned char) ((s & 0xff0000L) >> 16) & ~(unsigned char) (s & 0xffL);
		dformat->buf[11] = 0;
		dformat->buf[12] = 2;
		dformat->buf[13] = 2;
		dformat->buf[14] = 1;
		dformat->buf[15] = 0;
		dformat->buf[16] = 2;
		dformat->buf[21] = 0xf9;
		dformat->buf[24] = dformat->sec;
		dformat->buf[26] = 2;
		if (dformat->sec == 9) {
			dformat->buf[17] = 0x70;
			dformat->buf[19] = 0xa0;
			dformat->buf[20] = 0x05;
			dformat->buf[22] = 3;
		} else {
			dformat->buf[17] = 0xe0;
			dformat->buf[19] = 0x40;
			dformat->buf[20] = 0x0b;
			dformat->buf[22] = 5;
		}

		if (Flopwr(dformat->buf, 0L, dformat->drive, 1, 0, 0, 1) != 0) {
			unlock_device(dformat->drive);
			glob.sm_format = 2;
			frm_alert(1, rs_frstr[ALFORMERR], altitle, conf.wdial, 0L);
			cont = 0;
		}
		dformat->j_step = 3;
		break;
	case 3:
		/* Bei Bedarf Volume Label erzeugen */
		unlock_device(dformat->drive);
		if (dformat->label[3] != 0) {
			fh = Fcreate(dformat->label, FA_VOLUME);
			if (fh >= 0L) {
				Fclose((short) fh);
			} else {
				glob.sm_format = 2;
				frm_alert(1, rs_frstr[ALFORMERR], altitle, conf.wdial, 0L);
				cont = 0;
			}
		}
		dformat->j_step = 4;
		break;
	case 4:
		/* Abschliessend Parameter ermitteln und anzeigen */
		glob.sm_format = 2;
		dret = Dfree(&diskinfo, dformat->drive + 1);
		if (dret < 0) {
			frm_alert(1, rs_frstr[ALFORMERR], altitle, conf.wdial, 0L);
		} else {
			s = (long) (diskinfo.b_free * diskinfo.b_secsiz * diskinfo.b_clsiz);
			sprintf(almsg, rs_frstr[ALSERIAL], s, (short) dformat->buf[8], (short) dformat->buf[9], (short) dformat->buf[10]);
			frm_alert(1, almsg, altitle, conf.wdial, 0L);
		}
		cont = 0;
		break;
	}

	if (cont) {
		/* Job am Laufen halten */
		do_job( JB_FORMAT);
	} else {
		if (fi_wait.open)
			frm_end(&fi_wait);

		/* Verzeichnisfenster ggf. aktualisieren */
		for (i = 0; i < MAX_PWIN; i++) {
			if (glob.win[i].state & WSOPEN) {
				if (((W_PATH *) glob.win[i].user)->path[0] == 'A' + dformat->drive) {
					wpath_update(&glob.win[i]);
					win_redraw(&glob.win[i], tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h);
					win_slide(&glob.win[i], S_INIT, 0, 0);
				}
			}
		}

		/* Finito... */
		pfree(dformat->buf);
		pfree(dformat);
		glob.sm_format = 0;

		mn_update();
	}
}

/* Dialog-Init */

void di_format(void) {
	ICONDESK *a, *b;

	if (glob.sm_format) {
		mybeep();
		if (fi_wait.open)
			frm_restore(&fi_wait);
		return;
	}

	/* Falls Kobold zum Formatieren eingetragen ist, dann
	 Kobold-Job */
	if (conf.kbf_use) {
		if (kbd_newjob()) {
			graf_mouse(BUSYBEE, 0L);
			kbd_addcmd("DIALOG_LEVEL = 2\n");
			kbd_addcmd("FORMAT A\n");
			kbd_startjob();
			graf_mouse(ARROW, 0L);
			return;
		}
	}

	/* Falls Applikation fuer Formatieren eingetragen ist, dann
	 diese verwenden */
	if (conf.format[0]) {
		short ok = 0;

		strcpy(glob.cmd, conf.format);
		quote(glob.cmd);
		if ((desk.sel.numobs == 1) && (desk.sel.drives == 1)) {
			short i;
			char drv[2];

			a = desk.dicon + 1;
			for (i = 1; i <= MAXICON; i++, a++) {
				if ((a->class == IDDRIVE) && a->select) {
					ok = 1;
					drv[0] = a->spec.drive->drive + 'A';
					drv[1] = 0;
					strcat(glob.cmd, " ");
					strcat(glob.cmd, drv);
					strcat(glob.cmd, ":");
					break;
				}
			}
		}
		if (!ok)
			strcat(glob.cmd, " A:");
		va_open(glob.cmd);
		return;
	}

	/* Schliežlich interne Routine... */
	if (fi_format.open) {
		mybeep();
		frm_restore(&fi_format);
		return;
	}

	/* Falls genau eine Floppy selektiert ist, dann Laufwerkskennung uebernehmen */
	a = desk.dicon + 1;
	b = a + 1;
	if (a->class != IDFREE && a->select && ((b->class != IDFREE && !b->select)|| b->class == IDFREE)) {
		rs_trindex[FORMAT][FMDRIVEA].ob_state |= SELECTED;
		rs_trindex[FORMAT][FMDRIVEB].ob_state &= ~SELECTED;
	}
	if (b->class != IDFREE && b->select && ((a->class != IDFREE && !a->select)|| a->class == IDFREE)) {
		rs_trindex[FORMAT][FMDRIVEA].ob_state &= ~SELECTED;
		rs_trindex[FORMAT][FMDRIVEB].ob_state |= SELECTED;
	}
	rs_trindex[FORMAT][FMNAME].ob_spec.tedinfo->te_ptext[0] = 0;

	frm_start(&fi_format, conf.wdial, conf.cdial, 0);
}

/* Dialog-Exit */

void de_format(short mode, short ret) {
	short exit_obj, done;
	UNUSED(ret);

	done = 0;
	if (!mode) {
		exit_obj = fi_format.exit_obj;
		switch (exit_obj) {
		case FMOK:
			done = FMOK;
			if (!isValidFileMask(rs_trindex[FORMAT][FMNAME].ob_spec.tedinfo->te_ptext, FALSE)) {
				frm_alert(1, rs_frstr[ALILLDNAME], altitle, conf.wdial, 0L);
				done = 0;
			} else {
				if (frm_alert(2, rs_frstr[ALFORMAT], altitle, conf.wdial, 0L) == 2)
					done = 0;
			}
			if (!done) {
				fi_format.exit_obj = exit_obj;
				frm_norm(&fi_format);
			}
			break;
		case FMCANCEL:
			done = FMCANCEL;
			break;
		}
	} else
		done = FMCANCEL;

	if (done) {
		frm_end(&fi_format);
		if (done == FMOK) {
			dformat = pmalloc(sizeof(DFORMAT));
			if (!dformat) {
				frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
				return;
			}

			/* Parameter aus dem Dialog uebernehmen */
			if (rs_trindex[FORMAT][FMDRIVEA].ob_state & SELECTED)
				dformat->drive = 0;
			else
				dformat->drive = 1;
			if (rs_trindex[FORMAT][FMFORMDD].ob_state & SELECTED)
				dformat->sec = 9;
			else
				dformat->sec = 18;
			if (rs_trindex[FORMAT][FMQUICK].ob_state & SELECTED)
				dformat->fast = 1;
			else
				dformat->fast = 0;
			strcpy(dformat->label, "A:\\");
			strcat(dformat->label, rs_trindex[FORMAT][FMNAME].ob_spec.tedinfo->te_ptext);
			dformat->label[0] = 'A' + dformat->drive;

			/* Buffer fuer FATs etc. einrichten */
			dformat->buf = pmalloc(512L * 18L * 2L);
			if (!dformat->buf) {
				pfree(dformat);
				frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
				return;
			}

			/* Device-Lock moeglich? */
			if (lock_device(dformat->drive) >= 2) {
				pfree(dformat->buf);
				pfree(dformat);
				frm_alert(1, rs_frstr[ALNOLOCK], altitle, conf.wdial, 0L);
				return;
			}

			if (!dformat->fast) {
				/* "Wait"-Dialog vorbereiten und ausgeben */
				strcpy(rs_trindex[WAIT][WTEXT1].ob_spec.tedinfo->te_ptext, rs_frstr[MSFORMAT1]);
				dformat->track = 0;
				dformat->side = 0;
				sprintf(rs_trindex[WAIT][WTEXT2].ob_spec.tedinfo->te_ptext, rs_frstr[MSFORMAT2], dformat->track, dformat->side);
				rs_trindex[WAIT][WFSLIDE].ob_width = 1;
				frm_start(&fi_wait, conf.wdial, conf.cdial, 0);
				dformat->j_step = 0;
			} else
				dformat->j_step = 1;

			/* Job anwerfen */
			dformat->track = 79;
			dformat->side = 0;
			glob.sm_format = 1; /* Semaphore setzen */
			do_job(JB_FORMAT);
		}
	}
}

/* Status-Dialog-Exit */

void de_wait(short mode, short ret) {
	short exit_obj;
	UNUSED(ret);

	if (glob.sm_format)
		exit_obj = fi_wait.exit_obj;
	else
		exit_obj = fi_waitcopy.exit_obj;
	if (mode || (!mode && (exit_obj == WFCANCEL || exit_obj == WCCANCEL))) {
		if (glob.sm_format)
			glob.sm_format = 2;
		else
			glob.sm_copy = 2;
		if (frm_alert(1, rs_frstr[ALBREAK], altitle, conf.wdial, 0L) == 1) {
			if (glob.sm_format) {
				if (dformat->j_step < 5)
					unlock_device(dformat->drive);
				pfree(dformat->buf);
				pfree(dformat);
				frm_end(&fi_wait);
				glob.sm_format = 0;
			} else {
				if (dcopy) {
					pfree(dcopy);
					dcopy = 0L;
				}
				frm_end(&fi_waitcopy);
				glob.sm_copy = 0;
			}
		} else {
			/* Job fortsetzen */
			if (glob.sm_format) {
				fi_wait.exit_obj = exit_obj;
				frm_norm(&fi_wait);
				glob.sm_format = 1;
				do_job(JB_FORMAT);
			} else {
				fi_waitcopy.exit_obj = exit_obj;
				frm_norm(&fi_waitcopy);
				glob.sm_copy = 1;
				do_job(JB_COPY);
			}
		}
	}
}

/*-------------------------------------------------------------------------
 dl_nextwin()

 Auf naechstes Fenster umschalten
 -------------------------------------------------------------------------*/

void dl_nextwin(void) {
	WININFO *win;
	ACWIN *acc;
	short handle;

	aesmsg[0] = WM_TOPPED;
	aesmsg[1] = tb.app_id;
	aesmsg[2] = 0;
	aesmsg[4] = 0;
	aesmsg[5] = 0;
	aesmsg[6] = 0;
	aesmsg[7] = 0;

	/* Thing-Fenster aktiv ? */
	if (tb.topwin) {
		/* Ja */
		win = tb.topwin->next;
		if (!win) {
			/* Letztes Fenster - Accessory-Fenster vorhanden ? */
			if (!glob.accwin)
				win = tb.win; /* Nein - beim ersten weitermachen */
			else /* Ja - erstes Accessory-Fenster toppen */
			{
				if (avp_check(glob.accwin->id)) {
					aesmsg[3] = glob.accwin->handle;
					appl_write(glob.accwin->id, 16, aesmsg);
				} else
					win = tb.win;
			}
		}
		if (win) {
			tb.topwin = win;
			win_top(tb.topwin);
			magx_switch(tb.app_id, 0);
			if (glob.fmode && tb.topwin != glob.fwin)
				wf_clear();
			mn_check();
		}
	} else {
		/* Nein */

		/* Aktives Fenster bekannt ? */
		get_twin(&handle);
		acc = acwin_find(handle);
		if (acc) {
			/* Ja */
			acc = acc->next;
			if (!acc) {
				/* Letztes angemeldetes Fenster - Thing-Fenster vorhanden ? */
				if (!tb.win)
					acc = glob.accwin; /* Nein - erstes Accessory */
				else /* Ja - erstes Thing-Fenster */
				{
					tb.topwin = tb.win;
					win_top(tb.topwin);
					magx_switch(tb.app_id, 0);
					if (glob.fmode && tb.topwin != glob.fwin)
						wf_clear();
				}
			}
		} else
			acc = glob.accwin;
		if (acc) {
			if (avp_check(acc->id)) {
				aesmsg[3] = acc->handle;
				appl_write(acc->id, 16, aesmsg);
			}
		} else {
			if (tb.win) {
				tb.topwin = tb.win;
				win_top(tb.topwin);
				magx_switch(tb.app_id, 0);
				if (glob.fmode && tb.topwin != glob.fwin)
					wf_clear();
			}
		}
	}
}

/**-------------------------------------------------------------------------
 dl_closewin()

 Aktuelles Fenster schliessen
 -------------------------------------------------------------------------*/
void dl_closewin(void) {
	short whandle;
	ACWIN *awin;
	W_GRP *wgrp;
	WININFO *win;

	/* Fenster von Thing */
	if (tb.topwin) {
		win = tb.topwin;
		if (glob.fmode && win == glob.fwin)
			wf_clear();

		/* Je nach Art des Fensters schliessen und belegten Speicher freigeben */
		switch (win->class) {
			case WCDIAL:
				((FORMINFO *)win->user)->exit(1, 0);
				break;
			case WCPATH:
				if (fi_mask.open) {
					if (dmask->win == win)
						fi_mask.exit(1, 0);
				}
				win_close(win);
				wpath_tfree(win);
				wpath_lfree(win);
				pfree(win->user);
				break;
			case WCGROUP:
				wgrp = (W_GRP *)win->user;
				if (wgrp->changed) {
					if (wgrp->autosave)
						dl_savegrp();
					else {
						if (!glob.closeall) {
							sprintf(almsg, rs_frstr[ALGROUPCHANGED], wgrp->title);
							if (frm_alert(1, almsg, altitle, conf.wdial, 0L) == 2)
								return;
						}
					}
				}
				win_close(win);
				wgrp_tfree(win);
				while (wgrp->entry)
					wgrp_remove(wgrp,wgrp->entry);
				if (wgrp->img_ok)
					desk_ifree(&wgrp->img_info);
				pfree(win->user);
				pfree(win);
				if (!glob.autoclose && !glob.closeall && *wgrp->parent) {
					if (!handle_fkey_or_tool(wgrp->parent))
						mybeep();
				}
				break;
			case WCCON:
				cwin_close();
				break;
		}
		/* Aktives Fenster ermitteln */
		get_twin(&whandle);
		tb.topwin = win_getwinfo(whandle);
		win_newtop(tb.topwin);
	} else {
		/* Evtl. Acc-Fenster */
		get_twin(&whandle);

		if (whandle) {
			awin = acwin_find(whandle);
			/* Falls es bekannt ist, dann dem Eigentuemer WM_CLOSED schicken */
			if (awin) {
				if (avp_check(awin->id))
					appl_send(awin->id, WM_CLOSED, 0, whandle, 0, 0, 0, 0);
			}
		}
	}
}

/**-------------------------------------------------------------------------
 dl_closeallwin()

 Alle Fenster schliessen
 -------------------------------------------------------------------------*/
void dl_closeallwin(void) {
	ACWIN *awin, *skip;

	/* Thing-Fenster */
	glob.closeall = 1;
	while (tb.win) {
		tb.topwin = tb.win;
		dl_closewin();
	};
	glob.closeall = 0;

	/* Angemeldete Fenster */
	awin = glob.accwin;
	while (awin) {
		for (skip = awin->next; skip && (skip->id == awin->id); skip = skip->next)
			;
		if (avp_check(awin->id)) {
			appl_send(awin->id, WM_CLOSED, 0, awin->handle, 0, 0, 0, 0);
			awin = awin->next;
		} else
			awin = skip;
	}
}

/*-------------------------------------------------------------------------
 dl_copywin()

 Inhalt des aktiven Fensters oder der aktuellen Auswahl auf die Ablage
 -------------------------------------------------------------------------*/

void dl_copywin(void) {
	char tmp[514], outname[MAX_PLEN];
	short i, j, l, l1, l2;
	char *cbuf;
	W_PATH *wpath;
	WP_ENTRY *item;
	long fh, fh2;
	short files = 0, first = 1;
	ICONDESK *p;

	if (!desk.sel.numobs && !tb.topwin) {
		mybeep();
		return;
	}

	p = desk.dicon + OBCLIP;
	strcpy(outname, p->spec.clip->path);
	strcat(outname, "SCRAP.TXT");
	graf_mouse(BUSYBEE, 0L);
	scrap_clear();
	fh = Fcreate(outname, 0);
	strcpy(outname, p->spec.clip->path);
	strcat(outname, "SCRAP.TNG");
	fh2 = Fcreate(outname, 0);
	if ((fh < 0L) || (fh2 < 0L)) {
		graf_mouse(ARROW, 0L);
		err_file(rs_frstr[ALFLCREATE], fh, outname);
		if (fh >= 0)
			Fclose((short) fh);
		if (fh2 >= 0)
			Fclose((short) fh2);
		scrap_clear();
		clip_update();
		return;
	}

	if (desk.sel.numobs) {
		/* Selektierte Objekte? */
		if (desk.sel.win) {
			switch (desk.sel.win->class) {
			case WCPATH:
				files = 1;
				strcpy(tmp, "TNGC");
				Fwrite((short)fh2, strlen(tmp), tmp);
				wpath = (W_PATH *)desk.sel.win->user;
				sprintf(tmp,"%s\r\n\r\n" ,wpath->path);
				Fwrite((short)fh, strlen(tmp), tmp);
				for (i = 0; i < wpath->e_total; i++) {
					item = wpath->lptr[i];
					if (item->sel) {
						files = 2;
						strcpy(tmp, "  ");
						strcpy(tmp, item->name);
						if (item->class == EC_FOLDER)
							strcat(tmp, "\\");
						strcat(tmp, "\r\n");
						Fwrite((short)fh, strlen(tmp), tmp);
						if (first)
							first = 0;
						else
							Fwrite((short)fh2, 1L, " ");
						strcpy(tmp, wpath->path);
						strcat(tmp, item->name);
						if (item->class == EC_FOLDER)
							strcat(tmp, "\\");
						quote(tmp);
						Fwrite((short)fh2, strlen(tmp), tmp);
					}
				}
				Fwrite((short)fh2, 1L, "");
				break;
			}
		}
	}
	else {
		/* Noe - dann evtl. Fensterinhalt */
		if (tb.topwin) {
			switch (tb.topwin->class) {
			case WCCON:
				files = 1;
				/* Benutzten Bereich ermitteln */
				cbuf = con.buf;
				l1 = con.line + con.hist - 1;
				l2 = 0;
				i = 0;
				for (i = 0; i < con.line + con.hist; i++) {
					j = con.col;
					while ((cbuf[j] == 0 || cbuf[j] == 32) && j > 0)
						j--;
					if (j > 0 || cbuf[0] != 32) {
						if (i < l1)
							l1 = i;
						l2 = i;
					}
					cbuf += (long)(con.col + 1);
				}
				/* Und ausgeben */
				cbuf = con.buf + (long)l1 * (long)(con.col + 1);
				for (l = l1; l <= l2; l++) {
					/* Zeilenende ermitteln */
					j = con.col;
					while ((cbuf[j] == 0 || cbuf[j] == 32) && j > 0)
						j--;
					if (cbuf[j] != 0 && cbuf[j] != 32 && j < con.col)
						j++;

					/* Zeile erzeugen und schreiben */
					i = 0;
					while (i < j) {
						tmp[i] = cbuf[i];
						i++;
					}
					tmp[i] = 13;
					tmp[i + 1] = 10;
					tmp[i + 2] = 0;
					Fwrite((short)fh, i + 2, tmp);
					/* Naechste Zeile */
					cbuf += (long)(con.col + 1);
				}
				break;
			case WCPATH:
				files = 1;
				wpath = (W_PATH *)tb.topwin->user;
				sprintf(tmp, "%s\r\n\r\n", wpath->path);
				Fwrite((short)fh, strlen(tmp), tmp);
				for (i = 0; i < wpath->e_total; i++) {
					item = wpath->lptr[i];
					strcpy(tmp,"  ");
					strcpy(tmp, item->name);
					if (item->class == EC_FOLDER)
						strcat(tmp, "\\");
					strcat(tmp, "\r\n");
					Fwrite((short)fh, strlen(tmp), tmp);
				}
				break;
			}
		}
	}
	Fclose((short)fh);
	Fclose((short)fh2);
	switch (files) {
	case 0:
		mybeep();
		scrap_clear();
		break;
	case 1:
		Fdelete(outname);
		break;
	}
	clip_update();
	graf_mouse(ARROW, 0L);
}

/**-------------------------------------------------------------------------
 dl_cutwin()

 Inhalt der aktuellen Auswahl auf die Ablage
 -------------------------------------------------------------------------*/
void dl_cutwin(void) {
	char tmp[514], outname[MAX_PLEN];
	short i;
	W_PATH *wpath;
	WP_ENTRY *item;
	long fh, fh2;
	short files = 0, first = 1;
	ICONDESK *p;

	if (!desk.sel.numobs) {
		mybeep();
		return;
	}

	p = desk.dicon + OBCLIP;
	strcpy(outname, p->spec.clip->path);
	strcat(outname, "SCRAP.TXT");
	graf_mouse(BUSYBEE, 0L);
	scrap_clear();
	fh = Fcreate(outname, 0);
	strcpy(outname, p->spec.clip->path);
	strcat(outname, "SCRAP.TNG");
	fh2 = Fcreate(outname, 0);
	if ((fh < 0L) || (fh2 < 0L)) {
		graf_mouse(ARROW, 0L);
		err_file(rs_frstr[ALFLCREATE], fh, outname);
		if (fh >= 0)
			Fclose((short) fh);
		if (fh2 >= 0)
			Fclose((short) fh2);
		scrap_clear();
		clip_update();
		return;
	}

	if (desk.sel.numobs) {
		/* Selektierte Objekte? */
		if (desk.sel.win) {
			switch (desk.sel.win->class) {
				case WCPATH:
				strcpy(tmp, "TNGX");
				Fwrite((short)fh2, strlen(tmp), tmp);
				wpath=(W_PATH *)desk.sel.win->user;
				sprintf(tmp,"%s\r\n\r\n",wpath->path);
				Fwrite((short)fh,strlen(tmp),tmp);
				for (i = 0; i < wpath->e_total; i++) {
					item = wpath->lptr[i];
					if (item->sel) {
						files = 2;
						strcpy(tmp,"  ");strcpy(tmp,item->name);
						if (item->class == EC_FOLDER)
							strcat(tmp, "\\");
						strcat(tmp, "\r\n");
						Fwrite((short)fh, strlen(tmp), tmp);
						if (first)
							first = 0;
						else
							Fwrite((short)fh2, 1L, " ");
						strcpy(tmp, wpath->path);
						strcat(tmp, item->name);
						if (item->class == EC_FOLDER)
							strcat(tmp, "\\");
						quote(tmp);
						Fwrite((short)fh2, strlen(tmp), tmp);
					}
				}
				Fwrite((short)fh2, 1L, "");
				break;
			}
		}
	}
	Fclose((short)fh);
	Fclose((short)fh2);
	if (!files) {
		mybeep();
		scrap_clear();
	}
	clip_update();
	graf_mouse(ARROW, 0L);
}

/**
 * dl_pastewin
 *
 * Fuegt den Inhalt des Clipboards in das aktuelle Verzeichnisfenster
 * ein (ruft also dl_copy mit den passenden Parametern auf).
 */
void dl_pastewin(void) {
	char inname[MAX_PLEN];
	char *copybuf;
	W_PATH *wpath;
	long fh, magic;
	ICONDESK *p;

	if (!tb.topwin || (tb.topwin->class != WCPATH)) {
		mybeep();
		return;
	}
	wpath = (W_PATH *) tb.topwin->user;

	p = desk.dicon + OBCLIP;
	strcpy(inname, p->spec.clip->path);
	strcat(inname, "SCRAP.TNG");
	graf_mouse(BUSYBEE, 0L);
	fh = Fopen(inname, 0);
	if (fh < 0L) {
		graf_mouse(ARROW, 0L);
		if (fh == -33L)
			mybeep();
		else
			err_file(rs_frstr[ALFLOPEN], fh, inname);
		return;
	}

	magic = 0L;
	Fread((short) fh, 4L, &magic);
	if ((magic != 'TNGC') && (magic != 'TNGX')) {
		mybeep();
		dlp_exit: Fclose((short) fh);
		graf_mouse(ARROW, 0L);
		return;
	}

	copybuf = pmalloc(MAX_AVLEN);
	if (!copybuf) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		goto dlp_exit;
	}

	Fread((short) fh, MAX_AVLEN, copybuf);
	Fclose((short) fh);
	graf_mouse(ARROW, 0L);

	dl_copy(wpath->path, (magic == 'TNGX') ? K_CTRL : 0, copybuf);
	pfree(copybuf);
}

/**-------------------------------------------------------------------------
 dl_dupwin()

 Aktives Verzeichnisfenster duplizieren
 -------------------------------------------------------------------------*/
void dl_dupwin(void) {
	W_PATH *wpath;

	if (!tb.topwin)
		return;
	if (tb.topwin->class!=WCPATH)
		return;

	wpath = (W_PATH *) tb.topwin->user;
	wpath_open(wpath->path, wpath->index.wildcard, wpath->rel, wpath->relname, wpath->index.text, -1, wpath->index.sortby);
}

/**-------------------------------------------------------------------------
 dl_appl_list()

 Auswahlliste fuer Dialog 'Applikationen' erzeugen
 -------------------------------------------------------------------------*/
short dl_appl_list(void) {
	short i, j;
	char scut[4];
	char *filelist, dummy[12];

	aplist.list = 0L;
	aplist.ltext = 0L;
	aplist.appllist = app_list(&aplist.num); /* Liste der Applikationen holen */
	if (aplist.num == -1)
		return 0;
	if (aplist.num == 0)
		return 1;
	/* Textliste erzeugen */
	aplist.list = pmalloc(sizeof(char *) * (long) aplist.num);
	if (!aplist.list) {
		pfree(aplist.appllist);
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return 0;
	}
	aplist.ltext = pmalloc(sizeof(char) * 49L * (long) aplist.num);
	if (!aplist.ltext) {
		pfree(aplist.list);
		pfree(aplist.appllist);
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return 0;
	}
	for (i = 0; i < aplist.num; i++) {
		aplist.list[i] = &aplist.ltext[i * 49];
		if ((short) strlen(aplist.appllist[i]->title) < 13) {
			sprintf(aplist.list[i], "%-12s ", aplist.appllist[i]->title);
		} else {
			strncpy(aplist.list[i], aplist.appllist[i]->title, 12L);
			aplist.list[i][12] = ' ';
			aplist.list[i][13] = 0;
		}
		strcpy(scut, "   ");
		if (aplist.appllist[i]->shortcut) {
			scut[0] = '\7';
			scut[1] = '0' + aplist.appllist[i]->shortcut;
		}
		strcat(aplist.list[i], scut);
		for (j = 0; j < 2; j++) {
			if (j == 0)
				filelist = aplist.appllist[i]->fileopen;
			else
				filelist = aplist.appllist[i]->fileview;
			if (strlen(filelist) > 15L) {
				strncpy(dummy, filelist, 12L);
				dummy[12] = 0;
				strcat(dummy, "...  ");
			} else
				sprintf(dummy, "%-15s  ", filelist);
			if (j == 1)
				dummy[15] = 0;
			strcat(aplist.list[i], dummy);
		}
	}
	return 1;
}

/**-------------------------------------------------------------------------
 dl_appl_update()

 Auswahlliste im Dialog 'Applikationen' aktualisieren
 -------------------------------------------------------------------------*/
short dl_appl_update(short cont, APPLINFO *appl) {
	short i;

	if (aplist.ltext)
		pfree(aplist.ltext);
	if (aplist.list)
		pfree(aplist.list);
	if (aplist.appllist)
		pfree(aplist.appllist);

	if (!dl_appl_list())
		return 0;

	li_defappl.num = aplist.num;
	li_defappl.text = aplist.list;
	/* Aktuelle Auswahl aktualisieren */
	if (cont == 3) {
		/* Applikation wurde geloescht */
		li_defappl.sel = -1;
		if (li_defappl.num < li_defappl.view)
			li_defappl.offset = 0;
		else {
			if (li_defappl.offset > li_defappl.num - li_defappl.view)
				li_defappl.offset = li_defappl.num - li_defappl.view;
		}
	} else {
		/* Applikation wurde geaendert */
		for (i = 0; i < aplist.num; i++) {
			if (appl == aplist.appllist[i])
				li_defappl.sel = i;
		}
		if (li_defappl.sel < li_defappl.offset)
			li_defappl.offset = li_defappl.sel;
		else {
			if (li_defappl.sel >= li_defappl.offset + li_defappl.view)
				li_defappl.offset = li_defappl.sel - li_defappl.view + 1;
		}
	}
	lst_init(&li_defappl, 1, 1, 1, 1);
	return 1;
}

/**-------------------------------------------------------------------------
 di_appl()

 Dialog-Init 'Applikationen'
 -------------------------------------------------------------------------*/
void di_appl(void) {
	if (fi_defappl.open) {
		mybeep();
		frm_restore(&fi_defappl);
		return;
	}

	if (!dl_appl_list())
		return;
	li_defappl.num = aplist.num;
	li_defappl.sel = -1;
	li_defappl.offset = 0;
	li_defappl.text = aplist.list;

	rs_trindex[DEFAPPL][DALOCATE].ob_spec.tedinfo->te_ptext[0] = 0;
	rs_trindex[DEFAPPL][DAEDIT].ob_state |= DISABLED;
	rs_trindex[DEFAPPL][DADELETE].ob_state |= DISABLED;
	lst_init(&li_defappl, 1, 1, 0, 0);
	frm_start(&fi_defappl, conf.wdial, conf.cdial, 0);
}

void de_appl(short mode, short ret) {
	short done, exit_obj;
	short dclick;
	short sel, csel, off, i, j;
	long l;
	char *loc, m1[MAX_FLEN], m2[MAX_FLEN];
	APPLINFO *appl;
	short dadelete, daedit;
	OBJECT *objectTree;

	objectTree = rs_trindex[DEFAPPL];

	loc = objectTree[DALOCATE].ob_spec.tedinfo->te_ptext;
	done = 0;
	if (!mode) {
		exit_obj = fi_defappl.exit_obj;
		sel = li_defappl.sel;
		if (sel != -1)
			appl = aplist.appllist[sel];
		else
			appl = 0L;
		if (lst_handle(&li_defappl, ret, &dclick)) {
			if (dclick) {
				appl = aplist.appllist[li_defappl.sel];
				dl_dappinfo(appl, 1);
				if (fi_defappl.state != FST_WIN)
					frm_redraw(&fi_defappl, ROOT);
			}
		} else {
			switch (exit_obj) {
			case DAOK:
				done = DAOK;
				break;
			case DADELETE:
				sprintf(almsg, rs_frstr[ALAPPDEL], appl->title);
				if (frm_alert(1, almsg, altitle, conf.wdial, 0L) == 1) {
					/* Falls Applikations-Info auf ist, dann ggf. schliežen */
					if (fi_dappinfo.open) {
						if (dapp->appl == appl)
							fi_dappinfo.exit(1, 0);
					}
					app_remove(appl);
					appl = 0L;
					if (!dl_appl_update(3, appl))
						done = DAOK;
				}
				fi_defappl.exit_obj = exit_obj;
				frm_norm(&fi_defappl);
				break;
			case DANEW:
				appl = app_add();
				if (appl) {
					appl->name[0] = 0;
					app_default(appl);
					dl_dappinfo(appl, 2);
					if (fi_defappl.state != FST_WIN)
						frm_redraw(&fi_defappl, ROOT);
				}
				fi_defappl.exit_obj = exit_obj;
				frm_norm(&fi_defappl);
				break;
			case DAEDIT:
				dl_dappinfo(appl, 1);
				if (fi_defappl.state != FST_WIN)
					frm_redraw(&fi_defappl, ROOT);
				fi_defappl.exit_obj = exit_obj;
				frm_norm(&fi_defappl);
				break;
			case DALOCATE:
				off = li_defappl.offset;
				csel = -1;
				l = (short) strlen(loc);
				for (i = 0; i < l; i++)
					m1[i] = nkc_toupper(loc[i]);
				m1[i] = 0;
				for (i = 0; i < li_defappl.num && csel == -1; i++) {
					for (j = 0; j < l; j++)
						m2[j] = nkc_toupper(aplist.appllist[i]->title[j]);
					m2[j] = 0;
					if (!strcmp(m1, m2))
						csel = i;
				}
				if (csel != li_defappl.sel && csel != -1) {
					sel = csel;
					if (csel < off)
						off = csel;
					if (csel >= off + li_defappl.view)
						off = csel - li_mask.view + 1;
					if (off != li_defappl.offset) {
						li_defappl.sel = csel;
						li_defappl.offset = off;
						lst_init(&li_defappl, 1, 1, 1, 1);
					} else {
						if (fi_defappl.state == FST_WIN) {
							wind_update( BEG_UPDATE);
							wind_update( BEG_MCTRL);
						}
						lst_select(&li_defappl, csel);
						if (fi_defappl.state == FST_WIN) {
							wind_update( END_UPDATE);
							wind_update( END_MCTRL);
						}
					}
					objectTree[DAEDIT].ob_state &= ~DISABLED;
					frm_redraw(&fi_defappl, DAEDIT);
					if (aplist.appllist[li_defappl.sel] == &defappl)
						objectTree[DADELETE].ob_state |= DISABLED;
					else
						objectTree[DADELETE].ob_state &= ~DISABLED;
					frm_redraw(&fi_defappl, DADELETE);
				}
				break;
			}
		}

		dadelete = objectTree[DADELETE].ob_state;
		daedit = objectTree[DAEDIT].ob_state;
		/* "Loeschen"-Button deaktivieren, falls keine Auswahl
		 und Auto-Locator aktualisieren */
		if (sel != li_defappl.sel && !done) {
			obj_edit(fi_defappl.tree, fi_defappl.edit_obj, 0, 0,
					&fi_defappl.edit_idx, ED_END, fi_defappl.win.handle);
			if (li_defappl.sel == -1)
				loc[0] = 0;
			else
				strcpy(loc, aplist.appllist[li_defappl.sel]->title);
			fi_defappl.edit_idx = -1;
			obj_edit(fi_defappl.tree, fi_defappl.edit_obj, 0, 0,
					&fi_defappl.edit_idx, ED_INIT, fi_defappl.win.handle);
			frm_redraw(&fi_defappl, DALOCATE);

#if 0
			if((sel==-1 && li_defappl.sel!=-1) || (sel!=1 && li_defappl.sel==-1))
			{
#endif
			if (li_defappl.sel == -1) {
				daedit |= DISABLED;
				dadelete |= DISABLED;
			} else {
				daedit &= ~DISABLED;
				dadelete &= ~DISABLED;
			}
#if 0
		}
#endif
		}
		/* Default-Applikation kann nicht geloescht werden */
		if (li_defappl.sel != -1) {
			if (aplist.appllist[li_defappl.sel] == &defappl) {
				dadelete |= DISABLED;
			} else
				dadelete &= ~DISABLED;
		}
		if (dadelete != objectTree[DADELETE].ob_state) {
			objectTree[DADELETE].ob_state = dadelete;
			frm_redraw(&fi_defappl, DADELETE);
		}
		if (daedit != objectTree[DAEDIT].ob_state) {
			objectTree[DAEDIT].ob_state = daedit;
			frm_redraw(&fi_defappl, DAEDIT);
		}
	} else
		done = DAOK;

	if (done) {
		frm_end(&fi_defappl);
		if (aplist.ltext)
			pfree(aplist.ltext);
		if (aplist.list)
			pfree(aplist.list);
		if (aplist.appllist)
			pfree(aplist.appllist);
	}
}

/**-------------------------------------------------------------------------
 dl_appl()

 Angemeldete Applikationen bearbeiten -
 Entweder alle Applikationen oder nur das selektierte Programm
 -------------------------------------------------------------------------*/
void dl_appl(void) {
	APPLINFO *appl;
	short i, n, doup, sel;
	char *ptitle;
	W_PATH *wpath;
	WP_ENTRY *item;
	W_GRP *wgrp;
	WG_ENTRY *gitem;
	char name[MAX_PLEN];
	char title[MAX_FLEN];
	ICONDESK *p;

	appl = 0L;
	n = -1;
	item = 0L;
	doup = 0;
	sel = 1;

	/* Einzelne Datei selektiert ? */
	if (desk.sel.files == 1 && !desk.sel.folders && !desk.sel.trash
			&& !desk.sel.clip && !desk.sel.drives) {
		if (desk.sel.desk) /* Objekte auf dem Desktop  */
		{
			p = desk.dicon + 1;
			for (i = 1; i <= MAXICON; i++, p++)
				if (p->class==IDFILE && p->select) {
#if 0
					if(is_app(p->spec.file->name,p->spec.file->mode))
#endif
					{
						strcpy(name, p->spec.file->name);
						ptitle = p->title;
						if (!ptitle[0])
							ptitle = 0L;
						n = i;
					}
				}
		} else /* Objekte in einem Fenster */
		{
			if (desk.sel.win) {
				switch (desk.sel.win->class)
				{
					case WCPATH:
					wpath=(W_PATH *)desk.sel.win->user;
					for(i=0;i<wpath->e_total;i++)
					{
						item=wpath->lptr[i];
						if(item->sel && item->class==EC_FILE)
						{
#if 0
							if(item->aptype)
#endif
							{
								strcpy(name,wpath->path);
								strcat(name,item->name);
								ptitle=0L;
								n=0; /* Objekt vorhanden, aber Kein Desktop-Icon */
							}
						}
					}
					break;
				case WCGROUP:
					wgrp = (W_GRP *)desk.sel.win->user;
					gitem = wgrp->entry;
					while(gitem && n==-1) {
						if(gitem->sel && gitem->class==EC_FILE)
						{
#if 0
							if(gitem->aptype)
#endif
							{
								wgrp_eabs(wgrp,gitem,name);
								ptitle=gitem->title;
								n=0;
							}
						}
						gitem=gitem->next;
					}
					break;
				}
			}
		}
	}

	/* Icon selektiert ? */
	if (n != -1) {
		/* Applikations-Dialog verfuegbar? */
		if (fi_dappinfo.open) /* Nee - dann toppen */
		{
			mybeep();
			frm_restore(&fi_dappinfo);
			doup = 1;
		}
		else /* Ok */
		{
			appl = app_find(name);
			if (appl) /* Angemeldet - dann bearbeiten */
			{
				dl_dappinfo(appl, 1);
				doup = 1;
			}
			else
			{
				/* Icon-Titel verwenden oder Dateinamen, falls kein Titel angegeben */
				if (!ptitle) {
					ptitle = strrchr(name, '\\');
					ptitle = &ptitle[1];
				}

				strcpy(title, ptitle);
				sprintf(almsg, rs_frstr[ALAPPNEW], title);
				sel = frm_alert(1, almsg, altitle, conf.wdial, 0L);
				if (sel == 1) {
					appl = app_add();
					if (!appl)
						frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
					else {
						strcpy(appl->name, name);
						app_default(appl);
						strcpy(appl->title, title);
						dl_dappinfo(appl, 2);
						doup = 1;
					}
				}
			}
		}
	}

	/* Falls bei der Nachfrage nach Anmelden 'Abbruch' dann raus */
	if (sel == 3)
		return;

	/* Kein einzelnes Programm - dann alle Applikationen bearbeiten */
	if (!doup)
		fi_defappl.init();
}

/**-------------------------------------------------------------------------
 dl_iconedit()
 
 Icons bearbeiten (Iconeditor starten)
 -------------------------------------------------------------------------*/
void dl_iconedit(void) {
	short rex;
	APPLINFO app, *aptr;
	FILESYS fs;
	char parm[126];

	strcpy(app.name, tb.homepath);
	strcat(app.name, "thingicn.app");
	fsinfo(app.name, &fs);
	fsconv(app.name, &fs);
	aptr = app_find(app.name);
	if (!aptr) {
		app_default(&app);
		strcpy(app.title, "ThingIcn");
		aptr = &app;
	}
	sprintf(parm, "-d%d -v%d -s%d -r%d -w%d -a%d "
		"-f%04d%04d%04d%04d%04d%04d -i%d", !!tb.use3d, _VERS, conf.scroll,
			!!conf.rdouble, !!tb.backwin, !!conf.autoplace, tb.fupper,
			tb.flower, tb.fleft, tb.fright, tb.fhor, tb.fvert, conf.interactive);

	app_start(aptr, parm, 0L, &rex);
}

/**-------------------------------------------------------------------------
 dl_iconload()

 Icons neu laden
 -------------------------------------------------------------------------*/
void dl_iconload(void) {
	char rname[MAX_PLEN];
	WININFO *win;

	if (frm_alert(1, rs_frstr[ALLOADICON], altitle, conf.wdial, 0L) == 1) {
		graf_mouse(BUSYBEE, 0L);
		/* Bisher selektierte Icons deselektieren */
		icon_select(-1, 0, 0);
		win = tb.win;
		while (win) {
			switch (win->class) {
				case WCPATH:
					((W_PATH *)(win->user))->amask[0] = 0;
					wpath_esel(win, 0L, 0, 0, 1);
					break;
				case WCGROUP:
					break;
			}
			win = win->next;
		}
		/* Bisherige Icons entfernen */
		if (desk.icon) {
			Mfree(desk.icon);
			desk.icon = 0L;
			desk.maxicon = 0;
		}
		rsc_free(&glob.rinfo);
		/* Icon-Resource laden */
		strcpy(rname, tb.homepath);
		strcat(rname, FNAME_RSC);
		if (!rsc_load(rname, &glob.rinfo)) {
			/* Ganz uebel ... das darf eigentlich nie passieren ... */
			graf_mouse(ARROW, 0L);
			frm_alert(1,rs_frstr[ALNORSC], altitle, conf.wdial, 0L);
			main_exit();
			Pterm0();
		}
		rsc_gaddr(R_TREE, 0, &glob.rtree, &glob.rinfo);
		rs_fix(glob.rtree, rcw, rch);
		if (rsc_gaddr(R_TREE, 1, &glob.srtree, &glob.rinfo) != 0) {
			rs_fix(glob.srtree,rcw,rch);
		} else {
			/* frm_alert(1,rs_frstr[ALNOMINI],altitle,conf.wdial,0L); */
			glob.srtree = 0L;
			glob.sheight = 16;
		}

		conf_iload();
		/* Alles klar ... dann Update des Desktops und aller Fenster */
		icon_update(0);
		desk_draw(tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h);
		graf_mouse(ARROW, 0L);
		win = tb.win;
		while (win) {
			switch (win->class) {
				case WCPATH:
					wpath_update(win);
					win_redraw(win, tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h);
					win_slide(win, S_INIT, 0, 0);
					break;
				case WCGROUP:
					wgrp_update(win);
					wgrp_tree(win);
					win_redraw(win, tb.desk.g_x, tb.desk.g_y, tb.desk.g_w, tb.desk.g_h);
					win_slide(win, S_INIT, 0, 0);
					break;
			}
			win = win->next;
		}
	}
}

/**------------------------------------------------------------------------
 dl_conwin()

 Console-Fenster oeffnen - entweder durch Menueauswahl oder beim
 Start von Thing
 -------------------------------------------------------------------------*/
void dl_conwin(void) {
	short cret;

	cret = cwin_open();
	switch (cret) {
	case 0:
		frm_alert(1, rs_frstr[ALCONERR], altitle, conf.wdial, 0L);
		break;
	case -1:
		frm_alert(1, rs_frstr[ALNOTOS2GEM], altitle, conf.wdial, 0L);
		break;
	}
}

/**-------------------------------------------------------------------------
 dl_savegrp()
 
 Aktuelle Gruppe sichern
 -------------------------------------------------------------------------*/
void dl_savegrp(void) {
	WININFO *win;
	W_GRP *wgrp;
	WG_ENTRY *gitem;
	FILE *fh;
	short x, y, w, h;
	double lx, ly, lw, lh;
	char temp[MAX_PLEN];

	win = tb.topwin;

	graf_mouse(BUSYBEE, 0L);
	wgrp = (W_GRP *) win->user;
	fh = fopen(wgrp->name, "w");
	if (!fh) {
		sprintf(almsg, rs_frstr[ALSAVEGROUP], wgrp->title);
		graf_mouse(ARROW, 0L);
		frm_alert(1, almsg, altitle, conf.wdial, 0L);
		wgrp->autosave = 0;
	} else {
		file_header(fh, "Thing object group", wgrp->name);

		if (win->state & WSICON) {
			x = win->save.g_x;
			y = win->save.g_y;
			w = win->save.g_w;
			h = win->save.g_h;
		} else {
			x = win->curr.g_x;
			y = win->curr.g_y;
			w = win->curr.g_w;
			h = win->curr.g_h;
		}
		lx = (double) (x - tb.desk.g_x) * 10000L / (double) tb.desk.g_w;
		ly = (double) (y - tb.desk.g_y) * 10000L / (double) tb.desk.g_h;
		lw = (double) w * 10000L / (double) tb.desk.g_w;
		lh = (double) h * 10000L / (double) tb.desk.g_h;
		fprintf(fh, "INFO ");
		put_text(fh, wgrp->title);
		fprintf(fh, " %d %d %d %d %d %d\n", (short) lx, (short) ly, (short) lw, (short) lh, wgrp->text, wgrp->autosave);
		fprintf(fh, "IGTA %d\n", wgrp->getattr);
		fprintf(fh, "IACL %d\n", wgrp->autoclose);
		if (*wgrp->parent)
			fprintf(fh, "PRNT %s\n", wgrp->parent);
		fprintf(fh, "FONT %d %d %d %d\n", wgrp->font.id, wgrp->font.size, wgrp->fcol16, wgrp->bcol16);
		fprintf(fh, "FCOL %d %d\n", wgrp->fcol, wgrp->bcol);
		fprintf(fh, "BPAT %d %d\n", wgrp->bpat, wgrp->bpat16);
		if (wgrp->img_ok) {
			fprintf(fh, "BPIC ");
			strcpy(temp, wgrp->img);
			quote(temp);
			fprintf(fh, "%s %d\n", temp, wgrp->img_planes);
		}

		gitem = wgrp->entry;
		while (gitem) {
			switch (gitem->class) {
				case EC_FILE:
					fprintf(fh,"OFIL ");
					break;
				case EC_FOLDER:
					fprintf(fh,"OFLD ");
					break;
			}
			put_text(fh, gitem->title);
			strcpy(temp, gitem->name);
			quote(temp);
			fprintf(fh," %s ", temp);
			put_text(fh, gitem->parm);
			fprintf(fh,"\n");
			fprintf(fh, "OOPT %d 0 0 0 0 0 0 0 0 0\n", gitem->paralways);

			gitem = gitem->next;
		}
		fclose(fh);
		graf_mouse(ARROW, 0L);
		wgrp->changed = 0;
		wgrp_title(win);
		read_sendto();
	}
}

/**
 * get_xxmaster
 *
 * Ermittelt, ob eine bestimmte Environmentvariable einen absoluten
 * Programmpfad mit Laufwerksangabe enthaelt und wechselt im
 * Erfolgsfall in dessen Verzeichnis und liefert einen Zeiger auf den
 * Pfad zurueck.
 *
 * Eingabe:
 * which: Zeiger auf die zu testende Environment-Variable; fuer Thing
 *        entweder "SDMASTER" oder "RSMASTER"
 *
 * Rueckgabe:
 * 0L: Environmentvariable existiert nicht oder enthaelt ungueltigen
 *     Pfad; Things Homeverzeichnis ist das aktuelle Verzeichnis
 * sonst: Zeiger auf den enthaltenen Programmpfad, dessen Verzeichnis
 *        jetzt das aktuelle ist
 */
static char *get_xxmaster(char *which) {
	char *p, *d;
	short ok = 0;

	clr_drv();
	p = getenv(which);
	if (p) {
		if (strlen(p) >= 3) {
			if ((p[1] == ':') && (p[2] == '\\')) {
				*(d = strrchr(p, '\\')) = 0;
				Dsetdrv((p[0] & ~32) - 'A');
				if (!Dsetpath(p[2] ? &p[2] : "\\"))
					ok = 1;
				else
					clr_drv();
				*d = '\\';
			}
		}
	}
	if (!ok)
		p = 0L;
	return (p);
}

/**
 * dl_changeres
 *
 * Aufloesung wechseln unter MagiC 4
 */
void dl_changeres(void) {
	char sname[MAX_PLEN], *p, *args;

	strcpy(sname, tb.homepath);
	strcat(sname, "chgres.prg");
	if ((p = get_xxmaster("RSMASTER")) == 0L)
		p = sname;
	if (!file_exists(p, 1, 0L)) {
		if ((args = getenv("RSMASTER_ARGS")) == NULL)
			args = "";
		shel_write(1, 1, SHW_SINGLE, p, args);
		shel_write(1, 1, SHW_CHAIN, p, args);
		glob.done = 2;
	} else {
		sprintf(almsg, rs_frstr[ALMISS], "CHGRES.PRG", "$RSMASTER");
		frm_alert(1, almsg, altitle, conf.wdial, 0L);
	}
}

/**
 * dl_changeres_nomagic
 *
 * Aufloesung wechseln ohne MagiC oder als Nicht-Shell
 */
void dl_changeres_nomagic(void) {
	char *p, *args, sname[MAX_PLEN];
	XATTR xattr;
	short atype, is_gr;

	if (((p = get_xxmaster("RSMASTER")) != 0L) && !file_exists(p, 1, &xattr)) {
		if ((args = getenv("RSMASTER_ARGS")) == NULL)
			args = "";
		strcpy(sname, p);
		if (tb.sys & SY_MULTI) {
			strcpy(aesbuf, sname);
			quote( aesbuf);
			strcat(aesbuf, args);
			va_open(aesbuf);
		} else {
			atype = is_app(sname, xattr.mode);
			if ((atype == 2) || (atype == 3))
				is_gr = 0;
			else
				is_gr = 1;
			shel_write(1, is_gr, 0, sname, args);
			glob.done = 2;
		}
	} else {
		sprintf(almsg, rs_frstr[ALMISS], "CHGRES.PRG", "$RSMASTER");
		frm_alert(1, almsg, altitle, conf.wdial, 0L);
	}
}

/**-------------------------------------------------------------------------
 dl_shutdown()
 
 Shutdown-Programm unter MagiC 3 starten
 -------------------------------------------------------------------------*/
void dl_shutdown(void) {
	char sname[MAX_PLEN], *p;

	strcpy(sname, tb.homepath);
	strcat(sname, "shutdown.prg");
	if ((p = get_xxmaster("SDMASTER")) == 0L)
		p = sname;
	if (!file_exists(p, 1, 0L)) {
		shel_write(1, 1, SHW_SINGLE, p, "\4-1 0");
		shel_write(1, 1, SHW_CHAIN, p, "\4-1 0");
		glob.done = 2;
	} else {
		aesmsg[0] = AP_TFAIL;
		aesmsg[1] = 1;
		aesmsg[2] = 0;
		aesmsg[3] = 0;
		aesmsg[4] = 0;
		aesmsg[5] = 0;
		aesmsg[6] = 0;
		aesmsg[7] = 0;
		shel_write(SHW_AESSEND, 0, 0, (char *) aesmsg, 0L);
		sprintf(almsg, rs_frstr[ALMISS], "SHUTDOWN.PRG", "$SDMASTER");
		frm_alert(1, almsg, altitle, conf.wdial, 0L);
	}
}

/**-------------------------------------------------------------------------
 Thing beenden bzw. Shutdown (je nach Umgebung)
 -------------------------------------------------------------------------*/
void dl_quit(void) {
	if ((tb.sys & SY_MSHELL) && (tb.sys & SY_SHUT)) {
		/* Shutdown */
		if (frm_alert(1, rs_frstr[ALSHUT], altitle, conf.wdial, 0L) == 1)
			dl_shutdown();
	} else {
		/* Nur beenden */
		if (frm_alert(1, rs_frstr[ALQUIT], altitle, conf.wdial, 0L) == 1)
			glob.done = 2;
	}
}

/**
 * dl_saveindex
 *
 * Aktuelle Darstellung (Text/Miniicons/Icons), Sortierung und Maske
 * eines Verzeichnisfensters als thing.idx im betroffenen Verzeichnis
 * sichern.
 */
void dl_saveindex(void) {
	char full[MAX_PLEN];
	W_PATH *wpath;
	FILE *handle;

	if (!tb.topwin || (tb.topwin->class != WCPATH)) {
		mybeep();
		return;
	}
	strcpy(full, (wpath = (W_PATH *) tb.topwin->user)->path);
	strcat(full, FNAME_IDX);
	if ((handle = fopen(full, "w")) == NULL) {
		sprintf(almsg, rs_frstr[ALFLCREATE], FNAME_IDX);
		frm_alert(1, almsg, altitle, conf.wdial, 0L);
		return;
	}
	file_header(handle, "Thing directory information", FNAME_IDX);
	fprintf(handle, "IDEX %d %d\n", wpath->index.text, wpath->index.sortby);
	strcpy(full, wpath->index.wildcard);
	quote(full);
	fprintf(handle, "MASK %s\n", full);
	fclose(handle);
	wpath_update(tb.topwin);
	w_draw(tb.topwin);
}

/**
 * dl_hotkeys_list
 *
 * Baut die Liste fuer den Hotkey-Dialog auf.
 *
 * Eingabe:
 * init: Abschliežend lst_init aufrufen (1) oder nicht (0)?
 *
 * Rueckgabe:
 * 0: Fehler (kein Speicher), wurde gemeldet
 * sonst: Alles klar
 */
static short dl_hotkeys_list(short init) {
	HOTKEY *hk;
	char *p, hlp[46];
	short num, i;

	if (li_hotkeys.text != NULL)
		pfree(li_hotkeys.text);
	num = 0;
	for (hk = glob.hotkeys; hk != NULL; hk = hk->next)
		num++;
	li_hotkeys.num = num;
	li_hotkeys.sel = -1;
	li_hotkeys.offset = 0;
	if (num) {
		if ((li_hotkeys.text = pmalloc(num * (li_hotkeys.len + 1
				+ sizeof(char *)))) == NULL) {
			frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
			return (0);
		}
		p = (char *) &li_hotkeys.text[num];
		i = 0;
		for (hk = glob.hotkeys; hk != NULL; hk = hk->next) {
			li_hotkeys.text[i++] = p;
			strShortener(hlp, hk->object, 45);
			sprintf(p, "%c %-45s", hk->key, hlp);
			p += li_hotkeys.len + 1;
		}
		wl_qsort(li_hotkeys.text, 0, num - 1);
	} else
		li_hotkeys.text = NULL;
	if (init) {
		if (fi_hotkeys.open)
			lst_init(&li_hotkeys, 1, 1, 1, 1);
		else
			lst_init(&li_hotkeys, 1, 1, 0, 0);
	}
	return (1);
}

/**
 * di_hotkeys
 *
 * Oeffnungsvorbereitungen fuer den Hotkey-Dialog.
 */
void di_hotkeys(void) {
	OBJECT *tree = fi_hotkeys.tree;

	li_hotkeys.text = NULL;
	li_hotkeys.sel = -1;
	if (!dl_hotkeys_list(1))
		return;
	strcpy(tree[HKLOCATE].ob_spec.tedinfo->te_ptext, "");
	tree[HKDELETE].ob_state |= DISABLED;
	tree[HKCHANGE].ob_state |= DISABLED;
	frm_start(&fi_hotkeys, conf.wdial, conf.cdial, 0);
}

/**
 * de_hotkeys
 *
 * Benutzeraktionen im Hotkey-Dialog verarbeiten.
 *
 * Eingabe:
 * mode: 0 - Benutzeraktion im Dialog, 1 - Dialog schliežen
 * ret: Returncode von frm_do (nur bei mode == 0)
 */
void de_hotkeys(short mode, short ret) {
	short exit_obj, done = 0, key, sel, off, rd, i, d;
	OBJECT *tree = fi_hotkeys.tree;
	char *loc;
	HOTKEY *hk, *p;

	loc = tree[HKLOCATE].ob_spec.tedinfo->te_ptext;
	if (!mode) {
		sel = li_hotkeys.sel;
		if (sel >= 0)
			hk = get_hotkey(li_hotkeys.text[sel][0]);
		else
			hk = NULL;

		if (!lst_handle(&li_hotkeys, ret, &d)) {
			exit_obj = fi_hotkeys.exit_obj;
			switch (exit_obj) {
			case HKLOCATE:
				for (i = 0; i < li_hotkeys.num; i++) {
					if (li_hotkeys.text[i][0] == *loc)
						break;
				}
				if (i != li_hotkeys.num)
					li_hotkeys.sel = i;
				else
					li_hotkeys.sel = -1;
				if (sel != li_hotkeys.sel)
					lst_init(&li_hotkeys, 1, 1, 1, 1);
				break;
			case HKCLOSE:
				done = HKCLOSE;
				break;
			case HKDELETE:
				if (hk->prev)
					hk->prev->next = hk->next;
				else
					glob.hotkeys = hk->next;
				if (hk->next)
					hk->next->prev = hk->prev;
				pfree(hk);
				done = !dl_hotkeys_list(1);
				sel = li_hotkeys.num;
				frm_norm(&fi_hotkeys);
				break;
			case HKCHANGE:
				key = get_new_hotkey(hk);
				if (fi_hotkeys.state != FST_WIN)
					frm_redraw(&fi_hotkeys, ROOT);
				off = li_hotkeys.offset;
				if (key) {
					if (((p = get_hotkey(key)) != NULL) && (p != hk)) {
						if (p->prev)
							p->prev->next = p->next;
						else
							glob.hotkeys = p->next;
						if (p->next)
							p->next->prev = p->prev;
						pfree(p);
						off = 0;
						sel = -1;
					}
					hk->key = key;
					done = !dl_hotkeys_list(0);
					li_hotkeys.sel = sel;
					li_hotkeys.offset = off;
					lst_init(&li_hotkeys, 1, sel == -1, 1, sel == -1);
					sel = li_hotkeys.num;
				}
				frm_norm(&fi_hotkeys);
				break;
			case HKNEW:
				if ((hk = pmalloc(sizeof(HOTKEY))) == NULL)
					frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
				else {
					key = get_new_hotkey(NULL);
					if (fi_hotkeys.state != FST_WIN)
						frm_redraw(&fi_hotkeys, ROOT);
					if (key) {
						strcpy(hk->object, "");
						if (full_fselect(hk->object, NULL, "*.*", 0, rs_frstr[TXOBJSEARCH], 0, 0, &fi_hotkeys)) {
							if (((p = get_hotkey(key)) != NULL)) {
								if (p->prev)
									p->prev->next = p->next;
								else
									glob.hotkeys = p->next;
								if (p->next)
									p->next->prev = p->prev;
								pfree(p);
							}
							hk->key = key;
							hk->prev = NULL;
							hk->next = glob.hotkeys;
							if (glob.hotkeys != NULL)
								glob.hotkeys->prev = hk;
							glob.hotkeys = hk;
							done = !dl_hotkeys_list(0);
							lst_init(&li_hotkeys, 1, 1, 1, 1);
							sel = li_hotkeys.num;
						} else
							pfree(hk);
					} else
						pfree(hk);
				}
				frm_norm(&fi_hotkeys);
				break;
			}
		}

		if (!done && (sel != li_hotkeys.sel)) {
			obj_edit(tree, fi_hotkeys.edit_obj, 0, 0, &fi_hotkeys.edit_idx, ED_END, fi_hotkeys.win.handle);
			if (li_hotkeys.sel >= 0)
				*loc = li_hotkeys.text[li_hotkeys.sel][0];
			fi_hotkeys.edit_idx = -1;
			obj_edit(tree, fi_hotkeys.edit_obj, 0, 0, &fi_hotkeys.edit_idx, ED_INIT, fi_hotkeys.win.handle);
			frm_redraw(&fi_hotkeys, HKLOCATE);

			rd = 0;
			if (sel == -1) {
				rd = 1;
				tree[HKDELETE].ob_state &= ~DISABLED;
				tree[HKCHANGE].ob_state &= ~DISABLED;
			} else if (li_hotkeys.sel == -1) {
				rd = 1;
				tree[HKDELETE].ob_state |= DISABLED;
				tree[HKCHANGE].ob_state |= DISABLED;
			}
			if (rd) {
				frm_redraw(&fi_hotkeys, HKDELETE);
				frm_redraw(&fi_hotkeys, HKCHANGE);
			}
		}
	} else
		done = HKCLOSE;

	if (done) {
		frm_end(&fi_hotkeys);
		if (li_hotkeys.text)
			pfree(li_hotkeys.text);
	}
}

/**
 * get_new_hotkey
 *
 * Liest einen neuen Hotkey per Tastatur ein.
 *
 * Eingabe:
 * hotkey: Zeiger auf aktuellen HOTKEY-Eintrag, falls vorhanden
 *         (sonst NULL)
 *
 * Rueckgabe:
 * 0: Auswahl abgebrochen
 * sonst: ASCII-Wert des gelesenen Hotkeys (ggf. wurde schon wegen
 *        bisheriger Belegung nachgefragt, aber noch nicht geloescht)
 */
short get_new_hotkey(HOTKEY *hotkey) {
	OBJECT *tree;
	HOTKEY *hk;
	char obj[46];
	short key;

	tree = rs_trindex[CHOOSEHOTKEY];
	tree_win(tree, 0);
	wind_update( BEG_UPDATE);
	wind_update( BEG_MCTRL);
	setBackgroundBorderLine(tree, 0, 1);
	form_center(tree, &tree->ob_x, &tree->ob_y, &tree->ob_width, &tree->ob_height);
	form_dial(FMD_START, tree->ob_x, tree->ob_y, tree->ob_width,
			tree->ob_height, tree->ob_x, tree->ob_y, tree->ob_width,
			tree->ob_height);
	objc_draw(tree, ROOT, MAX_DEPTH, tree->ob_x, tree->ob_y, tree->ob_width, tree->ob_height);
	for (;;) {
		key = evnt_keybd() & 0xff;
		if ((key == 27) || ((key > 32) && (key < 127)))
			break;
		mybeep();
	}
	form_dial(FMD_FINISH, tree->ob_x, tree->ob_y, tree->ob_width,
			tree->ob_height, tree->ob_x, tree->ob_y, tree->ob_width,
			tree->ob_height);
	wind_update( END_MCTRL);
	wind_update( END_UPDATE);
	if (key == 27)
		return (0);
	if (((hk = get_hotkey(key)) != NULL) && (hk != hotkey)) {
		strShortener(obj, hk->object, 45);
		sprintf(almsg, rs_frstr[ALHOTKEY], key, obj);
		if (frm_alert(1, almsg, altitle, conf.wdial, 0L) != 1)
			return (0);
	}
	return (key);
}

/**
 * dl_default
 *
 * Setzt die aktuelle Sortierung und Anzeigeart als Standard fuer neue
 * Fenster.
 */
void dl_default(void) {
	W_PATH *wpath;

	if (tb.topwin && (tb.topwin->class == WCPATH)) {
		wpath = (W_PATH *) tb.topwin->user;
		conf.index.sortby = wpath->index.sortby;
		conf.index.text = wpath->index.text;
	} else
		mybeep();
}

/* EOF */
