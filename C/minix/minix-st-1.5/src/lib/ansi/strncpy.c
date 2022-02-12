/* strncpy - copy at most n characters of string src to dst */

#include <string.h>

char *strncpy(dst, src, n)
char *dst;
_CONST char *src;
size_t n;
{
  register char *dscan;
  register _CONST char *sscan;
  register size_t count;

  dscan = dst;
  sscan = src;
  count = n + 1;		/* extra so predecrement tests remainder */
  while (--count > 0 && (*dscan++ = *sscan++) != '\0') continue;
  if (count <= 0) return(dst);	/* so next loop works with unsigned size_t */ 
  while (--count > 0) *dscan++ = '\0';
  return(dst);
}
