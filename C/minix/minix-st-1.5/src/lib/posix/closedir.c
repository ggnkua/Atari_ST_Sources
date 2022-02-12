/* closedir -- close a directory stream		Author: D.A. Gwyn */

/*	last edit:	11-Nov-1988	D A Gwyn	*/

#include <stddef.h>
#include <errno.h>
#include <sys/types.h>
#include <limits.h>
#include <dirent.h>
#include <stdlib.h>
#include <unistd.h>

typedef char *pointer;		/* (void *) if you have it */

#define DULL (DIR *) NULL
#define CULL (char *) NULL

int closedir(dirp)
register DIR *dirp;		/* stream from opendir() */
{
  register int fd;

  if (dirp == DULL || dirp->dd_buf == CULL || dirp->dd_magic != _DIR_MAGIC) {
	errno = EBADF;
	return(-1);		/* invalid pointer */
  }
  fd = dirp->dd_fd;		/* bug fix thanks to R. Salz */
  dirp->dd_magic = 0;		/* invalidate the entry */
  free((pointer) dirp->dd_buf);
  free((pointer) dirp);
  return(close(fd));
}
