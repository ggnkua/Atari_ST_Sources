#include "syslib.h"

PUBLIC int sys_exec(proc, ptr, traced, prog_name, initpc)
int proc;			/* process that did exec */
char *ptr;			/* new stack pointer */
int traced;			/* is tracing enabled? */
char *prog_name;		/* name of the new program */
vir_bytes initpc;
{
/* A process has exec'd.  Tell the kernel. */

  message m;

  m.m1_i1 = proc;
  m.m1_i2 = traced;
  m.m1_p1 = ptr;
  m.m1_p2 = prog_name;
  m.m1_p3 = (char *)initpc;
  return(_taskcall(SYSTASK, SYS_EXEC, &m));
}
