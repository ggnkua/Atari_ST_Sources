
# include "y1.h" 

setunion( a, b )
register * a,
         * b;

{
  /* set a to the union of a and b */
  /* return 1 if b is not a subset of a, 0 otherwise */
  register i,
           x,
           sub;

  sub = 0;
  SETLOOP( i )
    {
      *a = ( x = *a ) | *b++;
      if ( *a++ != x )
        sub = 1;
    }
  return ( sub );
}
