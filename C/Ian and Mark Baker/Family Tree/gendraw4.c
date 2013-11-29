/************************************************************************/
/*																		*/
/*		Gendraw4.c	15 Mar 95											*/
/*																		*/
/************************************************************************/

#if !defined GEN_PH
	#include "geninc.h"			/* Use precompiled header GENINC.SYM ?	*/
#endif

#include "genhd.h"
#include "gendraw.h"
#include "genutil.h"
#include "gendata.h"

extern Index_couple *couples ;

extern BOOLEAN custom_tree_changed ;

extern short sibling_gap ;		/* default sibling horizontal spacing	*/
extern short couple_gap ;		/* default couple horizontal gap		*/
extern short generation_gap ;

extern Custom_device custom_display ;

extern Wind_edit_params custom_form ;

extern Custom_tree custom_tree ;

Custom_person*  add_custom_person( int reference, short x, short y, const FONTINFO* font_ptr, int parent_number )
{
	Custom_person* Cp_ptr ;

	Cp_ptr = (Custom_person*) checked_malloc( sizeof( Custom_person ) ) ;
	if( Cp_ptr )
	{
		if( font_ptr )
		{
			Cp_ptr->font_ptr = (FONTINFO*) checked_malloc( sizeof( FONTINFO ) ) ;
			if( Cp_ptr->font_ptr )
				*(Cp_ptr->font_ptr) = *font_ptr ;
			else
			{
				free( Cp_ptr ) ;
				Cp_ptr = NULL ;
			}
		}
		else  Cp_ptr->font_ptr = NULL ;
	}

	if( Cp_ptr )
	{
		if( custom_tree.end_person != NULL )
		{
			custom_tree.end_person->next_person = Cp_ptr ;
			Cp_ptr->list_number = custom_tree.end_person->list_number + 1 ;
		}
		else
		{
			Cp_ptr->list_number = 1 ;
			custom_tree.start_person = Cp_ptr ;
		}
		Cp_ptr->reference = reference ;
		Cp_ptr->x = x ;
		Cp_ptr->y = y ;
		Cp_ptr->status = CUST_SELECTED ;
		Cp_ptr->attributes = 0 ;
		Cp_ptr->font_ptr = NULL ;
		Cp_ptr->parent_number = parent_number ;
		Cp_ptr->coupling_list = NULL ; 	/* initialised zero, set by		*/
		Cp_ptr->couplings = 0 ;		/* draw_custom_person if necessary	*/
		Cp_ptr->couplings_drawn = 0 ;
		Cp_ptr->parent_line_data = NULL ;
		Cp_ptr->previous_person = custom_tree.end_person ;
		custom_tree.end_person = Cp_ptr ;
		Cp_ptr->next_person = NULL ;

				/* When adding to tree, calculate box. When		*/
				/* loading from file don't calculate.			*/
				/* Likewise for setting tree changed flag.		*/
		if( reference != 0 )
		{
			Cp_ptr->box = calculate_box( reference, x, y,
				Cp_ptr->attributes, Cp_ptr->font_ptr, Cp_ptr->parent_number ) ;
			custom_tree_changed = TRUE ;
		}
	}
	return Cp_ptr ;
}


GRECT  calculate_box( int reference, short x, short y,
				int attributes, FONTINFO* font_ptr, int parent_number )
{
	GRECT box ;
	BOOLEAN size_changed = FALSE ;
	
	box = get_box_size( reference, x, y, attributes, font_ptr, parent_number ) ;

	if( box.g_x - 1 < custom_tree.org_x )
	{
		size_changed = TRUE ;
		if( custom_display.x_start <= custom_tree.org_x )
			custom_display.x_start = box.g_x - 1 ;
		custom_tree.org_x = box.g_x - 1 ;
		send_redraw_message( &custom_display.custom_box, custom_form.fm_handle ) ;
	}
	if( rect_end( &box ) > custom_tree.lim_x )
	{
		size_changed = TRUE ;
		custom_tree.lim_x = rect_end( &box ) + 1 ;
	}
	
	if( box.g_y - 1 < custom_tree.org_y )
	{
		size_changed = TRUE ;
		if( custom_display.y_start <= custom_tree.org_y )
			custom_display.y_start = box.g_y - 1 ;
		custom_tree.org_y = box.g_y - 1 ;
		send_redraw_message( &custom_display.custom_box, custom_form.fm_handle ) ;
	}
	if( rect_bottom( &box ) + 1 > custom_tree.lim_y )
	{
		size_changed = TRUE ;
		custom_tree.lim_y = rect_bottom( &box ) + 1 ;
	}
	if( size_changed )  set_cust_sliders() ;
	
	return box ;
}


Custom_couple*  add_custom_parents( Custom_person* Cp_ptr )
{
	Custom_couple* Cc_ptr ;
	int siblings[MAX_CHILDREN] ;
	Custom_person* mCp_ptr = NULL ;		/* pointer to male parent		*/
	Custom_person* fCp_ptr = NULL ;		/* pointer to female parent		*/
	Person* pptr ;
	Couple* cptr ;
	int parents ;
	int father, mother ;
	int ref ;				/* temporary reference					*/
	short child ;			/* loop counter							*/
	short children ;		/* number of siblings, inc original		*/
	char* child_refs_ptr ;	/* pointer to references				*/
	short base_position_y ;		/* y position of original child		*/
	short upper_limit, lower_limit ;
	short leftest_sibling_x, rightest_sibling_x ;
	short highest_position_y ;
	short father_x, mother_x ;
	GRECT box_father, box_mother ;
	short parent_box_bottom ;
	short block ;			/* block number for get_[p/c]data_ptr	*/
	BOOLEAN fail = FALSE ;
	
	Cc_ptr = new_custom_couple() ;
	if( Cc_ptr == NULL )  return Cc_ptr ;
	pptr = get_pdata_ptr( Cp_ptr->reference, &block ) ;	
	assert( pptr != NULL ) ;
	parents = pptr->parents ;
	assert( parents != 0 ) ;
	Cc_ptr->reference = parents ;
	
	Cp_ptr->parent_number = Cc_ptr->list_number ;

	cptr = get_cdata_ptr( parents, &block ) ;
	child_refs_ptr = cptr->children ;
	assert( child_refs_ptr ) ;

					/* Force temporary father number in order that	*/
					/* auto_fname will work for add children.		*/
					/* Note that male_reference is wrongly used, it	*/
					/* will later be replaced with list number.		*/
	Cc_ptr->male_number = couples[parents].male_reference ;

				/* if person has auto fname, their size will change	*/
				/* with the addition of their father. Adjust their	*/
				/* position to allow for this if they are coupled.	*/
	if( cptr->male_reference != 0
		&& ( Cp_ptr->attributes & FNAME_AUTO_BIT
			|| ( (Cp_ptr->attributes & FNAME_BITS) == 0
				&& custom_tree.attributes & FNAME_AUTO_BIT ) ) )
	{
		Custom_couple* xCc_ptr ;
		short old_edge_x ;		/* active edge of person's box	*/
		short x_correction ;
		short reversed = FALSE ;
		short not_reversed = FALSE ;
		short coupling_index = 0 ;
		BOOLEAN left_partner = FALSE ;
		
		if( Cp_ptr->couplings_drawn != 0 )
		{
			while( *(Cp_ptr->coupling_list + coupling_index) )
			{
				xCc_ptr = get_Cc_ptr( *(Cp_ptr->coupling_list + coupling_index) ) ;
				assert( xCc_ptr ) ;
			
				if( xCc_ptr->status & CUST_REVERSED )  reversed = TRUE ;
				else  not_reversed = TRUE ;

				coupling_index++ ;
			}
				/* check if adjustment is possible, i.e. all	*/
				/* couplings on same side						*/
			if( reversed && !not_reversed || not_reversed && !reversed )
			{
				if( !reversed && xCc_ptr->male_number == Cp_ptr->list_number )
					left_partner = TRUE ;
				if( left_partner )
					old_edge_x = rect_end( &(Cp_ptr->box) ) ;
				else  old_edge_x = Cp_ptr->box.g_x ;
			}
		}
			
		Cp_ptr->box = calculate_box( Cp_ptr->reference, Cp_ptr->x, Cp_ptr->y,
				Cp_ptr->attributes, Cp_ptr->font_ptr, Cp_ptr->parent_number ) ;

		if( Cp_ptr->couplings_drawn != 0 )
		{
			if( left_partner )  x_correction = old_edge_x - rect_end( &(Cp_ptr->box) ) ;
			else  x_correction = old_edge_x - Cp_ptr->box.g_x ;
			Cp_ptr->x += x_correction ;
			Cp_ptr->box.g_x += x_correction ;
		}
	}

	child = 0 ;
	while( ( ref = form_ref( &child_refs_ptr ) ) && ( child < MAX_CHILDREN ) )
	{
		siblings[child] = ref ;
		child++ ;
	}
	siblings[child] = 0 ;
	children = child ;

				/* find current person in sibling array				*/
	child = 0 ;
	while( siblings[child] != Cp_ptr->reference )  child++ ;

	Cc_ptr->child_numbers = (int*) checked_malloc( (children + 1) * sizeof( int ) ) ;
	if( Cc_ptr->child_numbers == NULL )
	{
		Cp_ptr->parent_number = 0 ;
		remove_custom_coupling( Cc_ptr ) ;
		return NULL ;
	}
	
	Cc_ptr->child_numbers[child] = Cp_ptr->list_number ;
	Cc_ptr->child_numbers[children] = 0 ;						/* terminate list	*/

	upper_limit = Cp_ptr->box.g_x + Cp_ptr->box.g_w / 2 ;
	leftest_sibling_x = upper_limit ;	/* initialise limits to centre of original	*/
	rightest_sibling_x = upper_limit ;
	lower_limit = Cp_ptr->box.g_x ;
	base_position_y = Cp_ptr->box.g_y - Cp_ptr->box.g_h / 2 ;
	highest_position_y = Cp_ptr->box.g_y ;
	
												/* add any children to the left		*/
	if( child >= 1 )  fail = add_children( siblings, child-1, Cc_ptr, FALSE, upper_limit, lower_limit,
								base_position_y, &leftest_sibling_x, &highest_position_y) ;
	else  leftest_sibling_x = Cp_ptr->x ;
	
	if( fail )
	{
		Cp_ptr->parent_number = 0 ;
		remove_custom_coupling( Cc_ptr ) ;
		return NULL ;
	}
												/* add any children to the right	*/
	if( child+1 < children )  fail = add_children( siblings, child+1, Cc_ptr, TRUE, upper_limit, lower_limit,
								base_position_y, &rightest_sibling_x, &highest_position_y) ;
	else  rightest_sibling_x = Cp_ptr->x ;
	if( fail )
	{
		if( child >= 1 )
			while( --child >= 0 )
				remove_custom_person( get_Cp_ptr( Cc_ptr->child_numbers[child] ) ) ;
		Cp_ptr->parent_number = 0 ;
		remove_custom_coupling( Cc_ptr ) ;
		return NULL ;
	}

	if( father = couples[parents].male_reference )
		box_father = get_box_size( father, 0, 0, custom_tree.attributes, NULL, 0 ) ;
	if( mother = couples[parents].female_reference )
		box_mother = get_box_size( mother, 0, 0, custom_tree.attributes, NULL, 0 ) ;
	if( father )  Cc_ptr->y = highest_position_y - box_father.g_h - generation_gap ;
	else  Cc_ptr->y = highest_position_y - box_mother.g_h - generation_gap ;
	
	Cc_ptr->x = (leftest_sibling_x + rightest_sibling_x) / 2 ;
	if( father && mother )
	{
		father_x = Cc_ptr->x - box_father.g_w / 2 - couple_gap ;
		mother_x = Cc_ptr->x + box_mother.g_w / 2 + couple_gap ;
	}
	else
	{
		father_x = Cc_ptr->x ;
		mother_x = Cc_ptr->x ;
	}
	
	if( father )
	{
		mCp_ptr = add_custom_person( father, father_x, Cc_ptr->y, NULL, 0 ) ;
		if( mCp_ptr != NULL )
		{
			mCp_ptr->couplings_drawn = 1 ;
			Cc_ptr->male_number = mCp_ptr->list_number ;
			mCp_ptr->coupling_list = (int *) checked_malloc( 2 * sizeof( int ) ) ;
			if( mCp_ptr->coupling_list != NULL )
			{
				*(mCp_ptr->coupling_list) = Cc_ptr->list_number ;
				*(mCp_ptr->coupling_list + 1) = 0 ;	/* terminate list	*/
			}
			else  fail = TRUE ;
			parent_box_bottom = rect_bottom( &(mCp_ptr->box) ) ;
		}
		else  fail = TRUE ;
	}
	if( !fail && mother )
	{
		fCp_ptr = add_custom_person( mother, mother_x, Cc_ptr->y, NULL, 0 ) ;
		if( fCp_ptr != NULL )
		{
			fCp_ptr->couplings_drawn = 1 ;
			Cc_ptr->female_number = fCp_ptr->list_number ;
			fCp_ptr->coupling_list = (int *) checked_malloc( 2 * sizeof( int ) ) ;
			if( fCp_ptr->coupling_list != NULL )
			{
				*(fCp_ptr->coupling_list) = Cc_ptr->list_number ;
				*(fCp_ptr->coupling_list + 1) = 0 ;	/* terminate list	*/
			}
			else  fail = TRUE ;
		}
		else  fail = TRUE ;
		if( father )
		{
			if( rect_bottom( &(fCp_ptr->box) ) > parent_box_bottom )
				parent_box_bottom = rect_bottom( &(fCp_ptr->box) ) ;
		}
		else  parent_box_bottom = rect_bottom( &(fCp_ptr->box) ) ;
	}

	Cc_ptr->hline_x0 = leftest_sibling_x ;
	Cc_ptr->hline_x1 = rightest_sibling_x ;
	Cc_ptr->hline_y = parent_box_bottom + generation_gap / 2 ;

	if( fail )
	{
					/* remove children			*/
		child = 0 ;
		while( child < children )
		{
			if( Cc_ptr->child_numbers[child] != Cp_ptr->list_number )
				remove_custom_person( get_Cp_ptr( Cc_ptr->child_numbers[child] ) ) ;
			child++ ;
		}
		if( mCp_ptr )  remove_custom_person( mCp_ptr ) ;
		if( fCp_ptr )  remove_custom_person( fCp_ptr ) ;
		Cp_ptr->parent_number = 0 ;
		remove_custom_coupling( Cc_ptr ) ;
		Cc_ptr = NULL ;
	}
	return Cc_ptr ;
}


BOOLEAN  add_children( int* child_refs, short first_child, Custom_couple* Cc_ptr, BOOLEAN rightwards, short upper_x, short lower_x,
								short base_position_y, short* furthest_x, short* highest_y)
{
	Custom_person* child_ptr ;
	short child ;
	short sidestep ;
	short spacing ;
	BOOLEAN upper = TRUE ;
	GRECT box ;
	short upper_limit = upper_x ;
	short lower_limit = lower_x ;
	short child_position_x ;
	short child_position_y ;
	BOOLEAN fail = FALSE ;

	sidestep = rightwards ? 1 : -1 ;

	*furthest_x = upper_x ;
	
	child = first_child ;
	
	while( child >= 0 && child_refs[child] && !fail )
	{
		box = get_box_size( child_refs[child], 0, 0, custom_tree.attributes, NULL, Cc_ptr->list_number ) ;
		spacing = box.g_w / 2 + sibling_gap ;
		if( upper )
		{
			child_position_x = upper_limit + sidestep * spacing ;
			child_position_y = base_position_y ;
		}
		else
		{
			if( ( box.g_w / 2 ) < sidestep * ( upper_limit - lower_limit ) )
				child_position_x = upper_limit + sidestep * sibling_gap ;
			else
				child_position_x = lower_limit + sidestep * spacing ;
			child_position_y = base_position_y + box.g_h ;
		}
		child_ptr = add_custom_person( child_refs[child], child_position_x, child_position_y, NULL, Cc_ptr->list_number ) ;
		if( child_ptr )
		{
			child_ptr->parent_number = Cc_ptr->list_number ;
			Cc_ptr->child_numbers[child] = child_ptr->list_number ;
		
			if( upper )
			{
				if( rightwards )  upper_limit = rect_end( &(child_ptr->box) ) + 1 ;
				else  upper_limit = child_ptr->box.g_x ;
			}
			else
			{
				upper_limit = child_ptr->box.g_x + child_ptr->box.g_w / 2 ;

				if( rightwards )  lower_limit = rect_end( &(child_ptr->box) ) ;
				else  lower_limit = child_ptr->box.g_x ;
			}
			
			upper = !upper ;

			*furthest_x = child_ptr->x ;
			if( child_ptr->box.g_y < *highest_y )
				*highest_y = child_ptr->box.g_y ;
				
			child += sidestep ;
		}
		else  fail = TRUE ;
	}
	
	if( fail )			/* remove all children who have been added	*/
	{
		short failed_child ;

		failed_child = child ;
		child = first_child ;
		while( child != failed_child )
		{
			child_ptr = get_Cp_ptr( Cc_ptr->child_numbers[child] ) ;
			remove_custom_person( child_ptr ) ;
			child += sidestep ;
		}
	}
	
	return fail ;
}


void  update_all_couples( void )
{
	Custom_couple* current_couple ;
	Custom_person* Cp_ptr ;
	BOOLEAN all_selected = FALSE ;
	BOOLEAN couple_selected = TRUE ;
	
	Cp_ptr = get_next_selected_custom_person( custom_tree.start_person ) ;
	
	if( Cp_ptr == NULL )  all_selected = TRUE ;		/* nobody selected	*/

	current_couple = custom_tree.start_couple ;
	while( current_couple != NULL )
	{
		if( !all_selected )
		{
			couple_selected = FALSE ;
			if( current_couple->male_number )
			{
				Cp_ptr = get_Cp_ptr( current_couple->male_number ) ;
				if( Cp_ptr->status & SELECTED )  couple_selected = TRUE ;
			}
			if( current_couple->female_number )
			{
				Cp_ptr = get_Cp_ptr( current_couple->female_number ) ;
				if( Cp_ptr->status & SELECTED )  couple_selected = TRUE ;
			}
		}
		if( couple_selected )  update_children( current_couple ) ;
		current_couple = current_couple->next_couple ;
	}
}


void  update_children( Custom_couple* Cc_ptr )
{
	Couple* cptr ;
	Custom_person* Cp_ptr ;
	char* ch_ptr ;
	int* child_ptr ;
	int child ;
	int next_child ;
	BOOLEAN found ;
	short dummy ;
	short rightmost_position ;
	short left_update_limit ;
	
	cptr = get_cdata_ptr( Cc_ptr->reference, &dummy ) ;

	if( ( ch_ptr = cptr->children ) != NULL )
	{
				/* if any children already drawn find rightmost edge	*/
				/* else start from centre of couple						*/
		rightmost_position = Cc_ptr->x ;
				/* left_update_limit is used to ensure hline fully drawn	*/
		left_update_limit = Cc_ptr->x ;
		if( ( child_ptr = Cc_ptr->child_numbers ) != NULL )
		{
			while( *child_ptr != 0 )
			{
				Cp_ptr = get_Cp_ptr( *child_ptr++ ) ;
				left_update_limit = max( left_update_limit, Cp_ptr->x ) ;
				rightmost_position = max( rightmost_position, Cp_ptr->box.g_x + Cp_ptr->box.g_w ) ;
			}
		}

		ch_ptr = cptr->children ;
		next_child = form_ref( &ch_ptr ) ;
		while( child = next_child )
		{
			next_child = get_next_child( child, Cc_ptr->reference ) ;
			
			found = FALSE ;
			if( ( child_ptr = Cc_ptr->child_numbers ) != NULL )
			{
				while( *child_ptr != 0 )
				{
					Cp_ptr = get_Cp_ptr( *child_ptr++ ) ;
					if( Cp_ptr->reference == child )  found = TRUE ;
				}
			}
			if( !found )
				add_child( Cc_ptr, child, &rightmost_position, left_update_limit ) ;
		}
	}
}


void  add_child( Custom_couple* Cc_ptr, int ref, short *rightmost_position, short left_update_limit )
{
	Custom_person* Cp_ptr ;
	short previous_children = 0 ;
	int* child_ptr ;
	int* new_child_ptr ;
	int* child_numbers ;
	GRECT update_area ;

			/* add position is fairly arbitrary, relying on user to position	*/
	Cp_ptr = add_custom_person( ref, *rightmost_position, Cc_ptr->y + 2 * generation_gap, NULL, Cc_ptr->list_number ) ;

	if( Cp_ptr )
	{
		Cp_ptr->x += sibling_gap + Cp_ptr->box.g_w / 2 ;
		Cp_ptr->box.g_x += sibling_gap + Cp_ptr->box.g_w / 2 ;
					/* extend hline to new right hand limit position	*/
		Cc_ptr->hline_x1 = Cp_ptr->x ;
		
		
		if( ( child_ptr = Cc_ptr->child_numbers ) != NULL )
			while( *child_ptr++ != 0 )  previous_children++ ; 

		child_numbers = checked_malloc( ( previous_children + 2 ) * sizeof( int ) ) ;
		if( ( new_child_ptr = child_numbers ) != NULL )
		{
			if( ( child_ptr = Cc_ptr->child_numbers ) != NULL )
			{
				while( *child_ptr )  *new_child_ptr++ = *child_ptr++ ;
				free( Cc_ptr->child_numbers ) ;
			}
			Cc_ptr->child_numbers = child_numbers ;

			*rightmost_position = Cp_ptr->box.g_x + Cp_ptr->box.g_w ;
		
			*new_child_ptr++ = Cp_ptr->list_number ;
			*new_child_ptr = 0 ;	/* terminate list	*/
			
					/* screen area to update is width of person, but height	*/
					/* includes distance down from couple as well			*/
			update_area.g_x = mm2pix( left_update_limit, custom_display.x_start, XPOS, &custom_display ) ;
			update_area.g_w = mm2pix( Cp_ptr->box.g_x - left_update_limit + Cp_ptr->box.g_w, 0, XDIST, &custom_display ) ;
			update_area.g_y = mm2pix( Cc_ptr->y, custom_display.y_start, YPOS, &custom_display ) ; ;
			update_area.g_h = mm2pix( Cp_ptr->box.g_h + ( Cp_ptr->box.g_y - Cc_ptr->y ), 0, YDIST, &custom_display ) ;
			
			send_redraw_message( &update_area, custom_form.fm_handle ) ;
		}
		else  remove_custom_person( Cp_ptr ) ;
	}
}


void  remove_custom_person( Custom_person* Cp_ptr )
{
	if( Cp_ptr->font_ptr )  free( Cp_ptr->font_ptr ) ;
	if( Cp_ptr->parent_line_data )  free( Cp_ptr->parent_line_data ) ;
	if( Cp_ptr->coupling_list )  free( Cp_ptr->coupling_list ) ;

	if( Cp_ptr->previous_person == 0 )  custom_tree.start_person = Cp_ptr->next_person ;
	else  (Cp_ptr->previous_person)->next_person = Cp_ptr->next_person ;
	if( Cp_ptr->next_person == 0 )  custom_tree.end_person = Cp_ptr->previous_person ;
	else  (Cp_ptr->next_person)->previous_person = Cp_ptr->previous_person ;
	
	free( Cp_ptr ) ;
}


Custom_couple*  add_custom_coupling( Custom_person* Cp_ptr, short side )
{
	Custom_couple* Cc_ptr ;
	Custom_couple* sCc_ptr ;
	Custom_person* sCp_ptr ;		/* spouse Cp pointer		*/
	Custom_person* cCp_ptr ;		/* child Cp pointer			*/
	Person* pptr ;
	Couple* cptr ;
	BOOLEAN male ;			/* sex of pre-existing partner		*/
	short block ;
	int couple_reference = 0 ;
	int* new_coupling_list ;
	int* couple_list_ptr ;
	int* new_list_ptr ;
	char* coup_ptr ;
	int couple_ref ;				/* Couple reference number	*/
	int spouse_reference ;
	GRECT spouse_box ;
	short spouse_x ;
	short child_y ;
	int* child_number_ptr ;
	char* child_ptr ;
	int progeny[MAX_CHILDREN+1] ;
	int* prog_list_ptr ;
	short number_of_children ;
	short nearest_x ;
	short furthest_x ;
	short highest_y ;
	short parent_box_bottom ;

	Cc_ptr = new_custom_couple() ;
	if( Cc_ptr == NULL )  return Cc_ptr ;

	pptr = get_pdata_ptr( Cp_ptr->reference, &block ) ;
	coup_ptr = pptr->couplings ;	

	new_coupling_list = (int *) checked_malloc( ( Cp_ptr->couplings_drawn + 2 ) * sizeof( int ) ) ;
	if( new_coupling_list == NULL )
	{
		remove_custom_coupling( Cc_ptr ) ;
		return NULL ;
	}
	
	new_list_ptr = new_coupling_list ;

										/* find couple to add				*/

	if( Cp_ptr->couplings_drawn != 0 )
	{
		assert( Cp_ptr->coupling_list != NULL ) ;
												/* find first undrawn coupling	*/
		while( couple_ref = form_ref( &coup_ptr ), couple_ref != 0 && couple_reference == 0 )
		{
			BOOLEAN used ;
			
			couple_list_ptr = Cp_ptr->coupling_list ;
			used = FALSE ;
			while( *couple_list_ptr != 0 && couple_reference == 0 )
			{
				sCc_ptr = get_Cc_ptr( *couple_list_ptr++) ;
				if( couple_ref == sCc_ptr->reference )  used = TRUE ;
			}
			if( !used )  couple_reference = couple_ref ;
			else  couple_list_ptr++ ;
		}
		couple_list_ptr = Cp_ptr->coupling_list ;	
		while( *couple_list_ptr )
			*new_list_ptr++ = *couple_list_ptr++ ;
		free( Cp_ptr->coupling_list ) ;
	}
	else  couple_reference = form_ref( &coup_ptr ) ;

										/* initialise some values			*/

	*new_list_ptr++ = Cc_ptr->list_number ;
	*new_list_ptr++ = 0 ;
	Cc_ptr->reference = couple_reference ;
	Cp_ptr->coupling_list = new_coupling_list ;
	Cp_ptr->couplings_drawn++ ;
	
	Cc_ptr->y = Cp_ptr->y ;

										/* ascertain sex of existing		*/
										/* partner and ref of spouse, if	*/
										/* any								*/
	if( couples[couple_reference].male_reference == Cp_ptr->reference )
	{
		male = TRUE ;
		Cc_ptr->male_number = Cp_ptr->list_number ;
		spouse_reference = couples[couple_reference].female_reference ;
	}
	else
	{
		male = FALSE ;
		Cc_ptr->female_number = Cp_ptr->list_number ;
		spouse_reference = couples[couple_reference].male_reference ;
	}

										/* if spouse, add them to tree and	*/
										/* calculate lowest point of couple	*/

	if( spouse_reference != 0 )
	{
		if( male && side == CUST_LEFT || !male && side == CUST_RIGHT )  Cc_ptr->status |= CUST_REVERSED ;
	
		spouse_box = get_box_size( spouse_reference, 0, 0, custom_tree.attributes, NULL, 0 ) ;
		if( side == RIGHT )  Cc_ptr->x = rect_end( &(Cp_ptr->box) ) + couple_gap ;
		else  Cc_ptr->x = Cp_ptr->box.g_x - couple_gap ;
	
		if( side == RIGHT )  spouse_x = Cc_ptr->x + spouse_box.g_w / 2 + couple_gap ;
		else  spouse_x = Cc_ptr->x - spouse_box.g_w / 2 - couple_gap ;
		sCp_ptr = add_custom_person( spouse_reference, spouse_x, Cc_ptr->y, NULL, 0 ) ;
		if( sCp_ptr != NULL )
		{
			sCp_ptr->couplings_drawn = 1 ;
			if( male )  Cc_ptr->female_number = sCp_ptr->list_number ;
			else  Cc_ptr->male_number = sCp_ptr->list_number ;

			sCp_ptr->coupling_list = (int *) checked_malloc( 2 * sizeof( int ) ) ;
			if( sCp_ptr->coupling_list != NULL )
			{
				*(sCp_ptr->coupling_list) = Cc_ptr->list_number ;
				*(sCp_ptr->coupling_list + 1) = 0 ;	/* terminate list	*/
			}
		}
		if( rect_bottom( &(sCp_ptr->box) ) > rect_bottom( &(Cp_ptr->box) ) )
			parent_box_bottom = rect_bottom( &(sCp_ptr->box) ) ;
		else  parent_box_bottom = rect_bottom( &(Cp_ptr->box) ) ;
	}

										/* else if no spouse set bottom of	*/
										/* couple to bottom of person and	*/
										/* set spouse number to 0			*/

	else
	{
		Cc_ptr->x = Cp_ptr->x ;
		parent_box_bottom = rect_bottom( &(Cp_ptr->box) ) ;
		if( male )  Cc_ptr->female_number = 0 ;
		else  Cc_ptr->male_number = 0 ;
	}
										/* set hline_y even if there are no	*/
										/* children yet, ready for updating	*/
	Cc_ptr->hline_y = parent_box_bottom + generation_gap / 2 ;
	Cc_ptr->hline_x0 = Cc_ptr->x ;
	Cc_ptr->hline_x1 = Cc_ptr->x ;

										/* if any children, add them to		*/
										/* tree and couple list				*/

	cptr = get_cdata_ptr( Cc_ptr->reference, &block ) ;
	if( child_ptr = cptr->children, child_ptr != NULL )
	{
		prog_list_ptr = progeny ;
		number_of_children = 0 ;
		while( *prog_list_ptr++ = form_ref( &child_ptr ) )
		{
			number_of_children++ ;
		}
		Cc_ptr->child_numbers = (int *) checked_malloc( ( number_of_children + 1 ) * sizeof( int ) ) ;
		if( Cc_ptr->child_numbers != NULL )
		{
			int previous_last_number ;
			
			previous_last_number = custom_tree.end_person->list_number ;
			child_y = Cc_ptr->y + generation_gap ;
									/* measure width of children and add them at an arbitrary x position (i.e. 0)	*/
			highest_y = child_y ;	/* initialise to too low value	*/
			add_children( progeny, 0, Cc_ptr, TRUE, 0, 0,
								child_y, &furthest_x, &highest_y) ;

			prog_list_ptr = progeny ;
			child_number_ptr = Cc_ptr->child_numbers ;
			while( *prog_list_ptr )
			{
				*child_number_ptr++ = get_cust_person_by_ref( *prog_list_ptr++, previous_last_number ) ;
			}
			*child_number_ptr = 0 ;

			child_number_ptr = Cc_ptr->child_numbers ;
			cCp_ptr = get_Cp_ptr( Cc_ptr->child_numbers[0] ) ;
			nearest_x = cCp_ptr->x ;

			while( *child_number_ptr )
			{
				cCp_ptr = get_Cp_ptr( *child_number_ptr++ ) ;
				cCp_ptr->x += Cc_ptr->x - ( nearest_x + furthest_x ) / 2 ;
				cCp_ptr->box.g_x += Cc_ptr->x - ( nearest_x + furthest_x ) / 2 ;
				cCp_ptr->y += Cc_ptr->hline_y + generation_gap / 2 - highest_y ;
				cCp_ptr->box.g_y += Cc_ptr->hline_y + generation_gap / 2 - highest_y ;
			}

			cCp_ptr = get_Cp_ptr( Cc_ptr->child_numbers[0] ) ;
			Cc_ptr->hline_x0 = cCp_ptr->x ;
			if( custom_display.x_start <= custom_tree.org_x )
			{
				if( Cc_ptr->x - 1 < custom_display.x_start )
					custom_display.x_start = Cc_ptr->x - 1 ;
			}
			cCp_ptr = get_Cp_ptr( Cc_ptr->child_numbers[number_of_children - 1] ) ;
			Cc_ptr->hline_x1 = cCp_ptr->x ; 
		}
	}

	return Cc_ptr ;
}


Custom_couple* new_custom_couple( void )
{
	Custom_couple* Cc_ptr ;
	
	Cc_ptr = (Custom_couple*) checked_malloc( sizeof( Custom_couple ) ) ;

	if( Cc_ptr == NULL )  return Cc_ptr ;
	
	Cc_ptr->status = 0 ;
	
	if( custom_tree.end_couple == NULL )
	{
		Cc_ptr->list_number = 1 ;
		Cc_ptr->previous_couple = NULL ;
		custom_tree.start_couple = Cc_ptr ;
	}
	else
	{
		Cc_ptr->list_number = custom_tree.end_couple->list_number + 1 ;
		Cc_ptr->previous_couple = custom_tree.end_couple ;
		custom_tree.end_couple->next_couple = Cc_ptr ;
	}
	custom_tree.end_couple = Cc_ptr ;

	Cc_ptr->male_number = 0 ;	/* initialise to no mother or father	*/
	Cc_ptr->female_number = 0 ;
	Cc_ptr->next_couple = NULL ;
	
	Cc_ptr->child_numbers = NULL ;
	
	Cc_ptr->vline_data = NULL ;
	Cc_ptr->mline_data = NULL ;
	Cc_ptr->fline_data = NULL ;
	
	return Cc_ptr ;
}
