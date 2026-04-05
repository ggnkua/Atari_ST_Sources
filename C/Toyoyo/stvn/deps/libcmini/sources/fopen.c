/*
 * fopen.c
 *
 *  Created on: 29.05.2013
 *      Author: mfro
 */

#include <stdio.h>
#include <stdlib.h>
#include <mint/osbind.h>
#include <errno.h>
#include "lib.h"


FILE *fopen(const char *path, const char *mode)
{
	FILE *fp;
	long fd;
	int i;

	if (mode == NULL || path == NULL)
	{
		__set_errno(EFAULT);
		return NULL;
	}

	if ((fp = calloc(sizeof(FILE), 1)) == NULL)
		return NULL;

	switch (*mode)
	{
	case 'a':
		fp->__mode.__write = 1;
		fp->__mode.__create = 1;
		fp->__mode.__append = 1;
		break;

	case 'w':
		fp->__mode.__write = 1;
		fp->__mode.__create = 1;
		break;

	case 'r':
		fp->__mode.__read = 1;
		break;

	default:
		free(fp);
		return NULL;
	}

	for (i = 1; i < 4; ++i)
	{
		switch (*++mode)
		{
		case '\0':
		default:
			break;

		case '+':
			fp->__mode.__read = 1;
			fp->__mode.__write = 1;
			continue;

		case 'b':
			fp->__mode.__binary = 1;
			continue;

		case 'x':
			fp->__mode.__exclusive = 1;
			continue;
		}

		break;
	}

	if (fp->__mode.__append) {
		fd = Fopen(path, fp->__mode.__write ? 1 + fp->__mode.__read : 0);

		if(fd >= 0) {
			Fseek(0, fd, SEEK_END);
			goto ok;
		}
	}

	if (fp->__mode.__create) {
		fd = Fcreate (path, 0);

		if (fd < 0)
		{
			__set_errno(-fd);
			free(fp);
			return NULL;
		}
		if (fp->__mode.__read)
			goto ok;
		Fclose(fd);
	}

	if ((fd = Fopen(path, fp->__mode.__write ? 1 + fp->__mode.__read : 0)) >= 0)
		goto ok;
	__set_errno(-fd);
	free(fp);
	return NULL;

ok:
	fp->__magic = _IOMAGIC;
	FILE_SET_HANDLE(fp, fd);
	fp->__pushback = EOF;
#ifdef STDIO_MAP_NEWLINE
    fp->__last_char = EOF;
#endif /* defined STDIO_MAP_NEWLINE */
	fp->__next = __stdio_head;
	__stdio_head = fp;

	return fp;
}
