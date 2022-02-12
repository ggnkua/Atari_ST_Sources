#include <lib.h>
/*  rand(3)
 *
 *  Changed to return high order bits. Terrence W. Holm, Nov. 1988
 */

PRIVATE long _seed = 1L;

void srand(x)
unsigned x;
{
  _seed = (long) x;
}

int rand()
{
  _seed = 1103515245L * _seed + 12345;
  return((int) ((_seed >> 16) & 0x7fff));
}
