/***************************************************************************/
/*                                                                         */
/*    HardwareabhÑngiger Teil des DVI-Druckertreibers von Stefan Lindner   */
/*         Anpassung fÅr Atari Laserdrucker SLM804 von Lutz Birkhahn       */
/*                                                                         */
/*    0.90 (07.09.1988): Diablo 630 - Funktionen implementiert             */
/*    1.0  (10.12.1988): Anpassungen an neue Treiberkern-Version           */
/*    1.1  (13.01.1989): - " -: top_offset und left_offset eingefÅhrt      */
/*    1.2  (23.04.1989): left_skip() und top_skip() entfernt, da sie vom   */
/*                       Kern nicht mehr aufgerufen werden                 */
/*                                                                         */
/***************************************************************************/
/* Schonungslos geklaut und angepaût fÅr meinen Treiber am 1.3.93          */
/* von Markus Pristovsek                                                   */
/***************************************************************************/


#include <stdio.h>
#include <tos.h>
#include <portab.h>

#include "treiber.h"



WORD	drucke( UBYTE *p, LONG weite, LONG max_zeile, LONG h_dpi, LONG v_dpi )
{
	struct t_form
	{ /* Definition lt. Atari-Dok. SLM804 - Emulation Diablo 630 */
		void  *s_form;       /* gerade Adresse der Form                   */
		WORD  s_xmin;        /* Ursprungs-x in Pixels                     */
		WORD  s_ymin;        /* Ursprungs-y in Zeilen des Scanners (sic!) */
		WORD  s_nxln;        /* Ursprungs-Breite der Form in Bytes        */
		WORD  b_width;       /* Ursprungs-Breite in Pixels                */
		WORD  b_height;      /* Ursprungs-Hîhe in Pixels                  */
		WORD  d_xmin;        /* Ziel-x in Pixels                          */
		WORD  d_ymin;        /* Ziel-y in Zeilen des Scanners (sic!)      */
		WORD  scale_factor;  /* Maûstab des Bildes (1, 2 oder 4)          */
	} form;
	WORD	devh;
	UBYTE	tmp[64];
	extern char	tmp_file[256]; /* In Datei drucken? */

	if(  tmp_file[0]>0  )
		return 0;

	form.s_form       = p;
/* 7.5mm * unbedruckbarer linker Rand [Pixel 89] */
	form.s_xmin       = 89;
/* 5mm * unbedruckbarer oberer Rand [Pixel 59] */
	form.s_ymin       = 59;
	form.s_nxln       = (WORD)((weite+7)/8);
	form.b_width      = (WORD)weite;
	if(  weite>2336+89  )	/* RÑnder */
		form.b_width      = 2336+89;
	form.b_height     = (WORD)max_zeile;
	if(  weite>3386+59  ) /* RÑnder */
		form.b_height     = (WORD)3386+59;
	form.d_xmin       = 0;
	form.d_ymin       = 0;
	if(  h_dpi>175  )
		form.scale_factor = 1;	/* 300dpi */
	else if(  h_dpi>100  )
		form.scale_factor = 2;	/* 150dpi */
	else
		form.scale_factor = 4;	/* 75dpi */
	
	sprintf( tmp, "\033gG%08lX \015", &form );
	if(  (devh=open_printer())<0  )
		return -1;
	Fwrite( devh, 13L, tmp );
	return 0;
}
