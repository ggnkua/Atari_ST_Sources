/* Common definitions for FPLIB						*/
/* Copyright ½ David Brooks, 1989 All Rights Reserved			*/
 
#ifndef	MATH_H
#include <math.h>		/* Now they're all defined */
#endif

/* Some facts about the representation					*/

#define BIAS		0x40
#define MANT_BITS	24
#define EXP_MASK	0x7F
#define HUGE_AS_INT	0xFFFFFF7F

/* Redefine a 32-bit float number.  Can initialize with unsigned long.	*/

typedef union {
	unsigned long ul;
	float f;
	char sc[4];			/* Assuming char signed */
	} fstruct;
