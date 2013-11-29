/************************************************************************/
/*																		*/
/*		Genchek.h	 22 Jan 95											*/
/*																		*/
/************************************************************************/

/* Header file for GENCHEK containing #DEFINES and						*/
/* prototype definitions												*/

											/* Routines in GENCHEK.C	*/
void	check_data( void ) ;
short	check_person( int person, char *error_file ) ;
short	check_couple( int couple, char *error_file ) ;
short	coupling_confirmed( int person, int couple ) ;

