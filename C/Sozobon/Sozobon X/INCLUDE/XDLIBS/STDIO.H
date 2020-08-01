/*
 * @(#)stdio.h, xdLibs, SozobonX
 *
 *	 	Standard i/o include file
 *
 * some int returning functions are not declarated here, but this will
 * be changed soon. -jerry-
 * last change:
 *  -VS: 1995/08/18
 */

#ifndef _STDIO_H
#define _STDIO_H

#ifndef _STDLIB_H
#include <stdlib.h>
#endif /* _STDLIB_H */

#ifndef _STDARG_H
# include <stdarg.h>
#endif /* _STDARG_H */

/*
 *	CONSTANTS:
 */
#define _NFILE		(32)		/* maximum number of open streams */
#define FOPEN_MAX	_NFILE		/* ANSI equivalent (replaces _NFILE) */
#define FILENAME_MAX	(128)		/* maximum filename size */
#define BUFSIZ		(1024)		/* default buffer size */
#define EOF 	(-1)			/* end-of-file indicator */
#define EOS 	'\0'			/* end-of-string indicator */

#ifndef FALSE
#pragma echo  "you shouldn't manipulate standard header files"
#define FALSE		(0) 		/* boolean false */
#define TRUE		(1)		/* boolean true */
#endif

#ifndef ERROR
#define ERROR		(-1)		/* general error condition */
#endif

/* lseek() origins */
#define SEEK_SET	0		/* from beginning of file */
#define SEEK_CUR	1		/* from current location */
#define SEEK_END	2		/* from end of file */

/* cfg_ch() control flags */
#define _CIOB		0x01		/* use bios rather than gemdos */
#define _CIOCH		0x02		/* return only 8-bit values */
#define _CIOVT		0x04		/* process vt52 escape codes */

/* FILE structure flags */
#define _IOREAD 	0x0001		/* file may be read from */
#define _IOWRT		0x0002		/* file may be written to */
#define _IOBIN		0x0004		/* file is in "binary" mode */
#define _IODEV		0x0008		/* file is a character device */
#define _IOR		0x0020		/* last i/o was read */
#define _IOW		0x0040		/* last i/o was write */
#define	_IORW		0x0080		/* file is open for update (r+w) */
#define _IOFBF		0x0100		/* i/o is fully buffered */
#define _IOLBF		0x0200		/* i/o is line buffered */
#define _IONBF		0x0400		/* i/o is not buffered */
#define _IOMYBF		0x0800		/* standard buffer */
#define _IOEOF		0x1000		/* EOF has been reached */
#define _IOERR		0x4000		/* an error has occured */

typedef struct				/* FILE structure */
	{
	int 		_cnt;		/* # of bytes in buffer */
	unsigned char	*_ptr;		/* current buffer pointer */
	unsigned char	*_base; 	/* base of file buffer */
	unsigned int	_flag;		/* file status flags */
	int 		_file;		/* file handle */
	int 		_bsiz;		/* buffer size */
	unsigned char	_ch;		/* tiny buffer, for "unbuffered" i/o */
	}
	FILE;

#define L_tmpnam	128
#define TMP_MAX 	1000

extern	void	_exit();

extern	FILE	_iob[];
extern	char *	tmpnam	(char *);

extern	FILE *	fopen	(const char *filename, const char *mode);
extern	FILE *	freopen	(const char *filename, const char *mode, FILE *stream);

extern	int	remove(char *name);
extern	int	rename(char *name, char* newname);

extern	int	fclose(FILE *stream);
extern	int	fflush(FILE *stream);

extern	void	setbuf(FILE *fp, void *buf);
extern	int	setvbuf(FILE *fp, void *bp, int bmode, size_t size);

extern	size_t	fread(void *ptr, size_t size, size_t nmemb, FILE *stream);
extern	size_t	fwrite(const void *ptr, size_t size, size_t nmemb, FILE *stream);

extern	FILE *	fdopen(int h, char *mode);
extern  FILE *	fopenp(char *filename, char *mode, char *path);
extern	int	fgetpos(FILE *stream, fpos_t *pos);
extern	int	fseek(FILE *stream, long int offset, int whence);
extern	int	fsetpos(FILE *stream, const fpos_t *pos);
extern	long	ftell(FILE *fp), fsize();
extern	void	rewind(FILE *fp);

#ifdef __SRC__
extern	int	fscanf  (FILE *fp, const char *fmt, char *s);
extern	int	scanf   (const char *fmt, char *s);
extern	int	sscanf  (char *buf, const char *fmt, int);
#else /* not __SRC__ */
extern	int	fscanf  (FILE *fp, const char *, ...);
extern	int	scanf   (const char *fmt, ...);
extern	int 	sscanf  (char *buf, const char *fmt, ...);
#endif /* not __SRC__ */

extern	int	fprintf	(FILE *fp, const char *, ...);
extern	int	printf	(const char *, ...);
extern	int	sprintf	(char *, const char *, ...);

extern	int 	vfprintf (FILE *, const char *, va_list);
extern	int 	vprintf	 (const char *, va_list);
extern	int 	vsprintf (char *, const char *, va_list);
#ifndef _POSIX_SOURCE
extern	int	vscanf  (const char *, va_list);
extern	int	vfscanf (FILE *, const char *, va_list);
extern	int	vsscanf	(const char *, const char *, va_list);
#endif /* _POSIX_SOURCE */

extern	int	fgetc	(FILE *stream);
extern	int	fungetc	(char c, FILE *stream);
extern	char	*fgets	(char *str, int cnt, FILE *stream);
extern	char	*gets	(char *str);
extern	int	fputc	(int c, FILE *stream);
extern	int	fputs	(const char *, FILE *stream);
extern	int	puts	(const char *str);

/* standard streams */
#define stdin	(&_iob[0])
#define stdout	(&_iob[1])
#define stderr	(&_iob[2])
#define stdprn	(&_iob[3])
#define stdaux	(&_iob[4])

/* error handling	*/
	/* as stream macros */
#define clearerr(fp)	((void) ((fp)->_flag &= ~(_IOERR|_IOEOF)))
#define feof(fp)		((fp)->_flag & _IOEOF)
#define ferror(fp)		((fp)->_flag & _IOERR)
#define fpending(fp)	((fp)->_cnt)

extern void perror (const char *msg);
extern void perrorf (const char *msg);	/* extended perror func	*/

/* aliases */
#define getc			fgetc
#define ungetc			fungetc
#define putc			fputc
#define getchar()		fgetc(stdin)
#define ungetchar(c)		fungetc((c),stdin)
#define putchar(c)		fputc((c),stdout)


	/* here follow some non standard extensions	*/

extern	short	getw(FILE *fp);
extern	long	getl(FILE *fp);
extern	short	putw(short arg, FILE *fp);
extern	long	putl(long arg, FILE *fp);

#define fexists 		exists
#define exists(f)		!access(f,0x00)

/* a macro for mixing streams and low level I/O,
 * using it may cause some problems !!
 */
#define fileno(fp)	((fp)->_file)

	/* functions similiar to fgetc(), fputc() for std types	*/
extern	short	fgetw(FILE *fp);
extern	long	fgetl(FILE *fp);
extern	float	fgetf(FILE *fp);
extern	double	fgetd(FILE *fp);
extern	short	fputw(short n, FILE *fp);
extern	long	fputl(long n, FILE *fp);
extern	float	fputf(float n, FILE *fp);
extern	double	fputd(double n, FILE *fp);

#endif 	/* _STDIO_H	*/
