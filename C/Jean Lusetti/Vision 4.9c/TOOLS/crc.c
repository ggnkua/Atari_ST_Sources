#include <stddef.h>

#include "logging.h"


unsigned long simple_crc(void* buf, size_t nb_bytes)
{
/*  static short   shift[] = { 0, 8, 16, 24, 4, 12, 20, 28 } ;*/
  unsigned short* pt = buf ;
  size_t         i ;
  unsigned long  crc = 0 ;

  LoggingDo(LL_DEBUG, "simple_crc(%p,%ld)", pt, nb_bytes) ;
  for ( i = 0; i < (nb_bytes>>1); i++, pt++ )
  {
    crc += *pt ;
/*    j = i & 0x07 ;
    if ( j ) crc += (unsigned long)*pt << shift[j] ;
    else     crc += *pt ;*/
  }

  return crc ;
}
