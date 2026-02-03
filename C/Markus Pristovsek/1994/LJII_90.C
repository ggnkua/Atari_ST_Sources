/*******************************************************************************  Treiber fÅr LaserJet	 (HP-kompatibel)												*******************************************************************************/
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

#define OBEN 0L		/* Oberer Rand */
#define LINKS 0L	/* Linker Rand */#define MAX_DPI 300L	/* Maximale Auflîsung 600dpi */#define BREITE 3386L	/* max. Breite einer Grafikseite */#define HOEHE 2336L	/* max. Hoehe */
#define NO_COMPRESSION	/* Daten nicht komprimieren */

#include "hp_90.c"	/* HP-Standarttreiber */