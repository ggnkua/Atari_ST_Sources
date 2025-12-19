/*********************************************************************
****    Universaltreiber fÅr HP-kompatible Drucker                ****
*********************************************************************/

/* Siehe auch Datei JP350WS.C */

#include <portab.h>
#include <mintbind.h>
#include <atarierr.h>

#include <stdlib.h>
#include <string.h>

#include <treiber.h>


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

#ifndef BREITE	/* druckbare Breite (in Pixel) */
#define BREITE ((2336L*MAX_DPI)/300L)
#endif

#ifndef HOEHE		/* druckbare Hîhe (in Pixel) */
#define HOEHE ((3386L*MAX_DPI)/300L)
#endif

#ifdef FAST_PRN#define WRITE(i,j) ((th>0)?(Fwrite(th,i,j)):(print_block(i,j)))#endif
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


static UBYTE	druckzeile[1024];


WORD	drucke( UBYTE *p, LONG weite, LONG max_zeile, LONG h_dpi, LONG v_dpi )
{
	UBYTE	tmp1[50], tmp2[(BREITE+15)/7];
	LONG	rechts, i, j, x, v_hoehe, v_weite;
	WORD	th, rep, modus=0/* Komprimiert oder nicht? */;
	extern char	tmp_file[256]; /* In Datei drucken? */

#ifdef FAST_PRN	/* FÅr viel Geschwindigkeit = sinnvoll groûer Puffer */	if(  tmp_file[0]>0  ||  open_printer()<0  )#endif		th = (WORD)get_tempfile( "hpq" );	if(  th<0  )		return -1;	if(  h_dpi>700  )
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
	p += ((weite+15)/16)*2*i;	/* Nicht druckbare RÑnder*/

	v_weite = weite;
	if(  v_weite>(HOEHE*h_dpi)/MAX_DPI  )
		v_weite = (HOEHE*h_dpi)/MAX_DPI;
	weite = ((weite+15)/16)*2;

	max_zeile = max_zeile-i-1;
	v_hoehe = max_zeile;
	if(  v_hoehe>(BREITE*h_dpi)/MAX_DPI  )
		v_hoehe = (BREITE*h_dpi)/MAX_DPI;
	max_zeile = v_hoehe;

		/* RÑnder feststellen */
	for(  x=0;  x*8<v_hoehe  &&  ist_next_leer( p+x, weite, max_zeile );  x++  )
		;

	x *= 8;
	if(  x>=v_hoehe  )
	{
		/* Seite leer */
		WRITE( 5L, " \33*rB\14" ); /*FF*/
		flush_block();
		return 0;
	}

		/* In die obere Ecke */
	WRITE( 26, " \33*p0Y\33*p-300Y\33*p0X\33*p-300X" );
		/* Grafikdruck Anfang */
	strcpy( tmp1, "\33&100L\33*rB\33*t" );
		/* Grafikauflîsung festlegen */
	ltoa( h_dpi, tmp1+13, 10 );
	strcat( tmp1, "R\33*r" );
	WRITE( strlen(tmp1), tmp1 );
		/* Grafikweite festlegen */
	ltoa( v_hoehe, tmp1, 10 );
	v_hoehe = (v_hoehe+7)/8+1;
	strcat( tmp1, "s0A" );
	WRITE( strlen(tmp1), tmp1 );


	if(  x-LINKS>0  )
	{
		strcpy( tmp1, "\33*b" );
		ltoa( x, tmp1+3, 10 );
		strcat( tmp1, "Y" );
		WRITE( strlen(tmp1), tmp1 );
	}
	else
		x = LINKS;
	rechts = 0;

	while(  x<v_weite  )
	{
		if(  x%8==0  )
		{
			UBYTE	*q=p+(x/8);

			i = 0;
			while(  i<max_zeile  &&  *q==0  )
			{
				i++;
				q += weite;
			}
			if(  i>=max_zeile  )
			{
				WRITE( 5, "\33*b8Y" );
				x += 8;
				continue;
			}
			rechts = 0;
			if(  i>7  )
				rechts = (i/8)-1;
		}
		drehe_90( p+rechts*8*weite, tmp2, weite, v_hoehe-rechts, x );

		/* Wir komprimieren */
		for(  i=0, j=0;  i<v_hoehe-rechts  &&  j<v_hoehe-rechts;  /*Nichts*/  )
		{
			if(  find_next_same( &rep, tmp2+i, v_hoehe-i-rechts )  )
			{
				/* Gleiche */
				druckzeile[j++] = 1-rep;
				druckzeile[j++] = tmp2[i];
				i += rep;
			}
			else
			{
				/* Ungleiche */
				druckzeile[j++] = rep-1;
				while(  rep-->0  )
					druckzeile[j++] = tmp2[i++];
			}
		}

			/* Und nun den interessanten Rest */
		if(  j<v_hoehe-rechts  )
		{
			/* Komprimieren brachte etwas */
			strcpy( tmp1, "\33*b2m" );
			ltoa( j, tmp1+5-modus, 10 );
			strcat( tmp1, "W" );
			WRITE( strlen(tmp1), tmp1 );
			WRITE( j, druckzeile );
			modus = 2;
		}
		else
		{
			/* Komprimieren brachte nichts */
			j = v_hoehe-rechts;
			strcpy( tmp1, "\33*b0m" );
			ltoa( j, tmp1+3+modus, 10 );
			strcat( tmp1, "W" );
			WRITE( strlen(tmp1), tmp1 );
			WRITE( j, tmp2 );
			modus = 0;
		}

		x++;	/* NÑchste Zeile */
	}

	/* Ende Grafikmodus */
	/* Ende Seite */	if(  5!=WRITE( 5L, "\33*rB\14" )  )
	{		/* Platz reichte nicht aus */		if(  th>0  )			Fclose( th );		th = -1;	}	if(  tmp_file[0]==0  )		flush_block();
	return 0;
}
/* 22.1.93 */


