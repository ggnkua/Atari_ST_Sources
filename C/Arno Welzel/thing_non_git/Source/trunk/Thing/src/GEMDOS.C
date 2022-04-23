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
 * Verschiedene Funktionen fuer Dateinamen etc.
 */

#include "..\include\globdef.h"
#include "..\include\types.h"
#include "..\include\thingrsc.h"
#include <ctype.h>

/**
 * Separiert aus einem kompletten Dateinamen Pfad und Datei voneinander.
 *
 * @param *full Zeiger auf die Variable, die den kompletten Dateinamen enthaelt
 * @param *path Zeiger auf die Variable, die den Pfad enthalten soll
 * @param *file Zeiger auf die Variable, die den Dateinamen enthalten soll
 */
void full2comp(char *full, char *path, char *file) {
	char *p;

	strcpy(path, full);
	if (!path[0]) {
		path[0] = (char) Dgetdrv() + 65;
		path[1] = ':';
		Dgetpath(&path[2], 0);
		strcat(path, "\\");
	}
	p = strrchr(path, '\\');
	if (p) {
		strcpy(file, &p[1]);
		p[1] = 0;
	} else
		strcpy(file, "");
}

/**
 * Erzeugt aus einem Pfad und einer Datei einen kompletten Dateinamen.
 *
 * @param *full Zeiger auf die Variable, die den kompletten Dateinamen enthalten soll
 * @param *path Zeiger auf die Variable, die den Pfad enthaelt
 * @param *file Zeiger auf die Variable, die den Dateinamen enthaelt
 */
void comp2full(char *full, char *path, char *file) {
	strcpy(full, path);
	if (full[(int) strlen(full) - 1] != '\\')
		strcat(full, "\\");
	strcat(full, file);
}

/**
 * Prueft einen Pfad auf Zulaessigkeit.
 *
 * @param path Zeiger auf die Variable, die den Pfad enthaelt
 *
 * @return 1 - alles OK, 0 - sonst
 */
int valid_path(char *path) {
	char drv;

	/* Weniger als 3 Zeichen ("X:\")? */
	if ((int) strlen(path) < 3)
		return 0;

	/* Laufwerk unzulaessig? */
	drv = nkc_toupper(path[0]);
	if ((drv < 'A' || drv > 'Z'))
		return 0;

	/* Keine Laufwerksangabe am Anfang? */
	if (path[1] != ':')
		return 0;

	/* Kein Rootverzeichnis auf dem Laufwerk? */
	if (path[2] != '\\')
		return 0;

	/* Keine Fehler! */
	return 1;
}

/**
 * Prueft eine Dateimaske auf Zulaessigkeit.
 *
 * @param *mask Zeiger auf die Variable, die die Dateimaske enthaelt
 * @param wild 1 - Wildcards ausschliessen, 0 - sonst
 *
 * @return 1 - alles OK, 0 - sonst
 */
int valid_mask(char *mask, int wild) {
	int length, i;

	/* Nur pruefen, wenn Maske vorhanden */
	length = (int) strlen(mask);
	if (length) {
		for (i = 0; i < length; i++) {
			/* Unzulaessiges Zeichen in der Maske? */
			if ((unsigned char) mask[i] < 32 || mask[i] == '\\' || mask[i]
					== ':' || mask[i] == 34 || mask[i] == 64)
				return 0;

			/* Falls kein Wildcard erlaubt ... */
			if (!wild) {
				switch ((int) mask[i]) {
				case '*':
				case '[':
				case ']':
				case '?':
					return 0;
				}
			}
		}
	}

	/* Keine Fehler! */
	return 1;
}

/**
 * Prueft eine Extension auf Zulaessigkeit.
 *
 * @param *ext Zeiger auf die Variable, die die Extension enthaelt
 *
 * @return 1 - alles OK, 0 - sonst
 */
int valid_ext(char *ext) {
	int length, i;

	/* Nur pruefen, wenn Extension vorhanden */
	length = (int) strlen(ext);
	if (length) {
		for (i = 0; i < length; i++) {
			/* Unzulaessiges Zeichen in der Extension? */
			if ((unsigned char) ext[i] < 32 || ext[i] == '\\' || ext[i] == ':'
					|| ext[i] == '?' || ext[i] == '*' || ext[i] == '.'
					|| ext[i] == 34 || ext[i] == 64)
				return 0;
		}
	}

	/* Keine Fehler! */
	return 1;
}

/**
 is_app()

 PrÅfen, ob es sich bei einer Datei um ein Programm handelt
 -------------------------------------------------------------------------*/
int is_app(char *name, unsigned int mode) {
	char *p, *ext;
	int i, l, _ext[3];
	long *match;

	ext = (char *) _ext;
	l = 0;
	while (name[l])
		l++;
	l--;

	if (l > 0) {
		/* Erst Extension pruefen */
		while ((name[l] != '\\') && (name[l] != '.') && (l > 1))
			l--;

		p = &name[l];
		if (p[0] == '.') {
			i = 0;
			while (p[i] && i < 4) {
				ext[i] = nkc_toupper(p[i]);
				i++;
			}
			ext[i] = 0;
			match = (long *) ext;
			if (*match == '.APP' || *match == '.PRG')
				return 1;
			if (*match == '.TOS')
				return 2;
			if (*match == '.TTP')
				return 3;
			if (*match == '.ACC')
				return 4;
			if (*match == '.GTP')
				return 5;
			if (conf.altapp) {
				if (*match == '.PRX' || *match == '.APX')
					return 1;
				if (*match == '.ACX')
					return 4;
				if (conf.altcpx) {
					if (*match == '.CPZ' || *match == '.EPZ')
						return 6;
				}
			}
			if (conf.altcpx) {
				if (*match == '.CPX' || *match == '.EPX')
					return 6;
			}
		}
	}

	/* Evtl. x-Flags gesetzt - dann als TTP behandeln */
	if ((mode & 0111) != 0)
		return 3;

	return 0;
}

/**
 * is_appl
 *
 * Wie is_app, ermittelt mode aber selbst und liefert fuer leere Namen 'keine Applikation'.
 */
int is_appl(char *path) {
	FILESYS fs;
	XATTR xattr;

	if (!*path)
		return (0);

	fsinfo(path, &fs);
	if (!(fs.flags & UNIXATTR) || (Fxattr(0, path, &xattr) != 0L))
		xattr.mode = 0;
	return (is_app(path, xattr.mode));
}

/**
 * setdir
 *
 * Setzt aktuelles Laufwerk und aktuelles Verzeichnis auf das der
 * Åbergebenen Datei.
 *
 * Eingabe:
 * full: Zeiger auf die Datei / das Verzeichnis
 *
 * RÅckgabe:
 * 0: Verzeichnis gesetzt
 * sonst: (GEMDOS)-Fehlermeldung
 */
int setdir(char *full) {
	char path[MAX_PLEN], name[MAX_FLEN], *p;
	int drv;

LOG((0, "set_dir(%s)\n", full));
	full2comp(full, path, name);
LOG((0, "set_dir: path = %s, name = %s\n", path, name));
	if (*path) {
		p = strrchr(path, 0);
		if ((p > (path + 1)) && (p[-2] != ':') && (p[-1] == '\\'))
			p[-1] = 0;
	} else
		strcpy(path, "\\");
	if (path[1] == ':') {
		if (chk_drive(drv = (path[0] & ~32) - 'A') != -1) {
LOG((0, "set_dir: Setting drive to %d, path to %s\n", drv, &path[2]));
			Dsetdrv(drv);
			return (Dsetpath(&path[2]));
		} else {
LOG((0, "set_dir: Drive %d does not exist\n", drv));
			return (-46);
		}
	} else {
LOG((0, "set_dir: Setting path to %s\n", path));
		return (Dsetpath(path));
	}
}

#ifdef DEBUG
int setdir_debug(char *file, int line, char *full)
{
	LOG((0, "set_dir() called in file %s, line %d\n", file, line));
	return(setdir(full));
}
#endif

/**
 * get_label
 *
 * Ermittelt das Label zu einem gegebenen Laufwerk.
 *
 * Eingabe:
 * drive: GewÅnschtes Laufwerk (0 = A:, ...)
 * buf: Zeiger auf Zielpuffer
 * len: Grîûe des Zielpuffers
 *
 * RÅckgabe:
 * 0: Alles OK, Label u.U. leer
 * sonst: GEMDOS-Fehlercode
 */
long get_label(int drive, char *buf, int len) {
	char help[7];
	DTA dta, *odta;
	long err;

	sprintf(help, "%c:\\", drive + 'A');
	*buf = 0;
	if ((err = Dreadlabel(help, buf, len)) == -32L) {
		odta = Fgetdta();
		Fsetdta(&dta);
		sprintf(help, "%c:\\*.*", drive + 'A');
		if ((err = Fsfirst(help, FA_VOLUME)) == 0) {
			while (dta.d_attrib != FA_VOLUME) {
				if ((err = Fsnext()) != 0)
					break;
			}
			if (!err)
				strcpy(buf, dta.d_fname);
		}
		Fsetdta(odta);
	}
	return (err);
}
