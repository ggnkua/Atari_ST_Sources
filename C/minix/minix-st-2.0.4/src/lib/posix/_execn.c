#include <lib.h>
#include <string.h>

#define	PTRSIZE	sizeof(char *)
_PROTOTYPE( int _execn, (char * name));

PUBLIC int _execn(name)
char *name;			/* pointer to file to be exec'd */
{
/* Special version used when there are no args and no environment.  This call
 * is principally used by INIT, to avoid having to allocate ARG_MAX.
 */

  PRIVATE char stack[3 * PTRSIZE];
  message m;

  m.m1_i1 = strlen(name) + 1;
  m.m1_i2 = sizeof(stack);
  m.m1_p1 = name;
  m.m1_p2 = stack;
  (void) _syscall(MM, EXEC, &m);
}
