#include <lib.h>
#include <errno.h>
#include <sys/types.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <stdio.h>

typedef enum {
  False, True
} BOOLEAN;

#define LOCKDIR "/tmp/"		/* or /usr/tmp/ as the case may be */
#define MAXTRIES 3
#define NAPTIME (unsigned int)5

PRIVATE _PROTOTYPE( char *lockpath, (char *name));

BOOLEAN lock(name)		/* acquire lock */
char *name;
{
  char *path;
  int fd, tries;

  path = lockpath(name);
  tries = 0;
  while ((fd = creat(path, 0)) == -1 && errno == EACCES) {
	if (++tries >= MAXTRIES) return(False);
	sleep(NAPTIME);
  }
  if (fd == -1 || close(fd) == -1) {
	fprintf(stderr, "lock failed\n");
	exit(1);
  }
  return(True);
}

void unlock(name)		/* free lock */
char *name;
{
  if (unlink(lockpath(name)) == -1) syserr("unlock");
}

PRIVATE char *lockpath(name)	/* generate lock file path */
char *name;
{
  PRIVATE char path[20];

  strcpy(path, LOCKDIR);
  return(strcat(path, name));
}
