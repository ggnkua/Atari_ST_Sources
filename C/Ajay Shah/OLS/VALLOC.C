/*
Allocate vector addressed as A[l..r]. E.g., A[1..4] would be

1 2 3 4

You would get this vector by calling vector(1, 4).

All the work is done by the file "valloc.inc", which creates
vector of type VTYPE.  In this file, we merely tweak VTYPE
several times and include valloc.inc repeatedly.
*/

#include <stdlib.h>
#include <stdio.h>
#include "utils.h"

#define VTYPE float
/* This makes the (fixed) code behave as if it was written
	with float matrices in mind. */
VTYPE *
vector (int l, int h)
#include "valloc.inc"
#undef VTYPE

#define VTYPE double
     VTYPE *dvector (int l, int h)
#include "valloc.inc"
     /* That gives us double vectors. */
#undef VTYPE

#define VTYPE int
     VTYPE *ivector (int l, int h)
#include "valloc.inc"
     /* That gives us int vectors. */
#undef VTYPE

#ifdef TESTING
     int main ()
{
  float *v;
  int i;

  for (i = 1; i < 100000; i++)
    v = vector (1, 10);

  return 0;
}

#endif
