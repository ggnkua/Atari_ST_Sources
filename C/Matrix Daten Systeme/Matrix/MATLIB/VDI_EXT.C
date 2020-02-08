#include <aes.h>
#include <vdi.h>

# include "vdi_ext.h"
# include "vdi_bind.h"


int     contrl [ 12 ];
int     intin  [ 128 ];
int     ptsin  [ 512 ];
int     intout [ 10 ];
int     ptsout [ 10 ];

/*.... color palette setting ......................................*/

void vs_colors ( int handle, int from, int to,
						int *rgb_table )
{
	set_contrl(64,0,0,4,0,0,handle) ;

	intin[0] = from ;
	intin[1] = to ;
	set_ptr(2,rgb_table,int) ;

	callvdi();
}

void vq_colors ( int handle, int from, int to,
			     int set_flag, int *rgb_table )
{
	set_contrl(65,0,0,5,0,0,handle) ;

	intin[0] = from ;
	intin[1] = to ;
	intin[2] = set_flag ;
	set_ptr(3,rgb_table,int) ;

	callvdi();
}


/*	get a palette sequence	*/

/*...... calibration ..............................................*/
	
int vs_calibrate(int handle, int *table, int onoff)
{
	set_contrl(VDIescape,0,0,1,1,76,handle) ;

	intin[0] = (int)(((long)table) & 0x0000FFFFL);
	intin[1] = (int)((((long)table) & 0xFFFF0000L) >> 16);
	intin[2] = onoff;

	callvdi();

	return intout[0];
}


int vq_calibrate(int handle)
{
	set_contrl(VDIescape,0,0,0,1,77,handle) ;

	callvdi();

	return intout[0];
}

/*.................................................................*/


/*..... vs<x>_rgb .....*/	

void vsf_rgb ( int handle, int *rgb )
{
	set_contrl ( 51, 0, 0, 3, 0, 0, handle ) ;
	set_rgb ( rgb ) ;
	callvdi();
}
	
void vst_rgb ( int handle, int *rgb )
{
	set_contrl ( 52, 0, 0, 3, 0, 0, handle ) ;
	set_rgb ( rgb ) ;
	callvdi();
}
	
void vsl_rgb ( int handle, int *rgb )
{
	set_contrl ( 53, 0, 0, 3, 0, 0, handle ) ;
	set_rgb ( rgb ) ;
	callvdi();
}



/*..... vq<x>_rgb .....*/	

void vrf_rgb ( int handle, int *rgb )
{
	set_contrl ( 54, 0, 0, 0, 3, 0, handle ) ;

	callvdi();

	get_rgb ( rgb ) ;
}

void vrt_rgb ( int handle, int *rgb )
{
	set_contrl ( 55, 0, 0, 0, 3, 0, handle ) ;

	callvdi();

	get_rgb ( rgb ) ;
}

void vrl_rgb ( int handle, int *rgb )
{
	set_contrl ( 56, 0, 0, 0, 3, 0, handle ) ;

	callvdi();

	get_rgb ( rgb ) ;
}


/*..... vs/q_pixcol/rgb .....*/	

void vs_pixcol ( int handle, int x, int y,	int vdi_ix )
{
	set_contrl ( 57, 1, 0, 1, 0, 0, handle ) ;
	set_point ( x, y ) ;
	intin[0] = vdi_ix ;

	callvdi();
}

void vq_pixcol ( int handle, int x, int y,
						int *phys_ix, int *vdi_ix )
{
	set_contrl ( 58, 1, 0, 0, 2, 0, handle ) ;
	set_point ( x, y ) ;

	callvdi();

	*phys_ix = intout[0] ;
	*vdi_ix  = intout[1] ;
}

void vs_pixrgb ( int handle, int x, int y, int *rgb )
{
	set_contrl ( 59, 1, 0, 3, 0, 0, handle ) ;
	set_point ( x, y ) ;
	set_rgb ( rgb ) ;

	callvdi();
}

void vq_pixrgb ( int handle, int x, int y, int *rgb )
{
	set_contrl ( 60, 1, 0, 0, 3, 0, handle ) ;
	set_point ( x, y ) ;

	callvdi();

	get_rgb ( rgb ) ;
}


/*.... color runs .................................................*/

void vrun_rect ( int handle, int *pts, int *rgbs )
/*
	pts		= rectangle ( 2 points )	
	rgbs	= 4 * rgb values, one for each corner
*/
{
	int i, *op ;
	
	set_contrl ( 61, 2, 0, 12, 0, 0, handle ) ;

	op = ptsin ;
	for ( i = 0; i < 4 ; i++ )
		*op++ = *pts++ ;

	op = intin ;
	for ( i = 0; i < 12 ; i++ )
		*op++ = *rgbs++ ;

	callvdi();
}

void vrun_parallel ( int handle, int *pts, int *rgbs )
/*
	pts		= rectangle ( 3 points )	
	rgbs	= 4 * rgb values, one for each corner
*/
{
	int i, *op ;
	
	set_contrl ( 62, 3, 0, 12, 0, 0, handle ) ;

	op = ptsin ;
	for ( i = 0; i < 6 ; i++ )
		*op++ = *pts++ ;

	op = intin ;
	for ( i = 0; i < 12 ; i++ )
		*op++ = *rgbs++ ;

	callvdi();
}


void vrun_triangle ( int handle, int *pts, int *rgbs )
/*
	pts		= triangle ( 3 points )	
	rgbs	= 3 * rgb values, one for each corner
*/
{
	int i, *op ;
	
	set_contrl ( 63, 3, 0, 9, 0, 0, handle ) ;

	op = ptsin ;
	for ( i = 0; i < 6 ; i++ )
		*op++ = *pts++ ;

	op = intin ;
	for ( i = 0; i < 9 ; i++ )
		*op++ = *rgbs++ ;

	callvdi();
}

