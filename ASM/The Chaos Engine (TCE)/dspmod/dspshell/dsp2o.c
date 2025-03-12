/* convert *.DSP to *.O
   Aufbau O-Files: siehe ST-Computer 1/91. S.90-95
*/

#include <stdio.h>
#include <tos.h>
#include <string.h>

void Fnull( int handle, int anz );
 
int dsp_to_obj( char *in, char *out )
{
	int in_handle, out_handle;
	int i;
	long in_len, out_len;
	char buffer[16];
	char mem;
	long adr, code;
	char label[80];
	
	printf( "\nLabel eingeben\n" );
	do 
		gets( label );
	while ( strlen( label ) > 8 );
	 
	in_handle = (int) Fopen( in, FO_READ );
	if ( in_handle < 0 )
		return( 1 );
	in_len = Fseek( 0L, in_handle, 2 );		/* L„nge der Datei */
	out_len = ( in_len / 15L + 1L ) * 6L;	/* +1L wegen $ff-Endekennung */

	Fseek( 0L, in_handle, 0 );				/* zurck zum Anfang */

	Fcreate( out, 0 );
	out_handle = (int) Fopen( out, FO_WRITE );
	if ( out_handle < 0 )
		return( 2 );
	Fwrite( out_handle, 2L, "\x60\x1A" );	/* Object-Magic */
	Fnull( out_handle, 4 );					/* Code-Len = 0 */
	Fwrite( out_handle, 4L, &out_len );		/* Data-Len */
	Fnull( out_handle, 7 );					/* BSS-Len = 0 */
	Fwrite( out_handle, 1L, "\x0E" );		/* SYM-Len = 14 */		
	Fnull( out_handle, 10 );				/* 10 reservierte Bytes */

	while ( in_len != Fseek( 0L, in_handle, 1 ) ) {
		Fread( in_handle, 15L, buffer );
		buffer[15] = '\0';
		sscanf( buffer,"%c %LX %LX", &mem, &adr, &code );
/*		printf("%c\t%LX\t%LX\n", mem, adr, code ); */
		Fwrite( out_handle, 1L, &mem );				/* Memeory-Typ */			
		Fwrite( out_handle, 1L, (char*)&adr + 2L );	/* Adresse High */
		Fwrite( out_handle, 1L, (char*)&adr + 3L );	/* Adresse Low */
		Fwrite( out_handle, 1L, (char*)&code + 1L );/* Code High */
		Fwrite( out_handle, 1L, (char*)&code + 2L );/* Code Mid */
		Fwrite( out_handle, 1L, (char*)&code + 3L );/* Code Low */
	}
	Fwrite( out_handle, 6L, "\xff\xff\xff\xff\xff\xff" );	/* Ende mit 6 $ff */
	i = 0;
	while( label[i] )
		Fwrite( out_handle, 1L, &label[i++] );	/* Label */
	if ( i != 8 ) 
		Fnull( out_handle, 8 - i );				/* mit 0 ausfllen */
	Fwrite( out_handle, 1L, "\xA4" );			/* $A400 = defined global Symbol */
	Fnull( out_handle, 5 );
	Fnull( out_handle, (int) out_len );			/* Fixup-Tabelle */
	
	Fclose( in_handle );
	Fclose( out_handle );
	return( 0 );
}

void Fnull( int handle, int anz )
{
	int i;
	for ( i = 0; i < anz; i++ )
		Fwrite( handle, 1L, "\0" );
}

