#include <lib.h>
#include "stdio.h"

int puts(s)
_CONST char *s;
{
  char c;

  c = fputs(s, stdout);
  putchar('\n');
  return(c);
}
