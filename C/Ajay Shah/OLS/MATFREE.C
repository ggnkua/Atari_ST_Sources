#include <stdlib.h>
#include <stdio.h>
#include "utils.h"

void free_matrix (float **M, int rl, int rh, int cl, int ch)
     
#include "matfree.inc"
     
void free_dmatrix (double **M, int rl, int rh, int cl, int ch)
#include "matfree.inc"

void free_imatrix (int **M, int rl, int rh, int cl, int ch)
#include "matfree.inc"

#ifdef TESTING
     int main ()
{
  return 0;
}

#endif
