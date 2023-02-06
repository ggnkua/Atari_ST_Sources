#include <UTIL.H>

unsigned short lfsr = 0xACE1u;
unsigned bit;

int WrapInteger(int x, int min, int range)
{
	if (x >= min)
	{
		if (x >= range)
			return x - range;
		return x;
	}
	else
		return x + range;
}

void TrimLine(int *x, int min, int max)
{
	if (*x >= min)
	{
		if (*x >= max)
			*x = max - 1;
	}
	else
		*x = min;
}

unsigned MyRand(void)
{
	bit  = ((lfsr >> 0) ^ (lfsr >> 2) ^ (lfsr >> 3) ^ (lfsr >> 5) ) & 1;
	return lfsr =  (lfsr >> 1) | (bit << 15);
}
