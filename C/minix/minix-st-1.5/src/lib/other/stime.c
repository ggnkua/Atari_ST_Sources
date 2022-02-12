#include <lib.h>

PUBLIC int stime(top)
long *top;
{
  _M.m2_l1 = *top;
  return(callx(FS, STIME));
}
