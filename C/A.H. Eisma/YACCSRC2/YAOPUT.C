
# include "y4.h" 

void aoutput( )
{
  /* this version is for C */
  /* write out the optimized parser */

  fprintf( ftable, "# define YYLAST %ld\n", maxa - yyact + 1 );

  arout( "yyact", yyact, ( int )( maxa - yyact ) + 1 );
  arout( "yypact", pa, nstate );
  arout( "yypgo", pgo, nnonter + 1 );

}
