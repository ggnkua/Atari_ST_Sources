/*
 * strerror_r.c
 *
 *  Created on: 23.03.2014
 *      Author: ardi
 */

#define _GNU_SOURCE

#include <string.h>

char *strerror_r(int errnum, char *buf, size_t bufsize)
{
	char *retval;
	size_t len;
	size_t copylen;

	if (buf == NULL || bufsize == 0)
		return buf;
	retval = strerror(errnum);
	len = strlen(retval);

	copylen = len < (bufsize - 1) ? len : (bufsize - 1);

	memcpy(buf, retval, copylen);
	buf[copylen] = '\0';
	return buf;
}
