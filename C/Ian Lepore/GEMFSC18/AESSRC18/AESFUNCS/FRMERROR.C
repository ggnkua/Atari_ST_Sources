/**************************************************************************
 * FRMERROR.C - The frm_error() and frm_qerror() routines.
 *************************************************************************/

#include <stdarg.h>
#include "gemfast.h"
#include "exterror.h"

int frm_error(err, buttons, fmt)
    int     err;
    char    *buttons;
    char    *fmt;
{
    int     rv;
    va_list args;
    
    va_start(args, fmt);
    rv = frm_verror(err, buttons, fmt, args);
    va_end(args);
    
    return rv;
}


