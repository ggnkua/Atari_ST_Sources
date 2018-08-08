/* PPP implementation for STiK - packet grabbin' routine */
#include "lattice.h"
#include <stdio.h>
#include <string.h>		/* for memcpy */
#include "krmalloc.h"
#include "globdefs.h"
#include "globdecl.h"
#include "display.h"
#include "ppp.h"
#include "ppp.p"

UWORD neg_mru = DEFAULT_MRU;

/****************************** getinpkt() *******************************/
ULONG getinpkt(GPKT **inpkt, UWORD *buf_avail, BYTE **nextin,
                UWORD *bufsize)
{
    UWORD len;                              /* To re-init nextin */
    BYTE *memblock;                        /* Pointer to memory block */

    /* See if we were in the middle of a packet */
    if (*inpkt == GPNULL)
	{
        /* Guess not - allocate one now */
        *buf_avail = neg_mru + FRAME_OVERHEAD;
        
        *inpkt = allocate_packet(*buf_avail);

        /* Make sure we got one */
        if (*inpkt == GPNULL)
            return FAIL;
            
        /* Set up the next in pointer */
        *nextin = (*inpkt)->pip;

        /* Clear out the protocol type */
        (*inpkt)->protocol = 0;
    }
    /* Check the buffer space */
    else if ((*buf_avail)==0)
    {
        /* Re-allocate the buffer */
        *buf_avail = config.mtu;
        len = *bufsize;
        *bufsize += neg_mru;
        
        /*disp_info("getinpkt: calling STiKrealloc");
        memblock = STiKrealloc((*inpkt)->pip, (LONG)(*bufsize));*/
        
        memblock = STiKmalloc((LONG)(*bufsize));
        
        if (!memblock)
        {
            delete_packet(*inpkt, EI_MTUEXCEEDED);
            return (FAIL);
        }
		memcpy(memblock,(*inpkt)->pip, (LONG)(*bufsize));

		while(STiKfree( (*inpkt)->pip ) == E_LOCKED)
			;
			
        /* Attach the memory and get ready to add characters */
        (*inpkt)->fp = (*inpkt)->pip = memblock;
        *nextin = &((*inpkt)->pip[len]);
    }

    /* Made it here - must be OK */
    return (OK);
} /* getinpkt() */
