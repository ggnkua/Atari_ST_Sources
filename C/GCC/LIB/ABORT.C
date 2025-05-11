
#include <stdio.h>

extern FILE * stderr;

abort()
{
  int * stackp;
  int i;

  stackp = (int * )&stackp;
  printf(stderr, "\n\n!!! Aborting!!! stack = \n");
  for(i = 0 ; i < 16 ; i++)
  	printf("%lx: %lx\n", stackp, *stackp++);
  exit(-999);
}

_abort_internal(line, file)
int line;
char * file;
{
  fprintf(stderr, "Aborting at line %d of file %s\n", line, file);
  abort();		/* note that this won't work of compile this
			   with the define that got us to this fun in
			   the first place */
}
