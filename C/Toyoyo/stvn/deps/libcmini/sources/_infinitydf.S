#include "libc-symbols.h"

	.text
	.even

	.globl	C_SYMBOL_NAME(_infinitydf)

C_SYMBOL_NAME(_infinitydf):			| +infinity as proposed by IEEE
	.long	0x7ff00000,0x00000000
