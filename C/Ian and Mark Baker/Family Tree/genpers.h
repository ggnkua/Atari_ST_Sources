/************************************************************************/
/*																		*/
/*		Genpers.h	28 Dec 97											*/
/*																		*/
/************************************************************************/

/* Header file for GENPERS1 & GENPERS2 containing #DEFINES and			*/
/* prototype definitions												*/

											/* Routines in GENPERS1.C	*/
void	edit_person( int reference ) ;
void	form_wind_title( int pers_ref, int spouse_ref,
				Wind_edit_params *p, short rsrc_title, short rsrc_ititle ) ;
void	cancel_person( void ) ;
void	close_person( void ) ;
void	pers_mu_mesag( const short *message ) ;
void	pers_mu_button( short m_x, short m_y, short breturn ) ;
char	alt2ascii( short kstate ) ;
short	do_sub_form( OBJECT *fm_ptr, char *help_ref, int help_obj, BOOLEAN titled ) ;
void	popup_sex_selector( void ) ;
void	popup_date_qualifier( char* qual_ptr, OBJECT* form_ptr, int field ) ;
void	step_spouse( short step, int reference, GRECT box ) ;
void	slide_children( GRECT *box ) ;
short	page_children( short m_y ) ;
void	step_children( short step, GRECT *box ) ;
void	slide_siblings( GRECT *box ) ;
short	page_siblings( short m_y ) ;
void	step_siblings( short step, GRECT *box ) ;

											/* Routines in GENPERS2.C	*/
Person	*load_person( int reference, short *block ) ;
void	spouse_display( int reference ) ;
void	display_siblings( void ) ;
void	display_children( void ) ;
void	save_person( int reference, short block, Person *pptr ) ;
void	add_to_pidx( int ref, Person *pptr ) ;
void	str_load( char *dest, char *source ) ;
void	str_save( char **dest_ptr, char *source, char **next_ptr,
									char *block_end, short *changed_ptr ) ;
void	save_date( int *dest, char *source, char *qualifier, short *changed_ptr ) ;
short	form_flags( void ) ;
void	set_form_flags( short flags_val ) ;
void	clear_form_flags( void ) ;
void	set_person_form_addrs( void ) ;
void	notes_keys( short kstate, short kreturn ) ;
void	blank_field( OBJECT *obj_ptr, int object, short extent ) ;
short	q_delete_person( int ref ) ;

