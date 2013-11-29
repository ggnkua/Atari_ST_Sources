#include <errno.h>
#include <osbind.h>

char *sbrk(incr)
unsigned incr;
{
    long retval;

    retval = (long)Malloc((long)incr);
	if (!retval) 
		retval = -1;
		/* should set errno to something here */
	return (char *)retval;
}
