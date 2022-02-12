/* rewinddir -- rewind a directory stream	Author: D.A. Gwyn */

/*	last edit:	25-Apr-1987	D A Gwyn

  This is not simply a call to seekdir(), because seekdir()
  will use the current buffer whenever possible and we need
  rewinddir() to forget about buffered data.
*/

#include <lib.h>
#include <dirent.h>
#include <unistd.h>

#define	DULL (DIR *) NULL
#define	CULL (char *) NULL

#ifndef SEEK_SET
#define	SEEK_SET	0
#endif

void rewinddir(dirp)
register DIR *dirp;		/* stream from opendir() */
{
  if (dirp == DULL || dirp->dd_buf == CULL || dirp->dd_magic != _DIR_MAGIC) {
	errno = EFAULT;
	return;			/* invalid pointer */
  }
  dirp->dd_loc = dirp->dd_size = 0;	/* invalidate buffer */
  (void) lseek(dirp->dd_fd, (off_t) 0, SEEK_SET);	/* may set errno */
}
