#ifndef NO_POSIX_SOURCE
#undef  _POSIX_SOURCE
#define _POSIX_SOURCE   1
#undef  _POSIX_C_SOURCE
#define _POSIX_C_SOURCE 2
#endif

#include <stdio.h>
#include <stdlib.h>

#include "cat.h"
#include "alloc.h"

/* xmalloc */ /*{{{C}}}*//*{{{*/
void *xmalloc(size_t n)
{
  void *r;

  if ((r=malloc(n))==(void*)0)
  {
    fprintf(stderr,OUTOFMEM);
    exit(1);
  }
  else return r;
}
/*}}}*/
/* xrealloc */ /*{{{*/
void *xrealloc(void *s, size_t n)
{
  void *r;

  if ((r=(s==(void*)0 ? malloc(n) : realloc(s,n)))==(void*)0)
  {
    fprintf(stderr,OUTOFMEM);
    exit(1);
  }
  else return r;
}
/*}}}*/
