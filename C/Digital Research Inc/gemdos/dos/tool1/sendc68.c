#include <stdio.h>
#include "cout.h"
#include "sendc68.h"

/* this program reads a c.out format binary file and converts*/
/*  it to the absolute ASCII load format acceptable by MACSBUG*/
/*  and then sends it down the standard output file*/

#define RBLEN 32	/*number of bytes per S1 record*/

long lseek();
long datastart=0;
long bssstart=0;

long loctr=0;
int pflg=0;
int bcnt=RBLEN;
char cksum=0;
int syno=0;
char *ofn=0;
int noclear=0;
struct hdr couthd={0};
int input;

main(argc,argv)
char **argv;
{
	long l,l1;
	register i,j;

#ifdef DRI
	if (fileargs(&argc, &argv)) {
		printf("Out of memory reading arguments\n");
		exit(1);
	}
#endif

	if(argc < 2 || argc > 3) {
		usage();
	}
	i = 1;
	if(*argv[1] == '-') {
		noclear++;
		i++;
	}
	openfile(argv[i++]);
	if(argc>i)
		usage();
	l1 = couthd.ch_tsize;
	loctr = couthd.ch_entry;
mloop:
	for(l=0; l<l1; l+= 2) {
		i = getw(input);
		outword(i);
		loctr += 2;
	}
	if(couthd.ch_magic==MAGIC1) {
		while(bcnt != RBLEN)	/*fill out the last S1 buffer*/
			outword(0);
		loctr = datastart;
	}
	l1 = couthd.ch_dsize;
	for(l=0; l<l1; l+= 2) {
		i = getw(input);
		outword(i);
		loctr += 2;
	}
	if(noclear==0) {
		if(couthd.ch_magic==MAGIC1) {
			while(bcnt != RBLEN)	/*fill out the last S1 buffer*/
				outword(0);
			loctr = bssstart;
		}
		l1 = couthd.ch_bsize;		/*size of bss*/
		while(l1 > 0) {
			outword(0);		/*clear the bss*/
			l1 -= 2;
			loctr += 2;
		}
	}
	while(bcnt != RBLEN)	/*fill out the last S1 buffer*/
		outword(0);
	printf("S9030000FC\n");
	exit(0);
}

openfile(ap)
char *ap;
{

	register char *p;

	p = ap;
	if((input=openb(p,0)) < 0) {
		printf("unable to open %s\n",p);
		exit(1);
	}
	ifilname = p;	/*point to current file name for error msgs*/
	if(read(input,&couthd,2) != 2) {
		printf("read error on file: %s\n",ifilname);
		exit(1);
	}
	lseek(input,0L,0);
	readhdr();				/*read file header*/
}

readhdr()
{
	register int i;
	register short *p;

	p = &couthd;
	for(i=0; i<HDSIZE/2; i++)
		*p++ = getw(input);
	if(couthd.ch_magic != MAGIC) {
		if(couthd.ch_magic==MAGIC1) {
			datastart.hiword = getw(input);
			datastart.loword = getw(input);
			bssstart.hiword = getw(input);
			bssstart.loword = getw(input);
		}
		else {
			printf("file format error: %s\n",ifilname);
			exit(1);
		}
	}
}

outword(i)
	register i;
{
	if(bcnt==RBLEN) {	/*beginning of record*/
		cksum = 0;
		if(loctr.hiword) {
			printf("S2");
			hexby(RBLEN+4);
			hexby(loctr.hiword);
		}
		else {
			printf("S1");
			hexby(RBLEN+3);	/*byte count*/
		}
		hexwd(loctr.loword);
	}
	hexwd(i);
	bcnt -= 2;
	if(bcnt==0) {
		hexby(-cksum-1);
		putchar('\n');
		bcnt = RBLEN;
	}
}

hexwd(i)
{
	hexby((i>>8)&0xff);
	hexby(i&0xff);
}

hexby(c)
{
	cksum += c;
	outhex((c>>4)&017);
	outhex(c&017);
}

outhex(x)
{
	if(x>=0 && x<=9)
		putchar(x+'0');
	else if(x>=10 && x<=15)
		putchar(x-10+'A');
	else
		exit(1);
}

int getw(fd)
int fd;
{
	int buf;
	if (read(fd, &buf, sizeof(int)) != sizeof(int))
		return( -1 );
	return( buf );
}

usage()
{
		printf("Usage: sendc68 [-] commandfile [>outputfile]\n");
		exit(1);
}
