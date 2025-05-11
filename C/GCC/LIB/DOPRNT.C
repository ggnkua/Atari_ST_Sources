
#include <stdio.h>

void __doprnt_putc(c, f)
char c;
FILE * f;
{
  fputc(c, f);
}

_doprnt(template, args, f)
char * template;
long ** args;
FILE * f;
{
  _printf_guts(template, args, __doprnt_putc, f);
  if (isatty(fileno(f)))
	fflush(f);
}
