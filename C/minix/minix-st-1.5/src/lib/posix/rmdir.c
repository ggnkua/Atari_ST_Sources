#include <lib.h>

PUBLIC int rmdir(name)
_CONST char *name;
{
  return(callm3(FS, RMDIR, 0, name));
}
