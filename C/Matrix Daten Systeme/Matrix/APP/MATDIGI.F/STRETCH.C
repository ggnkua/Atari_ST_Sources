/* stretch.c */

# define TEST 0

# include <stdio.h>
# include <string.h>
# include <stdlib.h>
# include <ctype.h>
# include <tos.h>
# include <linea.h>
# include <portab.h>
# include <ext.h>

# include <global.h>
# include <fast.h>

# include "yc.h"
# include "yc_fast.h"
# include "tools.h"

# include "digiblit.h"
# include "digiblix.h"

# include "stretch.h"

/*..... interpolation ............................*/

# define Int2(a,b)				(((a)+(b))>>1)
# define Int4(a,b,c,d)			(((a)+(b)+(c)+(d))>>2)
# define Int8(a,b,c,d,e,f,g,h)	(((a)+(b)+(c)+(d)+(e)+(f)+(g)+(h))>>3)

# define B0400(p) ((p)&0x1f)
# define B1006(p) (((p)>>6)&0x1f)
# define B1511(p) (((p)>>11)&0x1f)

/*--------------------------------------------- InterpolateQuad ----*/
uword InterpolateQuad ( uword p0, uword p1, uword p2, uword p3 )
{
	int r, g, b ;

	b = Int4 ( B0400(p0), B0400(p1), B0400(p2), B0400(p3) ) ;
	g = Int4 ( B1006(p0), B1006(p1), B1006(p2), B1006(p3) ) ;
	r = Int4 ( B1511(p0), B1511(p1), B1511(p2), B1511(p3) ) ;
 
	return ( r << 11 ) | ( g <<  6 ) | b ;
}


/*--------------------------------------------- InterpolateOctal ----*/
uword InterpolateOctal ( uword p0, uword p1, uword p2, uword p3,
						uword p4, uword p5, uword p6, uword p7 )
{
	int r, g, b ;

	b = Int8 ( B0400(p0), B0400(p1), B0400(p2), B0400(p3),
			   B0400(p4), B0400(p5), B0400(p6), B0400(p7) ) ;
	g = Int8 ( B1006(p0), B1006(p1), B1006(p2), B1006(p3),
			   B1006(p4), B1006(p5), B1006(p6), B1006(p7) ) ;
	r = Int8 ( B1511(p0), B1511(p1), B1511(p2), B1511(p3),
			   B1511(p4), B1511(p5), B1511(p6), B1511(p7) ) ;
 
	return ( r << 11 ) | ( g <<  6 ) | b ;
}

/*--------------------------------------------- InterpolateNx ----*/
uword InterpolateNx ( uword *p, int nx )
{
	int i, r, g, b ;
	uword pix ;

	for ( r = g = b = 0, i = nx; i > 0 ; i-- )
	{
		pix = *p++ ;
		r += B1511(pix) ;
		g += B1006(pix) ;
		b += B0400(pix) ;
	}
 
	return ( ( r << 11 ) / nx ) | ( ( g <<  6 ) / nx ) | ( b / nx ) ;
}

/*--------------------------------------------- InterpolateNxy ----*/
uword InterpolateNxy ( uword *in, int nx, int ny, int w )
{
	int xi, yi, r, g, b, n ;
	uword pix ;
	
	r = g = b = 0 ;
	for ( yi = ny; yi > 0 ; yi-- )
	{
		for ( xi = nx; xi > 0 ; xi-- )
		{
			pix = *in++ ;
			r += B1511(pix) ;
			g += B1006(pix) ;
			b += B0400(pix) ;
		}
		in += w - nx ;	/* next row	*/
	}
 
 	n = nx * ny ;
	return ( ( r << 11 ) / n ) | ( ( g <<  6 ) / n ) | ( b / n ) ;
}


/*--------------------------------------------- InterpolateDual ----*/
uword InterpolateDual ( uword p0, uword p1 )
{
	int r, g, b ;

	b = Int2 ( B0400(p0), B0400(p1) ) ;
	g = Int2 ( B1006(p0), B1006(p1) ) ;
	r = Int2 ( B1511(p0), B1511(p1) ) ;
 
	return ( r << 11 ) | ( g <<  6 ) | b ;
}


/*--------------------------------------------- InterPolate555_21 -------*/
void InterPolate555_21 ( TImageWindow *source, TImageWindow *destin )
/*
	interpolate 2:1 -> 1:1
*/
{
	uword *in, *out ;
	int w2, x, y, incout, incin ;
	POINT copy ;
	
	w2 = source->window.w / 2 ;
	copy.x = min ( w2, destin->window.w ) ;
	copy.y = min ( source->window.h, destin->window.h ) ;

	in = source->image.data ;
	out = PixelPosition ( destin ) ;

	incout = destin->image.w - copy.x ;
	incin  = source->image.w - 2 * copy.x ;	/* skip rest + 1 line	*/
	for ( y = 0 ; y < copy.y ; y++ )
	{
		for ( x = 0 ; x < copy.x ; x++ )
			*out++ = InterpolateDual ( *in++, *in++ ) ;
		out += incout ;
		in += incin ;
	}
}

/*--------------------------------------------- InterPolate555_41 -------*/
void InterPolate555_41 ( TImageWindow *source, TImageWindow *destin )
/*
	interpolate 4:1 -> 1:1
*/
{
	uword *in, *out ;
	int w4, x, y, incout, incin ;
	POINT copy ;
	
	w4 = source->window.w / 4 ;
	copy.x = min ( w4, destin->window.w ) ;
	copy.y = min ( source->window.h, destin->window.h ) ;

	in  = source->image.data ;
	out = PixelPosition ( destin ) ;

	incout = destin->image.w - copy.x ;
	incin  = source->image.w - 4 * copy.x ;	/* skip rest + 1 line	*/
	for ( y = 0 ; y < copy.y ; y++ )
	{
		for ( x = 0 ; x < copy.x ; x++ )
			*out++ = InterpolateQuad ( *in++, *in++, *in++, *in++ ) ;
		out += incout ;
		in += incin ;
	}
}

/*--------------------------------------------- InterPolate555_22 -----------*/
void InterPolate555_22 ( TImageWindow *source, TImageWindow *destin )
/*
	interpolate 2:2 -> 1:1
*/
{
	uword *in0, *in1, *out ;
	int w2, h2, x, y, incout, incin ;
	POINT copy ;
	
	w2 = source->window.w / 2 ;
	h2 = source->window.h / 2 ;
	copy.x = min ( w2, destin->window.w ) ;
	copy.y = min ( h2, destin->window.h ) ;

	in0 = source->image.data ;
	in1 = in0 + source->image.w ;
	out = PixelPosition ( destin ) ;

	incout = destin->image.w - copy.x ;
	incin  = 2 * ( source->image.w - copy.x ) ;	/* skip rest + 1 line	*/
	for ( y = 0 ; y < copy.y ; y++ )
	{
		for ( x = 0 ; x < copy.x ; x++ )
			*out++ = InterpolateQuad ( *in0++, *in0++, *in1++, *in1++ ) ;
		out += incout ;
		in0 += incin ;
		in1 += incin ;
	}
}

/*--------------------------------------------- InterPolate555_42 -----------*/
void InterPolate555_42 ( TImageWindow *source, TImageWindow *destin )
/*
	interpolate 4:2 -> 1:1
*/
{
	uword *in0, *in1, *out ;
	int w4, h2, x, y, incout, incin ;
	POINT copy ;
	
	w4 = source->window.w / 4 ;
	h2 = source->window.h / 2 ;
	copy.x = min ( w4, destin->window.w ) ;
	copy.y = min ( h2, destin->window.h ) ;

	in0 = source->image.data ;
	in1 = in0 + source->image.w ;
	out = PixelPosition ( destin ) ;

	incout = destin->image.w - copy.x ;
	incin  = 2 * source->image.w - 4 * copy.x ;	/* skip rest + 1 line	*/
	for ( y = 0 ; y < copy.y ; y++ )
	{
		for ( x = 0 ; x < copy.x ; x++ )
			*out++ = InterpolateOctal ( *in0++, *in0++, *in0++, *in0++,
										*in1++, *in1++, *in1++, *in1++ ) ;
		out += incout ;
		in0 += incin ;
		in1 += incin ;
	}
}

/*--------------------------------------------- InterPolate555 -----------*/
void InterPolate555 ( TImageWindow *source, TImageWindow *destin, POINT *zoom )
{
	switch ( zoom->x )
	{
case 2 : 	switch ( zoom->y )
			{
		case 1 :	InterPolate555_21 ( source, destin ) ;	return ;
		case 2 :	InterPolate555_22 ( source, destin ) ;	return ;
			}
			break ;
case 4 :	switch ( zoom->y )
			{
		case 1 :	InterPolate555_41 ( source, destin ) ;	return ;
		case 2 :	InterPolate555_42 ( source, destin ) ;	return ;
			}
			break ;
	}
}


/*..... stretch ............................*/

/*--------------------------------------------- BlitFullSourceWindow -----------*/
void BlitFullSourceWindow ( TImageWindow *source, TImageWindow *destin )
{
# if 0
	uword *in, *out ;
	int x, y, incout, incin ;
	POINT copy ;
	
	copy.x = min ( source->window.w, destin->window.w ) ;
	copy.y = min ( source->window.h, destin->window.h ) ;

	in  = source->image.data ;
	out = PixelPosition ( destin ) ;

	incout = destin->image.w - copy.x ;
	incin  = source->image.w - copy.x ;
	for ( y = 0 ; y < copy.y ; y++ )
	{
		for ( x = 0 ; x < copy.x ; x++ )
			*out++ = *in++ ;
		out += incout ;
		in  += incin ;
	}
# else
	POINT copy ;
	uword *data ;
	
	data = source->image.data ;
	if ( data != NULL )
	{
		copy.x = min ( source->window.w, destin->window.w ) ;
		copy.y = min ( source->window.h, destin->window.h ) ;
		Blit555Rect ( data,
				  PixelPosition ( destin ),
				  copy.x, copy.y,
				  source->image.w - copy.x,		/* in++ 	*/
				  destin->image.w - copy.x ) ;	/* out++ 	*/
	}
# endif
}

# define MAXdestWidth	64

int TableSourceWidth = 0 ,
	TableDestWidth   = 0 ;
int SourceDxTable[MAXdestWidth] ;	/* table of source ixs for xd	*/

/*-------------------------------------- CheckStretchBlitTable -----------*/
bool CheckStretchBlitTable ( int sw, int dw )
{
	int xs, xl, xd, *xst ;
	
	xl = 0 ;
	if ( TableSourceWidth != sw || TableDestWidth != dw )
	{
		if ( dw <= MAXdestWidth )
		{
			xst = SourceDxTable ;
			for ( xd = 0 ; xd < dw; xd++ )
			{
				xs = iscale ( xd, sw-1, dw-1 ) ;
				*xst++ = xs - xl ;
				xl = xs ;
			}
			TableSourceWidth = sw ;
			TableDestWidth   = dw ;
		}
		else
			return FALSE ;
	}
	return TRUE ;
}


/*--------------------------------------------- StretchBlit -----------*/
void StretchBlit ( TImageWindow *source, TImageWindow *destin )
/*
	stretch full image source to window
*/
{
	uword *in0, *in, *out ;
	int xd, yd, ys, yl, incout ;
	int *xst ;

	if ( CheckStretchBlitTable ( source->window.w, destin->window.w ) )
	{
		in0 = PixelPosition ( source ) ;
		out = PixelPosition ( destin ) ;

		yl = 0 ;
		incout = destin->image.w - destin->window.w ;
		for ( yd = 0 ; yd < destin->window.h ; yd++ )
		{
			xst = SourceDxTable ;
			in = in0 ;
			for ( xd = 0 ; xd < destin->window.w ; xd++ )
			{
				*out++ = *in ;	/* move pixel	*/
				in += *xst++ ;	/* increment source pointer	*/
			}
			ys = iscale ( yd, source->window.h-1, destin->window.h-1 ) ;
			in0 += source->image.w * ( ys - yl ) ;
			yl = ys ;

			out  += incout ;
		}
	}
}


