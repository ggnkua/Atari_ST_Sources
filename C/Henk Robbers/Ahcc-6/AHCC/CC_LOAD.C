/*  Copyright (c) 1990 - present by Henk Robbers Amsterdam.
 *
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
 */

/*
 *		loads a complete file in heap memory.
 *      For use in AHCC.TTP & AHCL.TTP
 */

#include "common/hierarch.h"
#include <tos.h>
#include <string.h>
#include "common/amem.h"

void send_msg(Cstr text, ...);

global
char *CC_load(Cstr name, short *fh, long *l, Cstr opm, short key)
{
	long pl = 0, fl;
	char *bitmap = nil;

	if (l) *l = 0;
	fl  = fh ? *fh : -1;
	if (name)
		fl = Fopen(name,FO_READ);
	if (fl >= 0)
	{
		if (name)
			if (inq_xfs(name, nil) eq 0)
				strupr((Wstr)name);
		fl &= 0xffff;
		pl = Fseek(0L, fl, 2);
		Fseek(0L, fl, 0);
		bitmap = CC_fmalloc(pl+1, key, nil);
		if (bitmap eq nil)
			send_msg("Insufficient memory %s\n", opm);
		else
		{
			Fread(fl, pl, bitmap);
			*(bitmap + pl) = 0;
		}
		Fclose(fl);
		if (l) *l = pl;
	}
	if (fh) *fh = fl;
	return bitmap;
}

