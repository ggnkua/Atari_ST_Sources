/*
 * standard "print error message" function
 */

#include <stdio.h>
#include <errno.h>

#define	SYS_NERR	(-101)

static char nullstr[] = "";

int	sys_nerr = SYS_NERR;

static char *_errlist[1 - SYS_NERR] =
	{
	"file already exists",			/* 101 */
	"domain error",				/* 100 */
	nullstr,				/* 99 */
	nullstr,				/* 98 */
	nullstr,				/* 97 */
	nullstr,				/* 96 */
	nullstr,				/* 95 */
	nullstr,				/* 94 */
	nullstr,				/* 93 */
	nullstr,				/* 92 */
	nullstr,				/* 91 */
	nullstr,				/* 90 */
	nullstr,				/* 89 */
	nullstr,				/* 88 */
	nullstr,				/* 87 */
	nullstr,				/* 86 */
	nullstr,				/* 85 */
	nullstr,				/* 84 */
	nullstr,				/* 83 */
	nullstr,				/* 82 */
	nullstr,				/* 81 */
	nullstr,				/* 80 */
	nullstr,				/* 79 */
	nullstr,				/* 78 */
	nullstr,				/* 77 */
	nullstr,				/* 76 */
	nullstr,				/* 75 */
	nullstr,				/* 74 */
	nullstr,				/* 73 */
	nullstr,				/* 72 */
	nullstr,				/* 71 */
	nullstr,				/* 70 */
	nullstr,				/* 69 */
	nullstr,				/* 68 */
	"memory block growth failure",		/* 67 */
	"bad executable format",		/* 66 */
	"internal error",			/* 65 */
	"range error",				/* 64 */
	nullstr,				/* 63 */
	nullstr,				/* 62 */
	nullstr,				/* 61 */
	nullstr,				/* 60 */
	nullstr,				/* 59 */
	nullstr,				/* 58 */
	nullstr,				/* 57 */
	nullstr,				/* 56 */
	nullstr,				/* 55 */
	nullstr,				/* 54 */
	nullstr,				/* 53 */
	nullstr,				/* 52 */
	nullstr,				/* 51 */
	nullstr,				/* 50 */
	"no more files",			/* 49 */
	"rename across drives",			/* 48 */
	nullstr,				/* 47 */
	"invalid drive id",			/* 46 */
	nullstr,				/* 45 */
	nullstr,				/* 44 */
	nullstr,				/* 43 */
	nullstr,				/* 42 */
	nullstr,				/* 41 */
	"invalid memory block",			/* 40 */
	"out of memory",			/* 39 */
	nullstr,				/* 38 */
	"invalid handle",			/* 37 */
	"access denied",			/* 36 */
	"no more handles",			/* 35 */
	"path not found",			/* 34 */
	"file not found",			/* 33 */
	"invalid function number",		/* 32 */
	nullstr,				/* 31 */
	nullstr,				/* 30 */
	nullstr,				/* 29 */
	nullstr,				/* 28 */
	nullstr,				/* 27 */
	nullstr,				/* 26 */
	nullstr,				/* 25 */
	nullstr,				/* 24 */
	nullstr,				/* 23 */
	nullstr,				/* 22 */
	nullstr,				/* 21 */
	nullstr,				/* 20 */
	nullstr,				/* 19 */
	nullstr,				/* 18 */
	"disk swap request",			/* 17 */
	"bad sectors on format",		/* 16 */
	"unknown device",			/* 15 */
	"media changed",			/* 14 */
	"media write protected",		/* 13 */
	nullstr,				/* 12 */
	"read failure",				/* 11 */
	"write failure",			/* 10 */
	"out of paper",				/* 9 */
	"sector not found",			/* 8 */
	"unknown media",			/* 7 */
	"seek error",				/* 6 */
	"bad request",				/* 5 */
	"crc error",				/* 4 */
	"unknown command",			/* 3 */
	"drive not ready",			/* 2 */
	"error",				/* 1 */
	"OK"
	};

char	**sys_errlist = &_errlist[-SYS_NERR];

char *strerror(err)
	int err;
	{
	if(is_syserr(err))
		return(sys_errlist[err]);
	return(NULL);
	}

void perror(msg)
	char *msg;
	{
	if(msg && *msg)
		{
		fputs(msg, stderr);
		fputs(": ", stderr);
		}
	if(msg = strerror(errno))
		fputs(msg, stderr);
	fputs(".\n", stderr);
	}
