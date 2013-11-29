/************************************************************************/
/*																		*/
/*		Genpsel.h	23 Mar 97											*/
/*																		*/
/************************************************************************/

/* Header file for GENPSEL containing #DEFINES and						*/
/* prototype definitions												*/

											/* Routines in GENPSEL.C	*/
int		get_person_reference( char *f_nam, short list ) ;
void	set_to_ignore( short field ) ;
void	set_psel_form_addrs( void ) ;
void	clear_psel_form( char *f_nam ) ;
void	update_listed_people( GRECT box ) ;
void	update_filter( Filter *filter, char *fam_name, char *forename,
							char *before_date_str, char *after_date_str,
							char *birth_place ) ;
short	test_match( Filter *filter, int reference ) ;
int		pidx_compare( void *ref1_ptr, void *ref2_ptr ) ;
short	compare_dates( int date1, int date2 ) ;

void	pselect( int entry, int *ref_ptr, GRECT box ) ;
void	display_short_list( GRECT box ) ;
void	update_extra_info( int ref ) ;
size_t	my_glob_exact( const char *string, const char *pattern ) ;
size_t	my_glob( const char *string, const char *pattern ) ;
