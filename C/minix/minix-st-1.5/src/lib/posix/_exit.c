#include <lib.h>

PUBLIC void _exit(status)
int status;
{
  callm1(MM, EXIT, status, 0, 0, NIL_PTR, NIL_PTR, NIL_PTR);
}
