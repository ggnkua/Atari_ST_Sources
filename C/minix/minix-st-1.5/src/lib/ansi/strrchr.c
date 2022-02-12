#include <lib.h>
/* strrchr - find last occurrence of a character in a string */

#include <string.h>

char *strrchr(s, charwanted)		/* found char, or NULL if none */
_CONST char *s;
register char charwanted;
{
  register _CONST char *scan;
  register _CONST char *place;

  place = (char *) NULL;
  for (scan = s; *scan != '\0'; scan++)
	if (*scan == charwanted) place = scan;
  if (charwanted == '\0') return ((char *) scan);
  return((char *) place);
}
