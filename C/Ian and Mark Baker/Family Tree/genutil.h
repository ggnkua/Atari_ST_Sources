/************************************************************************/
/*																		*/
/*		Genutil.h	25 Mar 2000											*/
/*																		*/
/************************************************************************/

/* Header file for GEN containing #DEFINES and							*/
/* prototype definitions												*/

#define BUSY_DEFEAT 0				/* values for busy(), force off		*/
#define BUSY_RESTORE 1				/* restore business					*/
#define BUSY_MORE 2					/* get busier						*/
#define BUSY_LESS 3					/* get less busy					*/
#define BUSY_BLANK 4				/* blank mouse (for drawing)		*/
#define NO_STRING -1				/* used for not titling windows		*/

#define MODAL_EVENTS  ( MU_KEYBD | MU_BUTTON | MU_MESAG )
#define MODAL_EVENTS_WITH_TIME ( MODAL_EVENTS | MU_TIMER )

#define LEADING 1
#define TRAILING 2
#define SURROUNDING 3

#define DATE_QUALIFY_BITS 0x600000
#define CIRCA_CODE 0x200000
#define BEFORE_CODE 0x400000
#define AFTER_CODE 0x600000

#define TITLED TRUE
#define UNTITLED FALSE


											/* Routines in GENUTIL.C	*/
void*	pmalloc( size_t n ) ;
void	send_redraw_message( const GRECT *rect, int window_handle ) ;
void	redraw_all_windows( void ) ;
short	top_window( void ) ;
short	find_window( int x, int y ) ;
void	rubber_band( int vdi_handle,  short* new_m_x, short* new_m_y, short m_x, short m_y, short line_type ) ;
void	grect2pxy( const GRECT *gr_ptr, short *pxy_ptr ) ;
short	rect_end( GRECT* rect_ptr ) ;
short	rect_bottom( GRECT* rect_ptr ) ;
void	scroll_line( GRECT scroll_text_box, short text_lines,
								short direction, short scroll_text_size ) ;
void	extract_string( OBJECT *form_ptr, short field, char *buffer ) ;
void	form_names( int ref, char *buffer, short chmax,
												short use_full_forename ) ;
void	shorten_names( char *buffer, short length ) ;
void	names_ref( int ref, char *names, short chmax,
												short use_full_forename ) ;
void	form_date( char *date_str, char* qualifier, int date, short padflag ) ;
BOOLEAN	form_todays_date( char* buffer ) ;
void	names_date( int ref, char *names, short padto,
												short use_full_forename ) ;
void	names_dates( int ref, char *names, short padto,
												short use_full_forename ) ;
void	names_only( int ref, char *names, short chmax,
												short use_full_forename ) ;
short	fsel_geninput( char *pathfile, const char *dflt_file, short *button,
															short field ) ;
void	init_form( Wind_edit_params *ed_params, short index, short string_field,
													const char *help_string ) ;
void	wind_form_do( Wind_edit_params *ed_params, short start_obj ) ;
int		move_slide( OBJECT *tree, int slider, int slide_range, const GRECT *box ) ;
void	set_slide( int value, int range,
				OBJECT *tree, int slider, int slide_range, GRECT *box ) ;
int		isalpha_accented( int c ) ;
void	tidy_spaces( char *string ) ;
void	remove_surrounding_spaces( char *string, short position ) ;
void	form_mu_mesag( const short *message, Wind_edit_params *ed_params ) ;
void	form_mu_button( short m_x, short m_y, Wind_edit_params *ed_params ) ;
void	change_edit_object( Wind_edit_params *form_ed_params, short event ) ;
short	find_cursor_posn( Wind_edit_params *form_ed_params ) ;
void	form_redraw( const short *message, Wind_edit_params *form_ed_params ) ;
int		f_redraw( int handle, const GRECT *rect ) ;
void	close_form_window( Wind_edit_params *p ) ;
char	*get_next_slice( char *buffer, char **str_ptr, Str_prt_params *ps_ptr,
									short slice_length ) ;
char	get_previous_char( char **str_ptr, char *tail_ptr, char *insert_ptr ) ;
char	get_next_char( char **str_ptr, char *tail_ptr ) ;
char	get_next_char_with_properties( char **str_ptr, char *tail_ptr, char *property ) ;
char	*get_next_slice_with_properties( char *buffer, char **str_ptr, char *tail_ptr,
						Str_prt_params *ps_ptr, short *curs_x,
						char *property, char *properties, short slice_length ) ;
void	v_gtext_with_properties( int handle, int x, int y, const char *str, const char *properties ) ;
short	line_fits( char *line, Str_prt_params *ps_ptr ) ;
void	iconify_all( int x ) ;
void	uniconify_all( void ) ;
void	group_icon_mesag( const short *message ) ;
int		group_icon_redraw( int wh, const GRECT *area ) ;
BOOLEAN	app_modal_init( OBJECT *tree, const char *help_ref, BOOLEAN titled ) ;
int		app_modal_do( void ) ;
void	app_modal_first_draw( void ) ;
int		app_modal_button_check( int object ) ;
void	app_modal_end( void ) ;
GRECT	*app_modal_box( void ) ;
short	app_modal_edit_obj( short new_edit_obj ) ;
void	popup_menu( MENU *in, int x, int y, MENU *out ) ;
void	set_wind_title( int pers_ref, int spouse_ref,
				Wind_edit_params *p, short rsrc_title, short rsrc_ititle ) ;
void	help( const char *subject ) ;
void	v_attrs( int handle, short flag ) ;
char	get_date_qualifier( void ) ;
void	save_default_char( char* param_str, char param, FILE* fp ) ;
void	save_yes_no_param( char* param_str, BOOLEAN yes, FILE* fp ) ;
void	v_box( int handle, const short pxy[4] ) ;
int __stdargs __saveds draw_check( PARMBLK *parms ) ;
int __stdargs __saveds draw_radio( PARMBLK *parms ) ;
void	busy( short get_busier ) ;
void	*checked_malloc( size_t amount ) ;
int		rsrc_form_alert( int deflt, int index ) ;
int		rsrc_form_alert_with_text( int deflt, int index, char* text ) ;
void	report( const int event ) ;
void	box_report( const GRECT *box_ptr ) ;
void	str_report( const char *str ) ;
void	freport( const int value ) ;
void	fstr_report( const char *string ) ;
void	stk_report( void ) ;
