#include <string.h>
#include <stddef.h>


char* GetNextVaStartFileName(char* start_pos, char* filename)
{
  char* aposd ;
  char* new_pos = NULL ;

  filename[0] = 0 ;
  aposd = strchr( start_pos, '\'' ) ;
  if ( aposd )
  {
    char* aposf = strchr( 1 + aposd, '\'' ) ;

    if ( aposf )
    {
      *aposf = 0 ;
      strcpy( filename, 1 + aposd ) ;
      *aposf = '\'' ;
      new_pos = 1 + aposf ;
    }
  }
  else
  {
    char* space = strchr( start_pos, ' ' ) ;

    if ( space )
    {
      *space = 0 ;
      strcpy( filename, start_pos ) ;
      *space = ' ' ;
      new_pos = 1 + space ;
    }
    else
      strcpy( filename, start_pos ) ;
  }

  return new_pos ;
}
