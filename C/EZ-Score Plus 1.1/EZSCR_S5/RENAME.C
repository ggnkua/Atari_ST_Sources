#include <errno.h>
#include <fcntl.h>
#include <osbind.h>

int rename(from, to)
char *from, *to;
{
    if (errno = Frename(0, from, to)) 
 		return -1; 
	else 
		return 0;
}
