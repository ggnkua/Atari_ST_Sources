   /* external function declarations from assembler functions */
#ifndef MISCASM_H

#define MISCASM_H

#if	I8086

EXTERN	WORD	umul_div(WORD x, WORD y, WORD z);
EXTERN	WORD	mul_div(WORD x, WORD y, WORD z);
EXTERN	VOID	B_MOVE(LONG from, WORD count, LONG to);

#endif

#if MC68K

#include <string.h>

#define umul_div(x, y, z)	(WORD)((LONG)(x) * (LONG)(y) / (LONG)(z))
#define mul_div(x, y, z)	(WORD)((LONG)(x) * (LONG)(y) / (LONG)(z))
#define B_MOVE(s,l,d)	memcpy((void *)(d),(const void *)(s),l)

#endif

#endif
