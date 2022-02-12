/* strncat - append at most n characters of string src to dst */

#include <string.h>

char *strncat(dst, src, n)
char *dst;
_CONST char *src;
size_t n;
{
  register char *dscan;
  register _CONST char *sscan;
  register size_t count;

  for (dscan = dst; *dscan != '\0'; dscan++) continue;
  sscan = src;
  count = n + 1;		/* extra so predecrement tests remainder */
  while (*sscan != '\0' && --count > 0) *dscan++ = *sscan++;
  *dscan++ = '\0';
  return(dst);
}
