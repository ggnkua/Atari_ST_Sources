#include <stdio.h>
#include <osbind.h>
#include <ctype.h>
#include "proto.h"

#ifdef __STDC__
#include "stdarg.h"
#else
#include "varargs.h"
#endif

static char buffer[500];

void bprintf(const char *format, ...)
{
  char *s;
  va_list arglist;

	va_start(arglist,format);
  vsprintf(buffer,format,arglist);
  va_end(arglist);
  for(s=buffer; *s;)
  {
		if (*s == '\n')
			Bconout(2,'\r');
  	Bconout(2,*s++);
  }
}

