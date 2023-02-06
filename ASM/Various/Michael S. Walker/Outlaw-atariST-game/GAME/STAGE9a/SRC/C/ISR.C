/*
 * Michael S. Walker <mwalk762@mtroyal.ca>
 *	    _    _
 *       | |  | |	OUTLAW. 
 *      -| |  | |- 
 *  _    | |- | |
 *-| |   | |  | |- 	
 * |.|  -| ||/  |
 * | |-  |  ___/ 
 *-|.|   | | |
 * |  \_|| |
 *  \____  |
 *   |   | |- 
 *       | |
 *      -| |
 *       |_| Copyleft !(c) 2020 All Rights Unreserved in all Federations, including Alpha Centauris.
 */

#include <ISR.H>

int g_seconds;
long g_ticks;
char g_vblank_flag;

/*-------------------------------------------- InstallVector -----
|  Function InstallVector
|
|  Purpose: Install interupt vector
|
|  Parameters: num vector # to install, pointer to vector function to save. 
|
|  Returns:
*-------------------------------------------------------------------*/

Vector InstallVector(int num, Vector vector)
{
	Vector orig;
	Vector *vectp = (Vector *)((long)num << 2);
	/*	long old_ssp = Super(0); */

	orig = *vectp;
	*vectp = vector;

	/*	Super(old_ssp); */
	return orig;
}

/*-------------------------------------------- do_VBL_ISR -----
|  Function do_VBL_ISR
|
|  Purpose: increment g_ticks each time vsync happens.
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void do_VBL_ISR(void)
{
	g_ticks += 1;

	if (g_ticks % 70 == 0)
		g_seconds++;
	g_vblank_flag = 1;
}

/*-------------------------------------------- MyVsync -----
|  Function MyVsync
|
|  Purpose: busywait for vblank
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void MyVsync(void)
{
	while (!g_vblank_flag)
		;
	g_vblank_flag = 0;
}

/*-------------------------------------------- MyVblank -----
|  Function MyVblank
|
|  Purpose: Get vblank time 
|
|  Parameters:
|
|  Returns: n vblank cycles since reset
*-------------------------------------------------------------------*/

long MyVblank(void)
{
	return g_ticks;
}

/*-------------------------------------------- GetSeconds -----
|  Function GetSeconds
|
|  Purpose: Get seconds since reset
|
|  Parameters:
|
|  Returns: seconds since reset
*-------------------------------------------------------------------*/

int GetSeconds(void)
{
	return g_seconds;
}

/*-------------------------------------------- ResetSeconds -----
|  Function ResetSeconds
|
|  Purpose: reset seconds to 0
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void ResetSeconds(void)
{
	g_seconds = 0;
}

/*-------------------------------------------- ResetTicks -----
|  Function ResetTicks
|
|  Purpose: Reset vblank ticks to 0 
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void ResetTicks(void)
{
	g_ticks = 0;
}

/*-------------------------------------------- ResetVblankFlag -----
|  Function ResetVblankFlag
|
|  Purpose: set flag to 0 
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void ResetVblankFlag(void)
{
	g_vblank_flag = 0;
}
