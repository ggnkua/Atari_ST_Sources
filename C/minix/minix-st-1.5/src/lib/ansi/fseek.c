#include <lib.h>
#include <unistd.h>
#include <stdio.h>

int fseek(iop, offset, where)
FILE *iop;
long offset;
int where;
{
  int count;
  long pos = -1L;

  iop->_flags &= ~(_EOF | _ERR);
  /* Clear both the end of file and error flags */

  if (testflag(iop, READMODE)) {
	if (where < 2 && iop->_buf && !testflag(iop, UNBUFF)) {
		count = iop->_count;
		pos = offset;

		if (where == 0) {
			long L_tmp = lseek(fileno(iop), 0L, 1);
			/* Determine where we are */

			pos += (long) count - L_tmp;
		} else
			offset -= (long) count;

		if (count > 0 && pos <= (long) count
		    && pos >= (long) iop->_buf - (long) iop->_ptr) {
			iop->_ptr += (int) pos;
			iop->_count -= (int) pos;
			return(0);
		}
	}
	pos = lseek(fileno(iop), offset, where);
	iop->_count = 0;
  } else if (testflag(iop, WRITEMODE)) {
	fflush(iop);
	pos = lseek(fileno(iop), offset, where);
  }
  return((pos == -1L) ? -1 : 0);
}
