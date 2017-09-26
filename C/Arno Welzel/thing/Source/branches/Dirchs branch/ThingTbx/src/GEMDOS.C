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

#include <string.h>
#include <aes.h>
#include <tos.h>
#include <nkcc.h>
#include "..\include\thingtbx.h"

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
		path[0] = (char) Dgetdrv() + 'A';
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
	if (strrchr(full, 0)[-1] != '\\')
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
int isValidPath(char *path) {
	char drv;

	/* Weniger als 3 Zeichen ("X:\")? */
	if ((int) strlen(path) < 3)
		return (FALSE);

	/* Laufwerk unzulaessig? */
	drv = nkc_toupper(path[0]);
	if ((drv < 'A' || drv > 'Z'))
		return (FALSE);

	/* Keine Laufwerksangabe am Anfang? */
	if (path[1] != ':')
		return (FALSE);

	/* Kein Rootverzeichnis auf dem Laufwerk? */
	if (path[2] != '\\')
		return (FALSE);

	/* Keine Fehler! */
	return (TRUE);
}

/**
 * Prueft eine Dateimaske auf Zulaessigkeit.
 *
 * @param *mask Zeiger auf die Variable, die die Dateimaske enthaelt
 * @param wild 1 - Wildcards erlauben, 0 - sonst
 *
 * @return TRUE - alles OK, FALSE - sonst
 */
int isValidFileMask(char *mask, int wild) {
	int length, i;

	/* Nur pruefen, wenn Maske vorhanden */
	length = (int) strlen(mask);
	if (length) {
		for (i = 0; i < length; i++) {
			/* Unzulaessiges Zeichen in der Maske? */
			if ((unsigned char) mask[i] < 32 || mask[i] == '\\' || mask[i]
					== ':' || mask[i] == 34 || mask[i] == 64)
				return (FALSE);

			/* Falls kein Wildcard erlaubt ... */
			if (!wild)
				if (isWildcard(mask[i]))
					return (FALSE);
		}
	}

	/* Keine Fehler! */
	return (TRUE);
}

#if 0
/**
 * Prueft eine Extension auf Zulaessigkeit.
 *
 * @param *ext Zeiger auf die Variable, die die Extension enthaelt
 *
 * @return 1 - alles OK, 0 - sonst
 */
int isValidFileExtension(char *ext) {
	int length, i;

	/* Nur pruefen, wenn Extension vorhanden */
	length = (int) strlen(ext);
	if (length) {
		for (i = 0; i < length; i++) {
			/* Unzulaessiges Zeichen in der Extension? */
			if ((unsigned char) ext[i] < 32 || ext[i] == '\\' || ext[i] == ':'
					|| ext[i] == '?' || ext[i] == '*' || ext[i] == '.'
					|| ext[i] == 34 || ext[i] == 64)
				return (0);
		}
	}

	/* Keine Fehler! */
	return (1);
}
#endif
