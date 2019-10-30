/********************************************************************
 *																0.01*
 *	XAES: Special EXTINFO routines (attachment, settings, etc.)		*
 *	by Ken Hollis													*
 *																	*
 *	Copyright (C) 1994, Bitgate Software.							*
 *																	*
 *	These are the routines that are called only if you attach a		*
 *	routine to an object.  These are the very first preliminaries	*
 *	for the Windows-type Object Oriented routines.  At least they	*
 *	work!  Unfortunately, though, they only work for EXTINFO-type	*
 *	objects.  This will change soon, I hope...						*
 *																	*
 ********************************************************************/

#include <string.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include "xaes.h"

GLOBAL BOOL WAttachCode(int typ, OBJECT *obj, int object, void *rout)
{
	if ((obj[object].ob_type & 0xFF) == G_USERDEF) {
		EXTINFO *ex = (EXTINFO *)(obj[object].ob_spec.userblk->ub_parm);

		switch(typ) {
			case MOUSE_DOWN:
				ex->te_routines.mouse_down = rout;
				break;

			case MOUSE_UP:
				ex->te_routines.mouse_up = rout;
				break;

			case MOUSE_MOVE:
				ex->te_routines.mouse_move = rout;
				break;

			case MOUSE_CLICK:
				ex->te_routines.mouse_click = rout;
				break;
		}
		return TRUE;
	} else
		return FALSE;
}