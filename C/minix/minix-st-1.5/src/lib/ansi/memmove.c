/* memmove.c */
/* Moves a block of memory (safely). */
/* Calls memcpy(), so memcpy() had better be safe. */
/* Henry Spencer's routine is fine. */

#include <string.h>

void *memmove(s1, s2, n)
_VOIDSTAR s1;
_CONST _VOIDSTAR s2;
size_t n;
{
  return memcpy(s1, s2, n);
}
