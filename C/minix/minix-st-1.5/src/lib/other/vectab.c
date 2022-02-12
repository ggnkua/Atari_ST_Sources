#include <lib.h>
#include <signal.h>

void (*__vectab[_NSIG]) ();	/* array of funcs to catch signals */
