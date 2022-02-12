/*
 * check relo information of ACK object files
 * VS 20050724
 */

#define	uhsort	unsigned short

#include	"out.h"

#include	<stdlib.h>
#include	<ctype.h>
#include	<stdio.h>
#include	<string.h>

_PROTOTYPE(void dofile,  (char *fname));
_PROTOTYPE(void getofmt, (char *p, char *s, FILE *f));

int verbose = 0;

void main(argc, argv)
int argc;
char **argv;
{
	if (argc < 2) {
		fprintf(stderr, "falsche Anzahl Parameter\n");
		exit(1);
	}
	argv++;
	argc--;

	if (!strncmp(*argv, "-v", 2)) {
		verbose = 1;
		argv++;
		argc--;
	}

	while (argc > 0) {
		dofile(*argv);
		argv++;
		argc--;
	}
	exit(0);
}


void dofile(fname)
char *fname;
{
	FILE *fi;
	unsigned long i;
	struct outhead outhead;
	struct outrelo outrelo;
	unsigned int r1, r2, r4;
	
  	fi = fopen(fname,"r");
	if (fi == (FILE *) NULL) {
		fprintf(stderr, "Kann %s nicht oeffnen\n", fname);
		return;
	}
	
	getofmt((char *)&outhead, SF_HEAD, fi);
	if(BADMAGIC(outhead)) {
		fprintf(stderr, "%s bad format\n", fname);
		return;
	}
	
	fseek(fi, OFF_RELO(outhead), 0);
	
	r1 = 0;
	r2 = 0;
	r4 = 0;
	if (verbose)
		printf("%d Relos found\n", outhead.oh_nrelo);
	for (i=0; i<outhead.oh_nrelo; i++) {
		getofmt((char *)&outrelo, SF_RELO, fi);
		if (outrelo.or_type & RELPC) continue;
		if (outrelo.or_nami == outhead.oh_nname)
			continue;
		if ((outrelo.or_type & (RELBR|RELWR)) != (RELBR|RELWR)) {
			fprintf(stderr, "RELO %ld not for 680x0\n", i);
			continue;
		}
  		if ((outrelo.or_type & RELSZ) == RELO1) {
			if (verbose)
				printf("RELO %ld size RELO1 sect %d\n", i, outrelo.or_sect - S_MIN);
			r1++;
  		} else if ((outrelo.or_type & RELSZ) == RELO2) {
  			if (verbose)
				printf("RELO %ld size RELO2 sect %d\n", i, outrelo.or_sect - S_MIN);
			r2 ++;
		} else
			r4++;
		if (verbose)
			printf("%c %x %4d %5lx\n",
				"TRDB"[outrelo.or_sect-S_MIN],
				outrelo.or_type, outrelo.or_nami,
				outrelo.or_addr);
	}
	fclose(fi);
	if (r1 || r2) {
		printf("RELO1: %04d\n", r1);
		printf("RELO2: %04d\n", r2);
		printf("RELO4: %04d\n", r4);
	}
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

