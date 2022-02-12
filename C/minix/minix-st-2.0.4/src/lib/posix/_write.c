#include <lib.h>
#define write	_write
#include <unistd.h>

PUBLIC ssize_t write(fd, buffer, nbytes)
int fd;
_CONST void *buffer;
size_t nbytes;
{
  message m;
#ifdef __MLONG__
#define CHUNK_SIZ	(30*1024)
  size_t left, this;
  _CONST char *p;
  int r;

  if (nbytes & 0x80000000) {
	errno = EINVAL;
	return (-1);
  }

  left = nbytes;
  p = buffer;
  while (left > 0) {
	this = left > CHUNK_SIZ ? CHUNK_SIZ : left;
	left -= this;
	m.m1_i1 = fd;
	m.m1_i2 = this;
	m.m1_p1 = (char *) p;
	r = _syscall(FS, WRITE, &m);
	if (r < 0) return r;
	else if (r != this) return nbytes - left - this + r;
	p += this;
  }
  return nbytes;
#else
  m.m1_i1 = fd;
  m.m1_i2 = nbytes;
  m.m1_p1 = (char *) buffer;
  return(_syscall(FS, WRITE, &m));
#endif /* __MLONG__ */
}
