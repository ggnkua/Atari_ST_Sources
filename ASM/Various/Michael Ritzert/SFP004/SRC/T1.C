#include	<stdio.h>
#include	<stdlib.h>
#include	<math.h>

double _Float_(long,long,long,long);

main()	{
#ifdef EX
	double a=1.0, b=0.0, c=-1.1, d;
#else
	double a=-1.0, b=0.0, c=+1.1, d;
#endif
	union value {
		double v;
		unsigned long   V[2];
	} Val;

	printf(" Warum Nur? ");
	d= sqrt(c);
	printf("sqrt(%f)=%f\n",c,d);
	d= log(c);
	printf("ln  (%f)=%f\n",c,d);
	d= log10(c);
	printf("lg  (%f)=%f\n",c,d);

	Val.v = a/b;
	printf(" Warum Nur? ");
	printf( "%ld,%ld\n", Val.V[0],Val.V[1] );
	printf("%f/%f=%f\n",a,b,Val.v);
}
