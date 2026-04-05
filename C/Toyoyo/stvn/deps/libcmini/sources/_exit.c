#include <unistd.h>
#include <stdlib.h>
#include <mint/osbind.h>

void _exit(int status)
{
	Pterm(status);
	__builtin_unreachable();
}

#ifdef __GNUC__
void _Exit(int status) __attribute__((alias("_exit")));
#endif
