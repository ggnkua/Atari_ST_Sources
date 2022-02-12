#include <lib.h>
#include <fcntl.h>		/* for the proto; emphasize varargs kludge */

PUBLIC int fcntl(fd, cmd, barf)
int fd;
int cmd;
int barf;			/* varargs; fix it when open is fixed */
{
  return(callm1(FS, FCNTL, fd, cmd, barf, NIL_PTR, NIL_PTR, NIL_PTR));
}
