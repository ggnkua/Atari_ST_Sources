#include <lib.h>
#include <sys/types.h>

PUBLIC int setgid(grp)
gid_t grp;
{
  return(callm1(MM, SETGID, (int)grp, 0, 0, NIL_PTR, NIL_PTR, NIL_PTR));
}
