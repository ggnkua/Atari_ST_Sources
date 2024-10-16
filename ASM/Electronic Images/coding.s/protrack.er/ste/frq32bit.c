/* Amiga Period -> ST 16bit integer / 32bit Fraction convert. 	*/
/* Dodgy 'C' code By Griff.. (Compile with GCC 2.0 or above...) */
/* 12.5 khz table version                                       */

#include <stdio.h>
#define FILENAME "FRQ32BIT.TAB"
double frac(double x);

void main()
{	FILE *out;
	double per,work,freq_amiga=3579545.0,freq_st=12516.0;
	unsigned long i;
	void *x;
	out = fopen(FILENAME,"wb");
	x = (&i);
	for (per = 1 ; per <= (1024+256) ; per++) 
	{	work = (freq_amiga/per)/freq_st; /* whole part	*/
		i = work;
		i = i << 16;
		fwrite(x,2,1,out);		/* output int	*/
		i = (frac(work)*4294967296.0);
		fwrite(x,4,1,out);		/* output frac	*/
	}
	fclose(out);
}

double frac(double x)
{	int i;
	return (x - (i=x));
}