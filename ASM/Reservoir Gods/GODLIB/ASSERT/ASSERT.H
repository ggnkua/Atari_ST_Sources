#ifndef	INCLUDED_ASSERT_H
#define	INCLUDED_ASSERT_H

/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	<STRING.H>
#include	<GODLIB\BASE\BASE.H>


/* ###################################################################################
#  VARIABLE PROTOTYPES
################################################################################### */

extern	char gAssertString[ 1024 ];


/* ###################################################################################
#  FUNCTION PROTOTYPES
################################################################################### */



/* ###################################################################################
#  MACROS
################################################################################### */


#if	0
#define	dAssertTXT	

#define Assert( aExpr )\
	((void)((aExpr)||(sprintf( gAssertString, \
	"\nAssertion Failed\n%s\n%s\nLine:%d\n",\
	 #aExpr, __FILE__, __LINE__ ),\
	 ((int (*)(void))Assert_Display)())))

void	Assert_Display( void );
char *	Assert_GetpString( void );

#else

#define	Assert( aExp )
#define	Assert_Display()
#define	Assert_GetpString()	0

#endif


/* ################################################################################ */

#endif	/*	INCLUDED_ASSERT_H	*/