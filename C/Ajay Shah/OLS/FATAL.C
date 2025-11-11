#include <stdio.h>
#include <stdlib.h>
#include "utils.h"
/* for error checking. */

#ifdef TESTING
int 
main ()
{
  FatalError ("You are lost in a maze of twisty little passages, all alike.\n");
  return 0;
}

#endif

void 
FatalError (char *error_text)
{
  fprintf (stderr, "Run-time error...\n");
  fprintf (stderr, "%s\n", error_text);
  fprintf (stderr, "...now exiting to system...\n");
  exit (1);
}
