/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 4/93  <<<<<<<<<<<<<		*/
/*																		*/
/*																		*/
/*		P R O J E C T	:	Beispiele fr Codieralgorithmen				*/
/*							CODING.TTP									*/
/*																		*/
/*		M O D U L E		:	HUFFMAN.C									*/
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

/*
#define DEBUG
*/

#ifndef NULL
#define NULL ((void *) 0L)
#endif

#ifndef DEBUG

/*	This one is faster */

#define		HnSize				((uint)(sizeof (HN)))
#define		HnPtr(hn,n)			((HN*) ((char *)(hn) + (n)))
#define		HnIdx(hn,_hn)		((int)((long)_hn - (long)hn))

#else

#define		HnSize				(1)
#define		HnPtr(hn,n)			(&(hn[n]))
#define		HnIdx(hn,_hn)		(((uint)((long)_hn - (long)hn)) / \
								(uint) sizeof HN )
#endif

static	int		cmp( int *p1, int *p2 )
{
	int		t;
	
	if ( ( t = *p1 - *p2 ) == 0 )
		t = p1[1] - p2[1];
	return ( t );
}

static	char	bits[32];
static	int		temp[(MAX_HNUM << 1) + 4];

void	HuffBuildTree( HTI *hti )
{
	int		nlowest;
	int		num = hti->huf_num * HnSize;
	int		max, freq;
	HN		*root, *h, *h1;
	int		*p1, *p2;
	
	root = hti->ht;
	h = HnPtr(root,num - HnSize);
	nlowest = 0;
	p1 = temp;
	p2 = temp + (((uint)num / HnSize) << 1);
	*p2 = INT_MAX;
	for ( max = num; ( max -= HnSize ) >= 0; h-- )
	{
		h->son0 = 0;
		if ( h->freq <= 1 )
		{
			*p1++ = h->freq;
			*p1++ = max;
		}
		else
		{
			nlowest++;
			*--p2 = max;
			*--p2 = h->freq++;
			h->freq >>= 1;
		}
	}
	qsort( p1, nlowest, 2 * sizeof (int), cmp );

	p1 = temp;	
	h1 = h = HnPtr(root,num);
	nlowest = num;
	max = hti->hn_root;
	do
	{
		h->freq = INT_MAX;
		if ( *p1 <= h1->freq )
		{
			freq = *p1++;
			HnPtr(root,(h->son0 = *p1++))->dad = num;
		}
		else
		{
			freq = h1->freq;
			h->son0 = nlowest;
			h1++->dad = num;
			nlowest += HnSize;
		}
		if ( *p1 <= h1->freq )
		{
			freq += *p1++;
			HnPtr(root,(h->son1 = *p1++))->dad = num;
		}
		else
		{
			freq += h1->freq;
			h->son1 = nlowest;
			h1++->dad = num;
			nlowest += HnSize;
		}
		h->freq = freq;
		num += HnSize;
		h++;
	} while ( num <= max );
	h[-1].dad = 0;
#ifdef DEBUG
	num = hti->huf_num * HnSize;
	root = hti->ht;
	h = HnPtr(root,num);
	for ( max = hti->hn_root ; num <= max; h++, num += HnSize )
	{
		if ( h->son0 < 0 || h->son0 >= max )
			exit( -2 );
		if ( h->son1 < 0 || h->son1 >= max )
			exit( -3 );
	}
#endif	
}

void	HuffInit( HTI *hti, XFILE *xfp, int update )
{
	int		max, i;
	HN		*h;
	
	i = hti->huf_num * 2 - 1;

	hti->xfp = xfp;
	hti->update = update;
	hti->cupdate = hti->huf_num >> 1;
	hti->cnt = 0;
	hti->hn_root = (uint) (i-1) * HnSize;
	
	max = hti->huf_num;
	(uint) max *= HnSize;
	
	for ( i = 0, h = hti->ht; i < max; i += HnSize, h++ )
	{
		h->freq = 1;
		h->dad = 0;
		h->son0 = -1;
		h->son1 = -1;
	}
	HnPtr(hti->ht,max-HnSize)->dad = -1;
	
	HuffBuildTree( hti );
}

HTI		*HuffStart( XFILE *xfp, int huf_num, int update )
{
	int		max;
	HTI		*hti;

	if ( huf_num > MAX_HNUM )	
		return ( NULL );

	max = huf_num * 2 - 1;
	
	if ( ( hti = malloc( sizeof (HTI) + (long) max * sizeof (HN) ) ) == NULL )
		return ( hti );
	
	hti->huf_num = huf_num;
	HuffInit( hti, xfp, update );
	return ( hti );
}

void	HuffExit( HTI *hti )
{
	XBitsFlush( hti->xfp );
}

void	HuffEnd( HTI *hti )
{
	XBitsFlush( hti->xfp );
	free( hti );
}

void	HuffEncode( HTI *hti, uint val )
{
	HN		*hn, *h;
	int		i, n;
	uint	c;
	ulong	code;
	char	*p;
	XFILE	*xfp;

#ifdef DEBUG
	if ( val >= hti->huf_num )
		exit( ERANGE );
#endif

	val *= HnSize;
	c = val;
	hn = HnPtr(hti->ht,0);
	h = HnPtr(hn,(int)c);
	h->freq++;
	if ( ( n = h->son0 ) == 0 )
	{
		p = bits;
		i = h->dad;
		do
		{
			if ( (h = HnPtr(hn,i))->son1 == c )		*p++ = 1;
			else									*p++ = 0;
			n++;
			if ( ( c = h->dad ) == 0 )
				break;
			if ( (h = HnPtr(hn,c))->son1 == i )		*p++ = 1;
			else									*p++ = 0;
			n++;
		} while ( ( i = h->dad ) != 0 );

		if ( n > 16 )
		{
			xfp = hti->xfp;
			code = xfp->bitmap;
			i = xfp->num_bits;
			while ( --n >= 0 )
			{
				code += code;
				(uchar) code |= *(--p);
				if ( --i <= 0 )
				{
					*(ulong*)(xfp->bit_buf + xfp->bb_pos) = code;
					xfp->bb_pos += (int) sizeof (long);
					if ( xfp->bb_pos >= XFP_BUFFER )
					{
						ConvLong( xfp->bit_buf, xfp->bb_pos );
						XWrite( (char *) xfp->bit_buf, xfp->bb_pos, xfp );
						xfp->bb_pos = 0;
					}
					i = 32;
				}
			}
		}
		else
		{
			h = HnPtr(hn,(int)val);
			h->son0 = i = n;
			c = 0;
			while ( --i >= 0 )
			{
				c += c;
				(char) c |= *(--p);
			}
			h->son1 = c;
			goto da;
		}
	}
	else
	{
		c = h->son1;
da:
		xfp = hti->xfp;
		code = xfp->bitmap;
		i = xfp->num_bits;
		if ( i >= n )
		{
			code <<= n;
			(uint) code |= c;
			if ( ( i -= n ) == 0 )
			{	
				*(ulong*)(xfp->bit_buf + xfp->bb_pos) = code;
				xfp->bb_pos += (int) sizeof (long);
				if ( xfp->bb_pos >= XFP_BUFFER )
				{
					ConvLong( xfp->bit_buf, xfp->bb_pos );
					XWrite( (char *) xfp->bit_buf, xfp->bb_pos, xfp );
					xfp->bb_pos = 0;
				}
				i = 32;
			}
		}
		else
		{
			code <<= i;
			(uint) code |= c >> (n -= i);
			*(ulong*)(xfp->bit_buf + xfp->bb_pos) = code;
			xfp->bb_pos += (int) sizeof (long);
			if ( xfp->bb_pos >= XFP_BUFFER )
			{
				ConvLong( xfp->bit_buf, xfp->bb_pos );
				XWrite( (char *) xfp->bit_buf, xfp->bb_pos, xfp );
				xfp->bb_pos = 0;
			}
			(uint) code = c;
			i = 32 - n;
		}
	}
	xfp->num_bits = i;
	xfp->bitmap = code;

	if ( hti->cnt++ >= hti->cupdate )
	{
		HuffBuildTree( hti );
		hti->cupdate <<= 1;
		if ( hti->cupdate > hti->update )
			hti->cupdate = hti->update;
		hti->cnt = 0;
	}
}


uint	HuffDecode( HTI *hti )
{
	HN		*h;
	int		i, n;
	uint	val;
	ulong	code;
	XFILE	*xfp = hti->xfp;

	if ( ( n = xfp->num_bits ) == 0 )
	{
		if ( xfp->bb_pos >= xfp->bb_max )
		{
			xfp->bb_max = (int) XRead( (char *) xfp->bit_buf, XFP_BUFFER, xfp );
			ConvLong( xfp->bit_buf, xfp->bb_max );
			xfp->bb_pos = 0;
		}
		code = *(ulong*)(xfp->bit_buf + xfp->bb_pos);
		xfp->bb_pos += (int) sizeof (long);
		n = 32;
	}
	else
		code = xfp->bitmap;
	h = hti->ht;
	val = hti->hn_root;
	code <<= 32 - n;
	i = (uint) hti->huf_num * HnSize;
	do
	{
		if ( (long) code < 0 )
			val = HnPtr(h,val)->son1;
		else
			val = HnPtr(h,val)->son0;
		
		if ( --n == 0 )
		{
			if ( xfp->bb_pos >= xfp->bb_max )
			{
				xfp->bb_max = (int) XRead( (char *) xfp->bit_buf, XFP_BUFFER, xfp );
				ConvLong( xfp->bit_buf, xfp->bb_max );
				xfp->bb_pos = 0;
			}
			code = *(ulong*)(xfp->bit_buf + xfp->bb_pos);
			xfp->bb_pos += (int) sizeof (long);
			n = 32;
		}
		else
			code += code;
	} while ( val >= i );

	code >>= 32 - n;
	
	HnPtr(h,val)->freq++;
	val /= HnSize;
	xfp->bitmap = code;
	xfp->num_bits = n;

	if ( hti->cnt++ >= hti->cupdate )
	{
		HuffBuildTree( hti );
		hti->cupdate <<= 1;
		if ( hti->cupdate > hti->update )
			hti->cupdate = hti->update;
		hti->cnt = 0;
	}
	return ( val );
}

static	jmp_buf	priv_error;
static	long	sdlimit;
static	long	sslimit;
static	jmp_buf	*sderror;
static	jmp_buf	*sserror;

int	RLHuffEncode( XFILE *sxfp, XFILE *dxfp, long slen )
{
	HTI		*hti;
	uchar	*p;
	int		max;
	uchar	c, last = 0;
	int		cnt;
	int		ret;
	
	if ( ( hti = HuffStart( dxfp, 512, 4000 ) ) == NULL )
		return ( ENOMEM );
	sderror = dxfp->jmpbuf;
	sdlimit = dxfp->limit;
	dxfp->jmpbuf = priv_error;
	dxfp->limit = -1L;
	if ( ( ret = setjmp( priv_error ) ) == 0 )
	{
		while ( slen )
		{
			p = (uchar *) sxfp->bit_buf;
			max = (int) Min( (long) XFP_BUFFER, slen );
			if ( ( ret = (int) XRead( p, max, sxfp ) ) != max )
			{
				if ( ret != 0 )
					ret = EIO;
				break;
			}
			ConvLong( p, max );
			slen -= (long) max;
			while ( --max >= 0 )
			{
				if ( ( c = *p++ ) == last )
				{
					cnt = 256;
					while ( *p == c && cnt < 511 && --max >= 0 )
					{
						p++;
						cnt++;
					}
					HuffEncode( hti, cnt );	
				}
				else
				{
					HuffEncode( hti, c );	
					last = c;
				}
			}
		}
		HuffEnd( hti );
		if ( !slen )
			ret = 0;
	}
	else
		if ( ret == LIMIT_ERR )
			ret = 0;
			
	dxfp->jmpbuf = sderror;
	dxfp->limit = sdlimit;
	if ( ret && xfp_err && xfp_err->jmpbuf )
		longjmp( xfp_err->jmpbuf, ret );
	return ( ret );
}
	
int		RLHuffDecode( XFILE *sxfp, XFILE *dxfp, long dlen )
{
	HTI		*hti;
	char	*p;
	int		max;
	uint	c, last = 0;
	int		ret;
	
	if ( sxfp->jmpbuf )
		xfp_err = sxfp;
	else
		if ( dxfp->jmpbuf )
			xfp_err = dxfp;
	if ( ( hti = HuffStart( sxfp, 512, 4000 ) ) == NULL )
	{
		if ( xfp_err && xfp_err->jmpbuf )
			longjmp( xfp_err->jmpbuf, ENOMEM );
		return ( ENOMEM );
	}
	p = (char *) dxfp->bit_buf;
	sserror = sxfp->jmpbuf;
	sslimit = sxfp->limit;
	sxfp->jmpbuf = priv_error;
	sxfp->limit = -1L;
	if ( ( ret = setjmp( priv_error ) ) == 0 )
	{
		do
		{
			if ( ( max = (int) Min( (long) XFP_BUFFER, dlen ) ) == 0 )
				break;
			while ( --max >= 0 )
			{
				c = HuffDecode( hti );
				if ( c >= 256 )
				{
					c -= 255;
					*p++ = (char) last;
					while ( --c != 0 )
					{
						if ( --max < 0 ) 
						{
							p = (char *) dxfp->bit_buf;
							ret = (int) Min( (long) XFP_BUFFER , dlen );
							ConvLong( p, ret );
							if ( XWrite( p, ret, dxfp ) != ret )
								goto da;
							dlen -= ret;
							ret = 0;
							if ( ( max = (int) Min ( (long) XFP_BUFFER, dlen ) ) == 0 )
							{
								errno = ERANGE;
								goto da;
							}
							max--;
						}
						*p++ = (char) last;
					}
				}
				else
				{
					*p++ = (char) c;
					last = c;
				}
			}
			p = (char *) dxfp->bit_buf;
			ret = (int) Min( (long) XFP_BUFFER, dlen );
			ConvLong( p, ret );
			if ( XWrite( p, ret, dxfp ) != ret )
			{
da:				if ( !errno )
					ret = EIO;
				else
					ret = errno;
				break;
			}
			dlen -= ret;
			ret = 0;
		} while ( ( max = (int) Min ( (long) XFP_BUFFER, dlen ) ) != 0 );
		HuffEnd( hti );
	}
	else
		if ( ret == LIMIT_ERR )
			ret = 0;
			
	sxfp->jmpbuf = sserror;
	sxfp->limit = sslimit;
	if ( ret && xfp_err && xfp_err->jmpbuf )
		longjmp( xfp_err->jmpbuf, ret );
	return ( ret );
}

