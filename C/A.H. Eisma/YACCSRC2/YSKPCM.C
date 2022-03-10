
# include "y2.h" 

int skipcom( )
{
  /* skip over comments */
  register c,
           i; /* i is the number of lines skipped */
  i = 0; /*01*/
  /* skipcom is called after reading a / */

  if ( unix_getc( finput ) != '*' )
    error( "illegal comment" );
  c = unix_getc( finput );
  while ( c != EOF )
    {
      while ( c == '*' )
        {
          if ( ( c = unix_getc( finput ) ) == '/' )
            return ( i );
        }
      if ( c == '\n' )
        ++i;
      c = unix_getc( finput );
    }
  error( "EOF inside comment" );
  /* NOTREACHED */
}
