/************************************************************************/
/*																		*/
/*		Gendraw3.c	 5 Sep 95											*/
/*																		*/
/************************************************************************/

#if !defined GEN_PH
	#include "geninc.h"			/* Use precompiled header GENINC.SYM ?	*/
#endif

#include "genhd.h"
#include "gendraw.h"
#include "genutil.h"

extern Index_person *people ;

extern BOOLEAN custom_tree_changed ;

extern short couple_gap ;		/* default couple horizontal spacing	*/

extern Custom_device custom_display ;

extern Wind_edit_params custom_form ;

extern short selected_segment ;
extern short selected_line[] ;
extern BOOLEAN last_segment ;

extern Custom_tree custom_tree ;

Custom_person*  get_next_selected_custom_person( Custom_person* Cp_ptr )
{
	Custom_person* nCp_ptr ;
	
	nCp_ptr = Cp_ptr ;
	while( nCp_ptr != NULL && !( nCp_ptr->status & SELECTED ) )
		nCp_ptr = nCp_ptr->next_person ;
	
	return nCp_ptr ;
}	


void  directly_draw_selected_box( Custom_person* Cp_ptr, short* clip_array )
{
	vs_clip( custom_display.handle, 1, clip_array ) ;
	graf_mouse( M_OFF, 0 ) ;		/* turn off mouse while drawing		*/
	draw_selected_box( Cp_ptr, 0, 0 ) ;
	graf_mouse( M_ON, 0 ) ;			/* restore mouse after drawing		*/
	vs_clip( custom_display.handle, 0, NULL ) ;
}


void  get_mouse_move_mm( short* x_move, short* y_move, short m_x, short m_y )
{
	short new_x, new_y ;
	short old_x_move = 0 ;
	short old_y_move = 0 ;
	short clip_array[4] ;
	short button ;
	short kstate ;

	wind_update( BEG_UPDATE ) ;
	wind_update( BEG_MCTRL ) ;
	while( graf_mkstate( &new_x, &new_y, &button, &kstate ), button != 0 )
	{
		*x_move = new_x - m_x ;
		*y_move = new_y - m_y ;
		if( *x_move != old_x_move || *y_move != old_y_move )
		{
			clip_array[0] = custom_display.custom_box.g_x ;
			clip_array[1] = custom_display.custom_box.g_y ;
			clip_array[2] = clip_array[0] + custom_display.custom_box.g_w ;
			clip_array[3] = clip_array[1] + custom_display.custom_box.g_h ;

			vs_clip( custom_display.handle, 1, clip_array ) ;
				graf_mouse( M_OFF, 0 ) ;		/* turn off mouse while drawing		*/
			draw_selected_boxes( custom_display.custom_box, old_x_move, old_y_move ) ;
			draw_selected_boxes( custom_display.custom_box, *x_move, *y_move ) ;
			graf_mouse( M_ON, 0 ) ;			/* turn on mouse after drawing		*/
			vs_clip( custom_display.handle, 0, NULL ) ;

			old_x_move = *x_move ;
			old_y_move = *y_move ;
		}
	}
	wind_update( END_MCTRL ) ;
	wind_update( END_UPDATE ) ;
	
	*x_move = pix2mm( *x_move, 0, XDIST, &custom_display ) ;
	*y_move = pix2mm( *y_move, 0, YDIST, &custom_display ) ;
}


void  custom_rubber_band( short* x_move, short* y_move, short m_x, short m_y )
{
	short new_x, new_y ;
	short pxy_array[4] ;
	short button ;
	short kstate ;

	pxy_array[0] = m_x ;
	pxy_array[1] = m_y ;
	pxy_array[2] = m_x ;
	pxy_array[3] = m_y ;
	
	wind_update( BEG_UPDATE ) ;
	wind_update( BEG_MCTRL ) ;
	vswr_mode( custom_display.handle, MD_XOR ) ;
	vsl_type( custom_display.handle, DOTTED ) ;

	graf_mouse( M_OFF, 0 ) ;		/* turn off mouse while drawing		*/
	v_box( custom_display.handle, pxy_array ) ;
	graf_mouse( M_ON, 0 ) ;			/* turn on mouse after drawing		*/

	while( graf_mkstate( &new_x, &new_y, &button, &kstate ), button != 0 )
	{
		if( new_x != pxy_array[2] || new_y != pxy_array[3] )
		{
			graf_mouse( M_OFF, 0 ) ;		/* turn off mouse while drawing		*/
			v_box( custom_display.handle, pxy_array ) ;
			pxy_array[2] = new_x ;
			pxy_array[3] = new_y ;
			v_box( custom_display.handle, pxy_array ) ;
			graf_mouse( M_ON, 0 ) ;			/* turn on mouse after drawing		*/
		}
	}
	graf_mouse( M_OFF, 0 ) ;		/* turn off mouse while drawing		*/
	v_box( custom_display.handle, pxy_array ) ;
	graf_mouse( M_ON, 0 ) ;			/* turn on mouse after drawing		*/

	vsl_type( custom_display.handle, SOLID ) ;
	vswr_mode( custom_display.handle, MD_TRANS ) ;
	wind_update( END_MCTRL ) ;
	wind_update( END_UPDATE ) ;
	
	*x_move = pix2mm( new_x - m_x, 0, XDIST, &custom_display ) ;
	*y_move = pix2mm( new_y - m_y, 0, YDIST, &custom_display ) ;
}


void  move_cust_person( Custom_person* Cp_ptr, short x_move, short y_move )
{
	Custom_couple* Cc_ptr ;
	Custom_person* mCp_ptr ;
	Custom_person* fCp_ptr ;
	short* pld_ptr ;
	short vertices ;
	BOOLEAN left_edge = FALSE ;
	BOOLEAN top_edge = FALSE ;
	BOOLEAN size_changed = FALSE ;

	Cp_ptr->x += x_move ;
	Cp_ptr->box.g_x += x_move ;

	if( custom_display.x_start <= custom_tree.org_x )  left_edge = TRUE ;
	if( Cp_ptr->box.g_x - 1 < custom_tree.org_x )
	{
		size_changed = TRUE ;
		custom_tree.org_x = Cp_ptr->box.g_x - 1 ;
	}
	if( rect_end( &(Cp_ptr->box) ) + 1 > custom_tree.lim_x )
	{
		size_changed = TRUE ;
		custom_tree.lim_x = rect_end( &(Cp_ptr->box) ) + 1 ;
	}
	if( left_edge )  custom_display.x_start = custom_tree.org_x ;

	Cp_ptr->y += y_move ;
	Cp_ptr->box.g_y += y_move ;

	if( custom_display.y_start <= custom_tree.org_y )  top_edge = TRUE ;
	if( Cp_ptr->box.g_y - 1 < custom_tree.org_y )
	{
		size_changed = TRUE ;
		custom_tree.org_y = Cp_ptr->box.g_y - 1 ;
	}
	if( rect_bottom( &(Cp_ptr->box) ) + 1 > custom_tree.lim_y )
	{
		size_changed = TRUE ;
		custom_tree.lim_y = rect_bottom( &(Cp_ptr->box) ) + 1 ;
	}
	if( top_edge )  custom_display.y_start = custom_tree.org_y ;

	if( size_changed )  set_cust_sliders() ;

					/* If either parent not moved, correct parent	*/
					/* line if it exists, otherwise adjust parent	*/
					/* line.										*/
	if( Cp_ptr->parent_number > 0 )
	{
						/* Initialise selection to TRUE, then if	*/
						/* parent does not exist there will be no	*/
						/* adjustment of parent line.				*/
		BOOLEAN male_selected = TRUE ;
		BOOLEAN female_selected = TRUE ;
		
		Cc_ptr = get_Cc_ptr( Cp_ptr->parent_number ) ;
		assert( Cc_ptr ) ;
		/* check whether both parents being moved, i.e. selected	*/
		if( Cc_ptr->male_number )
		{
			mCp_ptr = get_Cp_ptr( Cc_ptr->male_number ) ;
			male_selected = mCp_ptr->status & SELECTED ;
		}
		if( Cc_ptr->female_number )
		{
			fCp_ptr = get_Cp_ptr( Cc_ptr->female_number ) ;
			female_selected = fCp_ptr->status & SELECTED ;
		}
		/* if not moving both parents as well adjust person's line to them	*/
		if( !male_selected || !female_selected )
		{
			vertices = 0 ;
			pld_ptr = Cp_ptr->parent_line_data ;
			if( pld_ptr != NULL )
				while( *pld_ptr++ )  vertices++ ;	/* count vertices	*/
			if( pld_ptr != NULL && vertices > 0 )
			{
				Cp_ptr->parent_line_data[vertices-1] -= x_move ;
				if( Cp_ptr->parent_line_data[vertices-1] == 0 )
					Cp_ptr->parent_line_data[vertices-2] = 0 ;
			}
		}
		adjust_couple_hline( Cc_ptr ) ;
	}
}



void  test_move_cust_couple( Custom_couple* Cc_ptr, short x_move, short y_move )
{
	short child = 0 ;
	Custom_person* mCp_ptr ;		/* male parent				*/
	Custom_person* fCp_ptr ;		/* female parent			*/
	Custom_person* cCp_ptr ;		/* child					*/
	int child_number ;				/* list number of child		*/
	short statuses[MAX_CHILDREN] ;

	if( Cc_ptr->child_numbers != NULL )
	{
		while( child_number = Cc_ptr->child_numbers[child], child_number != 0 )
		{
			cCp_ptr = get_Cp_ptr( child_number ) ;
			assert( cCp_ptr ) ;
			statuses[child] = cCp_ptr->status ;
			child++ ;
		}
	}
	if( Cc_ptr->male_number )  mCp_ptr = get_Cp_ptr( Cc_ptr->male_number ) ;
	if( Cc_ptr->female_number )  fCp_ptr = get_Cp_ptr( Cc_ptr->female_number ) ;
	
					/* If both parents moved and not all children unmoved	*/
					/* move couple complete including hline.				*/
	if( ( !Cc_ptr->male_number || mCp_ptr->status & SELECTED )
			&& ( !Cc_ptr->female_number || fCp_ptr->status & SELECTED ) )
	{
		Cc_ptr->x += x_move ;
		Cc_ptr->y += y_move ;
		
		adjust_couple_hline( Cc_ptr ) ;
		
		Cc_ptr->hline_y += y_move ;
	}
	else
	{
		if( Cc_ptr->male_number && mCp_ptr->status & CUST_SELECTED )
			adjust_couple_lines( mCp_ptr->list_number ) ;
		else if( Cc_ptr->female_number && fCp_ptr->status & CUST_SELECTED )
			adjust_couple_lines( fCp_ptr->list_number ) ;
	}
}


void  move_parent_segment( Custom_person* Cp_ptr, short x_move, short y_move )
{
	short* pld_ptr ;
	short move ;
	Custom_couple* Cc_ptr ;
	short end_y ;
	short last_length ;
	BOOLEAN horizontal_segment ;
	
	assert( Cp_ptr ) ;
	
	pld_ptr = Cp_ptr->parent_line_data ;
	
	end_y = Cp_ptr->box.g_y ;
	if( pld_ptr != NULL )
	{
		while( *pld_ptr != 0 )
		{
			end_y += *pld_ptr++ ;
			pld_ptr++ ;
		}
	}
	
	if( selected_segment % 2 )
	{
		horizontal_segment = TRUE ;
		move = y_move ;
	}
	else
	{
		horizontal_segment = FALSE ;
		move = x_move ;
	}

	Cc_ptr = get_Cc_ptr( Cp_ptr->parent_number ) ;
	assert( Cc_ptr ) ;
	last_length = Cc_ptr->hline_y - end_y ;
	
	move_segment( &(Cp_ptr->parent_line_data), selected_segment, move, last_length, horizontal_segment ) ;
	
	if( *(Cp_ptr->parent_line_data) == 0 )	/* if line reduced to single segment	*/
	{
		free( Cp_ptr->parent_line_data ) ;
		Cp_ptr->parent_line_data = NULL ;
	}
}


void  move_couple_segment( Custom_couple* Cc_ptr, short x_move, short y_move, short line_type )
{
	short move ;
	BOOLEAN horizontal_segment ;
	Custom_person* Cp_ptr ;

	switch( line_type )
	{
		case MLINE :
		case FLINE :
			if( selected_segment % 2 )
			{
				horizontal_segment = FALSE ;
				move = x_move ;
				y_move = 0 ;
			}
			else
			{
				horizontal_segment = TRUE ;
				move = y_move ;
				x_move = 0 ;
			}
			break ;
		case HLINE :
			break ;
		case VLINE :
			if( selected_segment % 2 )
			{
				horizontal_segment = TRUE ;
				move = y_move ;
			}
			else
			{
				horizontal_segment = FALSE ;
				move = x_move ;
			}
			break ;
		default :
			break ;
	}

	switch( line_type )
	{
		case MLINE :
			Cp_ptr = get_Cp_ptr( Cc_ptr->male_number ) ;
			if( last_segment )
			{
				move_cust_person( Cp_ptr, x_move, y_move ) ;
				Cp_ptr->status |= CUST_SELECTED ;
				test_move_cust_couple( Cc_ptr, x_move, y_move ) ;
				Cp_ptr->status &= ~CUST_SELECTED ;
				selected_line[1] += move ;
				selected_line[3] += move ;
			}
			else
			{
				assert( Cc_ptr->mline_data ) ;
				move_segment( &(Cc_ptr->mline_data), selected_segment, move, 0, horizontal_segment ) ;
				if( *(Cc_ptr->mline_data) == 0 )	/* if line reduced to single segment	*/
				{
					free( Cc_ptr->mline_data ) ;
					Cc_ptr->mline_data = NULL ;
				}
			}
			break ;
		case FLINE :
			Cp_ptr = get_Cp_ptr( Cc_ptr->female_number ) ;
			if( last_segment )
			{
				move_cust_person( Cp_ptr, x_move, y_move ) ;
				Cp_ptr->status |= CUST_SELECTED ;
				test_move_cust_couple( Cc_ptr, x_move, y_move ) ;
				Cp_ptr->status &= ~CUST_SELECTED ;
				selected_line[1] += move ;
				selected_line[3] += move ;
			}
			else
			{
				assert( Cc_ptr->fline_data ) ;
				move_segment( &(Cc_ptr->fline_data), selected_segment, move, 0, horizontal_segment ) ;
				if( *(Cc_ptr->fline_data) == 0 )	/* if line reduced to single segment	*/
				{
					free( Cc_ptr->fline_data ) ;
					Cc_ptr->fline_data = NULL ;
				}
			}
			break ;
		case HLINE :
			selected_line[1] += y_move ;
			selected_line[3] += y_move ;
			Cc_ptr->hline_y += y_move ;
			break ;
		case VLINE :
/*			str_report( "vertical line" ) ;
			adjust_couple_hline( Cc_ptr ) ;
*/
			break ;
		default :
			assert( FALSE ) ;
			break ;
	}
}


void  add_parent_segments( Custom_person* Cp_ptr, short segment, short position )
{
	short** ld_ptr_ptr ;
	
	assert( Cp_ptr ) ;

	ld_ptr_ptr = &(Cp_ptr->parent_line_data) ;
	add_segment( ld_ptr_ptr, segment, position ) ;
}


void  add_couple_segments( Custom_couple* Cc_ptr, short line_type, short segment, short position )
{
	short** ld_ptr_ptr = NULL ;
	
	assert( Cc_ptr ) ;

	switch( line_type )
	{
		case MLINE :
			ld_ptr_ptr = &(Cc_ptr->mline_data) ;
			break ;
		case FLINE :
			ld_ptr_ptr = &(Cc_ptr->fline_data) ;
			break ;
		case VLINE :
			ld_ptr_ptr = &(Cc_ptr->vline_data) ;
			break ;
		case HLINE :
			break ;
		default :
			assert( FALSE ) ;
			break ;
	}
	if( ld_ptr_ptr != NULL )  add_segment( ld_ptr_ptr, segment, position ) ;
}


			/*****	 	adjust_couple_lines								*****/
			/* Called when one partner only is moved from a marriage.		*/
			/* In case there are multiple marriages it checks that other	*/
			/* partner is not selected for each coupling.					*/
			/* It creates or edits polyline from "=" to edge of person box.	*/
			/*																*/
			/* Passed	list_number		number of person, not couple		*/

void  adjust_couple_lines( int list_number )
{
	int* coupling_ptr ;
	short couple_number ;
	Custom_person* Cp_ptr ;
	BOOLEAN male ;
	Custom_couple* Cc_ptr ;
	BOOLEAN left_partner ;	/* assumed male unless reversed status bit set	*/
	Custom_person* pCp_ptr ;	/* pointer to partner		*/
	BOOLEAN both_moved ;	/* only adjust lines if only one partner moved	*/
	short line_start_x ;
	short line_end_x ;
	short line_start_y ;
	short line_end_y ;
	short x ;
	short y ;
	short vertices ;
	short** line_data_ptr ;
	short* ldata_ptr ;

	Cp_ptr = get_Cp_ptr( list_number ) ;
	coupling_ptr = Cp_ptr->coupling_list ;
	if( coupling_ptr )
	{
		while( couple_number = *coupling_ptr++, couple_number )
		{
			Cc_ptr = get_Cc_ptr( couple_number ) ;
			
			if( list_number == Cc_ptr->male_number )
			{
				male = TRUE ;
				line_data_ptr = &(Cc_ptr->mline_data) ;
				left_partner = TRUE ;
			}
			else
			{
				male = FALSE ;
				line_data_ptr = &(Cc_ptr->fline_data) ;
				left_partner = FALSE ;
			}
			if( Cc_ptr->status & CUST_REVERSED )  left_partner = !left_partner ;
			
			if( male )
			{
				assert( Cc_ptr->female_number ) ;
				pCp_ptr = get_Cp_ptr( Cc_ptr->female_number ) ;
			}
			else
			{
				assert( Cc_ptr->male_number ) ;
				pCp_ptr = get_Cp_ptr( Cc_ptr->male_number ) ;
			}
			if( pCp_ptr->status & CUST_SELECTED )  both_moved = TRUE ;
			else  both_moved = FALSE ;
			
			if( !both_moved && Cc_ptr->male_number && Cc_ptr->female_number )
			{				/* both partners present so draw lines to '='	*/
				if( left_partner )
				{
					line_end_x = rect_end( &(Cp_ptr->box) ) ;
					line_start_x = Cc_ptr->x - couple_gap ;
				}
				else
				{
					line_end_x = Cp_ptr->box.g_x ;
					line_start_x = Cc_ptr->x + couple_gap ;
				}
				line_end_y = Cp_ptr->y ;
				line_start_y = Cc_ptr->y ;

				if( line_end_x == line_start_x && line_end_y == line_start_y )
				{
								/* remove line which is no longer needed	*/
					if( *line_data_ptr != NULL )
					{
						free( *line_data_ptr ) ;
						*line_data_ptr = NULL ;
					}
				}
				else
				{
								/* start line if none exists				*/
					if( *line_data_ptr == NULL )
					{
						*line_data_ptr = (short*) checked_malloc( 3 * sizeof( short ) ) ;
						if( *line_data_ptr != NULL )
						{
							if( line_end_y != line_start_y )
							{
								(*line_data_ptr)[0] = ( line_end_x - line_start_x ) / 2 ;
								(*line_data_ptr)[1] = line_end_y - line_start_y ;
								(*line_data_ptr)[2] = 0 ;
							}
							else  (*line_data_ptr)[0] = 0 ;
						}
					}
					else
								/* edit existing line						*/
					{
								/* find previous end of line				*/
						x = line_start_x ;
						y = line_start_y ;
						vertices = 0 ;
						ldata_ptr = *line_data_ptr ;
						while( *ldata_ptr != 0 )
						{
							x += *ldata_ptr++ ;
							y += *ldata_ptr++ ;
							vertices += 2 ;
						}
						if( y != line_end_y )	/* only change if vertical move	*/
						{
							if( vertices == 0 )	/* only horizontal line before	*/
							{
								(*line_data_ptr)[0] = ( line_end_x - x ) / 2 ;
								(*line_data_ptr)[1] = line_end_y - y ;
								(*line_data_ptr)[2] = 0 ;
							}
							else
							{
												/* adjust last y distance		*/
								(*line_data_ptr)[vertices-1] += line_end_y - y ;
									/* if last length now zero, remove pair of	*/
									/* vertices by zeroing previous length		*/
									/* (terminating list)						*/
								if( (*line_data_ptr)[vertices-1] == 0 )
									(*line_data_ptr)[vertices-2] = 0 ;
							}
						}
					}
				}
			}
		}
	}
}



void  reverse_selected_couples( void )
{
	Custom_couple* current_couple ;
	Custom_person* lCp_ptr ;
	Custom_person* rCp_ptr ;
	Custom_person* temp_Cp_ptr ;
	short y_difference ;
	short left_x_difference ;
	short right_x_difference ;
	short* line_data ;
	BOOLEAN changed = FALSE ;

	current_couple = custom_tree.start_couple ;
	while( current_couple != NULL )
	{
		if( current_couple->male_number && current_couple->female_number )
		{
			lCp_ptr = get_Cp_ptr( current_couple->male_number ) ;
			rCp_ptr = get_Cp_ptr( current_couple->female_number ) ;
			if( current_couple->status & CUST_REVERSED )
			{
				temp_Cp_ptr = lCp_ptr ;	
				lCp_ptr = rCp_ptr ;
				rCp_ptr = temp_Cp_ptr ;
			}
					
			if( lCp_ptr->status & CUST_SELECTED && rCp_ptr->status & CUST_SELECTED )
			{
				current_couple->status = current_couple->status ^ CUST_REVERSED ;
				changed = TRUE ;
			
				y_difference = lCp_ptr->y - rCp_ptr->y ;
				lCp_ptr->y -= y_difference ;
				lCp_ptr->box.g_y -= y_difference ;
				rCp_ptr->y += y_difference ;
				rCp_ptr->box.g_y += y_difference ;
				
				left_x_difference = rCp_ptr->box.g_x - lCp_ptr->box.g_x ;
				right_x_difference = rect_end( &(lCp_ptr->box) ) - rect_end( &(rCp_ptr->box) ) ;
				
				lCp_ptr->x += left_x_difference ; 
				lCp_ptr->box.g_x += left_x_difference ;
				rCp_ptr->x += right_x_difference ;
				rCp_ptr->box.g_x += right_x_difference ;
				
													/* swap line data over	*/
				line_data = current_couple->mline_data ;
				current_couple->mline_data = current_couple->fline_data ;
				current_couple->fline_data = line_data ;
				
						/* move people zero distance to update parent lines	*/
				move_cust_person( lCp_ptr, 0, 0 ) ;
				move_cust_person( rCp_ptr, 0, 0 ) ;
			}
		}
		current_couple = current_couple->next_couple ;
	}
	if( changed )
	{
		custom_tree_changed = TRUE ;
		send_redraw_message( &custom_display.custom_box, custom_form.fm_handle ) ;
	}
	else  rsrc_form_alert( 1, NO_COUPLE ) ;
}


void  remove_custom_coupling( Custom_couple* Cc_ptr )
{
	if( Cc_ptr->vline_data != NULL )  free( Cc_ptr->vline_data ) ;
	if( Cc_ptr->mline_data != NULL )  free( Cc_ptr->mline_data ) ;
	if( Cc_ptr->fline_data != NULL )  free( Cc_ptr->fline_data ) ;
	if( Cc_ptr->child_numbers != NULL )  free( Cc_ptr->child_numbers ) ;

	if( Cc_ptr->previous_couple != NULL )  (Cc_ptr->previous_couple)->next_couple = Cc_ptr->next_couple ;
	else  custom_tree.start_couple = Cc_ptr->next_couple ;
	if( Cc_ptr->next_couple != NULL )  (Cc_ptr->next_couple)->previous_couple = Cc_ptr->previous_couple ;
	else  custom_tree.end_couple = Cc_ptr->previous_couple ;
	
	free( Cc_ptr ) ;
}


int  get_cust_person_by_ref( int ref, int minimum_number )
{
	Custom_person* Cp_ptr ;
	int list_number = 0 ;
	
	Cp_ptr = custom_tree.start_person ;
	while( Cp_ptr != NULL && list_number <= minimum_number )
	{
		if( Cp_ptr->reference == ref )  list_number = Cp_ptr->list_number ;
		Cp_ptr = Cp_ptr->next_person ;
	}
	return list_number ;
}


Custom_couple* get_Cc_ptr( int list_number )
{
	Custom_couple* Cc_ptr ;
	BOOLEAN found = FALSE ;
	
	Cc_ptr = custom_tree.start_couple ;
	while( Cc_ptr != NULL && !found )
	{
		if( Cc_ptr->list_number == list_number )  found = TRUE ;
		else  Cc_ptr = Cc_ptr->next_couple ;
	}
	
	return Cc_ptr ;
}


Custom_person* get_Cp_ptr( int list_number )
{
	Custom_person* Cp_ptr ;
	BOOLEAN found = FALSE ;
	
	Cp_ptr = custom_tree.start_person ;
	while( Cp_ptr != NULL && !found )
	{
		if( Cp_ptr->list_number == list_number )  found = TRUE ;
		else  Cp_ptr = Cp_ptr->next_person ;
	}
	
	return Cp_ptr ;
}				



void  adjust_couple_hline( Custom_couple* Cc_ptr )
{
	short x0, x1 ;
	int* child_number_ptr ;
	short end_x, end_y ;
	Custom_person* Cp_ptr ;
	short* ld_ptr ;
	
	x0 = Cc_ptr->x ;
	if( Cc_ptr->vline_data )
	{
		ld_ptr = Cc_ptr->vline_data ;
		while( *ld_ptr )
		{
			ld_ptr++ ;
			x0 += *ld_ptr++ ;
		}
	}
	x1 = x0 ;
	
	if( Cc_ptr->child_numbers != NULL )
	{
		child_number_ptr = Cc_ptr->child_numbers ;
		
		while( *child_number_ptr != 0 )
		{
			Cp_ptr = get_Cp_ptr( *child_number_ptr ) ;
			assert( Cp_ptr ) ;
				
			if( !(Cp_ptr->attributes & HIDDEN_YES_BIT) )
			{
				get_last_parent_vertex( Cp_ptr, &end_x, &end_y ) ;
				if( end_x < x0 )  x0 = end_x ;
				if( end_x > x1 )  x1 = end_x ;
			}
			
			child_number_ptr++ ;
		}
	}
	
	Cc_ptr->hline_x0 = x0 ;
	Cc_ptr->hline_x1 = x1 ;
}	


void  adjust_tree_position( void )
{
	short xl ;		/* x left	*/
	short yt ;		/* y top	*/
	short xr ;		/* x right	*/
	short yb ;		/* y bottom	*/
	short x_shift = 0 ;
	short y_shift = 0 ;
	Custom_person* current_person ;
	Custom_couple* current_couple ;
	
	find_limits_of_tree( &xl, &xr, &yt, &yb ) ;
	
	if( ( (long) xr - xl ) > MAX_CUSTOM_WIDTH )  rsrc_form_alert( 1, TOO_WIDE ) ;
	else if( ( (long) yb - yt ) > MAX_CUSTOM_HEIGHT )  rsrc_form_alert( 1, TOO_HIGH ) ;

				/* else if tree exceeds any margin centre it	*/
	else if( xl < ( - MAX_CUSTOM_WIDTH / 2 ) || xr > ( MAX_CUSTOM_WIDTH / 2 )
			|| yt < ( - MAX_CUSTOM_HEIGHT / 2 ) || yb > ( MAX_CUSTOM_HEIGHT / 2 ) )
	{
		x_shift = xl + xr / 2 ;
		y_shift = yt + yb / 2 ;
		
		current_person = custom_tree.start_person ;
		while( current_person != NULL )
		{
			current_person->x -= x_shift ;
			current_person->y -= y_shift ;
			current_person->box.g_x -= x_shift ;
			current_person->box.g_y -= y_shift ;
		
			current_person = current_person->next_person ;
		}
		
		current_couple = custom_tree.start_couple ;
		while( current_couple != NULL )
		{
			current_couple->x -= x_shift ;
			current_couple->y -= y_shift ;
			current_couple->hline_x0 -= x_shift ;
			current_couple->hline_x1 -= x_shift ;
			current_couple->hline_y -= y_shift ;

			current_couple = current_couple->next_couple ;
		}
		custom_tree.org_x = xl - x_shift ;
		custom_tree.org_y = yt - y_shift ;
	}
	else
	{
		custom_tree.org_x = min( custom_tree.org_x, xl ) ;
		custom_tree.org_y = min( custom_tree.org_y, yt ) ;
	}
	custom_tree.lim_x = xr - x_shift ;
	custom_tree.lim_y = yb - y_shift ;
}
