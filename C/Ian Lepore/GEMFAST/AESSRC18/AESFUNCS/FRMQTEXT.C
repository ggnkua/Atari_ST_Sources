/**************************************************************************
 * FRMQTEXT.C - frm_qtext() function.
 *************************************************************************/

#include <stdarg.h>
#include "gemfast.h"

#ifndef NULL
  #define NULL 0L
#endif

void  frm_qtext(fmt)
	char	*fmt;
{
	va_list args;

	va_start(args, fmt);
	frm_vprintf(FRM_NORMAL, NULL, fmt, args);
	va_end(args);
}

