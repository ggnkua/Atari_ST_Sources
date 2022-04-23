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
 SYSTEM.C

 Thing
 Systemfunktionen und diverser Kleinkruscht
 =========================================================================*/

#include "..\include\globdef.h"
#include <ctype.h>
#include <stdarg.h>
#include "..\xhdi\xhdi.h"
#include "..\include\types.h"
#include "rsrc\thing.h"
#include "rsrc\thgtxt.h"
#include "..\include\jobid.h"

#undef ORIG_DIRCHECK

#ifdef ORIG_DIRCHECK
static short dirx_dir(char *path,short *nfiles,short *nfolders,long *size,
		short *nlinks, short follow);
static short dirx_file(char *path,short *nfiles,long *size,short *nlinks,
		short follow);
#else
static short build_filename(char *dst, char *a, char *b);
#endif
void title_update(short drive);

/*------------------------------------------------------------------*/
/*  global variables                                                */
/*------------------------------------------------------------------*/
extern BYTE *aesBuffer;

/**
 put_text()

 GegenstÅck zu get_text() -
 Konvertiert einen String und schreibt diesen in die angegebene Datei
 -------------------------------------------------------------------------*/
void put_text(FILE *fh, char *str) {
	unsigned char *p;

	fprintf(fh, "\"");
	p = (unsigned char *) str;
	while (*p) {
		if ((*p < 32) || (*p == '\"') || (*p == '@'))
			fprintf(fh, "@%02d", (short) *p);
		else
			fprintf(fh, "%c", *p);
		p++;
	}
	fprintf(fh, "\"");
}

/**
 chk_drive()

 PrÅft, ob das angegebene Laufwerk existiert und falls ja, um welchen
 Typ es sich handelt (Floppy, HD, sonstige)
 -------------------------------------------------------------------------*/
short chk_drive(short drv) {
	long dmap, dtst;

	dtst = 1L << (long) drv;
	dmap = Dsetdrv(Dgetdrv());
	if (dmap & dtst) { /* Laufwerk dem GEMDOS bekannt ? */
		/* Bei A: und B: Floppy, sonst Platte */
		if (drv < 2)
			return (0);
		else
			return (1);
	} else { /* Nein */
		return (-1);
	}
}

/**
 dir_check()

 Ermittelt die Anzahl aller Dateien und Ordner in einem Pfad
 einschliesslich aller Unterverzeichnisse
 -------------------------------------------------------------------------*/
#if ORIG_DIRCHECK
static short dlevel,xlen;
static char xname[MAX_PLEN];

static short dirx_dir(char *path,short *nfiles,short *nfolders,long *size,
		short *nlinks, short follow)
{
	char lpath[MAX_PLEN];
	char dbuf[MAX_FLEN+4];
	long dhandle;
	short done;
	short usexread;
	XATTR xattr;
	long xret,dret;

	/* Verzeichnis îffnen */
	dhandle=Dopendir(path,0);
	/* Bei schwerem Fehler sofort raus */
	if(dhandle==-32L) return -32;
	if((dhandle&0xff000000L)==0xff000000L) return (short)dhandle;

	/* Sonst normal behandeln */
	dret=dhandle;
	usexread = 1;
	if(dret>=0L) done=0; else done=1;
	while(!done)
	{
		if (usexread)
		dret=Dxreaddir(MAX_FLEN+4,dhandle,dbuf,&xattr,&xret);
		if((dret==-32L) || !usexread) /* Falls obiges nicht unterstÅtzt wird... */
		{
			usexread = 0;
			dret=Dreaddir(MAX_FLEN + 4, dhandle, dbuf);
			if(dret==0L)
			{
				if(((short)strlen(lpath) + (short)strlen(&dbuf[4]) + 4) < MAX_PLEN &&
						dlevel < 17)
				{
					strcpy(lpath, path);
					strcat(lpath, "\\");
					strcat(lpath, &dbuf[4]);
					xret = Fxattr(1, lpath, &xattr);
				}
				else
				{
					/* Pfad zu lang - dann abbrechen */
					frm_alert(1,rs_frstr[ALRECURS],altitle,conf.wdial,0L);
					dret=1L;
				}
			}
		}
		if(dret==0L) /* Kein Fehler - normal auswerten */
		{
			xattr.mode&=S_IFMT; /* Dateimodus maskieren */
			if(xattr.mode==S_IFDIR) /* Unterverzeichnis */
			{
				if(strcmp(&dbuf[4],".")!=0 && strcmp(&dbuf[4],"..")!=0)
				{
					*nfolders=*nfolders+1;

					/* Sicherheitscheck: Nur bearbeiten, wenn Pfad-Name nicht
					 zu lang wird bzw. nicht mehr als 20 Hirarchie-Ebenen */
					if(((short)strlen(lpath)+(short)strlen(&dbuf[4])+4)<MAX_PLEN && dlevel<17)
					{
						strcpy(lpath,path);strcat(lpath,"\\");strcat(lpath,&dbuf[4]);
						dret=(long)dirx_dir(lpath,nfiles,nfolders,size);
					}
					else
					{
						/* Pfad zu lang - dann abbrechen */
						frm_alert(1,rs_frstr[ALRECURS],altitle,conf.wdial,0L);
						dret=1L;
					}
				}
			}
			else /* Datei */
			{
				*nfiles=*nfiles+1;
				*size=*size+xattr.size;
			}
		}
		/* Fehlerbehandlung */
		if(dret!=0L)
		{
			done=1;
			Dclosedir(dhandle);
			if(dret!=1L && dret!=-49L && dret!=-33L)
			err_file(rs_frstr[ALPREAD],dret,path);
			else dret=0L;
		}
	}
	return (short)dret;
}

static short dirx_file(char *path,short *nfiles,long *size,short *nlinks,
		short follow)
{
	long fret;
	XATTR xattr;

	fret=Fxattr(1,path,&xattr);
	if(fret==-32L) return -32;
	if((fret&0xff000000L)==0xff000000L) return (short)fret;
	*nfiles=*nfiles+1;
	*size=*size+xattr.size;
	return 0;
}
#else
static short build_filename(char *dst, char *a, char *b) {
	if ((strlen(a) + strlen(b)) < (long) MAX_PLEN) {
		strcpy(dst, a);
		strcat(dst, b);
		return (0);
	} else {
		frm_alert(1, rs_frstr[ALRECURS], altitle, conf.wdial, 0L);
		return (1);
	}
}
#endif

short dir_check(char *path, short *nfiles, short *nfolders, unsigned long *size,
		short *nlinks, short follow, short sub)
#ifndef ORIG_DIRCHECK
		{
	short fret, xread, len;
	static XATTR xattr;
	_DTA *old_dta, mydta;
	long dirh, xfret;
	char *fpath;
	static char fname[MAX_FLEN + 4];
	char *xname;
	char *p;

	if (sub > 16) {
		frm_alert(1, rs_frstr[ALRECURS], altitle, conf.wdial, 0L);
		return (1);
	}
	if ((fpath = pmalloc(MAX_PLEN * 2L)) == NULL) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return (1);
	}
	xname = fpath + MAX_PLEN;
	strcpy(fpath, path);
	len = (short) strlen(fpath);
	if (!len) {
		pfree(fpath);
		return (1);
	}
	if ((fpath[len - 1] == '\\') && (len > 3))
		fpath[len - 1] = 0;
	if (len > 3) {
		fret = file_exists(fpath, follow, &xattr);
		if (fret) {
			err_file(rs_frstr[ALPREAD], (long) fret, fpath);
			pfree(fpath);
			return (fret);
		}
		xattr.mode &= S_IFMT;
		if (xattr.mode != S_IFDIR) {
			*size += (unsigned long) xattr.size;
			(*nfiles)++;
			if (xattr.mode == S_IFLNK)
				(*nlinks)++;
			pfree(fpath);
			return (0);
		}
		(*nfolders)++;
	}
	if (sub == -1) {
		pfree(fpath);
		return (0);
	}
	dirh = Dopendir(fpath, 0);
	if (len > 3)
		strcat(fpath, "\\");
	if (dirh != -32L) {
		if ((dirh & 0xff000000L) == 0xff000000L) {
			err_file(rs_frstr[ALPREAD], dirh, fpath);
			pfree(fpath);
			return ((short) dirh);
		}
	}
	fret = 0;
	if (dirh != -32L) {
		xread = 1;
		while (fret == 0) {
			if (xread)
				fret = (short) Dxreaddir(MAX_FLEN + 4, dirh, fname, &xattr, &xfret);
			if (follow || !xread || (fret == -32L)) {
				if (!xread || (fret == -32L)) {
					xread = 0;
					fret = (short) Dreaddir(MAX_FLEN + 4, dirh, fname);
				}
				if (fret)
					break;
				if ((fret = build_filename(xname, fpath, &fname[4])) != 0)
					break;
				if (follow) {
					if (!xread)
						xfret = Fxattr(1, xname, &xattr);
					if (xfret == 0) {
						if ((xattr.mode & S_IFMT) == S_IFLNK)
							(*nlinks)++;
					}
				}
				xfret = Fxattr(!follow, xname, &xattr);
			}
			if (fret)
				break;
			if (xfret) {
				fret = (short) xfret;
				break;
			}
			xattr.mode &= S_IFMT;
			if (xattr.mode == S_IFDIR) {
				if (!strcmp(&fname[4], ".") || !strcmp(&fname[4], ".."))
					continue;
				if ((fret = build_filename(xname, fpath, &fname[4])) != 0)
					break;
				fret = dir_check(xname, nfiles, nfolders, size, nlinks, follow, sub + 1);
				if (fret) {
					fret = 1;
					break;
				}
			} else {
				(*nfiles)++;
				if (xattr.mode == S_IFLNK)
					(*nlinks)++;
				*size += (unsigned long) xattr.size;
			}
		}
		Dclosedir(dirh);
	} else {
		len = (short) strlen(fpath);
		strcat(fpath, "*.*");
		old_dta = Fgetdta();
		Fsetdta(&mydta);
		for (fret = Fsfirst(fpath, 0x17); fret == 0; fret = Fsnext()) {
			if (mydta.dta_attribute == 0xf) /* Filter VFAT entries under TOS */
				continue;
			if (mydta.dta_attribute & FA_SUBDIR) {
				if (!strcmp(mydta.dta_name, ".") || !strcmp(mydta.dta_name, ".."))
					continue;
				fpath[len] = 0;
				if ((fret = build_filename(xname, fpath, mydta.dta_name)) != 0)
					break;
				fpath[len] = '*';
				fret = dir_check(xname, nfiles, nfolders, size, nlinks, follow,
						sub + 1);
				if (fret) {
					fret = 1;
					break;
				}
			} else {
				(*nfiles)++;
				*size += mydta.dta_size;
			}
		}
		fpath[len] = 0;
		Fsetdta(old_dta);
	}
	if (fret && (fret != -49) && (fret != -33)) {
		if (fret != 1) {
			p = strrchr(fname, '\\');
			if (p)
				*p = 0;
			err_file(rs_frstr[ALPREAD], (long) fret, fname);
			if (p)
				*p = '\\';
		}
	} else
		fret = 0;
	pfree(fpath);
	return (fret);
}
#else
{
	short fret;
	DTA dta,*odta;
	char lpath[MAX_PLEN];
	char *p;

	/* Erster Aufruf */
	if(!sub)
	{
		dlevel=0;
		/* Geht Dopendir() usw.? */
		strcpy(xname,path);
		xlen=(short)strlen(xname);
		if(xlen>4)
		{
			if(!strcmp(&xname[xlen-4],"\\*.*"))
			{
				xname[xlen-4]=0;
				fret=dirx_dir(xname,nfiles,nfolders,size);
			}
			else xlen=0;
		} else xlen=0;
		if(!xlen) fret=dirx_file(xname,nfiles,size);
	} else fret=-32;

	/* Falls MiNT-Funktionen Fehler gemeldet haben, dann raus */
	if(fret!=-32) return fret;

	/* Sonst normal weitermachen */
	odta=Fgetdta();Fsetdta(&dta);
	fret=Fsfirst(path,FA_SUBDIR|FA_HIDDEN|FA_SYSTEM);
	while (!fret)
	{
		if(dta.d_attrib&FA_SUBDIR)
		{
			if(strcmp(dta.d_fname,".")!=0 && strcmp(dta.d_fname,"..")!=0)
			{
				*nfolders=*nfolders+1;
				strcpy(lpath,path);
				p=strrchr(lpath,'\\');
				p[1]=0;

				dlevel++;

				/* Sicherheitscheck: Nur bearbeiten, wenn Pfad-Name nicht
				 zu lang wird bzw. nicht mehr als 20 Hirarchie-Ebenen */
				if(((short)strlen(lpath)+(short)strlen(dta.d_fname)+4)<MAX_PLEN && dlevel<17)
				{
					strcat(lpath,dta.d_fname);strcat(lpath,"\\*.*");
					fret=dir_check(lpath,nfiles,nfolders,size,1);
				}
				else
				{
					/* Pfad zu lang - dann abbrechen */
					frm_alert(1,rs_frstr[ALRECURS],altitle,conf.wdial,0L);
					fret=1;
				}

				dlevel--;
			}
		}
		else
		{
			*nfiles=*nfiles+1;
			*size=*size+dta.d_length;
		}
		if(!fret || fret==-49) fret=Fsnext();
	}

	if(fret!=0 && fret!=-49 && fret!=-33)
	{
		if(fret!=1)
		{
			strcpy(lpath,path);
			p=strrchr(lpath,'\\');
			p[1]=0;
			err_file(rs_frstr[ALPREAD],fret,lpath);
		}
	}
	else fret=0;
	Fsetdta(odta);

	return fret;
}
#endif

/**
 wild_match1()
 wild_match()

 PrÅft, ob eine Maske (Wildcard) zu einem Dateinamen passt.
 -------------------------------------------------------------------------*/
#if 0
static short has_wildcards(char *s) {
	unsigned char c;
	short *is_w;

	is_w = is_wild;
	while ((c = *s++) != 0) {
		if (is_w[c])
			return (1);
	}
	return (0);
}

short wild_match2(register char *pattern, register char *str) {
	register short scc;
	short ok, lc;
	short c, cc;
	char *t;
	short l;

	for (;;) {
		scc = *str++ & 0177;
		switch (c = *pattern++) {
		case '[':
			ok = 0;
			lc = 077777;
			while ((cc = *pattern++) != 0) {
				if (cc == ']') {
					if (ok)
						break;
					return (0);
				}
				if (cc == '-') {
					if (lc <= scc && scc <= *pattern++)
						ok++;
				} else if (scc == (lc = cc))
					ok++;
			}
			if (cc == 0)
				if (ok)
					pattern--;
				else
					return 0;
			continue;

		case '*':
			if (!*pattern)
				return (1);
			str--;
			if (!hasWildcards(pattern)) {
				l = 0;
				while (*str++)
					l++;
				str--;
				t = pattern;
				while (*t++) {
					str--;
					l--;
				}
				if (l >= 0) {
					while (*pattern) {
						if (*pattern++ != *str++)
							return (0);
					}
					return (1);
				} else
					return (0);
			}
			do {
				if (wild_match2(pattern, str))
					return (1);
			} while (*str++);
			return (0);

		case 0:
			return (scc == 0);

		case '?':
			if (scc == 0)
				return (0);
			continue;

		default:
			if (c != scc)
				return (0);
			continue;
		}
	}
}
#endif

short wild_match1(char *p, char *str) {
	if (*p == '~')
		return (!patternMatching(++p, str));
	else
		return (patternMatching(p, str));
}

short wild_match(char *mask, char *name) {
	char *p;

	p = strrchr(name, '\\');
	if (!p)
		p = name;
	else
		p = &p[1];
	return wild_match1(mask, p);
}

/**
 va_open()

 ôffnen eines beliebigen Objekts nach einer empfangenen VA_START-
 oder AV_PROGSTART-Meldung
 -------------------------------------------------------------------------*/
short va_open(char *name) {
	APPLINFO *appl, app;
	char *full, *afile, *apath;
	char *parm;
	short t, aok;
	short intern, rex;
	short ret;
	FILESYS fs;

	if ((full = pmalloc(MAX_PLEN * 3L)) == NULL) {
		frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
		return (0);
	}
	afile = full + MAX_PLEN;
	apath = afile + MAX_PLEN;

	/* Dateinamen und Parameter isolieren */
	if (!get_buf_entry(name, full, &parm)) {
		frm_alert(1, rs_frstr[ALILLNAME], altitle, conf.wdial, 0L);
		pfree(full);
		return (0);
	}
	while (*parm == ' ')
		parm++;

	/*
	 * Bei unzulÑssigen Dateinamen (ohne Pfadangabe) versuchen, den
	 * Dateinamen zu extrahieren und direkt mit der Suche einer
	 * passenden Applikation fortfahren. Falls kein Dateiname extrahiert
	 * werden kann, eine Warnung ausgeben und abbrechen
	 */
	if (!isValidPath(full)) {
		char *p;

		strcpy(apath, tb.homepath);
		if ((p = strrchr(full, '\\')) == NULL)
			strcpy(afile, full);
		else
			strcpy(afile, ++p);
		if (*afile)
			goto only_filename;
		frm_alert(1, rs_frstr[ALILLNAME], altitle, conf.wdial, 0L);
		pfree(full);
		return (0);
	}

	fsinfo(full, &fs);
	fsconv(full, &fs);

	/* Pfad und Dateiname erzeugen */
	full2comp(full, apath, afile);

	intern = sys_open(apath, afile); /* Interne Datei? */

	/* AusfÅhrbares Programm ? */
	if (!intern) {
		t = is_appl(full);
		if (t) {
			/* Als Applikation angemeldet ? */
			appl = app_find(full);
			if (!appl) {
				/* Nein */
				strcpy(app.name, full);
				app_default(&app);
				strcpy(app.title, afile);
				appl = &app;
			}
			ret = app_start(appl, parm, apath, &rex);
			pfree(full);
			return (ret);
		}

		only_filename:
		/* Applikation fÅr diese Datei angemeldet ? */
		appl = app_match(0, afile, &aok);
		if (appl) {
			ret = app_start(appl, name, apath, &rex);
			pfree(full);
			return (ret);
		} else {
			/* Aehm - eventuell ein Viewer vorhanden? */
			if (!aok) {
				appl = app_match(1, afile, &aok);
				if (appl) {
					ret = app_start(appl, name, apath, &rex);
					pfree(full);
					return (ret);
				}
			}
		}

		/* Keine Applikation und kein Viewer verfÅgbar */
		if (!aok) {
			sprintf(almsg, rs_frstr[ALNOAPP], afile);
			frm_alert(1, almsg, altitle, conf.wdial, 0L);
		}
		pfree(full);
		return (0);
	} else {
		pfree(full);
		return (1);
	}
}

/**
 err_file()
 
 Ausgabe einer Fehlermeldung im Zusammenhang mit Dateioperationen
 -------------------------------------------------------------------------*/
void err_file(char *alstr, long code, char *name) {
	char lname[31], msg[256];
	short i, c;

	strShortener(lname, name, 30);
	i = c = 0;
	while (c < 2 && alstr[i]) {
		msg[i] = alstr[i];
		i++;
		if (alstr[i] == ']')
			c++;
	}
	strcpy(&msg[i], "|(TOS %ld)]");
	strcat(msg, &alstr[i + 1]);
	sprintf(almsg, msg, lname, code);
	frm_alert(1, almsg, altitle, conf.wdial, 0L);
}

/**
 show_help()

 Anzeige eines Hilfetextes mit ST-Guide
 -------------------------------------------------------------------------*/
void show_help(char *ref) {
#if 0
	short ap_id;
#endif
	short ok, rex;
	APPLINFO app;
	char *p;

	if (!showSTGuideHelp(STGUIDEHELPFILE, ref)) {
		/* In einer Multitasking-Umgebung ggf. nachladen, sonst mosern. */
		ok = FALSE;
		if (tb.sys & SY_MULTI) {
			p = getenv("STGUIDE");
			if (p) {
				ok = TRUE;
				strcpy(app.name, p);
				app_default(&app);
				app.overlay = 0;
				app.single = 0;
				app_start(&app, aesBuffer, 0L, &rex);
			}
		}
		if (!ok)
			frm_alert(1, rs_frstr[ALNOGUIDE], altitle, conf.wdial, 0L);
	}
#if 0
	/* Kommandozeile */
	strcpy(aesbuf, "*:\\thing.hyp");
	if (ref) {
		strcat(aesbuf, " ");
		strcat(aesbuf, ref);
	}

	/* ST-Guide vorhanden? */
	ap_id = appl_find("ST-GUIDE");
	if (ap_id >= 0)
		appl_send(ap_id, VA_START, PT34, (long) aesbuf, 0, 0, 0, 0);
	else {
		/* In einer Multitasking-Umgebung ggf. nachladen, sonst mosern. */
		ok = 0;
		if (tb.sys & SY_MULTI) {
			p = getenv("STGUIDE");
			if (p) {
				ok = 1;
				strcpy(app.name, p);
				app_default(&app);
				app.overlay = 0;
				app.single = 0;
				app_start(&app, aesbuf, 0L, &rex);
			}
		}
		if (!ok)
			frm_alert(1, rs_frstr[ALNOGUIDE], altitle, conf.wdial, 0L);
	}
#endif
}

/**
 key_clr()

 Lîscht noch anstehende Tastatur-Events um z.B. beim Scrollen von
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
 msg_clr()

 Filtert ausser Protokoll- und Redraw-Messages alle anderen
 Messages aus der Queue, um nach einem Fensterdialog etc. das
 unbeabsichtigte Toppen von Fenstern zu verhindern
 -------------------------------------------------------------------------*/
void msg_clr(void) {
	EVENT event;
	short done, top;

	/* Evtl. laufende Hintergrund-Jobs einfrieren. */
	glob.sm_format++;

	event.ev_mflags = MU_TIMER | MU_MESAG;
	event.ev_mtlocount = 10;
	event.ev_mthicount = 0;
	done = 0;
	while (!done) {
		EvntMulti(&event);
		if (event.ev_mwich != MU_MESAG)
			done = 1;
		if (event.ev_mwich & MU_MESAG) {
			switch (event.ev_mmgpbuf[0]) {
			case WM_REDRAW:
				handle_win(event.ev_mmgpbuf[3], event.ev_mmgpbuf[0],
						event.ev_mmgpbuf[4], event.ev_mmgpbuf[5],
						event.ev_mmgpbuf[6], event.ev_mmgpbuf[7],
						event.ev_mmokstate);
				break;
			case WM_NEWTOP:
			case WM_ONTOP:
			case WM_TOPPED:
			case WM_FULLED:
			case WM_ARROWED:
			case WM_HSLID:
			case WM_VSLID:
			case WM_SIZED:
			case WM_MOVED:
			case WM_UNTOPPED:
			case WM_M_BDROPPED:
			case WM_BOTTOMED:
				break;
			default:
				handle_fmsg(&event, 0L);
				break;
			}
		}
	}

	get_twin(&top);
	win_newtop(win_getwinfo(top));

	/* Eingefrorene Jobs weiterlaufen lassen */
	glob.sm_format--;
	if (glob.sm_format)
		do_job(JB_FORMAT);
}

/**
 prlong()

 Schreibt eine Long-Zahl in der Form "999.999.999" in einen String.
 -------------------------------------------------------------------------*/
void prlong(unsigned long v, char *str) {
	char lstr[10];
	short i, j;

	sprintf(lstr, "%9lu", v);
	j = 0;
	for (i = 0; i < 10; i++) {
		if (lstr[i] != ' ') {
			if ((i == 3 && lstr[2] != ' ') || (i == 6 && lstr[5] != ' ')) {
				str[j] = glob.langdec;
				j++;
			}
			str[j] = lstr[i];
			j++;
		}
	}
	str[j] = 0;
}

void prlong11(unsigned long v, char *str) {
	char lstr[11];
	short i, j;

	sprintf(lstr, "%10lu", v);
	j = 0;
	for (i = 0; i < 11; i++) {
		if (lstr[i] != ' ') {
			if ((i < 10) && ((i % 3) == 1) && (lstr[i - 1] != ' ')) {
				str[j] = glob.langdec;
				j++;
			}
			str[j] = lstr[i];
			j++;
		}
	}
	str[j] = 0;
}

/**
 sys_open()

 PrÅft, ob es sich bei der angegebenen Datei um eine 'interne' Datei
 handelt (z.B. Gruppen, Icons etc.) und îffnet diese ggf.
 -------------------------------------------------------------------------*/
short sys_open(char *path, char *name) {
	short ret, i;
	char full[MAX_PLEN], lname[MAX_FLEN];

	ret = 0;
	if (!strcmp(path, tb.homepath)) {
		/* Startverzeichnis von Thing? */
		if (!strcmp(FNAME_PRG, name)) {
			/* Thing selber? */
			frm_alert(1, rs_frstr[ALDOUBLE], altitle, conf.wdial, 0L);
			ret = 1;
		}
	}
	/* Eventuell Gruppendatei? */
	if (!ret) {
		i = 0;
		while (name[i]) {
			lname[i] = nkc_toupper(name[i]);
			i++;
		}
		lname[i] = 0;
		if (wild_match1(GRP_MASK, lname)) {
			strcpy(full, path);
			strcat(full, name);
			wgrp_open(full, 0L, 0L);
			ret = 1;
		}
	}

	return (ret);
}

/**
 file_header()

 Kommentar am Anfang von Konfigurationsdateien erzeugen
 -------------------------------------------------------------------------*/
void file_header(FILE *fh, char *msg, char *name) {
	unsigned short sdate, stime;

	sdate = Tgetdate();
	stime = Tgettime();

	fprintf(fh, "# %s (%s)\n", msg, name);
	fprintf(fh, "# %02u-%02u-%04u / %02u:%02u\n", sdate & 0x001f,
			(sdate & 0x1e0) >> 5, 1980 + ((sdate & 0xfe00) >> 9),
			(stime & 0xf800) >> 11, (stime & 0x7e0) >> 5);
	fprintf(fh, "#\n");
}

/**
 * update_title
 *
 * Aktualisiert bei Bedarf den Titel eines Laufwerksicons.
 *
 * Eingabe:
 * drive: Betroffenes Laufwerk (0 = A:, ...)
 */
void title_update(short drive) {
	char label[MAX_FLEN];
	ICONDESK *p;

	if ((drive >= 0) && (drive < MAXDRIVES)) {
		p = desk.dicon + drive + 1;
		if ((p->class == IDDRIVE) && p->spec.drive->uselabel) {
			*label = 0;
			if (get_label(drive, label, MAX_FLEN))
				*label = 0;
			if (!*label)
				strcpy(label, p->spec.drive->deftitle);
			if (strcmp(p->title, label)) {
				strcpy(p->title, label);
				icon_redraw(drive + 1);
			}
		}
	}
}

/**
 fsinfo()

 Infos Åber ein Dateisystem ermitteln
 -------------------------------------------------------------------------*/
#ifdef DEBUG
void fsinfo_debug(char *file, short line, char *name, FILESYS *fs) {
DEBUGLOG((0, "fsinfo() called in file %s, line %d\n", file, line));
	fs_info(name, fs);
}
#endif

void fs_info(char *name, FILESYS *filesys) {
	XATTR xattr;
	long mode, ret;
	short namelen;
	char lpath[MAX_PLEN], *p;

DEBUGLOG((0, "fsinfo(%s)\n", name));
	/* Default-Werte, falls kein MiNT etc. vorhanden ist */
	filesys->flags = UPCASE | TOS;
	filesys->namelen = 12;
	if (*name)
		filesys->biosdev = (*name & ~32) - 'A';
	else
		filesys->biosdev = Dgetdrv();

	if (!name[0]) {
DEBUGLOG((0, "fsinfo: Name is empty, exiting\n"));
		return;
	}

	strcpy(lpath, name);
	lpath[0] = nkc_toupper(lpath[0]);
	p = strrchr(lpath, '\\');
	if (p)
		p[1] = 0;

	/* Aktuelles Verzeichnis setzen */
DEBUGLOG((0, "fsinfo: Setting dir to %s\n", lpath));
	if (set_dir(lpath)) {
DEBUGLOG((0, "fsinfo: set_dir() failed, exiting\n"));
		return;
	}

	mode = Dpathconf(".", -1);
	if (mode < 0L) {
		/* Kein Dpathconf() verfÅgbar */
		clr_drv();
DEBUGLOG((0, "fsinfo: No Dpathconf() available (%ld), exiting\n", mode));
		return;
	}
DEBUGLOG((0, "fsinfo: max. mode for Dpathconf(): %ld\n", mode));

	filesys->flags |= UNIXATTR | OWNER | STIMES | SYMLINKS;
	/* Maximale LÑnge eines Dateinamens ermitteln */
	if (mode >= 3) {
		ret = Dpathconf(".", 3);
		/* Bei Fehler 'normal' ermitteln */
		if (ret < 0L)
			ret = Dpathconf(lpath, 3);

		if (ret == 0x7fffffffL)
			namelen = MAX_FLEN - 1;
		else
			namelen = (short) ret;
		if (namelen >= MAX_FLEN)
			namelen = MAX_FLEN - 1;
		if (namelen < 12)
			namelen = 12; /* Kleiner Patch */
		filesys->namelen = namelen;
	}

	/* TOS-Modus (8+3) ermitteln */
	if (mode >= 5) {
		ret = Dpathconf(".", 5);
		/* Bei Fehler 'normal' ermitteln */
		if (ret < 0L)
			ret = Dpathconf(lpath, 5);
		if (ret >= 0L)
			switch ((short) ret) {
			case 0: /* Kein TOS-System */
			case 1:
				filesys->flags &= ~TOS;
				break;
			case 2: /* TOS (8+3) */
				filesys->flags |= TOS;
				filesys->flags &= ~UNIXATTR;
				break;
			}
	}

	/* PrÅfen, ob case-sensitiv */
	if (mode >= 6) {
		ret = Dpathconf(".", 6);
		/* Bei Fehler 'normal' ermitteln */
		if (ret < 0L)
			ret = Dpathconf(lpath, 6);
		if (ret >= 0L)
			switch ((short) ret) {
			case 0: /* case-sensitiv */
			case 2:
				filesys->flags &= ~UPCASE;
				break;
			case 1: /* nicht case-sensitiv */
				filesys->flags |= UPCASE;
				break;
			}
	}

	/* PrÅfen, ob Unix-Filemodi vorhanden sind */
	ret = -32L;
	if (mode >= 7) {
		ret = Dpathconf(".", 7);
		if (ret < 0L)
			ret = Dpathconf(lpath, 7);
DEBUGLOG((0, "fsinfo: Dpathconf(7) -> %lo (0x%lx)\n", ret, ret));
		if (ret >= 0L) {
			if ((ret & (0xfffL << 8L)) == 0)
				filesys->flags &= ~UNIXATTR;
			if ((ret & 0x01000000L) == 0L)
				filesys->flags &= ~SYMLINKS;
		}
	}

	/*
	 * Unter MagiC auch dann als nicht vorhanden ansehen, wenn das FS
	 * Dpathconf-Modus 7 nicht unterstÅtzt
	 */
	if ((ret < 0L) && (tb.sys & SY_MAGX))
		filesys->flags &= ~(UNIXATTR | OWNER | STIMES);

	if (mode >= 8) {
		ret = Dpathconf(".", 8);
		if (ret < 0L)
			ret = Dpathconf(lpath, 8);
		if (ret >= 0L) {
			/* PrÅfen, ob Fileeigner oder -gruppe unterstÅtzt wird */
			if (ret & 0x30)
				filesys->flags |= OWNER;
			else
				filesys->flags &= ~OWNER;
			/* PrÅfen, ob a- oder ctime unterstÅtzt wird */
			if (ret & 0x600)
				filesys->flags |= STIMES;
			else
				filesys->flags &= ~STIMES;
			/* PrÅfen, ob dev-Feld gÅltig und ggf. Åbernehmen */
			if (ret & 2) {
				ret = Fxattr(1, ".", &xattr);
				if (ret < 0L)
					ret = Fxattr(1, lpath, &xattr);
				if ((ret == 0L) && ((short) xattr.dev >= 0) && (xattr.dev < 32))
					filesys->biosdev = xattr.dev;
			}
		}
	}
	title_update(filesys->biosdev);
DEBUGLOG((0, "fsinfo: Result:\n"));
DEBUGLOG((0, "  upcase: %d\n", filesys->flags & UPCASE));
DEBUGLOG((0, "  namelen: %d\n", filesys->namelen));
DEBUGLOG((0, "  tos: %d\n", filesys->flags & TOS));
DEBUGLOG((0, "  unixattr: %d\n", filesys->flags & UNIXATTR));
DEBUGLOG((0, "  owner: %d\n", filesys->flags & OWNER));
DEBUGLOG((0, "  stimes: %d\n", filesys->flags & STIMES));
DEBUGLOG((0, "  biosdev: %d\n", filesys->biosdev));
	clr_drv();
}

/**
 * Verzeichniss des aktuellen LW auf '\' setzen, und als aktuelles
 * LW/Verzeichnis das Startverzeichnis von Thing setzen -
 * - z.B. nach AusfÅhrung eines Programms, das evtl. die Pfade verÑndert hat
 */
void clr_drv(void) {
	Dsetpath("\\");
	set_dir(tb.homepath);
}

/**
 * Dateinamen an ein Dateisystem anpassen (case-sensitiv, TOS etc.)
 *
 * @param *name
 * @param *filesys
 */
void fsconv(char *name, FILESYS *filesys) {
	short i, j, isfl;
	char *p, *pn;
	char newname[MAX_FLEN];

DEBUGLOG((0, "fsconv(%s)\n", name));
DEBUGLOG((0, "fsconv: filesys->upcase: %d\n", filesys->flags & UPCASE));
DEBUGLOG((0, "fsconv: filesys->tos: %d\n", filesys->flags & TOS));
DEBUGLOG((0, "fsconv: filesys->namelen: %d\n", filesys->namelen));
	i = 0;
	while (name[i])
		i++;
	i--;
	if (name[i] == '\\')
		isfl = 1;
	else
		isfl = 0;

	/* Dateiname? */
	if ((name[1] && name[1] != ':') || !name[1])
		pn = name;
	else {
		/* Nein - kompletter Pfad */
		if (isfl) {
			name[i] = 0;
			i--;
		}
		while (name[i] != '\\' && i > 0)
			i--;
		if (name[i] == '\\')
			i++;
		pn = &name[i];
		if (!pn[0])
			return;
	}

	/* Nur Grossbuchstaben? */
	if (filesys->flags & UPCASE) {
		i = 0;
		while (pn[i]) {
			pn[i] = nkc_toupper(pn[i]);
			i++;
		}
	}

	/* TOS-Konvention (8+3)? */
	if (filesys->flags & TOS) {
		p = strrchr(pn, '.');
		/* Dateiname max. 8 Zeichen */
		i = j = 0;
		while (pn[i] && &pn[i] != p && j < 8) {
			if (pn[i] == '.')
				i++;
			if (pn[i]) {
				newname[j] = pn[i];
				j++;
				i++;
			}
		}

		/* Extension, maximal 3 Zeichen */
		if (p) {
			newname[j] = '.';
			j++;
			i = 1;
			while (p[i] && i < 4) {
				newname[j] = p[i];
				j++;
				i++;
			}
		}
		newname[j] = 0;
		strcpy(pn, newname);
		if (isfl)
			strcat(pn, "\\");

		/* Leerzeichen in Unterstriche verwandeln */
		for (p = pn; *p; p++) {
			if (*p == ' ')
				*p = '_';
		}
	} else {
		/* Kein TOS-System, dann evtl. LÑngenbegrenzung */
		i = (short) strlen(pn);
		if (i > filesys->namelen)
			pn[filesys->namelen - 1] = 0;
		if (isfl)
			strcat(pn, "\\");
	}
}

/**
 setfpop()

 Setzt die wÑhlbaren EintrÑge im F-Tasten-Popup
 -------------------------------------------------------------------------*/
short setfpop(char *name) {
	short i, ret;

	ret = 4;
	for (i = 5; i < 45; i++) {
		if (!conf.fkey[i - 5][0])
			rs_trindex[POPFSHORT][i].ob_state &= ~DISABLED;
		else {
			if (!strcmp(conf.fkey[i - 5], name)) {
				ret = i;
				rs_trindex[POPFSHORT][i].ob_state &= ~DISABLED;
			} else
				rs_trindex[POPFSHORT][i].ob_state |= DISABLED;
		}
	}

	return ret;
}

/**
 * get_dir_entry
 *
 * Liest aus einen gegebenen Verzeichnis den jeweils nÑchsten Eintrag
 * und liefert ihn und seine Attribute zurÅck. Muû immer(!) so oft
 * aufgerufen werden, bis ein Fehlercode geliefert wird, da bei
 * Vorhandensein von Dopendir & Co. sonst das Handle nicht
 * geschlossen und falsche EintrÑge geliefert werden.
 *
 * Eingabe:
 * dirpath: Pfad des auszulesenden Verzeichnisses
 * buf: Zeiger auf Puffer fÅr den Dateinamen inklusive 4 Bytes Index
 *      am Anfang
 * len: Platz in buf (mindestens 4, ohne Nullbyte)
 * xattr: Zeiger auf zu belegende XATTR-Struktur
 *
 * RÅckgabe:
 * 0L: Alles OK
 * <0: Fehler beim Einlesen aufgetreten (Spezialfall: -49 (ENMFIL),
 *     keine weiteren Files mehr)
 */
long get_dir_entry(char *dirpath, char *buf, short len, XATTR *xattr) {
	static short first_call = 1;
	static short has_dxreaddir = 1;
	static long dirhandle = 0L;
	static _DTA my_dta;
	_DTA *old_dta;
	long ret, xret;
	char temp[MAX_PLEN + MAX_FLEN];

	if (!*dirpath)
		return (-34L);
	if (len < 4)
		return (-64L);
	if (first_call) {
		ret = Dopendir(dirpath, 0);
		if (ret == -32L) {
			dirhandle = 0L;
			old_dta = Fgetdta();
			Fsetdta(&my_dta);
			strcpy(temp, dirpath);
			if (temp[strlen(temp) - 1] != '\\')
				strcat(temp, "\\");
			strcat(temp, "*.*");
			ret = Fsfirst(temp, 0x17);
			while (!ret && (my_dta.dta_attribute == 0xf))
				ret = Fsnext();
			Fsetdta(old_dta);
			if (ret >= 0L) {
				*(long *) buf = 0L;
				strcpy(&buf[4], my_dta.dta_name);
				fill_xattr(dirpath, xattr, &my_dta);
				first_call = 0;
			}
			return (ret);
		}
		if ((ret & 0xff000000L) == 0xff000000L)
			return (ret);
		dirhandle = ret;
		first_call = 0;
		has_dxreaddir = 1;
		goto read_entry;
	} else {
		if (dirhandle) {
			read_entry: if (has_dxreaddir)
				ret = Dxreaddir(len, dirhandle, buf, xattr, &xret);
			else
				ret = -32L;
			if (ret == -32L) {
				has_dxreaddir = 0;
				ret = Dreaddir(len, dirhandle, buf);
				if (ret >= 0L) {
					strcpy(temp, dirpath);
					if (temp[strlen(temp) - 1] != '\\')
						strcat(temp, "\\");
					strcat(temp, &buf[4]);
					xret = Fxattr(1, temp, xattr);
				}
			}
			if ((ret < 0L) || (xret < 0L)) {
				Dclosedir(dirhandle);
				dirhandle = 0L;
				first_call = 1;
				return (ret);
			}
			return (0L);
		} else {
			old_dta = Fgetdta();
			Fsetdta(&my_dta);
			do {
				ret = Fsnext();
			} while (!ret && (my_dta.dta_attribute == 0xf));
			Fsetdta(old_dta);
			if (ret >= 0L) {
				*(long *) buf = 0L;
				strcpy(&buf[4], my_dta.dta_name);
				fill_xattr(dirpath, xattr, &my_dta);
			} else
				first_call = 1;
			return (ret);
		}
	}

  return (-34L);
}

/**
 * fill_xattr
 *
 * FÅllt eine XATTR-Struktur anhand einer gegebenen DTA.
 *
 * Eingabe:
 * path: Zugehîriger Pfad
 * xattr: Zeiger auf die zu fÅllende XATTR-Struktur
 * the_dta: Zeiger auf die Quell-DTA
 */
void fill_xattr(char *path, XATTR *xattr, _DTA *the_dta) {
	xattr->mode = (the_dta->dta_attribute & 16) ?
					(S_IFDIR | (0777 & ~glob.umask)) :
					(S_IFREG | (0666 & ~glob.umask));
	if (the_dta->dta_attribute & 1)
		xattr->mode &= ~0222;
	xattr->index = 0L;
	if (path[1] == ':')
		xattr->dev = (path[1] & ~32) - 'A';
	else
		xattr->dev = (short) Dgetdrv();
	xattr->nlink = 1;
	xattr->uid = xattr->gid = 0;
	xattr->size = the_dta->dta_size;
	xattr->blksize = 1024L;
	xattr->nblocks = the_dta->dta_size / 1024L;
	if (the_dta->dta_size % 1024L)
		xattr->nblocks++;
	xattr->mtime = xattr->atime = xattr->ctime = the_dta->dta_time;
	xattr->mdate = xattr->adate = xattr->cdate = the_dta->dta_date;
	xattr->attr = the_dta->dta_attribute;
}

/**
 * get_buf_entry
 *
 * Ermittelt den nÑchsten Filenamen aus einem Puffer, dessen EintrÑge
 * durch Leerzeichen getrennt und ggf. von Quotes (') umschlossen
 * sind. Der ermittelte Filename enthÑlt keine Quotes mehr.
 *
 * Eingabe:
 * buf: Zeiger auf den Puffer, muû bzw. darf nur beim ersten Aufruf
 *      fÅr buf angegeben werden, danach muû fÅr buf ein Nullzeiger
 *      Åbergeben werden, damit get_buf_entry den nÑchsten Eintrag
 *      ermitteln kann
 * name: Hierhin wird der nÑchste Filename kopiert. Da dieser mit
 *       komplettem Pfad versehen sein kann, sollte name ausreichend
 *       Platz bieten.
 * newpos: Wenn ungleich NULL, wird hier der Zeiger auf die nÑchste
 *         Leseposition abgelegt, so daû man get_buf_entry auch
 *         wechselseitig mit zwei oder mehr Puffern verwenden kann.
 *         Der Wert wird nur gesetzt, wenn ein Eintrag gelesen werden
 *         konnte, der Returncode also 1 ist.
 *
 * RÅckgabe:
 * 0: Kein weiterer (gÅltiger) Filename mehr in buf (ein Filename ist
 *    z.B. ungÅltig, wenn er falsch gequotet wurde)
 * 1: name enthÑlt den nÑchsten Filenamen
 */
short get_buf_entry(char *buf, char *name, char **newpos) {
	static char *bufpos;
	char *pos;
	short closed;

	if (buf != 0L)
		pos = buf;
	else
		pos = bufpos;

	/* Eventuell war der letzte Filename ungÅltig, dann abbrechen */
	if (pos == 0L)
		return (0);

	/* Erstmal fÅhrende Leerzeichen Åberlesen */
	for (; *pos == ' '; pos++)
		;
	/* Gibt es Åberhaupt noch einen Filenamen? */
	if (!*pos)
		return (0);

	if (*pos != '\'') {
		/*
		 * Wenn der Filename nicht mit einem Quote beginnt, bis zum nÑchsten
		 * Leerzeichen kopieren
		 */
		for (; *pos && (*pos != ' '); *name++ = *pos++)
			;
	} else {
		/* Sonst den Filenamen "entquoten" */
		closed = 0;
		for (pos++;;) {
			/* Bei einem Nullbyte abbrechen (gibt ungÅltigen Filenamen) */
			if (!*pos)
				break;
			if (*pos == '\'') {
				/*
				 * Ist das aktuelle Zeichen ein Quote, gibt es folgende FÑlle zu
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
	 * Puffer fÅr den nÑchsten Aufruf merken
	 */
	*name = 0;
	bufpos = pos;
	if (newpos != 0L)
		*newpos = pos;
	return 1;
}

/**
 * file_exists
 *
 * PrÅft, ob ein File existiert und liefert bei Bedarf dessen
 * XATTR-Struktur.
 *
 * Eingabe:
 * fname: Zeiger auf zu ÅberprÅfenden Dateinamen
 * follow: Symbolische Links verfolgen (1) oder nicht (0)
 * xattr: Zeiger auf zu fÅllende XATTR-Struktur oder NULL
 *
 * RÅckgabe:
 * 0: File existiert, *xattr ggf. gefÅllt
 * sonst: GEMDOS-Fehlermeldung, File existiert nicht,
 *        Inhalt von *xattr undefiniert
 */
short file_exists(char *fname, short follow, XATTR *xattr) {
	_DTA my_dta, *old_dta;
	XATTR the_xattr;
	long ret;

	ret = Fxattr(!follow, fname, &the_xattr);
	if (ret == 0L) {
		if (xattr)
			*xattr = the_xattr;
		return (0);
	}
	if (ret != -32L)
		return ((short) ret);
	old_dta = Fgetdta();
	Fsetdta(&my_dta);
	ret = (long) Fsfirst(fname, 0x17);
	Fsetdta(old_dta);
	if (ret == 0L) {
		if (xattr)
			fill_xattr(fname, xattr, &my_dta);
		return (0);
	}
	return ((short) ret);
}

/**
 * adjust_text
 *
 * Passt bei allen Dialogen die Textfelder an 3D-Look und -hinter-
 * grundfarbe an.
 *
 * Eingabe:
 * _3d: 3D-Look an (1) oder aus (0)
 * _3dcol: Hintergrundfarbe fÅr 3D-Look (wenn _3d == 1)
 * tree: Nummer des Baums (-1 fÅr alle)
 */
void adjust_text(short _3d, short _3dcol, short tree) {
	short bg, i;

	if (_3d && (tb.colors >= 16))
		bg = _3dcol;
	else
		bg = G_WHITE;
	if (tree == -1) {
		for (i = 0; i < NUM_TREE; i++)
			rs_textadjust(rs_trindex[i], bg);
	} else
		rs_textadjust(rs_trindex[tree], bg);
}

/**
 * get_username
 *
 * Ermittelt zu einer UID den passenden Usernamen.
 *
 * Eingabe:
 * uid: Gesuchte UID
 *
 * RÅckgabe:
 * NULL: Zu dieser UID existiert kein Name mit maximal 8 Zeichen
 * sonst: Zeiger auf Usernamen
 */
char *get_username(short uid) {
	UGNAME *search;

	for (search = glob.usernames; search != NULL; search = search->next) {
		if ((search->id == uid) && (strlen(search->name) <= 8))
			return (search->name);
	}
	return (NULL);
}

/**
 * get_groupname
 *
 * Ermittelt zu einer GUD den passenden Gruppennamen.
 *
 * Eingabe:
 * gid: Gesuchte GID
 *
 * RÅckgabe:
 * NULL: Zu dieser GID existiert kein Name mit maximal 8 Zeichen
 * sonst: Zeiger auf Gruppennamen
 */
char *get_groupname(short gid) {
	UGNAME *search;

	for (search = glob.groupnames; search != NULL; search = search->next) {
		if ((search->id == gid) && (strlen(search->name) <= 8))
			return (search->name);
	}
	return (NULL);
}

/**
 * quote
 *
 * Quotet ggf. einen Filenamen. Die Funktion hÑlt sich dabei sehr
 * strikt an die Regeln, d.h. es wird nur dann gequotet, wenn der
 * Filename mit einem einfachen Hochkomma beginnt oder ein
 * Leerzeichen enthÑlt.
 *
 * Eingabe:
 * fname: Zu quotender Filename
 */
void quote(char *fname) {
	char hlp[MAX_PLEN], *spos, *dpos;

	if ((*fname == '\'') || (strchr(fname, ' ') != NULL)) {
		strcpy(hlp, fname);
		dpos = fname;
		*(dpos++) = '\'';
		for (spos = hlp; *spos; spos++) {
			if (*spos == '\'')
				*(dpos++) = *spos;
			*(dpos++) = *spos;
		}
		*(dpos++) = '\'';
		*dpos = 0;
	}
}

/**
 * has_quotes
 *
 * Ermittelt, ob ein Puffer gequotete Filenamen enthÑlt.
 *
 * Eingabe:
 * buf: Zeiger auf zu testenden Puffer
 *
 * RÅckgabe:
 * 0: Puffer ist quotefrei
 * sonst: Puffer enthÑlt entsprechend viele gequotete Filenamen
 */
short has_quotes(char *buf) {
	short cnt;
	char hlp[MAX_PLEN], *pos;

	pos = buf;
	cnt = 0;
	while (get_buf_entry(pos, hlp, &pos)) {
		if ((*hlp == '\'') || (strchr(hlp, ' ') != NULL))
			cnt++;
	}
	return (cnt);
}

/**
 * count_char
 *
 * ZÑhlt die Vorkommen eines Zeichens in einem String. Dabei werden
 * direkt aufeinanderfolgende Vorkommen als eines gezÑhlt.
 *
 * Eingabe:
 * str: Zu durchsuchender String
 * which: Zu zÑhlendes Zeichen
 *
 * RÅckgabe:
 * Anzahl der Vorkommen von which in str.
 */
short count_char(char *str, char which) {
	short count = 0;
	char *p;

	for (p = str; *p;) {
		if (*p == which) {
			count++;
			while (*p == which)
				p++;
		} else
			p++;
	}
	return (count);
}

/**
 * drv_ejectable
 *
 * PrÅft, ob ein Laufwerk ausgeworfen werden kann. Dabei ist nur der
 * Status "nicht auswerfbar" eindeutig, da nur per XHDI getestet
 * werden kann, es aber auch Laufwerke gibt, die per Dcntl()
 * ausgeworfen werden kînnen, ohne vom XHDI-Treiber verwaltet zu
 * werden (z.B. CD-ROMs). "Nicht auswerfbar" wird nur dann geliefert,
 * wenn bei den Flags des Laufwerks weder XH_TARGET_REMOVABLE noch
 * XH_TARGET_EJECTABLE gesetzt ist oder XH_TARGET_LOCKED gemeldet
 * wird.
 *
 * Eingabe:
 * drv: Zu testendes BIOS-Device
 *
 * RÅckgabe:
 * 0: Laufwerk sicher nicht auswerfbar
 * sonst: Laufwerk mîglicherweise auswerfbar
 */
short drv_ejectable(short drv) {
	unsigned short maj, min;
	unsigned long flags;

	if ((drv < 0) || (drv > 32))
		return (1);
	if (XHGetVersion()) {
		if (XHInqDev(drv, &maj, &min, 0L, 0L) == 0L) {
			if (XHInqTarget(maj, min, 0L, &flags, 0L) == 0L) {
				/*
				 * XH_TARGET_REMOVEABLE: 2
				 * XH_TARGET_EJECTABLE:  8
				 * XH_TARGET_LOCKED:     2^29
				 */
				if (((flags & 10) == 0) || (flags & (1L << 29L)))
					return (0);
			}
		}
	}
	return (1);
}

/**
 * full_fselect
 *
 * Ruft fselect() auf und kÅmmert sich dabei um Sachen wie Zerlegung
 * und Zusammensetzung des Pfades, Ermittlung des Defaultpfades,
 * Neuzeichnen des Dialogs, etc.
 *
 * Eingabe:
 * full: Zeiger auf vorzuselektierende Datei inklusive Pfad. Nach dem
 *       Aufruf steht hier die tatsÑchlich ausgewÑhlte Datei.
 * deflt: Zeiger auf vorzusektierende Datei, wenn full leer ist.
 *          Wenn NULL, wird das aktuelle Verzeichnis benutzt.
 * ext: Zeiger auf Filterextension
 * dironly: Es soll ein Verzeichnis ausgewÑhlt werden; ein eventuell
 *          auswgewÑhlter Dateiname wird also ignoriert
 * title: Zeiger auf Titel fÅr die Auswahlbox
 * freedret: Freedom non-modal aufrufen? (0/1)
 * freedid: ID fÅr Freedom, wenn freedret = 1
 * form: Zeiger auf aufrufendes Formular, ggf. NULL
 *
 * RÅckgabe:
 * 0: Dateiauswahl mit 'Abbruch' verlassen oder Aufruf fehlgeschlagen
 * 1: Dateiauswahl erfolgreich, ausgewÑhlte Datei steht in full
 * 2: Dateiauswahl erfolgreich, ausgewÑhlter Ordner steht in full
 */
short full_fselect(char *full, char *deflt, char *ext, short dironly, char *title, short freedret, short freedid, FORMINFO *fi) {
	char path[MAX_PLEN], name[MAX_FLEN], *p;
	short exbut, ret;
	FILESYS fs;

	if (!*full) {
		if (deflt)
			strcpy(full, deflt);
		else {
			full[0] = Dgetdrv() + 'A';
			full[1] = ':';
			Dgetpath(&full[2], 0);
			if (strrchr(full, 0)[-1] != '\\')
				strcat(full, "\\");
		}
	}
	full2comp(full, path, name);
	strcat(path, ext);
	ret = fselect(path, name, &exbut, title, freedret, freedid);
	if (fi && (fi->state != FST_WIN))
		frm_redraw(fi, ROOT);
	if (ret && exbut) {
		if (dironly)
			*name = 0;
		p = strrchr(path, '\\');
		if (p)
			p[1] = 0;
		comp2full(full, path, name);
		*full = nkc_toupper(*full);
		fsinfo(full, &fs);
		fsconv(full, &fs);
		if (*name)
			return (1);
		else
			return (2);
	}
	return (0);
}

/* EOF */
