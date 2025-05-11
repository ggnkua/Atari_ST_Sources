/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 *  Tries to emulate unix open3.  The mode argument is ignored, and O_NDELAY
 * doesn't do anything.  Also O_APPEND does not garentee that things will
 * be written to the end - all we can do is seek to the end to start with.
 *
 * $Header: open.c,v 1.2 88/01/29 17:31:36 m68k Exp $
 *
 * $Log:	open.c,v $
 *
 * Modified by jrd for native gcc 1.2
 *
 * Revision 1.2  88/02/24  17:31:36  m68k
 * 
 */
#include	<types.h>
#include	<file.h>
#include	<errno.h>
#include	<osbind.h>

#ifdef DEBUG
extern int stderr;
#endif

int open(path, flags, mode)
char	* path;
short	flags;
u_short	mode;
{
  int		fd;
  int		exists;
  extern	int	errno;

  switch (flags & 0x3) 
	{
	case O_RDONLY:
		fd = Fopen(path, O_RDONLY);
		break;

	case O_WRONLY:
	case O_RDWR:
		fd = 0;
		exists = Fattrib(path, 0, 0) >= 0;
		if (flags & O_CREAT) 
			{
			if ((flags & O_EXCL) && exists)
				fd = EEXIST;
			}
		    else
			if (!exists)
				fd = ENOENT;
		if (!fd) 
			{
			if ((flags & O_TRUNC) || !exists) 
				{
				if ((fd = Fcreate(path, 0)) >= 0
					&& (flags & 0x3) == O_RDWR)
					{
					(void) close(fd);
					fd = Fopen(path, O_RDWR);
					}
				}
			    else
			if ((fd = Fopen(path, flags & 0x3)) >= 0
				&& (flags & O_APPEND))
					(void) Fseek(0L, fd, L_XTND);
			}
		break;

	default:
		fd = EINVAL;
	}
  if (fd < 0) 
	{
	errno = fd;
	fd = -1;
	}
#ifdef DEBUG
fprintf(stderr, "open('%s', %X)->%d\n", path, flags, fd);
#endif
  return fd;
}
