#include <stdio.h>
#include <osbind.h>
#include <ctype.h>
#include "proto.h"
#include "globals.h"

#ifdef __STDC__
#include "stdarg.h"
#else
#include "varargs.h"
#endif

void __write_char(char c)
{
  asm volatile (
    "0: btst #7,0xffffc15b;"
		"beq.s 0b;"
		"nop;"
		"move.b  %0,0xffffc15f;"
		"cmp.b   #10,%0;"
		"bne.s   1f;"
		"moveq   #13,%0;"
		"bra.s   0b;"
		"1: "
	       : 			/* output register */
	       : "d" (c)		/* input registers */
	       : "cc"			/* clobbered */ );
}

static char buffer[500];

void serprintf(const char *format, ...)
{
  char *s;
  va_list arglist;

#if 0
  asm volatile (
		"move.b #1,0xffffc15b\n"
		"move.b #1,0xffffc157\n"
		"bclr   #3,0xffffc10f\n"
		"bset   #2,0xffffc103\n"
		"move.b #0x88,0xffffc153\n"
		: 			/* output register */
		:  			/* input registers */
		: "cc"			/* clobbered */ );
#endif
	va_start(arglist,format);
  vsprintf(buffer,format,arglist);
  va_end(arglist);
  for(s=buffer; *s; )
  	__write_char(*s++);
}

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

void dprintf(UWORD level, const char *format, ...)
{
  char *s;
  va_list arglist;

	if (debug_flags & level)
	{
#   if 0
	  asm volatile (
			"move.b #1,0xffffc15b\n"
			"move.b #1,0xffffc157\n"
			"bclr   #3,0xffffc10f\n"
			"bset   #2,0xffffc103\n"
			"move.b #0x88,0xffffc153\n"
			: 			/* output register */
			:  			/* input registers */
			: "cc"			/* clobbered */ );
#   endif
		va_start(arglist,format);
	  vsprintf(buffer,format,arglist);
	  va_end(arglist);
	  for(s=buffer; *s; )
	  	__write_char(*s++);
  }
}

void check_debug(void)
{
	if((Kbshift(-1) & 3) && debug_flags == 0)
	{
		char c;
		UWORD flags = 0;
		bprintf("SCSI8XX: debug flags?");
		do
		{
			c = toupper(Bconin(2));
			if(isxdigit(c))
			{
				int x;
				x = (c <= '9') ? c-'0' : c-'A'+10;
				flags <<= 4;
				flags |= x;
				Bconout(2,c);
			}
		} while(c != 13);
		debug_flags = flags;
		bprintf("\r\n");
		if(debug_flags)
			serprintf("debug flags set to $%04X\r\n",debug_flags);
	}
}
