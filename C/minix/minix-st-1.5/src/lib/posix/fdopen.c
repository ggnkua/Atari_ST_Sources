#include <stdlib.h>
#include <stdio.h>

FILE *fdopen(fd, mode)
int fd;
_CONST char *mode;
{
  register int i;
  FILE *fp;
  int flags = 0;

  for (i = 0; _io_table[i] != 0; i++)
	if (i >= NFILES) return((FILE *)NULL);

  switch (*mode) {
      case 'w':	flags |= WRITEMODE;	  	break;
      case 'a':	flags |= WRITEMODE;	  	break;
      case 'r':	flags |= READMODE;	  	break;
      default:	return ((FILE *)NULL);
  }

  if ((fp = (FILE *)malloc(sizeof(FILE))) == (FILE *)NULL) return((FILE *)NULL);

  fp->_count = 0;
  fp->_fd = fd;
  fp->_flags = flags;
  fp->_buf = (char *)malloc(BUFSIZ);
  fp->_flags |= IOMYBUF;
  fp->_ptr = fp->_buf;
  _io_table[i] = fp;
  return(fp);
}
