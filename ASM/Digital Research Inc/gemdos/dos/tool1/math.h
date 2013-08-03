/*
	Copyright 1983
	Alcyon Corporation
	8716 Production Ave.
	San Diego, CA  92121

	@(#)math.h	2.1    7/5/84  REGULUS 4.2
*/

/* Declarations of Math Routines */

long atol();
char *ltoa();

double atof();
char *ftoa();		/* float to %f format */
char *etoa();		/* float to scientific notation format */

double sin();
double cos();
double tan();
double atan();

double fabs();
double floor();
double ceil();
double fmod();
double log10();
double log();
double pow();
double sqrt();
double exp();
double modf();
double ldexp();
double frexp();
double atan2();
