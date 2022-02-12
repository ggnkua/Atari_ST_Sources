#include <lib.h>

PUBLIC void (*__cleanup) ();

PUBLIC void exit(status)
int status;
{
  if (__cleanup) (*__cleanup) ();
  callm1(MM, EXIT, status, 0, 0, NIL_PTR, NIL_PTR, NIL_PTR);
}
