/*      ASSERT.H

        Diagnostic Includes

        Copyright (c) Borland International 1990
        All Rights Reserved.
*/



#if !defined( __ASSERT )
#define __ASSERT

#if !defined(NDEBUG)

#if     !defined(__STDLIB)
#include <stdlib.h>
#endif

#if     !defined( __STDIO )
#include <stdio.h>
#endif

#define assert( expr )\
	((void)((expr)||(fprintf( stderr, \
	"\nAssertion failed: %s, file %s, line %d\n",\
	 #expr, __FILE__, __LINE__ ),\
	 ((int (*)(void))abort)())))
#else

#define assert( expr )

#endif


#endif

/************************************************************************/
