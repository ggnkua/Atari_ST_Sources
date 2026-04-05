#include <stdlib.h>
#include <limits.h>

extern unsigned long _seed;

long lrand(void)
{
	_seed = (_seed >> 1) ^ (-(_seed & 1u) & 0x80200003u);
	return (_seed - 1) & LONG_MAX;
}
