/************************************************************************/
/*																		*/
/*		Gentree.c		29 Jun 97										*/
/*																		*/
/************************************************************************/

#if !defined GEN_PH
	#include "geninc.h"
#endif

#include "genhd.h"
#include "gentree.h"
#include "genutil.h"
#include "gendata.h"
#include "gendesc.h"
#include "genpers.h"
#include "genpsel.h"

extern Index_person *people ;
extern Index_couple *couples ;
extern short scr_handle ;
extern int next_person ;
extern int edit_pers_ref ;

extern OBJECT *icons_ptr ;

extern int ap_id ;

extern Preferences prefs ;

const char* const tree_help = "Tree" ;

int tree_stack[GENERATIONS] ;
int *tsptr = tree_stack ;

GRECT disp_tree_box ;			/* display area used for tree			*/
short tree_fulled ;				/* flag									*/
int tree_trunk = 0 ;			/* person at start of tree display		*/
int first_tree_trunk ;			/* original person at start of display	*/

char tree_names[MAX_TREE_SIZE][FULL_NAME_MAX + 1] ;
char tree_dates[MAX_TREE_SIZE][2*DATE_LENGTH + 2] ;
short name_max_found[GENERATIONS] ;
int tree_refs[MAX_TREE_SIZE] ;
GRECT tree_rects[MAX_TREE_SIZE] ;

int tree_kind = NAME | CLOSE | SMALLER | FULL | MOVE | SIZE | VSLIDE | HSLIDE ;

Wind_edit_params tree_form ;


void  disp_tree( int ref )
{
	char *fname ;			/* pointer to family name					*/
							/* Unless returning to tree from where left	*/
							/* off set backtracking stack empty.		*/
	if( !ref || ref != tree_trunk )
	{
		tsptr = tree_stack ;

		if( !ref )
		{
			if( edit_pers_ref )
				fname = people[edit_pers_ref].family_name ;
			else  fname = NULL ;

			tree_trunk = get_person_reference( fname, FALSE ) ;
		}
		else  tree_trunk = ref ;

		if( tree_trunk )
		{
			first_tree_trunk = tree_trunk ;
			load_all_strings( tree_trunk ) ;
		}
	}

	if( tree_trunk )
	{
		open_titled_draw_window( &tree_form, tree_kind, TREE_TITLE,
					TREE_ITITLE, &tree_fulled, tree_trunk, &disp_tree_box ) ;
		tree_form.help_ref = tree_help ;
	}
}


void  close_tree( void )
{
	wind_close( tree_form.fm_handle ) ;
	wind_delete( tree_form.fm_handle ) ;
	tree_trunk = -1 ;
	tree_form.fm_handle = -1 ;
}


void  tree_mu_mesag( const short *message )
{
	GRECT* rect ;			/* Grect pointer for wind_redraw			*/

	rect = (GRECT *) &(message[4]) ;
	switch( message[0] )
	{
		case WM_REDRAW :
			wind_redraw( (int) message[3], rect, tree_redraw ) ;
			break ;
		case WM_MOVED :
		case WM_SIZED :
			wind_calc( WC_WORK, tree_kind, ELTS( tree_form.fm_box ),
					REFS( disp_tree_box ) ) ;
			if( message[0] == WM_SIZED )  send_redraw_message( rect,
															tree_form.fm_handle ) ;
			break ;
		case WM_HSLID :
		case WM_VSLID :
			break ;
		case WM_CLOSED :
			close_tree() ;
			break ;
		case WM_UNICONIFY :
			wind_calc( WC_WORK, tree_kind, ELTS( tree_form.fm_box ),
					REFS( disp_tree_box ) ) ;
			break ;
		default :
			break ;
	}
}


void  tree_mu_button( short m_x, short m_y, short breturn )
{
	short pos ;						/* person clicked on, if any		*/
	int *stk_ptr, stk[MAX_GENS] ;
	short i ;

	if( !tree_form.iconified )
	{
		if( ( pos = get_rect_number( m_x, m_y ) ) != -1 )
		{
			if( breturn > 1 )
			{
				if( pos )  edit_person( tree_refs[pos] ) ;
			}
			else
			{
				if( pos > 0 )
				{
					tree_trunk = tree_refs[pos] ;

					i = pos >> 1 ;			/* load retrace stack				*/
					stk_ptr = stk ;
					while( i )
					{
						*stk_ptr++ = tree_refs[i] ;
						i >>= 1 ;
					}
					while( stk_ptr > stk )  *tsptr++ = *(--stk_ptr) ;
				}
				else  tree_trunk = *--tsptr ;

				load_all_strings( tree_trunk ) ;

				send_redraw_message( &disp_tree_box, tree_form.fm_handle ) ;
			}
		}
	}
}


int  tree_redraw( int handle, GRECT *rect_ptr )
{
	short pxyarray[4] ;
	short dummy ;
	Tree_params tree_params ;
	short h_cell, w_cell ;
	short chs_across, chs_up ;
	short max_gens ;
	short x_offset ;
	short val, offset ;						/* temporary offsets used in */
											/* optimisation of x_offset	*/
	short x, i ;
	short generation ;

	if( tree_form.iconified )
	{
		icons_ptr[0].ob_x = tree_form.fm_box.g_x ;
		icons_ptr[0].ob_y = tree_form.fm_box.g_y ;
		icons_ptr[ICON].ob_spec = icons_ptr[TREE_ICON].ob_spec ;
		((TEDINFO *)icons_ptr[ICON_LABEL1].ob_spec)->te_ptext = tree_form.icon_label1 ;
		((TEDINFO *)icons_ptr[ICON_LABEL2].ob_spec)->te_ptext = tree_form.icon_label2 ;
		objc_draw( icons_ptr, ROOT, MAX_DEPTH, PTRS( rect_ptr ) ) ;
	}
	else
	{
		grect2pxy( rect_ptr, pxyarray ) ;

		v_attrs( scr_handle, SAVE ) ;

		vst_point( scr_handle, prefs.tree_text_size,
								&dummy, &dummy, &w_cell, &h_cell ) ;

		chs_across = disp_tree_box.g_w / w_cell ;
				/* Allow slight vertical overlap to allow as many	*/
				/* generations as old versions without window bar.	*/
		chs_up = disp_tree_box.g_h / ( h_cell - 1 ) ;
		x = chs_up + 2 ;			/* calculate max generations vertically	*/
		max_gens = 0 ;
		while( x>3 & max_gens<MAX_GENS )
		{
			x >>= 1 ;
			max_gens++ ;
		}

						/* For each generation find value of offset which	*/
						/* would just allow name to fit. The offset is set	*/
						/* to the minimum of these to ensure that all		*/
						/* generations fit. Normally but not always it will	*/
						/* be the last generation that is critical.			*/
						/* Space allowed is width minus 2 to allow for		*/
						/* spaces at start and end of display.				*/
		offset = chs_across ;	/* initialise to excessive value	*/
		for( generation = 2; generation <= max_gens; generation++ )
		{
			val = ( chs_across - 2 - name_max_found[generation] )
														/ ( generation - 1 ) ;
			if( val < offset )  offset = val ;
		}

		if( offset <= 0 )  offset = 1 ;
		x_offset = w_cell * offset ;

		vs_clip( scr_handle, 1, pxyarray ) ;

		wind_update( BEG_UPDATE ) ;

		vr_recfl( scr_handle, pxyarray ) ;

		tree_params.ref = tree_trunk ;
		tree_params.generation = 1 ;
		tree_params.max_generations = max_gens ;		/* temporary values	*/
		tree_params.position = 1 ;
		tree_params.ch_width = w_cell ;
		tree_params.x_position = disp_tree_box.g_x + w_cell ;
		tree_params.x_offsets = x_offset ;
		tree_params.ch_height = h_cell ;
		tree_params.y_min = disp_tree_box.g_y + 2 ;
		tree_params.y_max = disp_tree_box.g_y + disp_tree_box.g_h - 2 ;
		tree_params.line_start_x = 0 ;
		tree_params.line_start_y = 0 ;
		tree_params.right_limit = disp_tree_box.g_x + disp_tree_box.g_w ;

		for( i=0; i<MAX_TREE_SIZE; i++ )
		{
			tree_rects[i].g_h = 0 ;
			tree_rects[i].g_w = 0 ;
		}

		if( tsptr > tree_stack )	/* draw characters for retracing tree	*/
		{
			v_gtext( scr_handle, tree_params.x_position, tree_params.y_max - h_cell,
															"  <<<  " ) ;
			tree_rects[0].g_x = w_cell ;
			tree_rects[0].g_y = disp_tree_box.g_h - 2 * h_cell ;
			tree_rects[0].g_w = 7 * w_cell ;
			tree_rects[0].g_h = h_cell ;
		}

		vswr_mode( scr_handle, MD_TRANS ) ;	/* Allow slight overlap.	*/

		draw_person( scr_handle, tree_params ) ;
		wind_update( END_UPDATE ) ;

		v_attrs( scr_handle, RESTORE ) ;

		vs_clip( scr_handle, 0, NULL ) ;
	}

	return 1 ;
}


void  draw_person( int handle, Tree_params pars )
{
	Tree_params next_pars ;
	short top_position, people_in_generation, y_pos ;
	short pxyarray[6] ;	/* used for joining line between generations	*/
	char buffer[FULL_NAME_MAX] ;
	short string_space ;

	next_pars = pars ;
	next_pars.generation += 1 ;
	next_pars.x_position += pars.x_offsets ;

	top_position = 1 << ( pars.generation - 1 ) ;
	people_in_generation = top_position ;

	y_pos = pars.y_min + ( ( 2 * ( pars.position - top_position ) ) + 1 )
				* ( pars.y_max - pars.y_min ) / ( 2 * people_in_generation ) ;


	if( tree_names[pars.position][0] != '\0' )
	{
		string_space = ( pars.right_limit - pars.x_position ) / pars.ch_width ;
		strcpy( buffer, tree_names[pars.position] ) ;
		if( strlen( buffer ) > string_space )
			shorten_names( buffer, string_space ) ;
		v_gtext( handle, pars.x_position, y_pos, buffer ) ;
		strcpy( buffer, tree_dates[pars.position] ) ;
						/* Following truncation of string cannot be		*/
						/* unconditional as string_space could exceed	*/
						/* max length of buffer.						*/
		if( string_space < strlen( buffer ) )  buffer[string_space] = '\0' ;
		v_gtext( handle, pars.x_position, y_pos + pars.ch_height, buffer ) ;

		if( pars.line_start_x )
		{
			pxyarray[0] = pars.line_start_x ;
			pxyarray[1] = pars.line_start_y  ;
			pxyarray[2] = pars.line_start_x ;
			pxyarray[3] = y_pos + 1 ;
			pxyarray[4] = pars.x_position ;
			pxyarray[5] = y_pos + 1 ;
			v_pline( handle, 3, pxyarray ) ;
		}

		if( handle == scr_handle )
		{
			tree_rects[pars.position].g_x = pars.x_position - disp_tree_box.g_x ;
			tree_rects[pars.position].g_y = y_pos - pars.ch_height - disp_tree_box.g_y ;
			tree_rects[pars.position].g_w = pars.ch_width
								* strlen( tree_names[pars.position] ) ;
			tree_rects[pars.position].g_h = 2 * pars.ch_height ;
		}
		if( pars.generation < pars.max_generations )
		{
			next_pars.position = 2 * pars.position ;

			if( 8 * pars.ch_width < 3 * pars.x_offsets / 4 )
				next_pars.line_start_x = pars.x_position + 8 * pars.ch_width ;
			else  next_pars.line_start_x = pars.x_position + 3 * pars.x_offsets / 4 ;

			next_pars.line_start_y = y_pos - pars.ch_height ;
			draw_person( handle, next_pars ) ;
			(next_pars.position)++ ;
			next_pars.line_start_y = y_pos + pars.ch_height + 1 ;
			draw_person( handle, next_pars ) ;
		}
	}
}


void  load_all_strings( int tree_trunk )
{
	Tree_params first_pars ;
	short i ;

	first_pars.ref = tree_trunk ;
	first_pars.generation = 1 ;
	first_pars.max_generations = MAX_GENS ;
	first_pars.position = 1 ;
	first_pars.ch_width = 0 ;		/* values not used	*/
	first_pars.x_position = 0 ;
	first_pars.x_offsets = 0 ;
	first_pars.ch_height = 0 ;
	first_pars.y_max = 0 ;
	first_pars.y_min = 0 ;
	first_pars.line_start_x = 0 ;
	first_pars.line_start_y = 0 ;

	for( i=0; i<MAX_TREE_SIZE; i++ )
	{
		tree_names[i][0] = '\0' ;
		tree_dates[i][0] = '\0' ;
		tree_refs[i] = 0 ;
	}

	for( i=0; i<GENERATIONS; i++ )  name_max_found[i] = NAME_MIN ;

	load_tree_strings( first_pars ) ;
}


void  load_tree_strings( Tree_params pars )
{
	char names[FULL_NAME_MAX + 1], *dptr, dates[DATE_LENGTH * 2 + 2] ;
	int date ;
	char qualifier ;
	Person *pptr ;
	short blk ;
	int cref ;
	Tree_params next_pars ;
	short i ;
	short name_max ;
	short length ;

	busy( BUSY_MORE ) ;

	tree_refs[pars.position] = pars.ref ;
	pptr = get_pdata_ptr( pars.ref, &blk ) ;

	name_max = ( prefs.longer_tree_name ? FULL_NAME_MAX : SHORT_NAME_MAX ) ;

	names_only( pars.ref, names, -name_max, prefs.longer_tree_name ) ;
	strcpy( tree_names[pars.position], names ) ;
	if( length = strlen( names ), length > name_max_found[pars.generation] )
		name_max_found[pars.generation] = length ;

	if( date = pptr->birth_date )
	{
		form_date( dates, &qualifier, date, FALSE ) ;
		if( qualifier != ' ' )
		{
			*dates = qualifier ;
			form_date( dates+1, &qualifier, date, FALSE ) ;
		}
	}
	else
	{
		dptr = dates ;
		for( i=0; i<4; i++ )  *dptr++ = ' ' ;
		*dptr = '\0' ;
	}
	if( date = pptr->death_date )
	{
		char* dates_ptr ;
		
		strcat( dates, " - " ) ;
		dates_ptr = dates + strlen(dates) ;
		form_date( dates_ptr, &qualifier, date, FALSE ) ;
		if( qualifier != ' ' )
		{
			*dates_ptr++ = qualifier ;
			form_date( dates_ptr, &qualifier, date, FALSE ) ;
		}
	}
	strcpy( tree_dates[pars.position], dates ) ;
	if( length = strlen(dates), length > name_max_found[pars.generation] )
		name_max_found[pars.generation] = length ; 

	if( pars.generation < pars.max_generations && ( cref = pptr->parents ) )
	{
		next_pars = pars ;
		next_pars.generation += 1 ;
		next_pars.position *= 2 ;
		if( next_pars.ref = couples[cref].male_reference )
			load_tree_strings( next_pars ) ;
		next_pars.position++ ;
		if( next_pars.ref = couples[cref].female_reference )
			load_tree_strings( next_pars ) ;
	}
	busy( BUSY_LESS ) ;
}


short  get_rect_number( short x, short y )
{
	short rect_number = -1 ;
	short i = 0 ;

	x -= disp_tree_box.g_x ;
	y -= disp_tree_box.g_y ;

	while( ( rect_number == -1 ) && i<MAX_TREE_SIZE )
	{
		if( rc_inside( x, y, &(tree_rects[i]) ) )
			rect_number = i ;
		i++ ;
	}
	return rect_number ;
}


