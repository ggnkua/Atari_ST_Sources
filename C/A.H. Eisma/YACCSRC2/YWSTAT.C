
# include "y3.h" 

void wrstate( i )
{
  /* writes state i */
  register               j0,
                         j1;
  register struct item * pp,
                       * qq;
  register struct wset * u;

  if ( foutput == NULL )
    return;
  fprintf( foutput, "\nstate %d\n", i );
  ITMLOOP( i, pp, qq )
    {
      fprintf( foutput, "\t%s\n", writem( pp->pitem ) );
    }
  if ( tystate[ i ] == MUSTLOOKAHEAD )
    {
      /* print out empty productions in closure */
      WSLOOP( wsets + ( pstate[ i + 1 ] - pstate[ i ] ), u )
        {
          if ( *( u->pitem ) < 0 )
            fprintf( foutput, "\t%s\n", writem( u->pitem ) );
        }
    }

    /* check for state equal to another */

  TLOOP( j0 )
    if ( ( j1 = temp1[ j0 ] ) != 0 )
      {
        fprintf( foutput, "\n\t%s  ", symnam( j0 ) );
        if ( j1 > 0 )
          {
            /* shift, error, or accept */
            if ( j1 == ACCEPTCODE )
              fprintf( foutput, "accept" );
            else
              if ( j1 == ERRCODE )
                fprintf( foutput, "error" );
              else
                fprintf( foutput, "shift %d", j1 );
          }
        else
          fprintf( foutput, "reduce %d", -j1 );
      }

      /* output the final production */

  if ( lastred )
    fprintf( foutput, "\n\t.  reduce %d\n\n", lastred );
  else
    fprintf( foutput, "\n\t.  error\n\n" );

  /* now, output nonterminal actions */

  j1 = ntokens;
  for ( j0 = 1; j0 <= nnonter; ++j0 )
    {
      if ( temp1[ ++j1 ] )
        fprintf( foutput,
                 "\t%s  goto %d\n",
                 symnam( j0 + NTBASE ),
                 temp1[ j1 ] );
    }

}

void wdef( s, n )
char * s;

{
  /* output a definition of s to the value n */
  fprintf( ftable, "# define %s %d\n", s, n );
}
