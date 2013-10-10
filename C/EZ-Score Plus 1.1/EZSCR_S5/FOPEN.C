#include <stdio.h>
#include <fcntl.h>

static FILE *_reopen = NULL;	/* stream to be reopened */
extern long lseek();
extern int _bufsize;	/* default buffer size */

FILE *fopen(name, mode)
char *name;
register char *mode;
{
    register int fd;
    register FILE *fp;
    int rmode;
    int binary = 0;    /* binary mode */

    if (*mode == 'b') {
	binary = O_BINARY; mode++;
    }
    if (*mode != 'r' && *mode != 'w' && *mode != 'a')
	return NULL;
    if ((fp = _reopen) == NULL)
	for (fp = _iob; fp<_iob+_NFILE; fp++)
	    if (!(fp->_flag & (_READ | _WRITE)))
		break;
    if (fp >= _iob+_NFILE)
	return NULL;
    _reopen = NULL;

    fp->_flag = 0;
    rmode = O_RDONLY;
    if (mode[1] == '+') {
	rmode = O_RDWR;
	fp->_flag |= (_WRITE | _READ);
    }
    if (*mode == 'w') {
	fd = creat(name, binary);
	fp->_flag |= _WRITE;
    }
    else if (*mode == 'a') {
	if ((fd = open(name, O_RDWR | binary)) == -1)
	    fd = creat(name, binary);
	lseek(fd, 0L, 2);    /* go to end of file */
	fp->_flag |= (_APPEND | _WRITE);
    }
    else {
	fd = open(name, rmode | binary);
	fp->_flag |= _READ;
    }

    if (fd == -1) {
	fp->_flag = 0;
	return NULL;
    }
    fp->_fd = fd;
    fp->_cnt = 0;
    fp->_base = fp->_ptr = NULL;
     
    fp->_mark = lseek(fp->_fd, 0L, 1);
    fp->_bufsize = _bufsize;
    return fp;
}

FILE *freopen(name, mode, stream)
char *name;
char *mode;
FILE *stream;
{
    _reopen = stream;
    fclose(stream);
    return fopen(name, mode);
}
