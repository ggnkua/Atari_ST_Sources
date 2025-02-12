/******************************************************************************
*                                                                             *
*       Copyright (C) 1992,1993,1994 Tony Robinson                            *
*                                                                             *
*       See the file LICENSE for conditions on distribution and usage         *
*                                                                             *
******************************************************************************/

# include <stdio.h>
# include <stdlib.h>
# include "shorten.h"

void *pmalloc(size) ulong size; {
  void *ptr;

#ifdef DOS_MALLOC_FEATURE
  fprintf(stderr, "requesting %ld bytes: ", size);
#endif
  ptr = malloc(size);
#ifdef DOS_MALLOC_FEATURE
  if(ptr == NULL)
    fprintf(stderr, "denied\n");
  else
    fprintf(stderr, "accepted\n");
#endif

  if(ptr == NULL)
    perror_exit("malloc(%ld)", size);

  return(ptr);
}

long **long2d(n0, n1) ulong n0, n1; {
  long **array0;

  if((array0 = (long**)pmalloc(n0 * sizeof(long*) +n0*n1*sizeof(long)))!=NULL){
    long *array1 = (long*) (array0 + n0);
    int i;

    for(i = 0; i < n0; i++)
      array0[i] = array1 + i * n1;
  }
  return(array0);
}
