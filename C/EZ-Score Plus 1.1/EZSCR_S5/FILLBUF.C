#include <stdio.h>
#include <osbind.h>

FILE _iob[_NFILE] = {
    {NULL, 0, NULL, _READ | _UNBUF, STDIN, 0L, 0},    /* stdin */
    {NULL, 0, NULL, _WRITE | _LINBUF, STDOUT, 0L, _BUFSIZE},   /* stdout */
    {NULL, 0, NULL, _WRITE | _LINBUF, STDERR, 0L, _BUFSIZE}    /* stderr */
};
int _bufsize = _BUFSIZE;	/* default buffer size */

static char smallbuf[_NFILE];

_fillbuf(fp)
register FILE *fp;
{
    FILE *tp;
    char *_newptr();

    if (!(fp->_flag&_READ))
	fp->_flag |= _ERR;
    if ((fp->_flag&(_EOF|_ERR))) {
	return EOF;
	fp->_ptr = fp->_base;
	fp->_cnt = 0;
    }
    while (fp->_base == NULL)
	if (fp->_flag & _UNBUF)
	    fp->_base = fp->_ptr = &smallbuf[fp-_iob];
	else if ((fp->_base = fp->_ptr = _newptr((long)fp->_bufsize)) == NULL)
	    fp->_flag |= _UNBUF;
	else
	    fp->_flag |= _BIGBUF;
    tp = fp; 
    tp->_mark = Fseek(0L, fp->_fd, 1);
    fp->_ptr = fp->_base;
    if (fp->_fd == STDIN)	/* reading from keyboard, flush stdout */
	fflush(stdout);
    fp->_cnt = read(fp->_fd, fp->_ptr, 
	fp->_flag&(_UNBUF|_LINBUF) ? 1 : fp->_bufsize);
    if (--fp->_cnt < 0) {
	if (fp->_cnt == -1)
	    fp->_flag |= _EOF;
	else
	    fp->_flag |= _ERR;
	fp->_cnt = 0;
	return EOF;
    }
    return (*fp->_ptr++ & 0377);
}

_flushbuf(c, fp)
char c;
register FILE *fp;
{
    FILE *tp;
    char *_newptr();

    fp->_cnt = 0;
    if (!(fp->_flag&_WRITE))
	fp->_flag |= _ERR;
    if ((fp->_flag&_ERR))
	return EOF;
    while (fp->_base == NULL)
	if (fp->_flag & _UNBUF)
	    fp->_base = fp->_ptr = &smallbuf[fp-_iob];
	else if ((fp->_base = fp->_ptr = _newptr((long)fp->_bufsize)) == NULL)
	    fp->_flag |= _UNBUF;
	else
	    fp->_flag |= _BIGBUF;
    if (fp->_flag & _UNBUF) {
	*fp->_ptr++ = c;
	fp->_flag |= _DIRTY;
    } 
    else
	if (fp->_flag & _LINBUF) { 
	    fp->_flag |= _DIRTY;
	    *fp->_ptr++ = c;
	    if (c != '\n' && fp->_ptr - fp->_base < fp->_bufsize)
		return c & 0377;
	}

    if (fflush(fp)) {
	fp->_flag |= _ERR;
	return EOF;
    }
    if (fp->_flag & (_UNBUF|_LINBUF)) {
	fp->_cnt = 0;
	return c & 0377;
    }
    else {
	fp->_cnt = fp->_bufsize-1;
	fp->_flag |= _DIRTY;
	return (*fp->_ptr++ = c) & 0377;
    }
}

int ungetc(c, stream)
char c;
register FILE *stream;
{
    if (stream->_flag&_DIRTY || (stream->_ptr == stream->_base))
	return EOF;
    stream->_cnt++;
    return *--stream->_ptr = c;
}

int fgetc(stream)
FILE *stream;
{
    return getc(stream);
}

int getw(stream)
FILE *stream;
{
    register int lo, hi;

    if ((hi = fgetc(stream)) == EOF)
	return EOF;
    if ((lo = fgetc(stream)) == EOF)
	return EOF;
    return (hi << 8) + lo;
}

int fputc(c, stream)
char c;
FILE *stream;
{
    return putc(c, stream);
}

int putw(w, stream)
int w;
FILE *stream;
{
    if (putc(w >> 8 & 0377, stream) == EOF)
	return EOF;
    if (putc(w & 0377, stream) == EOF)
	return EOF;
    return w;
}
