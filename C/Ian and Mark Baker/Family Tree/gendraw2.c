/************************************************************************/
/*																		*/
/*		Gendraw2.c	22 Jul 97											*/
/*																		*/
/************************************************************************/

#if !defined GEN_PH
	#include "geninc.h"			/* Use precompiled header GENINC.SYM ?	*/
#endif

#include "genhd.h"
#include "gendraw.h"
#include "genutil.h"
#include "gendata.h"
#include "gendesc.h"
#include "genpers.h"
#include "genpsel.h"
#include "genprnt.h"

extern GRECT deskbox ;
extern short scr_pixel_width, scr_pixel_height ;
extern short page_width_mm, page_height_mm ;

extern short printer_type ;				/* std printer, GDOS or to file	*/
extern short printer_device_number ;	/* GDOS device number			*/
extern BOOLEAN gdos_params_valid ;


extern FONTINFO fontinfo ;

extern Index_person *people ;
extern Index_couple *couples ;
extern int edit_pers_ref ;

extern OBJECT *icons_ptr ;

extern short work_in[] ;

const short selbox_size = 2 ;	/* size of selection boxes in mm.		*/
short sibling_gap = 4 ;	/* default sibling horizontal spacing	*/
short couple_gap = 4 ;	/* default couple horizontal gap		*/
short generation_gap = 6 ;

extern int first_person ;

extern Custom_device custom_display ;
extern short custom_fulled ;			/* flag									*/

extern Wind_edit_params custom_form ;

extern short selected_segment ;
extern short selected_segment_position ;
extern short selected_line[4] ;
extern BOOLEAN last_segment ;

extern Custom_device custom_printer ;

extern Custom_tree custom_tree ;

extern BOOLEAN show_hidden ;
extern BOOLEAN show_custom_pages ;

int  custom_redraw( int handle, GRECT *rect_ptr )
{
	short pxyarray[4] ;
	short hout ;	/* return values from vst_alignment	*/
	short vout ;

	assert( handle == custom_form.fm_handle ) ;

	if( custom_form.iconified )
	{
		icons_ptr[0].ob_x = custom_form.fm_box.g_x ;
		icons_ptr[0].ob_y = custom_form.fm_box.g_y ;
		icons_ptr[ICON].ob_spec = icons_ptr[CUSTOM_ICON].ob_spec ;
		FORM_TEXT( icons_ptr, ICON_LABEL1 ) = custom_form.icon_label1 ;
		FORM_TEXT( icons_ptr, ICON_LABEL2 ) = custom_form.icon_label2 ;
		objc_draw( icons_ptr, ROOT, MAX_DEPTH, PTRS( rect_ptr ) ) ;
	}
	else
	{
		assert( custom_display.handle ) ;

		grect2pxy( rect_ptr, pxyarray ) ;

		vst_alignment( custom_display.handle, CENTRE, BASE, &hout, &vout ) ;
		assert( hout == CENTRE ) ;
		assert( vout == BASE) ;

		vs_clip( custom_display.handle, 1, pxyarray ) ;

		graf_mouse( M_OFF, 0 ) ;		/* turn off mouse while drawing		*/

		wind_update( BEG_UPDATE ) ;

		vr_recfl( custom_display.handle, pxyarray ) ;
		
		if( show_custom_pages )  draw_custom_pages() ;
		draw_custom_tree( &custom_display, *rect_ptr,
						custom_display.x_start, custom_display.y_start, NULL ) ;
		draw_selected_boxes( *rect_ptr, 0, 0 ) ;
		wind_update( END_UPDATE ) ;

		graf_mouse( M_ON, 0 ) ;			/* restore mouse after drawing		*/

		vs_clip( custom_display.handle, 0, NULL ) ;
	}
	return 1 ;
}



			/* When drawing custom tree, the origin of the tree is stored	*/
			/* in the custom_tree structure as .orgx & .orgy, in mm. It is	*/
			/* typically negative as the first person is placed at 0,0.		*/
			/* x_start and y_start are the coordinates in mm of the point	*/
			/* of the tree which is drawn in the top left point of the		*/
			/* current page or window										*/
			/* The clip rect determines how much of the page or window is	*/
			/* to be drawn and is in pixels. The actual clipping is done by	*/
			/* the calling routine setting vs_clip.							*/
			/* Note that scr_pixel_width and height are in um.				*/
void  draw_custom_tree( Custom_device* device, GRECT clip_rect,
					short x_start_mm, short y_start_mm, Str_prt_params *ps_ptr )
{
	Custom_person* current_person ;
	Custom_couple* current_couple ;
	short pxy_array[4] ;
	
	GRECT page ;			/* displayed page in mm						*/

	assert( device->handle ) ;
	assert( custom_tree.start_person ) ;

	page.g_x = pix2mm( clip_rect.g_x, x_start_mm, XPOS, device ) ;
	page.g_w = pix2mm( clip_rect.g_w, 0, XDIST, device ) ;
	page.g_y = pix2mm( clip_rect.g_y, y_start_mm, YPOS, device ) ;
	page.g_h = pix2mm( clip_rect.g_h, 0, YDIST, device ) ;

	grect2pxy( &clip_rect, pxy_array ) ;

			/* Before drawing people, check they are on page to save	*/
			/* unnecessary accesses to their data. Couples are not		*/
			/* checked as their data is all in RAM as part of the		*/
			/* Custom tree.												*/

	current_person = custom_tree.start_person ;
	while( check_printing( ps_ptr ) && current_person )
	{
		if( is_onpage( current_person, &page ) || lines_onpage( current_person, &page ) )
		{
			if( !(current_person->attributes & HIDDEN_YES_BIT) || show_hidden )
				draw_custom_person( device, clip_rect, current_person, x_start_mm, y_start_mm ) ;
		}
		current_person = current_person->next_person ;	
	}
	
	use_scaled_fontinfo( device, custom_tree.fontinfo ) ;

	current_couple = custom_tree.start_couple ;
	while( check_printing( ps_ptr ) && current_couple )
	{
		draw_custom_couple( device, clip_rect, current_couple, x_start_mm, y_start_mm ) ;
		current_couple = current_couple->next_couple ;
	}
}


void  draw_custom_person( Custom_device* device, GRECT clip_rect,
			Custom_person* Cp_ptr, short x_start_mm, short y_start_mm )
{
	int ref ;
	Person* pptr ;
	char names[FULL_NAME_MAX+1] ;
	char dates[DATE_LENGTH * 2 + 2] ;
	FONTINFO* font_ptr ;
	short xmm, ymm ;		/* coordinates in mm						*/
	short xpix, ypix ;		/* coordinates in pixels on screen			*/
	short endy ;
	short pblk ;			/* block returned when getting person ptr	*/
	Custom_couple* Cc_ptr ;
	char* coup_ptr ;		/* points to coupling references			*/
	
	assert( device->handle != 0 ) ;
	assert( Cp_ptr != NULL ) ;

	ref = Cp_ptr->reference ;
	pptr = get_pdata_ptr( ref, &pblk ) ;
	assert( pptr ) ;
	
	xmm = Cp_ptr->x ;
	xpix = mm2pix( xmm, x_start_mm, XPOS, device ) ;
	ymm = Cp_ptr->y ;
	ypix = mm2pix( ymm, y_start_mm, YPOS, device ) ;

	if( font_ptr = Cp_ptr->font_ptr, font_ptr == NULL )
		font_ptr = &(custom_tree.fontinfo) ;
	assert( font_ptr ) ;
	use_scaled_fontinfo( device, *font_ptr ) ;

	custom_tree_names( Cp_ptr, names, dates ) ;
			
	v_gtext( device->handle, xpix, ypix, names ) ;
	
	if( *dates != '\0' )  v_gtext( device->handle, xpix, ypix + device->cell_height, dates ) ;
			
	if( pptr->parents == 0 )
		Cp_ptr->parent_number = -1 ;	/* indicates that no parents	*/
										/* so do not draw parent box	*/
	else if( Cp_ptr->parent_number == -1 )  Cp_ptr->parent_number = 0 ;
					/* now draw vertical line if parents are included	*/
					/* and at least one not hidden						*/
	if( Cp_ptr->parent_number > 0 )
	{
		BOOLEAN show = FALSE ;
		Custom_person* mCp_ptr ;	/* point to members of couple (parents)	*/
		Custom_person* fCp_ptr ;
		
		Cc_ptr = get_Cc_ptr( Cp_ptr->parent_number ) ;
		assert( Cc_ptr ) ;
		
		if( Cc_ptr->male_number )
		{
			mCp_ptr = get_Cp_ptr( Cc_ptr->male_number ) ;
			assert( mCp_ptr != NULL ) ;
			if( !(mCp_ptr->attributes & HIDDEN_YES_BIT) )  show = TRUE ;
		}
		if( Cc_ptr->female_number )
		{
			fCp_ptr = get_Cp_ptr( Cc_ptr->female_number ) ;
			assert( fCp_ptr != NULL ) ;
			if( !(fCp_ptr->attributes & HIDDEN_YES_BIT) )  show = TRUE ;
		}

		if( show || show_hidden )
		{
			ymm = Cp_ptr->box.g_y ;
			endy = mm2pix( Cc_ptr->hline_y, y_start_mm, YPOS, device ) ;
		
			draw_poly_line( Cp_ptr->parent_line_data, xmm, ymm, endy, 0, x_start_mm, y_start_mm, device, clip_rect ) ;
		}
	}

	Cp_ptr->couplings = 0 ;
	if( coup_ptr = pptr->couplings, coup_ptr )
		while( form_ref( &coup_ptr ) )  Cp_ptr->couplings++ ;
}


void  draw_poly_line( short* line_data, short x_line_start, short y_line_start, short end, BOOLEAN horizontal,
			short x_start, short y_start, Custom_device* device, GRECT clip_rect )
{
	short* ld_ptr ;
	BOOLEAN horiz ;
	short mmxy_array[4] ;
	short pxy_array[4] ;
	
	horiz = horizontal ;
	mmxy_array[2] = x_line_start ;	/* ends set to start deliberately as	*/
	mmxy_array[3] = y_line_start ;	/* while loop sets start to last end	*/
	pxy_array[2] = mm2pix( mmxy_array[2], x_start, XPOS, device ) ;
	pxy_array[3] = mm2pix( mmxy_array[3], y_start, YPOS, device ) ;
	ld_ptr = line_data ;
	
	if( line_data != NULL )
	{
		while( *ld_ptr != 0 )
		{
			mmxy_array[0] = mmxy_array[2] ;
			mmxy_array[1] = mmxy_array[3] ;
			pxy_array[0] = pxy_array[2] ;
			pxy_array[1] = pxy_array[3] ;
			if( horiz )
			{
				mmxy_array[2] += *ld_ptr++ ;
				pxy_array[2] = mm2pix( mmxy_array[2], x_start, XPOS, device ) ;
			}
			else
			{
				mmxy_array[3] += *ld_ptr++ ;
				pxy_array[3] = mm2pix( mmxy_array[3], y_start, YPOS, device ) ;
			}
			clipped_line( device->handle, pxy_array, clip_rect ) ;
			horiz = !horiz ;	/* alternate horizontal and vertical segments	*/
		}
	}
													/* draw final segment	*/
	pxy_array[0] = pxy_array[2] ;
	pxy_array[1] = pxy_array[3] ;
	if( horiz )  pxy_array[2] = end ;
	else  pxy_array[3] = end ;
	clipped_line( device->handle, pxy_array, clip_rect ) ;
}


void  clipped_line( int handle, short* pxy_array, GRECT clip_rect )
{
	short local_pxy[4] ;
	BOOLEAN off_page = FALSE ;

					/* get local_pxy[0] to left of local_pxy[2]	*/
	if( pxy_array[0] <= pxy_array[2] )
	{
		local_pxy[0] = pxy_array[0] ;
		local_pxy[2] = pxy_array[2] ;
	}
	else
	{
		local_pxy[0] = pxy_array[2] ;
		local_pxy[2] = pxy_array[0] ;
	}

					/* get local_pxy[1] above local_pxy[3]	*/
	if( pxy_array[1] <= pxy_array[3] )
	{
		local_pxy[1] = pxy_array[1] ;
		local_pxy[3] = pxy_array[3] ;
	}
	else
	{
		local_pxy[1] = pxy_array[3] ;
		local_pxy[3] = pxy_array[1] ;
	}
				
	if( local_pxy[2] < clip_rect.g_x
		|| local_pxy[0] > rect_end( &clip_rect )
		|| local_pxy[3] < clip_rect.g_y
		|| local_pxy[1] > rect_bottom( &clip_rect ) )  off_page = TRUE ;

	if( !off_page )
	{
		local_pxy[0] = max( local_pxy[0], clip_rect.g_x ) ;
		local_pxy[2] = min( local_pxy[2], rect_end( &clip_rect ) ) ;
		local_pxy[1] = max( local_pxy[1], clip_rect.g_y ) ;
		local_pxy[3] = min( local_pxy[3], rect_bottom( &clip_rect ) ) ;
		v_pline( handle, 2, local_pxy ) ;
	}
}


void  draw_custom_couple( Custom_device* device, GRECT clip_rect,
							Custom_couple* Cc_ptr, short x_start, short y_start )
{
	short xmm, ymm ;
	short xpix, ypix ;		/* coordinates in pixels on screen			*/
	short end ;
	short pxy_array[4] ;
	Custom_person* mCp_ptr ;
	Custom_person* fCp_ptr ;
	BOOLEAN show = FALSE ;

	assert( device->handle != 0 ) ;
	assert( Cc_ptr != NULL ) ;

	if( Cc_ptr->male_number )
	{
		mCp_ptr = get_Cp_ptr( Cc_ptr->male_number ) ;
		assert( mCp_ptr != NULL ) ;
		if( !(mCp_ptr->attributes & HIDDEN_YES_BIT) )  show = TRUE ;
	}
	if( Cc_ptr->female_number )
	{
		fCp_ptr = get_Cp_ptr( Cc_ptr->female_number ) ;
		assert( fCp_ptr != NULL ) ;
		if( !(fCp_ptr->attributes & HIDDEN_YES_BIT) )  show = TRUE ;
	}

	xmm = Cc_ptr->x ;
	xpix = mm2pix( xmm, x_start, XPOS, device ) ;

	if( Cc_ptr->male_number && Cc_ptr->female_number )  ymm = Cc_ptr->y ;
	else if( Cc_ptr->male_number )  ymm = mCp_ptr->box.g_y + mCp_ptr->box.g_h ;
	else  ymm = fCp_ptr->box.g_y + fCp_ptr->box.g_h ;
	ypix = mm2pix( ymm, y_start, YPOS, device ) ;
		
	if( (show || show_hidden) && Cc_ptr->child_numbers != NULL && !(Cc_ptr->status & CHILDREN_HIDDEN) )
	{
												/* draw vertical line	*/
		pxy_array[0] = xpix ;
		pxy_array[1] = ypix ;
		pxy_array[2] = pxy_array[0] ;		
		pxy_array[3] = mm2pix( Cc_ptr->hline_y, y_start, YPOS, device ) ;
		clipped_line( device->handle, pxy_array, clip_rect ) ;

												/* draw horizontal line	*/
		if( Cc_ptr->hline_x1 != Cc_ptr->hline_x0 )
		{
			pxy_array[0] = mm2pix( Cc_ptr->hline_x0, x_start, XPOS, device ) ;
			pxy_array[1] = mm2pix( Cc_ptr->hline_y, y_start, YPOS, device ) ;
			pxy_array[2] = mm2pix( Cc_ptr->hline_x1, x_start, XPOS, device ) ;
			pxy_array[3] = pxy_array[1] ;
			clipped_line( device->handle, pxy_array, clip_rect ) ;
		}
	}

			/* draw "=" if both parties present and unhidden	*/
	if( couples[Cc_ptr->reference].male_reference
					&& couples[Cc_ptr->reference].female_reference )
	{
		if( !(mCp_ptr->attributes & HIDDEN_YES_BIT) && !(fCp_ptr->attributes & HIDDEN_YES_BIT) )
		{
			if( xpix > clip_rect.g_x && xpix < rect_end( &clip_rect )
				&& ypix > clip_rect.g_y && ypix < rect_bottom( &clip_rect ) )
			{
				v_gtext( device->handle, xpix, ypix, "=" ) ;
			}

					/* link "=" to people if they have moved	*/
										/* left hand member		*/
			xmm -= couple_gap ;
			if( !(Cc_ptr->status & CUST_REVERSED) && Cc_ptr->mline_data != NULL )
			{
				end = rect_end( &(mCp_ptr->box) ) ;
				end = mm2pix( end, x_start, XPOS, device ) ;
				draw_poly_line( Cc_ptr->mline_data, xmm, ymm, end, HORIZONTAL, x_start, y_start, device, clip_rect ) ;
			}
			else if( Cc_ptr->status & CUST_REVERSED && Cc_ptr->fline_data != NULL ) 
			{
				end = rect_end( &(fCp_ptr->box) ) ;
				end = mm2pix( end, x_start, XPOS, device ) ;
				draw_poly_line( Cc_ptr->fline_data, xmm, ymm, end, HORIZONTAL, x_start, y_start, device, clip_rect ) ;
			}
										/* right hand member	*/

			xmm += 2 * couple_gap ;
			if( !(Cc_ptr->status & CUST_REVERSED) && Cc_ptr->fline_data != NULL )
			{
				end = fCp_ptr->box.g_x ;
				end = mm2pix( end, x_start, XPOS, device ) ;
				draw_poly_line( Cc_ptr->fline_data, xmm, ymm, end, HORIZONTAL, x_start, y_start, device, clip_rect ) ;
			}
			else if( Cc_ptr->status & CUST_REVERSED && Cc_ptr->mline_data != NULL )
			{
				end = mCp_ptr->box.g_x ;
				end = mm2pix( end, x_start, XPOS, device ) ;
				draw_poly_line( Cc_ptr->mline_data, xmm, ymm, end, HORIZONTAL, x_start, y_start, device, clip_rect ) ;
			}
		}
	}
}



void  draw_selected_boxes( GRECT clip_rect, short x_move, short y_move )
{
	Custom_person* current_person ;
	short x_start ;
	short y_start ;
	GRECT page ;	/* displayed page in mm, corrected for x_move, y_move	*/

	assert( custom_display.handle ) ;
	
	x_start = custom_display.x_start ;
	y_start = custom_display.y_start ;

	page.g_x = pix2mm( clip_rect.g_x - x_move, x_start, XPOS, &custom_display ) ;
	page.g_w = pix2mm( clip_rect.g_w, 0, XDIST, &custom_display ) ;
	page.g_y = pix2mm( clip_rect.g_y - y_move, y_start, YPOS, &custom_display ) ;
	page.g_h = pix2mm( clip_rect.g_h, 0, YDIST, &custom_display ) ;
	current_person = custom_tree.start_person ;
	
	while( current_person )
	{
		if( is_onpage( current_person, &page ) )
		{
			if( current_person->status & CUST_SELECTED )
				draw_selected_box( current_person, x_move, y_move ) ;
		}
		current_person = current_person->next_person ;	
	}
	
	if( selected_segment )
		dash_selected_line( x_move, y_move ) ;
}


void  draw_selected_box( Custom_person* Cp_ptr, short x_move, short y_move )
{
	short pxy_array[4] ;
	short sub_array[4] ;
	short x_start ;
	short y_start ;
	short selbox_x, selbox_y ;

	assert( custom_display.handle ) ;
	
	x_start = custom_display.x_start ;
	y_start = custom_display.y_start ;

	vswr_mode( custom_display.handle, MD_XOR ) ;

	selbox_x = selbox_size * 10l * custom_display.percent / custom_display.pixel_width ;
	selbox_y = selbox_size * 10l * custom_display.percent / custom_display.pixel_height ;
	
				/* draw main box	*/
	grect2pxy( &(Cp_ptr->box), pxy_array ) ;
	pxy_array[0] = mm2pix( pxy_array[0], x_start, XPOS, &custom_display ) + x_move ;
	pxy_array[1] = mm2pix( pxy_array[1], y_start, YPOS, &custom_display ) + y_move ;
	pxy_array[2] = mm2pix( pxy_array[2], x_start, XPOS, &custom_display ) + x_move ;
	pxy_array[3] = mm2pix( pxy_array[3], y_start, YPOS, &custom_display ) + y_move ;
	vsl_type( custom_display.handle, DOTTED ) ;
	v_box( custom_display.handle, pxy_array ) ;
	vsl_type( custom_display.handle, SOLID ) ;
	
				/* draw parent box if parents exist and not drawn	*/
	if( Cp_ptr->parent_number == 0 )
	{
		sub_array[0] = ( pxy_array[0] + pxy_array[2] - selbox_x ) / 2 ;
		sub_array[1] = pxy_array[1] ;
		sub_array[2] = sub_array[0] + selbox_x ;
		sub_array[3] = sub_array[1] + selbox_y ;
		v_box( custom_display.handle, sub_array ) ;
	}

				/* draw couple boxes if coupling(s) exist and not	*/
				/* all drawn										*/
	if( Cp_ptr->couplings_drawn < Cp_ptr->couplings )
	{
										/* left box					*/
		sub_array[0] = pxy_array[0] ;
		sub_array[1] = ( pxy_array[1] + pxy_array[3] - selbox_y ) / 2 ;
		sub_array[2] = sub_array[0] + selbox_x ;
		sub_array[3] = sub_array[1] + selbox_y ;
		v_box( custom_display.handle, sub_array ) ;
										/* right box				*/		
		sub_array[0] = pxy_array[2] - selbox_x ;
		sub_array[2] = pxy_array[2] ;
		v_box( custom_display.handle, sub_array ) ;
	}

	vswr_mode( custom_display.handle, MD_TRANS ) ;
}


void  draw_custom_pages( void )
{
	Str_prt_params params ;
	short right_edge_mm ;
	short bottom_edge_mm ;
	short page_line_pos_mm ;
	short pxy_array[4] ;

#ifdef BARBER
fstr_report( "draw custom pages" ) ;
#endif
	if( printer_type != GDOS_PRNT )  return ;
#ifdef BARBER
fstr_report( "printer type is GDOS" ) ;
#endif
	
			/* open gdos printer in order to set up page_width/height_mm 	*/
			/* if they are not yet set										*/
	if( !gdos_params_valid )
	{
#ifdef BARBER
fstr_report( "gdos params not valid" ) ;
#endif
#ifdef BARBER
fstr_report( "printer device number is" ) ;
#endif
#ifdef BARBER
freport( printer_device_number ) ;
#endif
		params.use_gdos = TRUE ;
		open_gdos_prn( &params, NULL, printer_device_number ) ;
		if( params.prn_handle )  v_clswk( params.prn_handle ) ;
	}
#ifdef BARBER
fstr_report( "custom display values, w & h" ) ;
#endif
#ifdef BARBER
freport( custom_display.custom_box.g_w ) ;
#endif
#ifdef BARBER
freport( custom_display.custom_box.g_h ) ;
#endif
	
	right_edge_mm = pix2mm( custom_display.custom_box.g_w, custom_display.x_start, XPOS, &custom_display ) ;
	bottom_edge_mm = pix2mm( custom_display.custom_box.g_h, custom_display.y_start, YPOS, &custom_display ) ;
	
	vsl_type( custom_display.handle, DASHDOTDOT ) ;
	vsl_color( custom_display.handle, 3 ) ;
#ifdef BARBER
fstr_report( "line type and colour set" ) ;
#endif
#ifdef BARBER
fstr_report( "page width" ) ;
#endif
#ifdef BARBER
freport( page_width_mm ) ;
#endif

	page_line_pos_mm = ( ( custom_display.x_start - custom_tree.org_x ) / page_width_mm + 1 )
						* page_width_mm + custom_tree.org_x ;
	pxy_array[1] = custom_display.custom_box.g_y ;
	pxy_array[3] = pxy_array[1] + custom_display.custom_box.g_h ;
	while( page_line_pos_mm < right_edge_mm )
	{
#ifdef BARBER
fstr_report( "page_line_pos_mm" ) ;
#endif
#ifdef BARBER
freport( page_line_pos_mm ) ;
#endif
		pxy_array[0] = mm2pix( page_line_pos_mm, custom_display.x_start, XPOS,  &custom_display ) ;
		pxy_array[2] = pxy_array[0] ;
		v_pline( custom_display.handle, 2, pxy_array ) ;
#ifdef BARBER
fstr_report( "line drawn" ) ;
#endif
		
		page_line_pos_mm += page_width_mm ;
	}

#ifdef BARBER
fstr_report( "page height" ) ;
#endif
#ifdef BARBER
freport( page_height_mm ) ;
#endif
	page_line_pos_mm = ( ( custom_display.y_start - custom_tree.org_y ) / page_height_mm + 1 )
						* page_height_mm + custom_tree.org_y ;
		pxy_array[0] = custom_display.custom_box.g_x ;
		pxy_array[2] = pxy_array[0] + custom_display.custom_box.g_w ;
	while( page_line_pos_mm < bottom_edge_mm )
	{
#ifdef BARBER
fstr_report( "page_line_pos_mm" ) ;
#endif
#ifdef BARBER
freport( page_line_pos_mm ) ;
#endif
		pxy_array[1] = mm2pix( page_line_pos_mm, custom_display.y_start, YPOS,  &custom_display ) ;
		pxy_array[3] = pxy_array[1] ;
		v_pline( custom_display.handle, 2, pxy_array ) ;
#ifdef BARBER
fstr_report( "line drawn" ) ;
#endif
		
		page_line_pos_mm += page_height_mm ;
	}
#ifdef BARBER
fstr_report( "now restore colour & style" ) ;
#endif

	vsl_color( custom_display.handle, 1 ) ;
	vsl_type( custom_display.handle, SOLID ) ;
}


void  dash_selected_line( short x_move, short y_move )
{
	short pxy_array[4] ;
	short x_start ;
	short y_start ;

	assert( custom_display.handle != 0 ) ;

	x_start = custom_display.x_start ;
	y_start = custom_display.y_start ;

	vswr_mode( custom_display.handle, MD_XOR ) ;

	pxy_array[0] = mm2pix( selected_line[0], x_start, XPOS, &custom_display ) ;
	pxy_array[1] = mm2pix( selected_line[1], y_start, YPOS, &custom_display ) ;
	pxy_array[2] = mm2pix( selected_line[2], x_start, XPOS, &custom_display ) ;
	pxy_array[3] = mm2pix( selected_line[3], y_start, YPOS, &custom_display ) ;
	if( pxy_array[0] == pxy_array[2] )		/* i.e. vertical line	*/
	{
		pxy_array[0] += x_move ;
		pxy_array[2] += x_move ;
	}
	else									/* horizontal line		*/
	{
		pxy_array[1] += y_move ;
		pxy_array[3] += y_move ;
	}
	vsl_type( custom_display.handle, DOTTED ) ;
	v_pline( custom_display.handle, 2, pxy_array ) ;
	vsl_type( custom_display.handle, SOLID ) ;
	vswr_mode( custom_display.handle, MD_TRANS ) ;
}


				/* mm2pix converts from custom tree positions in mm	*/
				/* to the position on the device (screen or printer)*/
				/* in pixels. It will also convert distances which	*/
				/* are scaled the same but ignore offsets.			*/
				/* When calculating position it allows for two		*/
				/* offsets, the start_mm passed to it and the pixel	*/
				/* value of the start of the device box, which will	*/
				/* depend on the window position for the screen.	*/
				/* For the screen the start_mm passed will be the	*/
				/* same as the device start_mm, but not for printer	*/
				/* where printer pages and offsets affect it.		*/
short  mm2pix( short mm, short start_mm, short operation, Custom_device* device )
{
	short pixel_size ;
	short offset_pix ;
	short offset_mm ;
	
	switch( operation )
	{
		case XPOS :
			pixel_size = device->pixel_width ;
			offset_pix = (device->custom_box).g_x ;
			offset_mm = start_mm ;
			break ;
		case XDIST :
			pixel_size = device->pixel_width ;
			offset_pix = 0 ;
			offset_mm = 0 ;
			break ;
		case YPOS :
			pixel_size = device->pixel_height ;
			offset_pix = (device->custom_box).g_y ;
			offset_mm = start_mm ;
			break ;
		case YDIST :
			pixel_size = device->pixel_height ;
			offset_pix = 0 ;
			offset_mm = 0 ;
			break ;
		default :
			assert( 0 ) ;
			break ;
	}
	
	return ( ( ( ( ( mm - offset_mm ) * 1000l + pixel_size / 2 ) / pixel_size )
								* device->percent + 50 ) / 100) + offset_pix ;
}


short  pix2mm( short pix, short start_mm, short operation, Custom_device* device )
{
	short pixel_size ;
	short offset_pix ;
	short offset_mm ;
	short result ;
	
	switch( operation )
	{
		case XPOS :
			pixel_size = device->pixel_width ;
			offset_pix = (device->custom_box).g_x ;
			offset_mm = start_mm ;
			break ;
		case XDIST :
			pixel_size = device->pixel_width ;
			offset_pix = 0 ;
			offset_mm = 0 ;
			break ;
		case YPOS :
			pixel_size = device->pixel_height ;
			offset_pix = (device->custom_box).g_y ;
			offset_mm = start_mm ;
			break ;
		case YDIST :
			pixel_size = device->pixel_height ;
			offset_pix = 0 ;
			offset_mm = 0 ;
			break ;
		default :
			assert( 0 ) ;
			break ;
	}

	if( pix - offset_pix >= 0 )  result = ( ( ( ( ( pix - offset_pix ) * 100l + device->percent / 2 ) / device->percent )
									* pixel_size + 500 ) / 1000) + offset_mm ;
	else  result = ( ( ( ( ( pix - offset_pix ) * 100l - device->percent / 2 ) / device->percent )
									* pixel_size - 500 ) / 1000) + offset_mm ;
	return result ;
}


BOOLEAN  lines_onpage(Custom_person* current_person, GRECT* page )
{
	Custom_couple* Cc_ptr ;
	BOOLEAN use_end_y = FALSE ;
	BOOLEAN horizontal = FALSE ;
	BOOLEAN checked = FALSE ;
	BOOLEAN onpage = FALSE ;
	short end_y ;
	short x, y, next_x, next_y ;
	short* ld_ptr ;

	assert( current_person != NULL ) ;

	if( current_person->parent_number > 0 )
	{
		Cc_ptr = get_Cc_ptr( current_person->parent_number ) ;
		assert( Cc_ptr != NULL ) ;
		
		end_y = Cc_ptr->hline_y ;
		x = current_person->x ;
		next_x = x ;
		y = current_person->box.g_y ;
		next_y = y ;
		
		ld_ptr = current_person->parent_line_data ;
		if( ld_ptr == NULL )  use_end_y = TRUE ;
		
		while( !checked )
		{
			if( horizontal )
			{
				y = next_y ;
				next_x = x + *ld_ptr ;
				if( y > page->g_y && y < rect_bottom( page )
						&& min( x, next_x ) < rect_end( page ) && max( x, next_x ) > page->g_x )
				{
					onpage = TRUE ;
					checked = TRUE ;
				}
			}  
			else
			{
				if( use_end_y )
				{
					next_y = end_y ;
					checked = TRUE ;
				}
				else  next_y = y + *ld_ptr ;
				x = next_x ;
				if( x > page->g_x && x < rect_end( page )
						&& min( y, next_y ) < rect_bottom( page ) && max( y, next_y ) > page->g_y )
				{
					onpage = TRUE ;
					checked = TRUE ;
				}
			}
			horizontal = !horizontal ;
			if( !use_end_y && *++ld_ptr == 0 )  use_end_y = TRUE ;
		}
	}
	return onpage ;
}


BOOLEAN  is_onpage( Custom_person* current_person, GRECT* page )
{
/*	Custom_couple* Cc_ptr ;
	int* couplings_ptr ;
*/
	BOOLEAN off_page = FALSE ;
/*	BOOLEAN parents_off_page = FALSE ;
	BOOLEAN couple_on_page = FALSE ;
*/	
	assert( current_person != NULL ) ;

	if( rect_end( &(current_person->box) ) < page->g_x )  off_page = TRUE ;
	else if( ( rect_bottom( &(current_person->box) ) ) < page->g_y )  off_page = TRUE ;
	else if( current_person->box.g_x > rect_end( page ) )  off_page = TRUE ;
	else if( current_person->box.g_y > rect_bottom( page ) )  off_page = TRUE ;
	
/*
	if( current_person->parent_number > 0 )
	{
		Cc_ptr = get_Cc_ptr( current_person->parent_number ) ;
		assert( Cc_ptr != NULL ) ;
		if( Cc_ptr->hline_y < page->g_y )  parents_off_page = TRUE ;
		else if( Cc_ptr->hline_y > rect_bottom( page ) )  parents_off_page = TRUE ;
		else if( Cc_ptr->hline_x1 < page->g_x )  parents_off_page = TRUE ;
		else if( Cc_ptr->hline_x0 > rect_end( page ) )  parents_off_page = TRUE ;
	}
	else  parents_off_page = TRUE ;
	
	if( current_person->coupling_list )
	{
		couplings_ptr = current_person->coupling_list ;
		while( *couplings_ptr != 0 )
		{
			Cc_ptr = get_Cc_ptr( *couplings_ptr ) ;
			assert( Cc_ptr != NULL ) ;
			if( rc_inside( Cc_ptr->x, Cc_ptr->y, page ) )  couple_on_page = TRUE ;
			couplings_ptr++ ;
		}
	}
*/
	return !( off_page /* && parents_off_page && !couple_on_page */ ) ;
}


void  find_limits_of_tree( short* xl, short* xr, short* yt, short* yb )
{
	short x_start ;		/* start of mline or fline	*/
	Custom_person* current_person ;
	Custom_couple* current_couple ;

	*xl = custom_tree.start_person->x ;
	*xr = custom_tree.start_person->x ;
	*yt = custom_tree.start_person->y ;
	*yb = custom_tree.start_person->y ;

	current_person = custom_tree.start_person ;
	while( current_person != NULL )
	{
		*xl = min( *xl, current_person->box.g_x ) ;
		*xr = max( *xr, rect_end( &(current_person->box) ) ) ;
		*yt = min( *yt, current_person->box.g_y ) ;
		*yb = max( *yb, rect_bottom( &(current_person->box) ) ) ;
		
		if( current_person->parent_line_data )
			line_range_check( current_person->parent_line_data, current_person->x, current_person->box.g_y,
							FALSE, xl, xr, yt, yb ) ;
		
		current_person = current_person->next_person ;
	}
	
	current_couple = custom_tree.start_couple ;
	while( current_couple != NULL )
	{
		if( current_couple->vline_data )
			line_range_check( current_couple->vline_data, current_couple->x, current_couple->y,
							FALSE, xl, xr, yt, yb ) ;
		if( current_couple->mline_data )
		{
			if( current_couple->status & CUST_REVERSED )  x_start = current_couple->x + couple_gap ;
			else  x_start = current_couple->x - couple_gap ;
			line_range_check( current_couple->mline_data, x_start, current_couple->y,
							TRUE, xl, xr, yt, yb ) ;
		}
		if( current_couple->fline_data )
		{
			if( current_couple->status & CUST_REVERSED )  x_start = current_couple->x - couple_gap ;
			else  x_start = current_couple->x + couple_gap ;
			line_range_check( current_couple->fline_data, x_start, current_couple->y,
							TRUE, xl, xr, yt, yb ) ;
		}
		current_couple = current_couple->next_couple ;
	}
}


void  line_range_check( short* line_data, short x_start, short y_start, BOOLEAN horizontal,
									short* xl, short* xr, short* yt, short* yb )
{
	short* ld_ptr ;
	short x ;
	short y ;
	
	ld_ptr = line_data ;
	x = x_start ;
	y = y_start ;
	
	while( *ld_ptr )
	{
		if( horizontal )
		{
			x += *ld_ptr++ ;
			*xl = min( *xl, x ) ;
			*xr = max( *xr, x ) ;
		}
		else
		{
			y += *ld_ptr++ ;
			*yt = min( *yt, y ) ;
			*yb = max( *yb, y ) ;
		}
		horizontal = !horizontal ;
	}
}
 

void  use_scaled_fontinfo( Custom_device* device, FONTINFO font )
{
	short font_size ;
	fix31 font_size31 ;
	short dummy ;

	assert( device->handle != 0 ) ;

	vst_font( device->handle, font.font_index ) ;
	font_size31 = 65536l * font.font_size * device->percent / 100 ;

	if( vq_vgdos() == '_FSM' )
		vst_arbpt32( device->handle, font_size31, &dummy, &dummy, &dummy, &(device->cell_height) ) ;
	else
	{
		font_size = (short) ( (font_size31 + 32768 ) >> 16 ) ;
		vst_point( device->handle, font_size, &dummy, &dummy, &dummy, &(device->cell_height) ) ;
	}
	vst_effects( device->handle, font.font_effects ) ;
}


short  move_segment( short** line_data, short segment, short xy_move, short last_length, BOOLEAN horizontal_segment )
{
	BOOLEAN last_segment = FALSE ;
	BOOLEAN next_to_last = FALSE ;
	BOOLEAN segment_removed = FALSE ;
	short move ;
	short* ld_ptr ;
	short* ld_ptr2 ;

	assert ( *line_data ) ;

	move = xy_move ;

	ld_ptr = *line_data + segment ;		/* points to length of this segment	*/
	if( *ld_ptr == 0 )  last_segment = TRUE ;
	else if( *(ld_ptr+1) == 0 )  next_to_last = TRUE ;
	
							/* only adjust next length if there is one!		*/
	if( !last_segment && !next_to_last )  *(ld_ptr+1) -= move ;
	*(ld_ptr-1) += move ;
	
							/* now clean up any zero lengths, starting from	*/
							/* far end										*/
	ld_ptr = *line_data + segment ;
	if( last_segment )  ld_ptr -= 1 ;
	else if( !next_to_last )  ld_ptr += 1 ;
	while( ld_ptr > *line_data )
	{
		if( *ld_ptr == 0 )
		{
			segment_removed = TRUE ;
			if( *(ld_ptr+1) == 0 )
			{
				*(ld_ptr-1) = 0 ;
				ld_ptr-- ;		/* skip checking what is new end of line	*/
			}
			else
			{
				ld_ptr2 = ld_ptr + 1 ;
				*(ld_ptr-1) += *ld_ptr2++ ;
				while( *(ld_ptr2-2) = *ld_ptr2 )  ld_ptr2++ ;
			}
		}
		ld_ptr-- ;
	}

	if( segment_removed )  move = 0 ;

	if( move != 0 ) 			/* i.e. successful move and lines not merged	*/
	{							/* correct selected line for dashed display		*/
		if( horizontal_segment )
		{
			selected_line[1] += move ;
			selected_line[3] += move ;
		}
		else 
		{
			selected_line[0] += move ;
			selected_line[2] += move ;
		}
	}
	else selected_segment = 0 ;

	return move ;
}


void  add_segment( short** ld_ptr_ptr, short segment, short position )
{
	short* ld_ptr ;
	short* new_ld_ptr ;
	short* old_ptr ;
	short* new_ptr ;
	short* original_line ;
	short no_line[1] = { 0 } ;		/* empty line in case old line does not exist	*/
	short vertex ;
	short vertices ;
	short addition_method ;
	short length ;
	short length_before ;
	short length_after ;
	short abs_length ;
	short abs_length_before ;
	short abs_length_after ;
	short abs_position ;
	short proportion100 ;
	
	if( *ld_ptr_ptr != NULL )  original_line = *ld_ptr_ptr ;
	else  original_line = no_line ;

	ld_ptr = original_line ;
	
	vertices = 0 ;
	while( *ld_ptr++ )  vertices++ ;
	assert( vertices >= segment ) ;

	if( segment < vertices )
	{
		length = (original_line)[segment] ;
		proportion100 = position * 100 / length ;
		assert( proportion100 >= 0 ) ;
	}
	else  length = position ;
	abs_length = abs( length ) ;
	if( segment > 0 )  length_before = (original_line)[segment-1] ;
	else  length_before = 0 ;
	abs_length_before = abs( length_before ) ;
	if( length != 0 )  length_after = (original_line)[segment+1] ;
	else  length_after = 0 ; 
	abs_length_after = abs( length_after ) ;
	abs_position = abs( position ) ;
	
										/* segment too short for anything	*/
	if( abs_length == 1 )  addition_method = NO_ADDITION ;
										/* final segment					*/
	else if( segment == vertices )
	{
		if( abs_position < 3 )  addition_method = NO_ADDITION ;
		else  addition_method = ADD_SIDE_STEP ;
	}
										/* first_segment, first 2/3			*/
	else if( segment == 0 && proportion100 < 67 )
	{
										/* side step if room				*/
		if( abs_length > 2 )  addition_method = ADD_SIDE_STEP ;
		else  addition_method = NO_ADDITION ;
	}
										/* first 1/3 of line				*/
	else if( proportion100 < 34 )
	{
										/* corner before if room before		*/
		if( abs_length_before > 1 )  addition_method = ADD_CORNER_BEFORE ;
										/* or side step if not, and room	*/
		else if( abs_length >= 3 )  addition_method = ADD_SIDE_STEP ;
		else  addition_method = NO_ADDITION ;
	}
										/* last 1/3 of line					*/
	else if( proportion100 > 66 || abs_length == 2 )
	{
										/* corner after if room after		*/
		if( abs_length_after != 1 )  addition_method = ADD_CORNER_AFTER ;
										/* or side step if not, and room	*/
		else if( abs_length >= 3 )  addition_method = ADD_SIDE_STEP ;
		else  addition_method = NO_ADDITION ;
	}
										/* middle section, side step if room*/
	else if( abs_length >= 3 )  addition_method = ADD_SIDE_STEP ;
	else  addition_method = NO_ADDITION ;

	if( addition_method != NO_ADDITION )
	{
		new_ld_ptr = (short *) checked_malloc( (vertices + 5) * sizeof( short ) ) ;
		if( new_ld_ptr == NULL ) return ;
		
						/* turn off selection of possibly changed segment	*/
		selected_segment = 0 ;
	}
	

	old_ptr = original_line ;
	new_ptr = new_ld_ptr ;
	vertex = 0 ;
	if( length == 0 )  length = position ;
	length /= 3 ;
	abs_length = abs( length ) ;

				/* convert lengths before and after from actual lengths	*/
				/* to new segment lengths for corners					*/
	if( abs_length_before < abs_length + 1 )
	{
		if( length_before < 0 )  length_before++ ;
		else  length_before-- ;
	}
	else
	{
		if( length_before < 0 )  length_before = -abs_length ;
		else  length_before = abs_length ;
	}
	if( abs_length_after == 0 )  length_after = length ;
	else  if( abs_length_after < abs_length + 1 )
	{
		if( length_after < 0 )  length_after++ ;
		else  length_after-- ;
	}
	else
	{
		if( length_after < 0 )  length_after = -abs_length ;
		else  length_after = abs_length ;
	}
	
	switch( addition_method )
	{
		case ADD_SIDE_STEP :
			while( vertex < segment )
			{
				*new_ptr++ = *old_ptr++ ;
				vertex++ ;
			}
			*new_ptr++ = length ;	/* start of line	*/
			*new_ptr++ = length ;	/* out of line		*/
			*new_ptr++ = length ;	/* parallel			*/
			*new_ptr++ = -length ;	/* back in line		*/
			if( *old_ptr != 0 )  *new_ptr++ = *old_ptr++ - 2 * length ;
			while( *new_ptr++ = *old_ptr++ ) ;

			if( *ld_ptr_ptr != NULL )  free( *ld_ptr_ptr ) ;
			*ld_ptr_ptr = new_ld_ptr ;
			break ;
		case ADD_CORNER_BEFORE :
			segment -= 1 ;			/* reduce segment and deliberately run into next case	*/
			length_after = length ;
			length = length_before ;
			/* no break here!!!!!	*/
		case ADD_CORNER_AFTER :
			while( vertex < segment )
			{
				*new_ptr++ = *old_ptr++ ;
				vertex++ ;
			}
			*new_ptr++ = *old_ptr++ - length ;
			*new_ptr++ = length_after ;
			*new_ptr++ = length ;
			if( *old_ptr != 0 )  *new_ptr++ = *old_ptr++ - length_after ;
			while( *new_ptr++ = *old_ptr++ ) ;

			if( *ld_ptr_ptr != NULL )  free( *ld_ptr_ptr ) ;
			*ld_ptr_ptr = new_ld_ptr ;
			break ;
		default :
			free( new_ld_ptr ) ;
			break ;
	}
}



			/*****	 	get_cust_person									*****/
			/* Searches through whole custom tree for people under mouse.	*/
			/* If there is more than one such person it will return the		*/
			/* the first person after the last selected person.				*/
			/*																*/
			/* Passed	x, y	mouse position converted to mm on tree		*/
			/*										it can be zeroed.		*/
			/* Return	Custom_person*	pointer to selected person			*/

Custom_person*  get_cust_person( short xmm, short ymm, char* selection )
{
	Custom_person* current_person ;
	Custom_person* found_person = NULL ;
	BOOLEAN selected_person_found = FALSE ;
	
	current_person = custom_tree.start_person ;

	while( current_person != NULL )
	{
		if( rc_inside( xmm, ymm, &(current_person->box) )
				&& ( !(current_person->attributes & HIDDEN_YES_BIT) || show_hidden ) )
		{
			if( found_person == NULL )  found_person = current_person ;
			if( selected_person_found && !(current_person->status & CUST_SELECTED ) )
			{
				found_person = current_person ;
				selected_person_found = FALSE ;
			}
			if( current_person->status & CUST_SELECTED )  selected_person_found = TRUE ;
		}
		current_person = current_person->next_person ;
	}
	
	if( found_person )
	{
		GRECT inner_box ;

		inner_box.g_w = selbox_size + 1 ;
		inner_box.g_h = selbox_size + 1 ;
																/* check for parent box		*/
		if( found_person->parent_number == 0 )
		{
			inner_box.g_x = found_person->box.g_x + ( found_person->box.g_w - selbox_size ) / 2 ;
			inner_box.g_y = found_person->box.g_y ;
			if( rc_inside( xmm, ymm, &inner_box ) )  *selection = 'p' ;
		}
																/* check for couple boxes	*/
		if( found_person->couplings > found_person->couplings_drawn )
		{
			inner_box.g_x = found_person->box.g_x ;
			inner_box.g_y = found_person->box.g_y + ( found_person->box.g_h - selbox_size ) / 2 ;
			if( rc_inside( xmm, ymm, &inner_box ) )  *selection = 'l' ;
			inner_box.g_x = rect_end( &(found_person->box) ) - selbox_size ;
			if( rc_inside( xmm, ymm, &inner_box ) )  *selection = 'r' ;
		}
	}
	
	return found_person ;
}


Custom_person*  get_cust_psegment( short xmm, short ymm, short* line, short* segment, short* position )
{
	Custom_person* current_person ;
	Custom_couple* Cc_ptr ;
	BOOLEAN found = FALSE ;
	short end_value ;
	
	current_person = custom_tree.start_person ;
	
	while( !found && current_person != NULL )
	{

		if( current_person->parent_number > 0 )
		{
			Cc_ptr = get_Cc_ptr( current_person->parent_number ) ;
			assert( Cc_ptr ) ;
			end_value = Cc_ptr->hline_y ;
			found = find_segment( xmm, ymm, current_person->x, current_person->box.g_y,
						current_person->parent_line_data, FALSE, end_value,
						segment, position, line ) ;
		}
		if( !found )  current_person = current_person->next_person ;
	}

	if( !found )  *segment = 0 ;
	
	return current_person ;
}




BOOLEAN  find_segment( short xmm, short ymm, short line_start_x, short line_start_y,
						short* line_data, BOOLEAN horizontal, short end_value,
						short* segment, short* position, short* line )
{
	BOOLEAN found = FALSE ;
	BOOLEAN end = FALSE ;
	BOOLEAN use_end_value = FALSE ;
	short vertex = 0 ;			/* counts each vertex as used		*/
	short x, y ;				/* start of segment being tested	*/
	short length ;				/* length of next segment			*/
	short next_x, next_y ;		/* end of segment and start of next	*/
	short* ld_ptr ;				/* line data pointer				*/
	
	ld_ptr = line_data ;

	x = line_start_x ;
	y = line_start_y ;
	next_x = x ;
	next_y = y ;

	if( ld_ptr != NULL && *ld_ptr != 0 )  length = *ld_ptr ;
	else
	{
		length = 0 ;
		use_end_value = TRUE ;
	}

	if( horizontal )
	{
		if( !use_end_value )  next_x += length ;
		else  next_x = end_value ;
	}
	else
	{
		if( !use_end_value )  next_y += length ;
		else  next_y = end_value ;
	}

	while( !found && !end )
	{

		if( ( ( xmm >= x && xmm <= next_x ) || ( xmm <= x && xmm >= next_x ) )
			&& ( ( ymm >= y && ymm <= next_y ) || ( ymm <= y && ymm >= next_y ) ) )
		{
			found = TRUE ;
			*segment = vertex ;
			if( horizontal )  *position = xmm - x ;
			else  *position = ymm - y ;
			line[0] = x ;
			line[1] = y ;
			line[2] = next_x ;
			line[3] = next_y ;
			if( use_end_value )  last_segment = TRUE ;
			else  last_segment = FALSE ;
		}
		else
		{
			vertex++ ;
			if( !use_end_value )
			{
				assert( ld_ptr ) ;	/* we should not be in here unless valid	*/
				ld_ptr++ ;
				length = *ld_ptr ;
				if( length == 0 )
					use_end_value = TRUE ;

				if( horizontal )
				{
					x = next_x ;
					if( !use_end_value )  next_y = y + length ;
					else  next_y = end_value ;
				}
				else
				{
					y = next_y ;
					if( !use_end_value )  next_x = x + length ;
					else  next_x = end_value ;
				}
			}
			else  end = TRUE ;
			
			horizontal = !horizontal ;
		}
	}
	
	return found ;
}



Custom_couple*  get_cust_csegment( short xmm, short ymm, short* line, short* line_type, short* segment, short* position )
{
	Custom_couple* current_couple ;
	Custom_person* Cp_ptr ;
	short start_x ;
	short end_x ;
	BOOLEAN found = FALSE ;

	current_couple = custom_tree.start_couple ;
	
	while( !found && current_couple != NULL )
	{
		if( current_couple->mline_data )
		{
			assert( current_couple->male_number ) ;
			Cp_ptr = get_Cp_ptr( current_couple->male_number ) ;
			assert( Cp_ptr ) ;
			if( current_couple->status & CUST_REVERSED )
			{
				start_x = current_couple->x + couple_gap ;
				end_x = Cp_ptr->box.g_x ;
			}
			else
			{
				start_x = current_couple->x - couple_gap ;
				end_x = rect_end( &(Cp_ptr->box) ) ;
			}
			found = find_segment( xmm, ymm, start_x, current_couple->y,
						current_couple->mline_data, TRUE, end_x,
						segment, position, line ) ;
			if( found )  *line_type = MLINE ;
		}
		if( !found && current_couple->fline_data )
		{
			assert( current_couple->female_number ) ;
			Cp_ptr = get_Cp_ptr( current_couple->female_number ) ;
			assert( Cp_ptr ) ;
			if( current_couple->status & CUST_REVERSED )
			{
				start_x = current_couple->x - couple_gap ;
				end_x = rect_end( &(Cp_ptr->box) ) ;
			}
			else
			{
				start_x = current_couple->x + couple_gap ;
				end_x = Cp_ptr->box.g_x ;
			}
			found = find_segment( xmm, ymm, start_x, current_couple->y,
						current_couple->fline_data, TRUE, end_x,
						segment, position, line ) ;
			if( found )  *line_type = FLINE ;
		}
		if( !found && current_couple->hline_x1 != current_couple->hline_x0 )
		{
			if( ymm == current_couple->hline_y && xmm >= current_couple->hline_x0 && xmm <= current_couple->hline_x1 )
			{
				*line_type = HLINE ;
				line[0] = current_couple->hline_x0 ;
				line[1] = current_couple->hline_y ;
				line[2] = current_couple->hline_x1 ;
				line[3] = current_couple->hline_y ;
				*segment = 1 ;	/* only segment	*/
				found = TRUE ;
			}
		}
	
		if( !found )  current_couple = current_couple->next_couple ;
	}

	if( !found )  *segment = 0 ;
	
	return current_couple ;
}


GRECT  get_box_size( int reference, short x, short y, int attributes, FONTINFO* font_ptr, int parent_number )
{
	GRECT box ;
	char names[FULL_NAME_MAX+1] ;
	char dates[DATE_LENGTH * 2 + 2] ;
	short pts[8] ;			/* corners of box returned by vqt_extent	*/
	Custom_person dummy_person ;
	short boxwidth, boxheight ;
	short nameheight, nameheight_mm ;

	dummy_person.reference = reference ;
	dummy_person.x = x ;
	dummy_person.y = y ;
	dummy_person.parent_number = parent_number ;
	dummy_person.attributes = attributes ;
	if( font_ptr == NULL )  dummy_person.font_ptr = &(custom_tree.fontinfo ) ;
	else  dummy_person.font_ptr = font_ptr ;
	dummy_person.parent_number = parent_number ;
	

	use_scaled_fontinfo( &custom_display, *(dummy_person.font_ptr) ) ;
							/* negative length used to prevent padding	*/
	custom_tree_names( &dummy_person, names, dates ) ;
	vqt_extent( custom_display.handle, names, pts ) ;
												/* round up to even number		*/
	boxwidth = pts[2] - pts[0] ;
	boxheight = pts[7] - pts[1] ;
	nameheight = boxheight ;
	if( *dates != '\0' )
	{
		box.g_h += custom_display.cell_height ;
		vqt_extent( custom_display.handle, dates, pts ) ;
		if( pts[2] - pts[0] > boxwidth )  boxwidth = pts[2] - pts[0] ;
		boxheight += pts[7] - pts[1] ;
	}

	box.g_w = pix2mm( boxwidth, 0, XDIST, &custom_display ) + 2 ;
	if( box.g_w & 1 )  box.g_w++ ;	/* ensure even number	*/
	box.g_h = pix2mm( boxheight, 0, YDIST, &custom_display ) ;
	if( box.g_h & 1 )  box.g_h++ ;	/* ensure even number	*/
	box.g_x = x - box.g_w / 2 ;
	nameheight_mm = pix2mm( nameheight, 0, YDIST, &custom_display ) ;
	if( nameheight_mm & 1 )  nameheight_mm++ ;
	box.g_y = y - nameheight_mm / 2 - 1 ;

	return box ;
}



void  get_last_parent_vertex( Custom_person* Cp_ptr, short* end_x, short* end_y )
{
	short* pld_ptr ;

	*end_x = Cp_ptr->x ;
	*end_y = Cp_ptr->box.g_y ;
	
	pld_ptr = Cp_ptr->parent_line_data ;
	if( pld_ptr != NULL )
	{
		while( *pld_ptr != 0 )
		{
			*end_y += *pld_ptr++ ;
			*end_x += *pld_ptr++ ;
		}
	}
}		


void  custom_scrolled( const short *message )
{
	short vertical_page_size ;
	short vertical_line_step ;
	short horizontal_page_size ;
	short horizontal_line_step ;

	vertical_page_size = pix2mm( custom_display.custom_box.g_h, 0, YDIST, &custom_display ) ;
	vertical_line_step = vertical_page_size / 10 ;
	if( vertical_line_step < 1 )  vertical_line_step = 1 ;
	horizontal_page_size = pix2mm( custom_display.custom_box.g_h, 0, YDIST, &custom_display ) ;
	horizontal_line_step = horizontal_page_size / 10 ;
	if( horizontal_line_step < 1 )  horizontal_line_step = 1 ;

	switch( message[4] )
	{
		case WA_UPPAGE :
			custom_display.y_start -= vertical_page_size ;
			break ;
		case WA_DNPAGE :
			custom_display.y_start += vertical_page_size ;
			break ;
		case WA_UPLINE :
			custom_display.y_start -= vertical_line_step ;
			break ;
		case WA_DNLINE :
			custom_display.y_start += vertical_line_step ;
			break ;
		case WA_LFPAGE :
			custom_display.x_start -= horizontal_page_size ;
			break ;
		case WA_RTPAGE :
			custom_display.x_start += horizontal_page_size ;
			break ;
		case WA_LFLINE :
			custom_display.x_start -= horizontal_line_step ;
			break ;
		case WA_RTLINE :
			custom_display.x_start += horizontal_line_step ;
			break ;
	}

				/* lower/right extent limited first in case page bigger	*/
				/* than tree, in which case second limiting operation	*/
				/* will put org at top left of page.					*/
	if( custom_display.y_start > custom_tree.lim_y - vertical_page_size )
		custom_display.y_start = custom_tree.lim_y - vertical_page_size ;
	if( custom_display.y_start < custom_tree.org_y )
		custom_display.y_start = custom_tree.org_y ;
	if( custom_display.x_start > custom_tree.lim_x - horizontal_page_size )
		custom_display.x_start = custom_tree.lim_x - horizontal_page_size ;
	if( custom_display.x_start < custom_tree.org_x )
		custom_display.x_start = custom_tree.org_x ;

	set_cust_sliders() ;
	send_redraw_message( &custom_display.custom_box, custom_form.fm_handle ) ;
}
			


void  set_cust_sliders( void )
{
	long sl_size ;
	short sl_pos ;
	short old_sl_size ;
	short old_sl_pos ;
	short dummy ;
	
	wind_get( custom_form.fm_handle, WF_VSLSIZE, &old_sl_size, &dummy, &dummy, &dummy ) ;
	wind_get( custom_form.fm_handle, WF_VSLIDE, &old_sl_pos, &dummy, &dummy, &dummy ) ;
										/* vertical slider size			*/
	if( custom_tree.lim_y - custom_tree.org_y > 0 )
		sl_size = pix2mm( custom_display.custom_box.g_h, 0, YDIST, &custom_display ) * 1000l
										/ ( custom_tree.lim_y - custom_tree.org_y ) ;
	else  sl_size = 1000 ;
	
	if( sl_size < 25 )  sl_size = 25 ;
	if( sl_size > 1000 )  sl_size = 1000 ; 
	if( sl_size == 1000 )  custom_display.y_start = custom_tree.org_y ;
	if( sl_size != old_sl_size )  wind_set( custom_form.fm_handle, WF_VSLSIZE, sl_size ) ;

										/* vertical slider position		*/
	if( sl_size < 1000 )
		sl_pos = ( custom_display.y_start - custom_tree.org_y ) * 1000l
					/ ( custom_tree.lim_y - custom_tree.org_y
						- pix2mm( custom_display.custom_box.g_h, 0, YDIST, &custom_display ) ) ;
	else  sl_pos = 0 ;
	if( sl_pos != old_sl_pos )  wind_set( custom_form.fm_handle, WF_VSLIDE, sl_pos ) ;

	wind_get( custom_form.fm_handle, WF_HSLSIZE, &old_sl_size, &dummy, &dummy, &dummy ) ;
	wind_get( custom_form.fm_handle, WF_HSLIDE, &old_sl_pos, &dummy, &dummy, &dummy ) ;
										/* horizontal slider size		*/
	if( custom_tree.lim_x - custom_tree.org_x > 0 )
		sl_size = pix2mm( custom_display.custom_box.g_w, 0, XDIST, &custom_display ) * 1000l
										/ ( custom_tree.lim_x - custom_tree.org_x ) ;
	else  sl_size = 1000 ;
	
	if( sl_size < 25 )  sl_size = 25 ;
	if( sl_size > 1000 )  sl_size = 1000 ; 
	if( sl_size == 1000 )  custom_display.x_start = custom_tree.org_x ;
	if( sl_size != old_sl_size )  wind_set( custom_form.fm_handle, WF_HSLSIZE, sl_size ) ;

										/* horizontal slider position	*/
	if( sl_size < 1000 )
		sl_pos = ( custom_display.x_start - custom_tree.org_x ) * 1000l
					/ ( custom_tree.lim_x - custom_tree.org_x
						- pix2mm( custom_display.custom_box.g_w, 0, XDIST, &custom_display ) ) ;
	else  sl_pos = 0 ;
	if( sl_pos != old_sl_pos )  wind_set( custom_form.fm_handle, WF_HSLIDE, sl_pos ) ;
}


void  custom_tree_names( Custom_person* Cp_ptr, char* names, char* dates )
{
	char name_buf[FULL_NAME_MAX+1] ;
	char* date_ptr ;
	int date ;
	char qualifier ;
	int attributes ;
	BOOLEAN include_fname ;
	short forename_limit ;
	BOOLEAN date_valid = FALSE ;
	
	assert( Cp_ptr ) ;
	if( Cp_ptr->attributes & LIMIT_BITS )  attributes = Cp_ptr->attributes & ( LIMIT_BITS + LIMIT_SIZE_BITS ) ;
	else  attributes = custom_tree.attributes & ( LIMIT_BITS + LIMIT_SIZE_BITS ) ;
	if( Cp_ptr->attributes & FNAME_BITS )  attributes |= Cp_ptr->attributes & FNAME_BITS ;
	else  attributes |= custom_tree.attributes & FNAME_BITS ;
	if( Cp_ptr->attributes & DOB_BITS )  attributes |= Cp_ptr->attributes & DOB_BITS ;
	else  attributes |= custom_tree.attributes & DOB_BITS ;
	if( Cp_ptr->attributes & DOD_BITS )  attributes |= Cp_ptr->attributes & DOD_BITS ;
	else  attributes |= custom_tree.attributes & DOD_BITS ;
	
	if( attributes & FNAME_YES_BIT )  include_fname = TRUE ;
	else if( attributes & FNAME_NO_BIT )  include_fname = FALSE ;
	else
	{
		if( Cp_ptr->parent_number > 0 )
		{
			Custom_couple* Cc_ptr ;

			Cc_ptr = get_Cc_ptr( Cp_ptr->parent_number ) ;
			assert( Cc_ptr ) ;
			if( Cc_ptr->male_number != 0 )  include_fname = FALSE ;
			else  include_fname = TRUE ;
		}
		else  include_fname = TRUE ;
	}
	strcpy( name_buf, people[Cp_ptr->reference].forename ) ;
	if( attributes & ONE_BIT )  strtok( name_buf, " " ) ;
	else if( attributes & LIMIT_BIT )
	{
		char* ch_ptr ;

		forename_limit = attributes & LIMIT_SIZE_BITS ;
		if( include_fname )  forename_limit -= strlen( people[Cp_ptr->reference].family_name ) ;
		if( forename_limit < 0 )  forename_limit = 0 ;

		ch_ptr = name_buf + strlen( name_buf ) ;
		if( ch_ptr > name_buf + forename_limit )
		{
			ch_ptr = name_buf + forename_limit ;
			while( ch_ptr > name_buf && *ch_ptr != ' ' )  ch_ptr-- ;
			if( ch_ptr == name_buf )		/* no name left to display	*/
				ch_ptr = name_buf + forename_limit ;
			*ch_ptr = '\0' ;
		}
	}
	
	if( include_fname )
	{
		strcat( name_buf, " " ) ;
		strcat( name_buf, people[Cp_ptr->reference].family_name ) ;
	}
	strcpy( names, name_buf ) ;
	
	if( attributes & DOB_YES_BIT && ( date = people[Cp_ptr->reference].birth_date ) )
	{
		date_valid = TRUE ;
		form_date( dates, &qualifier, date, FALSE ) ;
		if( qualifier != ' ' )
		{
			*dates = qualifier ;
			form_date( dates+1, &qualifier, date, FALSE ) ;
		}
	}
	else
	{
		short i ;
		char* dptr ;
		
		dptr = dates ;
		for( i=0; i<4; i++ )  *dptr++ = ' ' ;
		*dptr = '\0' ;
	}
	if( attributes & DOD_YES_BIT )
	{
		Person* pptr ;
		short block ;
		
		pptr = get_pdata_ptr( Cp_ptr->reference, &block ) ;
		if( date = pptr->death_date, date )
		{
			date_valid = TRUE ;
			strcat( dates, " - " ) ;
			date_ptr = dates + strlen( dates ) ;
			form_date( date_ptr, &qualifier, date, FALSE ) ;
			if( qualifier != ' ' )
			{
				*date_ptr++ = qualifier ;
				form_date( date_ptr, &qualifier, date, FALSE ) ;
			}
		}
	}
	if( !date_valid )  *dates = '\0' ;
}



