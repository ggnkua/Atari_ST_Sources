/* Amiga Period -> ST 16bit integer / 32bit Fraction convert. 	*/
/* Dodgy 'C' code By Griff.. (Compile with GCC 2.0 or above...) */
/* Modified version for 25kHz replay routine */

#include <stdio.h>
#define FILENAME "FRQ32BI2.TAB"
double frac(double x);

void main()
{	FILE *out;
	double per,work,freq_amiga=3579545.0,freq_st=25033.0/2;
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
