/*
 * math.h -- definitions and declarations for mathematics functions.
 *
 * Copyright (c) 1986-1987, Mark Williams Company, Chicago
 * This file and its contents may not be copied or distributed
 * without permission.
 */

/*
 * Definitions used by mathematics functions:
 */
#define HUGE_VAL	1e+37		/* Infinity */
#define L2HUGE_VAL	127.0		/* log2(infinity) */
#define L10P	17			/* log10(precision) */
#define L2L2P	6			/* log2(log2(precision)) */

/*
 * Error return values:
 */
#define EBON	0			/* Successful */
#include <errno.h>

/*
 * Constants:
 */
#define PI		0.31415926535897932e+01
#define SQRT2		0.14142135623730950e+01
#define LOG2B10		0.30102999566398119e+00
#define LOG10BE		0.23025850929940456e+01
#define LOG10B2		0.33219280948873623e+01
#define LOGEB2		0.14426950408889634e+01

/*
 * Complex variables:
 */
typedef struct cpx {
	double	z_r;
	double	z_i;
} CPX;

/*
 * Internal functions:
 */
double	_pol();
double	_two();

/*
 * Function declarations:
 */
double	acos();
double	asin();
double	atan();
double	atan2();
double	atof();
double	cabs();
double	ceil();
double	cos();
double	cosh();
double	exp();
double	fabs();
double	floor();
double	flt();
double	frexp();
double	hypot();
double	j0();
double	j1();
double	jn();
double	ldexp();
double	log();
double	log10();
double	modf();
double	pow();
double	sin();
double	sinh();
double	sqrt();
double	tan();
double	tanh();
double	two();

/* End of math.h */
