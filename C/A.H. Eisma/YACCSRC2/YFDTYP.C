
# include "y2.h" 

fdtype( t )
{
  /* determine the type of a symbol */
  register v;
  if ( t >= NTBASE )
    v = nontrst[ t - NTBASE ].tvalue;
  else
    v = TYPE( toklev[ t ] );
  if ( v <= 0 )
    error( "must specify type for %s",
           ( t >= NTBASE ) ?
           nontrst[ t - NTBASE ].name :
           tokset[ t ].name );
  return ( v );
}
