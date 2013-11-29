#include <errno.h>
#include <fcntl.h>
#include <osbind.h>

int unlink(path)
char *path;
{
    if (errno = Fdelete(path)) 
 		return -1; 
	else 
		return 0;
}
