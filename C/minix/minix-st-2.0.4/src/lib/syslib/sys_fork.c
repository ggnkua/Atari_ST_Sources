#include "syslib.h"

#if (SHADOWING == 0)
PUBLIC int sys_fork(parent, child, pid)
#else
PUBLIC int sys_fork(parent, child, pid, child_base_or_shadow)
#endif /* SHADOWING == 1 */
int parent;			/* process doing the fork */
int child;			/* which proc has been created by the fork */
int pid;			/* process id assigned by MM */
#if (SHADOWING == 1)
phys_clicks child_base_or_shadow;	/* memory allocated for shadow */
#endif /* SHADOWING == 1 */
{
/* A process has forked.  Tell the kernel. */

  message m;

  m.m1_i1 = parent;
  m.m1_i2 = child;
  m.m1_i3 = pid;
#if (SHADOWING == 1)
  m.m1_p1 = (char *) child_base_or_shadow;
#endif /* SHADOWING == 1 */
  return(_taskcall(SYSTASK, SYS_FORK, &m));
}
