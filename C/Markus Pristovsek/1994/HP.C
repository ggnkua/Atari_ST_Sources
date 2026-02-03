/*********************************************************************
****    Universaltreiber fÅr HP-kompatible Drucker                ****
*********************************************************************/

/* Siehe auch Datei JP350WS.C */

#include <portab.h>
#include <atarierr.h>

#include <stdio.h>
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
#define WEITE 9344L
#endif

#ifndef HOEHE		/* druckbare Hîhe (in Pixel) */
#define HOEHE 13544L
#endif

#ifndef EXT
char *drucker_ext="hp";
#else
char *drucker_ext=EXT;
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



WORD	drucke( UBYTE *p, LONG start_x, LONG start_y, LONG weite, LONG max_zeile, LONG h_dpi, LONG v_dpi, WORD th, WORD flag )
{
	UBYTE	tmp1[50];
	LONG	max_spalte, zeile, lz, rechts;
	LONG	i, j;
	WORD	rep, modus=0/* Komprimiert oder nicht? */;

	if(  start_x>0  )
		return -1;

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

	(void)v_dpi;	/* h_dpi = v_dpi bei HP-kompatiblen! */

	i = 0;
	if(  flag&1  )
		i = (OBEN*h_dpi)/MAX_DPI;	/* Oberen Rand Åberspringen */
	j = (LINKS*h_dpi)/MAX_DPI;
	max_spalte = (weite+15)/16;
	max_spalte *= 2;
	p += (max_spalte*i) + j;	/* Nicht druckbare RÑnder*/

	max_spalte -= j;
	if(  weite>(WEITE+LINKS*8)*h_dpi/MAX_DPI  /* LINKS*8 nicht druckbar!*/  )
		max_spalte = (WEITE*h_dpi)/(8*MAX_DPI);

	max_zeile -= i+1;
	max_zeile += start_y;
	if(  max_zeile>(HOEHE*h_dpi)/MAX_DPI  )
		max_zeile = (HOEHE*h_dpi)/MAX_DPI;
	zeile = start_y;
	weite = (weite+15)/16;
	weite *= 2;

	/* RÑnder feststellen */
	while(  max_spalte>0  &&  ist_next_leer( p+max_spalte-1, weite, max_zeile )  )
		max_spalte--;

	if(  flag==4  ||  (flag==7  &&  max_spalte<=1)  )
	{
		/* Seite leer */
		lz = max_zeile-zeile;
		zeile = max_zeile;
	}

	if(  flag&1  )
	{	/* In die obere Ecke */
		/* & Grafikauflîsung festlegen */
		sprintf( tmp1, " \33*p0Y\33*p-300Y\33*p0X\33*p-300X\33*rB\33*t%ldR", h_dpi );
		print_str( tmp1, th );
#ifndef NO_COMPRESSION
			/* Grafikweite festlegen */
		sprintf( tmp1, "\033*r%lds1A\033*b0M", max_spalte*8 );
		print_str( tmp1, th );
#endif
	}

	while(  zeile<max_zeile  &&  (flag&2)  )
 	{
 			/* Leerzeilen Åberspringen */
 		for(  lz=0;  zeile<max_zeile  &&  ist_leerzeile( p, max_spalte );  lz++, zeile++  )
 			p += weite;
 		if(  lz>0  )
 		{
#ifdef NO_COMPRESSION
			sprintf( tmp1, "\33*p+%ldY", lz );
#else
			sprintf( tmp1, "\33*b%ldY", lz );
#endif
			print_str( tmp1, th );
 		}

			/* eine oder Druckzeilen an den Drucker! */
		for(  lz=max_zeile;  zeile<lz  &&  zeile<max_zeile  &&  !ist_leerzeile( p, max_spalte );  zeile++  )
		{
			/* Wir komprimieren */
			for(  rechts=1;  rechts<max_spalte  &&  p[max_spalte-rechts]==0;  rechts++  )
				;
			rechts--;
#ifndef	NO_COMPRESSION
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
				print_str( tmp1, th );
				print_block( j, druckzeile, th );
				modus = 2;
			}
			else
			{
				/* Komprimieren brachte nichts */
				j = max_spalte-rechts;
				strcpy( tmp1, "\33*b0m" );
				ltoa( j, tmp1+3+modus, 10 );
				strcat( tmp1, "W" );
				print_str( tmp1, th );
				print_block( j, p, th );
				modus = 0;
			}
#else
			/* FÅr LaserJet II & kompatible: Unkomprimiert */
			j = max_spalte-rechts;
			sprintf( tmp1, "\33*b%ldW", j );
			print_str( tmp1, th );
			print_block( j, p+i, th );
			modus = 0;
#endif
			p += weite;
		} /* for */
		lz = 0;
	} /* while */

	/* Ende Grafikmodus */
	if(  flag&4  )
	{
		if(  6L!=print_block( 6L, " \33*rB\14", th )  )
			return -1;
	}
	else
		if(  lz>0  )
 		{
#ifdef NO_COMPRESSION
			sprintf( tmp1, "\33*p+%ldY", lz );
#else
			sprintf( tmp1, "\33*b%ldY", lz );
#endif
			print_str( tmp1, th );
 		}

	/* Sollte immer gut gehen! (d.h. kein File zu drucken!) */
	return 0;
}
/* 22.1.93 */
