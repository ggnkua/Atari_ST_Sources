/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

#ifdef NO_JSTDOUT
extern void	scr_putchar proto((char c));	/* defined in win32.c */
# ifdef IBMPCDOS
#  define flushscreen()	{ }
# else /* !IBMPCDOS */
extern void flushscreen proto((void));
# endif /* !IBMPCDOS */
#else /* !NO_JSTDOUT */
extern File	*jstdout;
# define scr_putchar(c)	f_putc((c), jstdout)
extern void		flushscreen proto((void));
# ifndef SMALL
#  define MAXTTYBUF	2048
# else
#  define MAXTTYBUF	512
# endif
#endif /* !NO_JSTDOUT */


#define f_putc(c, fp)	{ while (--(fp)->f_cnt < 0) flushout(fp); *(fp)->f_ptr++ = (c); }
#define f_getc(fp)	\
	((--(fp)->f_cnt < 0) ? f_filbuf(fp) : ZXRC(*(fp)->f_ptr++))
#define f_eof(fp)	(((fp)->f_flags & F_EOF) != 0)

/* typedef struct FileStruct File in jove.h */

struct FileStruct {
	int	f_cnt,		/* number of characters left in buffer */
		f_bufsize,	/* size of what f_base points to */
		f_fd,		/* fildes */
		f_flags;	/* various flags */
	char	*f_ptr,		/* current offset */
		*f_base;	/* pointer to base */
	char	*f_name;	/* name of open file */
};

#define F_READ		01
#define F_WRITE		02
#define F_APPEND	04
#define F_MODE(x)	((x)&07)
#define F_EOF		010
#define F_STRING	020
#define F_ERR		040
#define F_LOCKED	0100	/* don't close this file upon error */
#define F_MYBUF		0200	/* f_alloc allocated the buffer, so
				   f_close knows to free it up */
#define F_TELLALL	0400	/* whether to display info upon close */
#define F_READONLY	01000	/* file is read only */

/* ScrBufSize is the size of the buffer for jstdout.  It is also the
 * number of characters to be output between checks for input, so
 * it is meaningful even if jstdout isn't used.  Its value is set by
 * settout based on the baud rate of output (on systems with baud rates).
 */
extern int	ScrBufSize;

extern File
	*f_open proto((char *name,int flags,char *buffer,int buf_size)),
	*fd_open proto((char *name,int flags,int fd,char *buffer,int bsize));

extern int
	f_filbuf proto((File *fp));

#ifdef PIPEPROCS
extern size_t
	f_readn proto((File *fp,char *addr,size_t n));
#endif

#if defined(ZTCDOS) || defined(__BORLANDC__)
/* POSIX <sys/types.h> defines this as some signed arithmetic type
 * suitable for holding file sizes.
 */
typedef long	off_t;
#endif

extern void
	f_close proto((File *fp)),
	f_seek proto((File *fp, off_t offset)),
	f_toNL proto((File *fp)),
	flushout proto((File *fp)),
	fputnchar proto((char *s,int n,File *fp)),
	gc_openfiles proto((void)),
	putstr proto((const char *s));

extern bool
	f_gets proto((File *fp,char *buf,size_t max));
