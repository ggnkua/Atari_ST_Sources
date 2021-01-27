/* This file is part of the AHCC C Library.

   The AHCC C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public License as
   published by the Free Software Foundation; either version 2 of the
   License, or (at your option) any later version.

   The AHCC C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Library General Public
   License along with the GNU C Library; see the file COPYING.LIB.  If not,
   write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
   Boston, MA 02111-1307, USA.
*/

/* stdio.c */
/* from Dale Schumacher's dLibs library */
/* Adapted to ANSI and AHCC by H. Robbers */

#include <prelude.h>
#include <limits.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ext.h>
#include <tos.h>

short access(const char *name, short amode);

#define	_NFILE		OPEN_MAX		/* maximum number of open streams */

#define	LAST_DEVICE	(-3)		/* lowest character device handle # */
#include <ctype.h>

/* FILE structure flags */
#define	_IOREAD		0x01		/* file may be read from */
#define	_IOWRT		0x02		/* file may be written to */
#define	_IOBIN		0x04		/* file is in "binary" mode */
#define	_IODEV		0x08		/* file is a character device */
#define	_IORW		0x10		/* last i/o was 0:read/1:write */
#define	_IOEOF		0x20		/* EOF has been reached */
#define	_IOERR		0x40		/* an error has occured */

#define	_IOMYBUF	0x40		/* standard buffer (additive mode) */

typedef void VpV(void);

VpV Init_iob, Exit_iob;

FILE _StdInF  = {nil, 0, nil, nil, 0, _IOREAD | _IODEV,          _IOFBF, '\0', 0},
     _StdOutF = {nil, 0, nil, nil, 1, _IOWRT  | _IODEV,          _IONBF, '\0', 0},
     _StdErrF = {nil, 0, nil, nil,-1, _IOWRT  | _IODEV,          _IONBF, '\0', 0},
     _StdPrnF = {nil, 0, nil, nil, 2, _IOWRT  | _IODEV,          _IONBF, '\0', 0},
     _StdAuxF = {nil, 0, nil, nil, 3, _IOREAD | _IOWRT | _IODEV, _IONBF, '\0', 0};

FILE	_iob[FOPEN_MAX] = { 0 };
VpV *init_streams = Init_iob;
VpV *end_streams  = Exit_iob;


static
FILE *five[] = {&_StdInF, &_StdOutF, &_StdErrF, &_StdPrnF, &_StdAuxF};

static void i_f(short i, FILE *f)
{
	if (isatty(f->Handle))
		f->Flags |= _IODEV;
	_iob[i] = *f;
}

void Init_iob(void)
{
	i_f(0, &_StdInF);
	i_f(1, &_StdOutF);
	i_f(2, &_StdErrF);
	i_f(3, &_StdPrnF);
	i_f(4, &_StdAuxF);
}

static void c_f(FILE *p)
{
	short f = p->Flags;
	/*	if ((f & (_IOREAD | _IOWRT)) && !(f & _IODEV))	*/
		if (f & (_IOREAD | _IOWRT))
			fclose(p);
}

void Exit_iob(void)
{
	short i;

	c_f(&_StdInF);
	c_f(&_StdOutF);
	c_f(&_StdErrF);
	c_f(&_StdPrnF);
	c_f(&_StdAuxF);
	for (i=5; i < _NFILE; ++i)
		c_f(&_iob[i]);
}

/*
 *	INTERNAL FUNCTION.  Attempt to open <filename> in the given
 *	<mode> and attach it to the stream <fp>
 */
static
FILE * __fopen(const char *filename, const char *mode, FILE *fp)
{
	short h, i, iomode = 0, f = 0, b = 0;

	while(*mode)
	{
		switch(*mode++)
		{
			case 'r':
				f |= _IOREAD;
			break;
			case 'w':
				f |= _IOWRT;
				iomode |= (O_CREAT | O_TRUNC);
			break;
			case 'a':
				f |= _IOWRT;
				iomode |= (O_CREAT | O_APPEND);
			break;
			case '+':
				f |= (_IOREAD | _IOWRT);
			break;
			case 'b':
				f |= _IOBIN;
			break;
			case 't':
				f &= ~_IOBIN;
			break;
			default:
				fputs("Illegal file mode.\n", stderr);
				return nil;
		}
	}

	i = (f & (_IOREAD | _IOWRT));
	if (i == 0)
		return nil;

	if (i == _IOREAD)
		iomode |= O_RDONLY;
	elif (i == _IOWRT)
		iomode |= O_WRONLY;
	else
		iomode |= O_RDWR;

	h = open(filename, iomode, 0x00);

	if (h < 0)
		return nil;		/* file open/create error */

	if(isatty(h))
		f |= _IODEV,
		b  = _IONBF;
	else
		b  = _IOFBF;
	fp->Handle = h;			/* file handle */
	fp->Flags = f;			/* file status flags */
	fp->Mode  = b;
	fp->BufStart = nil;		/* base of file buffer */
	fp->BufPtr  = nil;		/* current buffer pointer */
	fp->_bsiz = 0;			/* buffer size */
	fp->_cnt = 0;			/* # of bytes in buffer */
	return fp;
}

FILE *fdopen(short h, const char *mode)
{
	short i, iomode = 0, f = 0, b = 0;
	FILE *fp = nil;

	for (i=0; !fp and i < _NFILE; ++i)
		if (!(_iob[i].Flags & (_IOREAD | _IOWRT)))   /* empty slot? */
			fp = &_iob[i];

	if (!fp)
		return(nil);

	while(*mode)
	{
		switch(*mode++)
		{
			case 'r':
				f |= _IOREAD;
			break;
			case 'w':
				f |= _IOWRT;
				iomode |= (O_CREAT | O_TRUNC);
			break;
			case 'a':
				f |= _IOWRT;
				iomode |= (O_CREAT | O_APPEND);
			break;
			case '+':
				f |= (_IOREAD | _IOWRT);
			break;
			case 'b':
				f |= _IOBIN;
			break;
			case 't':
				f &= ~_IOBIN;
			break;
			default:
				fputs("Illegal file mode.\n", stderr);
				return nil;
			}
	}

	if ((i = (f & (_IOREAD | _IOWRT))) == 0)
		return nil;

	if (i == _IOREAD)
		iomode |= O_RDONLY;
	elif(i == _IOWRT)
		iomode |= O_WRONLY;
	else
		iomode |= O_RDWR;

	if (isatty(h))
		f |= _IODEV,
		b  = _IONBF;
	else
		b  = _IOFBF;

	fp->Handle = h;			/* file handle */
	fp->Flags = f;			/* file status flags */
	fp->Mode  = b;
	fp->BufStart = nil;		/* base of file buffer */
	fp->BufPtr  = nil;		/* current buffer pointer */
	fp->_bsiz = 0;			/* buffer size */
	fp->_cnt  = 0;			/* # of bytes in buffer */

	return fp;
}

FILE *fopen(const char *filename, const char *mode)
{
	short i;
	FILE *fp = nil;

	for (i=0; !fp && i < _NFILE; ++i)
		if (!(_iob[i].Flags & (_IOREAD | _IOWRT)))   /* empty slot? */
			fp = &_iob[i];

	return fp ? __fopen(filename, mode, fp) : nil;
}

FILE *freopen(const char *filename, const char *mode, FILE *fp)
{
	return fclose(fp) ? nil : __fopen(filename, mode, fp);
}

FILE *fopenp(const char *filename, const char *mode)
{
	FILE *fp = nil;
	char fn[FILENAME_MAX];

	strcpy(fn, filename);

	if (strchr(fn, '.') == nil)
		strcat(fn, ".");

	if ((filename = pfindfile(nil, fn, "\0")) ne 0)
		fp = fopen(filename, mode);

	return fp;
}

size_t lseek(short h, size_t where, short how)
{
	size_t rv;

	rv = Fseek(where, h, how);

	if (rv < 0)
		errno = rv;

	return rv;
}

size_t tell(short h)
{
	return lseek(h, 0L, SEEK_CUR);
}

static short _fflush(FILE *fp)
{
	short f, rv = 0;
	long offset;

 	if (fp == nil)
		return 0;

	f = fp->Flags;

	if (    (f &  _IODEV) ne 0				/* file is a device */
	    || !(f & (_IOREAD | _IOWRT))		/* file not open! */
	   )
		return 0;

	if (fp->_cnt)							/* data in the buffer */
		if (f & _IORW)						/* writing */
		{
			if (write(fp->Handle, fp->BufStart, fp->_cnt) != fp->_cnt)
				fp->Flags |= _IOERR, rv = EOF;
		othw								/* reading */
			offset = -(fp->_cnt);

			if (lseek(fp->Handle, offset, 1) < 0)
				rv = EOF;
		}

	fp->BufPtr = fp->BufStart;
	fp->_cnt = 0;

	return rv;
}

short fflush(FILE *fp)
/*
 *	implementation note:  This function has the side effect of
 *	re-aligning the virtual file pointer (in the buffer) with
 *	the actual file pointer (in the file) and is therefore used
 *	in other functions to accomplish this re-sync operation.
 */
{
	short f, i;

 	if(fp)
		return(_fflush(fp));
	else
	{
		for(i=0; i<_NFILE; ++i)
		{
			f = _iob[i].Flags;
			if(f & (_IOREAD | _IOWRT))
				_fflush(&_iob[i]);
		}

		return(0);
	}
}

short fclose(FILE *fp)
{
	short f;

	if (fp == nil) return EOF;		/* nil file pointer file */

	f = fp->Flags;

	if ((f & (_IOREAD | _IOWRT)) == 0)
		return EOF;					/* file not open! */

	fflush(fp);

	if (fp->Mode & _IOMYBUF)	/* HR: free the buffer */
		free(fp->BufStart);

/*	if (fp->_bsiz != BUFSIZ)		/* throw away non-standard buffer HR: always */
*/	{
		fp->BufStart = nil;
		fp->BufPtr  = nil;
		fp->_bsiz = 0;
	}

	fp->Flags = 0;					/* clear status */

	if (f & _IODEV) return 0;		/* leave tty's alone */

	f = close(fp->Handle);

	return f ? EOF : 0;
}

static
void __getbuf(FILE *fp)						/* allocate a buffer for a stream */
{
	if (   fp->Mode == _IONBF
	    || (fp->BufStart = malloc(fp->_bsiz = BUFSIZ)) eq nil
	   )
	{
		fp->Mode = _IONBF;
		fp->BufStart  = &fp->ChrBuf;			/* use tiny buffer */
		fp->_bsiz  = 1;
	}
	else
	{
		fp->Mode = _IOMYBUF;			/* use big buffer */
		fp->_bsiz = BUFSIZ;
	}

	fp->BufPtr = fp->BufStart;
	fp->_cnt = 0;					/* start out with an empty buffer */
}

/*
 *	teeny-tiny tty driver
 */

#define	EXIT_BREAK	ENOSYS		/* ^C exit value */
#define	cecho(c)	Bconout(2,(c))	/* echo character to console */

short _tttty(FILE *fp)
{
	unsigned char *bp = fp->BufStart;
	char c;
	short f, b, n = 0, m = 0;

	f = fp->Flags;
	b = fp->Mode;
#ifdef DLEBUG
fprintf(stderr, "[_tttty: entry, mode=%s, %s]\n",
	(f & _IOBIN)  ? "binary"     : "normal",
	(b == _IONBF) ? "unbuffered" : "buffered"
	);
#endif

	do
	{
		m = read(fp->Handle, &c, 1);

		if (m <= 0)						/* file read error or EOF */
			return n ? n : m;

		if   (f & _IOBIN)
			++n, *bp++ = c;
		elif (b == _IONBF)
		{
			++n;

			if ((*bp++ = c) == '\003')	/* ^C (BREAK) */
				exit(EXIT_BREAK);
		othw
			switch(c)
			{
				case '\b':				/* BS */
				case '\177':			/* DEL */
					if(n > 0)
					{
						--n;
						--bp;
						if (c == '\177')
						{
							cecho('\b');
							cecho(' ');
							cecho('\b');
							cecho('\b');
						}
						cecho(' ');
						cecho('\b');
					}
				break;
				case '\004':			/* ^D (acts like ^Z) */
					c = '\032';
					/* fall-thru */
				case '\032':			/* EOF */
					cecho('\r');
					/* fall-thru */
				case '\r':	/* CR */
				case '\n':	/* LF */
					*bp = c;
					++n;
					cecho((c == '\n') ? '\r' : '\n');
#ifdef DLEBUG
fprintf(stderr, "[_tttty: eof/cr/nl exit, n=%d]\n", n);
#endif
					return n;

				case '\025':	/* ^U */
				case '\0':	/* ^@ */
					/* erase all characters in buffer */
					while(n > 0)
					{
						--n;
						--bp;
						cecho('\b');
						cecho(' ');
						cecho('\b');
					}
				break;
				case '\003':	/* ^C (BREAK) */
					exit(EXIT_BREAK);

				default:
					++n, *bp++ = c;
				break;
			}
		}

		if (n >= fp->_bsiz) break;
	}
	od

#ifdef DLEBUG
fprintf(stderr, "[_tttty: buffer full exit, n=%d]\n", n);
#endif

	return n;
}

short fgetc(FILE *fp)
{
	short c, f, m;
	bool look = false;

	f = (fp->Flags &= ~_IORW);

	if (   (f &  _IOREAD)          eq 0
	    || (f & (_IOERR | _IOEOF)) ne 0
	   )
		return EOF;

	if (fp->BufStart == nil)			/* allocate a buffer if there wasn't one */
		__getbuf(fp);

_fgetc1:
	if (--fp->_cnt < 0)
	{
		if (f & _IODEV)
			m = _tttty(fp);
		else
			m = read(fp->Handle, fp->BufStart, fp->_bsiz);

		if (m <= 0)
		{
			fp->Flags |= (m == 0 ? _IOEOF : _IOERR);
			c = EOF;
			goto _fgetc2;
		}

		fp->_cnt = m - 1;
		fp->BufPtr = fp->BufStart;
	}

	c = *fp->BufPtr++;

_fgetc2:
	if ((f & _IOBIN) eq 0)			/* TRANSLATED STREAM PROCESSING */
	{
		if (look)					/* process lookahead */
		{
			if (c != '\n')			/* if not CR+LF.. */
			{
				if (c == EOF)		/* ..undo EOF.. */
					fp->Flags &= ~(_IOERR | _IOEOF);
				else		/* ..or unget character */
					*--fp->BufPtr = c, ++fp->_cnt;

				c = '\r';			/* return CR */
			}
		}
		elif(c == '\r')				/* found CR */
		{
			if ((f & _IODEV) ne 0)	/* return it for tty */
				c = '\n';
			else					/* else lookahead for LF */
			{
				look = true;
				goto _fgetc1;
			}
		}
		elif (c == 0x00)			/* Ignore NUL's */
			goto _fgetc1;
		elif( c == 0x1A)			/* ^Z becomes EOF */
			fp->Flags |= _IOEOF, c = EOF;
	}

	return c;
}

char *fgets(char *data, short limit, FILE *fp)
{
	char *p = data;
	short c;

	while (--limit > 0 and (c = fgetc(fp)) != EOF)
		if ((*p++ = c) == '\n')
			break;

	*p = '\0';

	return (c == EOF and p == data) ? nil : data;	/* nil == EOF */
}

char *gets(char *data)
{
	char *p = data;
	short c;

	while ((c = fgetc(stdin)) != EOF and c != '\n')
		if (c == '\b')
			if (p > data)
				--p;
			else ;
		else
			*p++ = c;

	*p = '\0';

	return (c == EOF && p == data) ? nil : data;  /* nil == EOF */
}

short ungetc(short c, FILE *fp)
{
	if (  (fp->Flags & (_IOERR | _IOEOF)) ne 0	/* error or eof */
	    || fp->BufPtr <= fp->BufStart				/* or too many ungets */
	   )
		return EOF;

	++fp->_cnt;

	return *--fp->BufPtr = c;
}

short fungetc(short c, FILE *fp)		/* NOT in Pure C stdio */
{
	return ungetc(c, fp);
}

size_t fread(void *data, size_t size, size_t count, FILE *fp)
{
	size_t n, m, lsiz;
	short f, c;

	f    = fp->Flags &= ~_IORW;
	lsiz = size;
	n    = count * lsiz;

	if (f & _IODEV)							/* device i/o */
	{
		for(m = 0; m < n; ++m)
		{
			if ((c = fgetc(fp)) == EOF)
				break;
			*((char *)data)++ = c;
		}
	othw									/* file i/o */
		fflush(fp);							/* re-sync file pointers */
		m = Fread(fp->Handle, n, data);
	}

	return m > 0 ? m / lsiz : (errno = m);
}

void cputs(char *data)
{
	while (*data)
		putch(*data++);
}

short fputc(short c, FILE *fp)
{
	short f, m;
	bool nl = false;

	f = fp->Flags |= _IORW;

	if (   (f &  _IOWRT)	       eq 0		/* not opened for write? */
	    or (f & (_IOERR | _IOEOF)) ne 0)	/* error/eof conditions? */
		return EOF;

	if (fp->BufStart == nil)				/* allocate a buffer if there wasn't one */
		__getbuf(fp);

	if (    (f & _IOBIN) eq 0
	    and (c == '\n'))				/* NL -> CR+LF ? */
	{
		c = '\r';
		nl = true;
	}

_fputc:
	*fp->BufPtr++ = c;

	if (++fp->_cnt >= fp->_bsiz)
	{
		fp->_cnt = 0;
		fp->BufPtr = fp->BufStart;
		m = fp->_bsiz;

		if (write(fp->Handle, fp->BufStart, m) != m)
		{
			fp->Flags |= _IOERR;
			return EOF;
		}
	}

	if (nl and (c == '\r'))			/* NL -> CR+LF ? */
	{
		c = '\n';
		goto _fputc;
	}

	return c;
}

short fputs(const char *data, FILE *fp)
{
	short n = 0;

	while (*data)
	{
		if (fputc(*data++, fp) == EOF)
			return EOF;

		++n;
	}

	return n;
}

short puts(const char *data)
{
	short n;

	if (   (n = fputs(data, stdout)) == EOF
	    or (fputc('\n', stdout) == EOF) )
		return EOF;

	return ++n;
}

size_t fwrite(const void *data, size_t size, size_t count, FILE *fp)
{
	size_t n, m, lsiz;
	short f;

	f    = (fp->Flags |= _IORW);
	lsiz = ((long) size);
	n    = ((long) count) * lsiz;

	if(f & _IODEV)								/* device i/o */
	{
		for (m=0; m<n; ++m)
			if (fputc(*((char *)data)++, fp) == EOF)
				break;
	othw										/* file i/o */
		fflush(fp);								/* re-sync file pointers */
		m = Fwrite(fp->Handle, n, data);
	}

	return m > 0 ? m / lsiz : (errno = m);
}

short feof( FILE *fp )
{
	return fp->Flags & _IOEOF;
}

short ferror( FILE *fp )
{
	return fp->Flags & _IOERR;
}

long ftell(FILE *fp)
{
	long rv;

	fflush(fp);
	rv = Fseek(0L, fp->Handle, 1);

	return rv < 0 ? (errno = rv, -1) : rv;
}

short fseek(FILE *fp, long offset, short origin)
{
	long rv;


	fflush(fp);
	rv = Fseek(offset, fp->Handle, origin);

	return rv < 0 ? (errno = rv, -1) : 0;
}

void rewind(FILE *fp)
{
	long rv;

	fflush(fp);
	rv = Fseek(0L, fp->Handle, SEEK_SET);

	if (rv < 0)
		errno = rv;

	fp->Flags &= ~(_IOEOF|_IOERR);
}

short fgetpos(FILE *fp, fpos_t *pos)
{
	long rv;

	rv = ftell(fp);

	if (rv >= 0 and pos)
		return *pos = rv, 0;

	return ERROR;
}

short fsetpos(FILE *fp, const fpos_t *pos)
{
	long rv;

	if(pos)
	{
		rv = fseek(fp, *pos, SEEK_SET);

		if (rv >= 0)
		{
			fp->Flags &= ~(_IOEOF|_IOERR);
			return 0;
		}
	}

	return ERROR;
}

static char *__findext(const char *p, const char *q, const char *ext)
{
	if (ext == nil) ext = ".";

	while (p < q)
	{
		if (!stricmp(p, ext)) return p;

		while (*p++);
	}
	return nil;
}

char *fullpath(char *full, const char *part)
{
	static char buf[PATH_MAX];
	char *bp = buf;
	short drv;

	if (*part && (part[1] == ':'))
	{
		drv = *bp++ = *part++;
		drv = ((drv - 1) & 0xF);
		*bp++ = *part++;
	othw
		*bp++ = (drv = Dgetdrv()) + 'a';
		*bp++ = ':';
	}

	if (*part == '\\')
		++part;
	else
	{
		Dgetpath(bp, drv + 1);		/* 1 BASED drive number here */

		while(*bp++);

		--bp;
	}

	*bp++ = '\\';
	*bp = '\0';

	while(*part)					/* handle dots and copy path & file */
	{
		if (*part == '.')
		{
			if (*++part == '.')
			{
				if (*++part && *part != '\\')
					return nil;		/* illegal pathname */
				else
				{
					--bp;

					while (*--bp != '\\')
						if (*bp == ':')
						{
							++bp;
							break;
						}

					++bp;

					if (*part)
						++part;
				}
			}
			elif (*part && *part != '\\')
				return nil;			/* illegal pathname */
			else
				++part;
		}
		else
			while(*part && ((*bp++ = *part++) != '\\'));
	}

	*bp = '\0';

	if (full == nil)	/* special case to use local buffer */
		full = buf;

	return strlwr(strcpy(full, buf));	/* lowercase and return */
}

char *findfile(const char *afn, const char *ext)
{
	const char *q, *e;
	char *p;
	DTA dta, *pdta;

	afn = fullpath(nil, afn);
	if(    (p = strrchr(afn, '\\')) ne 0
	   and (p = strchr (p,   '.' )) ne 0 )		/* .EXT specified */
		return access(afn, 0x00) ? afn : nil;
	/*
	 * No extension specified, search directory for any extension
	 * and try to match with the list.
	 */
	p = strrchr(afn, '\0');
	p[0] = '.';
	p[1] = '*';
	p[2] = '\0';

	q = ext;
	while(*q)				/* q = end of exts / match */
		while(*q++) ;

	pdta = Fgetdta();
	Fsetdta(&dta);

	if (Fsfirst(afn, 0x00) == 0)
	{
		do
		{
			e = strchr(dta.d_fname, '.');
			if ((e = __findext(ext, q, e)) ne 0)
				q = e;
		} while (Fsnext() == 0);
	}

	Fsetdta(pdta);

	if (*q)
	{
		strcpy(p, q);
		return afn;
	}
	return nil;
}

char *pfindfile(const char *path, const char *afn, const char *ext)
{
	static char tmp[PATH_MAX];
	char *p;

	if (strchr(afn, '\\') || strchr(afn, ':'))	/* file has path */
		return findfile(afn, ext);

	if (     path == nil						/* if no path spec */
	    and (path = getenv("PATH")) == nil		/* get PATH from env */
	   )
		path = ".";								/* or fake it */

	while (*path)
	{
		p = tmp;

		while(    (*path != '\0')
		      and (*path != ';')
		      and (*path != ',')
		     )									/* copy directory */
			*p++ = *path++;

		if (*path) ++path;						/* move past delim */

		if (p[-1] != '\\') *p++   = '\\';		/* add \ if needed */

		strcpy(p, afn);							/* copy filename */

		if ((p = findfile(tmp, ext)) ne 0)	/* do search */
			return p;
	}
	return nil;
}

#define	SPLIT_EXT	1
#define	SPLIT_FILE	2
#define	SPLIT_PATH	3

char *_splitpath
(
	const char *src,
	char *drive,
	char *path,
	char *file,
	char *ext
)
{
	int state = SPLIT_EXT;
	char *q;
	char buf[128];

	if (drive)
		*drive = '\0';
	if (path)
		*path = '\0';
	if (file)
		*file = '\0';
	if (ext)
		*ext = '\0';
	if (src == nil)
		return nil;

	strcpy(buf, src);
	q = strrchr(buf, '\0');

	while (q-- > buf)
	{
		if(*q == '.')
		{
			if(state < SPLIT_FILE)
			{
				state = SPLIT_FILE;

				if(ext)
					strcpy(ext, q+1);

				*q = '\0';
			}
		}
		else if (*q == '\\')
		{
			if (state < SPLIT_PATH)
			{
				state = SPLIT_PATH;

				if (file)
					strcpy(file, q+1);

				if (q == buf || *(q-1) == ':')
					*(q+1) = '\0';
				else
					*q = '\0';
			}
		}
		else if (*q == ':')
			break;
	}
	if (state < SPLIT_PATH)
	{
		if (file)
			strcpy(file, q+1);
	}
	else
	{
		if (path)
			strcpy(path, q+1);
	}

	*(q+1) = '\0';

	if (drive)
		strcpy(drive, buf);

	return src;
}

char *_makepath
(
	char *dst,
	const char *drive,
	const char *path,
	const char *file,
	const char *ext
)
{
	char *p;

	if (dst)
	{
		*dst = '\0';

		if (drive && *drive)
			strcat(dst, drive);

		if (path && *path)
		{
			strcat(dst, path);
			p = strrchr(dst, '\0');
			if (*(p - 1) != '\\')
				strcat(dst, "\\");
		}

		if (file && *file)
			strcat(dst, file);

		if (ext && *ext)
		{
			strcat(dst, ".");
			strcat(dst, ext);
		}
	}

	return dst;
}

static	DTA  _wilddta;
static	char _wbuf[PATH_MAX];
static	char _wdrive[4], _wpath[PATH_MAX], _wbase[10], _wext[4];

char *wildcard(const char *pathname)
{
	DTA *olddta;
	int search;

	olddta = (DTA *) Fgetdta();
	Fsetdta(&_wilddta);

	if (pathname)				/* get first match */
	{
		_splitpath(pathname, _wdrive, _wpath, _wbase, _wext);
		search = Fsfirst(pathname, 0x07);
	}
	else					/* get next match */
		search = Fsnext();

	Fsetdta(olddta);

	if (search == 0)
	{
		_makepath(_wbuf, _wdrive, _wpath, _wilddta.d_fname, nil);
		return(_wbuf);
	}

	return nil;
}

static short _tmpcnt = 0;
static char	_tmpnam[L_tmpnam];
static char	_tmppfx[] = "TMP$.$$$";

char *tmpnam(char *s)
{
	do
	{
		sprintf(_tmpnam, "%.5s%03d.TMP", _tmppfx, _tmpcnt);
		_tmpcnt = (_tmpcnt + 1) % TMP_MAX;
	}
		while (exists(_tmpnam));
	if(s == nil)
		return strdup(_tmpnam);
	else
		return strcpy(s, _tmpnam);
}

char *tempnam(const char *dir, char *pfx)
{
	char *p;
	char path[L_tmpnam];

	if ((p = getenv("TMPDIR")) ne 0)
		fullpath(path, p);
	elif (dir)
		fullpath(path, dir);
	else
		fullpath(path, "");

	p = strrchr(path, '\0');

	if (pfx == nil)
		pfx = _tmppfx;
	do
	{
		sprintf(p, "%.5s%03d.TMP", pfx, _tmpcnt);
		_tmpcnt = (_tmpcnt + 1) % TMP_MAX;
	} while (exists(path));

	return strdup(path);
}

FILE *tmpfile(void)
{
	FILE *fp;
	char fn[L_tmpnam];

	tmpnam(fn);

	fp = fopen(fn, "wb+");

	return fp;
}

void clearerr(FILE *fp)
{
	fp->Flags &= ~(_IOEOF|_IOERR);
}

short getw(FILE *fp)
{
	short n, c;

	if ((c = fgetc(fp)) == EOF)
		return EOF;

	n = c << 8;

	if ((c = fgetc(fp)) == EOF)
		return EOF;

	n |= c & 0xFF;

	return n;
}

short putw(short n, FILE *fp)
{
	short m;

	m = (n >> 8);

	if (fputc(m & 0xFF, fp) == EOF)
		return(EOF);

	if (fputc(n & 0xFF, fp) == EOF)
		return EOF;

	return n;
}

long getl(FILE *fp)
{
	long n, c;

	if ((c = getw(fp)) == EOF)
		return EOF;

	n = c << 16;

	if ((c = getw(fp)) == EOF)
		return EOF;

	n |= c & 0xFF;

	return n;
}

long putl(long n, FILE *fp)
{
	long m;

	m = n >> 16;

	if (putw(m & 0xFFFFL, fp) == EOF)
		return EOF;

	if (putw(n & 0xFFFFL, fp) == EOF)
		return EOF;

	return n;
}

void setbuf(FILE *fp, void *buf)
{
	fp->Mode   = 0;
	fp->_cnt   = 0;
	fp->BufPtr = buf;

	if ((fp->BufStart = buf) ne 0)
	{
		fp->Mode  = _IOFBF;
		fp->_bsiz = BUFSIZ;
	othw
		fp->Mode  = _IONBF;
		fp->_bsiz = 0;
	}
}

short setvbuf(FILE *fp, void *buf, short bmode, size_t size)
{
	fp->Mode = bmode;
	fp->_cnt = 0;

	if (buf eq nil)
		if ((buf = malloc(size)) eq nil)
			return 1;

	if (bmode == _IONBF || buf == nil)		/* unbuffered */
	{
		fp->BufStart = nil;
		fp->_bsiz = 0;
	othw									/* full buffering */
		fp->BufStart = buf;
		fp->_bsiz = size;
	}

	fp->BufPtr = fp->BufStart;
	return 0;
}

static
short __xerr[] =
{
	EINVAL,
	ENOENT,
	ENOTDIR,
	EMFILE,

	EACCES,
	EBADF,
	EIO,
	ENOMEM,

	EINVMEM,
	EIO,
	EIO,
	EIO,

	EIO,
	EIO,
	ENODEV,
	EIO,

	EIO,
	ENOENT,
	EIO,
	EIO,

	EIO,
	EIO,
	EIO,
	EIO,

	EIO,
	EIO,
	EIO,
	EIO,

	EIO,
	EIO,
	EIO,
	EIO,

	ESPIPE,
	EIO,
	EPLFMT,
	ENOMEM,
};

static
long __Ferr(long rv, short d)
{
	long v;
	if (rv < d)
	{
		v = -rv - 32;
		if (v > 34)
			v = 5;
		else
			v = __xerr[v];
		return errno = v, -1;
	}
	return rv;
}

short creat(const char *filename, ...)
{
	long rv = Fdelete(filename);

	if (rv == 0 || rv == -33)    /* SUCCESS or FILE-NOT-FOUND */
		rv = Fcreate(filename, 0);

	return __Ferr(rv, 0);
}

short open(const char *filename, short iomode, ...)
{
	long rv;
	short pmode;

	if (access(filename, 0x00))		/* file exists */
	{
		if ((iomode & (O_CREAT | O_EXCL)) == (O_CREAT | O_EXCL))
		{
			errno = EEXIST;
			return -1;
		}

		if (iomode & O_TRUNC)
			rv = Fcreate(filename, 0);
		else
			rv = Fopen(filename, 0x03 & iomode);
	}
	elif (iomode & O_CREAT)
	{
		va_list args;
		va_start(args, iomode);
		pmode = va_arg(args, short);
		rv = Fcreate(filename, pmode);
	}
	else
		rv = -33;

	if (rv >= 0 && (iomode & O_APPEND) ne 0)
		lseek(rv, 0, SEEK_END);

	return __Ferr(rv, LAST_DEVICE);
}


short close(short handle)
{
	long rv = Fclose(handle);
	return __Ferr(rv, 0);
}

size_t read(short h, void *data, size_t len)
{
	long rv = Fread(h, len, data);
	return __Ferr(rv, 0);
}

size_t write(short h, const void *data, size_t len)
{
	long rv = Fwrite(h, len, data);
	return __Ferr(rv, 0);
}

short remove(const char *filename)
{
	long rv = Fdelete(filename);
	return __Ferr(rv, 0);
}

short rename(const char *oldname, const char *newname)
{
	long rv = Frename(0, oldname, newname);
	return __Ferr(rv, 0);
}

short unlink(const char *filename)
{
	return errno = Fdelete(filename);
}

short rmdir(const char *pathname)
{
	return errno = Ddelete(pathname);
}

short mkdir(const char *pathname)
{
	return errno = Dcreate(pathname);
}

short fileno(FILE *fp)
{
	return fp->Handle;
}

short dup(short handle)
{
	short rv;

	if ((rv = Fdup(handle)) < LAST_DEVICE)
		errno = rv;
	return rv;
}

short dup2(short handle1, short handle2)
{
	return errno = Fforce(handle2, handle1);
}

#define	KEY_UNDO	0x1B		/* escape */
#define	KEY_CR		0x0D
#define	KEY_LF		0x0A
#define	KEY_BS		0x08
#define	KEY_DEL		0x7F

char *getln(void *ip, InFunc *get, OutFunc *put, char *buffer, size_t limit)
{
	char *bp = buffer;
	short c, i = 0;

	for(;;)
	{
		c = get(ip) & 0xFF;
		if (c == KEY_UNDO)
		{
			*(bp = buffer) = '\0';
			i = 0;
			break;
		}
		else if ((c == KEY_CR) || (c == KEY_LF))
		{
			*bp = '\0';
			break;
		}
		else if (((c == KEY_BS) || (c == KEY_DEL)) && (bp != buffer))
		{
			--bp;
			put('\b',bp);
			put(' ',bp);
			put('\b',bp);
			--i;
		}
		else if ((c >= ' ') && (i < limit))
		{
			put(c,bp);
			++i;
		}
	}

	return buffer;
}

#define DEFLIST

static
ERR_LIST sys_errlist[]=
{
#include "pc_errno.h"
	{0,nil,nil}
};


char *strerror(short err)
{
	ERR_LIST *l = sys_errlist;
	short e = err;
	if (e < 0) e = -e;

	while (l->text)
	{
		short el = l->errno;

		if (el < 0) el = -el;
		if (e == el)
			return l->text;
		l++;
	}
	return nil;
}

void perror(char *prfx)
{
	char *t = strerror(errno);

	if (prfx)
		if (*prfx)
		{
			fputs(prfx, stderr);
			fputs(": ", stderr);
		}

	if (t)
		fputs(t, stderr);
	else
		fputs("unassigned", stderr);

	fputs(".\n", stderr);
}

extern char **_argv;

void perrorf(char *fmt, ...)
{
	char *progname = _argv[0];
	char pbuf[10];
	char *msg;
	va_list argp;

	_splitpath(progname, NULL, NULL, pbuf, NULL);
	fprintf(stderr, "%s: ", pbuf);

	if (fmt && *fmt)
	{
		va_start(argp, fmt);
		vfprintf(stderr, fmt, argp);
		va_end(argp);
		fputs(": ", stderr);
	}

	if ((msg = strerror(errno)) != 0)
		fputs(msg, stderr);

	fputs(".\n", stderr);
}
