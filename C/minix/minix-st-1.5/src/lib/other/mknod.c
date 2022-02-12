#include <lib.h>

PUBLIC int mknod(name, mode, addr, size)
char *name;
int mode, addr;
unsigned int size;
{
  return(callm1(FS, MKNOD, len(name), mode, addr, name, (char*)size, NIL_PTR));
}
