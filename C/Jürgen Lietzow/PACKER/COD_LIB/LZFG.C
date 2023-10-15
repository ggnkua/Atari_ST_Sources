/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 4/93  <<<<<<<<<<<<<		*/
/*																		*/
/*																		*/
/*		P R O J E C T	:	Beispiele fr Codieralgorithmen				*/
/*							CODING.TTP									*/
/*																		*/
/*		M O D U L E		:	LZFH.C										*/
/*																		*/
/*																		*/
/*		Author			:	Jrgen Lietzow fr TOS-Magazin				*/
/*																		*/
/*		System/Compiler	:	Atari ST/TT, TOS 4.01, Pure C				*/
/*																		*/
/*		Last Update		:	26.02.93 (JL)								*/
/*																		*/
/*																		*/
/************************************************************************/

#include <errno.h>
#include <limits.h>
#include <stdlib.h>
#include <string.h>

#include "..\cod_lib.h"

#define	DECODING				/*	define this to support decoding */
#define DECODEALL				/*	define this to support decoding
									for all possible parameters
									i.e. 32 Kbytes dictionary */
#define ENCODING				/*	define this to support encoding */


/*	The following defines may be changed */

#define DIC_BITS	(15)	/*	Size of sliding window dictionary */
							/*	range: 11 - 15 */
#define MAP_BITS	(11)	/*	Not huffman coded lower position bits */
							/*	range: 3 - 11 and */
							/*	0 <= DIC_BITS - MAP_BITS <= 8 */
#define THRESHOLD	(3)		/*	Smaller string lengths are handled */
							/*	as literals */
							/*	PkZIP uses 2 for binaries and 3 for */
							/*	ASCII-text. This is probably the */
							/*	best choice */
							/*	range: 2 - 4 */
#define MAX_LEN		(256)	/*	Maximum string length */
							/*	range: 32 - 1024 */
#define	HASH_BITS	(14)	/*	Size of hash table of first */
							/*	characters of each string in the */
							/*	dictionary */
							/*	range: 10 - 14 */
#define POS_UPDATE	(8192)	/*	Update huffamn tree after POS_UPDATE */
							/*	outputted codes */
							/*	range: 1024 - 16384 */
#define LEN_UPDATE	(4096)	/*	Update huffamn tree after LEN_UPDATE */
							/*	outputted string length */
							/*	range: 1024 - 16384 */


#ifdef DEBUG 

#define	Last(n)		(nlast[n])
#define	Next(n)		(nnext[n])
#define Nshift		(0)
#define Nsize		(1)
#define Hash(n)		hash[n]
#define Hshift		(0)
#define Hsize		(1)

#else

#if DIC_BITS > 14

#define	Last(n)		(nlast[n])
#define	Next(n)		(nnext[n])
#define Nshift		(0)
#define Nsize		(1)
#define Hash(n)		hash[n]
#define Hshift		(0)
#define Hsize		(1)

#else

/*	This way is faster, but only works with a maximum dictionary size of
	16 Kbytes. With 68020/30 code generation the previous way might be
	the better one because of the extended addressing modes  */

#define	Last(n)		(*(int *)((char *)nlast + (n)))
#define	Next(n)		(*(int *)((char *)nnext + (n)))
#define Nshift		(1)
#define Nsize		(2)
#define Hash(n)		(*(int *)((char *)hash + (n)))
#define Hshift		(1)
#define Hsize		(2)

#endif
#endif

#define	NUM_ENTRIES	((int)((1L<<DIC_BITS)-1L))	/* we use one less and take the */
										/* last one for easier and faster */
										/* handling (sentinel) */
#define SENTINEL	(NUM_ENTRIES*Nsize)	/* This is our sentinel word */
										/* All last hash chain entries */
										/* and all empty hashes point to */
										/* this word */

#define LEN_CODES	(MAX_LEN-THRESHOLD+1)	/*	number of huffman coded */
											/*	string length */
#define POS_CODES	(256+(1<<(DIC_BITS-MAP_BITS)))
#define	DIC_SIZE	((long)NUM_ENTRIES+(long)MAX_LEN)
#define MAP_MASK	((1<<MAP_BITS)-1)
#define HASH_LEN	(1<<HASH_BITS)

#define	NIL			(0)

						/*	We need here some kind of function that gets
							us a HASH_BITS long index out of the
							first two characters where <p> points to */

#if	THRESHOLD < 3
#define	HashIndex(p)	((((int)(p)[0] << (HASH_BITS-8)) ^ \
						(int)(p)[1])<<Hshift)
#else
#define	HashIndex(p)	((((int)(p)[0] << (HASH_BITS-8)) ^ \
						((int)(p)[1] << ((HASH_BITS-8)>>1)) ^ \
						(int)(p)[2])<<Hshift)
#endif

#ifndef DECODEALL

static	uchar	dictionary[DIC_SIZE];	/* sliding dictionary */
									/* the first MAX_LEN characters are */
									/* copied to top of dictionary + MAX_ENTRIES */
#else
static	uchar	dictionary[32768L+2048L];	/* Maximum dictionary size supported */
#endif

static	HTI		*hti_len;			/* huffman code for string length */
static	HTI		*hti_codes;			/* huffman code for string index and */
									/* literals (see HUFFMAN.C) */
static	XFILE	*sxfp;				/* source file */
static	XFILE	*dxfp;				/* destination file */
static	int		str_len;			/* string length of best string match */
static	int		txt_pos;			/* current position in the dictionary
									/* ring buffer */

/*	for decoding only */

#ifdef DECODING

static	int		max_len;			/*	see MAX_LEN */
static	int		len_codes;			/*	see LEN_CODES */
static	int		threshold;			/*	see THRESHOLD */
static	int		dic_bits;			/*	see DIC_BITS */
static	int		map_bits;			/*	see MAP_BITS */
static	int		num_entries;		/*	see NUM_ENTRIES */
static	int		len_update;			/*	see LEN_UPDATE */
static	int		pos_update;			/*	see POS_UPDATE */
static	long	dic_size;			/*	see DIC_SIZE */

#endif

/*	for encoding only. Only for speed up encoding */

#ifdef ENCODING

static	int		hash[HASH_LEN];		/* Each entry points to a chain */
									/* Each chain holds strings with same */
									/* hash value */

static	int		nlast[(long)NUM_ENTRIES+1L];	/* points to last one in the chain */
static	int		nnext[(long)NUM_ENTRIES+1L];	/* points to next one in the chain */

				/*	NOTE: the index to <nlast> or <nnext> referes
					to the word in the dictionary with the same index.
					i.e. nlast[5] referes to the word starting
					at <dictionary + 5>
				*/
#endif

/*
*	Add an new word, delete old word to/from the dictionary
*	For encoding only
*/

#ifdef ENCODING

static	void	InsertWord( int dic_pos, int len, uchar *dword )
{
	int		idx;
	int		first;
	int		last;

	while ( --len >= 0 )
	{
		/*	delete old word */
		
		if ( ( last = Last(dic_pos) ) < NIL )
		{
			first = Next(dic_pos);
			Last(first) = last;
			last = dic_pos >> Nshift;
			Hash(HashIndex((dictionary+last))) = first;
		}
		else
		{
			Next(last) = first = Next(dic_pos);
			Last(first) = last;
		}
		
		/* insert new word */
		
		first = Hash(idx = HashIndex(dword));
		Hash(idx) = dic_pos;
		Last(dic_pos) = -1;
		Next(dic_pos) = first;
		Last(first) = dic_pos;

		/*	copy first part of ring buffer to the top */

		dictionary[txt_pos] = *dword++;
		if ( txt_pos <= MAX_LEN )
#if DIC_BITS < 15
			dictionary[txt_pos+NUM_ENTRIES] = dword[-1];
#else
			dictionary[(long)txt_pos+(long)NUM_ENTRIES] = dword[-1];
#endif
		/*	update position within dictionary ring buffer */

		txt_pos++;
		dic_pos += Nsize;

		if ( txt_pos >= NUM_ENTRIES )
		{
			txt_pos = 0;
			dic_pos = 0;
		}
	}
}

/*
*	Find a word from the input buffer in the dictionary
*	For encoding only
*/

static	int		FindWord( int first, uchar *master )
{
	uchar	*m1, *wp;
	uchar	best_len = 1;
	int		best_word = -1;
	int		len;
	uchar	c;
	
	m1 = master;
	c = m1[1];
	do
	{
		wp = &dictionary[(first >> Nshift)];
		wp += best_len;
		if ( *wp == c && m1[0] == wp[-1] )
		{
			m1 = master;
			wp -= best_len;
			len = MAX_LEN - 1;
			while ( *wp++ == *m1++ )
				if ( --len == 0 )
				{
					str_len = MAX_LEN - 1;
					return ( first );
				}
			len = (MAX_LEN - 1) - len;
			if ( len > best_len )
			{
				best_word = first;
				best_len = len;
				m1 = &master[len-1];
				c = m1[1];
			}
			else
				m1 = &master[best_len-1];
		}
	} while ( ( first = Next(first) ) != SENTINEL );
	str_len = best_len;
	return ( best_word );
}

int		LZHEncode( long slen )
{
	int		len;
	uchar	*iptr = sxfp->bit_buf;
	int		in_rest = 0;
	int		wrd, first;
		
	str_len = 0;
	
	/* until end of file (slen) */
	
	while ( ( slen -= (long) str_len ) > 0 )
	{
		/*	fill input buffer. At least max_len characters or less
			if we reached end of file */
			
		if ( in_rest <= MAX_LEN && (long) in_rest != slen )
		{
			memmove( sxfp->bit_buf, iptr, in_rest );
			iptr = sxfp->bit_buf;
			len = (int) Min( (long) XFP_BUFFER - in_rest, slen - in_rest );
			if ( ( first = (int) XRead( iptr + in_rest, len, sxfp ) ) < len )
			{
				if ( first < 0 || slen - (long) first - in_rest > 0L )
					return ( EIO );
			}
			in_rest += first;
		}
		
		/*	if we have words with same hash index in the dictionary,
			look for best word, with a length greater or equal to THRESHOLD */
			
		if ( ( first = Hash(HashIndex(iptr)) ) != SENTINEL &&
			 ( wrd = FindWord( first, iptr ) ) >= NIL &&
			 ( str_len = Min( str_len, in_rest ) ) >= THRESHOLD )
		{
			/* calculate relative position within dictionary ring buffer */
			
			first = wrd;
			wrd >>= Nshift;
			if ( ( wrd = txt_pos - wrd ) < 0 )
				wrd += NUM_ENTRIES;
			len = str_len;
			if ( ( wrd = wrd - len ) < 0 )
				wrd += NUM_ENTRIES;
			len -= THRESHOLD;
			
			/*	output huffman code. The first 256 codes are reserved
				for literals */
			
			HuffEncode( hti_codes, 256 + (wrd >> MAP_BITS) );
			XPutBits( MAP_BITS, wrd & MAP_MASK, dxfp );
			HuffEncode( hti_len, len);
		}
		else
		{
			/*	output next character as literal */

			HuffEncode( hti_codes, *iptr );
			str_len = 1;
		}
		
		/*	update dictionary */
		
		InsertWord( txt_pos * Nsize, str_len, iptr );
		iptr += str_len;
		in_rest -= str_len;
	}
	return ( 0 );
}

int		LZHEncodeInit( XFILE *ssxfp, XFILE *ddxfp )
{
	int		i;
	
	/*	configurate huffman tree for dictionary positions and
		string length */

	if ( ( hti_codes = HuffStart( ddxfp, POS_CODES, POS_UPDATE ) ) == NULL )
		return ( ENOMEM );
	if ( ( hti_len = HuffStart( ddxfp, LEN_CODES, LEN_UPDATE ) ) == NULL )
	{
		HuffEnd( hti_codes );
		return ( ENOMEM );
	}
	
	/*	initialize dictionary */
	
	memset( dictionary, ' ', DIC_SIZE );
	
	/*	initialize hash table */

	for ( i = 0; i < HASH_LEN; i++ )
		hash[i] = SENTINEL;

	for ( i = 0; i < NUM_ENTRIES * Nsize; i += Nsize )		
	{
		Last(i) = i;
		Next(i) = i;
	}

	sxfp = ssxfp;
	dxfp = ddxfp;
	txt_pos = 0;

	/*	output various parameters for the decoder */
		
	XPutBits( 4, DIC_BITS, dxfp );
	XPutBits( 4, MAP_BITS, dxfp );
	XPutBits( 5, 1, dxfp );			/* number of free entries */
									/* here: one for sentinel */
	XPutBits( 10, LEN_CODES, dxfp );
	XPutBits( 3, THRESHOLD, dxfp );
	XPutBits( 16, POS_UPDATE, dxfp );
	XPutBits( 16, LEN_UPDATE, dxfp );
	return ( 0 );	
}

#endif

#ifdef DECODING

int		LZHDecode( long dlen )
{
			int		i;
			int		tp;
			int		smax = max_len;
			int		nwrds = num_entries;
			int		len;
			uchar	*optr = dictionary;
			uchar	*iptr;
	static	uchar	temp[2048];
	
	len = 0;
	tp = 0;
	/*	until end of file */
	
	while ( ( dlen -= (long) len ) > 0 )
	{
		/*	read first code. A code less than 256 is a literal */
		
		if ( ( i = HuffDecode( hti_codes ) ) < 256 )
		{
			len = 1;
			*optr++ = (uchar) i;
			if ( ++tp >= nwrds )
			{
				optr = dictionary;
				XWrite( optr, nwrds, dxfp );
				tp = 0;
			}
			else if ( tp <= smax )
			{
				optr[nwrds-1] = (uchar) i;
			}
		}
		else
		{
			i -= 256;
			i <<= map_bits;
			i |= XGetBits( map_bits, sxfp );
			
			len = HuffDecode( hti_len );
			len += threshold;
			
			/* calculate relative position to absolute one in the dictionary */

			if ( ( i = tp - i ) < 0 )
				i += nwrds;
			if ( ( i -= len ) < 0 )
				i += nwrds;
			iptr = dictionary + i;

			if ( i < tp && i + len > tp )
			{
				/*	make sure not to override the destination dictionary
					position */

				memmove( temp, iptr, len );
				iptr = temp;
			}
			i = len;
			do
			{
				*optr++ = *iptr++;
				if ( ++tp >= nwrds )
				{
					optr = dictionary;
					XWrite( optr, nwrds, dxfp );
					tp = 0;
				}
				else if ( tp <= smax )
				{
					optr[nwrds-1] = iptr[-1];
				}
			} while ( --i > 0 );
		}
	}
	XWrite( dictionary, tp, dxfp );
	return ( 0 );
}

int		LZHDecodeInit( XFILE *ssxfp, XFILE *ddxfp )
{
	sxfp = ssxfp;
	dxfp = ddxfp;
	txt_pos = 0;

	/*	read decoder parameters */
	
	dic_bits = XGetBits( 4, sxfp );
	map_bits = XGetBits( 4, sxfp );
	num_entries = 1 << dic_bits;
	num_entries -= XGetBits( 5, sxfp );
	len_codes = XGetBits( 10, sxfp );
	threshold = XGetBits( 3, sxfp );
	pos_update = XGetBits( 16, sxfp );
	len_update = XGetBits( 16, sxfp );

	max_len = len_codes + threshold - 1;
	dic_size = (long) num_entries + (long) max_len;

	/*	initialize huffman trees */
	
	if ( ( hti_codes = HuffStart( ssxfp, 256 + (1<<(dic_bits - map_bits)), pos_update ) ) == NULL )
		return ( ENOMEM );
	if ( ( hti_len = HuffStart( ssxfp, len_codes, len_update ) ) == NULL )
	{
		HuffEnd( hti_codes );
		return ( ENOMEM );
	}
	memset( dictionary, ' ', dic_size );
	
	return ( 0 );	
}

#endif

int		LZHExit( void )
{
	HuffEnd( hti_codes );
	HuffEnd( hti_len );
	return ( 0 );
}


