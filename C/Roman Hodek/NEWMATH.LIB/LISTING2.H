/* NEWMATH.H
   (c) 1992 MAXON Computer
   Headerdatei fÅr die FPU-Bibliothek
   NEWMATH.LIB 
        
   énderungen gegenÅber dem alten MATH.H:
   - ftoa ersetzt durch [fs]printfl
   - andere Fehlerbehandlung : fclrerr, ferr
   - neue Fkt.: sincos, log2, exp10, exp2
   - ftest zum Testen von Unendlich und NAN's       
   - fpumode jetzt zum Setzen von Rechen-
     genauigkeit und Rundungsmodus
*/


#if !defined( __MATH )
#define __MATH

#define HUGE_VAL    1.189731495357231765E+4932

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

int     printfl( double x );
int     fprintfl( FILE *file, double x );
int     sprintfl( char *str, double x );

double  fabs( double x );
double  ceil( double x );
double  floor( double x );
double  round( double x );
double  trunc( double x );
double  fmod( double x, double y );

double  exp( double x );
double  exp10( double x );
double  exp2( double x );
double  log( double x );
double  log10( double x );
double  log2( double x );

double  frexp( double x, int *nptr );
double  ldexp( double x, int n );
double  modf( double x, double *nptr );

double  pow( double x, double y );
double  pow10( int i );
double  sqrt( double x );

double  cos( double x );
double  sin( double x );
double  tan( double x );
double  sincos( double x, double *c );

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

double  atof( const char *digStr );

int     ftest( double x );
void    fclrerr( void );
int     ferr( void );

/* RÅckgabewerte von ferr() */

#define E_INEXACT   1
#define E_SING      2
#define E_OVERFLOW  4
#define E_UNDERFLOW 8
#define E_DOMAIN    16

void    fpumode( int prec, int round );

/* PrÑzisionen fÅr fpumode() */

#define P_EXTENDED 0
#define P_SINGLE   1
#define P_DOUBLE   2

/* Rundungsmodi fÅr fpumode() */

#define RM_NEAREST 0
#define RM_ZERO    1
#define RM_MIFTY   2
#define RM_PIFTY   3

#endif
