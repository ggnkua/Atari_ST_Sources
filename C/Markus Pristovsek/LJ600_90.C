/*******************************************************************************  Treiber fÅr 600dpi Laser	 (HP-kompatibel)												****
****	Ausdruck um 90 Grad gedreht																				*******************************************************************************/
/* Sollte auch Deskjet und o. Ñ. 300dpi Laser bedienen */

/* evt. muû der Rand (LINKS) angepaût werden, also:
 * (Diese Formel gilt natÅrlich nur bei 600 DPI.)
 * FÅr den Rand gilt 1mm ~ 23.5 Zeilen. da (25.4/600)mm = 1 Zeile
 * (Wenn man diese Datei an einen anderen Drucker anpaût, dann diese 
 *  bitte entsprechend umbennen (z.B. HP_LASER.C, dann wÑre z.B. 
 *  HOEHE=3350, LINKS=??? und an mich senden, BITTE!)
 */

#define OBEN 126L		/* Oberer Rand */
#define LINKS 0L	/* Linker Rand */#define MAX_DPI 600L	/* Maximale Auflîsung 600dpi */#define BREITE 5424L	/* max. Breite einer Grafikseite */#define HOEHE 7260L	/* max. Hoehe */
#include "hp_90.c"	/* HP-Standarttreiber */