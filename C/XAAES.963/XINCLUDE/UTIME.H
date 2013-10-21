#ifndef _U_TIME_H
#define _U_TIME_H

#ifndef _COMPILER_H
#include <compiler.h>
#endif

#ifndef _TIME_T
# define __need_time_t
# include <time.h>
# undef __need_time_t
#endif

struct utimbuf {			/* type for times() call */
	time_t	actime;
	time_t	modtime;
};

int   utime (const char *path, const struct utimbuf *times);
int __utime (const char *path, const struct utimbuf *times);

#endif  /* _U_TIME_H */
