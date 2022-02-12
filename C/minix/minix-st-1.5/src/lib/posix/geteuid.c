#include <lib.h>
#include <sys/types.h>

PUBLIC uid_t geteuid()
{
  int k;
  k = callm1(MM, GETUID, 0, 0, 0, NIL_PTR, NIL_PTR, NIL_PTR);
  if (k < 0) return((uid_t) k);
  return((uid_t) _M.m2_i1);
}
