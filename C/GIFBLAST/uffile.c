/* uffile.c - Portable fast file routines, UNIX version. */

#include <stdio.h>
#include <string.h>

#include "ubasic.h"
#include "uffile.h"

FFILE *
ff_open(fpath,mode)
char *fpath; int mode;
{
	FFILE *ff;

	if ((ff=(FFILE *)basic_alloc(sizeof(FFILE))) == NULL)
		return NULL;
	if ((ff->f=fopen(fpath,(mode==FF_READ?"rb":"wb"))) == NULL) {
		basic_free(ff);
		return NULL;
	}
	ff->mode = mode;
	ff->pos = ff->count = (mode==FF_READ?1:0);
	return ff;
}

static void
ff___fillbuf(ff)
FFILE *ff;
{
	ff->pos = 0;
	ff->count = fread(ff->buf,1,FFILEBUFSIZE,ff->f);
	if (ff->count == 0)
		ff->pos = ff->count = 1;
}

int
ff___inbuf(ff)
FFILE *ff;
{
	ff___fillbuf(ff);
	return (ff->pos==ff->count ? EOF : ff->buf[ff->pos++]);
}

int
ff_ungetc(c,ff)
int c; FFILE *ff;
{
	return ((c==EOF || ff->pos==0) ? EOF : (ff->buf[--ff->pos]=c));
}

size_t
ff_read(buf,n,ff)
char *buf; size_t n; FFILE *ff;
{
	size_t offset;

	offset = 0;
	while (n-offset > ff->count-ff->pos) {
		if (ff->count-ff->pos > 0)
			memcpy(buf+offset,ff->buf+ff->pos,ff->count-ff->pos);
		offset += (ff->count-ff->pos);
		ff___fillbuf(ff);
		if (ff->pos == ff->count)
			return offset;
	}
	if (n-offset > 0)
		memcpy(buf+offset,ff->buf+ff->pos,n-offset);
	ff->pos += (n-offset);
	return n;
}

static void
ff___flushbuf(ff)
FFILE *ff;
{
	size_t count,i;

	if (ff->count == 0)
		return;
	count = fwrite(ff->buf,1,ff->count,ff->f);
	if (0<count && count<ff->count) {
		for (i=0; i<ff->count-count; i++)
			ff->buf[i] = ff->buf[count+i];
	}
	ff->count -= count;
}

int
ff___outbuf(c,ff)
int c; FFILE *ff;
{
	ff___flushbuf(ff);
	if (ff->count != 0)
		return EOF;
	else
		return (ff->buf[ff->count++] = c);
}

int
ff_unputc(ff)
FFILE *ff;
{
	return (ff->count==0 ? EOF : ff->buf[--ff->count]);
}

size_t
ff_write(buf,n,ff)
char *buf; size_t n; FFILE *ff;
{
	size_t offset;

	offset = 0;
	while (n-offset > FFILEBUFSIZE-ff->count) {
		if (FFILEBUFSIZE-ff->count > 0)
			memcpy(ff->buf+ff->count,buf+offset,FFILEBUFSIZE-ff->count);
		offset += (FFILEBUFSIZE-ff->count);
		ff->count = FFILEBUFSIZE;
		ff___flushbuf(ff);
		if (ff->count != 0)
			return offset;
	}
	if (n-offset > 0)
		memcpy(ff->buf+ff->count,buf+offset,n-offset);
	ff->count += (n-offset);
	return n;
}

int
ff_seek(ff,offset,whence)
FFILE *ff; long offset; int whence;
{
	if (ff->mode == FF_READ)
		ff->pos = ff->count = 1;
	else {
		ff___flushbuf(ff);
		if (ff->count != 0)
			return -1;
	}
	return fseek(ff->f,offset,whence);
}

long
ff_tell(ff)
FFILE *ff;
{
	long fpos;

	fpos = ftell(ff->f);
	if (fpos == -1L)
		return fpos;
	else if (ff->mode == FF_READ)
		return fpos-(ff->count-ff->pos);
	else
		return fpos+ff->count;
}

int
ff_flush(ff)
FFILE *ff;
{
	if (ff->mode == FF_READ)
		ff->pos = ff->count = 1;
	else {
		ff___flushbuf(ff);
		if (ff->count != 0)
			return EOF;
	}
	return fflush(ff->f);
}

int
ff_close(ff)
FFILE *ff;
{
	int res;
	FILE *f;

	if (ff->mode == FF_READ)
		res = 0;
	else {
		ff___flushbuf(ff);
		res = (ff->count!=0 ? EOF : 0);
	}
	f = ff->f;
	basic_free(ff);
	if (fclose(f) == EOF)
		return EOF;
	else
		return res;
}

void
ff_start1bit(ff)
FFILE *ff;
{
	ff->onebitpos = 0;
}

int
ff___in1bit(ff)
FFILE *ff;
{
	ff___fillbuf(ff);
	if (ff->pos == ff->count)
		return -1;
	ff->onebitpos++;
	return (ff->buf[ff->pos]&1);
}

int
ff___out1bit(ff,bit)
FFILE *ff; int bit;
{
	ff___flushbuf(ff);
	if (ff->count != 0)
		return -1;
	ff->onebitpos++;
	return (ff->buf[ff->count] = (bit&1));
}

int
ff_end1bit(ff)
FFILE *ff;
{
	if (ff->onebitpos > 0) {
		if (ff->mode == FF_READ)
			ff->pos++;
		else
			ff->count++;
		ff->onebitpos = 0;
	}
	return 0;
}
