/*
 * extended (formatted) error print function
 */

#include <stdio.h>
#include <errno.h>
#include <stdarg.h>

extern	char	**_argv;

void perrorf(fmt)
	char *fmt;
	{
	register char *progname = _argv[0];
	char pbuf[10];
	register char *msg;
	va_list argp;

	_splitpath(progname, NULL, NULL, pbuf, NULL);
	fprintf(stderr, "%s: ", pbuf);
	if(fmt && *fmt)
		{
		va_start(argp, fmt);
		vfprintf(stderr, fmt, argp);
		va_end(argp);
		fputs(": ", stderr);
		}
	if(msg = strerror(errno))
		fputs(msg, stderr);
	fputs(".\n", stderr);
	}
