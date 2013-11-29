/************************************************************************/
/*																		*/
/*		Genfoot.h	11 Jul 97											*/
/*																		*/
/************************************************************************/

/* Header file for GENFOOT containing #DEFINES and							*/
/* prototype definitions												*/


typedef struct
{
	BOOLEAN enable ;
	char left[FOOTER_CHARS+1] ;
	char centre[FOOTER_CHARS+1] ;
	char right[FOOTER_CHARS+1] ;

} Footer_line ;

typedef struct
{
	Footer_line line[FOOTER_LINES] ;
} Footers ;

typedef struct
{
	char *l ;
	char *c ;
	char *r ;
} Footer_line_addrs ;


											/* Routines in GENFOOT.C	*/
void	set_footer_addrs( void ) ;
void	set_footers( void ) ;
void	clear_footers( void ) ;
void	copy_form_to_footers( void ) ;
void	copy_footers_to_form( void ) ;
void	use_saved_footers( void ) ;
void	load_saved_footer_param( int param, char *buf_ptr ) ;
void	store_saved_footer_params( FILE *fp ) ;
short	footer_lines( void ) ;
void	print_footer_lines( Str_prt_params *ps_ptr ) ;
void	form_footer_part( char *buffer, const char *template, int ref1, int ref2, short page ) ;
