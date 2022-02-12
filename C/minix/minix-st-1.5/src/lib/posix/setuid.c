#include <lib.h>
#include <sys/types.h>

PUBLIC int setuid(usr)
uid_t usr;
{
  return(callm1(MM, SETUID, (int)usr, 0, 0, NIL_PTR, NIL_PTR, NIL_PTR));
}
