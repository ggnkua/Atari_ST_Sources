#include <lib.h>

PUBLIC int mkdir(name, mode)
char *name;
int mode;
{
  return(callm1(FS, MKDIR, len(name), mode, 0, name, NIL_PTR, NIL_PTR));
}
