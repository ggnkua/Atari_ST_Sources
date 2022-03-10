/**************************************************************************
 * FRMQERR.C - The frm_qerror() routine.
 *************************************************************************/

#include <stdarg.h>
#include "gemfast.h"

#ifndef NULL
  #define NULL 0L
#endif

int frm_qerror(err, fmt)
    char *fmt;
{
    va_list args;
    
    va_start(args, fmt);
    frm_verror(err, NULL, fmt, args);
    va_end(args);
    
    return err;
}
