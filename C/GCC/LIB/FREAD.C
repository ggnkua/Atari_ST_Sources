
#include "std-guts.h"

int fread(where, how_big, how_many, f)
char * where;
int how_big;
int how_many;
struct file * f;
{
  int i, j, c;

  for (i = 0 ; i < how_many ; i++)
	for (j = 0 ; j < how_big ; j++)
		{
		c = fgetc(f);
		if (c == EOF)
			return(i);
		*where++ = c;
		}
  return(i);
}
