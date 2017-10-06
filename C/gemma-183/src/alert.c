/* Alert functions */

/*  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

# include <errno.h>
# include <string.h>
# include <mint/mintbind.h>
# include <mint/slb.h>

# include "gemma.h"
# include "gemproto.h"
# include "user.h"

static char begin_error[] = "[0][";

void
bin2asc(long number, char *out)
{
	char decout[10];
	unsigned short x, quot, remd;

	if (number)
	{
		if (number < 0)
		{
			*out++ = '-';
			number = ~number;
			number++;
		}

		for (x = 0; number && (x < 10);)
		{
			quot = (unsigned short)(number / 10);
			remd = (unsigned short)(number % 10);
			number = (unsigned long)quot;
			decout[x++] = remd | 0x30;
		}
		while(x > 0)
			*out++ = decout[--x];
	}
	else
		*out++ = '0';

	*out = 0;
}

static void
line_break(char *line, const short rmargin)
{
	short i, left, ms = 0, q = 0;

	left = strlen(line);

	if (left < rmargin)
		return;

	/* First, cut trailing spaces off */

	for (i = left-1; i; i--)
	{
		if (line[i] != ' ')
			break;
		line[i] = 0;
		ms++;
	}

	left -= ms;

	while(left > rmargin)
	{
		for (i = rmargin; i; i--)
		{
			if(line[i + q] == ' ')
				break;
		}
		line[i + q] = '|';
		left -= i;
		q += i;
	}

	return;
}

long
_alert(PROC_ARRAY *proc, short button, char *msg)
{
	char tmp[512], c;
	short x, y = 0;

	for (x = 0; x < 512; x++)
	{
		c = msg[x];
		if (!c)
			break;
		if (c == '%')
		{
			x++;
			if (msg[x] == 'a')
			{
				bin2asc((long)proc->gem.global[2], tmp + y);
				y = strlen(tmp);
				continue;
			}
		}
		tmp[y++] = msg[x];
	}

	return _form_alert(proc, button, tmp);
}

long
windial_alert(BASEPAGE *bp, long fn, short nargs, \
		short button, long object, PROC_ARRAY *p)
{
	PROC_ARRAY *proc = 0;
	long r, obj;

	if (nargs < 2) return -EINVAL;
	if (nargs >= 3) proc = p;
	if (nargs < 3 || !proc) proc = get_contrl(bp);

	if (!proc->gem.global[0])
		return -EACCES;

	obj = object;
	if (nargs < 3)
		obj >>= 16;

	r = (long)obj2addr(proc, R_STRING, (unsigned long)obj);
	if (r > 0)
		r = _alert(proc, button, (char *)r);

	return r;
}

long
windial_error(BASEPAGE *bp, long fn, short nargs, \
		long error, char *message, PROC_ARRAY *p)
{
	PROC_ARRAY *proc = 0;
	char msgbuf[256], *m;
	long r;
	SLB syserrlib;

	if (nargs < 1) return -EINVAL;
	if (nargs >= 3) proc = p;
	if (nargs < 3 || !proc) proc = get_contrl(bp);

	if (!proc->gem.global[0])
		return -EACCES;

	if (error > 0)
	{
		_alert(proc, 1, "[1][windial_error():|value out of range for apid %a!][ Cancel ]");
		return -EBADARG;
	}
	if (!error && (proc->gem.global[0] >= 0x0410))
		begin_error[1] = '4';			/* use new icon */
	else
		begin_error[1] = '3';

	strcpy(msgbuf, begin_error);
	if (nargs > 1 && (long)message > 0)
	{
		m = (char *)obj2addr(proc, R_STRING, (unsigned long)message);
		if ((long)m > 0)
		{
			char trans[256];

			if (strlen(m) > MAX_LINE)
			{
				strcpy(trans, m);
				line_break(trans, MAX_LINE);
				m = trans;
			}
			strcat(msgbuf, m);
			strcat(msgbuf, "|");
		}
	}

	r = Slbopen("error.slb", 0L, 0x0100L, &syserrlib.handle, &syserrlib.exec);
	if (r >= 0)
	{
		m = (char *)(syserrlib.exec)(syserrlib.handle, 0L, (short)1, error);
		strcat(msgbuf, m);
		Slbclose((long)syserrlib.handle);
	}		
	else
	{
		strcat(msgbuf, "Unknown error");
	}
	
	if (error)
	{
		char *d;

		strcat(msgbuf,"|Status: ");
		d = msgbuf + strlen(msgbuf);
		bin2asc(error, d);
	}

	if (error)
		strcat(msgbuf, "][ Cancel ]");
	else
		strcat(msgbuf, "][ OK ]");

	_alert(proc, 1, msgbuf);

	return 0;
}

/* EOF */
