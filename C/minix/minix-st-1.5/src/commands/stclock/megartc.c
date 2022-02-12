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

long	lseek();
long	time();
char	*ctime();

main(argc, argv)
char **argv;
{
	register i, n, d, ok;
	long ot, nt;
#ifdef DEBUG
	int debug = argc != 1;
#endif

	fd = open("/dev/mem", 2);
	if (fd < 0)
		fatal("cannot open /dev/mem for update (must be root)");
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
		printf("n=%d\n");
		for (i = N; --i >= 0; )
			printf("%2d", a[i]);
		printf("\n");
	}
#endif
	if (a[SECL] == 15)
		fatal("no RTC present");
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
	exit(0);
}

dd(i, min, max)
{
	register n;

	n = a[i] + 10 * a[i+1];
	if (n < min || n > max)
		fatal("ASSERT(%d >= %d && %d <= %d)", n, min, n, max);
	return(n);
}

r(i)
{
	char c;

	if (lseek(fd, AD_RTC + 2 * i + 1, 0) == -1)
		fatal("bad seek");
	if (read(fd, &c, 1) != 1)
		fatal("bad read");
	return(c & 0x0F);
}

fatal(s, a1, a2, a3, a4, a5)
char *s;
{
	printf("megartc: ");
	printf(s, a1, a2, a3, a4, a5);
	printf(" (fatal)\n");
	exit(1);
}
