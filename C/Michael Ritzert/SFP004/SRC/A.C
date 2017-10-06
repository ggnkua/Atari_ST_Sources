#include <math.h>
#include <stdio.h>

 unsigned long dd[2];
#define D (*((double*)&dd[0]))
main()	{
	double a=2.4, b=2.5, c=2.6, d, e;
	d=modf(a,&e);
	printf(" %f %f\n",d,e);
	d=modf(b,&e);
	printf(" %f %f\n",d,e);
	d=modf(c,&e);
	printf(" %f %f\n",d,e);
	D = 0.0;
	printf(" %lx %lx\n", dd[0],dd[1]);
}
