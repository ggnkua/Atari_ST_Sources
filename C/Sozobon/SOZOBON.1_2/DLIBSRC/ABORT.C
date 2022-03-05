#include <stdio.h>

void abort()
	{
	fputs("Abnormal program termination\n", stderr);
	fflush(stderr);
	_exit(3);
	}
