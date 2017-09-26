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
 * MultiTOS Drag&Drop
 */

#include <gem.h>
#include <string.h>
#include <mintbind.h>
#include <signal.h>
#include "..\include\dragdrop.h"

#define DD_TIMEOUT 1000    /* Timeout fuer Antwort auf D&D-Anfrage */
#define DD_EXTSIZE   32    /* Richtig(?) */
#define DD_NAMEMAX    4

/**
 * Pipe fuer Drag&Drop erzeugen.
 *
 * @param myid Eigene AES id
 * @param apid AES id des Empfaengers
 * @param winid Handle des betroffenen Fensters oder 0
 * @param msx Position der Maus in x-Richtung oder -1
 * @param msy Position der Maus in y-Richtung oder -1
 * @param kstate Tastaturstatus
 * @param *ext Zeiger auf einen 32 byte grossen Buffer fuer die Aufnahme der bevorzugten 8 Dateitypen des Empfaengers
 * @param **oldpipesig Zeiger auf den Zeiger des alten Signalhandlers
 *
 * @return > 0 - positives file handle
 *          -1 - keine Antwort oder DD_NAK vom Empfaenger
 *          -2 - AP_DRAGDROP konnte nicht gesendet werden
 */
short ddcreate(short myid, short apid, short winid, short msx, short msy, short kstate,
		void *ext, void **oldpipesig) {
	short handle, i;
	short buf[8];
	long handle_mask;
	char c;
	char *pipe;

	/* Pipe erzeugen */
	pipe = "U:\\PIPE\\DRAGDROP.AA";
	handle = -1;
	pipe[18] = 'A' - 1;

	do {
		pipe[18]++;
		if (pipe[18] > 'Z') {
			pipe[17]++;
			if (pipe[17] > 'Z')
				break;
		}
		handle = (short) Fcreate(pipe, FA_HIDDEN);
	} while (handle == -36);

	if (handle < 0)
		return (handle);

	/* Empfaenger benachrichtigen */
	buf[0] = AP_DRAGDROP;
	buf[1] = myid;
	buf[2] = 0;
	buf[3] = winid;
	buf[4] = msx;
	buf[5] = msy;
	buf[6] = kstate;
	buf[7] = (pipe[17] << 8) | pipe[18];
	if (!appl_write(apid, 16, buf)) {
		Fclose(handle);
		return (-2);
	}

	/* Antwort des Empfaengers abwarten */
	handle_mask = 1L << handle;
	i = Fselect(DD_TIMEOUT, &handle_mask, 0L, 0L);
	if (!i || !handle_mask) {
		/* Fehler: Timeout */
		Fclose(handle);
		return (-1);
	}

	/* Antwort entgegennehmen */
	i = (short) Fread(handle, 1L, &c);
	if (i != 1 || c != DD_OK) {
		Fclose(handle);
		return (-1);
	}

	/* Bei Erfolg die Extensions entgegennehmen */
	if (Fread(handle, DD_EXTSIZE, ext) != (long) DD_EXTSIZE) {
		Fclose(handle);
		return (-1);
	}

	*oldpipesig = Psignal(SIGPIPE, (long) SIG_IGN);

	return handle;
}

/**
 * Pruefen, ob der Empfaenger nach Eroeffnung der Pipe die gewuenschten Daten entgegennimmt.
 *
 * @param handle Handle der Pipe von ddcreate()
 * @param ext Datentyp (z.B. 'ARGS')
 * @param *name Name der Daten
 * @param size Umfang der Daten
 *
 * @return DD_OK  - Alles OK
 *         DD_EXT - Empfaenger akzeptiert den Datentyp nicht
 *         DD_LEN - Empfaenger akzeptiert den Umfang nicht
 *         DD_NAK - Empfaenger wurde vorher beendet
 */
short ddstry(short handle, unsigned long ext, char *name, long size) {
	short hdrlen, i;
	char c;

	/* 4 byte fuer 'ext', 4 byte for 'size', 2 byte fuer abschliessende Nullbytes */
	hdrlen = 10 + (short) strlen(name);
	if (Fwrite(handle, 2L, &hdrlen) != 2)
		return (DD_NAK);

	c = 0;
	i = (short) Fwrite(handle, 4L, &ext);
	i += (short) Fwrite(handle, 4L, &size);
	i += (short) Fwrite(handle, 1L, &c);
	i += (short) Fwrite(handle, (long) strlen(name) + 1, name);
	if (i != hdrlen)
		return (DD_NAK);

	/* Antwort holen */
	if (Fread(handle, 1L, &c) != 1L)
		return (DD_NAK);

	return ((short) c);
}

/**
 * Drag&Drop-Pipe schliessen.
 *
 * @param handle Handle der Pipe von ddcreate()
 * @param
 */
void ddclose(short handle, void *oldpipesig) {
	Psignal(SIGPIPE, (long) oldpipesig);
	Fclose(handle);
}

/**
 * Pipe fuer Drag&Drop oeffnen.
 *
 * @param *pipe Zeiger auf den Namen der Pipe ("DRAGDROP.??")
 * @param *ext Zeiger auf Array mit unterstuetzten Datenformaten
 * @param **oldpipesig Zeiger auf den Zeiger des alten Signalhandlers
 *
 * @return > 0 - file handle der Pipe, Fehlercode sonst
 */
short ddopen(char *pipe, unsigned long *ext, void **oldpipesig) {
	short handle;
	char outbuf[DD_EXTSIZE + 1];

	 /* Handle der Pipe erfragen */
	handle = (short) Fopen(pipe, 2);
	if (handle < 0)
		return (handle);

	/* Programm unterstuetzt Drag & Drop */
	outbuf[0] = DD_OK;

	/* unterstuetzte Datenformate kopieren */
	strncpy(outbuf + 1, (char *) ext, DD_EXTSIZE);

	/* Signal ignorieren */
	*oldpipesig = Psignal(SIGPIPE, (long)SIG_IGN);

	if (Fwrite(handle, (long) DD_EXTSIZE + 1, outbuf) != DD_EXTSIZE + 1) {
		ddclose(handle, *oldpipesig);
		return (-1);
	}

	return (handle);
}
