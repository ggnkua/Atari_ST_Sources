/************************************************************************/
/*																		*/
/*		Gencsvd.h	 2 Oct 1996											*/
/*																		*/
/************************************************************************/

/* Header file for GENCSVD.C containing #DEFINES and							*/
/* prototype definitions												*/

#define NO_OF_PARAMS 34
#define NO_DISPLAYED 12

#define WARN_SELECTED TRUE

											/* Routines in GENCSVD.C	*/
void	select_csv_params( void ) ;
BOOLEAN	clear_selections( BOOLEAN* selected, short entries ) ;
BOOLEAN	clear_selections_set_one( BOOLEAN* selected, short entries, short selection ) ;
void	add_csv_entry( short index, BOOLEAN warn_already_selected ) ;
void	remove_csv_entry( short index ) ;
void	csv_sooner( void ) ;
void	csv_later( void ) ;
void	update_boxes( short csv_entries, short csv_oset, short param_oset ) ;
void	rubber_band_params( short m_x, short m_y, short oset, short kstate, BOOLEAN field ) ;
void	update_param_list( short param_oset ) ;
void	update_param_box( short param_oset ) ;
BOOLEAN	not_already_listed( short index ) ;
void	set_csv_slider_height( short csv_entries ) ;
void	update_csv_list( short csv_oset ) ;
void	update_csv_box( short csv_oset ) ;
void	update_selections( short param_oset, short csv_oset ) ;
void	write_param_name( char* dest, int param_tag ) ;
void	extract_flag( char* dest, short flag_number ) ;
void	set_csv_format( void ) ;
void	set_csv_fmt_addrs( void ) ;
void	write_csv_format( void ) ;
void	save_csv_format( void ) ;
void	read_csv_format( void ) ;
void	load_csv_file( FILE* fp ) ;
BOOLEAN	load_csv_string( Person* pptr, char** buf_ptr, int param_tag, short block ) ;
BOOLEAN	load_csv_strings( Person* pptr, char** buf_ptr, int param_tag, short block ) ;
short	csv_string_length( int param_tag ) ;
BOOLEAN	copy_csv_string( char* dest_ptr, char** buf_ptr, short limit_length ) ;
BOOLEAN	load_csv_sex( Person* pptr, char** buf_ptr ) ;
BOOLEAN	load_csv_date( Person* pptr, char** buf_ptr, int param_tag ) ;
BOOLEAN	load_csv_flags( Person* pptr, char** buf_ptr, int param_tag ) ;
void	write_csv_transfer_person( int i, FILE* fp ) ;
void	write_csv_reference( FILE* fp, int reference ) ;
void	write_csv_char( FILE* fp, char character ) ;
void	write_csv_date( int date, FILE* fp ) ;
void	check_fputs( char* str, FILE* fp ) ;
