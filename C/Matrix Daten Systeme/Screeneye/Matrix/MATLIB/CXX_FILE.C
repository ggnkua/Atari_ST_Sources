#include <portab.h>
#include <stdlib.h>
#include <stdio.h>

# include "\tc\cxx.lib\gp_lib.h"
# include "\tc\cxx.lib\gp_init.h"
# include "\tc\cxx.lib\gp_fast.h"
# include "\tc\cxx.lib\gp_clut.h"

# include "picfiles.h"


/*--------------------------------------------- load_palette ----*/
void get_moc_palette ( PALETTE *mocpal )
{
	save_palette ( mocpal ) ;
}


extern int pal_shift ;

/*--------------------------------------------- load_palette ----*/
void set_moc_palette(PALETTE *mocpal)
{
	byte *in_ptr;
	int	 entry ;
	COLOR_LEVEL r, g, b ;

# define LEV_CORR(lev) (((lev*(256-pal_shift))>>8) + pal_shift)
	
	in_ptr = &(*mocpal)[0].rsrvd ;
	for(entry=0;entry<=MAX_COLOR;entry++)
	{
		in_ptr++ ;				/* dummy */
		r = *in_ptr++ ;
		g = *in_ptr++ ;
		b = *in_ptr++ ;
#if 0
		if( ! vdi_active() || entry >= 16 )
# endif
#if 1
		{
			if(pal_shift)
			{
				clut_set_color( entry, LEV_CORR(r), LEV_CORR(g), LEV_CORR(b) ) ;
			}
			else	
			{
				clut_set_color( entry, r, g, b ) ;
			}
		}
#else
			clut_set_color(entry,*in_ptr++,*in_ptr++,*in_ptr++) ;
#endif
	}
}


/*--------------------------------------------- set_vid_palette ----*/
void set_vid_palette(byte **in_buffer,int levels)
/* on entry	: *in_buffer points to start of palette area,
						 ( byte sequence : dummy, r, g, b, ... )
   on exit	: *in_buffer points behind palette area				*/
{
	byte *in_ptr;
	int	 entry ;
	COLOR_LEVEL r, g, b ;
	int shift ;
	
	in_ptr = *in_buffer;

	if(levels==6)
		shift = 2 ;
	else
		shift = 0 ;
		
	for(entry=0;entry<=MAX_COLOR;entry++)
	{
		r = *in_ptr++ << shift ;
		g = *in_ptr++ << shift ;
		b = *in_ptr++ << shift ;
		if( !vdi_active() || entry >= 16)
			clut_set_color( entry, r, g, b ) ;
	}
	*in_buffer = in_ptr ;
}


/*---------------------------------------------- cxx_limits -----*/
void cxx_limits ( int *x, int *y, int *w, int *h )
{
	*x &= 0xfffe ;					/* round down	*/
	*w = ( *w + 1 ) & 0xfffe ;		/* round up		*/
	
	if ( *x+*w > d_x ) *w = d_x - *x ;	/* check limits	*/
	if ( *y+*h > d_y ) *h = d_y - *y ;
}

/*---------------------------------------------- mcc_def_malloc ---*/
int mcc_def_malloc ( MCCpic *mccpic )
{
	return ( malloc_mcc_pic ( mccpic, d_x, d_y ) ) ;
}

/*---------------------------------------------- moc_def_malloc ---*/
int moc_def_malloc ( MOCpic *mocpic )
{
	return ( malloc_moc_pic ( mocpic, d_x, d_y ) ) ;
}


/*---------------------------------------------- cxx_get_moc -------*/
int cxx_get_moc (	int x, int y, int w, int h,
					MOCpic *mocpic )
{
	int	result ;

	if ( mocpic->data != NULL )	/* buffer allocated	*/
	{
		result = 0 ;
		mocpic->head->breite = w ;	/* assuming buffer is big enough */
		mocpic->head->hoehe  = h ;
	}
	else
	{
		result =  malloc_moc_pic ( mocpic, w, h ) ;
	}
	
	if ( result == 0 )
	{
		get_moc_palette ( mocpic->palette ) ;
		window_to_moc ( bit_map, byt_per_lin, x, y, w, h, mocpic ) ;
# if 0
		realloc ( mocpic->data, mocpic->size ) ;
# endif
	}
	return ( result ) ;
}

/*---------------------------------------------- cxx_compress -----*/
int cxx_compress (	int x, int y, int w, int h,
					MCCpic *mccpic )
{
	int	result ;

	if ( mccpic->size > 0 )	/* buffer allocated	*/
	{
		result = 0 ;
		mccpic->head->breite = w ;	/* assuming buffer is big enough */
		mccpic->head->hoehe  = h ;
	}
	else
	{
		result =  malloc_mcc_pic ( mccpic, w, h ) ;
	}
	
	if ( result == 0 )
	{
		get_moc_palette ( mccpic->palette ) ;
		result = compress_window ( bit_map, byt_per_lin, x, y, w, h, mccpic ) ;
# if 0
		realloc ( mccpic->data, mccpic->size ) ;
# endif
	}
	return ( result ) ;
}



/*-------------------------------------------- cxx_uncompress -----*/
int cxx_uncompress ( int x, int y, MCCpic *mccpic )
{
	set_moc_palette ( mccpic->palette ) ;
	return ( uncompress_window ( bit_map, byt_per_lin, x, y, mccpic ) ) ;
}


/*--------------------------------------------- calc_disp_rect ----*/
void calc_disp_rect ( PIChead *pichead,
						int x0, int y0, int dx, int dy,
						Point *dim )
{
	dim->x = pichead->breite ;
	if ( dim->x > d_x - x0 ) dim->x = d_x - x0 ;
	if ( dim->x > dx ) dim->x = dx ;

	dim->y = pichead->hoehe ;
	if ( dim->y > d_y - y0 ) dim->y = d_y - y0 ;
	if ( dim->y > dy ) dim->y = dy ;
}

/*--------------------------------------------- center_disp_rect --*/
void center_disp_rect ( Point *dim, Point *pos )
{
	pos->x = ( d_x - dim->x ) / 2 ;
	pos->y = ( d_y - dim->y ) / 2 ;
}



/*--------------------------------------------- init_cxx_file -----*/
unsigned init_cxx_file ( void )
{
	if ( init_cxx_par() )
	{
		return ( vdi_active() ? 2 : 1 ) ;
	}
	else 
		return( 0 ) ;
}


