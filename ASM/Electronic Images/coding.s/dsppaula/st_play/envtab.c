#include <stdio.h>
#define FILENAME "ENV_TAB.TAB"
double frac(double x);

void main()
{	FILE *out;
	double per,work;
	/*double freq_st=25175000.0/(3.0*256.0);*/
	double freq_st=25000.0;
	unsigned long i=0;
	void *x=&i;
	out = fopen(FILENAME,"wb");
	fwrite(x,4,1,out);		
	fwrite(x,4,1,out);		
	for (per = 1 ; per <= (256) ; per++) 
	{	work = (2000000.0/per)/freq_st; 
		i = work;
		fwrite(x,4,1,out);		/* output int	*/
		i = (frac(work)*4294967296.0);
		fwrite(x,4,1,out);		/* output frac	*/
	}
	fclose(out);
}

double frac(double x)
{	int i;
	return (x - (i=x));
}