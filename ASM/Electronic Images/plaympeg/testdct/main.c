#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>
#include <string.h>
#include "types.h"

#define TEST (10000)
#define CLOCKS_PER_SEC CLK_TCK
static INT16 srcblock[8][8];
static INT16 testblock[8][8];
long runtime;
clock_t tstart,tstop;

void print_time(clock_t s,clock_t e)
{	clock_t diff = e-s;
   	printf("%ld ticks\n",diff);
}

void main(void)
{	long i,j;
	init_fastidct();
	tstart = clock();
	
	for (i=0 ; i < 8; i++)
	{	for (j=0 ; j < 8; j++)
		{	srcblock[i][j] = (rand() % 1024)- 512;
		}
	}
	
	for (i=0 ; i < TEST; i++)
	{	memcpy(testblock,srcblock,128);
		idct(&srcblock[0][0]);
	}
	tstop = clock();
	print_time(tstart,tstop);
	
	tstart = clock();
	for (i=0 ; i < TEST; i++)
	{	memcpy(testblock,srcblock,128);
		idctasm(&srcblock[0][0]);
	}
	tstop = clock();
	print_time(tstart,tstop);

	tstart = clock();
	for (i=0 ; i < TEST; i++)
	{	memcpy(testblock,srcblock,128);
		fastidct(&srcblock[0][0]);
	}
	tstop = clock();
	print_time(tstart,tstop);

}
