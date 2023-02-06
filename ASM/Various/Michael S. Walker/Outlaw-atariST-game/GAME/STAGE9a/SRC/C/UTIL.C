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
#include <ISR.H>

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

/*-------------------------------------------- MySleep -----
|  Function MySleep
|
|  Purpose: sleep for n seconds
|
|  Parameters: n time to sleep 
|
|  Returns:
*-------------------------------------------------------------------*/

void MySleep(int n)
{
	int i = 0;

	ResetSeconds();
	while (GetSeconds() < 2)
		if ((i + 1) == GetSeconds())
			i++;
	return;
}

/*-------------------------------------------- GetTime -----
|  Function GetTime
|
|  Purpose: Get vblank time 
|
|  Parameters:
|
|  Returns: n vblank cycles since reset
*-------------------------------------------------------------------*/

uint32_t GetTime(void)
{
	return MyVblank();
}
