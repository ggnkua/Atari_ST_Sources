#include <lib.h>

PUBLIC unsigned int alarm(sec)
unsigned int sec;
{
  return(callm1(MM, ALARM, (int) sec, 0, 0, NIL_PTR, NIL_PTR, NIL_PTR));
}
