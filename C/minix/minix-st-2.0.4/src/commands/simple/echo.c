/* echo - echo arguments	Author: Andy Tanenbaum */

#include <sys/types.h>
#include <stdlib.h>
#include <unistd.h>

#define SIZE 1024
char buf[SIZE];
int count;

_PROTOTYPE(int main, (int argc, char **argv));
_PROTOTYPE(void collect, (char *s));

int main(argc, argv)
int argc;
char *argv[];
{
  register int i, nflag;

  nflag = 0;
  if (argc > 1 && argv[1][0] == '-' && argv[1][1] == 'n') {
	nflag++;
	argc--;
	argv++;
  }
  for (i = 1; i < argc; i++) {
	collect(argv[i]);
	if (i < argc - 1) collect(" ");
  }

  if (nflag == 0) collect("\n");

  /* Print accumulated output. */
  if (count > 0) write(1, buf, count);
  return(0);
}

void collect(s)
char *s;
{
/* Collect characters.  For efficiency, write them in large chunks. */
  char c;

  while ((c = *s++) != 0) {
	if (count == SIZE) {
		write(1, buf, count);
		count = 0;
	}
	buf[count++] = c;
  }
}
