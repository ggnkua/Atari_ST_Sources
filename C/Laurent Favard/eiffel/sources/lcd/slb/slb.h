/*
*
* Binding for the use of "shared libraries"
*
* Andreas Kromke
* 22.10.97
* Last change 19.2.99  - SLB_EXEC with cdecl corrected
*
*/

#ifndef LONG
#include <portab.h>
#endif

typedef void *SHARED_LIB;

typedef LONG cdecl (*SLB_EXEC)( SHARED_LIB *sl, LONG fn, WORD nargs, ... );

extern LONG Slbopen( char *name, char *path, LONG min_ver,
				SHARED_LIB *sl, SLB_EXEC *fn );
extern LONG Slbclose( SHARED_LIB *sl );
