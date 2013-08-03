/*
 * sysconf() and pathconf() for TOS/MiNT (kinda POSIXy)
 * Written by Dave Gymer and placed in the Public Domain
 *
 * NOTE: this file will have to be updated as and when MiNT gains
 * new Sysconf() and Dpathconf() variables, as will unistd.h, so that
 * TOS programs get the correct values back. (But who uses TOS? :-)
 */

#include <unistd.h>
#include <mintbind.h>
#include <errno.h>
#include <limits.h>
#ifndef _COMPILER_H
#include <compiler.h>		/* ++ ers */
#endif
#include "lib.h"

#define UNLIMITED	(0x7fffffffL)

long
sysconf(var)
	int var;
{
	long r;

	r = Sysconf(var);
	if (r != -EINVAL)
		return r;

	switch(var) {
	case _SC_LAST:
		return 4;
	case _SC_MEMR_MAX:
		return UNLIMITED; /* not true for TOS < 1.4 :-( */
	case _SC_ARG_MAX:
		return 127; /* ignore this, cuz we can pass via the env */
	case _SC_OPEN_MAX:
		return 45; /* think I read this somewhere */
	case _SC_NGROUPS_MAX:
		return 0; /* this is bad news :-( */
	case _SC_CHILD_MAX:
		return UNLIMITED; /* good 'ol TOS :-) */
	default:
		return EINVAL;
	}
}

long
pathconf(_path, var)
	const char *_path;
	int var;
{
	long r;
	char path[PATH_MAX];

	_unx2dos (_path, path);
	r = Dpathconf(path, var);
	if (r != -EINVAL) {
		if (var == _PC_NO_TRUNC)
			return r ? -1 : 0;
		return r;
	}
	switch(var) {
	case _PC_LAST:
		return 4;
	case _PC_IOPEN_MAX:
		return 45; /* -ish, maybe... */
	case _PC_LINK_MAX:
		return 1;
	case _PC_PATH_MAX:
		return 128; /* I'm sure I read that this is 64 in TOS 1.0 */
	case _PC_NAME_MAX:
		return 12;
	case _PC_NO_TRUNC:
		return -1;  /* file names are automatically truncated */
	default: /* note that _PC_PIPE_BUF is invalid */
		return EINVAL;
	}
}
