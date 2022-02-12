#include <lib.h>

PUBLIC int unlink(name)
_CONST char *name;
{
  return(callm3(FS, UNLINK, 0, name));
}
