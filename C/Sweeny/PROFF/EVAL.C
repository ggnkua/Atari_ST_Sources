#include <stdio.h>
#include <ctype.h>
#include "proff.h"
#include "debug.h"


/*
 * eval - evaluate defined command (push back definition)
 *
 */
eval(buf,defn)
char buf[];
char defn[];
{
	register int j,k;
	int i;
	int argptr[10];

	for (i = 0; i < 10 ; i++)
		argptr[i] = 0;

	buf[0] = '\0';		/* buf[0] is cchar */
	dprintf(defn);
	dprintf("eval  ");
	i = 1;
	argptr[0] = 1;		/* first parm is macro name */
	while (buf[i] != ' ' && buf[i] != '\t' &&
	    buf[i] != '\n' && buf[i] != '\0')
		i++;
	buf[i++] = '\0';		/* EOS terminate */
	/*
	 * start scanning remaining macro parameters.
	 * delimiters are blanks or commas. Any string
	 * enclosed with double quotes are accepted as
	 * parameters as well
	 *
	 */
	for (j = 1; j < 10; j++) {
		skipbl(buf, &i);
		if (buf[i] == '\n' || buf[i] == '\0')
			break;
		argptr[j] = i;
		while (buf[i] != ' ' && buf[i] != '\t' &&
		    buf[i] != ',' && buf[i] != '\n' && buf[i] != '\0')
			i++;
		buf[i] = '\0';
		i++;
	}
	for (k = strlen(defn) - 1; k >= 0; k--)
		if (defn[k-1] != ARGFLAG)
			putbak(defn[k]);
		else {
			if (defn[k] < '0' || defn[k] > '9')
				putbak(defn[k]);
			else {
				i = defn[k] - '0';
				i = argptr[i];
				pbstr(&buf[i]);
				k--;		/* skip over $ */
			}
		}
	if (k = 0)	/* do the last character */
		putbak(defn[k]);
}

