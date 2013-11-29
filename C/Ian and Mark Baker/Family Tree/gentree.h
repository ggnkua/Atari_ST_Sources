/************************************************************************/
/*																		*/
/*		Gentree.h		 5 Feb 97										*/
/*																		*/
/************************************************************************/

/* Header file for GEN containing #DEFINES and							*/
/* prototype definitions												*/

											/* Routines in GENTREE.C	*/
void	disp_tree( int ref ) ;
void	close_tree( void ) ;
void	tree_mu_mesag( const short *message ) ;
void	tree_mu_button( short m_x, short m_y, short breturn ) ;
int		tree_redraw( int handle, GRECT *rect_ptr ) ;
void	draw_person( int handle, Tree_params pars ) ;
void	load_all_strings( int tree_trunk ) ;
void	load_tree_strings( Tree_params pars ) ;
short	get_rect_number( short x, short y ) ;
