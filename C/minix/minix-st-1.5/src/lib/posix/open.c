#include <lib.h>
#include <sys/types.h>
#include <fcntl.h>

PUBLIC int open(name, flags, mode)
_CONST char *name;
int flags, mode;
{
  if (flags & O_CREAT)
	return callm1(FS, OPEN, len(name), flags, mode,
		      (char *)name, NIL_PTR, NIL_PTR);
  return(callm3(FS, OPEN, flags, name));
}
