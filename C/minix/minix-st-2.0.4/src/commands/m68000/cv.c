/*
 * (c) copyright 1988 by the Vrije Universiteit, Amsterdam, The Netherlands.
 * See the copyright notice in the file "../Copyright".
 */
/*
 * Convert ACK a.out file to ST-Minix object format.
 */

#include <sys/types.h>
#include <stdio.h>
#include <a.out.h>
#undef	S_ABS	/* avoid collision */
#include <out.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>

_PROTOTYPE(void main, (int argc, char *argv []));
_PROTOTYPE(void emit_head, (void));
_PROTOTYPE(int follows, (int segb, int sega));
_PROTOTYPE(void emit_sect, (int seg));
_PROTOTYPE(void emit_syms, (void));
_PROTOTYPE(void emit_relo, (void));
_PROTOTYPE(long chmem, (char *str, long old));
_PROTOTYPE(void fatal, (char *s, ...));
_PROTOTYPE(void rderr, (void));
_PROTOTYPE(void wrerr, (void));
_PROTOTYPE(void getofmt, (char *p, char *s, FILE *f));
_PROTOTYPE(void putlong, (long l, FILE *f));

#define	DEFAULT_STACK	0x00008000L

#define	USE_ALLOCA
#ifdef USE_ALLOCA
_PROTOTYPE(char *alloca, (unsigned int amount));
#define	ALLOCA_MAX	65534
#endif /* USE_ALLOCA */

#define TXTSEG	0
#define ROMSEG	1
#define DATSEG	2
#define BSSSEG	3
#define ENDSEG	4

struct outhead	outhead;
struct outsect	outsect[ENDSEG+1];

int	Rflag;

char	*output_file;
char	*program;
char	*chmemstr;

void main(argc, argv)
	int	argc;
	char	*argv[];
{
	register int	i;

	program = argv[0];
	while (argc > 1) {
		switch (argv[1][0]) { 
		case '-':
			if (strcmp(argv[1], "-R") == 0) {
				Rflag++;
				argc--;
				argv++;
				continue;
			}
			/* fall through */
		case '+':
		case '=':
			chmemstr = argv[1];
			argc--;
			argv++;
			continue;
		}
		break;
	}
	if (argc == 4 && strncmp(argv[2], "-o", 2) == 0) {	/* For GCC */
		argv[2] = argv[3];
		argc--;
	}
	if (argc != 3)
		fatal("Usage: %s [-R] [+-= amount] <ACK object> [-o] <MINIX-ST object>", argv[0]);

	if ((freopen(argv[1], "r", stdin)) == NULL)
		fatal("Can't read %s", argv[1]);
	if ((freopen(argv[2], "w", stdout)) == NULL)
		fatal("Can't write %s", argv[2]);
	output_file = argv[2];

	getofmt((char *)&outhead, SF_HEAD, stdin);
	if (BADMAGIC(outhead))
		fatal("Not an ack object file");
	if (outhead.oh_flags & HF_LINK)
		fatal("Contains unresolved references");
	if (outhead.oh_nsect < BSSSEG+1)
		fatal("Input must have at least %d sections, not %ld",
			BSSSEG+1, outhead.oh_nsect);
	if (outhead.oh_nsect > ENDSEG+1)
		fatal("Input must have at most %d sections, not %ld",
			ENDSEG+1, outhead.oh_nsect);
	for (i = 0; i < outhead.oh_nsect; i++)
		getofmt((char *)&outsect[i], SF_SECT, stdin);

	/* A few checks */
	if (outsect[BSSSEG].os_flen != 0)
		fatal("bss contains initialized data");
	if (! follows(ROMSEG, TXTSEG))
		fatal("rom must follow text");
	if (! follows(DATSEG, ROMSEG))
		fatal("data must follow rom");
	if (! follows(BSSSEG, DATSEG))
		fatal("bss must follow data");
	outsect[TXTSEG].os_size = outsect[ROMSEG].os_base - outsect[TXTSEG].os_base;
	outsect[ROMSEG].os_size = outsect[DATSEG].os_base - outsect[ROMSEG].os_base;
	outsect[DATSEG].os_size = outsect[BSSSEG].os_base - outsect[DATSEG].os_base;
	if (outhead.oh_nsect == ENDSEG+1) {
		if (! follows(ENDSEG, BSSSEG))
			fatal("end segment must follow bss");
		if (outsect[ENDSEG].os_size != 0)
			fatal("end segment must be empty");
	}
/*
	fprintf(stderr,"TXT os_base / os_size = %ld / %ld\n", outsect[TXTSEG].os_base, outsect[TXTSEG].os_size);
	fprintf(stderr,"DAT os_base / os_size = %ld / %ld\n", outsect[DATSEG].os_base, outsect[DATSEG].os_size);
	fprintf(stderr,"BSS os_base / os_size = %ld / %ld\n", outsect[BSSSEG].os_base, outsect[BSSSEG].os_size);
*/
	emit_head();
	emit_sect(TXTSEG);
	emit_sect(ROMSEG);
	emit_sect(DATSEG);
	emit_syms();
	emit_relo();
#ifndef UNIX
	if (output_file) chmod(output_file, 0777 & ~umask(0));
#endif
	exit(0);
}

void emit_head()
{
	register	i;
	long		mh[8];
	long		stack;
	struct exec *ep = (struct exec *) &mh[0];

#if 0
	mh[0] = 0x0103100BL;
	mh[1] = 0x20000000L;
#else
	ep->a_cpu = A_M68K;
	ep->a_flags = A_EXEC;
	ep->a_magic[0] = A_MAGIC0;
	ep->a_magic[1] = A_MAGIC1;
	ep->a_version = 0;
	ep->a_unused = 0;
	ep->a_hdrlen = 0x20;
#endif
	mh[2] = outsect[TXTSEG].os_size + outsect[ROMSEG].os_size;
	mh[3] = outsect[DATSEG].os_size;
	mh[4] = outsect[BSSSEG].os_size;
	mh[5] = 0;
#ifndef DEFAULT_STACK
	stack = 0x00010000L - (mh[3] + mh[4]);
	if ((mh[0] & 0x00200000L) == 0)		/* not SEPARATE */
		stack -= mh[2];
	while (stack < 0)
		stack += 0x00010000L;
#else
	stack = DEFAULT_STACK;
#endif /* DEFAULT_STACK */
	if (chmemstr) {
		stack = chmem(chmemstr, stack);
		fprintf(stderr, "%ld bytes assigned to stack+malloc area\n", stack);
	}
	mh[6] = stack + (mh[3] + mh[4]);
	if ((mh[0] & 0x00200000L) == 0)		/* not SEPARATE */
		mh[6] += mh[2];
	mh[7] = outhead.oh_nname * (long) sizeof(struct nlist);
	for (i = 0; i < 8; i++)
		putlong(mh[i], stdout);
}

int follows(segb, sega)
int segb;
int sega;
{
	register struct outsect *pb = &outsect[segb];
	register struct outsect *pa = &outsect[sega];
	register long		b;

	/* return 1 if segb follows sega */

	b = pa->os_base + pa->os_size;
	if (pb->os_lign) {
		b += pb->os_lign - 1;
		b -= b % pb->os_lign;
	}
	return(pb->os_base == b);
}

/*
 * Transfer the emitted bytes from one file to another.
 */
#define	TRANSBUF_SZ	(6*4096)
void emit_sect(seg)
int seg;
{
	register struct outsect *sp = &outsect[seg];
	register long		sz;
	register int		c;
	register int		chunk;
	char    		*buf;

	fseek(stdin, sp->os_foff, 0);

	if ((buf = malloc(TRANSBUF_SZ)) != NULL) {
		sz = sp->os_flen;
		while (sz > 0) {
			chunk = (sz > TRANSBUF_SZ) ? TRANSBUF_SZ : sz;
			if (fread(buf, 1, chunk, stdin) != chunk)
				rderr();
			if (fwrite(buf, 1, chunk, stdout) != chunk)
				wrerr();
			sz -= chunk;
		}
		free(buf);
	} else {
		for (sz = sp->os_flen; sz > 0; sz--) {
			c = getc(stdin);
			if (c == EOF)
				rderr();
			c = putc(c, stdout);
			if (c == EOF)
				wrerr();
		}
	}

	for (sz = sp->os_size - sp->os_flen; sz > 0; sz--) {
		c = putc(0, stdout);
		if (c == EOF)
			wrerr();
	}
}

void emit_syms()
{
	register unsigned short nrsyms;
	struct outname nbuf;
	struct nlist alist;
	long fi_to_co;
	char *cbufp;
	register int sclass;
	static char segment[] = { N_TEXT, N_TEXT, N_DATA, N_BSS, N_BSS };
#ifdef USE_ALLOCA
	unsigned long ul, readcount = outhead.oh_nchar;
	unsigned int ucount;
#else
	unsigned readcount = outhead.oh_nchar;
#endif /* USE_ALLOCA */

	if (readcount == 0) return;	/* no symbols present */

#ifdef USE_ALLOCA
	ul = readcount;
	while (ul > 0) {
		ucount = ul > ALLOCA_MAX ? ALLOCA_MAX : ul;
		cbufp = (char *)alloca(ucount);
		if (cbufp == NULL) {
    			fprintf(stderr, "cv warning: out of memory writing symbols, no symbols written\n");
			return;
		}
		ul -= ucount;
	}
#else
	if (readcount != outhead.oh_nchar) {
		fprintf(stderr, "cv warning: too many symbols, no symbols written\n");
/*    		fprintf(stderr, "oh_nname=%d, oh_nchar=%ld(=%lx)\n", \
			outhead.oh_nname, outhead.oh_nchar, outhead.oh_nchar);
 */
		return;
    	}

	if ((cbufp = (char *)malloc(readcount)) == NULL) {
    		fprintf(stderr, "cv warning: out of memory writing symbols, no symbols written\n");
		return;
	}
#endif /* USE_ALLOCA */

	fseek(stdin, OFF_CHAR(outhead), 0);
	fi_to_co = (long)cbufp - OFF_CHAR(outhead);

#ifdef USE_ALLOCA
	ul = readcount;
	while (ul > 0) {
		ucount = ul > 32000 ? 32000 : ul;
		fread(cbufp, 1, ucount, stdin);
		ul -= ucount;
		cbufp += ucount;
	}
#else
	fread(cbufp, 1, readcount, stdin);
#endif /* USE_ALLOCA */

	fseek(stdin, OFF_NAME(outhead), 0);
	alist.n_numaux = 0;
	alist.n_type = 0;
	for (nrsyms = outhead.oh_nname; nrsyms > 0; nrsyms--)
	{
		getofmt((char *)&nbuf, SF_NAME, stdin);
		if (nbuf.on_foff == 0) /* no name */
			strcpy(alist.n_name, "");
		else
			strncpy(alist.n_name, (char *)(nbuf.on_foff + fi_to_co), 8); 
		alist.n_value = nbuf.on_valu;
		sclass = nbuf.on_type & S_TYP;
		alist.n_sclass = (sclass == S_ABS) ? N_ABS :
						segment[sclass - S_MIN];
		if (nbuf.on_type & S_EXT) {
			alist.n_sclass |= C_EXT;
		}
		fwrite(&alist, sizeof(struct nlist), 1, stdout);
	}
#ifndef	USE_ALLOCA
	free(cbufp);
#endif /* USE_ALLOCA */
}

void emit_relo()
{
	register char	*ptr;
	register unsigned int	len;
	register int	bit;
	register unsigned long	byt; /* index for 64k -> unsigned */
	register long	last;
	register long	curr;
	register long	base;
	register long	stop;
	register long	i;
	struct outrelo	outrelo;

	if (Rflag) {
		putlong(0L, stdout);
		return;
	}
	fseek(stdin, OFF_RELO(outhead), 0);
	base = outsect[TXTSEG].os_base;
	stop = outsect[BSSSEG].os_base;
	len = (unsigned int)(((stop - base) + 15) / 16);
	if (len != (((stop - base) + 15) / 16)) /* 64k relo => 1MB total size */
		fatal("relo: span too big");
	ptr = calloc(len, 1);
	if (ptr == NULL)
		fatal("out of memory allocating relo mem");
	for (i = outhead.oh_nrelo; i > 0; i--) {
		getofmt((char *)&outrelo, SF_RELO, stdin);
		if (outrelo.or_type & RELPC)
			continue;
		if (outrelo.or_nami == outhead.oh_nname)
			continue;
		if ((outrelo.or_type & (RELBR|RELWR)) != (RELBR|RELWR))
			fatal("relo: not for 680X0");
		if ((outrelo.or_type & RELSZ) != RELO4) {

			static int warned;

			if (!warned) {
				fprintf(stderr, "only longs can be relocated\n");
/*				fprintf(stderr, "%lx(%d):%d (%ld)", 
					outrelo.or_addr, outrelo.or_sect-S_MIN,
					outrelo.or_type & RELSZ,
					(long) (outhead.oh_nrelo - i));
 */
				warned++;
			}
		}
		outrelo.or_sect -= S_MIN;
		if (outrelo.or_sect < TXTSEG || outrelo.or_sect > DATSEG)
			fatal("relo: bad section");
		curr = outrelo.or_addr;
		curr += outsect[outrelo.or_sect].os_base;
		if (curr < base || curr >= stop)
			fatal("relo: bad address");
		curr -= base;
		if (curr & 1)
			fatal("relo: odd address");
		curr >>= 1;
		byt = (unsigned int)(curr >> 3);
		bit = 1 << ((int)curr & 7);
		if (ptr[byt] & bit)
			fatal("relo: twice on same address");
		ptr[byt] |= bit;
	}
	/*
         * read relocation, modify to GEMDOS format, and write.
         * Only longs can be relocated.
         *
         * The GEMDOS format starts with a long L: the offset to the
         * beginning of text for the first long to be relocated.
         * If L==0 then no relocations have to be made.
         *
         * The long is followed by zero or more bytes. Each byte B is
         * processed separately, in one of the following ways:
         *
         * B==0:
         *      end of relocation
         * B==1:
         *      no relocation, but add 254 to the current offset
         * B==0bWWWWWWW0:
         *      B is added to the current offset and the long addressed
         *      is relocated. Note that 00000010 means 1 word distance.
         * B==0bXXXXXXX1:
         *      illegal
         */
	last = 0;
	for (byt = 0; byt < len; byt++) {
		if (ptr[byt] == 0)
			continue;
		for (bit = 0; bit < 8; bit++) {
			if ((ptr[byt] & (1<<bit)) == 0)
				continue;
			curr = ((long)byt << 3) + bit;
			curr <<= 1;
			curr += base;
			if (last == 0)
				putlong(curr, stdout);
			else {
				while (curr - last > 255) {
					if (putc(1, stdout) == EOF)
						wrerr();
					last += 254;
				}
				if (putc((int)(curr - last), stdout) == EOF)
					wrerr();
			}
			last = curr;
		}
	}
	if (last == 0)
		putlong(last, stdout);
	else {
		if (putc(0, stdout) == EOF)
			wrerr();
	}
	free(ptr);
}

long
chmem(str, old)
char *str;
long old;
{
        register long num, new = 0;

        num = atol(str+1);
        if (num == 0)
                fatal("bad chmem amount %s", str+1);
        switch (str[0]) {
        case '-':
                new = old - num; break;
        case '+':
                new = old + num; break;
        case '=':
                new = num; break;
        }
        return(new);
}

#ifdef __STDC__
void fatal(char *s, ...)
{
	va_list args;

	va_start(args, s);
	fprintf(stderr, "%s: ", program);
	vfprintf(stderr, s, args);
	fprintf(stderr, "\n");
	va_end(args);
	if (output_file)
		unlink(output_file);
	exit(-1);
}
#else
/* VARARGS1 */
void fatal(s, a1, a2, a3, a4, a5)
	char	*s;
{
	fprintf(stderr, "%s: ", program);
	fprintf(stderr, s, a1, a2, a3, a4, a5);
	fprintf(stderr, "\n");
	if (output_file)
		unlink(output_file);
	exit(-1);
}
#endif

void rderr()
{
	fatal("read error");
}

void wrerr()
{
	fatal("write error");
}

void getofmt(p, s, f)
register char	*p;
register char	*s;
register FILE	*f;
{
	register i;
	register long l;

	for (;;) {
		switch (*s++) {
/*		case '0': p++; continue; */
		case '1':
			*p++ = getc(f);
			continue;
		case '2':
			i = getc(f);
			i |= (getc(f) << 8);
			*((short *)p) = i; p += sizeof(short);
			continue;
		case '4':
			l = (long)getc(f);
			l |= ((long)getc(f) << 8);
			l |= ((long)getc(f) << 16);
			l |= ((long)getc(f) << 24);
			*((long *)p) = l; p += sizeof(long);
			continue;
		default:
			fatal("bad getofmt");
		case '\0':
			break;
		}
		break;
	}
	if (feof(f) || ferror(f))
		rderr();
}

void putlong(l, f)
long		l;
register FILE	*f;
{
	putc((int)(l>>24), f);
	putc((int)(l>>16), f);
	putc((int)(l>>8 ), f);
	putc((int)(l    ), f);
	if (ferror(f))
		wrerr();
}
