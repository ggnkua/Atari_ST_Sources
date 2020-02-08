#include <vdi.h>
#include <aes.h>
#include <ext.h>

#include <global.h>

# include "\pc\cxxsetup\aesutils.h"

# include "drawwind.h"
# include "updown.h"

# include "\pc\tcxx\tcxx.lib\tcxxfast.h"
# include "\pc\tcxx\kernel\kernfast.h"
# include "\pc\tcxx\kernel\kern_fct.h"

# include "digitise.h"
# include "filter.h"
# include "mfilter.h"


/*... filter ...*/

# define MAXgrayLevel	255

# define MATdimension	0
# define MATscale		1
# define MAToffset		2
# define MATmodifier	3
# define MATcoeff		4

# define filter_matrix(name,dim,scale,ofs) int name[MATcoeff+dim*dim] = \
						{ dim, scale, ofs,
# define filter_end				 }

filter_matrix ( median5x5_filter, 5, 13, 0 )
  0,  0,  1,  0,  0,
  0,  1,  1,  1,  0,
  1,  1,  1,  1,  1,
  0,  1,  1,  1,  0,
  0,  0,  1,  0,  0
filter_end ;

# define filter3x3_matrix(name,scale,ofs,modi,m00,m01,m02,m10,m11,m12,m20,m21,m22) \
int name[MATcoeff+3*3] = { 3, scale, ofs, modi, \
							 m00,m01,m02,m10,m11,m12,m20,m21,m22 }

filter3x3_matrix ( median3x3_filter, 5, 0, 0,
  0,  1,  0,
  1,  1,  1,
  0,  1,  0
) ;

filter3x3_matrix ( gauss_filter, 16, 0, 0,
  1,  2,  1,
  2,  4,  2,
  1,  2,  1
) ;

filter3x3_matrix ( x_grad_filter, -8, 0, 0,
  -1, 0, -1,
  -2, 0, -2,
  -1, 0, -1
) ;

filter3x3_matrix ( y_grad_filter, -8, 0, 0,
  -1, -2, -1,
   0,  0,  0,
  -1, -2, -1
) ;

filter3x3_matrix ( enhance_filter, 1, 0, 0,
  0, -1,  0,
 -1,  5, -1,
  0, -1,  0
) ;

filter3x3_matrix ( sobel_filter, 3, 0, 1,
  0,  1,  2,
 -1,  0,  1,
 -2, -1,  0
) ;

filter3x3_matrix ( laplace_filter, 3, 0, 1,
 -1, -1, -1,
 -1,  8, -1,
 -1, -1, -1
) ;

filter3x3_matrix ( user_filter, 1, 0, 0,
  0,  0,  0,
  0,  1,  0,
  0,  0,  0
) ;


int *(filters[]) =
{
	median5x5_filter,
	median3x3_filter,
	gauss_filter,
	x_grad_filter,
	y_grad_filter,
	enhance_filter,
	sobel_filter,
	laplace_filter, 
	user_filter, 
	NULL
} ;

int selected_matrix = 0 ;

UP_DOWN_VALUE updown_matrix[USERdimension*USERdimension] ;
UP_DOWN_VALUE updown_offset, updown_scale  ;


/*----------------------------------------- init_filters ----------*/
void init_filters ( void )
{
# if 0
	int **pfilter, *filter, *coeff  ;
	int n, neg, pos ;

	pfilter = filters ;
	while ( ( filter = *pfilter++ ) != NULL )
	{
		neg = pos = 0 ;
		coeff = &filter[MATcoeff] ;
		for ( n = filter[MATdimension] * filter[MATdimension];
					n > 0 ; n-- )
		{
			if ( *coeff > 0 )
				pos += *coeff ;
			else if ( *coeff < 0 )
				neg += *coeff ;
			coeff++ ;
		}
		filter[MATscale] = pos - neg ;
		filter[MAToffset] = -neg * MAXgrayLevel ;
	}
# endif
}


/*-------------------------------------------- filter_info ---------*/
void filter_info ( void )
{
	int *filter ;
	
	filter = filters[selected_matrix] ;
	info_printf ( " filter # %d, offset %d, scale %d, modifier %d",
			selected_matrix,
			filter[MAToffset], filter[MATscale] , filter[MATmodifier] ) ;
}


/*----------------------------------------- filter_copy ----------*/
void filter_copy ( void )
{
	UP_DOWN_VALUE *updown ;
	int n, *filter, *coeff ;

	filter = filters[selected_matrix] ;
	if ( filter[MATdimension] == USERdimension )
	{
		filter_info() ;

		updown = updown_matrix ;
		coeff  = &filter[MATcoeff] ;
		for ( n = filter[MATdimension] * filter[MATdimension];
					n > 0 ; n-- )
		{
			update_updown ( updown++, *coeff++ ) ;
		}
		update_updown ( &updown_offset, filter[MAToffset] ) ;
		update_updown ( &updown_scale,  filter[MATscale]  ) ;
# if 0
		update_updown ( &updown_modifier,  filter[MATmodifier]  ) ;
# else
		user_filter[MATmodifier] = filter[MATmodifier] ;
# endif
	}
	else
		info_printf ( "Matrix zu grož ( <= %d x %d ! )", USERdimension, USERdimension ) ;
}


/*----------------------------------------- init_user_filter ----------*/
void init_user_filter ( int m00, int ofsobj, int scaleobj )
{
	UP_DOWN_VALUE *updown ;
	int n, *filter, *coeff  ;
	int obj ;

	updown = updown_matrix ;
	filter = user_filter ;
	obj = m00 ;
	coeff = &filter[MATcoeff] ;
	for ( n = filter[MATdimension] * filter[MATdimension];
				n > 0 ; n-- )
	{
		init_updown ( updown++, tcdraw_tree, obj, coeff++, "%3d" ) ;
		obj += 4 ;
	}
	init_updown ( &updown_offset, tcdraw_tree, ofsobj, &filter[MAToffset],"+%3d" ) ;
	init_updown ( &updown_scale,  tcdraw_tree, scaleobj,  &filter[MATscale],"/%3d"  ) ;
}


/*----------------------------------------- filter_rect ----*/
void filter_rect ( int *pts, int *matrix )
{
	int n ;
	
	if ( keyboard_state ( K_ALT ) )
	{
		info_printf ( "GSP" ) ;
		if ( g_check_init ( ) == OK )
			g_matrix_filter ( pts[X0], pts[Y0], pts[X1]-pts[X0]-1, pts[Y1]-pts[Y0]-1,
												matrix ) ;
# if 0
		for ( n = 20 ; n > 0 && ! g_ready() ; n-- )
			;
# else
		for ( n = 10000 ; n > 0 ; n-- )
		{
			if ( ! g_busy() )
				break ;
			delay ( 10 ) ;
		}
# endif
	}
	else
	{
		info_printf ( "CPU" ) ;
		matrix_filter ( pixel_address ( pts[X0], pts[Y0] ), matrix,
					pts[X1]-pts[X0]-1, pts[Y1]-pts[Y0]-1, bytes_per_line ) ;
	}
}

