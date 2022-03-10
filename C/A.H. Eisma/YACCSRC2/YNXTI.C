
# include "y4.h" 

nxti( )
{
  /* finds the next i */
  register i,
           max,
           maxi;

  max = 0;

  for ( i = 1; i <= nnonter; ++i )
    if ( ggreed[ i ] >= max )
      {
        max  = ggreed[ i ];
        maxi = -i;
      }

  for ( i = 0; i < nstate; ++i )
    if ( greed[ i ] >= max )
      {
        max  = greed[ i ];
        maxi = i;
      }

  if ( nxdb )
    fprintf( ftable, "nxti = %d, max = %d\n", maxi, max );
  if ( max == 0 )
    return ( NOMORE );
  else
    return ( maxi );
}
