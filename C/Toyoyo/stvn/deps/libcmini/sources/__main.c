#include <stdlib.h>
#include "lib.h"

#ifdef __GCC_HAVE_INITFINI_ARRAY_SUPPORT

/*
 * Support for the init/fini initialization mechanism.
 * Inspired from glibc's csu/libc-start.c.
 * https://sourceware.org/git/?p=glibc.git;f=csu/libc-start.c;hb=refs/heads/master
 */

/* These magic symbols are provided by the linker.  */
extern void (*__preinit_array_start [])(int, char **, char **);
extern void (*__preinit_array_end [])(int, char **, char **);
extern void (*__init_array_start [])(int, char **, char **);
extern void (*__init_array_end [])(int, char **, char **);
extern void (*__fini_array_start [])(void);
extern void (*__fini_array_end [])(void);

/* Call global initializers/constructors.  */
static void
call_init(int argc, char **argv, char **envp)
{
	size_t size;
	size_t i;

	/* Preinitializers come from the .preinit_array sections.  */
	size = __preinit_array_end - __preinit_array_start;
	for (i = 0; i < size; i++)
		(*__preinit_array_start [i])(argc, argv, envp);

	/* Modern systems don't require the .init section.  */
	/*_init();*/

	/* Initializers come from the .init_array sections.  */
	size = __init_array_end - __init_array_start;
	for (i = 0; i < size; i++)
		(*__init_array_start [i])(argc, argv, envp);
}

/* Call global finalizers/destructors.  */
static void
call_fini(void)
{
	/* Finalizers come from the .fini_array sections.  */
	size_t i = __fini_array_end - __fini_array_start;
	while (i-- > 0)
		(*__fini_array_start [i])();

	/* Modern systems don't require the .fini section.  */
	/*_fini();*/
}

void __main(void)
{
	atexit(call_fini);
	call_init(__libc_argc, __libc_argv, environ);
}

#endif /* __GCC_HAVE_INITFINI_ARRAY_SUPPORT */
