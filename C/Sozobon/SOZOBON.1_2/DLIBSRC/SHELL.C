#include <osbind.h>
#include <stdio.h>

extern char	*_base;

void shell()
	{
	register char *p, *q;
	register int (*shell)();
	int rv = 0;
	char command[128];
	char *getenv(), *strtok(), *fullpath();
	int getch(), putch();

	/* SHELL= variable? */
	if((p = getenv("SHELL")) && (*p))	/* SHELL is valid? */
		{
		q = (char *) Super(0L);
		shell = (int (*)()) *((long *) 0x4F6L);	/* get _shell_p value */
		Super(q);
		if((shell) &&				/* shell available */
		   (((long) shell) < ((long) _base)) &&	/* reasonable value */
		   (strncmp(shell, "PATH", 4))) 	/* not corrupted */
			{
			rv = (*shell)(p);		/* call shell */
			return;
			}
		forklp(p, p, NULL);			/* execute shell */
		wait(&rv);
		return;
		}
	/* internal command line interface */
	for(;;)
		{
		cprintf("%s> ", fullpath(NULL, ""));	/* cwd as prompt */
		getln(NULL, getch, putch, command, 128);/* editable field */
		cputs("\r\n");
		if(command[0] == '\0')			/* ignore blank lines */
			continue;
		if(!stricmp(command, "exit"))		/* leave the shell */
			return;
		system(command);			/* execute a command */
		}
	}
