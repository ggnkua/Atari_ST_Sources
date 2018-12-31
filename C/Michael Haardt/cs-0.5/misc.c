#include <errno.h>
#include <sys/types.h>
#include <string.h>

#ifdef NEEDS_MEMMOVE
void memmove(void *dst, void *src, size_t len)
{
  bcopy(src,dst,len);
}
#endif

#ifdef NEEDS_STRERROR
extern int sys_nerr;
extern char *sys_errlist[];

char *strerror(int errno)
{
  return sys_errlist[errno];
}
#endif
