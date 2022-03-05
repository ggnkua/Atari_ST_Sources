#include <osbind.h>
#include <stdio.h>
#include <string.h>
#include <basepage.h>

static parse_args(cmdln, argv)
	char *cmdln;
	register char *argv[];
	{
	register char *p;
	static char delim[] = " \t\r\n";

	if(p = strtok(cmdln, delim))
		{
		do
			{
			*argv++ = p;
			}
			while(p = strtok(NULL, delim));
		}
	}

int system(command)
	register char *command;
	{
	register char *p;
	register int (*shell)();
	char rv[2];
	char cmdln[1024];
	char *args[64];
	char *getenv();

	if(!command)
		return(ERROR);

	/* get _shell_p value */
	p = (char *) Super(0L);
	shell = (int (*)()) *((long *) 0x4F6L);
	Super(p);

	/* validate _shell_p */
	if((shell) &&				/* Shell available. */
	   (((long) shell) < ((long) _base)) &&	/* Reasonable shell pointer. */
	   (strncmp(shell, "PATH", 4)))		/* Not corrupted */
		{
		/* execute the command */
#ifdef DEBUG
_COOKIE("system: using _shell_p");
#endif
		return((*shell)(command));
		}

	strcpy(cmdln, command);	/* copy the command line for parsing */

	if((p = getenv("SHELL")) && (*p))	/* SHELL= variable? */
		{
		args[0] = p;
		parse_args(cmdln, (args + 1));
#ifdef DEBUG
_COOKIE("system: executing SHELL");
_COOKIE(p);
#endif
		}
	else	/* attempt to find first token as a program on the path */
		{
		parse_args(cmdln, args);
		p = args[0];
#ifdef DEBUG
_COOKIE("system: directly executing program");
_COOKIE(p);
#endif
		}

	forkvpe(p, args, NULL);
	wait(rv);
	return((rv[1] == 0) ? rv[0] : rv[1]);
	}
