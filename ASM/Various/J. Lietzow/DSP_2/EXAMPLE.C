/*
*  Rahmenprogramm for die DSP-Steuerung
*/

#include <stdlib.h>
#include <stdio.h>
#include "dsplib.h"

int		DoDSP( int ability, char *dsp_lod )
{
  long xmem, ymem;
  void *buf;
  long len;
  
  /* L„uft dieses DSP-Programm noch */
  
  if ( Dsp_GetProgAbility() == ability )
    return ( ability );
  
  /* hole neue Kennung */
  
  ability = Dsp_RequestUniqueAbility();
  
  Dsp_Available( &xmem, &ymem );

  /* hier xmem und ymem berprfen */
  /* evtl. mit Dsp_FlushSubroutines() */
  /* DSP-Speicher frei machen */
	
  /* .... */

  /* DSP-Speicher reservieren */

  if ( Dsp_Reserve( xmem, ymem ) != 0 )
    return ( -1 );
	
  /* temp. buffer gr”že berechnen */
  /* nblocks ist die Anzahl der Speicherbl”cke in
  /* der LOD-Datei */
	
  len = 3 * ( xmem + ymem + ( 3 * nblocks ) );
	
  if ( ( buf = malloc( len ) ) == NULL )
    return ( -1 );
	
  /* erzeuge im Puffer den DSP-Bin„r-Code */
	
  len = Dsp_LodToBinary( dsp_lod, buf );

  /* Programm zum DSP und ausfhren */
  	
  Dsp_ExecProg( buf, len, ability );

  return ( ability );
}


int main( void )
{
  int  ability;
  long curadder, curadc;
  char *rambuf;
    
  /* Ist berhaupt ein DSP vorhanden, */
  /* und ist es ein DSP mit Wortgr”že 3 ? */
  
  if ( Dsp_GetWordSize() != 3 )
  	return ( 1 );

  /* sperre sound system fr andere Programme */
  
  if ( locksnd() != 1 )
  	return ( -1 );
  
  /* sperre DSP fr andere Programme */
  
  if ( Dsp_Lock() != 0 )
  {
  	unlocksnd();
    return ( -1 );
  }
  
  ability = -1;
  ability = DoDSP( ability, "TEST.LOD" ); 
  
 /* keine Abschw„chung des Ausgabekanals */
  
  soundcmd( LTATTEN, 0 );
  soundcmd( RTATTEN, 0 );
  
 /* verst„rke den Eingabekanal */
  
  soundcmd( LTGAIN, 0x80 );
  soundcmd( RTGAIN, 0x80 );

 /* sichere und setze Eingabe-Quelle */
 /* (1: D/A-Wandler 2:Multiplexer) */
  
  curadder = soundcmd( ADDERIN, INQUIRE );

 /* Addierereingang nur von Matrix */

  soundcmd( ADDERIN, 2 );

 /* sichere und setze ADC Eingang auf Mikrofon */
  
  curadc = soundcmd( ADCINPUT, INQUIRE );
  soundcmd( ADCINPUT, 0 );

 /* Verbinde Matrix mit ext. DSP-Schnittstelle */

  dsptristate( ENABLE, ENABLE );

  rambuf = malloc( 1000000L );

 /* setze 16 Bit Stereo Aufnahme-/Abspielmodus */

  setsndmode( STEREO16 );

 /* setze DMA Abspiel- und Aufnahmepuffer */
  
  setbuffer( 0, &rambuf[0], &rambuf[100000L] );
  setbuffer( 1, &rambuf[0], &rambuf[100000L] );

 /* setze Abspiel- und Aufnahmemodus */
  
  buffoper( PLAY_ENABLE   | PLAY_REPEAT | 
            RECORD_ENABLE | RECORD_REPEAT );

 /* verbinde jede Quelle mit Ziel oder 0 */
 /* hier zum Beispiel: */
 /* ADC -> DMA -> DSP -> DAC */
 
  
  devconnect( ADC,    DMAREC, CLK_25M,
              CLK50K, NO_SHAKE );
  devconnect( EXTINP, 0,      CLK_25M,
              CLK50K, NO_SHAKE );
  devconnect( DSPXMIT,DAC,    CLK_25M,
              CLK50K, NO_SHAKE );
  devconnect( DMAPLAY,DSPREC, CLK_25M,
              CLK50K, NO_SHAKE );

 /* hier kommt das Hauptprogramm bzw. */
 /* eine Endlosschleife */
  
  /* .... */
  
 /* setze die Ursprungsdaten */
  
  buffoper( 0 );
  dsptristate( TRISTATE, TRISTATE );
  soundcmd( ADDERIN, curadder );
  soundcmd( ADCINPUT, curadc );

  Dsp_Unlock();
  unlocksnd();

  return ( 0 );
}  