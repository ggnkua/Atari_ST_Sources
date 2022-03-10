/* Edits:
 *      06-Dec-80 Original code broken out of y1.c.
 *      18-Dec-80 Add conditional code for Decus for tempfile deletion.
 *      26-Apr-91 Changed function ungetc to yacc_ungetc because of
 *                conflict with Turbo-C macro for ungetc
 */

# include "y1.h" 

void others( )
{
  /* put out other arrays, copy the parsers */
  register c,
           i,
           j;

  finput = fopen( PARSER, "r" );
  if ( finput == NULL )
    error( "cannot find parser %s", PARSER );

  warray( "yyr1", levprd, nprod );

  aryfil( temp1, nprod, 0 );
  PLOOP( 1, i )
    temp1[ i ] = prdptr[ i + 1 ] - prdptr[ i ] - 2;
  warray( "yyr2", temp1, nprod );

  aryfil( temp1, nstate, -1000 );
  TLOOP( i )
    {
      for ( j = tstates[ i ]; j != 0; j = mstates[ j ] )
        {
          temp1[ j ] = tokset[ i ].value;
        }
    }
  NTLOOP( i )
    {
      for ( j = ntstates[ i ]; j != 0; j = mstates[ j ] )
        {
          temp1[ j ] = -i;
        }
    }
  warray( "yychk", temp1, nstate );

  warray( "yydef", defact, nstate );

  /* copy parser text */

  while ( ( c = unix_getc( finput ) ) != EOF )
    {
      if ( c == '$' )
        {
          if ( ( c = unix_getc( finput ) ) != 'A' )
            putc( '$', ftable );
          else
            {
              /* copy actions */
              faction = fopen( ACTNAME, "r" );
              if ( faction == NULL )
                error( "cannot reopen action tempfile" );
              while ( ( c = unix_getc( faction ) ) != EOF )
                putc( c, ftable );
              fclose( faction );
              ZAPFILE( ACTNAME );
              c       = unix_getc( finput );
            }
        }
      putc( c, ftable );
    }

  fclose( ftable );
}

static char getbuf[ 30 ],
          * getbufptr = getbuf;

int unix_getc( iop )
FILE * iop;
{
  if ( getbufptr == getbuf )
    return ( getc( iop ) );
  else
    return ( *--getbufptr );
}

int yacc_ungetc( int c )
{
  return ( *getbufptr++ = c );
}
