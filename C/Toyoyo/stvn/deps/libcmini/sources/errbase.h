/*
 * Errno defs to be included in *.ss floating point routines, from <errno.h>
 *   -- hyc@hanauma.jpl.nasa.gov, 9-17-92
 */

#include "errno.h"

	.globl	C_SYMBOL_NAME(errno)

Edom	= EDOM
Erange	= ERANGE

#define Errno	C_SYMBOL_NAME(errno)
#define Stderr	C_SYMBOL_NAME(stderr)

#ifdef __MSHORT__
#define Emove	movew
#else
#define Emove	movel
#endif
