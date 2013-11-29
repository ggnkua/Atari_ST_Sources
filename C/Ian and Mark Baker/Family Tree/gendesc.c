/************************************************************************/
/*																		*/
/*		Gendesc.c	22 Jul 97											*/
/*																		*/
/************************************************************************/

#if !defined GEN_PH
	#include "geninc.h"			/* Use precompiled header GENINC.SYM ?	*/
#endif

#include "genhd.h"
#include "gendesc.h"
#include "genutil.h"
#include "gencoup.h"
#include "gendata.h"
#include "genpers.h"
#include "genprnt.h"
#include "genpsel.h"

extern Index_person *people ;
extern int edit_pers_ref ;
extern GRECT deskbox ;
extern short scr_handle ;

extern OBJECT *icons_ptr ;

extern Preferences prefs ;

const char* const descendants_help = "Descendants" ;

short verticals[MAX_LEVELS] ;
short max_levels ;
short desc_lines ;		/* number of lines to display all descendants	*/
short desc_first_line ;
short desc_chars_up ;	/* descendant window height						*/
short mouse_clicked_line ;
int mouse_clicked_ref ;
short desc_slider_posn = -1 ;		/* combined flag and actual posn	*/

Wind_edit_params desc_form ;
GRECT disp_desc_box ;			/* display area used for tree			*/
short desc_fulled ;				/* flag									*/
int desc_root = 0 ;				/* person at start of desc display		*/

int desc_kind = NAME | CLOSE | SMALLER | FULL | MOVE | SIZE | UPARROW
										| DNARROW | VSLIDE | HSLIDE ;


void  print_descendants( int ref )
{
	int reference ;
	Str_prt_params params ;
	short i ;

	if( !ref )  reference = get_person_reference( NULL, FALSE ) ;
	else  reference = ref ;
	if( !reference )  return ;

	for( i=0; i<MAX_LEVELS; i++ )  verticals[i] = FALSE ;

	if( open_printer( &params ) )
	{
		busy( BUSY_MORE ) ;
		
		params.ref1 = reference ;
		params.ref2 = 0 ;			/* Do not print second reference.	*/

		max_levels = MAX_LEVELS ;
		find_max_levels( reference, 0, &params ) ;

		if( max_levels < 2 )  rsrc_form_alert( 1, GROSS_FONT ) ;
		else
		{
			start_print_checking( &params ) ;

			params.align = LEFT ;
			params.x_pos = 0 ;
			params.max_len = 0 ;
			params.last_x_end = 0 ;
			params.y_pos = 0 ;
			params.tabpos = SPOUSE_SPACING ;
			params.downlines = 1 ;
			params.line_number = 0 ;
			params.first_line = 0 ;
			params.last_line = 32767 ;

			print_desc( reference, 0, &params ) ;
			end_page( &params, FALSE ) ;
		}

		close_printer( &params ) ;

		busy( BUSY_LESS ) ;
	}
}


void  build_spouse_name_string( char* names, int ref, int* spouse, Couple *cptr )
{
	if( cptr->male_reference == ref )
		*spouse = cptr->female_reference ;
	else  *spouse = cptr->male_reference ;
			
	strcpy( names, "= " ) ;
	if( prefs.include_wdate && cptr->wedding_date )
	{
		strcat( names, "(" ) ;
		form_date( names + 4, names + 3, cptr->wedding_date, FALSE /*don't pad*/ ) ;
		if( *(names+3) = ' ' )  strcpy( names+3, names+4 ) ;
		strcat( names, ") " ) ;
	}
	if( prefs.include_ddate )
		names_dates( *spouse, names + strlen( names ), 0, prefs.longer_tree_name ) ;
	else  names_date( *spouse, names + strlen( names ), 0, prefs.longer_tree_name ) ;
}


void  find_max_levels( int ref, short level, Str_prt_params *ps_ptr )
						/* Based on print desc but does not print	*/
{
	Person *pptr ;
	Couple *cptr ;
	int coup, spouse, ch ;
	short pblk, cblk ;					/* block numbers				*/
	char *ch_ptr ;						/* ptrs to array of child refs	*/
	char *coupls_ptr ;					/* ptr to array of couplings	*/
	char names[FULL_NAME_MAX+2*DATE_LENGTH+8] ;
										/* 56 name, 11+11dates, " - ",	*/
										/* "= ", spaces and \0			*/
	short next_level ;
	int next_coup, next_child ;

	pptr = get_pdata_ptr( ref, &pblk ) ;

	if( prefs.include_ddate )  names_dates( ref, names, 0, prefs.longer_tree_name ) ;
	else  names_date( ref, names, 0, prefs.longer_tree_name ) ;

	if( rightmost_char_posn( names, level, ps_ptr ) > ps_ptr->chs_across )
		max_levels = min( max_levels, level - 1 ) ;

	if( coupls_ptr = pptr->couplings )
	{
		sort_couplings( ref ) ;
		next_coup = form_ref( &coupls_ptr ) ;
		while( coup = next_coup )
		{
			next_coup = get_next_couple( coup, ref ) ;
			cptr = get_cdata_ptr( coup, &cblk ) ;
			
			build_spouse_name_string( names, ref, &spouse, cptr ) ;

			if( rightmost_char_posn( names, level, ps_ptr ) > ps_ptr->chs_across )
				max_levels = min( max_levels, level - 1 ) ;

			next_level = level + 1 ;
			if( ( ch_ptr = cptr->children ) && level <= max_levels )
			{
				next_child = form_ref( &ch_ptr ) ;
				while( ch = next_child )
				{
					next_child = get_next_child( ch, coup ) ;
					find_max_levels( ch, next_level, ps_ptr ) ;
				}
			}
		}
	}
}


short  rightmost_char_posn( const char *names, short level, const Str_prt_params *ps_ptr )
{
	short rightmost ;

	if( ps_ptr->use_gdos )
	{
		short pts[8] ;
		
		vqt_extent( ps_ptr->prn_handle, names, pts ) ;
		rightmost = LEVEL_SPACING * level
			+ ( pts[2] - pts[0] + ps_ptr->cell_width - 1 ) / ps_ptr->cell_width ;
	}
	else  rightmost = LEVEL_SPACING * level + strlen( names ) ;
	
	return rightmost ;
}


void  print_desc( int ref, short level, Str_prt_params *ps_ptr )
						/* This routine uses get_next_couple/child	*/
						/* as the data blocks may not still be		*/
						/* there when coming round loop again. The	*/
						/* original flawed version had form_ref in	*/
						/* while().									*/
						/* Note that this is called recursively and	*/
						/* uses 128 bytes of local variables. From	*/
						/* tests it uses 172bytes per recursion.	*/
{
	Person *pptr ;
	Couple *cptr ;
	int coup, spouse, ch ;
	short pblk, cblk ;					/* block numbers				*/
	char *ch_ptr ;						/* ptrs to array of child refs	*/
	char *coupls_ptr ;					/* ptr to array of couplings	*/
	char names[FULL_NAME_MAX+2*DATE_LENGTH+8] ;
										/* 56 name, 11+11dates, " - ",	*/
										/* "= ", spaces and \0			*/
	short next_level ;
	int next_coup, next_child ;

	pptr = get_pdata_ptr( ref, &pblk ) ;

	if( prefs.include_ddate )  names_dates( ref, names, 0, prefs.longer_tree_name ) ;
	else  names_date( ref, names, 0, prefs.longer_tree_name ) ;

	if( ps_ptr->line_number == mouse_clicked_line )  mouse_clicked_ref = ref ;
	if( ps_ptr->first_line <= ps_ptr->line_number
									&& ps_ptr->line_number <= ps_ptr->last_line )
	{
		draw_verticals( level, TRUE, ps_ptr ) ;
					/* TRUE flag causes horiz line to be printed.	*/
		printout_strings( names, NULL, ps_ptr ) ;
	}
	ps_ptr->line_number++ ;

	if( coupls_ptr = pptr->couplings )
	{
		sort_couplings( ref ) ;
		next_coup = form_ref( &coupls_ptr ) ;
		while( coup = next_coup )
		{
			next_coup = get_next_couple( coup, ref ) ;
			cptr = get_cdata_ptr( coup, &cblk ) ;
			
			build_spouse_name_string( names, ref, &spouse, cptr ) ;

			if( ps_ptr->line_number == mouse_clicked_line )  mouse_clicked_ref = spouse ;
			if( ps_ptr->first_line <= ps_ptr->line_number
									&& ps_ptr->line_number <= ps_ptr->last_line )
			{
				draw_verticals( level, FALSE, ps_ptr ) ;
				printout_strings( "", names, ps_ptr ) ;
			}
			ps_ptr->line_number++ ;
			next_level = level + 1 ;
			if( ( ch_ptr = cptr->children ) && level < max_levels )
			{
				verticals[level] = TRUE ;
				ps_ptr->x_pos += LEVEL_SPACING ;

				next_child = form_ref( &ch_ptr ) ;
				while( printing_ok( ps_ptr ) && ( ch = next_child ) )
				{
					next_child = get_next_child( ch, coup ) ;
					if( !next_child )  verticals[level] = FALSE ;
					print_desc( ch, next_level, ps_ptr ) ;
				}
				ps_ptr->x_pos -= LEVEL_SPACING ;
			}
		}
	}
}


void  draw_verticals( short level, short horiz_flag, Str_prt_params *ps_ptr )
{
	short pxy_array[6] ;
	short hpos ;
	short i ;
	short old_xpos ;

	old_xpos = ps_ptr->x_pos ;

	if( ps_ptr->use_gdos )
	{
		if( ps_ptr->y_pos >= ps_ptr->chs_up )  next_page( ps_ptr ) ;

		pxy_array[1] = ps_ptr->y_pos * ps_ptr->cell_height
				+ ps_ptr->cell_height - ps_ptr->char_height + ps_ptr->y_offset ;
		pxy_array[3] = pxy_array[1] + ps_ptr->cell_height - 1 ;
		for( i=0; i<=level; i++ )
		{
			if( verticals[i] )
			{
				pxy_array[0] = ( LEVEL_SPACING * i + 3 ) * ps_ptr->cell_width + ps_ptr->x_offset ;
				pxy_array[2] = pxy_array[0] ;
				v_pline( ps_ptr->prn_handle, 2, pxy_array ) ;
			}
		}
		if( level && horiz_flag )
		{
			pxy_array[0] = ( LEVEL_SPACING * level - 3 ) * ps_ptr->cell_width + ps_ptr->x_offset ;
			pxy_array[2] = pxy_array[0] ;
			pxy_array[1] = ps_ptr->y_pos * ps_ptr->cell_height
				+ ps_ptr->cell_height - ps_ptr->char_height + ps_ptr->y_offset ;
			pxy_array[3] = pxy_array[1] + ps_ptr->cell_height / 2  ;
			pxy_array[4] = pxy_array[2] + ( ps_ptr->cell_width * 5 ) / 2 ;
			pxy_array[5] = pxy_array[3] ;
			v_pline( ps_ptr->prn_handle, 3, pxy_array ) ;
		}
	}
	else
	{
		ps_ptr->downlines = 0 ;
		for( i=0; i<level; i++ )
		{
			if( verticals[i] )
			{
				ps_ptr->x_pos = LEVEL_SPACING * i + 3 ;
				printout_strings( "|", NULL, ps_ptr ) ;
			}
		}
		if( level && horiz_flag )
		{
			hpos = LEVEL_SPACING * level - 3 ;
			if( ps_ptr->last_x_end < hpos - 1 )
			{
				ps_ptr->x_pos = hpos ;
				printout_strings( "|__", NULL, ps_ptr ) ;
			}
			else
			{
				ps_ptr->x_pos = hpos + 1 ;
				printout_strings( "__", NULL, ps_ptr ) ;
			}
		}
		ps_ptr->downlines = 1 ;
	}
	ps_ptr->x_pos = old_xpos ;
}


void  disp_desc( int ref )	/* Selects a person for display if passed	*/
							/* reference 0, then opens a window which	*/
							/* calls redraw to actually get a display.	*/
{
	char *fname ;			/* pointer to family name					*/
	if( !ref )
	{
		if( edit_pers_ref )
			fname = people[edit_pers_ref].family_name ;
		else  fname = NULL ;

		desc_root = get_person_reference( fname, FALSE ) ;
	}
	else  desc_root = ref ;


	if( desc_root )
	{
		open_titled_draw_window( &desc_form, desc_kind, DESC_TITLE, DESC_ITITLE,
					&desc_fulled, desc_root, &disp_desc_box ) ;
		desc_form.help_ref = descendants_help ;
		if( desc_form.fm_handle > 0 )
		{
			desc_lines = desc_line_count() ;
			desc_first_line = 0 ;
			set_desc_scroll() ;
		}
	}
}


void  open_titled_draw_window( Wind_edit_params *p, int wind_kind,
				short title_index, short ititle_index, short *fulled_flag_ptr,
				int reference, GRECT *draw_box_ptr )
{
	if( p->fm_handle <= 0 )
	{
		if( p->fm_box.g_w == 0 )
		{
			p->fm_box = deskbox ;
			wind_calc( WC_WORK, wind_kind, ELTS( p->fm_box ),
												REFS( *draw_box_ptr ) ) ;
		}
		p->fm_handle = wind_create( wind_kind, ELTS( deskbox ) ) ;
		if( p->fm_handle < 0 )
		{
			p->fm_handle = -1 ;
			rsrc_form_alert( 1, NO_WINDOW ) ;
		}
		if( p->fm_handle > 0 )
		{
			wind_open( p->fm_handle, ELTS( p->fm_box ) ) ;
			wind_set( p->fm_handle, WF_HSLSIZE, 1000 ) ;
			wind_set( p->fm_handle, WF_VSLSIZE, 1000 ) ;
		}
	}
	if( p->fm_handle > 0 )
	{
		*fulled_flag_ptr = FALSE ;
		wind_set( p->fm_handle, WF_TOP ) ;
		send_redraw_message( draw_box_ptr, p->fm_handle ) ;
		set_wind_title( reference, 0, p, title_index, ititle_index ) ;
	}
}


void  close_desc( void )
{
	wind_close( desc_form.fm_handle ) ;
	wind_delete( desc_form.fm_handle ) ;
	desc_root = -1 ;
	desc_form.fm_handle = -1 ;
}


void  desc_mu_mesag( const short *message )
{
	GRECT* rect ;			/* Grect pointer for wind_redraw			*/
	short wh ;

	rect = (GRECT *) &(message[4]) ;

	switch( message[0] )
	{
		case WM_FULLED :
			set_desc_scroll() ;
			break ;
		case WM_REDRAW :
			wind_redraw( (int) message[3], rect, desc_redraw ) ;
			break ;
		case WM_MOVED :
		case WM_SIZED :
			wind_calc( WC_WORK, desc_kind, ELTS( desc_form.fm_box ),
					REFS( disp_desc_box ) ) ;
			if( message[0] == WM_SIZED )
			{
				set_desc_scroll() ;
				send_redraw_message( rect, desc_form.fm_handle ) ;
			}
			break ;
		case WM_CLOSED :
			close_desc() ;
			break ;
		case WM_VSLID :
			if( desc_lines > desc_chars_up )
			{
				desc_first_line = message[4] * ( desc_lines - desc_chars_up ) / 1000 ;
				set_desc_scroll() ;
				send_redraw_message( &disp_desc_box, desc_form.fm_handle ) ;
			}
			break ;
		case WM_HSLID :
			break ;
		case WM_ARROWED :
			if( desc_lines > desc_chars_up )
			{
				switch( message[4] )
				{
					case WA_UPPAGE :
						desc_first_line -= desc_chars_up - 1 ;
						if( desc_first_line < 0 )  desc_first_line = 0 ;
						set_desc_scroll() ;
						send_redraw_message( &disp_desc_box, desc_form.fm_handle ) ;
						break ;
					case WA_DNPAGE :
						desc_first_line += desc_chars_up - 1 ;
						if( desc_first_line > desc_lines - desc_chars_up )
							desc_first_line = desc_lines - desc_chars_up ;
						set_desc_scroll() ;
						send_redraw_message( &disp_desc_box, desc_form.fm_handle ) ;
						break ;
					case WA_UPLINE :
						if( desc_first_line > 0 )
						{
							desc_first_line-- ;
							desc_slider_posn = desc_first_line * 1000
											/ ( desc_lines - desc_chars_up ) ;
							if( wind_get( desc_form.fm_handle, WF_TOP, &wh,
										NULL, NULL, NULL), wh == desc_form.fm_handle )
							{
								scroll_line( disp_desc_box, desc_chars_up,
													DOWN, prefs.tree_text_size ) ;
								draw_one_desc( TOP_LINE ) ;
							}
							else
								send_redraw_message( &disp_desc_box,
																desc_form.fm_handle ) ;
						}
						break ;
					case WA_DNLINE :
						if( desc_first_line < desc_lines - desc_chars_up )
						{
							desc_first_line++ ;
							desc_slider_posn = desc_first_line * 1000
											/ ( desc_lines - desc_chars_up ) ;
							if( wind_get( desc_form.fm_handle, WF_TOP, &wh,
										NULL, NULL, NULL ), wh == desc_form.fm_handle )
							{
								scroll_line( disp_desc_box,	desc_chars_up,
													UP, prefs.tree_text_size ) ;
								draw_one_desc( BOTTOM_LINE ) ;
							}
							else
								send_redraw_message( &disp_desc_box, desc_form.fm_handle ) ;
						}
						break ;
					default :
						break ;
				}
			}
			break ;
		default :
			break ;
	}
}



void  desc_mu_button( short m_x, short m_y, short breturn )

{	Str_prt_params params ;
	short cell_ht ;
	short dummy ;

	if( !desc_form.iconified )
	{
		v_attrs( scr_handle, SAVE ) ;

		vst_point( scr_handle, prefs.tree_text_size,
				&dummy, &dummy, &dummy, &cell_ht ) ;

		mouse_clicked_line = ( m_y - disp_desc_box.g_y ) / cell_ht + desc_first_line ;

		params.check_printer = CHECK_PRINTER_OFF ;
		params.use_gdos = TRUE ;	/* select gdos for screen display	*/
		params.line_number = 0 ;
		params.first_line = 1 ;
		params.last_line = 0 ;		/* prevents any printing			*/
		max_levels = MAX_LEVELS ;

		mouse_clicked_ref = 0 ;
		print_desc( desc_root, 0, &params ) ;

		v_attrs( scr_handle, RESTORE ) ;

		if( breturn > 1 && mouse_clicked_ref )  edit_person( mouse_clicked_ref ) ;
	}
}


int  desc_redraw( int handle, GRECT *rect_ptr )
{
	short pxyarray[4] ;
	Str_prt_params params ;
	short i ;
	short dummy ;

	if( desc_form.iconified )
	{
		icons_ptr[0].ob_x = desc_form.fm_box.g_x ;
		icons_ptr[0].ob_y = desc_form.fm_box.g_y ;
		icons_ptr[ICON].ob_spec = icons_ptr[DESC_ICON].ob_spec ;
		((TEDINFO *)icons_ptr[ICON_LABEL1].ob_spec)->te_ptext = desc_form.icon_label1 ;
		((TEDINFO *)icons_ptr[ICON_LABEL2].ob_spec)->te_ptext = desc_form.icon_label2 ;
		objc_draw( icons_ptr, ROOT, MAX_DEPTH, PTRS( rect_ptr ) ) ;
	}
	else
	{
		grect2pxy( rect_ptr, pxyarray ) ;

		v_attrs( scr_handle, SAVE ) ;

		vst_font( scr_handle, SYSTEM_FONT ) ;	/* restore screen to system font	*/

		vst_point( scr_handle, prefs.tree_text_size, &dummy, &params.char_height,
								&params.cell_width, &params.cell_height ) ;
		params.check_printer = CHECK_PRINTER_OFF ;
		params.chs_across = disp_desc_box.g_w / params.cell_width ;
		params.chs_up = desc_chars_up ;

		vs_clip( scr_handle, 1, pxyarray ) ;

		graf_mouse( M_OFF, 0 ) ;		/* turn off mouse while drawing		*/

		vr_recfl( scr_handle, pxyarray ) ;

		for( i=0; i<MAX_LEVELS; i++ )  verticals[i] = FALSE ;

							/* Allow start of names to reach but not		*/
							/* exceed screen edge.							*/
		max_levels = ( params.chs_across ) / LEVEL_SPACING + 1 ;

		if( max_levels > MAX_LEVELS )  max_levels = MAX_LEVELS ;

		params.use_gdos = TRUE ;	/* select gdos for screen display	*/
		params.prn_handle = scr_handle ;
		params.fp = NULL ;			/* file pointer not used			*/
		params.align = LEFT ;
		params.x_pos = 0 ;
		params.x_offset = disp_desc_box.g_x ;
		params.max_len = 0 ;
		params.last_x_end = 0 ;
		params.y_pos = 0 ;
		params.y_offset = disp_desc_box.g_y ;
		params.tabpos = 3 ;
		params.downlines = 1 ;
		params.line_number = 0 ;
		params.first_line = desc_first_line ;
		params.last_line = params.first_line + params.chs_up - 1 ;

		print_desc( desc_root, 0, &params ) ;

		v_attrs( scr_handle, RESTORE ) ;

		graf_mouse( M_ON, 0 ) ;			/* restore mouse after drawing		*/

		vs_clip( scr_handle, 0, NULL ) ;
	}
	return 1 ;
}


short  desc_line_count( void )
{
	Str_prt_params params ;

	params.check_printer = CHECK_PRINTER_OFF ;
	params.use_gdos = TRUE ;	/* select gdos for screen display	*/
	params.line_number = 1 ;
	params.first_line = 1 ;
	params.last_line = 0 ;		/* prevents any printing			*/
	max_levels = MAX_LEVELS ;

	print_desc( desc_root, 0, &params ) ;

	return params.line_number ;
}


void  set_desc_scroll( void )
{
	short sl_size ;				/* vertical scroll bar variables		*/
	short h_char, w_cell, h_cell ;	/* character and cell sizes			*/
	short dummy ;

	v_attrs( scr_handle, SAVE ) ;

	vst_point( scr_handle, prefs.tree_text_size, &dummy, &h_char,
													&w_cell, &h_cell ) ;

	desc_chars_up = ( disp_desc_box.g_h - ( h_cell - h_char ) ) / h_cell ;

	if( desc_lines > desc_chars_up )
	{
		sl_size = desc_chars_up * 1000 / desc_lines ;
		desc_slider_posn = desc_first_line * 1000
										/ ( desc_lines - desc_chars_up ) ;
	}
	else
	{
		sl_size = 1000 ;
		desc_slider_posn = 0 ;
	}
	wind_set( desc_form.fm_handle, WF_VSLSIZE, sl_size ) ;
	wind_set( desc_form.fm_handle, WF_VSLIDE, desc_slider_posn ) ;

	v_attrs( scr_handle, RESTORE ) ;
}


void  draw_one_desc( short position )
{
	GRECT old_disp_desc_box, clip_box ;
	short old_desc_first_line, old_desc_chars_up ;
	short h_char, h_cell ;			/* character and cell sizes			*/
	short dummy ;

	old_desc_first_line = desc_first_line ;
	old_desc_chars_up = desc_chars_up ;
	old_disp_desc_box.g_y = disp_desc_box.g_y ;
	old_disp_desc_box.g_h = disp_desc_box.g_h ;

	vst_point( scr_handle, prefs.tree_text_size, &dummy, &h_char,
														&dummy, &h_cell ) ;

	disp_desc_box.g_h = 2 * h_cell - h_char ;
	if( position == BOTTOM_LINE )
	{
		disp_desc_box.g_y += h_cell * ( desc_chars_up - 1 ) ;
		desc_first_line += desc_chars_up - 1 ;
	}
	desc_chars_up = 1 ;
	clip_box = disp_desc_box ;
	clip_box.g_y += h_cell - h_char ;
	clip_box.g_h -= h_cell - h_char ;

	wind_update( BEG_UPDATE ) ;
	desc_redraw( scr_handle, &clip_box ) ;
	wind_update( END_UPDATE ) ;

	disp_desc_box.g_y = old_disp_desc_box.g_y ;
	disp_desc_box.g_h = old_disp_desc_box.g_h ;
	desc_first_line = old_desc_first_line ;
	desc_chars_up = old_desc_chars_up ;
}
