#include "protect.h"


int CountNbBits(long x, char value)
{
  long i, mask ;
  int  nb = 0 ;

  mask = 0x01L ;
  for ( i = 0; i < 32; i++, mask <<= 1 )
  {
    if ( x & mask )
    {
      if ( value ) nb++ ;
    }
    else
    {
      if ( value == 0 ) nb++ ;
    }
  }

  return( nb ) ;
}

long s_key(long key)
{
  long k, skey ;

  k    = key - KEY_MIN ;
  skey = ( k * 7 ) & SKEY_MASK ;

  return( skey ) ;
}

int IsSKeyOK(long key)
{
  long skey = key >> SKEY_LSHIFT ;
  long first_key = key & ~(SKEY_MASK << SKEY_LSHIFT) ;

  if ( s_key( first_key ) != skey ) return( 0 ) ;
 
   return( 1 ) ;
}
