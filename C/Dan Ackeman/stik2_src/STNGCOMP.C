/* 
 * STiNG Compatibility routines.  Just a few.  
 *
 * version 	0.1
 * date		June 7, 2000
 * author	Dan Ackerman (baldrick@zeus.netset.com)
 *
 * version .2 New
 *    - Fixed setting of options in RAW_send
 */

#include "lattice.h"
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include "krmalloc.h"
#include "display.h"
#include "globdefs.h"
#include "globdecl.h"

extern CCB ctn[];  /* Connection Control Block list */

/* 
 *  TCP_info - A sting routine
 * 
 *  Not implemented at the moment.  But all necessary definitions
 * exist.
 */


int16 cdecl 
TCP_info(int16 cn, TCPIB *data)
{
     if (cn < 0 || cn >= CNMAX)
        return (E_BADHANDLE);

    return (E_BADROUTINE);
}

/* 
 *  UDP_info - A sting routine
 * 
 *  Not implemented at the moment.  But all necessary definitions
 * exist.
 */


int16 cdecl 
UDP_info(int16 cn, void *data)
{
     if (cn < 0 || cn >= CNMAX)
        return (E_BADHANDLE);

    return (E_BADROUTINE);
}


/* 
 * cntrl_port - another sting routine
 *
 * Not implemented yet.  Will have to research how to implement.
 */

int16 cdecl
cntrl_port(char *port, uint32 param1, int16 param2)
{

    return (E_BADROUTINE);
}

