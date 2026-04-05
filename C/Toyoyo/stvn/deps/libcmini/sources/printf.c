#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>


int printf(const char *fmt, ...)
{
	int ret;

	va_list va;
	va_start(va, fmt);
	ret = vprintf(fmt, va);
	va_end(va);

	return ret;
}
