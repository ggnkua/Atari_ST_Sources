#include "config.h"
#include "fvdi.h"
#include "relocate.h"

long CDECL c_get_colour_1(Virtual *vwk, long colour)
{
	return colour;
}

void CDECL c_get_colours_1(Virtual *vwk, long colour, long *foreground, long *background)
{
	*foreground = colour & 0xffffL;
	*background = (colour >> 16) & 0xffffL;
}

