/*
 * Multitos Library for Pure C 1.0. Copyright (c) 1994, 2002 W. Klaren.
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

#include <np_aes.h>      DjV 001 241202 */
#include <stdarg.h>
#include <multitos.h>

static unsigned char argtab[] =
{
	1, 1, 1, 4, 4, 4, 4, 1,
	1, 1, 4, 4, 1, 1, 1, 1,
	4, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1, 1
};

int wind_get(int handle, int field, ... )
{
	va_list args;
	int parms, i;

	va_start(args, field);

	_GemParBlk.contrl[0] = 0x68;
	_GemParBlk.contrl[1] = 2;
	_GemParBlk.contrl[2] = 5;
	_GemParBlk.contrl[3] = 0;
	_GemParBlk.contrl[4] = 0;

	_GemParBlk.intin[0] = handle;
	_GemParBlk.intin[1] = field;

	aes();

	parms = argtab[(field - 1) & 0x1F];

	for(i = 0; i < parms; i++)
		*(va_arg(args, int *)) = _GemParBlk.intout[i + 1];

	va_end(args);

	return _GemParBlk.intout[0];
}
