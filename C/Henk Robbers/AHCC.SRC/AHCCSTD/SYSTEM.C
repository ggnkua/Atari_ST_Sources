#include <tos.h>
#include <stdio.h>
#include <string.h>
#include <basepage.h>

static void parse_args(char *cmdln, char *argv[])
{
	static char delim[] = " \t\r\n";
	char *p = strtok(cmdln, delim);

	while (p)
	{
		*argv++ = p;
		p = strtok(NULL, delim);
	}
}

typedef int Shell(char *);

int system(char *command)
{
	char *p;
	Shell *shell;
	char rv[2];
	char cmdln[1024];
	char *args[64];
	char *getenv();

	if(!command)
		return(ERROR);

	/* get _shell_p value */
	p = (char *) Super(0L);
	shell = (Shell *) 0x4F6L;
	Super(p);

	/* validate _shell_p */
	if(   shell									/* Shell available. */
	   && (long) shell < (long) _base			/* Reasonable shell pointer. */
	   && strncmp((char *)shell, "PATH", 4)		/* Not corrupted */
	  )
		return shell(command);					/* execute the command */

	strcpy(cmdln, command);						/* copy the command line for parsing */

	if ((p = getenv("SHELL")) && *p)			/* SHELL= variable? */
	{
		args[0] = p;
		parse_args(cmdln, (args + 1));
	}
	else	/* attempt to find first token as a program on the path */
	{
		parse_args(cmdln, args);
		p = args[0];
	}

	forkvpe(p, args, NULL);
	wait(rv);
	return rv[1] == 0 ? rv[0] : rv[1];
}
