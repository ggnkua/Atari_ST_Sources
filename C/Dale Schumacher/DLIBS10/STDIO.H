/*
 *
 *	STDIO.H		Standard i/o include file
 *
 */

#define	_COOKIE(s)	gemdos(9,"<");gemdos(9,s);gemdos(9,">\r\n")

/*
 *	CONSTANTS:
 */

#define	dLibs		(0x1000)
#define	TRUE		(1)
#define	FALSE		(0)
#define	ERROR		(-1)
#define	NULL		((char *) 0)
#define	MAXINT		(32767)
#define	MININT		(-32768)
#define	MAXFILES	(20)
#define	BUFSIZ		(1024)
#define	PATHSIZE	(128)
#define	EOF		(-1)
#define	EOS		'\0'

/* FILE structure flags */
#define	F_READ		0x0001		/* file may be read from */
#define	F_WRITE		0x0002		/* file may be written to */
#define	F_BINARY	0x0004		/* file is in "binary" mode */
#define	F_IODIR		0x0010		/* last i/o was 0:read/1:write */
#define	F_BUFFER	0x0020		/* i/o is buffered */
#define	F_DEVICE	0x0040		/* file is a character device */
#define	F_EOF		0x0100		/* EOF has been reached */
#define	F_ERROR		0x0200		/* an error has occured */


/*
 *	TYPES:
 */

#define	VOID	void

typedef	unsigned char	BYTE;		/* 8-bit unsigned */
typedef	unsigned int	WORD;		/* 16-bit unsigned */
typedef	unsigned long	LONG;		/* 32-bit unsigned */
typedef	unsigned char	uchar;		/* 8-bit unsigned */
typedef	unsigned int	uint;		/* 16-bit unsigned */
typedef	unsigned long	ulong;		/* 32-bit unsigned */

typedef	struct {		/* FILE structure */
	int		F_h;		/* file handle */
	WORD		F_stat;		/* file status flags */
	char		*F_buf;		/* base of file buffer */
	char		*F_bp;		/* current buffer pointer */
	uint		F_bsiz;		/* buffer size */
	int		F_cnt;		/* # of bytes in buffer */
	char		F_unc1;		/* primary ungotten character */
	char		F_unc2;		/* secondary ungotten character */
} FILE;

/*
 *	Standard external definitions
 */
extern	void	_exit();
extern	long	gemdos();
extern	long	bios();
extern	long	xbios();

/*
 *	MACROS:
 */

/* standard streams */
extern	FILE	_iob[];
#define stdin	(&_iob[0])
#define stdout	(&_iob[1])
#define stderr	(&_iob[2])
#define stdprn	(&_iob[3])
#define stdaux	(&_iob[4])

#define clearerr(fp)	((fp)->F_stat &= ~F_ERROR)
#define feof(fp)	((fp)->F_stat & F_EOF)
#define ferror(fp)	((fp)->F_stat & F_ERROR)
#define fileno(fp)	((fp)->F_h)

#define	spawn(prog,cmdln)	spawne(prog,cmdln,NULL)
#define	spawnp(prog,cmdln)	spawnpe(prog,cmdln,NULL)
#define	chdir(pathname)		((int)gemdos(0x3B,pathname))
#define	mkdir(pathname)		((int)gemdos(0x39,pathname))
#define	rmdir(pathname)		((int)gemdos(0x3A,pathname))
#define	open(filename,iomode)	((int)gemdos(0x3D,filename,iomode))
#define	close(h)		((int)gemdos(0x3E,h))
#define	dup(handle)		((int)gemdos(0x45,handle))
#define	dup2(h1,h2)		((int)gemdos(0x46,h2,h1))
#define	unlink(filename)	((int)gemdos(0x41,filename))
#define	rename(oldname,newname)	((int)gemdos(0x56,0,oldname,newname))
#define	lseek(h,where,how)	gemdos(0x42,where,h,how)
#define	tell(h)			gemdos(0x42,0L,h,1)
#define	ftell(fp)		tell(fileno(fp))
#define	isatty(h)		((h)<6)
#define	read(h,data,len)	((int)gemdos(0x3F,h,((long)(len)),data))
#define	write(h,data,len)	((int)gemdos(0x40,h,((long)(len)),data))
#define	lread(h,data,len)	(gemdos(0x3F,h,len,data))
#define	lwrite(h,data,len)	(gemdos(0x40,h,len,data))
#define	srand(seed)		/* no random seeding required */
#define	sync()			/* sync() not possible */

#define	getc			fgetc
#define	ungetc			fungetc
#define	putc			fputc
#define	getchar()		fgetc(stdin)
#define	ungetchar(c)		fungetc((c),stdin)
#define	putchar(c)		fputc((c),stdout)

#define	abs(x)		((x)<0?(-(x)):(x))
#define max(x,y)   	(((x)>(y))?(x):(y))
#define	min(x,y)   	(((x)<(y))?(x):(y))
#define	swap(a,b)	((a)=(a)^((b)=(b)^((a)=(a)^(b))))
