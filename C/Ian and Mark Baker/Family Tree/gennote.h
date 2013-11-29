/************************************************************************/
/*																		*/
/*		Gennote.h	26 Feb 00											*/
/*																		*/
/************************************************************************/

/* Header file for GENNOTE containing #DEFINES and						*/
/* prototype definitions												*/

											/* Routines in GENNOTE.C	*/
void	further_notes( int reference, Person *pptr ) ;
void	notes_mu_mesag( const short *message ) ;
void	notes_mouse_handler( short m_x, short m_y, short breturn ) ;
void	mark_block( short end ) ;
void	delete_block( void ) ;
void	select_all_notes( void ) ;
Ch_posn	get_ch_posn( char *ch_ptr ) ;
void	invert_block( Ch_posn start, Ch_posn end ) ;
Ch_posn	limit_posn( Ch_posn ch_posn ) ;
void	load_notes( Person *pptr ) ;
void	set_notes_sizes( GRECT *rect ) ;
void	set_notes_slider( void ) ;
void	scroll_text( short slid_pos ) ;
void	new_text_position( void ) ;
void	uppage( void ) ;
void	dnpage( void ) ;
void	upline( void ) ;
void	dnline( void ) ;
int		notes_redraw( int notes_handle, GRECT *rect ) ;
void	blank_text( void ) ;
short	draw_text( short line, short chr, short last_sp, char *txt_ptr,
					short line_no, char **first_line_ptr, char *property,
					short drawing ) ;
void	draw_cursor( void ) ;
char	*notes_ch_ptr( Ch_posn ch_posn, char* property ) ;
char	get_property( Ch_posn ch_posn ) ;
void	move_cursor_xy( short m_x, short m_y ) ;
void	move_cursor_cl( Ch_posn ch_posn ) ;
void	position_cursor( Ch_posn ch_posn ) ;
Ch_posn	char_posn( short m_x, short m_y ) ;
short	word_up( short corr ) ;
char	*check_notes( void ) ;
void	clear_empty_tags( void ) ;
void	add_string( const char *str ) ;
void	next_posn( Ch_posn *posn_ptr ) ;
void	add_reference( void ) ;
void	remove_reference_here( Ch_posn posn ) ;
void	remove_reference( void ) ;
short	find_href_string( Ch_posn posn, char **ref_ptr, char **tag_start ) ;
short	find_href( Ch_posn posn, char *ref_file ) ;
void	link_to_reference( void ) ;
void	invite_add_association( char* link_file ) ;
