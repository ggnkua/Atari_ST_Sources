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
 * Verwaltung des GEM-Clipboards
 */

#include "..\include\globdef.h"
#include "..\include\types.h"
#include "rsrc\thing_de.h"
#include "rsrc\thgtxtde.h"

/**
 * Setzt den Pfad fuer die Ablage und richtet ggf. das Verzeichnis ein.
 */
void clip_init(void) {
	char path[MAX_PLEN], *cp;
	int p, ret, exist;
	XATTR xattr;

	cp = desk.dicon[OBCLIP].spec.clip->path;
	strcpy(path, cp);
	p = (int) strlen(path) - 1;
	if (p > 2) {
		path[p] = 0;
		exist = !file_exists(path, 1, &xattr);
		if (exist && ((xattr.mode & S_IFMT) != S_IFDIR))
			exist = 0;

		/* Existiert das Verzeichnis? Falls nicht, dann anlegen.*/
		if (!exist) {
			ret = Dcreate(path);
			if (ret < 0) {
				err_file(rs_frstr[ALCCREATE], (long) ret, path);
				scrp_read(cp);
				p = (int) strlen(cp) - 1;
				if ((p > 0) && (cp[p] != '\\'))
					strcat(cp, "\\");
			} else
				scrp_write(cp);
		} else
			scrp_write(cp);
	}
}

/**
 * Kopiert den Inhalt einer Datei in das GEM-Clipboard.
 *
 * @param *name Name der Datei
 */
int clip_file(char *name) {
	long infh, outfh, inlen, outlen;
	unsigned long bufsize;
	char *buf, *p, outname[MAX_PLEN];
	int done, ret;

	/* Dateiname fuer Clipboard erzeugen */
	strcpy(outname, desk.dicon[OBCLIP].spec.clip->path);
	strcat(outname, "SCRAP");
	p = strrchr(name, '\\');
	if (p)
		p = strrchr(p, '.');
	if (p)
		strcat(outname, p);

	/* Buffer einrichten */
	buf = 0L;
	bufsize = 1024L * 64L;
	while (!buf && bufsize > 0L) {
		buf = pmalloc(bufsize);
		if (!buf) {
			bufsize = bufsize / 2;

			/* Kein Speicher mehr, dann raus */
			if (!bufsize) {
				frm_alert(1, rs_frstr[ALNOMEM], altitle, conf.wdial, 0L);
				return (0);
			}
		}
	}

	/* Datei oeffnen */
	infh = Fopen(name, FO_READ);
	if (infh < 0L) {
		pfree(buf);
		err_file(rs_frstr[ALFLOPEN], infh, name);
		return (0);
	}

	/* Clipboardinhalt loeschen und Zieldatei anlegen */
	scrap_clear();
	outfh = Fcreate(outname, 0);
	if (outfh < 0L) {
		Fclose((int) infh);
		pfree(buf);
		err_file(rs_frstr[ALFLCREATE], outfh, outname);
		return (0);
	}

	/* Auf gehts... */
	done = 0;
	ret = 1;
	while (!done) {
		inlen = Fread((int) infh, bufsize, buf);
		if (inlen < 0L) {
			Fclose((int) outfh);
			Fclose((int) infh);
			pfree(buf);
			err_file(rs_frstr[ALFLREAD], inlen, name);
			ret = 0;
		}
		if (inlen > 0L) {
			outlen = Fwrite((int) outfh, inlen, buf);
			if (outlen != inlen) {
				Fclose((int) outfh);
				Fclose((int) infh);
				pfree(buf);
				if (outlen >= 0L)
					outlen = -39L;
				err_file(rs_frstr[ALFLWRITE], outlen, outname);
				Fdelete(outname);
				return (0);
			}
		} else
			done = 1;
	}
	Fclose((int) outfh);
	Fclose((int) infh);
	pfree(buf);

	clip_update();

	return (ret);
}

/**
 * Sorgt fuer ein Update des Clipboard-Verzeichnisses, wenn dort eine neue Datei angelegt wurde.
 */
void clip_update(void) {
	int mode, type, id;
	char name[9];

	if (tb.sys & SY_ASEARCH) {
		mode = 0;
		strcpy(name, "        ");
		while (appl_search(mode, name, &type, &id)) {
			mode = 1;
			if ((type != 1) && (id != tb.app_id)) {
				if (strnicmp(name, "msgservr", 8))
					appl_send(id, 80 /* SC_CHANGED */, 0, 0, 0, 0, 0, 0);
			}
		}
	}
	strcpy(aesbuf, desk.dicon[OBCLIP].spec.clip->path);
	appl_send(tb.app_id, AV_PATH_UPDATE, PT34, (long) aesbuf, 0, 0, 0, 0);
}
