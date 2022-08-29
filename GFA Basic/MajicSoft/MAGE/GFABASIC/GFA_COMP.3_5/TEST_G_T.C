#include <stdio.h>
#include "GFA_TC.H"

/*	test GFA-BASIC Array	*/
short test[] =
{ 0x8000, 0x0000, 0x0000, 0x03ff,	/*  1   */
  0x8000, 0x0000, 0x0000,-0x03ff,	/* -1   */
  0x8000, 0x0000, 0x0000, 0x03fe,	/*  0.5 */
  0xC000, 0x0000, 0x0000, 0x03ff,	/*  1.5 */
  0x8000, 0x0000, 0x0000, 0x03ff,	/*  1   */
};

/* 	Turbo C 1.1 Array	*/
double result[5];

void hexdump(short *test,int lines, int llen);

void main()
{
	int i;
	gfa_tc(test,result,5);
	for (i = 0;i < 5;i++)
		printf("%f ",result[i]);
	printf("\n");
	result[1] = 0.1;
	tc_gfa(result,test,5);
	hexdump(test,5,4);
}

#include "GFA_TC.C"		/* kann auch getrennt compiliert	*/
						/* und dann gelinkt werden			*/

void hexdump(short *test,int lines, int llen)
{
	int i;
	int l = 1;
	
	while(lines--)
		{
		printf("%4d: ",l++);
		for(i=0;i<llen;i++)
			printf("%04x ",*test++);
		printf("\n");
		}
}
		
