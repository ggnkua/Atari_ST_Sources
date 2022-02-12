#include <lib.h>
#include <stdio.h>

void fprintf(file, fmt, args)
FILE *file;
_CONST char *fmt;
int args;
{
  _doprintf(file, fmt, &args);
  if (testflag(file, PERPRINTF)) fflush(file);
}


void printf(fmt, args)
_CONST char *fmt;
int args;
{
  _doprintf(stdout, fmt, &args);
  if (testflag(stdout, PERPRINTF)) fflush(stdout);
}
