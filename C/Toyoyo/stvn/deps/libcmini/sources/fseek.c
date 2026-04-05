/*
 * fseek.c
 *
 *  Created on: 29.05.2013
 *      Author: mfro
 */

#include <stdio.h>
#include <stdlib.h>
#include <mint/osbind.h>
#include <errno.h>
#include "lib.h"


int fseek(FILE *fp, long offset, int origin)
{
	long res;

	if (fp == NULL || fp->__magic != _IOMAGIC)
	{
		__set_errno(EBADF);
		return -1;
	}
	res = Fseek(offset, FILE_GET_HANDLE(fp), origin);
	if (res < 0)
	{
		__set_errno(-res);
		return -1;
	}
	fp->__eof = 0;
	fp->__pushback = EOF;
#ifdef STDIO_MAP_NEWLINE
    fp->__last_char = EOF;
#endif /* defined STDIO_MAP_NEWLINE */
	return 0;
}

