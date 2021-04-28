#pragma idempotent

/*
 *
 *	STDIO.H 	Standard i/o include file
 *
 */

#ifndef STDIO_H
#define STDIO_H

#include <stddef.h>
#include <types.h>

#define _COOKIE(s)	gemdos(9,"<");gemdos(9,s);gemdos(9,">\r\n")

/*
 *	CONSTANTS:
 */

#define _NFILE		(20)		/* maximum number of open streams */
#define OPEN_MAX	_NFILE		/* ANSI equivalent (replaces _NFILE) */
#define FILENAME_MAX	(128)		/* maximum filename size */
#define BUFSIZ		(1024)		/* default buffer size */
#define EOF		(-1)		/* end-of-file indicator */
#define EOS		'\0'		/* end-of-string indicator */

#define EXIT_FAILURE	(-1)		/* failure return value for exit() */
#define EXIT_SUCCESS	(0)		/* success return value for exit() */

#define RAND_MAX	(0x7FFF)	/* maximum value from rand() */

#ifndef FALSE
  #define FALSE 	(0)		/* boolean false */
  #define TRUE		(!FALSE)	/* boolean true */
#endif

#ifndef ERROR
  #define ERROR 	(-1)		/* general error condition */
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
#define _IORW		0x0080		/* last i/o was 0:read/1:write */
#define _IOFBF		0x0100		/* i/o is fully buffered */
#define _IOLBF		0x0100		/* i/o is line buffered */
#define _IONBF		0x0400		/* i/o is not buffered */
#define _IOMYBUF	0x0800		/* standard buffer */
#define _IOEOF		0x1000		/* EOF has been reached */
#define _IOERR		0x4000		/* an error has occured */

typedef struct			/* FILE structure */
	{
	int		_cnt;		/* # of bytes in buffer */
	unsigned char	*_ptr;		/* current buffer pointer */
	unsigned char	*_base; 	/* base of file buffer */
	unsigned int	_flag;		/* file status flags */
	int		_file;		/* file handle */
	int		_bsiz;		/* buffer size */
	unsigned char	_ch;		/* tiny buffer, for "unbuffered" i/o */
	}
	FILE;

#define L_tmpnam	128
#define TMP_MAX 	1000

extern	char	*etext;
extern	char	*edata;
extern	char	*end;

extern	void	_exit();
extern	long	gemdos();
extern	long	bios();
extern	long	xbios();
extern	int	bdos();

extern	FILE	_iob[];
extern	FILE	*fopen(), *fdopen(), *freopen(), *fopenp();
extern	long	ftell(), fsize();
extern	void	rewind(), setbuf(), setvbuf();
extern	char	*fgets(), *gets(), *tmpnam(), *tempnam();
extern	char	*fullpath(), *findfile(), *pfindfile(), *wildcard();

/* standard streams */
#define stdin	(&_iob[0])
#define stdout	(&_iob[1])
#define stderr	(&_iob[2])
#define stdprn	(&_iob[3])
#define stdaux	(&_iob[4])

/* stream macros */
#define clearerr(fp)	((void) ((fp)->_flag &= ~(_IOERR|_IOEOF)))
#define feof(fp)	((fp)->_flag & _IOEOF)
#define ferror(fp)	((fp)->_flag & _IOERR)
#define fileno(fp)	((fp)->_file)

/* compatibility macros */
#define srand(seed)		/* no random seeding required */
#define sync()			/* sync() not possible, no operation */

/* aliases */
#define getc			fgetc
#define ungetc			fungetc
#define putc			fputc
#define getchar()		fgetc(stdin)
#define ungetchar(c)		fungetc((c),stdin)
#define putchar(c)		fputc((c),stdout)
#define fexists 		exists
#define exists(f)		access(f,0x00)
#define unlink			remove
#define forkv(prog,args)	forkve(prog,args,NULL)
#define forkvp(prog,args)	forkvpe(prog,args,NULL)

#endif STDIO_H
