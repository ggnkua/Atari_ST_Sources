/**************************************************************************
 * FRMVERRO.C - The frm_verror() routine.
 *************************************************************************/

#include <stdarg.h>
#include "gemfast.h"
#include "exterror.h"

#ifndef NULL
  #define NULL 0L
#endif

extern char *_Frmaddmsg;

int frm_verror(err, buttons, fmt, args)
	int 	err;
	char	*buttons;
	char	*fmt;
	va_list args;
{
	char	*msg;

	if (err) {
		if (NULL == (msg = exterror(err))) {
			msg = "<no message>";
		}
		_Frmaddmsg = msg;
	}

	return frm_vprintf(FRM_NORMAL, buttons, fmt, args);
}
