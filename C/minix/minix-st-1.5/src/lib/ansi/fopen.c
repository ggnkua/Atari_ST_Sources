#include <lib.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>

#define  PMODE    0666

/* HACK to get at statically allocated buffers to avoid leaking memory.
 * They should not have been public in the old version.
 */
extern char __stdin[];
extern char __stdout[];
extern struct _io_buf _stdin;
extern struct _io_buf _stdout;
extern struct _io_buf _stderr;

FILE *fopen(name, mode)
_CONST char *name, *mode;
{
  register int i;
  FILE *fp;
  int fd, flags = 0;

  for (i = 0; _io_table[i] != 0; i++)
	if (i >= NFILES) return((FILE *)NULL);

  switch (*mode) {

      case 'w':
	flags |= WRITEMODE;
	if ((fd = creat(name, PMODE)) < 0) return((FILE *)NULL);
	break;

      case 'a':
	flags |= WRITEMODE;
	if ((fd = open(name, 1)) < 0)
		if (errno != ENOENT || (fd = creat(name, PMODE)) < 0)
			return((FILE *)NULL);
	lseek(fd, 0L, 2);
	break;

      case 'r':
	flags |= READMODE;
	if ((fd = open(name, 0)) < 0) return((FILE *)NULL);
	break;

      default:	return((FILE *)NULL);
  }

  if (i == 0)
	fp = &_stdin;		/* fclose annulls even the low 3 slots */
  else if (i == 1)
	fp = &_stdout;
  else if (i == 2)
	fp = &_stderr;
  else {
	if ((fp = (FILE *)malloc(sizeof(FILE))) == (FILE *)NULL)
		return((FILE *)NULL);
  }
  fp->_count = 0;
  fp->_fd = fd;
  fp->_flags = flags;
  if (i == 0)
	fp->_buf = __stdin;	/* fclose does not modify it but setbuf may */
  else if (i == 1)
	fp->_buf = __stdout;
  else if (i == 2)
	fp->_buf = (char *)NULL;	/* perhaps should mallocate this */
  else
	fp->_buf = (char *)malloc(BUFSIZ);
  if (fp->_buf == (char *)NULL)
	fp->_flags |= UNBUFF;
  else if (i >= 2)
	fp->_flags |= IOMYBUF;

  fp->_ptr = fp->_buf;
  _io_table[i] = fp;
  return(fp);
}
