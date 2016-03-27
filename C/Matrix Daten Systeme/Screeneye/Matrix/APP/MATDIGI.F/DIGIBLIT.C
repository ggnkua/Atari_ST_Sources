/* digiblit.c */

# include <stdio.h>
# include <string.h>
# include <ctype.h>
# include <tos.h>
# include <linea.h>
# include <portab.h>
# include <ext.h>

# include <global.h>
# include <fast.h>

# include <picfiles.h>
# include "yc.h"
# include "yc_fast.h"
# include "tools.h"

# define HWzoom	4		/* max hw zoom factor	*/
# include "mdf_addr.h"

# include "digiblit.h"
# include "digiblix.h"
# include "digitise.h"
# include "digitisx.h"

POINT Zoom1x1 = { 1, 1 } ;

# define USEgrey	0

/*----------------------------------------------- PixelPosition ---*/
void *PixelPosition ( TImageWindow *imgwnd )
{
	return (void *) (((long)imgwnd->image.data)
						+ (long)imgwnd->window.y * (long)imgwnd->image.bpl
						+ (long) iscale ( imgwnd->window.x, imgwnd->image.planes, 8 ) ) ;
}

/*------------------------------ ImageInfo --------*/
void ImageInfo ( char *info, TImage *img )
{
		printf ( "%s$%08lx - %3d x %3d x %d, bpl=%d\n", info,
					img->data,
					img->w, img->h, img->planes, img->bpl ) ;
}

/*------------------------------ WindowInfo --------*/
void WindowInfo ( char *info, TRectangle *wnd )
{
	printf ( "%s%d:%d..+%d:%d\n", info, wnd->x, wnd->y,	wnd->w, wnd->h ) ;
}


/*------------------------------ ImageWindowInfo --------*/
void ImageWindowInfo ( char *info, TImageWindow *imgwnd )
{
	printf ( "%s", info ) ; ImageInfo  ( "img : ", &imgwnd->image ) ;
	printf ( "%s", info ) ; WindowInfo ( "wnd : ", &imgwnd->window ) ;
}

/*------------------------------ BlitWindowInfo --------*/
void BlitWindowInfo ( TBlitWindow *blitwind )
{
	ImageWindowInfo ( "src.", &blitwind->src ) ;
	ImageWindowInfo ( "dst.", &blitwind->dst ) ;
}

/*--------------------------------------------- SetToFullSize ------*/
void SetToFullSize ( TImageWindow *imgwnd, void *data, int w, int h, int planes )
{
	imgwnd->image.data 	 = data ;
	imgwnd->image.w 	 = w ;
	imgwnd->image.h 	 = h ;
	imgwnd->image.planes = planes ;
	imgwnd->image.bpl    = iscale ( w, planes, 8 ) ;

	imgwnd->window.x = imgwnd->window.y = 0 ;
	imgwnd->window.w = w ;
	imgwnd->window.h = h ;
}


# if USEhisto
unsigned long YDhisto[256] ;
unsigned long Yhisto[256] ;
unsigned long Uhisto[256] ;
unsigned long Vhisto[256] ;
unsigned long Rhisto[256] ;
unsigned long Ghisto[256] ;
unsigned long Bhisto[256] ;
unsigned long UDhisto[4][4] ;
unsigned long VDhisto[4][4] ;

ulong SumDelta, NDelta ;
# define PRINTscale	32

# define HISTOformat	" %2x"	
# define OVFLformat		" ++"

/*--------------------------------------------- ShowHisto -----------------*/
void ShowHisto ( char name, unsigned long *h, int maxi )
{
	int i ;
	uword v ;

	printf ( "%c  :", name ) ;
	for ( i = 0 ; i < 16 ; i++ )
		printf ( HISTOformat, i ) ;
	for ( i = 0 ; i <= maxi ; i++ )
	{
		if ( (i & 15 ) == 0 )
			printf ( "\n%02x :", i ) ;
		v = (unsigned) ( *h++ / PRINTscale ) ;
		if ( v < 256 )
			printf ( HISTOformat, v ) ;
		else
			printf ( OVFLformat ) ;
		
	}
	printf ( "\n" ) ;
}
# endif

word GreyTo555Table[256] ;

/*----------------------------------- InitGreyTo555TableWithColors ------*/
void InitGreyTo555TableWithColors ( void )
{
	word *wp ;
	uword grey, g35, g3, r, g, b ;
	
	wp = GreyTo555Table ;
	for ( grey = 0 ; grey < 256 ; grey++ )
	{
		g35 = grey * ( ( 3 * 32 ) - 1 ) / 255 ;
		g3 = g35 % 3 ;
		r = g = b = g35 / 3 ;
		if ( g3 && b < 31)
			b += 1 ;
		if ( g3 & 2 && g < 31 )
			g += 1 ;
		*wp++ = ( r << 11 ) | ( g <<  6 ) | b ;
	}
}

/*----------------------------------- InitGreyTo555Table ------*/
void InitGreyTo555Table ( void )
{
	word *wp ;
	int g, g5 ;
	
	wp = GreyTo555Table ;
	for ( g = 0 ; g < 256 ; g++ )
	{
		g5 = g * 31 / 255 ;
		*wp++ = ( g5 << 11 ) | ( g5 <<  6 ) | g5 ;
	}
}


# define _GrabActive() ( *GRABcntrlReg & GRABactive )

byte GrabShiftEnable = 0 ;	/* used in yc_fast.s	*/
byte GrabShiftDisable = 0 ;

/*----------------------------------------------- SetGrabShiftCtrls ---------*/
void SetGrabShiftCtrls ( void )
{
	if ( GrabMode == GMzoomG8 )
	{
		GrabShiftEnable  = GRABshiftEnable  | GRABzoomXG8 ;
		GrabShiftDisable = GRABshiftDisable | GRABzoomXG8 ;
	}
	else /* GMnormal	*/
	{
		GrabShiftEnable  = GRABshiftEnable ;
		GrabShiftDisable = GRABshiftDisable ;
	}
}


/*----------------------------------------------- SetCntrlReg ---------*/
void SetCntrlReg ( byte val )
{
	if ( GrabMode == GMzoomG8 )
		val |= GRABzoomXG8 ;
	*GRABcntrlReg = (byte)val ;
}

/*----------------------------------------------- GetCntrlReg ---------*/
byte GetCntrlReg ( void )
{
	return *GRABcntrlReg ;
}


# define DELAY 30	/* msec */

/*--------------------------------------------- GrabFieldIntoFifo --------*/
unsigned GrabFieldIntoFifo ( bool wait, TFieldType field )
{
	int n ;
	
	/*... start digitiser ...*/
	
	for ( n = DELAY ; n > 0 ; n-- )								
	{
		switch ( field )
		{
 case FIELDnext :	SetCntrlReg ( GRABstart ) ; 		  	break ;
 case FIELDeven :	SetCntrlReg ( GRABstart | GRABeven ) ;	break ;
 case FIELDodd :	SetCntrlReg ( GRABstart | GRABodd ) ;	break ;
  		}
		
		if ( _GrabActive() )
			break ;
		delay ( 1 ) ;
	}

	SetCntrlReg ( 0 ) ;						/* clear GRABstart	*/

	if ( n > 0 )
	{
		/*... digitising started	...*/
		if ( wait )
		{
			for ( n = DELAY ; ( n > 0 ) && ( _GrabActive() ) ; n-- )
				delay ( 1 ) ;

			if ( n == 0 )
				return 2 ;
			/*... digitising finished, field in FIFO	...*/
		}
		return 0 ;
	}
	else
		return 1 ;
}

/*--------------------------------------------- ResetGrabber -----------*/
void ResetGrabber ( void )
{
	SetCntrlReg ( 0 ) ;
}



typedef void (*SkipProc) ( uword *port, int n ) ;

/*------------------------------------ GrabBlitSetup -----*/
void *GrabBlitSetup ( uword *in, TBlitWindow *blitwind, POINT *zoom,
					  int *skipright, int *incout, POINT *hwz,
					  SkipProc skip )
/* return pointer to output start position	*/
{
	int yi, digdx ;
	
	if ( skip == SkipW )
		SetGrabShiftCtrls();

	SetCntrlReg ( 0 ) ;
	(*skip) ( in, 2 ) ;		/* read dummy pixel		*/	
	SetCntrlReg ( RESETread ) ;
	(*skip) ( in, 2 ) ;		/* read dummy pixel		*/	
	
	/* position digitiser to source start point */
	
	digdx = blitwind->src.image.w / hwz->x ;
	for ( yi = blitwind->src.window.y; yi > 0; yi -= hwz->y )	/* start y	*/
		(*skip) ( in, digdx ) ;
	(*skip) ( in, blitwind->src.window.x / hwz->x ) ;			/* start x	*/

	/* calculate *skipright	= # of digi pixels to skip after each line */
	
	*skipright = blitwind->src.image.w * ( zoom->y / hwz->y )
							- blitwind->src.window.w * zoom->x ;
	if ( hwz->x > 1 )
		*skipright /= hwz->x ;

	*incout = blitwind->dst.image.w - blitwind->dst.window.w ;

	if ( verbose )
	{
		printf ( "\n" ) ;
		BlitWindowInfo ( blitwind ) ;
		printf ( " z=%d:%d,hz=/%d:%d ", zoom->x, zoom->y, hwz->x, hwz->y ) ;
		printf ( " skr=%d inco=%d ", *skipright, *incout ) ;
	}

	return PixelPosition ( &blitwind->dst ) ; 
}


# if HWzoom
# define MAXzoom	8
# define CASExy(x,y)	(((x)*MAXzoom)|(y))

/*----------------------------------------- GetHWzoom ------------------*/
bool GetHWzoom ( POINT *zoom, POINT *hwz )
/* returns TRUE, if data has to be taken form alternative port	*/
{
	hwz->x = 1 ;
	hwz->y = 1 ;	
	switch ( CASExy(zoom->x,zoom->y) )
  	{
case CASExy(2,1):	hwz->x = 2 ; return TRUE ;
case CASExy(4,1):	hwz->x = 2 ; return TRUE ;	/* ???? x=4 ??? */
case CASExy(2,2):	hwz->x = 2 ; hwz->y = 2 ;	return TRUE ;
case CASExy(4,2):
case CASExy(8,2):	hwz->x = 4 ; hwz->y = 2 ;	return TRUE ;
default :			return FALSE ;
	}
}

/*--------------------------------------------- Blit555Window -----------*/
void Blit555Window ( TBlitWindow *blitwind, POINT *zoom )
/* DigiFormat :		NTC	555						*/
/* PictureFormat :	PITcolor,	PIOpacked,	555	*/
{
	int y, skipright, incout ;
	POINT hwz ;
	uword *in, *out, softzx ;

	in = GetHWzoom ( zoom, &hwz ) ? INport555zx2 : INport555 ;

	softzx = zoom->x / hwz.x ;

	out = GrabBlitSetup ( in, blitwind, zoom, &skipright, &incout, &hwz, Skip ) ;

	for ( y = 0 ; y < blitwind->dst.window.h ; y++ )
	{
		out = Move555To555Color ( out, in, blitwind->dst.window.w, softzx ) + incout ;
		Skip ( in, skipright ) ;
	}
}
# else
void Blit555Window ( TBlitWindow *blitwind, POINT *zoom )
	{	printf ( "* fast blit only with HW zoom !\n" ) ;	}
# endif



/*--------------------------------------------- BlitFyc224Window -----------*/
void BlitFyc224Window ( TBlitWindow *blitwind, POINT *zoom )
/* DigiFormat :		YC 411						*/
/* PictureFormat :	PITyc,	PIOmix16,	224		*/
{
	int y, skipright, incout ;
	POINT hwz ;
	uword *in, *out, softzx ;

	in = GetHWzoom ( zoom, &hwz ) ? INportYCzx2 : INportYC ;

	softzx = zoom->x / hwz.x ;

	out = GrabBlitSetup ( in, blitwind, zoom, &skipright, &incout, &hwz, Skip ) ;

	for ( y = 0 ; y < blitwind->dst.window.h ; y++ )
	{
		out = MoveYCToFyc224 ( out, in, blitwind->dst.window.w, softzx ) ;
		((long)out) += incout ;	/* 1 byte / pixel	*/
		Skip ( in, skipright ) ;
	}
}

/*--------------------------------------------- BlitF332Window -----------*/
void BlitF332Window ( TBlitWindow *blitwind, POINT *zoom )
/* DigiFormat :		NTC	555						*/
/* PictureFormat :	PITcolor,	PIOmix16,	332	*/
{
	int y, skipright, incout ;
	POINT hwz ;
	uword *in, *out, softzx ;

	in = GetHWzoom ( zoom, &hwz ) ? INport555zx2 : INport555 ;

	softzx = zoom->x / hwz.x ;

	out = GrabBlitSetup ( in, blitwind, zoom, &skipright, &incout, &hwz, Skip ) ;

	for ( y = 0 ; y < blitwind->dst.window.h ; y++ )
	{
		out = Move555ToF332Color ( out, in, blitwind->dst.window.w, softzx ) ;
		((long)out) += incout ;	/* 1 byte / pixel	*/
		Skip ( in, skipright ) ;
	}
}

/*--------------------------------------------- BlitF8GreyWindow -----------*/
void BlitF8GreyWindow ( TBlitWindow *blitwind, POINT *zoom )
/* DigiFormat :		YC 411						*/
/* PictureFormat :	PITgrey,	PIOmix16,	8	*/
{
	int y, skipright, incout ;
	POINT hwz ;
	uword *in, *out, softzx ;

	in = GetHWzoom ( zoom, &hwz ) ? INportYCzx2 : INportYC ;

	softzx = zoom->x / hwz.x ;

	out = GrabBlitSetup ( in, blitwind, zoom, &skipright, &incout, &hwz, Skip ) ;
	
	for ( y = 0 ; y < blitwind->dst.window.h ; y++ )
	{
		out = MoveYCToF8Grey ( out, in, blitwind->dst.window.w, softzx ) ;
		((long)out) += incout ;	/* 1 byte / pixel	*/
		Skip ( in, skipright ) ;
	}
}

/*--------------------------------------------- BlitF7GreyWindow -----------*/
void BlitF7GreyWindow ( TBlitWindow *blitwind, POINT *zoom )
/* DigiFormat :		YC 411									*/
/* PictureFormat :	PITgrey,	PIOmix16,	7, SW-packing	*/
/* map     0,   2,..,126 	->    64,  65,..,195	*/
/*		0x00,0x02,..,0xfe	->	0x40,0x41,..,0xbf	*/
{
	int y, skipright, incout ;
	POINT hwz ;
	uword *in, *out, softzx ;

	in = GetHWzoom ( zoom, &hwz ) ? INportYCzx2 : INportYC ;

	softzx = zoom->x / hwz.x ;

	out = GrabBlitSetup ( in, blitwind, zoom, &skipright, &incout, &hwz, Skip ) ;
	
	for ( y = 0 ; y < blitwind->dst.window.h ; y++ )
	{
		out = MoveYCToF7Grey ( out, in, blitwind->dst.window.w, softzx ) ;
		((long)out) += incout ;	/* 1 byte / pixel	*/
		Skip ( in, skipright ) ;
	}
}

# if 0
/*--------------------------------------------- BlitP8ColorWindowZX1 -----------*/
void BlitP8ColorWindowZX1 ( TBlitWindow *blitwind, POINT *zoom )
# else
/*--------------------------------------------- BlitP8ColorWindow -----------*/
void BlitP8ColorWindow ( TBlitWindow *blitwind, POINT *zoom )
# endif
/* DigiFormat :		mix 16 bytes									*/
/* PictureFormat :	PITcolor,	PIOmix16,	8, 		HW byte packing	*/
/*					PITgrey,	PIOmix16,	7/8, 	HW byte packing	*/
/*					byte	0			1					15
	lca input ( Y ) :	y0.7..y0.0 | y1.7..y1.0 | .. | y15.7..y15.0
					byte   0	1	   2	3				15
	lca output :		y0.0..y15.0 | y0.1..y15.1
*/
{
	int y, x16, skipright, incout ;
	POINT hwz ;
	uword *in, *out/*, softzx */ ;
	void *old_stack;

	GetHWzoom ( zoom, &hwz ) ;
	in = INport332 ;
/*
	softzx = zoom->x / hwz.x ;
*/
	old_stack = Super((void *)1L) ? NULL : (void *)Super((void *)0L) ;

	out = GrabBlitSetup ( in, blitwind, zoom, &skipright, &incout, &hwz, SkipW ) ;

	x16 = blitwind->dst.window.w/16 ;

	SkipW ( in, 8+1 ) ;	/* fill register file with first data	*/

	skipright -= 2 ;

	for ( y = 0 ; y < blitwind->dst.window.h ; y++ )
	{
		out = MoveByteRegisterFiles ( out, in, x16 ) ;
		((long)out) += incout ;	/* 1 byte / pixel	*/
		SkipW ( in, skipright ) ;
	}
	if ( old_stack != NULL )
		Super ( (void *) old_stack );
}

# if 0
/*--------------------------------------------- BlitP8ColorWindow -----------*/
void BlitP8ColorWindow ( TBlitWindow *blitwind, POINT *zoom )
/* DigiFormat :		mix 16 bytes									*/
/* PictureFormat :	PITcolor,	PIOmix16,	8, 		HW byte packing	*/
/*					PITgrey,	PIOmix16,	7/8, 	HW byte packing	*/
/*					byte	0			1					15
	lca input ( Y ) :	y0.7..y0.0 | y1.7..y1.0 | .. | y15.7..y15.0
					byte   0	1	   2	3				15
	lca output :		y0.0..y15.0 | y0.1..y15.1
*/
{
	int y, x16, skipright, incout ;
	POINT hwz ;
	uword *in, *out/*, softzx */ ;
	void *old_stack;

	if ( zoom->x <= 1 )
	{
		BlitP8ColorWindowZX1 ( blitwind, zoom ) ;
		return ;
	}

	hwz.x = hwz.y = 1 ;
	in = INport332 ;

	old_stack = Super((void *)1L) ? NULL : (void *)Super((void *)0L) ;

	out = GrabBlitSetup ( in, blitwind, zoom, &skipright, &incout, &hwz, SkipW ) ;
	x16 = blitwind->dst.window.w/16 ;

	SkipW ( in, 8+1 ) ;	/* fill register file with first data	*/

	skipright -= 2 ;

	for ( y = 0 ; y < blitwind->dst.window.h ; y++ )
	{
		out = MoveZXByteRegisterFiles ( out, in, x16, zoom->x ) ;
		((long)out) += incout ;	/* 1 byte / pixel	*/
		SkipW ( in, skipright ) ;
	}
	if ( old_stack != NULL )
		Super ( (void *) old_stack );
}
# endif

/*--------------------------------------------- BlitP8GreyWindow -----------*/
void BlitP8GreyWindow ( TBlitWindow *blitwind, POINT *zoom )
/* DigiFormat :		mix 16 words									*/
/* PictureFormat :	PITcolor,	PIOmix16,	8, 		HW word packing	*/
/*					PITgrey,	PIOmix16,	7/8, 	HW word packing	*/
/*					byte	0			1					15
	lca input ( Y ) :	y0.7..y0.0 | y1.7..y1.0 | .. | y15.7..y15.0
					byte   0	1	   2	3				15
	lca output :		y0.0..y15.0 | y0.1..y15.1
*/
{
	int y, x16, skipright, incout ;
	POINT hwz ;
	uword *in, *out, softzx ;
	void *old_stack;

	in = GetHWzoom ( zoom, &hwz ) ? INportYCzx2 : INportYC ;

	softzx = zoom->x / hwz.x ;

/* ????????? */
	softzx = softzx ;
/* ????
	in = INportYCzx2 ;
???*/
	old_stack = Super((void *)1L) ? NULL : (void *)Super((void *)0L) ;

	out = GrabBlitSetup ( in, blitwind, zoom, &skipright, &incout, &hwz, SkipW ) ;

	x16 = blitwind->dst.window.w/16 ;

	SkipW ( in, 16 ) ;	/* fill register file with first data	*/
	skipright-=2;
	for ( y = 0 ; y < blitwind->dst.window.h ; y++ )
	{
		out = MoveWordRegisterFiles ( out, in, x16 ) ;
		((long)out) += incout ;	/* 1 byte / pixel	*/
		SkipW ( in, skipright ) ;
	}
	if ( old_stack != NULL )
		Super ( (void *) old_stack );
}
	
# if USEhisto
/*--------------------------------------------- Blit555WindowTest -----------*/
void Blit555WindowTest ( TBlitWindow *blitwind, POINT *zoom )
/* DigiFormat :		NTC	555									*/
/* PictureFormat :	PITcolor,	PIOpacked,	555	- test mode */
{
	int y, skipright, incout ;
	uword *in, *out ;
	int i ;

	if ( ! test )
	{
		Blit555Window ( blitwind, zoom ) ;
		return ;
	}
	else
	{
		for ( i = 0 ; i < 256 ; i++ )
			Rhisto[i] = Ghisto[i] = Bhisto[i] = 0 ;

# if HWzoom
		in = zoom->x <= 1 ? INport555 : INport555zx2 ;
# else
		in = INport555 ;
# endif

/* ???????????? hwz !!! */
		out = GrabBlitSetup ( in, blitwind, zoom, &skipright, &incout, &Zoom1x1, Skip ) ;

		for ( y = 0 ; y < blitwind->dst.window.h ; y++ )
		{
			uword rgb ;
			int x ;
		
			for ( x = blitwind->dst.window.w ; x > 0 ; x-- )
			{
				*out++ = rgb = *in ;
				Rhisto[(rgb>>11)&31]++ ;	/*  15..11				*/
				Ghisto[(rgb>> 6)&31]++ ;	/*		  10..6x		*/
				Bhisto[(rgb    )&31]++ ;	/*              4..0 	*/
# if ! HWzoom
				if ( zoom->x > 1 && *in )
					/* discard pixel */ ;
# endif
			}
			Skip ( in, skipright ) ;
		}
	}
}
# else ! USEhisto
/*--------------------------------------------- Blit555WindowTest -----------*/
void Blit555WindowTest ( TBlitWindow *blitwind, POINT *zoom )
/* DigiFormat :		NTC	555									*/
/* PictureFormat :	PITcolor,	PIOpacked,	555	- test mode */
{
	int y, skipright, incout ;
	uword *in, *out ;

# if HWzoom
	in = zoom->x <= 1 ? INport555 : INport555zx2 ;
# else
	in = INport555 ;
# endif

/* ???????????? hwz !!! */
	out = GrabBlitSetup ( in, blitwind, zoom, &skipright, &incout, &Zoom1x1, Skip ) ;

	for ( y = 0 ; y < blitwind->dst.window.h ; y++ )
	{
# if HWzoom
		out = Move555To555Color ( out, in, blitwind->dst.window.w, 1 ) + incout ;
# else
		out = Move555To555Color ( out, in, blitwind->dst.window.w, zoom->x ) + incout ;
# endif
		Skip ( in, skipright ) ;
	}
}
# endif USEhisto


extern uword *ntc_table ;

YUVtoNTCproc _Cyuv_to_ntc = Cyuv_to_ntc ;
bool ClipConversion    	 = TRUE ;
bool GrabBeforeDisplay 	 = TRUE ;

# define CHKrgbRange	1

# if CHKrgbRange
long RgbUnder[3], RgbOver[3] ;
# define _ChkRange(c,i) 	if ( c < 0 ) RgbUnder[i]++ ; else if ( c >= 256 ) RgbOver[i]++
# define _ChkRangeClip(c,i) if ( c < 0 ) { c = 0 ; RgbUnder[i]++ ; } else if ( c >= 256 ) { c = 255 ; RgbOver[i]++ ; }
# endif

/*----------------------------------- YCto555 ----------------*/
uword YCto555 ( int y, int u, int v )
{
# if CHKrgbRange
	int r, g, b ;
	
	r = y + v ;
	g = y - ((v>>1)&0xfff8) ;
	b = y + u ;
	if ( ClipConversion )
	{
		_ChkRangeClip(r,0) ;	
		_ChkRangeClip(g,1) ;
		_ChkRangeClip(b,2) ;
	}
	else
	{
		_ChkRange(r,0) ;	
		_ChkRange(g,1) ;
		_ChkRange(b,2) ;
	}
	
	return	  (( r & 0xf8) << 8 )
			| (( g & 0xf8) << 3 )
			| (( b & 0xf8) >> 3 ) ;
# else
	return	  ((( y + v      ) & 0xf8) << 8 )
			| ((( y - (v>>1) ) & 0xf8) << 3 )
			| ((( y + u 	 ) & 0xf8) >> 3 ) ;
# endif
}

/* format : 55o5	*/
/*	r  r  r  r  r  g  g  g . g  g  o  b  b  b  b  b  */
/*	15 14 13 12 11 10 9  8 . 7  6  5  4  3  2  1  0	*/

/*----------------------------- Blit555HWSimulation ----------------*/
uword *Blit555HWSimulation ( uword *in, uword *out, int nx, int zoomx )
{
	int xi ;
	uword yc ;
	char Un, Vn ;
	int Us, Vs ;

	Vs = Us = 0 ;
	for ( xi = nx ; xi > 0 ; xi-- )	/* x x x x uv3 uv2 uv1 uv0 | y7 .. y1 x */
	{
									/*	 f  e  d  c  b  a  9  8   7 .. 1 0		*/
	/* 0 */	yc = *in ;					/*   0, 0, 0, 0,u7,u6,v7,v6 , y7..y1,0		*/
			Un = ( yc >> 4 ) & 0xc0 ;	/* start fetching new color values	*/ 
			Vn = ( yc >> 2 ) & 0xc0 ;
			*out++ = YCto555 ( yc & 0xf8, Us, Vs ) ;

	/* 1 */	yc = *in ;					/*   0, 0, 0, 0,u5,u4,v5,v4 , y7..y1,0		*/
			Un |= ( yc >> 6 ) & 0x30 ;
			Vn |= ( yc >> 4 ) & 0x30 ;
			if ( zoomx == 1 )
				*out++ = YCto555 ( yc & 0xf8, Us, Vs ) ;
					
	/* 2 */	yc = *in ;					/*   0, 0, 0, 0,u3,u2,v3,v2 , y7..y1,0		*/
			Un |= ( yc >> 8 ) & 0x08 ;
			Vn |= ( yc >> 6 ) & 0x08 ;

			if ( DmsdParameterBlock.dmsd != 7191 ) /* from now on, use new color values	*/
			{
				Us = (signed char)Un ;
				Vs = (signed char)Vn ;
			}
			else
			{
				Us = (unsigned char)Un - 128 ;
				Vs = (unsigned char)Vn - 128 ;
			}

			*out++ = YCto555 ( yc & 0xf8, Us, Vs ) ;
				
	/* 3 */	yc = *in ;					/*   0, 0, 0, 0,u1,u0,v1,v0 , y7..y1,0		*/
			if ( zoomx == 1 )
				*out++ = YCto555 ( yc & 0xf8, Us, Vs ) ;
	}
	return out ;
}

/*----------------------------------- Blit555SWQuad ----------------*/
uword *Blit555SWQuad ( uword *in, uword *out, unsigned zoomx )
{
	int i ;
	uword yc, y4[4], *yp, V, U ;
									/* f e d c  b   a   9   8  | 7      1 0 */  
	V = U = 0 ;
	for ( i = 0, yp = y4; i < 4; i++ )
	{
		yc    = *in ;
		*yp++ = (byte)yc ;
# if USEhisto
		VDhisto[i][(yc>> 8)&3]++ ;
		UDhisto[i][(yc>>10)&3]++ ;
		Yhisto[yc&0xff]++ ;
# endif
		V   = ( V << 2 ) | ( ( yc >>  8 ) & 3 ) ;
		U   = ( U << 2 ) | ( ( yc >> 10 ) & 3 ) ;
	}
# if USEhisto
	Uhisto[U]++ ;
	Vhisto[V]++ ;
# endif

/*	V = U = 0x80 ;
*/
	if ( DmsdParameterBlock.dmsd != 7191 ) /* from now on, use new color values	*/
	{
		U ^= 0x80 ;
		V ^= 0x80 ;
	}

	if ( zoomx < 2 )	/* zoomx == 1 */
	{
		for ( i = 0, yp = y4; i < 4; i++ )
# if 0
			*out++ =  yuv_to_ntc ( *yp++, V, U ) ;
# elif 1
			*out++ =  (*_Cyuv_to_ntc) ( *yp++, V, U ) ;
# else
			*out++ =  ntc_table [  ( ( *yp++ & 0xfc ) << 8 )
								 | ( ( V & 0xf8    ) << 2 )
								 | (   U             >> 3 ) ] ;
# endif
	}
	else	/* zoomx == 2 */
	{
		*out++ =  (*_Cyuv_to_ntc) ( y4[0], V, U ) ;
		*out++ =  (*_Cyuv_to_ntc) ( y4[2], V, U ) ;
	}
	return out ;
}


/*--------------------------------------------- Blit555HWSimWindow -----------*/
void Blit555HWSimWindow ( TBlitWindow *blitwind, POINT *zoom )
/* DigiFormat :		YC 411						*/
/* PictureFormat :	PITcolor,	PIOpacked,	555	- hw csc simulation */
{
	int nx, y, skipright, incout ;
	uword *in, *out ;

	CheckCalcCSCtables ( NULL ) ;

	in = INportYC ;

# if USEhisto
	{
		int i, j ;
		for ( i = 0 ; i < 3 ; i++ )
			for ( j = 0 ; j < 3 ; j++ )
				UDhisto[j][i] =	VDhisto[j][i] = 0 ;
		for ( i = 0 ; i < 256 ; i++ )
			Yhisto[i] = Uhisto[i] = Vhisto[i] = 0 ;
	}
# endif

	out = GrabBlitSetup ( in, blitwind, zoom, &skipright, &incout, &Zoom1x1, Skip ) ;

	nx = blitwind->dst.window.w/4*zoom->x ;

# if CHKrgbRange
	RgbOver[0] = RgbUnder[0] = RgbOver[1] = RgbUnder[1] = RgbOver[2] = RgbUnder[2] = 0 ;
# endif
	for ( y = 0 ; y < blitwind->dst.window.h ; y++ )
	{
		out = Blit555HWSimulation ( in, out, nx, zoom->x ) + incout ;
		Skip ( in, skipright ) ;
	}
}

/*--------------------------------------------- Blit555SWWindow -----------*/
void Blit555SWWindow ( TBlitWindow *blitwind, POINT *zoom )
/* DigiFormat :		YC 411									*/
/* PictureFormat :	PITcolor,	PIOpacked,	555	- sw csc	*/
{
	int xi, nx, y, skipright, incout ;
	uword *in, *out ;

	CheckCalcCSCtables ( NULL ) ;

	in = INportYC ;

# if USEhisto
	{
		int i, j ;
		for ( i = 0 ; i < 3 ; i++ )
			for ( j = 0 ; j < 3 ; j++ )
				UDhisto[j][i] =	VDhisto[j][i] = 0 ;
		for ( i = 0 ; i < 256 ; i++ )
			Yhisto[i] = Uhisto[i] = Vhisto[i] = 0 ;
	}
# endif

	out = GrabBlitSetup ( in, blitwind, zoom, &skipright, &incout, &Zoom1x1, Skip ) ;
	nx = blitwind->dst.window.w/4*zoom->x ;

	for ( y = 0 ; y < blitwind->dst.window.h ; y++ )
	{
		for ( xi = nx ; xi > 0 ; xi-- )	/* x x x x uv3 uv2 uv1 uv0 | y7 .. y1 x */
			out = Blit555SWQuad ( in, out, zoom->x ) + incout ;
		Skip ( in, skipright ) ;
	}
}


/*....................... Y C 4:1:1 ..................................*/

/*----------------------------------- BlitYC411Quad ----------------*/
byte *BlitYC411Quad ( byte *out, uword *in )
/* 	sequence : 	Y0..3,U,V ( 6 bytes / 4 pixels = 12 bpp	*/
{
	int i ;
	uword yc, V, U ;

	V = U = 0 ;
	for ( i = 0; i < 4; i++ )
	{
		yc     = *in ;
		*out++ = (byte)yc ;
		V   = ( V << 2 ) | ( ( yc >>  8 ) & 3 ) ;
		U   = ( U << 2 ) | ( ( yc >> 10 ) & 3 ) ;
	}

	if ( DmsdParameterBlock.dmsd != 7191 ) /* from now on, use new color values	*/
	{
		U ^= 0x80 ;
		V ^= 0x80 ;
	}

	*out++ = U ;
	*out++ = V ;
	return out ;
}

/*---------------------------------------- BlitYC411toRGBWindow ----*/
void BlitYC411toRGBWindow ( TBlitWindow *blitwind, POINT *zoom )
/* DigiFormat :		YC 411						*/
/* PictureFormat :	PITcolor,	PIOpacked,	888 */
/* blit YC411 -> RGB window	*/
{
	int xi, nx, y, skipright, incout ;
	uword *in ;
	byte  *out ;
	
	in = INportYC ;

	out = GrabBlitSetup ( in, blitwind, zoom, &skipright, &incout, &Zoom1x1, Skip ) ;
	incout = blitwind->dst.image.w * 3 			/* image width	*/
			 - blitwind->dst.window.w * 6 / 4;	/* yc411 - width	*/

	nx  = blitwind->dst.window.w / 4 ;

	for ( y = 0 ; y < blitwind->dst.window.h ; y++ )
	{
		for ( xi = nx ; xi > 0 ; xi-- )
			out = BlitYC411Quad ( out, in ) ;
		out += incout ;
		Skip ( in, skipright ) ;
	}
}

/*---------------------------------------- ConvertYC411ImageToRGB ----*/
void ConvertYC411ImageToRGB ( TBlitWindow *blitwind )
/* convert YC411 -> RGB image on place	*/
{
	int xi, nx, i, y, bplyc, bplrgb, incin, incout ;
	byte *in ;
	byte *out ;
	int U, V ;

	CheckCalcCSCtables ( NULL ) ;
	
	bplrgb = blitwind->dst.image.w * 3 ;
	bplyc  = blitwind->dst.image.w * 6 / 4 ;
	in  = ((byte *)blitwind->dst.image.data) + bplyc ;	/* end of yc line	*/
	out = ((byte *)blitwind->dst.image.data) + bplrgb ;	/* end of rgb line	*/

	nx  = blitwind->dst.window.w / 4 ;
								/* step to the end of the next 	*/
	incin  = bplrgb + bplyc ;	/*  .. yc line	*/
	incout = 2 * bplrgb ;		/*	.. rgb line	*/
	
	for ( y = 0 ; y < blitwind->dst.window.h ; y++ )
	{
		for ( xi = nx ; xi > 0 ; xi-- )
		{
			V = *--in ;
			U = *--in ;
			for ( i = 4; i > 0 ; i-- )
				out = yuv_to_bgr ( out, *--in, V, U ) ;
		}
		in  += incin ;
		out += incout ;
	}
}



/*....................... R G B ..................................*/

# define TEST 0

# if TEST == 1
extern int PictureNumber ;
# endif

/*----------------------------------- BlitRGBQuad ----------------*/
byte *BlitRGBQuad ( byte *out, uword *in, unsigned zoomx )
/* 4 * YC411 -> 4 * RGB	*/
{
	int i ;
	uword yc, y4[4], *yp, V, U ;
# if TEST == 3
	uword ud, vd ;
# endif
	
	V = U = 0 ;
	for ( i = 0, yp = y4; i < 4; i++ )
	{
		yc    = *in ;
		*yp++ = (byte)yc ;
# if TEST == 3
		ud = ( yc >> 10 ) & 3 ;
		vd = ( yc >>  8 ) & 3 ;
		V   = ( V << 2 ) | vd ;
		U   = ( U << 2 ) | ud ;
		UDhisto[i][ud]++ ;
		VDhisto[i][vd]++ ;
# else
		V   = ( V << 2 ) | ( ( yc >>  8 ) & 3 ) ;
		U   = ( U << 2 ) | ( ( yc >> 10 ) & 3 ) ;
# endif
	}

# if TEST == 3
	Uhisto[U]++ ;
	Vhisto[V]++ ;
# endif

	if ( DmsdParameterBlock.dmsd != 7191 ) /* from now on, use new color values	*/
	{
		U ^= 0x80 ;
		V ^= 0x80 ;
	}

	if ( zoomx < 2 )	/* zoomx == 1 */
	{
		for ( i = 0, yp = y4; i < 4; i++ )
# if TEST == 1
		{
			switch ( PictureNumber )
			{
	default :	out = yuv_to_rgb ( out, *yp++, V, U ) ;
				break ;
	case 1 :	*out++ = *yp ;		/*	Y	*/
				*out++ = *yp ;
				*out++ = *yp++ ;
				break ;
	case 2 :	*out++ = U ;
				*out++ = U ;
				*out++ = U ;
				break ;
	case 3 :	*out++ = V ;
				*out++ = V ;
				*out++ = V ;
				break ;
			}
		}
# elif TEST == 3
		{
			Yhisto[*yp]++ ;
			out = yuv_to_rgb ( out, *yp++, V, U ) ;
		}
# else
			out = yuv_to_rgb ( out, *yp++, V, U ) ;
# endif
	}
	else	/* zoomx == 2 */
	{
		out = yuv_to_rgb ( out, y4[0], V, U ) ;
		out = yuv_to_rgb ( out, y4[2], V, U ) ;
	}
	return out ;
}





/*--------------------------------------------- BlitRGBWindow -----------*/
void BlitRGBWindow ( TBlitWindow *blitwind, POINT *zoom )
/* DigiFormat :		YC 411											*/
/* PictureFormat :	PITcolor,	PIOpacked,	555	- sw csc simulation */
{
	int xi, nx, y, skipright, incout ;
	uword *in ;
	byte  *out ;
# if TEST == 4
	int i ;
	uword yc ;
# endif
			

# if TEST == 3
	{
		int i, j ;
		for ( i = 0 ; i < 3 ; i++ )
			for ( j = 0 ; j < 3 ; j++ )
				UDhisto[j][i] =	VDhisto[j][i] = 0 ;
		for ( i = 0 ; i < 256 ; i++ )
			Yhisto[i] = Uhisto[i] = Vhisto[i] = 0 ;
	}
# endif

	CheckCalcCSCtables ( NULL ) ;
	
	in = INportYC ;

	out = GrabBlitSetup ( in, blitwind, zoom, &skipright, &incout, &Zoom1x1, Skip ) ;
# if TEST == 2
	if ( PictureNumber )
		Skip ( in, PictureNumber ) ;		/* read dummy pixels	*/	
	if ( skipright != 0 )
		printf ( "\033H * skipright = %d\n", skipright ) ;
# endif
	nx  = blitwind->dst.window.w / 4 * zoom->x ;
	incout *= 3 ;


	for ( y = 0 ; y < blitwind->dst.window.h ; y++ )
	{
		for ( xi = nx ; xi > 0 ; xi-- )
# if TEST == 4
		{
			for ( i = 4 ; i > 0 ; i-- )
			{
				yc = *in ;
				*out++ = (byte)yc ;
				*out++ = (byte)yc ;
				*out++ = (byte)yc ;
			}
		}
# else
			out = BlitRGBQuad ( out, in, zoom->x ) ;
# endif
		out += incout ;
		Skip ( in, skipright ) ;
	}
	
# if TEST == 3
	printf ( "\033H" ) ;
	ShowHisto ( 'Y', Yhisto, 255 ) ;
	getch();
	printf ( "\033H" ) ;
	ShowHisto ( 'U', Uhisto, 255 ) ;
	ShowHisto ( '0', UDhisto[0], 3 ) ;
	ShowHisto ( '1', UDhisto[1], 3 ) ;
	ShowHisto ( '2', UDhisto[2], 3 ) ;
	ShowHisto ( '3', UDhisto[3], 3 ) ;
	getch();
	printf ( "\033H" ) ;
	ShowHisto ( 'V', Vhisto, 255 ) ;
	ShowHisto ( '0', VDhisto[0], 3 ) ;
	ShowHisto ( '1', VDhisto[1], 3 ) ;
	ShowHisto ( '2', VDhisto[2], 3 ) ;
	ShowHisto ( '3', VDhisto[3], 3 ) ;
	getch();
# endif
	
}


/*--------------------------------------------- BlitGreyWindow -----------*/
void BlitGreyWindow ( TBlitWindow *blitwind, POINT *zoom )
/* DigiFormat :		YC 411						*/
/* PictureFormat :	PITgrey,	PIOpacked,	555	*/
{
	int y, skipright, incout ;
	uword *in, *out ;
# if USEhisto
	int i ;
# if USEgrey
	unsigned char *gout ;

	gout = GreyBuffer ;
# endif
	
	for ( i = 0 ; i < 256 ; i++ )
		Yhisto[i] = YDhisto[i] = 0 ;
	SumDelta = NDelta = 0 ;
# endif

	in = INportYC ;

	out = GrabBlitSetup ( in, blitwind, zoom, &skipright, &incout, &Zoom1x1, Skip ) ;
	for ( y = 0 ; y < blitwind->dst.window.h ; y++ )
	{
# if 1
# if USEhisto
		{
			byte last, current, delta ;
			int x ;
			
			last = current = (byte)*in ;	/* first pixel in line */
			*out++ = GreyTo555Table[current] ;
# if USEgrey
			*gout++ = current ;
# endif
			Yhisto[ current ] ++ ;
			
			for ( x = blitwind->dst.window.w-1 ; x > 0 ; x-- )
			{
				current = (byte)*in ;
				delta = current > last ? current - last : last - current ;
				YDhisto[ delta ] ++ ;
				NDelta++ ;
				SumDelta += delta ;
				Yhisto[ current ]++ ;
				*out++ = GreyTo555Table[current] ;
# if USEgrey
				*gout++ = current ;
# endif
				last = current ;
			}
		}
# else
		for ( x = blitwind->dst.window.w ; x > 0 ; x-- )
			*out++ = GreyTo555Table[(byte)*in] ;
# endif
		out += incout ;
# else
		out = MoveYCTo555Grey ( out, in, blitwind->dst.window.w, zoom->x ) + incout ;
# endif
		Skip ( in, skipright ) ;
	}
}

/*--------------------------------------------- DigitiseFrame -----------*/
void DigitiseFrame ( TBlitWindow *blitwind, POINT *zoom, bool wait )
{
	int result ;

	if ( ( result = GrabFieldIntoFifo ( wait, FIELDnext ) ) == 0 )
	{
		Blit555Window ( blitwind, zoom ) ;
	}
	else
	{
		printf ( "* error : %d\n", result ) ;
		return ;
	}
}
