#include <stdio.h>
#include <math.h>

main()	{
	static unsigned long min_d[2] =
		{ 0x01000000L, 0x00000001L };
	static unsigned long max_d[2] =
		{ 0x400fffffL, 0xffffffffL };
	static unsigned long min_f =
		  0x00800001L;
	static unsigned long max_f =
		  0x3fffffffL;
	double d;
	float  f;

	f = (*((float *)&min_f));
	printf("#define FLT_MIN %23.15e\n",(double)f);

	f=(float)log10((double)f);
	printf("#define FLT_MIN_10_EXP %d\n",(int)f);

	f = (*((float *)&max_f));
	printf("#define FLT_MAX %23.15e\n",(double)f);

	f=(float)log10((double)f);
	printf("#define FLT_MAX_10_EXP %d\n",(int)f);

	d = (*((double *)&min_d[0]));
	printf("#define DBL_MIN %23.15e\n",d);

	d = log10(f);
	printf("#define DBL_MIN_10_EXP -%d\n",(int)d);
	   /* Maximum int x such that FLT_RADIX**(x-1) is a representable double */

	d = *((double *)&max_d[0]);
	printf("#define DBL_MAX %23.15e\n",d);
	   /* Maximum int x such that 10**x is a representable double */

	d = log10(f);
	printf("#define DBL_MAX_10_EXP %d\n",(int)d);
	   /* Maximum double */

}
