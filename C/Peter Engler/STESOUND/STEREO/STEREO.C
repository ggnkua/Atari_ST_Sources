/* ------------------------------------------------------------------- */
/* --- STEREO.C : Erzeugung von Stereosounds auf dem STE           --- */
/* ---                                                             --- */
/* --- In Turbo-C 2.0 implementiert von Peter Engler               --- */
/* ------------------------------------------------------------------- */



#include <stdio.h>
#include <stdlib.h>
#include <ext.h>
#include <tos.h>
#include <math.h>

#include "sout.h"


/* --- Prototypen der im Modul verwendeten Funktionen --- */

int snd_alloc( SOUND *, unsigned long );
void snd_free( SOUND * );
void stereo( SOUND * );
int main( void );



/* --- Anlegen des Arrays fÅr die zu wandelnden Bytes --- */

int snd_alloc( SOUND *snd, unsigned long anz )
{
	/* --- Speicherplatz belegen --- */
	snd -> s_ptr = (char *)  malloc( anz ); 

	/* --- Fehler aufgetreten --- */
	if (! snd -> s_ptr)
	{
		snd -> anz_bytes = 0L;
		return( -1 );
	}
	
	/* --- Anzahl Bytes des reservierten Bereichs --- */
	snd -> anz_bytes = anz;
	
	/* --- Anzahl Bytes, die pro Sekunde gewandelt werden --- */	
	switch( snd -> mode_reg & 0x000F )
	{
	
		case MOD_FR50K : snd -> bytes_pro_sekunde = 50066L;
						 break;
		case MOD_FR25K : snd -> bytes_pro_sekunde = 25033L;
						 break;
		case MOD_FR12K : snd -> bytes_pro_sekunde = 12517L;
						 break;
		case MOD_FR6K  : snd -> bytes_pro_sekunde = 6258L;
						 break;
		default 	   : snd -> bytes_pro_sekunde = 0L;
						 break;		
		
	}
	
	
	return( 0 );
}



/* --- Freigeben des Arrays der SOUND-Struktur --- */

void snd_free( SOUND *snd )
{
	free( snd -> s_ptr );
}



/* --- Generieren der Werte (rechts Sinus, links SÑgezahn ) --- */

void stereo( SOUND *snd)
{
	unsigned long bytes_pro_periode, index;
	char *h_ptr;
	
	h_ptr = snd -> s_ptr;

	/* --- Berechnung der Anzahl Bytes pro Periode --- */	
	bytes_pro_periode = snd -> bytes_pro_sekunde / snd -> frequenz;
	
	/* --- Eintragen in SOUND-Struktur --- */
	snd -> anz_bytes = bytes_pro_periode * 2;
	
	
	/* --- Berechnung der Werte fÅr den Vierklang --- */
	for (index = 0; index < bytes_pro_periode; index++)
	{
		/* --- Zuerst der linke Kanal --- */
	
		*h_ptr++ = 
			(char) (127 * sin( 2.0 * M_PI * ((double) index) / (double) bytes_pro_periode) - 1); 


		/* --- Dann der rechte Kanal --- */

		*h_ptr++ =
           	(char) (255 * ((double) index) / ((double) bytes_pro_periode ) - 128);
	}
	
}



int main( )
{
	SOUND snd;
	
	/* --- 'mode_reg' immer vor 1. Aufruf von 'snd_alloc' setzen !! --- */
	snd.mode_reg = MOD_FR50K | MOD_STEREO;
	snd.control_reg = SND_IMMER;
	snd.frequenz = 220;    /* --- in Hz --- */
	
	/* --- Array fÅr den Frame anlegen --- */
	if (snd_alloc( &snd, 65536L))  return(-1);


	/* --- Stereoklang berechnen --- */
    stereo( &snd );
		
	/* --- ... und abspielen --- */
	snd_play( &snd );
		
	/* --- Auf Tastendruck warten --- */
	(void)  getch( );		

	/* --- Tonerzeugung ausschalten --- */	
	snd_stop( );
	snd_free( &snd );
	
	return( 0 );
}