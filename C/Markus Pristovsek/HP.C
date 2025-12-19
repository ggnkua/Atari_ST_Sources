/*********************************************************************
****    Universaltreiber fÅr HP-kompatible Drucker                ****
*********************************************************************/

/* Siehe auch Datei JP350WS.C */

#include <portab.h>
#include <atarierr.h>

#include <stdlib.h>
#include <string.h>

#include "mintbind.h"	/* Geht seltsamerweise nur mit der eigenen Version */
#include "treiber.h"


/********************************************************************/
/* Setzt die freien Werte auf Standartwerte */

#ifndef OBEN	/* Wenn noch kein oberer Rand definiert */
#define OBEN 0L
#endif

#ifndef LINKS	/* Wenn noch kein linker Rand definiert */
#define LINKS 0L
#endif

#ifndef MAX_DPI	/* Wenn keine maximale Auflîsung definiert */
#define MAX_DPI 1200L
#endif

#ifndef WEITE	/* druckbare Breite (in Pixel) */
#define WEITE ((2336L*MAX_DPI)/300L)
#endif

#ifndef HOEHE		/* druckbare Hîhe (in Pixel) */
#define HOEHE ((3386L*MAX_DPI)/300L)
#endif


/********************************************************************/



/* Findet entweder Wiederholung (TRUE) oder nichts */
WORD	find_next_same( WORD *rep, UBYTE *p, LONG limit )
{
	WORD	i;

		/* SpezialfÑlle */
	if(  limit<1  )
	{
		*rep = 1;
		return FALSE;
	}
	if( limit<2  &&  p[0]==p[1]  )
	{
		*rep = 2;
		return TRUE;
	}

		/* Sonst getrennt */
	if(  p[0]==p[1]  &&  p[1]==p[2]  )
	{
		/* Abstand zum nÑchsten Ungleichen... */
		i = 3;
		while(  i<128  &&  i<limit  &&  p[0]==p[i]  )
			i++;
		*rep = i;
		return TRUE;
	}
	else
	{
		/* ... bzw. Gleichen ermitteln */
		i = 0;
		while(  i<128  &&  i<limit  &&  !(p[i]==p[i+1]  &&  p[i]==p[i+2])  )
			i++;
		*rep = i;
		return FALSE;
	}
}
/* 17.1.93 */


static UBYTE	druckzeile[4096];

/* Wird aufgerufen, wenn Datei zu drucken */
WORD	drucke_datei( UBYTE *p, LONG weite, LONG max_zeile, LONG h_dpi, LONG max_spalte, LONG zeile )
{
	UBYTE	tmp1[50];
	LONG	lz, rechts;
	LONG	i, j;
	WORD	rep, modus=0/* Komprimiert oder nicht? */;
	WORD	th;

	/* RÑnder feststellen */
	while(  ist_next_leer( p+max_spalte-1, weite, max_zeile )  &&  max_spalte>1  )
		max_spalte--;

	if(  (th=(WORD)get_tempfile( "hp" ))<0  )
		return -1;

	if(  max_spalte<=1  )
	{
		/* Seite leer */
		Fwrite( th, 5L, " \33*rB\14" ); /*FF*/
		return Fclose( th );
	}

		/* In die obere Ecke */
	Fwrite( th, 27, " \33*p0Y\33*p-300Y\33*p0X\33*p-300X" );
		/* Grafikdruck Anfang */
	strcpy( tmp1, "\33*rB\33*t" );
		/* Grafikauflîsung festlegen */
	ltoa( h_dpi, tmp1+7, 10 );
	strcat( tmp1, "R\33*r" );
	Fwrite( th, strlen(tmp1), tmp1 );
		/* Grafikweite festlegen */
	ltoa( max_spalte*8, tmp1, 10 );
	strcat( tmp1, "s0A" );
	Fwrite( th, strlen(tmp1), tmp1 );

	while(  zeile<max_zeile  )
 	{
 			/* Leerzeilen Åberspringen */
 		for(  lz=0;  zeile<max_zeile  &&  ist_leerzeile( p, max_spalte );  lz++, zeile++  )
 			p += weite;
 		if(  lz>0  )
 		{
			strcpy( tmp1, "\33*b" );
			ltoa( lz, tmp1+3, 10 );
			strcat( tmp1, "Y" );
			Fwrite( th, strlen(tmp1), tmp1 );
 		}

			/* eine oder Druckzeilen an den Drucker! */
		for(  lz=max_zeile;  zeile<lz  &&  zeile<max_zeile  &&  !ist_leerzeile( p, max_spalte );  zeile++  )
		{
			/* Wir komprimieren */
			for(  rechts=1;  rechts<max_spalte  &&  p[max_spalte-rechts]==0;  rechts++  )
				;
			rechts--;
			for(  i=0, j=0;  i<max_spalte-rechts  &&  j<max_spalte-rechts;  /*Nichts*/  )
			{
				if(  find_next_same( &rep, p+i, max_spalte-i-rechts )  )
				{
					/* Gleiche */
					druckzeile[j++] = 1-rep;
					druckzeile[j++] = p[i];
					i += rep;
				}
				else
				{
					/* Ungleiche */
					druckzeile[j++] = rep-1;
					while(  rep-->0  )
						druckzeile[j++] = p[i++];
				}
			}

			/* Und nun den interessanten Rest */
		if(  j<max_spalte-rechts  )
		{
			/* Komprimieren brachte etwas */
			strcpy( tmp1, "\33*b2m" );
			ltoa( j, tmp1+3+2-modus, 10 );
			strcat( tmp1, "W" );
			Fwrite( th, strlen(tmp1), tmp1 );
			Fwrite( th, j, druckzeile );
			modus = 2;
		}
		else
		{
			/* Komprimieren brachte nichts */
			j = max_spalte-rechts;
			strcpy( tmp1, "\33*b0m" );
			ltoa( j, tmp1+3+modus, 10 );
			strcat( tmp1, "W" );
			Fwrite( th, strlen(tmp1), tmp1 );
			Fwrite( th, j, p );
			modus = 0;
		}

		p += weite;
		}
	}

	/* Ende Grafikmodus */
	/* Sollte immer gut gehen! (d.h. kein File zum drucken!) */
	Fwrite( th, 5L, "\33*rB\14" );
	return Fclose( th );
}
/* 22.1.93 */



WORD	drucke( UBYTE *p, LONG weite, LONG max_zeile, LONG h_dpi, LONG v_dpi )
{
	UBYTE	tmp1[50];
	LONG	max_spalte, zeile, lz, rechts;
	LONG	i, j;
	WORD	rep, modus=0/* Komprimiert oder nicht? */;
	extern char	tmp_file[256]; /* In Datei drucken? */

	if(  h_dpi>700  )
		h_dpi = 1200;
	else if(  h_dpi>350  )
		h_dpi = 600;
	else if(  h_dpi>175  )
		h_dpi = 300;
	else if(  h_dpi>110  )
		h_dpi = 150;
	else if(  h_dpi>80  )
		h_dpi = 100;
	else
		h_dpi = 75;

		/* Unsinnige Werte werden als Maximum angenommen */
	if(  h_dpi<=0  ||  h_dpi>MAX_DPI  )
		h_dpi = MAX_DPI;

	i = (OBEN*h_dpi)/MAX_DPI;
	j = (LINKS*h_dpi)/MAX_DPI;
	max_spalte = (weite+15)/16;
	max_spalte *= 2;
	p += (max_spalte*i) + j;	/* Nicht druckbare RÑnder*/

	max_spalte -= j;
	if(  weite>(WEITE+LINKS*8)*h_dpi/MAX_DPI  /* LINKS*8 nicht druckbar!*/  )
		max_spalte = (WEITE*h_dpi)/(8*MAX_DPI);

	max_zeile -= i+1;
	if(  max_zeile>(HOEHE*h_dpi)/MAX_DPI  )
		max_zeile = (HOEHE*h_dpi)/MAX_DPI;
	zeile = 0;
	weite = (weite+15)/16;
	weite *= 2;

	/* RÑnder feststellen */
	while(  max_spalte>0  &&  ist_next_leer( p+max_spalte-1, weite, max_zeile )  )
		max_spalte--;

	if(  tmp_file[0]>0  )
		return drucke_datei( p, weite, max_zeile, h_dpi, max_spalte, zeile );

	if(  open_printer()<0  )
		return -1;

	if(  max_spalte<=1  )
	{
		/* Seite leer */
		print_block( 5L, " \33*rB\14" ); /*FF*/
		return 0;
	}

		/* In die obere Ecke */
	print_block( 27L, " \33*p0Y\33*p-300Y\33*p0X\33*p-300X" );
		/* Grafikdruck Anfang */
	strcpy( tmp1, "\33*rB\33*t" );
		/* Grafikauflîsung festlegen */
	ltoa( h_dpi, tmp1+7, 10 );
	strcat( tmp1, "R\33*r" );
	print_block( strlen(tmp1), tmp1 );
		/* Grafikweite festlegen */
	ltoa( max_spalte*8, tmp1, 10 );
	strcat( tmp1, "s0A" );
	print_block( strlen(tmp1), tmp1 );

	while(  zeile<max_zeile  )
 	{
 			/* Leerzeilen Åberspringen */
 		for(  lz=0;  zeile<max_zeile  &&  ist_leerzeile( p, max_spalte );  lz++, zeile++  )
 			p += weite;
 		if(  lz>0  )
 		{
			strcpy( tmp1, "\33*b" );
			ltoa( lz, tmp1+3, 10 );
			strcat( tmp1, "Y" );
			print_block( strlen(tmp1), tmp1 );
 		}

			/* eine oder Druckzeilen an den Drucker! */
		for(  lz=max_zeile;  zeile<lz  &&  zeile<max_zeile  &&  !ist_leerzeile( p, max_spalte );  zeile++  )
		{
			/* Wir komprimieren */
			for(  rechts=1;  rechts<max_spalte  &&  p[max_spalte-rechts]==0;  rechts++  )
				;
			rechts--;
			for(  i=0, j=0;  i<max_spalte-rechts  &&  j<max_spalte-rechts;  /*Nichts*/  )
			{
				if(  find_next_same( &rep, p+i, max_spalte-i-rechts )  )
				{
					/* Gleiche */
					druckzeile[j++] = 1-rep;
					druckzeile[j++] = p[i];
					i += rep;
				}
				else
				{
					/* Ungleiche */
					druckzeile[j++] = rep-1;
					while(  rep-->0  )
						druckzeile[j++] = p[i++];
				}
			}

			/* Und nun den interessanten Rest */
		if(  j<max_spalte-rechts  )
		{
			/* Komprimieren brachte etwas */
			strcpy( tmp1, "\33*b2m" );
			ltoa( j, tmp1+3+2-modus, 10 );
			strcat( tmp1, "W" );
			print_block( strlen(tmp1), tmp1 );
			print_block( j, druckzeile );
			modus = 2;
		}
		else
		{
			/* Komprimieren brachte nichts */
			j = max_spalte-rechts;
			strcpy( tmp1, "\33*b0m" );
			ltoa( j, tmp1+3+modus, 10 );
			strcat( tmp1, "W" );
			print_block( strlen(tmp1), tmp1 );
			print_block( j, p );
			modus = 0;
		}

		p += weite;
		}
	}

	/* Ende Grafikmodus */
	/* Sollte immer gut gehen! (d.h. kein File zum drucken!) */
	print_block( 5L, "\33*rB\14" );
	flush_block();
	return 0;
#if 0
(864115415746648754)
	if(  max_spalte<1  )
	{
		/* Seite leer */
		print_block( 5L, " \33*rB\14" ); /*FF*/
		flush_block();
		return 0;
	}

		/* In die obere Ecke */
	print_block( 27, " \33*p0Y\33*p-300Y\33*p0X\33*p-300X" );
		/* Grafikdruck Anfang */
	strcpy( tmp1, "\33&100L\33*rB\33*t" );
		/* Grafikauflîsung festlegen */
	ltoa( h_dpi, tmp1+13, 10 );
	strcat( tmp1, "R\33*r" );
	print_block( strlen(tmp1), tmp1 );
		/* Grafikweite festlegen */
	ltoa( max_spalte*8, tmp1, 10 );
	strcat( tmp1, "s0A" );
	print_block( strlen(tmp1), tmp1 );

	while(  zeile<max_zeile  )
 	{
 			/* Leerzeilen Åberspringen */
 		for(  lz=0;  zeile<max_zeile  &&  ist_leerzeile( p, max_spalte );  lz++, zeile++  )
 			p += weite;
 		if(  lz>0  )
 		{
			strcpy( tmp1, "\33*b" );
			ltoa( lz, tmp1+3, 10 );
			strcat( tmp1, "Y" );
			print_block( strlen(tmp1), tmp1 );
 		}

			/* 50 Zeilen (eine Druckkopfhîhe an den Drucker! */
		for(  ;  zeile<max_zeile  &&  !ist_leerzeile( p, max_spalte );  zeile++  )
		{
			/* Wir komprimieren */
			for(  rechts=1;  rechts<max_spalte  &&  p[max_spalte-rechts]==0;  rechts++  )
				;
			rechts--;
			for(  i=0, j=0;  i<max_spalte-rechts  &&  j<max_spalte-rechts;  /*Nichts*/  )
			{
				if(  find_next_same( &rep, p+i, max_spalte-i-rechts )  )
				{
					/* Gleiche */
					druckzeile[j++] = 1-rep;
					druckzeile[j++] = p[i];
					i += rep;
				}
				else
				{
					/* Ungleiche */
					druckzeile[j++] = rep-1;
					while(  rep-->0  )
						druckzeile[j++] = p[i++];
				}
			}

				/* Und nun den interessanten Rest */
			if(  j<max_spalte-rechts  )
			{
				/* Komprimieren brachte etwas */
				strcpy( tmp1, "\33*b2m" );
				ltoa( j, tmp1+5-modus, 10 );
				strcat( tmp1, "W" );
				print_block( strlen(tmp1), tmp1 );
				print_block( j, druckzeile );
				modus = 2;
			}
			else
			{
				/* Komprimieren brachte nichts */
				j = max_spalte-rechts;
				strcpy( tmp1, "\33*b0m" );
				ltoa( j, tmp1+3+modus, 10 );
				strcat( tmp1, "W" );
				print_block( strlen(tmp1), tmp1 );
				print_block( j, p );
				modus = 0;
			}
	
			p += weite;
		}
	}

	/* Ende Grafikmodus */
	/* Sollte immer gut gehen! (d.h. kein File zum drucken!) */
	print_block( 5L, "\33*rB\14" );
	flush_block();
	return 0;
#endif
}
/* 22.1.93 */


