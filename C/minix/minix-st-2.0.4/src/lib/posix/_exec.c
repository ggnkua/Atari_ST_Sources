#include <lib.h>
#define execl	_execl
#define execle	_execle
#define execv	_execv
#define execve	_execve
#define sbrk	_sbrk
#include <minix/minlib.h>
#include <stdarg.h>
#include <string.h>
#include <unistd.h>

extern char ***_penviron;

#define	PTRSIZE	(sizeof(char *))

#ifdef _ANSI
PUBLIC int execl(const char *name, const char *arg, ...)
#else
PUBLIC int execl(name)
char *name;
#endif
{
  va_list argp;
  int result;

  va_start(argp, name);

  /* The following cast of argp is not portable.  Doing it right by copying
   * the args to a true array will cost as much as ARG_MAX bytes of space.
   */
  result = execve(name, (char **) argp, *_penviron);
  va_end(argp);
  return(result);
}


#ifdef _ANSI
PUBLIC int execle(const char *name, const char *arg, ...)
#else
PUBLIC int execle(name)
char *name;
#endif
{
  va_list argp;
  char **p;
  int result;

  va_start(argp, name);
  
  /* The following cast of argp is not portable, as for execl(). */
  p = (char **) argp;
  while (*p++ != NIL_PTR)
	;			/* null statement */
  result = execve(name, (char **) argp, (char **) *p);
  va_end(argp);
  return(result);
}


PUBLIC int execv(name, argv)
_CONST char *name;
char * _CONST argv[];
{
  return(execve(name, argv, *_penviron));
}


PUBLIC int execve(path, argv, envp)
_CONST char *path;		/* pointer to name of file to be executed */
char * _CONST argv[];		/* pointer to argument array */
char * _CONST envp[];		/* pointer to environment */
{
  int i, j;

  /* Count the argument pointers and environment pointers. */
  i = 0;
  if (argv != NULL)
  {
	while (argv[i] != NULL) i++;
  }
  j = 0;
  if (envp != NULL)
  {
	while (envp[j] != NULL) j++;
  }

  return(__execve(path, argv, envp, i, j));
}


PUBLIC int __execve(path, argv, envp, nargs, nenvps)
_CONST char *path;		/* pointer to name of file to be executed */
char * _CONST argv[];		/* pointer to argument array */
char * _CONST envp[];		/* pointer to environment */
int nargs;			/* number of args */
int nenvps;			/* number of environment strings */
{
/* This is split off from execve to be called from execvp, so execvp does not
 * have to allocate up to ARG_MAX bytes just to prepend "sh" to the arg array.
 */

  char *hp, **ap, *p;
  int i, stackbytes, npointers, overflow, temp;
  char *stack;
  message m;

  /* Decide how big a stack is needed. Be paranoid about overflow. */
  overflow = FALSE;
  npointers = 1 + nargs + 1 + nenvps + 1;	/* 1's for argc and NULLs */
  stackbytes = nargs + nenvps;		/* 1 byte for each null in strings */
  if (nargs < 0 || nenvps < 0 || stackbytes < nargs || npointers < stackbytes)
	overflow = TRUE;
  for (i = PTRSIZE; i != 0; i--) {
	temp = stackbytes + npointers;
	if (temp < stackbytes) overflow = TRUE;
	stackbytes = temp;
  }
  ap = (char **) argv;
  for (i = 0; i < nargs; i++) {
	temp = stackbytes + strlen(*ap++);
	if (temp < stackbytes) overflow = TRUE;
	stackbytes = temp;
  }
  ap = (char **) envp;
  for (i = 0; i < nenvps; i++) {
	temp = stackbytes + strlen(*ap++);
	if (temp < stackbytes) overflow = TRUE;
	stackbytes = temp;
  }
  temp = stackbytes + PTRSIZE - 1;
  if (temp < stackbytes) overflow = TRUE;
  stackbytes = (temp / PTRSIZE) * PTRSIZE;

  /* Check for overflow before committing sbrk. */
  if (overflow) {
	errno = E2BIG;
	return(-1);
  }

  /* Allocate the stack. */
  stack = sbrk(stackbytes);
  if (stack == (char *) -1) {
	errno = E2BIG;
	return(-1);
  }

  /* Prepare the stack vector and argc. */
  ap = (char **) stack;
  hp = &stack[npointers * PTRSIZE];
  *ap++ = (char *) nargs;

  /* Prepare the argument pointers and strings. */
  for (i = 0; i < nargs; i++) {
	*ap++ = (char *) (hp - stack);
	p = *argv++;
	while ( (*hp++ = *p++) != 0)
		;
  }
  *ap++ = (char *) NULL;

  /* Prepare the environment pointers and strings. */
  for (i = 0; i < nenvps; i++) {
	*ap++ = (char *) (hp - stack);
	p = *envp++;
	while ( (*hp++ = *p++) != 0)
		;
  }
  *ap++ = (char *) NULL;

  /* Do the real work. */
  m.m1_i1 = strlen(path) + 1;
  m.m1_i2 = stackbytes;
  m.m1_p1 = (char *) path;
  m.m1_p2 = stack;
  (void) _syscall(MM, EXEC, &m);

  /* The exec failed. */
  sbrk(-stackbytes);
  return(m.m_type);
}
