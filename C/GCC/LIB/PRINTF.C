
#include <stdio.h>

void __printf_putc(c)
char c;
{
  fputc(c, stdout);
}

void printf(template, args)
char * template;
long args;
{
  _printf_guts(template, &args, __printf_putc);
  if (isatty(fileno(stdout)))
	fflush(stdout);
}
