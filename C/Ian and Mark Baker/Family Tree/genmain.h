/************************************************************************/
/*																		*/
/*		Genmain.h	 7 Feb 1999											*/
/*																		*/
/************************************************************************/

/* Header file for GEN containing #DEFINES and							*/
/* prototype definitions												*/

										/* Routines in GEN.C		*/
int		main( int argc, char *argv[] ) ;
void	initialise( void ) ;
void	set_rsrc_ptrs( void ) ;
void	set_rsrc_addrs( void ) ;
void	load_months( void ) ;
void	close_down( void ) ;
void	service_events( void ) ;
void	ctrl_keys( short kstate, short kreturn, int *quit_ptr ) ;
void	alt_keys( short kreturn, int *quit_ptr ) ;
void	edit_keys( short kreturn, Wind_edit_params *form_ed_params ) ;
int		form_keys( short kreturn, Wind_edit_params *form_ed_params ) ;
void	pass_message( const short *message ) ;
void	save_current_edits( void ) ;
void	about_message( void ) ;
short	save_and_continue( void ) ;
short	data_changed( void ) ;
void	clear_jobs( void ) ;
void	sub_edit_person( int old_ref, int new_ref ) ;
void	make_job_room( void ) ;
void	load_defaults( void ) ;
void	initialise_file_name( char *file_name, const char *default_name ) ;
void	save_defaults( void ) ;
void	set_date_qualifier( short asc_char ) ;
