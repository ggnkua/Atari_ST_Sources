/*
 * Disk Cache statistics
 */

#include <osbind.h>
#include "cache.h"

#define	reg	register

int	verbose = 0;
extern	char *	c1_4f();

main(argc, argv)
	char **	argv;
{
  reg	int	i = 1, n;
  reg	short *	stats;
  reg	Cache *	cache;
	int	dev = 0
	int	total;

	if (i < argc && argv[i][0]=='-') {
		verbose = 1;
		i ++;
	}
	if (i < argc)
		if ('a' <= argv[i][0] && argv[i][0] <= 'z')
			dev = argv[i][0] - 'a';

	stats = Rwabs(CSTAT, 0L, 0, 0, dev);
	cache = Rwabs(CSTAT, 0L, 0, 1, dev);
	if (stats == NULL || cache == NULL) {
		printf("Cache not installed\n");
		return 1;
	}

	total = stats[0];
	if (total==0) {
		printf("No statistics yet\n");
		return 1;
	}

	printf("Cache hits %s, ",	c1_4f(stats[HITS], total));
	printf("Disk reads %s, ",	c1_4f(stats[READS]-stats[HITS], total));
	printf("Disk writes %s; ",	c1_4f(stats[WRITES], total));
	printf("Buffer reclaims%s\n",	c1_4f(stats[RECLMS], total));

	if (!verbose)
		return 0;

	n = 0;
	for (i = 0; i < NSECT; i ++) {
		short	avg, buf;
		avg = cache[i].avg;
		buf = cache[i].buf;
		if (avg > 0 || buf != NOBUF) {
		    printf("%4d%c%5s  ",
			i, (buf == NOBUF) ? '.' : ':', c1_4f(avg, total));
		    if (++n % 6 == 0)
			printf("\n");
		}
	}
	printf("\n");
	return 0;
}

/* convert a/b in %1.3f format */
char * c1_4f(a, b)
	int a, b;
{
	register int i;
	register long l;
	register char * p;
	static char buf [12];

	p = buf;
	l = a;
	i = a/b;
	*p++ = (0<i && i<=9) ? '0'+i : ' ';
	*p++ = '.';
	for (i = 1; i <= 4; i++) {
		l = 10*(l%b);
		*p++ = '0' + (short)(l/b);
	}
	*p = '\0';
	return buf;
}

