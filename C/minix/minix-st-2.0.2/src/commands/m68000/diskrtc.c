#include <sys/types.h>
#include <minix/config.h>
#include <fcntl.h>
#include <sgtty.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <time.h>

_PROTOTYPE(int main, (int argc, char **argv));
_PROTOTYPE(int dd, (int i, int min, int max));
_PROTOTYPE(void fatal, (char *s, ...));

#define	DEBUG

#define	AD_RTC	0xFFFC20

#define	SECL	0
#define	SECH	1
#define	MINL	2
#define	MINH	3
#define	HOURL	4
#define	HOURH	5

#define	DAYL	7
#define	DAYH	8
#define	MONL	9
#define	MONH	10
#define	YEARL	11
#define	YEARH	12

#define	N	13

int	fd;
unsigned char	a[N];
int	m[12] = {31,28,31,30,31,30,31,31,30,31,30,31};

int main(argc, argv)
int argc;
char **argv;
{
	register int i, n;
	int x;
	long ot, nt;
#ifdef DEBUG
	int debug = argc != 2;
#endif
	if(argc == 1) {
usage:
		fatal("Usage: %s [bms1|bms2|supra|icd]\n",argv[0]);
		exit(1);
	}
	if(strcmp(argv[1],"bms1") == 0)
		x = DC_RBMS100;
	else if(strcmp(argv[1],"bms2") == 0)
		x =  DC_RBMS200;
	else if(strcmp(argv[1],"supra") == 0)
		x =  DC_RSUPRA;
	else if(strcmp(argv[1],"icd") == 0)
		x =  DC_RICD;
	else
		goto usage;

	fd = open("/dev/rhd0", 0);
	if (fd < 0)
		fatal("cannot open /dev/rhd0 ");
	for(n=0;n<3;n++) {
		i = ioctl(fd,x,(struct sgttyb *)a);
		if(i <0) {
			perror("read");
			printf("read (ioctl) returned %d\n",i);
			exit(1);
		}
		if (a[SECL] == 15)
			fatal("no RTC present");
		break;
	}
if(debug)
	printf("bms: %x %x %x %x  %x %x %x %x  %x %x %x %x %x\n",
	  a[0],a[1],a[2],a[3],a[4],a[5],a[6],a[7],a[8],a[9],a[10],a[11],a[12]);
	a[HOURH] &= 3;
	nt = 0;
	i = dd(YEARL, 0, 99);
	if ((i & 3) == 0)
		m[1]++;
	i += 80;
	while (--i >= 70) {
		nt += 365;
		if ((i & 3) == 0)
			nt++;
	}
	i = dd(MONL, 1, 12)-1;
	while (--i >= 0)
		nt += m[i];
	nt += dd(DAYL, 1, 31) - 1;
	nt *= 24;
	nt += dd(HOURL, 0, 23);
	nt *= 60;
	nt += dd(MINL, 0, 59);
	nt *= 60;
	nt += dd(SECL, 0, 59);
	time(&ot);
#ifdef DEBUG
	if (debug) {
		printf("old time = (%ld) %s\n", ot, ctime(&ot));
		printf("new time = (%ld) %s\n", nt, ctime(&nt));
	}
#endif
	if (ot > nt)
		fatal("cannot set time back\n");
	if (stime(&nt) < 0)
		fatal("stime() failed");
	return(0);
}

int dd(i, min, max)
int i;
int min;
int max;
{
	register int n;

	n = a[i] + 10 * a[i+1];
	if (n < min || n > max)
		fatal("ASSERT(idx=%d %d >= %d && %d <= %d)", i, n, min, n, max);
	return(n);
}


#ifdef __STDC__
void fatal(char *s, ...)
{
	va_list args;

	va_start(args, s);
	fprintf(stderr, "bmsrtc: ");
	vfprintf(stderr, s, args);
	fprintf(stderr, " (fatal)\n");
	va_end(args);
	exit(1);
}
#else
void fatal(s, a1, a2, a3, a4, a5)
char *s;
int a1, a2, a3, a4, a5;
{
	fprintf(stderr, "diskrtc: ");
	fprintf(stderr, s, a1, a2, a3, a4, a5);
	fprintf(stderr, " (fatal)\n");
	exit(1);
}
#endif
