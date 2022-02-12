#include <lib.h>
#include <stdlib.h>
/*  bsearch(3)
 *
 *  Author: Terrence Holm          Aug. 1988
 *
 *
 *  Performs a binary search for a given <key> within a sorted
 *  table. The table contains <count> entries of size <width>
 *  and starts at <base>.
 *
 *  Entries are compared using keycmp( key, entry ), each argument
 *  is a (void *), the function returns an int < 0, = 0 or > 0
 *  according to the order of the two arguments.
 *
 *  Bsearch(3) returns a pointer to the matching entry, if found,
 *  otherwise NULL is returned.
 */

#include <stddef.h>

void *bsearch(key, basefix, count, width, keycmp)
_CONST void *key;
_CONST void *basefix;
unsigned int count;
unsigned int width;
_PROTOTYPE( int (*keycmp), (const void *, const void *));
{
  _CONST char *mid_point;
  int cmp;
  _CONST char *base = (char *) basefix;

  while (count > 0) {
	mid_point = base + width * (count >> 1);

	cmp = keycmp(key, mid_point);

	if (cmp == 0) return((void *)mid_point);

	if (cmp < 0)
		count >>= 1;
	else {
		base = mid_point + width;
		count = (count - 1) >> 1;
	}
  }

  return((void *)NULL);
}
