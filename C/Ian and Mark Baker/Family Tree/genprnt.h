/************************************************************************/
/*																		*/
/*		Genprnt.h	22 Jul 97											*/
/*																		*/
/************************************************************************/

/* Header file for GENPPRN containing #DEFINES and						*/
/* prototype definitions												*/



											/* Routines in GENPRNT.C	*/
BOOLEAN	start_print_checking( Str_prt_params *ps_ptr ) ;
BOOLEAN	check_printing( Str_prt_params *ps_ptr ) ;
BOOLEAN	printing_ok( Str_prt_params *ps_ptr ) ;
void  stop_print_checking( Str_prt_params *ps_ptr ) ;
void	end_page( Str_prt_params *ps_ptr, BOOLEAN more ) ;
void	next_page( Str_prt_params *ps_ptr ) ; 
void	close_printer( Str_prt_params *ps_ptr ) ;
void	page_feed( Str_prt_params *ps_ptr, BOOLEAN more ) ;
short	print_str( OBJECT *form_ptr, short field, char *str_ptr,
					short ignore_blank, Str_prt_params *ps_ptr ) ;
short	print_char( OBJECT *form_ptr, short field, char chr,
					short ignore_blank, Str_prt_params *ps_ptr ) ;
short	print_date( OBJECT *form_ptr, short field, int date,
					short ignore_blank, Str_prt_params *ps_ptr ) ;
short	print_int( OBJECT *form_ptr, short field, int number,
					short ignore_blank, Str_prt_params *ps_ptr ) ;
void	printout_strings( char *str1, char *str2, Str_prt_params *ps_ptr ) ;
void	down_n_lines( short n, Str_prt_params *ps_ptr ) ;
short	open_printer( Str_prt_params *ps_ptr ) ;
void	open_gdos_prn( Str_prt_params *ps_ptr, char *metafile_name, short pdev ) ;
void	setup_font( Str_prt_params *ps_ptr, FONTINFO fontinfo ) ;

