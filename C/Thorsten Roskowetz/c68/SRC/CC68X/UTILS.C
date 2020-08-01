#include <stdio.h>
#include <stdarg.h>
#include "global.h"

void *mallok(n)
  size_t n;
{
  void *r = malloc(n);

  if (!r)
    fatal("Out of memory -- cannot allocate %ld bytes", (unsigned long)n);
  return r;
}

void *reallok(r, n)
  void *r;
  size_t n;
{
  r = realloc(r, n);
  if (!r)
    fatal("Out of memory -- cannot allocate %ld bytes", (unsigned long)n);
  return r;
}

#ifdef __STDC__
void error(const char *fmt, ...)
#else
void error(fmt) const char *fmt;
#endif
{
  va_list ap;

  fprintf(stderr, "%s:  ", argv0);
  va_start(ap, fmt);
  vfprintf(stderr, fmt, ap);
  va_end(ap);
  fputc('\n', stderr);
}

#ifdef __STDC__
void fatal(const char *fmt, ...)
#else
void fatal(fmt) const char *fmt;
#endif
{
  va_list ap;

  fprintf(stderr, "%s: FATAL:  ", argv0);
  va_start(ap, fmt);
  vfprintf(stderr, fmt, ap);
  va_end(ap);
  fputc('\n', stderr);
  exit(1);
}

#ifdef __STDC__
void bugchk(const char *fmt, ...)
#else
void bugchk(fmt) const char *fmt;
#endif
{
  va_list ap;

  fprintf(stderr, "%s: internal error:  ", argv0);
  va_start(ap, fmt);
  vfprintf(stderr, fmt, ap);
  va_end(ap);
  fputc('\n', stderr);
  exit(1);
}
