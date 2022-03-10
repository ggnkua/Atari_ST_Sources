
# include "y3.h" 

void warray( s, v, n )
char * s;
int  * v,
       n;

{

  register i;

  fprintf( ftable, "short %s[]={\n", s );
  for ( i = 0; i < n; )
    {
      if ( i % 10 == 0 )
        fprintf( ftable, "\n" );
      fprintf( ftable, "%4d", v[ i ] );
      if ( ++i == n )
        fprintf( ftable, " };\n" );
      else
        fprintf( ftable, "," );
    }
}
