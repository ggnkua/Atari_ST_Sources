#include <stdio.h>
#include "as.h"

/*
 *  Error messages
 *
 *    error(string)
 *    errors(string1, string2)
 *    errord(string, longint)
 *
 *    warn(string)
 *
 *    fatal(string)
 *    interror(string)
 *
 *  For `errors' and `errord' the first strings are passed to
 *  printf(), the second argument will appear where `%' format
 *  is specified in the string.
 *
 *  Error messages are printed in the form:
 *
 *	"<filename>", line <number>: <message>
 *
 *  This message format should not be changed, as some tools depend on
 *  it for parsing error messages.
 *
 */
#define EBUFSIZ	200		/* max size of an error message */


/*
 *  Imports
 */
extern char *firstfname;
extern char *curfname;
extern int curlineno;
extern int cfileno;
extern int err_fd;
extern int err_flag;
extern char *err_fname;
extern int listing;		/* > 0, doing a listing */


/*
 *  Locals
 */
int errcnt;

#ifdef ST
static char nl[] = "\r\n";
#endif

#ifdef UNIX
static char nl[] = "\n";
#endif



error(s)
char *s;
{
	char buf[EBUFSIZ];

	err_setup();
	if (listing > 0) ship_ln(s);
	sprintf(buf, "\"%s\", line %d: %s%s", curfname, curlineno, s, nl);
	write(err_fd, buf, (LONG)strlen(buf));
	taglist('E');
	++errcnt;

	return ERROR;
}


errors(s, s1)
char *s;
char *s1;
{
	char buf[EBUFSIZ];
	char buf1[EBUFSIZ];

	err_setup();
	sprintf(buf, s, s1);
	if (listing > 0) ship_ln(buf);
	sprintf(buf1, "\"%s\", line %d: %s%s", curfname, curlineno, buf, nl);
	write(err_fd, buf1, (LONG)strlen(buf1));
	taglist('E');
	++errcnt;

	return ERROR;
}


warn(s)
char *s;
{
	char buf[EBUFSIZ];

	err_setup();
	if (listing > 0) ship_ln(s);
	sprintf(buf, "\"%s\", line %d: warning: %s%s", curfname, curlineno, s, nl);
	write(err_fd, buf, (LONG)strlen(buf));
	taglist('W');

	return OK;
}


fatal(s)
char *s;
{
	char buf[EBUFSIZ];

	err_setup();
	if (listing > 0) ship_ln(s);
	sprintf(buf, "\"%s\", line %d: Fatal error: %s%s",
			curfname, curlineno, s, nl);
	write(err_fd, buf, (LONG)strlen(buf));

	exit(1);
}


interror(n)
int n;
{
	char buf[EBUFSIZ];

	err_setup();
	sprintf(buf, "\"%s\", line %d: Internal error number %d%s",
			curfname, curlineno, n, nl);
	if (listing > 0) ship_ln(buf);
	write(err_fd, buf, (LONG)strlen(buf));

	exit(1);
}


/*
 *  Setup for error message
 *
 *    o  create error listing file (if necessary)
 *    o  set current filename
 *
 */
err_setup()
{
	char fnbuf[FNSIZ];

	setfnum(cfileno);
	if (err_fname != NULL)
	{
		strcpy(fnbuf, err_fname);
		if (*fnbuf == EOS)
		{
			strcpy(fnbuf, firstfname);
			fext(fnbuf, ".err", 1);
		}
		err_fname = NULL;

		if ((err_fd = creat(fnbuf, CREATMASK)) < 0)
			cantcreat(fnbuf);
		err_flag = 1;
	}
}
