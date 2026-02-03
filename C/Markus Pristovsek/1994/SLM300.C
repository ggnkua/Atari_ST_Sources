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
/*    1.4  (15.07.1993): MP: Angepaût fÅr meinen Treiber, noch ungetestet, */
/*                       aber die Bitmap sieht richtig aus.                */
/*                                                                         */
/*    ACHTUNG: Darf nicht in's TT-RAM geladen werden!											 */
/*                                                                         */
/***************************************************************************/


#include <portab.h>
#include <string.h>

#include "mintbind.h"
#include "treiber.h"

/**** Aus ASSLASER.S ****/
extern void print_laser(int *); /* Druckt die Bitmap des Lasers */
extern int check_laser(void);   /* True, wenn Laser an */

char	*drucker_ext="";

/* Datei ausdrucken */
WORD	drucke( UBYTE *bitmap, LONG x, LONG y, LONG weite, LONG max_zeile, LONG h_dpi, LONG v_dpi, WORD th, WORD flag )
{
	if(  (weite>>8)!=292  )
	{
		Cconws( "\007SLM300.TTP geht nur mit Weite = 198mm! (Sonst SLM.TTP benutzen)\xD" );
		return 0;
	}

	(void)h_dpi;
	(void)v_dpi;
	(void)max_zeile;	/* Zu kurz => Rauschen am Ende! */

	/* Kann logischerweise nicht in Datei drucken */
	if(  th!=3  &&  flag!=7  )
	{
		Cconws( "\007SLM_300 kann nicht in eine Datei und nur alles auf einmal drucken!\xD" );
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
	Cconws( "\033H*" );
	print_laser(bitmap);    /* Bitmap 2336x3386 drucken (in Assembler) */
	return 0;
}


