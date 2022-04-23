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
#include "rsrc\thing.h"
#include "rsrc\thgtxt.h"
#include <ctype.h>

/**
 is_app()

 PrÅfen, ob es sich bei einer Datei um ein Programm handelt
 -------------------------------------------------------------------------*/
short is_app(char *name, unsigned short mode) {
	char *p, *ext;
	short i, l, _ext[3];
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
				return (1);
			if (*match == '.TOS')
				return (2);
			if (*match == '.TTP')
				return (3);
			if (*match == '.ACC')
				return (4);
			if (*match == '.GTP')
				return (5);
			if (conf.altapp) {
				if (*match == '.PRX' || *match == '.APX')
					return (1);
				if (*match == '.ACX')
					return (4);
				if (conf.altcpx) {
					if (*match == '.CPZ' || *match == '.EPZ')
						return (6);
				}
			}
			if (conf.altcpx) {
				if (*match == '.CPX' || *match == '.EPX')
					return (6);
			}
		}
	}

	/* Evtl. x-Flags gesetzt - dann als TTP behandeln */
	if ((mode & 0111) != 0)
		return (3);

	return (0);
}

/**
 * is_appl
 *
 * Wie is_app, ermittelt mode aber selbst und liefert fuer leere Namen 'keine Applikation'.
 */
short is_appl(char *path) {
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
short setdir(char *full) {
	char path[MAX_PLEN], name[MAX_FLEN], *p;
	short drv;

DEBUGLOG((0, "set_dir(%s)\n", full));
	full2comp(full, path, name);
DEBUGLOG((0, "set_dir: path = %s, name = %s\n", path, name));
	if (*path) {
		p = strrchr(path, 0);
		if ((p > (path + 1)) && (p[-2] != ':') && (p[-1] == '\\'))
			p[-1] = 0;
	} else
		strcpy(path, "\\");
	if (path[1] == ':') {
		if (chk_drive(drv = (path[0] & ~32) - 'A') != -1) {
DEBUGLOG((0, "set_dir: Setting drive to %d, path to %s\n", drv, &path[2]));
			Dsetdrv(drv);
			return (Dsetpath(&path[2]));
		} else {
DEBUGLOG((0, "set_dir: Drive %d does not exist\n", drv));
			return (-46);
		}
	} else {
DEBUGLOG((0, "set_dir: Setting path to %s\n", path));
		return (Dsetpath(path));
	}
}

#if 0
#ifdef DEBUG
short setdir_debug(char *file, short line, char *full) {
DEBUGLOG((0, "set_dir() called in file %s, line %d\n", file, line));
	return(setdir(full));
}
#endif
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
long get_label(short drive, char *buf, short len) {
	char help[7];
	_DTA dta, *odta;
	long err;

	sprintf(help, "%c:\\", drive + 'A');
	*buf = 0;
	if ((err = Dreadlabel(help, buf, (short) len)) == -32L) {
		odta = Fgetdta();
		Fsetdta(&dta);
		sprintf(help, "%c:\\*.*", drive + 'A');
		if ((err = Fsfirst(help, FA_VOLUME)) == 0) {
			while (dta.dta_attribute != FA_VOLUME) {
				if ((err = Fsnext()) != 0)
					break;
			}
			if (!err)
				strcpy(buf, dta.dta_name);
		}
		Fsetdta(odta);
	}
	return (err);
}
