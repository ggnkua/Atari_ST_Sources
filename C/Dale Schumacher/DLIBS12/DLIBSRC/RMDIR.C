#include <errno.h>

int rmdir(pathname)
	char *pathname;
	{
	long gemdos();

	return(errno = ((int) gemdos(0x3A, pathname)));
	}
