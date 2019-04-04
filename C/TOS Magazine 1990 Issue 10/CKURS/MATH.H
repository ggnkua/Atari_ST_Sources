/*      MATH.H

        Mathematical Definition Includes

        Copyright (c) Borland International 1988
        All Rights Reserved.
*/


#if !defined( __MATH )
#define __MATH

#define HUGE_VAL    1.189731495357231765E+4932

#define M_E	    	2.71828182845904523536
#define M_LOG2E		1.44269504088896340736
#define M_LOG10E	0.434294481903251827651
#define M_LN2		0.693147180559945309417
#define M_LN10		2.30258509299404568402
#define M_PI		3.14159265358979323846
#define M_PI_2		1.57079632679489661923
#define M_PI_4		0.785398163397448309116
#define M_1_PI		0.318309886183790671538
#define M_2_PI		0.636619772367581343076
#define M_1_SQRTPI	0.564189583547756286948
#define M_2_SQRTPI	1.12837916709551257390
#define M_SQRT2		1.41421356237309504880
#define M_SQRT_2	0.707106781186547524401

double  fabs( double x );
double  ceil( double x );
double  floor( double x );
double  round( double x );
double  trunc( double x );
double  fmod( double x, double y );

double  cos( double x );
double  sin( double x );
double  tan( double x );

double  frexp( double x, int *nptr );
double  ldexp( double x, int n );
double  modf( double x, double *nptr );



int 	ftoa( double *x, char *resStr, int ndig, int format,
              int *decPnt, int *sign );

double  atof( const char *digStr );


typedef enum
{
         DOMAIN = 1,    /* argument domain error -- log (-1)      */
         SING,          /* argument singularity  -- pow (0,-2))   */
         OVERFLOW,      /* overflow range error  -- exp (1000)    */
         UNDERFLOW      /* underflow range error -- exp (-1000)   */
} mexcep;

struct exception
{
    mexcep      type;
    char        *name;
    double      arg1;
    double      arg2;
    double      retval;
};


void    setmatherr( int (*errorfunc)( struct exception *e ) );
int     fpumode( int disable );
void    xdcnv( double *val, void *rep8bytes );
void    dxcnv( void *rep8bytes, double *val );


#endif

/************************************************************************/
