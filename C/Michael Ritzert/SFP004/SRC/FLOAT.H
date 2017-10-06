/*
 * float.h
 *	see sec 2.2.4.2 and 4.1.3 of ansi draft
 *
 *	this implementation strives to meet these values, but actually
 *	does'nt quite make it, so we lie
 *	i need help here!
 *		++jrb
 */
#ifndef _FLOAT_H
#define _FLOAT_H

/* float.h */
/* hacked by mjr according to K&R (ansi draft), 11.5.91 */

   /* Radix of exponent representation */
#define FLT_RADIX 2
   /* Number of base-FLT_RADIX digits in the mantissa of a float */
#define FLT_MANT_DIG 23 /* mjr was 24 */
   /* Number of decimal digits of precision in a float */
#define FLT_DIG 6
   /* Addition rounds to 0: zero, 1: nearest, 2: +inf, 3: -inf, -1: unknown */
#define FLT_ROUNDS 1
   /* Minimum float x such that 1.0+x != 1.0 */
#define FLT_EPSILON 1.0e-6
   /* Minimum int x such that FLT_RADIX**(x-1) is a normalised float */
#define FLT_MIN_EXP (-125)
   /* Minimum normalised float */
#define FLT_MIN 1.0e-37F
   /* Minimum int x such that 10**x is a normalised float */
#define FLT_MIN_10_EXP (-37)
   /* Maximum int x such that FLT_RADIX**(x-1) is a representable float */
#define FLT_MAX_EXP 127
   /* Maximum float */
#define FLT_MAX 1.0e+37F
   /* Maximum int x such that 10**x is a representable float */
#define FLT_MAX_10_EXP 37

   /* Number of base-FLT_RADIX digits in the mantissa of a double */
/* #define DBL_MANT_DIG 53 mjr: */
#define DBL_MANT_DIG 52
   /* Number of decimal digits of precision in a double */
#define DBL_DIG 15
   /* Minimum double x such that 1.0+x != 1.0 */
#define DBL_EPSILON 1.0e-15
   /* Minimum int x such that FLT_RADIX**(x-1) is a normalised double */
#define DBL_MIN_EXP (-1021)
   /* Minimum normalised double */
#define DBL_MIN 7.3e-304
   /* Minimum int x such that 10**x is a normalised double */
#define DBL_MIN_10_EXP (-304)
   /* Maximum int x such that FLT_RADIX**(x-1) is a representable double */
#define DBL_MAX_EXP 1022 /* mjr was 1024 */
   /* Maximum double */
#define DBL_MAX 1.79e+304
   /* Maximum int x such that 10**x is a representable double */
#define DBL_MAX_10_EXP 304

   /* Number of base-FLT_RADIX digits in the mantissa of a long double */
#define LDBL_MANT_DIG 52 /* mjr was 53 */
   /* Number of decimal digits of precision in a long double */
#define LDBL_DIG 15
   /* Minimum long double x such that 1.0+x != 1.0 */
#define LDBL_EPSILON 1.0e-15L
   /* Minimum int x such that FLT_RADIX**(x-1) is a normalised long double */
#define LDBL_MIN_EXP (-1021)
   /* Minimum normalised long double */
#define LDBL_MIN 7.3e-304L
   /* Minimum int x such that 10**x is a normalised long double */
#define LDBL_MIN_10_EXP (-304)
   /* Maximum int x such that FLT_RADIX**(x-1) is a representable long double */
#define LDBL_MAX_EXP 1022
   /* Maximum long double */
#define LDBL_MAX 1.79e+304L
   /* Maximum int x such that 10**x is a representable long double */
#define LDBL_MAX_10_EXP 304


#endif /* _FLOAT_H */
