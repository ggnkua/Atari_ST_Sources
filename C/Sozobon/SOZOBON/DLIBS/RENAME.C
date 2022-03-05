#include <errno.h>

int rename(oldname, newname)
	char *oldname, *newname;
	{
	long gemdos();

	return(errno = ((int) gemdos(0x56, 0, oldname, newname)));
	}
