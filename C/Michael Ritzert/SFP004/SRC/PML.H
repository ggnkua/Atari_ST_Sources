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
 *	This file gets included with all of the floating point math
 *	library routines when they are compiled.  Note that
 *	this is the proper place to put machine dependencies
 *	whenever possible.
 *
 *	It should be pointed out that for simplicity's sake, the
 *	environment parameters are defined as floating point constants,
 *	rather than octal or hexadecimal initializations of allocated
 *	storage areas.  This means that the range of allowed numbers
 *	may not exactly match the hardware's capabilities.  For example,
 *	if the maximum positive double precision floating point number
 *	is EXACTLY 1.11...E100 and the constant "MAXDOUBLE is
 *	defined to be 1.11E100 then the numbers between 1.11E100 and
 *	1.11...E100 are considered to be undefined.  For most
 *	applications, this will cause no problems.
 *
 *	An alternate method is to allocate a global static "double" variable,
 *	say "maxdouble", and use a union declaration and initialization
 *	to initialize it with the proper bits for the EXACT maximum value.
 *	This was not done because the only compilers available to the
 *	author did not fully support union initialization features.
 *
 */

#ifndef NO_DBUG
#    include <dbug.h>
#else
#    define DBUG_ENTER(a1)
#    define DBUG_RETURN(a1) return(a1)
#    define DBUG_VOID_RETURN return
#    define DBUG_EXECUTE(keyword,a1)
#    define DBUG_2(keyword,format)
#    define DBUG_3(keyword,format,a1)
#    define DBUG_4(keyword,format,a1,a2)
#    define DBUG_5(keyword,format,a1,a2,a3)
#    define DBUG_PUSH(a1)
#    define DBUG_POP()
#    define DBUG_PROCESS(a1)
#    define DBUG_FILE (stderr)
#    define ENTER(a1)
#    define LEAVE()
#    define DEBUG3(keyword,format,a1)
#    define DEBUG4(keyword,format,a1,a2)
#    define DEBUGPUSH(a)
#    define DEBUGWHO(w)
#endif

#include <errno.h>
extern int errno;

#ifndef atarist
#ifdef ATARI_ST
#include <std.h>
#endif
#endif
/*
 *	MAXDOUBLE	=>	Maximum double precision number
 *	MINDOUBLE	=>	Minimum double precision number
 *	DMAXEXP		=>	Maximum exponent of a double
 *	DMINEXP		=>	Minimum exponent of a double
 */

#define MAXDOUBLE	1.7e+308
#define MINDOUBLE	2.225e-308
#define DMAXEXP		1023
#define DMINEXP		(-1022)

#define LOG2_MAXDOUBLE 1024
#define LOG2_MINDOUBLE (-1023)
#define LOGE_MAXDOUBLE  7.09782712893383970e+02
#define LOGE_MINDOUBLE  -7.09089565712824080e+02

/*
 *	The following are hacks which should be fixed when I understand all
 *	the issues a little better.   |tanh(TANH_MAXARG)| = 1.0
 */
#define TANH_MAXARG 16
#define SQRT_MAXDOUBLE 1.304380e19

#define PI		3.14159265358979323846
#define TWOPI 		6.28318530717958620
#define HALFPI		1.57079632679489660
#define FOURTHPI	0.785398163397448280
#define SIXTHPI		0.523598775598298820

#define LOG2E		1.4426950408889634074	/* Log to base 2 of e */
#define LOG10E		0.4342944819032518276
#define SQRT2		1.41421356237309504880
#define SQRT3		1.7320508075688772935
#define LN2		0.69314718055994530942
#define LNSQRT2		0.3465735902799726547


/*
 *	MC68000 HARDWARE DEPENDENCIES
 *
 *		cc -DIEEE	=>	uses IEEE floating point format
 *
 */

#ifdef IEEE
#define X6_UNDERFLOWS (4.209340e-52)	/* X**6 almost underflows */
#define X16_UNDERFLOWS (5.421010e-20)	/* X**16 almost underflows	*/
#endif

#ifdef TRUE
#undef TRUE
#endif

#ifdef FALSE
#undef FALSE
#endif

#define TRUE 1
#define FALSE 0
#define VOID void

#if ((defined(__STDC__)) && (!defined(__NO_PROTO__)))
double modf(double, double *);
double ldexp(double, int);

/* mjr: i don't undestand this...
 #ifdef __MSHORT__
 double frexp(double, short *);
 #else
 double frexp(double, int *);
 #endif
*/
 double frexp(double, int *);

#else

extern double modf(/* double, double * */);
extern double ldexp(/* double, int  */);
extern double frexp(/* double, int * */);

#endif /* __STDC__ */
