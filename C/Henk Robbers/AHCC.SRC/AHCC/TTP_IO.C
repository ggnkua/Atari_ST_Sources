/* Copyright (c) 1990 - 2009 by H.Robbers Amsterdam.
 * This file is part of AHCC.
 *
 * AHCC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * AHCC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with AHCC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 *
 * TTP_IO.C		for IO in AHCC.TTP
 *
 */

#include <stdio.h>

#include <stdlib.h>
#include <string.h>
#include "param.h"

#ifndef __TURBOC__
#define Handle _file
#define BufPtr _ptr
#define BufStart _base
#endif

char *Cload(Cstr fname, short *fh, long *l, Cstr opm)
{
	return CC_load(fname, fh, l, opm, 501);
}

global Wstr out_buf, out_goes;
global long out_l;

static FILE out_file;

global FILE *open_S(Cstr name)
{
	/* in TTP AHCC this is dummy */
	memset (&out_file, 0, sizeof(FILE));
	return &out_file;
}

global short close_S(FILE *fd)
{
	/* in TTP AHCC this is dummy */
	return 0;
}

void send_msg(Cstr text, ...)
{
	va_list argpoint;
	va_start(argpoint, text);

	if (    * text      eq '%'		/* special feature :-) indentation */
	    and *(text + 1) eq 'd'
	    and *(text + 2) eq '>'
	   )
	{
		short lvl = va_arg(argpoint, short);
		while (lvl--)
			fprintf(bugf, "\t");
		text += 3;
	}

	vfprintf(bugf, text, argpoint);	/* current out stream */
	va_end(argpoint);
}

void console(Cstr text, ...)
{
	va_list argpoint;
	va_start(argpoint, text);
	vprintf(text, argpoint);			/* stdout */
	va_end(argpoint);
}
