/*
 * kbhit.c
 *
 *  Created on: 25.07.2019
 *      Author: og
 */

#include <ext.h>
#include <mint/osbind.h>


int
kbhit()
{
	return Bconstat(DEV_CONSOLE);
}
