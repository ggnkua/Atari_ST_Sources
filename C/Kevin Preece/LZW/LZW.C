/*******************************************************************************
**
** Name		: LZW.C
** Date		: 21st May 1994
** Author	: Kevin Preece
** Title	: LZW Compression & Decompression Routines
** Compiler	: Lattice C V5.51
**
**--- DESCRIPTION --------------------------------------------------------------
**
** This source contains modules for compressing and decompressing files using
** the Lempel-Ziv-Welch (LZW) compression scheme, as described in the TIFF 5.0
** specification document.  The scheme described in this document is essentially
** the same as the GIF standard for LZW compression and decompression.
**
** There are two major entry points:
**
** (1) PackLZW( ... );
** (2) UnpackLZW( ... );
**
** (1) PackLZW( unsigned char *ipb, void *opb, long len );
**		ipb	a pointer to the input buffer to be compressed
**		opb	a pointer to the buffer to receive packed data
**		len	the length of the uncompressed data
**
********************************************************************************
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <setjmp.h>

#include "lzw.h"

/* ------------------------------ */

typedef struct node
{
	const unsigned char	*s;
	long				slen;
	short				code;
	struct node 		*next;
} NODE;

/* ------------------------------ */

short			LastCode;
NODE			**HashTab		= NULL;
NODE			*MemBlk			= NULL;
short			NodeNo;

unsigned char	*IBuffP		= NULL;
long			IBuffLen;
void			*OBuffP		= NULL;
long			OBuffLen;
long			BufferSize	= BUFFER_SIZE;

jmp_buf			_pksave;

long			ByteCount		= 0;
short			NextCode		= 1;

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

/* -- LZW Compression Routines -- */


/* ClearHashTable()
 * --------------
 *
 * Clears the hash table of all strings it contains.  On the first call to this
 * function a block of memory is allocated to it.
 *
 * INPUTS:	** NONE **
 * OUTPUTS:	** NONE **
 */
void ClearHashTable( void )
{
	if ( HashTab == NULL )
	{
		if (( HashTab = (NODE**) calloc( HASHMAX, sizeof( NODE** ))) == NULL )
		{
			fprintf( stderr, "Cannot clear hash table\n" );
			longjmp( _pksave, ERROR_CODE );
		}
	}
	else
	{
		memset( HashTab, 0, HASHMAX * sizeof( NODE** ));
	}
	NodeNo = 0;
}


/* NewNode()
 * -------
 *
 * This function is called to obtain storage for a NODE structure.
 *
 * On the first call to this function, a chunk of memory large enough to hold HASHMAX
 * NODEs (HASHMAX is the largest value returned by the hashing function).
 *
 * On subsequent calls, a block (the size of a NODE structure) is carved from this
 * block.
 *
 * INPUTS:	** NONE **
 *
 * OUTPUTS:	returns	a pointer to the new node.
 */
NODE *NewNode( void )
{
	if ( MemBlk == NULL )
	{
		MemBlk = malloc(( HASHMAX - 1 ) * sizeof( NODE ));
		if ( MemBlk == NULL )
		{
			fprintf( stderr, "Cannot allocte NewNode()\n" );
			longjmp( _pksave, ERROR_CODE );
		}
	}
	if ( NodeNo < ( HASHMAX - 1 ))
	{
		return ( &MemBlk[ NodeNo++ ] );
	}
	fprintf( stderr, "Cannot allocte NewNode() call 2, NodeNo = %ld\n" );
	errno = ENOMEM;
	longjmp( _pksave, ERROR_CODE );

	return NULL;
}


long mhash( const unsigned char *b, size_t len )
{
	long	d1;
	long	d3;

	d1 = 0;

	while ( len )
	{
		--len;
		d1	<<= 4;
		d1	 += *b++;
		d3	  = d1;
		d3	 &= 0xF0000000L;

		if ( !d3 )
			continue;

		d1	 ^= d3;
		d3	>>= 24;
		d3	 &= 0x00FF;
		d1	 ^= d3;
	}
	return d1;
}


/* AddTableEntry()
 * -------------
 *
 * Adds a new string to the table
 *
 * INPUTS:	s		the string to be added
 *			slen	the length of string s
 *
 * OUTPUTS:	** NONE **
 */
void AddTableEntry( const unsigned char *s, const long slen )
{
	NODE	*t;
	NODE	**p;

	t		= NewNode();
	t->s	= s;
	t->slen	= slen;
	t->code	= NextCode++;
	p = &HashTab[ mhash( s, slen ) % HASHMAX ];
	t->next = ( *p ) ? *p : NULL;					/* link to next string with same hash code */
	*p = t;
}


/* InitStringTable()
 * ---------------
 *
 * Sets the string table to its virgin state.
 *
 * INPUTS:	** NONE **
 * OUTPUTS:	** NONE **
 */
void InitStringTable( void )
{
	short		c;

	ClearHashTable();
	for ( NextCode = c = 0; c < 256; ++c )
	{
		AddTableEntry( &CharTab[c], 1 );
	}
	NextCode = END_OF_INFORMATION + 1;
}


#ifdef DEBUG
void ShowCode( short code )
{
	static short	pos		= 0;

	if (( code > 32 ) && ( code < 256 ))
	{
		pos += printf( "%c", (char) code );
	}
	else
	{
		pos += printf( "<%d>", (int) code );
	}
	if ( pos > 140 )
	{
		pos = 0;
		printf( "\n" );
	}
}
#endif


void PutByte( unsigned char c )
{
	char	*s;

	s		= (char*) OBuffP;
	*s++	= c;
	OBuffP	= s;

	++ByteCount;
	if ( ByteCount == IBuffLen )
	{
		fprintf( stderr, "Unable to compress file\n" );
		longjmp( _pksave, -1 );
	}
}


/* WriteCode()
 * ----------
 *
 * Writes the given code to the output stream
 *
 * INPUTS:	code	the code to be written
 *
 * OUTPUTS:	** NONE **
 */
void WriteCode( short code )
{
	static long			byte	= 0;
	static short		bits	= 0;
	short				bpc;
	short				shift_amt;
	unsigned short		accum;

	static const short	mask[]	= {
		0x0000, 0x0001, 0x0003, 0x0007, 0x000F, 0x001F, 0x003F, 
		0x007F, 0x0000, 0x01FF, 0x03FF, 0x07FF, 0x0FFF };

	bpc			  = BitsPerChar[ (( NextCode - 1 ) >> 8 ) & 0xf ];
	bits		 += bpc;
	byte		<<= bpc;
	byte		 |= code AND mask[ bpc ];
	shift_amt	  = bits AND 7;
	accum		  = (short) ( byte >> shift_amt );
	byte		 &= mask[ shift_amt ];

	if ( bits >= 16 )
	{
		PutByte( ( accum >> 8 ) & 0xFF );
	}
	PutByte( accum AND 0xFF );
	bits = shift_amt;

#ifdef DEBUG
	ShowCode( code );
#endif

	switch ( code )
	{
		case CLEAR_CODE :
			InitStringTable();
			break;

		case END_OF_INFORMATION :
			ClearHashTable();
			byte <<= 8 - bits;
			PutByte( (char) byte );
			bits = 0;
			byte = 0;
			break;

		case MAX_CODE :
			WriteCode( CLEAR_CODE );
			break;
	}
}


/* FindString()
 * -----------
 *
 * Given a string, this function searches the hash table to see whether it has been
 * seen already.
 *
 * INPUTS:	s		The string we wish to find
 *			slen	The length of the string s
 *
 * OUTPUTS	returns	1 if the string was found, or zero if not.
 */
short FindString( const unsigned char *s, const long slen )
{
	NODE	*p;

	p = HashTab[ mhash( s, slen ) % HASHMAX ];
	if ( p != NULL )
	{
		do
		{
			if (( slen == p->slen ) && !memcmp( s, p->s, slen ))
			{
				LastCode = p->code;
				return ( 1 );
			}
			p = p->next;
		}
		while ( p );
	}
	return ( 0 );
}


/* PackStrip()
 * ----------
 *
 * Packs a single strip of the image.  Note that a strip here is not the same as a
 * strip in packbits or CCITT compression schemes.  Here it is a block of upto
 * BufferSize bytes in length.
 * 
 * INPUTS:	_		a pointer to the buffer holding the strip
 *			length	the total length of the data in the input buffer
 *
 * OUTPUTS:	compressed data is added to the output stream
 */
void PackStrip( register unsigned char *_, register long length )
{
	register long	_len;
	register short	code;

	WriteCode( CLEAR_CODE );
	for ( _len = 0; length; --length )
	{
		++_len;
		if ( FindString( _, _len ))
		{
			code = LastCode;
		}
		else
		{
			WriteCode( code );
			AddTableEntry( _, _len );
			--_len;
			_ += _len;
			code = *_;
			_len = 1;
		}
	}
	WriteCode( code );
}

void ReleaseMem( const void *addr )
{
}


/* lzw()
 * ---
 *
 * Packs an image according to the specification for the LZW scheme described in the
 * ALDUS/MICROSOFT document for version 5.0 of TIFF (Tagged Image File Format).
 * 
 * INPUTS:	buf_	a pointer to the buffer holding the image to be compressed
 *			buf_o	a pointer or file handle for the destination
 *			length	the total size of the image in bytes
 *
 * OUTPUTS:	output buffer contains compressed data
 *			return value is the size of the compressed image in bytes or -1 on error
 */
long PackLZW( void )
{
	unsigned char	*buf_i;
	void			*buf_o;
	long			len;
	long			ret;

	if (( ret = setjmp( _pksave )) == 0 )
	{
		buf_i		= IBuffP;
		buf_o		= OBuffP;
		len			= IBuffLen;
		ByteCount	= 0;

		for ( ; len > 0; buf_i += BufferSize, len -= BufferSize )
		{
			PackStrip( buf_i, min( len, BufferSize ));
		}
		WriteCode( END_OF_INFORMATION );

		OBuffP	= buf_o;
		ret		= ByteCount;
	}
	else
	{
		fprintf( stderr, "program aborted\n" );
	}
	ReleaseMem( HashTab );
	ReleaseMem( MemBlk );
	return ( ret );
}

/***** ReadFile *****
**
*/
BOOL ReadFile( const char *name )
{
	FILE	*fp;
	long	len;

	fp = fopen( name, "rb" );
	if ( fp )
	{
		fseek( fp, 0, SEEK_END );
		len = ftell( fp );
		fseek( fp, 0, SEEK_SET );

		IBuffP = malloc( len );
		if ( IBuffP )
		{
			if ( fread( IBuffP, len, 1, fp ) == 1 )
			{
/*				BufferSize	= len;
*/				IBuffLen	= len;
				fclose( fp );
				return TRUE;
			}
			fprintf( stderr, "Cannot read file %s\n", name );
		}
		else
		{
			fprintf( stderr, "Out of memory\n" );
		}
		fclose( fp );
	}
	else
	{
		fprintf( stderr, "cannot open file %s\n", name );
	}

	return FALSE;
}

void WriteFile( const char *name )
{
	FILE	*fp;

	fp = fopen( name, "wb" );
	if ( fp )
	{
		if ( fwrite( OBuffP, OBuffLen, 1, fp ) != 1 )
		{
			fprintf( stderr, "cannot write output\n" );
		}
		fclose( fp );
	}
	else
	{
		fprintf( stderr, "Cannot open %s for output\n" );
	}
}


/*
**** main()
*/

int main( int argc, char **argv )
{
	if ( argc == 3 )
	{
		if ( ReadFile( argv[1] ))
		{
			OBuffP	= malloc( IBuffLen );
			if ( OBuffP )
			{
				OBuffLen = PackLZW();
				WriteFile( argv[2] );
				printf( "Original = %ld bytes, packed = %ld bytes\n", IBuffLen, OBuffLen );
			}
			return 0;
		}
	}
	else
	{
		fprintf( stderr, "Usage: lzw input output\n" );
	}
	return 1;
}

