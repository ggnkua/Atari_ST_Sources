/* C library - startup, stdio, strings, TOS */

#define MAXARG	30

/* header file for stdio implementation */

#define MAXBUF	256
#define MAXIO	6

struct file {
	char	mode;		/* free or open for read/write 		*/
	char	fd;		/* GEMTOS file descriptor		*/
	int	idx;		/* next slot in buf read/written	*/
	int	len;		/* length of the buffer			*/
	char	buf[MAXBUF];	/* i/o buffer				*/
};

/* these are the allowed modes */

#define FREE	0
#define RD	1
#define WR	2
#define RDWR	3

/* these should match what's found in stdio.h, except for FILE */

#define FILE	struct file
#define EOF	(-1)
#define NULL	((char *)0)

/* these are the GEMDOS trap commands */

#define CREATE	0x3C
#define OPEN	0x3D
#define CLOSE	0x3E
#define READ	0x3F
#define WRITE	0x40
#define LSEEK	0x42
#define SETBLK	0x4A
#define EXIT	0x4C

/* 
 * the c runtime start up routine for ttp processes
 *
 * assumes a startup sttp.s of
 *	. _bstk 2048
 *	. _estk 4
 *	taa 7 6
 *	lll 4 0
 *	sgl _estk
 *	lag _estk 7
 *	jsr _cttp
 */

_cttp(tpa) long tpa; {

	extern int argc;
	extern char *argv[MAXARG];
	extern FILE *stdin, *stdout, *stderr;
	extern FILE _iobuf[1];

	char *b, *w, *in, *out;
	int i;
	long x, *lp;

	/* compute size of program, give memory back to TOS */
	lp = tpa;
	x = lp[3] + lp[5] + lp[7] + 0x100;
	if (trap(1, SETBLK, 0, tpa, x))
		exit(-1);

	/* parse the command line */
	argc = 1;
	argv[0] = "yc";
	b = tpa + 0x81;
	in = out = NULL;
	while (*b) {
		while (*b && *b <= ' ') b++;
		w = b;
		while (*b && *b > ' ') b++;
		if (*b) *b++ = 0;
		if (*w == '<') in = w+1;
		else if (*w == '>') out = w+1;
		else if (argc < MAXARG) argv[argc++] = w;
	}
	argv[argc] = 0L;

	/* init stdio */
	for (i = 0; i < MAXIO; i++) {
		_iobuf[i].mode = FREE;
		_iobuf[i].fd = _iobuf[i].idx = _iobuf[i].len = 0;
	}
	stdin = &_iobuf[0];
	stdout = &_iobuf[1];
	stderr = &_iobuf[2];
	stdin->mode = stdout->mode = stderr->mode = RDWR;
	if (in) {
		stdin->fd = i = trap(1, OPEN, in, 0);
		stdin->mode = RD;
		if (i < 0) _cant(in, i);
	}
	if (out) {
		if (*out != '>') { /* create */
			stdout->fd = i = trap(1, CREATE, out, 0);
		}
		else	{ /* append */
			stdout->fd = i = trap(1, OPEN, ++out, 1);
			if (i >= 0) i = trap(1, LSEEK, 0L, i, 2);
		}
		stdout->mode = WR;
		if (i < 0) _cant(out, i);
	}
	
	/* run the program */
	i = main(argc, argv);

	/* close up shop */
	if (in) fclose(stdin);
	if (out) fclose(stdout);
	exit(i);
}

/* trouble redirecting output */

_cant(s, fd) char *s; {
	_ps("can't redirect ");
	_ps(s);
	_ps("\n\r");
	exit(fd);
}

_ps(s) char *s; { while (*s) trap(1, 2, *s++); }

/* exit the program */

exit(n) { trap(1, EXIT, n); }

/* data for _cttp or _ctos */

int 	argc;
char 	*argv[MAXARG];

FILE	_iobuf[MAXIO], *stdin, 	*stdout, *stderr;

/* 
 * printf's
 */

sprintf(buf, fmt, args) char *buf, *fmt; int args; {
	_dopf(buf, fmt, &args);
}

printf(fmt, args) char *fmt; int args; { 
	extern char _pfb[1];
	_dopf(_pfb, fmt, &args);
	fputs(_pfb, stdout);
}

fprintf(s, fmt, args) FILE *s; char *fmt; int args; { 
	extern char _pfb[1];
	_dopf(_pfb, fmt, &args);
	fputs(_pfb, s);
}

/*
 * stdio routines 
 */

/* close a stream */

fclose(s) FILE *s; {
	if (s != NULL) {
		if (s->mode == WR) fflush(s);
		if (s->fd) trap(1, CLOSE, s->fd);
		s->mode = FREE;
	}
}
/* flush out a buffer */

fflush(s) FILE *s; {
	int r;
	if (s->idx > 0) 
		r = trap(1, WRITE, s->fd, (long) s->idx, s->buf);
	s->idx = 0;
	return r <= 0 ? EOF : r;
}

/* get a string from a stream */

char *
fgets(b, n, f) char *b; int n; FILE *f; {
	int c, i;
	c = getc(f);
	if (c == EOF) return NULL;
	n--;
	for (i = 0; i < n && c != EOF; c = getc(f)) {
		b[i++] = c;
		if (c == '\n') break;
	}
	b[i] = 0;
	return b;
}

/* open a stream */

FILE *
fopen(name, mode) char *name, *mode; {
	int i, m, fd, x;
	FILE *s;
	for (i = 0; i < MAXIO && _iobuf[i].mode != FREE; i++)
		;
	if (i >= MAXIO) return NULL;
	if (*mode == 'w') {
		fd = trap(1, CREATE, name, 0);
		m = WR;
	}
	else if (*mode == 'r') {
		fd = trap(1, OPEN, name, 0);
		m = RD;
	}
	else if (*mode == 'a') {
		if ((fd = trap(1, OPEN, name, 1)) < 0)
			fd = trap(1, CREATE, name, 0);
		else	if (trap(1, LSEEK, 0L, fd, 2) < 0L)
			fd = -1;
		m = WR;
	}
	else	{ /* anything goes here, usually '+' */
		fd = trap(1, OPEN, name, 3);
		m = RDWR;
	}
	if (fd < 0) return NULL;
	s = &_iobuf[i];
	s->len = s->idx = 0;
	s->fd = fd;
	s->mode = m;
	return s;
}

/* put a string onto the stream */

fputs(s, f) char *s; FILE *f; {
	while (*s) putc(*s++, f);
}

/* get a string from stdin */

char *
gets(b) char *b; {
	int c;
	char *r;
	r = b;
	if ((c = getc(stdin)) == EOF) return NULL;
	while (c != '\n' && c != EOF) {
		*b++ = c;
		c = getc(stdin);
	}
	*b = 0;
	return r;
}

/* get a character from standard input */

getchar() { return getc(stdin); }

/* get a character from a stream */

getc(s) FILE *s; {
	int i, l, c, r;
	if (s == NULL) return EOF;
	if (s->mode == RDWR) {
		l = trap(1, READ, s->fd, (long) 1, s->buf);
		if (l != 1) return EOF;
		i = 0;
	}
	else if (s->mode == RD) {
		i = s->idx;
		while (i >= s->len) {
			l = trap(1, READ, s->fd, (long) MAXBUF, s->buf);
			if (l <= 0) {
				s->idx = s->len = 0;
				return EOF;
			}
			s->len = l;
			i = 0;
		}
		s->idx = i + 1;
	}
	else	return EOF;
	c = s->buf[i] & 255;
	if (s->fd == 0 && c == '\r')
		putc(c = '\n', s);
	return c;
}

/* output characters to a stream */

putchar(c) { putc(c, stdout); }

puts(s) char *s; {
	while (*s) putc(*s++, stdout);
	putc('\n', stdout);
}

putc(c, s) int c; FILE *s; {
	int i, r;
	if (s == NULL) return EOF;
	r = 0;
	if (s->mode == RDWR) {
		s->buf[0] = c;
		r = trap(1, WRITE, s->fd, (long) 1, s->buf);
	}
	else if (s->mode == WR) {
		if (s->idx == MAXBUF) r = fflush(s);
		s->buf[s->idx] = c;
		s->idx = s->idx + 1;
	}
	else 	return EOF;
	if (s->fd == 0 && c == '\n') r = putc('\r', s);
	return r <= 0 ? EOF : r;
}

/* 
 * string routines
 */

/* concatenate two strings */

strcat(s1, s2) char *s1, *s2; {
	while (*s1) s1++;
	while (*s1++ = *s2++);
}

/* compare string s1 to s2, <0 for <, 0 for ==, >0 for >  */

int				
strcmp(s1, s2) char *s1, *s2; {
	while (*s1 && *s1 == *s2) {
		s1++;
		s2++;
	}

	/*
	 * The following case analysis is necessary so that characters
	 * which look negative collate low against normal characters but
	 * high against the end-of-string NUL.
	 */

	if (*s1 == 0 && *s2 == 0)
		return 0;
	else if (*s1 == 0)
		return -1;
	else if (*s2 == 0)
		return 1;
	else	return (*s1 - *s2);
}

/* copy a string from source to destination */

char *
strcpy(dst, src) char *dst, *src; {
	char *r;
	r = dst;
	while (*dst++ = *src++)
		;
	return r;
}

/* 
 * TOS routines 
 */

/* duplicate a file descriptor */

dup(fd) { return trap(1, 0x45, fd); }

/*  execute a program: mode=0 -> load and go; mode=3 -> load and return  */

exec(file, args, env, mode) char *file, *args, *env; int mode; {
	return trap(1, 0x4B, mode, file, args, env);
}

/* get current directory: drive=0 -> current drive, drive=1 -> A:, etc */

getdir(buf, drive) char *buf; {
	return trap(1, 0x47, buf, drive);
}

/* 
 * list the disk directory
 *	pat != NULL - set the DTA buffer, do an SFIRST
 *	pat == NULL - do a SNEXT
 */

listdir(pat, buf, mode) char *pat, *buf; {
	if (pat) {
		trap(1, 0x1A, buf);
		return trap(1, 0x4E, pat, mode);
	}
	else	return trap(1, 0x4F);
}

/* seek to a position in a file */

lseek(fd, offset, mode) int fd; long offset; int mode; {
	return trap(1, 0x42, offset, fd, mode);
}

/* 
 * memory allocation 
 *	size = -1L - return current free memory
 * 	negative return is an error
 */

char *
malloc(size) long size; {
	return (char *) trap(1, 0x48, size);
}

/*  free allocated memory: return of 0 is good, negative is error */

long
mfree(m) char *m; {
	return (long) trap(1, 0x49, m);
}

/* reserve a specific block of memory */

setblock(start, size) char *start; long size; {
	return trap(1, 0x4A, start, size);
}

/* unlink a file */

unlink(name) char *name; { return trap(1, 0x41, name); }

/* close a file */

close(fd) { trap(1, 0x3E, fd); }

/* create a file */

creat(f, m) char *f; {
	return trap(1, 0x3C, f, m);
}

/* open a file */

open(f, m) char *f; {
	return trap(1, 0x3D, f, m);
}

/* read a file */

read(fd, buf, sz) int fd, sz; char *buf; {
	return trap(1, 0x3F, fd, (long) sz, buf);
}

/* unix-like write system call */

write(fd, buf, sz) int fd, sz; char *buf; {
	return trap(1, 0x40, fd, (long) sz, buf);
}

/* 
 * chmod(name, mode)
 * mode = 0x00 - normal file (read/write)
 *        0x01 - read only file
 *        0x02 - hidden file
 *        0x04 - system file
 *        0x08 - file is volume label
 *        0x10 - file is a subdirectory
 *        0x20 - file is written and closed correctly
 */

chmod(name, mode) char *name; int mode; {
	return trap(1, 0x43, name, mode, 0);
}

/* 
 * the guts of all the printf's 
 */

char _pfb[100];		/* in case someone needs a buffer */

_dopf(buf, fmt, ap) char *buf, *fmt; int *ap; {
	char *_pn(), **pp, *ps;
	long n, *lp;
	int c, larg;
	while (c = *fmt++) {
		if (c == '%') {
			c = *fmt++;
			if (larg = (c == 'l'))
				c = *fmt++;
			switch (c) {
				case 'c': *buf++ = *ap++; 
					  break;
				case 's': pp = (char **) ap;
					  ps = *pp++;
					  ap = (int *) pp;
					  while (*ps) *buf++ = *ps++;
					  break;
				case 'd': case 'x': case 'o':
					  if (larg) {
						lp = ap;
						n = *lp++;
						ap = lp;
					  }
					  else	n = (long) (*ap++);
					  buf = _pn(buf, n, c); 
	   				  break;
				default:  *buf++ = c; 
					  break;
			}
		}
		else	*buf++ = c;
	}
	*buf = 0;
}

/* fill a buffer with a number */

char *
_pn(b, n, base) char *b; long n; {
	int i, nd;
	unsigned long x;
	char nb[20];
	x = n;
	switch (base) {
	case 'o':
		base = 8;
		break;
	case 'x':
		base = 16;
		break;
	default:
		base = 10;
		if (n < 0) {
			*b++ = '-';
			x = -n;
		}
	}
	for (i = 0; x; x = x / base) {
		nd = x % base;
		nb[i++] = "0123456789ABCDEF"[nd & 15]; /* just to be safe */
	}
	if (i == 0) nb[i++] = '0';
	while (i--) *b++ = nb[i];
	return b;
}

/* 
 * stuff for long binary ops (both signed and unsigned)
 *	op == 0 for a multiplication request
 *	op == 1 for a division
 *	op == 2 for a mod operation
 *	a and b are the left and right arguments to the binary operator
 *
 * div and mod are done by long division, shift b up until >= a, then
 * back down, subtracting when appropriate
 *
 * mul is done by shifts and adds
 */

#define MUL	0
#define DIV	1
#define MOD	2

long
_lop(op, a, b) int op; long a, b; {
	int neg;
	long result, _ulop();
	neg = 0;
	if (a < 0) {
		neg++;
		a = -a;
	}
	if (b < 0) {
		neg++;
		b = -b;
	}
	result = _ulop(op, a, b);
	return (((op != MOD) && (neg & 1)) ? -result : result);
}

long
_ulop(op, xx, yy) int op; unsigned long xx, yy; {
	register int i;
	register unsigned long result, x, y;
	x = xx;
	y = yy;
	if (op == MUL) {
		result = 0L;
		while (x) {
			if (x & 1L)
				result += y;
			x >>= 1L;
			y <<= 1L;	
		}
	}
	else	{ /* DIV or MOD */
		i = 0;
		result = x > 0x80000000L ? 0x80000000L : x;
		while (y < result) {
			i++;
			y <<= 1L;
		}
		result = 0L;
		while (i) {
			if (x >= y) {
				x -= y;
				result++;
			}
			i--;
			result <<= 1L;
			y >>= 1L;
		}
		if (x >= y) {
			x -= y;
			result++;
		}
		if (op == MOD) result = x;
	}
	return result;
}
