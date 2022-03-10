
# include "y4.h" 

/*
 * Write summary.
 */

void osummary( )


{
  register int i,
             * p;

  if ( foutput == NULL )
    return;

  i = 0;
  for ( p = maxa; p >= yyact; --p )

    {
      if ( *p == 0 )
        ++i;
    }
  fprintf( foutput,
           "Optimizer space used: input %d/%d, output %d/%d\n",
           pmem - mem0 + 1,
           MEMSIZE,
           maxa - yyact + 1,
           ACTSIZE );
  fprintf( foutput,
           "%d table entries, %d zero\n",
           ( maxa - yyact ) + 1,
           i );
  fprintf( foutput,
           "maximum spread: %d, maximum offset: %d\n",
           maxspr,
           maxoff );
  fclose( foutput );
}
