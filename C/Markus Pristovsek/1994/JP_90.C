/*******************************************************************************  Treiber fÅr Olivetti JP350WS-Tintenstrahldrucker (HP-kompatibel)  ****
****  Ausdruck um 90 Grad gedreht                                       *******************************************************************************/
/* Sollte auch Deskjet und 300dpi Laser bedienen */

/* evt. muû der Rand (LINKS) angepaût werden, also:
 * Dazu als Faustregel: 1Pixel = (1/300)" = (25.4/300)mm 
 * (Diese Formel gilt natÅrlich nur bei 300 DPI.)
 * FÅr den oberen Rand gilt es entsprechend
 * (Wenn man diese Datei an einen anderen Drucker anpaût, dann diese 
 *  bitte entsprechend umbennen (z.B. HP_LASER.C, dann wÑre z.B. 
 *  HOEHE=3350, LINKS=??? und an mich senden, BITTE!)
 */

#define OBEN 101L			/* Oberer Rand */
#define LINKS 24L			/* Linker Rand */#define MAX_DPI 300L	/* Maximale Auflîsung 300dpi */#define BREITE 3360L		/* max. Breite */#define HOEHE 2336L	/* max. Hîhe einer Grafikseite */#include "hp_90.c"	/* HP-Standarttreiber */

/* email: prissi@marie.physik.tu-berlin.de
 * Post:  Markus Pristovsek
 *        Boumannstraûe 66
 *        13467 Berlin
 */