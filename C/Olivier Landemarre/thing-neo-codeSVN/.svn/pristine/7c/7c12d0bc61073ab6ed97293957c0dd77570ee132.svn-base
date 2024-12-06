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

/*
 * date.c vom 21.06.1999
 *
 * Autor:
 * Thomas Binder
 * (gryf@hrzpub.tu-darmstadt.de)
 *
 * Zweck:
 * EnthÑlt Datumsroutinen fÅr ThingFnd.
 *
 * History:
 * 21.06.-
 * 21.06.1999: - Erstellung
 */

#include <string.h>
#include <stdlib.h>
#include <portab.h>

static void julgreg( LONG, WORD *);
static LONG julian( WORD, WORD, WORD);
static WORD schalt_check( WORD);

static WORD mlen[] = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };

/**
 * parse_date
 *
 * Wandelt ein Datum im Format "ttmmjjjj" in das entsprechende
 * GEMDOS-Datum (Tgetdate()-Format) um und ÅberprÅft es dabei auf
 * GÅltigkeit (eine Eingabe wie 30021999 wird also als fehlerhaft
 * abgelehnt).
 *
 * Eingabe:
 * date: Zeiger auf umzuwandelndes Datum im Format "ttmmjjjj"
 *
 * RÅckgabe:
 * 0xffff: date war ungÅltig
 * sonst: Entsprechendes GEMDOS-Datum
 */
UWORD parse_date(char *date) {
	WORD tag, monat, jahr, check[3];
	LONG jul;
	char temp[9];

	if (strlen(date) != 8)
		return (0xffffU);

	strcpy(temp, date);
	jahr = atoi(temp + 4);
	temp[4] = 0;
	monat = atoi(temp + 2);
	temp[2] = 0;
	tag = atoi(temp);

	jul = julian(tag, monat, jahr);
	julgreg(jul, check);

	if ((tag != check[0]) || (monat != check[1]) || (jahr != check[2])) {
		return (0xffffU);
	}
	if ((jahr < 1980) || (jahr > 2099))
		return (0xffffU);

	return ((UWORD)(((jahr - 1980) << 9) | (monat << 5) | tag));
}

/**
 * julgreg
 *
 * Wandelt ein Datum der julianischen TageszÑhlung in das
 * entsprechende Datum des gregorianischen Kalenders.
 *
 * Eingabe:
 * jul: Das umzuwandelnde Datum der julianischen TageszÑhlung
 * datum: Zeiger auf 3 WORDs, in denen Tag, Monat und Jahr abgelegt
 *        werden sollen
 */
static void julgreg(LONG jul, WORD *datum) {
	LONG t1, t2, t3;
	WORD schalt, plus = 200;

	datum[2] = 1583;

	do {
		t1 = julian(1, 1, datum[2]);
		t2 = julian(31, 12, datum[2]);
		t3 = julian(31, 12, datum[2] + plus);

		if ((t1 <= jul) && (t2 >= jul))
			break;

		if (jul <= t3) {
			datum[2]++;
			if (plus > 1)
				plus /= 2;
		} else {
			datum[2] += plus;
		}
	} while (1);

	schalt = schalt_check(datum[2]);

	for (datum[1] = 1; jul > julian(mlen[datum[1] - 1] + (datum[1] == 2) * schalt, datum[1], datum[2]); datum[1]++)
		;

	for (datum[0] = 1; jul > julian(datum[0], datum[1], datum[2]); datum[0]++)
		;
}

/**
 * julian
 *
 * Wandelt ein gregorianisches Kalenderdatum in den entsprechenden
 * Tag der julianischen TageszÑhlung. UngÅltige Werte bei der Eingabe
 * werden dabei nicht erkannt.
 *
 * Eingabe:
 * tag: Tag (1-31) des umzuwandelnden Datums
 * monat: Monat (1-12)
 * jahr: Jahr (immer vierstellig!)
 *
 * RÅckgabe:
 * Entsprechender Tag der julianischen TageszÑhlung
 */
static LONG julian(WORD tag, WORD monat, WORD jahr) {
	LONG help;

	help = 1721060L + 365L * (LONG) jahr + (LONG) tag + 31L * ((LONG) monat - 1);

	if (monat > 2) {
		help -= (LONG)(0.4 * (float) monat + 2.3);
		jahr++;
	}

	help = help + (((LONG) jahr - 1L) / 4L) - ((((LONG) jahr - 1L) / 100L) - (((LONG) jahr - 1L) / 400L));

	return (help);
}

/**
 * schalt_check
 *
 * PrÅft, ob ein Jahr ein Schaltjahr ist. Dabei werden alle
 * definierten FÑlle erkannt, d.h. das Jahr 2000 wird als Schaltjahr
 * gemeldet, das Jahr 2100 hingegen nicht.
 *
 * Eingabe:
 * jahr: Zu prÅfendes Jahr (vierstellig!)
 *
 * RÅckgabe:
 * 0: jahr ist kein Schaltjahr
 * 1: jahr ist Schaltjahr
 */
static WORD schalt_check(WORD jahr) {
	WORD help;

	help = 0;

	if (!(jahr % 4)) {
		help = 1;
		if ((!(jahr % 100)) && (jahr % 400))
			help = 0;
	}
	return (help);
}

/* EOF */