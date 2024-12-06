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
 * Verschiedene Funktionen fuer Strings.
 */

#include <string.h>
#include <stdlib.h>
#include "..\include\thingtbx.h"

/**
 * Diese Methode begrenzt einen String, wie z.B. eine Pfadangabe auf die
 * Anzahl von Zeichen, die in 'limit' angegeben wurden. Ist der String
 * kuerzer wird er komplett kopiert. Ist er laenger, werden die ersten
 * 10 Zeichen und die letzten (limit - 13) Zeichen uebernommen. Um
 * anzuzeigen, dass der String verkuerzt wurde, wird nach den ersten
 * 10 Zeichen '...' eingefuegt.
 *
 * Beispiele:
 * 'Zwei flinke Boxer jagen die quirlige Eva und ihren Mops durch Sylt.' (68 Zeichen)
 *
 * limit 30: 'Zwei flink... Mops durch Sylt.'
 * limit 45: 'Zwei flink...e Eva und ihren Mops durch Sylt.'
 *
 *
 * @param *dest der Ziel-String
 * @param *src der Quell-String
 * @param limit Anzahl der Zeichen, auf die der String begrenzt werden soll
 */
void strShortener(char *dest, char *src, short limit) {
	short len;

	len = (short) strlen(src);
	if (len > limit) {
		strncpy(dest, src, 10);
		strcpy(&dest[10], "...");
		strcat(dest, &src[len - (limit - 13)]);
	} else
		strcpy(dest, src);
}

/**
 * Prueft, ob ein Zeichen Wildcards ('*', '?', '[' oder '])
 * enthaelt.
 *
 * @param char zu untersuchendes Zeichen
 *
 * Rueckgabe:
 * 1: s enthaelt mindestens ein Wildcard-Zeichen
 * 0: sonst
 */
short isWildcard(char c) {
	switch (c) {
	case '[':
	case ']':
	case '*':
	case '?':
		return (TRUE);
	}

	return (FALSE);
}

/**
 * Prueft, ob eine Zeichenkette Wildcards ('*', '?', '[' oder '])
 * enthaelt.
 *
 * @param *string Zeiger auf zu untersuchenden String
 *
 * Rueckgabe:
 * 1: s enthaelt mindestens ein Wildcard-Zeichen
 * 0: sonst
 */
short hasWildcards(char *str) {
	unsigned char c;

	while ((c = *str++) != 0) {
		if (isWildcard(c))
			return (TRUE);
	}
	return (FALSE);
}

/**
 * Patternvergleich mit Wildcards.
 *
 * @param *pattern Zeiger auf Vergleichsmaske, ggf. mit Wildcards
 * @param *string Zeiger auf zu vergleichenden String
 *
 * Rueckgabe:
 * 1: s passt auf Maske p
 * 0: sonst
 */
short patternMatching(register char *pattern, register char *str) {
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
					return (FALSE);
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
					return (FALSE);
			continue;

		case '*':
			if (!*pattern)
				return (TRUE);
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
							return (FALSE);
					}
					return (TRUE);
				} else
					return (FALSE);
			}
			do {
				if (patternMatching(pattern, str))
					return (TRUE);
			} while (*str++);
			return (FALSE);

		case 0:
			return (scc == 0);

		case '?':
			if (scc == 0)
				return (FALSE);
			continue;

		default:
			if (c != scc)
				return (FALSE);
			continue;
		}
	}
}

/**
 *
 *
 * @param *str Eingabe-String
 get_text()

 Wird verwendet um Strings, die von Anfuehrungszeichen
 umschlossen sind, einzulesen.
 Als Ergebnis wird ein Zeiger auf die erste Position hinter dem
 zweiten AnfÅhrungszeichen (einschlieûlich einer Leerstelle
 Zwischenraum) geliefert.
 -------------------------------------------------------------------------*/
char *get_text(char *str, char *buf, short maxlen) {
	short i, j, p, done;
	short val;
	char vbuf[4];

	i = 0;
	while (str[i] != '"' && str[i] != 0)
		i++;
	buf[0] = 0;
	if (!str[i])
		return (&str[i]);
/*	return buf; */ /* Thing Icon gibt das zurueck. macht das einen unterschied? */

	i++;
	p = 0;
	done = FALSE;
	while (!done) {
		switch (str[i]) {
		case '"':
		case 0:
			done = TRUE;
			break;
		case '@':
			j = 0;
			i++;
			while (str[i] >= '0' && str[i] <= '9' && j < 2) {
				vbuf[j] = str[i];
				j++;
				i++;
			}
			vbuf[j] = 0;
			val = atoi(vbuf);
			if (val < 1)
				val = 1;
			if (val > 255)
				val = 255;
			buf[p] = (char) val;
			p++;
			break;
		default:
			buf[p] = str[i];
			i++;
			p++;
		}
		if (p == maxlen)
			done = TRUE;
	}
	buf[p] = 0;
	if (str[i]) {
		if (str[i] != '"') {
			while (str[i] != '"' && str[i])
				i++;
		} else
			i++;
		if (str[i] == ' ')
			i++;
	}

	return (&str[i]);
}

#if 0
/**
 put_text()

 GegenstÅck zu get_text() -
 Konvertiert einen String und schreibt diesen in die angegebene Datei
 -------------------------------------------------------------------------*/
void put_text(FILE *fh, char *str) {
	short i, j;
	unsigned char *p;
	char outbuf[1024];

	p = (unsigned char *) str;
	i = 0;
	j = 0;
	while (p[i]) {
		if (p[i] < 32) {
			sprintf(&outbuf[j], "@%02d", (short) p[i]);
			j += 3;
		} else {
			switch (p[i]) {
			case '\042':
				sprintf(&outbuf[j], "@34");
				j += 3;
				break;
			case '@':
				sprintf(&outbuf[j], "@64");
				j += 3;
				break;
			default:
				outbuf[j] = (char) p[i];
				j++;
				break;
			}
		}
		i++;
	}
	outbuf[j] = 0;
	fprintf(fh, "\042%s\042", outbuf);
}

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
#endif
