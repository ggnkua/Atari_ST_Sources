/* ------------------------------------------------------------------- */
/* --- FRAMES.C: Sequentielles Abspielen unterschiedlicher Frames  --- */
/* ---                                                             --- */
/* --- In Turbo-C 2.0 implementiert von Peter Engler               --- */
/* ------------------------------------------------------------------- */



#include <stdio.h>
#include <stdlib.h>
#include <ext.h>
#include <tos.h>
#include <math.h>

#include "frm.h"



/* --- Prototypen der im Modul verwendeten Funktionen --- */

int frm_alloc( FRAME *, unsigned long, int, int, int );
void frm_free( FRAME * );
void saegezahn( FSOUND * );
void sinus( FSOUND * );
void dreieck( FSOUND * );
void rechteck( FSOUND * );
int main( void );



/* --- Anlegen der Frames innerhalb der FRAME-Struktur --- */
/* --- Parameter:	
					- frm     : Zeiger auf FRAME-Struktur
					- anz     : Maximale Anzahl der Bytes pro Frame
					- anz_frm : Anzahl der Frames in der FRAME-Struktur
					- mode    : Eintrag fÅr 'Sound Mode Control' Register
					- control : Eintrag fÅr 'Sound DMA Control' Register
								(Die letzten 2 Parameter sind fÅr alle 
								 Frames gleich)         
   --- */

int frm_alloc( FRAME *frm, unsigned long anz, int anz_frm, int mode, int control )
{
	unsigned long bytes_ps;
	int index;

	/* --- Anzahl Bytes, die pro Sekunde gewandelt werden --- */	
	switch( mode & 0x000F )
	{
	
		case MOD_FR50K : bytes_ps = 50066L;
						 break;
		case MOD_FR25K : bytes_ps = 25033L;
						 break;
		case MOD_FR12K : bytes_ps = 12517L;
						 break;
		case MOD_FR6K  : bytes_ps = 6258L;
						 break;
		default 	   : bytes_ps = 0L;
						 break;		
		
	}

	/* --- Speicher fÅr Zeiger auf die FSOUND-Strukturen anlegen --- */
	frm -> frame_tab = (FSOUND **) malloc( anz_frm * sizeof(FSOUND *) );
	
	/* --- Fehler aufgetreten ? --- */
	if (! frm -> frame_tab)
	{
		frm -> anz_frames = 0;
		return( -1 );
	}
	
	
	/* --- Anlegen der anz_frm FSOUND-Strukturen --- */
	for( index = 0; index < anz_frm; index++)
	{

		/* --- Speicherplatz fÅr FSOUND-Struktur belegen --- */
		*(frm -> frame_tab + index) = (FSOUND *)  malloc( sizeof(FSOUND) );	
		
		/* --- Fehler aufgetreten ? --- */
		if (! *(frm -> frame_tab + index))
		{
			frm -> anz_frames = 0;
			return( -1 );
		}
	
		/* --- Speicher fÅr die zu wandelnden Bytes belegen --- */
		(*(frm -> frame_tab + index)) -> s_ptr = 
			(char *)  malloc( anz );
			
		if (! (*(frm -> frame_tab + index)) -> s_ptr)
		{
			frm -> anz_frames = 0;
			return( -1 );
		}
		
		/* --- Anzahl Bytes des reservierten Bereichs --- */
		(*(frm -> frame_tab + index)) -> anz_bytes = anz;
		/* --- Samplingrate eintragen --- */
		(*(frm -> frame_tab + index)) -> bytes_pro_sekunde = bytes_ps;
		(*(frm -> frame_tab + index)) -> control_reg = control;
		(*(frm -> frame_tab + index)) -> mode_reg = mode;
	
	}
	
	/* --- Anzahl der Frames eintragen --- */
	frm -> anz_frames = anz_frm;

	
	
	return( 0 );
}



/* --- Freigeben der Arrays der FRAME-Struktur --- */

void frm_free( FRAME *frm )
{
	int index;
	
	for( index = 0; index < frm -> anz_frames; index++)
	{
		free( (*(frm -> frame_tab + index)) -> s_ptr);
		free( *(frm -> frame_tab + index) );
	}
}



/* --- Generieren der Werte fÅr einen Sinus --- */

void sinus( FSOUND *snd )
{
    unsigned long bytes_pro_periode, index;
    char *h_ptr;
    
    h_ptr = snd -> s_ptr;

    /* --- Berechnen der Bytes, die pro Periode ausgegeben werden --- */    
    bytes_pro_periode = snd -> bytes_pro_sekunde / snd -> frequenz;
    
    if ((bytes_pro_periode % 2) == 1)  bytes_pro_periode++; 
    
    snd -> anz_bytes = bytes_pro_periode;
    
   	/* --- Eintragen der Werte fÅr den Sinus in die SOUND-Struktur --- */
   	for (index = 0; index < bytes_pro_periode; index++)
   	{
       	*h_ptr++ = 
       		(char) (127 * sin( 2.0 * M_PI * ((double) index) / (double) bytes_pro_periode) - 1); 
   	}
    
}


/* --- Generieren der Werte fÅr einen SÑgezahn --- */

void saegezahn( FSOUND *snd )
{
    unsigned long bytes_pro_periode, index;
    char *h_ptr;
    
    h_ptr = snd -> s_ptr;
    
    /* --- Berechnen der Bytes, die pro Periode ausgegeben werden --- */
    bytes_pro_periode = snd -> bytes_pro_sekunde / snd -> frequenz;
    
    if ((bytes_pro_periode % 2) == 1)  bytes_pro_periode++; 
    
    
    snd -> anz_bytes = bytes_pro_periode;
    
    /* --- Eintragen der Werte fÅr den SÑgezahn in die SOUND-Struktur --- */    
    for (index = 0; index < bytes_pro_periode; index++)
    {
        *h_ptr++ = 
           (char) ( 255 * ((double) index) / ((double) bytes_pro_periode ) - 128);
    }
    
}


/* --- Generieren der Werte fÅr ein Dreieck --- */

void dreieck( FSOUND *snd )
{
    unsigned long bytes_pro_halbperiode, index;
    char *h_ptr;
    
    h_ptr = snd -> s_ptr;
    
    /* --- Berechnen der Bytes, die pro Halbperiode ausgegeben werden --- */
    bytes_pro_halbperiode = (snd -> bytes_pro_sekunde / snd -> frequenz) / 2L;
    
    if ((bytes_pro_halbperiode % 2) == 1)  bytes_pro_halbperiode++; 

    
    snd -> anz_bytes = bytes_pro_halbperiode * 2L;
    
    /* --- Eintragen der Werte fÅr das Dreieck in die SOUND-Struktur --- */ 
    for (index = 0; index < bytes_pro_halbperiode; index++)
    {
        *h_ptr++ = 
           (char) ( 255 * ((double) index) / ((double) bytes_pro_halbperiode ) - 128);
    }
    
    for (index = bytes_pro_halbperiode ; index > 0 ; index--)
    {
        *h_ptr++ = 
           (char) ( 255 * ((double) index) / ((double) bytes_pro_halbperiode ) - 128);
    }
    
}


/* --- Generieren der Werte fÅr ein Rechteck --- */

void rechteck( FSOUND *snd )
{
    unsigned long bytes_pro_halbperiode, index;
    char *h_ptr;
    
    h_ptr = snd -> s_ptr;
    
    /* --- Berechnen der Bytes, die pro Halbperiode ausgegeben werden --- */
    bytes_pro_halbperiode = (snd -> bytes_pro_sekunde / snd -> frequenz) / 2L;
    
    if ((bytes_pro_halbperiode % 2) == 1)  bytes_pro_halbperiode++; 
    
    
    snd -> anz_bytes = bytes_pro_halbperiode * 2L;

    /* --- Eintragen der Werte fÅr das Rechteck in die SOUND-Struktur --- */    
    for (index = 0; index < bytes_pro_halbperiode; index++)
    {
        *h_ptr++ = (char) 127;
    }
    
    for (index = bytes_pro_halbperiode ; index > 0 ; index--)
    {
        *h_ptr++ = (char) -128;
    }
    
}



int main( )
{
    FRAME frm;
    
	/* --- 4 Frames zu 65536 Bytes anlegen --- */
	if (frm_alloc( &frm, 65536L, 4, MOD_FR50K | MOD_MONO, SND_IMMER)) 
	   return(-1);

	/* --- Werte fÅr 1. Frame eintragen --- */
	(*(frm.frame_tab)) -> frequenz = 440;
	(*(frm.frame_tab)) -> wiederholungen = 40;
	sinus( *(frm.frame_tab) );

	/* --- Werte fÅr 2. Frame eintragen --- */
	(*(frm.frame_tab + 1)) -> frequenz = 440;
	(*(frm.frame_tab + 1)) -> wiederholungen = 40;
	dreieck( *(frm.frame_tab + 1) );

	/* --- Werte fÅr 3. Frame eintragen --- */
	(*(frm.frame_tab + 2)) -> frequenz = 440;
	(*(frm.frame_tab + 2)) -> wiederholungen = 40;
	rechteck( *(frm.frame_tab + 2) );
	
	/* --- Werte fÅr 4. Frame eintragen --- */
	(*(frm.frame_tab + 3)) -> frequenz = 440;
	(*(frm.frame_tab + 3)) -> wiederholungen = 40;
	saegezahn( *(frm.frame_tab + 3) );
	

	/* --- Ausgabe der Frames anstoûen --- */
	frm_start( &frm );
	
	/* --- Programmtext, der parallel zur Tonausgabe abgearbeitet
	       wird :
	       
	       ...  (hier einfÅgen)
	       
	       --- */
	       
	(void)  getch( );
	
	/* --- Tonausgabe stoppen --- */
    frm_stop(  );
    frm_free( &frm );
    
    return( 0 );

}