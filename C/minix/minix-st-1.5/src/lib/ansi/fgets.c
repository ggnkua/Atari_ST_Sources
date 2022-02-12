#include <lib.h>
#include <stdio.h>

char *fgets(str, n, file)
char *str;
int n;
FILE *file;
{
  register int ch = 0;		/* initialize is quick fix for case n = 1 */
  register char *ptr;

  if (n == 0) return(str);	/* aagghh, quick fix for case n = 0 */
  ptr = str;
  while (--n > 0 && (ch = getc(file)) != EOF) {
	*ptr++ = ch;
	if (ch == '\n') break;
  }
  if (ch == EOF && ptr == str) return((char *)NULL);
  *ptr = '\0';
  return(str);
}
