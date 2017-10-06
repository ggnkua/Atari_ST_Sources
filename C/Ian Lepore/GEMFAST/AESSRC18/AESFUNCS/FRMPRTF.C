/**************************************************************************
 * FRMPRTF.C - frm_printf() function.
 *************************************************************************/

#include <stdarg.h>
#include "gemfast.h"

int frm_printf(options, buttons, fmt)
	long	options;
	char	*buttons;
	char	*fmt;
{
	va_list args;
	int 	rv;

	va_start(args, fmt);
	rv = frm_vprintf(options, buttons, fmt, args);
	va_end(args);

	return rv;
}

