#include <sys/types.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>

_PROTOTYPE(int main, (int argc, char **argv));
_PROTOTYPE(int r, (int i));
_PROTOTYPE(void fatal1, (char *s));

#define	DEBUG

#define	AD_RTC_CMD	0xFFFF8961L
#define	AD_RTC_DATA	0xFFFF8963L

#define	DM	4

#define	SEC	0
#define	MIN	2
#define	HOUR	4
#define	WDAY	6
#define	DAY	7
#define	MON	8
#define	YEAR	9
#define	A	10
#define	B	11
#define	C	12
#define	D	13

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

	if (geteuid() != 0) {
		fatal1("must be root to set the time\n");
	}
	fd = open("/dev/mem", 2);
	if (fd < 0)
		fatal1("cannot open /dev/mem for update");
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
	if (a[DAY] == 0)
		fatal1("no RTC present");
	if (a[B] & DM)	/* binary mode */
	{
		if (a[HOUR] >= 0x80)	/* PM in 12 hour mode */
			a[HOUR] = a[HOUR] - 0x80 + 12;
	}
	else /* bcd mode */
	{
		a[SEC]  = (a[SEC]  >> 4) * 10 + (a[SEC]  & 0xf);
		a[MIN]  = (a[MIN]  >> 4) * 10 + (a[MIN]  & 0xf);
		if (a[HOUR] >= 0x80)	/* PM in 12 hour mode */
		{
			a[HOUR] = a[HOUR] - 0x80;
			a[HOUR] = (a[HOUR] >> 4) * 10 + (a[HOUR] & 0xf);
			a[HOUR] = a[HOUR] + 12;
		}
		else
		{
			a[HOUR] = (a[HOUR] >> 4) * 10 + (a[HOUR] & 0xf);
		}
		a[DAY]  = (a[DAY]  >> 4) * 10 + (a[DAY]  & 0xf);
		a[MON]  = (a[MON]  >> 4) * 10 + (a[MON]  & 0xf);
		a[YEAR] = (a[YEAR] >> 4) * 10 + (a[YEAR] & 0xf);
	}
	nt = 0;
	i = a[YEAR];
	if ((i & 3) == 0)
		m[1]++;
	i += 68;
	while (--i >= 70) {
		nt += 365;
		if ((i & 3) == 0)
			nt++;
	}
	i = a[MON] - 1;
	while (--i >= 0)
		nt += m[i];
	nt += a[DAY] - 1;
	nt *= 24;
	nt += a[HOUR];
	nt *= 60;
	nt += a[MIN];
	nt *= 60;
	nt += a[SEC];
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

int r(i)
int i;
{
	char c = i;

	if (lseek(fd, AD_RTC_CMD, 0) == -1)
		fatal1("bad seek");
	if (write(fd, &c, 1) != 1)
		fatal1("bad write");
	if (lseek(fd, AD_RTC_DATA, 0) == -1)
		fatal1("bad seek");
	if (read(fd, &c, 1) != 1)
		fatal1("bad read");
	return(c);
}

void fatal1(s)
char *s;
{
	printf("ttrtc: ");
	printf(s);
	printf(" (fatal)\n");
	exit(1);
}
