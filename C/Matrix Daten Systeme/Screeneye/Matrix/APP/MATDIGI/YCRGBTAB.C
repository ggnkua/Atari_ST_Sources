
# include <stdio.h>
# include <global.h>

# include "fastrom.h"
# include "ycrgbtab.h"

uword rgb_table[0x0FFFFL] ;
uword grey_table[0x0FF] ;

bool  yc_table_ok = FALSE ;
bool  yc_mul_table_ok = FALSE ;

local long cr_r[255] ;
local long cr_g[255], cb_g[255] ;
local long cb_b[255] ;

/*----------------------------------------------------- calc_yc_mul_tab ---*/
local void calc_yc_mul_tab ( void )
{
	int n ;
	
	if ( ! yc_mul_table_ok )
	{
		for ( n = 0 ; n < 0x100; n++ )
		{
			cr_r[n] = (long)  351 * (long)(n-128) ;
			cr_g[n] = (long)- 179 * (long)(n-128) ;
			cb_g[n] = (long)-  86 * (long)(n-128) ;
			cb_b[n] = (long)+ 443 * (long)(n-128) ;
		}
		yc_mul_table_ok = TRUE ;
	}
}


/*----------------------------------------------- col_332 ------*/
byte col_332 ( int r, int g, int b )
/* format : 332	*/
/*	0  0  0  0  0  0  0  0  r  r  r  g  g  g  b  b  */
/*	15 14 13 12 11 10 9  8  7  6  5  4  3  2  1  0	*/
{
	return (   ( r & 0xE0 )			  |
		     ( ( g & 0xE0 ) >> 3 )	  |
		     ( ( b & 0xC0 ) >> 6 ) ) ;
}


/*----------------------------------------------- col_ntc ------*/
uword col_ntc ( int r, int g, int b )
/* format : 565 or 55o5	*/
/*	r  r  r  r  r  g  g  g  g  g  g/o  b  b  b  b  b  */
/*	15 14 13 12 11 10 9  8  7  6  5    4  3  2  1  0	*/
{
	return ( ( ( r & 0xF8 ) << 8 )     |
		     ( ( g & 0xFC ) << 3 )     |
		     ( ( b & 0xF8 ) >> 3 ) ) ;
}


/*----------------------------------------------- yctorgb ------*/
void yctorgb ( ulong *rgb, int y0cr, int y1cb )
/* format : o888*/
{
	int r, g, b, y, cr, cb ;

	y = y0cr & 0xFF00 ;
	cr = y0cr & 0x00FF ;
	cb = y1cb & 0x00FF ;
	
	r = add32clip8 ( y, cr_r[cr] 				) ;
	g = add32clip8 ( y, cr_g[cr] + cb_g[cb]		) ;
	b = add32clip8 ( y, cb_b[cb]				) ;
	
	*rgb++ = ( ( ( r & 0xFF ) << 16 )     |
		       ( ( g & 0xFF ) <<  8 )     |
		       (   b & 0xFF )       ) ;

	y = y1cb & 0xFF00 ;

	r = add32clip8 ( y, cr_r[cr] 				) ;
	g = add32clip8 ( y, cr_g[cr] + cb_g[cb]		) ;
	b = add32clip8 ( y, cb_b[cb]				) ;
	
	*rgb++ = ( ( ( r & 0xFF ) << 16 )     |
		       ( ( g & 0xFF ) <<  8 )     |
		       (   b & 0xFF )       ) ;
}


/*----------------------------------------------- grey_ntc ------*/
uword grey_ntc ( int y )
/* format : 565 or 55o5, r=g=b	*/
/*	0  0  0  0  0  0  0  0  Y  Y  Y    Y  Y  Y  Y  Y  */
/*	Yr Yr Yr Yr Yr Yg Yg Yg Yg Yg Yg/o Yb Yb Yb Yb Yb */
/*	15 14 13 12 11 10 9  8  7  6  5    4  3  2  1  0	*/
{
	return ( ( ( y & 0xF8 ) << 8 )     |
		     ( ( y & 0xFC ) << 3 )     |
		     ( ( y & 0xF8 ) >> 3 ) ) ;
}


# ifdef TRUE_COLOUR
/*----------------------------------------------- col_tc ------*/
ulong col_tc ( int r, int g, int b )
/* format : 0888 */
{
	return ( ( ( r & 0xFF ) << 16 )     |
		     ( ( g & 0xFF ) <<  8 )     |
		     (   b & 0xFF         ) ) ;
}
# endif TRUE_COLOUR

# define Step(bits)	(1<<(8-bits))

/*	y  y  y  y  y  y .cr cr | cr cr cr.cb cb cb cb cb */
/*	15 14 13 12 11 10 9  8  | 7  6  5  4  3  2  1  0	 */
# define Ystep	Step(6)
# define Crstep	Step(5)
# define Cbstep	Step(5)

/*--------------------------------------------------- init_ntc_table ---*/
void init_ntc_table ( void )
{
	int	 cb, cr, y ;
	int r,g,b ;
	uword *tab ;

	tab = (uword *)rgb_table ;
														/*		  844	  655	   55o5   */
	for ( y = 0 ; y < 0x100 ; y += Ystep )				/*	Y  : 15..8 / 15..10	/ 15..10  */
	{
		for ( cr = 0 ; cr < 0x100 ; cr += Crstep )		/*	Cr :  7..4 /  9.. 5	/ 9.. 5   */
			for ( cb = 0 ; cb < 0x100 ; cb += Cbstep )	/*	Cb :  3..0 /  4.. 0	/ 4.. 0   */
			{
				r = add32clip8 ( y, cr_r[cr] 				) ;
				g = add32clip8 ( y, cr_g[cr] + cb_g[cb]		) ;
				b = add32clip8 ( y, cb_b[cb]				) ;
					*tab++ = col_ntc ( r, g, b ) ;
			}
	}
}


/*--------------------------------------------------- init_332_table ---*/
void init_332_table ( void )
{
	int	 cb, cr, y ;
	int r,g,b ;
	byte *tab ;

	tab = (byte *)rgb_table ;
														/*		  844	  655	   55o5   */
	for ( y = 0 ; y < 0x100 ; y += Ystep )				/*	Y  : 15..8 / 15..10	/ 15..10  */
	{
		for ( cr = 0 ; cr < 0x100 ; cr += Crstep )		/*	Cr :  7..4 /  9.. 5	/ 9.. 5   */
			for ( cb = 0 ; cb < 0x100 ; cb += Cbstep )	/*	Cb :  3..0 /  4.. 0	/ 4.. 0   */
			{
				r = add32clip8 ( y, cr_r[cr] 				) ;
				g = add32clip8 ( y, cr_g[cr] + cb_g[cb]		) ;
				b = add32clip8 ( y, cb_b[cb]				) ;
					*tab++ = col_332 ( r, g, b ) ;
			}
	}
}


/*-------------------------------------------- init_grey_ntc_table ---*/
void init_grey_ntc_table ( void )
{
	int	 y ;
	uword *tab ;

	tab = grey_table ;

	for ( y = 0 ; y < 0x100 ; y++ )
		*tab++ = grey_ntc ( y  ) ;
}

# ifdef TRUE_COLOUR
/*--------------------------------------------------- init_tc_table ---*/
void init_tc_table ( void )
{
	int	 cb, cr, y ;
	int r,g,b ;
	ulong *tab ;

	tab = (ulong *)rgb_table ;
														/*		  844	  655	   55o5   */
	for ( y = 0 ; y < 0x100 ; y += Ystep )				/*	Y  : 15..8 / 15..10	/ 15..10  */
	{
		for ( cr = 0 ; cr < 0x100 ; cr += Crstep )		/*	Cr :  7..4 /  9.. 5	/ 9.. 5   */
			for ( cb = 0 ; cb < 0x100 ; cb += Cbstep )	/*	Cb :  3..0 /  4.. 0	/ 4.. 0   */
			{
				r = add32clip8 ( y, cr_r[cr] 				) ;
				g = add32clip8 ( y, cr_g[cr] + cb_g[cb]		) ;
				b = add32clip8 ( y, cb_b[cb]				) ;
					*tab++ = col_tc ( r, g, b ) ;
			}
	}
}
# endif TRUE_COLOUR


/*------------------------------------------------------ rgb_init -*/
void rgb_init ( int planes )
{
	if ( ! yc_mul_table_ok )
		calc_yc_mul_tab() ;
		
	if ( ! yc_table_ok )
	{
		switch ( planes )
		{
# ifdef TRUE_COLOUR
case 32 :
case 24 :	init_tc_table () ;				/* True Colour */
			break ;
# endif TRUE_COLOUR
case 16 :	init_ntc_table () ;				/* FALCON ntc */
			init_grey_ntc_table () ;
			break ;
case  8 :	init_332_table () ;				/* 332 rgb */
			break ;
default : ;
		}
		yc_table_ok = TRUE ;
	}
}

