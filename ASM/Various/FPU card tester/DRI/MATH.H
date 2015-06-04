/**
 *  Copyright 1988
 *  ATARI Corp. Deutschland & K. Ullmann
 *  Frankfurter Str 89 - 91
 * 
 *  6096 Raunheim
 *  W-Germany
 *  
 *  math.h  1.0     15.08.88
**/

/*
 * Konstanten:
 */

#define PI              0.31415926535897932e+01
#define SQRT2           0.14142135623730950e+01
#define LOG2B10         0.30102999566398119e+00
#define LOG10BE         0.23025850929940456e+01
#define LOG10B2         0.33219280948873623e+01
#define LOGEB2          0.14426950408889634e+01


/*
 * Deklaration von mathematischen Routinen
 */

extern long atol();
extern char *ltoa();

extern double atof();
extern char *ftoa();
extern char *etoa();

/*
 * Diese Funktionen laufen Åber den 
 * MC68881 Floating Point Coprocessor
 *
*/

extern double acos();
extern double acosh();
extern double asin();
extern double asinh();
extern double atan();
extern double atan2();
extern double atanh();
extern double cos();
extern double cosh();
extern double exp();
extern double exp10();
extern double exp2();
extern double log();
extern double log10();
extern double log2();
extern double pow();
extern double sin();
extern double sinh();
extern double sqrt();
extern double tan();
extern double tanh();
extern mctest();

/*
 * Setzen und Hohlen von FP-Registern
*/ 
            
extern double fget1();
extern double fget2();
extern double fset1();
extern double fset2();

/*
 * Dies sind alte Funktionen aus der
 * Mathe Bibliothek von DRI
*/

extern double fabs();
extern double floor();
extern double ceil();
extern double fmod();
extern double modf();
extern double ldexp();
extern double frexp();

