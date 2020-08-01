/*
syscall.c by David Roch
This routine translates some of the Berkely Unix (tm)
system calls to the Amiga.
Works on atari too.
*/

#include <stdio.h>
#include "syscall.h"
typedef unsigned int call_args;
syscall(n, arg1, arg2, arg3, arg4, arg5, arg6, arg7)
int	n;
call_args	arg1, arg2, arg3, arg4, arg5, arg6, arg7;
{
	switch (n) {

		case SYS_chdir:
			return(chdir(arg1));
		case SYS_chmod:
			return(chmod(arg1, arg2));
		case SYS_access:
			return(access(arg1, arg2));
		default:
			printf("System call %d has not yet been implemented in this port of SBProlog.\n",
				"If you wish to add this system primitive, you must add the proper case\n",
				"statement to the C source file syscall.c and recompile.\n");
			return(-1); /* command failed (hopefully) */
		}
}
