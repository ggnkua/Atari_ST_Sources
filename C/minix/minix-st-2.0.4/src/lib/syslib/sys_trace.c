#include "syslib.h"

PUBLIC int sys_trace(req, procnr, addr, data_p)
int req, procnr;
long addr, *data_p;
{
  message m;
  int r;

  m.m2_i1 = procnr;
  m.m2_i2 = req;
  m.m2_l1 = addr;
  if (data_p) m.m2_l2 = *data_p;
  r = _taskcall(SYSTASK, SYS_TRACE, &m);
  if (data_p) *data_p = m.m2_l2;
  return(r);
}
