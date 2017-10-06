#include <stdio.h>
#include <osbind.h>
#include <errno.h>

int dup(handle)
	int handle;
	{
	register int rv;

	if((rv = Fdup(handle)) < (-3))
		errno = rv;
	return(rv);
	}

int dup2(handle1, handle2)
	int handle1, handle2;
	{
	return(errno = Fforce(handle2, handle1));
	}
