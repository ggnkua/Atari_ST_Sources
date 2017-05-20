/*      STDLIB.H

        Standard Library Includes

        Copyright (c) Borland International 1990
        All Rights Reserved.
*/


#if !defined( __STDLIB )
#define __STDLIB


#define EXIT_FAILURE    !0
#define EXIT_SUCCESS    0
#define RAND_MAX        32767


typedef unsigned long   size_t;


typedef struct
{
    int    quot;
    int    rem;
} div_t;

typedef struct
{
    long   quot;
    long   rem;
} ldiv_t;


double  atof( const char *str );
int     atoi( const char *str );
long    atol( const char *str );

char    *ecvt( double d, int ndig, int *dec, int *sign );
char    *fcvt( double d, int ndig, int *dec, int *sign );
char    *gcvt( double value, int dec, char * buf );

char    *itoa( int value, char *string, int radix );
char    *ltoa( long value, char *string, int radix );
char    *ultoa( unsigned long value, char *string, int radix );

void    *malloc( size_t size );
void    *calloc( size_t elt_count, size_t elt_size );
void    free( void *ptr );
void    *realloc( void *ptr, size_t size );

int     abs( int x );
long    labs( long x );
div_t   div( int n, int d );
ldiv_t  ldiv( long n, long d );

int     rand( void );
void    srand( unsigned int seed );
#define random( x ) (rand() % (x))
double  strtod( const char *s, char **endptr );

int     system( const char *command );

void    exit( int status );
void    abort( void );
int     atexit( void (*func)( void ) );

char    *getenv( const char *name );

void    *bsearch( const void *key, const void *base,
          size_t nmemb, size_t size,
          int (*compar)() );
void    qsort( void *base, size_t nmemb, size_t size,
          int (*compar)() );

#endif

/************************************************************************/
