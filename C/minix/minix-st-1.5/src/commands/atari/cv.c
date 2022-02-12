/*
 * (c) copyright 1988 by the Vrije Universiteit, Amsterdam, The Netherlands.
 * See the copyright notice in the file "../Copyright".
 */
/*
 * Convert ACK a.out file to ST-Minix object format.
 */

#ifdef UNIX
#include <stdio.h>
#include "../../include/a.out.h"
#undef	S_ABS	/* avoid collision */
#include "out.h"
#else
#include <sys/types.h>
#include <stdlib.h>
#include <stdio.h>
#include <a.out.h>
#undef	S_ABS	/* avoid collision */
#include <out.h>
#endif

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

main(argc, argv)
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
	if (argc != 3)
		fatal("Usage: %s [-R] [+-= amount] <ACK object> <MINIX-ST object>", argv[0]);

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

emit_head()
{
	register	i;
	long		mh[8];
	long		stack;
	long		chmem();

	mh[0] = 0x04100301L;
	mh[1] = 0x00000020L;
	mh[2] = outsect[TXTSEG].os_size + outsect[ROMSEG].os_size;
	mh[3] = outsect[DATSEG].os_size;
	mh[4] = outsect[BSSSEG].os_size;
	mh[5] = 0;
	stack = 0x00010000L - (mh[3] + mh[4]);
	if ((mh[0] & 0x00200000L) == 0)		/* not SEPARATE */
		stack -= mh[2];
	while (stack < 0)
		stack += 0x00010000L;
	if (chmemstr)
		stack = chmem(chmemstr, stack);
	fprintf(stderr, "%ld bytes assigned to stack+malloc area\n", stack);
	mh[6] = stack + (mh[3] + mh[4]);
	if ((mh[0] & 0x00200000L) == 0)		/* not SEPARATE */
		mh[6] += mh[2];
	mh[7] = outhead.oh_nname * (long) sizeof(struct nlist);
	for (i = 0; i < 8; i++)
		putlong(mh[i], stdout);
}

follows(segb, sega)
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
 * Transfer the emitted byted from one file to another.
 */
emit_sect(seg)
{
	register struct outsect *sp = &outsect[seg];
	register long		sz = sp->os_flen;
	register int		c;

	fseek(stdin, sp->os_foff, 0);
	for (sz = sp->os_flen; sz > 0; sz--) {
		c = getc(stdin);
		if (c == EOF)
			rderr();
		c = putc(c, stdout);
		if (c == EOF)
			wrerr();
	}
	for (sz = sp->os_size - sp->os_flen; sz > 0; sz--) {
		c = putc(0, stdout);
		if (c == EOF)
			wrerr();
	}
}

emit_syms()
{
	register unsigned short nrsyms;
	struct outname nbuf;
	struct nlist alist;
	unsigned readcount = outhead.oh_nchar;
	long fi_to_co;
	char *cbufp;
	register int sclass;
	static char segment[] = { N_TEXT, N_TEXT, N_DATA, N_BSS, N_BSS };

    if (readcount != outhead.oh_nchar || (cbufp = (char *)malloc(readcount)) == NULL) {
    	fprintf(stderr, "cv: out of memory\n");
    	exit(-1);
    }

    fseek(stdin, OFF_CHAR(outhead), 0);
	fread(cbufp, 1, readcount, stdin);
	fi_to_co = (long)cbufp - OFF_CHAR(outhead);
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
}

emit_relo()
{
	register char	*ptr;
	register int	len;
	register int	bit;
	register int	byt;
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
	len = (int)(((stop - base) + 15) / 16);
	if (len != (((stop - base) + 15) / 16))
		fatal("relo: span too big");
	ptr = calloc(len, 1);
	if (ptr == NULL)
		fatal("out of memory");
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
		byt = (int)(curr >> 3);
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
        register long num, new;
        long atol();

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

/* VARARGS1 */
fatal(s, a1, a2, a3, a4, a5)
	char	*s;
{
	fprintf(stderr, "%s: ", program);
	fprintf(stderr, s, a1, a2, a3, a4, a5);
	fprintf(stderr, "\n");
	if (output_file)
		unlink(output_file);
	exit(-1);
}

rderr()
{
	fatal("read error");
}

wrerr()
{
	fatal("write error");
}

getofmt(p, s, f)
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

putlong(l, f)
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
