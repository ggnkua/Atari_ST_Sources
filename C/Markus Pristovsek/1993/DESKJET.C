/***************************************************************************
****  Treiber fÅr Deskjet-Tintenstrahldrucker														****
***************************************************************************/

/* Sollte auch 300dpi Laser bedienen */

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

#define OBEN 28				/* Oberer Rand */
#define LINKS 9				/* Linker Rand */
#define MAX_DPI 300L	/* Maximale Auflîsung 300dpi */
#define BREITE 2336L	/* max. Breite einer Grafikseite */
#define HOEHE 3386L		/* max. Hoehe */

#include "hp.c"	/* HP-Standarttreiber */

/* email: prissi@marie.physik.tu-berlin.de
 * Post:  Markus Pristovsek
 *        Boumannstraûe 66
 *        13467 Berlin
 */