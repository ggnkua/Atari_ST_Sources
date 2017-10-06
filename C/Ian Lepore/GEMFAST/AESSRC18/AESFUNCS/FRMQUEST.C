/**************************************************************************
 * FRMQUEST.C - frm_question() function.
 *************************************************************************/

#include <stdarg.h>
#include "gemfast.h"

int frm_question(fmt)
	char	*fmt;
{
	va_list args;
	int 	rv;

	va_start(args, fmt);
	rv = frm_vprintf(FRM_DMUSTSELECT, "No\nYes", fmt, args);
	va_end(args);

	return rv;
}

