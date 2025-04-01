/***********************************************/
/* Modul  : UTILITY                            */
/***********************************************/

#include <string.h>
#include "utility.h"

void Swap( int *a, int *b )
{
   int c;

   c  = *a;
   *a = *b;
   *b = c;
}

/***********************************************/
/* Leerzeichen am Anfang und Ende des          */
/* Strings lîschen                             */
/***********************************************/
char *DeleteSpace( char *str )
{
   char  *ptr,
         *oldbeg;

   oldbeg = str;

   /* Leerzeichen am Anfang Åberspringen */
   while( *str == ' ' )
      ++str;

   /* Das Nullzeichen zum Anfang
      hin verschieben */
   ptr = &str[strlen( str ) - 1];
   if( strlen( str ) )
      while( *ptr == ' ' )
      {
         *ptr = 0;
         --ptr;
      }

   /* Den String an der alten Adresse
      beginnen lassen */
   memmove( oldbeg, str, strlen( str ) + 1 );


   return( oldbeg );
}
