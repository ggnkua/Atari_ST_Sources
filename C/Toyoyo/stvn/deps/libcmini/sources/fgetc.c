/*
 * fgetc.c
 *
 *  Created on: 29.05.2013
 *      Author: mfro
 */

#include <stdio.h>
#include <mint/osbind.h>
#include "lib.h"


int fgetc(FILE *stream)
{
	unsigned char ch;
	long rc;
	
	if (stream->__pushback != EOF)
	{
		ch = stream->__pushback;
		stream->__pushback = EOF;
		return ch;
	}
	rc = Fread(FILE_GET_HANDLE(stream), 1, &ch);
	if (rc == 0)
	{
		stream->__eof = 1;
		return EOF;
	}
	if (rc < 0)
	{
		__set_errno(-rc);
		stream->__error = 1;
		return EOF;
	}
	return ch;
}
int getc(FILE *stream) __attribute__((alias("fgetc")));
