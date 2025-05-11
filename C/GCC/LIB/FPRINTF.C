
#include <stdio.h>

static void __fprintf_putc(c, f)
char c;
FILE * f;
{
  fputc(c, f);
}

void fprintf(f, template, args)
FILE * f;
char * template;
long args;
{
  _printf_guts(template, &args, __fprintf_putc, f);
  if (isatty(fileno(f)))
	fflush(f);
}
