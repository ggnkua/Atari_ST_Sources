#include <lib.h>
/* strcmp - compare string s1 to s2 */

#include <string.h>

int  strcmp(s1, s2)			/* <0 for <, 0 for ==, >0 for > */
_CONST char *s1;
_CONST char *s2;
{
  register _CONST char *scan1;
  register _CONST char *scan2;

  scan1 = s1;
  scan2 = s2;
  while (*scan1 != '\0' && *scan1 == *scan2) {
	scan1++;
	scan2++;
  }

  /* The following case analysis is necessary so that characters which
   * look negative collate low against normal characters but high
   * against the end-of-string NUL. */
  if (*scan1 == '\0' && *scan2 == '\0')
	return(0);
  else if (*scan1 == '\0')
	return(-1);
  else if (*scan2 == '\0')
	return(1);
  else
	return(*scan1 - *scan2);
}
