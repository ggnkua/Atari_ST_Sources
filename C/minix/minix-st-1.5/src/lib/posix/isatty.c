#include <lib.h>
#include <sgtty.h>
#include <minix/com.h>

int isatty(fd)
int fd;
{
  _M.TTY_REQUEST = TIOCGETP;
  _M.TTY_LINE = fd;
  if (callx(FS, IOCTL) < 0) return(0);
  return(1);
}
