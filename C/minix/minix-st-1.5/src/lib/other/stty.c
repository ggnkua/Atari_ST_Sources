#include <lib.h>
#include <sgtty.h>

int stty(fd, argp)
int fd;
struct sgttyb *argp;
{
  return ioctl(fd, TIOCSETP, argp);
}
