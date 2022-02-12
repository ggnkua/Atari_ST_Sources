#include <lib.h>
/* strcpy - copy string src to dst  */

#include <string.h>

char *strcpy(dst, src)
char *dst;
_CONST char *src;
{
  register char *dscan;
  register _CONST char *sscan;

  dscan = dst;
  sscan = src;
  while ((*dscan++ = *sscan++) != '\0') continue;
  return(dst);
}
