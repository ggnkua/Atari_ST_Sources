#include <vdi.h>
#include <aes.h>
#include <stdlib.h>
#include <math.h>

#include <global.h>
#include <vdi_ext.h>
# include "\pc\cxxsetup\poti.h"
#include <fast.h>

# include "\pc\cxxsetup\aesutils.h"
# include "\pc\cxxsetup\main.h"
# include "\pc\cxxsetup\draw.h"
# include "\pc\cxxsetup\screen.h"

# include <beauty.h>

# include "colors.h"
# include "drawwind.h"
# include "drawutil.h"
# include "effects.h"
# include "text.h"

# include "basics.h"

/*--------------------------------------------- buffer_ok ----------*/
bool buffer_ok ( void )
{
	if ( ! buffer_allocated )
	{
		info_printf ( MSGnoBackBuffer ) ;
		return FALSE ;
	}
	else
		return TRUE ;
}

/*--------------------------------------------- sort_pts ----------*/
void sort_pts ( int *pts )
{
	int h ;

	if ( pts[X0] > pts[X1] )	/* swap x	*/
	{
		h = pts[X0] ;
		pts[X0] = pts[X1] ;
		pts[X1] = h ;
	}
					
	if ( pts[Y0] > pts[Y1] )	/* swap y	*/
	{
		h = pts[Y0] ;
		pts[Y0] = pts[Y1] ;
		pts[Y1] = h ;
	}
}


/*--------------------------------------------- save_p0p1 ----------*/
void save_p0p1 ( int *pts )
{
	RECTangle active ;

	if ( ! buffer_ok() )
		return ;

	sort_pts ( pts ) ;
	
	active.x = pts[X0] ;
	active.y = pts[Y0] ;
	active.w = pts[X1] - pts[X0] + 1 ;
	active.h = pts[Y1] - pts[Y0] + 1 ;

	save_window ( &tcdraw_work, &active ) ;
}	

/*-------------------------------------- copy_rectangle ------------*/
void copy_rectangle ( int *srcpts, int *dstpts )
{
	clip_on();
	start_time = get_ticks() ;
	copy_box ( srcpts, dstpts, blit_mode ) ;
	end_time = get_ticks() ; 
	save_p0p1 ( dstpts ) ;
}

/*----------------------------------------- hypothenuse ------------*/
unsigned hypothenuse ( int *pts )
{
	ulong w, h ;
	
	w = pts[X1]-pts[X0]+1 ;
	h = pts[Y1]-pts[Y0]+1 ;
	return (unsigned) sqrt ( w*w + h*h ) ;
}


/*---------------------------------------------------------- set_curr_fill_attr ---*/
void set_curr_fill_attr ( void )
{
	vswr_mode ( vdi_handle, writing_mode ) ;      
	vsf_interior ( vdi_handle, interior ) ;
	vsf_style ( vdi_handle, style ) ;
	if ( is_mattc )
		vsf_rgb ( vdi_handle, curr_fill_rgb ) ;
	else
		vsf_color ( vdi_handle, curr_color ) ;
	vsf_perimeter ( vdi_handle, with_outlines ) ;
}


/*-------------------------------------------- set_invert_attr -----*/
void set_invert_attr ( void )
{
	vswr_mode ( vdi_handle, MD_XOR ) ;      
	vsf_interior ( vdi_handle, SOLID ) ;
	vsf_color ( vdi_handle, BLACK ) ;
	vsf_perimeter ( vdi_handle, 0 ) ;
}

/*-------------------------------------------------------- invert_rect -----*/
void invert_rect ( int *pts )
{
	set_invert_attr() ;
# if 1
	filled_box ( pts[X0], pts[Y0], pts[X1]-pts[X0], pts[Y1]-pts[Y0] ) ;
# else
	filled_box ( pts[X0], pts[Y0], pts[X1]-pts[X0]+1, pts[Y1]-pts[Y0]+1 ) ;
# endif
}

/*--------------------------------------------- DrawText ------------*/
void DrawText ( int *pt, char *s )
{
	vswr_mode ( vdi_handle, writing_mode ) ;
	if ( is_mattc )
		vst_rgb ( vdi_handle, curr_text_rgb ) ;
	else
		vst_color ( vdi_handle, curr_color ) ;
	vst_alignment ( vdi_handle, 0, 5, &dummy, &dummy ) ;
	vst_effects (  vdi_handle, text_effects ) ;
	v_gtext ( vdi_handle, pt[X0], pt[Y0], s ) ;
}
				
/*--------------------------------------------- erase_picture -----*/
void erase_picture ( void )
{
	set_fill_attr ( FIS_SOLID, 1, curr_color, 0  ) ;
	start_time = get_ticks() ;
	filled_box ( canvas.x, canvas.y, canvas.w, canvas.h ) ;
	end_time = get_ticks() ; 
	if ( buffer_ok() )
		save_window ( &tcdraw_work, &canvas ) ;
}


/*-------------------------------------------------------- filled_rectangle -----*/
void filled_rectangle ( int *pts )
{
	set_curr_fill_attr() ;
	filled_box ( pts[X0], pts[Y0], pts[X1]-pts[X0]+1, pts[Y1]-pts[Y0]+1 ) ;
}


/*------------------------------------------------------ circle_function ---*/
void circle_function ( int *pts )
{
	set_curr_fill_attr() ;
	v_circle ( vdi_handle, pts[X0], pts[Y0], radius ( pts ) );
}

/*---------------------------------------------------------- DrawCircle ---*/
void DrawCircle ( int *pts )
{
	v_circle ( vdi_handle, pts[X0], pts[Y0], radius ( pts ) );
}


/*--------------------------------------------- Line ------------*/
void Line ( int *pts )
{
	set_line_attr ( writing_mode, 1, outline_width, curr_color ) ;
	if ( is_mattc )
		vsl_rgb ( vdi_handle, curr_line_rgb ) ;
	else
		vsl_color ( vdi_handle, curr_color ) ;
	if ( keyboard_state ( K_ALT ) )
		line_nalias ( pts, curr_line_rgb ) ;
	else
		draw_linep ( pts ) ;
}


	
/*--------------------------------------------- Fill ------------*/
void Fill ( int *pts, int fillcol )
{
	

	vswr_mode ( vdi_handle, writing_mode ) ;      
	vsf_interior ( vdi_handle, interior ) ;
	vsf_style ( vdi_handle, style ) ;
	if ( is_mattc )
		vsf_rgb ( vdi_handle, curr_fill_rgb ) ;
	else
		vsf_color ( vdi_handle, curr_color ) ;
	vsf_perimeter ( vdi_handle, 0 ) ;

	start_time = get_ticks() ;
	v_contourfill ( vdi_handle, pts[X0], pts[Y0], fillcol ) ;
	end_time = get_ticks() ; 
# if 0
	if ( buffer_ok() )
		save_window ( &tcdraw_work, &canvas ) ;
# endif
}

int mirr_degree[5] = { -1, 0, 45, 90, 135 } ; 

/*--------------------------------------------- Mirror ------------*/
void Mirror ( int *pts )
{
	mirror_rect ( pts, mirr_degree[mirr_mode-MIR_POINT] ) ; 
}


/*----------------------------------- SimulateClut ------------*/
void SimulateClut ( int *pts )
{
# if 0
# define CLUT_MASK(col) ((long)(0xff-(0xff>>clut_masks[col])))
					simulate_clut ( pts,
							( CLUT_MASK(R) << 16 )
						  | ( CLUT_MASK(G) <<  8 )
						  |   CLUT_MASK(B) ) ;
# else
					simulate_tclut ( pts,
							clut_masks[R],	
							clut_masks[G],	
							clut_masks[B] ) ;
# endif
}


/*----------------------------------- DrawFractal ------------*/
void DrawFractal ( int *pts )
{
	ClippingOff ( vdi_handle ) ;

	check_stop_message() ;
	draw_fractal ( 7*256-1, pts[X0], pts[Y0], pts[X1]-pts[X0]+1, pts[Y1]-pts[Y0]+1,
# if 0
					Pmin, Pmax, Qmin, Qmax, M ) ;
					-2.25, 0.75, -1.5, 1.5, 40 ) ;
# else
					-0.74591, -0.74448, 0.11196, 0.11339, 40.0 ) ;
# endif
	info_printf ( "" ) ;
}


/*--------------------------------------------- color_cube ------------*/
void color_cube ( int *pts )
{
	rgb_cube ( pts, color_space ) ;
}



/*......................................................................*/

# define STOPdisabled	0
# define RUNNING		1
# define STOPPED		2

int stop_state = STOPdisabled ;


/*------------------------------------ check_stop_message ------*/
void check_stop_message ( void )
{
	stop_state = RUNNING ;
	info_printf ( " *** Anhalten mit 'Shift'" ) ;
}


/*--------------------------------------------- check_stop ------*/
void check_stop_off ( void )
{
	stop_state = STOPdisabled ;
}


/*--------------------------------------------- check_stop ------*/
bool check_stop ( void )
{
	switch ( stop_state )
	{
 case STOPPED :	return TRUE ;
 case RUNNING :	if ( *keyshift & (K_LSHIFT|K_RSHIFT) )
				{
					info_printf ( " *** Weiter mit 'Alternate', Stop mit 'Control'" ) ;
					for(;;)
					{
						if ( *keyshift & K_CTRL )
						{
							info_printf ( FCTaborted ) ;
							stop_state = STOPPED ;
							return TRUE ;
						}
						if ( *keyshift & K_ALT )
						{
							check_stop_message();
							return FALSE ;
						}
					}
				}
	}
	return FALSE ;
}
					

