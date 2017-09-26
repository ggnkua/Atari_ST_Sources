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

#include "..\include\dudolib.h"

#ifdef _USR_EDITFIELD_
WORD getScrollOffset(OBJECT *tree, WORD object) {
	UBPARM *ubparm;

	if ((tree[object].ob_type & 0xFF) != G_USERDEF)
		return(0);

	ubparm = (UBPARM *)tree[object].ob_spec.userblk->ub_parm;
	if (ubparm->magic == 'DIRK')
		return(ubparm->scrollOffset);

	return(0);
}

void setScrollOffset(OBJECT *tree, WORD object, WORD scrollOffset) {
	UBPARM *ubparm;

	if ((tree[object].ob_type & 0xFF) != G_USERDEF)
		return;

	ubparm = (UBPARM *)tree[object].ob_spec.userblk->ub_parm;
	if (ubparm->magic == 'DIRK')
		ubparm->scrollOffset = scrollOffset;
}

WORD pixel2index() {
	return (0);
}

WORD index2pixel() {
	return (0);
}

WORD getCursorIndex(OBJECT *tree, WORD object) {
	UBPARM *ubparm;

	if ((tree[object].ob_type & 0xFF) != G_USERDEF)
		return(0);

	ubparm = (UBPARM *)tree[object].ob_spec.userblk->ub_parm;
	if (ubparm->magic == 'DIRK')
		return(ubparm->cursorIndex);

	return(0);
}

void setCursorIndex(OBJECT *tree, WORD object, WORD cursorIndex) {
	UBPARM *ubparm;

	if ((tree[object].ob_type & 0xFF) != G_USERDEF)
		return;

	ubparm = (UBPARM *)tree[object].ob_spec.userblk->ub_parm;
	if (ubparm->magic == 'DIRK')
		ubparm->cursorIndex = cursorIndex;
}
#endif
