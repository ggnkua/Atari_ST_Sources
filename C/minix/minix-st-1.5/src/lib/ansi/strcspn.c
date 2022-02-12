#include <lib.h>
/* strcspn - find length of initial segment of s consisting entirely
 * of characters not from reject
 */

#include <string.h>

size_t strcspn(s, reject)
_CONST char *s;
_CONST char *reject;
{
  register _CONST char *scan;
  register _CONST char *rscan;
  register size_t count;

  count = 0;
  for (scan = s; *scan != '\0'; scan++) {
	for (rscan = reject; *rscan != '\0';)	/* ++ moved down. */
		if (*scan == *rscan++) return(count);
	count++;
  }
  return(count);
}
