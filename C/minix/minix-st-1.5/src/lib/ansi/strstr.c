#include <lib.h>
/* strstr - find first occurrence of wanted in s */

#include <string.h>

char *strstr(s, wanted)		/* found string, or NULL if none */
_CONST char *s;
_CONST char *wanted;
{
  register _CONST char *scan;
  register size_t len;
  register char firstc;

  /* We inline the first char for speed. */
  if ((firstc = *wanted) == '\0') return((char *) s);
  len = strlen(wanted);
  for (scan = s; *scan != '\0'; scan++)
	if (*scan == firstc && strncmp(scan, wanted, len) == 0)
		return((char *) scan);
  return( (char *) NULL);
}
