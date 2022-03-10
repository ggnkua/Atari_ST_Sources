/**************************************************************************
 * FRMNLMEN.C - frm_nlmenu(): Newline-delimited menu.
 *************************************************************************/

#include "gemfast.h"

#ifndef NULL
  #define NULL 0L
#endif

#ifndef TRUE
  #define TRUE	1
  #define FALSE 0
#endif

/**************************************************************************
 *
 *************************************************************************/

int frm_nlmenu(options, title, strings)
	long			 options;
	register char	*title;
	register char	*strings;
{
	int 			status;
	char			*strptrs[FRM_DSMAXSTRINGS+1];
	char			*strpatches[FRM_DSMAXSTRINGS+1];

	if (strings == NULL || *strings == '\0') {
		strings = "<error: no items>";
	}

	_FrmNL2DS(strings, strptrs, strpatches, FRM_DSMAXSTRINGS);

	status = frm_dsmenu(options, title, strptrs);

	_FrmNLPatch(strpatches);

	return status;
}
