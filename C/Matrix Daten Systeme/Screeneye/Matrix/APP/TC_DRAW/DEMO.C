# define DEF_WRITE_MODE	0	/* S xor D 10	*/

# define TEST	0
# define ERASE	1		/* erase lines after drawing	*/
# if TEST
#include <stdio.h>
# endif

#include <stdlib.h>
#include <math.h>
#include <aes.h>
#include <vdi.h>

# include <global.h>

# include "\pc\cxxsetup\aesutils.h"

# include "\pc\tcxx\lib\scr_def.h"
# include "\pc\tcxx\tcxxinfo\tcxx_acc.h"
# include "\pc\tcxx\lib\rgb.h"

# include "\pc\tcxx\kernel\kernfast.h"
# include "\pc\tcxx\kernel\kern_fct.h"

# define ReGrBl void

# include "drawwind.h"
# include "digitise.h"
# include "demo.h"

/* +++++++++++++++++++++++ lines +++++++++++++++++++++++++++++++++++*/

/*.... gp_lib - macros	....*/

# define RAIN_BOW	1

# if RAIN_BOW
extern long rainbow_colors[7*256] ;
# else
long color_table[] =
{
# if 1
	TC_BLACK, TC_RED, TC_YELLOW, TC_GREEN,
# else
	0x808080L, TC_RED, TC_YELLOW, TC_GREEN,
# endif
	TC_CYAN, TC_BLUE, TC_MAGENTA, TC_WHITE,
	-1
} ;
# endif
		/*	 0 1 - runs			*/
		/*	 v v				*/
# define PAT_1_1	0x55555555L				
# define PAT_2_2	0x33333333L				
# define PAT_8_8	0x00ff00ffL				

# define PAT_0		0x00000000L
# define PAT_1		0xffffffffL


# define TC_GREY 0x808080L

long curl_color = TC_GREEN ;

# define COLOR_LEVEL	unsigned
# define NUM_COLORS		8

# if RAIN_BOW
# define gp_def_color(fg)		curl_color = fg ;\
								g_set_wrmode(DEF_WRITE_MODE,TC_BLACK,\
												curl_color)
# else
# define gp_def_colors(fg,bg)	curl_color = color_table[(fg)&7] ; \
								g_set_wrmode(DEF_WRITE_MODE,color_table[(bg)&7],\
												curl_color)
# endif
# define gx_line(x0,y0,x1,y1)	g_line(x0,y0,x1,y1,PAT_1)



# define LINES	1000		/* max. 16384 */
# define DELTA_X	5
# define DELTA_Y	3


# define BOUND 8
# define HEAD_BOUND 24


int xstart[LINES],
	ystart[LINES],
	xend[LINES],
	yend[LINES];

/*----------------------------------------------- gpx_line ---------*/
void gpx_line ( int x, int y, int x1, int y1)
{
	gx_line ( x, y, x1, y1 ) ;
}

/*----------------------------------------------- gdraw_rect -------------*/
void gdraw_rect ( int x, int y, int x1, int y1)
{
	gx_line ( x, y, x1, y ) ;
	gx_line ( x, y, x, y1 ) ;
	gx_line ( x1, y, x1, y1 ) ;
	gx_line ( x, y1, x1, y1 ) ;
}
# if 0
	xy[0] = xy[6] = xy[8] = x ;
	xy[2] = xy[4] = x + w ;
	xy[1] = xy[3] = xy[9] = y ;
	xy[5] = xy[7] = y + h  ;
# endif
# define min(x,y) ((x)<(y)?(x):(y))
# define max(x,y) ((x)>(y)?(x):(y))
# define abs(x)	  ((x)<0?-(x):(x))

/*----------------------------------------------- gx_circle -------------*/
void gx_circle(int x, int y, int x1, int y1)
{
	gx_line ( x, y, x1, y1 ) ;
	gx_line ( x, y1, x1, y ) ;
}

/*----------------------------------------------- gdraw_box -------------*/
void gdraw_box(int x, int y, int x1, int y1)
{
	int dx, dy ;
	
	dx = x1 - x ;
	if ( dx < 0 )
	{
		dx = -dx ;
		x = x1 ;
	}
	dy = y1 - y ;
	if ( dy < 0 )
	{
		dy = -dy ;
		y = y1 ;
	}
# if 0
	dx = (dx+dy) & 127 ;		/* small square	*/
/* # else */
	dx >>= 1 ;
	dy >>= 1 ;
# endif
	g_fill ( x, y, dx, dy, curl_color );
}

	
# if 0
# define NEXT(a,d,l,u,dd) a += d; if(a<l) { d = dd; a = l+l-a ; }\
								else if( a>u ) { d = -dd; a = u+u-a; }
# else
# define NEXT(a,d,l,u,dxy,dd)\
	a += d;\
	if(a<l)\
		{ d = dd; a = l + (int) ( (long)rand()*(long)dxy/65536L ); }\
	else if( a>u )\
		{ d = -dd; a = u - (int) ( (long)rand()*(long)dxy/65536L ); }
# endif

typedef void (*DRAW_FCT)(int x,int y,int x1, int y1) ;


int color = 0 ;

/*------------------------------------------- demo_sequence --------*/
void demo_sequence ( DRAW_FCT drawfct, int dlta, int colinc,
					 long maxfig, int ers,
					 int x0, int y0, int dx, int dy )
{
	int xs, ys, xe, ye, x1, y1 ;
	long figure, drix, erix;

	int dir_xs, dir_ys, dir_xe, dir_ye;
	int delta_x, delta_y ;
		
# if ERASE
	int eraseline ;
# endif
	
	x1 = x0 + dx -1 ;
	y1 = y0 + dy -1 ;
	dir_xs = dir_xe = DELTA_X ;
	dir_ys = dir_ye = DELTA_Y ;

# if ERASE
	eraseline = -ers ;
# endif
	delta_x = dlta*DELTA_X ;
	delta_y = dlta*DELTA_Y ;

	xs = x0 + (int) ( (long)rand()*(long)dx/32768L ) ;
	ys = y0 + (int) ( (long)rand()*(long)dy/32768L ) ;
	xe = x0 + (int) ( (long)rand()*(long)dx/32768L ) ;
	ye = y0 + (int) ( (long)rand()*(long)dy/32768L ) ;


	g_clip ( x0, y0, x1, y1 );

	g_set_gspwrmode ( 0, 0, TC_WHITE, TC_BLACK ) ;
	g_fill ( x0, y0, dx, dy, TC_BLACK ) ;

	for ( drix = 0, figure = 0 ; figure < maxfig
			/* && ! ( ( figure & 0x1ff ) == 0 && kbhit() ) */ ;
			 drix++, figure++ )
	{
		if ( drix == LINES )
		{
			drix = 0 ;
			if ( check_stop() )
				break ;
		}

		NEXT ( xs, dir_xs, x0, x1, dx, delta_x ) ;
		NEXT ( ys, dir_ys, y0, y1, dy, delta_y ) ;
		NEXT ( xe, dir_xe, x0, x1, dx, delta_x ) ;
		NEXT ( ye, dir_ye, y0, y1, dy, delta_y ) ;
			
		xstart[drix] = xs ;
		ystart[drix] = ys ;
		xend[drix]	 = xe ;
		yend[drix]	 = ye ;

# if RAIN_BOW
		color += colinc ;
		if ( color >= 7*256 )
			color = 0 ;
		gp_def_color(rainbow_colors[color]);
# else
		color = (color+delta_x) & 0xFF ;
		gp_def_colors(color,0);
# endif

		(*drawfct)( xs, ys, xe, ye );
	
# if ERASE
								/* erase old line, 'count' lines back */
			if(eraseline>=0)
			{
				erix = (int)(eraseline % LINES) ;
# if RAIN_BOW
				gp_def_color(TC_BLACK);
# else
				gp_def_colors(0,0);
# endif
				(*drawfct)( xstart[erix],ystart[erix],
						 xend[erix],  yend[erix]);
			}
			eraseline++;
# endif						/* draw new line */
	}

	g_clip_off();

} /*- demo_sequence -*/


/*------------------------------------------- demo_function --------------*/
void demo_function ( int demo, int count, int erase_set,
					 int x0, int y0, int dx, int dy )
{
	switch ( demo )
	{
	case 1 :	demo_sequence ( gpx_line,   1,  2, count, erase_set, x0, y0, dx, dy ) ;
				break ;
				
	case 2 :	demo_sequence ( gx_circle,  1,  4, count, erase_set, x0, y0, dx, dy  ) ;
				break ;
				
	case 3 :	demo_sequence ( gdraw_rect, 1,  8, count, erase_set, x0, y0, dx, dy  ) ;
				break ;
				
	case 4 :	demo_sequence ( gdraw_box, 19, 32, count, erase_set, x0, y0, dx, dy  ) ;
				break ;
	}
}


/*----------------------------------- run_demo ---------------------*/
int run_demo ( int demo, int count, int erase_set, int *pts )
{
	int result ;

	if ( ( result = g_check_init() ) == OK )
	{
		switch_vdi ( 0 ) ;
						
		demo_function ( demo, count, erase_set,
					pts[0], pts[1],
					pts[2]-pts[0]+1, pts[3]-pts[1]+1 ) ;
		switch_vdi ( 1 ) ;
	}

	
	return result ;
}

