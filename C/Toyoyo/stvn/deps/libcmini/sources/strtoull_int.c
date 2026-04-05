#include <limits.h>
#include <stdlib.h>
#include "lib.h"

# ifndef LLONG_MIN
#  define LLONG_MIN	(-LLONG_MAX-1)
# endif
# ifndef LLONG_MAX
#  define LLONG_MAX	__LONG_LONG_MAX__
# endif
# ifndef ULLONG_MAX
#  define ULLONG_MAX	(LLONG_MAX * 2ULL + 1)
# endif


#define ISSPACE(c) ((c) == ' '||(c) == '\t')
#define ISDIGIT(c) ((c) >= '0' && (c) <= '9')

static inline
unsigned long long __mul64 (long long in, long mul, char *overflow) {
	unsigned long ret_lo;
	unsigned long ret_hi;

	unsigned long in_lo=in&0xffffffffUL, in_hi=in>>32;
	__asm__(
	"	clr.l		%0				\n" /* ret_lo = 0								*/
	"	clr.l		%1				\n" /* ret_hi = 0								*/
	"	bra		.start		\n"
	".loop:						\n" /* }											*/
	"	lsr.l		#1, %5		\n" /* mul >>= 1								*/
	"	beq		.end			\n" /* if (mul == 0) goto end; 			*/
	
	"	add.l		%3, %3		\n" /* in <<= 1;								*/
	"	addx.l	%4, %4		\n"
	"	bcs		.overfl		\n" /* overflow?	goto overfl;			*/
	".start:						\n"
	"	btst.l	#0, %5		\n" /* if (mul & 0x01) {					*/
	"	beq		.loop			\n"
	"	add.l		%3, %0		\n" /*   ret = ret + in;					*/
	"	addx.l	%4, %1		\n"
	"	bcc		.loop			\n" /*   if(!overflow) goto loop;		*/
	".overfl:					\n"
	"	scs		%2				\n"
	".end:						\n"
	: "=d"(ret_lo), "=d"(ret_hi),"+g"(*overflow), "+d"(in_lo), "+d"(in_hi),"+d"(mul)
	);
	return (unsigned long long)ret_hi<<32 | ret_lo;
}

static inline
unsigned long long __add64 (long long in, long add, char *overflow) {

	unsigned long lo=in&0xffffffffUL, hi=in>>32;
	unsigned long zero=0;
	__asm__(
	"	add.l		%3, %0		\n"
	"	addx.l	%4, %1		\n"
	"	bcc		1f	\n"
	"	st			%2				\n"
	"1:				\n"
	: "+d"(lo), "+d"(hi),"+g"(*overflow)
	: "g"(add), "d"(zero)
	);
	return (unsigned long long)hi<<32 | lo;
}

unsigned long long __strtoull_internal(const char *nptr, char **endptr, int base, int *sign) {
	long long ret = 0LL;
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
		ptr++;
		switch (*ptr&~0x20) {
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
				ret = __mul64(ret, base, &overflow);
			ret = __add64(ret, val, &overflow);
		}
	}
	if(ret_ok) {
		if(endptr) *endptr = (char*)ptr;
		return overflow ? ULLONG_MAX : ret;
	}
error:
	if(endptr) *endptr = (char*)nptr;
	/* TODO set errno */
	return 0LL;
}

