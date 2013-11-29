/*********************************/
/*---------- COOKIES.C ----------*/
/* Module de gestion des cookies */
/*********************************/
#include    <tos.h>
#include <stddef.h>
#include <string.h>


typedef struct
{
  long magic ;
  long data ;
} COOKIE;


COOKIE *cookie_jar(void)
{
  COOKIE *cookie ;
  long   stack ;

  stack  = Super(NULL) ;
  cookie = *(COOKIE**) 0x5A0 ;
  Super((void*) stack) ;

  return(cookie) ;
}

COOKIE *cookie_find(char ident[4])
{
  COOKIE *cookie ;
  long   magic ;

  memcpy(&magic, ident, sizeof(long)) ;
  cookie = cookie_jar() ;
  if (cookie == NULL) return(cookie) ;
  while (cookie->magic != 0)
  {
	if (cookie->magic == magic) break ;
	cookie++ ;
  }

  if (cookie->magic == 0) cookie = NULL ;
  return(cookie) ;
}
