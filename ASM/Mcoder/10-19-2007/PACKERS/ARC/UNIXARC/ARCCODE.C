/*  ARC - Archive utility - ARCCODE

(C) COPYRIGHT 1985 by System Enhancement Associates; ALL RIGHTS RESERVED

    By:  Thom Henderson

    Description:
         This file contains the routines used to encrypt and decrypt
         data in an archive.  The encryption method is nothing fancy,
         being just a routine XOR, but it is used on the packed data,
         and uses a variable length key.  The end result is something
         that is in theory crackable, but I'd hate to try it.  It should
         be more than sufficient for casual use.

    Language:
         Computer Innovations Optimizing C86
*/
#include <stdio.h>
#include "arc.h"

static char *p;                        /* password pointer */

setcode()                              /* get set for encoding/decoding */
{
    p = password;                      /* reset password pointer */
}

int code(c)                            /* encode some character */
int c;                                 /* character to encode */
{
    if(p)                              /* if password is in use */
    {    if(!*p)                       /* if we reached the end */
              p = password;            /* then wrap back to the start */
         return c^*p++;                /* very simple here */
    }
    else return c;                     /* else no encryption */
}
