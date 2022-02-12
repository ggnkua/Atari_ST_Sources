#include "syslib.h"

PUBLIC int sys_fork(parent, child, pid, child_base_or_shadow)
int parent;			/* process doing the fork */
int child;			/* which proc has been created by the fork */
int pid;			/* process id assigned by MM */
phys_clicks child_base_or_shadow;	/* position for child [VM386];
				 * memory allocated for shadow [68000] */
{
/* A process has forked.  Tell the kernel. */

  message m;

  m.m1_i1 = parent;
  m.m1_i2 = child;
  m.m1_i3 = pid;
  m.m1_p1 = (char *) child_base_or_shadow;
  return(_taskcall(SYSTASK, SYS_FORK, &m));
}
