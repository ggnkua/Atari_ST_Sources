/**
 * ThingFnd - Thing Find
 * Copyright (C) 1999-2012 Thomas Binder
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
 * @copyright  Thomas Binder 1999-2012
 * @author     Thomas Binder
 * @license    LGPL
 */

#include <gem.h>
#include <mintbind.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include "..\include\thingfnd.h"

#define MAX_NAMELEN		MAX_FLEN
#define MAX_TITLELEN	32
#define SEARCH_BUF		65536L

typedef struct {
	long magic;
	char *path, *full;
	short fsfirst;
	short dxreaddir;
	long dir;
	_DTA dta, *old;
} GNF;

static long do_search(char *searchpath, long *hits, short depth, short follow,
		char *filemask, short fm_case, short fm_dirs, unsigned short mindate,
		unsigned short maxdate, long minsize, long maxsize, char *contentmask,
		short cm_case, short cm_binary, short (*update)(char *current, long hits),
		FILE *result);
static short get_next_file(char *dirpath, GNF *handle, short follow, char *name,
		short namelen, XATTR *xattr);
static void fill_xattr(char *path, XATTR *xattr, _DTA *the_dta);
static short file_match(char *filename, char *match, short csense, short binary,
		short (*update)(char *current, long hits));
static char *fast_strstr(char *str1, long length, char *str2);
static void write_entry(short is_dir, FILE *result, char *path);

/**
 * search_main
 *
 * FÅhrt die Suche von ThingFnd durch. "Frontend" zu do_search().
 *
 * Eingabe:
 * drvbits: Zu durchsuchende Laufwerke, Belegung wie bei der
 *          gleichnamigen Systemvariablen
 * searchpath: Zu durchsuchender Pfad; wenn nicht NULL, bleibt
 *             drvbits unbeachtet
 * follow: Symbolische Links verfolgen?
 * filemask: Suchmaske, mit "Globbing-Wildcards" (*, ?, [])
 * fm_case: Falls nicht 0, wird die Groû/Kleinschreibung beim
 *          Dateivergleich berÅcksichtigt
 * fm_dirs: Suchmaske gilt auch fÅr Verzeichnisse
 * mindate: Keine gefundene Datei darf jÅnger als dieses GEMDOS-Datum
 *          sein
 * maxdate: Keine gefundene Datei darf Ñlter als dieses GEMDOS-Datum
 *          sein
 * minsize: Mindestgrîûe gefundener Dateien
 * maxsize: Maximalgrîûe gefundener Dateien
 * contentmask: Falls nicht NULL, Suchmaske fÅr den Dateiinhalt;
 *              darf ebenfalls "Globbing-Wildcards" enthalten
 * cm_case: Vergleiche im Dateiinhalt mit BerÅcksichtigung von
 *          Groû/Kleinschreibung?
 * cm_binary: Sollen auch BinÑrdateien durchsucht werden? In diesem
 *            Fall wird kein "Globbing" durchgefÅhrt
 * update: Zeiger auf Update-Funktion des Aufrufes. Parameter:
 *         current: Gerade bearbeitete Datei/Verzeichnis (kann NULL
 *                  sein, dann hat sich nichts geÑndert und es soll
 *                  nur auf Abbruch geprÅft werden)
 *         hits: Bisherige Treffer (-1L: keine énderung; -2L: keine
 *               énderung, Dateisuche aktiv)
 *         Wenn die Funktion 0 zurÅckliefert, wird die Suche
 *         abgebrochen
 * resultfile: Zeiger auf den Pfad der Ergebnisgruppe
 * resulttemplate: Pfad der Vorlage fÅr die Ergebnisgruppe
 *
 * RÅckgabe:
 * 0: OK
 * sonst: (GEMDOS-)Fehlermeldung
 */
long search_main(long drvbits, char *searchpath, short follow, char *filemask,
		short fm_case, short fm_dirs, unsigned short mindate, unsigned short maxdate,
		long minsize, long maxsize, char *contentmask, short cm_case,
		short cm_binary, short (*update)(char *current, long hits),
		char *resultfile, char *resulttemplate) {
	FILE *result, *template;
	long ret, hits;
	short i;
	char helppath[] = "A:\\", linebuf[1024];

	/* Gibt es Åberhaupt etwas zu durchsuchen? */
	if ((drvbits == 0L) && (searchpath == NULL))
		return (0L);

	/* Vorlage îffnen */
	if ((template = fopen(resulttemplate, "r")) == NULL)
		return (-1L);

	/* Ausgabedatei anlegen und initialisieren */
	if ((result = fopen(resultfile, "w")) == NULL) {
		fclose(template);
		return (-1L);
	}

	while (fgets(linebuf, 1024, template)) {
		if ((*linebuf == '#') || !strncmp(linebuf, "INFO ", 5)
				|| !strncmp(linebuf, "IGTA ", 5)
				|| !strncmp(linebuf, "IACL ", 5)
				|| !strncmp(linebuf, "PRNT ", 5)
				|| !strncmp(linebuf, "FONT ", 5)
				|| !strncmp(linebuf, "FCOL ", 5)
				|| !strncmp(linebuf, "BPAT ", 5)
				|| !strncmp(linebuf, "BPIC ", 5)) {
			fprintf(result, "%s", linebuf);
		}
	}
	fclose(template);
	fprintf(result, "\n");

	/* Je nach Suchmodus die eigentliche Suchfunktion aufrufen */
	if (searchpath) {
		hits = 0;
		ret = do_search(searchpath, &hits, 1, follow, filemask, fm_case,
				fm_dirs, mindate, maxdate, minsize, maxsize, contentmask,
				cm_case, cm_binary, update, result);
	} else {
		hits = 0;
		for (i = 0; i < 32; i++) {
			if (drvbits & 1) {
				ret = do_search(helppath, &hits, 1, follow, filemask, fm_case,
						fm_dirs, mindate, maxdate, minsize, maxsize,
						contentmask, cm_case, cm_binary, update, result);
				if (ret == 0x80000000L)
					break;
			}
			drvbits >>= 1;
			(*helppath)++;
		}
	}
	fclose(result);
	return ((ret == 0x80000000L) ? 0L : ret);
}

/**
 * do_search
 *
 * Die eigentliche Suchfunktion, wird von search_main() aufgerufen.
 *
 * Eingabe:
 * searchpath: Zu durchsuchender Pfad
 * hits: Zeiger auf long, in dem die Treffer gezÑhlt werden
 * depth: Aktuelle Rekursionstiefe
 * follow: Symbolische Links verfolgen?
 * filemask: Suchmaske, mit "Globbing-Wildcards" (*, ?, [])
 * fm_case: Falls nicht 0, wird die Groû/Kleinschreibung beim
 *          Dateivergleich berÅcksichtigt
 * fm_dirs: Suchmaske gilt auch fÅr Verzeichnisse
 * mindate: Keine gefundene Datei darf jÅnger als dieses GEMDOS-Datum
 *          sein
 * maxdate: Keine gefundene Datei darf Ñlter als dieses GEMDOS-Datum
 *          sein
 * minsize: Mindestgrîûe gefundener Dateien
 * maxsize: Maximalgrîûe gefundener Dateien
 * contentmask: Falls nicht NULL, Suchmaske fÅr den Dateiinhalt;
 *              darf ebenfalls "Globbing-Wildcards" enthalten
 * cm_case: Vergleiche im Dateiinhalt mit BerÅcksichtigung von
 *          Groû/Kleinschreibung?
 * cm_binary: Sollen auch BinÑrdateien durchsucht werden? In diesem
 *            Fall wird kein "Globbing" durchgefÅhrt
 * update: Zeiger auf Update-Funktion des Aufrufes. Parameter:
 *         current: Gerade bearbeitete Datei/Verzeichnis
 *         hits: Bisherige Treffer
 *         Wenn die Funktion 0 zurÅckliefert, wird die Suche
 *         abgebrochen
 * result: Zeiger auf FILE-Struktur der geîffneten Ergebnisgruppe
 *
 * RÅckgabe:
 * 0: OK
 * sonst: (GEMDOS-)Fehlermeldung, -2^32 bei Abbruch durch update()
 */
static long do_search(char *searchpath, long *hits, short depth, short follow,
		char *filemask, short fm_case, short fm_dirs, unsigned short mindate,
		unsigned short maxdate, long minsize, long maxsize, char *contentmask,
		short cm_case, short cm_binary, short (*update)(char *current, long hits),
		FILE *result) {
	char namebuf[MAX_NAMELEN + 5], path[4 * (MAX_NAMELEN + 1) + 1], *p;
	short ok, compare, match;
	long ret;
	GNF handle;
	XATTR xattr;

	if (depth++ == 10)
		return (-80L);
	for (p = filemask; *p == '*'; p++)
		;
	compare = *p;
	if (compare && !fm_case)
		strupr(filemask);
	if (!(update)(searchpath, *hits))
		return (0x80000000L);

	match = 0;
	for (ok = get_next_file(searchpath, &handle, follow, namebuf, (short) sizeof(namebuf), &xattr);
			ok;
			ok = get_next_file(NULL, &handle, follow, namebuf, (short) sizeof(namebuf), &xattr)) {
		if ((strlen(searchpath) + strlen(namebuf) + 2) > sizeof(path)) {
			get_next_file(NULL, &handle, follow, NULL, 0, NULL);
			return (-69);
		}
		strcpy(path, searchpath);
		if (strrchr(path, 0)[-1] != '\\')
			strcat(path, "\\");
		strcat(path, namebuf);
		if (compare && !fm_case)
			strupr(namebuf);
		if ((xattr.mode & S_IFMT) == S_IFDIR) {
			if (!strcmp(namebuf, ".") || !strcmp(namebuf, ".."))
				continue;
			if (fm_dirs) {
				if ((!compare || wild_match(namebuf, filemask))
						&& (contentmask == NULL) && (xattr.mdate >= mindate)
						&& (xattr.mdate <= maxdate) && (xattr.size >= minsize)
						&& (xattr.size <= maxsize)) {
					write_entry(1, result, path);
					(*hits)++;
				}
			}
			ret = do_search(path, hits, depth, follow, filemask, fm_case,
					fm_dirs, mindate, maxdate, minsize, maxsize, contentmask,
					cm_case, cm_binary, update, result);
			if ((ret == 0x80000000L) || !(update)(searchpath, *hits)) {
				get_next_file(NULL, &handle, follow, NULL, 0, NULL);
				return (0x80000000L);
			}
		} else {
			if (!(update)(NULL, *hits)) {
				get_next_file(NULL, &handle, follow, NULL, 0, NULL);
				return (0x80000000L);
			}
			if (compare && !wild_match(namebuf, filemask))
				continue;
			if (contentmask && ((xattr.mode & S_IFMT) != S_IFREG))
				continue;
			if ((xattr.size < minsize) || (xattr.size > maxsize))
				continue;
			if ((xattr.mdate < mindate) || (xattr.mdate > maxdate))
				continue;
			if ((contentmask == NULL) || ((match = file_match(path, contentmask, cm_case, cm_binary, update)) != 0)) {
				if (match == -1) {
					get_next_file(NULL, &handle, follow, NULL, 0, NULL);
					return (0x80000000L);
				}
				write_entry(0, result, path);
				(*hits)++;
			}
		}
	}
	return (0L);
}

/**
 * get_next_file
 *
 * Liefert den nÑchsten Eintrag aus einem Verzeichnis, inklusive
 * der dazugehîrigen XATTR-Struktur, die ggf. manuell erstellt
 * wird.
 *
 * Eingabe:
 * dirpath: Zu durchsuchendes Verzeichnis; darf nur beim ersten
 *          Aufruf gesetzt sein, fÅr alle weiteren muû NULL
 *          Åbergeben werden (der Pfad muû aber gÅltig bleiben!)
 * handle: Zeiger auf GNF-Struktur, in der Daten fÅr diese Suche
 *         abgelegt werden. Dadurch ist es mîglich, die Funktion
 *         problemlos rekursiv aufzurufen
 * follow: Symbolische Links verfolgen?
 * name: Zeiger auf Puffer fÅr den Dateinamen; wenn NULL, wird
 *       die aktuelle Suche abgebrochen
 * namelen: Grîûe von name in Byte (== maximale NamenslÑnge +
 *          Nullbyte + 4)
 * xattr: Zeiger auf XATTR-Struktur der gefundenen Datei
 *
 * RÅckgabe:
 * 1: Alles OK, Inhalt von name und xattr gÅltig
 * 0: Fehler aufgetreten oder keine weitere Datei mehr
 */
static short get_next_file(char *dirpath, GNF *handle, short follow, char *name,
		short namelen, XATTR *xattr) {
	long err, xerr;

	if (namelen < 17)
		return (0);
	if (dirpath != NULL) {
		memset(handle, 0, sizeof(GNF));
		handle->magic = 0xbeebbeebL;
		handle->path = dirpath;
		handle->dxreaddir = 1;
		handle->full = malloc(strlen(dirpath) + (size_t) namelen + 2);
		if (handle->full == NULL)
			return (0);

		if (Fxattr(0, ".", xattr) == -32L)
			handle->fsfirst = 1;
		else {
			handle->dir = Dopendir(dirpath, 0);
			if (handle->dir == -32L)
				handle->fsfirst = 1;
			else {
				if ((handle->dir & 0xff000000L) == 0xff000000L) {
					free(handle->full);
					handle->magic = 0L;
					return (0);
				}
				return (get_next_file(NULL, handle, follow, name, namelen, xattr));
			}
		}

		handle->old = Fgetdta();
		Fsetdta(&handle->dta);
		strcpy(handle->full, dirpath);
		if (strrchr(handle->full, 0)[-1] != '\\')
			strcat(handle->full, "\\");
		strcat(handle->full, "*.*");
		if (Fsfirst(handle->full, 0x17)) {
			free(handle->full);
			Fsetdta(handle->old);
			handle->magic = 0L;
			return (0);
		}

		strcpy(name, handle->dta.dta_name);
		fill_xattr(handle->path, xattr, &handle->dta);
		return (1);
	}

	if (handle->magic != 0xbeebbeebL)
		return (0);

	if (name == NULL) {
		free(handle->full);
		if (handle->fsfirst)
			Fsetdta(handle->old);
		else {
			free(handle->full);
			Dclosedir(handle->dir);
		}
		handle->magic = 0L;
		return (0);
	}

	if (handle->fsfirst) {
		if (Fsnext()) {
			free(handle->full);
			Fsetdta(handle->old);
			handle->magic = 0L;
			return (0);
		}
		strcpy(name, handle->dta.dta_name);
		fill_xattr(handle->path, xattr, &handle->dta);
		return (1);
	} else {
		if (handle->dxreaddir) {
/*fprintf(stderr, "\n7.1 (namelen %d; dir: %ld, name: %s)", namelen, handle->dir, name);*/
			err = Dxreaddir(namelen, handle->dir, name, (long *)xattr, &xerr);
			if (err == -32L)
				handle->dxreaddir = 0;
			else if (err || xerr) {
gnf_derror:
				free(handle->full);
				Dclosedir(handle->dir);
				handle->magic = 0L;
				return (0);
			} else {
				if (follow && ((xattr->mode & S_IFMT) == S_IFLNK))
					goto gnf_fxattr;
				else {
					strcpy(name, name + 4);
					return (1);
				}
			}
		}
		err = Dreaddir(namelen, handle->dir, name);
		if (err)
			goto gnf_derror;

gnf_fxattr:
		strcpy(handle->full, handle->path);
		if (strrchr(handle->full, 0)[-1] != '\\')
			strcat(handle->full, "\\");
		strcat(handle->full, name + 4);
		if (Fxattr(!follow, handle->full, xattr)) {
			if (follow) {
				return (get_next_file(NULL, handle, follow, name, namelen, xattr));
			}
			free(handle->full);
			Dclosedir(handle->dir);
			handle->magic = 0L;
			return (0);
		}
		strcpy(name, name + 4);
		return (1);
	}
}

/*
 * fill_xattr
 *
 * FÅllt eine XATTR-Struktur anhand einer gegebenen DTA.
 *
 * Eingabe:
 * path: Zugehîriger Pfad (nur Laufwerkskennung ist wichtig)
 * xattr: Zeiger auf die zu fÅllende XATTR-Struktur
 * the_dta: Zeiger auf die Quell-DTA
 */
static void fill_xattr(char *path, XATTR *xattr, _DTA *the_dta) {
	memset(xattr, 0, sizeof(XATTR));
	xattr->mode = (the_dta->dta_attribute & 16) ? (S_IFDIR | 0777) : (S_IFREG | 0666);
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

/* Shell-style pattern matching for ?, \, [], and * characters.
 I'm putting this replacement in the public domain.

 Written by Rich $alz, mirror!rs, Wed Nov 26 19:03:17 EST 1986.
 Some improvements by Thomas 'Gryf' Binder in 1998 */

/* The character that inverts a character class; '!' or '^'.  */
#define INVERT '^'

/* Return nonzero if `string' matches Unix-style wildcard pattern
 `pattern'; zero if not.  */

short wild_match(char *string, char *pattern) {
	short prev; /* Previous character in character class.  */
	short matched; /* If 1, character class has been matched.  */
	short reverse; /* If 1, character class is inverted.  */
	short esc; /* If 1, next character loses special meaning inside [] */

	for (; *pattern; string++, pattern++) {
		switch (*pattern) {
		case '\\':
			/* Literal match with following character */
			if (!*++pattern)
				return (0);
			/* else FALL THROUGH */
		default:
			if (*string != *pattern)
				return (0);
			continue;
		case '?':
			/* Match anything.  */
			if (*string == '\0')
				return (0);
			continue;
		case '*':
			/* Trailing star matches everything.  */
			while (*(++pattern) == '*')
				;
			if (!*pattern)
				return (1);
			while (*string)
				if (wild_match(string++, pattern))
					return (1);
			return (0);
		case '[':
			esc = 0;
			/* Check for inverse character class.  */
			reverse = pattern[1] == INVERT;
			if (reverse)
				pattern++;
			for (prev = 256, matched = 0;
					*++pattern && (esc || *pattern != ']');
					prev = esc ? prev : *pattern) {
				if (!esc && ((esc = *pattern == '\\') != 0))
					continue;
				if (!esc && *pattern == '-') {
					if (!*++pattern)
						return (0);
					if (*pattern == '\\')
						if (!*++pattern)
							return (0);
					matched = matched || (*string <= *pattern && *string >= prev);
				} else
					matched = matched || *string == *pattern;
				esc = 0;
			}
			if (prev == 256 || esc || *pattern != ']' || matched == reverse)
				return (0);
			continue;
		}
	}
	return (*string == '\0');
}

/**
 * file_match
 *
 * Sucht in einer Datei nach einem String/Pattern.
 *
 * Eingabe:
 * filename: Zu durchsuchende Datei
 * match: Zu suchender String, mit "Globbing-Wildcards" (*, ?, [])
 * csense: Vergleich mit Unterscheidung von Groû/Kleinschreibung?
 * binary: Soll "binÑr", also nicht zeilenorientiert gesucht werden?
 *         Falls ja, werden Wildcards in match ignoriert.
 * update: Zeiger auf Update-Funktion des Aufrufes. Parameter:
 *         current: Gerade bearbeitete Datei/Verzeichnis (hier NULL,
 *                  um anzuzeigen, daû sich nichts geÑndert hat)
 *         hits: Bisherige Treffer (hier -2L)
 *         Wenn die Funktion 0 zurÅckliefert, wird die Suche
 *         abgebrochen
 *
 * RÅckgabe:
 * 1: Treffer
 * 0: Fehler aufgetreten oder kein Treffer
 * -1: Benutzer hat in der Update-Funktion abgebrochen
 */
static short file_match(char *filename, char *match, short csense, short binary,
		short (*update)(char *current, long hits)) {
	char *buffer, *help, *last, *p, c;
	long size, read, i, err;
	short handle, found, abort, just_strstr = 0;

	if (!binary) {
		for (p = match; *p == '*'; p++)
			;
		if (!*p)
			return (1);
	}
	size = SEARCH_BUF + strlen(match) + 1;
	if ((buffer = malloc(size)) == NULL)
		return (0);
	help = buffer + SEARCH_BUF;
	if (!binary) {
		if (!csense) {
			for (p = match; *p && !isalpha(*p); p++)
				;
			if (!*p)
				csense = 1;
		}
		if (strpbrk(match, "*?[]\\") == NULL)
			just_strstr = 1;
		else {
			strcpy(help, match + 1);
			if (help[1]) {
				strrchr(help, 0)[-1] = 0;
				if ((*match == '*') && (strrchr(match, 0)[-1] == '*') && (strpbrk(help, "*?[]\\") == NULL)) {
					match = help;
					just_strstr = 1;
				}
			}
		}
	}
	if (!csense)
		strupr(match);
	if (just_strstr || binary)
		fast_strstr(NULL, 0L, match);
	if ((err = Fopen(filename, 0)) < 0L) {
		free(buffer);
		return (0);
	}
	handle = (short) err;
	found = abort = 0;
	if (binary) {
		size = SEARCH_BUF - 1;
		while ((read = Fread(handle, size, buffer)) > 0) {
			if (!csense) {
				p = buffer;
				for (i = 0; i < read; i++) {
					if (islower(*p))
						*p ^= 0x20;
					p++;
				}
			}
			found = fast_strstr(buffer, read, match) != NULL;
			if (found || (read != size) || (Fseek(-strlen(match) + 1, handle, 1) < 0L)) {
				break;
			}
			if (!(update)(NULL, -2L)) {
				abort = 1;
				break;
			}
		}
	} else {
		size = SEARCH_BUF - 1;
		while ((read = Fread(handle, size, buffer)) > 0) {
			buffer[read] = 0;
			if (just_strstr) {
				if (!csense)
					strupr(buffer);
				found = fast_strstr(buffer, 0L, match) != NULL;
				if (found || (read != size) || (Fseek(-strlen(match) + 1, handle, 1) < 0L)) {
					break;
				}
			} else {
				if (!csense)
					strupr(buffer);
				last = buffer;
				for (;;) {
					p = strpbrk(last, "\r\n");
					if (p) {
						c = *p;
						*p = 0;
						if (c == '\r')
							p += 2;
						else
							p++;
					} else if (read == size)
						break;
					found = wild_match(last, match);
					if (found || (p == NULL))
						break;
					last = p;
				}
				if (found)
					break;
				if (read != size)
					break;
				if (last && (last > buffer) && (Fseek((last - buffer) - read, handle, 1) < 0L)) {
					break;
				}
			}
			if (!(update)(NULL, -2L)) {
				abort = 1;
				break;
			}
		}
	}
	Fclose(handle);
	free(buffer);
	return (abort ? -1 : found);
}

/**
 * fast_strstr
 *
 * Schnelles strstr() mit intelligentem öberspringen. Basiert auf
 * Quicksearch, siehe auch c't 8/1997, S. 292ff. Ist nur fÅr FÑlle
 * brauchbar, in denen sehr hÑufig hintereinander die gleiche Folge
 * gesucht wird.
 *
 * Eingabe:
 * str1: Zu durchsuchender String; wenn NULL, wird ein statisches
 *       Array initialisiert, das von str2 abhÑngig ist. Dies MUSS
 *       vor dem ersten wirklichen Vergleich gemacht werden!
 * length: LÑnge von str1; falls Null wird die LÑnge via strlen()
 *         selbst ermittelt. Nur von Bedeutung wenn str1 nicht NULL.
 * str2: Zu suchender String
 *
 * RÅckgabe:
 * NULL: str2 ist in str1 nicht enthalten oder str1 war NULL
 * sonst: Startposition des ersten Vorkommens von str2 in str1
 */
static char *fast_strstr(char *str1, long length, char *str2) {
	char *maxpos, *p;
	long i, len;
	static long shift[256];

	len = strlen(str2);
	if (str1 == NULL) {
		for (i = 0; i < 256; i++)
			shift[i] = len + 1;
		for (i = 0; i < len; i++)
			shift[(unsigned char) str2[i]] = len - i;
		return (NULL);
	}

	maxpos = length ? (str1 + length - 1) : strrchr(str1, 0);
	for (p = str1; (p + len) <= maxpos;) {
		i = len - 1;
		while (p[i] == str2[i]) {
			if (!i--)
				return (p);
		}
		p += shift[(unsigned char) p[len]];
	}
	return (NULL);
}

/**
 * write_entry
 *
 * Schreibt ein gefundenes Objekt in die Ergebnisgruppe.
 *
 * Eingabe:
 * is_dir: Ist Objekt ein Verzeichnis?
 * result: Zeiger auf Handle der Ergebnisgruppe
 * path: Kompletter Pfad des gefundenen Objekts
 */
static void write_entry(short is_dir, FILE *result, char *path) {
	char title[MAX_TITLELEN + 1], *p;
	short l;

	fprintf(result, is_dir ? "OFLD \"" : "OFIL \"");
	if ((l = (short) strlen(path)) > MAX_TITLELEN) {
		strncpy(title, path, 10);
		strcpy(title + 10, "...");
		strcat(title, &path[l - MAX_TITLELEN + 13]);
	} else
		strcpy(title, path);
	for (p = title; *p; p++) {
		if ((*p == '\"') || (*p == '@') || ((unsigned char) *p < ' '))
			fprintf(result, "%02d", (short) *p);
		else
			fprintf(result, "%c", *p);
	}
	fprintf(result, "\" ");
	if (strchr(path, ' ') || (*path == '\'')) {
		fprintf(result, "\'");
		for (p = path; *p; p++) {
			if (*p == '\'')
				fprintf(result, "\'\'");
			else
				fprintf(result, "%c", *p);
		}
		if (is_dir)
			fprintf(result, "\\");
		fprintf(result, "\'");
	} else
		fprintf(result, "%s%s", path, is_dir ? "\\" : "");
	fprintf(result, " \"%s\"\n", is_dir ? "*" : "");
}

/* EOF */
