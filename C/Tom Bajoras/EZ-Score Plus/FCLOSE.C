#include <stdio.h>

int fclose(stream)
register FILE *stream;
{
    if (fflush(stream))
	return EOF;
    if (stream->_flag & _BIGBUF)
	_disposptr(stream->_base);
    stream->_flag = 0;
    if (close(stream->_fd))	/* ST specific */
	return EOF;
    return 0;
}

int fflush(stream)
register FILE *stream;
{
    register int len;
    long lseek();

    if (!(stream->_flag&(_READ|_WRITE)))
	return EOF;
    len = stream->_ptr - stream->_base;
    if (stream->_flag & _DIRTY) {
	if (!(stream->_flag & _WRITE))
	    return EOF;
	if (stream->_flag & _APPEND)
	    lseek(stream->_fd, 0L, 2);	  /* go to end for append */

	if (write(stream->_fd, stream->_base, len) == -1)
	    return EOF;
	stream->_flag &= ~_DIRTY;    /* no longer dirty */
	stream->_mark += len;
    }
    else
	if (stream->_fd > 0) 
	    stream->_mark = lseek(stream->_fd, (long)-stream->_cnt ,1);
	
    stream->_ptr = stream->_base;   /* empty the buffer */
    stream->_cnt = 0;
    return 0;
}
