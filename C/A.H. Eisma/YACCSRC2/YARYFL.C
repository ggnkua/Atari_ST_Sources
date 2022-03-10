
# include "y1.h" 
void aryfil( v, n, c )
int * v,
      n,
      c;
{
  /* set elements 0 through n-1 to c */
  register int i;
  for ( i = 0; i < n; ++i )
    v[ i ] = c;
}
