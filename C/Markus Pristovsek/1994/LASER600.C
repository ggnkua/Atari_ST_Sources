/*******************************************************************************  Treiber fÅr 600dpi Laser	 (HP-kompatibel)												*******************************************************************************/
/* evt. muû der Rand (LINKS) angepaût werden, also:
 * Dazu als Faustregel: 1Byte = 8Pixel = (8/600)" = (1/75)" ~ 0.339mm 
 * Das heiût: Grafik jetzt ca. 4mm zu weit links, Rand um 12 erhîhen, 
 * denn 12*0.338666 = 4.064mm
 * (Diese Formel gilt natÅrlich nur bei 600 DPI.)
 * FÅr den oberen Rand gilt 1mm ~ 23.5 Zeilen. da (25.4/600)mm = 1 Zeile
 * (Wenn man diese Datei an einen anderen Drucker anpaût, dann diese 
 *  bitte entsprechend umbennen (z.B. HP_LASER.C, dann wÑre z.B. 
 *  HOEHE=3350, LINKS=??? und an mich senden, BITTE!)
 */

/* Anpassung: Michael Hoppe */
#define OBEN 0L		/* Oberer Rand */
#define LINKS 45L	/* Linker Rand */#define MAX_DPI 600L	/* Maximale Auflîsung 600dpi */#define BREITE 5424L	/* max. Breite einer Grafikseite */#define HOEHE 7260L	/* max. Hoehe */
#include "hp.c"	/* HP-Standarttreiber */