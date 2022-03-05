#include <errno.h>

int remove(filename)
	char *filename;
	{
	long gemdos();

	return(errno = ((int) gemdos(0x41, filename)));
	}
