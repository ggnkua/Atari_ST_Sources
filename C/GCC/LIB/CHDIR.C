
#include <osbind.h>

int chdir(dir)
char * dir;
{
  return(Dsetpath(dir));
}

