/************************************************************************/
/*																		*/
/*		Genclip.h	 7 Sep 95											*/
/*																		*/
/************************************************************************/

/* Header file for GENCLIP containing #DEFINES and						*/
/* prototype definitions												*/

											/* Routines in GENCLIP.C	*/
char	*clip_setup( void ) ;
void	clip_clear( char *path ) ;
void	clip_finish( void ) ;
void	write_further_notes_to_clipboard( void ) ;
void	read_further_notes_from_clipboard( void ) ;
void	write_notes_as_text( FILE *fp ) ;
void	write_tree_to_clipboard( void ) ;
void	write_desc_to_clipboard( void ) ;
void	write_window_to_img_file( int wh, char *filename ) ;
void	write_custom_to_clipboard( void ) ;
