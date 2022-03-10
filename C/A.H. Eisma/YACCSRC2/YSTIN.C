/*
 * 4-Dec-89 (MvL) Corrected (TC)-bug
 */

# include "y4.h" 

void stin( i )
{
  register * r,
           * s,
             n,
             flag,
             j,
           * q1,
           * q2;

  greed[ i ] = 0;

  /* enter state i into the yyact array */

  q1 = mem0 + yypact[ i ];     /* these two statements switched */
  q2 = mem0 + yypact[ i + 1 ]; /* ----------------------------- */
  /* find an acceptable place */

  for ( n = -maxoff; n < ACTSIZE; ++n )
    {

      flag    = 0;
      for ( r = q1; r < q2; r += 2 )
        {
          if ( ( s = *r + n + yyact ) < yyact )
            goto nextn;
          if ( *s == 0 )
            ++flag;
          else
            if ( *s != r[ 1 ] )
              goto nextn;
        }

      /* check that the position equals another only if the states are identical */

      for ( j = 0; j < nstate; ++j )
        {
          if ( pa[ j ] == n )
            {
              if ( flag )
                goto nextn; /* we have some disagreement */
              if ( yypact[ j + 1 ] + yypact[ i ] == yypact[ j ] +
                   yypact[ i + 1 ] )
                {
                  /* states are equal */
                  pa[ i ] = n;
                  if ( adb > 1 )
                    fprintf( ftable,
                             "State %d: entry at %d equals state %d\n",
                             i,
                             n,
                             j );
                  return;
                }
              goto nextn; /* we have some disagreement */
            }
        }

      for ( r = q1; r < q2; r += 2 )
        {
          if ( ( s = *r + n + yyact ) >= &yyact[ ACTSIZE ] )
            error( "out of space in optimizer a array" );
          if ( s > maxa )
            maxa = s;
          if ( *s != 0 && *s != r[ 1 ] )
            error( "clobber of yyact array, pos'n %d, by %d",
                   s - yyact,
                   r[ 1 ] );
          *s = r[ 1 ];
        }
      pa[ i ] = n;
      if ( adb > 1 )
        fprintf( ftable, "State %d: entry at %d\n", i, pa[ i ] );
      return;

      nextn : ;
    }

  error( "Error; failure to place state %d\n", i );
}
