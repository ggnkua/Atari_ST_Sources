/* The <stdio.h> header is used by the I/O routines. */

#ifndef _STDIO_H
#define _STDIO_H

#ifdef NULL
#undef NULL
#endif

#define BUFSIZ  1024
#define NFILES  20
#define NULL       0
#define EOF     (-1)
#define CMASK   0377

#define READMODE     1
#define WRITEMODE    2
#define UNBUFF       4
#define _EOF         8
#define _ERR        16
#define IOMYBUF     32
#define PERPRINTF   64
#define STRINGS    128

#ifndef FILE

extern struct _io_buf {
    int     _fd;
    int     _count;
    int     _flags;
    char   *_buf;
    char   *_ptr;
}  *_io_table[NFILES];


#endif	/* FILE */

#define FILE struct _io_buf


#define stdin  (_io_table[0])	
#define stdout 	(_io_table[1])
#define stderr 	(_io_table[2])

/* -------------- Prototypes copied from Earl Chew's stdio -----------------*/

#include <ansi.h>

#if _ANSI
#  define __STDIO_P__(__x) __x
#  define __STDIO_VA__ ,...
#else
#  define __STDIO_P__(__x) ()
#  define __STDIO_VA__
#endif

#ifndef _SIZE_T
#define _SIZE_T
typedef unsigned size_t;
#endif

#define __fpos_t long
#define __STDIO_VA_LIST__	void *

/* ANSI Stdio Requirements */

int	getc		__STDIO_P__((FILE *));
int	getchar		__STDIO_P__((void));
int	putc		__STDIO_P__((int, FILE *));
int	putchar		__STDIO_P__((int));
int	feof		__STDIO_P__((FILE *));
int	ferror		__STDIO_P__((FILE *));
void	clearerr	__STDIO_P__((FILE *));

FILE 	*fopen		__STDIO_P__((const char *, const char *));
FILE	*freopen	__STDIO_P__((const char *, const char *, FILE *));
int	fflush		__STDIO_P__((FILE *));
int	fclose		__STDIO_P__((FILE *));

int	fgetpos		__STDIO_P__((FILE *, __fpos_t *));
int	fsetpos		__STDIO_P__((FILE *, __fpos_t *));
long	ftell		__STDIO_P__((FILE *));
int	fseek		__STDIO_P__((FILE *, long, int));
void	rewind		__STDIO_P__((FILE *));

int	fgetc		__STDIO_P__((FILE *));
int	fputc		__STDIO_P__((int, FILE *));
size_t	fread		__STDIO_P__((void *, size_t, size_t, FILE *));
size_t	fwrite		__STDIO_P__((const void *, size_t, size_t, FILE *));

int	getw		__STDIO_P__((FILE *));
int	putw		__STDIO_P__((int, FILE *));
char	*gets		__STDIO_P__((char *));
char	*fgets		__STDIO_P__((char *, int, FILE *));
int	puts		__STDIO_P__((const char *));
int	fputs		__STDIO_P__((const char *, FILE *));

int	ungetc		__STDIO_P__((int, FILE *));

/* WRONG */
void	printf		__STDIO_P__((const char * __STDIO_VA__));
/* WRONG */
void	fprintf		__STDIO_P__((FILE *, const char * __STDIO_VA__));
/* WRONG */
char	*sprintf	__STDIO_P__((char *, const char * __STDIO_VA__));
int	vprintf		__STDIO_P__((const char *, __STDIO_VA_LIST__));
int	vfprintf	__STDIO_P__((FILE *, const char *, __STDIO_VA_LIST__));
/* WRONG */
char 	*vsprintf	__STDIO_P__((char *, const char *, __STDIO_VA_LIST__));
int	scanf		__STDIO_P__((char *nonconstfmt __STDIO_VA__));
int	fscanf		__STDIO_P__((FILE *, char *nonconstfmt __STDIO_VA__));
int	sscanf		__STDIO_P__((char *nonconststr, char *nonconstfmt __STDIO_VA__));

void	setbuf		__STDIO_P__((FILE *, char *));
int	setvbuf		__STDIO_P__((FILE *, char *, int, size_t));

int	rename		__STDIO_P__((const char *, const char *));
int	remove		__STDIO_P__((const char *));

void	perror		__STDIO_P__((const char *));

char *	tmpnam		__STDIO_P__((char *));
FILE *	tmpfile		__STDIO_P__((void));

/* Posix Definitions */
int	unlink		__STDIO_P__((const char *));

char *	ctermid		__STDIO_P__((char *s));

char *	cuserid		__STDIO_P__((char *s));

FILE	*fdopen		__STDIO_P__((int, const char *));

int	fileno		__STDIO_P__((FILE *));

/* Local Definitions */
extern _PROTOTYPE( void (*__cleanup), (void)				);
_PROTOTYPE( void _doprintf, (FILE *iop, const char *fmt,
			     __STDIO_VA_LIST__)				);
_PROTOTYPE( int _doscanf, (int code, char *funcarg, char *nonconstfmt,
			     __STDIO_VA_LIST__)				);
_PROTOTYPE( void prints, (const char *fmt __STDIO_VA__)			);

/* ---------------------- End of Earl's prototypes --------------------------*/

#define getchar() 		getc(stdin)
#define putchar(c) 		putc(c,stdout)
#define getc(f)			fgetc(f)
#define putc(c,f)		fputc(c,f)
#define feof(p) 		(((p)->_flags & _EOF) != 0)
#define ferror(p) 		(((p)->_flags & _ERR) != 0)
#define clearerr(p) 		((p)->_flags &= ~(_ERR))
#define fileno(p) 		((p)->_fd)
#define rewind(f)		fseek(f, 0L, 0)
#define testflag(p,x)		((p)->_flags & (x))

/* If you want a stream to be flushed after each printf use:
 * 
 *	perprintf(stream);
 *
 * If you want to stop with this kind of buffering use:
 *
 *	noperprintf(stream);
 */

#define noperprintf(p)		((p)->_flags &= ~PERPRINTF)
#define perprintf(p)		((p)->_flags |= PERPRINTF)

extern FILE	*fopen();
extern FILE	*freopen();
extern long	ftell();
extern char	*fgets();
extern char	*gets();

#endif /* _STDIO_H */
