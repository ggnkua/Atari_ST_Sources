#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <setjmp.h>

#include "lzw.h"

#define ERROR_CODE	-1

/* - LZW Decompression Routines - */

#define string_from_code(c)		(((c)<256) ? &CharTab[(c)] : s_tab[(c)].str)
#define len_from_code(c)		(((c)<256) ? 1 : s_tab[(c)].len)
#define is_in_table(c)			(c) < next_code

typedef struct
{
	char	*str;
	long	len;
} STR_ENTRY;


const short	BitsPerChar[]			= { 
	9, 9, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 12, 12, 12, 12
	};

const unsigned char	CharTab[256]	= {
	0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F,
	0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F,
	0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2A, 0x2B, 0x2C, 0x2D, 0x2E, 0x2F,
	0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3A, 0x3B, 0x3C, 0x3D, 0x3E, 0x3F,
	0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4A, 0x4B, 0x4C, 0x4D, 0x4E, 0x4F,
	0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5A, 0x5B, 0x5C, 0x5D, 0x5E, 0x5F,
	0x60, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6A, 0x6B, 0x6C, 0x6D, 0x6E, 0x6F,
	0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7A, 0x7B, 0x7C, 0x7D, 0x7E, 0x7F,
	0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89, 0x8A, 0x8B, 0x8C, 0x8D, 0x8E, 0x8F,
	0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98, 0x99, 0x9A, 0x9B, 0x9C, 0x9D, 0x9E, 0x9F,
	0xA0, 0xA1, 0xA2, 0xA3, 0xA4, 0xA5, 0xA6, 0xA7, 0xA8, 0xA9, 0xAA, 0xAB, 0xAC, 0xAD, 0xAE, 0xAF,
	0xB0, 0xB1, 0xB2, 0xB3, 0xB4, 0xB5, 0xB6, 0xB7, 0xB8, 0xB9, 0xBA, 0xBB, 0xBC, 0xBD, 0xBE, 0xBF,
	0xC0, 0xC1, 0xC2, 0xC3, 0xC4, 0xC5, 0xC6, 0xC7, 0xC8, 0xC9, 0xCA, 0xCB, 0xCC, 0xCD, 0xCE, 0xCF,
	0xD0, 0xD1, 0xD2, 0xD3, 0xD4, 0xD5, 0xD6, 0xD7, 0xD8, 0xD9, 0xDA, 0xDB, 0xDC, 0xDD, 0xDE, 0xDF,
	0xE0, 0xE1, 0xE2, 0xE3, 0xE4, 0xE5, 0xE6, 0xE7, 0xE8, 0xE9, 0xEA, 0xEB, 0xEC, 0xED, 0xEE, 0xEF,
	0xF0, 0xF1, 0xF2, 0xF3, 0xF4, 0xF5, 0xF6, 0xF7, 0xF8, 0xF9, 0xFA, 0xFB, 0xFC, 0xFD, 0xFE, 0xFF
	};

short		bits_per_char	= 9;
char		*buf_o;
STR_ENTRY	*s_tab;
long		next_code;

jmp_buf		_pksave;

char		*IBuffP			= NULL;
FILE		*OutFile		= NULL;
long		OutFileLen		= 0;
char		*OutBuffer[ BUFFER_SIZE ];
long		OutBufferLen	= 0;
long		ByteCount		= 0;


/* get_next_code()
 * -------------
 *
 * Gets the next code from the input stream.  Bit boundaries are catered for here.
 *
 * INPUTS:	buf_i	the file pointer, or pointer to memory where input will come from
 * OUTPUTS:	returns	the code it found.
 */
short get_next_code( void )
{
	short					code;
	short					bpc;
	static char				msk		= 0;
	static char				byte	= 0;

	for ( code = 0, bpc = bits_per_char; bpc; msk >>= 1, --bpc )
	{
		if ( msk == 0 )
		{
			msk = 0x80;
			byte = *IBuffP++;
		}
		code += code;			/* fast shift left */
		if ( byte AND msk )
		{
			++code;
		}
	}
#ifdef DEBUG
	if (( code > 31 ) _AND_ ( code < 256 ))
	{
		printf( "%c", (char) code );
	}
	else
	{
		printf( "<%d>", (int) code );
	}
#endif
	return ( code );
}


/* initialise_table()
 * ----------------
 *
 * Sets the string pointer table to its virgin state.
 *
 * INPUTS:	** NONE **
 * OUTPUTS:	** NONE **
 */
void initialise_table( void )
{
	if ( s_tab == NULL )
	{
		if (( s_tab = (STR_ENTRY*) malloc(( HASHMAX - 256 ) * sizeof( STR_ENTRY ))) == NULL )
		{
			longjmp( _pksave, ERROR_CODE );
		}
	}
	memset( s_tab, 0, ( HASHMAX - 256 ) * sizeof( STR_ENTRY ));
	next_code = END_OF_INFORMATION + 1;
	bits_per_char = 9;
}


/* write_string()
 * ------------
 *
 * writes the given string to the output buffer.
 *
 * INPUTS:	str		Pointer to the string to be written
 *			buf_o	Pointer to the output buffer
 *			len		The length of str
 *
 * OUTPUTS:	returns	a pointer to the start of the string just written.
 */
unsigned char *write_string( const unsigned char *str, const unsigned char *buf_o, register long len )
{
	static unsigned char	*buf;
	unsigned char			*ptr;

	if ( buf == NULL )
	{
		buf = buf_o;
	}
	memmove( buf, str, len );
	ptr			 = buf;
	buf			+= len;
	ByteCount		+= len;
	OutBufferLen += len;
	return( ptr );
}


/* add_string_to_table()
 * -------------------
 *
 * Adds a new string to the table, and updates the code number of the next strin to
 * be added.
 *
 * INPUTS:	str		The string to be added
 *			len		The length of str
 *
 * OUTPUTS:	** NONE **
 */
void add_string_to_table( char *str, long len )
{
	STR_ENTRY	*p;

	p = &s_tab[ next_code++ ];
	p->str = str;
	p->len = len;
	bits_per_char = BitsPerChar[ (( next_code ) >> 8 ) & 0xf ];
}

void WriteOutBuffer( void )
{
	if ( fwrite( OutBuffer, OutBufferLen, 1, OutFile ) != 1 )
	{
		fprintf( stderr, "Cannot write to output file\n" );
		longjmp( _pksave, ERROR_CODE );
	}
}


/* unlzw()
 * -----
 *
 * De-compress an image that has been compresed by the LZW compression scheme implimented
 * in the function lzw().
 *
 * INPUTS:	buf_i	A pointer to the buffer, or the file pointer, of the compressed data
 *			buf_o	A pointer to the memory area to hold the un-compressed image
 *
 * OUTPUTS:	returns the total size of the image
 */
long UnLZW( void )
{
	unsigned char	*ptr;
	unsigned char	*tptr;
	short			code;
	short			old_code;
	long			len;
	long			ret;

	if (( ret = (long) setjmp( _pksave )) == 0 )
	{
		ptr				= buf_o = OutBuffer;
		ByteCount		= 0;
		OutBufferLen	= 0;
		while (( code = get_next_code()) != END_OF_INFORMATION )
		{
			if ( code == CLEAR_CODE )
			{
				WriteOutBuffer();
				initialise_table();

				buf_o			= OutBuffer;
				OutBufferLen	= 0;

				if (( code = get_next_code()) == END_OF_INFORMATION )
				{
					break;
				}
				write_string( string_from_code( code ), buf_o, len_from_code( code ));
				old_code = code;
			}
			else
			{
				len = len_from_code( old_code );
				if ( is_in_table( code ))
				{
					tptr = write_string( string_from_code( code ), buf_o, len_from_code( code ));
					add_string_to_table( ptr, ++len );
					ptr = tptr;
				}
				else
				{
					ptr = write_string( string_from_code( old_code ), buf_o, len );
					write_string( string_from_code( old_code ), buf_o, 1 );
					add_string_to_table( ptr, ++len );
				}
				old_code = code;
			}
		}
		ret = ByteCount;
	}
	else
	{
		fprintf( stderr, "Program aborted by longjmp()\n" );
	}
/*	release_mem( s_tab ); */
	return ( ret );
}

BOOL ReadInputFile( const char *name )
{
	FILE	*fp;
	long	len;
	BOOL	rc		= FALSE;

	fp	= fopen( name, "rb" );
	if ( fp )
	{
		fseek( fp, 0, SEEK_END );
		len = ftell( fp );
		fseek( fp, 0, SEEK_SET );

		IBuffP	= malloc( len );
		if ( IBuffP )
		{
			if ( fread( IBuffP, len, 1, fp ) != 1 )
			{
				fprintf( stderr, "Unable to read input file\n" );
			}
			else
			{
				rc = TRUE;
			}
		}
		else
		{
			fprintf( stderr, "Out of memory\n" );
		}

		fclose( fp );
	}
	else
	{
		fprintf( stderr, "Unable to open file %s\n", name );
	}

	return rc;
}

BOOL OpenOutputFile( const char *name )
{
	OutFile = fopen( name, "wb" );
	if ( !OutFile )
	{
		fprintf( stderr, "Cannot open output file %s\n" );
		return FALSE;
	}
	return TRUE;
}

int main( int argc, char **argv )
{
	if ( argc == 3 )
	{
		if ( ReadInputFile( argv[1] ))
		{
			if ( OpenOutputFile( argv[2] ))
			{
				UnLZW();
				fclose( OutFile );
			}
		}
	}
	else
	{
		fprintf( stderr, "Usage: unlzw input output\n" );
	}
}

