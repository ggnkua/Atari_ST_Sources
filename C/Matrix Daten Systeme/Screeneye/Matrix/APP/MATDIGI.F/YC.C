# define TEST 0

# include <stdio.h>
# if TEST
# include <ext.h>
# endif

# include <global.h>

# include "yc.h"
# include "yc_fast.h"


uword ntc_table[0x10000L] ;

local long cr_r[255] ;
local long cr_g[255], cb_g[255] ;
local long cb_b[255] ;

bool  CSCtablesOk = FALSE ;

int	DefaultYCcoeff[] = DEFAULTycCoeff ;


# define MAXrgb	255
# define chk_rgb(rgb) rgb < 0 ? 0 : ( rgb > MAXrgb ? MAXrgb : (byte)rgb )

# define Step(bits)	(1<<(8-bits))

/*	y  y  y  y  y  y .cr cr | cr cr cr.cb cb cb cb cb */
/*	15 14 13 12 11 10 9  8  | 7  6  5  4  3  2  1  0	 */
# define Ystep	Step(6)
# define Crstep	Step(5)
# define Cbstep	Step(5)

# define MAXintLevel	255

/*----------------------------------------------- col_ntc ------*/
uword col_ntc ( int r, int g, int b )
/* format : 55o5	*/
/*	r  r  r  r  r  g  g  g  g  g  o  b  b  b  b  b  */
/*	15 14 13 12 11 10 9  8  7  6  5  4  3  2  1  0	*/
{
	return ( ( r * 31 / MAXintLevel ) << 11 )
		 | ( ( g * 31 / MAXintLevel ) <<  6 )
		 | ( ( b * 31 / MAXintLevel )       ) ;
}

# define _add32_noclip8(a8,b32) (int)(a8+(((long)b32)>>8))

/*----------------------------------------------- CyuvToNtcNoClip ------*/
uword CyuvToNtcNoClip ( uword y, uword cr, uword cb )
{
	int r, g, b ;

	r = _add32_noclip8 ( y, cr_r[cr] 				) ;
	g = _add32_noclip8 ( y, cr_g[cr] + cb_g[cb]	) ;
	b = _add32_noclip8 ( y, cb_b[cb]				) ;
	return col_ntc ( r, g, b ) ;
}



/*----------------------------------------------- yuv_to_bgr ------*/
byte *yuv_to_bgr ( byte *out, uword y, uword cr, uword cb )
{
	*--out = add32_clip8 ( y, cb_b[cb]				) ;	/* B	*/
	*--out = add32_clip8 ( y, cr_g[cr] + cb_g[cb]	) ;	/* G	*/
	*--out = add32_clip8 ( y, cr_r[cr] 				) ;	/* R	*/
	return out ;
}

/*----------------------------------------------- yuv_to_rgb ------*/
byte *yuv_to_rgb ( byte *out, uword y, uword cr, uword cb )
{
	*out++ = add32_clip8 ( y, cr_r[cr] 				) ;	/* R	*/
	*out++ = add32_clip8 ( y, cr_g[cr] + cb_g[cb]	) ;	/* G	*/
	*out++ = add32_clip8 ( y, cb_b[cb]				) ;	/* B	*/
	return out ;
}


/*----------------------------------------------- Cyuv_to_ntc ------*/
uword Cyuv_to_ntc ( uword y, uword cr, uword cb )
{
	int r, g, b ;

	r = add32_clip8 ( y, cr_r[cr] 				) ;
	g = add32_clip8 ( y, cr_g[cr] + cb_g[cb]	) ;
	b = add32_clip8 ( y, cb_b[cb]				) ;
	return col_ntc ( r, g, b ) ;
}

/*--------------------------------------------------- CalcNTCtable ---*/
void CalcNTCtable ( void )
{
	int	 cb, cr, y ;
	int r,g,b ;
	uword *tab ;
	
# if TEST
	printf ( "CalcNTCtable -> $%p\n", ntc_table ) ;
# endif

	tab = ntc_table ;
														/*		  844	  655	*/
	for ( y = 0 ; y < 256 ; y += Ystep )				/*	Y  : 15..8 / 15..10	*/
	{
		for ( cr = 0 ; cr < 256 ; cr += Crstep )		/*	Cr :  7..4 /  9.. 5	*/
			for ( cb = 0 ; cb < 256 ; cb += Cbstep )	/*	Cb :  3..0 /  4.. 0	*/
			{
				r = add32_clip8 ( y, cr_r[cr] 				) ;
				g = add32_clip8 ( y, cr_g[cr] + cb_g[cb]	) ;
				b = add32_clip8 ( y, cb_b[cb]				) ;
				*tab++ = col_ntc ( r, g, b ) ;
			}
	}

# if TEST
		printf ( "name       y   cr  cb   ntc\n" ) ;
		prycntc ( 235, 128, 128, "white" ) ;
		prycntc ( 16,  128, 128, "black" ) ;
		prycntc ( 82,  240,  90, "red" ) ;
		prycntc ( 145,  34,  54, "green" ) ;
		prycntc ( 41,  110, 240, "blue" ) ;
		printf ( "- Any key !\n" ) ;
		getch();
# endif		
}

/*----------------------------------------------------- CalcYCmulTab ---*/
void CalcYCmulTab ( int *coeff )
{
	int n ;

	if ( coeff == NULL )
		coeff = DefaultYCcoeff ;
# if TEST
	printf ( "CalcYCmulTab :\n" ) ;
	for ( n = Kcrr ; n <= Kcbb; n++ )
		printf ( " %d", coeff[n] ) ;
	printf ( "\n" ) ;
# endif

	for ( n = 0 ; n < 256; n++ )
	{
		cr_r[n] = (long)coeff[Kcrr] * (long)(n-128) ;
		cr_g[n] = (long)coeff[Kcrg] * (long)(n-128) ;
		cb_g[n] = (long)coeff[Kcbg] * (long)(n-128) ;
		cb_b[n] = (long)coeff[Kcbb] * (long)(n-128) ;
	}
}


/*----------------------------------------------------- CalcCSCtables ---*/
void CalcCSCtables ( int *coeff )
{
	CalcYCmulTab ( coeff ) ;
	CalcNTCtable () ;
	CSCtablesOk = TRUE ;
}

/*----------------------------------------------------- CheckCalcCSCtables ---*/
void CheckCalcCSCtables ( int *coeff )
{
	if ( ! CSCtablesOk )
		CalcCSCtables ( coeff );
}

# if 0
/*-------------------------------------------- InitYC ----------------*/
void InitYC ( void )
{
	CalcCSCtables ( DefaultYCcoeff ) ;
}
# endif

# define ctabix(cr,cb)   ( (( cr & 0xf8 ) << 2 ) | ( ( cb & 0xf8 ) >> 3 ) )
# define ytabix(y)		 ( y & 0xfc00 )
# if 0	/*	-> yc_fast.s	*/

# define yc_ntc_line Cyc_ntc_line

/*------------------------------------------------------ yc_ntc_line -*/
void yc_ntc_line ( uword *sd, uword *dd, int w )
/* ycdata ->  y0  cb0  y1  cr0	*/
/*			  +0   +1  +2  +3	*/
{
	int cix ;
	uword ycr, ycb ;
	
	w >>= 1 ;	/* 2 pixels 7 line	*/
	do
	{
		ycb = *sd++ ;
		ycr = *sd++ ;
		cix = ctabix ( ycr, ycb ) ;
		*dd++ = ntc_table[ ytabix(ycb) | cix ] ;
		*dd++ = ntc_table[ ytabix(ycr) | cix ] ;
	}
	while ( --w > 0 ) ;
}
# endif

/*------------------------------------------------------ print_ntc -*/
void print_ntc ( uword ntc, char *es )
{
	printf ( "$%04x = (%2d,%2d,%2d)%s",
					ntc, (ntc>>11)&0x1f, (ntc>>6)&0x1f, ntc&0x1f, es ) ;
}

/*------------------------------------------------------ print_yc -*/
void print_yc ( uword *yc, int odd, char *es )
{
	byte *ycb ;
	
	if ( odd )	/* set yc to first value of yc pixel pair	*/
		yc-- ;

	ycb = (byte *)yc ;
	
	printf ( "%c$%04x %c$%04x = (%3d,%3d) (%3d,%3d)%s",
					odd ? ' ' : '>', yc[0-odd],
					odd ? '>' : ' ', yc[1-odd],
					ycb[0], ycb[1], ycb[2], ycb[3],
					es ) ;
}

/*------------------------------------------------------ prycntc -*/
void prycntc ( int y, int cr, int cb, char *name )
{
	uword ntc ;
	
	ntc = ntc_table[ ytabix((y<<8)) | ctabix ( cr, cb ) ] ;
	printf ( "%-10s %3d %3d %3d ", name, y, cr, cb ) ;
# if 1
	print_ntc ( ntc, "\n" ) ;
# else
	{
		uword yca[2],ntca[2] ;

		print_ntc ( ntc, ", " ) ;
		yca[0] = (y<<8) | cb ;
		yca[1] = (y<<8) | cr ;
		yc_ntc_line ( yca, ntca, 2 ) ;
		print_ntc ( ntca[0], " - " ) ;
		print_ntc ( ntca[1], "\n" ) ;
	}
# endif
}

/*------------------------------------------------------ yc_to_ntc_window -*/
void yc_to_ntc_window ( uword *ycdata,  int sbpl,
				  		uword *ntcdata, int dbpl,
						int   w, 	    int h,
						int   mode   )
/* ycdata ->  y0  cb0  y1  cr0		*/
{
	CheckCalcCSCtables ( DefaultYCcoeff );

	while ( h-- > 0 )
	{
		if ( mode )
			yc_ntc_line ( ycdata, ntcdata, w ) ;
		else
			yc_gray_line ( ycdata, ntcdata, w ) ;
		
		(long)ycdata  += sbpl ;
		(long)ntcdata += dbpl ;
	}
}	
