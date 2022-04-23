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

#include "..\include\globdef.h"

#ifdef DEBUG
#include <stdarg.h>

/**
 *
 *
 * @param
 * @param
 */
void debugLog(int init, const char *format, ...) {
	FILE *fh;
	va_list va;
	char logfileName[MAX_PLEN];

	sprintf(logfileName, "%s%s", tb.homepath, "thing.log");
	if ((fh = fopen(logfileName, init ? "w" : "a")) == NULL)
		return;

	va_start(va, format);
	vfprintf(fh, format, va);
	va_end(va);
	fclose(fh);
}
#endif

#ifdef _DEBUG
/**
 *
 *
 * @param *txt
 */
void debugMain(char *debugMsg) {
	FILE *fh;

	if (glob.debug_level > 0) {
		fh = fopen(glob.debug_name, "a");
		if (fh) {
			fprintf(fh, "%s\n", debugMsg);
			fclose(fh);
		} else {
			sprintf(almsg, "[3][Failed to create file|%s|debug disabled][ OK ]", glob.debug_name);
			form_alert(1, almsg);
		}
	}
}
#endif
