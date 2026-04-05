#include <stdio.h>
#include <stdarg.h>


int sprintf(char *str, const char *format, ...)
{
	int ret;
	va_list va;
	va_start(va, format);
	
	ret = vsprintf(str, format, va);
	 va_end(va);
	return ret;
}
