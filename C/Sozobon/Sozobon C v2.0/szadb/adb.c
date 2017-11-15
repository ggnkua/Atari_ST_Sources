/* Copyright (c) 1990,91 by Sozobon, Limited.  Authors: Johann Ruegg, Don Dugger
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 *
 *	adb.c
 */

#include <setjmp.h>
#include "adb.h"

#define IN_ADB
#include "lang.h"

#define CNTLC	3
#define CNTLS	0x13
#define CNTLW	0x17

struct file binary;

long dot;
int dotoff;
long olddot;

#define DOT	(dot+dotoff)

int dotset;
long maxoff = 256;
int ibase = 16;

int lastc = 0;
char sign = 0;

unsigned long regbuf[19];

struct regs regs[] = {
	"pc",	&regbuf[16],
	"sr",	&regbuf[17],
	"xsp",	&regbuf[18],
	"d0",	&regbuf[0],
	"d1",	&regbuf[1],
	"d2",	&regbuf[2],
	"d3",	&regbuf[3],
	"d4",	&regbuf[4],
	"d5",	&regbuf[5],
	"d6",	&regbuf[6],
	"d7",	&regbuf[7],
	"a0",	&regbuf[8],
	"a1",	&regbuf[9],
	"a2",	&regbuf[10],
	"a3",	&regbuf[11],
	"a4",	&regbuf[12],
	"a5",	&regbuf[13],
	"a6",	&regbuf[14],
	"sp",	&regbuf[15],
	"", 0,
};

#define NREGS	19

jmp_buf jmpb, trp_buf;

_main()
{
	extern int _argc;
	extern char **_argv;

	main(_argc, _argv);
	exit(0);
}

main(argc, argv)
int argc;
char *argv[];
{
	char *cp;
	extern long ossp;

	winopen();
	binary.symptr = 0;
	binary.flags = 0;
	if (argc != 2) {
		prtf("Usage: adb binary\n");
		seeerr();
		exit(1);
	}
	binary.name = argv[1];

	if ((binary.fid = open(binary.name, 0)) < 0) {
/*		prtf("%s:cannot open\n", binary.name);	*/
		prtf(M1, binary.name);
		seeerr();
		exit(2);
	}
	if (setobj(&binary) != 0) {
/*		prtf("%s:bad format\n", binary.name);	*/
		prtf(M2, binary.name);
		seeerr();
		exit(3);
	}
	if (loadpcs() != 0) {
/*		prtf("%s:bad pexec\n", binary.name);	*/
		prtf(M3, binary.name);
		seeerr();
		exit(4);
	}
	close(binary.fid);
	relsym();
	vects();
/*	prt("Szadb version 2.0 (english)\n");	*/
	prt(M4);
	if (setjmp(trp_buf)) {
		seeerr();
		exit(0);
	}
	adb();
}

exit(n)
{
	oldvects();
	winclose();
	_exit(n);
}

seeerr()
{
/*	prt("(hit any key)");	*/
	prt(M5);
	gemdos(7);
}

setobj(fp)
struct file *fp;
{
	struct fheader hdr;

	if (read(fp->fid, &hdr, sizeof(hdr)) != sizeof(hdr))
		return -1;
	if (hdr.magic != MAGIC)
		return -1;
	if (hdr.ssize) {
		lseek(fp->fid, hdr.tsize + hdr.dsize, 1);
		return setsym(fp, (int)(hdr.ssize/sizeof(struct filsym)));
	}
	return 0;
}

adb()
{
	int cmddol(), cmdcol(), cmdprt(), cmdwrt(), cmdsreg(), null();
	long getn(), getdot();
	long expr();
	int intr();
	register int c, lc, count;
	int (*f)();
	long (*g)();
	char fmt[128];

	f = cmdprt;
	g = getdot;
	lc = '=';
	dot = 0;
	dotoff = 0;
	setjmp(jmpb);

	for (;;) {
		prt("> ");
		dotoff = 0;
		c = peekc();
		if (type(c) & (ALPHANUM | SPECX)) {
			dot = expr();
			olddot = dot;
			dotset = 1;
		} else
			dotset = 0;
		if (peekc() == ',') {
			nb();
			count = expr();
		} else
			count = 1;

		switch (c = nb()) {
		case '>':
			f = cmdsreg;
			break;
		case '$':
			c = nb();
			f = cmddol;
			break;
		case ':':
			c = nb();
			f = cmdcol;
			break;
		case '?':
		case '/':
			g = getn;
			switch (peekc()) {

			case 'w':
			case 'W':
				f = cmdwrt;
				break;
			default:
				f = cmdprt;
				getfmt(fmt);
			case '\n':
				f = cmdprt;
				break;

			}
			break;
		case '=':
			f = cmdprt;
			g = getdot;
			if (peekc() != '\n')
				getfmt(fmt);
			break;
		case '\r':
		case '\n':
			c = lc;
			break;
		default:
			f = null;
			count = 1;
			break;
		}

		dotoff = 0;
		if (f == cmdprt && g != getdot) {
			prtad(DOT);
			putchr(':');
			putchr('\n');
		}
		while (count--) {
			(*f)(c, fmt, g);
			if (chkbrk())
				break;
		}
		if (f == cmdprt && g != getdot)
			dot += dotoff;
		lc = c;
		while (getchr() != '\n')
			;
	}
}

#define LINESZ	80
static char lbuf[LINESZ+1];
static int lb_cur, lb_fill;

getchr()
{
	char c;

	if (lastc) {
		c = lastc;
		lastc = 0;
		return c;
	}

	if (lb_cur >= lb_fill)
		getline();
	c = lbuf[lb_cur++];
	return c;
}

getline()
{
	char c;

	lb_fill = lb_cur = 0;
	while (lb_fill < LINESZ) {
		c = getachr();
		if (c == '\b') {
			if (lb_fill) {
				putchr(c);
				lb_fill--;
			}
		} else
			lbuf[lb_fill++] = c;
		if (c == '\n')
			return;
	}
	lbuf[lb_fill++] = '\n';
	return;
}

getachr()
{
	long gemdos(), l;
	register int c;

again:
	l = gemdos(7);

	if (l == 0x620000L) {
		help();
		goto again;
	}
	
	c = l & 0xff;
	if (c == CNTLW) {
		winswtch();
		c = gemdos(7);
		winswtch();
		goto again;
	} else if (c == CNTLC || c == CNTLS)
		goto again;

	if (c == '\r')
		c = '\n';
	if (c != '\b')	/* getline will echo \b if not at sol */
		putchr(c);

	return(c);
}

chkbrk()
{
	char c;

	if (gemdos(11) == 0)	/* any chars pending ? */
		return 0;
	c = gemdos(7) & 0xff;
	if (c == CNTLC)
		return 1;
	else if (c == CNTLS) {
		c = gemdos(7) & 0xff;
		if (c == CNTLC)
			return 1;
	}
	return 0;
}

pushc(c)
int c;
{

	lastc = c;
	return(c);
}

peekc()
{

	return(pushc(nb()));
}

nb()
{
	register int c;

	while ((c = getchr()) == ' ' || c == '\t')
		;
	if (c == '\n')
		pushc(c);
	return(c);
}

type(c)
char c;
{

	if (c >= '0' && c <= '9')
		return(NUMERIC);
	if (c >= 'a' && c <= 'f')
		return(HEX);
	if (c >= 'A' && c <= 'F')
		return(HEX);
	if (c >= 'g' && c <= 'z')
		return(ALPHA);
	if (c >= 'G' && c <= 'Z')
		return(ALPHA);
	if (c == '_')
		return(ALPHA);
	switch (c) {
	case '$':
	case ':':
	case '?':
	case '/':
	case '=':
	case ',':
	case '>':
	case '\r':
	case '\n':
		return (SPECCMD);
	}
	return(SPECX);
}

long
expr()
{
	long term();
	long r;
	int c;

	r = term();
	for (;;)
		switch (c = nb()) {
		case '+':
			r += term();
			break;
		case '-':
			r -= term();
			break;
		case '*':
			r *= term();
			break;
		case '%':
			r /= term();
			break;
		case '&':
			r &= term();
			break;
		case '|':
			r |= term();
			break;
		case ')':
		default:
			pushc(c);
			return(r);
		}
}

long
term()
{
	long n, getn();
	register int c, base;
	char *cp, buf[NAMEMAX+1];
	struct symbol *sp, *findnam();
	struct regs *rp, *findreg();

	if ((c = nb()) == '(') {
		n = expr();
		if (nb() != ')')
			error(UNBAL);
		return(n);
	} else if (c == '\'') {
		n = 0;
		while ((c = getchr()) != '\'')
			if (c == '\n') {
				pushc(c);
				break;
			} else
				n = (n << 8) | c;
		return(n);
	} else if (c == '-') {
		n = term();
		return -n;
	} else if (c == '~') {
		n = term();
		return ~n;
	} else if (c == '<') {
		cp = buf;
		while (type(c = getchr()) & ALPHANUM)
			*cp++ = c;
		*cp = '\0';
		pushc(c);
		if (rp = findreg(buf))
			return *rp->value;
		error(BADRNAME);
	} else if (c == '*') {
		n = term();
		n = getn(n, 4);
		return n;
	} else if (c == '@') {
		n = term();
		n = getn(n, 2);
		return n;
	} else if (c == '.') {
		return dot;
	} else if (c == '&') {
		return olddot;
	} else if (type(c) & ALPHAONLY) {
		cp = buf;
		*cp++ = '_';
		*cp++ = c;
		while (type(c = getchr()) & ALPHANUM)
			*cp++ = c;
		*cp = '\0';
		pushc(c);
		if (sp = findnam(buf + 1, binary.symptr))
			return(sp->value);
		else if (sp = findnam(buf, binary.symptr))
			return(sp->value);
		error(BADNAME);
	}
	n = 0;
	base = ibase;
	if (c == '0') {
		base = 8;
		switch (pushc(getchr())) {
		case 'x':
			base += 6;
		case 't':
			base += 2;
		case 'o':
			getchr();
			c = getchr();
			break;
		default:
			base = ibase;
			break;
		}
	}
	while (type(c) & HEXDIG) {
		if (c >= 'a' && c <= 'f')
			c -= 'a' - '9' - 1;
		if (c >= 'A' && c <= 'F')
			c -= 'A' - '9' - 1;
		n = (n * base) + (c - '0');
		c = getchr();
	}
	pushc(c);
	return(n);
}

null(c, fmt, get)
int c;
char *fmt;
long (*get)();
{
/*	prtf("unknown command\n");	*/
	prtf(M6);
	return(0);
}

cmddol(c, fmt, get)
int c;
char *fmt;
long (*get)();
{
	extern struct regs regs[];
	extern struct bpt bpt[];
	int i;

	switch (c) {
	case 'q':
		exit(0);
	case 'd':
		ibase = 10;
		break;
	case 'o':
		ibase = 8;
		break;
	case 'x':
		ibase = 16;
		break;
	case 's':
		maxoff = dot;
		break;
	case 'e':
		prtstbl(binary.symptr);
		break;
	case 'b':
		for (i = 0; i < MAXBPTS; i++)
			if (bpt[i].flag & BP_VALID)
				prbpt(bpt[i].addr);
		break;
	case 'r':
		prregs();
		prbpt(*(regs[PC].value));
		break;
	case 'p':
		prbasepg();
		break;
	case 'c':
	case 'C':
		prstack(c == 'C');
		break;
	default:
		error(UNKNOWN);
		break;
	}
	return(0);
}

prregs()
{
	struct regs *rp;

	prtreg(&regs[PC]);
	prtreg(&regs[XSP]);
	prt_sr();
	optnl();

	rp = &regs[D0];
	while (rp < &regs[NREGS])
		prtreg(rp++);
	optnl();
}

prtreg(rp)
struct regs *rp;
{
	int i;

	i = strlen(rp->name);
	prt(rp->name);
	prtn(*(rp->value), 15-i);
	prt("    ");
	return;
}

prtstbl(sp)
struct symbol *sp;
{
	while (sp) {
		prt(sp->name);
		prt(": ");
		prtn(sp->value, 0);
		putchr('\n');
		sp = sp->next;
		if (chkbrk())
			return;
	}
	return;
}

cmdwrt(c, fmt, get)
char c;
char *fmt;
long (*get)();
{
	long l;

	c = nb();
	l = expr();
	putn(l, DOT, c == 'w' ? 2 : 4, 1);
	return;
}

cmdprt(c, fmt, get)
int c;
char *fmt;
long (*get)();
{
	register int c1;
	long *ip;
	struct symbol *sp;
	long getdot();
	int rep, incr, oldoff;

	incr = 0;
	while (c = *fmt++) {
		if (c >= '0' && c <= '9') {
			rep = c - '0';
			while ((c = *fmt++) >= '0' && c <= '9')
				rep = 10*rep + (c - '0');
		} else
			rep = 1;

		if (c == 't')
			tab(rep);
		else if (c == '^')
			dotoff -= rep*incr;
		else
		while (rep--) {

		oldoff = dotoff;

		switch (c) {
		case 'a':
		case 'p':
			prtad(DOT);
			if (c == 'a')
				putchr(':');
			tab(20);
			break;
		case 'i':
			if (get == getdot)
				error(BADCMD);
			puti();
			putchr('\n');
			break;
		case 'o':
			puto((*get)(DOT, 2) & 0xffff, 9);
			break;
		case 'O':
			puto((*get)(DOT, 4), 19);
			break;
		case 'd':
			putd((*get)(DOT, 2), 9);
			break;
		case 'D':
			putd((*get)(DOT, 4), 19);
			break;
		case 'x':
			putx((*get)(DOT, 2) & 0xffff, 9);
			break;
		case 'X':
			putx((*get)(DOT, 4), 19);
			break;
		case 'b':
			puto((*get)(DOT, 1) & 0xff, 4);
			break;
		case 'c':
			putchr((char)(*get)(DOT, 1));
			break;
		case 'S':
		case 's':
			if (get == getdot)
				error(BADCMD);
			while (c1 = (char)(*get)(DOT, 1)) {
				if ((c1 < ' ' || c1 > 127) && (c == 'S'))
					c1 = '.';
				putchr(c1);
			}
			break;
		case '"':
			while ((c = *fmt++) != '"' && c)
				putchr(c);
			if (c != '"')
				fmt--;
			break;
		case 'r':
			putchr(' ');
			break;
		case 'n':
			putchr('\n');
			break;
		case '+':
			dotoff++;
			break;
		case '-':
			dotoff--;
			break;
		default:
			putchr(c);
			break;
		}

		incr = dotoff - oldoff;

		}
	}
	optnl();
	return;
}

error(why)
{

	while (getchr() != '\n')
		;
	prt(errwhy[why]);
	longjmp(jmpb, 1);
}

prtad(where)
long where;
{
	struct symbol *sp, *findsym();

	if ((sp = findsym(where, binary.symptr)))
			prtsym(where, sp);
		else
			prtn(where, 0);
	return;
}

prt_sr()
{
	long sr;
	int i;

	sr = *regs[SR].value;
	prtf("sr %I -> ", sr);
	if (sr & 0x2000)
		prt("Supv");
	else
		prt("User");

	prtf(" pri%I ", (sr>>8) & 7);

	for (i=4; i>=0; i--)
		if (sr & (1<<i))
			putchr("CVZNX"[i]);
	putchr('\n');
}

struct regs *
findreg(s)
char *s;
{
	struct regs *rp;

	for (rp = regs; rp->value; rp++)
		if (strcmp(s, rp->name) == 0)
			return rp;
	return 0;
}
