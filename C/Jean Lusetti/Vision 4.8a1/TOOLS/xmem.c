#include <string.h>


void memzero(void* s, size_t n)
{
  (void)memset( s, 0, n ) ;
}
