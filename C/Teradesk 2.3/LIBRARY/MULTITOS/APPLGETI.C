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

#include <np_aes.h>			/* DjV 001 241202 */
#include <multitos.h>

int appl_getinfo(int ap_gtype,
				 int *ap_gout1, int *ap_gout2,
				 int *ap_gout3, int *ap_gout4)
{
	_GemParBlk.contrl[0] = 130;
	_GemParBlk.contrl[1] = 1;
	_GemParBlk.contrl[2] = 5;
	_GemParBlk.contrl[3] = 0;
	_GemParBlk.contrl[4] = 0;

	_GemParBlk.intin[0] = ap_gtype;

	aes();

	*ap_gout1 = _GemParBlk.intout[1];
	*ap_gout2 = _GemParBlk.intout[2];
	*ap_gout3 = _GemParBlk.intout[3];
	*ap_gout4 = _GemParBlk.intout[4];

	return _GemParBlk.intout[0];
}

int objc_sysvar(int mo, int which,
				int  ivall, int  ival2,
                int *oval1, int *oval2)
{
	_GemParBlk.contrl[0] = 48;
	_GemParBlk.contrl[1] = 4;
	_GemParBlk.contrl[2] = 3;
	_GemParBlk.contrl[3] = 0;
	_GemParBlk.contrl[4] = 0;

	_GemParBlk.intin[0] = mo;
	_GemParBlk.intin[1] = which;
	_GemParBlk.intin[2] = ivall;
	_GemParBlk.intin[3] = ival2;

	aes();

	*oval1 = _GemParBlk.intout[1];
	*oval2 = _GemParBlk.intout[2];

	return _GemParBlk.intout[0];
}
