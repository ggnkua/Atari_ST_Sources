/*--------------------------------------------------------------------*/
/*												Fastzoom-Routine														*/
/*																																		*/
/*	Originalroutine in GFA-BASIC: Gerald Schmieder										*/
/*	C-Konvertierung: Thomas Werner																		*/
/*	(c) 1992 MAXON Computer GmbH																			*/
/*--------------------------------------------------------------------*/


#include <vdi.h>


/*--------------------------------------------------------------------*/
/*												Fastzoom-Routine														*/
/*																																		*/
/* vx,vy  - x/y-Vergrîûerung																					*/
/* x,y 	  - x/y-Koordinate der linken oberen Ecke des Originals				*/
/* br     - Breite in Pixel																						*/
/* ho     - Hîhe in Pixel																							*/
/* xo,yo  - x/y-Koordinate der linken oberen Ecke der Vergrîûerung		*/
/* mode   - Schreibmodus																							*/
/* handle - Grafik-Handle																							*/
/* schirm - Adresse der MFDB-Struktur des Bildschirms									*/
/*--------------------------------------------------------------------*/

void great(int vx,int vy,int x,int y,int br,int ho,int xo,int yo,
					int mode,int handle, MFDB *schirm)
{
	int		i, j, xw, yw, xy[8];
	
  /*-----------------------------------------------------*/
  /* Die Vergrîûerungsschleifen laufen rÅckwÑrts,				 */
  /* da sonst Probleme auftauchen, falls Teile der Kopie */
  /* in das Original reichen, sprich:										 */
  /* Vergrîûerung schon vergrîûerter Graphikteile !!!    */
  /*-----------------------------------------------------*/
	
	
  /**** Vergrîûerung der Vorlage an der Y-Achse ****/
  
  for (i=(y+ho); i>=y; i--)				/* Schleife fÅrs Einlesen der Zeilen */
  {
  	xy[0] = x;
  	xy[1] = i;
  	xy[2] = x+br;
  	xy[3] = i;
  	yw = yo+((i-y)*vy);
    for (j=0; j<vy; j++)				/* Schleife fÅrs Setzen der Zeile */
    {
	  	xy[4] = xo;
  		xy[5] = yw-j;
  		xy[6] = xo+br;
  		xy[7] = yw-j;
      vro_cpyfm(handle,mode,xy,schirm,schirm);
    }
	}
  
  /**** Vergrîûerung der Kopie an der X-Achse ****/
  
  for (i=xo+br; i>xo; i--)			/* Schleife fÅrs Einlesen der Spalten */
  {
  	xy[0] = i;
  	xy[1] = yo;
  	xy[2] = i;
  	xy[3] = yo+(ho*vy);
  	xw = xo+((i-xo)*vx);
    for (j=0; j<vx; j++)				/* Schleife fÅr Setzen der Spalte */
    {
	  	xy[4] = xw-j;
  		xy[5] = yo;
	  	xy[6] = xw-j;
	  	xy[7] = yo+(ho*vy);
      vro_cpyfm(handle,mode,xy,schirm,schirm);
    }
  }
}
