#include <unistd.h>
#include <support.h>
#include <process.h>
#include <stdio.h>
#include "global.h"

#define ARG_GRAN	10

void add_args(A, arg_list)
  Arguments *A;
  char const * const * arg_list;
{
  register int n;
  register char const * const *p;
  register char const **q;

  if (A->_args == 0) {
    A->_args = mallok((A->arg_spc = ARG_GRAN) * sizeof(char *));
    A->nargs = 0;
    A->_args[0] = 0;
  }
  for (n = 0, p = arg_list; *p; n++, p++)
    continue;
  if (A->nargs + n >= A->arg_spc) {
    do
      A->arg_spc *= 2;
    while (A->nargs + n >= A->arg_spc);
    A->_args = reallok(A->_args, (A->arg_spc *= 2) * sizeof (char *));
  }
  for (p = arg_list, q = A->_args + A->nargs; *p; p++, q++)
    *q = *p;
  *q = 0;
  A->nargs += n;
}

void add_arg(A, arg)
  Arguments *A;
  const char *arg;
{
  static const char *arg_list[2] = {0, 0};

  arg_list[0] = arg;
  add_args(A, arg_list);
}

void remove_args(A, n)
  Arguments *A;
  int n;
{
  if (A->nargs < n)
    bugchk("remove %d args from %d-arg stack \"%s\"?", n, A->nargs, args(A)[0]);
  A->nargs -= n;
  A->_args[A->nargs] = 0;
}

void run(A, envp)
  Arguments *A;
  char const * const *envp;
{
  const char *prog;
  static char * const exts[] = {"prg", "tos", "ttp", NULL};

  if (A->nargs == 0 || args(A) == 0)
    bugchk("execute nothing?");

  if (!action || verbose) {
    register const char **p = args(A);

    for (; *p; p++)
      printf("%s%c", *p, (p[1] ? ' ' : '\n'));
  }
  if (!action)
    return;

  prog = findfile(args(A)[0], getenv("PATH"), exts);
  if (!prog)
    fatal("can't find program %s\n", args(A)[0]);

  if (spawnve(P_WAIT, prog, (char * const *)args(A), (char * const *)envp) != 0)
    fatal("error running program %s\n", args(A)[0]);
}
