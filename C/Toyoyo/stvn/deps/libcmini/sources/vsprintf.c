#include <stdio.h>
#include <stdarg.h>
#include "lib.h"

int vsprintf(char *str, const char *format, va_list va)
{
	struct _mem_stream stream;

	stream.xstring = str;
	stream.xestring = (char *)0x7fffffffl;

	doprnt(__addchar, &stream, format, va);
	*stream.xstring = '\0';

	return (int)(stream.xstring - str);
}
