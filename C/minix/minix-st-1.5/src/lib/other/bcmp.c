#include <lib.h>
/* bcmp - Berklix equivalent of memcmp  */

#include <string.h>

int bcmp(s1, s2, length)	/* == 0 or != 0 for equality and inequality */ 
_CONST char *s1;
_CONST char *s2;
int length;
{
  return(memcmp((_CONST _VOIDSTAR) s1, (_CONST _VOIDSTAR) s2, (_SIZET) length));
}
