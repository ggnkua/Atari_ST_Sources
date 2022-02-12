#include <lib.h>
/* strpbrk - find first occurrence of any char from breakat in s */

#include <string.h>

char *strpbrk(s, breakat)	/* found char, or NULL if none */
_CONST char *s;
_CONST char *breakat;
{
  register _CONST char *sscan;
  register _CONST char *bscan;

  for (sscan = s; *sscan != '\0'; sscan++) {
	for (bscan = breakat; *bscan != '\0';)	/* ++ moved down. */
		if (*sscan == *bscan++) return((char *) sscan);
  }
  return( (char *) NULL);
}
