/*
 * setdisk.c
 *
 *  Created on: 25.07.2019
 *      Author: og
 */

#include <ext.h>


long
setdisk(int drive)
{
	return Dsetdrv((short)drive);
}
