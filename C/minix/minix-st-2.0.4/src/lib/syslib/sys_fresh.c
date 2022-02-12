#include "syslib.h"

PUBLIC int sys_fresh(proc, ptr, dc, basep, sizep)
int proc;			/* process whose map is to be changed */
struct mem_map *ptr;		/* pointer to new map */
phys_clicks dc;			/* size of initialized data */
phys_clicks *basep, *sizep;	/* base and size for free_mem() */
{
/* Create a fresh process image for exec().  Tell the kernel. */

  message m;
  int r;

  m.m1_i1 = proc;
  m.m1_i2 = (int) dc;
  m.m1_p1 = (char *) ptr;
  r = _taskcall(SYSTASK, SYS_FRESH, &m);
  *basep = (phys_clicks) m.m1_i1;
  *sizep = (phys_clicks) m.m1_i2;
  return(r);
}
