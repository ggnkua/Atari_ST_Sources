#include <lib.h>
#include <sgtty.h>

int gtty(fd, argp)
int fd;
struct sgttyb *argp;
{
  return(ioctl(fd, TIOCGETP, argp));
}
