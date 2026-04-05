/*
 * vsnprintf.c
 *
 *  Created on: 29.05.2013
 *      Author: mfro
 */

#include <stdarg.h>
#include <stdlib.h>
#include <stdarg.h>
#include "lib.h"

int __addchar(int c, void *_stream)
{
	struct _mem_stream *stream = (struct _mem_stream *)_stream;
	
	if (stream->xestring == 0 || stream->xstring >= stream->xestring)
		stream->xstring++;
	else
		*stream->xstring++ = (char) c;

	return 1;
}

int vsnprintf(char *str, size_t size, const char *fmt, va_list va)
{
	struct _mem_stream stream;
	stream.xstring = str;
	stream.xestring = size == 0 ? 0 : str + size - 1;
	doprnt(__addchar, &stream, fmt, va);
	if (size != 0)
	{
		if (stream.xstring <= stream.xestring)
			*stream.xstring = '\0';
		else
			*stream.xestring = '\0';
	}

	return (int)(stream.xstring - str);
}
