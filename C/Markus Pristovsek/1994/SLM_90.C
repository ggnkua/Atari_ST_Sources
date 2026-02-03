/****************************************************************************/
/*  Querdruck fÅr SLM-Laser; Braucht mindestens 1MB FREIEN Speicher         */
/*  ACHTUNG: Darf nicht in's TT-RAM geladen werden!													*/
/****************************************************************************/


#include <portab.h>
#include <string.h>

#include "mintbind.h"
#include "treiber.h"

/**** Aus ASSLASER.S ****/
extern void print_laser(int *); /* Druckt die Bitmap des Lasers */
extern int check_laser(void);   /* True, wenn Laser an */

/**** Assembler zur Vergrîûerung ****/
extern void kop2_1( void *quell, long quellweite, void *ziel );

#define LINKS	59L
#define OBEN	89L
#define HOEHE	3386L
#define WEITE	2336L
#define WWEITE 146L
#define MAX_DPI	300L

#define RECHTS	(2480-(WEITE+LINKS))



	/* Diese wird an den Drucker geschickt */
WORD	bitmap[494794L];
char	tmp_zeile[WWEITE*2];	/* Gedrehte Zeilen + Sicherheit */
char	display_status[4]="\033H*", *drucker_ext="";


/* Datei ausdrucken */
WORD	drucke( UBYTE *p, LONG x, LONG y, LONG weite, LONG max_zeile, LONG h_dpi, LONG v_dpi, WORD th, WORD flag )
{
	LONG		i, j, max_spalte;
	LONG		drehe_off, drehe_copy;

	/* Kann logischerweise nicht in Datei drucken */
	if(  th!=3  &&  flag!=7  )
	{
		Cconws( "\007SLM_90 kann nicht in eine Datei und nur alles auf einmal drucken!\xD" );
		(void)x;
		(void)y;
		return 0;
	}

	/* Nicht angeschaltet? => kein Druck! */
	if(  !check_laser()  )
	{
		Cconws( "\007Laser nicht angeschlossen!\xD" );
		return 0;
	}

	Cconws( display_status );
	display_status[2] ^= 1;

		/* Horizontale und vertikale Auflîsung natÅrlich vertauschen */
	j = v_dpi;
	v_dpi = h_dpi;
	h_dpi = j;

		/* Horizontale Auflîsung: 75,150,300 DpI */
	if(  h_dpi>175  )
		h_dpi = 300;
	else
		h_dpi = 150;

		/* Vertikale Auflîsung: 75,100,150,300 DpI */
	if(  v_dpi>175  )
		v_dpi = 300;
	else if(  v_dpi>110  )
		v_dpi = 150;
	else if(  v_dpi>80  )
		v_dpi = 100;
	else
		v_dpi = 75;

		/* Unsinnige Werte werden als Maximum angenommen */
	if(  h_dpi<=0  ||  h_dpi>MAX_DPI  )
		h_dpi = MAX_DPI;
	if(  v_dpi<=0  ||  v_dpi>MAX_DPI  )
		v_dpi = MAX_DPI;

		/* Bitmapanfang entsprechend verschieben */
	max_spalte = (weite+15)/16;
	max_spalte *= 2;
	p += max_spalte*RECHTS;	/* Nicht druckbare RÑnder*/
	max_zeile -= RECHTS;
	x = OBEN;
	if(  max_zeile>(WEITE*h_dpi)/MAX_DPI  )
	{
		max_zeile = WEITE;
		drehe_copy = (2*WWEITE*h_dpi)/MAX_DPI;
		drehe_off = 0;;
	}
	else
	{
		drehe_off = ((max_zeile*h_dpi)/MAX_DPI+7)/8;
		drehe_copy = (2*WWEITE*h_dpi)/MAX_DPI - drehe_off;
	}
/*		drehe_off = ((max_zeile*h_dpi)/MAX_DPI+7)/8-2*WWEITE;*/

	for(  i=0;  i<HOEHE  &&  x<weite;  x++  )
	{
		if(  (x%128)==0  )
		{
			Cconws( display_status );
			display_status[2] ^= 1;
		}

		drehe_90( p, tmp_zeile+drehe_off, max_spalte, drehe_copy, x );
		switch( (WORD)h_dpi )
		{
			case 300:	memcpy( bitmap+i*WWEITE, tmp_zeile, 2*WWEITE );
							break;
			case 150:	kop2_1( tmp_zeile, WWEITE, bitmap+i*WWEITE );
							break;
		}
		switch( (WORD)v_dpi )
		{
			case 300:	/* Nix */
								i++;
							break;
								/* Letzte Zeile kopieren */
			case 150:	memcpy( bitmap+(i+1L)*WWEITE, bitmap+i*WWEITE, 2*WWEITE );
								i += 2;
							break;
								/* Letzten beiden Zeile kopieren */
			case 100: memcpy( bitmap+(i+1L)*WWEITE, bitmap+i*WWEITE, 2*WWEITE );
								memcpy( bitmap+(i+2L)*WWEITE, bitmap+i*WWEITE, 2*WWEITE );
								i += 3;
							break;
								/* Letzten drei Zeile kopieren */
			case 75: 	memcpy( bitmap+(i+1L)*WWEITE, bitmap+i*WWEITE, 2*WWEITE );
								memcpy( bitmap+(i+2L)*WWEITE, bitmap+i*WWEITE, 2*WWEITE );
								memcpy( bitmap+(i+3L)*WWEITE, bitmap+i*WWEITE, 2*WWEITE );
								i += 4;
							break;
		}
	}
  print_laser(bitmap);    /* Bitmap 2336x3386 drucken (in Assembler) */
	return 0;
}


