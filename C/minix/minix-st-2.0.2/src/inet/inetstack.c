#include <minix/config.h>

#if (MACHINE == ATARI)

#if 0		/* not needed any more */
#define INET_STACK_BYTES 4096

char inet_stack[INET_STACK_BYTES];

char *stackpt = &inet_stack[INET_STACK_BYTES];
#endif

#endif /* MACHINE == ATARI */
