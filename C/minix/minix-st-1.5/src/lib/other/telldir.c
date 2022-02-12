#include <lib.h>
/* telldir -- report directory stream position	Author: D.A. Gwyn */

/*	last edit:	25-Apr-1987	D A Gwyn	*/

#include	<errno.h>
#include	<sys/types.h>
#include	<limits.h>
#include	<dirent.h>
#include 	<unistd.h>

#define DULL (DIR *) 0

#ifndef SEEK_CUR
#define	SEEK_CUR	1
#endif

off_t telldir(dirp)		/* return offset of next entry */
DIR *dirp;			/* stream from opendir() */
{
  if (dirp == DULL || dirp->dd_buf == (char *)NULL || dirp->dd_magic != _DIR_MAGIC)
	if (dirp == DULL || dirp->dd_buf == (char *) NULL) {
		errno = EBADF;
		return(-1);	/* invalid pointer */
	}
  if (dirp->dd_loc < dirp->dd_size)	/* valid index */
	return(((struct dirent *) & dirp->dd_buf[dirp->dd_loc])->d_off);
  else				/* beginning of next directory block */
	return(lseek(dirp->dd_fd, (off_t) 0, SEEK_CUR));
}
