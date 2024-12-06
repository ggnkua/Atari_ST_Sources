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
 DLFILEIN.C

 Thing
 Dialog fuer Dateien/Ordner anzeigen/aendern
 =========================================================================*/

#include "..\include\globdef.h"
#include "..\include\types.h"
#include "rsrc\thing.h"
#include "rsrc\thgtxt.h"
#include <ctype.h>
/*#include <types.h>*/
#include <pwd.h>
#include <grp.h>
#include "..\include\dragdrop.h"

#ifndef _DOSTIME
#define _DOSTIME DOSTIME
#endif

/**-------------------------------------------------------------------------
 dl_fileinfo()

 Info ueber Dateien/Ordner anzeigen/aendern
 -------------------------------------------------------------------------*/
void dl_fileinfo_mode(short mode, short file, short desk) {
	OBJECT *tree;
	UNUSED(file);

	tree = rs_trindex[FLINFO];

	tree[FINAME].ob_flags &= ~EDITABLE;
	tree[FILABEL].ob_flags &= ~EDITABLE;
	tree[FPMAGIC].ob_flags &= ~EDITABLE;
	tree[FAUID].ob_flags &= ~EDITABLE;
	tree[FAGID].ob_flags &= ~EDITABLE;

	fi_fileinfo.edit_obj = -1;

	switch (mode) {
	case 0:
		tree[FLSUB].ob_head = FLSGENERAL;
		tree[FLSUB].ob_tail = FLSGENERAL;
		tree[FLSGENERAL].ob_next = FLSUB;

		if (!desk) {
			tree[FINAME].ob_flags |= EDITABLE;
			fi_fileinfo.edit_obj = FINAME;
		} else {
			tree[FILABEL].ob_flags |= EDITABLE;
			fi_fileinfo.edit_obj = FILABEL;
		}
		break;
	case 1:
		tree[FLSUB].ob_head = FLSPROG;
		tree[FLSUB].ob_tail = FLSPROG;
		tree[FLSPROG].ob_next = FLSUB;
		if (tb.sys & SY_MAGX) {
			tree[FPMAGIC].ob_flags |= EDITABLE;
			fi_fileinfo.edit_obj = FPMAGIC;
		}
		break;
	case 2:
		tree[FLSUB].ob_head = FLSATTR;
		tree[FLSUB].ob_tail = FLSATTR;
		tree[FLSATTR].ob_next = FLSUB;

		if (!desk) {
			if ((tree[FAUID].ob_flags & HIDETREE) == 0) {
				fi_fileinfo.edit_obj = FAUID;
				tree[FAUID].ob_flags |= EDITABLE;
				tree[FAGID].ob_flags |= EDITABLE;
			}
		}
		break;
	}
}


/**
 *
 */
static void dl_fileinfo_dmode(OBJECT *tree, short dmode, unsigned short atime,
		unsigned short adate, unsigned short mtime, unsigned short mdate,
		unsigned short ctime, unsigned short cdate) {
	unsigned short _time, _date;
	char *desc;

	switch (dmode) {
	case 0:
		_time = mtime;
		_date = mdate;
		desc = rs_frstr[TXMDATE];
		break;
	case 1:
		_time = atime;
		_date = adate;
		desc = rs_frstr[TXADATE];
		break;
	case 2:
		_time = ctime;
		_date = cdate;
		desc = rs_frstr[TXCDATE];
		break;
	}/* FLOFILE */
	sprintf(tree[FIDATE].ob_spec.tedinfo->te_ptext, glob.dateformat, _date & 0x1f, (_date & 0x1e0) >> 5, 1980 + ((_date & 0xfe00) >> 9));
	sprintf(tree[FITIME].ob_spec.tedinfo->te_ptext, glob.timeformat, (_time & 0xf800) >> 11, (_time & 0x7e0) >> 5);
	tree[FIDATETYPE].ob_spec.tedinfo->te_ptext = desc;
}

#define MAXNAME 128
static char name_txt[MAXNAME+4];

#if 0
short dl_fileinfo(char *path, short usepar, FILESYS *filesys, WP_ENTRY *item,
		ICONDESK *icon, short donext) { char chaine[200];
/*short pxy[10];
pxy[0]=icon->x;
pxy[1]=icon->y;
pxy[2]=icon->x+200;
pxy[3]=icon->y;
pxy[4]=icon->x+20;
pxy[5]=icon->y+100;
pxy[6]=icon->x;
pxy[7]=icon->y+10;
pxy[8]=icon->x;
pxy[9]=icon->y;
v_pline(tb.vdi_handle, 5, pxy);*/
sprintf(chaine,"[1][coucou %d %d!][ok]",icon->x,icon->y);
(void)form_alert(1,chaine);
}
#endif


/**
 * Init Dialog Dateien/Ordner anzeigen/aendern
 */
short dl_fileinfo(char *path, short usepar, FILESYS *filesys, WP_ENTRY *item,
		ICONDESK *icon, short donext) {
	W_PATH *wpath1;
	char *wname, *lpath;
	char *fmask, *dlstr;
	short cont, done, ok, attr, fkey, atfirst, i, l, desk, file;
	short nfiles, nfolders, nlinks;
	unsigned long size;
	long fret;
	long magic[2];
	char name[MAX_FLEN], *oldname, *newname;
	short mode1;
	static short mode = 0;
	unsigned short tmode, imode;
	long fh;
	PH ph;
	short isp, ism, dvalid;
	_DOSTIME dtime;
	OBJECT *tree;
	static short dmode = 0;
	struct passwd *pwd;
	struct group *grp;
	short newuid, newgid;
	HOTKEY *hk, *p;
	short key = 0;


	wname = pmalloc(MAX_PLEN * 4L);
	if (wname == NULL) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return (0);
	}
	lpath = wname + MAX_PLEN;
	oldname = lpath + MAX_PLEN;
	newname = oldname + MAX_PLEN;

	tree = rs_trindex[FLINFO];
tree[FINAME].ob_spec.tedinfo->te_ptext=name_txt;
tree[FINAME].ob_spec.tedinfo->te_txtlen = MAXNAME;


	/* Vorbereitungen: Datei auf Desktop? Datei/Ordner? */
	tree[FLPROG].ob_state |= DISABLED;
	tree[FLPROG].ob_flags &= ~(SELECTABLE | TOUCHEXIT);

	/* Erweiterte Attribute ja/nein? */
	tree[FLATTR].ob_state |= DISABLED;
	tree[FLATTR].ob_flags &= ~(SELECTABLE | TOUCHEXIT);

	/* Objekt ist symbolischer Link */
	tree[FILINK].ob_flags |= HIDETREE;
	tree[FILINKDEST].ob_flags |= HIDETREE;
	tree[FILINKDEST].ob_state &= ~DISABLED;

	if (item) {
		desk = 0;
		if (item->class == EC_FILE)
			file = 1;
		else
			file = 0;
		strcpy(oldname, path);
		strcat(oldname, item->name);
		if (item->link) {
			if (!Freadlink(MAX_PLEN, newname, oldname)) {
				tree[FILINK].ob_flags &= ~HIDETREE;
				tree[FILINKDEST].ob_flags &= ~HIDETREE;
				if (item->link == 2)
					tree[FILINKDEST].ob_state |= DISABLED;
				strShortener(getObjectText(tree, FILINKDEST), newname, 30);
			} 	
		}
	} else {
		desk = 1;
		if (icon->class == IDFILE) {
			file = 1;
			strcpy(oldname, icon->spec.file->name);
		} else {
			file = 0;
			strcpy(oldname, icon->spec.folder->path);
		}
	}
	if (item && !file)
		strcat(oldname, "\\");
	for (hk = glob.hotkeys; hk != NULL; hk = hk->next) {
		if (!strcmp(hk->object, oldname))
			break;
	}
	if (item && !file)
		*strrchr(oldname, '\\') = 0;
	tree[FIHOTKEY].ob_spec.tedinfo->te_ptext[0] = hk ? hk->key : 0;

	/* Zeiger von 'Pfad: ..' im Dialog sichern */
	dlstr = tree[FIPATH - 1].ob_spec.free_string;

	/* Objekte im Verzeichnis */
	if (!desk) {
		tree[FILABEL].ob_flags &= ~EDITABLE;
		tree[FILABEL].ob_state |= DISABLED;
		tree[FILABEL].ob_flags |= HIDETREE;
		tree[FILABEL - 1].ob_flags |= HIDETREE;
		tree[FILABEL].ob_spec.tedinfo->te_ptext[0] = 0;
		tree[FLOFILE].ob_flags &= ~HIDETREE;

		if (file) /* Datei - ggf. Programmheader lesen */
		{
			/* Dialoganpassung */
			tree[FLOFOLD].ob_flags |= HIDETREE;
			tree[FLOFLAG].ob_flags &= ~HIDETREE;

			/* Dateiname */
	/*		strcpy(tree[FINAME].ob_spec.tedinfo->te_ptext, item->name);*/
		strShortener(name_txt, item->name, MAXNAME);

		if(strlen(name_txt)>29/*strlen(tree[FINAME].ob_spec.tedinfo->te_ptmplt-3)*/) {
			tree[FINAME].ob_spec.tedinfo->te_ptext=&name_txt[strlen(name_txt)-32/*strlen(tree[FINAME].ob_spec.tedinfo->te_ptmplt)*/+4];
			tree[FINAME].ob_spec.tedinfo->te_txtlen = MAXNAME-strlen(name_txt)+32-4;
		}

			isp = ism = dvalid = 0;
#if 0
			if(is_app(oldname,item->mode))
#endif
			{
				fh = Fopen(oldname, FO_READ);
				if (fh >= 0L) {
					/* Zeit/Datum sichern */
					Fdatime(&dtime, (short) fh, 0);
					if (dtime.time != 0 && dtime.date != 0)
						dvalid = 1;

					/* Programmheader lesen */
					if (Fread((short) fh, sizeof(PH), &ph) == sizeof(PH)) {
						if (ph.ph_branch == 0x601a)
							isp = 1;
					}

					/* MagiC-Speicherlimit ermitteln */
					if (isp && (tb.sys & SY_MAGX)) {
						Fseek(-8L, (short) fh, 2);
						if (Fread((short) fh, 8L, magic) == 8L) {
							if (magic[0] == 'MAGX' && magic[1] >= 0L)
								ism = 1;
						}
					}
					Fclose((short) fh);
				}
			}

			/* GEMDOS-Flags */
			setObjectState(tree, FIFLAGRO, SELECTED, item->attr & FA_READONLY);
			setObjectState(tree, FIFLAGH, SELECTED, item->attr & FA_HIDDEN);
			setObjectState(tree, FIFLAGS, SELECTED, item->attr & FA_SYSTEM);
			setObjectState(tree, FIFLAGA, SELECTED, item->attr & FA_ARCHIVE);

			/* Programmflags eintragen falls Datei ein Programm ist */
			if (isp) {
				tree[FLPROG].ob_state &= ~DISABLED;
				tree[FLPROG].ob_flags |= (SELECTABLE | TOUCHEXIT);

				setObjectState(tree, FPFAST, SELECTED, !!(ph.ph_res2 & 0x1L));
				setObjectState(tree, FPLALT, SELECTED, !!(ph.ph_res2 & 0x2L));
				setObjectState(tree, FPMALT, SELECTED, !!(ph.ph_res2 & 0x4L));
				setObjectState(tree, FPMINMEM, SELECTED, !!(ph.ph_res2 & 0x8L));
				setObjectState(tree, FPSHARED, SELECTED, !!(ph.ph_res2 & 0x800L));
				pop_mem.sel = 1 + ((short) (ph.ph_res2 & 0x70L) >> 4);

				if (ism && magic[1] > 0L)
					ltoa(magic[1] / 1024L, tree[FPMAGIC].ob_spec.tedinfo->te_ptext, 10);
				else
					tree[FPMAGIC].ob_spec.tedinfo->te_ptext[0] = 0;
			}

			/* Reihenfloge der Flagaenderung merken */
			if (item->attr & FA_READONLY)
				atfirst = 1;
			else
				atfirst = 0;

			/* Weitere Daten eintragen */
			prlong11(item->size, tree[FISIZE].ob_spec.free_string);
		} else {
			/* Ordner */

			/* Dialoganpassung */
			tree[FLOFLAG].ob_flags |= HIDETREE;
			tree[FLOFOLD].ob_flags &= ~HIDETREE;

			strcpy(lpath, path);
			if (usepar) {
				i = (short) strlen(lpath) - 2;
				while (lpath[i] != '\\')
					i--;
				i++;
				strcpy(item->name, &lpath[i]);
				path[i] = 0;
				item->name[(short) strlen(item->name) - 1] = 0;
			}

			/* Infos ermitteln */
			strcpy(oldname, path);
			strcat(oldname, item->name);
			graf_mouse(BUSYBEE, 0L);
			nfiles = nfolders = nlinks = 0;
			size = 0L;
			fret = dir_check(oldname, &nfiles, &nfolders, &size, &nlinks, 0, 0);
			graf_mouse(ARROW, 0L);
			if (fret != 0) {
				pfree(wname);
				return 0; /* Bei Lesefehler raus */
			}

			/* Dialog vorbereiten */
			strShortener(tree[FIPATH].ob_spec.free_string, path, 30);
			strcpy(oldname, path);
			strcat(oldname, item->name);
			strcat(oldname, "\\");

/*			strcpy(tree[FINAME].ob_spec.tedinfo->te_ptext, item->name);*/
			strShortener(name_txt, item->name, MAXNAME);
			if(strlen(name_txt)>29 /*strlen(tree[FINAME].ob_spec.tedinfo->te_ptmplt-3)*/) {
				tree[FINAME].ob_spec.tedinfo->te_ptext=&name_txt[strlen(name_txt)-32/*strlen(tree[FINAME].ob_spec.tedinfo->te_ptmplt)*/+4];
				tree[FINAME].ob_spec.tedinfo->te_txtlen = MAXNAME-strlen(name_txt)+32-4;
			}


			prlong11(size, tree[FISIZE].ob_spec.free_string);
			sprintf(tree[FLFILES].ob_spec.free_string, "%-6d", nfiles);
			sprintf(tree[FLFOLDERS].ob_spec.free_string, "%-6d", nfolders);
		}

		/* MiNT-Flags */
		tmode = S_IRUSR;
		for (i = 0; i < 12; i++) {
			setObjectState(tree, FLMODE1 + i, SELECTED, item->mode & tmode);
			if (tmode != S_IXOTH)
				tmode >>= 1;
			else
				tmode = 04000; /* setuid */
		}

		/* Pfad */
		strShortener(tree[FIPATH].ob_spec.free_string, path, 30);

		/* Datum/Zeit */
		tree[FIDATETYPE].ob_flags &= ~TOUCHEXIT;
		tree[FIDATETYPE].ob_flags &= ~HIDETREE;
		if (filesys->flags & STIMES)
			tree[FIDATETYPE].ob_flags |= TOUCHEXIT;
		else {
			tree[FIDATETYPE].ob_flags |= HIDETREE;
			dmode = 0;
		}
		dl_fileinfo_dmode(tree, dmode, item->atime, item->adate, item->time, item->date, item->ctime, item->cdate);

		/*
		 * Falls Dateisystem nicht case-sensitiv, dann im Dialog nur
		 * Grossbuchstaben.
		 */
/* todo */
		fmask = tree[FINAME].ob_spec.tedinfo->te_pvalid;
		i = 0;
		if (filesys->flags & (TOS | UPCASE)) {
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

		/* Bei entsprechende Filesystemen MiNT-Attribute-Page erlauben */
		if (filesys->flags & UNIXATTR) {
			tree[FIFLAGRO].ob_state |= DISABLED;
			tree[FIFLAGH].ob_state |= DISABLED;
			tree[FIFLAGS].ob_state |= DISABLED;
			tree[FIFLAGA].ob_state |= DISABLED;
			tree[FLATTR].ob_state &= ~DISABLED;
			tree[FLATTR].ob_flags |= SELECTABLE | TOUCHEXIT;

			if (filesys->flags & OWNER) {
				tree[FAUID].ob_state &= ~HIDETREE;
				tree[FAGID].ob_state &= ~HIDETREE;

				pwd = getpwuid(item->uid);
				if ((pwd == NULL) || (strlen(pwd->pw_name) > 8)) {
					sprintf(tree[FAUID].ob_spec.tedinfo->te_ptext, "%u", (unsigned short) item->uid);
				} else
					strcpy(tree[FAUID].ob_spec.tedinfo->te_ptext, pwd->pw_name);

				grp = getgrgid(item->gid);
				if ((grp == NULL) || (strlen(grp->gr_name) > 8)) {
					sprintf(tree[FAGID].ob_spec.tedinfo->te_ptext, "%u", (unsigned short) item->gid);
				} else
					strcpy(tree[FAGID].ob_spec.tedinfo->te_ptext, grp->gr_name);
			} else {
				tree[FAUID].ob_state |= HIDETREE;
				tree[FAGID].ob_state |= HIDETREE;
			}
		}
	} else {
		/* Objekt auf dem Desktop */
		/* Dialoganpassung */

		tree[FIFLAGRO].ob_state &= ~DISABLED;
		tree[FIFLAGH].ob_state &= ~DISABLED;
		tree[FIFLAGS].ob_state &= ~DISABLED;
		tree[FIFLAGA].ob_state &= ~DISABLED;

		tree[FLOFLAG].ob_flags |= HIDETREE;
		tree[FLOFOLD].ob_flags |= HIDETREE;
		tree[FLOFILE].ob_flags |= HIDETREE;

		tree[FILABEL].ob_flags |= EDITABLE;
		tree[FILABEL].ob_state &= ~DISABLED;
		tree[FILABEL].ob_flags &= ~HIDETREE;
		tree[FILABEL - 1].ob_flags &= ~HIDETREE;
		strcpy(tree[FILABEL].ob_spec.tedinfo->te_ptext, icon->title);

		strShortener(tree[FIPATH].ob_spec.free_string, oldname, 30);

		if (icon->class==IDFILE) {
			/* Statt 'Pfad: ...' 'Name: ...' */
			tree[FIPATH - 1].ob_spec.free_string = tree[FINAME - 1].ob_spec.free_string;
		}
		tree[FINAME - 1].ob_flags |= HIDETREE;
		tree[FINAME].ob_flags |= HIDETREE;
	}

	/* Weitere Vorbereitungen */
	unsetObjectSelected(tree, FLGENERAL);
	unsetObjectSelected(tree, FLPROG);
	unsetObjectSelected(tree, FLATTR);

	mode1 = mode;
	if (((mode == 2) && (tree[FLATTR].ob_state & DISABLED)) || ((mode == 1) && (tree[FLPROG].ob_state & DISABLED))) {
		mode = mode1 = 0;
	}
	switch (mode) {
	case 0:
		tree[FLGENERAL].ob_state |= SELECTED;
		break;
	case 1:
		tree[FLPROG].ob_state |= SELECTED;
		break;
	case 2:
		tree[FLATTR].ob_state |= SELECTED;
		break;
	}

	dl_fileinfo_mode(mode, file, desk);

	pop_fkeyfd.sel = setfpop(oldname);
	fkey = pop_fkeyfd.sel;

	setObjectState(tree, FINEXT, DISABLED, !donext);

	/* Auf gehts ... */
	frm_start(&fi_fileinfo, conf.wdial, conf.cdial, 1);
	done = 0;
	while (!done) {
		frm_dial(&fi_fileinfo, &mevent);
		mode1 = mode;
		switch (fi_fileinfo.exit_obj) {
		short d, mb;

		case FIDATETYPE:
			do
				graf_mkstate(&d, &d, &mb, &d);
			while (mb & 1);
			if (++dmode == 3)
				dmode = 0;
			dl_fileinfo_dmode(tree, dmode, item->atime, item->adate, item->time, item->date, item->ctime, item->cdate);
			if (mode == 0)
				frm_redraw(&fi_fileinfo, FLOFILE);
			break;
		case FIHOTKEYSEL:
			key = get_new_hotkey(hk);
			if (fi_fileinfo.state != FST_WIN)
				frm_redraw(&fi_fileinfo, ROOT);
			if (key) {
				tree[FIHOTKEY].ob_spec.tedinfo->te_ptext[0] = key;
				frm_redraw(&fi_fileinfo, FIHOTKEY);
			}
			frm_norm(&fi_fileinfo);
			break;
		case FIHELP:
			show_help(fi_fileinfo.userinfo);
			frm_norm(&fi_fileinfo);
			break;
		case FICANCEL:
			cont = 0; /* Rueckgabe: Abbruch */
			mode = 0;
			done = 1;
			break;
		case FIOK:
			ok = 1;

			/* Bei Verzeichnisobjekten Dateinamen und ggf. UID/GID pruefen */
			if (!desk) {
				char *p = name_txt/*tree[FINAME].ob_spec.tedinfo->te_ptext*/; /* as file name can be at higher lenght of edit field we put as text pointer only end of file name */
				if (!*p || !isValidFileMask(p, FALSE)) {
					frm_alert(1, rs_frstr[ALILLNAME], altitle, conf.wdial, 0L);
					ok = 0;
				}
				if (ok && ((filesys->flags & (UNIXATTR | OWNER)) == (UNIXATTR | OWNER))) {
					char *hlp, *err;
					unsigned long id;
					short isok = 1;

					hlp = tree[FAUID].ob_spec.tedinfo->te_ptext;
					if (isdigit(*hlp)) {
						id = strtoul(hlp, &err, 10);
						if (*err || (id > 65535UL))
							isok = 0;
						newuid = (short) id;
					} else {
						pwd = getpwnam(hlp);
						if (pwd != NULL)
							newuid = (short) pwd->pw_uid;
						else
							isok = 0;
					}
					if (!isok) {
						frm_alert(1, rs_frstr[ALUID], altitle, conf.wdial, 0L);
						ok = 0;
					} else {
						hlp = tree[FAGID].ob_spec.tedinfo->te_ptext;
						if (isdigit(*hlp)) {
							id = strtoul(hlp, &err, 10);
							if (*err || (id > 65535UL))
								isok = 0;
							newgid = (short) id;
						} else {
							grp = getgrnam(hlp);
							if (grp != NULL)
								newgid = (short) grp->gr_gid;
							else
								isok = 0;
						}
						if (!isok) {
							frm_alert(1, rs_frstr[ALGID], altitle, conf.wdial, 0L);
							ok = 0;
						}
					}
				}
			}

			if (ok) {
				cont = 2; /* Rueckgabe: Icon geaendert */
				done = 1;
			} else
				frm_norm(&fi_fileinfo);
			break;
		case FINEXT:
			cont = 1; /* Rueckgabe: Icon uebersprungen */
			done = 1;
			break;
		case FLGENERAL:
			mode = 0;
			break;
		case FLPROG:
			mode = 1;
			break;
		case FLATTR:
			mode = 2;
			break;
		}

		if (mode1 != mode) {
			if (mode1 == 2) {
				obj_edit(fi_fileinfo.tree, fi_fileinfo.edit_obj, 0, 0, &fi_fileinfo.edit_idx, ED_END, fi_fileinfo.win.handle);
				fi_fileinfo.edit_obj = 0;
				fi_fileinfo.edit_idx = -1;
			}
			dl_fileinfo_mode(mode, file, desk);
			fi_fileinfo.edit_idx = -1;
			if (fi_fileinfo.edit_obj != -1)
				obj_edit(fi_fileinfo.tree, fi_fileinfo.edit_obj, 0, 0, &fi_fileinfo.edit_idx, ED_INIT, fi_fileinfo.win.handle);
			frm_redraw(&fi_fileinfo, FLSUB);
		}
	}
	frm_end(&fi_fileinfo);

	if (fi_fileinfo.exit_obj == FIOK) {
		if (key) {
			p = get_hotkey(key);
			if ((hk != NULL) && (p != NULL) && (p != hk)) {
				if (hk->prev)
					hk->prev->next = hk->next;
				else
					glob.hotkeys = hk->next;
				if (hk->next)
					hk->next->prev = hk->prev;
				pfree(hk);
			}
			if (p == NULL) {
				if (hk == NULL) {
					if ((p = pmalloc(sizeof(HOTKEY))) == NULL)
						frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
					else {
						p->prev = NULL;
						p->next = glob.hotkeys;
						if (glob.hotkeys != NULL)
							glob.hotkeys->prev = p;
						glob.hotkeys = p;
					}
				} else
					p = hk;
			}
			if (p != NULL) {
				p->key = key;
				hk = p;
			}
		}
		if (!desk) /* Objekt im Verzeichnis */
		{
			strcpy(name, name_txt/*tree[FINAME].ob_spec.tedinfo->te_ptext*/);

			/* Bei Bedarf Schreibweise anpassen */
			fsconv(name, filesys);

			attr = item->attr;
			if (isObjectSelected(tree, FIFLAGRO))
				attr |= FA_READONLY;
			else
				attr &= ~FA_READONLY;
			if (isObjectSelected(tree, FIFLAGH))
				attr |= FA_HIDDEN;
			else
				attr &= ~FA_HIDDEN;
			if (isObjectSelected(tree, FIFLAGS))
				attr |= FA_SYSTEM;
			else
				attr &= ~FA_SYSTEM;
			if (isObjectSelected(tree, FIFLAGA))
				attr |= FA_ARCHIVE;
			else
				attr &= ~FA_ARCHIVE;

			imode = item->mode;
			tmode = S_IRUSR;
			for (i = 0; i < 12; i++) {
				if (isObjectSelected(tree, FLMODE1 + i))
					imode |= tmode;
				else
					imode &= ~tmode;
				if (tmode != S_IXOTH)
					tmode >>= 1;
				else
					tmode = 04000; /* setuid */
			}

			/* Programmflags */
			if (file && isp) {
				ph.ph_res2 &= ~0x100f;
				if (isObjectSelected(tree, FPFAST))
					ph.ph_res2 |= 0x1L;
				if (isObjectSelected(tree, FPLALT))
					ph.ph_res2 |= 0x2L;
				if (isObjectSelected(tree, FPMALT))
					ph.ph_res2 |= 0x4L;

				ph.ph_res2 &= ~0x70L;
				ph.ph_res2 |= (long) ((pop_mem.sel - 1) << 4);

				if (isObjectSelected(tree, FPSHARED))
					ph.ph_res2 |= 0x1000L;
				if (isObjectSelected(tree, FPMINMEM))
					ph.ph_res2 |= 0x8L;

				/* MagiC-Speicherlimit */
				magic[0] = 'MAGX';
				magic[1] = atol(tree[FPMAGIC].ob_spec.tedinfo->te_ptext) * 1024L;
			}

			if (atfirst) /* Falls Datei schreibgeschuetzt, dann erst Attr. */
			{
				strcpy(newname, oldname);
				goto dl_fileinfo2;
			}

			dl_fileinfo1:
			/* Falls Programm, dann Programmheader ersetzen */
			if (file && isp) {
				fh = Fopen(oldname, FO_RW);
				if (fh >= 0L) {
					Fwrite((short) fh, sizeof(PH), &ph);

					/* Bei Bedarf MagiC-Speicherlimit setzen/loeschen */
					if (magic[1] > 0L) /* Limit „ndern/setzen */
					{
						if (ism)
							Fseek(-8L, (short) fh, 2);
						else
							Fseek(0L, (short) fh, 2);
						Fwrite((short) fh, 8L, magic);
					} else /* Limit l”schen */
					{
						if (ism) {
							Fseek(-8L, (short) fh, 2);
							Fwrite((short) fh, 0L, (void *) -1L); /* Achtung: Geht nur mit MagiC! */
						}
					}

					/* Ggf. Datum/Zeit wiederherstellen */
					if (dvalid)
						Fdatime(&dtime, (short) fh, 1);

					Fclose((short) fh);
					/*
					 * Durch das Aendern wurde das FA_ARCHIVE-Flag gesetzt und muss
					 * daher im alten Attribut gesetzt werden, damit es anschliessend
					 * bei Bedarf wieder entfernt wird.
					 */
					item->attr |= FA_ARCHIVE;
					atfirst = 0;
				}
			}

			/* Datei/Ordner umbenennen */
			strcpy(newname, path);
			strcat(newname, name);
			if (!file) {
				i = 0;
				while (oldname[i])
					i++;
				if (i > 0)
					oldname[i - 1] = 0;
			}
			if (strcmp(oldname, newname) != 0)
				fret = (long) Frename(0, oldname, newname);
			else
				fret = 0L;
			if (fret != 0L) {
				err_file(rs_frstr[ALFLRENAME], fret, oldname);
				/*
				 * Alten Namen als neuen eintragen, damit im Verzeichnis nicht
				 * der falsche erscheint
				 */
				full2comp(oldname, path, name);
				cont = 1;
			} else {
				if (atfirst)
					goto dl_fileinfo3;
dl_fileinfo2:
				/* Dateiattribute setzen */
				if (filesys->flags & UNIXATTR) {
					if (imode != item->mode) {
						fret = Fchmod(newname, imode & 07777);
						if (fret != 0L) {
							err_file(rs_frstr[ALFLATTR], fret, newname);
							cont = 1;
						} else {
							item->mode = imode;
						}
					}
					if ((filesys->flags & OWNER) && ((newuid != item->uid)
							|| (newgid != item->gid))) {
						fret = Fchown(newname, newuid, newgid);
						if (fret != 0L) {
							err_file(rs_frstr[ALFLATTR], fret, newname);
							cont = 1;
						} else {
							item->uid = newuid;
							item->gid = newgid;
						}
					}
				} else {
					if (file && attr != item->attr) {
						Fattrib(newname, 1, attr);
						fret = (long) Fattrib(newname, 0, attr);
						if ((short) fret != attr) {
							err_file(rs_frstr[ALFLATTR], fret, newname);
							cont = 1;
						} else {
							item->attr = attr;
						}
					}
				}
				if (atfirst)
					goto dl_fileinfo1;
			}

dl_fileinfo3:
			/* Neuen Namen eintragen */
			strcpy(item->name, name);

			/* Bei Ordnern Pfade der Verzeichnisfenster anpassen */
			if (!file) {
				strcat(oldname, "\\");
				l = (short) strlen(oldname);

				for (i = 0; i < MAX_PWIN; i++) {
					if (glob.win[i].state & WSOPEN) {
						/* Pfad */
						wpath1 = (W_PATH *) glob.win[i].user;
						if (!strncmp(oldname, wpath1->path, (long) l)) {
							strcpy(wname, newname);
							if (wpath1->path[l - 1])
								strcat(wname, &wpath1->path[l - 1]);
							strcpy(wpath1->path, wname);
							wpath_iupdate(&glob.win[i], 0);
						}
					}
				}
			}

			/* F-Taste zuweisen */
			if (!file)
				strcat(newname, "\\");
			if (fkey > 4)
				conf.fkey[fkey - 5][0] = 0;
			if (pop_fkeyfd.sel > 4)
				strcpy(conf.fkey[pop_fkeyfd.sel - 5], newname);

			/* Hotkey zuweisen */
			if (hk)
				strcpy(hk->object, newname);
		} else /* Objekt auf dem Desktop */
		{
			strcpy(icon->title, tree[FILABEL].ob_spec.tedinfo->te_ptext);
			/* F-Taste zuweisen */
			if (fkey > 4)
				conf.fkey[fkey - 5][0] = 0;
			if (pop_fkeyfd.sel > 4)
				strcpy(conf.fkey[pop_fkeyfd.sel - 5], oldname);

			/* Hotkey zuweisen */
			if (hk)
				strcpy(hk->object, oldname);
		}
	}

	/* Ggf. neuen Pfadnamen bei Verzeichnisfenstern eintragen */
	if (!file && !desk && usepar) {
		strcat(path, item->name);
		strcat(path, "\\");
	}

	tree[FIPATH - 1].ob_spec.free_string = dlstr;
	tree[FINAME - 1].ob_flags &= ~HIDETREE;
	tree[FINAME].ob_flags &= ~HIDETREE;

	if (!donext || !cont)
		mode = dmode = 0;
	pfree(wname);
	return (cont);
}
