/* draw_555.c */

# include <stdio.h>
# include <string.h>
# include <ctype.h>
# include <tos.h>
# include <linea.h>
# include <portab.h>
# include <ext.h>

# include <global.h>
# include <scancode.h>
# include <picfiles.h>
# include "yc.h"
# include "yc_fast.h"
# include "tools.h"
# include "digiblit.h"
# include "matdigif.h"

# include "draw_555.h"

# define BYT_PER_PIX	2

# define MouseX()			(Vdiesc->cur_x)
# define MouseY()			(Vdiesc->cur_y)
# define DX()				(Vdiesc->v_rez_hz)
# define DY()				(Vdiesc->v_rez_vt)

/*----------------------------------------------- pixel_position ---*/
uword *pixel_position ( uword *base, int x, int y, int bpl )
{
	return (uword *) (((long)base)
						+ (long)y * (long)bpl
						+ (long) ( x * BYT_PER_NTC_PIX )    ) ;
}

/*----------------------------------------------- screen_position --*/
uword *screen_position ( int x, int y )
{
	return pixel_position ( ScreenImage.data, x, y, ScreenImage.bpl ) ;
}

/*----------------------------------------------- col555 ------*/
uword col555 ( int r, int g, int b )
/* r, g, b = 0 .. 31	*/
{
	return ( r << 11 ) | ( g <<  6 ) | b ;
}

/*----------------------------------------------- col16 ------*/
uword col16 ( int r, int g, int b )
/* format : 55o5	*/
/*	r  r  r  r  r  g  g  g  g  g  o  b  b  b  b  b  */
/*	15 14 13 12 11 10 9  8  7  6  5  4  3  2  1  0	*/
{
	return ( ( r * 31 / 1000 ) << 11 )
		 | ( ( g * 31 / 1000 ) <<  6 )
		 | ( ( b * 31 / 1000 )       ) ;
}

/*----------------------------------------------- frect555 ------*/
void frect555 ( int x, int y, int w, int h, uword color )
{
	int ww, xadd ;
	uword *p ;

	p = screen_position ( x, y ) ;
	xadd = ScreenImage.bpl - w * BYT_PER_PIX ;
	
	while ( h-- > 0 )
	{
		for ( ww = w; ww > 0 ; ww-- )
			*p++ = color ;
		(long)p += xadd ;
	}
}

/*----------------------------------------------- frect ------*/
void frect ( int x, int y, int w, int h,
			 int r, int g, int b )
{
	printf ( "color (%d,%d,%d)\n", r, g, b ) ;
	frect555 ( x, y, w, h, col16 ( r, g, b ) ) ;
}


/*----------------------------------------------- ColorRun555 ---------*/
void ColorRun ( int x, int y, int dx, int dy, int r, int g, int b )
{
	uword color, colinc ;
	int n, x0, x1 ;
	
	colinc = col555 ( r, g, b ) ;
	
	for ( x0 = x, color = 0, n = 1;  n <= 32;  n++, color += colinc )
	{
		x1 = x + n * dx / 32 ;
		frect555 ( x0, y, x1-x0, dy, color ) ;
		x0 = x1 ;
	}
}

/*----------------------------------------------- TestRun ----------*/
void TestRun ( void )
{
# if 0
	int y, dy, dx, c ;

	dx = DX() ;
	dy = DY() / 8 ;
	for ( y = c = 0; c < 8; c++, y += dy )
		ColorRun ( 0, y, dx, dy, (c&4)>>2, (c&2)>>1, c&1 ) ;
# else
	int x, dy, dx, c ;

	dx = DX() / 8 ;
	dy = DY() ;
	for ( x = c = 0; c < 8; c++, x += dx )
		ColorRun ( x, 0, dx, dy, (c&4)>>2, (c&2)>>1, c&1 ) ;
# endif
}


/*----------------------------------------------- TestScreen -------*/
void TestScreen ( void )
{
	frect (   0,  0,  20, 10, 1000,    0,    0 ) ;
	frect (  20, 10,  40, 20,    0, 1000,    0 ) ;
	frect (  40, 20,  80, 40,    0,    0, 1000 ) ;
}


# if 0
/*----------------------------------------------- ntc_pixel_info --*/
void ntc_pixel_info ( int x, int y )
{
	uword *pixp ;
	
	pixp = screen_position ( x, y ) ;
	printf ( "  NTC %3d : %3d $%p : ", x, y, pixp ) ;
	print_ntc ( *pixp, "" ) ;
}

/*----------------------------------------------- yc_pixel_info --*/
void yc_pixel_info ( uword *base, int x, int y, int bpl )
{
	uword *pixp ;
	
	pixp = pixel_position ( base, x, y, bpl ) ;
	printf ( "  YC %3d : %3d $%p : ", x, y, pixp ) ;
	print_yc ( pixp, x & 1, "" ) ;
}
# endif

/*----------------------------------------------- pixel_info -----*/
void pixel_info ( uword *ycdata, int ycbpl, int maxx, int maxy )
{
	int lmx, lmy ;
	uword saved_pixel, cursor ;
	uword *savpixpos ;

	SetCrs(10) ;

	lmx = lmy = 0 ;

	
	savpixpos = NULL ;
	saved_pixel = 0 ;
	cursor = 0 ;
	while ( ! kbhit() )
	{
		if ( MouseX() != lmx || MouseY() != lmy )
		{
			lmx = MouseX() ;
			lmy = MouseY() ;
			if ( savpixpos != NULL )
				*savpixpos = saved_pixel ;

			SetCrs(6) ;
			if ( lmx > maxx )
				printf ( " X over\n" ) ;
			else if ( lmy > maxy )
				printf ( " Y over\n" ) ;
			else
			{
# if 1
				printf ( "%3d:%3d\n", lmx, lmy ) ;
				if ( ycdata != NULL )
					print_yc ( pixel_position ( ycdata, lmx, lmy, ycbpl ),
													 lmx & 1, "\n" ) ;
				savpixpos = screen_position ( lmx, lmy ) ;
				saved_pixel = *savpixpos ;
				print_ntc ( saved_pixel, "\n" ) ;
								/* rrrrrggg.ggobbbbb	*/
								/* fedcba98.76543210	*/
								/* 10000100.00010000	*/
# else
				if ( ycdata != NULL )
					yc_pixel_info ( ycdata, lmx, lmy, ycbpl ) ;
				ntc_pixel_info ( lmx, lmy ) ;
# endif
			}
		}
		else
		{
			if ( savpixpos != NULL )
			{
				*savpixpos = cursor /* saved_pixel ^ 0x8410 */ ;
				cursor = ~cursor ;
			}
		}
		delay ( 50 ) ;
	}
	getch();
	if ( savpixpos != NULL )
		*savpixpos = saved_pixel ;

}

/*--------------------------------------------- display_file -------*/
void display_file ( char *name, unsigned mode )
{
	YCpic yc ;
	int	 ycbpl, maxx, maxy ;

	printf ( "display %s : ", name ) ;
	if ( read_yc_picture ( name, &yc ) == OK )
	{
		ycbpl = yc.head->breite * 2 ;
		maxx = min ( ScreenImage.w, yc.head->breite ) ;
		maxy = min ( ScreenImage.h, yc.head->hoehe  ) ;
		printf ( "%d x %d\n", yc.head->breite, yc.head->hoehe ) ;
		yc_to_ntc_window ( (uword *)yc.data, ycbpl,
				  	   ScreenImage.data, ScreenImage.bpl,
					   maxx, maxy,
					   mode ) ;
		free_yc_pic ( &yc ) ;
	}
	else
		printf ( "* read error\n" ) ;
}


