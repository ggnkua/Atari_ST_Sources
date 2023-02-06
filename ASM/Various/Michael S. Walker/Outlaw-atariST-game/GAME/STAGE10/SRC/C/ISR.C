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
