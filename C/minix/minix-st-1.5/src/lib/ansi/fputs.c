#include <lib.h>
#include <stdio.h>

int fputs(s, file)
_CONST register char *s;
FILE *file;
{
  while (*s) putc(*s++, file);
  return(ferror(file));
}
