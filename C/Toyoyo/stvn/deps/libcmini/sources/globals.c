#include "lib.h"

/* globals */

#ifdef __GNUC__

/*
 * For Pure-C, these variables are defined in the startup module
 */

short _app = 1;
unsigned long _PgmSize;
BASEPAGE *_base=0;
/* BasPag for libcmini compatibility */
extern BASEPAGE *_BasPag __attribute__((alias("_base")));

int errno;

char **environ;
long __libc_argc = 1;

static char *__libc_argv_default[] = { "unknown application", NULL };
char **__libc_argv = __libc_argv_default;

#endif
