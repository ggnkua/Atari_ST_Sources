/*
 * getch.c
 *
 *  Created on: 25.07.2019
 *      Author: og
 */

#include <ext.h>
#include <stdio.h>


int getch()
{
	int ch = 0;

	do {
		if (Cconis()) {
			ch = Cnecin() & 0xff;
		}
	} while (ch == 0);

	return ch;
}
