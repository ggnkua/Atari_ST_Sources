/*
 * putch.c
 *
 *  Created on: 25.07.2019
 *      Author: og
 */

#include <ext.h>
#include <stdio.h>


int
putch(int c)
{
	Cconout(c & 0xff);
	return c;
}
