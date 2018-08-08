#include	<stdio.h>
#include	<stdarg.h>
#include	"stikbios.h"

void disp_info(const char *fmt, ...)
{
	char buf[120];
	char *msg = (char *) buf;
	va_list args;
	va_start(args,fmt);
	
	vsprintf(msg,fmt,args);
	va_end(args);
	
	while(*msg != '\0')
	{
		SBconout(2,(int) *msg++);
	}
	SBconout(2,(int)'\n');
	SBconout(2,(int)'\r');
}
