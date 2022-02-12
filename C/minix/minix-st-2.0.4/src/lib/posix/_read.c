#include <lib.h>
#define read	_read
#include <unistd.h>

PUBLIC ssize_t read(fd, buffer, nbytes)
int fd;
void *buffer;
size_t nbytes;
{
  message m;
#ifdef __MLONG__
#define CHUNK_SIZ	(30*1024)
  size_t left, chunk;
  int r;

  if (nbytes & 0x80000000) {
	errno = EINVAL;
	return (-1);
  }

  left = nbytes;
  while (left) {
	chunk = left > CHUNK_SIZ ? CHUNK_SIZ : left;
	left -= chunk;
	m.m1_i1 = fd;
	m.m1_i2 = chunk;
	m.m1_p1 = (char *) buffer;
	r = _syscall(FS, READ, &m);
	if (r < 0) return r;
	else if (r != chunk) return nbytes - left - chunk + r;
	buffer += chunk;
  }
  return nbytes;
#else
  m.m1_i1 = fd;
  m.m1_i2 = nbytes;
  m.m1_p1 = (char *) buffer;
  return(_syscall(FS, READ, &m));
#endif /* __MLONG__ */
}
