/* execlp(3) and execvp(3)
 *
 * Author: Terrence W. Holm      July 1988
 */

/* FIXES - Dec 1989 - Jan 1990 Bruce Evans.
 *	 - Don't use search path when file name contains a '/' *anywhere*.
 *	 - Invoke sh(1) on command files.
 *	 - Use PATH_MAX and check strings fit in buffer.
 *	 - Use stdargs, with the unjustified assumption that va_start() turns
 *	   the arg list into a char *[].  Strictly, the arg list should be
 *	   copied, "wasting" up to ARG_MAX bytes.
 */

/*  Execlp(3) and execvp(3) are like execl(3) and execv(3),
 *  except that they use the environment variable $PATH as
 *  a search list of possible locations for the executable
 *  file, if <file> does not contain a '/', and they attempt
 *  to run non-binary executable files using sh(1).
 *
 *  The path search list is a list of directory names separated
 *  by ':'s. If a colon appears at the beginning or end of the
 *  list, or two appear together, then an empty prefix is tried.
 *  If $PATH is not in the environment, it defaults to "".
 *
 *  For example, if <file> is "ls", and the $PATH is
 *  ":/usr/local/bin:/bin:/usr/bin", then  ./ls,
 *  /usr/local/bin/ls, /bin/ls and /usr/bin/ls are tried until
 *  an exectable one is found. If the direct attempt to exec it
 *  fails, the arg list is modified to begin with "sh" and the
 *  absolute name of <file>, and an exec of /bin/sh is tried.
 *  If this fails, no further attempts are made.
 *
 *  This function only returns after an error.  It returns -1
 *  and sets errno like execv().
 */

#include <sys/types.h>
#include <lib.h>
#include <errno.h>
#include <limits.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <stdarg.h>

#undef NULL
#define NULL 0			/* kludge for ACK not understanding void * */

#define MAX_NUM_ARGS 512	/* maximum number of arguments to execvp */

extern char ***_penviron;	/* environment pointer */

#ifdef _ANSI
int execlp(const char *file, const char *arg, ...)
#else
int execlp(file)
char *file;
#endif
{
  register va_list argp;
  register int result;

  va_start(argp, file);
  result = execvp(file, (char **) argp);
  va_end(argp);
  return(result);
}

#ifdef _ANSI
int execvp(const char *file, char *const argv[])
#else
int execvp(file, argv)
char *file;
char **argv;
#endif
{
  int i, best_errno;
  char **envtop;
  size_t flength;
  char *searchpath;
  size_t slength;
  char *split;
  char execpath[PATH_MAX + 1];
  char *arg2[MAX_NUM_ARGS + 3];	/* place to copy argv */

  /* POSIX requires argv to be immutable.  Unfortunately, we have to change it
   * during execution.  To keep POSIX happy, a copy is made and the copy 
   * changed.  The question arises: how big should the copy be?  Allocating
   * space dynamically requires using malloc, which itself takes up a lot
   * of space.  The solution chosen here is to limit the number of arguments
   * to MAX_NUM_ARGS and set this value fairly high.  This solution is simpler
   * and is probably adequate.  Only programs with huge numbers of very short
   * arguments will get an error (if the arguments are large, ARG_MAX will
   * be exceeded.
   */

  if (strchr(file, '/') != NULL || (searchpath = getenv("PATH")) == NULL)
	searchpath = "";
  flength = strlen(file);
  best_errno = ENOENT;

  while (1) {
	split = strchr(searchpath, ':');
	if (split == NULL)
		slength = strlen(searchpath);
	else
		slength = split - searchpath;
	if (slength + flength >= sizeof execpath - 2) {
		errno = ENAMETOOLONG;	/* too bad if premature */
		return(-1);
	}
	strncpy(execpath, searchpath, slength);
	if (slength != 0) execpath[slength++] = '/';
	strcpy(execpath + slength, file);

	/* Don't try to avoid execv() for non-existent files, since the Minix
	 * shell doesn't, and it is not clear whether access() or stat() work
	 * right when this code is set-uid.
	 */
	execv(execpath, argv);
	switch (errno) {
	    case EACCES:
		best_errno = errno;	/* more useful than ENOENT */
	    case ENOENT:
		if (split == NULL) {
			/* No more path components. */
			errno = best_errno;
			return(-1);
		}
		searchpath = split + 1;	/* try next in path */
		break;
	    case ENOEXEC:
		/* Assume a command file and invoke sh(1) on it.  Replace arg0
		 * (which is usually a short name for the command) by the full
		 * name of the command file.
		 */

		/* Copy the arg pointers from argv to arg2,  moving them up by
		 * 1, overlaying the assumed NULL at the end, to make room 
		 * for "sh" at the beginning.
		 */
		i = 0;
		if (argv != NULL)
		{
			while (argv[i] != 0) {
				if (i >= MAX_NUM_ARGS) {
					/* Copy failed.  Not enough room. */
					errno = ENOEXEC;
					return(-1);
				}
				arg2[i + 1] = argv[i];
				i++;
			}
		}
		arg2[0] = "sh";		/* exec the shell */
		arg2[1] = execpath;	/* full path */
		arg2[i + 1] = NULL;	/* terminator */

		/* Count the environment pointers. */
		for (envtop = *_penviron; *envtop != NULL; ) envtop++;

		/* Try only /bin/sh, like the Minix shell.  Lose if the user
		 * has a different shell or the command has #!another/shell.
		 */
		__execve("/bin/sh", arg2, *_penviron, i + 1, (int)(envtop - *_penviron));

		/* Oops, no shell?   Give up. */
		errno = ENOEXEC;
		return(-1);
	    default:
		return(-1);	/* probably  ENOMEM or E2BIG */
	}
  }
}
