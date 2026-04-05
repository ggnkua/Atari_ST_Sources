#include <limits.h>
#include <stdlib.h>
#include "lib.h"

#define ISSPACE(c) ((c) == ' '||(c) == '\t')
#define ISDIGIT(c) ((c) >= '0' && (c) <= '9')

static inline
unsigned long __mul32 (long in, long mul, char *overflow) {
	unsigned long ret;
	__asm__(
	"	clr.l		%0				\n" /* ret = 0									*/
	"	bra		.start		\n"
	".loop:						\n" /* }											*/
	"	lsr.l		#1, %3		\n" /* mul >>= 1								*/
	"	beq		.end			\n" /* if (mul == 0) goto end; 			*/
	
	"	add.l		%2, %2		\n" /* in <<= 1;								*/
	"	bcs		.overfl		\n" /* overflow?	goto overfl;			*/
	".start:						\n"
	"	btst.l	#0, %3		\n" /* if (mul & 0x01) {					*/
	"	beq		.loop			\n"
	"	add.l		%2, %0		\n" /*   ret = ret + in;					*/
	"	bcc		.loop			\n" /*   if(!overflow) goto loop;		*/
	".overfl:					\n"
	"	scs		%1				\n"
	".end:						\n"
	: "=d"(ret), "+g"(*overflow), "+d"(in) ,"+d"(mul)
	);
	return ret;
}

static inline
unsigned long __add32 (long in, long add, char *overflow) {

	__asm__(
	"	add.l		%2, %0		\n"
	"	bcc		.add32_end	\n"
	"	st			%1				\n"
	".add32_end:				\n"
	: "+d"(in), "+g"(*overflow)
	: "g"(add)
	);
	return in;
}

unsigned long __strtoul_internal(const char *nptr, char **endptr, int base, int *sign) {
	long ret = 0L;
	const char *ptr = nptr;
	int val;
	short ret_ok=0;
	char overflow=0;
	
	if(base!=0 && 2 > base && base > 36)
		goto error;

	while(*ptr && ISSPACE(*ptr)) ptr++; /* skip spaces */
	
	if( (*sign = (*ptr == '-')) )
		ptr++;

	if(!*ptr)
		goto error;
	
	if(*ptr == '0') {
		ret_ok = 1;
		switch (*++ptr&~0x20) {
		case 'B':
			if(base != 0 && base != 2) goto error;
			base = 2;
			ptr++;
			break;
		case 'X':
			if(base != 0 && base != 16) goto error;
			base = 16;
			ptr++;
			break;
		default:
			if(base == 0) 
				base = 8;
			break;
		}
	} else if(base == 0)
		base = 10;
	
	for( ;*ptr; ptr++) {
		if(ISDIGIT(*ptr)) 
			val = *ptr - '0';
		else {
			val = 10 + (*ptr&~0x20 /*TOUPPER*/) - 'A';
			if(val < 10) val = 37;  
		}
		ret_ok = 1;
		if(val >= base) break;
		if(!overflow) {
			if(ret)
				ret = __mul32(ret, base, &overflow);
			ret = __add32(ret, val, &overflow);
		}
	}
	if(ret_ok) {
		if(endptr) *endptr = (char*)ptr;
		return overflow ? ULONG_MAX : ret;
	}
error:
	if(endptr) *endptr = (char*)nptr;
	/* TODO set errno */
	return 0LL;
}

