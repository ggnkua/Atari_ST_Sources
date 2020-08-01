/*
 * stdio.h -- standard I/O library for Atari ST.
 *
 * Copyright (c) 1986-1987, Mark Williams Company, Chicago
 * This file and its contents may not be copied or distributed
 * without permission.
 */
#ifndef	STDIO_H
#define	STDIO_H	STDIO_H
typedef struct	FILE {
	unsigned char	*_cp,		/* Current character pointer */
			*_dp,		/* pointer to start of data in buffer */
			*_bp;		/* Buffer pointer */
	int	_cc;			/* Character count */
	int	(*_gt)(),		/* getc() function */
		(*_pt)();		/* putc() function */
	char	_ff;			/* Flags; see below */
	char	_fd;			/* File descriptor (reqd by reopen) */
	int	_uc;			/* unget char */
}	FILE;

#define	NULL	((char *)0)
#define	EOF	(-1)
#define CTRLZ	26
#define	BUFSIZ	(1<<9)
#define	_NFILE	20

extern	FILE	_stdin, _stdout, _stderr, *_fp[_NFILE];

/* Flags in _ff */
#define	_FINUSE	0x01
#define	_FSTBUF	0x02		/* setbuf was called */
#define	_FUNGOT	0x04		/* Ungotten char present */
#define	_FEOF	0x08
#define	_FERR	0x10
#define _FASCII	0x20		/* ASCII mode (default) */
#define _FWRITE 0		/* File is opened for writing, not used */
#define _FDONTC	0		/* Don't close, not used */

#define	_ep(fp)		((fp)->_bp+BUFSIZ)

char	*gets();
char	*fgets();
FILE	*fopen();
FILE	*freopen();
FILE	*fdopen();
FILE	*_stropen();
char	*malloc();
char	*sbrk();
long	ftell();
void	puts();
void	fputs();
void	setbuf();
long	bdos();

#define	getchar()	getc(stdin)
#define	putchar(c)	putc(c, stdout)
#define getc(fp)	((*(fp)->_gt)((fp)))
#define putc(c,fp)	((*(fp)->_pt)(c,(fp)))
#define	bingetc(fp)	(++(fp)->_cc>0 ? --(fp)->_cc,(*(fp)->_gt)(fp) :\
				*(fp)->_cp++)
#define	binputc(c,fp)	(--(fp)->_cc<0 ? ++(fp)->_cc,(*(fp)->_pt)(c,fp) :\
				(*(fp)->_cp++=c))
#define	bingetw(fp)	((fp)->_cc>-2 ? fgetw(fp) :	((fp)->_cc+=2\
							,(fp)->_cp+=2\
							,(fp)->_cp[-2]<<8\
							|(fp)->_cp[-1]))
#define	binputw(w,fp)	((fp)->_cc<2 ? fputw(w,fp) :	((fp)->_cc-=2\
							,*(fp)->_cp++=w>>8\
							,*(fp)->_cp++=w\
							,w))
#define	feof(fp)	((fp)->_ff&(_FEOF|_FERR))
#define	ferror(fp)	((fp)->_ff&_FERR)
#define	clearerr(fp)	((fp)->_ff &= ~(_FERR|_FEOF))
#define	fileno(fp)	((fp)->_fd)
#define	wdleng()	(16)

#define	stdin	(&_stdin)
#define	stdout	(&_stdout)
#define	stderr	(&_stderr)

/*
 * Temporary file directory manifests for System V compatibility
 */
#define P_tmpdir	"\\tmp"		/* Default temporary directory */
#define L_tempnam	64		/* Maximum length of temp file name */

#endif
/* End of stdio.h */
