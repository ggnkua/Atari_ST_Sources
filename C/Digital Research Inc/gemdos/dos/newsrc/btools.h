
/*  btools.h - header file for routines which call the block oriented tools */


#define	STRCPY( d , s )		strcpy( d , s )		/* use std.	*/
#define	STRNCPY( d , s , n )	bmove( s , d , n )
#define	STRLEN( s )		blength( s , '\0' )
#define	bzero( s , n ) 		bfill( s , 0 , n )


EXTERN	VOID	bmove() ;
EXTERN	VOID	bfill() ;
EXTERN	BYTE	*bsrch() ;
EXTERN	WORD	blength() ;

