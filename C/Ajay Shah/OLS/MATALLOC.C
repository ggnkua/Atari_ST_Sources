/*
Allocate matrix A[rl..rh, cl..ch] in such a way that all the storage
for it is in a contiguous block.

E.g., A[2..4, -1..2] is

   -1  0  1  2
2
3
4

You would get this matrix by calling matrix(2, 4, -1, 2);

All the work is done by the file "matalloc.inc", which creates
matrices of type MATTYPE.  In this file, we merely tweak MATTYPE
several times and include matalloc.inc repeatedly.
*/

#include <stdlib.h>
#include <stdio.h>
#include "utils.h"

#define MATTYPE float
/* This makes the (fixed) code behave asif it was written
	with float matrices in mind. */
MATTYPE **
matrix (int rl, int rh, int cl, int ch)
#include "matalloc.inc"
#undef MATTYPE
     /* You'll get warnings about "MATTYPE redefined" otherwise.  */

#define MATTYPE double
     MATTYPE **dmatrix (int rl, int rh, int cl, int ch)
#include "matalloc.inc"
     /* That gives us double matrices. */
#undef MATTYPE

#define MATTYPE int
     MATTYPE **imatrix (int rl, int rh, int cl, int ch)
#include "matalloc.inc"
     /* That gives us int matrices. */
#undef MATTYPE

#ifdef TESTING
     int main ()
{
  float **M;
  int i;

  for (i = 1; i < 100000; i++)
    M = matrix (1, 10, 1, 2);

  return 0;
}

#endif
