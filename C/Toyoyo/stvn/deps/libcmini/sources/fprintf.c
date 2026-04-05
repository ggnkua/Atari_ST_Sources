#include <stdarg.h>
#include <stdio.h>


/* Write formatted output to STREAM from the format string FORMAT.  */
/* VARARGS2 */
int fprintf(FILE *stream, const char *format, ...)
{
  va_list arg;
  int done;

  va_start(arg, format);
  done = vfprintf(stream, format, arg);
  va_end(arg);

  return done;
}
