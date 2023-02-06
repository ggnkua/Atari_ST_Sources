/*
 * Michael S. Walker <mwalk762@mtroyal.ca>
 *         _    _
 *        | |  | |	OUTLAW. 
 *       -| |  | |- 
 *   _    | |- | |
 * -| |   | |  | |- 	
 *  |.|  -| ||/  |
 *  | |-  |  ___/ 
 * -|.|   | | |
 *  |  \_|| |
 *   \____  |
 *    |   | |- 
 *        | |
 *       -| |
 *        |_| Copyleft !(c) 2020 All Rights Unreserved in all Federations, including Alpha Centauris.
 */

#include <UTIL.H>

unsigned short lfsr = 0xACE1u;
unsigned bit;

/*-------------------------------------------- WrapInteger -----
|  Function WrapInteger
|
|  Purpose:
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

int WrapInteger(int x, int min, int range)
{
	if (x >= min)
	{
		if (x >= range)
			return x - range;
		return x;
	}
	else
		return x + range;
}

/*-------------------------------------------- TrimLine -----
|  Function TrimLine
|
|  Purpose:
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void TrimLine(int *x, int min, int max)
{
	if (*x >= min)
	{
		if (*x >= max)
			*x = max - 1;
	}
	else
		*x = min;
}

/*-------------------------------------------- MyRand -----
|  Function MyRand
|
|  Purpose:
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

unsigned MyRand(void)
{
	bit = ((lfsr >> 0) ^ (lfsr >> 2) ^ (lfsr >> 3) ^ (lfsr >> 5)) & 1;
	return lfsr = (lfsr >> 1) | (bit << 15);
}
