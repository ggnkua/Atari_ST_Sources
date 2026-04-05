/*
 * fclose.c
 *
 *  Created on: 29.05.2013
 *      Author: mfro
 */

#include <stdio.h>
#include <stdlib.h>
#include <mint/osbind.h>
#include "lib.h"


int fclose(FILE *fp)
{
	if (fp && fp->__magic == _IOMAGIC)
	{
		FILE **prev;
		
		Fclose(FILE_GET_HANDLE(fp));
		FILE_SET_HANDLE(fp, -7);
		fp->__magic = 0;

		prev = &__stdio_head;
		for (prev = &__stdio_head; (*prev) && *prev != fp; prev = &(*prev)->__next)
			;
		if (*prev == fp)
		{
			*prev = fp->__next;
			free(fp);
		}
	}
	return 0;
}
