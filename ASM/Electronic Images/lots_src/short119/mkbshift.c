/******************************************************************************
*                                                                             *
*       Copyright (C) 1992,1993,1994 Tony Robinson                            *
*                                                                             *
*       See the file LICENSE for conditions on distribution and usage         *
*                                                                             *
******************************************************************************/

# include <stdio.h>
# include "shorten.h"

uchar linear2ulaw PROTO((int));
int   ulaw2linear PROTO((uchar));

# define USIZE 256
# define HUSIZE 128
# define SHIFTSIZE 13

char	*argv0 = "mkbshift";

int main() {
  FILE *fout;
  char *filename = "bitshift.h", *writemode = "w";
  int shift, i;
  int tab[USIZE];
  long **forwardmap = long2d((ulong) SHIFTSIZE, (ulong) USIZE);
  long **reversemap = long2d((ulong) SHIFTSIZE, (ulong) USIZE);

  fout = fopen(filename, writemode);
  if(fout == NULL)
    perror_exit("fopen(\"%s\", \"%s\")", filename, writemode);

  for(i = 0; i < USIZE; i++) tab[i] = 0;

  for(shift = 0; shift < SHIFTSIZE; shift++)
    for(i = -(1 << 15); i < (1 << 15); i += 1 << (shift + 3))
      tab[linear2ulaw(i)] = shift;
  fprintf(fout, "char ulaw_maxshift[%d] = {", USIZE);
  for(i = 0; i < USIZE - 1; i++)
    fprintf(fout, "%d,", tab[i]);
  fprintf(fout, "%d};\n\n", tab[USIZE - 1]);

  for(shift = 0; shift < SHIFTSIZE; shift++) {
    int nused;
  
    nused = 0;
    for(i = 255; i >= 128; i--)
      if(tab[i] >= shift) forwardmap[shift][i] = nused++;
    for(i = 255; i >= 128; i--)
      if(tab[i] < shift) forwardmap[shift][i] = nused++;
  
    nused = -1;
    for(i = 126; i >= 0; i--)
      if(tab[i] >= shift) forwardmap[shift][i] = nused--;
    forwardmap[shift][127] = nused--;
    for(i = 126; i >= 0; i--)
      if(tab[i] < shift) forwardmap[shift][i] = nused--;

    for(i = 0; i < USIZE; i++)
      reversemap[shift][forwardmap[shift][i] + HUSIZE] = i;
  }

  for(shift = 0; shift < SHIFTSIZE; shift++)
    for(i = 0; i < USIZE; i++)
      if(forwardmap[shift][reversemap[shift][i]] != i - HUSIZE)
	fprintf(stderr, "identity maping failed for shift: %d\tindex: %d\n",
		shift, i);

  fprintf(fout, "schar ulaw_inward[%d][%d] = {\n", SHIFTSIZE, USIZE);
  for(shift = 0; shift < SHIFTSIZE; shift++) {
    fprintf(fout, "{");
    for(i = 0; i < USIZE - 1; i++)
      fprintf(fout, "%ld,", forwardmap[shift][i]);
    if(shift != SHIFTSIZE - 1)
      fprintf(fout, "%ld},\n", forwardmap[shift][USIZE - 1]);
    else
      fprintf(fout, "%ld}\n};\n", forwardmap[shift][USIZE - 1]);
  }
  fprintf(fout, "\n");

  fprintf(fout, "uchar ulaw_outward[%d][%d] = {\n", SHIFTSIZE, USIZE);
  for(shift = 0; shift < SHIFTSIZE; shift++) {
    fprintf(fout, "{");
    for(i = 0; i < USIZE - 1; i++)
      fprintf(fout, "%ld,", reversemap[shift][i]);
    if(shift != SHIFTSIZE - 1)
      fprintf(fout, "%ld},\n", reversemap[shift][USIZE - 1]);
    else
      fprintf(fout, "%ld}\n};\n", reversemap[shift][USIZE - 1]);
  }
  return(0);
}
