#include "syslib.h"

#if (SHADOWING == 0)
PUBLIC int sys_xit(parent, proc)
int parent;			/* parent of exiting process */
int proc;			/* which process has exited */
#else
PUBLIC int sys_xit(parent, proc, basep, sizep)
int parent;			/* parent of exiting process */
int proc;			/* which process has exited */
phys_clicks *basep;		/* where to return base of shadow [68000] */
phys_clicks *sizep;		/* where to return size of shadow [68000] */
#endif /* SHADOWING == 0 */
{
/* A process has exited.  Tell the kernel. */

  message m;
  int r;

  m.m1_i1 = parent;
  m.m1_i2 = proc;
  r = _taskcall(SYSTASK, SYS_XIT, &m);
#if (SHADOWING == 1)
  *basep = (phys_clicks) m.m1_i1;
  *sizep = (phys_clicks) m.m1_i2;
#endif /* SHADOWING == 1 */
  return(r);
}
