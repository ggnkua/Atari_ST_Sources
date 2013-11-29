/************************************************************************/
/*																		*/
/*		Genrsrc.h	19 Feb 00											*/
/*																		*/
/************************************************************************/

/* Header file for GENRSRC containing #DEFINES and						*/
/* prototype definitions												*/

#define RESOURCE_CHAR_WIDTH 8
#define RESOURCE_CHAR_HEIGHT 8

											/* Routines in GENRSRC.C	*/
void	rescale_resources( void ) ;
void	rescale_tree( int tree ) ;
int		rescale_object( OBJECT *object, int object_number ) ;
short	rescale( int pixels, int charsize, int resource_char_size ) ;
int		restore_menu( OBJECT *object, int object_number ) ;
void	rescale_menu( int tree ) ;
void	set_scroll_colours( void ) ;
