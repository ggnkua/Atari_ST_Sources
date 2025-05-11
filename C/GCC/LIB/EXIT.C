
/* don't know why this is supposed to be here.  chance to clean up before
   exitting for real? */

#include <stdio.h>

exit(value)
int value;
{
  fclose(stdin);
  fclose(stdout);
  fclose(stderr);

  _exit(value);
}
