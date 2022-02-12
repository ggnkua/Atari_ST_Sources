/* roff - text justifier		Author: George L. Sicherman */

/*
 *	roff - C version.
 *	the Colonel.  19 May 1983.
 *
 *	Copyright 1983 by G. L. Sicherman.
 *	You may use and alter this software freely for noncommercial ends
 *	so long as you leave this message alone.
 *
 *	Fix by Tim Maroney, 31 Dec 1984.
 *	.hc implemented, 8 Feb 1985.
 *	Fix to hyphenating with underlining, 12 Feb 1985.
 *	Fixes to long-line hang and .bp by Dave Tutelman, 30 Mar 1985.
 *	Fix to centering valve with long input lines, 4 May 1987.
 */

#include <sys/types.h>
#include <sys/stat.h>
#include <termios.h>
#include <signal.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <stdio.h>

#define SUFTAB	"/usr/lib/suftab"
#define TXTLEN	(o_pl-o_m1-o_m2-o_m3-o_m4-2)
#define IDTLEN	(o_ti>=0?o_ti:o_in)
#define MAXMAC	64
#define MAXDEPTH 10
#define MAXLENGTH 255
#define UNDERL	'\200'

char cumbuf[BUFSIZ];

char spacechars[] = " \t\n";
int sflag, hflag, startpage, stoppage;
char holdword[MAXLENGTH], *holdp;
char assyline[MAXLENGTH];
int assylen;
char ehead[100], efoot[100], ohead[100], ofoot[100];
struct macrotype {
  char mname[3];
  long int moff;
} macro[MAXMAC];
int n_macros;
int depth;
int adjtoggle;
int isrequest = 0;
char o_tr[40][2];		/* OUTPUT TRANSLATION TABLE */
int o_cc = '.';			/* CONTROL CHARACTER */
int o_hc = -1;			/* HYPHENATION CHARACTER */
int o_tc = ' ';			/* TABULATION CHARACTER */
int o_in = 0;			/* INDENT SIZE */
int o_ix = -1;			/* NEXT INDENT SIZE */
int o_ta[20] = {
	9, 17, 25, 33, 41, 49, 57, 65, 73, 81, 89, 97, 105,
	113, 121, 129, 137, 145, 153, 161};
int n_ta = 20;			/* #TAB STOPS */
int o_ll = 65, o_ad = 1, o_po = 0, o_ls = 1, o_ig = 0, o_fi = 1;
int o_pl = 66, o_ro = 0, o_hx = 0, o_bl = 0, o_sp = 0, o_sk = 0;
int o_ce = 0, o_m1 = 2, o_m2 = 2, o_m3 = 1, o_m4 = 3, o_ul = 0;
int o_li = 0, o_n1 = 0, o_n2 = 0, o_bp = -1, o_hy = 1;
int o_ni = 1;			/* LINE-NUMBER INDENT */
int o_nn = 0;			/* #LINES TO SUPPRESS NUMBERING */
int o_ti = -1;			/* TEMPORARY INDENT */
int page_no = -1;
int line_no = 9999;
int n_outwords;
FILE *File, *Macread, *Macwrite;
FILE *Save;
long int teller[MAXDEPTH];
char *request[] = {
	   "ad", "ar", "bl", "bp", "br", "cc", "ce", "de",
	 "ds", "ef", "eh", "fi", "fo", "hc", "he", "hx", "hy", "ig",
	   "in", "ix", "li", "ll", "ls", "m1", "m2", "m3", "m4",
	 "n1", "n2", "na", "ne", "nf", "ni", "nn", "nx", "of", "oh",
	 "pa", "pl", "po", "ro", "sk", "sp", "ss", "ta", "tc", "ti",
	   "tr", "ul", 0};
char *mfilnam = "/tmp/rtmXXXXXX";
int c;				/* LAST CHAR READ */
struct termios tty;

_PROTOTYPE(int main, (int argc, char **argv));
_PROTOTYPE(void mesg, (int f));
_PROTOTYPE(void readfile, (void));
_PROTOTYPE(int readline, (void));
_PROTOTYPE(void bumpword, (void));
_PROTOTYPE(void dehyph, (char *s));
_PROTOTYPE(int reallen, (char *s));
_PROTOTYPE(void tabulate, (void));
_PROTOTYPE(int readreq, (void));
_PROTOTYPE(void snset, (int *par));
_PROTOTYPE(int tread, (char *s));
_PROTOTYPE(void nread, (int *i));
_PROTOTYPE(int snread, (int *i, int *s, int sdef));
_PROTOTYPE(int cread, (int *k));
_PROTOTYPE(void defmac, (void));
_PROTOTYPE(void openmac, (void));
_PROTOTYPE(int copyline, (void));
_PROTOTYPE(void submac, (int r));
_PROTOTYPE(void endmac, (void));
_PROTOTYPE(void do_ta, (void));
_PROTOTYPE(void do_tr, (void));
_PROTOTYPE(void do_nx, (void));
_PROTOTYPE(int skipsp, (void));
_PROTOTYPE(void writebreak, (void));
_PROTOTYPE(void blankline, (void));
_PROTOTYPE(void writeline, (int adflag, int flushflag));
_PROTOTYPE(void fillline, (void));
_PROTOTYPE(void insrt, (int p));
_PROTOTYPE(void newpage, (void));
_PROTOTYPE(void beginpage, (void));
_PROTOTYPE(void endpage, (void));
_PROTOTYPE(void blankpage, (void));
_PROTOTYPE(void waitawhile, (void));
_PROTOTYPE(void nix, (int sig));
_PROTOTYPE(void writetitle, (char *t));
_PROTOTYPE(char *pgform, (void));
_PROTOTYPE(int titlen, (char *t, int c, int k));
_PROTOTYPE(void spits, (char *s));
_PROTOTYPE(void spit, (int c));
_PROTOTYPE(int suck, (void));
_PROTOTYPE(char *strhas, (char *p, int c));
_PROTOTYPE(char *strend, (char *p));
_PROTOTYPE(int isspace, (int c));
_PROTOTYPE(int isalnum, (int c));
_PROTOTYPE(int isdigit, (int c));
_PROTOTYPE(int islegal, (int c));
_PROTOTYPE(void bomb, (void));

int main(argc, argv)
int argc;
char **argv;
{
  if (!isatty(1)) setbuf(stdout, cumbuf);
  while (--argc) switch (**++argv) {
	    case '+':	startpage = atoi(++*argv);	break;
	    case '-':
		++*argv;
		if (isdigit(**argv))
			stoppage = atoi(*argv);
		else
			switch (**argv) {
			    case 's':	sflag++;	break;
			    case 'h':	hflag++;	break;
			    default:	bomb();
			}
		break;
	    default:
		argc++;
		goto endargs;
	}
endargs:
  if (sflag) tcgetattr(0, &tty);
  mesg(0);			/* BLOCK OUT MESSAGES */
  assylen = 0;
  assyline[0] = '\0';
  if (!argc) {
	File = stdin;
	readfile();
  } else
	while (--argc) {
		File = fopen(*argv, "r");
		if (NULL == File) {
			fprintf(stderr, "roff: cannot read %s\n", *argv);
			exit(1);
		}
		readfile();
		fclose(File);
		argv++;
	}
  writebreak();
  endpage();
  for (; o_sk; o_sk--) blankpage();
  mesg(1);			/* ALLOW MESSAGES */
  return(0);
}

void mesg(f)
int f;
{
  static int mode;
  struct stat cbuf;

  if (!isatty(1)) return;
  if (!f) {
	fstat(1,&cbuf);
	mode = cbuf.st_mode;
	chmod(ttyname(1),mode & ~022);
  }
  else chmod(ttyname(1),mode);
/* ------- end of mesg */
}

void readfile()
{
  while (readline()) {
	if (isrequest) continue;
	if (o_ce || !o_fi) {
		if (assylen)
			writeline(0, 1);
		else
			blankline();
		if (o_ce) o_ce--;
	}
  }
}

int readline()
{
  int startline, doingword;
  isrequest = 0;
  startline = 1;
  doingword = 0;
  c = suck();
  if (c == '\n') {
	o_sp = 1;
	writebreak();
	goto out;
  } else if (isspace(c))
	writebreak();
  for (;;) {
	if (c == EOF) {
		if (doingword) bumpword();
		break;
	}
	if (c != o_cc && o_ig) {
		while (c != '\n' && c != EOF) c = suck();
		break;
	}
	if (isspace(c) && !doingword) {
		startline = 0;
		switch (c) {
		    case ' ':
			assyline[assylen++] = ' ';
			break;
		    case '\t':	tabulate();	break;
		    case '\n':	goto out;
		}
		c = suck();
		continue;
	}
	if (isspace(c) && doingword) {
		bumpword();
		if (c == '\t')
			tabulate();
		else if (assylen)
			assyline[assylen++] = ' ';
		doingword = 0;
		if (c == '\n') break;
	}
	if (!isspace(c)) {
		if (doingword)
			*holdp++ = o_ul ? c | UNDERL : c;
		else if (startline && c == o_cc && !o_li) {
			isrequest = 1;
			return readreq();
		} else {
			doingword = 1;
			holdp = holdword;
			*holdp++ = o_ul ? c | UNDERL : c;
		}
	}
	startline = 0;
	c = suck();
  }
out:
  if (o_ul) o_ul--;
  if (o_li) o_li--;
  return c != EOF;
}

/*
 *	bumpword - add word to current line.
 */

void bumpword()
{
  char *hc;
  *holdp = '\0';
/*
 *	Tutelman's fix #1, modified by the Colonel.
 */
  if (!o_fi || o_ce) goto giveup;
/*
 *	We use a while-loop in case of ridiculously long words with
 *	multiple hyphenation indicators.
 */
  if (assylen + reallen(holdword) > o_ll - IDTLEN) {
	if (!o_hy)
		writeline(o_ad, 0);
	else
		while (assylen + reallen(holdword) > o_ll - IDTLEN) {
/*
 *	Try hyphenating it.
 */
			if (o_hc && strhas(holdword, o_hc)) {
/*
 *	There are hyphenation marks.  Use them!
 */
				for (hc = strend(holdword); hc >= holdword; hc--) {
					if ((*hc & ~UNDERL) != o_hc)
						continue;
					*hc = '\0';
					if (assylen + reallen(holdword) + 1 >
					    o_ll - IDTLEN) {
						*hc = o_hc;
						continue;
					}

/*
 *	Yay - it fits!
 */
					dehyph(holdword);
					strcpy(&assyline[assylen], holdword);
					strcat(assyline, "-");
					assylen += strlen(holdword) + 1;
					strcpy(holdword, ++hc);
					break;	/* STOP LOOKING */
				}	/* for */
/*
 *	It won't fit, or we've succeeded in breaking the word.
 */
				writeline(o_ad, 0);
				if (hc < holdword) goto giveup;
			} else {
/*
 *	If no hyphenation marks, give up.
 *	Let somebody else implement it.
 */
				writeline(o_ad, 0);
				goto giveup;
			}
		}		/* while */
  }
giveup:
/*
 *	remove hyphenation marks, even if hyphenation is disabled.
 */
  if (o_hc) dehyph(holdword);
  strcpy(&assyline[assylen], holdword);
  assylen += strlen(holdword);
  holdp = holdword;
}

/*
 *	dehyph - remove hyphenation marks.
 */

void dehyph(s)
char *s;
{
  char *t;
  for (t = s; *s; s++)
	if ((*s & ~UNDERL) != o_hc) *t++ = *s;
  *t = '\0';
}

/*
 *	reallen - length of a word, excluding hyphenation marks.
 */

int reallen(s)
char *s;
{
  register n;
  n = 0;
  while (*s) n += (o_hc != (~UNDERL & *s++));
  return n;
}

void tabulate()
{
  int j;
  for (j = 0; j < n_ta; j++)
	if (o_ta[j] - 1 > assylen + IDTLEN) {
		for (; assylen + IDTLEN < o_ta[j] - 1; assylen++)
			assyline[assylen] = o_tc;
		return;
	}

  /* NO TAB STOPS REMAIN */
  assyline[assylen++] = o_tc;
}

int readreq()
{
  char req[3];
  int r, s;
  if (skipsp()) return c != EOF;
  c = suck();
  if (c == EOF || c == '\n') return c != EOF;
  if (c == '.') {
	o_ig = 0;
	do
		(c = suck());
	while (c != EOF && c != '\n');
	if (depth) endmac();
	return c != EOF;
  }
  if (o_ig) {
	while (c != EOF && c != '\n') c = suck();
	return c != EOF;
  }
  req[0] = c;
  c = suck();
  if (c == EOF || c == '\n')
	req[1] = '\0';
  else
	req[1] = c;
  req[2] = '\0';
  for (r = 0; r < n_macros; r++)
	if (!strcmp(macro[r].mname, req)) {
		submac(r);
		goto reqflsh;
	}
  for (r = 0; request[r]; r++)
	if (!strcmp(request[r], req)) break;
  if (!request[r]) {
	do
		(c = suck());
	while (c != EOF && c != '\n');
	return c != EOF;
  }
  switch (r) {
      case 0:			/* ad */
	o_ad = 1;
	writebreak();
	break;
      case 1:			/* ar */	o_ro = 0;	break;
      case 2:			/* bl */
	nread(&o_bl);
	writebreak();
	break;
      case 3:			/* bp */
      case 37:			/* pa */
	c = snread(&r, &s, 1);
/*
 *	Tutelman's fix #2 - the signs were reversed!
 */
	if (s > 0)
		o_bp = page_no + r;
	else if (s < 0)
		o_bp = page_no - r;
	else
		o_bp = r;
	writebreak();
	if (line_no) {
		endpage();
		beginpage();
	}
	break;
      case 4:			/* br */	writebreak();	break;
      case 5:			/* cc */
	c = cread(&o_cc);
	break;
      case 6:			/* ce */
/*
 *	Fix to centering.  Set counter _after_ breaking!  --G.L.S.
 */
	nread(&r);
	writebreak();
	o_ce = r;
	break;
      case 7:			/* de */	defmac();	break;
      case 8:			/* ds */
	o_ls = 2;
	writebreak();
	break;
      case 9:			/* ef */
	c = tread(efoot);
	break;
      case 10:			/* eh */
	c = tread(ehead);
	break;
      case 11:			/* fi */
	o_fi = 1;
	writebreak();
	break;
      case 12:			/* fo */
	c = tread(efoot);
	strcpy(ofoot, efoot);
	break;
      case 13:			/* hc */
	c = cread(&o_hc);
	break;
      case 14:			/* he */
	c = tread(ehead);
	strcpy(ohead, ehead);
	break;
      case 15:			/* hx */	o_hx = 1;	break;
      case 16:			/* hy */	nread(&o_hy);	break;
      case 17:			/* ig */	o_ig = 1;	break;
      case 18:			/* in */
	writebreak();
	snset(&o_in);
	o_ix = -1;
	break;
      case 19:			/* ix */
	snset(&o_ix);
	if (!n_outwords) o_in = o_ix;
	break;
      case 20:			/* li */	nread(&o_li);	break;
      case 21:			/* ll */	snset(&o_ll);	break;
      case 22:			/* ls */	snset(&o_ls);	break;
      case 23:			/* m1 */	nread(&o_m1);	break;
      case 24:			/* m2 */	nread(&o_m2);	break;
      case 25:			/* m3 */	nread(&o_m3);	break;
      case 26:			/* m4 */	nread(&o_m4);	break;
      case 27:			/* n1 */	o_n1 = 1;	break;
      case 28:			/* n2 */	nread(&o_n2);	break;
      case 29:			/* na */
	o_ad = 0;
	writebreak();
	break;
      case 30:			/* ne */
	nread(&r);
	if (line_no + (r - 1) * o_ls + 1 > TXTLEN) {
		writebreak();
		endpage();
		beginpage();
	}
	break;
      case 31:			/* nf */
	o_fi = 0;
	writebreak();
	break;
      case 32:			/* ni */	snset(&o_ni);	break;
      case 33:			/* nn */	snset(&o_nn);	break;
      case 34:			/* nx */
	do_nx();
	c = '\n';		/* SO WE DON'T FLUSH THE FIRST LINE */
	break;
      case 35:			/* of */
	c = tread(ofoot);
	break;
      case 36:			/* oh */
	c = tread(ohead);
	break;
      case 38:			/* pl */	snset(&o_pl);	break;
      case 39:			/* po */	snset(&o_po);	break;
      case 40:			/* ro */	o_ro = 1;	break;
      case 41:			/* sk */	nread(&o_sk);	break;
      case 42:			/* sp */
	nread(&o_sp);
	writebreak();
	break;
      case 43:			/* ss */
	writebreak();
	o_ls = 1;
	break;
      case 44:			/* ta */	do_ta();	break;
      case 45:			/* tc */
	c = cread(&o_tc);
	break;
      case 46:			/* ti */
	writebreak();
	c = snread(&r, &s, 0);
	if (s > 0)
		o_ti = o_in + r;
	else if (s < 0)
		o_ti = o_in - r;
	else
		o_ti = r;
	break;
      case 47:			/* tr */	do_tr();	break;
      case 48:			/* ul */	nread(&o_ul);	break;
  }
reqflsh:
  while (c != EOF && c != '\n') c = suck();
  return c != EOF;
}

void snset(par)
int *par;
{
  int r, s;
  c = snread(&r, &s, 0);
  if (s > 0)
	*par += r;
  else if (s < 0)
	*par -= r;
  else
	*par = r;
}

int tread(s)
char *s;
{
  int leadbl;
  leadbl = 0;
  for (;;) {
	c = suck();
	if (c == ' ' && !leadbl) continue;
	if (c == EOF || c == '\n') {
		*s = '\0';
		return c;
	}
	*s++ = c;
	leadbl++;
  }
}

void nread(i)
int *i;
{
  int f;
  f = 0;
  *i = 0;
  if (!skipsp()) for (;;) {
		c = suck();
		if (c == EOF) break;
		if (isspace(c)) break;
		if (isdigit(c)) {
			f++;
			*i = *i * 10 + c - '0';
		} else
			break;
	}
  if (!f) *i = 1;
}

int snread(i, s, sdef)
int *i, *s, sdef;
{
  int f;
  f = *i = *s = 0;
  for (;;) {
	c = suck();
	if (c == EOF || c == '\n') break;
	if (isspace(c)) {
		if (f)
			break;
		else
			continue;
	}
	if (isdigit(c)) {
		f++;
		*i = *i * 10 + c - '0';
	} else if ((c == '+' || c == '-') && !f) {
		f++;
		*s = c == '+' ? 1 : -1;
	} else
		break;
  }
  while (c != EOF && c != '\n') c = suck();
  if (!f) {
	*i = 1;
	*s = sdef;
  }
  return c;
}

int cread(k)
int *k;
{
  int u;
  *k = -1;
  for (;;) {
	u = suck();
	if (u == EOF || u == '\n') return u;
	if (isspace(u)) continue;
	if (*k < 0) *k = u;
  }
}

void defmac()
{
  int i;
  char newmac[3], *nm;
  if (skipsp()) return;
  nm = newmac;
  if (!Macwrite) openmac();
  *nm++ = suck();
  c = suck();
  if (c != EOF && c != '\n' && c != ' ' && c != '\t') *nm++ = c;
  *nm = '\0';
  /* KILL OLD DEFINITION IF ANY */
  for (i = 0; i < n_macros; i++)
	if (!strcmp(newmac, macro[i].mname)) {
		macro[i].mname[0] = '\0';
		break;
	}
  macro[n_macros].moff = ftell(Macwrite);
  strcpy(macro[n_macros++].mname, newmac);
  while (c != EOF && c != '\n') c = suck();	/* FLUSH HEADER LINE */
  while (copyline());
  fflush(Macwrite);
}

void openmac()
{
  if (NULL == (Macwrite = fopen(mktemp(mfilnam), "w"))) {
	fprintf(stderr, "roff: cannot open temp file\n");
	exit(1);
  }
  Macread = fopen(mfilnam, "r");
  unlink(mfilnam);
}

int copyline()
{
  int n, first, second;
  if (c == EOF) {
	fprintf(Macwrite, "..\n");
	return 0;
  }
  n = 0;
  first = 1;
  second = 0;
  for (;;) {
	c = suck();
	if (c == EOF) {
		if (!first) putc('\n', Macwrite);
		return 0;
	}
	if (c == '\n') {
		putc('\n', Macwrite);
		return n != 2;
	}
	if (first && c == '.')
		n++;
	else if (second && n == 1 && c == '.')
		n++;
	putc(c, Macwrite);
	second = first;
	first = 0;
  }
}

void submac(r)
int r;
{
  while (c != EOF && c != '\n') c = suck();
  if (depth)
	teller[depth - 1] = ftell(Macread);
  else {
	Save = File;
	File = Macread;
  }
  depth++;
  fseek(Macread, macro[r].moff, 0);
}

void endmac()
{
  depth--;
  if (depth)
	fseek(Macread, teller[depth - 1], 0);
  else
	File = Save;
  c = '\n';
}

void do_ta()
{
  int v;
  n_ta = 0;
  for (;;) {
	nread(&v);
	if (v == 1)
		return;
	else
		o_ta[n_ta++] = v;
	if (c == '\n' || c == EOF) break;
  }
}

void do_tr()
{
  char *t;
  t = &o_tr[0][0];
  *t = '\0';
  if (skipsp()) return;
  for (;;) {
	c = suck();
	if (c == EOF || c == '\n') break;
	*t++ = c;
  }
  *t = '\0';
}

void do_nx()
{
  char fname[100], *f;
  f = fname;
  if (skipsp()) return;
  for (;;) switch (c = suck()) {
	    case EOF:
	    case '\n':
	    case ' ':
	    case '\t':
		if (f == fname) return;
		goto got_nx;
	    default:	*f++ = c;
	}
got_nx:
  fclose(File);
  *f = '\0';
  if (!(File = fopen(fname, "r"))) {
	fprintf(stderr, "roff: cannot read %s\n", fname);
	exit(1);
  }
}

int skipsp()
{
  for (;;) switch (c = suck()) {
	    case EOF:
	    case '\n':
		return 1;
	    case ' ':
	    case '\t':
		continue;
	    default:
		ungetc(c, File);
		return 0;
	}
}

void writebreak()
{
  int q;
  if (assylen) writeline(0, 1);
  q = TXTLEN;
  if (o_bl) {
	if (o_bl + line_no > q) {
		endpage();
		beginpage();
	}
	for (; o_bl; o_bl--) blankline();
  } else if (o_sp) {
	if (o_sp + line_no > q)
		newpage();
	else if (line_no)
		for (; o_sp; o_sp--) blankline();
  }
}

void blankline()
{
  if (line_no >= TXTLEN) newpage();
  if (o_n2) o_n2++;
  spit('\n');
  line_no++;
}

void writeline(adflag, flushflag)
int adflag, flushflag;
{
  int j, q;
  char lnstring[7];
  for (j = assylen - 1; j; j--) {
	if (assyline[j] == ' ')
		assylen--;
	else
		break;
  }
  q = TXTLEN;
  if (line_no >= q) newpage();
  for (j = 0; j < o_po; j++) spit(' ');
  if (o_n1) {
	if (o_nn) for (j = 0; j < o_ni + 4; j++)
			spit(' ');
	else {
		for (j = 0; j < o_ni; j++) spit(' ');
		sprintf(lnstring, "%3d ", line_no + 1);
		spits(lnstring);
	}
  }
  if (o_n2) {
	if (o_nn) for (j = 0; j < o_ni + 4; j++)
			spit(' ');
	else {
		for (j = 0; j < o_ni; j++) spit(' ');
		sprintf(lnstring, "%3d ", o_n2++);
		spits(lnstring);
	}
  }
  if (o_nn) o_nn--;
  if (o_ce) for (j = 0; j < (o_ll - assylen + 1) / 2; j++)
		spit(' ');
  else
	for (j = 0; j < IDTLEN; j++) spit(' ');
  if (adflag && !flushflag) fillline();
  for (j = 0; j < assylen; j++) spit(assyline[j]);
  spit('\n');
  assylen = 0;
  assyline[0] = '\0';
  line_no++;
  for (j = 1; j < o_ls; j++)
	if (line_no <= q) blankline();
  if (!flushflag) {
	if (o_hc) dehyph(holdword);
	strcpy(assyline, holdword);
	assylen = strlen(holdword);
	*holdword = '\0';
	holdp = holdword;
  }
  if (o_ix >= 0) o_in = o_ix;
  o_ix = o_ti = -1;
}

void fillline()
{
  int excess, j, s, inc, spaces;
  adjtoggle ^= 1;
  if (!(excess = o_ll - IDTLEN - assylen)) return;
  if (excess < 0) {
	fprintf(stderr, "roff: internal error #2 [%d]\n", excess);
	exit(1);
  }
  for (j = 2;; j++) {
	if (adjtoggle) {
		s = 0;
		inc = 1;
	} else {
		s = assylen - 1;
		inc = -1;
	}
	spaces = 0;
	while (s >= 0 && s < assylen) {
		if (assyline[s] == ' ')
			spaces++;
		else {
			if (0 < spaces && spaces < j) {
				insrt(s - inc);
				if (inc > 0) s++;
				if (!--excess) return;
			}
			spaces = 0;
		}
		s += inc;
	}
  }
}

void insrt(p)
int p;
{
  int i;
  for (i = assylen; i > p; i--) assyline[i] = assyline[i - 1];
  assylen++;
}

void newpage()
{
  if (page_no >= 0)
	endpage();
  else
	page_no = 1;
  for (; o_sk; o_sk--) blankpage();
  beginpage();
}

void beginpage()
{
  int i;
  if (sflag) waitawhile();
  for (i = 0; i < o_m1; i++) spit('\n');
  writetitle(page_no & 1 ? ohead : ehead);
  for (i = 0; i < o_m2; i++) spit('\n');
  line_no = 0;
}

void endpage()
{
  int i;
  for (i = line_no; i < TXTLEN; i++) blankline();
  for (i = 0; i < o_m3; i++) spit('\n');
  writetitle(page_no & 1 ? ofoot : efoot);
  for (i = 0; i < o_m4; i++) spit('\n');
  if (o_bp < 0)
	page_no++;
  else {
	page_no = o_bp;
	o_bp = -1;
  }
}

void blankpage()
{
  int i;
  if (sflag) waitawhile();
  for (i = 0; i < o_m1; i++) spit('\n');
  writetitle(page_no & 1 ? ohead : ehead);
  for (i = 0; i < o_m2; i++) spit('\n');
  for (i = 0; i < TXTLEN; i++) spit('\n');
  for (i = 0; i < o_m3; i++) spit('\n');
  writetitle(page_no & 1 ? ofoot : efoot);
  page_no++;
  for (i = 0; i < o_m4; i++) spit('\n');
  line_no = 0;
}

void waitawhile()
{
  tcflag_t oldflags; 
  if (isatty(0)) {
	oldflags = tty.c_lflag;
	tty.c_lflag &= ~ECHO;	/* DON'T ECHO THE RUBOUT */
	tcsetattr(0, TCSANOW, &tty);
  }
  signal(SIGINT, nix);
  pause();
  if (isatty(0)) {
	tty.c_lflag = oldflags;
	tcsetattr(0, TCSANOW, &tty);
  }
}

void nix(sig)
int sig;
{
}

void writetitle(t)
char *t;
{
  char d, *pst;
  int j, l, m, n;
  d = *t;
  if (o_hx || !d) {
	spit('\n');
	return;
  }
  pst = pgform();
  for (j = 0; j < o_po; j++) spit(' ');
  l = titlen(++t, d, strlen(pst));
  while (*t && *t != d) {
	if (*t == '%')
		spits(pst);
	else
		spit(*t);
	t++;
  }
  if (!*t) {
	spit('\n');
	return;
  }
  m = titlen(++t, d, strlen(pst));
  for (j = l; j < (o_ll - m) / 2; j++) spit(' ');
  while (*t && *t != d) {
	if (*t == '%')
		spits(pst);
	else
		spit(*t);
	t++;
  }
  if (!*t) {
	spit('\n');
	return;
  }
  if ((o_ll - m) / 2 > l)
	m += (o_ll - m) / 2;
  else
	m += l;
  n = titlen(++t, d, strlen(pst));
  for (j = m; j < o_ll - n; j++) spit(' ');
  while (*t && *t != d) {
	if (*t == '%')
		spits(pst);
	else
		spit(*t);
	t++;
  }
  spit('\n');
}

char *
 pgform()
{
  static char pst[11];
  int i;
  if (o_ro) {
	*pst = '\0';
	i = page_no;
	if (i >= 400) {
		strcat(pst, "cd");
		i -= 400;
	}
	while (i >= 100) {
		strcat(pst, "c");
		i -= 100;
	}
	if (i >= 90) {
		strcat(pst, "xc");
		i -= 90;
	}
	if (i >= 50) {
		strcat(pst, "l");
		i -= 50;
	}
	if (i >= 40) {
		strcat(pst, "xl");
		i -= 40;
	}
	while (i >= 10) {
		strcat(pst, "x");
		i -= 10;
	}
	if (i >= 9) {
		strcat(pst, "ix");
		i -= 9;
	}
	if (i >= 5) {
		strcat(pst, "v");
		i -= 5;
	}
	if (i >= 4) {
		strcat(pst, "iv");
		i -= 4;
	}
	while (i--) strcat(pst, "i");
  } else
	sprintf(pst, "%d", page_no);
  return pst;
}

int titlen(t, c, k)
char *t, c;
int k;
{
  int q;
  q = 0;
  while (*t && *t != c) q += *t++ == '%' ? k : 1;
  return q;
}

void spits(s)
char *s;
{
  while (*s) spit(*s++);
}

void spit(c)
char c;
{
  static int col_no, n_blanks;
  int ulflag;
  char *t;
  ulflag = c & UNDERL;
  c &= ~UNDERL;
  for (t = (char *) o_tr; *t; t++)
	if (*t++ == c) {
/*
 *	fix - last char translates to space.
 */
		c = *t ? *t : ' ';
		break;
	}
  if (page_no < startpage || (stoppage && page_no > stoppage)) return;
  if (c != ' ' && c != '\n' && n_blanks) {
	if (hflag && n_blanks > 1)
		while (col_no / 8 < (col_no + n_blanks) / 8) {
			putc('\t', stdout);
			n_blanks -= 8 - (col_no & 07);
			col_no = (8 + col_no) & ~07;
		}
	for (; n_blanks; n_blanks--) {
		putc(' ', stdout);
		col_no++;
	}
  }
  if (ulflag && isalnum(c)) fputs("_\b", stdout);
  if (c == ' ')
	n_blanks++;
  else {
	putc(c, stdout);
	col_no++;
  }
  if (c == '\n') {
	col_no = 0;
	n_blanks = 0;
  }
}

int suck()
{
  for (;;) {
	c = getc(File);
	if (islegal(c)) return c;
  }
}

/*
 *	strhas - does string have character?  Allow UNDERL flag.
 */

char *
 strhas(p, c)
char *p, c;
{
  for (; *p; p++)
	if ((*p & ~UNDERL) == c) return p;
  return NULL;
}

/*
 *	strend - find NULL at end of string.
 */

char *
 strend(p)
char *p;
{
  while (*p++);
  return p;
}

/*
 *	isspace, isalnum, isdigit, islegal - classify a character.
 *	We could just as well use <ctype.h> if it didn't vary from
 *	one version of Unix to another.  As it is, these routines
 *	must be modified for weird character sets, like EBCDIC and
 *	CDC Scientific.
 */

int isspace(c)
int c;
{
  char *s;
  for (s = spacechars; *s; s++)
	if (*s == c) return 1;
  return 0;
}

int isalnum(c)
int c;
{
  return(c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9');
}

int isdigit(c)
int c;
{
  return c >= '0' && c <= '9';
}

int islegal(c)
int c;
{
  return (c >= ' ' && c <= '~') || isspace(c) || c == '\n' || c == EOF;
}

void bomb()
{
  fprintf(stderr, "Usage: roff [+00] [-00] [-s] [-h] file ...\n");
  exit(1);
}
