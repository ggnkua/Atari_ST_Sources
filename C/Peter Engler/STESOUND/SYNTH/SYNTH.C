/* ------------------------------------------------------------------- */
/* --- SYNTH.C: Ausgabe eines Tones mit Amplituden- und            --- */
/* ---			Klanghllkurve                                     --- */
/* ---															   --- */
/* --- In Turbo-C 2.0 implementiert von Peter Engler               --- */
/* ------------------------------------------------------------------- */



#include <stdio.h>
#include <stdlib.h>
#include <ext.h>

#include "sout.h"


/* --- Typdeklaration --- */

typedef struct
{
	/* --- Einheit der Zeitwerte ist 1 ms ! --- */
	/* --- Sustainlevel (..._slevel) werden in dB angegeben --- */

	/* --- Amplitudenhllkurve --- */
	int amp_attack, amp_decay, amp_sustain, amp_slevel, amp_release;
	/* --- Hllkurve fr H”henfilter --- */
	int hoe_attack, hoe_decay, hoe_sustain, hoe_slevel, hoe_release;
	/* --- Hllkurve fr Tiefenfilter --- */
	int tie_attack, tie_decay, tie_sustain, tie_slevel, tie_release;	 
	
} HUELLKURVE;



/* --- Prototypen der im Modul verwendeten Funktionen --- */

int snd_alloc( SOUND *, unsigned long );
void snd_free( SOUND * );
void rauschen( SOUND * );
void rechteck( SOUND * );
void ton_ausgabe( SOUND *, HUELLKURVE * );
int main( void );



/* --- Anlegen des Arrays fr die zu wandelnden Bytes --- */

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



/* --- Generieren der Werte fr ein Rechteck --- */

void rechteck( SOUND *snd )
{
    unsigned long bytes_pro_halbperiode, index;
    char *h_ptr;
    
    h_ptr = snd -> s_ptr;
    
    /* --- Berechnen der Bytes, die pro Halbperiode ausgegeben werden --- */
    bytes_pro_halbperiode = (snd -> bytes_pro_sekunde / snd -> frequenz) / 2L;
    
    if ((bytes_pro_halbperiode % 2) == 1)  bytes_pro_halbperiode++; 
    
    
    snd -> anz_bytes = bytes_pro_halbperiode * 2L;

    /* --- Eintragen der Werte fr das Rechteck in die SOUND-Struktur --- */    
    for (index = 0; index < bytes_pro_halbperiode; index++)
    {
        *h_ptr++ = (char) 127;
    }
    
    for (index = bytes_pro_halbperiode ; index > 0 ; index--)
    {
        *h_ptr++ = (char) -128;
    }
    
}





/* --- Generieren der Werte fr das Rauschen --- */

void rauschen( SOUND *snd )
{
    unsigned long bytes_pro_periode, index;
    char *h_ptr;
    time_t ticks;
    
    h_ptr = snd -> s_ptr;
    
    /* --- Berechnen der Bytes, die pro Periode ausgegeben werden --- */
    bytes_pro_periode = snd -> bytes_pro_sekunde / snd -> frequenz;
    
    if ((bytes_pro_periode % 2) == 1)  bytes_pro_periode++; 
    
    
    snd -> anz_bytes = bytes_pro_periode;
    srand ((unsigned int) time(&ticks) );
    
    /* --- Eintragen der zuf„lligen Werte in die SOUND-Struktur --- */    
    for (index = 0; index < bytes_pro_periode; index += 2)
    {
        *h_ptr++ = (char) ( (rand( ) % 256) * (rand( ) % 256) );
        *h_ptr++ = (char) 0;
    }
    
}



void ton_ausgabe( SOUND *snd, HUELLKURVE *hlk )
{
	int max_index, index;
    float amp_attack_inc, amp_decay_dec, amp_release_dec, 
    	  hoe_attack_inc, hoe_decay_dec, hoe_release_dec, 
    	  tie_attack_inc, tie_decay_dec, tie_release_dec, 
          amplitude, tiefen, hoehen;
    
	/* --- Lautst„rke auf -80 dB --- */
	snd_laut( -80 );
	snd_hoehen( -12 );
	snd_tiefen( -12 );
	
	/* --- L„nge des Tones berechnen (in Einheiten zu 10ms) --- */
	max_index = hlk -> amp_attack + hlk -> amp_decay +
				hlk -> amp_sustain + hlk -> amp_release;
				
	
				
	/* --- Wert eines Amplitudenschrittes in der Attackphase --- */
	if (! hlk -> amp_attack)  amp_attack_inc = 0.0;
	   else
		amp_attack_inc =  80.0 / (float) hlk -> amp_attack;
		
	/* --- Wert eines Amplitudenschrittes in der Decayphase --- */
	if (! hlk -> amp_decay)  amp_decay_dec = 0.0;
	   else
		amp_decay_dec = ( (float) hlk -> amp_slevel ) / (float) hlk -> amp_decay;
		
	/* --- Wert eines Amplitudenschrittes in der Releasephase --- */
	if (! hlk -> amp_release)  amp_release_dec = 0.0;
	   else
		amp_release_dec = ( (float) ( -80.0 - hlk -> amp_slevel )) / (float) hlk -> amp_release;


				
	/* --- Wert eines Hoehenschrittes in der Attackphase --- */
	if (! hlk -> hoe_attack)  hoe_attack_inc = 0.0;
	   else
		hoe_attack_inc =  24.0 / (float) hlk -> hoe_attack;
		
	/* --- Wert eines Hoehenschrittes in der Decayphase --- */
	if (! hlk -> hoe_decay)  hoe_decay_dec = 0.0;
	   else
		hoe_decay_dec = ( -12.0 + (float) hlk -> hoe_slevel ) / (float) hlk -> hoe_decay;
		
	/* --- Wert eines Hoehenschrittes in der Releasephase --- */
	if (! hlk -> hoe_release)  hoe_release_dec = 0.0;
	   else
		hoe_release_dec = ( (float) ( -12.0 - hlk -> hoe_slevel )) / (float) hlk -> hoe_release;


				
	/* --- Wert eines Tiefenschrittes in der Attackphase --- */
	if (! hlk -> tie_attack)  tie_attack_inc = 0.0;
	   else
		tie_attack_inc =  24.0 / (float) hlk -> tie_attack;
		
	/* --- Wert eines Amplitudenschrittes in der Decayphase --- */
	if (! hlk -> tie_decay)  tie_decay_dec = 0.0;
	   else
		tie_decay_dec = ( -12.0 + (float) hlk -> tie_slevel ) / (float) hlk -> tie_decay;
		
	/* --- Wert eines Amplitudenschrittes in der Releasephase --- */
	if (! hlk -> tie_release)  tie_release_dec = 0.0;
	   else
		tie_release_dec = ( (float) ( -12.0 - hlk -> tie_slevel )) / (float) hlk -> tie_release;
	

	/* --- Ton ausgeben --- */	
	snd_play( snd );
	
	/* --- Startwerte fr Amplitude, Hoehen und Tiefen --- */
    amplitude = -80.0;
    tiefen = hoehen = -12.0;
	
	/* --- Amplituden - Attackphase  0 ms ? --- */
	if (! amp_attack_inc)
	{
		/* --- Zus„tzlich  Decayphase 0 ms ? 
		        dann gleich auf Sustainlevel einstellen --- */
	  	if (! amp_decay_dec)
	  	{
	  		snd_laut( hlk -> amp_slevel );
	  		amplitude = (float) hlk -> amp_slevel;
	  	}
	  	else
	  	{
	  	    snd_laut( 0 );
	  	    amplitude = 0.0;
	  	}
	}

	/* --- Hoehen - Attackphase  0 ms ? --- */
	if (! hoe_attack_inc)
	{
		/* --- Zus„tzlich  Decayphase 0 ms ? 
		        dann gleich auf Sustainlevel einstellen --- */
	  	if (! hoe_decay_dec)
	  	{
	  		snd_hoehen( hlk -> hoe_slevel );
	  		hoehen = (float) hlk -> hoe_slevel;
	  	}
	  	else
	  	{
	  	    snd_hoehen( 12 );
	  	    hoehen = 12.0;
	  	}
	}


	/* --- Tiefen - Attackphase  0 ms ? --- */
	if (! tie_attack_inc)
	{
		/* --- Zus„tzlich  Decayphase 0 ms ? 
		        dann gleich auf Sustainlevel einstellen --- */
	  	if (! tie_decay_dec) 
	  	{
	  		snd_tiefen( hlk -> tie_slevel );
	  		tiefen = (float) hlk -> tie_slevel;
	  	}
	  	else
	  	{
	  	    snd_tiefen( 12 );
	  	    tiefen = 12.0;
	  	}
	}

		
	/* --- Amplituden- und Klanghllkurve ausgeben --- */
	for ( index = 0;     	
		 index < max_index; index++)
	{
			/* --- Berechsberschreitungen abfangen --- */
			if (amplitude > 0.0) amplitude = 0.0;
			   else
			   	if (amplitude < -80.0) amplitude = -80.0;
			
			if (tiefen > 12.0)  tiefen = 12.0;
			   else
			   	if (tiefen < -12.0)  tiefen = -12.0;
			   	
			if (hoehen > 12.0)  hoehen = 12.0;
			   else
			   	if (hoehen < -12.0)  hoehen = -12.0;
	
	
			/* --- Lautst„rke, Hoehen und Tiefen setzen --- */
			snd_laut( (int) amplitude );
			snd_hoehen( (int) hoehen );
			snd_tiefen( (int) tiefen );
			
			/* --- 1 ms Verz”gerung --- */
			delay( 1 );

			/* --- Ver„ndern der Amplitude gem„ss der Hllkurve --- */			
			/* --- Attackphase ? --- */
			if (index < hlk -> amp_attack)
			{
				amplitude += amp_attack_inc;
			}
			else
			/* --- Decayphase ? --- */
			if (index < (hlk -> amp_decay + hlk -> amp_attack))
			{
				amplitude += amp_decay_dec;
			}
			else
			/* --- Releasephase ? --- */
			if (index > (hlk -> amp_decay + hlk -> amp_attack +
						 hlk -> amp_sustain))
			{
				amplitude += amp_release_dec;
			}


			/* --- Ver„ndern der H”hen gem„ss der Hllkurve --- */			
			/* --- Attackphase ? --- */
			if (index < hlk -> hoe_attack)
			{
				hoehen += hoe_attack_inc;
			}
			else
			/* --- Decayphase ? --- */
			if (index < (hlk -> hoe_decay + hlk -> hoe_attack))
			{
				hoehen += hoe_decay_dec;
			}
			else
			/* --- Releasephase ? --- */
			if (index > (hlk -> hoe_decay + hlk -> hoe_attack +
						 hlk -> hoe_sustain))
			{
				hoehen += hoe_release_dec;
			}


			/* --- Ver„ndern der Tiefen gemass der Hllkurve --- */
			/* --- Attackphase ? --- */
			if (index < hlk -> tie_attack)
			{
				tiefen += tie_attack_inc;
			}
			else
			/* --- Decayphase ? --- */
			if (index < (hlk -> tie_decay + hlk -> tie_attack))
			{
				tiefen += tie_decay_dec;
			}
			else
			/* --- Releasephase ? --- */
			if (index > (hlk -> tie_decay + hlk -> tie_attack +
						 hlk -> tie_sustain))
			{
				tiefen += tie_release_dec;
			}

	
    }
    
    /* --- Ton beenden --- */
    snd_stop(  );
    
}



int main( )
{
    SOUND snd;
    HUELLKURVE hlk;
    
    
    /* --- Setzen von 'mode_reg' vor 1. Aufruf von 'snd_alloc' !! --- */
	snd.mode_reg = MOD_FR50K | MOD_MONO;
	snd.control_reg = SND_IMMER;
	
	/* --- Array anlegen --- */
	if (snd_alloc( &snd, 65536L))  return(-1);

	snd.frequenz = 110;        
	snd_init( );
	
	/* --- Werte fr Rechteck in den Frame eintragen --- */
	/* rauschen( &snd ); */
	rechteck( &snd );

	/* --- Amplitudenhllkurve festlegen --- */
	hlk.amp_attack = 20;  	/* --- in Millisekunden --- */
	hlk.amp_decay = 20;	 	/* --- in ms --- */
	hlk.amp_slevel = -10; 	/* --- in dB --- */
	hlk.amp_sustain = 200;	/* --- in ms --- */
	hlk.amp_release = 100;	/* --- in ms --- */

	/* --- Hllkurve fr H”henfilter festlegen (15 kHz) --- */
	hlk.hoe_attack = 5;		/* --- in ms --- */
	hlk.hoe_decay = 10;	/* --- in ms --- */
	hlk.hoe_slevel = 0;		/* --- in dB --- */
	hlk.hoe_sustain = 320;	/* --- in ms --- */
	hlk.hoe_release = 0;	/* --- in ms --- */

	/* --- Hllkurve fr Tiefenfilter festlegen (50 Hz) --- */
	hlk.tie_attack = 100;		/* --- in ms --- */
	hlk.tie_decay = 100;		/* --- in ms --- */
	hlk.tie_slevel = -6;		/* --- in dB --- */
	hlk.tie_sustain = 100;	/* --- in ms --- */
	hlk.tie_release = 5;	/* --- in ms --- */

	while ( getch( ) != 27 )
	{
		ton_ausgabe( &snd, &hlk );
	}
	
	snd_init( );
	snd_free( &snd );
	
    return( 0 );

}