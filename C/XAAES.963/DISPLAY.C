/*
 * XaAES - XaAES Ain't the AES (c) 1992 - 1998 C.Graham
 *                                 1999 - 2003 H.Robbers
 *
 * A multitasking AES replacement for MiNT
 *
 * This file is part of XaAES.
 *
 * XaAES is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * XaAES is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with XaAES; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */


#include <prelude.h>
#include <osbind.h>
#include <stdarg.h>
#include "display.h"

/* reduced (faster) version */
int vsdisplay(char *to, const char *f, void *sp)
{
	char *s = to;

	do
	{
		char c=*f++,*fro;
		int i,sz;
		bool lo;
		unsigned long l;

		if (c eq '%')
		{
			c = *f++;

			sz = 0;				/* for x */
			if (c eq '0')
			{
				sz = *f++ - '0';
				c = *f++;
			}

			if ( (lo = c eq 'l') ne 0)
				c = *f++;

			switch (c)
			{
			case 's':
				fro = va_arg(sp,char *);
				if (fro)
				{
					while((*s++ = *fro++) ne 0);
					s--;
				othw
					*s++ = '~';			/* HR 101102: zero pointer */
					*s++ = 'Z';
					*s++ = '~';
				}
				break;

			case 'd':
				if (lo)
				{
					char x[16];
					long sign;
					l = va_arg(sp, long);
					if ( (sign=l) < 0 )
						l=-l;
					fro=&x[sizeof(x)-1];
					*fro=0;
					do
						*--fro=l%10+'0';
					while ((l/=10) > 0 );
					if ( sign<0 )
						*--fro='-';
					while((*s++ = *fro++) ne 0);	
					s--;				
				othw
					char x[7];
					int sign;
					i = va_arg(sp, int);
					if ( (sign=i) < 0 )
						i=-i;
					fro=&x[sizeof(x)-1];
					*fro=0;
					do
						*--fro=i%10+'0';
					while ((i/=10) > 0 );
					if ( sign<0 )
						*--fro='-';
					while((*s++ = *fro++) ne 0);	
					s--;				
				}
				break;

			case 'X':
			case 'x':
			{
				char x[9];
				if (lo)
					l = va_arg(sp, unsigned long);		/* 300502 HR unsigned */
				else
					l = va_arg(sp, unsigned int);		/* 300502 HR unsigned */
				for (i=0;i<sizeof(x);i++) x[i]='0';
				fro=&x[sizeof(x)-1];
				*fro--=0;
				do 
				{
					i=(l%16);
					*fro--=i+(i<10 ? '0' : 'W');
				} while ((l/=16) > 0 );
				fro=x;
				if (!sz)
				{
					while (*fro == '0') fro++;
					if (*fro == 0)
						fro--;
				}
				else
					fro += sizeof(x) -1 - sz;	/* preliminary */
				while((*s++ = *fro++) ne 0);
				s--;
			}
			break;
			case 'c':
				*s++=va_arg(sp,int);
				break;

			default:
				*s++=c;
			}
		othw
			*s++=c;
		}
	} while (*f);
	*s = 0;
	return s - to;
}

static
int ins_cr(char line[], int l)
{
	if (line[l-1] == '\n')
		if (line[l-2] != '\r')
		{
			l++;
			line[l-2] = '\r';
			line[l-1] = '\n';
			line[l  ] = 0;
		}
	return l;
}

int sdisplay(char *to, const char *t, ...)
{
	int l;
	va_list argpoint;
	va_start(argpoint,text);
	l = vsdisplay(to,t,argpoint);
	va_end(argpoint);
	return l;
}

int fdisplay(int fl, bool echo, const char *t, ...)
{
	char line[512];
	int l;
	va_list argpoint;
	va_start(argpoint,text);
	l = vsdisplay(line,t,argpoint);
	l = ins_cr(line, l);
	va_end(argpoint);
	if (echo)
		Cconws(line);
	return Fwrite(fl, l, line);
}

/* HR: absolutely NO need for stream io */

int display(const char *t, ...)	/* avoid use of stream IO */
{
	int l;
	char line[512];
	va_list argpoint;
	va_start(argpoint,text);
	l = vsdisplay(line,t,argpoint);
	l = ins_cr(line, l);
	va_end(argpoint);
	Cconws(line);
	return l;
}
