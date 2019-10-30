/********************************************************************
 *																1.10*
 *	Sizing fixing and positioning routine							*
 *																	*
 *	Copyright (C) 1994, Bitgate Software							*
 *																	*
 *	These routines simply reposition objects that have been fixed	*
 *	by the Extended Object routine.									*
 *																	*
 ********************************************************************/

#include <stdlib.h>
#include "xaes.h"

#ifndef __SIZING__
#define __SIZING__
#endif

GLOBAL void position_fix(OBJECT *obj)
{
	int object = 1, objc, parent;
	int i, j;

	object = 1;

	do {
		object++;
		parent = object;
		if ((obj[parent].ob_state & DRAW3D) && !(obj[parent].ob_state & ALREADYMOD)) {
			for (objc = obj[parent].ob_head; objc>=0 && objc!=parent; objc = obj[objc].ob_next) {
				if ((obj[parent].ob_state & DRAW3D) && (objc!=1)) {
					if (!(obj[objc].ob_state & ALREADYMOD)) {
						EXTINFO *ex = (EXTINFO *) obj[parent].ob_spec.userblk->ub_parm;

						if (ex->te_thickness < 0) {
							obj[objc].ob_x += (abs(ex->te_thickness));
							obj[objc].ob_y += (abs(ex->te_thickness));
							obj[objc].ob_state |= ALREADYMOD;
						}
					}
				}
			}

			while(parent >= 0) {
				objc = parent;
				parent = -1;

				i = objc;

				do {
					if ((obj[parent].ob_state & DRAW3D) && (i!=1)) {
						EXTINFO *ex = (EXTINFO *) obj[parent].ob_spec.userblk->ub_parm;

						if (!(obj[i].ob_state & ALREADYMOD)) {
							if (ex->te_thickness < 0) {
								obj[i].ob_x += (abs(ex->te_thickness));
								obj[i].ob_y += (abs(ex->te_thickness));
								obj[i].ob_state |= ALREADYMOD;
							}
						}
					}

					if ((j = obj[i].ob_next) >= 0 && obj[j].ob_tail == i) {
						parent = j;
						i = obj[j].ob_head;
					} else
						i = j;
				} while(i>=0 && i!=objc);
			}
		}
	} while(!(obj[object].ob_flags & LASTOB));
}