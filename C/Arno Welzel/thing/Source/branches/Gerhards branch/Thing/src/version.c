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

/*
 * version.c vom 22.05.1997
 *
 * Autor:
 * Thomas Binder
 * (binder@rbg.informatik.th-darmstadt.de)
 *
 * Zweck:
 * Erzeugt automatisch (durch entsprechende Abh„ngigkeiten im
 * Makefile) den String mit der aktuellen Versionsnummer und dem
 * Compilierdatum.
 *
 * History:
 * 23.10.1996: - Erstellung
 * 22.05.1997: - Die Versionsnummer wird version_str() jetzt mit
 *               uebergeben, was das #include von globdef.h spart und
 *               dadurch das Compilieren deutlich beschleunigt.
 */

#include <stdio.h>

char *version_str(char *langver, short vers) {
	static char _version_str[40];

	sprintf(_version_str, langver, vers / 100, vers % 100, __DATE__);
	return (_version_str);
}

/* EOF */
