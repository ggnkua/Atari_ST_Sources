#include <lib.h>
#include <sys/types.h>

PUBLIC mode_t umask(complmode)
mode_t complmode;
{
  return((mode_t)callm1(FS, UMASK, (int)complmode, 0, 0, NIL_PTR, NIL_PTR, NIL_PTR));
}
