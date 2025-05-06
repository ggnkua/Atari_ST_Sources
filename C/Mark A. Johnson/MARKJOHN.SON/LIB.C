/* 
 * C library for MJC 2.0 - startup, stdio, TOS, malloc 
 * - now cr/nl mapping
 * - fopen handles binary or text options
 * - MAXBUF is now 1024 for speed
 * - exec passes on current process' environment
 */

/* max number of args in argv[] */

#define MAXARG	50	

/* header file for stdio implementation */

#define MAXBUF	1024
#define MAXIO	8

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
#define BINARY	4

/* these should match what's found in stdio.h, except for FILE */

#define FILE	struct file
#define EOF	(-1)
#define NULL	(0L)
#define EOS	((char)0)

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

	extern int _argc;
	extern char *environ;
	extern char *_argv[MAXARG];
	extern FILE *stdin, *stdout, *_fopen();

	char *b, *w, *in, *out;
	int i;
	long x, *lp;

	if (tpa == NULL) { /* this happened to me once; I don't know why */
		_ps("null tpa\n\r");
		return 1;
	}

	/* compute size of program, give memory back to TOS */
	lp = tpa;
	x = lp[3] + lp[5] + lp[7] + 0x100;
	if (trap(1, SETBLK, 0, tpa, x))
		exit(-1);

	/* parse the command line */
	_argc = 1;
	_argv[0] = "yc";
	environ = (char *) lp[11];
	b = tpa + 0x81;
	in = out = NULL;

	while (*b) {
		while (*b && *b <= ' ') b++;
		w = b;
		while (*b && *b > ' ') b++;
		if (*b) *b++ = 0;
		if (*w == '<') in = w+1;
		else if (*w == '>') out = w+1;
		else if (_argc < MAXARG) _argv[_argc++] = w;
	}
	_argv[_argc] = 0L;

	/* init stdio and re-direct if necessary */
	_ioinit();
	if (in) {
		if (_fopen(stdin, in, "r") == NULL) 
			_cant(in);
	}
	if (out) {
		if (*out != '>') { /* create */
			if (_fopen(stdout, out, "w") == NULL)
				_cant(out);
		}
		else	{ /* append */
			if (_fopen(stdout, ++out, "a") == NULL)
				_cant(out);
		}
	}

	/* run the program */
	i = main(_argc, _argv, environ);

	/* close up shop */
	if (in) fclose(stdin);
	if (out) fclose(stdout);
	exit(i);
}

/* initialize standard i/o */

_ioinit() {
	int i;
	extern FILE *stdin, *stdout, *stderr;
	extern FILE _iobuf[1];

	for (i = 0; i < MAXIO; i++) {
		_iobuf[i].mode = FREE;
		_iobuf[i].idx = _iobuf[i].len = 0;
	}
	stdin = &_iobuf[0];   stdin->fd = 0;
	stdout = &_iobuf[1];  stdout->fd = 1;
	stderr = &_iobuf[2];  stderr->fd = 1;
	stdin->mode = RDWR | BINARY;
	stdout->mode = stderr->mode = RDWR;
}

/* trouble redirecting output */

_cant(s) char *s; {
	_ps("can't redirect ");
	_ps(s);
	_ps("\n\r");
	exit(1);
}

/* exit the program */

exit(n) { trap(1, EXIT, n); }

/*  execute a program: mode=0 -> load and go; mode=3 -> load and return  */

exec(file, args, mode) char *file, *args; int mode; {
	extern char *environ;
	return trap(1, 0x4B, mode, file, args, environ);
}

/* get environment variable */

char *
getenv(name) char *name; {
	extern char *environ;
	char *p, *q;
	for (p = environ; *p; ) {
		for (q = name; *p++ == *q++; )
			;
		if (p[-1] == '=' && q[-1] == 0)
			return p;
		while (*p++)
			;
	}
	return NULL;
}

/* data for _cttp */

int 	_argc;
char 	*_argv[MAXARG];
char	*environ;

/* data for standard i/o */

FILE	_iobuf[MAXIO], *stdin, 	*stdout, *stderr;

/* get options from command line */

extern char	*strchr();
extern char	*optarg;
extern int	optind, opterr, optsubind;

getopt(argc, argv, optstr) char *argv[], *optstr; {
	char	*o, c;

	if (++optind == argc) return EOF;

	o = argv[optind];

	if (*o == '-') {
		c = o[++optsubind];
		if (c == '-') return EOF;
		optstr = strchr(optstr, c);
		if (optstr == NULL) {
			if (opterr == 0) {
				_ps("unknown option: ");
				_ps(o);
				_ps("\n\r");
			}
			optsubind = 0;
			return '?';
		}
		if (optstr[1] == ':') {
			optarg = (o[optsubind + 1] != (char)0)
					? o + optsubind + 1 : argv[++optind];
			optsubind = 0;
			if (optarg == NULL) {
				if (opterr == 0) {
					_ps("missing arg: ");
					_ps(o);
					_ps("\n\r");
				}
				return '?';
			}
		}
		else if (o[2] != (char)0) {
			optind -= 1;
		}
		return c;
	}
	return EOF;
}

char	*optarg;
int	optind, opterr, optsubind;

_ps(s) char *s; { while (*s) trap(1, 2, *s++); }

/*
 * stdio routines 
 */

/* return file descriptor of a stream */

fileno(s) FILE *s; { return s->fd; }

/* read a stream */

fread(buf, sz, n, s) char *buf; FILE *s; {
	int r;
	long nn;
	nn = (long) n * (long) sz;
	if ((r = trap(1, READ, s->fd, nn, buf)) < 0)
		r = 0;
	else	r = r / sz;
	return r;
}

/* write on a stream */

fwrite(buf, sz, n, s) char *buf; FILE *s; {
	int r;
	long nn;
	nn = (long) n * (long) sz;
	if ((r = trap(1, WRITE, s->fd, nn, buf)) < 0)
		r = 0;
	else	r = r / sz;
	return r;
}

/* seek and ye shall find */

fseek(s, offset, mode) FILE *s; long offset; {
	lseek(s->fd, offset, mode);
}

/* re-open a stream */

FILE *
freopen(name, mode, fp) char *name, *mode; FILE *fp; {
	FILE *fopen();
	fclose(fp);
	return fopen(name, mode);
}

/* close a stream */

fclose(s) FILE *s; {
	if (s != NULL) {
		if ((s->mode & RDWR) == WR) fflush(s);
		if (s->fd > 5) trap(1, CLOSE, s->fd);
		s->mode = FREE;
	}
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
	int i;
	FILE *_fopen();
	for (i = 0; i < MAXIO && _iobuf[i].mode != FREE; i++)
		;
	if (i >= MAXIO) return NULL;
	return _fopen(&_iobuf[i], name, mode);
}

FILE *
_fopen(s, name, mode) FILE *s; char *name, *mode; {
	int m, fd;
	if (strcmp(name, "PRT:") == 0) {
		fd = 3;
		m = RDWR;
	}
	else if (strcmp(name, "CON:") == 0) {
		fd = 0;
		m = RDWR;
	}
	else if (strcmp(name, "AUX:") == 0) {
		fd = 2;
		m = RDWR;
	}
	else	{
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
	}
	if (mode[1] == 'b')
		m |= BINARY;
	if (fd < 0) return NULL;
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
	if ((c = getc(stdin)) == EOF) 
		return NULL;
	while (c != '\n' && c != EOF) {
		*b++ = c;
		c = getc(stdin);
	}
	*b = 0;
	return r;
}

/* get a character from standard input */

getchar() { return getc(stdin); }

/* get a character from a stream, map CR/NL to NL, handle console */

getc(s) FILE *s; {
	int i, l, c, r, m;
	if (s == NULL) return EOF;
	m = (s->mode & RDWR);
	if (m == RDWR) {
		l = trap(1, READ, s->fd, (long) 1, s->buf);
		if (l != 1) return EOF;
		i = 0;
	}
	else if (m == RD) {
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
	if (s->fd == 0) { /* tty input */
		if (c == '\r')
			trap(1, 2, (c = '\n'));
		else if (c == 0x04) /* control D */
			c = EOF;
	}
	if (c == '\r' && !(s->mode & BINARY))
		c = getc(s);
	return c;
}

/* output characters to a stream */

putchar(c) { putc(c, stdout); }

puts(s) char *s; {
	while (*s) putc(*s++, stdout);
	putc('\n', stdout);
}

putc(c, s) int c; FILE *s; {
	int i, m, r = 0;
	if (s == NULL) return EOF;
	if (c == '\n' && !(s->mode & BINARY))
		r = putc('\r', s);
	r = 0;
	m = s->mode & RDWR;
	if (m == RDWR) {
		s->buf[0] = c;
		r = trap(1, WRITE, s->fd, (long) 1, s->buf);
	}
	else if (m == WR) {
		if (s->idx == MAXBUF) r = fflush(s);
		s->buf[s->idx] = c;
		s->idx = s->idx + 1;
	}
	else 	return EOF;
	return r <= 0 ? EOF : r;
}

/* flush out a buffer */

fflush(s) FILE *s; {
	int r;
	if (s->idx > 0) 
		r = trap(1, WRITE, s->fd, (long) s->idx, s->buf);
	s->idx = 0;
	return r <= 0 ? EOF : r;
}

/* 
 * TOS routines 
 */

/* duplicate a file descriptor */

dup(fd) { return trap(1, 0x45, fd); }

dup2(fold, fnew) { return trap(1, 0x46, fold, fnew); }

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

/* malloc, free, realloc: dynamic memory allocation */

#define MAXHUNK	20000

struct header {
	struct header *next;
	long size;
};

char *
realloc(r, n) struct header *r; unsigned n; {
	struct header *p, *q;
	char *malloc();
	long *src, *dst;
	long sz;

	p = r - 1;
	sz = (n + sizeof(struct header) + 7) & ~7;

	if (p->size > sz) { /* block too big, split in two */
		q = ((long) p) + sz;
		q->size = p->size - sz;
		free(q + 1);
		p->size = sz;
	}
	else if (p->size < sz) { /* block too small, get new one */
		dst = q = malloc(n);
		if (q != NULL) {
			src = r;
			n = p->size - sizeof(struct header);
			while (n > 0) {
				*dst++ = *src++;
				n -= sizeof(long);
			}
		}
		free(r);
		r = q;
	}
	/* else current block will do just fine */

	return r;
}

char *
calloc(n, sz) unsigned n, sz; {
	char *r, *s, *malloc();
	unsigned total;

	total = n * sz;
	if ((r = s = malloc(total)) != NULL) {
		while (total--)
			*s++ = 0;
	}
	return r;
}

char *
malloc(n) unsigned n; {
	extern struct header _base;
	struct header *p, *q;
	long sz, asz;

	/* add a header to required size and round up */
	sz = (n + sizeof(struct header) + 7) & ~7;

	/* look for first block big enough in free list */
	p = &_base;
	q = _base.next;
	while (q != NULL && q->size < sz) {
		p = q;
		q = q->next;
	}

	/* if not enough memory, get more from the system */
	if (q == NULL) {
		asz = (sz < MAXHUNK) ? MAXHUNK : sz;
		q = trap(1, 0x48, asz);
		if (((long)q) < 0L) /* no more memory */
			return NULL;
		p->next = q;
		q->size = asz;
		q->next = NULL;
	}
		
	if (q->size > sz + sizeof(struct header)) { /* chop it up */
		q->size -= sz;
		q = ((long) q) + q->size;
		q->size = sz;
	}
	else	{ /* unlink from free list */
		p->next = q->next;
	}
	
	/* skip over header, hope they don't touch it */
	return ++q;
}

free(r) struct header *r; {
	extern struct header _base;
	struct header *p, *q, *t;

	/* move back to uncover the header */
	r--;

	/* find where to insert it */
	p = &_base;
	q = _base.next;
	while (q != NULL && q < r) {
		p = q;
		q = q->next;
	}

	/* merge after if possible */
	t = ((long) r) + r->size;
	if (q != NULL && t >= q) {
		r->size += q->size;
		q = q->next;
	}
	r->next = q;
	
	/* merge before if possible, otherwise link it in */
	t = ((long) p) + p->size;
	if (t >= r) {
		p->size += r->size;
		p->next = r->next;
	}
	else	p->next = r;
}

struct header _base = { NULL, 0L };

/* a UNIX style time command */

extern int _ma[];

long
time(tloc) long *tloc; {
	int	n, hms, y, m, d;
	long	t;

	n = getdate();
	y = (n >> 9) & 127; m = (n >> 5) & 15; d = n & 31;
	hms = gettime();
	t = (1460 * y) / 4 + ((y % 4) ? 1 : 0) + _ma[m] + d;
	t = 2L * (long)(hms & 31)
		+ 60L * (long)((hms >> 5) & 63)
		+ 3600L * (24L * t + (long)((hms >> 11) & 31));
	if (tloc != NULL) *tloc = t;
	return t;
}

getdate() { return trap(1, 0x2A); }

gettime() { return trap(1, 0x2C); }

int _ma[12] = { 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334 };

/* setjmp/longjmp thanks to Bruce Szablak, use setjmp.h! */

setjmp(buf) char **buf; {
	asm( lll 8 0);
	asm( tda 0 0); /* a0 has pointer to buffer */
	asm( tad 6 0); /* d0 has current link pointer */
	asm( sol 0 0 0); /* save clp */
	asm( lol 6 0 0); /* d0 has old link pointer */
	asm( sol 0 4 0); /* save olp */
	asm( lol 6 4 0); /* d0 has return address */
	asm( sol 0 8 0); /* save ret */
	return 0;
}

longjmp(buf, rc) char **buf; {
	asm( lll 8 0);
	asm( tda 0 0); /* buf in a0 */
	asm( llw 12 0); /* rc in d0 */
	asm( lol 0 0 1); /* current link pointer */
	asm( tda 1 6); /* now in a6 */
	asm( lol 0 4 1); /* old link pointer */
	asm( sll 1 0); /* now on stack */
	asm( lol 0 8 1); /* return address */
	asm( sll 1 4); /* now on stack */
	return; /* longjmp! */
}	

