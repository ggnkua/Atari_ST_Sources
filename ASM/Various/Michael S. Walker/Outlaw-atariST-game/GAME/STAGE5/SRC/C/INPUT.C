#include <osbind.h>

/* 
 * Check the status of the console input device. 
 * Returns -1 if a character is waiting, 0 if none is available.
 */

int CheckInputStatus(void)
{
    return Cconis() < 0 ? -1 : 0;
}

/* 
 * Read a character from the console with no echo. 
 */

int ReadCharNoEcho(void)
{
    return Cnecin();
}
