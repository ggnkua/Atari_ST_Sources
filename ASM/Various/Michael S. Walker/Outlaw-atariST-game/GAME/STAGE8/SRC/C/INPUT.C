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

#include <osbind.h>

/*-------------------------------------------- CheckInputStatus -----
|  Function CheckInputStatus
|
|  Purpose: Check the status of the console input device. 
|
|  Parameters:
|
|  Returns: -1 if a character is waiting, 0 if none is available
*-------------------------------------------------------------------*/

int CheckInputStatus(void)
{
    return Cconis();
}

/*-------------------------------------------- ReadCharNoEcho -----
|  Function ReadCharNoEcho
|
|  Purpose: Read a character from the console with no echo. 
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

int ReadCharNoEcho(void)
{
    return Cnecin();
}
