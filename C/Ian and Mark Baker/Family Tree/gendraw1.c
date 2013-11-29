/************************************************************************/
/*																		*/
/*		Gendraw1.c	 5 Dec 99											*/
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
#include "genfsel.h"
#include "genpers.h"
#include "genpsel.h"

extern short scr_handle ;		/* GEM vdi handle used by AES			*/
extern short scr_pixel_width, scr_pixel_height ;

extern FONTINFO fontinfo ;

extern Index_person* people ;
extern Index_couple* couples ;
extern int edit_pers_ref ;

extern OBJECT* icons_ptr ;
extern OBJECT* popups_ptr ;
extern OBJECT* menu_ptr ;		/* pointer used to point to				*/
								/* menu bar tree						*/

extern short work_in[] ;

extern char custom_file[] ;
extern BOOLEAN custom_tree_changed ;
const char* const custom_tree_help = "Custom Tree" ;
const char* const custom_attributes_help = "Custom Attributes" ;

extern short sibling_gap ;		/* default sibling horizontal spacing	*/
extern short couple_gap ;		/* default couple horizontal gap		*/
extern short generation_gap ;

extern int fsel_maxsize ;

extern OBJECT* strings_ptr ;

int first_person ;

Custom_device custom_display = { 0, 100, 6, {0,0,0,0}, 100, 100, 0, 0, 0 } ;
short custom_fulled ;			/* flag									*/
int custom_kind = NAME | CLOSE | SMALLER | FULL | MOVE | SIZE | UPARROW | DNARROW | VSLIDE | LFARROW | RTARROW | HSLIDE ;

Wind_edit_params custom_form ;

short selected_segment = 0 ;
short selected_segment_position ;
short selected_line[4] = { 0, 0, 0, 0 } ;
BOOLEAN last_segment ;

BOOLEAN show_hidden = FALSE ;
BOOLEAN show_custom_pages = FALSE ;

const short scales[] = { 10, 15, 25, 35, 50, 70, 100, 140, 200, 280, 400 } ;

Custom_tree custom_tree ;

OBJECT* attr_ptr ;

void  initialise_custom_tree( void )
{
	short work_out[57] ;		/* filled in by v_opnvwk				*/
	short dummy ;

	custom_tree.start_person = NULL ;
	custom_tree.end_person = NULL ;
	custom_tree.start_couple = NULL ;
	custom_tree.end_couple = NULL ;
	custom_tree.org_x = 0 ;
	custom_tree.org_y = 0 ;
	custom_display.x_start = custom_tree.org_x ;
	custom_display.y_start = custom_tree.org_y ;
	custom_tree.lim_x = 0 ;
	custom_tree.lim_y = 0 ;
	custom_tree.attributes = HIDDEN_NO_BIT + ALL_BIT + FNAME_AUTO_BIT
							+ DOB_YES_BIT + DOD_YES_BIT + 99 ;
	custom_tree.fontinfo = fontinfo ;

	if( !custom_display.handle )
	{
		custom_display.handle = graf_handle( &dummy, &dummy, &dummy, &dummy ) ;
		v_opnvwk( work_in, &(custom_display.handle), work_out ) ;
		vst_load_fonts( custom_display.handle, 0 ) ;
		vswr_mode( custom_display.handle, MD_TRANS ) ;
		custom_display.percent = 100 ;
		custom_display.pixel_width = scr_pixel_width ;
		custom_display.pixel_height = scr_pixel_height ;
	}
	custom_menu_enables( TRUE ) ;
}


void  new_custom_tree( void )
{
	char* fname ;				/* pointer to family name				*/
	Custom_person* Cp_ptr ;
	
	if( edit_pers_ref )
		fname = people[edit_pers_ref].family_name ;
	else  fname = NULL ;
	first_person = get_person_reference( fname, FALSE ) ;

	if( first_person )
	{
		initialise_custom_tree() ;
		custom_file[0] = '\0' ;		/* avoid saves under old name		*/
		Cp_ptr = add_custom_person( first_person, 0, 0, NULL, 0 ) ;
		if( Cp_ptr != NULL )  custom_tree_changed = TRUE ;
		else  close_custom_tree() ;
	}
}


void  open_custom_window( int first_person )
{
	open_titled_draw_window( &custom_form, custom_kind, CUSTOM_TITLE,
				CUSTOM_ITITLE, &custom_fulled, first_person, &custom_display.custom_box ) ;
	custom_form.help_ref = custom_tree_help ;
	if( custom_form.fm_handle > 0 )
	{
		menu_ienable( menu_ptr, DISP_CUSTOM, FALSE ) ;
		set_cust_sliders() ;
	}
}


void  close_custom_display( void )
{
	if( custom_form.fm_handle > 0 )
	{
		wind_close( custom_form.fm_handle ) ;
		wind_delete( custom_form.fm_handle ) ;
		custom_form.fm_handle = -1 ;
	}
	menu_ienable( menu_ptr, DISP_CUSTOM, TRUE ) ;
}


void  close_custom_tree( void )
{
	Custom_person* current_person ;
	Custom_person* next_person ;
	Custom_couple* current_couple ;
	Custom_couple* next_couple ;

	current_person = custom_tree.start_person ;
	while( current_person )
	{
		next_person = current_person->next_person ;
		if( current_person->font_ptr )  free( current_person->font_ptr ) ;
		if( current_person->parent_line_data )  free( current_person->parent_line_data ) ;
		free( current_person ) ;
		
		current_person = next_person ;
	}
	current_couple = custom_tree.start_couple ;
	while( current_couple )
	{
		next_couple = current_couple->next_couple ;
		if( current_couple->vline_data )  free( current_couple->vline_data ) ;
		free( current_couple ) ;
		
		current_couple = next_couple ;
	}
	custom_tree.start_person = NULL ;	/* indicate no tree loaded	*/
	custom_menu_enables( FALSE ) ;
	custom_tree_changed = FALSE ;
}


void  close_custom( void )
{
	if( custom_tree.start_person != NULL )
	{
		close_custom_display() ;
		close_custom_tree() ;
	}
}


void  set_custom_attributes( void )
{
	Custom_person* Cp_ptr ;
	Custom_couple* Cc_ptr ;
	int attributes ;
	int old_attributes ;
	int attribute_mask ;
	short forename_limit ;
	FONTINFO temp_fontinfo ;
	short button ;
	BOOLEAN selection = FALSE ;
	BOOLEAN default_font = FALSE ;
	BOOLEAN font_invalid = FALSE ;
	BOOLEAN attributes_cleared = FALSE ;
	BOOLEAN done = FALSE ;
	BOOLEAN font_malloc_failed = FALSE ;
	
	attr_ptr[SELECTION].ob_flags |= HIDETREE ;
	attr_ptr[CUST_DEFAULT].ob_flags |= HIDETREE ;


	Cp_ptr = get_next_selected_custom_person( custom_tree.start_person ) ;
	
	if( Cp_ptr == NULL )		/* nobody selected	*/
	{
		strcpy( FORM_TEXT( attr_ptr, SEL_OR_DEFAULT ), FORM_TEXT( attr_ptr, CUST_DEFAULT ) ) ;
		attr_ptr[SPACING].ob_flags &= ~HIDETREE ;		/* unhide wanted items	*/
		attr_ptr[ATTRIB_CLEAR].ob_flags |= HIDETREE ;	/* hide unwanted items	*/
		attr_ptr[HIDDEN].ob_flags |= HIDETREE ;
		sprintf( FORM_TEXT( attr_ptr, SIBLING_GAP ), "%2hd", sibling_gap ) ;
		sprintf( FORM_TEXT( attr_ptr, COUPLE_GAP ), "%2hd", couple_gap ) ;
		sprintf( FORM_TEXT( attr_ptr, GENERATION_GAP ), "%2hd", generation_gap ) ;
		attributes = custom_tree.attributes ;
		forename_limit = attributes & LIMIT_SIZE_BITS ;
		temp_fontinfo = custom_tree.fontinfo ;
	}
	else
	{
		selection = TRUE ;
		strcpy( FORM_TEXT( attr_ptr, SEL_OR_DEFAULT ), FORM_TEXT( attr_ptr, SELECTION ) ) ;
		attr_ptr[ATTRIB_CLEAR].ob_flags &= ~HIDETREE ;	/* unhide wanted items	*/
		attr_ptr[HIDDEN].ob_flags &= ~HIDETREE ;
		attr_ptr[SPACING].ob_flags |= HIDETREE ;		/* hide unwanted items	*/
		attributes = Cp_ptr->attributes ;
		forename_limit = attributes & LIMIT_SIZE_BITS ;
		if( Cp_ptr->font_ptr )  temp_fontinfo = *(Cp_ptr->font_ptr) ;
		else
		{
			default_font = TRUE ;
			temp_fontinfo = custom_tree.fontinfo ;
		}
		while( Cp_ptr = get_next_selected_custom_person( Cp_ptr->next_person ), Cp_ptr != NULL )
		{
			attributes &= Cp_ptr->attributes ;
			if( Cp_ptr->attributes & LIMIT_SIZE_BITS != forename_limit )  attributes &= ~FORENAME_LIMIT ;
			if( Cp_ptr->font_ptr && default_font )  font_invalid = TRUE ;
			if( Cp_ptr->font_ptr == NULL && !default_font )
			{
				temp_fontinfo = custom_tree.fontinfo ;
				default_font = TRUE ;
				font_invalid = TRUE ;
			}
		}
	}

	clear_attribute_fields( attr_ptr ) ;
	if( attributes & HIDDEN_YES_BIT )  attr_ptr[HIDDEN_YES].ob_state |= SELECTED ;
	if( attributes & HIDDEN_NO_BIT )  attr_ptr[HIDDEN_NO].ob_state |= SELECTED ;
	if( attributes & ONE_BIT )  attr_ptr[ONE].ob_state |= SELECTED ;
	if( attributes & ALL_BIT )  attr_ptr[ALL].ob_state |= SELECTED ;
	if( attributes & LIMIT_BIT )  attr_ptr[LIMIT].ob_state |= SELECTED ;
	sprintf( FORM_TEXT( attr_ptr, FORENAME_LIMIT ), "%d", forename_limit ) ;
	if( attributes & FNAME_YES_BIT )  attr_ptr[FNAME_YES].ob_state |= SELECTED ;
	if( attributes & FNAME_NO_BIT )  attr_ptr[FNAME_NO].ob_state |= SELECTED ;
	if( attributes & FNAME_AUTO_BIT )  attr_ptr[FNAME_AUTO].ob_state |= SELECTED ;
	if( attributes & DOB_YES_BIT )  attr_ptr[CUSTOM_DOB_YES].ob_state |= SELECTED ;
	if( attributes & DOB_NO_BIT )  attr_ptr[CUSTOM_DOB_NO].ob_state |= SELECTED ;
	if( attributes & DOD_YES_BIT )  attr_ptr[CUSTOM_DOD_YES].ob_state |= SELECTED ;
	if( attributes & DOD_NO_BIT )  attr_ptr[CUSTOM_DOD_NO].ob_state |= SELECTED ;

	app_modal_init( attr_ptr, custom_attributes_help, TITLED ) ;

	while( !done )
	{
		button = app_modal_do() ;
		button &= ~DOUBLE_CLICK ;
		if( button && button != APP_MODAL_TERM )
		{
			attr_ptr[button].ob_state &= ~SELECTED ;
			objc_draw( attr_ptr, button, 0, PTRS( app_modal_box() ) ) ;
		}

		switch( button )
		{
			case CUSTOM_FONT :
				{
					font_invalid = FALSE ;
					fsel_maxsize = 72 ;
					app_modal_end() ;
					temp_fontinfo = font_select( scr_handle, temp_fontinfo,
						(char *)strings_ptr[SEL_CUST_FONT].ob_spec ) ;
					app_modal_init( attr_ptr, "Set Attributes", TITLED ) ;
				}
				break ;
			case ATTRIB_CLEAR :
				font_invalid = TRUE ;
				attributes_cleared = TRUE ;
				clear_attribute_fields( attr_ptr ) ;
				objc_draw( attr_ptr, ROOT, MAX_DEPTH, PTRS( app_modal_box() ) ) ;
				break ;
			case ATTRIB_HELP :
				help( custom_attributes_help ) ;
				break ;
			case APP_MODAL_TERM :
				done = TRUE ;
				break ;

			default :
				done = TRUE ;
		}
	}
	app_modal_end() ;

	if( button == ATTRIB_OK )
	{
		attributes = atoi( FORM_TEXT( attr_ptr, FORENAME_LIMIT ) ) ;
		if( attr_ptr[HIDDEN_YES].ob_state & SELECTED )  attributes |= HIDDEN_YES_BIT ;
		if( attr_ptr[HIDDEN_NO].ob_state & SELECTED )  attributes |= HIDDEN_NO_BIT ;
		if( attr_ptr[ONE].ob_state & SELECTED )  attributes |= ONE_BIT ;
		if( attr_ptr[ALL].ob_state & SELECTED )  attributes |= ALL_BIT ;
		if( attr_ptr[LIMIT].ob_state & SELECTED )  attributes |= LIMIT_BIT ;
		if( attr_ptr[FNAME_YES].ob_state & SELECTED )  attributes |= FNAME_YES_BIT ;
		if( attr_ptr[FNAME_NO].ob_state & SELECTED )  attributes |= FNAME_NO_BIT ;
		if( attr_ptr[FNAME_AUTO].ob_state & SELECTED )  attributes |= FNAME_AUTO_BIT ;
		if( attr_ptr[CUSTOM_DOB_YES].ob_state & SELECTED )  attributes |= DOB_YES_BIT ;
		if( attr_ptr[CUSTOM_DOB_NO].ob_state & SELECTED )  attributes |= DOB_NO_BIT ;
		if( attr_ptr[CUSTOM_DOD_YES].ob_state & SELECTED )  attributes |= DOD_YES_BIT ;
		if( attr_ptr[CUSTOM_DOD_NO].ob_state & SELECTED )  attributes |= DOD_NO_BIT ;

		if( attributes_cleared && ( attributes & (HIDDEN_BITS + LIMIT_BITS + LIMIT_SIZE_BITS + FNAME_BITS + DOB_BITS + DOD_BITS) ) == 0 )		/* i.e. attributes cleared and none set	*/
			attribute_mask = HIDDEN_BITS + LIMIT_BITS + LIMIT_SIZE_BITS + FNAME_BITS + DOB_BITS + DOD_BITS ;
		else
		{
			attribute_mask = 0 ;
			if( attributes & HIDDEN_BITS )  attribute_mask += HIDDEN_BITS ;
			if( attributes & LIMIT_BITS )  attribute_mask += LIMIT_BITS + LIMIT_SIZE_BITS ;
			if( attributes & FNAME_BITS )  attribute_mask += FNAME_BITS ;
			if( attributes & DOB_BITS )  attribute_mask += DOB_BITS ;
			if( attributes & DOD_BITS )  attribute_mask += DOD_BITS ;
		}
	

		if( selection )
		{
			Cp_ptr = get_next_selected_custom_person( custom_tree.start_person ) ;
			while( Cp_ptr != NULL )
			{
				old_attributes = Cp_ptr->attributes ;
				Cp_ptr->attributes &= ~attribute_mask ;
				Cp_ptr->attributes |= attributes ;
				if( !font_invalid )
				{
					if( Cp_ptr->font_ptr == NULL && !font_malloc_failed )
						Cp_ptr->font_ptr = (FONTINFO*) checked_malloc( sizeof( FONTINFO ) ) ;
					if( Cp_ptr->font_ptr != NULL )  *(Cp_ptr->font_ptr) = temp_fontinfo ;
							/* this may be set repeatedly, but this will not waste significant time	*/	
						else  font_malloc_failed = TRUE ;
				}
				else if( attributes_cleared )
				{
					if( Cp_ptr->font_ptr != NULL )
					{
						free( Cp_ptr->font_ptr ) ;
						Cp_ptr->font_ptr = NULL ;
					}
				}
				Cp_ptr->box = calculate_box( Cp_ptr->reference, Cp_ptr->x, Cp_ptr->y,
													Cp_ptr->attributes, Cp_ptr->font_ptr, Cp_ptr->parent_number ) ;

				if( (old_attributes & HIDDEN_YES_BIT) != (Cp_ptr->attributes & HIDDEN_YES_BIT)
					&& Cp_ptr->parent_number > 0 )
				{
					Cc_ptr = get_Cc_ptr( Cp_ptr->parent_number ) ;
					assert( Cc_ptr != NULL ) ;
					adjust_couple_hline( Cc_ptr ) ;
						/* scan through children to see whether all hidden	*/
					if( Cc_ptr->child_numbers != NULL )
					{
						short child = 0 ;
						int child_number ;
						short number_unhidden = 0 ;
						Custom_person* cCp_ptr ;
						
						while( child_number = Cc_ptr->child_numbers[child], child_number != 0 )
						{
							cCp_ptr = get_Cp_ptr( child_number ) ;
							assert( cCp_ptr ) ;
							if( !(cCp_ptr->attributes & HIDDEN_YES_BIT) )  number_unhidden++ ;
							child++ ;
						}
						if( number_unhidden == 0 )  Cc_ptr->status |= CHILDREN_HIDDEN ;
						else  Cc_ptr->status &= ~CHILDREN_HIDDEN ;
					}

				}

				Cp_ptr = get_next_selected_custom_person( Cp_ptr->next_person ) ;
			}	
		}
		else
		{
			sibling_gap = atoi( FORM_TEXT( attr_ptr, SIBLING_GAP ) ) ;
			couple_gap = atoi( FORM_TEXT( attr_ptr, COUPLE_GAP ) ) ;
			generation_gap = atoi( FORM_TEXT( attr_ptr, GENERATION_GAP ) ) ;
			custom_tree.attributes = attributes ;
			custom_tree.fontinfo = temp_fontinfo ;
			Cp_ptr = custom_tree.start_person ;
			while( Cp_ptr != NULL )
			{
				Cp_ptr->box = calculate_box( Cp_ptr->reference, Cp_ptr->x, Cp_ptr->y,
							Cp_ptr->attributes, Cp_ptr->font_ptr, Cp_ptr->parent_number ) ;
				Cp_ptr = Cp_ptr->next_person ;
			}
		}
		custom_tree_changed = TRUE ;
		send_redraw_message( &custom_display.custom_box, custom_form.fm_handle ) ;
	}
}


void  clear_attribute_fields( OBJECT* attr_ptr )
{
	attr_ptr[ONE].ob_state &= ~SELECTED ;
	attr_ptr[ALL].ob_state &= ~SELECTED ;
	attr_ptr[LIMIT].ob_state &= ~SELECTED ;
	attr_ptr[FNAME_YES].ob_state &= ~SELECTED ;
	attr_ptr[FNAME_NO].ob_state &= ~SELECTED ;
	attr_ptr[FNAME_AUTO].ob_state &= ~SELECTED ;
	attr_ptr[CUSTOM_DOB_YES].ob_state &= ~SELECTED ;
	attr_ptr[CUSTOM_DOB_NO].ob_state &= ~SELECTED ;
	attr_ptr[CUSTOM_DOD_YES].ob_state &= ~SELECTED ;
	attr_ptr[CUSTOM_DOD_NO].ob_state &= ~SELECTED ;
	attr_ptr[HIDDEN_YES].ob_state &= ~SELECTED ;
	attr_ptr[HIDDEN_NO].ob_state &= ~SELECTED ;
}


void  graphic_mu_mesag( Wind_edit_params* form, short* fulled, const short* message, GRECT* disp_box )
{
	GRECT* rect ;			/* Grect pointer for wind_redraw			*/
	GRECT tempbox ;

	switch( message[0] )
	{	case WM_FULLED :
			if( !*fulled )
			{	wind_get( form->fm_handle, WF_FULLXYWH, REFS( tempbox ) ) ;
				*fulled = TRUE ;
			}
			else
			{	wind_get( form->fm_handle, WF_PREVXYWH, REFS( tempbox ) ) ;
				*fulled = FALSE ;
			}
			wind_set( form->fm_handle, WF_CURRXYWH, ELTS( tempbox ) ) ;
			wind_calc( WC_WORK, custom_kind, ELTS( tempbox ),
					&(disp_box->g_x), &(disp_box->g_y), &(disp_box->g_w), &(disp_box->g_h)  ) ;
			send_redraw_message( disp_box, form->fm_handle ) ;
			break ;
		case WM_MOVED :
		case WM_SIZED :
			rect = (GRECT *) &(message[4]) ;
			wind_set( form->fm_handle, WF_CURRXYWH, PTRS( rect ) ) ;
			form->fm_box = *rect ;
			*fulled = FALSE ;
			break ;
		case WM_TOPPED :
			wind_set( form->fm_handle, WF_TOP ) ;
			break ;
		case WM_BOTTOM :
			wind_set( form->fm_handle, WF_BOTTOM ) ;
			break ;
		case WM_ALLICONIFY :
			iconify_all( form->fm_box.g_x ) ;
			break ;
		case WM_ICONIFY :
			wind_set( form->fm_handle, WF_UNICONIFYXYWH, ELTS( form->fm_box ) ) ;
			form->fm_box = *(GRECT *)&message[4] ;
			form->iconified = TRUE ;
			wind_set( form->fm_handle, WF_ICONIFY, ELTS( form->fm_box ) ) ;
			wind_title( form->fm_handle, form->icon_title ) ;
			send_redraw_message( &form->fm_box, form->fm_handle ) ;
			break ;
		case WM_UNICONIFY :
			wind_get( form->fm_handle, WF_UNICONIFY, REFS( form->fm_box ) ) ;
			wind_set( form->fm_handle, WF_UNICONIFY, ELTS( form->fm_box ) ) ;
			wind_title( form->fm_handle, form->title_str ) ;
			form->iconified = FALSE ;
			break ;
		default :
			break ;
	}
}


void  custom_mu_mesag( const short* message )
{
	GRECT* rect ;			/* Grect pointer for wind_redraw			*/

	rect = (GRECT *) &(message[4]) ;

	switch( message[0] )
	{	case WM_FULLED :
			set_cust_sliders() ;
			break ;
		case WM_REDRAW :
			wind_redraw( (int) message[3], rect, custom_redraw ) ;
			break ;
		case WM_MOVED :
		case WM_SIZED :
			wind_calc( WC_WORK, custom_kind, ELTS( custom_form.fm_box ),
					REFS( custom_display.custom_box ) ) ;
			set_cust_sliders() ;
			if( message[0] == WM_SIZED )
			{
				send_redraw_message( rect, custom_form.fm_handle ) ;
			}
			break ;
		case WM_CLOSED :
			close_custom_display() ;
			break ;
		case WM_VSLID :
			if( ( custom_tree.lim_y - custom_tree.org_y )
					> pix2mm( custom_display.custom_box.g_h, 0, YDIST, &custom_display ) )
			{	
				custom_display.y_start = custom_tree.org_y
					+ (long) message[4] * ( ( custom_tree.lim_y - custom_tree.org_y )
					- pix2mm( custom_display.custom_box.g_h, 0, YDIST, &custom_display ) ) / 1000 ;
				set_cust_sliders() ;
				send_redraw_message( &custom_display.custom_box, custom_form.fm_handle ) ;
			}
			break ;
		case WM_HSLID :
			if( ( custom_tree.lim_x - custom_tree.org_x )
					> pix2mm( custom_display.custom_box.g_w, 0, XDIST, &custom_display ) )
			{	
				custom_display.x_start = custom_tree.org_x
					+ (long) message[4] * ( ( custom_tree.lim_x - custom_tree.org_x )
					- pix2mm( custom_display.custom_box.g_w, 0, XDIST, &custom_display ) ) / 1000 ;
				set_cust_sliders() ;
				send_redraw_message( &custom_display.custom_box, custom_form.fm_handle ) ;
			}
			break ;
		case WM_ARROWED :
			custom_scrolled( message ) ;
			break ;
		case WM_UNICONIFY :
			wind_calc( WC_WORK, custom_kind, ELTS( custom_form.fm_box ),
					REFS( custom_display.custom_box ) ) ;
			break ;
		default :
			break ;
	}
}


void  cust_mu_button( short m_x, short m_y, short breturn )
{
	BOOLEAN redraw = FALSE ;
	short xmm, ymm ;
	/* Cp_ptr nulled as it will not be set up if alt key held	*/
	Custom_person* Cp_ptr = NULL ;	/* odd job pointer			*/
	int list_number ;
	Custom_couple* Cc_ptr ;
	Custom_person* current_person ;	/* list traversing pointer	*/
	Custom_couple* current_couple ;	/* list traversing pointer	*/
	char selection = 0 ;
	BOOLEAN already_selected = FALSE ;
	short button ;
	short kstate ;
	short new_x, new_y ;
	Custom_person* line_Cp_ptr = NULL ;	/* used for marking selected line segment	*/
	Custom_couple* line_Cc_ptr = NULL ;
	short line[4] ;
	short segment = 0 ;
	short position ;
	short line_type ;
	short clip_array[4] ;

	if( !custom_form.iconified
		&& m_x > custom_display.custom_box.g_x && m_x < rect_end( &(custom_display.custom_box) )
		&& m_y > custom_display.custom_box.g_y && m_y < rect_bottom( &(custom_display.custom_box) ) )
	{
		grect2pxy( &( custom_display.custom_box ), clip_array ) ;

		graf_mkstate( &new_x, &new_y, &button, &kstate ) ;
		
		xmm = pix2mm( m_x, custom_display.x_start, XPOS, &custom_display ) ;
		ymm = pix2mm( m_y, custom_display.y_start, YPOS, &custom_display ) ;

				/* do not select person if alt key pressed	*/
				/* to allow selection of line instead		*/
		if( !(kstate & K_ALT) )
			Cp_ptr = get_cust_person( xmm, ymm, &selection ) ;
		if( !Cp_ptr )  line_Cp_ptr = get_cust_psegment( xmm, ymm, line, &segment, &position ) ;
		if( !Cp_ptr && !line_Cp_ptr )
			line_Cc_ptr = get_cust_csegment( xmm, ymm, line, &line_type, &segment, &position ) ;



		if( Cp_ptr )
		{
			if( Cp_ptr->status & SELECTED )  already_selected = TRUE ;
			list_number = Cp_ptr->list_number ;
		}
		else  list_number = 0 ;

								/* shift not held, and button clicked, not held	*/
		if( !(kstate & (K_RSHIFT | K_LSHIFT)) && ( button == 0 || !already_selected ) )
		{
			GRECT page ;

			page.g_x = pix2mm( custom_display.custom_box.g_x, custom_display.x_start, XPOS, &custom_display ) ;
			page.g_w = pix2mm( custom_display.custom_box.g_w, 0, XDIST, &custom_display ) ;
			page.g_y = pix2mm( custom_display.custom_box.g_y, custom_display.y_start, YPOS, &custom_display ) ;
			page.g_h = pix2mm( custom_display.custom_box.g_h, 0, YDIST, &custom_display ) ;

			current_person = custom_tree.start_person ;

			graf_mouse( M_OFF, 0 ) ;		/* turn off mouse while drawing		*/
			while( current_person != NULL )
			{
				if( current_person->status & SELECTED
						&& ( current_person->list_number != list_number )
						&& is_onpage( current_person, &page ) )
				{
					if( top_window() == CUSTOM_WINDOW )
						directly_draw_selected_box( current_person, clip_array ) ;
					else  redraw = TRUE ;
				}

				current_person->status &= ~CUST_SELECTED ;
				current_person = current_person->next_person ;
			}
			graf_mouse( M_ON, 0 ) ;			/* restore mouse after drawing		*/
		}

								/* if valid segment update global copies		*/
		selected_segment = segment ;
		if( segment != 0 )
		{
			short i ;
				
			selected_segment_position = position ;
			for( i=0; i<4; i++ )  selected_line[i] = line[i] ;
		}

		if( breturn > 1 )		/* double click, edit person or add segments	*/
		{
			if( Cp_ptr != NULL )  edit_person( Cp_ptr->reference ) ;
			else if( line_Cp_ptr != NULL )
			{
				add_parent_segments( line_Cp_ptr, segment, position ) ;
				redraw = TRUE ;
			}
			else if( line_Cc_ptr != NULL )
			{
				add_couple_segments( line_Cc_ptr, line_type, segment, position ) ;
				redraw = TRUE ;
			}
		}

		else if( button == 0 )				/* single click, button released	*/
		{
			if( !(kstate & (K_RSHIFT | K_LSHIFT)) )	/* shift not held			*/
			{
				if( Cp_ptr )  Cp_ptr->status |= CUST_SELECTED ;
					
				if( already_selected )
				{
					switch( selection )
					{
						case 'p' :
							add_custom_parents( Cp_ptr ) ;
							break ;
						case 'l' :
							add_custom_coupling( Cp_ptr, CUST_LEFT ) ;
							break ;
						case 'r' :
							add_custom_coupling( Cp_ptr, CUST_RIGHT ) ;
							break ;
						default :
							break ;
					}
					redraw = TRUE ;
				}
				else
				{
					if( Cp_ptr != NULL )
					{
						if(top_window() == CUSTOM_WINDOW )
							directly_draw_selected_box( Cp_ptr, clip_array ) ;
						else  redraw = TRUE ;
					}
				}

			}
			else									/* shift held				*/
			{	
				if( Cp_ptr )
				{
					if( Cp_ptr->status & CUST_SELECTED )  Cp_ptr->status &= ~CUST_SELECTED ;
					else  Cp_ptr->status |= CUST_SELECTED ;
					if( top_window() == CUSTOM_WINDOW )
						directly_draw_selected_box( Cp_ptr, clip_array ) ;
					else  redraw = TRUE ;
				}
			}
		}
								/* button held and custom window top		*/
		else if( CUSTOM_WINDOW == top_window() )
		{
			short x_move ;
			short y_move ;

			if( Cp_ptr != NULL )
			{
				Cp_ptr->status |= SELECTED ;

				get_mouse_move_mm( &x_move, &y_move, m_x, m_y ) ;

				current_person = custom_tree.start_person ;
				while( current_person != NULL )
				{
					if( current_person->status & CUST_SELECTED )
						move_cust_person( current_person, x_move, y_move ) ;
					current_person = current_person->next_person ;
				}
				
				current_couple = custom_tree.start_couple ;
				while( current_couple != NULL )
				{
					test_move_cust_couple( current_couple, x_move, y_move ) ;
					current_couple = current_couple->next_couple ;
				}
				custom_tree_changed = TRUE ;
			}

			else if( selected_segment != 0 )
			{
				graf_mouse( M_OFF, NULL ) ;
				wind_update( BEG_UPDATE ) ;
				wind_update( BEG_MCTRL ) ;
				draw_selected_boxes( custom_display.custom_box, 0, 0 ) ;
				wind_update( END_MCTRL ) ;
				wind_update( END_UPDATE ) ;
				graf_mouse( M_ON, NULL ) ;
				
				get_mouse_move_mm( &x_move, &y_move, m_x, m_y ) ;

				if( line_Cp_ptr != NULL )
				{
					move_parent_segment( line_Cp_ptr, x_move, y_move ) ;
					Cc_ptr = get_Cc_ptr( line_Cp_ptr->parent_number ) ;
					adjust_couple_hline( Cc_ptr ) ;
				}
				if( line_Cc_ptr != NULL )  move_couple_segment( line_Cc_ptr, x_move, y_move, line_type ) ;

				selected_segment = 0 ;	/* do not dash line as it does not remain selected	*/
				custom_tree_changed = TRUE ;
			}
						/* nothing to move so rubber band		*/
			else
			{
				short m_x_mm ;
				short m_y_mm ;
				short x_move ;
				short y_move ;
				short lo_x ;
				short lo_y ;
				short hi_x ;
				short hi_y ;

				custom_rubber_band( &x_move, &y_move, m_x, m_y ) ;

				m_x_mm = pix2mm( m_x, custom_display.x_start, XPOS, &custom_display ) ;
				m_y_mm = pix2mm( m_y, custom_display.y_start, YPOS, &custom_display ) ;

				if( x_move < 0 )
				{
					lo_x = m_x_mm + x_move ;
					hi_x = m_x_mm ;
				}
				else
				{
					lo_x = m_x_mm ;
					hi_x = m_x_mm + x_move ;
				} 
				if( y_move < 0 )
				{
					lo_y = m_y_mm + y_move ;
					hi_y = m_y_mm ;
				}
				else
				{
					lo_y = m_y_mm ;
					hi_y = m_y_mm + y_move ;
				} 
				current_person = custom_tree.start_person ;
				while( current_person != NULL )
				{
					if( current_person->box.g_x >= lo_x
							&& rect_end( &(current_person->box) ) <= hi_x
							&& current_person->box.g_y >= lo_y
							&& rect_bottom( &(current_person->box) ) <= hi_y
							&& ( !(current_person->attributes & HIDDEN_YES_BIT) || show_hidden ) )
						current_person->status |= SELECTED ;
					current_person = current_person->next_person ;
				}
 
			}
			redraw = TRUE ;
		}
	}
	if( redraw )  send_redraw_message( &custom_display.custom_box, custom_form.fm_handle ) ;
}


void  select_all_custom_people( void )
{
	Custom_person* current_person ;

	current_person = custom_tree.start_person ;

	while( current_person != NULL )
	{
		current_person->status |= CUST_SELECTED ;
		current_person = current_person->next_person ;
	}
	send_redraw_message( &custom_display.custom_box, custom_form.fm_handle ) ;
}


void  custom_menu_enables( BOOLEAN flag )
{
	menu_ienable( menu_ptr, CLOSE_CUSTOM, flag ) ;
	menu_ienable( menu_ptr, SAVE_CUSTOM_AS, flag ) ;
	menu_ienable( menu_ptr, UPDATE_CHILDREN, flag ) ;
	menu_ienable( menu_ptr, REVERSE_COUPLE, flag ) ;
	menu_ienable( menu_ptr, CUSTOM_ATTRIBS, flag ) ;
	menu_ienable( menu_ptr, CUSTOM_SCALE, flag ) ;
	menu_ienable( menu_ptr, SHOW_HIDDEN, flag ) ;
	menu_ienable( menu_ptr, SHOW_PAGES, flag ) ;
	menu_ienable( menu_ptr, PRINT_CUSTOM, flag ) ;
}


void  popup_scale_selector( void )
{
	MENU popup ;
	short x, y ;
	short old_scale_percent ;

		/* SCALE10 assumed minimum											*/
	assert( SCALE15 - SCALE10 == 1 ) ;
	assert( SCALE25 - SCALE10 == 2 ) ;
	assert( SCALE35 - SCALE10 == 3 ) ;
	assert( SCALE50 - SCALE10 == 4 ) ;
	assert( SCALE70 - SCALE10 == 5 ) ;
		/* 100% = 6 assumed in initialisations in gencprn.c and this file	*/
	assert( SCALE100 - SCALE10 == 6 ) ;
	assert( SCALE140 - SCALE10 == 7 ) ;
	assert( SCALE200 - SCALE10 == 8 ) ;
	assert( SCALE280 - SCALE10 == 9 ) ;
	assert( SCALE400 - SCALE10 == 10 ) ;
	assert( SCALE400 - SCALE10 == MAX_SCALE_INDEX ) ;

	old_scale_percent = custom_display.percent ;

	popup.mn_tree = popups_ptr ;
	popup.mn_menu = SCALE_SELECTOR ;
	
	popup.mn_item = SCALE10 + custom_display.scale_index ;

	objc_offset( menu_ptr, CUSTOM_SCALE, &x, &y ) ;
	popup_menu( &popup, x, y, &popup ) ;
	
	custom_display.scale_index = popup.mn_item - SCALE10 ;
	custom_display.percent = scales[custom_display.scale_index] ;
	if( custom_display.percent != old_scale_percent && custom_form.fm_handle > 0 )
	{
		send_redraw_message( &custom_display.custom_box, custom_form.fm_handle ) ;
		set_cust_sliders() ;
	}
}


void  custom_zoom( short zoom_steps )
{
	short old_scale_index ;
	short m_x, m_y ;
	short old_m_xmm, old_m_ymm ;
	short new_m_xmm, new_m_ymm ;
	short dummy ;

	old_scale_index = custom_display.scale_index ;
	custom_display.scale_index += zoom_steps ;
	if( custom_display.scale_index < MIN_SCALE_INDEX )  custom_display.scale_index = MIN_SCALE_INDEX ;
	if( custom_display.scale_index > MAX_SCALE_INDEX )  custom_display.scale_index = MAX_SCALE_INDEX ;
	
	if( custom_display.scale_index != old_scale_index )
	{
		graf_mkstate( &m_x, &m_y, &dummy, &dummy ) ;	/* find mouse position	*/
									/* calculate and store mouse position in mm	*/
		old_m_xmm = pix2mm( m_x, custom_display.x_start, XPOS, &custom_display ) ;
		old_m_ymm = pix2mm( m_y, custom_display.y_start, YPOS, &custom_display ) ;
		
		custom_display.percent = scales[custom_display.scale_index] ;
		
									/* calculate new mouse position in mm		*/
		new_m_xmm = pix2mm( m_x, custom_display.x_start, XPOS, &custom_display ) ;
		new_m_ymm = pix2mm( m_y, custom_display.y_start, YPOS, &custom_display ) ;
		
						/* adjust starts to put same point under mouse pointer	*/
		custom_display.x_start -= new_m_xmm - old_m_xmm ;
		custom_display.y_start -= new_m_ymm - old_m_ymm ;
		
		if( custom_form.fm_handle > 0 )
		{
			set_cust_sliders() ;
			send_redraw_message( &custom_display.custom_box, custom_form.fm_handle ) ;
		}
	}
	
	if( _AESglobal[0] >= 0x0330 )
		menu_istart( MIS_SETALIGN, popups_ptr, SCALE_SELECTOR, SCALE10 + custom_display.scale_index ) ;
}
