/**
 * Thing Image
 * Copyright (C) 1996-2012 Thomas Binder
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
 * @copyright  Thomas Binder 1996-2012
 * @author     Thomas Binder
 * @license    LGPL
 */

/*
 * thingimg.h vom 24.08.1996 (Strukturversion 1.02)
 *
 * Autoren:
 * Arno Welzel (aw@zaphot.augusta.de)
 * Thomas Binder (binder@rbg.informatik.th-darmstadt.de)
 *
 * Zweck:
 * Headerfile fÅr die Entwicklung eigener Bild-Lade-Programme fÅr
 * Thing. Bei Interesse bitte bei Thomas Binder melden.
 *
 * History:
 * 02.02.1996: Erstellung
 * 21.07.1996: Neuentwurf
 * 22.07.1996: Neues Element version in THINGIMG-Struktur
 * 16.08.1996: Neues Element homepath in THINGIMG-Struktur
 * 23.08.1996: Neue Elemente desk_w und desk_h in THINGIMG-Struktur
 * 24.08.1996: Neues Element confpath in THINGIMG-Struktur
 */

#include <gem.h>

/* Konstanten */
#define TI_MAGIC	0x27081969L
#define TI_INIT		0
#define TI_TEST		1
#define TI_SIZE		2
#define TI_LOAD		3

/*
 * Diese Struktur wird den Routinen des externen Programms
 * Åbergeben. Es mÅssen dann dort die entsprechenden Felder korrekt
 * belegt werden.
 */
typedef struct
{
/* Versionsnummer dieser Struktur, zur Zeit 0x102 */
	short		version;		/* Immer gÅltig */

/* Zu benutzendes VDI-Handle */
	short		vdi_handle;		/* GÅltig bei TI_TEST, TI_SIZE und TI_LOAD */

/* Voller Zugriffspfad fÅr das zu ladende/testende Bild */
	char	*filename;		/* GÅltig bei TI_TEST, TI_SIZE und TI_LOAD */

/* Palette des Bildes benutzen (1) oder nicht (0)? */
	short		use_palette;	/* GÅltig bei TI_TEST, TI_SIZE und TI_LOAD */

/* Benîtigter Speicher fÅr das Bild als VDI-Raster (MFDB) */
	long	pic_size;		/* GÅltig bei TI_SIZE und TI_LOAD */

/* MFDB des Bildes, fd_addr == 0L -> Kein Bild geladen */
	MFDB	picture;		/* GÅltig bei TI_LOAD */

/* Ist das Bild monochrom (1) oder nicht(0) ? */
	short		is_mono;		/* GÅltig bei TI_LOAD */

/* Wenn use_palette 1 ist, steht hier die alte Farbpalette */
	short		old_palette[256 * 3];	/* GÅltig bei TI_LOAD */

/* Erster und letzter benutzter Index in old_palette */
	short		first;			/* GÅltig bei TI_LOAD */
	short		last;			/* GÅltig bei TI_LOAD */

/*
 * Pfad, in dem ThingImg liegt (nÅtzlich z.B. fÅr INF-Dateien),
 * erst seit Strukturversion 1.01 (0x101) vorhanden und immer mit
 * Backslash abgeschlossen!
 */
	char	*homepath;		/* Immer gÅltig */

/*
 * Grîûe des Desktop-Arbeitsbereichs in Pixeln, erst seit Struktur-
 * version 1.02 (0x102) vorhanden!
 */
	short		desk_w;			/* Immer gÅltig */
	short		desk_h;			/* Immer gÅltig */

/*
 * Pfad, in dem die Konfigurationsdateien von Thing liegen (hier
 * sinnvoll fÅr userabhÑngige Modul-INF-Dateien). Immer mit Backslash
 * abgeschlossen und erst seit Strukturversion 1.02 (0x102)
 * vorhanden. Vorsicht: Kann mit homepath identisch sein!
 */
	char	*confpath;		/* Immer gÅltig */
} THINGIMG;

/* EOF */