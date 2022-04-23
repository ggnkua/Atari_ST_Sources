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

#include <mintbind.h>
#include <string.h>
#include <stdlib.h>
#include <portab.h>
#include "thingimg.h"

#define PW		64
#define PH		40

#define FAKTOR	65536L
#define RFAKTOR	65536.0

/* Prototypen */
void set_pixel(int *addr, int x, int y);
void read_infofile(WORD handle);
WORD readline(WORD handle, char *buffer);
extern WORD apfel_calc(LONG cx, LONG cy);
extern WORD apfel2_calc(LONG cx, LONG cy);

#ifdef __030__
#define iterate	apfel_calc
#else
#define iterate	apfel2_calc
#endif

/* Globale Variablen */
long *c_x, *c_y, size;
int width, height, wdwidth, nomem, maxiter, errno;

long cdecl main(long magic, int what, THINGIMG *img_info) {
	MFDB src;
	double x1, x2, y1, y2,
	dx, dy,
	maxi;
	long err;
	int x, y,
	mx, my,
	iter,
	handle,
	*pic;
	static char inf[256];

	/*
	 * Wenn magic nicht den "magischen" Wert enthÑlt, muû sich ThingImg
	 * gleich mittels Pterm beenden. (Vorsicht: Kein Startupcode, also
	 * ist hier kein return mîglich!)
	 */
	if (magic != TI_MAGIC) {
		if (!nomem)
			Mfree(c_x);
		Pterm(0);
	}

	switch (what) {
		/* Initialisierung, das Beispiel hier braucht keine */
		case TI_INIT:
			strcpy(inf, img_info->confpath);
			strcat(inf, "apfelimg.inf");
			if ((err = Fopen(inf, 0)) >= 0L) {
				handle = (int)err;
				read_infofile(handle);
				Fclose(handle);
			} else {
				strcpy(inf, img_info->homepath);
				strcat(inf, "apfelimg.inf");
				if ((err = Fopen(inf, 0)) >= 0L) {
					handle = (int)err;
					read_infofile(handle);
					Fclose(handle);
				} else {
					width = PW;
					height = PH;
				}
			}
			if ((width == -1) || (width > img_info->desk_w))
				width = img_info->desk_w;
			if ((height == -1) || (height > img_info->desk_h))
				height = img_info->desk_h;
	
			wdwidth = (width + 15) / 16;
			size = 2L * wdwidth * height;
			nomem = 0;
			if ((c_x = Malloc((width + height) * sizeof(long))) == 0L)
				nomem = 1;
			else
				c_y = &c_x[width];

			return (0L);

		/*
		 * Bilddatei testen. Da das Beispiel sowieso keine Dateien verarbei-
		 * ten kann, wird immer "Ist OK" gemeldet. Hier sieht man Åbrigens
		 * eine durchaus denkbare Mîglichkeit eines speziellen ThingImg, das
		 * keine Bilder lÑdt, sondern z.B. jedesmal ein neues ApfelmÑnnchen
		 * berechnet.
		 */
		case TI_TEST:
			return (1L);

		/*
		 * Das Bild hat die durch die #defines festgelegte Grîûe in Bytes.
		 * Wichtig: Der Returnwert gibt an, ob die Berechnung glatt ging, die
		 * Grîûe selbst muû in die THINGIMG-Struktur eingetragen werden!
		 */
		case TI_SIZE:
			if (nomem)
				return (-39L);
			img_info->pic_size = size;

			return (0L);

		/*
		 * Das Bild "laden". Das Beispielprogramm erzeugt einfach eine Bitmap
		 * fixer Grîûe mit einem schicken ;) Streifenmuster.
		 */
		case TI_LOAD:
			if (nomem)
				return (-39L);

			/*
			 * Das fertige Bild muû an der durch den MFDB festgelegten Adresse
			 * zu liegen kommen
			 */
			pic = img_info->picture.fd_addr;
			memset(pic, 0, size);
			mx = width - 1;
			my = height - 1;
			pic_calc:
			for (;;) {
				x1 = (double)Random() / (double)(1L << 24L);
				x1 = x1 * 3.0 - 2.3;
				x2 = (double)Random() / (double)(1L << 24L);
				x2 = x2 * 3.0 - 2.3;
				if (x1 > x2) {
					dx = x1;
					x1 = x2;
					x2 = dx;
				}
				y1 = (double)Random() / (double)(1L << 24L);
				y1 = y1 * 2.0 - 1;
				y2 = y1 + (x2 - x1) / 1.5;
				dx = (x2 - x1) / mx;
				dy = (y2 - y1) / my;
				if ((dx > (1.0 / RFAKTOR)) && (dy > (1.0 / RFAKTOR)))
					break;
			}
	
			maxi = 3.0 - (x2 - x1);
			maxi = maxi * maxi * maxi * maxi * maxi * maxi;
			maxiter = (int)maxi + 25;
			for (x = 0; x <= mx; c_x[x++] = (long)((x1 + x * dx) * FAKTOR))
				;
			for (y = 0; y <= my; c_y[y++] = (long)((y1 + y * dy) * FAKTOR))
				;
	
			iter = iterate(c_x[1], c_y[1]);
			if ((iter == iterate(c_x[1], c_y[my - 1])) && (iter == iterate(c_x[mx - 1], c_y[1])) && (iter == iterate(c_x[mx - 1], c_y[my - 1]))) {
				goto pic_calc;
			}
			for (y = 1; y < my; y++) {
				for (x = 1; x < mx; x++) {
					iter = iterate(c_x[x], c_y[y]);
					if ((iter == maxiter) || (iter & 1))
						set_pixel(pic, x, y);
				}
			}
	
			/* Der restliche MFDB muû noch aufgefÅllt werden! */
			img_info->picture.fd_w = width;
			img_info->picture.fd_h = height;
			img_info->picture.fd_wdwidth = wdwidth;
			img_info->picture.fd_stand = 0;
			img_info->picture.fd_nplanes = 1;
			src = img_info->picture;
			src.fd_stand = 1;
	
			/*
			 * Die kÅnstliche erzeugte Bitmap muû natÅrlich ins gerÑteabhÑngige
			 * Format transformiert werden (auch wenn sie monochrom ist)
			 */
			vr_trnfm(img_info->vdi_handle, &src, &img_info->picture);
	
			/*
			 * Thing anzeigen, daû die Bitmap monochrom ist. Ist zwar genauge-
			 * genommen auch Åber die Anzahl der Planes ermittelbar, so ist es
			 * aber noch deutlicher.
			 */
			img_info->is_mono = 1;
			return (0L);

		/*
		 * Sollte es neue Opcodes geben, die dieses ThingImg noch nicht
		 * beherrscht, einfach 0L zurÅckliefern. ZukÅnftige énderungen an der
		 * Schnittstelle werden das berÅcksichtigen.
		 */
		default:
			return (0L);
	}
}

void set_pixel(int *addr, int x, int y) {
	int bit;

	bit = 15 - (x % 16);
	x /= 16;
	addr[(long) y * (long) wdwidth + (long) x] |= (1 << bit);
}

void read_infofile(WORD handle) {
	static char input[256];
	char *arg, *pos;

	/* Die Datei zeilenweise auslesen und auswerten */
	while (readline(handle, input)) {
		/* Leerzeilen werden komplett ignoriert */
		if (!*input)
			continue;

		/* Jede Zeile muû mindestens ein Gleichheitszeichen enthalten */
		if ((arg = strchr(input, '=')) == NULL)
			continue;
		*arg = 0;
		pos = &arg[strlen(&arg[1])];
		while (*pos == ' ')
			*pos-- = 0;

		/*
		 * Folgt hinter dem Gleichheitszeichen nichts mehr, ist die Zeile
		 * ungÅltig
		 */
		if (!arg[1])
			continue;
		if (!stricmp(input, "x_size")) {
			width = atoi(&arg[1]);
			continue;
		}
		if (!stricmp(input, "y_size")) {
			height = atoi(&arg[1]);
			continue;
		}
	}
}

WORD readline(WORD handle, char *buffer) {
	WORD count;
	LONG fpos, add, bytes_read;

	for (;;) {
		fpos = Fseek(0L, handle, 1);
		if (fpos < 0L)
			return (0);
		if ((bytes_read = Fread(handle, 255, buffer)) <= 0L) {
			return (0);
		}
		count = 0;
		add = 1L;
		for (;;) {
			if (count == bytes_read) {
				add = 0L;
				break;
			}
			if (buffer[count] == '\n')
				break;
			if (count == 255)
				return (0);
			if (buffer[count] == '\t')
				buffer[count] = ' ';
			count++;
		}
		if (Fseek((LONG) count + fpos + add, handle, 0) < 0L) {
			return (0);
		}
		if (count) {
			if (buffer[count - 1] == '\r')
				count--;
		}
		buffer[count] = 0;
		if (*buffer != '#')
			break;
	}
	return (1);
}

/* EOF */
