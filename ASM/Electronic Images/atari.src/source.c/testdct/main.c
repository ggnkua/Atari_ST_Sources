#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define TEST (100000)

static short block[8][8];
int runtime;
clock_t tstart,tstop;

void print_time(clock_t s,clock_t e)
{	clock_t diff = e-s;
	float seconds = (time_t) (diff / CLOCKS_PER_SEC);
	float milli = ((float) (diff % CLOCKS_PER_SEC)) / CLOCKS_PER_SEC;
    	printf("%2.2f seconds\n",seconds+milli);
}

void main(void)
{	int i;
	init_dct();
	tstart = clock();
	for (i=0 ; i < TEST; i++)
	{	idct2(&block);
	}
	tstop = clock();
	print_time(tstart,tstop);
	tstart = clock();
	for (i=0 ; i < TEST; i++)
	{	idct3(&block);
	}
	tstop = clock();
	print_time(tstart,tstop);

}
