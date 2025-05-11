
/* what a crock... */
#include "std-guts.h"

puts(str)
char * str;
{
  char c;
  int eol_flag = 0;

  while (c = *str++)
	{
	eol_flag = (c == '\n');
	fputc(c, stdout);
	}
  if (!eol_flag)
	fputc('\n', stdout);
}


