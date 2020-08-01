/*
 * random stuff for atariST
 */

#include "EXTERN.h"
#include "perl.h"
#include <process.h>

long _stksize = 64*1024L;
unsigned long __DEFAULT_BUFSIZ__ = 8 * 1024L;

/*
 * The following code is based on the do_exec and do_aexec functions
 * in file doio.c
 */
int
do_aspawn(really,arglast)
STR *really;
int *arglast;
{
    register STR **st = stack->ary_array;
    register int sp = arglast[1];
    register int items = arglast[2] - sp;
    register char **a;
    char **argv;
    char *tmps;
    int status;

    if (items) {
	New(1101,argv, items+1, char*);
	a = argv;
	for (st += ++sp; items > 0; items--,st++) {
	    if (*st)
		*a++ = str_get(*st);
	    else
		*a++ = "";
	}
	*a = Nullch;
	if (really && *(tmps = str_get(really)))
	    status = spawnvp(-P_WAIT,tmps,argv); /* -P_WAIT is a hack, see spawnvp.c in the lib */
	else
	    status = spawnvp(-P_WAIT,argv[0],argv);
	Safefree(argv);
    }
    return status;
}


int
do_spawn(cmd)
char *cmd;
{
    return system(cmd);
}

int userinit()
{
    install_null();	/* install device /dev/null or NUL: */
    return 0;
}

#ifdef HAS_SYSCALL
int syscall()
{
  /* for now */
  return 0;
}
#endif
