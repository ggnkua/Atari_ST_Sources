#include <stdio.h>
#include <stdarg.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#ifndef	_BITS_TYPES_H
#define	_BITS_TYPES_H	1
#endif
#include <sys/stat.h>
#include <mint/osbind.h>
#include <mint/mintbind.h>
#include "lib.h"

#ifndef _REALO_NOATIME
#define _REALO_NOATIME    0x000004               /* Do not set atime.  */
#endif
#ifndef _REALO_APPEND
#define _REALO_APPEND     0x000008               /* this is what MiNT uses */
#endif
#ifndef _REALO_NOINHERIT
#define _REALO_NOINHERIT  0x000080                /* this is what MiNT uses */
#endif
#ifndef _REALO_NDELAY
#define _REALO_NDELAY     0x000100               /* this is what MiNT uses */
#endif
#ifndef _REALO_CREAT
#define _REALO_CREAT      0x000200               /* create new file if needed */
#endif
#ifndef _REALO_TRUNC
#define _REALO_TRUNC      0x000400               /* make file 0 length */
#endif
#ifndef _REALO_EXCL
#define _REALO_EXCL       0x000800               /* error if file exists */
#endif
#ifndef _REALO_DIRECTORY
#define _REALO_DIRECTORY  0x010000UL
#endif
#ifndef _REALO_SYNC
#define _REALO_SYNC       0x000000       /* sync after writes (NYI) */
#endif
#define __O_NOINHERIT   _REALO_NOINHERIT
#undef _REALO_SHMODE
#define _REALO_SHMODE(mode) (((mode) & (O_SHMODE)) >> 4)
#ifndef __O_CLOEXEC
#define __O_CLOEXEC     0x100000UL
#endif
#ifndef FTRUNCATE
#define FTRUNCATE (('F'<< 8) | 4)
#endif


/*
 * from our flags, calculate the mode that
 * has to be passed to the OS
 */
static long __real_omode(long iomode)
{
	long realmode;						/* which bits get passed to the OS? */

	/* these are always identical */
	realmode = iomode & O_ACCMODE;

	/* now translate some emulated flags */
	if (iomode & O_SYNC)
		realmode |= _REALO_SYNC;
	if (iomode & O_NDELAY)
		realmode |= _REALO_NDELAY;
	if (iomode & O_TRUNC)
		realmode |= _REALO_TRUNC;
	if (iomode & O_CREAT)
		realmode |= _REALO_CREAT;
	if (iomode & O_APPEND)
		realmode |= _REALO_APPEND;
	if (iomode & O_EXCL)
		realmode |= _REALO_EXCL;

	if ((iomode & O_SHMODE) == O_COMPAT)
		realmode |= _REALO_SHMODE(O_DENYNONE);
	else
		realmode |= _REALO_SHMODE(iomode);

	if (iomode & O_NOATIME)
		realmode |= _REALO_NOATIME;
    if (iomode & O_DIRECTORY)
		realmode |= _REALO_DIRECTORY;
	if (iomode & __O_NOINHERIT)
		realmode |= _REALO_NOINHERIT;

	return realmode;
}



/*
 * it should be possible to call Fopen() on filenames like "PRN:", "CON:" and "AUX", but
 * it isn't neccessary since these file descriptors are always open (as -3, -1 and -2, respectively)
 */
static int _open_v(const char *_filename, int iomode, va_list argp)
{
	long rv;
	long realmode;						/* which bits get passed to the OS? */
	long fcbuf;							/* a temporary buffer for Fcntl */
	struct stat sb;
	unsigned int pmode = 0;
	const char *filename = _filename;

	if (!_filename)
	{
		__set_errno(EFAULT);
		return -1;
	}

	if (*_filename == '\0')
	{
		__set_errno(ENOENT);
		return -1;
	}

	if (iomode & O_CREAT)
		pmode = va_arg(argp, unsigned int);

	/* set the file access modes correctly */
	realmode = __real_omode(iomode);

	rv = -ENOSYS;
    if (iomode & O_NOFOLLOW)
		rv = Fstat64(1, filename, &sb);
	if (rv == -ENOSYS)
	{
		rv = stat(filename, &sb);
		if (rv != 0)
			rv = -errno;
	}

	if (rv == 0)						/* file exists */
	{
        if (S_ISLNK(sb.st_mode) && (iomode & O_NOFOLLOW))
		{
			__set_errno(ELOOP);
			return -1;
		}

		if (S_ISDIR(sb.st_mode))
		{
			__set_errno(EISDIR);
		} else
		{
            if (iomode & O_DIRECTORY)
			{
				__set_errno(ENOTDIR);
				return -1;
			}
		}

		if ((iomode & (O_CREAT | O_EXCL)) == (O_CREAT | O_EXCL))
		{
			__set_errno(EEXIST);
			return -1;
		}

		rv = Fopen(filename, realmode & ~_REALO_CREAT);
		if (rv == -ENOENT)
			/* race: file can disappear between stat and open... */
			goto noent;
		if ((iomode & O_TRUNC) && (rv >= 0))
		{
			/* Give up if the mode flags conflict */
			if ((iomode & O_ACCMODE) == O_RDONLY)
			{
				(void) Fclose((int) rv);
				__set_errno(EACCES);
				return -1;
			}
			/* Try the FTRUNCATE first.  If it fails, have GEMDOS
			   truncate it, then reopen with the correct modes.
			 */
			fcbuf = 0L;
			if (Fcntl((int) rv, (long) &fcbuf, FTRUNCATE) < 0)
			{
				(void) Fclose((int) rv);
				rv = Fcreate(filename, 0x00);
				if (rv < 0)
				{
					__set_errno(-rv);
					return -1;
				}
				(void) Fclose((int) rv);
				rv = Fopen(filename, realmode);
			}
		}
	} else								/* file doesn't exist */
	{
	  noent:
		if (iomode & O_CREAT)
		{
			/* posix requirement for trailing slash check */
			size_t len = strlen(filename);

			if (len > 0 && (filename[len - 1] == '/' || filename[len - 1] == '\\'))
			{
				__set_errno(EISDIR);
				return -1;
			}

			rv = Fopen(filename, realmode);
			if (rv == -ENOENT)
				rv = Fcreate(filename, 0x00);
			if (rv >= 0)
			{
				if (Ffchmod(rv, pmode) == -ENOSYS)
					(void) Fchmod(filename, pmode);
			}
		}
	}

	if (rv < 0)
	{
		__set_errno(-rv);
		return -1;
	}

	if (iomode & __O_CLOEXEC)
	{
		/* set the close-on-exec flag */
		fcbuf = Fcntl((int) rv, 0, F_GETFD);
		if ((fcbuf >= 0) && !(fcbuf & FD_CLOEXEC))
			(void) Fcntl((int) rv, fcbuf | FD_CLOEXEC, F_SETFD);
	}

	if (iomode & O_APPEND)
		(void) Fseek(0L, (int) rv, SEEK_END);

	return (int) rv;
}


int open(const char *filename, int access, ...)
{
    va_list args;
    int retval;

    va_start(args, access);
    retval = _open_v(filename, access, args);

    return retval;
}
