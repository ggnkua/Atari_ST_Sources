/************************************************************************/
/*																		*/
/*		Gencprn.c	21 Oct 01											*/
/*																		*/
/************************************************************************/

#if !defined GEN_PH
	#include "geninc.h"			/* Use precompiled header GENINC.SYM ?	*/
#endif

#include "genhd.h"
#include "gendraw.h"
#include "genutil.h"
#include "genprnt.h"

extern Custom_tree custom_tree ;

extern  short printer_type ;		/* std printer, GDOS or to file		*/

extern short gdos_x_offset, gdos_y_offset ;
										/* gdos left and top margins	*/
extern short prn_pixel_width ;			/* gdos pixel width & height	*/
extern short prn_pixel_height ;
extern short print_width ;				/* printer page width & height	*/
extern short print_height ;				/* in pixels					*/
extern short page_width_mm, page_height_mm ;
										/* printer page width & height	*/
										/* in mm						*/
extern int first_person ;

Custom_device custom_printout = { 0, 100, 6, {0,0,0,0}, 100, 100, 0, 0, 0 } ;


void  print_custom( void )
{
	Str_prt_params params ;
	short pxy_array[4] ;
	short pages_across ;
	short pages_down ;
	short page_x ;
	short page_y ;
	short x_start_mm ;
	short y_start_mm ;
	short hout ;	/* return values from vst_alignment	*/
	short vout ;

	if( printer_type != GDOS_PRNT )
	{
		rsrc_form_alert( 1, NEED_GDOS_PRNT ) ;
		return ;
	}
	
	if( open_printer( &params ) )
	{
		busy( BUSY_MORE ) ;

		start_print_checking( &params ) ;

		params.ref1 = first_person ;
		params.ref2 = 0 ;			/* Do not print second reference in footer	*/
		
		adjust_tree_position() ;

		custom_printout.handle = params.prn_handle ;
		assert( custom_printout.handle ) ;
		custom_printout.pixel_width = prn_pixel_width ;
		custom_printout.pixel_height = prn_pixel_height ;
		custom_printout.cell_height = params.cell_height ;
		custom_printout.custom_box.g_x = mm2pix( gdos_x_offset, 0, XDIST, &custom_printout ) ;
		custom_printout.custom_box.g_y = mm2pix( gdos_y_offset, 0, YDIST, &custom_printout ) ;
		custom_printout.custom_box.g_w = print_width - custom_printout.custom_box.g_x ;
		custom_printout.custom_box.g_h = print_height - custom_printout.custom_box.g_y ;

		grect2pxy( &(custom_printout.custom_box), pxy_array ) ;
		vs_clip( custom_printout.handle, 1, pxy_array ) ;

		vst_alignment( custom_printout.handle, CENTRE, BASE, &hout, &vout ) ;
		assert( hout == CENTRE ) ;
		assert( vout == BASE) ;
		
								/* calculate pages required, rounding up	*/
		pages_across = ( custom_tree.lim_x - custom_tree.org_x + page_width_mm - 1 ) / page_width_mm ;
		pages_down = ( custom_tree.lim_y - custom_tree.org_y + page_height_mm - 1 ) / page_height_mm ;

		for( page_y = 0; page_y < pages_down; page_y++ )
		{
			y_start_mm = custom_tree.org_y + page_y * page_height_mm /* - gdos_y_offset */;
			
			for( page_x = 0; check_printing( &params ) && page_x < pages_across; page_x++ )
			{
				x_start_mm = custom_tree.org_x + page_x * page_width_mm /* - gdos_x_offset */;
				
				draw_custom_tree( &custom_printout, custom_printout.custom_box, x_start_mm, y_start_mm, &params ) ;

				end_page( &params, FALSE ) ;
			}
		}
		vs_clip( custom_printout.handle, 0, pxy_array ) ;
		/* Passing NULL instead of pxy_array upset NVDI which complained of insufficient
		   room on drive E although Atari Library Manual explicitly allows NULL when
		   disabling clipping.																*/

		close_printer( &params ) ;
		busy( BUSY_LESS ) ;
	}

}
