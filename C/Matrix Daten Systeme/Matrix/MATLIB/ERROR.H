/* error.h /4.7.91 / MATRIX /  WA	*/

# ifdef OK
# undef OK
# endif

# define ERRdef(id,text)	id

typedef enum {
# include <errdef.h>

ERRdef ( LASTerror,	"???"											)
} ERROR ;
# undef ERRdef

extern char *error_text[] ;

extern char *get_error_text ( int errn ) ;
extern void print_error ( int errn, const char *s, ... ) ;
