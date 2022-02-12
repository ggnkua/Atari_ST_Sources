#include <lib.h>
/* memcmp - compare bytes */

#include <string.h>

int  memcmp(s1, s2, size)
_CONST _VOIDSTAR s1;		/* <0, == 0, >0 */
_CONST _VOIDSTAR s2;
size_t size;
{
  register _CONST char *scan1;
  register _CONST char *scan2;
  register size_t n;

  scan1 = (char *) s1;
  scan2 = (char *) s2;
  for (n = size; n > 0; n--)
	if (*scan1 == *scan2) {
		scan1++;
		scan2++;
	} else
		return(*scan1 - *scan2);

  return(0);
}
