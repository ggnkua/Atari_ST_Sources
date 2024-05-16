#include <stdio.h>
#include <tos.h>
#include <ext.h>
#include <stdlib.h>

#define BUFSIZE 3*(512+3)
char lod_buffer[16384];

/* Prototypen */

void write_host( char *d );

int load_lod( char *fname )
{
	long xav, yav;

	Dsp_Hf0( 0 );	
	Dsp_Available( &xav, &yav );
	Dsp_Reserve( xav, yav );
	if ( Dsp_LoadProg( fname, 9999,lod_buffer ) == -1 ) {
		printf( "DSP-Programm kann nicht gestarte werden!" );
		return( 0 );
	}
	return( 1 );
}


int load_dsp( void )
{
	char buffer[BUFSIZE];
	int handle;

	handle = (int) Fopen( "LOADER.P56", FO_READ );
	if ( handle < 0 ) {			
		handle = (int) Fopen( "C:\\DSP\\DEVPAC56\\SOURCE\\LOADER.P56", FO_READ );
		if ( handle < 0 )			
			return( 0 );
	}
	Fread( handle, (long)BUFSIZE, buffer );
	Fclose( handle );
	
	Dsp_ExecBoot( &buffer[9], (unsigned int) buffer[8], 1 );

	handle = (int) Fopen( "MODPLAY.P56", FO_READ );
	if ( handle < 0 ) {
		handle = (int) Fopen( "C:\\DSP\\DEVPAC56\\SOURCE\\MODPLAY.P56", FO_READ );
		if ( handle < 0 )
			return( 0 );
	}

	while( Fread( handle, 3L, buffer ) > 0L ) {
/*		printf("%x%x%x\n",buffer[0], buffer[1], buffer[2] );
		getch();*/
		write_host( buffer );
	}
	Fclose( handle );
	
	buffer[0] = -1;
	buffer[1] = -1;
	buffer[2] = -1;
	write_host( buffer );			/* fertig */
/*	
	while( 1 ) {		
	Dsp_BlkHandShake( buffer, 0L, buffer, 1L );
	printf("%d\n", buffer[2] );
	}
*/	
	return( 1 );
}

void write_host( char *d )
{
	char *host_status = (char *)0xffffa202L;
	char *host_tx	  = (char *)0xffffa205L;
    long old_super_stack;

    old_super_stack = Super( 0L );

	while ( ! ( *host_status & 0x02 ) );
	*host_tx++ = *d++;
	*host_tx++ = *d++;
	*host_tx   = *d;
    Super((void *) old_super_stack );
}

		