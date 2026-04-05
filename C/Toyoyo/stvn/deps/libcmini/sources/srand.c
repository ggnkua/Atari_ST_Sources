#include <stdlib.h>
#include <limits.h>

extern unsigned long _lseed;

void srand(unsigned int seed)
{
	_lseed = seed;
}
