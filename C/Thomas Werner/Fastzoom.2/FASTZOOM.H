/*--------------------------------------------------------------------*/
/*												Fastzoom-Routine														*/
/*																																		*/
/* vx,vy  - x/y-Vergr”žerung																					*/
/* x,y 	  - x/y-Koordinate der linken oberen Ecke des Originals				*/
/* br     - Breite in Pixel																						*/
/* ho     - H”he in Pixel																							*/
/* xo,yo  - x/y-Koordinate der linken oberen Ecke der Vergr”žerung		*/
/* mode   - Schreibmodus																							*/
/* handle - Grafik-Handle																							*/
/* schirm - Adresse der MFDB-Struktur des Bildschirms									*/
/*--------------------------------------------------------------------*/

void great(int vx,int vy,int x,int y,int br,int ho,int xo,int yo,
					int mode,int handle, MFDB *schirm);
