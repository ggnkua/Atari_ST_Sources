/* @(#)aoutdump.c	1.1 */
#define	ushort	unsigned short

#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include "out.h"

_PROTOTYPE(int main, (int argc, char *argv []));
_PROTOTYPE(void p_head, (int part));
_PROTOTYPE(void p_sect, (int part));
_PROTOTYPE(void p_fill, (int part));
_PROTOTYPE(void p_relo, (int part));
_PROTOTYPE(void p_name, (int part));
_PROTOTYPE(void p_char, (int part));
_PROTOTYPE(void error, (char t, char *s, ...));
_PROTOTYPE(void getofmt, (char *p, char *s, FILE *f));

struct outhead	outhead;
struct outsect	outsect[S_MAX - S_MIN + 1];
struct outrelo	outrelo;
struct outname	outname;

char		options[] = "111111";
char		*progname;

int main(argc,argv)
int argc;
char *argv[];
{
	register char *filename = "a.out";

	progname = argv[0];
	if (argc > 3)
		error('f',"Usage: %s [filename [111111]]", progname);
	if (argc > 1)
		filename = argv[1];
	if (freopen(filename, "r", stdin) == (FILE *)NULL)
		error('f',"Couldn't open %s for input",filename);
	if (argc > 2) 
		strncpy(options,argv[2],6);
	p_head(0);
	p_sect(1);
	p_fill(2);
	p_relo(3);
	p_name(4);
	p_char(5);
	return(0);
}

void p_head(part)
int part;
{
	getofmt((char *)&outhead, SF_HEAD, stdin);
	if (options[part] != '1')
		return;
	printf("header:");
	printf("\toh_magic: 0x%04x\n", outhead.oh_magic);
	printf("\toh_stamp: %d\n", outhead.oh_stamp);
	printf("\toh_flags: 0x%04x\n", outhead.oh_flags);
	printf("\toh_nsect: %d\n", outhead.oh_nsect);
	printf("\toh_nrelo: %d\n", outhead.oh_nrelo);
	printf("\toh_nname: %d\n", outhead.oh_nname);
	printf("\toh_nemit: %ld\n", outhead.oh_nemit);
	printf("\toh_nchar: %ld\n", outhead.oh_nchar);
}

void p_sect(part)
int part;
{
	register struct outsect *sp;
	register i = 0;

	for (sp = outsect; sp < &outsect[outhead.oh_nsect]; sp++,i++) {
		getofmt((char *)sp, SF_SECT, stdin);
		if (options[part] != '1')
			continue;
		printf("\nsection %d header:\n", i);
		printf("\tos_base: 0x%lx\n", sp->os_base);
		printf("\tos_size: %ld\n", sp->os_size);
		printf("\tos_foff: %ld\n", sp->os_foff);
		printf("\tos_flen: %ld\n", sp->os_flen);
		printf("\tos_lign: %ld\n", sp->os_lign);
	}
}

void p_fill(part)
int part;
{
	register struct outsect *sp;
	register i = 0;
	register c;
	register long l;

	for (sp = outsect; sp < &outsect[outhead.oh_nsect]; sp++,i++) {
		if (ftell(stdin) != sp->os_foff)
			error(
				'f',
				"sp->os_foff (%ld) != ftell() (%ld)",
				sp->os_foff,
				ftell(stdin)
			);
		if (options[part] != '1') {
			fseek(stdin, sp->os_flen, 1);
			continue;
		}
		printf("\nsection %d filler:\n", i);
		for (l = 0; l < sp->os_flen; l++) {
			if ((l & 15) == 0)
				printf("%06lx: ", l);
			if ((c = getc(stdin)) == EOF)
				error('f', "EOF");
			printf(" %02x", c & 0xFF);
			if ((l & 15) == 15)
				printf("\n");
		}
		if ((l & 15) != 0)
			printf("\n");
	}
}

void p_relo(part)
int part;
{
	register i = 0;

	if (options[part] == '1')
		printf("\nrelocation:\n");
	for (i = 0; i < outhead.oh_nrelo; i++) {
		getofmt((char *)&outrelo, SF_RELO, stdin);
		if (options[part] != '1')
			continue;
		printf("%4d: t=%02x s=%02x i=%-5d a=%06lx\n",
			i,
			outrelo.or_type,
			outrelo.or_sect,
			outrelo.or_nami,
			outrelo.or_addr
		);
	}
}

void p_name(part)
int part;
{
	register i = 0;

	if (options[part] == '1')
		printf("\nsymbols:\n");
	for (i = 0; i < outhead.oh_nname; i++) {
		getofmt((char *)&outname, SF_NAME, stdin);
		if (options[part] != '1')
			continue;
		printf("%4d: o=%-6ld t=%04x d=%04x v=%ld\n",
			i,
			outname.on_foff,
			outname.on_type,
			outname.on_desc,
			outname.on_valu
		);
	}
}

void p_char(part)
int part;
{
	register long off;
	register i = 0;
	register c = 0;

	off = ftell(stdin);
	if (off != OFF_CHAR(outhead))
		error(
			'f',
			"char off (%ld) != ftell() (%ld)",
			OFF_CHAR(outhead),
			off
		);
	if (options[part] != '1')
		return;
	printf("\nstrings:\n");
	for (i = 0; i < outhead.oh_nchar; i++,off++) {
		if (c == 0)
			printf("%ld:\t", off);
		c = getc(stdin);
		if (c == EOF)
			error('f', "EOF");
		if (c >= ' ' && c < 0177)
			putchar(c);
		else if (c == 0)
			putchar('\n');
		else
			printf("\\%03o", c);
	}
}

#ifdef __STDC__
void error(char t,char *s, ...)
{
  	va_list args;
	va_start(args, s);

	fprintf(stderr,"%s: ",progname);
	vfprintf(stderr, s, args);
	fprintf(stderr,"\n");
	va_end(args);
	switch (t) {
	case 'w':
		return;
	case 'f':
		exit(1);
	case 'a':
		abort();
	default:
		error('w',"Illegal error type: '%c'",t);
	}
}
#else
/* VARARGS2 */
void error(t,s,a,b,c,d,e,f,g,h,i,j)
char t;
char *s;
{
	fprintf(stderr,"%s: ",progname);
	fprintf(stderr,s,a,b,c,d,e,f,g,h,i,j);
	fprintf(stderr,"\n");
	switch (t) {
	case 'w':
		return;
	case 'f':
		exit(1);
	case 'a':
		abort();
	default:
		error('w',"Illegal error type: '%c'",t);
	}
}
#endif

void getofmt(p, s, f)
register char	*p;
register char	*s;
register FILE	*f;
{
	register i;
	register long l;

	while (i = *s++) {
		switch (i) {
/*		case '0': p++; break; */
		case '1':
			*p++ = getc(f);
			break;
		case '2':
			i = getc(f);
			i |= (getc(f) << 8);
			*((short *)p) = i; p += sizeof(short);
			break;
		case '4':
			l = (long)getc(f);
			l |= ((long)getc(f) << 8);
			l |= ((long)getc(f) << 16);
			l |= ((long)getc(f) << 24);
			*((long *)p) = l; p += sizeof(long);
			break;
		default:
			error('f', "bad getofmt string");
		}
	}
	if (feof(f) || ferror(f))
		error('f', "read error");
}
