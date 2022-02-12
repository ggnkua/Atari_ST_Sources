/*
 * Errno defs to be included in *.ss floating point routines, from <errno.h>
 *   -- hyc@hanauma.jpl.nasa.gov, 9-17-92
 */
#define AssemB
#include "errno.h"
#undef  AssemB

	.globl	_errno

Edom	=	EDOM
Erange	=	ERANGE

#ifdef __MBASE__
#define Errno	__MBASE__@(_errno)
#define Stderr	__MBASE__@(__iob+52)
#else
#define Errno	_errno
#define Stderr	__iob+52
#endif

#ifdef __MSHORT__
#define Emove	movew
#else
#define Emove	movel
#endif
