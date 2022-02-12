#include <lib.h>
#include <unistd.h>
#include <stdio.h>


int fgetc(iop)
FILE *iop;
{
  char ch;

  if (testflag(iop, (_EOF | _ERR))) return(EOF);

  if (!testflag(iop, READMODE)) return(EOF);

  if (iop->_count <= 0) {

	if (testflag(iop, UNBUFF))
		iop->_count = read(iop->_fd, &ch, 1);
	else
		iop->_count = read(iop->_fd, iop->_buf, BUFSIZ);

	if (iop->_count <= 0) {
		if (iop->_count == 0)
			iop->_flags |= _EOF;
		else
			iop->_flags |= _ERR;

		return(EOF);
	} else
		iop->_ptr = iop->_buf;
  }
  iop->_count--;		/* account one char */
  if (testflag(iop, UNBUFF))
	return(ch & CMASK);
  else
	return(*iop->_ptr++ & CMASK);
}
