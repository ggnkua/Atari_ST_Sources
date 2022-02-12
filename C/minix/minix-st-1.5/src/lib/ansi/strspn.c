#include <lib.h>
/* strspn - find length of initial segment of s consisting entirely
 * of characters from accept
 */

#include <string.h>

size_t strspn(s, accept)
_CONST char *s;
_CONST char *accept;
{
  register _CONST char *sscan;
  register _CONST char *ascan;
  register size_t count;

  count = 0;
  for (sscan = s; *sscan != '\0'; sscan++) {
	for (ascan = accept; *ascan != '\0'; ascan++)
		if (*sscan == *ascan) break;
	if (*ascan == '\0') return (count);
	count++;
  }
  return(count);
}
