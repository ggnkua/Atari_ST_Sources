/**
 * Thing
 * Copyright (C) 1994-2012 Arno Welzel, Thomas Binder
 *
 * This program is free software: you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation, either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this program. If not, see
 * <http://www.gnu.org/licenses/>.
 *
 * @copyright  Arno Welzel, Thomas Binder 1994-2012
 * @author     Arno Welzel, Thomas Binder
 * @license    LGPL
 */

/**
 * Verschiedene Funktionen fuer Drag&Drop Protokoll.
 */

#include "..\include\thingtbx.h"

/**
 * Drag&Drop-Protokoll abweisen
 *
 * @param *mevent
 */
void ddnak(EVENT *mevent) {
	char *pipename = "U:\\PIPE\\DRAGDROP.AA";
	long fd;
	char c;

	pipename[18] = mevent->ev_mmgpbuf[7] & 0x00ff;
	pipename[17] = (mevent->ev_mmgpbuf[7] & 0xff00) >> 8;
	fd = Fopen(pipename, O_RDWR);
	if (fd >= 0L) {
		c = 1; /* DD_NAK */
		Fwrite((short) fd, 1, &c);
		Fclose((short) fd);
	}
}
