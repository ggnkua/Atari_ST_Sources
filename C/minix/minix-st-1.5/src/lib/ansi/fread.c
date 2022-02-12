#include <lib.h>
#include <stdio.h>

size_t fread(ptrfix, size, count, file)
void *ptrfix;
size_t size, count;
FILE *file;
{
  register int c;
  size_t ndone = 0, s;
  char *ptr = (char *) ptrfix;

  ndone = 0;
  if (size) while (ndone < count) {
		s = size;
		do {
			if ((c = getc(file)) != EOF)
				*ptr++ = (char) c;
			else
				return(ndone);
		} while (--s);
		ndone++;
	}
  return(ndone);
}
