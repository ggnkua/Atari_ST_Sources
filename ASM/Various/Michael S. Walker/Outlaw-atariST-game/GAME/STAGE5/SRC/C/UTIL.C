#include <UTIL.H>

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
