/************************************************************************/
/*																		*/
/*		Genfprn.h	 9 Feb 97											*/
/*																		*/
/************************************************************************/

/* Header file for GENFPRN containing #DEFINES and						*/
/* prototype definitions												*/

											/* Routines in GENFPRN.C	*/
void	print_family( void ) ;
void	print_basic_person_data( Person* pptr, Str_prt_params *ps_ptr ) ;
void	print_date_text(  OBJECT *form_ptr, short field, int date, char *text,
					Str_prt_params *ps_ptr ) ;
void	print_parents( Person *pptr, Str_prt_params *ps_ptr ) ;
void	print_spouses( Person* pptr, Str_prt_params *ps_ptr ) ;

