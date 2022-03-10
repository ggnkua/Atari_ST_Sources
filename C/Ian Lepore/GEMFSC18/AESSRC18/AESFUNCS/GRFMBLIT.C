/**************************************************************************
 * GRFMBLIT.C - grf_memblit() function.
 *************************************************************************/

#include "gemfast.h"
#include <osbind.h>

#ifndef NULL
  #define NULL 0L
#endif

void *grf_memblit(options, buffer, prect)
    int      options;
    void    *buffer;
    void    *prect;
{
    long     mem_len;           /* total bytes needed for blit buffer */

/*----------------------------------------------------------------------*
 * if buffer is NULL, get a buffer, and blit from screen to buffer, 
 * else blit from provided buffer to screen.
 *----------------------------------------------------------------------*/

    options &= ~(GRF_BFROMSCREEN|GRF_BTOSCREEN); /* bufptr sets direction */

    if (buffer == NULL) {
        if (0 < (mem_len = grf_blit(options|GRF_BMEMCALC, NULL, prect))) {
            if (NULL != (buffer = apl_malloc(mem_len))) {
                if (0 == grf_blit(options|GRF_BFROMSCREEN, buffer, prect)) {
                    apl_free(buffer);
                    buffer = NULL;
                }
            }
        }
    } else {
        grf_blit(options|GRF_BTOSCREEN, buffer, prect);
        apl_free(buffer);
    }

    return buffer;
}


