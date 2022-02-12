/* @(#)astrip.c	1.4 */
#define	ushort	unsigned short

#include "out.h"
#include <sys/types.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

_PROTOTYPE(int main, (int argc, char **argv));
_PROTOTYPE(int strip, (char *name));
_PROTOTYPE(int copy, (char *fnam, char *tnam, FILE *fr, FILE *to, long size));
_PROTOTYPE(void getofmt, (char *p, char *s, FILE *f));
_PROTOTYPE(void putofmt, (char *p, char *s, FILE *f, char *fnam));

/*

	astrip -- remove symbols and relocation bits

*/

char	*tname;
FILE	*tf;
struct outhead buf;

int main(argc, argv)
int argc;
char **argv;
{
	int	status = 1;

	signal(SIGHUP, SIG_IGN);
	signal(SIGINT, SIG_IGN);
	signal(SIGQUIT, SIG_IGN);
	tname = mktemp("/tmp/sXXXXX");
	while(--argc) {
		if ((status = strip(argv[argc])) > 1)
			break;
	}
	unlink(tname);
	return(status);
}

int strip(name)
char *name;
{
	long size;
	FILE *f;

	if ((f = fopen(name,"r")) == (FILE *)NULL) {
		fprintf(stderr, "astrip: cannot open %s\n", name);
		return(1);
	}
	getofmt ((char *)&buf, SF_HEAD , f);
	if(BADMAGIC(buf)) {
		fprintf(stderr, "astrip: %s-- bad format\n", name);
		fclose(f);
		return(1);
	}
	size = OFF_RELO(buf) - SZ_HEAD;
	buf.oh_flags &= ~HF_LINK;
	buf.oh_nrelo = 0;
	buf.oh_nname = 0;
	buf.oh_nchar = 0;


	if ((tf = fopen(tname,"w")) == (FILE *)NULL) {
		fprintf(stderr, "astrip: cannot create temp file %s\n", tname);
		fclose(f);
		return(2);
	}
	fseek(tf, (long)0, 0);
	putofmt((char *)&buf,SF_HEAD,tf,tname);
	if(copy(name, tname, f, tf, size)) {
		fclose(f);
		fclose(tf);
		return(1);
	}
	fclose(f);
	fclose(tf);
	size += SZ_HEAD;
	if ((f = fopen(name,"w")) == (FILE *)NULL) {
		fprintf(stderr, "astrip: cannot write %s\n", name);
		return(1);
	}
	if ((tf = fopen(tname,"r")) == (FILE *)NULL) {
		fprintf(stderr, "astrip: cannot read temp file %s\n", tname);
		fclose(f);
		return(2);
	}
	fseek(tf, (long)0, 0);
	if(copy(tname, name, tf, f, size)) {
		fclose(f);
		fclose(tf);
		return(2);
	}

	fclose(f);
	fclose(tf);
	return(0);
}

int copy(fnam, tnam, fr, to, size)
char *fnam;
char *tnam;
long size;
FILE *fr,*to;
{
	register s, n;
	char lbuf[512];

	while(size != (long)0) {
		s = 512;
		if(size < 512)
			s = (int) size;
		n = fread(lbuf,1,s,fr);
		if(n != s) {
			fprintf(stderr, "astrip: unexpected eof on %s\n", fnam);
			return(1);
		}
		n = fwrite(lbuf,1,s,to);
		if(n != s) {
			fprintf(stderr, "astrip: write error on %s\n", tnam);
			return(1);
		}
		size -= (long)s;
	}
	return(0);
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
		case '\0':
			break;
		}
		break;
	}
}

void putofmt(p, s, f, fnam)
register char	*p;
register char	*s;
register FILE	*f;
char		*fnam;
{
	register i,j;
	register long l;

	while (j = *s++) {
		switch (j -= '0') {
/*		case 0: p++; break; */
		case 1:
			i = *p++; putc(i,f);
			break;
		case 2:
			i = *((short *)p); p += sizeof(short);
			putc(i,f);
			i>>=8; putc(i,f);
			break;
		case 4:
			l = *((long *)p); p += sizeof(long);
			putc((int)l,f);
			l >>=8; putc((int)l,f);
			l >>=8; putc((int)l,f);
			l >>=8; putc((int)l,f);
			break;
		default:
			break;
		}
		if (ferror(f)) fprintf(stderr, "astrip: write error on %s\n", fnam);
	}
}
