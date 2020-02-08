/* error.c / 8.7.91 / MATRIX / WA	*/

# include <stdio.h>

# include "error.h"

# define ERRdef(id,text)	text

extern char *error_text[LASTerror+1] =
{
# include "errdef.h"
ERRdef ( LASTerror,	"???" )
} ;

# if sizeof(error_text) != ((LASTerror+1) * sizeof(char *))
??? error text table ???
# endif

/*--------------------------------------------- get_error_text -----*/
char *get_error_text ( int errn )
{
	return ( error_text
		[ errn >= OK && errn < LASTerror ? errn : LASTerror ] ) ;
}

/*--------------------------------------------- print_error --------*/
void print_error ( int errn, const char *s, ... )
{
	printf ( "* " ERRor " # %d : %s", errn, get_error_text ( errn ) ) ;
	vprintf ( s, ... ) ;
}
