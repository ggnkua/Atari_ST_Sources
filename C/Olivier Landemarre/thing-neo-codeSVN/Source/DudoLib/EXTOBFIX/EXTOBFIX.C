/**
 * DudoLib - Dirchs user defined object library
 * Copyright (C) 1994-2012 Dirk Klemmt
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
 * @copyright  Dirk Klemmt 1994-2012
 * @author     Dirk Klemmt
 * @license    LGPL
 */

#include <stddef.h>
#include <portab.h>
#include "..\include\dudolib.h"

LOCAL VOID fix_objs(OBJECT *tree, BOOLEAN is_dialog);
GLOBAL LONG pinit_obfix(BOOLEAN status);

LOCAL LONG routines[] = {
	(LONG)fix_objs,
	0L,
	0L,
	0L,
	'0610', '1965',				/* Magic */
	(LONG)pinit_obfix,
};

LOCAL VOID fix_objs(OBJECT *tree, BOOLEAN is_dialog) {
	setUserdefs(tree, !is_dialog);
	setBackgroundBorderLine(tree, 0, TRUE);
}

GLOBAL LONG pinit_obfix(BOOLEAN status) {
	if (status == TRUE) {
		if (initDudolib() != USR_NOERROR)
			return (0L);

		return ((LONG)routines);
	} 

	releaseDudolib();
	return (0L);
}

main() {
	LOCAL LONG du;
	
	du = routines[6];
	return (0);
}
