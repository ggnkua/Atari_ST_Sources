#include <lib.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>

int fclose(fp)
FILE *fp;
{
  register int i;

  for (i = 0; i < NFILES; i++)
	if (fp == _io_table[i]) {
		_io_table[i] = 0;
		break;
	}
  if (i >= NFILES) return(EOF);
  fflush(fp);
  close(fp->_fd);
  if (testflag(fp, IOMYBUF) && fp->_buf) free(fp->_buf);
  if (i > 2) free(fp);
  return(0);
}
