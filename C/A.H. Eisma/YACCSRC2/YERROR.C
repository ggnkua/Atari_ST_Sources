
# include "y1.h"     
# include <stdlib.h> 
# include <stdarg.h> 

/*
 * 12-Apr-83 (RBD) Add symbolic exit status
 * 12-Feb-91 (A.H. Eisma) Modified for ANSI-C varargs.
 */

void error( char * s, ... )


{
  va_list argp;

  /* write out error comment */

  ++nerrors;
  fprintf( stderr, "\n fatal error: " );
  va_start( argp, s );
  vfprintf( stderr, s, argp );
  va_end( argp );
  fprintf( stderr, ", line %d\n", lineno );
  if ( !fatfl )
    return;
  summary( );
  exit( EX_ERR );
}
