#include <vdi.h>
#include <aes.h>
#include <stdlib.h>
#include <stddef.h>

#include <global.h>
#include <vdi_ext.h>
#include <fast.h>

# include "\pc\cxxsetup\main.h"
# include "\pc\cxxsetup\cxxfast.h"
# include "\pc\cxxsetup\draw.h"
# include "\pc\cxxsetup\screen.h"
# include "\pc\cxxsetup\poti.h"	

# include "tc_draw.h"
# include "\pc\tcxx\tcxx.lib\tcxxfast.h"
# include "\pc\tcxx\chips\clut.h"
# include "colors.h"
# include "drawwind.h"

# include "effects.h"

# if 0
/*------------------------------------------- line_nalias ----------*/
void line_nalias ( int *pts, int *line_rgb )
/*
   -								+------+
   ^						+------+
  dy				+------+
   v		+------+
   -+------+
	|<------- dx --------->|
*/
{
		int i, d, dd ;
		int dx, dy ;
 		int dx_diag, dy_diag ;
		int diag_inc, nondiag_inc ;
	
		byte *pa, *pa1 ;
		int diag, nondiag ;
		int rgb[3] ;
	
		rgb[R] = uscale ( line_rgb[R], 255, 1000 ) ;
		rgb[G] = uscale ( line_rgb[G], 255, 1000 ) ;
		rgb[B] = uscale ( line_rgb[B], 255, 1000 ) ;

		dx = pts[X1] - pts[X0] ;
		dy = pts[Y1] - pts[Y0] ;
		
		if ( dx < 0 ) { dx = -dx; dx_diag = -4 ; } else dx_diag = 4 ;
		if ( dy < 0 ) { dy = -dy; dy_diag = -bytes_per_line;  } else dy_diag = bytes_per_line ;
			
		diag = dx_diag + dy_diag ;
	
		if ( dx < dy )
		{
			int h ;	h = dx; dx = dy ; dy = h ;	/* meaning dx <-> dy changed !!	*/
			nondiag = dy_diag ;
		}
		else
		{
			nondiag = dx_diag ;
		}

		/* dx >= dy ! */

		nondiag_inc = dy << 1 ;		/* 2*dy			*/
		d = nondiag_inc - dx ;		/* 2*dy	- dx	*/
		diag_inc = d - dx ;			/* 2*dy	- 2*dx	( < 0 ! ) */
		
		d += diag_inc ;	/* == 4*dy	- 3*dx	( < 0 ! )		*/

		pa = (byte *)pixel_address ( pts[X0], pts[Y0] ) ;
		
		for ( i = 0 ; i <= dx; i++ )
		{
			dd = nondiag_inc - d ;
			pa[0] = 0 ;
			pa[R+1] = (byte) ( iscale ( rgb[R], d, nondiag_inc )
								+ iscale ( pa[R+1], dd, nondiag_inc ) ) ;
			pa[G+1] = (byte) ( iscale ( rgb[G], d, nondiag_inc )
								+ iscale ( pa[G+1], dd, nondiag_inc ) ) ;
			pa[B+1] = (byte) ( iscale ( rgb[B], d, nondiag_inc )
								+ iscale ( pa[B+1], dd, nondiag_inc ) ) ;
			pa1 = pa + diag ;
			pa1[0] = 0 ;
			pa1[R+1] = (byte) ( iscale ( rgb[R], dd, nondiag_inc )
								+ iscale ( pa[R+1], d, nondiag_inc ) ) ;
			pa1[G+1] = (byte) ( iscale ( rgb[G], dd, nondiag_inc )
								+ iscale ( pa[G+1], d, nondiag_inc ) ) ;
			pa1[B+1] = (byte) ( iscale ( rgb[B], dd, nondiag_inc )
								+ iscale ( pa[B+1], d, nondiag_inc ) ) ;
if ( i == 0 )
	printf ( "????? line_nalias 0 + ???\n" ) ;
			if ( d < 0 + diag_inc )
			{
				pa += nondiag ;
				d += nondiag_inc ;		/* really increment	*/
			}
			else
			{
				pa += diag ;
				d += diag_inc ;			/* really decrement	*/
			}
		}
}
# else
/*---------------------------------------- line_nalias ----*/
void line_nalias ( int *pts, int *line_rgb )
/*
;	pixel			n		n+1
;	raster		|.......|.......|
;	exact		^
;	real			^
;	corr		|dx>|
;	rgb[n]   = new * (1-k) + rgb[n] * k		; k = dx/pw
;	rgb[n+1] = new * k + rgb[n+1] * (1-k)
*/
{
	int dx, dy, x, y ;
	byte rgb[3] ;
	
	rgb[R] = (byte) uscale ( line_rgb[R], 255, 1000 ) ;
	rgb[G] = (byte) uscale ( line_rgb[G], 255, 1000 ) ;
	rgb[B] = (byte) uscale ( line_rgb[B], 255, 1000 ) ;
/*
 void get_tcpixel ( int x, int y, unsigned char *rgb ) ;
*/

	dx = pts[X1] - pts[X0] ;
	dy = pts[Y1] - pts[Y0] ;
	if ( abs ( dx ) > abs ( dy ) )
	{
		for ( x = pts[X0]; x <= pts[X1]; x++ )
		{
		/*	y = pts[Y0] + ( x - pts[X0] ) / dx * dy ;	*/
			set_xapixel ( pts[X0], pts[Y0], x, dx, dy, rgb ) ;
		}
	}
	else
	{
		for ( y = pts[Y0]; y <= pts[Y1]; y++ )
		{
		/*	x = pts[X0] + ( y - pts[Y0] ) / dy * dx ;	*/
			set_yapixel ( pts[X0], pts[Y0], y, dx, dy, rgb ) ;
		}
	}

}
# endif

/*----------------------------------------- rgb_cube -----*/
void rgb_cube ( int *pts, int space )
/*
					B
				  /   \
				/		\
			   m         c
			   |\		/|
			   |  \   /  |
			   |    w    |
			   |         |
			   R         G
				\		/
				  \   /
				    y
*/
{
	int dx, dy, ddy ;
	int rgbs[12], ptsarea[6], *ip ;
	int	xm, y1, y2, y3 ;

	dx = pts[X1] - pts[X0] + 1 ;
	if ( dx <= 0 )
		return ;

	dy = pts[Y1] - pts[Y0] + 1 ;
	if ( dy <= 0 )
		return ;

# if 1	/*	30'	*/	  /* dx*sin(30')/(cos(30')	*/
	ddy = iscale ( dx,  32, 2*110 ) ;
# else	/*	45'	*/
	ddy = dx/2 ;
# endif

	if ( dy <= 2 * ddy ) return ;

	xm  = pts[X0] + dx/2 ;
	
	y1 = pts[Y0] + ddy ;
	y2 = y1 + ddy ;
	y3 = pts[Y1] - ddy ;

# define corners(xa,ya,xb,yb,xc,yc) \
	ip=ptsarea;*ip++=xa;*ip++=ya;*ip++=xb;*ip++=yb;*ip++=xc;*ip++=yc
# define pshcol(r,g,b) *ip++=r;*ip++=g;*ip++=b
# define col_points(c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11) \
	ip=rgbs;pshcol(c0,c1,c2);pshcol(c3,c4,c5);pshcol(c6,c7,c8);pshcol(c9,c10,c11)
# define Black   0,0,0
# define Red     1000,0,0
# define Green   0,1000,0
# define Blue    0,0,1000
# define Yellow  1000,1000,0
# define Magenta 1000,0,1000
# define Cyan    0,1000,1000
# define White   1000,1000,1000

	switch ( space )
	{
  case RGBspace	:
		corners(xm,pts[Y0],pts[X0],y1,pts[X1],y1);
		col_points ( Blue, Magenta, Cyan, White );	
		vrun_parallel ( vdi_handle, ptsarea, rgbs ) ;

		corners(pts[X0],y1,xm,y2,pts[X0],y3);
		col_points ( Magenta, White, Red, Yellow );	
		vrun_parallel ( vdi_handle, ptsarea, rgbs ) ;

		corners(xm,y2,pts[X1],y1,xm,pts[Y1]);
		col_points ( White, Cyan, Yellow, Green );	
		vrun_parallel ( vdi_handle, ptsarea, rgbs ) ;
		break ;

  case CMYspace	:
		corners(xm,pts[Y0],pts[X0],y1,pts[X1],y1);
		col_points ( Yellow, Green, Red, Black );	
		vrun_parallel ( vdi_handle, ptsarea, rgbs ) ;

		corners(pts[X0],y1,xm,y2,pts[X0],y3);
		col_points ( Green, Black, Cyan, Blue );	
		vrun_parallel ( vdi_handle, ptsarea, rgbs ) ;

		corners(xm,y2,pts[X1],y1,xm,pts[Y1]);
		col_points ( Black, Red, Blue, Magenta );	
		vrun_parallel ( vdi_handle, ptsarea, rgbs ) ;
		break ;
	}

	if ( with_outlines )
	{

		set_line_attr ( MD_REPLACE, 1, outline_width, curr_color ) ;
		draw_line4 ( xm, pts[Y0], pts[X0], y1 ) ;
		draw_line4 ( xm, pts[Y0], pts[X1], y1 ) ;
	
		draw_line4 ( pts[X0], y1, xm, y2 ) ;
		draw_line4 ( pts[X1], y1, xm, y2 ) ;
		
		draw_line4 ( pts[X0], y1, pts[X0], y3 ) ;	/*	left	*/
		draw_line4 ( pts[X1], y1, pts[X1], y3 ) ;	/*	right	*/
		draw_line4 ( xm, y2, xm, pts[Y1] ) ;	/*	midle	*/
	
		draw_line4 ( pts[X0], y3, xm, pts[Y1] ) ;
		draw_line4 ( pts[X1], y3, xm, pts[Y1] ) ;
	}
}

# define MAX_BRIGTH	255
byte bright_table[MAX_BRIGTH+1] ;

/*----------------------------------------- init_bright ----*/
void init_bright ( void )
{
	int ilevel ;
	byte *bp ;
	
	bp = bright_table ;
	for ( ilevel = MAX_BRIGTH; ilevel >= 0; ilevel-- )
		*bp++ = MAX_BRIGTH - (ilevel*ilevel) / MAX_BRIGTH ;	/* 1.0 - (1.0-int)^2 */
}

# define MINMAX 1

/*----------------------------------------- calib_rect ----*/
void calib_rect ( int *pts, int ref_top, int ref_bottom )
{
	int x, y, dref ;
	unsigned char rgb[3] ;
# if MINMAX
	long mini[3], maxi[3] ;
# else
	long sum[3] ;
# endif
	byte *reference, *rp ;

	dref = ref_bottom - ref_top + 1 ;
	if ( dref <= 0 )
		return ;
# if MINMAX
	reference = malloc ( 2*3*(pts[X1]-pts[X0]+1) ) ;
# else
	reference = malloc ( 3*(pts[X1]-pts[X0]+1) ) ;
# endif
	if ( reference != NULL )
	{
		rp = reference ;
		for ( x = pts[X0]; x <= pts[X1]; x++ )
		{
# if MINMAX
			mini[R] = mini[G] = mini[B] = 255 ;
			maxi[R] = maxi[G] = maxi[B] = 0 ;
			for ( y = ref_top; y <= ref_bottom; y++ )
			{ 
				get_tcpixel ( x, y, rgb ) ;
				if ( rgb[R] < mini[R] )
					mini[R] = rgb[R] ;
				if ( rgb[G] < mini[G] )
					mini[G] = rgb[G] ;
				if ( rgb[B] < mini[B] )
					mini[B] = rgb[B] ;

				if ( rgb[R] > maxi[R] )
					maxi[R] = rgb[R] ;
				if ( rgb[G] > maxi[G] )
					maxi[G] = rgb[G] ;
				if ( rgb[B] > maxi[B] )
					maxi[B] = rgb[B] ;
			}
			*rp++ = mini[R] ;
			*rp++ = maxi[R] - mini[R] ;
			*rp++ = mini[G] ;
			*rp++ = maxi[G] - mini[G] ;
			*rp++ = mini[B] ;
			*rp++ = maxi[B] - mini[B] ;
# else
			sum[R] = sum[G] = sum[B] = 0 ;
			for ( y = ref_top; y <= ref_bottom; y++ )
			{ 
				get_tcpixel ( x, y, rgb ) ;
				sum[R] += rgb[R] ;
				sum[G] += rgb[G] ;
				sum[B] += rgb[B] ;
			}
			*rp++ = (byte)( sum[R] / (long)dref ) ;
			*rp++ = (byte)( sum[G] / (long)dref ) ;
			*rp++ = (byte)( sum[B] / (long)dref ) ;
# endif
		}


		for ( y = pts[Y0]; y <= pts[Y1]; y++ )
		{ 
# if MINMAX
			minmax_line ( pixel_address ( pts[X0], y ),
					reference, (pts[X1]-pts[X0]+1) ) ;
# else
			calib_line ( pixel_address ( pts[X0], y ),
					reference, (pts[X1]-pts[X0]+1) ) ;
# endif
		}

		free ( reference ) ;
	}
}


/*----------------------------------------- gray_rect ----*/
void gray_rect ( int *pts )
{
	int x, y ;
	
	for ( y = pts[Y0]; y <= pts[Y1]; y++ )
	{ 
		for ( x = pts[X0]; x <= pts[X1]; x++ )
			gray_pixel ( x, y ) ;
	}
}


/*-------------------------------------------- convert_line_to_yuv -*/
void convert_line_to_yuv ( long *pos, int len )
{
	for ( ; len > 0 ; len-- )
		pixrgb_to_yuv ( pos++ ) ;
}


/*--------------------------------------- yuv_rect ----*/
void yuv_rect ( int *pts )
{
	int y, length;
	long *start_adr;
   
	length = pts[X1] - pts[X0] + 1 ;
	start_adr = pixel_address ( pts[X0], pts[Y0] ) ;
	for ( y = pts[Y0]; y <= pts[Y1]; y++ )
	{
		convert_line_to_yuv ( start_adr, length ) ;
		(long)start_adr += bytes_per_line;
	}
}



/*----------------------------------------- bright_rect ----*/
void bright_rect ( int *pts )
{
	int x, y ;
	
	
	for ( y = pts[Y0]; y <= pts[Y1]; y++ )
	{ 
		for ( x = pts[X0]; x <= pts[X1]; x++ )
			bright_pixel ( x, y, bright_table ) ;
	}
}


/*----------------------------------------- zoom_rect ----*/
void zoom_rect ( long *spixa, long *dpixa,
				 int dx2, int dy2, int sx, int sy )
/*
		+-----------+
		|			|
		|			|
		+-----------+
*/
{
	int xi ;
	long *sp, *dp1, *dp2 ;
	
	while ( dy2-- > 0  )
	{
		if ( sy > 0 )
		{
			sp = spixa ;	(long)spixa += sy ;
			dp2 = dpixa ;	(long)dpixa += sy ;
			dp1 = dpixa ;	(long)dpixa += sy ;
		}
		else
		{
			(long)spixa += sy ;	sp = spixa ;
			(long)dpixa += sy ;	dp2 = dpixa ;
			(long)dpixa += sy ;	dp1 = dpixa ;
		}
		if ( sx > 0 )
		{
			for ( xi = dx2; xi > 0; xi-- )
				*dp2++ = *dp2++ = *dp1++ = *dp1++ = *sp++ ;
		}
		else
		{
			for ( xi = dx2; xi > 0; xi-- )
				*--dp2 = *--dp2 = *--dp1 = *--dp1 = *--sp ;
		}
	}
}

/*----------------------------------------- zoom_box ----*/
void zoom_box ( int *pts )
/*
Y0		+-----------+-----------+		11112222
y14		|	1		|	2		|		11112222
		|			|			|		33334444
		+-----------+-----------+		33334444
y34		|	3		|	4		|
		|			|			|
y44		+-----------+-----------+
		X0	x14			x34		x44
*/
{
	int dx4, dy4 ;
	int x14, x34, y14, y34, x44, y44 ;

	dx4 =  ( pts[X1] - pts[X0] + 1 ) / 4 ;
	dy4 =  ( pts[Y1] - pts[Y0] + 1 ) / 4 ;
	x44 = pts[X0] + dx4 * 4 ;	y44 = pts[Y0] + dy4 * 4 ;
	x14 = pts[X0] + dx4 ;		x34 = x44 - dx4 ;
	y14 = pts[Y0] + dy4 ;		y34 = y44 - dy4 ;

	zoom_rect ( pixel_address ( x14, y14 ),					/*	1	*/
				pixel_address ( pts[X0], pts[Y0] ),
				dx4, dy4, +1,  bytes_per_line ) ;
	zoom_rect ( pixel_address ( x34, y14 ),					/*	2	*/
				pixel_address ( x44, pts[Y0] ),
				dx4, dy4, -1,  bytes_per_line ) ;
	zoom_rect ( pixel_address ( x14, y34 ),					/*	3	*/
				pixel_address ( pts[X0], y44 ),
				dx4, dy4, +1,  -bytes_per_line ) ;
	zoom_rect ( pixel_address ( x34, y34 ),					/*	4	*/
				pixel_address ( x44, y44 ),
				dx4, dy4, -1,  - bytes_per_line ) ;
}

/*----------------------------------------- zoom_box ----*/
void zoom_copy ( int *spts, int *dpts )
/*
Y0		+-----------+-----------+		11112222
y14		|	1		|	2		|		11112222
		|			|			|		33334444
		+-----------+-----------+		33334444
y34		|	3		|	4		|
		|			|			|
y44		+-----------+-----------+
		X0	x14			x34		x44
*/
{
	int dx2, dy2 ;

	dx2 =  ( spts[X1] - spts[X0] + 1 ) >> 1 ;
	dy2 =  ( spts[Y1] - spts[Y0] + 1 ) >> 1 ;

	zoom_rect ( pixel_address ( spts[X0], spts[Y0] ),
				pixel_address ( dpts[X0], dpts[Y0] ),
				dx2, dy2, +1,  bytes_per_line ) ;
}



/*----------------------------------------- copy_block ----*/
void copy_block ( int *spts, int *dpts,
				  int blit_mode,
				  MFDB *source, MFDB *dest )
{
	int pxyarray[8] ;

	pxyarray[0] = spts[X0] ;
	pxyarray[1] = spts[Y0] ;
	pxyarray[2] = spts[X1] ;
	pxyarray[3] = spts[Y1] ;

	pxyarray[4] = dpts[X0] ;
	pxyarray[5] = dpts[Y0] ;
	pxyarray[6] = dpts[X1] ;
	pxyarray[7] = dpts[Y1] ;

	vro_cpyfm ( vdi_handle, blit_mode, pxyarray, source, dest ) ;
}


/*----------------------------------------- copy_box ----*/
void copy_box ( int *spts, int *dpts, int blit_mode )
{
	int pxyarray[8] ;

	pxyarray[0] = spts[X0] ;
	pxyarray[1] = spts[Y0] ;
	pxyarray[2] = spts[X1] ;
	pxyarray[3] = spts[Y1] ;

	pxyarray[4] = dpts[X0] ;
	pxyarray[5] = dpts[Y0] ;
	pxyarray[6] = dpts[X1] ;
	pxyarray[7] = dpts[Y1] ;

	vro_cpyfm ( vdi_handle, blit_mode, pxyarray, &vdi_screen, &vdi_screen ) ;
}

/*------------------------------------------------- mirror_rect ----*/
void mirror_rect ( int *pts, int degree )
{
	int x, y, x0, y0, x1, y1 ;
	unsigned char pix0[3], pix1[3] ;

	switch ( degree )	
	{
 case -1 :	for ( y0 = pts[Y0], y1 = pts[Y1]; y0 < y1; y0++, y1-- )	/* Punkt	*/
			{
				for ( x0 = pts[X0], x1 = pts[X1]; x0 <= pts[X1]; x0++, x1-- )
				{
					get_tcpixel ( x0, y0, pix0 ) ;
					get_tcpixel ( x1, y1, pix1 ) ;
			
					set_pixel ( x0, y0, pix1 ) ;
					set_pixel ( x1, y1, pix0 ) ;
				}
			}
			if ( y0 == y1 )	/* mid line	*/
			{
				for ( x0 = pts[X0], x1 = pts[X1]; x0 < x1; x0++, x1-- )
				{
					get_tcpixel ( x0, y0, pix0 ) ;
					get_tcpixel ( x1, y1, pix1 ) ;
			
					set_pixel ( x0, y0, pix1 ) ;
					set_pixel ( x1, y1, pix0 ) ;
				}
			}
			break ;

 case 0 :	for ( y0 = pts[Y0], y1 = pts[Y1]; y0 < y1; y0++, y1-- )
			{ 
				for ( x = pts[X0]; x <= pts[X1]; x++ )
				{
					get_tcpixel ( x, y0, pix0 ) ;
					get_tcpixel ( x, y1, pix1 ) ;
		
					set_pixel ( x, y0, pix1 ) ;
					set_pixel ( x, y1, pix0 ) ;
				}
			}
			break ;

 case 90 :	for ( y = pts[Y0]; y <= pts[Y1]; y++ )
			{ 
				for ( x0 = pts[X0], x1 = pts[X1]; x0 < x1; x0++, x1-- )
				{
					get_tcpixel ( x0, y, pix0 ) ;
					get_tcpixel ( x1, y, pix1 ) ;
		
					set_pixel ( x0, y, pix1 ) ;
					set_pixel ( x1, y, pix0 ) ;
				}
			}
			break ;


/* 45 / 135 : quadrat	!	*/

 case 45 :	for ( y0 = pts[Y0], x0 = pts[X1]; y0 <= pts[Y1]; y0++, x0-- )
			{
				for ( x = x0, y = y0; x >= pts[X0]; x--, y++ )
				{
					get_tcpixel (  x, y0, pix0 ) ;
					get_tcpixel ( x0,  y, pix1 ) ;
		
					set_pixel (  x, y0, pix1 ) ;
					set_pixel ( x0,  y, pix0 ) ;
				}
			}
			break ;

 case 135 :	for ( y0 = pts[Y0], x0 = pts[X0]; y0 <= pts[Y1]; y0++, x0++ )
			{
				for ( x = x0, y = y0; x <= pts[X1]; x++, y++ )
				{
					get_tcpixel (  x, y0, pix0 ) ;
					get_tcpixel ( x0,  y, pix1 ) ;
		
					set_pixel (  x, y0, pix1 ) ;
					set_pixel ( x0,  y, pix0 ) ;
				}
			}
			break ;
	}
}


# if 0
/*----------------------------------------- simulate_clut ----*/
void simulate_clut ( int *pts, long mask )
{
	int x, y ;
	
	for ( y = pts[Y0]; y <= pts[Y1]; y++ )
	{
		for ( x = pts[X0]; x <= pts[X1]; x++ )
			clut_pixel ( x, y, mask ) ;
	}
}
# else
byte clut_conv_table[3*256] ;	/* 256*r,256*g,256*b	*/

/*----------------------------------------- init_clut_conv ----*/
void init_clut_conv ( int rbits, int gbits, int bbits )
{
	int ilevel ;
	byte *bp ;
	int rfac, gfac, bfac ;
	
	rfac = rbits > 0 ? 255 / ( (256 >> (8-rbits)) - 1 ) : 0 ;
	gfac = gbits > 0 ? 255 / ( (256 >> (8-gbits)) - 1 ) : 0 ;
	bfac = bbits > 0 ? 255 / ( (256 >> (8-bbits)) - 1 ) : 0 ;

	bp = clut_conv_table ;
	for ( ilevel = 0; ilevel < 256; ilevel++ )
		*bp++ = ( ilevel >> ( 8 - rbits ) ) * rfac ;
	for ( ilevel = 0; ilevel < 256; ilevel++ )
		*bp++ = ( ilevel >> ( 8 - gbits ) ) * gfac ;
	for ( ilevel = 0; ilevel < 256; ilevel++ )
		*bp++ = ( ilevel >> ( 8 - bbits ) ) * bfac ;
}


/*----------------------------------------- simulate_tclut ----*/
void simulate_tclut ( int *pts,
						int rbits, int gbits, int bbits )
{
	int x, y ;
	
	init_clut_conv ( rbits, gbits, bbits ) ;

	for ( y = pts[Y0]; y <= pts[Y1]; y++ )
	{
		for ( x = pts[X0]; x <= pts[X1]; x++ )
			clut_tpixel ( x, y, clut_conv_table ) ;
	}
}
# endif

/*----------------------------------------- even_to_odd ----*/
void even_to_odd ( int *pts )
{
	int x, y ;
	long *p, *sp, *dp ;
	
	p = pixel_address ( pts[X0], pts[Y0] ) ;
	for ( y = pts[Y0]; y < pts[Y1]; y+=2 )
	{
		sp = p ;
		(long)dp = (long)p + bytes_per_line ;	/* next line */
		(long)p  = (long)dp + bytes_per_line ;	/* next pair of lines	*/
		for ( x = pts[X0]; x <= pts[X1]; x++ )
			*dp++ = *sp++ ;
	}
}

/*----------------------------------------- draw_frame ----*/
void draw_frame ( int *pts )
{
	set_line_attr ( writing_mode, 1, outline_width, curr_color ) ;

	draw_line4 ( pts[X0], pts[Y0], pts[X0], pts[Y1] ) ;	/*	left	*/
	draw_line4 ( pts[X0], pts[Y1], pts[X1], pts[Y1] ) ;	/*	bottom	*/
	draw_line4 ( pts[X0], pts[Y0], pts[X1], pts[Y0] ) ;	/*	top		*/
	draw_line4 ( pts[X1], pts[Y0], pts[X1], pts[Y1] ) ;	/*	right	*/
}


/*----------------------------------------- rect_slope ----*/
void rect_slope ( int *pts,
				 unsigned char *topleft,
				 unsigned char *topright,
				 unsigned char *bottomleft,
				 unsigned char *bottomright )
/*
			  -- hor. color -->
			0-------------------X
 vert.  |	|					|
 color  |	|					|
	    v	|					|
			Y-------------------+
*/
{
	int dx, dy, x, y, ddx, ddy ;
	unsigned char rgb[3], start[3], end[3];
	int drgbx[3], dright[3], dleft[3] ;
	
	dx = pts[X1] - pts[X0] + 1 ;
	if ( dx < 0 ) return ;
	dy = pts[Y1] - pts[Y0] + 1 ;
	if ( dy < 0 ) return ;

	dleft[0] = (int)bottomleft[0] - (int)topleft[0] ;
	dleft[1] = (int)bottomleft[1] - (int)topleft[1] ;
	dleft[2] = (int)bottomleft[2] - (int)topleft[2] ;

	dright[0] = (int)bottomright[0] - (int)topright[0] ;
	dright[1] = (int)bottomright[1] - (int)topright[1] ;
	dright[2] = (int)bottomright[2] - (int)topright[2] ;

	for ( y = pts[Y0]; y <= pts[Y1]; y++ )
	{
		ddy = y - pts[Y0] ;
		start[0] = topleft[0]  + iscale ( ddy, dleft[0],  dy ) ;
		start[1] = topleft[1]  + iscale ( ddy, dleft[1],  dy ) ;
		start[2] = topleft[2]  + iscale ( ddy, dleft[2],  dy ) ;

		end[0]	 = topright[0] + iscale ( ddy, dright[0], dy ) ;
		end[1]	 = topright[1] + iscale ( ddy, dright[1], dy ) ;
		end[2]	 = topright[2] + iscale ( ddy, dright[2], dy ) ;

		drgbx[0] = (int)end[0] - (int)start[0] ;
		drgbx[1] = (int)end[1] - (int)start[1] ;
		drgbx[2] = (int)end[2] - (int)start[2] ;

		for ( x = pts[X0]; x <= pts[X1]; x++ )
		{
			ddx = x - pts[X0] ;
			rgb[0] = start[0] + iscale ( ddx, drgbx[0], dx ) ;
			rgb[1] = start[1] + iscale ( ddx, drgbx[1], dx ) ;
			rgb[2] = start[2] + iscale ( ddx, drgbx[2], dx ) ;
			set_pixel ( x, y, rgb ) ;
		}
	}
}


/*----------------------------------------- rect_slope ----*/
void rect_rgb_slope ( int *pts, int *rgbs )
/*
	pts :	+0 : left	x0
			+1 : top	y0
			+2 : right	x1
			+3 : bottom	y1

	rgbs : 	+0 : topleft
			+3 : topright
			+6 : bottomleft
			+9 : bottomright

			  -- hor. color -->
			0-------------------X
 vert.  |	|					|
 color  |	|					|
	    v	|					|
			Y-------------------+
*/
{
	int dx, dy, x, y, ddx, ddy ;
	int rgb[3], start[3], end[3] ;
	int drgbx[3], dright[3], dleft[3] ;
	
	dx = pts[2] - pts[0] + 1 ;
	if ( dx < 0 ) return ;
	dy = pts[3] - pts[1] + 1 ;
	if ( dy < 0 ) return ;

	dleft[R] = rgbs[6+R] - rgbs[0+R] ;	/* bottomleft - topleft	*/
	dleft[G] = rgbs[6+G] - rgbs[0+G] ;
	dleft[B] = rgbs[6+B] - rgbs[0+B] ;

	dright[R] = rgbs[9+R] - rgbs[3+R] ;	/* bottomright - topright	*/
	dright[G] = rgbs[9+G] - rgbs[3+G] ;
	dright[B] = rgbs[9+B] - rgbs[3+B] ;

	for ( y = pts[1]; y <= pts[3]; y++ )
	{
		ddy = y - pts[1] ;
		start[R] = rgbs[0+R]  + iscale ( ddy, dleft[R],  dy ) ;
		start[G] = rgbs[0+G]  + iscale ( ddy, dleft[G],  dy ) ;
		start[B] = rgbs[0+B]  + iscale ( ddy, dleft[B],  dy ) ;

		end[R]	 = rgbs[3+R] + iscale ( ddy, dright[R], dy ) ;
		end[G]	 = rgbs[3+G] + iscale ( ddy, dright[G], dy ) ;
		end[B]	 = rgbs[3+B] + iscale ( ddy, dright[B], dy ) ;

		drgbx[R] = (int)end[R] - (int)start[R] ;
		drgbx[G] = (int)end[G] - (int)start[G] ;
		drgbx[B] = (int)end[B] - (int)start[B] ;

		for ( x = pts[0]; x <= pts[2]; x++ )
		{
			ddx = x - pts[0] ;
			rgb[R] = start[R] + iscale ( ddx, drgbx[R], dx ) ;
			rgb[G] = start[G] + iscale ( ddx, drgbx[G], dx ) ;
			rgb[B] = start[B] + iscale ( ddx, drgbx[B], dx ) ;
			vs_pixrgb ( vdi_handle, x, y, rgb ) ;
		}
	}
}

/*----------------------------------------- rgb_slope ----*/
void rgb_slope ( int *pts )
/*
			  -- hor. color -->
			0-------------------X
 vert.  |	|					|
 color  |	|					|
	    v	|					|
			Y-------------------+
*/
{
	unsigned char bottomleft[3], bottomright[3],
			 	  topleft[3], topright[3] ;
	
	get_tcpixel ( pts[X0], pts[Y0], topleft     ) ;
	get_tcpixel ( pts[X1], pts[Y0],	topright    ) ;
	get_tcpixel ( pts[X0], pts[Y1], bottomleft  ) ;
	get_tcpixel ( pts[X1], pts[Y1], bottomright ) ;

	rect_slope ( pts,
				 topleft,	  topright,
				 bottomleft, bottomright ) ;
	if ( with_outlines )
		draw_frame ( pts ) ; 
}

/*----------------------------------------- max_histo ----*/
uword max_histo ( uword *data, int n )
{
	uword maxi ;
	
	maxi = 0 ;
	while ( n-- > 0 )
	{
		if ( *data > maxi )
			maxi = *data ;
		data++ ;
	}
	return maxi ;
}


/*----------------------------------------- get_histo ----*/
void get_histo ( int *pts,
				 uword *data )
{
	int i, x, y ;
	unsigned char rgb[3] ;

	for ( i = 0; i < 256; i++ )
		data[i] = 0 ;

	for ( y = pts[Y0]; y <= pts[Y1]; y++ )
	{ 
		for ( x = pts[X0]; x <= pts[X1]; x++ )
		{
			get_tcpixel ( x, y, rgb ) ;
			data[ (rgb[R]+rgb[G]+rgb[B])/3 ] += 1 ;
		}
	}
}

/*----------------------------------------- get_rgb_histo ----*/
void get_rgb_histo ( int *pts,
				 uword *data )
{
	int i, x, y ;
	unsigned char rgb[3] ;

	for ( i = 0; i < 3*256; i++ )
		data[i] = 0 ;

	for ( y = pts[Y0]; y <= pts[Y1]; y++ )
	{ 
		for ( x = pts[X0]; x <= pts[X1]; x++ )
		{
			get_tcpixel ( x, y, rgb ) ;
			data[ 		rgb[R] ] += 1 ;
			data[ 256 + rgb[G] ] += 1 ;
			data[ 512 + rgb[B] ] += 1 ;
		}
	}
}

/*------------------------------------------------------ get_line_histo --*/
int get_line_histo ( int *pts, uword *data )
{
	int dx, dy ;

	int i, d ;
	int dx_diag, dy_diag ;
	int diag_inc, nondiag_inc, swap ;
	int diag, nondiag ;
	byte *pa ;
	int gofs, bofs ;

	dx = pts[X1] - pts[X0] ;
	dy = pts[Y1] - pts[Y0] ;
	
	if ( dx < 0 )
	{
		dx = -dx ;
		dx_diag = -4 ;
	}
	else
		dx_diag = 4 ;
		
	if ( dy < 0 )
	{
		dy	 = -dy ;
		dy_diag = - bytes_per_line ;
	}
	else
		dy_diag =  bytes_per_line ;
		
	diag = dx_diag + dy_diag ;

	if ( dx < dy )
	{
		swap = dx ;			/* swap dx <-> dy	!!	*/
		dx = dy ;
		dy = swap ;
		nondiag = dy_diag ;
	}
	else
	{
		nondiag = dx_diag ;
	}

	nondiag_inc = dy << 1 ;
	d = nondiag_inc - dx ;
	diag_inc = d - dx ;
	
	pa = (byte *)pixel_address ( pts[X0], pts[Y0] ) ;

	gofs = dx + 1 ;
	bofs = 2 * gofs ;
	
	for ( i = 0 ; i <= dx; i++ )
	{
		data[ 		 i ] = ((byte *)pa)[1+R] ;
		data[ gofs + i ] = ((byte *)pa)[1+G] ;
		data[ bofs + i ] = ((byte *)pa)[1+B] ;

		if ( d < 0 )
		{
			pa += nondiag ;
			d += nondiag_inc ;
		}
		else
		{
			pa += diag ;
			d += diag_inc ;
		}
	}
	return gofs ;
}


long rainbow_colors[7*256] ;
int  rainbow_rgbs[3*7*256] ;

/*----------------------------------------- init_rainbow ----*/
void init_rainbow ( void )
{
	int colix, state ;
	unsigned char rgb[3], up, dn, *out ;
	int *rgbc ;
# define r rgb[R]
# define g rgb[G]
# define b rgb[B]
	
	out  = (unsigned char *) rainbow_colors ;
	rgbc = rainbow_rgbs ;
	
	for ( colix = 0; colix < 7*256; colix++ )
	{
		state = colix >> 8 ;
		up    = colix & 255 ;
		dn	  = 255 - up ;
		switch ( state )
		{
case 0 :	r =  up ; g =   0 ; b =   0 ; break ; /* 0 000  100 */
case 1 : 	r = 255 ; g =  up ; b =   0 ; break ; /* 1 100  110 */
case 2 : 	r =  dn ; g = 255 ; b =   0 ; break ; /* 2 110  010 */
case 3 : 	r =   0 ; g = 255 ; b =  up ; break ; /* 3 010  011 */
case 4 :   	r =   0 ; g =  dn ; b = 255 ; break ; /* 4 011  001 */
case 5 : 	r =  up ; g =   0 ; b = 255 ; break ; /* 5 001  101 */
# if 0
case 6 : 	r = 255 ; g =  up ; b = 255 ; break ; /* 6 101  111 */
# else			/* last color : back to black */
case 6 : 	r =  dn ; g =   0 ; b =  dn ; break ; /* 6 101  000 */
# endif
		}
		*out++ = 0 ;
		*out++ = r ;
		*out++ = g ;
		*out++ = b ;
		*rgbc++ = scale ( r, 1000, 255 ) ;
		*rgbc++ = scale ( g, 1000, 255 ) ;
		*rgbc++ = scale ( b, 1000, 255 ) ;

	}
	
}


/*----------------------------------------- lines_box ----*/
void lines_box ( int *pts )
{
	int x0, x1, d, color, n ;
	
	color = 0 ;
	n = 0 ;
	set_fill_attr ( FIS_SOLID, 1, color, 0  ) ;

	for ( n = 0, d = 1, x0 = pts[X0]; ; )
	{
		x1 = x0 + d ;
		if ( x1 > pts[X1] )
			break ;
		
		if ( ( n++ & 15 ) == 15 )
			d++ ;

		color = 1 - color ;
		vsf_color ( vdi_handle, color ) ;
		filled_box ( x0, pts[Y0], d, pts[Y1]-pts[Y0] ) ;
		x0 = x1 ;
	}
}


/*----------------------------------------- rain_bow ----*/
void rain_bow ( int *pts )
/*
			  -- hor. color -->
			+-------------------+
 			|					|
 			|					|
			|					|
			+-------------------+
*/
{
	int dx1, dy ;
	int ptsl[4] ;

	dx1 = pts[X1] - pts[X0] ;
	if ( dx1 <= 0 ) return ;
	dy = pts[Y1] - pts[Y0] + 1 ;
	if ( dy < 0 ) return ;

	ptsl[Y0] = pts[Y0] ;
	ptsl[Y1] = pts[Y1] ;

	vswr_mode ( vdi_handle, MD_REPLACE ) ;
	vsl_type  ( vdi_handle, 1 ) ;
	vsl_width ( vdi_handle, 1 ) ;
	
	for ( ptsl[X0] = pts[X0]; ptsl[X0] <= pts[X1]; ptsl[X0]++ )
	{
		ptsl[X1] = ptsl[X0] ;
		vsl_rgb ( vdi_handle, &rainbow_rgbs[ 3 * iscale ( ptsl[X0] - pts[X0], 7*256-1, dx1 ) ] ) ;
		v_pline ( vdi_handle, 2, ptsl ) ;
	}
	if ( with_outlines )
		draw_frame ( pts ) ; 
}

/*---------------------------------------------------- draw_line4 ---*/
void draw_line4 ( int x, int y, int x1, int y1 )
{
	int pxy[4] ;

	pxy[0] = x ;
	pxy[1] = y ;
	pxy[2] = x1 ;
	pxy[3] = y1 ;

	v_pline( vdi_handle, 2, pxy ) ;
}


/*---------------------------------------------------- draw_linep ---*/
void draw_linep ( int *pts )
{
	v_pline( vdi_handle, 2, pts ) ;
}

# define swap(a,b)	h=a;a=b;b=h

/*---------------------------------------------------- draw_cross ---*/
void draw_cross ( int *pts )
{
	int h ;
	
	v_pline( vdi_handle, 2, pts ) ;
	swap ( pts[X0], pts[X1] ) ;
	v_pline( vdi_handle, 2, pts ) ;
	swap ( pts[X0], pts[X1] ) ;
}


/*---------------------------------------------------- draw_rect ---*/
void draw_rect ( int *pts )
{
	int pxy[10] ;

	pxy[0] = pts[X0] ;
	pxy[1] = pts[Y0] ;
	pxy[2] = pts[X1] ;
	pxy[3] = pts[Y0] ;
	pxy[4] = pts[X1] ;
	pxy[5] = pts[Y1] ;
	pxy[6] = pts[X0] ;
	pxy[7] = pts[Y1] ;
	pxy[8] = pts[X0] ;
	pxy[9] = pts[Y0] ;


	v_pline( vdi_handle, 5, pxy ) ;
}

