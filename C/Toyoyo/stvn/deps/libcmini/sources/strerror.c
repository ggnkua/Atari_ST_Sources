/*
 * strerror.c
 *
 *  Created on: 23.03.2014
 *      Author: ardi
 */

#include "lib.h"
#include <string.h>
#include <stdio.h>

#define ERR(s, o) s "\0"
#define NONE
static char const _sys_err_msgs[] = {
	"Unknown error" "\0"
#include "strerror.h"
};


#define ERR(s, o) o,
#define NONE 0,
static unsigned short const _sys_errlist_internal[] = {
#include "strerror.h"
};

/* Map error number to descriptive string.  */

static char unknown_error2[] = "Unknown error 0123456789";

#define SYS_NERR (unsigned int) (sizeof (_sys_errlist_internal) / sizeof (_sys_errlist_internal[0]))

char *strerror(int errnum)
{
	if ((unsigned int)errnum < SYS_NERR)
		return (char *) NO_CONST(&_sys_err_msgs[_sys_errlist_internal[errnum]]);
#ifdef __MINT__
	_ultoa(errnum, unknown_error2 + sizeof("Unknown error ") - 1, 10);
#else
	sprintf(unknown_error2 + sizeof("Unknown error ") - 1, "%u", errnum);
#endif
	return unknown_error2;
}


#ifdef MAIN

#define ERR(s, o) s,
#define NONE 0,
static const char *const _new_sys_errlist_internal[] = {
#include "strerror.h"
};

#undef SYS_NERR
#define SYS_NERR (unsigned int) (sizeof (_new_sys_errlist_internal) / sizeof (_new_sys_errlist_internal[0]))

int main(void)
{
	unsigned int i;
	unsigned int offset = sizeof("Unknown error");
	
	for (i = 0; i < SYS_NERR; i++)
	{
		printf("%u: %u: %s\n", i, offset, _new_sys_errlist_internal[i]);
		if (_new_sys_errlist_internal[i])
			offset += strlen(_new_sys_errlist_internal[i]) + 1;
	}
	return 0;
}
#endif
