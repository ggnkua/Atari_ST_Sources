/*
 * getche.c
 *
 *  Created on: 25.07.2019
 *      Author: og
 */

#include <ext.h>


int getche()
{
	int ch = 0;

	do {
		if (Cconis()) {
			ch = Cconin() & 0xff;
		}
	} while (ch == 0);

	if (ch == 0x1a) {
		// CTRL-Z
		ch = EOF;
	}

	return ch;
}
