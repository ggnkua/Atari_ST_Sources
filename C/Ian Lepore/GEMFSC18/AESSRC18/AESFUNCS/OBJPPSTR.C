/**************************************************************************
 * OBJPPSTR.C - Return a pointer to an object's string pointer.
 *************************************************************************/

#include "gemfast.h"

char **obj_ppstring(pobj)
	register OBJECT *pobj;
{
	register int  ob_type;
	register long *pspec;

	ob_type = pobj->ob_type & 0x00FF;
	pspec	= &pobj->ob_spec;

	if (pobj->ob_flags & INDIRECT) {
		pspec = (long *)(*pspec);
	}

	if (ob_type == G_USERDEF) {
		register XUSERBLK *pxub = (XUSERBLK *)(*pspec);
		if (pxub->ub_self == pxub) {
			ob_type = pxub->ob_type;
			pspec	= &pxub->ob_spec;
		}
	}

	switch (ob_type) {
	  case G_ICON:
		pspec = (long *)(*pspec);
		pspec = &pspec[2];		/* add 12-byte offset to pointer */
		break;
	  case G_TEXT:
	  case G_BOXTEXT:
	  case G_FTEXT:
	  case G_FBOXTEXT:
		pspec = (long *)(*pspec);
		break;
	}

	return (char **)pspec;
}

