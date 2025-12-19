#include <ctype.h>
#include <string.h>

#include "xalloc.h"
#include "spattern.h"
#include "logging.h"


char* strstri(const char* string, const char* sub_string_lower)
{
  size_t i, j ;
  char*  match = NULL ;
  int    done = 0 ;

  i = j = 0 ;
  do
  {
    if ( sub_string_lower[j] == 0 ) match = (char*) &string[i-j] ;
    else
    {
      if ( sub_string_lower[j] == tolower(string[i]) ) j++;
      else                                             j = 0 ;
    }
    done = match || (string[i] == 0) ;
    i++ ;
  }
  while ( !done ) ;

  return match ;
}

long find_pattern(int type, void* data, size_t size, void* pattern, size_t pattern_size, long* sresults, long nsresults)
{
  char*          cpattern = pattern ;
  char*          data2compare ;
  char*          snc_data2compare_ori ;
  char*          cdata = (char*) data ;
  char*          snc_cdata = (char*) data ;
  long           offset = -1 ;
  long           snc_offset = pattern_size-2 ;
#define SNC_EXTRA_SIZE 1000
  long           snc_buffer_size = pattern_size+SNC_EXTRA_SIZE ;
  long           noccurs = 0 ;
  long           nloop = 0x80000L ;
  int            done = 0 ;
  long           i ;
  long           abs_nsresults = (nsresults < 0) ? -nsresults:nsresults ;
  static char    tlower[256] ;

  /* Safety checks */
  if ( !data || !pattern ) return -1 ;
  if ( pattern_size > size ) return -2 ;
  if ( !sresults || (abs_nsresults < 1) ) return -1 ;

  if ( type == SPT_STRINGNOCASE )
  {
    /* Need to re-allocate data (for pattern lenght) and pattern as we are going to touch it */
    cpattern = (char*) Xalloc( pattern_size+snc_buffer_size ) ;
    if ( cpattern == NULL ) return -3 ;
    memcpy( cpattern, pattern, pattern_size ) ;
    data2compare = snc_data2compare_ori = cpattern+pattern_size ;
    if ( tlower['A'] != 'a' )
      for ( i = 0; i < 256; i++ ) tlower[i] = (char)tolower((int)i) ; /* Initialize tolower array */
    for ( i = 0; i < (long)pattern_size; i++ )
    {
      cpattern[i] = tlower[((char*)pattern)[i]] ;
      data2compare[i] = tlower[cdata[i]] ;
    }
    data2compare-- ;
    snc_cdata += offset+pattern_size ;
  }

  do
  {
    offset++ ;
    if ( type == SPT_STRINGNOCASE )
    {
      if ( snc_offset >= pattern_size+SNC_EXTRA_SIZE-1 )
      {
        memcpy( snc_data2compare_ori, &data2compare[snc_offset], pattern_size ) ;
        data2compare = snc_data2compare_ori ;
        data2compare-- ;
        snc_offset = pattern_size-2 ;
      }
      data2compare++ ;
      snc_offset++ ;
      snc_data2compare_ori[snc_offset] = tlower[*snc_cdata] ;
      snc_cdata++ ;
    }
    else data2compare = &cdata[offset] ;
    if ( memcmp(data2compare, cpattern, pattern_size) == 0 )
    {
      /* If nsresults<0, it means we can store up to abs_nsresults and then keep counting without storing found offsets */
      if ( noccurs < abs_nsresults ) sresults[noccurs] = offset ;
      if ( ++noccurs == nsresults ) done = 1 ;
    }
    if ( nloop-- == 0 )
    {
      long pc = 100L*(offset >> 8) ; /* >> 8 because we may overflow as we multiply by 100 */

      pc /= (size >> 8) ;
      LoggingDo(LL_INFO, "Searching from offset $%lx/$%lx (%ld matches so far), %d%% done", offset, size, noccurs, (int)pc) ;
      nloop = 0x80000L ;
    }
    if ( !done && (offset + pattern_size >= size) ) done = 1 ;
  }
  while ( !done ) ;

  if ( type == SPT_STRINGNOCASE ) Xfree( cpattern ) ;

  return noccurs ;
}
