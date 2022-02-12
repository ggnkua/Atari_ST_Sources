#include <lib.h>
/* Get next token from string s (NULL on 2nd, 3rd, etc. calls),
 * where tokens are nonempty strings separated by runs of
 * chars from delim.  Writes NULs into s to end tokens.  delim need not
 * remain constant from call to call.
 */

#include <string.h>

#define C_NULL  (char *) NULL

PRIVATE char *scanpoint = C_NULL;

char *strtok(s, delim)		/* NULL if no token left */
char *s;
register _CONST char *delim;
{
  register char *scan;
  char *tok;
  register _CONST char *dscan;

  if (s == C_NULL && scanpoint == C_NULL) return(C_NULL);
  if (s != C_NULL)
	scan = s;
  else
	scan = scanpoint;

  /* Scan leading delimiters. */
  for (; *scan != '\0'; scan++) {
	for (dscan = delim; *dscan != '\0'; dscan++)
		if (*scan == *dscan) break;
	if (*dscan == '\0') break;
  }
  if (*scan == '\0') {
	scanpoint = C_NULL;
	return(C_NULL);
  }
  tok = scan;

  /* Scan token. */
  for (; *scan != '\0'; scan++) {
	for (dscan = delim; *dscan != '\0';)	/* ++ moved down. */
		if (*scan == *dscan++) {
			scanpoint = scan + 1;
			*scan = '\0';
			return(tok);
		}
  }

  /* Reached end of string. */
  scanpoint = C_NULL;
  return(tok);
}
