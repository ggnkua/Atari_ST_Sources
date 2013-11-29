#include <tos.h>
#include <stddef.h>
#include "cookies.h"

char mint_is_present = -1 ;


int CreateThread(int (*ThreadProc)(void *param), void *param)
{
  int pid = -1 ;

  if ( mint_is_present == -1 )
    mint_is_present = ( cookie_find( "MiNT" ) != NULL ) ;

  if ( mint_is_present )
  {
    pid = Pfork() ;
    if ( pid == 0 )
    {
      int exit_code ;

      exit_code = ThreadProc( param ) ;

      Pterm( exit_code ) ;
    }
  }

  return( pid ) ;
}

