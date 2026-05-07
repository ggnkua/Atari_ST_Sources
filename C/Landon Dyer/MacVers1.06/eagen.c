/*
 *  Effective Address code generation
 *	ea0gen()
 *	ea1gen()
 *
 */
#include "as.h"
#include "amode.h"
#include "sect.h"

extern char *range_error;
extern char *abs_error;
extern char *rel_error;


#define	eaNgen	ea0gen
#define	amN	am0
#define	aNexattr a0exattr
#define	aNexval	a0exval
#define	aNexpr	a0expr
#define	aNixreg	a0ixreg
#define	aNixsiz	a0ixsiz
#include "eagen0.c"

#define	eaNgen	ea1gen
#define	amN	am1
#define	aNexattr a1exattr
#define	aNexval	a1exval
#define	aNexpr	a1expr
#define	aNixreg	a1ixreg
#define	aNixsiz	a1ixsiz
#include "eagen0.c"
