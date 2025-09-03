/* 18.05.90 modified by Jan Bolt */
#include <osbind.h>
#include <stdio.h>
#include <errno.h>
#include <malloc.h>
#include <string.h>
#include <basepage.h>

static char delim[] = " \t\r\n";

static cnt_args(cmdln)
	char *cmdln;
	{
	register char *p;
	register int cnt = 0;

	p = cmdln;
	while (strtok(p, delim))
		 {
		 cnt++;
		 p = NULL;
		 }
	return cnt;
	}

static parse_args(cmdln, argv)
	char *cmdln;
	register char *argv[];
	{
	register char *p;

	p = cmdln;
	while (*argv++ = strtok(p, delim))
		 p = NULL;
	}

int system(command)
	register char *command;
	{
	register char *p;
	char *cmdln;
	char **args;
	register int (*shell)();
	char rv[2];
	char *getenv();

	if(!command)
		return(ERROR);

	/* get _shell_p value */
	p = (char *) Super(0L);
	shell = (int (*)()) *((long *) 0x4F6L);
	Super(p);

	/* validate _shell_p */
	if((shell) &&				/* Shell available. */
	   (((long) shell) < ((long) _base)) && /* Reasonable shell pointer. */
	   (strncmp(shell, "PATH", 4)))		/* Not corrupted */
		{
		/* execute the command */
#ifdef DEBUG
_COOKIE("system: using _shell_p");
#endif
		return((*shell)(command));
		}

	/* copy command line and allocate memory for argument list */
	if ((cmdln=malloc(strlen(command)+1)) == NULL)
	   return ENSMEM;
	strcpy(cmdln, command);
	if ((args=(char **)malloc((cnt_args(cmdln)+2)*sizeof(char *))) == NULL)
	   return ENSMEM;
	strcpy(cmdln, command); /* restore command line */

	if((p = getenv("SHELL")) && (*p))	/* SHELL= variable? */
		{
		args[0] = p;
		parse_args(cmdln, (args + 1));
#ifdef DEBUG
_COOKIE("system: executing SHELL");
_COOKIE(p);
#endif
		}
	else /* attempt to find first token as a program on the path */
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
	free(cmdln);
	free(args);
	return((rv[1] == 0) ? rv[0] : rv[1]);
	}

