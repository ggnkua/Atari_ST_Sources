
# include "y2.h" 

void cpycode( )
{
  /* copies code between \{ and \} */

  int c;
  c = unix_getc( finput );
  if ( c == '\n' )
    {
      c = unix_getc( finput );
      lineno++;
    }
  fprintf( ftable, "\n# line %d\n", lineno );
  while ( c >= 0 )
    {
      if ( c == '\\' )
        if ( ( c = unix_getc( finput ) ) == '}' )
          return;
        else
          putc( '\\', ftable );
      if ( c == '%' )
        if ( ( c = unix_getc( finput ) ) == '}' )
          return;
        else
          putc( '%', ftable );
      putc( c, ftable );
      if ( c == '\n' )
        ++lineno;
      c = unix_getc( finput );
    }
  error( "eof before %%}" );
}
