/*
 * Teradesk. Copyright (c) 1993, 1994, 2002 W. Klaren.
 *
 * This file is part of Teradesk.
 *
 * Teradesk is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Teradesk is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Teradesk; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include <np_aes.h>			/* HR 240203 */
#include <stdlib.h>
#include <stdarg.h>			/* HR 240203 */
#include <boolean.h>
#include <ctype.h>

int vsprintf(char *buffer, const char *format, va_list argpoint)
{
	char *s, *d, *h, tmp[16];
	boolean lng, ready;
	int maxl, i;
	long value;

	s = (char *) format;
	d = buffer;

	while (*s)
	{
		if (*s == '%')
		{
			s++;
			lng = ready = FALSE;
			maxl = 0;

			while (ready == FALSE)
			{
				switch (*s)
				{
				case 's':
					h = va_arg(argpoint, char *);

					i = 0;
					if (maxl == 0)
						maxl = 32767;

					while ((h[i]) && (i < maxl))
						*d++ = h[i++];
					ready = TRUE;
					break;
				case 'l':
					lng = TRUE;
					break;
				case 'd':
				case 'x':
					value = (lng == TRUE) ? va_arg(argpoint, long) : va_arg(argpoint, int);

					ltoa(value, tmp, (*s == 'x') ? 16 : 10);
					h = tmp;
					while (*h)
						*d++ = *h++;
					ready = TRUE;
					break;
				default:
					if (isdigit(*s))
						maxl = maxl * 10 + (int) (*s - '0');
					else
						ready = TRUE;
					break;
				}
				s++;
			}
		}
		else
			*d++ = *s++;
	}
	*d++ = 0;

	return (int) (d - buffer);
}

int sprintf(char *buffer, const char *format,...)
{
	int r;
	va_list argpoint;

	va_start(argpoint, format);
	r = vsprintf(buffer, format, argpoint);
	va_end(argpoint);

	return r;
}

int vaprintf( int def,const char *string,va_list argpoint )
{
	char s[256];

	vsprintf(s,string,argpoint);
	return form_alert(def,s);
}

int aprintf( int def,const char *string, ... )
{
	va_list argpoint;
	int button;

	va_start(argpoint,string);
	button = vaprintf(def,string,argpoint);
	va_end(argpoint);

	return button;
}
