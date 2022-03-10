
# include "y2.h"     
# include <string.h> 

chfind( t, s )
register char * s;

{
  int i;

  # ifdef debug
  fprintf( ftable, "chfind t = %d s = %s ", t, s );
  # endif 

  if ( s[ 0 ] == ' ' )
    t = 0;
  TLOOP( i )
    {
      if ( !strcmp( s, tokset[ i ].name ) )
        {
          # ifdef debug
          fprintf( ftable, "ret = %d\n", i );
          # endif 
          return ( i );
        }
    }
  NTLOOP( i )
    {
      if ( !strcmp( s, nontrst[ i ].name ) )
        {
          # ifdef debug
          fprintf( ftable, "ret = %d\n", i + NTBASE );
          # endif 
          return ( i + NTBASE );
        }
    }
  /* cannot find name */
  if ( t > 1 )
    error( "%s should have been defined earlier", s );
  return ( defin( t, s ) );
}
