#include <lib.h>
/* strcat - append string src to  */

#include <string.h>

char *strcat(dst, src)
char *dst;
_CONST char *src;
{
  register char *dscan;
  register _CONST char *sscan;

  for (dscan = dst; *dscan != '\0'; dscan++) continue;
  sscan = src;
  while ((*dscan++ = *sscan++) != '\0') continue;
  return(dst);
}
