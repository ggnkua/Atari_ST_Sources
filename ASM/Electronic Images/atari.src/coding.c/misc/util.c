#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "types.h"

void toggle_sign8(UBYTE *sam_data,UINT32 nsamples)
{	UINT32 	i;
    	for (i = 0 ; i < nsamples ; i++)
		*sam_data++ ^= (UBYTE) 0x80;
}

void toggle_sign16(UINT16 *sam_data,UINT32 nsamples)
{	UINT32 	i;
    	for (i = 0 ; i < nsamples ; i++)
		*sam_data++ ^= (UINT16) 0x8000;
}
