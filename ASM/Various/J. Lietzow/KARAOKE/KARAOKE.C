#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <time.h>

#ifndef __GNU__
 #include <tos.h>
 #define _read(h,b,l)	 read(h,b,l)
 #define fflush(a)
#else
 #include <osbind.h>
 #include <fcntl.h>
 #include <unistd.h>
#endif
 
#include "dsplib.h"

/* fÅllt char buffer mit 3 Byte Worten */

#define Fill3(p,l,v) \
			(p[(l)*3+0]=(char)((v)>>16),\
			 p[(l)*3+1]=(char)((v)>>8), \
			 p[(l)*3+2]=(char)(v) )

/*	DSP Kommandos */

#define	HOST_SEND	 0x000000L
#define	HOST_RECEIVE 0x000080L

/* DSP SpeicherplÑtze */

#define	LEVEL_L1	0x000000L
#define	LEVEL_R1	0x000001L
#define	LEVEL_L2	0x000002L
#define	LEVEL_R2	0x000003L
#define	EFFECT		0x000004L
#define	SMPL_CNT	0x000005L
#define PEEK_LEFT	0x000006L
#define PEEK_RIGHT	0x000007L

	/* CRA ist Pseudo-Speicher */
	/* immer 16 Bit samples */

#define	SSI_CRA		0x00407FL

/*	Bit-Maske fÅr Effekte */

#define		KARAOKE		0x000100L
#define		LEVEL_MTR	0x000200L

/*	SSI CRA Werte (frames per sync) */

#define		FRAMES_2	0x000100L
#define		FRAMES_4	0x000300L

void	PrintAt( int c, int l, char *t )
{
  char buf[16] = "\33Y";
  
  buf[2] = ' ' + l;
  buf[3] = ' ' + c;
  buf[4] = '\0';
  
  Cconws( buf );
  Cconws( t );
}

int		RunDSP( char *dsp_lod )
{
  long xmem, ymem, x, y;
  int  nblocks;
  void *buf;
  long len;
  int  ability;
  
  /* Starte ein DSP-Programm */
    
  ability = Dsp_RequestUniqueAbility();
  Dsp_Available( &xmem, &ymem );

  nblocks = 50;
  x = 1000;
  y = 2000;
  if ( xmem < x || ymem < y )
  {
    Dsp_FlushSubroutines();
    Dsp_Available( &xmem, &ymem );
    if ( xmem < x || ymem < y )
      return ( -1 );
  }

  if ( Dsp_Reserve( x, y ) != 0 )
    return ( -1 );
	
  len = 3 * ( x + y + ( 3 * nblocks ) );
	
  if ( ( buf = malloc( len ) ) == NULL )
    return ( -1 );

  len = Dsp_LodToBinary( dsp_lod, buf );
  Dsp_ExecProg( buf, len, ability );
  
  return ( ability );
}

long effect = KARAOKE|LEVEL_MTR;
long left = 0x3fff00L;
long right = 0x3fff00L;
char host_io[16];
int  lleft = 0;
int  lright = 0;

int main( void )
{
  long curadder, curadc;
  char *sndbuf;
  char c;
  int  handle;
  int  prescale;
  long length;
  long l;
  
  /* Ist Åberhaupt ein DSP vorhanden, */
  /* und ist es ein DSP mit Wortgrîûe 3 ? */
  
  if ( Dsp_GetWordSize() != 3 )
  	return ( -1 );

  /* sperre sound system und DSP */
  
  if ( locksnd() != 1 )
  	return ( -1 );
  
  if ( Dsp_Lock() != 0 )
  {
  	unlocksnd();
    return ( -1 );
  }
  /* resette CODEC wenn Fehler */
  
  if ( sndstatus( 0 ) )
    sndstatus( 1 );

  /* keine externe Hardware */
        
  dsptristate( ENABLE, ENABLE );
  if ( RunDSP( "KARAOKE.LOD" ) == -1 )
  {
    Dsp_Unlock();
    unlocksnd();
    return ( -1 );
  }

  /* ein Stereo-Kanal (2 frames) */

  Fill3( host_io, 0, SSI_CRA|FRAMES_2 );
  Dsp_BlkHandshake( host_io, 1, NULL, 0 );
  Fill3( host_io, 0,
         HOST_SEND|EFFECT|KARAOKE|LEVEL_MTR );
  Dsp_BlkHandshake( host_io, 1, NULL, 0 );

  soundcmd( LTATTEN, 0x80 ); /* Ausgabekanal */
  soundcmd( RTATTEN, 0x80 );
  
  soundcmd( LTGAIN, 0x80 );  /* Eingabekanal */
  soundcmd( RTGAIN, 0x80 );

 /* Addierereingang nur von Matrix */
  
  curadder = soundcmd( ADDERIN, INQUIRE );
  soundcmd( ADDERIN, 2 );
  
 /* setze ADC Eingang auf Mikrofon */
  
  curadc = soundcmd( ADCINPUT, INQUIRE );
  soundcmd( ADCINPUT, 0 );

  setmontrack(0);/* Lautsprecher = erste Spur */

  printf( "\nEingang von \"CABO.HSN\" (M)"
          " oder Åber Mikrofon (F)?" );
  fflush( stdout );
  if ( toupper( (char)Bconin( 2 ) ) == 'M' )
  {
   /* lade Sample-Datei */

    prescale = 11;
    length = 214794L;
    if ( ( sndbuf = malloc( length ) ) == NULL )
      return ( -1 );

    if ( (handle = open( "CABO.HSN", O_RDONLY ))
          <= 0 )
      return ( -1 );
      
    /* ohne header */
    
    if ( _read( handle, sndbuf, 128 ) < 128 )
      return ( -1 );

    if (_read(handle, sndbuf, length) != length)
      return ( -1 );
    close( handle );

    Fill3(host_io,0,
          HOST_SEND|SMPL_CNT|((16000L/40)<<8));
    Dsp_BlkHandshake( host_io, 1, NULL, 0 );

    setsndmode( STEREO8 );

    /* setze DMA Abspielpuffer */
    
    setbuffer( 0, &sndbuf[0], &sndbuf[length] );
    settrack( 1, 0 ); /* eine Wiedergabespur */

    /* verbinde DMA-Quelle mit DSP-Eingang */
  
    devconnect( DMAPLAY,DSPREC, CLK25M,
                prescale, NO_SHAKE );

    /* verbinde DSP-Ausgang mit DAC */

    devconnect( DSPXMIT,DAC,    CLK25M,
                prescale, NO_SHAKE );

    buffoper( PLAY_ENABLE | PLAY_REPEAT );
  }
  else
  {
    setsndmode( STEREO16 );
    Fill3(host_io,0,
          HOST_SEND|SMPL_CNT|((50000L/40)<<8));
    Dsp_BlkHandshake( host_io, 1, NULL, 0 );
    /* verbinde ADC-Eingang mit DSP */

    devconnect( ADC,DSPREC, CLK25M, 1,NO_SHAKE );

    /* verbinde DSP-Ausgang mit DAC */

    devconnect( DSPXMIT,DAC,CLK25M, 1,NO_SHAKE );
  }

 /* warte auf Abbruchbedingung */
 
  PrintAt( 0, 1, "\33f" ); /* Cursor aus */
  
  printf( 
    "\nTaste K      fÅr Karaoke an/aus" 
    "\nTaste <      fÅr linken Kanal verstÑrken"
    "\nTaste >      fÅr rechten Kanal verstÑrken"
    "\nTaste M      fÅr Kanalmitte"
    "\nTaste Return fÅr Abbruch" );
  PrintAt(0,8,"Links  :" );
  PrintAt(0,9,"Rechts :" );
  
  fflush( stdout );
  c = 1;
  while ( c )
  {
    if ( effect & LEVEL_MTR )
    {
     Fill3(host_io,0,HOST_RECEIVE|PEEK_LEFT);
     Dsp_BlkHandshake( host_io, 1, host_io, 1 );
     host_io[0] >>= 1;
     if ( host_io[0] > lleft )
       while ( host_io[0] != lleft )
         PrintAt(9 + ++lleft,8,"-");
     else
       while ( host_io[0] != lleft )
         PrintAt(9 + lleft--,8," ");
     Fill3(host_io,0,HOST_RECEIVE|PEEK_RIGHT);
     Dsp_BlkHandshake( host_io, 1, host_io, 1 );
     host_io[0] >>= 1;
      if ( host_io[0] > lright )
       while ( host_io[0] != lright )
        PrintAt(9 + ++lright,9,"-");
      else
       while ( host_io[0] != lright )
         PrintAt(9 + lright--,9," ");
     fflush( stdout );
    }
	for ( l = 0; l < 60; l++ )
      if ( Bconstat( 2 ) )
  	    switch ( toupper((char) Bconin( 2 )) )
  	{
  	  case '\r': c = 0;	break;
  	  case 'K' : effect ^= KARAOKE;
  	             Fill3(host_io,0,
  	                    HOST_SEND|effect|EFFECT);
  	             Dsp_BlkHandshake( host_io, 1,
  	                               NULL, 0 );
  	             break;
  	  case '<' : if ( right - 0x8000L > 0 )
  	             {
  	               left += 0x8000L;
  	               right -= 0x8000L;
  	               goto send_level;
  	             }
  	             break;
  	  case '>' : if ( left - 0x8000L > 0 )
  	             {
  	               left -= 0x8000L;
  	               right += 0x8000L;
send_level:        Fill3(host_io,0,
                        HOST_SEND|left|LEVEL_L1);
  	               Fill3(host_io,1,
  	                   HOST_SEND|right|LEVEL_R1);
  	               Dsp_BlkHandshake( host_io, 2,
  	                                 NULL, 0 );
  	             }
  	             break;
  	  case 'M' : left = right = 0x3fff00L;
  	             goto send_level;
  	  default  : break;
  	}
 }
    
 /* setze die Ursprungsdaten */
  
  buffoper( 0 );
  soundcmd( ADDERIN, (int) curadder );
  soundcmd( ADCINPUT, (int) curadc );

  Dsp_Unlock();
  unlocksnd();

  return ( 0 );
}  