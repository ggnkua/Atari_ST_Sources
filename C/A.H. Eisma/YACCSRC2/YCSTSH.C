
# include "y2.h" 
char * cstash( s )
register char * s;

{
  char * temp;

  temp = cnamp;
  do
    {
      if ( cnamp >= &cnames[ cnamsz ] )
        error( "too many characters in id's and literals" );
      else
        *cnamp++ = *s;
    }
  while ( *s++ );
  return ( temp );
}
