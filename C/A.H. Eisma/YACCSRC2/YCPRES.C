
# include "y1.h"     
# include <stdlib.h> 
/*
 * 12-Apr-83 (RBD) Add symbolic exit status
 */
extern int * pyield[ NPROD ];

void cpres( )
{
  /* compute an array with the beginnings of  productions yielding given nonterminals
       The array pres points to these lists */
  /* the array pyield has the lists: the total size is only NPROD+1 */
  register * * pmem;
  register     c,
               j,
               i;

  pmem      = pyield;

  NTLOOP( i )
    {
      c     = i + NTBASE;
      pres[ i ] = pmem;
      fatfl = 0; /* make undefined  symbols  nonfatal */
      PLOOP( 0, j )
        {
          if ( *prdptr[ j ] == c )
            *pmem++ = prdptr[ j ] + 1;
        }
      if ( pres[ i ] == pmem )
        {
          error( "nonterminal %s not defined!", nontrst[ i ].name );
        }
    }
  pres[ i ] = pmem;
  fatfl     = 1;
  if ( nerrors )
    {
      summary( );
      exit( EX_ERR );
    }
  if ( pmem != &pyield[ nprod ] )
    error( "internal Yacc error: pyield %d", pmem - &pyield[ nprod ] );
}
