/**************************************************************************
 * FRMVFMT.C - Allocate a 2k buffer, format text into it with vsprintf().
 *************************************************************************/

#include <stdarg.h>
#include "gemfast.h"

#ifndef NULL
  #define NULL 0L
#endif

static char errmsg[] = "\n"
                       "<Internal error: Can't get buffer to format message>"
                       "\n"
                       ;

static char nullmsg[] = "\n"
                        "<Internal error: NULL format pointer>\n"
                        "\n"
                        ;

void _FrmVFree(buffer)
    char *buffer;
{
    if (buffer != NULL && buffer != errmsg && buffer != nullmsg) {
        apl_free(buffer);
    }
}

char *_FrmVFormat(fmt, args, plen)
    char    *fmt;
    va_list args;
    int     *plen;
{
    char    *buffer;
    int     len;
    
    if (NULL == fmt) {
        buffer = nullmsg;
        len    = -1;
    } else if (NULL == (buffer = apl_malloc(2048L))) {
        buffer = errmsg;
        len    = -1;
    } else {
        len = vsprintf(buffer, fmt, args);
    }
    
    if (plen != NULL) {
        *plen = len;
    }
    
    return buffer;
}

