/* printenv - print the current environment	Author: Richard Todd */

#include <sys/types.h>
#include <stdio.h>

extern char **environ;

_PROTOTYPE(int main, (void));

int main()
{
  char **sptr;
  for (sptr = environ; *sptr; ++sptr) {
	printf("%s\n", *sptr);
  }
  return(0);
}
