/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 *  The only thing that doesn't get filled in at all is st_ino - it really
 * should be a unique number for each file - any ideas?
 *
 * $Header: stat.c,v 1.2 88/01/29 17:31:52 m68k Exp $
 *
 * $Log:	stat.c,v $
 *
 * 1.2 jrd
 *
 * Revision 1.1  88/01/29  17:31:52  m68k
 * Initial revision
 * 
 */
#include	<types.h>
#include	<stat.h>
#include	<ctype.h>
#include	<errno.h>
#include	<osbind.h>
#include	<string.h>


int
stat(path, st)
	char		*path;
	struct stat	*st;
{
	int		rval;
	struct _dta	dtabuf;

	if (!path) {
		errno = EFAULT;
		return -1;
	}
	if (index(path, '*') || index(path, '?')) {
		errno = EPATH;
		return -1;
	}
	if ((rval = Fsetdta(&dtabuf)) < 0) {
		errno = rval;
		return -1;
	}
	if ((rval = Fsfirst(path, FA_SYSTEM|FA_HIDDEN|FA_DIR)) < 0) {
		errno = rval;
		return -1;
	}
	st->st_mode = dtabuf.dta_attribute & FA_DIR ?  S_IFDIR | 0777
		: (dtabuf.dta_attribute & FA_RDONLY ? S_IFREG | 0555
			: S_IFREG | 0777);
	st->st_ino = 0;		/* should be able to do better then this */
	if (*path && path[1] == ':')
		st->st_dev = islower(*path) ? *path - 'a' : *path - 'A';
	else
		st->st_dev = Dgetdrv();
	st->st_rdev = 0;
	st->st_nlink = 1;
	st->st_uid = 0;
	st->st_gid = 0;
	st->st_size = dtabuf.dta_size;
	st->st_blksize = 1024;
	st->st_blocks = (dtabuf.dta_size + 1023) / 1024;
	st->st_mtime = st->st_ctime = st->st_atime =
		(dtabuf.dta_date << 16) | dtabuf.dta_time;
	st->st_attr = dtabuf.dta_attribute;
	return 0;
}
