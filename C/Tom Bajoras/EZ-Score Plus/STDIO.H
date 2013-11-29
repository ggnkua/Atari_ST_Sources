#ifndef _BUFSIZE

#define _BUFSIZE 512
#define _NFILE 73

typedef struct _iobuf {
    char *_ptr;
    int _cnt;
    char *_base;
    int _flag;
    int _fd;
    long _mark;   /* position relative to start of file of _base */
    int _bufsize;	/* buffer size for this file */
} FILE;
extern FILE _iob[_NFILE];

#define stdin (&_iob[0])
#define stdout (&_iob[1])
#define stderr (&_iob[2])
#define STDCON -32000
#define STDAUX -32001
#define STDPRT -32002
#define STDIN STDCON
#define STDOUT STDCON
#define STDERR STDCON

#define _READ	 01
#define _WRITE	 02
#define _APPEND  04
#define _UNBUF	 010
#define _BIGBUF  020
#define _LINBUF  0400
#define _EOF	 040
#define _ERR	 0100
#define _DIRTY	 0200	/* buffer was changed */

#define NULL 0L    /* must be long since it can be passed as a parameter */
#define EOF (-1)

#define getc(p) (--(p)->_cnt >= 0 ? *(p)->_ptr++ & 0377 : _fillbuf(p))
#define getchar() getc(stdin)
#define putc(x,p) (--(p)->_cnt >= 0 ? (*(p)->_ptr++ = (x)) & 0377 : \
    _flushbuf((x),p))
#define putchar(x) putc(x,stdout)
#define feof(p) ((p)->_flag&_EOF)
#define ferror(p) ((p)->_flag&_ERR)
#define clearerr(p) ((p)->_flag &= ~(_ERR | _EOF))
#define fileno(p) ((p)->_fd)
#define abs(x) ((x)<0?-(x):(x))
#define rand() (int)(_seed = _seed * 6907 + 130253)
#define srand(x) _seed = x;

extern FILE *fopen();
extern long ftell();
extern char *gets();
extern char *fgets();
extern char *malloc(), *calloc();
extern long _seed;

typedef long jmp_buf[9];

#endif
