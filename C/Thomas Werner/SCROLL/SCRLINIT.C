/*   SCROLL - ROUTINEN  fÅr MEGAMAX LASER C   */
/*          von Ulrich Witte                  */
/*      (c) 1992 MAXON Computer               */

#include <tos.h>
#include "scroll.h"


void scrollinit(RECT *k,SCROLLER *scroll,int links_oder_oben)  
{
   register int help, x1, x2;
   
	/* x-Koordinaten geteilt durch 16 ergibt An- */
	/* zahl der Worte pro Zeile */    
	/* Die x-Koordinaten der Struktur */
	/* dÅrfen nicht geÑndert werden */
   x1 = k->x1 >> 4;   
   x2 = k->x2 >> 4;   
   
   scroll->adr = (char *)Physbase();  /* Monitor-Adresse holen */
      
   help = x2 - x1;										/* Differenz merken */
   if (links_oder_oben)    /* ==> Adresse auf linke obere Ecke setzen */
      scroll->adr += (x1 << 1) + (k->y1 * 80);
   else                    /* ==> oder rechts unten als Adresse eintragen */
      scroll->adr += (x2 << 1) + ((k->y2 - 1) * 80);  
   scroll->words = help - 1;
   scroll->offset = (long)(help << 1);	/* Bytes = Worte * 2 */
   scroll->zeilen = k->y2 - k->y1 - 1;	/* Zeilen - 1 */ 
   scroll->pixel = help << 4; 					/* Pixelzahl = Differenz * 16 */
}
