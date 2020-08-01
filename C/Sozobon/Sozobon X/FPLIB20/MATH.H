/*
 *	MATH.H		Math function declarations
 */

#ifndef MATH_H
#define	MATH_H

extern	float	sin(), cos(), tan();
extern	float	asin(), acos(), atan(), atan2();
extern	float	exp(), sinh(), cosh(), tanh();
extern	float	log(), log10(), pow();
extern	float	sqrt();
extern	float	ceil(), floor(), fabs();
extern	float	ldexp(), frexp(), modf(), fmod();
extern	float	atof();

/* Some useful constants, generally to 8-9 digits */

#define M_E	2.71828183
#define M_LOG2E	1.44269504
#define M_LOG10E	0.43429448
#define M_LN2	0.69314718
#define M_LN10	2.30258509
#define M_PI	3.14159265
#define M_PI_2	1.570796327
#define M_PI_4	0.785398163
#define M_1_PI	0.318309886
#define M_2_PI	0.636619772
#define M_2_SQRTPI	1.128379167
#define M_SQRT2	1.41421356
#define M_SQRT1_2	0.70710678
/* This is what the compiler should turn into 0xFFFFFF7F... */
#define MAXFLOAT	((float)9.2233715e+18)
#define HUGE	MAXFLOAT

#define _ABS(x)	((x) < 0 ? -(x) : (x))

#endif MATH_H
