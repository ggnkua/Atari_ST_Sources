/************************************************************************/ 
/*																		*/
/*		Gencoup.h	 5 Feb 97											*/
/*																		*/
/************************************************************************/

/* Header file for GEN containing #DEFINES and							*/
/* prototype definitions												*/

											/* Routines in GENCOUP.C	*/
void	edit_couple( int reference, int male_ref, int female_ref ) ;
void	close_couple( void ) ;
void	coup_mu_mesag( const short *message ) ;
void	coup_mu_button( short m_x, short m_y, short breturn ) ;
void	select_progeny( short prog_num, GRECT box ) ;
void	set_couple_form_addrs( void ) ;
Couple *load_couple( int reference, int male_ref, int female_ref,
													short *blk_ptr ) ;
void	update_progeny( void ) ;
void	save_couple( int reference, short block, Couple *cptr ) ;
void	save_int( int *dest, int source, short *changed_ptr ) ;
int		child_compare( void *child1_ptr, void *child2_ptr ) ;
void	add_to_cidx( int ref, Couple *cptr ) ;
short	q_del_coup( int reference, short block, Couple *cptr ) ;
void	sort_couplings( int ref ) ;
void	get_children( Couple *cptr, int *children ) ;
