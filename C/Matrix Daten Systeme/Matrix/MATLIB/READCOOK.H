typedef struct
{
	char	name[4] ;
	ulong	value ;
} COOKIE ;

extern COOKIE *read_cookie ( char *name, long *value ) ;
