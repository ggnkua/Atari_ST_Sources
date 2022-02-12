#include <lib.h>
/* memchr - search for a byte
 *
 * CHARBITS should be defined only if the compiler lacks "unsigned char".
 * It should be a mask, e.g. 0377 for an 8-bit machine.
 */

#include <string.h>

#define CHARBITS 0377

#ifndef CHARBITS
#	define	UNSCHAR(c)	((unsigned char)(c))
#else
#	define	UNSCHAR(c)	((c)&CHARBITS)
#endif

void *memchr(s, ucharwanted, size)
_CONST _VOIDSTAR s;
int ucharwanted;
size_t size;
{
  register _CONST char *scan;
  register size_t n;
  register int uc;

  scan = (char *) s;
  uc = UNSCHAR(ucharwanted);
  for (n = size; n > 0; n--) {
	if (UNSCHAR(*scan) == uc)
		return( (void *) scan);
	else
		scan++;
  }

  return( (_VOIDSTAR) NULL);
}
