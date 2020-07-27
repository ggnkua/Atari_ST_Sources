#ifndef _COMPILER_H
#include <compiler.h>
#endif

#ifndef _OSBIND_H
#include <osbind.h>
#endif
#include <linea.h>

int errno;

__EXTERN __EXITING __exit __PROTO((long)); /* def in crt0.c */

void
_init_signal()
{
 /* NULL */
}


void
exit(status)
	int status;
{
    __exit((long)status);
}

void _main(argc, argv, environ)
	long argc;
	char **argv;
	char **environ;
{
    /* set up stderr */
#ifndef __MINT__
    (void)    Fforce(2,(int)Fdup(1));
#endif
    /* initialize lineA */
    (void)linea0();
    __exit((long)(main((int)argc, argv, environ)));
}
