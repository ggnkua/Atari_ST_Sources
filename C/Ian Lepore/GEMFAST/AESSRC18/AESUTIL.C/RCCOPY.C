/**************************************************************************
 * RCCOPY.C - Copy a rectangle (or any 2 longwords).
 *************************************************************************/

void *rc_copy(psrce, pdest)
    long *psrce;
    long *pdest;
{
    pdest[0] = psrce[0];
    pdest[1] = psrce[1];
    return pdest;
}

