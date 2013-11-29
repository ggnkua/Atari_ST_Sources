/************************************************************************/
/*																		*/
/*		Gennote.c	30 Jun 02											*/
/*																		*/
/************************************************************************/

#if !defined GEN_PH
	#include "geninc.h"			/* Use precompiled header GENINC.SYM ?	*/
#endif

#include "genhd.h"
#include "gennote.h"
#include "genclip.h"
#include "genmain.h"
#include "genmedi.h"
#include "genutil.h"

#include <unistd.h>

/************************************************************************
void  noterep( void ) ;
void  my_v_gtext( int handle, int x, int y, char *str ) ;
short  my_draw_text( short line, short chr, short last_sp, char *txt_ptr,
					short line_no, char **first_line_ptr, short drawing ) ;
*********************************************************************** */

extern int ap_id ;				/* global application identifier		*/
extern OBJECT *strings_ptr ;	/* pointer to resource strings			*/
extern OBJECT *icons_ptr ;
extern OBJECT *menu_ptr ;		/* pointer to menu bar tree				*/

extern short scr_handle ;
extern GRECT deskbox ;

extern char save_directory[] ;

extern Person *person_ptr ;		/* pointer to current person			*/

extern short curs_enbl ;

extern Preferences prefs ;

const char* const notes_help = "Notes" ;
const char* const href_str = "a href=\"" ;
const char* const set_href_str = "<a href=\"%s\">" ;
const char* const end_href_str = "<\\a>" ;

char *edit_buffer = NULL ;

Wind_edit_params notes_form ;

int notes_kind = NAME | CLOSE | SMALLER | FULL | MOVE | SIZE
				| UPARROW | DNARROW | VSLIDE | HSLIDE ;
GRECT text_box ;
							/* note box is whole window, text box is	*/
							/* work area only.							*/
short notes_fulled ;		/* flag										*/
short notes_loaded = FALSE ;
short notes_changed ;
GRECT notes_area ;

short chr_max, line_max ;	/* maximum characters in window, hor & vert	*/

char *tail_ptr ;			/* pointer to start of tail in edit buffer	*/
char *edit_ptr ;			/* pointer to end of head in edit buffer	*/
int notes_size ;			/* number of characters in edit buffer		*/

short first_line ;				/* first line in window					*/
short total_lines ;				/* number of lines at set window width	*/
char *line_start[MAX_LINES] ;	/* ptr into edit buffer of character at	*/
								/* start of line						*/
char start_property[MAX_LINES] ;/* property at start of each line		*/
short last_char[MAX_LINES] ;	/* position of last character in line	*/
short last_line ;				/* last line in window with text in		*/
short notes_slider_posn = -1 ;	/* combined flag and actual position	*/
								/* used to allow setting in main timing	*/
								/* loop.								*/

short curs_set = FALSE ;	/* flag to say cursor position set			*/
short curs_on = FALSE ;		/* cursor drawn, toggles when flashing		*/
Ch_posn cursor ;			/* line and character where cursor drawn	*/
short x_cur, y_cur ;		/* position of cursor within window			*/
short previous_space ;		/* last space before cursor					*/
Ch_posn block_start, block_end ;	/* highlit text						*/
char *block_start_ptr, *block_end_ptr ;

char deflt_file[FNSIZE+FMSIZE] = "" ;	/* default media file			*/


/* ***********************************************************************
void  noterep( void )
{
	FILE *rp ;
	short i ;

	rp = fopen( "m:\\gennote.rep", "a" ) ;

	fprintf( rp,
		"total_lines = %d, line_max = %d, last_line = %d, first_line = %d\n",
		total_lines, line_max, last_line, first_line ) ;

	for( i=0; i<=line_max; i++ )
		fprintf( rp, "line_start [%d]= %X\n", i, (int) line_start[i] ) ;

	fclose( rp ) ;
}


short  my_draw_text( short line, short chr, short last_sp, char *txt_ptr,
					short line_no, char **first_line_ptr, char *property, short drawing )
{
	noterep() ;
	return draw_text( line, chr, last_sp, txt_ptr,
					line_no, first_line_ptr, property, drawing ) ;
}


void  my_v_gtext( int handle, int x, int y, char *str )
{
	FILE *rp ;
	char repstr[81] ;

	rp = fopen("m:\\gennote.rep", "a" ) ;

	fprintf( rp, "x = %X, y = %X\n", x, y ) ;
	strncpy( repstr, str, 80 ) ;
	fprintf( rp, "%d %s", (int) str, repstr ) ;

	fclose( rp ) ;

	v_gtext( handle, x, y, repstr ) ;
}

********************************************************************** */


void  further_notes( int reference, Person *pptr )
{
	if( !edit_buffer )
	{
		edit_buffer = pmalloc( (size_t) prefs.edit_buffer_size ) ;
		if( !edit_buffer )  rsrc_form_alert( 1, NO_BUFF ) ;
	}

	if( edit_buffer )
	{
		if( !notes_loaded )  load_notes( pptr ) ;

		if( notes_form.fm_handle <= 0 && notes_loaded )
		{
			notes_form.fm_handle = wind_create( notes_kind, ELTS( deskbox ) ) ;
			if( notes_form.fm_handle <= 0 )
			{
				notes_form.fm_handle = -1 ;
				rsrc_form_alert( 1, NO_WINDOW ) ;
			}
			else if( notes_form.fm_handle > 0 )
				wind_open( notes_form.fm_handle, ELTS( notes_form.fm_box ) ) ;
		}
		if( notes_form.fm_handle > 0 && notes_loaded )
		{
			set_notes_sizes( &notes_form.fm_box ) ;
			set_wind_title( reference, 0, &notes_form, NOTES_TITLE,
														NOTES_ITITLE ) ;
			notes_form.help_ref = notes_help ;
			wind_set( notes_form.fm_handle, WF_TOP ) ;
		}
	}
	curs_enbl = FALSE ;
}


void  notes_mu_mesag( const short *message )
{
	GRECT *rect ;
	GRECT tempbox ;

	switch( message[0] )
	{
		case WM_FULLED :
			if( !notes_fulled )
			{
				wind_get( notes_form.fm_handle, WF_FULLXYWH, REFS( tempbox ) ) ;
				notes_fulled = TRUE ;
			}
			else
			{
				wind_get( notes_form.fm_handle, WF_PREVXYWH, REFS( tempbox ) ) ;
				notes_fulled = FALSE ;
			}
			wind_set( notes_form.fm_handle, WF_CURRXYWH, ELTS( tempbox ) ) ;
			set_notes_sizes( &tempbox ) ;
			send_redraw_message( &text_box, notes_form.fm_handle ) ;
			break ;
		case WM_REDRAW :
			rect = (GRECT *) &(message[4]) ;
			wind_redraw( (int) message[3], rect, notes_redraw ) ;
			break ;
		case WM_CLOSED :
			wind_close( notes_form.fm_handle ) ;
			wind_delete( notes_form.fm_handle ) ;
			notes_form.fm_handle = -1 ;
			break ;
		case WM_TOPPED :
			wind_set( notes_form.fm_handle, WF_TOP ) ;
			break ;
		case WM_BOTTOM :
			wind_set( notes_form.fm_handle, WF_BOTTOM ) ;
			break ;
		case WM_MOVED :
		case WM_SIZED :
			rect = (GRECT *) &(message[4]) ;
			wind_set( notes_form.fm_handle, WF_CURRXYWH, PTRS( rect ) ) ;
			notes_fulled = FALSE ;
			set_notes_sizes( rect ) ;
				/* Send myself message to redraw this window	*/
			if( message[0] == WM_SIZED )
				send_redraw_message( rect, notes_form.fm_handle ) ;
			break ;
		case WM_VSLID :
			scroll_text( message[4] ) ;
			break ;
		case WM_HSLID :
			break ;
		case WM_ARROWED :
			switch( message[4] )
			{
				case WA_UPPAGE :
					uppage() ;
					break ;
				case WA_DNPAGE :
					dnpage() ;
					break ;
				case WA_UPLINE :
					upline() ;
					break ;
				case WA_DNLINE :
					dnline() ;
					break ;
				default :
					break ;
			}
			break ;
		case WM_ALLICONIFY :
			iconify_all( notes_form.fm_box.g_x ) ;
			break ;
		case WM_ICONIFY :
			wind_set( notes_form.fm_handle, WF_UNICONIFYXYWH, ELTS( notes_form.fm_box ) ) ;
			notes_form.fm_box = *(GRECT *)&message[4] ;
			notes_form.iconified = TRUE ;
			wind_set( notes_form.fm_handle, WF_ICONIFY, ELTS( notes_form.fm_box ) ) ;
			wind_title( notes_form.fm_handle, notes_form.icon_title ) ;
			send_redraw_message( &notes_form.fm_box, notes_form.fm_handle ) ;
			break ;
		case WM_UNICONIFY :
			wind_get( notes_form.fm_handle, WF_UNICONIFY, REFS( notes_form.fm_box ) ) ;
			set_notes_sizes( &notes_form.fm_box ) ;
			wind_set( notes_form.fm_handle, WF_UNICONIFY, ELTS( notes_form.fm_box ) ) ;
			wind_title( notes_form.fm_handle, notes_form.title_str ) ;
			notes_form.iconified = FALSE ;
			break ;
		default :
			break ;
	}
}


void  notes_mouse_handler( short m_x, short m_y, short breturn )
{
	short event ;
	short new_m_x, new_m_y, button ;
	short dummy ;
	char dummy_ch ;
	short kstate ;
	Ch_posn old_block_end ;

			/* do nothing if mouse clicked outside text box	*/
	if( !rc_inside( m_x, m_y, &text_box ) )  return ;

	event = evnt_multi( MU_BUTTON | MU_TIMER,
							/* Wait for button release or timer.		*/
						1, 3, 0,
							/* 1 click, both buttons, released			*/
						0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
							/* Do not detect mouse in & out of rects	*/
						NULL,
						500, 0,
							/* timer setting of half second				*/
						&new_m_x, &new_m_y, &button,
						&dummy, &dummy, &dummy ) ;

	graf_mkstate( &new_m_x, &new_m_y, &button, &kstate ) ;
	if( !button )	/* ie released	*/
	{
		if( curs_enbl )  move_cursor_xy( m_x, m_y ) ;
		if( breturn == 2 )  link_to_reference() ;
	}
	else
	{
		graf_mouse( M_OFF, NULL ) ;	/* Avoid mouse flahing as it is		*/
									/* turned on and off by				*/
									/* invert_block which is			*/
									/* repeatedly called.				*/

									/* remove any old block marking		*/
		if( block_start_ptr && block_end_ptr )
			invert_block( block_start, block_end ) ;

		block_start = limit_posn( char_posn( m_x, m_y ) ) ;
		block_end = block_start ;
		while( button )
		{
			evnt_timer( 20, 0 ) ;				/* wait 20milliseconds	*/
			graf_mkstate( &new_m_x, &new_m_y, &button, &kstate ) ;

			old_block_end = block_end ;
			block_end = limit_posn( char_posn( new_m_x, new_m_y ) ) ;
			invert_block( old_block_end, block_end ) ;
		}
		block_start_ptr = notes_ch_ptr( block_start, &dummy_ch ) ;
		block_end_ptr = notes_ch_ptr( block_end, &dummy_ch ) ;

		graf_mouse( M_ON, NULL ) ;
	}
}


void  mark_block( short end )
{
	char *old_ptr ;
	char *swap_ptr ;

	if( end == BLOCK_START )
	{
		old_ptr = block_start_ptr ;
		block_start_ptr = edit_ptr ;
	}
	else
	{
		old_ptr = block_end_ptr ;
		block_end_ptr = edit_ptr ;
	}

	if( block_end_ptr == block_start_ptr )
	{
		block_end_ptr = block_start_ptr = NULL ;
		if( old_ptr )	/* then there would have been an inverted block	*/
			invert_block( get_ch_posn( old_ptr ), cursor ) ;
	}

	if( block_start_ptr && block_end_ptr )
	{
		if( block_start_ptr > block_end_ptr )
		{
			swap_ptr = block_start_ptr ;
			block_start_ptr = block_end_ptr ;
			block_end_ptr = swap_ptr ;
		}
		block_start = get_ch_posn( block_start_ptr ) ;
		block_end = get_ch_posn( block_end_ptr ) ;
		invert_block( block_start, block_end ) ;
	}
}


void  delete_block( void )
{
	char *old_start ;
	short old_total_lines ;
	size_t block_size ;
	char *dummy ;
	char dummy_ch ;

	notes_changed = TRUE ;			/* This will cause the notes to be	*/
									/* checked to see if really changed	*/

	if( !block_start_ptr || !block_end_ptr )
	{
		block_start_ptr = edit_buffer ;
		block_end_ptr = edit_buffer+prefs.edit_buffer_size ;
	}

	block_size = block_end_ptr - block_start_ptr ;
		/* block size only valid if block entirely within head or tail	*/

	if( edit_ptr < block_start_ptr )	/* block entirely within tail	*/
	{
		memmove( tail_ptr + block_size, tail_ptr,
								block_start_ptr - tail_ptr ) ;
		tail_ptr += block_size ;
	}

	else if( edit_ptr < block_end_ptr )	/* i.e. block split				*/
	{
		block_size -= ( tail_ptr - edit_ptr ) ;			/* now valid	*/
		edit_ptr = block_start_ptr ;
		*edit_ptr = '\0' ;
		tail_ptr = block_end_ptr ;
	}
	else								/* block entirely within head	*/
	{
		memmove( block_start_ptr, block_end_ptr,
								(size_t)( edit_ptr - block_end_ptr + 1 ) ) ;
		edit_ptr -= block_size ;
	}

	notes_size -= block_size ;

	old_start = block_start_ptr ;
	block_start_ptr = block_end_ptr = NULL ;

	old_total_lines = total_lines ;
	total_lines = draw_text( 0, 0, 0, edit_buffer, -1, &dummy, &dummy_ch, FALSE ) ;


	if( line_start[0] > old_start )
	{
		first_line -= old_total_lines - total_lines ;
		if( first_line < 0 )  first_line = 0 ;
	}

	set_notes_sizes( &notes_form.fm_box ) ;

	if( line_start[last_line] >= old_start )	/* redraw required	*/
		send_redraw_message( &text_box, notes_form.fm_handle ) ;
}


void  select_all_notes( void )
{
	block_start_ptr = edit_buffer ;
	block_end_ptr = tail_ptr + strlen( tail_ptr ) ;
	send_redraw_message( &text_box, notes_form.fm_handle ) ;
}


Ch_posn  get_ch_posn( char *ch_ptr )
{
	Ch_posn ch_posn ;
	short line ;
	int x ;
	char *chr_ptr ;
	char property ;

	if( ch_ptr <= line_start[0] )
	{
		ch_posn.c_x = 0 ;
		ch_posn.c_y = 0 ;
	}
	else
	{
		line = 0 ;
		while( line_start[line+1] < ch_ptr && line < last_line )  line++ ;
		ch_posn.c_y = line ;

		chr_ptr = line_start[line] ;
		x = 0 ;
		while( chr_ptr < ch_ptr )
		{
			get_next_char_with_properties( &chr_ptr, tail_ptr, &property ) ;
			x++ ;
		}
				/* limit x position in case edit point is off screen	*/

		if( x > chr_max )  ch_posn.c_x = chr_max ;
		else  ch_posn.c_x = x ;
	}
	return ch_posn ;
}


void  invert_block( Ch_posn start, Ch_posn end )
{
	Ch_posn temp_posn ;
	short pxy[4] ;			/* pxy_array for bar drawing				*/
	short line ;
	short w_cell, h_cell ;	/* character sizes							*/
	short dummy ;

							/* do nothing if zero size block			*/
	if( start.c_x == end.c_x && start.c_y == end.c_y )  return ;

							/* swap start and end if wrong way round	*/
	if( start.c_y > end.c_y
					|| ( start.c_y == end.c_y && start.c_x > end.c_x ) )
	{
		temp_posn = end ;
		end = start ;
		start = temp_posn ;
	}

	graf_mouse( M_OFF, NULL ) ;	/* avoid mouse droppings			*/

	wind_update( BEG_UPDATE ) ;		/* keep screen to myself as I could	*/
									/* not redraw block until it is		*/
									/* finished.						*/
	v_attrs( scr_handle, SAVE ) ;
	vswr_mode( scr_handle, MD_XOR ) ;

	vst_point( scr_handle, prefs.notes_text_size, &dummy, &dummy,
													&w_cell, &h_cell ) ;

	for( line = start.c_y; line <= end.c_y; line++ )
	{
		if( line > start.c_y )  pxy[0] = 0 ;
		else  pxy[0] = start.c_x * w_cell ;
		if( line < end.c_y )  pxy[2] = chr_max * w_cell ;
		else  pxy[2] = end.c_x * w_cell ;

		if( pxy[2] > pxy[0] )
		{
			pxy[0] += text_box.g_x + w_cell ;
			pxy[1] = text_box.g_y + line * h_cell + 2 ;
			pxy[2] += text_box.g_x + w_cell - 1 ;
			pxy[3] = pxy[1] + h_cell - 1 ;
			vr_recfl( scr_handle, pxy ) ;
		}
	}
	v_attrs( scr_handle, RESTORE ) ;
	wind_update( END_UPDATE ) ;
	graf_mouse( M_ON, NULL ) ;
}


Ch_posn limit_posn( Ch_posn ch_posn )
{
	if( ch_posn.c_y < 0 )  ch_posn.c_y = 0 ;
	if( ch_posn.c_y > last_line )	/* limit cursor to actual text	*/
	{
		ch_posn.c_y = last_line ;
		ch_posn.c_x = last_char[ch_posn.c_y] ;
	}
	if( ch_posn.c_x < 0 )  ch_posn.c_x = 0 ;
	if( ch_posn.c_x > last_char[ch_posn.c_y] )
		ch_posn.c_x = last_char[ch_posn.c_y] ;

	return ch_posn ;
}


void  load_notes( Person *pptr )
				/* copy notes into head of edit buffer, nothing in tail	*/
{
	notes_loaded = TRUE ;
	if( pptr->notes )
	{
		if( strlen( pptr->notes ) > prefs.edit_buffer_size - 4 )
		{
			rsrc_form_alert( 1, ED_FULL ) ;
			notes_loaded = FALSE ;
		}
		else  strcpy( edit_buffer, pptr->notes ) ;
	}
	else  edit_buffer[0] = '\0' ;

	if( notes_loaded )
	{
		notes_size = strlen( edit_buffer ) ;
		edit_ptr = edit_buffer + notes_size ;
		tail_ptr = edit_buffer + prefs.edit_buffer_size - 1 ;
		*tail_ptr = '\0' ;
		first_line = 0 ;
		block_start_ptr = NULL ;
		block_end_ptr = NULL ;
	}
}


void  set_notes_sizes( GRECT *rect )
{
	char *dummy_str ;
	char dummy_ch ;
	short old_total_lines ;
	short w_cell, h_cell ;			/* character sizes					*/
	short dummy ;

	old_total_lines = total_lines ;

	notes_form.fm_box = *rect ;

	wind_calc( WC_WORK, notes_kind, PTRS( rect ), REFS( text_box ) ) ;

	vst_point( scr_handle, prefs.notes_text_size, &dummy, &dummy,
													&w_cell, &h_cell ) ;

	chr_max = ( text_box.g_w - 2 ) / w_cell - 1 ;
	line_max = ( 2 * text_box.g_h - h_cell ) / ( 2 * h_cell ) ;
	if( line_max > MAX_LINES )  line_max = MAX_LINES ;
	total_lines = draw_text( 0, 0, 0, edit_buffer, -1, &dummy_str, &dummy_ch, FALSE ) ;

	if( old_total_lines && first_line )
	{
		first_line = first_line * (int)total_lines / old_total_lines ;
								/* int cast above to avoid overflowing	*/
								/* 16 bit range when multiplying		*/
		if( first_line >= total_lines )  first_line = total_lines - 1 ;
	}
	else  first_line = 0 ;

	set_notes_slider() ;
}


void  set_notes_slider( void )
{
	char *dummy ;				/* used for unwanted return				*/
	char dummy_ch ;
	short sl_size, sl_pos ;

	total_lines = draw_text( 0, 0, 0, edit_buffer, -1, &dummy, &dummy_ch, FALSE ) ;

	sl_size = line_max * 1000 / ( total_lines + line_max ) ;
	wind_set( notes_form.fm_handle, WF_VSLSIZE, sl_size ) ;
	if( total_lines > 1 )  sl_pos = first_line * 1000 / ( total_lines - 1 ) ;
	else  sl_pos = first_line * 1000 ;
	wind_set( notes_form.fm_handle, WF_VSLIDE, sl_pos ) ;

	wind_set( notes_form.fm_handle, WF_HSLSIZE, 1000 ) ;
}


void  scroll_text( short slid_pos )
{
	first_line = slid_pos * ( total_lines - 1 ) / 1000 ;
	new_text_position() ;
}


void  new_text_position( void )
{
	short sl_pos ;

	sl_pos = first_line * 1000 / ( total_lines - 1 ) ;
	wind_set( notes_form.fm_handle, WF_VSLIDE, sl_pos ) ;

	send_redraw_message( &text_box, notes_form.fm_handle ) ;
}


void  uppage( void )
{
	first_line -= line_max - 1 ;
	if( first_line < 0 )  first_line = 0 ;

	new_text_position() ;
}


void  dnpage( void )
{
	first_line += line_max - 1 ;
	if( first_line > total_lines - 1 )  first_line = total_lines - 1 ;

	new_text_position() ;
}


void  upline( void )	/* up arrow so text moves down	*/
{
	short curs_set_save = FALSE ;
	short i ;
	char property = 0 ;
	char *dummy_ptr ;
	Ch_posn new_block_start ;
	short wh ;

	if( first_line > 0 )
	{
		first_line-- ;
		if( last_line < line_max - 1 )  last_line++ ;
		notes_slider_posn = first_line * 1000 / ( total_lines - 1 ) ;

		if( wind_get( notes_form.fm_handle, WF_TOP, &wh,	NULL, NULL, NULL),
														wh == notes_form.fm_handle )
		{
			if( curs_on )  draw_cursor() ;

			scroll_line( text_box, line_max, DOWN, prefs.notes_text_size ) ;

			if( curs_set )
			{
				curs_set_save = TRUE ;
				cursor.c_y++ ;
			}

			for( i = line_max ; i > 0 ; i-- )
			{
				line_start[i] = line_start[i-1] ;
				last_char[i] = last_char[i-1] ;
			}
			draw_text( 0, 0, 0, edit_buffer, first_line, &line_start[0], &property, FALSE ) ;
			start_property[0] = property ;
			draw_text( 0, 0, 0, line_start[0], 0, &dummy_ptr, &property, TRUE ) ;

			if( curs_set_save && cursor.c_y < line_max && !curs_set )
			{
				curs_set = TRUE ;
				position_cursor( cursor ) ;
			}
			if( block_start_ptr && block_end_ptr )
				/* marked blocks need updating after scrolling, and top	*/
				/* line may need updating								*/
			{
				block_start.c_y++ ;
				block_end = get_ch_posn( block_end_ptr ) ;
				new_block_start = get_ch_posn( block_start_ptr ) ;
				if( block_end.c_y == 0 && block_end.c_x != 0 )
					invert_block( new_block_start, block_end ) ;
				else if( block_end.c_y > 0 && new_block_start.c_y == 0 )
					invert_block( new_block_start, block_start ) ;
				block_start = new_block_start ;
			}
		}
		else
			send_redraw_message( &text_box, notes_form.fm_handle ) ;
	}
}


void  dnline( void )
{
	short curs_set_save = FALSE ;
	short i ;
	char property ;
	char *dummy_ptr ;
	Ch_posn new_block_end ;
	short wh ;

	if( first_line < total_lines - 1 )
	{
		first_line++ ;
		last_line-- ;
		notes_slider_posn = first_line * 1000 / ( total_lines - 1 ) ;

		if( wind_get( notes_form.fm_handle, WF_TOP, &wh,	NULL, NULL, NULL),
														wh == notes_form.fm_handle )
		{
			if( curs_on )  draw_cursor() ;

			scroll_line( text_box, line_max, UP, prefs.notes_text_size ) ;

			if( curs_set )
			{
				curs_set_save = TRUE ;
				cursor.c_y-- ;
			}

			for( i = 0 ; i < line_max ; i++ )
			{
				line_start[i] = line_start[i+1] ;
				last_char[i] = last_char[i+1] ;
				start_property[i] = start_property[i+1] ;
			}
			if( last_line == line_max - 2 )
			{
				if( line_start[line_max - 1] )
				{
					property = start_property[line_max - 1] ;
					draw_text( line_max - 1, 0, 0, line_start[line_max - 1],
									0, &dummy_ptr, &property, TRUE ) ;
				}
					/* The else condition draws the next to bottom line	*/
					/* in order to get a blank line drawn at the bottom	*/
					/* of the window.									*/
				else
				{
					property = start_property[line_max - 2] ;
					draw_text( line_max - 2, 0, 0, line_start[line_max - 2],
									0, &dummy_ptr, &property, TRUE ) ;
				}
			}
			else  curs_set = FALSE ;

			if( curs_set_save && cursor.c_y >= 0 && !curs_set )
			{
				curs_set = TRUE ;
				position_cursor( cursor ) ;
			}
			if( block_start_ptr && block_end_ptr )
				/* marked blocks need updating after scrolling, and		*/
				/* bottom line may need updating						*/
			{
				block_end.c_y-- ;
				block_start = get_ch_posn( block_start_ptr ) ;
				new_block_end = get_ch_posn( block_end_ptr ) ;
				if( block_start.c_y == line_max - 1
										&& block_start.c_x != chr_max )
					invert_block( block_start, new_block_end ) ;
				else if( block_start.c_y < line_max - 1
								&& new_block_end.c_y == line_max - 1 )
					invert_block( block_end, new_block_end ) ;
				block_end = new_block_end ;
			}
		}
		else
			send_redraw_message( &text_box, notes_form.fm_handle ) ;
	}
}


int  notes_redraw( int notes_handle, GRECT *rect )
{
	short pxyarray[4] ;
	char property = 0 ;
	char *dummy ;

	if( notes_form.iconified )
	{
		icons_ptr[0].ob_x = notes_form.fm_box.g_x ;
		icons_ptr[0].ob_y = notes_form.fm_box.g_y ;
		icons_ptr[ICON].ob_spec = icons_ptr[NOTES_ICON].ob_spec ;
		((TEDINFO *)icons_ptr[ICON_LABEL1].ob_spec)->te_ptext = notes_form.icon_label1 ;
		((TEDINFO *)icons_ptr[ICON_LABEL2].ob_spec)->te_ptext = notes_form.icon_label2 ;
		objc_draw( icons_ptr, ROOT, MAX_DEPTH, PTRS( rect ) ) ;
		
		curs_enbl = FALSE ;
	}
	else
	{
		grect2pxy( rect, pxyarray ) ;

		vs_clip( scr_handle, 1, pxyarray ) ;

		blank_text() ;


		draw_text( 0, 0, 0, edit_buffer, first_line, &line_start[0], &property, FALSE ) ;
		start_property[0] = property ;
		draw_text( 0, 0, 0, line_start[0], 0, &dummy, &property, TRUE ) ;

		if( block_start_ptr && block_end_ptr )
		{
			block_start = get_ch_posn( block_start_ptr ) ;
			block_end = get_ch_posn( block_end_ptr ) ;
			invert_block( block_start, block_end ) ;
		}

		vs_clip( scr_handle, 0, NULL ) ;
		
		curs_enbl = TRUE ;
	}

	return 1 ;
}


void  blank_text( void )
{
	short pxyarray[4] ;
	short i ;							/* loop counter					*/

	grect2pxy( &text_box, pxyarray ) ;

	vr_recfl( scr_handle, pxyarray ) ;

	for( i=1; i<MAX_LINES; i++ )
	{
		line_start[i] = NULL ;
		last_char[i] = 0 ;
	}

	curs_on = FALSE ;
}






short  draw_text( short line, short chr, short last_sp, char *txt_ptr,
					short line_no, char **first_line_ptr, char *property,
					short drawing )
				/* If drawing is TRUE, this routine draws text from		*/
				/* specified line and char until end of tail or bottom	*/
				/* of window. If it runs out of text it fills the		*/
				/* remainder of the window with spaces. It ignores		*/
				/* line_no and first_line_ptr. The txt_ptr should point	*/
				/* to the first character to be drawn.					*/
				/* If drawing is FALSE, line, chr and last_sp should	*/
				/* all be 0, for start of virtual display. If			*/
				/* line_no == -1 this routine counts the number of		*/
				/* lines in the edit_buffer at the current notes window	*/
				/* width. It returns this number. If line_no is >= 0 it	*/
				/* sets txt_ptr to point to the start of the line_no'th	*/
				/* line. Note these are lines in the buffer, not on the	*/
				/* screen.												*/
{
	Str_prt_params ps_params ;
	char line_buf[256] ;		/* buffer for forming line				*/
	char properties[256] ;		/* character by character properties	*/
	char *tx_ptr ;				/* pointer into edit buffer				*/
	short done = FALSE ;		/* text draw complete flag				*/
	short last_space, x, y ;
	short w_cell, h_cell ;		/* character sizes						*/
	short curs_x ;				/* for cursor posn from get next slice	*/
	short dummy ;

	vst_point( scr_handle, prefs.notes_text_size, &dummy, &dummy,
													&w_cell, &h_cell ) ;
	last_space = last_sp ;
	tx_ptr = txt_ptr ;
	x = chr ;
	y = line ;

	ps_params.use_gdos = 0 ;
	ps_params.align = LEFT_WRAP ;
	ps_params.max_len = chr_max - x ;


	if( drawing )
	{
		if( curs_on )				/* blank cursor before writing		*/
		{
			draw_cursor() ;
			curs_on = FALSE ;
		}
		curs_set = FALSE ;

		graf_mouse( M_OFF, 0 ) ;	/* turn off mouse while drawing		*/
		wind_update( BEG_UPDATE ) ;
	}
	else
	{
		*first_line_ptr = NULL ;
		tx_ptr = edit_buffer ;
		if( line_no == 0 )
		{
			*first_line_ptr = tx_ptr ;
			done = TRUE ;
		}
	}

	while( !done )
	{
		if( drawing )
		{
			if( x==0 )  line_start[y] = tx_ptr ;
		}
		get_next_slice_with_properties( line_buf, &tx_ptr, tail_ptr, &ps_params,
											&curs_x, property, properties, chr_max ) ; 
		if( drawing )
		{
			short line_length ;
			short padding_spaces ;
			char *pad_ptr ;
			char *prop_ptr ;

			if( ( tx_ptr > tail_ptr || tx_ptr == NULL ) && line_start[y] < tail_ptr )
														/* ie spans cursor position	*/
			{
				cursor.c_x = curs_x ;
				cursor.c_y = y ;
				curs_set = TRUE ;
				previous_space = last_space ;
			}
			
			line_length = strlen( line_buf ) ;
			padding_spaces = chr_max - x - line_length ;
			pad_ptr = line_buf + line_length ;
			prop_ptr = properties + line_length ;
			while( padding_spaces > 0 )
			{
				*pad_ptr++ = ' ' ;
				*prop_ptr++ = *property ;
				padding_spaces-- ;
			}
			*pad_ptr = '\0' ;

			v_gtext_with_properties( scr_handle,
						text_box.g_x + (x + 1) * w_cell, text_box.g_y + (y + 1) * h_cell,
						line_buf, properties ) ;

			last_char[y] = x + line_length ;
			if( tx_ptr == line_start[y+1] )  done = TRUE ;
			line_start[y+1] = tx_ptr ;
			start_property[y+1] = *property ;
			ps_params.max_len = chr_max ;
		}
		x = 0 ;
		y++ ;

		if( drawing )
		{
			if( y >= line_max )
			{
				last_line = line_max - 1 ;
				done = TRUE ;
			}
		}
		else
		{
			if( y == line_no )
			{
				done = TRUE ;
				*first_line_ptr = tx_ptr ;
			}
		}

		if( tx_ptr == NULL )
		{
			done = TRUE ;
			if( drawing)
			{
				if( y < line_max )			/* Blank next line.				*/
				{
					last_line = y - 1 ;
					for( x=0; x<chr_max; x++ )  line_buf[x] = ' ' ;
					line_buf[x] = '\0' ;
					v_gtext( scr_handle, text_box.g_x + w_cell,
						text_box.g_y + (y + 1) * h_cell, line_buf ) ;
				}
				else  last_line = line_max - 1 ;
			}
		}
	}

	if( drawing )
	{
		wind_update( END_UPDATE ) ;
		graf_mouse( M_ON, 0 ) ;			/* restore mouse after drawing	*/

		if( curs_set )  position_cursor( cursor ) ;
	}
	return y ;
}


char  *notes_ch_ptr( Ch_posn ch_posn, char* property )
{
	char *ch_ptr ;
	char *ch_ptr2 ;
	short i ;

	ch_ptr = line_start[ch_posn.c_y] ;
	*property = start_property[ch_posn.c_y] ;
	for( i=ch_posn.c_x ; i > 0 ; i-- )
		get_next_char_with_properties( &ch_ptr, tail_ptr, property ) ;
	
	if( *ch_ptr == '\<' )
	{
		ch_ptr2 = ch_ptr ;
		if( get_next_char_with_properties( &ch_ptr2, tail_ptr, property ) == '\0' )
			ch_ptr = ch_ptr2 - 1 ;
	}
	
	return ch_ptr ;
}


char  get_property( Ch_posn ch_posn )
{
	char property ;
	
	notes_ch_ptr( ch_posn, &property ) ;
	
	return property ;
}


void  move_cursor_xy( short m_x, short m_y )
{
	move_cursor_cl( char_posn( m_x, m_y ) ) ;
}


void  move_cursor_cl( Ch_posn ch_posn )
			/* Proceed to move cursor, and text between head and tail,	*/
			/* only if new position is not the same as the old cursor	*/
			/* position.												*/
{
	char *curs_ptr ;
	int length ;						/* size of memory moves			*/
						/* used for calculating new line start values	*/
	char *old_tail_ptr, *old_head_end, *l_start ;
	int h_to_t, t_to_h ;				/* offsets from head to tail	*/
	short line ;						/* loop counter					*/
	char dummy_ch ;

	if( ( ch_posn.c_x != cursor.c_x || ch_posn.c_y != cursor.c_y ) )
	{
		ch_posn = limit_posn( ch_posn ) ;

		old_head_end = edit_ptr ;	/* Save old values for computing	*/
		old_tail_ptr = tail_ptr ;	/* new line start values.			*/
					/* move part of head to tail or vice versa			*/
		curs_ptr = notes_ch_ptr( ch_posn, &dummy_ch ) ;
		if( curs_ptr < edit_ptr )
		{
			length = edit_ptr - curs_ptr ;
			memmove( tail_ptr - length, curs_ptr, (size_t) length ) ;
			edit_ptr = curs_ptr ;
			*edit_ptr = '\0' ;
			tail_ptr -= length ;
		}
		else if( curs_ptr > tail_ptr )
		{
			length = curs_ptr - tail_ptr ;
			memmove( edit_ptr, tail_ptr, (size_t) length ) ;
			edit_ptr += length ;
			*edit_ptr = '\0' ;
			tail_ptr += length ;
		}
		cursor = ch_posn ;

					/* Set line_start values for new cursor position	*/
		h_to_t = tail_ptr - edit_ptr ;
		t_to_h = old_head_end - old_tail_ptr ;
		for( line = 0; line <= last_line + 1; line++ )
		{
			l_start = line_start[line] ;
			if( l_start < old_head_end && l_start > edit_ptr )
														/* head to tail	*/
				line_start[line] = l_start + h_to_t ;
			if( l_start > old_tail_ptr && l_start < tail_ptr )
														/* tail to head	*/
				line_start[line] = l_start + t_to_h ;
		}

		previous_space = 0 ;	/* Force text to be drawn from beginning*/
								/* of line first time after moving		*/
								/* cursor. Drawing the text will set	*/
								/* previous space for subsequent draws.	*/

								/* If block marked unmark it when		*/
								/* cursor moved to save calculating		*/
								/* new pointers and positions.			*/
		if( block_start_ptr && block_end_ptr )
		{
			invert_block( block_start, block_end ) ;
			block_start_ptr = block_end_ptr = NULL ;
		}

		if( block_start_ptr )
		{
			if( block_start_ptr <= old_head_end
											&& block_start_ptr > edit_ptr )
				block_start_ptr += tail_ptr - edit_ptr ;
			else if( block_start_ptr >= tail_ptr
											&& block_start_ptr < tail_ptr )
				block_start_ptr -= tail_ptr - edit_ptr ;
		}
		if( block_end_ptr )
		{
			if( block_end_ptr <= old_head_end
											&& block_end_ptr > edit_ptr )
				block_end_ptr += tail_ptr - edit_ptr ;
			else if( block_end_ptr >= tail_ptr
											&& block_end_ptr < tail_ptr )
				block_end_ptr -= tail_ptr - edit_ptr ;
		}

		if( curs_on )  draw_cursor() ;

		position_cursor( ch_posn ) ;
	}
}


void  position_cursor( Ch_posn ch_posn )
{
	short w_cell, h_cell ;
	short dummy ;

	vst_point( scr_handle, prefs.notes_text_size, &dummy, &dummy,
													&w_cell, &h_cell ) ;

	x_cur = ( ch_posn.c_x + 1 ) * w_cell ;
												/* +1 for text offset	*/
	y_cur = ch_posn.c_y * h_cell + 1 ;
	curs_set = TRUE ;
	curs_on = FALSE ;
	draw_cursor() ;
}


Ch_posn  char_posn( short m_x, short m_y )
{
	Ch_posn ch_posn ;
	short w_cell, h_cell ;
	short dummy ;

	vst_point( scr_handle, prefs.notes_text_size, &dummy, &dummy,
													&w_cell, &h_cell ) ;


	ch_posn.c_x = ( m_x - text_box.g_x ) / w_cell - 1 ;
										/* -1 to allow for text offset	*/
	ch_posn.c_y = ( m_y - text_box.g_y - 2 ) / h_cell ;
	if( ch_posn.c_x == -1 )  ch_posn.c_x = 0 ;

	return ch_posn ;
}



void  draw_cursor( void )
{
	short pxy_array[4] ;
	short w_cell, h_cell ;
	short dummy ;

	vst_point( scr_handle, prefs.notes_text_size, &dummy, &dummy,
													&w_cell, &h_cell ) ;


	graf_mouse( M_OFF, 0 ) ;		/* turn off mouse while drawing		*/
	wind_update( BEG_UPDATE ) ;

	v_attrs( scr_handle, SAVE ) ;
	vswr_mode( scr_handle, MD_XOR ) ;
	pxy_array[0] = x_cur + text_box.g_x ;
	pxy_array[1] = y_cur + text_box.g_y ;
	pxy_array[2] = x_cur + text_box.g_x ;
	pxy_array[3] = y_cur + text_box.g_y + h_cell ;
	v_pline( scr_handle, 2, pxy_array ) ;

	v_attrs( scr_handle, RESTORE ) ;

	curs_on = !curs_on ;

	wind_update( END_UPDATE ) ;
	graf_mouse( M_ON, 0 ) ;			/* restore mouse after drawing		*/
}


void  notes_keys( short kstate, short kreturn )
{
	short ascii ;
	short scan ;
	char cursor_key ;				/* flag to say cursor key pressed	*/
	Ch_posn cur_posn ;
	char property ;
	char *dummy ;
	short done ;
	char *new_edit_ptr ;
	char *old_tail_ptr ;

	notes_changed = TRUE ;			/* This will cause the notes to be	*/
									/* checked to see if really changed	*/

	ascii = kreturn & 0xFF ;
	scan  = kreturn & 0xFF00 ;

	switch( kstate )	/* ignore caps lock and shifts, bits 4,1,0 resp	*/
	{
		case 0 :
		case 1 :
		case 2 :
		case 3 :
		case 16 :
		case 17 :
		case 18 :
		case 19 :
			if( ( curs_set && ascii >= 0x20 && ascii != 0x7F )
														|| ascii == 0x0D )
			{
				if( notes_size < prefs.edit_buffer_size - 4 )
				{					/* If block marked unmark it when	*/
									/* adding text to save calculating	*/
									/* new pointers and positions.		*/
					if( block_start_ptr && block_end_ptr )
					{
						invert_block( block_start, block_end ) ;
						block_start_ptr = block_end_ptr = NULL ;
					}

					notes_size++ ;
					*edit_ptr++ = ascii ;
					*edit_ptr = '\0' ;
					if( ascii == ' ' && word_up( 0 ) )
					{
						line_start[cursor.c_y] = NULL ;	/* force redraw	*/
						property = start_property[cursor.c_y - 1] ;
						draw_text( cursor.c_y - 1 , 0, 0,
							line_start[cursor.c_y - 1], 0, &dummy, &property, TRUE ) ;
					}
					else 
					{
						property = start_property[cursor.c_y] ;
						draw_text( cursor.c_y, 0, 0,
								line_start[cursor.c_y], 0, &dummy, &property, TRUE ) ;
					}
					if( !curs_set )		/* scroll screen up one line	*/
					{
						property = start_property[1] ;
						start_property[0] = property ;
						draw_text( 0, 0, 0, line_start[1], 0, &dummy, &property, TRUE ) ;
					}
				}
				else  rsrc_form_alert( 1, ED_FULL ) ;
			}
														/* backspace	*/
			else if( curs_set && ascii == 0x08
				&& edit_ptr > edit_buffer && ( cursor.c_x || cursor.c_y ) )
			{					/* If block marked unmark it when		*/
								/* deleting text to save calculating	*/
								/* new pointers and positions.			*/
				if( block_start_ptr && block_end_ptr )
				{
					invert_block( block_start, block_end ) ;
					block_start_ptr = block_end_ptr = NULL ;
				}

				/* if tags in way, move edit point past it	*/
				done = FALSE ;
				while( *(edit_ptr-1) == '>' && !done )
				{
					new_edit_ptr = edit_ptr - 1 ;
					while( !done )
					{
						new_edit_ptr-- ;
						if( *new_edit_ptr == '>' || new_edit_ptr <= edit_buffer ) done = TRUE ;
						else
						{
							if( *new_edit_ptr == '<' )
							{
								if( *(new_edit_ptr-1) == '<' )  new_edit_ptr-- ;
								else		/* found start of tag	*/
								{
									tail_ptr -= edit_ptr - new_edit_ptr ;
									strncpy( tail_ptr, new_edit_ptr, (size_t) (edit_ptr - new_edit_ptr) ) ;
									edit_ptr = new_edit_ptr ;
									*edit_ptr = '\0' ;
								}
							}
						}
					}
				}
				
				*--edit_ptr = '\0' ;	/* delete last character	*/
				notes_size-- ;

				if( word_up( 1 ) || ( cursor.c_x == 0 ) )
				{
					line_start[cursor.c_y] = NULL ;	/* force redraw		*/
					property = start_property[cursor.c_y - 1] ;
					draw_text( cursor.c_y - 1, 0, 0,
							line_start[cursor.c_y - 1], 0, &dummy, &property, TRUE ) ;
				}
				else
				{
					property = start_property[cursor.c_y] ;
					draw_text( cursor.c_y, 0, 0, line_start[cursor.c_y],
												0, &dummy, &property, TRUE ) ;
				}
			}
														/* delete		*/
			else if( ascii == 0x7F && block_start_ptr && block_end_ptr )
				delete_block() ;
			else if( curs_set && ascii == 0x7F  && *tail_ptr
								&& !( cursor.c_y == last_line
									&& cursor.c_x == last_char[cursor.c_y] ) )
			{
													/* delete next char	*/
				/* if tags in way, move edit point past it	*/
				while( *tail_ptr == '<' && *(tail_ptr+1) != '<' )
				{
					old_tail_ptr = tail_ptr ;
					while( *tail_ptr++ != '>' ) ;
					strncpy( edit_ptr, old_tail_ptr, (size_t) (tail_ptr - old_tail_ptr) ) ;
					edit_ptr += tail_ptr - old_tail_ptr ;
					*edit_ptr = '\0' ; 
				}
				
				tail_ptr++ ;
				notes_size-- ;

				/* if( previous_space )
					draw_text( cursor.c_y, previous_space,
							previous_space, edit_ptr, 0, &dummy, TRUE ) ;
				else */ if( word_up( 0 ) )
				{
					property = start_property[cursor.c_y - 1] ;
					line_start[cursor.c_y] = NULL ;	/* force redraw		*/
					draw_text( cursor.c_y - 1, 0, 0,
							line_start[cursor.c_y - 1], 0, &dummy, &property, TRUE ) ;
				}
				else
				{
					property = start_property[cursor.c_y] ;
					draw_text( cursor.c_y, 0, 0, line_start[cursor.c_y],
														0, &dummy, &property, TRUE ) ;
				}
			}

			else if( curs_set && ascii == 0 )
			{
				cursor_key = TRUE ;
									/* take copy of old cursor position	*/
				cur_posn = cursor ;

				switch( scan )
				{
					case 0x4B00 :					/* cursor left		*/
						cur_posn.c_x -= 1 ;
						break ;
					case 0x4D00 :					/* cursor right		*/
						cur_posn.c_x += 1 ;
						break ;
					case 0x4800 :					/* cursor up		*/
						cur_posn.c_y -= 1 ;
						break ;
					case 0x5000 :					/* cursor down		*/
						cur_posn.c_y += 1 ;
						break ;
					case 0x6200 :					/* help				*/
						break ;
					default :
						cursor_key = FALSE ;
#ifndef NDEBUG
						report( scan ) ;
#endif
						break ;
				}
			if( cursor_key )  move_cursor_cl( cur_posn ) ;
			}
			break ;
		case 4 :								/* Ctrl key held down	*/
		case 5 :
		case 6 :
		case 7 :
		case 20 :
		case 21 :
		case 22 :
		case 23 :
						/* add 0x60 to go from control value to letter	*/
			switch( ascii + 0x60 ) {
				case 'c' :
					write_further_notes_to_clipboard() ;
					break ;
				case 'x' :
					write_further_notes_to_clipboard() ;
					delete_block() ;
					break ;
				case 'v' :
					read_further_notes_from_clipboard() ;
					break ;
				case 'b' :
					mark_block( BLOCK_START ) ;
					break ;
				case 'e' :
					mark_block( BLOCK_END ) ;
					break ;
				case 'l' :
					add_reference() ;
					break ;
				default :
					break ;
			}
			break ;
		default :
			break ;
	}
}


short  word_up( short corr )	/* Tests if adding space will allow		*/
								/* first word in line to move to end of	*/
								/* previous line. Correction passed is	*/
								/* to allow for different cursor		*/
								/* position relative to end of word for	*/
								/* entry of space and deletion.			*/
{
	short up = FALSE ;

	if( !previous_space && cursor.c_y > 0 )
		if( chr_max - ( last_char[cursor.c_y - 1] + 1 ) > cursor.c_x - corr )
			up = TRUE ;
								/* No word up if previous line ended	*/
								/* with carriage return.				*/
	if( up && *(line_start[cursor.c_y] - 1) == 0x0D )  up = FALSE ;

	return up ;
}


char  *check_notes( void )
{
	int lng ;

	if( notes_changed )
	{
		lng = strlen( tail_ptr ) + 1 ;
		memmove( edit_ptr, tail_ptr, (size_t) lng ) ;
		clear_empty_tags() ;
		return edit_buffer ;
	}
	else  return NULL ;
}

void  clear_empty_tags( void )
{
	char *tag_start ;
	char *tag_end ;
	char *ch_ptr ;
	char ch ;
	int lng ;
	
	ch_ptr = edit_buffer ;
	while( ch = *ch_ptr++, ch != '\0' )
	{
		if( ch == '<' && *ch_ptr != '<' && *ch_ptr != '\\' )
		{
			tag_start = ch_ptr - 1 ;
			while( ch = *ch_ptr++, ch != '\0' && ch != '>' ) ;
			if( ch == '>' )
			{
				ch = *ch_ptr++ ;
				if( ch == '<' && *ch_ptr != '<' )
				{
					while( ch = *ch_ptr++, ch != '\0' && ch != '>' ) ;
					if( ch == '>' )
					{
						tag_end = ch_ptr ;
						lng = strlen( tag_end ) + 1 ;
						memmove( tag_start, tag_end, (size_t) lng ) ;
					}
				}
			}
			if( ch = '\0' )  ch_ptr-- ;	/* ready to exit main loop with terminator	*/ 
		}
	}
}

void  add_string( const char *str )
{
	if( strlen( str ) > prefs.edit_buffer_size - notes_size )
		rsrc_form_alert( 1, ED_FULL ) ;
	else
	{
		strcpy( edit_ptr, str ) ;
		edit_ptr += strlen( str ) ;
	}
}

void  next_posn( Ch_posn *posn_ptr )
{
	if( posn_ptr->c_x < last_char[posn_ptr->c_y] )  posn_ptr->c_x += 1 ;
	else
	{
		posn_ptr->c_x = 0 ;
		posn_ptr->c_y += 1 ;
	}
}

void  add_reference( void )
{
	Ch_posn start_posn, end_posn, test_posn ;
	char link_file[FMSIZE+FNSIZE] ;
	char buffer[FNSIZE+FMSIZE+3] ;
	short button ;
	char va ;						/* only used to check if associated file	*/
	char program[FNSIZE+FMSIZE] ;
	char *backslash ;
	char *dot ;
	short href_found = FALSE ;


	if( block_start_ptr && block_end_ptr && block_start_ptr != block_end_ptr )	/* valid block	*/
	{
		start_posn = get_ch_posn( block_start_ptr ) ;
		end_posn = get_ch_posn( block_end_ptr ) ;

		/* set deflt file to existing file reference if there is one.	*/
		test_posn = start_posn ;
		while( !href_found && ( test_posn.c_y < end_posn.c_y
						|| test_posn.c_y == end_posn.c_y && test_posn.c_x <= end_posn.c_x ) )
		{
			if( get_property( test_posn ) & HREF )
			{
				find_href( test_posn, deflt_file ) ;
				href_found = TRUE ;
			}
			else  next_posn( &test_posn ) ;
		}
		 
		/* if deflt still not set then set it to standard default	*/
		if( *deflt_file == '\0' )
		{
			strcpy( deflt_file, save_directory ) ;
			strcat( deflt_file, "\\*.IMG" ) ;
		}
		
		link_file[0] = '\0' ;
		fsel_geninput( link_file, deflt_file, &button, SELECT_LINK_FILE ) ;
		if( button )
		{
			/* remove previous references, if any	*/
			if( href_found )
			{
				move_cursor_cl( test_posn ) ;
				remove_reference() ;
			}
			
			sprintf( buffer, set_href_str, link_file ) ;
			strcpy( deflt_file, link_file ) ;
			backslash = strrchr( deflt_file, '\\' ) ;
			dot = strrchr( deflt_file, '.' ) ;
			if( backslash && dot > backslash + 1 )
			{
				*(backslash + 1) = '*' ;
				strcpy( backslash + 1, dot ) ;
			}
		
			move_cursor_cl( end_posn ) ;
			add_string( end_href_str ) ;
			move_cursor_cl( start_posn ) ;
			add_string( buffer ) ;

			send_redraw_message( &text_box, notes_form.fm_handle ) ;

			notes_changed = TRUE ;	/* This will cause the notes to be	*/
									/* checked to see if really changed	*/
			if( !get_associated_program( program, link_file, &va ) )
				invite_add_association( link_file ) ;
		}
	}
	else  rsrc_form_alert( 1, NO_BLOCK_MARKED ) ;
}


void  remove_reference( void )
{
	char *ptr, *tag ;
	char ch ;
	char *old_tail_ptr ;
	
	if( find_href_string( cursor, &ptr, &tag ) )
	{
		while( *ptr++ != '>' ) ;
		strcpy( tag, ptr ) ;	/* removes leading tag	*/
		edit_ptr -= ptr - tag ;
		
		ch = ' ' ;	/* non '<' starting value	*/
		while( ch != '<' )
		{
			ch = get_next_char( &tag, tail_ptr ) ;
			
			if( ch == '<' && *tag == '<' )
			{
				get_next_char( &tag, tail_ptr ) ;
				ch = get_next_char( &tag, tail_ptr ) ;
			}
		}
		
		tag-- ;

		ptr = tag ;
		while( *ptr++ != '>' ) ;
		old_tail_ptr = tail_ptr ;
		tail_ptr += ptr - tag ;
		memmove( tail_ptr, old_tail_ptr, (size_t) ( tag - old_tail_ptr ) ) ;
		send_redraw_message( &text_box, notes_form.fm_handle ) ;

		notes_changed = TRUE ;		/* This will cause the notes to be	*/
									/* checked to see if really changed	*/
	}
}


short  find_href_string( Ch_posn posn, char **ref_ptr, char **tag_start )
{
	char property ;
	char *ptr ;
	char *sav_ptr ;
	short found = FALSE ;
	char ch ;
	char buffer[FMSIZE+FNSIZE+1] ;
	char *buf_ptr ;
	short i ;
	
	property = start_property[posn.c_y] ;
	ptr = notes_ch_ptr( posn, &property ) ;
	if( ptr == edit_ptr && ptr > edit_buffer )  ptr-- ;	/* force it to point to character, not \0	*/
	
	if( ( property & HREF ) == 0 )  return FALSE ;
	while( !found )
	{
		ch = ' ' ;				/* a value to allow loop to start	*/
		while( ch && ch != '<' )
		{
			ch = get_previous_char( &ptr, tail_ptr, edit_ptr ) ;
	
			while( ch == '<' && *ptr == '<' )	/* discard any "<<"	*/
			{
				get_previous_char( &ptr, tail_ptr, edit_ptr ) ;
				ch = get_previous_char( &ptr, tail_ptr, edit_ptr ) ;
			}
		}
		if( !ch )  return FALSE ;	
	
		*tag_start = ptr+1 ;
		
		sav_ptr = ptr ;
		found = TRUE ;
	
		ptr++ ;
		ptr++ ;
		
		buf_ptr = buffer ;
		ch = ' ' ;
		while( isspace( ch ) )  ch = get_next_char( &ptr, tail_ptr ) ;
		if( ch != 'a' && ch != 'A' )  found = FALSE ;
		else
		{
			ch = ' ' ;
			while( isspace( ch ) )  ch = get_next_char( &ptr, tail_ptr ) ;
			*buf_ptr++ = ch ;
			for( i=0; i<3; i++ )  *buf_ptr++ = get_next_char( &ptr, tail_ptr ) ;
			*buf_ptr = '\0' ;
			strlwr( buffer ) ;
			
			if( strstr( href_str, buffer ) != href_str+2 )  found = FALSE ;
		}
		if( !found )  ptr = sav_ptr ;
	}
	*ref_ptr = ptr ;
	
	return found ;
}

short  find_href( Ch_posn posn, char *ref_file )
{
	char *ptr, *tag ;
	char ch ;
	char buffer[FMSIZE+FNSIZE+1] ;
	char *buf_ptr ;
	char *buf_end ;
	
	if( !find_href_string( posn, &ptr, &tag ) ) return FALSE ;
	
	/* if we get here we have found "a href"	*/
	ch = ' ' ;	/* arbitrary value to start while loop	*/
	while( ch && ch != '=' )  ch = get_next_char( &ptr, tail_ptr ) ;
	while( ch && ch != '\"' )  ch = get_next_char( &ptr, tail_ptr ) ;
	if( ch )  ch = get_next_char( &ptr, tail_ptr ) ;
	buf_ptr = buffer ;
	buf_end = buffer + FMSIZE+FNSIZE ;
	while( ch && ch != '\"' && buf_ptr < buf_end )
	{
		*buf_ptr++ = ch ;
		ch = get_next_char( &ptr, tail_ptr ) ;
	}
	*buf_ptr = '\0' ;
	
	strcpy( ref_file, buffer ) ;

	return TRUE ; 
}


void  link_to_reference( void )
{
	char reference[FMSIZE+FNSIZE+3] ;
	char program[FMSIZE+FNSIZE+1] ;
	char dummy[FMSIZE+FNSIZE+1] ;
	char assoc_app[FNSIZE + 1] ;
	char ass_path[FMSIZE+1] ;
	char cur_path[FMSIZE+1] ;
	char ass_name[FMSIZE + 1] ;
	char va ;
	int assoc_id = -1 ;
	unsigned short msg[8] ;
	char program_name[9] = "12345678" ;
	char *dot_ptr ;
	
	if( find_href( cursor, reference+2 ) )
	{
		if( !get_associated_program( program, reference+2, &va ) )
			invite_add_association( reference+2 ) ;
			
		if( get_associated_program( program, reference+2, &va ) )
		{
			if( va == 'v' )
			{
				strsfn( program, dummy, dummy, assoc_app, dummy ) ;
				assoc_app[8] = '\0' ;
				strupr( assoc_app ) ;
				while( strlen( assoc_app ) < 8 )  strcat( assoc_app, " " ) ;
				assoc_id = appl_find( assoc_app ) ;
			}
			
			/* if string contains a space it needs quotes around it	*/
			if( strchr( reference+2, ' ' ) )
			{
				*(reference+1) = '\"' ;
				strcat( reference+1, "\"" ) ;
			}
			else  strcpy( reference+1, reference+2 ) ;

			if( assoc_id != -1 )
			{
				msg[0] = /*VA_START*/ 0x4711 ;
				msg[1] = ap_id ;
				msg[2] = 0 ;
				msg[3] = (long)(reference+1) >> 16 ;
				msg[4] = (long)(reference+1) ;
				msg[5] = 0 ;
				msg[6] = 0 ;
				msg[7] = 0 ;

				appl_write( assoc_id, 16, msg ) ;
			}
			else
			{
				getcwd( cur_path, FMSIZE ) ; 
				stcgfp( ass_path, program ) ;
				chdir( ass_path ) ;
				*reference = strlen( reference+1 ) ;
				if( _AESglobal[0] >= MAGIC )	/* ie multitasking	*/
					Pexec( 100, program, reference, NULL ) ;
				else
				{
					ass_name[0] = ' ' ;
					stcgfn( ass_name+1, program ) ;
					if( dot_ptr = strchr( ass_name, '.' ), dot_ptr )  *dot_ptr = '\0' ;
					strncpy( program_name, (char *)(menu_ptr[PROGRAM_NAME].ob_spec), 8 ) ;
					ass_name[strlen(program_name)] = '\0' ;
					menu_bar( menu_ptr, MENU_REMOVE ) ;
					menu_text( menu_ptr, PROGRAM_NAME, ass_name ) ;
					menu_bar( menu_ptr, MENU_INSTALL ) ;
					
					menu_bar( menu_ptr, MENU_REMOVE ) ;
					Pexec( 0, program, reference, NULL ) ;
					
					menu_text( menu_ptr, PROGRAM_NAME, program_name ) ;
					menu_bar( menu_ptr, MENU_INSTALL ) ;
					redraw_all_windows() ;
				}
				chdir( cur_path ) ;
			}
			
			graf_mouse( ARROW, NULL ) ;
		}
	}
}

void  invite_add_association( char* link_file )
{
	void *alert_ptr ;
	char alert_str[200] ;
	char fname[31] ;
					
	shorten_file_name( fname, link_file, 30 ) ;
	rsrc_gaddr( R_STRING, NO_ASSOCIATION, &alert_ptr ) ;
	sprintf( alert_str, alert_ptr, fname ) ;
	if( form_alert( 0, alert_str ) == 1 )
		add_to_file_associations( link_file ) ;
}

