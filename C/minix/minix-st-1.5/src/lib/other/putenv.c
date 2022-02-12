#include <lib.h>
/*  putenv(3)
 *
 *  Author: Ronald Lamprecht          Sep. 1989
 */

#include <stdlib.h>

extern char **environ;

int putenv(name)
register char *name;
{
  char **v, **nv, **newenv;
  register char *n;
  register char *p;
  register int i = 0;

  if (name == (char *)NULL) return(1);
  if (environ != (char **) NULL) {
	for (v = environ; *v != (char *)NULL; v++, i++) {
		n = name;
		p = *v;

		while (*n == *p && *n != '=' && *n != '\0') ++n, ++p;

		if (*n == '=' && *p == '=') {
			*v = name;
			return(1);
		}
	}
  }

  /* Realloc environment ptr. array (original array may not be
   * mallocated !) */
  if ((newenv = (char **) malloc((i + 2) * sizeof(char *))) == (char **) 0)
	return(0);
  for (v = environ, nv = newenv; i > 0; i--, v++, nv++) *nv = *v;
  *(nv++) = name;
  *nv = (char *)NULL;
  environ = newenv;
  return(1);
}
