/*
 * Copyright 1992 Eric R. Smith. All rights reserved.
 * Redistribution is permitted only if the distribution
 * is not for profit, and only if all documentation
 * (including, in particular, the file "copying")
 * is included in the distribution in unmodified form.
 * THIS PROGRAM COMES WITH ABSOLUTELY NO WARRANTY, NOT
 * EVEN THE IMPLIED WARRANTIES OF MERCHANTIBILITY OR
 * FITNESS FOR A PARTICULAR PURPOSE. USE AT YOUR OWN
 * RISK.
 */
#include <osbind.h>
#include <stdlib.h>
#include "filbuf.h"

FILBUF *
FBopen(name)
	char *name;
{
	FILBUF *f;

	f = malloc( sizeof(FILBUF) );
	if (!f) return f;

	f->fd = Fopen(name, 0);
	if (f->fd < 0) {
		free(f);
		return 0;
	}
	f->nbytes = 0;
	return f;
}

void
FBclose(f)
	FILBUF *f;
{
	Fclose(f->fd);
	free(f);
}

int
FBgetchar(f)
	FILBUF *f;
{
	int r;

	if (f->nbytes <= 0) {
		r = Fread(f->fd, (long)FILBUFSIZ, f->buf);
		if (r <= 0) return -1;	/* EOF */
		f->nbytes = r;
		f->ptr = f->buf;
	}
	f->nbytes--;
	r = *f->ptr;
	f->ptr++;
	return r;
}

char *
FBgets(f, buf, siz)
	FILBUF *f;
	char *buf;
	int siz;
{
	char *obuf;
	int c;

	obuf = buf;
	if (siz <= 0) return 0;

	--siz;		/* for the trailing NULL */

	for(;;) {
		c = FBgetchar(f);
		if (c == '\n') break;
		if (c < 0) return 0;
		if (siz && c != '\r') {
			*buf++ = c;
			--siz;
		}
	}
	*buf++ = 0;
	return obuf;
}
