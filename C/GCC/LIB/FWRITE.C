
#include "std-guts.h"

int fwrite(where, how_big, how_many, f)
char * where;
int how_big;
int how_many;
struct file * f;
{
  int i, j;

  for (i = 0 ; i < how_many ; i++)
	for (j = 0 ; j < how_big ; j++)
		fputc(*where++, f);
  return(i);
}
