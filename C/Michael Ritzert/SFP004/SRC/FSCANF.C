/* from Dale Schumacher's dLibs */

#define __SRC__	/* to keep compiler happy about proto */
#include <stdio.h>

extern int fgetc(), fungetc();

fscanf(fp, fmt, arg)
	FILE *fp;
	const char *fmt;
	char *arg;
	{
	return(_scanf(fp, fgetc, fungetc, fmt, &arg));
	}

scanf(fmt, arg)
	const char *fmt;
	char *arg;
	{
	return(_scanf(stdin, fgetc, fungetc, fmt, &arg));
	}
