/* readdir -- read next entry from a directory stream	Author: D.A. Gwyn */

/*	last edit:	25-Apr-1987	D A Gwyn	*/

#include <lib.h>
#include <dirent.h>
#include <stddef.h>

extern int getdents();		/* SVR3 system call, or emulation */

#define DULL (DIR *) NULL
#define CULL (char *) NULL

struct dirent *readdir(dirp)
register DIR *dirp;		/* stream from opendir() */
{
  register struct dirent *dp;	/* -> directory data */

  if (dirp == DULL || dirp->dd_buf == CULL || dirp->dd_magic != _DIR_MAGIC) {
	errno = EBADF;
	return( (struct dirent *) NULL);	/* invalid pointer */
  }

  do {
	if (dirp->dd_loc >= dirp->dd_size)	/* empty or obsolete */
		dirp->dd_loc = dirp->dd_size = 0;

	if (dirp->dd_size == 0	/* need to refill buffer */
	    && (dirp->dd_size =
	     getdents(dirp->dd_fd, dirp->dd_buf, (unsigned) _DIRBUF)) <= 0)
		return((struct dirent *) NULL);	/* EOF or error */

	dp = (struct dirent *) & dirp->dd_buf[dirp->dd_loc];
	dirp->dd_loc += dp->d_reclen;
  }
  while (dp->d_ino == 0);	/* don't rely on getdents() */

  return(dp);
}
