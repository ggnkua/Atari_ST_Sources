/*******************************************************************************  Treiber fÅr Olivetti JP350WS-Tintenstrahldrucker (HP-kompatibel)  *******************************************************************************/
/* Sollte auch Deskjet und 300dpi Laser bedienen */

/* evt. muû der Rand (LINKS) angepaût werden, also:
 * Dazu als Faustregel: 1Byte = 8Pixel = (8/300)" = (2/75)" ~ 0.653mm 
 * Das heiût: Grafik jetzt ca. 4mm zu weit links, Rand um 6 erhîhen, 
 * denn 6*0.653 = 3.96mm
 * (Diese Formel gilt natÅrlich nur bei 300 DPI.)
 * FÅr den oberen Rand gilt 1mm ~ 12 Zeilen. da (25.4/300)mm = 1 Zeile
 * (Wenn man diese Datei an einen anderen Drucker anpaût, dann diese 
 *  bitte entsprechend umbennen (z.B. HP_LASER.C, dann wÑre z.B. 
 *  HOEHE=3350, LINKS=??? und an mich senden, BITTE!)
 */

/* Deskjet wÑre: OBEN 28, LINKS ???, HOEHE 3386 */

#define OBEN 19				/* Oberer Rand */
#define LINKS 6				/* Linker Rand */#define MAX_DPI 300L	/* Maximale Auflîsung 300dpi */#define BREITE 2336L	/* max. Breite einer Grafikseite */#define HOEHE 3360L		/* max. Hoehe */#include "hp.c"	/* HP-Standarttreiber */

/* email: prissi@marie.physik.tu-berlin.de
 * Post:  Markus Pristovsek
 *        Boumannstraûe 66
 *        W1000 Berlin 28
 */