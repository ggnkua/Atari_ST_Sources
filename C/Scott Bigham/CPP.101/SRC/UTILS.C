
#include <stdio.h>
#include <stddef.h>
#include <stdlib.h>
#if defined(__STDC__) || defined(__SOZOBONC__)
#include <stdarg.h>
#else
#include <varargs.h>
#endif
#include "global.h"
#include "ztype.h"

#define EM_ERROR  0
#define EM_WARN   1
#define EM_FATAL  2
#define EM_BUGCHK 3

#ifdef __STDC__
#define __EM_fmt__ (char *fmt, ...)
#else
# ifdef __SOZOBONC__
# define __EM_fmt__ (fmt) char *fmt;
# else
# define __EM_fmt__ (va_alist) va_dcl
# endif
#endif

extern int nerrs;

static char *em_text[] =
{"", " warning:", " FATAL:", " compiler bug:"};

/* em_header() -- add file and line number information to error message */
static void em_header(n)
  int n;
{
  if (cur_file)
    fprintf(stderr, "In file \"%s\" (%lu):%s ", cur_file, this_line, em_text[n]);
  else
    fprintf(stderr, "%s:%s ", argv0, em_text[n]);
}

/* fatal() -- print an error message and punt */
void fatal __EM_fmt__
{
  va_list ap;
    em_header(EM_FATAL);
    va_start(ap, fmt);
    vfprintf(stderr, fmt, ap);
    va_end(ap);
    fputc('\n', stderr);
    exit(1);
}

/*
   bugchk() -- similar to fatal(), but reserved for flagging compiler bugs
*/
void bugchk __EM_fmt__
{
  va_list ap;
    em_header(EM_BUGCHK);
    va_start(ap, fmt);
    vfprintf(stderr, fmt, ap);
    va_end(ap);
    fputc('\n', stderr);
    exit(1);
}

/* error() -- print an error message and bump the error counter */
void error __EM_fmt__
{
  va_list ap;
    em_header(EM_ERROR);
    va_start(ap, fmt);
    vfprintf(stderr, fmt, ap);
    va_end(ap);
    fputc('\n', stderr);
    nerrs++;
}

/* warning() -- print an error/informational message */
void warning __EM_fmt__
{
  va_list ap;
    em_header(EM_WARN);
    va_start(ap, fmt);
    vfprintf(stderr, fmt, ap);
    va_end(ap);
    fputc('\n', stderr);
}

/* mallok() -- a paranoia wrapper around malloc() */
void *mallok(n)
  size_t n;
{
  void *t = malloc(n);

  if (!t)
    fatal("cannot get %lu bytes", (unsigned long)n);
  return t;
}

/* reallok() -- a paranoia wrapper around realloc() */
void *reallok(t, n)
  void *t;
  size_t n;
{
  void *u = realloc(t, n);

  if (!u)
    fatal("cannot get %lu bytes", (unsigned long)n);
  return u;
}

/*
   copy_filename() -- return malloc()'ed memory containing the first |len|
   characters of |fnam|, or all of |fnam| if |len==0|
*/
char *copy_filename(fnam, len)
  char *fnam;
  int len;
{
  char *newfnam;
  register char *s = fnam, *t;
  register int i;

  if (len == 0)
    len = strlen(fnam);
  t = newfnam = mallok(len + 1);
  for (i = 0; i < len; s++, t++, i++)
    *t = ((*s == '/' || *s == '\\') ? PATH_SEP : *s);
  *t = 0;
  return newfnam;
}

#ifndef __GNUC__
/* strdup() -- return malloc()'ed space containing a copy of |s| */
char *strdup(s)
  char *s;
{
  char *t = (char *)mallok(strlen(s) + 1);

  strcpy(t, s);
  return t;
}

#endif

/*
   xfopen() -- like fopen(), except that setvbuf() is called to increase the
   buffer size
*/
FILE *xfopen(fnam, mode)
  char *fnam, *mode;
{
  FILE *f = fopen(fnam, mode);

  if (!f)
    fatal("cannot open %s file %s", (*mode == 'r' ? "input" : "output"),
	  fnam);
  if (setvbuf(f, NULL, _IOFBF, NEWBUFSIZ) != 0)
    fatal("cannot get file buffer for %s", fnam);
  return f;
}

/*
   grow() -- expand buffer |*buf|, originally of length |*buflen|, to hold an
   additional |add_len| characters.  |in_ptr| is a pointer into the buffer;
   return a pointer into the new buffer with the same offset.
*/
char *grow(buf, buflen, in_ptr, add_len)
  char **buf;
  size_t *buflen;
  char *in_ptr;
  int add_len;
{
  ptrdiff_t dp = in_ptr - *buf;

  if (dp + add_len <= *buflen)
    return in_ptr;
  while (*buflen < dp + add_len)
    *buflen *= 2;
  *buf = reallok(*buf, *buflen);
  return *buf + dp;
}
