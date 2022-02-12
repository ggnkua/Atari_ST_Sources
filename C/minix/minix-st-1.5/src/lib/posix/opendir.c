/* opendir -- open a directory stream	Author: D.A. Gwyn */

/*	last edit:	27-Oct-1988	D A Gwyn	*/

#include <lib.h>
#include <sys/stat.h>
#include <dirent.h>
#include <unistd.h>
#include <stdlib.h>
#include <fcntl.h>

#define DULL (DIR *) 0
#define CULL (char *) 0

typedef char *pointer;		/* (void *) if you have it */

#ifndef O_RDONLY
#define	O_RDONLY	0
#endif

#ifndef S_ISDIR			/* macro to test for directory file */
#define	S_ISDIR( mode )		(((mode) & S_IFMT) == S_IFDIR)
#endif

DIR *opendir(dirname)
char *dirname;			/* name of directory */
{
  register DIR *dirp;		/* -> malloc'ed storage */
  register int fd;		/* file descriptor for read */

  /* The following is PRIVATE just to keep the stack small. */
  PRIVATE struct stat sbuf;	/* result of fstat() */

  if ((fd = open(dirname, O_RDONLY)) < 0)
	return(DULL);		/* errno set by open() */

  if (fstat(fd, &sbuf) != 0 || !S_ISDIR(sbuf.st_mode)) {
	(void) close(fd);
	errno = ENOTDIR;
	return(DULL);		/* not a directory */
  }
  if ((dirp = (DIR *) malloc(sizeof(DIR))) == DULL
      || (dirp->dd_buf = (char *) malloc((unsigned) _DIRBUF)) == CULL){
	register int serrno = errno;
	/* Errno set to ENOMEM by sbrk() */

	if (dirp != (DIR *) DULL) free((pointer) dirp);

	(void) close(fd);
	errno = serrno;
	return(DULL);		/* not enough memory */
  }
  dirp->dd_fd = fd;
  dirp->dd_magic = _DIR_MAGIC;	/* to recognize DIRs */
  dirp->dd_loc = dirp->dd_size = 0;	/* refill needed */

  return(dirp);
}
