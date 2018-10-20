/*      MATH.H

        Mathematical Definition Includes

        Copyright (c) Borland International 1990
        All Rights Reserved.
*/


#if !defined( __MATH )
#define __MATH

#define HUGE_VAL        1.189731495357231765E+4932

#define M_E             2.71828182845904523536
#define M_LOG2E         1.44269504088896340736
#define M_LOG10E        0.434294481903251827651
#define M_LN2           0.693147180559945309417
#define M_LN10          2.30258509299404568402
#define M_PI            3.14159265358979323846
#define M_PI_2          1.57079632679489661923
#define M_PI_4          0.785398163397448309116
#define M_1_PI          0.318309886183790671538
#define M_2_PI          0.636619772367581343076
#define M_1_SQRTPI      0.564189583547756286948
#define M_2_SQRTPI      1.12837916709551257390
#define M_SQRT2         1.41421356237309504880
#define M_SQRT_2        0.707106781186547524401

double  fabs( double x );
double  ceil( double x );
double  floor( double x );
double  round( double x );
double  trunc( double x );

double  fmod( double x, double y );
double  exp( double x );
double  log( double x );
double  log10( double x );

double  frexp( double x, int *nptr );
double  ldexp( double x, int n );
double  modf( double x, double *nptr );

double  pow( double x, double y );
double  pow10( int i );
double  sqrt( double x );

double  cos( double x );
double  sin( double x );
double  tan( double x );
void    sincos( double x, double *sin, double *cos );

double  acos( double x );
double  asin( double x );
double  atan( double x );
double  atan2( double x, double y );
double  cosh( double x );
double  sinh( double x );
double  tanh( double x );

double  acosh( double x );
double  asinh( double x );
double  atanh( double x );

int     ftoa( double *x, char *resStr, int ndig, int format,
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

#if defined( __68881__ )
double  fint( double x );
double  fintrz( double x );
double  fgetexp( double x );
double  fgetman( double x );
double  frem( double x, double y );
double  fsgldiv( double x, double y );
double  fsglmul( double x, double y );
double  fetoxm1( double x );
double  flognp1( double x );
double  pow2( double x );
#endif

#if defined( __68881__ ) && !defined( __NFPUIN__ )
                                              /* MC68881 extensions */
/* Arithmetische Befehle: */
#define trunc( x )      __FINTRZ__( x )
#define fabs( x )       __FABS__( x )
#define fgetexp( x )    __FGETEXP__( x )
#define fgetman( x )    __FGETMAN__( x )
#define fint( x )       __FINT__( x )
#define fintrz( x )     __FINTRZ__( x )
#define fmod( x, y )    __FMOD__( y, x )
#define frem( x, y )    __FREM__( y, x )
#define ldexp( x, y )   __FSCALE__( y, x )
#define fsgldiv( x, y ) __FSGLDIV__( y, x )
#define fsglmul( x, y ) __FSGLMUL__( y, x )

/* Potenzen und Logarithmen: */
#define exp( x )        __FETOX__( x )
#define fetoxm1( x )    __FETOXM1__( x )
#define log( x )        __FLOGN__( x )
#define flognp1( x )    __FLOGNP1__( x )
#define log10( x )      __FLOG10__( x )
#define log2( x )       __FLOG2__( x )
#define sqrt( x )       __FSQRT__( x )
#define pow10( x )      __FTENTOX__( x )
#define pow2( x )       __FTWOTOX__( x )

/* Trigonometrie: */
#define acos( x )       __FACOS__( x )
#define asin( x )       __FASIN__( x )
#define atan( x )       __FATAN__( x )
#define cos( x )        __FCOS__( x )
#define sin( x )        __FSIN__( x )
#define tan( x )        __FTAN__( x )

/* Hyperbelfunktionen: */
#define atanh( x )      __FATANH__( x )
#define cosh( x )       __FCOSH__( x )
#define sinh( x )       __FSINH__( x )
#define tanh( x )       __FTANH__( x )

/* Conversionsfunktionen nur fÅr TC881LIB.LIB */
double x80x96cnv( void *rep10bytes );
void   x96x80cnv( double rep12bytes, void *rep10bytes );

#endif

#endif

/************************************************************************/
