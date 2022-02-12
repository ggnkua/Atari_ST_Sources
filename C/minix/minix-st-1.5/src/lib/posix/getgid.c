#include <lib.h>
#include <sys/types.h>

PUBLIC gid_t getgid()
{
  return((gid_t)callm1(MM, GETGID, 0, 0, 0, NIL_PTR, NIL_PTR, NIL_PTR));
}
