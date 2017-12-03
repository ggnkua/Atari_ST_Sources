#include <stdio.h>
#include <tos.h>
#include <ext.h>
#include <stdlib.h>

/* Prototypen */

void write_host( long d );


int load_dsp( void )
{
	char buffer[3*512];
	char mem;
	long adr, dat;
	int i;
	FILE *fp;

	fp = fopen( "F:\\DSPASS\\LOADER.DSP", "r" );
		if ( fp == NULL )			
			return( 0 );
	i = 0;
	while ( fscanf( fp, "%c %lX %lX\n", &mem, &adr, &dat ) != EOF ) {
		buffer[i++] = (char) ( dat >> 16 );
		buffer[i++] = (char) ( dat >>  8 );
		buffer[i++] = (char) dat;
		if ( i > ( 3 * 512 ) )
			return( 0 );		
		}
	fclose( fp );
	Dsp_ExecBoot( buffer, i / 3, 1 );

	write_host( 0 );				/* kein Debugger */

	fp = fopen( "F:\\DSPASS\\SOURCE\\VT.DSP", "r" );
	if ( fp == NULL )
		return( 0 );
	while ( fscanf( fp, "%c %lX %lX\n", &mem, &adr, &dat ) != EOF ) {
		adr |= (long) mem << 16;
		write_host( adr );
		write_host( dat );
	}
	write_host( 0xff0000L );		/* fertig */
	fclose( fp );
	return( 1 );
}

void write_host( long d )
{
	char *host_status = (char *)0xffffa202L;
	char *host_tx	  = (char *)0xffffa205L;
    long old_super_stack;

    old_super_stack = Super( 0L );

	while ( ! ( *host_status & 0x02 ) );
	*host_tx++ = (char) ( d >> 16 );
	*host_tx++ = (char) ( d >> 8 );
	*host_tx   = (char) d;
    Super((void *) old_super_stack );
}		