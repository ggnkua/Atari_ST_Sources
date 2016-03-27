# include <stdio.h>

#define M1(var,const)  (INT32)(((INT16) (var)) * ((INT16) (const)))
#define M2(var,const)  (INT32)(((INT16) (var)) * ((INT32) (const)))
#define M3(var,const)  (INT32)((var) * (const))

typedef long  INT32 ;
typedef short INT16 ;

#define C ((INT32)2446)

void main ( void )
{
	INT16 s ;
	INT32 a, b, c ;
	
	printf ( "\033Estart 1\n" ) ;
	for ( c = 500000L; c > 0; c-- )	
		a = b + M1(s,C);

	printf ( "start 2\n" ) ;
	for ( c = 500000L; c > 0; c-- )	
		a = b + M2(s,C);

	printf ( "end\n" ) ;
}


