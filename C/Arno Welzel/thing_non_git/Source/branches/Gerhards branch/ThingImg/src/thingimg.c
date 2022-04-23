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
 * thingimg.c vom 24.08.1996
 *
 * Autor:
 * Thomas Binder
 * (binder@rbg.informatik.th-darmstad.de)
 *
 * Idee:
 * Arno Welzel
 * (aw@zaphot.augusta.de)
 *
 * Zweck:
 * Minimalistischer Beispielsource fÅr ein externes ThingImg-Modul.
 * ThingImg ist der Bildlader fÅr Thing. Durch das externe Konzept
 * wird einerseits Speicher gespart (ThingImg belegt nur beim Laden
 * eines Bildes Speicher), andererseits ermîglicht es eine wesent-
 * lich flexiblere Hintergrundbildeinbindung, da ThingImg bei Bedarf
 * gegen ein anderes Modul ausgewechselt werden kann, das z.B. JPEG
 * statt (X)IMG laden kann.
 *
 * ThingImg ist ein Programm _ohne_ Startupcode, der Programmtext
 * muû mit einer Funktion beginnen, die ihre Parameter auf dem Stack
 * erhÑlt (siehe main in diesem Pure-C-Source). Diese Funktion wird
 * von Thing aufgerufen und erhÑlt dabei einige Parameter. Wenn
 * magic nicht den Wert 0x27081969L enthÑlt, muû sich ThingImg sofort
 * beenden (das ist dann der Fall, wenn Thing ThingImg wieder los-
 * werden will).
 *
 * Ansonsten entscheidet der zweite Parameter what, was gerade getan
 * werden soll:
 * TI_INIT - ThingImg erhÑlt hier die Mîglichkeit, sich auf seine
 *           Arbeit vorzubereiten. Dabei darf _kein_ Speicher dauer-
 *           haft angefordert werden! Das gilt Åbrigens durchgehend,
 *           ebenso darf ThingImg keine AES-Aufrufe tÑtigen. Was aber
 *           durchaus mîglich ist, ist die Initialisierung von
 *           Strukturen, etc. Der Inhalt der THINGIMG-Struktur, auf
 *           die der dritte Parameter img_info zeigt, ist zu dieser
 *           Zeit noch ungÅltig (bis auf die Elemente version,
 *           homepath, desk_w, desk_h und confpath,, die immer gÅltig
 *           sind) und darf daher nicht ausgelesen oder geÑndert
 *           werden. Der RÅckgabewert wird ignoriert.
 * TI_TEST - ThingImg soll eine Bilddatei auf gÅltiges Format prÅfen.
 *           Dazu zeigt das Element filename auf den vollen Zugriffs-
 *           pfad der zu testenden Datei. Auûerdem sind die Elemente
 *           vdi_handle und use_palette gÅltig, alle anderen sind
 *           nicht von Bedeutung. Als Ergebnis muû ThingImg einen von
 *           Null verschiedenen Wert liefern, wenn das Bild OK ist,
 *           sonst Null.
 * TI_SIZE - ThingImg soll den Speicherbedarf eines Rasters fÅr eine
 *           Bilddatei berechnen. Die GÅltigkeit der Elemente der
 *           THINGIMG-Struktur ist identisch mit der bei TI_TEST. Zu
 *           berechnen ist die Anzahl Bytes, die benîtigt wird, um
 *           das Bild in der aktuellen Farbtiefe in einem VDI-Raster
 *           (MFDB) halten zu kînnen. Dieser Wert muû abschlieûend in
 *           das Element pic_size der THINGIMG-Struktur eingetragen
 *           werden. Der Returnwert der Funktion ist Null, wenn alles
 *           glatt ging, ungleich Null sonst (z.B. ein GEMDOS-Fehler-
 *           code).
 * TI_LOAD - ThingImg soll eine Bilddatei laden und an die aktuelle
 *           Farbtiefe anpassen. Dazu zeigt das Element filename der
 *           THINGIMG-Struktur auf den Namen des Bildes, fd_addr des
 *           MFDB im Element picture zeigt auf den Speicherbereich,
 *           in dem das fertige Bild abgelegt werden soll (der Rest
 *           des MFDB ist nicht vorinitialisiert!) Das Element
 *           use_palette gibt an, ob die Farbtabelle des Bildes
 *           (falls vorhanden) benutzt werden soll. In vdi_handle
 *           findet sich das Handle einer virtuellen VDI-Workstation,
 *           mit der ThingImg arbeiten kann (dabei darf, bis auf die
 *           Farbpalette, nichts dauerhaft verstellt werden).
 *           Wenn das Bild geladen und angepaût wurde, sollte, falls
 *           die Farbpalette benutzt werden soll/kann, die aktuelle
 *           Palette im Element old_palette abgelegt werden. Dabei
 *           muû nur der Bereich zwischen dem ersten und dem letzten
 *           zu verÑndernden Farbindex gesichert werden, diese beiden
 *           Werte mÅssen entsprechend in den Elementen first und
 *           last abgelegt werden. Ist die Palette unbenutzt oder
 *           irrelevant (z.B. bei Direct Color), muû first auf dem
 *           Initialwert von -1 bleiben!
 *           Danach wird die Farbpalette von ThingImg so eingestellt,
 *           daû das Bild korrekt dargestellt wird (natÅrlich nur,
 *           wenn nîtig und Åber use_palette gewÅnscht). Handelt es
 *           sich um ein monochromes Bild, muû das Element is_mono
 *           auf Eins gesetzt werden, sonst auf Null.
 *           Ein RÅckgabewert von 0 signalisiert, daû das Bild
 *           geladen und angepaût werden konnte, alle anderen Werte
 *           zeigen Thing an, daû etwas schiefgelaufen ist und das
 *           Bild nicht benutzt werden kann. In letzterem Fall darf
 *           die Farbpalette noch nicht geÑndert worden sein!
 *           Wenn die Farbpalette des Bildes benutzt werden soll, ist
 *           darauf zu achten, nach Mîglichkeit nicht die ersten 16
 *           Farben zu verÑndern. Falls dies doch nîtig sein sollte,
 *           sollten die énderungen mîglichst unaufÑllig sein, um
 *           dem Anwender normales Arbeiten zu ermîglichen.
 *
 * Das Element version der THINGIMG-Struktur gibt Åbrigens an, welche
 * Version die Åbergebene Struktur hat, zur Zeit ist dies 0x102
 * (Version 1.02). Anhand der Versionsnummer kann auf eventuelle
 * Erweiterungen geschlossen werden, die auf jeden Fall immer
 * abwÑrtskompatibel sein werden.
 *
 * History:
 * 22.07.-
 * 23.07.1996: Erstellung
 * 07.08.1996: énderungen bei den ErlÑuterungen zu TI_INIT, TI_TEST
 *             und TI_SIZE. Betriff hauptsÑchlich die Tatsache, daû
 *             die Elemente vdi_handle und use_palette der THINGIMG-
 *             Struktur auch schon bei TI_TEST und TI_SIZE gÅltig
 *             sind (was aus Sicht von Thing ohnehin schon der Fall
 *             war), denn sonst kînnen Bilder nicht richtig geprÅft
 *             und ihre Grîûe nicht richtig berechnet werden. Dank an
 *             Thomas KÅnneth fÅr diesen Hinweis; ich selbst habe es
 *             beim Implementieren der Schnittstelle in Thing zwar
 *             richtig gemacht, es dann aber fÅr die Doku falsch
 *             beschrieben, weil ich falsch gedacht hatte...
 * 16.08.1996: ErlÑuterungen an neue Strukturversion (1.01) angepaût
 * 23.08.-
 * 24.08.1996: ErlÑuterungen an neue Strukturversion (1.02) angepaût
 */

#include <mintbind.h>
#include <string.h>
#include "thingimg.h"

/* NICHT VERGESSEN: KEINEN STARTUPCODE DAZULINKEN!!! */

#define PW		320L
#define PH		200L
#define PICSIZE	(+((PW + 15) / 16) * PH * 2)

long cdecl main(long magic, short what, THINGIMG *img_info) {
	MFDB src;

	/*
	 * Wenn magic nicht den "magischen" Wert enthÑlt, muû sich ThingImg
	 * gleich mittels Pterm beenden. (Vorsicht: Kein Startupcode, also
	 * ist hier kein return mîglich!)
	 */
	if (magic != TI_MAGIC)
		Pterm(0);

	switch (what) {
		/* Initialisierung, das Beispiel hier braucht keine */
		case TI_INIT:
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
			img_info->pic_size = PICSIZE;
			return (0L);

		/*
		 * Das Bild "laden". Das Beispielprogramm erzeugt einfach eine Bitmap
		 * fixer Grîûe mit einem schicken ;) Streifenmuster.
		 */
		case TI_LOAD:
			/*
			 * Das fertige Bild muû an der durch den MFDB festgelegten Adresse
			 * zu liegen kommen
			 */
			memset(img_info->picture.fd_addr, 24, PICSIZE);

			/* Der restliche MFDB muû noch aufgefÅllt werden! */
			img_info->picture.fd_w = (short)PW;
			img_info->picture.fd_h = (short)PH;
			img_info->picture.fd_wdwidth = (short)((PW + 15) / 16);
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

/* EOF */
