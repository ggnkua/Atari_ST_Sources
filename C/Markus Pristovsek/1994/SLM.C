/***************************************************************************/
/*                                                                         */
/* HardwareabhÑngiger Teil des DVI-Druckertreibers von Stefan Lindner      */
/* Anpassung fÅr Atari Laserdrucker SLM804 von Lutz Birkhahn               */
/* Optimierter Atari Lasertreiber von ‰-soft, Markus Fritze                */
/* Anpassung fÅr DVI-100 von Markus Pristovsek                             */
/*                                                                         */
/*    0.90 (07.09.1988): Diablo 630 - Funktionen implementiert             */
/*    1.0  (10.12.1988): Anpassungen an neue Treiberkern-Version           */
/*    1.1  (13.01.1989): - " -: top_offset und left_offset eingefÅhrt      */
/*    1.2  (23.04.1989): left_skip und Top_skip entfernt.                  */
/*    1.3  (20.05.1989): MRF: Eigenen Lasertreiber implementiert (V1.0)    */
/*    1.4  (15.07.1993): MP: Angepaû fÅr meinen Treiber, noch ungetestet,  */
/*                       aber die Bitmap sieht richtig aus.                */
/*                                                                         */
/*    ACHTUNG: Darf nicht in's TT-RAM geladen werden!											 */
/*    PureC Linker-Option -R und -M anschalten!                            */
/*                                                                         */
/***************************************************************************/


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

	/* Diese wird an den Drucker geschickt */
WORD	bitmap[494794L];
WORD	tmp_zeile[WWEITE];
char	display_status[4]="\033H*", *drucker_ext="";


/* Datei ausdrucken */
WORD	drucke( UBYTE *p, LONG x, LONG y, LONG weite, LONG max_zeile, LONG h_dpi, LONG v_dpi, WORD th, WORD flag )
{
	LONG		i, j, max_spalte;

	/* Kann logischerweise nicht in Datei drucken */
	if(  th!=3  &&  flag!=7  )
	{
		Cconws( "\007SLM kann nicht in eine Datei und nur alles auf einmal drucken!\xD" );
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

		/* Horizontale Auflîsung: 75,150,300 DpI */
	if(  h_dpi>175  )
		h_dpi = 300;
	else if(  h_dpi>100  )
		h_dpi = 150;
	else 
		h_dpi = 75;

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
	weite = (weite+15)/16;
	weite *= 2;
	p += (weite*OBEN) + (LINKS/8);	/* Nicht druckbare RÑnder*/
	max_spalte = weite-(LINKS/8);
	max_zeile -= OBEN+1;

	memset( bitmap, 0, 3386L*WWEITE*2 );
		/* Anfang feststellen */
	for(  j=0;  j<max_zeile  &&  ist_leerzeile( p, max_spalte );  j++  )
		p += weite;
	i = (j*MAX_DPI)/v_dpi;

	while(  i<HOEHE  &&  j<max_zeile  )
	{
		if(  (i%500)==0  )
		{
			Cconws( display_status );
			display_status[2] ^= 1;
		}

		switch( (WORD)h_dpi )
		{
			case 300:	if(  max_spalte>WWEITE*2  )
									memcpy( bitmap+i*WWEITE, p, WWEITE*2 );
								else
									memcpy( bitmap+i*WWEITE, p, max_spalte );
							break;
			case 150:	memset( tmp_zeile, 0, WWEITE*2 );
								if(  max_spalte>WWEITE  )
									kop2_1( p, WWEITE, tmp_zeile );
								else
									kop2_1( p, max_spalte, tmp_zeile );
								memcpy( bitmap+i*WWEITE, tmp_zeile, WWEITE*2 );
							break;
			case 75:	memset( tmp_zeile, 0, WWEITE );
								if(  max_spalte>WWEITE/2  )
									kop2_1( p, WWEITE/2, tmp_zeile );
								else
									kop2_1( p, max_spalte, tmp_zeile );
								kop2_1( bitmap+i*WWEITE, WWEITE, tmp_zeile );
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
		p += weite;
		j++;
	}

	Cconws( display_status );
  print_laser(bitmap);    /* Bitmap 2336x3386 drucken (in Assembler) */
	return 0;
}


