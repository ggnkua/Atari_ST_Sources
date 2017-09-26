/*
*
* Binding fÅr Verwendung von "shared libraries"
*
* Andreas Kromke
* 22.10.97
*
*/

#ifndef LONG
#include <portab.h>
#endif

typedef void *SHARED_LIB;
typedef LONG (*SLB_EXEC)( void , ... );
/*
	das geht leider in PureC nicht, weil PureC hier einen
	Fehler (!!!) hat: cdecl wird ignoriert, wenn die Funktion
	eine variable Anzahl von Parametern hat.

typedef LONG (cdecl *SLB_EXEC)( SHARED_LIB *sl, LONG fn, WORD nargs, ... );
*/

extern LONG Slbopen( char *name, char *path, LONG min_ver,
				SHARED_LIB *sl, SLB_EXEC *fn );
extern LONG Slbclose( SHARED_LIB *sl );
