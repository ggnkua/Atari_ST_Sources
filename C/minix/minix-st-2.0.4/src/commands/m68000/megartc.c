#include <sys/types.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>

_PROTOTYPE(int main, (int argc, char **argv));
_PROTOTYPE(int dd, (int i, int min, int max));
_PROTOTYPE(int r, (int i));
_PROTOTYPE(void fatal1, (char *s));
_PROTOTYPE(void fatal5, (char *s, int a1, int a2, int a3, int a4));

#define	DEBUG

#define	AD_RTC	0xFFFC20

#define	SECL	0
#define	SECH	1
#define	MINL	2
#define	MINH	3
#define	HOURL	4
#define	HOURH	5
#define	WDAY	6
#define	DAYL	7
#define	DAYH	8
#define	MONL	9
#define	MONH	10
#define	YEARL	11
#define	YEARH	12
#define	X	13
#define	Y	14
#define	Z	15

#define	N	13

int	fd;
int	a[N];
int	m[12] = {31,28,31,30,31,30,31,31,30,31,30,31};

int main(argc, argv)
int argc;
char **argv;
{
	register i, n, d, ok;
	long ot, nt;
#ifdef DEBUG
	int debug = argc != 1;
#endif

	fd = open("/dev/mem", 2);
	if (fd < 0)
		fatal1("cannot open /dev/mem for update (must be root)");
	for (i = 0; i < N; i++)
		a[i] = r(i);
	for (n = 0; n < 10; n++) {
		ok = 1;
		for (i = 0; i < N; i++) {
			d = r(i);
			if (d != a[i]) {
				ok = 0;
				a[i] = d;
			}
		}
		if (ok)
			break;
	}
#ifdef DEBUG
	if (debug) {
		printf("n=%d\n", n);
		for (i = N; --i >= 0; )
			printf("%2d", a[i]);
		printf("\n");
	}
#endif
	if (a[SECL] == 15)
		fatal1("no RTC present");
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
		fatal1("cannot set time back\n");
	if (stime(&nt) < 0)
		fatal1("stime() failed");
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
		fatal5("ASSERT(%d >= %d && %d <= %d)", n, min, n, max);
	return(n);
}

int r(i)
int i;
{
	char c;

	if (lseek(fd, AD_RTC + 2 * i + 1, 0) == -1)
		fatal1("bad seek");
	if (read(fd, &c, 1) != 1)
		fatal1("bad read");
	return(c & 0x0F);
}

void fatal1(s)
char *s;
{
	printf("megartc: ");
	printf(s);
	printf(" (fatal)\n");
	exit(1);
}

void fatal5(s, a1, a2, a3, a4)
char *s;
int a1, a2, a3, a4;
{
	printf("megartc: ");
	printf(s, a1, a2, a3, a4);
	printf(" (fatal)\n");
	exit(1);
}
