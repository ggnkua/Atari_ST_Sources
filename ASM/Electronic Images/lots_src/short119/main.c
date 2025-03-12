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

#ifdef unix
int main(argc, argv) int argc; char **argv; {
  return(shorten(stdin, stdout, argc, argv));
}
#else
int main(argc, argv) int argc; char **argv; {
  FILE *bstdin  = fdopen(fileno(stdin), "rb");
  FILE *bstdout = fdopen(fileno(stdout), "wb");
  int rval;

  setbuf(bstdin, NULL);
  setbuf(bstdout, NULL);
  rval = shorten(bstdin, bstdout, argc, argv);
  fclose(bstdin);
  fclose(bstdout);
  return(rval);
}
#endif
