/**************************************************************************
 * FRMVPRTF.C - frm_vprintf() function.
 *************************************************************************/

#include <osbind.h>
#include <stdarg.h>
#include "gemfast.h"
#include "frmtypes.h"

#ifndef NULL
  #define NULL 0L
#endif

char	*_Frmaddmsg = NULL; 	/* hook for frm_error() to add a message */

/**************************************************************************
 *
 *************************************************************************/

int frm_vprintf(options, buttons, fmt, args)
	long			options;
	register char	*buttons;
	register char	*fmt;
	va_list 		args;
{
	int 	status;
	int 	position;
	char	*msgbuf;

	msgbuf = _FrmVFormat(fmt, args, &position);

	if (_Frmaddmsg != NULL && position != -1) {
		strcpy(&msgbuf[position], _Frmaddmsg);
		_Frmaddmsg = NULL;
	}

	status = frm_nldial(options, buttons, msgbuf);

	_FrmVFree(msgbuf);

	return status;
}

