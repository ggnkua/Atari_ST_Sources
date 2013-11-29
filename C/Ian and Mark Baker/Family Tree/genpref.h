/************************************************************************/
/*																		*/
/*		Genpref.h	 6 Jul 97											*/
/*																		*/
/************************************************************************/

/* Header file for GEN containing #DEFINES and							*/
/* prototype definitions												*/


											/* Routines in GENPREF.C	*/
void	load_preferences( void ) ;
void	save_preferences( void ) ;
void	set_preferences( void ) ;
void	read_pref_strings( OBJECT *pref_ptr,
								short *reload, short *idx_size_changed ) ;
void	set_edit_buffer( void ) ;
int		set_save_time( void ) ;
short	save_timer( void ) ;
void	initialise_prn_strs( void ) ;
void	set_printer_strings( void ) ;
void	form_printer_string( char *printer_string, char *text_string ) ;
void	load_prn_config( void ) ;
void	save_prn_config( void ) ;
void	set_config( void ) ;
void	set_prn_config( void ) ;
void	name_flags( void ) ;
void	set_to_qprint( short field ) ;
void	set_to_ignore( short field ) ;
void	set_all_notset( void ) ;
void	set_to_notset( short field ) ;
void	initialise_flag_strings( void ) ;
void	load_custom( void ) ;
void	save_custom( void ) ;
