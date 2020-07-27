/*
 * getargs: interpret either MWC args or command-line args (if no MWC).
 *
 * USAGE:
 *	main(argc,argv)
 *	int argc;
 *	char *argv[];
 *	{
 *		getargs(&argc,&argv);
 *		... now process the args and run the program ...
 *	}
 *
 * Allows a max of NARGV arguments: normally 128 is sufficient.
 *
 * Call with *(&argc) != 0 if somebody has already parsed the command-
 * line arguments for you; in that case, if there aren't any
 * args in the environment, this procedure just returns
 * because the previous parser has already done its best. 
 *
 * Requires getenv().
 *
 * Clobbers the environment so children started from here will not
 * see ARGV= in their env (unless it's put there later).  This also
 * means you can't call getargs twice...
 *
 * Interprets the environment string like MWC does.
 *
 * Does NOT validate that the command-line length byte is 0x7f,
 * as msh makes it.  That isn't widely-enough spread yet.
 */

static char argcopy[128];

#define NARGV 256
static char *argv[NARGV];

getargs(p_argc,p_argv)
int *p_argc;
char ***p_argv;
{
    extern char *_base;
    char *getenv();
    register char *eptr;
    register int count = 0;
    char hold;

    if ((eptr = getenv("ARGV"))) {
	eptr += strlen(eptr) + 1;
	while (count < NARGV-1 && *eptr) {
	    argv[count++] = eptr;
	    eptr += strlen(eptr) + 1;
	}

	/* clobber "ARGV=" so environment ends there,	*/
	/* so children won't see these args in the env.	*/

	eptr = getenv("ARGV");
	while (*(--eptr) != 'A') ;
	*eptr = 0;
    }
    else {
	/* if we've already got args, don't do anything! */
    	if (*p_argc != 0) return *p_argc;
	count = *(_base+0x80);
	*(_base+0x81+count) = 0;
	strcpy(argcopy,_base+0x81);
	eptr = argcopy;
	argv[0] = "runtime";
	count = 1;
	while (1) {
	    while (*eptr == ' ') eptr++;	/* skip leading spaces */
	    if (!*eptr) break;			/* if end, quit */
	    argv[count++] = eptr;		/* not end: next arg */
	    while (*eptr && *eptr != ' ') eptr++;   /* skip nonwhite */
	    hold = *eptr;			/* save old value */
	    *eptr = 0;				/* null terminate */
	    if (!hold) break;			/* if old was null, end */
	    else eptr++;			/* else increment & loop */
	}
    }
    argv[count] = eptr;
    *p_argv = &argv[0];
    *p_argc = count;
    return count;
}

