#include <stdlib.h>

#ifndef __PROTO
#  ifdef __STDC__
#    define __PROTO(x)	x
#  else
#    define __PROTO(x)	()
#  endif
#endif

typedef struct {
  int nargs;
  int arg_spc;
  const char **_args;
} Arguments;
#define args(A)		((A)->_args)

/* run.c */
void add_args __PROTO((Arguments *, const char * const *));
void add_arg __PROTO((Arguments *, const char *));
void remove_args __PROTO((Arguments *, int));
void run __PROTO((Arguments *, char const * const *));

/* utils.c */
void *mallok __PROTO((size_t));
void *reallok __PROTO((void *, size_t));
void error __PROTO((const char *, ...));
void fatal __PROTO((const char *, ...));
void bugchk __PROTO((const char *, ...));

/* main.c */
extern char *argv0;
extern int verbose, action;
