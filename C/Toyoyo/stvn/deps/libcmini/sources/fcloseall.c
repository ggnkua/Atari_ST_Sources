/*
 * fcloseall.c
 *
 *  Created on: 10.07.2017
 *      Author: og
 */

#include <stdio.h>
#include <stdlib.h>
#include <mint/osbind.h>
#include "lib.h"


int fcloseall(void)
{
	/* close all streams */

	FILE *f, *next;

	for (f = __stdio_head; f != NULL; f = next)
	{
		next = f->__next;
		fclose(f);
	}

	return 0;
}
