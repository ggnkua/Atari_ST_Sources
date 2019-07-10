#include "bitmap.h"

int
bit_on(map, x, y)
	BITMAP *map;
	int x, y;
{
	return bit_point(map, x, y, DST) != 0;
}
