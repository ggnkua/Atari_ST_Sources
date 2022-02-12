#include "syslib.h"

PUBLIC int sys_xit(parent, proc, basep, sizep)
int parent;			/* parent of exiting process */
int proc;			/* which process has exited */
phys_clicks *basep;		/* where to return base of shadow [68000] */
phys_clicks *sizep;		/* where to return size of shadow [68000] */
{
/* A process has exited.  Tell the kernel. */

  message m;
  int r;

  m.m1_i1 = parent;
  m.m1_i2 = proc;
  r = _taskcall(SYSTASK, SYS_XIT, &m);
  *basep = (phys_clicks) m.m1_i1;
  *sizep = (phys_clicks) m.m1_i2;
  return(r);
}
