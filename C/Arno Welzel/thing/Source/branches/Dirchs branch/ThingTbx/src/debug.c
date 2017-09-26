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

#ifdef DEBUG
#include "..\include\thingtbx.h"
#include <stdarg.h>

/**
 *
 *
 * @param
 * @param
 */
void debugLog(int init, char *logFile, const char *format, ...) {
	FILE *fh;
	va_list va;
	char logfileName[256];

	sprintf(logfileName, "%s%s", tb.homepath, logFile);
	if ((fh = fopen(logfileName, init ? "w" : "a")) == NULL)
		return;

	va_start(va, format);
	vfprintf(fh, format, va);
	va_end(va);
	fclose(fh);
}
#endif
