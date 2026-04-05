#include <stdlib.h>
#include <limits.h>

extern unsigned long _seed;

void srand48(long int seed)
{
	if (seed == 0) seed = -1;
	_seed = seed;
}
