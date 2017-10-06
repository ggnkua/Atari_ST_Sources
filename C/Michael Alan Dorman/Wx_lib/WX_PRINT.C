#include <stdio.h>
#include <stdarg.h>
#include <wx_lib.h>

void wx_printf(ws,fmt)
Window	*ws;
char	*fmt;
{
	va_list	args;
	char	buf[255];

	va_start(args,fmt);
	vsprintf(buf,fmt,args);
	va_end(args);
	wx_puts(ws,buf);
}
