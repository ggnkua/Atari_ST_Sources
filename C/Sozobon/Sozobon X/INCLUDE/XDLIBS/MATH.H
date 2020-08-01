#ifndef _MATH_H
#define _MATH_H

/************************************************************************
 *									*
 *				N O T I C E				*
 *									*
 *			Copyright Abandoned, 1987, Fred Fish		*
 *									*
 *	This previously copyrighted work has been placed into the	*
 *	public domain by the author (Fred Fish) and may be freely used	*
 *	for any purpose, private or commercial.  I would appreciate	*
 *	it, as a courtesy, if this notice is left in all copies and	*
 *	derivative works.  Thank you, and enjoy...			*
 *									*
 *	The author makes no warranty of any kind with respect to this	*
 *	product and explicitly disclaims any implied warranties of	*
 *	merchantability or fitness for any particular purpose.		*
 *									*
 ************************************************************************
 */


/*
 *  FILE
 *
 *	math.h    include file for users of portable math library
 *
 *  SYNOPSIS
 *
 *	#include <math.h>
 *
 *  DESCRIPTION
 *
 *	This file should be included in any user compilation module
 *	which accesses routines from the Portable Math Library (PML).
 *
 */


#ifndef _COMPILER_H
#include <compiler.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __TURBOC__

#include <tcmath.h>

#else

#ifndef __STRICT_ANSI__
/*
 *	Create the type "COMPLEX".  This is an obvious extension that I
 *	hope becomes a part of standard C someday.
 *
 */

typedef struct cmplx {			/* Complex structure */
    double real;			/* Real part */
    double imag;			/* Imaginary part */
} COMPLEX;

/* exceptions ++jrb */
typedef enum  {
    DOMAIN      = 1,
    SING        = 2,
    OVERFLOW    = 3,
    UNDERFLOW   = 4,
    TLOSS       = 5,
    PLOSS       = 6
} exception_type;

struct exception {
	exception_type	type;	/* exception type */
	char		*name;	/* function in which it occured */
	double		arg1;	/* an arg */
	double		arg2;	/* another arg */
	double		retval; /* val to return */
};

#define M_LN2                0.69314718055994530942
#define M_PI         3.14159265358979323846
#define M_SQRT2              1.41421356237309504880
#define M_E          2.7182818284590452354
#define M_LOG2E              1.4426950408889634074
#define M_LOG10E     0.43429448190325182765
#define M_LN10               2.30258509299404568402
#define M_PI_2               1.57079632679489661923
#define M_PI_4               0.78539816339744830962
#define M_1_PI               0.31830988618379067154
#define M_2_PI               0.63661977236758134308
#define M_2_SQRTPI   1.12837916709551257390
#define M_SQRT1_2    0.70710678118654752440

#endif /* __STRICT_ANSI__ */

extern const double _infinitydf;	/* in normdf.cpp */


#if defined(_M68881) || defined(__M68881__)
#  include <math-68881.h>
#else
#  define HUGE_VAL  (_infinitydf)
#endif

#define HUGE HUGE_VAL

#ifdef __GNUC__
# ifndef __cplusplus
#  ifndef max
#   define max(x,y) ({typeof(x) _x=(x); typeof(y) _y=(y); if (_x>_y) _y=_x; _y;})
#   define min(x,y) ({typeof(x) _x=(x); typeof(y) _y=(y); if (_x<_y) _y=_x; _y;})
#  endif
# endif
#endif

#if !(defined(_M68881) || defined(__M68881__))
__EXTERN double	acos	__PROTO((double));
__EXTERN double asin	__PROTO((double));
__EXTERN double atan	__PROTO((double));
__EXTERN double atanh	__PROTO((double));
__EXTERN double cos	__PROTO((double));
__EXTERN double cosh	__PROTO((double));
__EXTERN double fabs	__PROTO((double));
__EXTERN double dabs	__PROTO((double));

__EXTERN double exp	__PROTO((double));
__EXTERN double log	__PROTO((double));
__EXTERN double log10	__PROTO((double));
__EXTERN double fmod	__PROTO((double, double));
__EXTERN double sin	__PROTO((double));
__EXTERN double sinh	__PROTO((double));
__EXTERN double sqrt	__PROTO((double));
__EXTERN double hypot   __PROTO((double, double));
__EXTERN double tan	__PROTO((double));
__EXTERN double tanh	__PROTO((double));
__EXTERN double floor	__PROTO((double));
__EXTERN double ceil	__PROTO((double));
__EXTERN double rint	__PROTO((double));

__EXTERN double acosh	__PROTO((double));
__EXTERN double asinh	__PROTO((double));
__EXTERN double atan2	__PROTO((double, double));
__EXTERN double pow	__PROTO((double, double));
#endif

#ifndef __STRICT_ANSI__

#if defined(_M68881) || defined(__M68881__)
#  define dabs(x) fabs(x)
#endif

__EXTERN double copysign	__PROTO((double, double));
__EXTERN int matherr	__PROTO((struct exception *));
__EXTERN double cabs	__PROTO((COMPLEX));
__EXTERN COMPLEX cmult	__PROTO((COMPLEX, COMPLEX));
__EXTERN COMPLEX csqrt	__PROTO((COMPLEX));
#ifndef __GNUG__
__EXTERN COMPLEX clog	__PROTO((COMPLEX));
#endif
__EXTERN COMPLEX cacos	__PROTO((COMPLEX));
__EXTERN COMPLEX cadd	__PROTO((COMPLEX,COMPLEX));
__EXTERN COMPLEX casin	__PROTO((COMPLEX));
__EXTERN COMPLEX catan	__PROTO((COMPLEX));
__EXTERN COMPLEX ccosh	__PROTO((COMPLEX));
__EXTERN COMPLEX crcp	__PROTO((COMPLEX));
__EXTERN COMPLEX csinh	__PROTO((COMPLEX));
__EXTERN COMPLEX ctan	__PROTO((COMPLEX));
__EXTERN COMPLEX ctanh	__PROTO((COMPLEX));
__EXTERN COMPLEX cexp	__PROTO((COMPLEX));
__EXTERN COMPLEX ccos	__PROTO((COMPLEX));
__EXTERN COMPLEX csin	__PROTO((COMPLEX));
__EXTERN COMPLEX cdiv	__PROTO((COMPLEX, COMPLEX));
__EXTERN COMPLEX csubt	__PROTO((COMPLEX,COMPLEX));

__EXTERN int pmlcfs	__PROTO((int, int));
__EXTERN int pmlcnt	__PROTO((void));
__EXTERN int pmlerr	__PROTO((int));
__EXTERN int pmllim	__PROTO((int));
__EXTERN int pmlsfs	__PROTO((int, int));
__EXTERN double poly	__PROTO((int, double *, double));

#endif /* __STRICT_ANSI__ */

#if !(defined(_M68881) || defined(__M68881__))
__EXTERN double modf	__PROTO((double, double *));
__EXTERN double ldexp	__PROTO((double, int));
__EXTERN double frexp	__PROTO((double, int *));
#endif /* !_M68881 */

#endif /* __TURBOC__ */

#ifdef __cplusplus
}
#endif

#endif /* _MATH_H */
