/*************************************************************************
 *
 *  m a k e :   r e a d e r . c
 *
 *  Read in makefile
 *========================================================================
 * Edition history
 *
 *  #    Date                         Comments                       By
 * --- -------- ---------------------------------------------------- ---
 *   1    ??                                                         ??
 *   2 23.08.89 cast to NULL added                                   RAL
 *   3 30.08.89 indention changed                                    PSH,RAL
 *   4 03.09.89 fixed LZ eliminated                                  RAL
 * ------------ Version 2.0 released ------------------------------- RAL
 *
 *************************************************************************/

#include "h.h"


/*
 *	Syntax error handler.  Print message, with line number, and exits.
 */
void error(msg, a1)
char *msg;
char *a1;
{
  fprintf(stderr, "%s: ", myname);
  fprintf(stderr, msg, a1);
  if (lineno)  fprintf(stderr, " in %s near line %d", makefile, lineno);
  fputc('\n', stderr);
  exit(1);
}


/*
 *	Read a line into the supplied string.  Remove
 *	comments, ignore blank lines. Deal with	quoted (\) #, and
 *	quoted newlines.  If EOF return TRUE.
 *
 *	The comment handling code has been changed to leave comments and
 *	backslashes alone in shell commands (lines starting with a tab).
 *	This is not what POSIX wants, but what all makes do.  (KJB)
 */
bool getline(strs, fd)
struct str *strs;
FILE *fd;
{
  register char *p;
  char          *q;
  int            tmppos;

  strs->pos = 0;
  for (;;) {
	if (strs->pos >= strs->len -128)
		strrealloc(strs);
	if (fgets(*strs->ptr + strs->pos, strs->len - strs->pos, fd) == (char *)0)
		return TRUE;		/*  EOF  */

	lineno++;

	while ((p = strchr(*strs->ptr + strs->pos, '\n')) == (char *)0) {
		tmppos = strs->len -1;
		strrealloc(strs);
		if (fgets(*strs->ptr + tmppos, strs->len - tmppos, fd) == (char *)0)
			error("Unexpected EOF",(char *)0);
	}


	if (p[-1] == '\\')
	{
		p[-1] = '\n';
		strs->pos = p - *strs->ptr;
		continue;
	}

	p = q =  *strs->ptr;
	while (isspace(*q)) q++;
	if (*p != '\t' || *q == '#') {
		while (((q = strchr(p, '#')) != (char *)0) &&
		    (p != q) && (q[-1] == '\\'))
		{
			char	*a;

			a = q - 1;	/*  Del \ chr; move rest back  */
			p = q;
			while (*a++ = *q++)
				;
		}
		if (q != (char *)0)
			{
			q[0] = '\n';
			q[1] = '\0';
		}
	}

	p = *strs->ptr;
	while (isspace(*p))	/*  Checking for blank  */
		p++;

	if (*p != '\0')
		return FALSE;
	strs->pos = 0;
  }
}


/*
 *	Get a word from the current line, surounded by white space.
 *	return a pointer to it. String returned has no white spaces
 *	in it.
 */
char  *gettok(ptr)
register char **ptr;
{
  register char *p;


  while (isspace(**ptr))	/*  Skip spaces  */
	(*ptr)++;

  if (**ptr == '\0')	/*  Nothing after spaces  */
	return ((char *)NULL);

  p = *ptr;		/*  word starts here  */

  while ((**ptr != '\0') && (!isspace(**ptr)))
	(*ptr)++;	/*  Find end of word  */

  *(*ptr)++ = '\0';	/*  Terminate it  */

  return(p);
}
