
#include <lib.h>
#include <minix/com.h>
#include <sgtty.h>
#include <errno.h>

/* use this instead of ioctl */
/* ioctl does termio emulation work, passes the rest to o_ioctl */


int ioctl(fd, request, u)
int fd;
int request;
union {
  long arg;
} u;

{
  int n;

  _M.TTY_REQUEST = request;
  _M.TTY_LINE = fd;

  switch(request) {
/* for disk-clock */
     case DC_RBMS100:
     case DC_RBMS200:
     case DC_RSUPRA:
     case DC_RICD:
     case DC_WBMS100:
     case DC_WBMS200:
	_M.TTY_SPEK = u.arg;  /* this is address to write ans to */
	n = callx(FS, IOCTL);
	return(n);
     default:
	n = -1;
	errno = (EINVAL);
	return(n);
  }
}

