#include <lib.h>
/* bcopy - Berklix equivalent of memcpy  */

#include <string.h>

void bcopy(src, dst, length)
_CONST char *src;
char *dst;
int length;
{
  (void) memcpy((_VOIDSTAR) dst, (_CONST _VOIDSTAR) src, (_SIZET) length);
}
