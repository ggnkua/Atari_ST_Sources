#include "defines.h"
#include "globals.h"
#include <stdarg.h>

/* this is the ansi version ... */

void print_solution(FILE *stream, double *sol)
{
  int i;

  if(Verbose)
    for (i = 0; i <= Sum; i++)
      fprintf(stream, "%-10s%16.5g\n", Names[i], sol[i]);
  else
    {
      fprintf(stream, "Value of objective function: %16.5g\n", sol[0]);
      for (i = Rows + 1; i <= Sum; i++)
	fprintf(stream, "%-10s%16.5g\n", Names[i], sol[i]);
    }
} /* print_solution */


void print_indent(void)
{
  int i;

  fprintf(stderr, "%2d", Level);
  for(i = Level; i > 0; i--)
    fprintf(stderr, "--");
  fprintf(stderr, "> ");
} /* print_indent */


void debug_print_solution(double *sol)
{
  int i;

  if(Debug)
    for (i = 0; i <= Sum; i++)
      {
	print_indent();
	fprintf(stderr, "%-10s%16.5g\n", Names[i], sol[i]);
      }
} /* debug_print_solution */


void debug_print_bounds(double *upbo, double *lowbo)
{
  int i;

  if(Debug)
    for(i = Rows + 1; i <= Sum; i++)
      {
	if(lowbo[i] != 0)
	  {
	    print_indent();
	    fprintf(stderr, "%s > %10.3g\n", Names[i], lowbo[i]);
	  }
	if(upbo[i] != INFINITE)
	  {
	    print_indent();
	    fprintf(stderr, "%s < %10.3g\n", Names[i], upbo[i]);
	  }
      }
} /* debug_print_bounds */


void debug_print(char *format, ...)
{
  va_list ap;

  if(Debug)
    {
      va_start(ap, format);
      print_indent();
      vfprintf(stderr, format, ap);
      fputc('\n', stderr);
      va_end(ap);
    }
} /* debug_print */

