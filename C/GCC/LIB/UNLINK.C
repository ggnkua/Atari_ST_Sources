
#include <osbind.h>

int unlink(filename)
char * filename;
{
  return(Fdelete(filename));
}
