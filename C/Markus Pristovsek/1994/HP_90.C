/*********************************************************************
****    Universaltreiber fÅr HP-kompatible Drucker                ****
*********************************************************************/

/* Siehe auch Datei JP350WS.C */

#include <portab.h>
#include <atarierr.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "mintbind.h"
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

#ifndef BREITE	/* druckbare Breite (in Pixel) */
#define BREITE 13544L
#endif

#ifndef HOEHE		/* druckbare Hîhe (in Pixel) */
#define HOEHE 9344L
#endif

#ifdef FAST_PRN#define WRITE(i,j) (print_block(i,j,th))#endif
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


static UBYTE	druckzeile[1024];


WORD	drucke( UBYTE *p, LONG start_x, LONG start_y, LONG weite, LONG max_zeile, LONG h_dpi, LONG v_dpi, WORD th, WORD flag )
{
	UBYTE	tmp1[50], tmp2[(BREITE+15)/7], x_offset[10]="", *q;
	LONG	rechts, i, j, x, v_hoehe, v_weite;
	WORD	rep, modus/* Komprimiert oder nicht? */, and;
	extern char	tmp_file[256]; /* In Datei drucken? */

	if(  (flag&7)!=7  &&  start_y>0  )
	{
		Cconws( "Illegaler Modus" );
		/* Keine Warnings mehr... */
		(void)start_y;
		(void)v_dpi;
		/* Nur ganze Seiten! */
		return -1;
	}

	if(  flag&4  )
	{	/* Nur Seitenvorschub */
		if(  5!=WRITE( 5L, " \33*rB\14" )  )
			return -1; /*FF*/
	}

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

	if(  weite+start_x>(BREITE*h_dpi)/MAX_DPI  )
		v_weite = ((BREITE-start_x)*h_dpi)/MAX_DPI;
	else
		v_weite = weite;
	weite = ((weite+15)>>4)*2;		/* aufgerundete Byteweite */

	/* Nicht druckbarer Rand */
	i = (OBEN*h_dpi)/MAX_DPI;
	p += i*weite;

	max_zeile = max_zeile-i-1;
	v_hoehe = max_zeile;
	if(  v_hoehe>(HOEHE*h_dpi)/MAX_DPI  )
		max_zeile = (HOEHE*h_dpi)/MAX_DPI;
	else
		/* Linken Rand setzen */
		sprintf( x_offset, "%ldx", ((BREITE*h_dpi)/MAX_DPI-max_zeile+7)&0x7FFFFFF8L );
	v_hoehe = (max_zeile+7)>>3;

		/* Falls Hoehe nicht durch 8 teilbar */
	and = (WORD)(max_zeile&7);
	if(  and==0  )
		and = 0x00FF;
	else
		and = 0x00FF>>and;

		/* RÑnder feststellen */
	for(  x=0;  x*8<v_weite  &&  ist_next_leer( p+x, weite, max_zeile );  x++  )
		;
	x *= 8;

	i = 0;
	if(  flag&1  )
	{	/* Evt. Linken Rand abziehen */
		i = (LINKS*h_dpi)/MAX_DPI;

		/* In die obere Ecke */
		WRITE( 27, " \33*p0Y\33*p-300Y\33*p0X\33*p-300X" );
	}

	if(  x-i>0  )
	{	/* Rand an der linken Seite */
		sprintf( tmp1, "\33*p+%ldY", x-i );
		WRITE( strlen(tmp1), tmp1 ); /*FF*/
	}
	else
		if(  flag&1  )
			x = i;

	/* Grafikdruck Anfang */
	/* Grafikauflîsung festlegen */
	/* Grafikweite festlegen */
	sprintf( tmp1, "\33&100L\33*rB\33*t%ldR\33*r0A", h_dpi );
	WRITE( strlen(tmp1), tmp1 );
	rechts = 0;

	for(  modus=-1;  x<v_weite;  x++  )
	{
		if(  (x&7)==0  ||  modus==-1  )
		{	/* NÑchste 8er Zeile: Neue RÑnder */
			q = p+(x>>3);
			i = 0;
			while(  i<max_zeile  &&  *q==0  )
			{
				i++;
				q += weite;
			}
			if(  i>=max_zeile  )
			{
				i = x;
				if(  i>v_weite  )
					i = v_weite;
				i = 8-(i&7);
				sprintf( tmp1, "\33*b%ldY", i );
				WRITE( strlen(tmp1), tmp1 );
				x += i;
				continue;
			}
			rechts = (i>>3);
		}

		/* und den Needle-Warp... */
		drehe_90( p+rechts*8*weite, tmp2, weite, v_hoehe-rechts-1, x );
		tmp2[0] &= and;

#ifdef	NO_COMPRESSION
		/* FÅr LaserJet II & kompatible: Unkomprimiert */
		strcpy( tmp1, "\33*b" );
		j = v_hoehe-rechts;
		for(  i=0;  i<j  &&  p[i]==0;  i++  )
			;
		if(  i>4  )
		{
			i--;
			j -= i;
			ltoa( i*8, tmp1+3, 10 );
			strcat( tmp1, "x" );
		}
		ltoa( j, tmp1+strlen(tmp1), 10 );
		strcat( tmp1, "W" );
		WRITE( strlen(tmp1), tmp1 );
		WRITE( j, p+i );
#else
		/* Wir komprimieren */
		for(  i=0, j=0;  i<v_hoehe-rechts  &&  j<v_hoehe-rechts;  /* Nix! */  )
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
			if(  modus!=2  )
				sprintf( tmp1, "\33*b%s2m%ldW", x_offset, j );
			else
				sprintf( tmp1, "\33*b%s%ldW", x_offset, j );
			WRITE( strlen(tmp1), tmp1 );
			WRITE( j, druckzeile );
			modus = 2;
		}
		else
		{
			/* Komprimieren brachte nichts */
			j = v_hoehe-rechts;
			if(  modus!=0  )
				sprintf( tmp1, "\33*b%s0m%ldW", x_offset, j );
			else
				sprintf( tmp1, "\33*b%s%ldW", x_offset, j );
			WRITE( strlen(tmp1), tmp1 );
			WRITE( j, tmp2 );
			modus = 0;
		}
		/* 8 Bits fertig */
#endif
	}

	/* Ende Grafikmodus */
	/* Ende Seite */	if(  (flag&4)  &&  5!=WRITE( 5L, "\33*rB\14" )  )
		/* Platz reichte nicht aus */		return -1;
	return 0;
}
/* 22.1.93 */


