/*
print_hex(x)
int x;
{
  char * foo = "0123456789ABCDEF";
  int i;
  char buf[10];

  for (i = 7 ; i >= 0 ; i--)
	buf[7 - i] = foo[((x >> (i << 2)) & 0x0F)];
  buf[8] = ' ';
  buf[9] = '\0';
  dbgstr(buf);
}
*/
void __sprintf_pushc(c, str_p)
char c;
char ** str_p;
{
  char * str = * str_p;
/*
  dbgstr("  enter pushc ");
  print_hex(c);
  print_hex(str_p);
  print_hex(*str_p);
  dbgstr("\r\n");
*/
  *str++ = c;
  *str_p = str;
}

void sprintf(target, template, args)
char * target;
char * template;
long args;
{
/*
  dbgstr(" enter sprintf\r\n");
*/
  _printf_guts(template, &args, __sprintf_pushc, &target);
  *target = '\0';
/*
  dbgstr(" exit sprintf\r\n");
*/
}
