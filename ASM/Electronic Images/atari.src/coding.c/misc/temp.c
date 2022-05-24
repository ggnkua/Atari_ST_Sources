#include <graph.h>
#include <conio.h>
#include <stdio.h>

#define _PIO    0x300
#define _CR     _PIO+3
#define _PA     _PIO
#define _PB     _PIO+1
#define _PC     _PIO+2

int swap(int data)
{
	int ret=0;
	ret+=8*(data&1);
	ret+=4*((data>>1)&1);
	ret+=2*((data>>2)&1);
	ret+=(data>>3)&1;
	return ret;
}


main()
{
	int d1,d2,d3,sign,cf;  /*d1=tens d2=units d3=tenths */
	unsigned int datain;

	_clearscreen( _GCLEARSCREEN );
	outp(_CR, 128+16+8+2+1);   /*          10011011*/


	while(!kbhit()){
		datain=inpw(_PA);

		sign=datain&1;
		cf=datain&4096;
		d1=(datain>>1)&0xf;
		d2=(datain>>5)&0xf;
		d3=(datain>>9)&0xf;

		d1=swap(d1);
		d2=swap(d2);
		d3=swap(d3);

		_settextposition( 0,0);
		printf( "Temperature:%d%d.%d", d1,d2,d3);
		printf( "\nsign: %d",sign);
		printf( "\ncf: %d",cf);
		printf("\nPort C:%X     ",inp( _PC ));
		/*else printf("\nStrobe off");*/
	}
	getch();
	return 0;
}



