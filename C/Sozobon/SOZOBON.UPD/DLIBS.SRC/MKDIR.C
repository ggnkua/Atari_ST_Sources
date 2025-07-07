#include <errno.h>

int mkdir(pathname)
	char *pathname;
	{
	long gemdos();

	return(errno = ((int) gemdos(0x39, pathname)));
	}
