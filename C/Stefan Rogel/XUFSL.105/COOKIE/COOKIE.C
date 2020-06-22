/* siehe ST-Computer 12/90,1/91 S.157ff. */

#include <stddef.h>
#include <string.h>
#include <tos.h>
#include <define.h>
#include <cookie.h>

void create_cookie(COOKIE_ENTRY *cookie,long magic,long value)
{
  cookie->magic=magic;
  cookie->value=value;
}

boolean new_cookie(COOKIE_ENTRY *cookie)
{
boolean ret;
long    sav;

	sav=Super((void *)1L);
	if (sav==0L)
	  sav=Super(NULL);
	CK_SetOptions(8,cookie->magic);
  ret=CK_WriteJar(cookie->magic,cookie->value)==TRUE;
	if (sav!=-1L)
	  Super((void *)sav);
	return ret;
}

long get_cookie(long magic)
{
boolean active;
long    value;
long    sav;

  sav=(long)Super(0L);
  active=CK_ReadJar(magic,&value)==TRUE;
  Super((char *)sav);
  return (active)? value : 0L;
}
