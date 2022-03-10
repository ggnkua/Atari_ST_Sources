
# include "y1.h" 

void prlook( p )
struct looksets * p;

{
  register j,
         * pp;
  pp = p->lset;
  if ( pp == 0 )
    fprintf( foutput, "\tNULL" );
  else
    {
      fprintf( foutput, " { " );
      TLOOP( j )
        {
          if ( BIT( pp, j ) )
            fprintf( foutput, "%s ", symnam( j ) );
        }
      fprintf( foutput, "}" );
    }
}
