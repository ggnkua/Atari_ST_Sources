/*  bdos.h - common include file for bdos files				*/


/*
**  system types
*/

/*  ERROR - error return code						*/
#if !defined(ERROR)
typedef	long	ERROR ;
#endif
/*  FH - File Handle							*/
typedef	int	FH ;



/*
**  common externals
*/

EXTERN	ERROR	xopen(),	ixopen() ;
EXTERN	ERROR	xclose(),	ixclose() ;
EXTERN	ERROR	xread(),	ixread() ;
EXTERN	ERROR	xwrite(),	ixwrite() ;
EXTERN	ERROR	xlseek(),	ixlseek() ;


/*
**  compiler defined
*/

#ifndef	COMPILER
#define	ALCYON		1
#define	LATTICE		2

#define	COMPILER	ALCYON
#endif

