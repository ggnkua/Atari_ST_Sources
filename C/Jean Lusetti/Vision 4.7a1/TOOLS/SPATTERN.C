#include <ctype.h>
#include <string.h>

#include "xalloc.h"
#include "spattern.h"
#include "logging.h"

static char* strstri(char* string, char* sub_string_lower)
{
  size_t i, j ;
  char*  match = NULL ;
  int    done = 0 ;

  i = j = 0 ;
  do
  {
    if ( sub_string_lower[j] == 0 ) match = &string[i-j] ;
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
  char* pat ;
  char* cdata = (char*) data ;
  long  offset = -1 ;
  long  noccurs = 0 ;
#define FREQ_PROG 0x100000L
  long  nloop = 0x80000L ;
  int   done = 0 ;

  /* Safety checks */
  if ( !data || !pattern ) return -1 ;
  if ( pattern_size > size ) return -2 ;
  if ( !sresults || (nsresults < 1) ) return -1 ;

  if ( type == SPT_STRINGCASE )
  {
    do
    {
      offset++ ;
      pat = strstr( &cdata[offset], pattern ) ;
	    if ( pat )
	    {
        offset = (long)(pat - cdata) ;
        sresults[noccurs++] = offset ;
        if ( noccurs == nsresults ) done = 1 ;
	    }
      else if ( cdata[offset] )
        offset += pattern_size-1 ;
	    if ( !done ) done = (offset + pattern_size >= size) ;
      if ( nloop-- == 0 )
      {
        long pc ;

        pc = 100L*(offset >> 8) ; /* >> 8 because we may overflow as we multiply by 100 */
        pc /= (size >> 8) ;
        LoggingDo(LL_INFO, "Searching from offset $%lx/$%lx (%ld matches so far), %d%% done", offset, size, noccurs, (int)pc) ;
        nloop = 0x80000L ;
      }
    }
    while ( !done ) ;
  }
  else if ( type == SPT_STRINGNOCASE )
  {
    char* lpattern = Xalloc( 1+pattern_size ) ;

    if ( lpattern == NULL ) return -3 ;
    memcpy( lpattern, pattern, 1+pattern_size ) ; /* copy tailing zero */
    strlwr( lpattern ) ;
    do
    {
      offset++ ;
      pat = strstri( &cdata[offset], lpattern ) ;
      if ( pat )
	    {
        offset = (long)(pat - cdata) ;
        sresults[noccurs++] = offset ;
        if ( noccurs == nsresults ) done = 1 ;
	    }
	    else if ( cdata[offset] )
        offset += pattern_size-1 ;
	    if ( !done ) done = (offset + pattern_size >= size) ;
      if ( nloop-- == 0 )
      {
        long pc ;

        pc = 100L*(offset >> 8) ; /* >> 8 because we may overflow as we multiply by 100 */
        pc /= (size >> 8) ;
        LoggingDo(LL_INFO, "Searching from offset $%lx/$%lx (%ld matches so far), %d%% done", offset, size, noccurs, (int)pc) ;
        nloop = 0x80000L ;
      }
    }
    while ( !done ) ;

    Xfree( lpattern ) ;
  }
  else if ( type == SPT_BIN )
  {
    do
    {
      offset++ ;
	    if ( memcmp(&cdata[offset], pattern, pattern_size) == 0 )
	    {
        sresults[noccurs++] = offset ;
        if ( noccurs == nsresults ) done = 1 ;
	    }
	    if ( !done ) done = (offset + pattern_size >= size) ;
      if ( nloop-- == 0 )
      {
        long pc ;

        pc = 100L*(offset >> 8) ; /* >> 8 because we may overflow as we multiply by 100 */
        pc /= (size >> 8) ;
        LoggingDo(LL_INFO, "Searching from offset $%lx/$%lx (%ld matches so far), %d%% done", offset, size, noccurs, (int)pc) ;
        nloop = 0x80000L ;
      }
    }
    while ( !done ) ;
  }

  return noccurs ;
}
