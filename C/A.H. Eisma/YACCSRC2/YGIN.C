
# include "y4.h" 

void gin( i )
{

  register * p,
           * r,
           * s,
           * q1,
           * q2;

  /* enter gotos on nonterminal i into array a */

  ggreed[ i ] = 0;

  q2 = mem0 + yypgo[ i + 1 ] - 1;
  q1 = mem0 + yypgo[ i ];

  /* now, find a place for it */

  for ( p = yyact; p < &yyact[ ACTSIZE ]; ++p )
    {
      if ( *p )
        continue ;
      for ( r = q1; r < q2; r += 2 )
        {
          s = p + *r + 1;
          if ( *s )
            goto nextgp;
          if ( s > maxa )
            {
              if ( ( maxa = s ) > &yyact[ ACTSIZE ] )
                error( "yyact array overflow" );
            }
        }
      /* we have found a spot */

      *p       = *q2;
      if ( p > maxa )
        {
          if ( ( maxa = p ) > &yyact[ ACTSIZE ] )
            error( "yyact array overflow" );
        }
      for ( r = q1; r < q2; r += 2 )
        {
          s  = p + *r + 1;
          *s = r[ 1 ];
        }

      pgo[ i ] = p - yyact;
      if ( adb > 1 )
        fprintf( ftable, "Nonterminal %d, entry at %d\n", i, pgo[ i ] );
      goto nextgi;

      nextgp : ;
    }

  error( "cannot place goto %d\n", i );

  nextgi : ;
}
