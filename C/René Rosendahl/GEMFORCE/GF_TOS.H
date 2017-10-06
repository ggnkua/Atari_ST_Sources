#ifndef __GF_TOS__
# define __GF_TOS__

/************************* prototypes ***********************************/

GLOBAL BOOLEAN copy ( const char *, const char * );
GLOBAL BOOLEAN test_printer ( void );
GLOBAL void lprint ( char *, BOOLEAN );
GLOBAL void supervisor ( BOOLEAN );
GLOBAL void poke ( long, char );
GLOBAL void wpoke ( long, int );
GLOBAL void lpoke ( long, long );
GLOBAL char peek ( long );
GLOBAL int wpeek ( long );
GLOBAL long lpeek ( long );
GLOBAL void cls ( void );
GLOBAL void cursor_on ( void );
GLOBAL void cursor_off ( void );
GLOBAL void at ( int, int );
GLOBAL void print_at ( int, int, const char * );
GLOBAL void tab ( int );
GLOBAL void print_tab ( int, const char * );
GLOBAL BOOLEAN file_exist ( const char * );
GLOBAL BOOLEAN path_exist ( const char * );

#endif