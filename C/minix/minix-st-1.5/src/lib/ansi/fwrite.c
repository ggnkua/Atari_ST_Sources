#include <lib.h>
#include <stdio.h>

size_t fwrite(ptrfix, size, count, file)
_CONST void *ptrfix;
size_t size, count;
FILE *file;
{
  size_t s;
  size_t ndone = 0;
  _CONST char *ptr = (char *) ptrfix;

  if (size) while (ndone < count) {
		s = size;
		do {
			putc(*ptr++, file);
			if (ferror(file)) return(ndone);
		}
		while (--s);
		ndone++;
	}
  return(ndone);
}
