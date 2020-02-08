/* xbra.h	/	22.8.91	/	MATRIX	/	WA	*/

typedef struct
{
	char magic[4] ;
	char id[4] ;
	PROC *oldvec ;
} XBRAstruct ;

extern void link_axbra ( XBRAstruct *xbra, PROC **pexcserv, char *ids ) ;
extern void link_xbra ( XBRAstruct *xbra, int number, char *ids ) ;
extern PROC **find_paxbra ( PROC **pexcserv, char *ids ) ;
extern PROC **find_pxbra ( int number, char *ids ) ;
extern bool unlink_xbra ( int number, char *ids ) ;
extern void print_xbra ( char *deli, XBRAstruct *xbra ) ;
extern void list_xbra ( int number, bool priall ) ;
