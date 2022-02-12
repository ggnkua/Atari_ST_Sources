#include "syslib.h"

PUBLIC int sys_newmap(proc, ptr)
int proc;			/* process whose map is to be changed */
struct mem_map *ptr;		/* pointer to new map */
{
/* A process has been assigned a new memory map.  Tell the kernel. */

  message m;

  m.m1_i1 = proc;
  m.m1_p1 = (char *) ptr;
  return(_taskcall(SYSTASK, SYS_NEWMAP, &m));
}
