/************************************************************************/
/*																		*/
/*		Genpprn.h	16 Jul 97											*/
/*																		*/
/************************************************************************/

/* Header file for GENPPRN containing #DEFINES and						*/
/* prototype definitions												*/

											/* Routines in GENPPRN.C	*/
void	print_people( int ref ) ;
void	print_person( int reference, Str_prt_params *ps_ptr ) ;
void	print_flag( short flag_num, short flags, Str_prt_params *ps_ptr ) ;
void	print_notes( char *notes, Str_prt_params *ps_ptr ) ;
void	print_notes_indented( Person *pptr, Str_prt_params *ps_ptr ) ;
void	print_index( void ) ;
void	print_idx_person( int ref, Str_prt_params *ps_ptr ) ;
