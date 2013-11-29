/************************************************************************/
/*																		*/
/*		Gendesc.h	 5 Feb 97											*/
/*																		*/
/************************************************************************/

/* Header file for GENDESC containing #DEFINES and						*/
/* prototype definitions												*/

#define LEVEL_SPACING 6
#define SPOUSE_SPACING 2

											/* Routines in GENDESC.C	*/
void	print_descendants( int ref ) ;
void	build_spouse_name_string( char* names, int ref, int* spouse, Couple *cptr ) ;
void	find_max_levels( int ref, short level, Str_prt_params *ps_ptr ) ;
short	rightmost_char_posn( const char *names, short level, const Str_prt_params *ps_ptr ) ;
void	print_desc( int ref, short level, Str_prt_params *ps_ptr ) ;
void	draw_verticals( short level, short horiz_flag, Str_prt_params *ps_ptr ) ;
void	tree_print_std_printer( int trunk ) ;
void	std_print_tree_person( Tree_params tree_params, Str_prt_params *ps_ptr,
						short *verts, char *underlines, short sidestep ) ;
void	disp_desc( int ref ) ;
void	open_titled_draw_window( Wind_edit_params *p, int wind_kind,
				short title_index, short ititle_index, short *fulled_flag_ptr,
				int reference, GRECT *draw_box_ptr ) ;
void	close_desc( void ) ;
void	desc_mu_mesag( const short *message ) ;
void	desc_mu_button( short m_x, short m_y, short breturn ) ;
int		desc_redraw( int handle, GRECT *rect_ptr ) ;
short	desc_line_count( void ) ;
void	set_desc_scroll( void ) ;
void	draw_one_desc( short position ) ;
