#include <lib.h>
/* bzero - Berklix subset of memset  */

#include <string.h>

void bzero(dst, length)
char *dst;
int length;
{
  (void) memset((_VOIDSTAR) dst, 0, (_SIZET) length);
}
