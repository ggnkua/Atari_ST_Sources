#include <lib.h>
/* strchr - find first occurrence of a character in a string */

#include <string.h>

char *strchr(s, charwanted) 	/* found char, or NULL if none */
_CONST char *s;
register char charwanted;
{
  register _CONST char *scan;

  /* The odd placement of the two tests is so NUL is findable. */
  for (scan = s; *scan != charwanted;)	/* ++ moved down for opt. */
	if (*scan++ == '\0') return((char *) NULL);
  return((char *) scan);
}
