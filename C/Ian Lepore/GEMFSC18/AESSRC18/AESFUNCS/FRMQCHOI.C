/**************************************************************************
 * FRMQCHOI.C - frm_qchoice() function.
 *************************************************************************/

#include <stdarg.h>
#include "gemfast.h"

int frm_qchoice(buttons, fmt)
	char	*buttons;
	char	*fmt;
{
	va_list args;
	int 	rv;

	va_start(args, fmt);
	rv = frm_vprintf(FRM_NORMAL, buttons, fmt, args);
	va_end(args);

	return rv;
}

