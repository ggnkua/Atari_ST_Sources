# define TEST 0
# if TEST
#include <stdio.h>
# endif
#include <aes.h>
#include <vdi.h>

#include <global.h>
#include <vdi_ext.h>

# include "\pc\cxxsetup\aesutils.h"
# include "\pc\cxxsetup\main.h"
# include "\pc\cxxsetup\dialog.h"
# include "\pc\cxxsetup\draw.h"
# include "\pc\cxxsetup\poti.h"

# include "tc_draw.h"
# include "colors.h"
# include "text.h"
# include "drawwind.h"

# include "drawutil.h"


/*-------------------------------------- fill_object ------------*/
void fill_object ( OBJECT *tree, int objn, int color )
{
	RECTangle bigbox ;
	
	ObjectGetRectangle ( tree, objn, bigbox ) ;
	set_fill_attr ( FIS_SOLID, 1, color, 0 ) ;
	draw_box ( color, FIS_SOLID, 1, VALrect ( bigbox ) ) ;
}

# if 0
/*-------------------------------------- fill_object_rgb ------------*/
void fill_object_rgb ( OBJECT *tree, int objn, int *rgb )
{
	RECTangle bigbox ;
	
	ObjectGetRectangle ( tree, objn, bigbox ) ;
	vswr_mode(vdi_handle,MD_REPLACE);      
	vsf_interior(vdi_handle,FIS_SOLID);
	vsf_perimeter(vdi_handle,0);
	vsf_rgb ( vdi_handle, rgb ) ;
	filled_box ( VALrect ( bigbox ) ) ;
}
# endif


# if 0
/*----------------------------------------- in_side ---------*/
bool in_side ( int x, int y, RECTANGLE *rect )
{
	return (	x >= rect.x && y >= rect.y
			 && x < rect.x + rect.w || y < rect.y + rect.h ) ;
}
# endif

/*----------------------------------------------- snap_x_y -----*/
int snap_x_y ( int *xy, int base, int max, int multiple, int round )
{
	int xyout ;
	int result ;
# if TEST
	printf ( "snap_x_y : in=%3d, base=%3d, may=%4d, mul=%2d, round=%2d",
		 *xy, base, max, multiple, round ) ;
# endif
	
	xyout = *xy ;
	switch ( round )
	{
case +1 :	xyout += multiple - 1 ;		break ;	/* up	*/
case  0 :	xyout += multiple >> 1 ;	break ;	/* mid	*/
case -1 :								break ;	/* down */
	}
	xyout -= base ;
	if ( xyout < 0 )
	{
		*xy = base ;
		result = -1 ;
	}
	else
	{
		if ( xyout > max )
		{
			xyout = max ;
			result = +1 ;
		}
		else
			result = 0 ;
		*xy = base + xyout / multiple * multiple ;
	}
# if TEST
	printf ( ", out=%3d, res=%2d\n", *xy, result ) ;
# endif
	return result ;
}

/*----------------------------------------------- snap_xcanv -----*/
int snap_xcanv ( int *x, int round )
{
	return snap_x_y(x,canvas.x,canvas.x+canvas.w-1,
						snap_grid ? grid_width.x : 1,round) ;
}

/*----------------------------------------------- snap_ycanv -----*/
int snap_ycanv ( int *y, int round )
{
	return snap_x_y(y,canvas.y,canvas.y+canvas.h-1,
						snap_grid ? grid_width.y : 1,round) ;
}

/*----------------------------------------------- snap_ycanv -----*/
void snap_xy2_canv ( int *pts )
{
# if TEST
	printf ( "in  : %4d,%4d, %4d, %4d\n", pts[X0], pts[Y0], pts[X1], pts[Y1] ) ;
# endif
	snap_xcanv ( &pts[X0], +1 ) ;
	snap_ycanv ( &pts[Y0], +1 ) ;
	snap_xcanv ( &pts[X1], -1 ) ;
	snap_ycanv ( &pts[Y1], -1 ) ;
# if TEST
	printf ( "out : %4d,%4d, %4d, %4d\n", pts[X0], pts[Y0], pts[X1], pts[Y1] ) ;
# endif
}

/*----------------------------------------------- clip_grid ------*/
void clip_grid ( int *pts, int *npts )
/*				start pos for quad, mouse pos		*/
{
	int d ;
	
	if ( quadrat && pts[X0] >= 0 )
	{
		d = (npts[X0] - pts[X0]) + (npts[Y0] - pts[Y0]) / 2 ;
		npts[X0] = pts[X0] + d ;						/* new end points	*/
		npts[Y0] = pts[Y0] + d ;
											/* snap end points	*/
		switch ( snap_xcanv ( &npts[X0], 0 ) + snap_ycanv ( &npts[Y0], 0 ) )
		{
	case    0 : return ;							/* ok			*/
	case +1*2 :	d = min ( npts[X0] - pts[X0], npts[Y0] - pts[Y0] ) ;	/* overflow		*/
				break ;
	case -1*2 :	d = min ( npts[X0] - pts[X0], npts[Y0] - pts[Y0] ) ;	/* underflow	*/
				break ;
		}
		npts[X0] = pts[X0] + d ;
		npts[Y0] = pts[Y0] + d ;
	}
	else if ( snap_grid )
	{
		if ( grid_width.x > 1 )
			snap_xcanv ( &npts[X0], 0 ) ;
		if ( grid_width.y > 1 )
			snap_ycanv ( &npts[Y0], 0 ) ;
	}
	else	/* clip position	*/
	{
		if ( npts[X0] < canvas.x )
			npts[X0] = canvas.x ;
		else if ( npts[X0] >= canvas.x + canvas.w )
			npts[X0] = canvas.x + canvas.w - 1 ;
		if ( npts[Y0] < canvas.y )
			npts[Y0] = canvas.y ;
		else if ( npts[Y0] >= canvas.y + canvas.h )
			npts[Y0] = canvas.y + canvas.h - 1 ;
	}
}


/*----------------------------------------------- mouse_move -----*/
bool mouse_move ( int *pts, int *buttons, bool clip )
{
	int dummy ;
	int npts[2] ;
	
	graf_mkstate ( &npts[X0], &npts[Y0], buttons, &dummy ) ;

	if ( clip )
		clip_grid ( pts, npts ) ;

	if ( npts[X0] != pts[X0] || npts[Y0] != pts[Y0] )
	{
		pts[X0] = npts[X0] ;
		pts[Y0] = npts[Y0] ;
		return ( TRUE ) ;
	}
	else if ( *buttons & BOTH_BUTTONS )
		return ( TRUE ) ;
	else
		return ( FALSE ) ;
}
	


/*----------------------------------------- get_position --*/
int get_position ( int *pts, char *info )
/*
	info_format = "..text.. %3d:%3d"
*/
{
	int buttons ;

	release_button();

	pts[X0] = pts[Y0] = 0 ;

	WindMouseBegin() ;
	do
	{
		if ( mouse_move ( pts, &buttons, FALSE ) )
			info_printf ( " %3d:%3d - %s", pts[X0], pts[Y0], info ) ;
	}
	while ( ! ( buttons & BOTH_BUTTONS ) ) ;
	WindMouseEnd() ;

	if ( buttons & RIGHT_BUTTON )
		info_printf ( FCTaborted ) ;

# if 0
	if ( inside_work ( pts[X0], pts[Y0] ) )
# endif
		release_button() ;
	return buttons ;
}

/*... pattern ... */

int pattern = DEFpattern ;
int interior ;
int style ;

struct POTIstruct pattern_poti =
	 { NULL, PO_PATT, &pattern, MINpattern, MAXpattern, MAXpattern, DEFpattern, 0, NULL, update_pattern, NULL } ;


/*--------------------------------------- set_fill_pattern ----------*/
void set_fill_pattern ( void )

{
	if ( pattern == 0 )
	{
		interior = FIS_HOLLOW ;	/*	vsf_interior	*/
		style = 0 ;				/*	vsf_style		*/
	}
	else if ( pattern == 1 )
	{
		interior = FIS_SOLID ;
		style = 0 ;
	}
	else if ( pattern <= 25 )
	{
		interior = FIS_PATTERN ;
		style = pattern - 1 ;
	}
	else	/* pattern <= 38	*/
	{
		interior = FIS_HATCH ;
		style = pattern - 25 ;
	}
}


/*--------------------------------------- update_pattern ----------*/
void update_pattern(void)
{
	ObjectDraw ( tcdraw_tree, BX_PATT ) ;
}

